# Fase 3 — Identidad técnica del vehículo

> **Para agentes ejecutores:** SUB-SKILL OBLIGATORIA: usa `superpowers:subagent-driven-development` (recomendada) o `superpowers:executing-plans` para implementar este plan tarea a tarea. Los pasos usan casillas (`- [ ]`) para el seguimiento.

**Objetivo:** que cada vehículo pueda tener una ficha técnica estructurada (generación, motor, potencia, caja de cambios, tracción) además de sus datos administrativos, como base para que un futuro catálogo de piezas pueda identificar la variante exacta en vez de adivinarla por el nombre comercial.

**Arquitectura:** una tabla nueva en relación uno a uno con `Vehicles`, dos enums de dominio siguiendo el patrón ya usado por `FuelType`/`MaintenanceCategory`, y una pantalla propia alcanzable desde la ficha del vehículo. Nada de esto toca la capa de red: es 100% manual y offline, como el resto de la aplicación hoy.

**Tech Stack:** Flutter, Drift (SQLite), Riverpod. Sin dependencias nuevas.

## Global Constraints

- Plataforma única: Android. `minSdkVersion` 24.
- Toda la interfaz en español. Fechas `dd/MM/yyyy`, separador de miles con punto.
- `lib/domain/` no puede importar `package:drift/...` ni `package:flutter/...`.
- Sin dependencias nuevas.
- Mensajes de commit en español, sin coautoría ni menciones a herramientas.
- **Entorno**: el toolchain no está en el PATH y la carpeta temporal debe redirigirse o Gradle no arranca. Antepón a cada comando de PowerShell:
  `$env:Path = "F:\dev\flutter\bin;F:\dev\android-sdk\platform-tools;$env:Path"; $env:JAVA_HOME = 'C:\Program Files\Eclipse Adoptium\jdk-17.0.20.8-hotspot'; $env:ANDROID_HOME = 'F:\dev\android-sdk'; $env:TMP = 'F:\dev\tmp'; $env:TEMP = 'F:\dev\tmp'`
- Punto de partida: `flutter analyze` limpio, 94 tests pasando.

## Decisiones de diseño ya cerradas (no reabrir sin motivo)

Estas decisiones vienen del documento de visión (`docs/superpowers/specs/2026-08-12-roadmap-identidad-tecnica-catalogo-piezas.md`, §5) y de un cierre de detalles posterior. Cada tarea las da por sentadas:

- **Pantalla propia**, alcanzable desde la ficha del vehículo. No se mete en `VehicleFormScreen`, que es para datos administrativos.
- **`vehicleId` es la clave primaria** de `VehicleSpecifications`, no un `id` autoincremental aparte: fuerza la relación 1:1 a nivel de esquema.
- **La potencia se guarda en kW**, como en la ficha técnica oficial. El CV se calcula al mostrarlo y nunca se persiste, para que no puedan desincronizarse.
- **`codigoTecnico` existe en el esquema pero no aparece en ningún formulario de esta fase.** No hay ningún flujo todavía que pueda rellenarlo (depende de un catálogo que no existe hasta la Fase 5/6), así que mostrar un campo que nadie puede completar sería confuso.
- **La fila de especificación no se crea al dar de alta el vehículo.** Se crea (o actualiza) la primera vez que se guarda algo en la pantalla nueva.
- Todos los campos son opcionales. Nadie debe sentirse obligado a rellenarlos.

---

## Estructura de ficheros

| Fichero | Responsabilidad |
|---|---|
| `lib/domain/tipo_caja.dart` | Enum `TipoCaja` |
| `lib/domain/traccion.dart` | Enum `Traccion` |
| `lib/domain/potencia.dart` | Conversión kW → CV, lógica pura |
| `lib/data/tables/vehicle_specifications.dart` | Tabla `VehicleSpecifications` |
| `lib/data/daos/vehicle_specification_dao.dart` | Acceso a datos de la ficha técnica |
| `lib/providers/providers.dart` | Se amplía con el provider de la ficha técnica |
| `lib/ui/vehicle/vehicle_form_screen.dart` | Se amplía con el campo del VIN (columna ya existente desde la fase 1, sin usar en pantalla hasta ahora) |
| `lib/ui/vehicle/vehicle_specification_screen.dart` | Pantalla de alta/edición de la ficha técnica |
| `lib/ui/vehicle/vehicle_detail_screen.dart` | Se amplía con el acceso a la pantalla nueva |
| `test/domain/potencia_test.dart` | Tests de la conversión kW/CV |
| `test/data/vehicle_specification_dao_test.dart` | Tests del DAO |
| `test/data/database_migration_test.dart` | Se amplía con el test de migración v3→v4 |

---

## Tarea 1: Enums de dominio — caja de cambios y tracción

**Ficheros:**
- Crear: `lib/domain/tipo_caja.dart`, `lib/domain/traccion.dart`

**Interfaces:**
- Produce: enum `TipoCaja { manual, automatica }`; enum `Traccion { delantera, trasera, total }`; mapas `etiquetasTipoCaja` y `etiquetasTraccion` con el texto en español de cada valor.

- [ ] **Paso 1: Escribir `TipoCaja`**

`lib/domain/tipo_caja.dart`:

```dart
/// Tipo de caja de cambios del vehículo.
///
/// El nombre del enum y el de sus valores forman parte del formato en el
/// que Drift guarda la columna `tipoCaja` de `VehicleSpecifications`, vía
/// `textEnum`: se serializan como texto por nombre. No se pueden renombrar
/// sin romper los datos ya guardados en el dispositivo del usuario.
enum TipoCaja { manual, automatica }

const Map<TipoCaja, String> etiquetasTipoCaja = {
  TipoCaja.manual: 'Manual',
  TipoCaja.automatica: 'Automática',
};
```

- [ ] **Paso 2: Escribir `Traccion`**

`lib/domain/traccion.dart`:

```dart
/// Tracción del vehículo.
///
/// El nombre del enum y el de sus valores forman parte del formato en el
/// que Drift guarda la columna `traccion` de `VehicleSpecifications`, vía
/// `textEnum`: se serializan como texto por nombre. No se pueden renombrar
/// sin romper los datos ya guardados en el dispositivo del usuario.
enum Traccion { delantera, trasera, total }

const Map<Traccion, String> etiquetasTraccion = {
  Traccion.delantera: 'Delantera',
  Traccion.trasera: 'Trasera',
  Traccion.total: 'Total',
};
```

- [ ] **Paso 3: Verificar**

```powershell
flutter analyze
```

Esperado: `No issues found!`

- [ ] **Paso 4: Commit**

```bash
git add -A && git commit -q -m "Añadir los enums de caja de cambios y tracción"
```

---

## Tarea 2: Conversión de potencia kW → CV

Lógica de dominio pura, la única de esta fase con cálculo real que merece tests dedicados.

**Ficheros:**
- Crear: `lib/domain/potencia.dart`, `test/domain/potencia_test.dart`

**Interfaces:**
- Produce: función `int kwACv(int kw)`.

- [ ] **Paso 1: Escribir el test que debe fallar**

`test/domain/potencia_test.dart`:

```dart
import 'package:car_care/domain/potencia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('convierte kilovatios a caballos de vapor métricos', () {
    // 1 kW = 1,35962 CV. 140 kW es la potencia real de ejemplo del roadmap.
    expect(kwACv(140), 190);
  });

  test('redondea al entero mas cercano, no trunca', () {
    // 100 kW = 135,962 CV -> redondea a 136, no a 135.
    expect(kwACv(100), 136);
  });

  test('cero kilovatios da cero CV', () {
    expect(kwACv(0), 0);
  });
}
```

- [ ] **Paso 2: Ejecutar el test para verificar que falla**

```powershell
flutter test test/domain/potencia_test.dart --reporter=failures-only
```

Esperado: FALLA porque `lib/domain/potencia.dart` no existe.

- [ ] **Paso 3: Escribir la implementación**

`lib/domain/potencia.dart`:

```dart
/// 1 kW equivale a 1,35962 CV métricos (caballos de vapor, DIN).
const double _kwACvFactor = 1.35962;

/// Convierte kilovatios a CV para mostrar, redondeando al entero más
/// cercano. La potencia se guarda siempre en kW; el CV es solo de
/// presentación y nunca se persiste, para que no puedan desincronizarse.
int kwACv(int kw) => (kw * _kwACvFactor).round();
```

- [ ] **Paso 4: Ejecutar el test para verificar que pasa**

```powershell
flutter test test/domain/potencia_test.dart --reporter=failures-only
```

Esperado: `All tests passed!`

- [ ] **Paso 5: Comprobar que el dominio sigue limpio**

```bash
grep -E "package:(drift|flutter)/" lib/domain/potencia.dart
```

Esperado: sin salida.

- [ ] **Paso 6: Commit**

```bash
git add -A && git commit -q -m "Añadir la conversión de potencia de kilovatios a CV"
```

---

## Tarea 3: Tabla `VehicleSpecifications` y migración

**Ficheros:**
- Crear: `lib/data/tables/vehicle_specifications.dart`
- Modificar: `lib/data/database.dart`
- Test: `test/data/database_migration_test.dart` (ampliar)

**Interfaces:**
- Consume: `TipoCaja`, `Traccion` de la Tarea 1.
- Produce: tabla `VehicleSpecifications`; fila `VehicleSpecification`; `schemaVersion` 4.

- [ ] **Paso 1: Escribir la tabla**

`lib/data/tables/vehicle_specifications.dart`:

```dart
import 'package:drift/drift.dart';

import '../../domain/tipo_caja.dart';
import '../../domain/traccion.dart';
import 'vehicles.dart';

export '../../domain/tipo_caja.dart';
export '../../domain/traccion.dart';

/// Ficha técnica de un vehículo, en relación uno a uno con [Vehicles].
///
/// `vehicleId` es la clave primaria de esta tabla, no un `id` autoincremental
/// aparte: así la relación 1:1 queda forzada por el propio esquema, no solo
/// por convención en el código.
class VehicleSpecifications extends Table {
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();

  TextColumn get generacion => text().nullable()();
  TextColumn get motorCodigo => text().nullable()();
  IntColumn get cilindradaCc => integer().nullable()();

  /// Siempre en kilovatios, como en la ficha técnica oficial. El CV se
  /// calcula al mostrarlo (ver `lib/domain/potencia.dart`) y nunca se
  /// guarda aquí.
  IntColumn get potenciaKw => integer().nullable()();

  TextColumn get tipoCaja => textEnum<TipoCaja>().nullable()();
  IntColumn get numeroMarchas => integer().nullable()();
  TextColumn get traccion => textEnum<Traccion>().nullable()();

  /// Identificador de variante de un catálogo externo (p. ej. el KType de
  /// TecDoc). Nunca se rellena a mano: solo lo resolverá un catálogo, si
  /// alguna vez existe. Sin UI en esta fase.
  TextColumn get codigoTecnico => text().nullable()();

  TextColumn get notasTecnicas => text().nullable()();

  @override
  Set<Column> get primaryKey => {vehicleId};
}
```

- [ ] **Paso 2: Registrar la tabla y la migración**

En `lib/data/database.dart`:

Añade el import junto a los demás:

```dart
import 'tables/vehicle_specifications.dart';
```

Añade `VehicleSpecifications` a la lista `tables` de `@DriftDatabase`:

```dart
@DriftDatabase(
  tables: [
    Vehicles,
    MileageReadings,
    Settings,
    MaintenanceSchedules,
    MaintenanceRecords,
    VehicleSpecifications,
  ],
  daos: [VehicleDao, MileageDao, MaintenanceDao],
)
```

Sube `schemaVersion` a 4:

```dart
  int get schemaVersion => 4;
```

Amplía el `onUpgrade`, manteniendo intactos los pasos `from < 2` y `from < 3` ya existentes:

```dart
          // v3 -> v4: se añade la ficha técnica del vehículo.
          if (from < 4) {
            await m.createTable(vehicleSpecifications);
          }
```

- [ ] **Paso 3: Escribir el test de migración que debe fallar**

Añade este test a `test/data/database_migration_test.dart`, dentro del mismo `main()` que ya contiene los de v1→v2 y v2→v3. Reutiliza los imports que ya están en el fichero (`dart:io`, `package:car_care/data/database.dart`, `package:drift/native.dart`, `package:flutter_test/flutter_test.dart`, `package:path/path.dart as p`, `package:sqlite3/sqlite3.dart as sqlite3`).

```dart
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

      final version =
          await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.data['user_version'], 4);

      // Lo que ya había sigue ahí.
      final vehiculos = await db.select(db.vehicles).get();
      expect(vehiculos, hasLength(1));
      expect(vehiculos.single.marca, 'BMW');
      expect(vehiculos.single.modelo, 'Serie 3');

      // La tabla nueva existe, está vacía y se puede usar.
      expect(await db.select(db.vehicleSpecifications).get(), isEmpty);

      final vehicleId = vehiculos.single.id;
      await db.into(db.vehicleSpecifications).insert(
            VehicleSpecificationsCompanion.insert(
              vehicleId: Value(vehicleId),
              motorCodigo: const Value('B47'),
            ),
          );
      final guardada = await (db.select(db.vehicleSpecifications)
            ..where((s) => s.vehicleId.equals(vehicleId)))
          .getSingle();
      expect(guardada.motorCodigo, 'B47');

      await db.close();
    },
  );
```

Nota: `VehicleSpecificationsCompanion.insert` recibe `vehicleId` como parámetro nombrado obligatorio porque es la clave primaria y no autoincremental — Drift lo exige explícito. Escríbelo como `Value(vehicleId)` o directamente `vehicleId` según lo que pida el compilador tras generar el código; ambas formas son válidas en `.insert()` para un campo obligatorio no autoincremental, usa la que no dé error.

- [ ] **Paso 4: Ejecutar el test para verificar que falla**

```powershell
flutter test test/data/database_migration_test.dart --reporter=failures-only
```

Esperado: FALLA porque el código generado por Drift todavía no conoce `VehicleSpecifications`.

- [ ] **Paso 5: Regenerar el código de Drift**

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Esperado: `Succeeded after ...`

- [ ] **Paso 6: Ejecutar los tests**

```powershell
flutter test --reporter=failures-only
```

Esperado: `All tests passed!`

- [ ] **Paso 7: Commit**

```bash
git add -A && git commit -q -m "Añadir la tabla de la ficha técnica del vehículo"
```

---

## Tarea 4: DAO de la ficha técnica

**Ficheros:**
- Crear: `lib/data/daos/vehicle_specification_dao.dart`, `test/data/vehicle_specification_dao_test.dart`
- Modificar: `lib/data/database.dart` (registrar el DAO)

**Interfaces:**
- Consume: tabla de la Tarea 3.
- Produce: `VehicleSpecificationDao` con `watchFor(int vehicleId)` (`Stream<VehicleSpecification?>`), `getFor(int vehicleId)` (`Future<VehicleSpecification?>`), `guardar(VehicleSpecificationsCompanion)` (`Future<void>`, inserta o actualiza según exista ya la fila).

- [ ] **Paso 1: Escribir el DAO**

`lib/data/daos/vehicle_specification_dao.dart`:

```dart
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
```

- [ ] **Paso 2: Registrar el DAO**

En `lib/data/database.dart`, añade el import:

```dart
import 'daos/vehicle_specification_dao.dart';
```

Y amplía la lista `daos`:

```dart
  daos: [VehicleDao, MileageDao, MaintenanceDao, VehicleSpecificationDao],
```

- [ ] **Paso 3: Escribir el test que debe fallar**

`test/data/vehicle_specification_dao_test.dart`:

```dart
import 'package:car_care/data/database.dart';
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
        marca: Value('BMW'),
        modelo: Value('Serie 3'),
        combustible: Value(FuelType.diesel),
      ),
    );
  });
  tearDown(() => db.close());

  test('sin ficha guardada, getFor y watchFor devuelven null', () async {
    expect(await db.vehicleSpecificationDao.getFor(vehicleId), isNull);
    expect(
      await db.vehicleSpecificationDao.watchFor(vehicleId).first,
      isNull,
    );
  });

  test('guardar crea la ficha la primera vez', () async {
    await db.vehicleSpecificationDao.guardar(
      VehicleSpecificationsCompanion.insert(
        vehicleId: Value(vehicleId),
        motorCodigo: const Value('B47'),
        potenciaKw: const Value(140),
      ),
    );

    final guardada = await db.vehicleSpecificationDao.getFor(vehicleId);

    expect(guardada!.motorCodigo, 'B47');
    expect(guardada.potenciaKw, 140);
  });

  test('guardar dos veces actualiza en vez de duplicar', () async {
    await db.vehicleSpecificationDao.guardar(
      VehicleSpecificationsCompanion.insert(
        vehicleId: Value(vehicleId),
        motorCodigo: const Value('B47'),
      ),
    );
    await db.vehicleSpecificationDao.guardar(
      VehicleSpecificationsCompanion.insert(
        vehicleId: Value(vehicleId),
        motorCodigo: const Value('B48'),
      ),
    );

    final todas = await db.select(db.vehicleSpecifications).get();
    final guardada = await db.vehicleSpecificationDao.getFor(vehicleId);

    expect(todas, hasLength(1));
    expect(guardada!.motorCodigo, 'B48');
  });

  test('borrar el vehiculo arrastra su ficha tecnica', () async {
    await db.vehicleSpecificationDao.guardar(
      VehicleSpecificationsCompanion.insert(
        vehicleId: Value(vehicleId),
        motorCodigo: const Value('B47'),
      ),
    );

    await (db.delete(db.vehicles)..where((v) => v.id.equals(vehicleId))).go();

    expect(await db.select(db.vehicleSpecifications).get(), isEmpty);
  });
}
```

- [ ] **Paso 4: Ejecutar el test para verificar que falla**

```powershell
flutter test test/data/vehicle_specification_dao_test.dart --reporter=failures-only
```

Esperado: FALLA por `vehicle_specification_dao.g.dart` no generado.

- [ ] **Paso 5: Regenerar y ejecutar**

```powershell
dart run build_runner build --delete-conflicting-outputs
flutter test --reporter=failures-only
```

Esperado: `All tests passed!`

- [ ] **Paso 6: Commit**

```bash
git add -A && git commit -q -m "Añadir el acceso a datos de la ficha técnica del vehículo"
```

---

## Tarea 5: Provider de la ficha técnica

**Ficheros:**
- Modificar: `lib/providers/providers.dart`

**Interfaces:**
- Consume: `VehicleSpecificationDao` de la Tarea 4.
- Produce: `vehicleSpecificationProvider` (`StreamProvider.family<VehicleSpecification?, int>`, por `vehicleId`).

- [ ] **Paso 1: Añadir el provider**

En `lib/providers/providers.dart`, junto a los demás providers `family` por vehículo (sigue el mismo patrón que `ultimaLecturaProvider`):

```dart
final vehicleSpecificationProvider =
    StreamProvider.family<VehicleSpecification?, int>((ref, vehicleId) {
  return ref.watch(databaseProvider).vehicleSpecificationDao.watchFor(vehicleId);
});
```

- [ ] **Paso 2: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando.

- [ ] **Paso 3: Commit**

```bash
git add -A && git commit -q -m "Añadir el provider de la ficha técnica del vehículo"
```

---

## Tarea 6: Campo del VIN en el formulario de vehículo

`Vehicles.vin` existe en el esquema desde la fase 1 (`text().nullable()`), pero no hay ningún campo en pantalla que lo use — se quedó sin conectar. El roadmap (§5) lo pide como parte de esta fase: "se ofrece un campo opcional al dar de alta o editar el vehículo, con una ayuda visual de dónde encontrarlo".

**Ficheros:**
- Modificar: `lib/ui/vehicle/vehicle_form_screen.dart`

**Interfaces:**
- Consume: `Vehicle.vin` (ya existe en el esquema, sin cambios de datos en esta tarea).

- [ ] **Paso 1: Añadir el controlador**

Junto a la declaración de `_matricula` (línea 42), añade:

```dart
  late final TextEditingController _vin;
```

- [ ] **Paso 2: Inicializarlo y liberarlo**

En `initState`, junto a la inicialización de `_matricula` (línea 85):

```dart
    _vin = TextEditingController(text: v?.vin ?? '');
```

En `dispose`, añade `_vin` a la lista que ya se recorre (línea 101):

```dart
    for (final c in [_marca, _modelo, _version, _anio, _matricula, _color, _vin]) {
```

- [ ] **Paso 3: Guardarlo al actualizar y al crear**

En `_guardar`, en la rama de edición (línea 214, junto a `matricula`):

```dart
            vin: Value(textoONulo(_vin)),
```

Y en la rama de alta (línea 229, junto a `matricula`):

```dart
            vin: Value(textoONulo(_vin)),
```

- [ ] **Paso 4: Añadir el campo al formulario**

Busca el `TextFormField` de matrícula (alrededor de la línea 426) y añade justo después uno para el VIN:

```dart
            const SizedBox(height: 12),
            TextFormField(
              controller: _vin,
              decoration: const InputDecoration(
                labelText: 'VIN (número de bastidor)',
                hintText: 'Lo encuentras en el parabrisas del lado del '
                    'conductor o en el permiso de circulación',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
```

- [ ] **Paso 5: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando. No hace falta test nuevo: es un campo de texto opcional que sigue el mismo patrón que `matricula`, sin lógica propia que probar.

- [ ] **Paso 6: Commit**

```bash
git add -A && git commit -q -m "Añadir el campo del VIN al formulario de vehículo"
```

---

## Tarea 7: Pantalla de la ficha técnica

**Ficheros:**
- Crear: `lib/ui/vehicle/vehicle_specification_screen.dart`
- Modificar: `lib/ui/vehicle/vehicle_detail_screen.dart` (acceso desde la ficha del vehículo)

**Interfaces:**
- Consume: `vehicleSpecificationProvider`, `VehicleSpecificationDao.guardar`, `TipoCaja`/`etiquetasTipoCaja`, `Traccion`/`etiquetasTraccion`, `kwACv`.
- Produce: `VehicleSpecificationScreen({required int vehicleId})`.

**Qué construir**

Formulario con: generación, código de motor, cilindrada (cc), potencia (kW, con el CV calculado mostrado al lado como texto de ayuda, nunca editable), tipo de caja (desplegable con `etiquetasTipoCaja`), número de marchas, tracción (desplegable con `etiquetasTraccion`), y notas técnicas. **Sin campo para `codigoTecnico`**: no tiene ningún flujo que pueda rellenarlo todavía.

Al abrir la pantalla, si ya existe una ficha guardada (`vehicleSpecificationProvider` con datos), los campos se rellenan con lo que haya. Si no existe (`null`), el formulario aparece vacío. Guardar llama siempre a `VehicleSpecificationDao.guardar(...)` con `vehicleId: Value(widget.vehicleId)`: como es upsert por diseño, no hace falta distinguir alta de edición en la pantalla.

**Patrón a seguir**, tal como se ha hecho en toda la fase 2: lee `lib/ui/vehicle/vehicle_form_screen.dart` antes de escribir nada y sigue sus mismos criterios, que son requisitos de esta tarea y no sugerencias:
- Todo `setState` o uso de `BuildContext` posterior a un `await`, precedido de `if (!mounted) return;`.
- Guarda de reentrada en el botón de guardar.
- La escritura en `try`/`catch`, con `SnackBar` en español y `debugPrint` del detalle.
- Controladores de texto liberados en `dispose`.

**El campo de potencia en kW junto al CV calculado**: al escribir en el campo de kW, se recalcula y se muestra el CV correspondiente con `kwACv(...)` en un texto de ayuda debajo del campo (por ejemplo "≈ 190 CV"), actualizado con cada cambio. Si el campo está vacío, no se muestra nada.

**Acceso desde la ficha del vehículo**: en `lib/ui/vehicle/vehicle_detail_screen.dart`, añade una entrada para llegar a esta pantalla nueva. El sitio natural es junto al icono de "Editar vehículo" que ya existe en el `AppBar` (`actions`), con un icono distinto (por ejemplo `Icons.settings_suggest_outlined` o `Icons.build_outlined`) y tooltip "Identidad técnica", que navega con `Navigator.of(context).push(MaterialPageRoute(builder: (_) => VehicleSpecificationScreen(vehicleId: vehiculo.id)))`.

- [ ] **Paso 1: Escribir la pantalla**

- [ ] **Paso 2: Añadir el acceso desde la ficha del vehículo**

- [ ] **Paso 3: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando.

- [ ] **Paso 4: Commit**

```bash
git add -A && git commit -q -m "Añadir la pantalla de identidad técnica del vehículo"
```

---

## Tarea 8: Verificación final y APK

**Ficheros:** ninguno nuevo.

- [ ] **Paso 1: Verificación completa**

```powershell
flutter analyze
flutter test --reporter=failures-only
flutter build apk --release
```

Esperado: `No issues found!`, todos los tests pasando (94 previos + los añadidos en esta fase), y el APK construido.

- [ ] **Paso 2: Commit**

```bash
git add -A && git commit -q -m "Cerrar la fase 3: identidad técnica del vehículo" --allow-empty
```

---

## Qué queda para después

La Fase 4 (motor de recomendaciones: agrupación de mantenimientos, estado de confianza confirmado/histórico/desconocido derivado de `esSembrado`, aprendizaje del patrón real de uso, `fuenteIntervalo` en `MaintenanceSchedules`) y la Fase 5 (decidir la fuente del catálogo de piezas) están descritas en `docs/superpowers/specs/2026-08-12-roadmap-identidad-tecnica-catalogo-piezas.md`, sin plan de implementación todavía.
