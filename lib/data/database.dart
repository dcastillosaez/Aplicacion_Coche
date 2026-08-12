import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/maintenance_dao.dart';
import 'daos/mileage_dao.dart';
import 'daos/vehicle_dao.dart';
import 'daos/vehicle_specification_dao.dart';
import 'tables/maintenance_records.dart';
import 'tables/maintenance_schedules.dart';
import 'tables/mileage_readings.dart';
import 'tables/settings.dart';
import 'tables/vehicle_specifications.dart';
import 'tables/vehicles.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Vehicles,
    MileageReadings,
    Settings,
    MaintenanceSchedules,
    MaintenanceRecords,
    VehicleSpecifications,
  ],
  daos: [VehicleDao, MileageDao, MaintenanceDao, VehicleSpecificationDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_abrirConexion());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      // v1 -> v2: se añade el tono del color (entero ARGB) junto al
      // nombre de color ya existente, para poder pintar un distintivo
      // en la tarjeta del vehículo sin perder el nombre editable.
      if (from < 2) {
        await m.addColumn(vehicles, vehicles.colorValor);
      }
      // v2 -> v3: se añaden las tablas de mantenimientos configurados y
      // realizados.
      if (from < 3) {
        await m.createTable(maintenanceSchedules);
        await m.createTable(maintenanceRecords);
      }
      // v3 -> v4: se añade la ficha técnica del vehículo.
      if (from < 4) {
        await m.createTable(vehicleSpecifications);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) {
        await into(settings).insert(const SettingsCompanion());
      }
    },
  );
}

LazyDatabase _abrirConexion() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final fichero = File(p.join(dir.path, 'car_care.sqlite'));
    return NativeDatabase.createInBackground(fichero);
  });
}
