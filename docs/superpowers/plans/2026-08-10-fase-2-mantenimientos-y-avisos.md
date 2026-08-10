# Fase 2 — Mantenimientos, vencimientos e historial

> **Para agentes ejecutores:** SUB-SKILL OBLIGATORIA: usa `superpowers:subagent-driven-development` (recomendada) o `superpowers:executing-plans` para implementar este plan tarea a tarea. Los pasos usan casillas (`- [ ]`) para el seguimiento.

**Objetivo:** que la aplicación sepa qué mantenimiento toca en cada coche y cuándo, mostrándolo con estados claros, y que guarde lo que ya se ha hecho.

**Arquitectura:** se mantienen las tres capas de la fase 1. El motor de vencimientos vive en `lib/domain/`, es lógica pura sin Drift ni Flutter, y es donde se concentra el esfuerzo de tests: un fallo silencioso ahí es un mantenimiento saltado. La capa de datos añade dos tablas con su migración, y la interfaz añade la ficha del vehículo y el historial.

**Stack:** Flutter, Drift (SQLite), Riverpod. Sin dependencias nuevas.

## Restricciones globales

- Plataforma única: Android. `minSdkVersion` 24.
- Toda la interfaz en español. Fechas `dd/MM/yyyy`, importes en euros con dos decimales, separador de miles con punto.
- **`lib/domain/` no puede importar `package:drift/...` ni `package:flutter/...`.**
- Los valores derivados no se persisten: el próximo vencimiento se calcula, nunca se guarda.
- Todo `setState` o uso de `BuildContext` posterior a un `await` va precedido de `if (!mounted) return;`.
- Las escrituras van en `try`/`catch`, con mensaje claro en español para el usuario y el detalle por `debugPrint`.
- Al pintar ficheros de imagen desde disco, `errorBuilder`.
- Las fotos se guardan como ruta relativa mediante `PhotoStorage`.
- No se añaden dependencias.
- Mensajes de commit en español, sin coautoría ni menciones a herramientas.
- **Entorno**: el toolchain no está en el PATH y la carpeta temporal debe redirigirse o Gradle no arranca. Antepón a cada comando de PowerShell:
  `$env:Path = "F:\dev\flutter\bin;F:\dev\android-sdk\platform-tools;$env:Path"; $env:JAVA_HOME = 'C:\Program Files\Eclipse Adoptium\jdk-17.0.20.8-hotspot'; $env:ANDROID_HOME = 'F:\dev\android-sdk'; $env:TMP = 'F:\dev\tmp'; $env:TEMP = 'F:\dev\tmp'`
- Punto de partida: `flutter analyze` limpio y 23 tests pasando. Lo que se rompa, es de quien lo rompe.

## Sobre el nivel de detalle de este plan

Las tareas de datos y de dominio traen el código y los tests completos: es donde un fallo silencioso cuesta caro y donde los valores esperados son el contrato.

Las tareas de interfaz describen el comportamiento y señalan el fichero del proyecto que sirve de patrón, en lugar de dictar el código. Es una desviación deliberada respecto al plan de la fase 1, y la razón es que allí el código dictado resultó ser la fuente de los tres defectos importantes que encontró la revisión: `setState` sin comprobar `mounted`, guardado sin manejo de errores y ficheros huérfanos. El código del plan no garantizó calidad, y en cambio arrastró a quien lo implementaba a copiarlo tal cual.

Ahora el proyecto ya tiene patrones establecidos y corregidos en el propio código. Apuntar a ellos envejece mejor que congelarlos aquí. Cada tarea de interfaz dice qué debe ocurrir, qué fichero mirar y qué errores concretos no repetir; la revisión posterior comprueba el resultado.

---

## Estado actual del proyecto

Ficheros que ya existen y que este plan consume:

| Fichero | Qué aporta |
|---|---|
| `lib/data/database.dart` | `AppDatabase`, `schemaVersion` 2, `AppDatabase.forTesting(QueryExecutor)` |
| `lib/data/tables/vehicles.dart` | Tabla `Vehicles`, enum `FuelType`. Fila: `Vehicle` |
| `lib/data/tables/mileage_readings.dart` | Tabla `MileageReadings`, enum `MileageOrigin`. Fila: `MileageReading` |
| `lib/data/tables/settings.dart` | `avisoKmPorDefecto` (1000), `avisoDiasPorDefecto` (30), `diasRecordatorioLectura` (15), `tema`, `fechaUltimaCopia` |
| `lib/data/daos/vehicle_dao.dart` | `watchActivos`, `getById`, `insertar`, `actualizar`, `archivar` |
| `lib/data/daos/mileage_dao.dart` | `registrar`, `watchUltima`, `ultimaLectura`, `lecturasDesde`, `watchTodas`, `soloFecha(DateTime)` |
| `lib/domain/usage_rate.dart` | `UsageRate.calcular`, `MileagePoint`, `UsageRateResult` (`kmPorDia`, `esPorDefecto`, `cocheParado`), constantes `kRitmoPorDefecto`, `kVentanaDias` |
| `lib/providers/providers.dart` | `databaseProvider`, `vehiculosProvider`, `ultimaLecturaProvider`, `ritmoUsoProvider` |
| `lib/providers/recalculo_al_reanudar.dart` | `providersARecalcularAlReanudar`, lista donde registrar lo que debe invalidarse al volver a primer plano |
| `lib/ui/theme/app_theme.dart` | `AppTheme.claro()`, `AppTheme.oscuro()`, `AppTheme.cifras` |
| `lib/ui/common/formatters.dart` | `formatearKm(int)`, `formatearFecha(DateTime)` |
| `lib/ui/home/vehicle_card.dart` | Tarjeta de vehículo; hoy al pulsarla abre la edición |

---

## Estructura de ficheros nuevos

| Fichero | Responsabilidad |
|---|---|
| `lib/data/tables/maintenance_schedules.dart` | Tabla de mantenimientos configurados y su enum de categoría |
| `lib/data/tables/maintenance_records.dart` | Tabla de mantenimientos realizados |
| `lib/data/daos/maintenance_dao.dart` | Consultas de mantenimientos y registros |
| `lib/domain/maintenance_due.dart` | Motor de vencimientos: lógica pura |
| `lib/domain/itv.dart` | Periodicidad y próxima fecha de ITV |
| `lib/domain/plantillas_mantenimiento.dart` | Mantenimientos habituales sugeridos al crear un vehículo |
| `lib/ui/theme/status_colors.dart` | Colores de los cuatro estados, claro y oscuro |
| `lib/ui/common/estado_chip.dart` | Distintivo visual de estado, reutilizable |
| `lib/providers/mantenimiento_providers.dart` | Providers de mantenimientos y vencimientos |
| `lib/ui/vehicle/vehicle_detail_screen.dart` | Ficha del vehículo |
| `lib/ui/maintenance/maintenance_form_screen.dart` | Alta y edición de un mantenimiento |
| `lib/ui/maintenance/register_maintenance_sheet.dart` | Registrar un mantenimiento realizado |
| `lib/ui/maintenance/plantillas_screen.dart` | Selección de plantillas al crear un vehículo |
| `lib/ui/history/history_screen.dart` | Historial (sustituye al esqueleto actual) |

---

## Tarea 1: Tablas de mantenimientos y migración

**Ficheros:**
- Crear: `lib/data/tables/maintenance_schedules.dart`, `lib/data/tables/maintenance_records.dart`
- Modificar: `lib/data/database.dart`
- Test: `test/data/database_migration_test.dart` (ampliar)

**Interfaces:**
- Produce: tablas `MaintenanceSchedules` y `MaintenanceRecords`; filas `MaintenanceSchedule` y `MaintenanceRecord`; enum `MaintenanceCategory`; `schemaVersion` 3.

- [ ] **Paso 1: Escribir la tabla de mantenimientos configurados**

`lib/data/tables/maintenance_schedules.dart`:

```dart
import 'package:drift/drift.dart';

import 'vehicles.dart';

enum MaintenanceCategory {
  motor,
  frenos,
  neumaticos,
  electricidad,
  suspension,
  transmision,
  carroceria,
  itv,
  otro,
}

class MaintenanceSchedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();
  TextColumn get nombre => text().withLength(min: 1, max: 80)();
  TextColumn get categoria => textEnum<MaintenanceCategory>()();

  /// Al menos uno de los dos intervalos debe tener valor. La comprobación
  /// vive en el formulario: SQLite no puede expresarla sin un CHECK que
  /// complicaría las migraciones.
  IntColumn get intervalKm => integer().nullable()();
  IntColumn get intervalMeses => integer().nullable()();

  /// Márgenes de aviso propios. A nulo, se heredan los de Settings.
  IntColumn get avisoKm => integer().nullable()();
  IntColumn get avisoDias => integer().nullable()();

  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  /// Sigue calculando su estado, pero no genera notificación.
  BoolColumn get silenciado => boolean().withDefault(const Constant(false))();

  IntColumn get orden => integer().withDefault(const Constant(0))();
}
```

- [ ] **Paso 2: Escribir la tabla de mantenimientos realizados**

`lib/data/tables/maintenance_records.dart`:

```dart
import 'package:drift/drift.dart';

import 'maintenance_schedules.dart';
import 'vehicles.dart';

class MaintenanceRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();

  /// Nulo en reparaciones puntuales que no responden a ningún mantenimiento
  /// configurado. Si se borra el mantenimiento, el registro sobrevive.
  IntColumn get scheduleId => integer()
      .nullable()
      .references(MaintenanceSchedules, #id, onDelete: KeyAction.setNull)();

  DateTimeColumn get fecha => dateTime()();
  IntColumn get km => integer()();
  RealColumn get coste => real().nullable()();
  TextColumn get taller => text().nullable()();
  TextColumn get notas => text().nullable()();

  /// Dato anterior a la instalación de la app, introducido a mano para
  /// poder calcular el primer vencimiento. Cuenta para los cálculos y se
  /// distingue en el historial.
  BoolColumn get esSembrado => boolean().withDefault(const Constant(false))();
}
```

- [ ] **Paso 3: Registrar las tablas y la migración**

En `lib/data/database.dart`: añade los imports de las dos tablas, inclúyelas en la lista `tables` de la anotación `@DriftDatabase`, sube `schemaVersion` a 3 y amplía el `onUpgrade` existente para que, cuando `from < 3`, cree las dos tablas nuevas:

```dart
        if (from < 3) {
          await m.createTable(maintenanceSchedules);
          await m.createTable(maintenanceRecords);
        }
```

Mantén intacto el paso `from < 2` que ya existe.

- [ ] **Paso 4: Escribir el test que debe fallar**

Añade este test a `test/data/database_migration_test.dart`, dentro del mismo `main()` que ya contiene el de v1 a v2. Reutiliza los imports que ya están en el fichero.

```dart
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
```

Añade al fichero los imports que este test necesita y que aún no están: `package:drift/drift.dart` (para `Value`) y `package:car_care/data/tables/maintenance_schedules.dart` (para `MaintenanceCategory`). Si `Value` colisiona con algún matcher, importa con `show Value`.

- [ ] **Paso 5: Ejecutar el test para verificar que falla**

```powershell
flutter test test/data/database_migration_test.dart --reporter=failures-only
```

Esperado: FALLA porque el código generado por Drift todavía no conoce las tablas nuevas.

- [ ] **Paso 6: Regenerar el código de Drift**

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Esperado: `Succeeded after ...`

- [ ] **Paso 7: Ejecutar los tests**

```powershell
flutter test --reporter=failures-only
```

Esperado: `All tests passed!`

- [ ] **Paso 8: Commit**

```bash
git add -A && git commit -q -m "Añadir las tablas de mantenimientos configurados y realizados"
```

---

## Tarea 2: DAO de mantenimientos

**Ficheros:**
- Crear: `lib/data/daos/maintenance_dao.dart`, `test/data/maintenance_dao_test.dart`
- Modificar: `lib/data/database.dart` (registrar el DAO)

**Interfaces:**
- Consume: tablas de la Tarea 1.
- Produce: `MaintenanceDao` con `watchSchedules(int vehicleId)`, `getSchedule(int id)`, `insertarSchedule(MaintenanceSchedulesCompanion)`, `actualizarSchedule(MaintenanceSchedule)`, `borrarSchedule(int id)`, `watchRecords(int vehicleId)`, `watchTodosLosRecords()`, `ultimoRecordDe(int scheduleId)`, `ultimosRecordsPorSchedule(int vehicleId)`, `insertarRecord(MaintenanceRecordsCompanion)`, `borrarRecord(int id)`.

- [ ] **Paso 1: Escribir el DAO**

`lib/data/daos/maintenance_dao.dart`. Sigue el patrón de `lib/data/daos/mileage_dao.dart`: `@DriftAccessor`, `DatabaseAccessor<AppDatabase>` con el mixin generado, constructor `MaintenanceDao(super.db)` y `part 'maintenance_dao.g.dart';`.

```dart
import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/maintenance_records.dart';
import '../tables/maintenance_schedules.dart';

part 'maintenance_dao.g.dart';

@DriftAccessor(tables: [MaintenanceSchedules, MaintenanceRecords])
class MaintenanceDao extends DatabaseAccessor<AppDatabase>
    with _$MaintenanceDaoMixin {
  MaintenanceDao(super.db);

  Stream<List<MaintenanceSchedule>> watchSchedules(int vehicleId) {
    return (select(maintenanceSchedules)
          ..where((s) => s.vehicleId.equals(vehicleId))
          ..orderBy([
            (s) => OrderingTerm(expression: s.orden),
            (s) => OrderingTerm(expression: s.nombre),
          ]))
        .watch();
  }

  Future<MaintenanceSchedule?> getSchedule(int id) {
    return (select(maintenanceSchedules)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertarSchedule(MaintenanceSchedulesCompanion schedule) {
    return into(maintenanceSchedules).insert(schedule);
  }

  Future<bool> actualizarSchedule(MaintenanceSchedule schedule) {
    return update(maintenanceSchedules).replace(schedule);
  }

  Future<int> borrarSchedule(int id) {
    return (delete(maintenanceSchedules)..where((s) => s.id.equals(id))).go();
  }

  Stream<List<MaintenanceRecord>> watchRecords(int vehicleId) {
    return (select(maintenanceRecords)
          ..where((r) => r.vehicleId.equals(vehicleId))
          ..orderBy([
            (r) => OrderingTerm(expression: r.fecha, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<MaintenanceRecord>> watchTodosLosRecords() {
    return (select(maintenanceRecords)
          ..orderBy([
            (r) => OrderingTerm(expression: r.fecha, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Future<MaintenanceRecord?> ultimoRecordDe(int scheduleId) {
    return (select(maintenanceRecords)
          ..where((r) => r.scheduleId.equals(scheduleId))
          ..orderBy([
            (r) => OrderingTerm(expression: r.fecha, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Último registro de cada mantenimiento del vehículo, indexado por
  /// `scheduleId`. Una sola consulta en lugar de una por mantenimiento.
  Future<Map<int, MaintenanceRecord>> ultimosRecordsPorSchedule(
    int vehicleId,
  ) async {
    final todos = await (select(maintenanceRecords)
          ..where((r) => r.vehicleId.equals(vehicleId) & r.scheduleId.isNotNull())
          ..orderBy([(r) => OrderingTerm(expression: r.fecha)]))
        .get();

    // Al ir en orden ascendente, el último que se escribe de cada clave es
    // el más reciente.
    return {for (final r in todos) r.scheduleId!: r};
  }

  Future<int> insertarRecord(MaintenanceRecordsCompanion record) {
    return into(maintenanceRecords).insert(record);
  }

  Future<int> borrarRecord(int id) {
    return (delete(maintenanceRecords)..where((r) => r.id.equals(id))).go();
  }
}
```

- [ ] **Paso 2: Registrar el DAO**

En `lib/data/database.dart`, añade el import y `MaintenanceDao` a la lista `daos`.

- [ ] **Paso 3: Escribir el test que debe fallar**

`test/data/maintenance_dao_test.dart`:

```dart
import 'package:car_care/data/database.dart';
import 'package:car_care/data/tables/maintenance_schedules.dart';
import 'package:car_care/data/tables/vehicles.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late int vehicleId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    vehicleId = await db.vehicleDao.insertar(
      const VehiclesCompanion(
        marca: Value('Seat'),
        modelo: Value('León ST'),
        combustible: Value(FuelType.diesel),
      ),
    );
  });
  tearDown(() => db.close());

  Future<int> crearSchedule({
    String nombre = 'Aceite y filtro',
    int orden = 0,
    int? vehiculo,
  }) {
    return db.maintenanceDao.insertarSchedule(
      MaintenanceSchedulesCompanion.insert(
        vehicleId: vehiculo ?? vehicleId,
        nombre: nombre,
        categoria: MaintenanceCategory.motor,
        intervalKm: const Value(15000),
        orden: Value(orden),
      ),
    );
  }

  Future<int> crearRecord(int? scheduleId, DateTime fecha, int km) {
    return db.maintenanceDao.insertarRecord(
      MaintenanceRecordsCompanion.insert(
        vehicleId: vehicleId,
        scheduleId: Value(scheduleId),
        fecha: fecha,
        km: km,
      ),
    );
  }

  test('inserta un mantenimiento y lo recupera por id', () async {
    final id = await crearSchedule();

    final guardado = await db.maintenanceDao.getSchedule(id);

    expect(guardado!.nombre, 'Aceite y filtro');
    expect(guardado.intervalKm, 15000);
    expect(guardado.activo, isTrue);
    expect(guardado.silenciado, isFalse);
  });

  test('watchSchedules devuelve solo los del vehiculo y en orden', () async {
    final otroVehiculo = await db.vehicleDao.insertar(
      const VehiclesCompanion(
        marca: Value('Mercedes-Benz'),
        modelo: Value('Clase B'),
        combustible: Value(FuelType.diesel),
      ),
    );
    await crearSchedule(nombre: 'Frenos', orden: 2);
    await crearSchedule(nombre: 'Aceite', orden: 1);
    await crearSchedule(nombre: 'De otro coche', vehiculo: otroVehiculo);

    final lista = await db.maintenanceDao.watchSchedules(vehicleId).first;

    expect(lista.map((s) => s.nombre), ['Aceite', 'Frenos']);
  });

  test('ultimoRecordDe devuelve el de fecha mas reciente', () async {
    final id = await crearSchedule();
    await crearRecord(id, DateTime(2026, 8, 1), 100000);
    await crearRecord(id, DateTime(2025, 1, 1), 80000);

    final ultimo = await db.maintenanceDao.ultimoRecordDe(id);

    expect(ultimo!.km, 100000);
  });

  test('ultimosRecordsPorSchedule da el mas reciente de cada uno', () async {
    final aceite = await crearSchedule(nombre: 'Aceite');
    final frenos = await crearSchedule(nombre: 'Frenos');
    await crearRecord(aceite, DateTime(2025, 1, 1), 80000);
    await crearRecord(aceite, DateTime(2026, 5, 1), 95000);
    await crearRecord(frenos, DateTime(2024, 3, 1), 60000);

    final mapa =
        await db.maintenanceDao.ultimosRecordsPorSchedule(vehicleId);

    expect(mapa[aceite]!.km, 95000);
    expect(mapa[frenos]!.km, 60000);
  });

  test('borrar un mantenimiento no borra su historial', () async {
    final id = await crearSchedule();
    await crearRecord(id, DateTime(2026, 5, 1), 95000);

    await db.maintenanceDao.borrarSchedule(id);
    final registros = await db.maintenanceDao.watchRecords(vehicleId).first;

    expect(registros, hasLength(1));
    expect(registros.single.scheduleId, isNull);
    expect(registros.single.km, 95000);
  });

  test('borrar el vehiculo arrastra mantenimientos y registros', () async {
    final id = await crearSchedule();
    await crearRecord(id, DateTime(2026, 5, 1), 95000);

    await (db.delete(db.vehicles)..where((v) => v.id.equals(vehicleId))).go();

    expect(await db.maintenanceDao.watchSchedules(vehicleId).first, isEmpty);
    expect(await db.maintenanceDao.watchRecords(vehicleId).first, isEmpty);
  });
}
```

- [ ] **Paso 4: Ejecutar el test para verificar que falla**

```powershell
flutter test test/data/maintenance_dao_test.dart --reporter=failures-only
```

Esperado: FALLA por `maintenance_dao.g.dart` no generado.

- [ ] **Paso 5: Regenerar y ejecutar**

```powershell
dart run build_runner build --delete-conflicting-outputs
flutter test --reporter=failures-only
```

Esperado: `All tests passed!`

- [ ] **Paso 6: Commit**

```bash
git add -A && git commit -q -m "Añadir el acceso a datos de mantenimientos"
```

---

## Tarea 3: Motor de vencimientos

Es el corazón de la aplicación y la tarea con más peso de tests del proyecto. Lógica pura: sin Drift, sin Flutter, sin base de datos.

**Ficheros:**
- Crear: `lib/domain/maintenance_due.dart`, `test/domain/maintenance_due_test.dart`

**Interfaces:**
- Consume: `UsageRateResult` de `lib/domain/usage_rate.dart`.
- Produce: enum `EstadoMantenimiento { sinConfigurar, ok, proximo, atencion, vencido }`; clase `DatosVencimiento`; clase `Vencimiento`; función `calcularVencimiento(...)`.

- [ ] **Paso 1: Escribir el test que debe fallar**

`test/domain/maintenance_due_test.dart`:

```dart
import 'package:car_care/domain/maintenance_due.dart';
import 'package:car_care/domain/usage_rate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ahora = DateTime(2026, 8, 10);
  const ritmoMedido = UsageRateResult(kmPorDia: 50, esPorDefecto: false);
  const ritmoPorDefecto =
      UsageRateResult(kmPorDia: kRitmoPorDefecto, esPorDefecto: true);
  const cocheParado = UsageRateResult(kmPorDia: 0.2, esPorDefecto: false);

  Vencimiento calcular({
    int? intervalKm,
    int? intervalMeses,
    int? avisoKm,
    int? avisoDias,
    int? ultimoKm,
    DateTime? ultimaFecha,
    int kmActual = 100000,
    DateTime? fechaUltimaLectura,
    UsageRateResult ritmo = ritmoMedido,
  }) {
    return calcularVencimiento(
      datos: DatosVencimiento(
        intervalKm: intervalKm,
        intervalMeses: intervalMeses,
        avisoKm: avisoKm,
        avisoDias: avisoDias,
        ultimoKm: ultimoKm,
        ultimaFecha: ultimaFecha,
      ),
      kmActual: kmActual,
      fechaUltimaLectura: fechaUltimaLectura ?? ahora,
      ritmo: ritmo,
      ahora: ahora,
      avisoKmPorDefecto: 1000,
      avisoDiasPorDefecto: 30,
    );
  }

  test('sin ningun mantenimiento previo queda sin configurar', () {
    final v = calcular(intervalKm: 15000);

    expect(v.estado, EstadoMantenimiento.sinConfigurar);
    expect(v.proximoKm, isNull);
    expect(v.proximaFecha, isNull);
  });

  test('calcula el proximo kilometraje sumando el intervalo al ultimo', () {
    final v = calcular(intervalKm: 15000, ultimoKm: 135000,
        ultimaFecha: DateTime(2026, 5, 10));

    expect(v.proximoKm, 150000);
  });

  test('calcula la proxima fecha sumando los meses del intervalo', () {
    final v = calcular(intervalMeses: 12, ultimoKm: 135000,
        ultimaFecha: DateTime(2026, 5, 10));

    expect(v.proximaFecha, DateTime(2027, 5, 10));
  });

  test('esta ok cuando falta mucho por ambas vias', () {
    final v = calcular(
      intervalKm: 15000,
      intervalMeses: 12,
      ultimoKm: 99000,
      ultimaFecha: DateTime(2026, 8, 1),
    );

    expect(v.estado, EstadoMantenimiento.ok);
  });

  test('esta vencido cuando se ha pasado de kilometros', () {
    final v = calcular(intervalKm: 15000, ultimoKm: 80000,
        ultimaFecha: DateTime(2025, 1, 1), kmActual: 96000);

    expect(v.estado, EstadoMantenimiento.vencido);
    expect(v.kmRestantes, lessThanOrEqualTo(0));
  });

  test('esta vencido cuando se ha pasado de fecha aunque sobren kilometros',
      () {
    final v = calcular(
      intervalMeses: 12,
      ultimoKm: 99000,
      ultimaFecha: DateTime(2025, 1, 1),
    );

    expect(v.estado, EstadoMantenimiento.vencido);
  });

  test('pide atencion cuando entra en el margen de kilometros', () {
    // Faltan 800 km, el margen por defecto son 1.000.
    final v = calcular(intervalKm: 15000, ultimoKm: 85000,
        ultimaFecha: DateTime(2026, 8, 10), kmActual: 99200);

    expect(v.estado, EstadoMantenimiento.atencion);
  });

  test('pide atencion cuando entra en el margen de dias', () {
    // Vence en 20 días, el margen por defecto son 30.
    final v = calcular(
      intervalMeses: 12,
      ultimoKm: 99000,
      ultimaFecha: DateTime(2025, 8, 30),
    );

    expect(v.estado, EstadoMantenimiento.atencion);
  });

  test('avisa como proximo dentro del doble del margen', () {
    // Faltan 1.500 km: fuera del margen de 1.000, dentro de 2.000.
    final v = calcular(intervalKm: 15000, ultimoKm: 85500,
        ultimaFecha: DateTime(2026, 8, 10), kmActual: 99000);

    expect(v.estado, EstadoMantenimiento.proximo);
  });

  test('respeta el margen propio del mantenimiento sobre el general', () {
    // Faltan 1.500 km y el margen propio son 2.000: ya pide atención.
    final v = calcular(intervalKm: 15000, avisoKm: 2000, ultimoKm: 85500,
        ultimaFecha: DateTime(2026, 8, 10), kmActual: 99000);

    expect(v.estado, EstadoMantenimiento.atencion);
  });

  test('gana el vencimiento que llegue antes de los dos', () {
    // Por kilómetros faltarían 10.000 (200 días al ritmo actual), pero por
    // fecha vence en 10 días.
    final v = calcular(
      intervalKm: 15000,
      intervalMeses: 12,
      ultimoKm: 90000,
      ultimaFecha: DateTime(2025, 8, 20),
    );

    expect(v.estado, EstadoMantenimiento.atencion);
    expect(v.venceAntesPorFecha, isTrue);
  });

  test('proyecta los kilometros desde la ultima lectura con el ritmo', () {
    // Última lectura hace 10 días a 99.000 km, a 50 km/día: hoy ≈ 99.500.
    final v = calcular(
      intervalKm: 15000,
      ultimoKm: 90000,
      ultimaFecha: DateTime(2026, 1, 1),
      kmActual: 99000,
      fechaUltimaLectura: DateTime(2026, 7, 31),
    );

    expect(v.kmProyectado, 99500);
    expect(v.kmRestantes, 105000 - 99500);
  });

  test('con el coche parado no estima fecha por kilometros', () {
    final v = calcular(
      intervalKm: 15000,
      ultimoKm: 90000,
      ultimaFecha: DateTime(2026, 1, 1),
      ritmo: cocheParado,
    );

    expect(v.fechaEstimadaPorKm, isNull);
  });

  test('con el ritmo por defecto la estimacion se marca como supuesta', () {
    final v = calcular(
      intervalKm: 15000,
      ultimoKm: 90000,
      ultimaFecha: DateTime(2026, 1, 1),
      ritmo: ritmoPorDefecto,
    );

    expect(v.fechaEstimadaPorKm, isNotNull);
    expect(v.estimacionEsSupuesta, isTrue);
  });

  test('solo con intervalo de kilometros no calcula fecha de vencimiento', () {
    final v = calcular(intervalKm: 15000, ultimoKm: 99000,
        ultimaFecha: DateTime(2026, 8, 1));

    expect(v.proximaFecha, isNull);
    expect(v.diasRestantes, isNull);
    expect(v.proximoKm, isNotNull);
  });

  test('solo con intervalo de tiempo no calcula kilometraje de vencimiento',
      () {
    final v = calcular(intervalMeses: 12, ultimoKm: 99000,
        ultimaFecha: DateTime(2026, 8, 1));

    expect(v.proximoKm, isNull);
    expect(v.kmRestantes, isNull);
    expect(v.proximaFecha, isNotNull);
  });

  test('sumar meses no desborda a un dia inexistente', () {
    // 31 de enero más un mes: 28 de febrero, no el 3 de marzo.
    final v = calcular(intervalMeses: 1, ultimoKm: 99000,
        ultimaFecha: DateTime(2026, 1, 31));

    expect(v.proximaFecha, DateTime(2026, 2, 28));
  });

  test(
      'diasNaturalesEntre no pierde un dia en el cambio de hora de '
      'primavera', () {
    // El cambio de hora de 2026 en España es el 29 de marzo: los relojes
    // adelantan de 02:00 a 03:00. Sin normalizar a UTC, la resta de dos
    // medianoches locales pierde esa hora y el resultado trunca a 30 en
    // vez de 31.
    expect(diasNaturalesEntre(DateTime(2026, 3, 1), DateTime(2026, 4, 1)), 31);
  });
}
```

- [ ] **Paso 2: Ejecutar el test para verificar que falla**

```powershell
flutter test test/domain/maintenance_due_test.dart --reporter=failures-only
```

Esperado: FALLA con `Target of URI doesn't exist: 'package:car_care/domain/maintenance_due.dart'`.

- [ ] **Paso 3: Escribir la implementación**

`lib/domain/maintenance_due.dart`:

```dart
import 'usage_rate.dart';

enum EstadoMantenimiento {
  /// No hay ningún dato de cuándo se hizo por última vez, así que no se
  /// puede calcular nada. No genera avisos.
  sinConfigurar,
  ok,
  proximo,
  atencion,
  vencido,
}

/// Lo que el motor necesita saber de un mantenimiento, sin acoplarse a la
/// capa de datos.
class DatosVencimiento {
  final int? intervalKm;
  final int? intervalMeses;
  final int? avisoKm;
  final int? avisoDias;
  final int? ultimoKm;
  final DateTime? ultimaFecha;

  const DatosVencimiento({
    this.intervalKm,
    this.intervalMeses,
    this.avisoKm,
    this.avisoDias,
    this.ultimoKm,
    this.ultimaFecha,
  });
}

class Vencimiento {
  final EstadoMantenimiento estado;

  /// Kilometraje al que toca. Nulo si el mantenimiento no va por kilómetros.
  final int? proximoKm;

  /// Fecha en la que toca. Nula si el mantenimiento no va por tiempo.
  final DateTime? proximaFecha;

  /// Kilómetros que faltan respecto a la proyección de hoy. Negativo si ya
  /// se pasó.
  final int? kmRestantes;

  /// Días naturales que faltan. Negativo si ya se pasó.
  final int? diasRestantes;

  /// Kilometraje estimado a día de hoy a partir de la última lectura y del
  /// ritmo de uso. Siempre es una estimación: el dato real es la lectura.
  final int kmProyectado;

  /// Cuándo se alcanzarán los kilómetros del vencimiento, al ritmo actual.
  /// Nula con el coche parado, porque no se alcanzarían nunca.
  final DateTime? fechaEstimadaPorKm;

  /// Cierto cuando la estimación se apoya en el ritmo por defecto y no en
  /// lecturas reales: es una suposición, y la interfaz debe decirlo.
  final bool estimacionEsSupuesta;

  /// De las dos vías, cuál llega antes. Nulo si solo hay una.
  final bool? venceAntesPorFecha;

  const Vencimiento({
    required this.estado,
    required this.kmProyectado,
    this.proximoKm,
    this.proximaFecha,
    this.kmRestantes,
    this.diasRestantes,
    this.fechaEstimadaPorKm,
    this.estimacionEsSupuesta = false,
    this.venceAntesPorFecha,
  });
}

/// Días naturales entre dos fechas, inmune a los cambios de horario.
int diasNaturalesEntre(DateTime desde, DateTime hasta) {
  final a = DateTime.utc(desde.year, desde.month, desde.day);
  final b = DateTime.utc(hasta.year, hasta.month, hasta.day);
  return b.difference(a).inDays;
}

/// Suma meses sin desbordar a un día que no existe: el 31 de enero más un
/// mes es el 28 de febrero, no el 3 de marzo.
DateTime sumarMeses(DateTime fecha, int meses) {
  final totalMeses = fecha.month - 1 + meses;
  final anio = fecha.year + totalMeses ~/ 12;
  final mes = totalMeses % 12 + 1;
  final ultimoDiaDelMes = DateTime(anio, mes + 1, 0).day;
  return DateTime(anio, mes, fecha.day.clamp(1, ultimoDiaDelMes));
}

Vencimiento calcularVencimiento({
  required DatosVencimiento datos,
  required int kmActual,
  required DateTime fechaUltimaLectura,
  required UsageRateResult ritmo,
  required DateTime ahora,
  required int avisoKmPorDefecto,
  required int avisoDiasPorDefecto,
}) {
  final diasDesdeLectura = diasNaturalesEntre(fechaUltimaLectura, ahora);
  final kmProyectado =
      kmActual + (ritmo.kmPorDia * diasDesdeLectura).round();

  if (datos.ultimoKm == null || datos.ultimaFecha == null) {
    return Vencimiento(
      estado: EstadoMantenimiento.sinConfigurar,
      kmProyectado: kmProyectado,
    );
  }

  final margenKm = datos.avisoKm ?? avisoKmPorDefecto;
  final margenDias = datos.avisoDias ?? avisoDiasPorDefecto;

  int? proximoKm;
  int? kmRestantes;
  DateTime? fechaEstimadaPorKm;
  if (datos.intervalKm != null) {
    proximoKm = datos.ultimoKm! + datos.intervalKm!;
    kmRestantes = proximoKm - kmProyectado;
    if (!ritmo.cocheParado) {
      fechaEstimadaPorKm =
          ahora.add(Duration(days: (kmRestantes / ritmo.kmPorDia).round()));
    }
  }

  DateTime? proximaFecha;
  int? diasRestantes;
  if (datos.intervalMeses != null) {
    proximaFecha = sumarMeses(datos.ultimaFecha!, datos.intervalMeses!);
    diasRestantes = diasNaturalesEntre(ahora, proximaFecha);
  }

  final vencidoPorKm = kmRestantes != null && kmRestantes <= 0;
  final vencidoPorFecha = diasRestantes != null && diasRestantes <= 0;

  final atencionPorKm = kmRestantes != null && kmRestantes <= margenKm;
  final atencionPorFecha =
      diasRestantes != null && diasRestantes <= margenDias;

  final proximoPorKm = kmRestantes != null && kmRestantes <= margenKm * 2;
  final proximoPorFecha =
      diasRestantes != null && diasRestantes <= margenDias * 2;

  final EstadoMantenimiento estado;
  if (vencidoPorKm || vencidoPorFecha) {
    estado = EstadoMantenimiento.vencido;
  } else if (atencionPorKm || atencionPorFecha) {
    estado = EstadoMantenimiento.atencion;
  } else if (proximoPorKm || proximoPorFecha) {
    estado = EstadoMantenimiento.proximo;
  } else {
    estado = EstadoMantenimiento.ok;
  }

  bool? venceAntesPorFecha;
  if (proximaFecha != null && fechaEstimadaPorKm != null) {
    venceAntesPorFecha = proximaFecha.isBefore(fechaEstimadaPorKm);
  }

  return Vencimiento(
    estado: estado,
    kmProyectado: kmProyectado,
    proximoKm: proximoKm,
    proximaFecha: proximaFecha,
    kmRestantes: kmRestantes,
    diasRestantes: diasRestantes,
    fechaEstimadaPorKm: fechaEstimadaPorKm,
    estimacionEsSupuesta: ritmo.esPorDefecto,
    venceAntesPorFecha: venceAntesPorFecha,
  );
}
```

- [ ] **Paso 4: Ejecutar el test para verificar que pasa**

```powershell
flutter test test/domain/maintenance_due_test.dart --reporter=failures-only
```

Esperado: `All tests passed!`

Si algún caso falla, **no cambies el test para que pase**: los valores esperados están calculados a mano y son el contrato. Corrige la implementación.

- [ ] **Paso 5: Comprobar que el dominio sigue limpio**

```bash
grep -E "package:(drift|flutter)/" lib/domain/maintenance_due.dart
```

Esperado: sin salida.

- [ ] **Paso 6: Commit**

```bash
git add -A && git commit -q -m "Añadir el motor de cálculo de vencimientos"
```

---

## Tarea 4: Cálculo de la ITV

**Ficheros:**
- Crear: `lib/domain/itv.dart`, `test/domain/itv_test.dart`

**Interfaces:**
- Produce: `int mesesEntreItv(DateTime fechaMatriculacion, DateTime enFecha)`, `DateTime? proximaItv({required DateTime? fechaMatriculacion, DateTime? ultimaItv})`.

- [ ] **Paso 1: Escribir el test que debe fallar**

`test/domain/itv_test.dart`:

```dart
import 'package:car_care/domain/itv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('periodicidad', () {
    test('menos de cuatro anios esta exento', () {
      expect(mesesEntreItv(DateTime(2024, 1, 1), DateTime(2026, 8, 10)), 0);
    });

    test('de cuatro a diez anios toca cada dos anios', () {
      expect(mesesEntreItv(DateTime(2018, 1, 1), DateTime(2026, 8, 10)), 24);
    });

    test('pasados diez anios toca cada anio', () {
      expect(mesesEntreItv(DateTime(2009, 1, 1), DateTime(2026, 8, 10)), 12);
    });

    test('el limite de los diez anios cuenta el dia exacto', () {
      expect(mesesEntreItv(DateTime(2016, 8, 10), DateTime(2026, 8, 10)), 12);
      expect(mesesEntreItv(DateTime(2016, 8, 11), DateTime(2026, 8, 10)), 24);
    });
  });

  group('proxima inspeccion', () {
    test('sin fecha de matriculacion no se puede calcular', () {
      expect(proximaItv(fechaMatriculacion: null), isNull);
    });

    test('sin inspecciones previas toca a los cuatro anios de matricular',
        () {
      expect(
        proximaItv(fechaMatriculacion: DateTime(2023, 5, 20)),
        DateTime(2027, 5, 20),
      );
    });

    test('un coche joven suma dos anios a la ultima inspeccion', () {
      expect(
        proximaItv(
          fechaMatriculacion: DateTime(2018, 3, 1),
          ultimaItv: DateTime(2025, 3, 1),
        ),
        DateTime(2027, 3, 1),
      );
    });

    test('un coche de mas de diez anios suma uno', () {
      expect(
        proximaItv(
          fechaMatriculacion: DateTime(2009, 6, 15),
          ultimaItv: DateTime(2026, 6, 15),
        ),
        DateTime(2027, 6, 15),
      );
    });
  });
}
```

- [ ] **Paso 2: Ejecutar el test para verificar que falla**

```powershell
flutter test test/domain/itv_test.dart --reporter=failures-only
```

Esperado: FALLA porque `lib/domain/itv.dart` no existe.

- [ ] **Paso 3: Escribir la implementación**

`lib/domain/itv.dart`:

```dart
import 'maintenance_due.dart' show sumarMeses;

/// Periodicidad de la ITV para turismos según la normativa española, en
/// meses. Devuelve 0 mientras el vehículo está exento.
///
/// Hasta los 4 años: exento. De 4 a 10: cada 2 años. A partir de 10: anual.
int mesesEntreItv(DateTime fechaMatriculacion, DateTime enFecha) {
  final diezAnios = DateTime(
    fechaMatriculacion.year + 10,
    fechaMatriculacion.month,
    fechaMatriculacion.day,
  );
  final cuatroAnios = DateTime(
    fechaMatriculacion.year + 4,
    fechaMatriculacion.month,
    fechaMatriculacion.day,
  );

  if (enFecha.isBefore(cuatroAnios)) return 0;
  return enFecha.isBefore(diezAnios) ? 24 : 12;
}

/// Fecha de la próxima inspección.
///
/// Sin inspecciones previas se toma la primera obligatoria, a los cuatro
/// años de matricular. Con una previa, se le suma la periodicidad que
/// correspondía a la antigüedad del vehículo en esa inspección — es una
/// simplificación deliberada: la normativa mira la antigüedad en el momento
/// de inspeccionar, no en el de la anterior, y en el año de transición
/// puede desviarse. Como el usuario puede corregir la fecha a mano, no
/// compensa complicarlo.
DateTime? proximaItv({
  required DateTime? fechaMatriculacion,
  DateTime? ultimaItv,
}) {
  if (fechaMatriculacion == null) return null;

  if (ultimaItv == null) {
    return DateTime(
      fechaMatriculacion.year + 4,
      fechaMatriculacion.month,
      fechaMatriculacion.day,
    );
  }

  final meses = mesesEntreItv(fechaMatriculacion, ultimaItv);
  return sumarMeses(ultimaItv, meses == 0 ? 24 : meses);
}
```

- [ ] **Paso 4: Ejecutar el test para verificar que pasa**

```powershell
flutter test test/domain/itv_test.dart --reporter=failures-only
```

Esperado: `All tests passed!`

- [ ] **Paso 5: Commit**

```bash
git add -A && git commit -q -m "Añadir el cálculo de la periodicidad de la ITV"
```

---

## Tarea 5: Colores de estado y distintivo visual

**Ficheros:**
- Crear: `lib/ui/theme/status_colors.dart`, `lib/ui/common/estado_chip.dart`

**Interfaces:**
- Consume: `EstadoMantenimiento` de la Tarea 3.
- Produce: `ColoresEstado` con `Color de(EstadoMantenimiento)`, extensión `ThemeData.coloresEstado`; widget `EstadoChip({required EstadoMantenimiento estado, String? texto})`; función `etiquetaEstado(EstadoMantenimiento)`.

- [ ] **Paso 1: Escribir los colores de estado**

`lib/ui/theme/status_colors.dart`:

```dart
import 'package:flutter/material.dart';

import '../../domain/maintenance_due.dart';

/// Los cuatro estados en tonos desaturados: legibles, pero sin efecto
/// semáforo de juguete. El color aquí es información, no decoración.
class ColoresEstado {
  final Color ok;
  final Color proximo;
  final Color atencion;
  final Color vencido;
  final Color sinConfigurar;

  const ColoresEstado({
    required this.ok,
    required this.proximo,
    required this.atencion,
    required this.vencido,
    required this.sinConfigurar,
  });

  static const claro = ColoresEstado(
    ok: Color(0xFF2E7D5B),
    proximo: Color(0xFF2C6E9B),
    atencion: Color(0xFFB0741F),
    vencido: Color(0xFFB3453A),
    sinConfigurar: Color(0xFF8A9199),
  );

  static const oscuro = ColoresEstado(
    ok: Color(0xFF6FBF9A),
    proximo: Color(0xFF7FB6DC),
    atencion: Color(0xFFE0A857),
    vencido: Color(0xFFE58C82),
    sinConfigurar: Color(0xFF8A9199),
  );

  Color de(EstadoMantenimiento estado) => switch (estado) {
        EstadoMantenimiento.ok => ok,
        EstadoMantenimiento.proximo => proximo,
        EstadoMantenimiento.atencion => atencion,
        EstadoMantenimiento.vencido => vencido,
        EstadoMantenimiento.sinConfigurar => sinConfigurar,
      };
}

extension ColoresEstadoDelTema on ThemeData {
  ColoresEstado get coloresEstado =>
      brightness == Brightness.light ? ColoresEstado.claro : ColoresEstado.oscuro;
}

String etiquetaEstado(EstadoMantenimiento estado) => switch (estado) {
      EstadoMantenimiento.ok => 'Al día',
      EstadoMantenimiento.proximo => 'Próximo',
      EstadoMantenimiento.atencion => 'Conviene hacerlo',
      EstadoMantenimiento.vencido => 'Vencido',
      EstadoMantenimiento.sinConfigurar => 'Sin datos',
    };
```

- [ ] **Paso 2: Escribir el distintivo**

`lib/ui/common/estado_chip.dart`:

```dart
import 'package:flutter/material.dart';

import '../../domain/maintenance_due.dart';
import '../theme/status_colors.dart';

/// Distintivo de estado. Sin texto propio muestra la etiqueta del estado.
class EstadoChip extends StatelessWidget {
  final EstadoMantenimiento estado;
  final String? texto;

  const EstadoChip({super.key, required this.estado, this.texto});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final color = tema.coloresEstado.de(estado);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            texto ?? etiquetaEstado(estado),
            style: tema.textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
```

Si `withValues` no existe en tu versión de Flutter, usa `withOpacity(0.14)`.

- [ ] **Paso 3: Verificar**

```powershell
flutter analyze
```

Esperado: `No issues found!`

- [ ] **Paso 4: Commit**

```bash
git add -A && git commit -q -m "Añadir los colores y el distintivo de los estados de mantenimiento"
```

---

## Tarea 6: Providers de mantenimientos

**Ficheros:**
- Crear: `lib/providers/mantenimiento_providers.dart`
- Modificar: `lib/providers/recalculo_al_reanudar.dart`

**Interfaces:**
- Consume: `MaintenanceDao`, `calcularVencimiento`, `ritmoUsoProvider`, `ultimaLecturaProvider`.
- Produce: `MantenimientoConVencimiento` (con `schedule`, `ultimoRegistro`, `vencimiento`); `schedulesProvider` (family por `vehicleId`); `vencimientosProvider` (`FutureProvider.family<List<MantenimientoConVencimiento>, int>`); `estadoVehiculoProvider` (`FutureProvider.family<EstadoMantenimiento, int>`); `ajustesProvider`.

- [ ] **Paso 1: Escribir los providers**

`lib/providers/mantenimiento_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../domain/maintenance_due.dart';
import 'providers.dart';

class MantenimientoConVencimiento {
  final MaintenanceSchedule schedule;
  final MaintenanceRecord? ultimoRegistro;
  final Vencimiento vencimiento;

  const MantenimientoConVencimiento({
    required this.schedule,
    required this.ultimoRegistro,
    required this.vencimiento,
  });
}

final ajustesProvider = FutureProvider<Setting>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.settings).getSingle();
});

final schedulesProvider =
    StreamProvider.family<List<MaintenanceSchedule>, int>((ref, vehicleId) {
  return ref.watch(databaseProvider).maintenanceDao.watchSchedules(vehicleId);
});

/// Mantenimientos de un vehículo con su vencimiento ya calculado, ordenados
/// por urgencia: lo más vencido primero.
final vencimientosProvider =
    FutureProvider.family<List<MantenimientoConVencimiento>, int>(
        (ref, vehicleId) async {
  final db = ref.watch(databaseProvider);
  final schedules = await ref.watch(schedulesProvider(vehicleId).future);
  final ritmo = await ref.watch(ritmoUsoProvider(vehicleId).future);
  final ultimaLectura =
      await ref.watch(ultimaLecturaProvider(vehicleId).future);
  final ajustes = await ref.watch(ajustesProvider.future);
  final ultimos = await db.maintenanceDao.ultimosRecordsPorSchedule(vehicleId);

  final ahora = DateTime.now();
  final kmActual = ultimaLectura?.km ?? 0;
  final fechaLectura = ultimaLectura?.fecha ?? ahora;

  final resultado = <MantenimientoConVencimiento>[];
  for (final s in schedules.where((s) => s.activo)) {
    final ultimo = ultimos[s.id];
    resultado.add(
      MantenimientoConVencimiento(
        schedule: s,
        ultimoRegistro: ultimo,
        vencimiento: calcularVencimiento(
          datos: DatosVencimiento(
            intervalKm: s.intervalKm,
            intervalMeses: s.intervalMeses,
            avisoKm: s.avisoKm,
            avisoDias: s.avisoDias,
            ultimoKm: ultimo?.km,
            ultimaFecha: ultimo?.fecha,
          ),
          kmActual: kmActual,
          fechaUltimaLectura: fechaLectura,
          ritmo: ritmo,
          ahora: ahora,
          avisoKmPorDefecto: ajustes.avisoKmPorDefecto,
          avisoDiasPorDefecto: ajustes.avisoDiasPorDefecto,
        ),
      ),
    );
  }

  resultado.sort((a, b) => _urgencia(a).compareTo(_urgencia(b)));
  return resultado;
});

/// Estado general del vehículo: el peor de sus mantenimientos.
final estadoVehiculoProvider =
    FutureProvider.family<EstadoMantenimiento, int>((ref, vehicleId) async {
  final lista = await ref.watch(vencimientosProvider(vehicleId).future);
  if (lista.isEmpty) return EstadoMantenimiento.sinConfigurar;

  for (final estado in [
    EstadoMantenimiento.vencido,
    EstadoMantenimiento.atencion,
    EstadoMantenimiento.proximo,
    EstadoMantenimiento.ok,
  ]) {
    if (lista.any((m) => m.vencimiento.estado == estado)) return estado;
  }
  return EstadoMantenimiento.sinConfigurar;
});

/// Orden de urgencia para la lista: primero lo vencido, después lo que pide
/// atención, y dentro de cada grupo lo que antes llega.
int _urgencia(MantenimientoConVencimiento m) {
  final base = switch (m.vencimiento.estado) {
    EstadoMantenimiento.vencido => 0,
    EstadoMantenimiento.atencion => 1000000,
    EstadoMantenimiento.proximo => 2000000,
    EstadoMantenimiento.ok => 3000000,
    EstadoMantenimiento.sinConfigurar => 4000000,
  };
  final dias = m.vencimiento.diasRestantes ?? 9999;
  return base + dias.clamp(-9999, 9999);
}
```

Nota sobre `ajustesProvider`: si la expresión encadenada resulta confusa, escríbela en dos líneas leyendo `databaseProvider` en una variable local. Lo importante es que devuelva la única fila de `Settings`.

- [ ] **Paso 2: Registrar el recálculo al volver a primer plano**

En `lib/providers/recalculo_al_reanudar.dart`, añade `vencimientosProvider` y `estadoVehiculoProvider` a la lista `providersARecalcularAlReanudar`, con el import correspondiente. Los vencimientos dependen de la fecha de hoy, así que si la aplicación pasa días en segundo plano se quedarían obsoletos igual que el ritmo de uso.

- [ ] **Paso 3: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando.

- [ ] **Paso 4: Commit**

```bash
git add -A && git commit -q -m "Añadir los providers de mantenimientos y vencimientos"
```

---

## Tarea 7: Alta y edición de un mantenimiento

**Ficheros:**
- Crear: `lib/ui/maintenance/maintenance_form_screen.dart`

**Interfaces:**
- Consume: `MaintenanceDao`, `MaintenanceCategory`, `databaseProvider`.
- Produce: `MaintenanceFormScreen({required int vehicleId, MaintenanceSchedule? schedule})`; mapa `etiquetasCategoria`.

**Qué construir**

Formulario con: nombre, categoría (desplegable con las etiquetas en español), intervalo por kilómetros e intervalo por meses (ambos opcionales pero **al menos uno obligatorio**, validado en el formulario), márgenes de aviso propios (opcionales, con el texto que indique que si se dejan vacíos se usan los generales), interruptor de silenciado, y los datos del último mantenimiento realizado para sembrar el cálculo: fecha y kilometraje.

Al crear un mantenimiento con datos de siembra rellenos, se inserta también un `MaintenanceRecord` con `esSembrado: true`. Al editar, la siembra no se toca: ya existirán registros reales.

Etiquetas de categoría en español:

```dart
const Map<MaintenanceCategory, String> etiquetasCategoria = {
  MaintenanceCategory.motor: 'Motor',
  MaintenanceCategory.frenos: 'Frenos',
  MaintenanceCategory.neumaticos: 'Neumáticos',
  MaintenanceCategory.electricidad: 'Electricidad',
  MaintenanceCategory.suspension: 'Suspensión',
  MaintenanceCategory.transmision: 'Transmisión',
  MaintenanceCategory.carroceria: 'Carrocería',
  MaintenanceCategory.itv: 'ITV',
  MaintenanceCategory.otro: 'Otro',
};
```

Sigue el patrón de `lib/ui/vehicle/vehicle_form_screen.dart`: `ConsumerStatefulWidget`, controladores liberados en `dispose`, guarda de reentrada en el guardado, `try`/`catch` con `SnackBar` en español y `debugPrint`, y `if (!mounted) return;` tras cada `await`.

- [ ] **Paso 1: Escribir la pantalla**

Impleméntala según lo descrito. La validación de "al menos un intervalo" se hace en el `onPressed` de guardar: si ambos campos están vacíos, muestra un `SnackBar` explicando que hace falta al menos uno y no guarda.

- [ ] **Paso 2: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando.

- [ ] **Paso 3: Commit**

```bash
git add -A && git commit -q -m "Añadir el alta y edición de mantenimientos"
```

---

## Tarea 8: Registrar un mantenimiento realizado

**Ficheros:**
- Crear: `lib/ui/maintenance/register_maintenance_sheet.dart`

**Interfaces:**
- Consume: `MaintenanceDao`, `MileageDao`, `databaseProvider`, `formatearKm`, `formatearFecha`.
- Produce: `Future<void> mostrarRegistroMantenimiento(BuildContext, {required int vehicleId, MaintenanceSchedule? schedule})`.

**Qué construir**

Hoja inferior con: qué mantenimiento (preseleccionado si se llega desde uno concreto; desplegable si se llega desde la ficha), fecha (por defecto hoy), kilometraje (por defecto la última lectura), coste, taller y notas.

Al guardar: inserta el `MaintenanceRecord` y, en la misma operación, registra el kilometraje con `MileageDao.registrar` usando `MileageOrigin.mantenimiento`, salvo que el kilometraje introducido sea menor que la última lectura de ese día.

**Cuidado con el `MediaQuery`**: esta hoja lleva teclado. Usa el contexto del propio `builder`, no el de quien la abre, tal como se corrigió en `lib/ui/mileage/update_mileage_sheet.dart`. Léelo antes de escribir esta pantalla y sigue exactamente ese patrón, incluido el `SafeArea`.

- [ ] **Paso 1: Escribir la hoja**

- [ ] **Paso 2: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando.

- [ ] **Paso 3: Commit**

```bash
git add -A && git commit -q -m "Añadir el registro de mantenimientos realizados"
```

---

## Tarea 9: Ficha del vehículo

**Ficheros:**
- Crear: `lib/ui/vehicle/vehicle_detail_screen.dart`
- Modificar: `lib/ui/home/vehicle_card.dart`

**Interfaces:**
- Consume: `vencimientosProvider`, `estadoVehiculoProvider`, `ultimaLecturaProvider`, `EstadoChip`, `MaintenanceFormScreen`, `mostrarRegistroMantenimiento`, `VehicleFormScreen`.
- Produce: `VehicleDetailScreen({required Vehicle vehiculo})`.

**Qué construir**

Cabecera con la foto, el kilometraje y el distintivo de estado general. Debajo, el vencimiento más cercano destacado, con sus cifras: kilómetros que faltan, días, y el próximo kilometraje o fecha. Después, la lista de mantenimientos configurados con su distintivo de estado y su detalle.

Acciones: registrar un mantenimiento realizado, añadir un mantenimiento nuevo, y editar el vehículo.

Las cifras estimadas se marcan con `≈`, y el kilometraje que se muestra como dato es siempre el real, nunca el proyectado. Si `estimacionEsSupuesta` es cierto, el texto debe dejar claro que se apoya en un ritmo supuesto y no en lecturas reales.

**Cambio de comportamiento en la tarjeta:** hoy pulsar la tarjeta de un vehículo abre su edición. Pasa a abrir esta ficha, y la edición se alcanza desde dentro de ella. Actualiza `lib/ui/home/vehicle_card.dart` en consecuencia y añade a la tarjeta el distintivo de estado general leyendo `estadoVehiculoProvider`.

- [ ] **Paso 1: Escribir la ficha**

- [ ] **Paso 2: Cambiar la navegación de la tarjeta y añadirle el estado**

- [ ] **Paso 3: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando.

- [ ] **Paso 4: Commit**

```bash
git add -A && git commit -q -m "Añadir la ficha del vehículo con sus mantenimientos"
```

---

## Tarea 10: Plantillas al crear un vehículo

**Ficheros:**
- Crear: `lib/domain/plantillas_mantenimiento.dart`, `test/domain/plantillas_mantenimiento_test.dart`, `lib/ui/maintenance/plantillas_screen.dart`
- Modificar: `lib/ui/vehicle/vehicle_form_screen.dart`

**Interfaces:**
- Consume: `MaintenanceCategory`, `FuelType`, `proximaItv`, `mesesEntreItv`.
- Produce: `PlantillaMantenimiento` (`nombre`, `categoria`, `intervalKm`, `intervalMeses`); `List<PlantillaMantenimiento> plantillasPara({required FuelType combustible, required bool esAutomatico, DateTime? fechaMatriculacion})`.

**Los intervalos son orientativos, y la pantalla debe decirlo.** No son cifras oficiales de ningún fabricante: son valores razonables que el usuario ajusta con el libro de mantenimiento delante. Este aviso tiene que aparecer en la propia pantalla, no solo en el código.

- [ ] **Paso 1: Escribir el test que debe fallar**

`test/domain/plantillas_mantenimiento_test.dart`:

```dart
import 'package:car_care/data/tables/vehicles.dart';
import 'package:car_care/domain/plantillas_mantenimiento.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('un diesel incluye filtro de combustible y no bujias', () {
    final p = plantillasPara(
        combustible: FuelType.diesel, esAutomatico: false);
    final nombres = p.map((e) => e.nombre).toList();

    expect(nombres, contains('Filtro de combustible'));
    expect(nombres, isNot(contains('Bujías')));
  });

  test('un gasolina incluye bujias', () {
    final p = plantillasPara(
        combustible: FuelType.gasolina, esAutomatico: false);

    expect(p.map((e) => e.nombre), contains('Bujías'));
  });

  test('un electrico no incluye aceite de motor', () {
    final p = plantillasPara(
        combustible: FuelType.electrico, esAutomatico: false);

    expect(p.map((e) => e.nombre), isNot(contains('Aceite y filtro')));
  });

  test('un cambio automatico añade el aceite de la caja', () {
    final p = plantillasPara(combustible: FuelType.diesel, esAutomatico: true);

    expect(p.map((e) => e.nombre), contains('Aceite de la caja automática'));
  });

  test('la distribucion se propone sin intervalo, para que lo ponga el dueño',
      () {
    final p = plantillasPara(
        combustible: FuelType.diesel, esAutomatico: false);
    final distribucion =
        p.firstWhere((e) => e.nombre == 'Correa o cadena de distribución');

    expect(distribucion.intervalKm, isNull);
    expect(distribucion.intervalMeses, isNull);
  });

  test('la itv de un coche de mas de diez anios se propone anual', () {
    final p = plantillasPara(
      combustible: FuelType.diesel,
      esAutomatico: false,
      fechaMatriculacion: DateTime(2009, 1, 1),
    );
    final itv = p.firstWhere((e) => e.nombre == 'ITV');

    expect(itv.intervalMeses, 12);
  });

  test('la itv de un coche de entre cuatro y diez anios se propone bienal',
      () {
    final p = plantillasPara(
      combustible: FuelType.diesel,
      esAutomatico: false,
      fechaMatriculacion: DateTime(2018, 1, 1),
    );
    final itv = p.firstWhere((e) => e.nombre == 'ITV');

    expect(itv.intervalMeses, 24);
  });
}
```

- [ ] **Paso 2: Ejecutar el test para verificar que falla**

```powershell
flutter test test/domain/plantillas_mantenimiento_test.dart --reporter=failures-only
```

Esperado: FALLA porque el fichero no existe.

- [ ] **Paso 3: Escribir la implementación**

`lib/domain/plantillas_mantenimiento.dart`. Ojo: importa `FuelType` de `package:car_care/data/tables/vehicles.dart`, que es un fichero de la capa de datos y arrastra Drift. **Eso rompería la regla del dominio**, así que declara aquí el parámetro como el enum y comprueba con `grep` si el import resulta prohibido; si lo es, recibe el combustible como un enum propio del dominio y haz la conversión en la interfaz. Decide y explica tu decisión en el informe.

Contenido de las plantillas, con intervalos orientativos:

- Aceite y filtro — motor — 15.000 km / 12 meses (no para eléctricos)
- Filtro de aire — motor — 30.000 km / 24 meses (no para eléctricos)
- Filtro de habitáculo — otro — 20.000 km / 12 meses
- Filtro de combustible — motor — 40.000 km / 48 meses (solo diésel)
- Bujías — motor — 60.000 km / 60 meses (solo gasolina, híbrido y GLP)
- Líquido de frenos — frenos — sin km / 24 meses
- Refrigerante — motor — 60.000 km / 48 meses (no para eléctricos)
- Pastillas de freno delanteras — frenos — 40.000 km / sin meses
- Pastillas de freno traseras — frenos — 60.000 km / sin meses
- Discos de freno — frenos — 80.000 km / sin meses
- Neumáticos — neumáticos — 40.000 km / 72 meses
- Batería — electricidad — sin km / 60 meses
- Correa o cadena de distribución — motor — sin km / sin meses (no para eléctricos)
- Aceite de la caja automática — transmisión — 60.000 km / 72 meses (solo si es automático)
- ITV — itv — sin km / según antigüedad: 24 meses de 4 a 10 años, 12 a partir de 10, y 24 si aún no llega a 4 años o no hay fecha de matriculación

- [ ] **Paso 4: Ejecutar el test para verificar que pasa**

```powershell
flutter test test/domain/plantillas_mantenimiento_test.dart --reporter=failures-only
```

Esperado: `All tests passed!`

- [ ] **Paso 5: Escribir la pantalla de selección**

`lib/ui/maintenance/plantillas_screen.dart`: lista con casillas, todas marcadas por defecto salvo la distribución (que no tiene intervalo y hay que rellenarla), con el aviso visible de que los intervalos son orientativos y hay que ajustarlos al libro de mantenimiento. Un botón para confirmar que inserta los mantenimientos elegidos, y otro para saltarse el paso.

- [ ] **Paso 6: Engancharla en el alta de vehículo**

En `lib/ui/vehicle/vehicle_form_screen.dart`, cuando se crea un vehículo nuevo (no al editar), tras guardar con éxito se navega a la pantalla de plantillas con el `id` recién insertado, en lugar de volver directamente a Inicio. `insertar` ya devuelve el `id`.

- [ ] **Paso 7: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando.

- [ ] **Paso 8: Commit**

```bash
git add -A && git commit -q -m "Proponer los mantenimientos habituales al crear un vehículo"
```

---

## Tarea 11: Historial

**Ficheros:**
- Modificar: `lib/ui/shell/app_shell.dart`
- Crear: `lib/ui/history/history_screen.dart`

**Interfaces:**
- Consume: `MaintenanceDao.watchTodosLosRecords`, `vehiculosProvider`, `formatearKm`, `formatearFecha`.
- Produce: `HistoryScreen`.

**Qué construir**

Línea temporal descendente con los mantenimientos realizados de todos los vehículos: kilometraje, fecha, nombre del mantenimiento, vehículo y coste. Filtro por vehículo. Los registros sembrados se distinguen visualmente como datos anteriores a la aplicación.

Estado vacío con `EmptyState` cuando no hay nada registrado, explicando que aquí aparecerá lo que se vaya haciendo.

Sustituye el esqueleto `_PendienteFase2` de la pestaña Historial en `lib/ui/shell/app_shell.dart` por esta pantalla. Deja el de Ajustes como está: es de la fase 3.

- [ ] **Paso 1: Escribir la pantalla**

- [ ] **Paso 2: Engancharla en el shell**

- [ ] **Paso 3: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando.

- [ ] **Paso 4: Commit**

```bash
git add -A && git commit -q -m "Añadir el historial de mantenimientos"
```

---

## Tarea 12: Inicio con los próximos vencimientos

**Ficheros:**
- Modificar: `lib/ui/home/home_screen.dart`, `lib/ui/home/vehicle_card.dart`

**Interfaces:**
- Consume: `vencimientosProvider`, `estadoVehiculoProvider`, `EstadoChip`.

**Qué construir**

En cada tarjeta de vehículo, bajo el kilometraje, los tres vencimientos más cercanos con su distintivo de estado y sus cifras. Debajo de la lista de vehículos, la lista global de próximos mantenimientos de todos los coches ordenada por urgencia, indicando a qué vehículo pertenece cada uno.

Un vehículo sin mantenimientos configurados no debe parecer que está al día: muestra que no tiene nada configurado todavía y ofrece añadirlos.

- [ ] **Paso 1: Ampliar la tarjeta**

- [ ] **Paso 2: Añadir la lista global a Inicio**

- [ ] **Paso 3: Verificar y compilar**

```powershell
flutter analyze
flutter test --reporter=failures-only
flutter build apk --release
```

Esperado: `No issues found!`, todos los tests pasando y el APK construido.

- [ ] **Paso 4: Commit**

```bash
git add -A && git commit -q -m "Mostrar los próximos vencimientos en la pantalla de inicio"
```

---

## Qué queda para la fase 3

Notificaciones locales con el permiso `POST_NOTIFICATIONS`, el recordatorio periódico de lectura del kilometraje, la pantalla de Ajustes real con el selector de tema y los márgenes de aviso, y la copia de seguridad en `.zip`. Después, la fase 4 con componentes, facturas y gastos.
