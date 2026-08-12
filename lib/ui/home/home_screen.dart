import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/maintenance_due.dart';
import '../../providers/mantenimiento_providers.dart';
import '../../providers/providers.dart';
import '../common/empty_state.dart';
import '../common/estado_chip.dart';
import '../common/vencimiento_texto.dart';
import '../maintenance/register_maintenance_sheet.dart';
import '../mileage/update_mileage_sheet.dart';
import '../vehicle/vehicle_detail_screen.dart';
import '../vehicle/vehicle_form_screen.dart';
import 'vehicle_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiculos = ref.watch(vehiculosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis vehículos')),
      body: vehiculos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) {
          debugPrint('Error al cargar los vehículos: $e\n$st');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No se han podido cargar los vehículos. '
                    'Inténtalo de nuevo.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(databaseProvider),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (lista) {
          if (lista.isEmpty) {
            return const EmptyState(
              icono: Icons.directions_car_outlined,
              titulo: 'Todavía no hay vehículos',
              descripcion:
                  'Añade tu primer coche para empezar a llevar su kilometraje.',
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              for (final vehiculo in lista) ...[
                VehicleCard(vehiculo: vehiculo),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 8),
              _ProximosMantenimientosGlobal(vehiculos: lista),
            ],
          );
        },
      ),
      floatingActionButton: vehiculos.maybeWhen(
        data: (lista) => lista.isEmpty
            ? FloatingActionButton.extended(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VehicleFormScreen()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Vehículo'),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'nuevo-vehiculo',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const VehicleFormScreen(),
                      ),
                    ),
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton.extended(
                    heroTag: 'actualizar-km',
                    onPressed: () => _pedirKilometraje(context, lista),
                    icon: const Icon(Icons.speed),
                    label: const Text('Kilometraje'),
                  ),
                ],
              ),
        orElse: () => null,
      ),
    );
  }

  Future<void> _pedirKilometraje(
    BuildContext context,
    List<Vehicle> vehiculos,
  ) async {
    if (vehiculos.length == 1) {
      return mostrarHojaKilometraje(context, vehiculo: vehiculos.single);
    }

    final elegido = await showModalBottomSheet<Vehicle>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: vehiculos
              .map((v) => ListTile(
                    leading: const Icon(Icons.directions_car_outlined),
                    title: Text('${v.marca} ${v.modelo}'),
                    onTap: () => Navigator.of(context).pop(v),
                  ))
              .toList(),
        ),
      ),
    );

    if (elegido != null && context.mounted) {
      await mostrarHojaKilometraje(context, vehiculo: elegido);
    }
  }
}

/// Resumen de todos los vehículos: lo que hace de esta pantalla la respuesta
/// a "¿tengo algo pendiente?" en tres segundos, sin entrar en cada ficha.
///
/// Solo entra lo que de verdad pide vigilancia —vencido, lo que pide
/// atención y lo próximo—, ordenado por la misma urgencia que usa cada
/// ficha. Lo que ya está "al día" no aporta nada a un resumen de pendientes,
/// y un mantenimiento recién configurado sin ningún registro ("sin datos")
/// tampoco tiene una cifra que enseñar aquí. Se recorta a un máximo: la
/// lista completa, coche a coche, ya vive en la ficha de cada uno.
class _ProximosMantenimientosGlobal extends ConsumerWidget {
  final List<Vehicle> vehiculos;

  const _ProximosMantenimientosGlobal({required this.vehiculos});

  static const _maximoVisibles = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final estados = [
      for (final v in vehiculos) ref.watch(vencimientosProvider(v.id)),
    ];

    if (estados.any((e) => !e.hasValue && !e.hasError)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    AsyncValue<List<MantenimientoConVencimiento>>? conError;
    for (final estado in estados) {
      if (estado.hasError) {
        conError = estado;
        break;
      }
    }
    if (conError != null) {
      debugPrint(
        'Error al cargar los próximos mantenimientos: '
        '${conError.error}\n${conError.stackTrace}',
      );
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No se han podido cargar los próximos mantenimientos. '
              'Inténtalo de nuevo.',
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                for (final v in vehiculos) {
                  ref.invalidate(vencimientosProvider(v.id));
                }
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final todos = <(Vehicle, MantenimientoConVencimiento)>[];
    for (var i = 0; i < vehiculos.length; i++) {
      for (final item in estados[i].value ?? const []) {
        todos.add((vehiculos[i], item));
      }
    }

    // Sin ningún mantenimiento configurado en ningún vehículo no hay nada
    // que resumir aquí: cada tarjeta ya lo dice por su cuenta y ofrece
    // configurarlo. No es lo mismo que "todo al día" y no debe leerse así.
    if (todos.isEmpty) return const SizedBox.shrink();

    final pendientes = todos.where((par) {
      final estado = par.$2.vencimiento.estado;
      return estado == EstadoMantenimiento.vencido ||
          estado == EstadoMantenimiento.atencion ||
          estado == EstadoMantenimiento.proximo;
    }).toList()
      ..sort(
        (a, b) =>
            urgenciaVencimiento(a.$2).compareTo(urgenciaVencimiento(b.$2)),
      );

    if (pendientes.isEmpty) {
      // "Todo al día" solo puede decirse de lo que sí está configurado: un
      // vehículo sin ningún mantenimiento no genera pendientes porque no hay
      // nada que calcular, no porque esté cuidado. Si el banner callara esto,
      // le daría al usuario permiso para no mirar justo lo que debería mirar.
      final sinConfigurar = <Vehicle>[
        for (var i = 0; i < vehiculos.length; i++)
          if ((estados[i].value ?? const []).isEmpty) vehiculos[i],
      ];

      final mensaje = sinConfigurar.isEmpty
          ? 'Todo al día. No hay ningún mantenimiento pendiente.'
          : 'Todo al día en lo configurado. ${_nombresVehiculos(sinConfigurar)} '
              '${sinConfigurar.length == 1 ? 'todavía no tiene' : 'todavía no tienen'} '
              'ningún mantenimiento configurado.';

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const EstadoChip(estado: EstadoMantenimiento.ok),
              const SizedBox(width: 12),
              Expanded(
                child: Text(mensaje, style: tema.textTheme.bodyMedium),
              ),
            ],
          ),
        ),
      );
    }

    final visibles = pendientes.take(_maximoVisibles).toList();
    final restantes = pendientes.length - visibles.length;
    final avisoRitmo = necesitaAvisoRitmoSupuesto(
      visibles.map((par) => par.$2.vencimiento),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Próximos mantenimientos', style: tema.textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final par in visibles)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FilaVencimientoGlobal(vehiculo: par.$1, item: par.$2),
          ),
        if (restantes > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              restantes == 1
                  ? 'Y 1 mantenimiento más pendiente, en su ficha.'
                  : 'Y $restantes mantenimientos más pendientes, en cada '
                      'ficha.',
              style: tema.textTheme.bodySmall
                  ?.copyWith(color: tema.colorScheme.outline),
            ),
          ),
        if (avisoRitmo)
          Text(
            avisoRitmoSupuesto,
            style: tema.textTheme.bodySmall
                ?.copyWith(color: tema.colorScheme.outline),
          ),
      ],
    );
  }
}

/// Los nombres de una lista de vehículos en una frase legible: "Seat León
/// ST", "Seat León ST y BMW X3" o "Seat León ST, BMW X3 y Audi A4".
String _nombresVehiculos(List<Vehicle> vehiculos) {
  final nombres = vehiculos.map((v) => '${v.marca} ${v.modelo}').toList();
  if (nombres.length == 1) return nombres.single;
  return '${nombres.sublist(0, nombres.length - 1).join(', ')} y ${nombres.last}';
}

/// Una fila de la lista global: igual que una fila de mantenimiento de la
/// ficha, pero identificando a qué vehículo pertenece, porque aquí se
/// mezclan los de todos.
class _FilaVencimientoGlobal extends StatelessWidget {
  final Vehicle vehiculo;
  final MantenimientoConVencimiento item;

  const _FilaVencimientoGlobal({required this.vehiculo, required this.item});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final v = item.vencimiento;
    final resumen = resumenVencimiento(v);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VehicleDetailScreen(vehiculo: vehiculo),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.schedule.nombre,
                      style: tema.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${vehiculo.marca} ${vehiculo.modelo}',
                      style: tema.textTheme.bodySmall
                          ?.copyWith(color: tema.colorScheme.outline),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resumen.isEmpty ? 'Sin datos todavía' : resumen,
                      style: tema.textTheme.bodySmall
                          ?.copyWith(color: tema.colorScheme.outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              EstadoChip(estado: v.estado),
              IconButton(
                icon: const Icon(Icons.fact_check_outlined),
                tooltip: 'Registrar realizado',
                onPressed: () => mostrarRegistroMantenimiento(
                  context,
                  vehicleId: vehiculo.id,
                  schedule: item.schedule,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
