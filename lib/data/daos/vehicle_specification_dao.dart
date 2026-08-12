import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/vehicle_specifications.dart';

part 'vehicle_specification_dao.g.dart';

@DriftAccessor(tables: [VehicleSpecifications])
class VehicleSpecificationDao extends DatabaseAccessor<AppDatabase>
    with _$VehicleSpecificationDaoMixin {
  VehicleSpecificationDao(super.db);

  Stream<VehicleSpecification?> watchFor(int vehicleId) {
    return (select(vehicleSpecifications)
          ..where((s) => s.vehicleId.equals(vehicleId)))
        .watchSingleOrNull();
  }

  Future<VehicleSpecification?> getFor(int vehicleId) {
    return (select(vehicleSpecifications)
          ..where((s) => s.vehicleId.equals(vehicleId)))
        .getSingleOrNull();
  }

  /// Inserta la ficha técnica si el vehículo no tenía ninguna, o la
  /// sustituye si ya existía. La relación es 1:1 por `vehicleId`, así que
  /// no hace falta distinguir alta de edición desde fuera.
  Future<void> guardar(VehicleSpecificationsCompanion datos) {
    return into(vehicleSpecifications).insertOnConflictUpdate(datos);
  }
}
