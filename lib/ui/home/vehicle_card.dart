import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/photo_storage.dart';
import '../../providers/mantenimiento_providers.dart';
import '../../providers/providers.dart';
import '../common/estado_chip.dart';
import '../common/formatters.dart';
import '../common/vencimiento_texto.dart';
import '../theme/app_theme.dart';
import '../vehicle/vehicle_detail_screen.dart';

class VehicleCard extends ConsumerWidget {
  final Vehicle vehiculo;

  const VehicleCard({super.key, required this.vehiculo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final lectura = ref.watch(ultimaLecturaProvider(vehiculo.id));
    final ritmo = ref.watch(ritmoUsoProvider(vehiculo.id));
    final estado = ref.watch(estadoVehiculoProvider(vehiculo.id));
    final vencimientos = ref.watch(vencimientosProvider(vehiculo.id));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VehicleDetailScreen(vehiculo: vehiculo),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vehiculo.fotoPath != null)
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Image.file(
                  File(PhotoStorage.absoluta(vehiculo.fotoPath!)),
                  fit: BoxFit.cover,
                  // Si el fichero ya no está en disco, no se rompe la tarjeta.
                  errorBuilder: (_, _, _) => Container(
                    color: tema.colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.directions_car_outlined,
                      size: 32,
                      color: tema.colorScheme.outline,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          '${vehiculo.marca} ${vehiculo.modelo}',
                          style: tema.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (vehiculo.colorValor != null) ...[
                        const SizedBox(width: 8),
                        _DistintivoColor(valor: vehiculo.colorValor!),
                      ],
                    ],
                  ),
                  if (vehiculo.version != null)
                    Text(
                      vehiculo.version!,
                      style: tema.textTheme.bodySmall
                          ?.copyWith(color: tema.colorScheme.outline),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: lectura.when(
                          loading: () => const SizedBox(height: 40),
                          error: (e, st) {
                            debugPrint(
                              'Error al cargar el kilometraje: $e\n$st',
                            );
                            return const Text('No se ha podido cargar');
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
                      const SizedBox(width: 8),
                      // Distintivo de estado general: se oculta en carga o
                      // error, igual que el ritmo de uso de más abajo, sin
                      // romper el resto de la tarjeta. El detalle del error
                      // sigue siendo visible en la ficha del vehículo.
                      estado.when(
                        loading: () => const SizedBox.shrink(),
                        error: (e, st) {
                          debugPrint('Error al cargar el estado: $e\n$st');
                          return const SizedBox.shrink();
                        },
                        data: (e) => EstadoChip(estado: e),
                      ),
                    ],
                  ),
                  ritmo.maybeWhen(
                    data: (r) => r.esPorDefecto
                        ? const SizedBox.shrink()
                        : Text(
                            r.cocheParado
                                ? 'Prácticamente parado'
                                : '≈ ${r.kmPorDia.round()} km al día',
                            style: tema.textTheme.bodySmall
                                ?.copyWith(color: tema.colorScheme.outline),
                          ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                  // Los mantenimientos más próximos, igual que el resto de
                  // la tarjeta: se resuelven aparte, así que un fallo aquí
                  // no tapa el kilometraje ni el estado general de arriba.
                  vencimientos.when(
                    loading: () => const SizedBox.shrink(),
                    error: (e, st) {
                      debugPrint(
                        'Error al cargar los mantenimientos: $e\n$st',
                      );
                      return const SizedBox.shrink();
                    },
                    data: (lista) => _ProximosVencimientos(lista: lista),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Los mantenimientos más próximos del vehículo, para responder de un
/// vistazo a "¿tengo algo pendiente?" sin tener que entrar en la ficha.
///
/// Sin ningún mantenimiento configurado, el coche no está "al día": está sin
/// configurar. Se dice explícitamente, y no con una lista vacía que se
/// leería como que todo está correcto.
class _ProximosVencimientos extends StatelessWidget {
  final List<MantenimientoConVencimiento> lista;

  const _ProximosVencimientos({required this.lista});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    if (lista.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.build_outlined,
              size: 16,
              color: tema.colorScheme.outline,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Sin mantenimientos configurados. Toca para añadirlos.',
                style: tema.textTheme.bodySmall
                    ?.copyWith(color: tema.colorScheme.outline),
              ),
            ),
          ],
        ),
      );
    }

    // vencimientosProvider ya la devuelve ordenada por urgencia: los tres
    // primeros son los tres más próximos.
    final proximos = lista.take(3).toList();
    final avisoRitmo = necesitaAvisoRitmoSupuesto(
      proximos.map((m) => m.vencimiento),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in proximos)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _FilaVencimientoCompacta(item: item),
            ),
          if (avisoRitmo)
            Text(
              avisoRitmoSupuesto,
              style: tema.textTheme.bodySmall
                  ?.copyWith(color: tema.colorScheme.outline),
            ),
        ],
      ),
    );
  }
}

class _FilaVencimientoCompacta extends StatelessWidget {
  final MantenimientoConVencimiento item;

  const _FilaVencimientoCompacta({required this.item});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final v = item.vencimiento;
    final resumen = resumenVencimiento(v);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.schedule.nombre,
                style: tema.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                resumen.isEmpty ? 'Sin datos todavía' : resumen,
                style: tema.textTheme.bodySmall
                    ?.copyWith(color: tema.colorScheme.outline),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        EstadoChip(estado: v.estado),
      ],
    );
  }
}

/// Distintivo discreto con el tono del vehículo. El color en esta app se
/// reserva para comunicar estado de mantenimiento, así que aquí es
/// deliberadamente pequeño: un punto junto al nombre, no un fondo.
class _DistintivoColor extends StatelessWidget {
  final int valor;

  const _DistintivoColor({required this.valor});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Semantics(
      label: 'Color del vehículo',
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(valor),
          border: Border.all(color: tema.colorScheme.outlineVariant),
        ),
      ),
    );
  }
}
