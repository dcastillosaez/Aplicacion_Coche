import 'dart:io';

import 'package:car_care/data/database.dart';
import 'package:car_care/data/tables/maintenance_schedules.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
// sqlite3 es una dependencia transitiva de drift, no una directa: se usa
// aquí solo para levantar a mano una base de datos con el esquema de la
// versión 1 y comprobar la migración contra ella.
// ignore: depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// Comprueba que una base de datos creada con el esquema de la versión 1
/// (sin la columna `color_valor` en `vehicles`) se actualiza a la versión 2
/// sin perder los vehículos que ya tenía guardados, y que la columna nueva
/// queda a nulo para esas filas antiguas.
void main() {
  test(
    'migrar de v1 a v2 conserva los vehículos y añade colorValor a nulo',
    () async {
      final dir = await Directory.systemTemp.createTemp('car_care_migracion');
      final fichero = File(p.join(dir.path, 'v1.sqlite'));
      addTearDown(() => dir.delete(recursive: true));

      // 1. Se crea a mano una base de datos con el esquema tal y como
      //    quedaría en una instalación previa a este cambio (schemaVersion
      //    1: sin la columna color_valor) y se inserta un vehículo, como si
      //    la app llevara tiempo en uso.
      final crudo = sqlite3.sqlite3.open(fichero.path);
      crudo.execute('''
        CREATE TABLE vehicles (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          marca TEXT NOT NULL,
          modelo TEXT NOT NULL,
          version TEXT NULL,
          anio INTEGER NULL,
          matricula TEXT NULL,
          combustible TEXT NOT NULL,
          fecha_matriculacion INTEGER NULL,
          color TEXT NULL,
          foto_path TEXT NULL,
          vin TEXT NULL,
          notas TEXT NULL,
          creado_en INTEGER NOT NULL,
          archivado INTEGER NOT NULL DEFAULT 0
        );
      ''');
      crudo.execute('''
        CREATE TABLE mileage_readings (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
          fecha INTEGER NOT NULL,
          km INTEGER NOT NULL,
          origen TEXT NOT NULL,
          UNIQUE(vehicle_id, fecha)
        );
      ''');
      crudo.execute('''
        CREATE TABLE settings (
          id INTEGER NOT NULL DEFAULT 1,
          aviso_km_por_defecto INTEGER NOT NULL DEFAULT 1000,
          aviso_dias_por_defecto INTEGER NOT NULL DEFAULT 30,
          dias_recordatorio_lectura INTEGER NOT NULL DEFAULT 15,
          tema TEXT NOT NULL DEFAULT 'automatico',
          fecha_ultima_copia INTEGER NULL,
          PRIMARY KEY (id)
        );
      ''');

      final ahora = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      crudo.execute(
        '''
        INSERT INTO vehicles
          (marca, modelo, version, combustible, color, creado_en, archivado)
        VALUES
          (?, ?, ?, ?, ?, ?, 0);
        ''',
        ['Seat', 'León', 'FR 1.5 TSI', 'gasolina', 'Azul', ahora],
      );
      crudo.execute('INSERT INTO settings DEFAULT VALUES;');
      crudo.execute('PRAGMA user_version = 1;');
      crudo.close();

      // 2. Se abre esa misma base de datos con AppDatabase, cuyo esquema en
      //    código ya está en la versión 2: drift debe detectar el salto de
      //    versión y ejecutar `onUpgrade` en vez de crear las tablas desde
      //    cero (lo que sí borraría los datos).
      final db = AppDatabase.forTesting(NativeDatabase(fichero));

      final version = await db
          .customSelect('PRAGMA user_version')
          .getSingle();
      // AppDatabase migra siempre hasta su schemaVersion actual en una sola
      // pasada: al abrir una base de datos en v1 ejecuta todos los pasos de
      // onUpgrade pendientes (incluido el de v2 a v3), así que el resultado
      // es la versión vigente del esquema, no la 2.
      expect(version.data['user_version'], 3);

      final vehiculos = await db.select(db.vehicles).get();
      expect(vehiculos, hasLength(1));
      final vehiculo = vehiculos.single;
      expect(vehiculo.marca, 'Seat');
      expect(vehiculo.modelo, 'León');
      expect(vehiculo.version, 'FR 1.5 TSI');
      expect(vehiculo.color, 'Azul');
      // La columna es nueva: para una fila que ya existía antes de la
      // migración no hay tono guardado, así que debe quedar a nulo.
      expect(vehiculo.colorValor, isNull);

      await db.close();
    },
  );

  test(
    'migrar de v2 a v3 conserva los vehículos y crea las tablas de '
    'mantenimientos',
    () async {
      final dir = await Directory.systemTemp.createTemp('car_care_migracion');
      final fichero = File(p.join(dir.path, 'v2.sqlite'));
      addTearDown(() => dir.delete(recursive: true));

      // Esquema de la versión 2: como el de la 1 pero con color_valor, y
      // todavía sin ninguna tabla de mantenimientos.
      final crudo = sqlite3.sqlite3.open(fichero.path);
      crudo.execute('''
        CREATE TABLE vehicles (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          marca TEXT NOT NULL,
          modelo TEXT NOT NULL,
          version TEXT NULL,
          anio INTEGER NULL,
          matricula TEXT NULL,
          combustible TEXT NOT NULL,
          fecha_matriculacion INTEGER NULL,
          color TEXT NULL,
          color_valor INTEGER NULL,
          foto_path TEXT NULL,
          vin TEXT NULL,
          notas TEXT NULL,
          creado_en INTEGER NOT NULL,
          archivado INTEGER NOT NULL DEFAULT 0
        );
      ''');
      crudo.execute('''
        CREATE TABLE mileage_readings (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
          fecha INTEGER NOT NULL,
          km INTEGER NOT NULL,
          origen TEXT NOT NULL,
          UNIQUE(vehicle_id, fecha)
        );
      ''');
      crudo.execute('''
        CREATE TABLE settings (
          id INTEGER NOT NULL DEFAULT 1,
          aviso_km_por_defecto INTEGER NOT NULL DEFAULT 1000,
          aviso_dias_por_defecto INTEGER NOT NULL DEFAULT 30,
          dias_recordatorio_lectura INTEGER NOT NULL DEFAULT 15,
          tema TEXT NOT NULL DEFAULT 'automatico',
          fecha_ultima_copia INTEGER NULL,
          PRIMARY KEY (id)
        );
      ''');

      final ahora = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      crudo.execute(
        '''
        INSERT INTO vehicles
          (marca, modelo, combustible, creado_en, archivado)
        VALUES (?, ?, ?, ?, 0);
        ''',
        ['Mercedes-Benz', 'Clase B', 'diesel', ahora],
      );
      crudo.execute(
        'INSERT INTO mileage_readings (vehicle_id, fecha, km, origen) '
        'VALUES (1, ?, 142350, ?);',
        [ahora, 'manual'],
      );
      crudo.execute('INSERT INTO settings DEFAULT VALUES;');
      crudo.execute('PRAGMA user_version = 2;');
      crudo.close();

      final db = AppDatabase.forTesting(NativeDatabase(fichero));

      final version =
          await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.data['user_version'], 3);

      // Lo que ya había sigue ahí.
      final vehiculos = await db.select(db.vehicles).get();
      expect(vehiculos, hasLength(1));
      expect(vehiculos.single.marca, 'Mercedes-Benz');
      expect(vehiculos.single.modelo, 'Clase B');

      final lecturas = await db.select(db.mileageReadings).get();
      expect(lecturas, hasLength(1));
      expect(lecturas.single.km, 142350);

      // Las tablas nuevas existen, están vacías y se pueden usar.
      expect(await db.select(db.maintenanceSchedules).get(), isEmpty);
      expect(await db.select(db.maintenanceRecords).get(), isEmpty);

      final idSchedule = await db.into(db.maintenanceSchedules).insert(
            MaintenanceSchedulesCompanion.insert(
              vehicleId: 1,
              nombre: 'Aceite y filtro',
              categoria: MaintenanceCategory.motor,
              intervalKm: const Value(15000),
              intervalMeses: const Value(12),
            ),
          );
      final guardado = await (db.select(db.maintenanceSchedules)
            ..where((s) => s.id.equals(idSchedule)))
          .getSingle();
      expect(guardado.nombre, 'Aceite y filtro');
      expect(guardado.intervalKm, 15000);
      expect(guardado.activo, isTrue);

      await db.close();
    },
  );
}
