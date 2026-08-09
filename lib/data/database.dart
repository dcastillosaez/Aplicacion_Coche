import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/vehicle_dao.dart';
import 'tables/mileage_readings.dart';
import 'tables/settings.dart';
import 'tables/vehicles.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Vehicles, MileageReadings, Settings],
  daos: [VehicleDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_abrirConexion());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
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
