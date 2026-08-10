import 'dart:io';

import 'package:car_care/data/database.dart';
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
      expect(version.data['user_version'], 2);

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
}
