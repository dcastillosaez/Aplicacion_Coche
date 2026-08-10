import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers/providers.dart';
import '../common/formatters.dart';
import '../theme/app_theme.dart';
import '../vehicle/vehicle_form_screen.dart';

class VehicleCard extends ConsumerWidget {
  final Vehicle vehiculo;

  const VehicleCard({super.key, required this.vehiculo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final lectura = ref.watch(ultimaLecturaProvider(vehiculo.id));
    final ritmo = ref.watch(ritmoUsoProvider(vehiculo.id));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VehicleFormScreen(vehiculo: vehiculo),
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
                  File(vehiculo.fotoPath!),
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
                  Text(
                    '${vehiculo.marca} ${vehiculo.modelo}',
                    style: tema.textTheme.titleMedium,
                  ),
                  if (vehiculo.version != null)
                    Text(
                      vehiculo.version!,
                      style: tema.textTheme.bodySmall
                          ?.copyWith(color: tema.colorScheme.outline),
                    ),
                  const SizedBox(height: 16),
                  lectura.when(
                    loading: () => const SizedBox(height: 40),
                    error: (e, _) => Text('Error: $e'),
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
