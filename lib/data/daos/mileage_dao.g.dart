// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mileage_dao.dart';

// ignore_for_file: type=lint
mixin _$MileageDaoMixin on DatabaseAccessor<AppDatabase> {
  $VehiclesTable get vehicles => attachedDatabase.vehicles;
  $MileageReadingsTable get mileageReadings => attachedDatabase.mileageReadings;
  MileageDaoManager get managers => MileageDaoManager(this);
}

class MileageDaoManager {
  final _$MileageDaoMixin _db;
  MileageDaoManager(this._db);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db.attachedDatabase, _db.vehicles);
  $$MileageReadingsTableTableManager get mileageReadings =>
      $$MileageReadingsTableTableManager(
        _db.attachedDatabase,
        _db.mileageReadings,
      );
}
