import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../domain/usage_rate.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final vehiculosProvider = StreamProvider<List<Vehicle>>((ref) {
  return ref.watch(databaseProvider).vehicleDao.watchActivos();
});

/// Todos los vehículos, activos y archivados: para pantallas que necesitan
/// nombrar cualquier vehículo que aparezca en sus datos, como el historial,
/// no solo los que se gestionan hoy desde Inicio.
final vehiculosTodosProvider = StreamProvider<List<Vehicle>>((ref) {
  return ref.watch(databaseProvider).vehicleDao.watchTodos();
});

final ultimaLecturaProvider = StreamProvider.family<MileageReading?, int>((
  ref,
  vehicleId,
) {
  return ref.watch(databaseProvider).mileageDao.watchUltima(vehicleId);
});

final vehicleSpecificationProvider =
    StreamProvider.family<VehicleSpecification?, int>((ref, vehicleId) {
      return ref
          .watch(databaseProvider)
          .vehicleSpecificationDao
          .watchFor(vehicleId);
    });

final ritmoUsoProvider = FutureProvider.family<UsageRateResult, int>((
  ref,
  vehicleId,
) async {
  final db = ref.watch(databaseProvider);
  final ahora = DateTime.now();
  final lecturas = await db.mileageDao.lecturasDesde(
    vehicleId,
    ahora.subtract(const Duration(days: kVentanaDias)),
  );

  return UsageRate.calcular(
    lecturas: lecturas
        .map((l) => MileagePoint(fecha: l.fecha, km: l.km))
        .toList(),
    ahora: ahora,
  );
});
