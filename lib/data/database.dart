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
  int get schemaVersion => 5;

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
      // v4 -> v5: se añade la fuente del intervalo de cada mantenimiento.
      //
      // OJO, trampa documentada en CLAUDE.md: no basta con "if (from < 5)".
      // La tabla maintenance_schedules se crea en el paso "from < 3" de
      // arriba con la definición ACTUAL de la clase Dart, que para este
      // código ya incluye fuenteIntervalo. Un usuario que salte de v1 o v2
      // directo a v5 ejecutaría ese "createTable" con la columna ya
      // dentro, y si este paso también corriera, intentaría añadirla otra
      // vez: "duplicate column name". La guarda "from >= 3" limita este
      // paso a quien ya tenía la tabla sin esta columna (v3 o v4), que es
      // el único caso real en el que hace falta.
      if (from >= 3 && from < 5) {
        await m.addColumn(
          maintenanceSchedules,
          maintenanceSchedules.fuenteIntervalo,
        );
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
