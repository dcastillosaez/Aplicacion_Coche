// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_specification_dao.dart';

// ignore_for_file: type=lint
mixin _$VehicleSpecificationDaoMixin on DatabaseAccessor<AppDatabase> {
  $VehiclesTable get vehicles => attachedDatabase.vehicles;
  $VehicleSpecificationsTable get vehicleSpecifications =>
      attachedDatabase.vehicleSpecifications;
  VehicleSpecificationDaoManager get managers =>
      VehicleSpecificationDaoManager(this);
}

class VehicleSpecificationDaoManager {
  final _$VehicleSpecificationDaoMixin _db;
  VehicleSpecificationDaoManager(this._db);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db.attachedDatabase, _db.vehicles);
  $$VehicleSpecificationsTableTableManager get vehicleSpecifications =>
      $$VehicleSpecificationsTableTableManager(
        _db.attachedDatabase,
        _db.vehicleSpecifications,
      );
}
