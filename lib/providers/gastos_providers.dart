import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../domain/gastos.dart';
import 'mantenimiento_providers.dart';
import 'providers.dart';

/// Un vehículo con lo que se ha gastado en él.
class GastosDeVehiculo {
  final Vehicle vehiculo;
  final ResumenGastos resumen;

  const GastosDeVehiculo({required this.vehiculo, required this.resumen});
}

/// Gastos de cada vehículo activo, en el mismo orden en que los devuelve
/// `vehiculosProvider`.
///
/// Los vehículos archivados quedan fuera, igual que en Inicio: la pantalla
/// responde a "cuánto me cuestan los coches que tengo", no a un balance
/// histórico de todo lo que ha pasado por el garaje.
final gastosProvider = FutureProvider<List<GastosDeVehiculo>>((ref) async {
  final vehiculos = await ref.watch(vehiculosProvider.future);
  final registros = await ref.watch(historialProvider.future);

  return [
    for (final vehiculo in vehiculos)
      GastosDeVehiculo(
        vehiculo: vehiculo,
        resumen: calcularResumenGastos([
          for (final r in registros)
            if (r.vehicleId == vehiculo.id) (fecha: r.fecha, coste: r.coste),
        ]),
      ),
  ];
});
