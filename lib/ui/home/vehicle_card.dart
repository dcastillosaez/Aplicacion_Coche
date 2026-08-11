import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/photo_storage.dart';
import '../../providers/mantenimiento_providers.dart';
import '../../providers/providers.dart';
import '../common/estado_chip.dart';
import '../common/formatters.dart';
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
                ],
              ),
            ),
          ],
        ),
      ),
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
