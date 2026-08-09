import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/vehicles.dart';

part 'vehicle_dao.g.dart';

@DriftAccessor(tables: [Vehicles])
class VehicleDao extends DatabaseAccessor<AppDatabase> with _$VehicleDaoMixin {
  VehicleDao(super.db);

  Stream<List<Vehicle>> watchActivos() {
    return (select(vehicles)
          ..where((v) => v.archivado.equals(false))
          ..orderBy([(v) => OrderingTerm(expression: v.creadoEn)]))
        .watch();
  }

  Future<Vehicle?> getById(int id) {
    return (select(vehicles)..where((v) => v.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertar(VehiclesCompanion vehiculo) {
    return into(vehicles).insert(vehiculo);
  }

  Future<bool> actualizar(Vehicle vehiculo) {
    return update(vehicles).replace(vehiculo);
  }

  Future<int> archivar(int id) {
    return (update(vehicles)..where((v) => v.id.equals(id)))
        .write(const VehiclesCompanion(archivado: Value(true)));
  }
}
