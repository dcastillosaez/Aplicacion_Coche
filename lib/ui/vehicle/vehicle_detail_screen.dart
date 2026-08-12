import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/photo_storage.dart';
import '../../domain/maintenance_grouping.dart';
import '../../domain/origen_mantenimiento.dart';
import '../../providers/mantenimiento_providers.dart';
import '../../providers/providers.dart';
import '../common/estado_chip.dart';
import '../common/formatters.dart';
import '../common/origen_chip.dart';
import '../common/vencimiento_texto.dart';
import '../maintenance/maintenance_form_screen.dart';
import '../maintenance/register_maintenance_sheet.dart';
import '../theme/app_theme.dart';
import 'vehicle_form_screen.dart';
import 'vehicle_specification_screen.dart';

/// Ficha del vehículo: de un vistazo, su estado general, lo que toca antes
/// de nada, y el detalle de cada mantenimiento configurado. Punto de
/// entrada a editar el vehículo, registrar lo ya hecho y dar de alta
/// mantenimientos nuevos.
class VehicleDetailScreen extends ConsumerWidget {
  final Vehicle vehiculo;

  const VehicleDetailScreen({super.key, required this.vehiculo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vencimientos = ref.watch(vencimientosProvider(vehiculo.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('${vehiculo.marca} ${vehiculo.modelo}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.badge_outlined),
            tooltip: 'Identidad técnica',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    VehicleSpecificationScreen(vehicleId: vehiculo.id),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar vehículo',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VehicleFormScreen(vehiculo: vehiculo),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          _Cabecera(vehiculo: vehiculo),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: vencimientos.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, st) {
                debugPrint('Error al cargar los mantenimientos: $e\n$st');
                return Column(
                  children: [
                    const Text(
                      'No se han podido cargar los mantenimientos. '
                      'Inténtalo de nuevo.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          ref.invalidate(vencimientosProvider(vehiculo.id)),
                      child: const Text('Reintentar'),
                    ),
                  ],
                );
              },
              data: (lista) =>
                  _ContenidoMantenimientos(vehiculo: vehiculo, lista: lista),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'nuevo-mantenimiento',
            tooltip: 'Añadir mantenimiento',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MaintenanceFormScreen(vehicleId: vehiculo.id),
              ),
            ),
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'registrar-mantenimiento',
            onPressed: () =>
                mostrarRegistroMantenimiento(context, vehicleId: vehiculo.id),
            icon: const Icon(Icons.fact_check_outlined),
            label: const Text('Registrar'),
          ),
        ],
      ),
    );
  }
}

/// Foto, kilometraje real (nunca el proyectado) y distintivo de estado
/// general. Cada dato depende de un provider distinto y se resuelve por
/// separado, para que un fallo en uno no tape a los demás.
class _Cabecera extends ConsumerWidget {
  final Vehicle vehiculo;

  const _Cabecera({required this.vehiculo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final lectura = ref.watch(ultimaLecturaProvider(vehiculo.id));
    final estado = ref.watch(estadoVehiculoProvider(vehiculo.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: vehiculo.fotoPath == null
              ? _marcador(tema)
              : Image.file(
                  File(PhotoStorage.absoluta(vehiculo.fotoPath!)),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  // El fichero puede haberse perdido: no se rompe la ficha.
                  errorBuilder: (_, _, _) => _marcador(tema),
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: lectura.when(
                  loading: () => const SizedBox(height: 40),
                  error: (e, st) {
                    debugPrint('Error al cargar el kilometraje: $e\n$st');
                    return const Text('No se ha podido cargar el kilometraje');
                  },
                  data: (l) => Text(
                    l == null ? 'Sin kilometraje' : formatearKm(l.km),
                    style: tema.textTheme.headlineMedium?.merge(
                      AppTheme.cifras.copyWith(
                        color: tema.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              estado.when(
                loading: () => const SizedBox(width: 90, height: 28),
                error: (e, st) {
                  debugPrint('Error al cargar el estado general: $e\n$st');
                  return const Text('Estado no disponible');
                },
                data: (e) => EstadoChip(estado: e),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _marcador(ThemeData tema) => Container(
    color: tema.colorScheme.surfaceContainerHighest,
    alignment: Alignment.center,
    child: Icon(
      Icons.directions_car_outlined,
      size: 40,
      color: tema.colorScheme.outline,
    ),
  );
}

/// Cuerpo de la ficha una vez resueltos los vencimientos: o bien la
/// invitación a configurar el primer mantenimiento, o bien lo más próximo
/// destacado y la lista completa.
class _ContenidoMantenimientos extends StatelessWidget {
  final Vehicle vehiculo;
  final List<MantenimientoConVencimiento> lista;

  const _ContenidoMantenimientos({required this.vehiculo, required this.lista});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    // Sin ningún mantenimiento dado de alta, el coche no está "al día": está
    // sin configurar. Se distingue con su propio bloque, no con una lista
    // vacía que parecería un falso todo correcto.
    if (lista.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              Icons.build_outlined,
              size: 48,
              color: tema.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Sin mantenimientos configurados',
              style: tema.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Añade los mantenimientos habituales del coche para saber qué '
              'toca y cuándo.',
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MaintenanceFormScreen(vehicleId: vehiculo.id),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Añadir mantenimiento'),
            ),
          ],
        ),
      );
    }

    // vencimientosProvider ya devuelve la lista ordenada por urgencia: el
    // primero es lo más próximo, tanto para destacarlo como para encabezar
    // la lista completa de abajo.
    final destacado = lista.first;
    final avisoRitmo = necesitaAvisoRitmoSupuesto(
      lista.map((m) => m.vencimiento),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lo más próximo', style: tema.textTheme.titleSmall),
        const SizedBox(height: 8),
        _TarjetaDestacada(item: destacado),
        if (avisoRitmo) ...[
          const SizedBox(height: 8),
          Text(
            avisoRitmoSupuesto,
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.outline,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text('Mantenimientos', style: tema.textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final grupo in agruparPorProximidad(
          lista.map((m) => m.vencimiento).toList(),
          const MaintenanceGroupingPolicy(),
        ))
          if (grupo.length == 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FilaMantenimiento(
                vehiculo: vehiculo,
                item: lista[grupo.single],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GrupoMantenimientos(
                vehiculo: vehiculo,
                items: [for (final i in grupo) lista[i]],
              ),
            ),
      ],
    );
  }
}

/// Varios mantenimientos cuyos vencimientos caen lo bastante cerca (según
/// [agruparPorProximidad]) como para convenir hacerlos en la misma visita
/// al taller. Reutiliza [_FilaMantenimiento] tal cual para cada uno —misma
/// tarjeta, mismo comportamiento al tocarla— y añade un marco y una
/// cabecera que los presenta como conjunto.
class _GrupoMantenimientos extends StatelessWidget {
  final Vehicle vehiculo;
  final List<MantenimientoConVencimiento> items;

  const _GrupoMantenimientos({required this.vehiculo, required this.items});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: tema.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tema.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              children: [
                Icon(
                  Icons.merge_type,
                  size: 18,
                  color: tema.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Puedes hacer esto junto y ahorrar una visita al taller',
                    style: tema.textTheme.bodySmall?.copyWith(
                      color: tema.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FilaMantenimiento(vehiculo: vehiculo, item: item),
            ),
        ],
      ),
    );
  }
}

class _TarjetaDestacada extends StatelessWidget {
  final MantenimientoConVencimiento item;

  const _TarjetaDestacada({required this.item});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final v = item.vencimiento;
    final lineas = [
      textoKmRestantes(v),
      textoDiasRestantes(v),
      textoDiasEstimadosPorKm(v),
      textoProximoKm(v),
      textoProximaFecha(v),
    ].whereType<String>().toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.schedule.nombre,
                    style: tema.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                EstadoChip(estado: v.estado),
                const SizedBox(width: 8),
                OrigenChip(
                  origen: calcularOrigen(item.ultimoRegistro?.esSembrado),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (lineas.isEmpty)
              Text(
                'Aún no se ha registrado. Sin un primer dato no se puede '
                'calcular cuándo toca.',
                style: tema.textTheme.bodyMedium?.copyWith(
                  color: tema.colorScheme.outline,
                ),
              )
            else
              for (final linea in lineas)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(linea, style: tema.textTheme.bodyMedium),
                ),
          ],
        ),
      ),
    );
  }
}

class _FilaMantenimiento extends ConsumerWidget {
  final Vehicle vehiculo;
  final MantenimientoConVencimiento item;

  const _FilaMantenimiento({required this.vehiculo, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final v = item.vencimiento;
    final resumen = resumenVencimiento(v);
    final patronReal = ref.watch(patronRealProvider(item.schedule.id)).value;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MaintenanceFormScreen(
              vehicleId: vehiculo.id,
              schedule: item.schedule,
            ),
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
                    Text(item.schedule.nombre, style: tema.textTheme.bodyLarge),
                    const SizedBox(height: 4),
                    Text(
                      resumen.isEmpty ? 'Sin datos todavía' : resumen,
                      style: tema.textTheme.bodySmall?.copyWith(
                        color: tema.colorScheme.outline,
                      ),
                    ),
                    if (patronReal != null)
                      Text(
                        'Tu patrón habitual: cambias cada '
                        '≈ ${formatearKm(patronReal.kmMedioEntreCambios.round())}',
                        style: tema.textTheme.bodySmall?.copyWith(
                          color: tema.colorScheme.outline,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              EstadoChip(estado: v.estado),
              const SizedBox(width: 8),
              OrigenChip(
                origen: calcularOrigen(item.ultimoRegistro?.esSembrado),
              ),
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
