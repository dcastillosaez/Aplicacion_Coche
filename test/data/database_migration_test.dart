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

      final version = await db.customSelect('PRAGMA user_version').getSingle();
      // AppDatabase migra siempre hasta su schemaVersion actual en una sola
      // pasada: al abrir una base de datos en v1 ejecuta todos los pasos de
      // onUpgrade pendientes (incluidos los de v2 a v3, v3 a v4, v4 a v5 y
      // v5 a v6), así que el resultado es la versión vigente del esquema,
      // no la 2.
      expect(version.data['user_version'], 6);

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

  test('migrar de v2 a v3 conserva los vehículos y crea las tablas de '
      'mantenimientos', () async {
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

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    // Igual que en el test de v1 a v2: la migración llega de un salto
    // hasta la versión vigente del esquema (incluidos los pasos de v3 a v4,
    // v4 a v5 y v5 a v6), no se queda en la 3.
    expect(version.data['user_version'], 6);

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

    final idSchedule = await db
        .into(db.maintenanceSchedules)
        .insert(
          MaintenanceSchedulesCompanion.insert(
            vehicleId: 1,
            nombre: 'Aceite y filtro',
            categoria: MaintenanceCategory.motor,
            intervalKm: const Value(15000),
            intervalMeses: const Value(12),
          ),
        );
    final guardado = await (db.select(
      db.maintenanceSchedules,
    )..where((s) => s.id.equals(idSchedule))).getSingle();
    expect(guardado.nombre, 'Aceite y filtro');
    expect(guardado.intervalKm, 15000);
    expect(guardado.activo, isTrue);

    await db.close();
  });

  test(
    'migrar de v3 a v4 conserva los vehículos y crea la ficha técnica',
    () async {
      final dir = await Directory.systemTemp.createTemp('car_care_migracion');
      final fichero = File(p.join(dir.path, 'v3.sqlite'));
      addTearDown(() => dir.delete(recursive: true));

      // Esquema de la versión 3: como el de la 2, más las tablas de
      // mantenimientos, y todavía sin ficha técnica.
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
      crudo.execute('''
        CREATE TABLE maintenance_schedules (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
          nombre TEXT NOT NULL,
          categoria TEXT NOT NULL,
          interval_km INTEGER NULL,
          interval_meses INTEGER NULL,
          aviso_km INTEGER NULL,
          aviso_dias INTEGER NULL,
          activo INTEGER NOT NULL DEFAULT 1,
          silenciado INTEGER NOT NULL DEFAULT 0,
          orden INTEGER NOT NULL DEFAULT 0
        );
      ''');
      crudo.execute('''
        CREATE TABLE maintenance_records (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
          schedule_id INTEGER NULL REFERENCES maintenance_schedules(id) ON DELETE SET NULL,
          fecha INTEGER NOT NULL,
          km INTEGER NOT NULL,
          coste REAL NULL,
          taller TEXT NULL,
          notas TEXT NULL,
          es_sembrado INTEGER NOT NULL DEFAULT 0
        );
      ''');

      final ahora = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      crudo.execute(
        '''
        INSERT INTO vehicles
          (marca, modelo, combustible, creado_en, archivado)
        VALUES (?, ?, ?, ?, 0);
        ''',
        ['BMW', 'Serie 3', 'diesel', ahora],
      );
      crudo.execute('INSERT INTO settings DEFAULT VALUES;');
      crudo.execute('PRAGMA user_version = 3;');
      crudo.close();

      final db = AppDatabase.forTesting(NativeDatabase(fichero));

      final version = await db.customSelect('PRAGMA user_version').getSingle();
      // La migración llega de un salto hasta la versión vigente del
      // esquema (incluidos los pasos de v4 a v5 y v5 a v6), no se queda
      // en la 4.
      expect(version.data['user_version'], 6);

      // Lo que ya había sigue ahí.
      final vehiculos = await db.select(db.vehicles).get();
      expect(vehiculos, hasLength(1));
      expect(vehiculos.single.marca, 'BMW');
      expect(vehiculos.single.modelo, 'Serie 3');

      // La tabla nueva existe, está vacía y se puede usar.
      expect(await db.select(db.vehicleSpecifications).get(), isEmpty);

      final vehicleId = vehiculos.single.id;
      await db
          .into(db.vehicleSpecifications)
          .insert(
            VehicleSpecificationsCompanion.insert(
              vehicleId: Value(vehicleId),
              motorCodigo: const Value('B47'),
            ),
          );
      final guardada = await (db.select(
        db.vehicleSpecifications,
      )..where((s) => s.vehicleId.equals(vehicleId))).getSingle();
      expect(guardada.motorCodigo, 'B47');

      await db.close();
    },
  );

  test('migrar de v4 a v5 conserva los mantenimientos y añade la fuente '
      'orientativa por defecto', () async {
    final dir = await Directory.systemTemp.createTemp('car_care_migracion');
    final fichero = File(p.join(dir.path, 'v4.sqlite'));
    addTearDown(() => dir.delete(recursive: true));

    // Esquema de la versión 4: como el de la 3, más la ficha técnica del
    // vehículo, y todavía sin fuenteIntervalo en maintenance_schedules.
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
    crudo.execute('''
        CREATE TABLE maintenance_schedules (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
          nombre TEXT NOT NULL,
          categoria TEXT NOT NULL,
          interval_km INTEGER NULL,
          interval_meses INTEGER NULL,
          aviso_km INTEGER NULL,
          aviso_dias INTEGER NULL,
          activo INTEGER NOT NULL DEFAULT 1,
          silenciado INTEGER NOT NULL DEFAULT 0,
          orden INTEGER NOT NULL DEFAULT 0
        );
      ''');
    crudo.execute('''
        CREATE TABLE maintenance_records (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
          schedule_id INTEGER NULL REFERENCES maintenance_schedules(id) ON DELETE SET NULL,
          fecha INTEGER NOT NULL,
          km INTEGER NOT NULL,
          coste REAL NULL,
          taller TEXT NULL,
          notas TEXT NULL,
          es_sembrado INTEGER NOT NULL DEFAULT 0
        );
      ''');
    crudo.execute('''
        CREATE TABLE vehicle_specifications (
          vehicle_id INTEGER NOT NULL PRIMARY KEY REFERENCES vehicles(id) ON DELETE CASCADE,
          generacion TEXT NULL,
          motor_codigo TEXT NULL,
          cilindrada_cc INTEGER NULL,
          potencia_kw INTEGER NULL,
          tipo_caja TEXT NULL,
          numero_marchas INTEGER NULL,
          traccion TEXT NULL,
          codigo_tecnico TEXT NULL,
          notas_tecnicas TEXT NULL
        );
      ''');

    final ahora = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    crudo.execute(
      '''
        INSERT INTO vehicles
          (marca, modelo, combustible, creado_en, archivado)
        VALUES (?, ?, ?, ?, 0);
        ''',
      ['Seat', 'León ST', 'diesel', ahora],
    );
    crudo.execute(
      '''
        INSERT INTO maintenance_schedules
          (vehicle_id, nombre, categoria, interval_km)
        VALUES (1, ?, ?, 15000);
        ''',
      ['Aceite y filtro', 'motor'],
    );
    crudo.execute('INSERT INTO settings DEFAULT VALUES;');
    crudo.execute('PRAGMA user_version = 4;');
    crudo.close();

    final db = AppDatabase.forTesting(NativeDatabase(fichero));

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    // La migración llega de un salto hasta la versión vigente del esquema
    // (incluido el paso de v5 a v6), no se queda en la 5.
    expect(version.data['user_version'], 6);

    // Lo que ya había sigue ahí.
    final vehiculos = await db.select(db.vehicles).get();
    expect(vehiculos, hasLength(1));
    expect(vehiculos.single.marca, 'Seat');

    final schedules = await db.select(db.maintenanceSchedules).get();
    expect(schedules, hasLength(1));
    expect(schedules.single.nombre, 'Aceite y filtro');

    // La columna nueva existe y, para una fila que ya existía antes de
    // la migración, toma el valor por defecto: orientativo.
    expect(schedules.single.fuenteIntervalo, FuenteIntervalo.orientativo);

    await db.close();
  });

  test('saltar de v2 a v5 de un tiro no falla por columna duplicada', () async {
    final dir = await Directory.systemTemp.createTemp('car_care_migracion');
    final fichero = File(p.join(dir.path, 'v2.sqlite'));
    addTearDown(() => dir.delete(recursive: true));

    // Esquema de la versión 2: vehículos con color_valor ya añadido,
    // pero sin ninguna tabla de mantenimientos ni ficha técnica todavía.
    // Es el caso que dispararía la trampa: el paso "from < 3" de abajo
    // va a crear maintenance_schedules con la definición actual de la
    // clase, que ya incluye fuenteIntervalo.
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
    crudo.execute('INSERT INTO settings DEFAULT VALUES;');
    crudo.execute('PRAGMA user_version = 2;');
    crudo.close();

    // Si la guarda estuviera mal (por ejemplo, "if (from < 5)" a secas),
    // esta línea lanzaría con "duplicate column name: fuente_intervalo".
    final db = AppDatabase.forTesting(NativeDatabase(fichero));

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    // La migración llega de un salto hasta la versión vigente del esquema
    // (incluido el paso de v5 a v6), no se queda en la 5.
    expect(version.data['user_version'], 6);

    final vehiculos = await db.select(db.vehicles).get();
    expect(vehiculos, hasLength(1));
    expect(vehiculos.single.marca, 'Mercedes-Benz');

    // maintenance_schedules se creó de cero en este mismo salto, ya con
    // la columna incluida desde el principio: se puede insertar y leer
    // con normalidad.
    final id = await db.maintenanceDao.insertarSchedule(
      MaintenanceSchedulesCompanion.insert(
        vehicleId: 1,
        nombre: 'Filtro de aire',
        categoria: MaintenanceCategory.motor,
        intervalKm: const Value(30000),
      ),
    );
    final guardado = await db.maintenanceDao.getSchedule(id);
    expect(guardado!.fuenteIntervalo, FuenteIntervalo.orientativo);

    await db.close();
  });

  test('migrar de v5 a v6 conserva mantenimientos y registros, y añade '
      'los campos nuevos a nulo', () async {
    final dir = await Directory.systemTemp.createTemp('car_care_migracion');
    final fichero = File(p.join(dir.path, 'v5.sqlite'));
    addTearDown(() => dir.delete(recursive: true));

    // Esquema de la versión 5: como el de la 4, más fuente_intervalo en
    // maintenance_schedules, y todavía sin tipo/posición/kind.
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
    crudo.execute('''
        CREATE TABLE maintenance_schedules (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
          nombre TEXT NOT NULL,
          categoria TEXT NOT NULL,
          interval_km INTEGER NULL,
          interval_meses INTEGER NULL,
          aviso_km INTEGER NULL,
          aviso_dias INTEGER NULL,
          activo INTEGER NOT NULL DEFAULT 1,
          silenciado INTEGER NOT NULL DEFAULT 0,
          orden INTEGER NOT NULL DEFAULT 0,
          fuente_intervalo TEXT NOT NULL DEFAULT 'orientativo'
        );
      ''');
    crudo.execute('''
        CREATE TABLE maintenance_records (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          vehicle_id INTEGER NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
          schedule_id INTEGER NULL REFERENCES maintenance_schedules(id) ON DELETE SET NULL,
          fecha INTEGER NOT NULL,
          km INTEGER NOT NULL,
          coste REAL NULL,
          taller TEXT NULL,
          notas TEXT NULL,
          es_sembrado INTEGER NOT NULL DEFAULT 0
        );
      ''');
    crudo.execute('''
        CREATE TABLE vehicle_specifications (
          vehicle_id INTEGER NOT NULL PRIMARY KEY REFERENCES vehicles(id) ON DELETE CASCADE,
          generacion TEXT NULL,
          motor_codigo TEXT NULL,
          cilindrada_cc INTEGER NULL,
          potencia_kw INTEGER NULL,
          tipo_caja TEXT NULL,
          numero_marchas INTEGER NULL,
          traccion TEXT NULL,
          codigo_tecnico TEXT NULL,
          notas_tecnicas TEXT NULL
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
      '''
        INSERT INTO maintenance_schedules
          (vehicle_id, nombre, categoria, interval_km)
        VALUES (1, ?, ?, 40000);
        ''',
      ['Pastillas de freno delanteras', 'frenos'],
    );
    crudo.execute(
      '''
        INSERT INTO maintenance_records
          (vehicle_id, schedule_id, fecha, km)
        VALUES (1, 1, ?, 35000);
        ''',
      [ahora],
    );
    crudo.execute('INSERT INTO settings DEFAULT VALUES;');
    crudo.execute('PRAGMA user_version = 5;');
    crudo.close();

    final db = AppDatabase.forTesting(NativeDatabase(fichero));

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data['user_version'], 6);

    // Lo que ya había sigue ahí.
    final schedules = await db.select(db.maintenanceSchedules).get();
    expect(schedules, hasLength(1));
    expect(schedules.single.nombre, 'Pastillas de freno delanteras');

    // Los campos nuevos existen y, para una fila que ya existía antes de
    // la migración, quedan a nulo/false: sin inventar información.
    expect(schedules.single.tipo, isNull);
    expect(schedules.single.posicion, isNull);
    expect(schedules.single.nombreAutogenerado, isFalse);

    final registros = await db.select(db.maintenanceRecords).get();
    expect(registros, hasLength(1));
    expect(registros.single.km, 35000);
    expect(registros.single.kind, isNull);

    await db.close();
  });

  test('saltar de v2 a v6 de un tiro no falla por columna duplicada', () async {
    final dir = await Directory.systemTemp.createTemp('car_care_migracion');
    final fichero = File(p.join(dir.path, 'v2.sqlite'));
    addTearDown(() => dir.delete(recursive: true));

    // Esquema de la versión 2: igual que el test equivalente de la fase 4,
    // sin ninguna tabla de mantenimientos todavía. El paso "from < 3" de
    // abajo va a crear maintenance_schedules y maintenance_records con la
    // definición ACTUAL de sus clases, que ya incluye tipo/posicion/kind.
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
      ['Seat', 'León ST', 'diesel', ahora],
    );
    crudo.execute('INSERT INTO settings DEFAULT VALUES;');
    crudo.execute('PRAGMA user_version = 2;');
    crudo.close();

    // Si alguna de las dos guardas ("from >= 3 && from < 5" o
    // "from >= 3 && from < 6") estuviera mal escrita (por ejemplo,
    // "if (from < 6)" a secas), esta línea lanzaría con
    // "duplicate column name".
    final db = AppDatabase.forTesting(NativeDatabase(fichero));

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data['user_version'], 6);

    final vehiculos = await db.select(db.vehicles).get();
    expect(vehiculos, hasLength(1));
    expect(vehiculos.single.marca, 'Seat');

    // Las dos tablas se crearon de cero en este mismo salto, ya con todas
    // las columnas incluidas desde el principio.
    final id = await db.maintenanceDao.insertarSchedule(
      MaintenanceSchedulesCompanion.insert(
        vehicleId: 1,
        nombre: 'Pastillas de freno delanteras',
        categoria: MaintenanceCategory.frenos,
        intervalKm: const Value(40000),
        tipo: const Value(MaintenanceType.pastillasFreno),
        posicion: const Value(Posicion.delantera),
      ),
    );
    final guardado = await db.maintenanceDao.getSchedule(id);
    expect(guardado!.tipo, MaintenanceType.pastillasFreno);
    expect(guardado.posicion, Posicion.delantera);
    expect(guardado.fuenteIntervalo, FuenteIntervalo.orientativo);

    await db.close();
  });
}
