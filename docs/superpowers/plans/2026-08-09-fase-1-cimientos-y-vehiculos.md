# Fase 1 — Cimientos, vehículos y kilometraje

> **Para agentes ejecutores:** SUB-SKILL OBLIGATORIA: usa `superpowers:subagent-driven-development` (recomendada) o `superpowers:executing-plans` para implementar este plan tarea a tarea. Los pasos usan casillas (`- [ ]`) para el seguimiento.

**Objetivo:** dejar instalada en el móvil una aplicación Flutter que gestiona vehículos y su histórico de kilometraje, sobre una base de datos local probada y con la lógica del ritmo de uso ya implementada.

**Arquitectura:** tres capas — `data/` con Drift sobre SQLite, `domain/` con lógica pura sin dependencias de base de datos ni de Flutter, y `ui/` con las pantallas. El estado se distribuye con Riverpod, alimentado por consultas reactivas de Drift. Nada de red, nada de autenticación.

**Stack:** Flutter, Dart, Drift (SQLite), Riverpod, image_picker, path_provider.

## Restricciones globales

- Plataforma única: Android. `--platforms android` en la creación del proyecto.
- `minSdkVersion` 24.
- Toda la interfaz en español. Fechas en formato `dd/MM/yyyy`, importes en euros, separador de miles con punto.
- Los ficheros de dominio (`lib/domain/`) no pueden importar `package:drift/...` ni `package:flutter/...`.
- Los valores derivados no se persisten: el kilometraje actual es siempre la lectura más reciente.
- Salida de consola mínima: usar los modos silenciosos de cada comando tal como aparecen en los pasos.
- Mensajes de commit en español, sin coautoría ni referencias a herramientas.
- No se instala `google_fonts`: se usa la tipografía del sistema con cifras tabulares.

---

## Estructura de ficheros

| Fichero | Responsabilidad |
|---|---|
| `lib/main.dart` | Punto de entrada, arranque de Riverpod |
| `lib/app.dart` | `MaterialApp`, temas e idioma |
| `lib/data/tables/vehicles.dart` | Tabla de vehículos y enum de combustible |
| `lib/data/tables/mileage_readings.dart` | Tabla de lecturas de kilometraje |
| `lib/data/tables/settings.dart` | Tabla de ajustes, fila única |
| `lib/data/database.dart` | `AppDatabase`, apertura, migraciones |
| `lib/data/daos/vehicle_dao.dart` | Consultas de vehículos |
| `lib/data/daos/mileage_dao.dart` | Consultas de kilometraje |
| `lib/domain/usage_rate.dart` | Cálculo del ritmo de uso, lógica pura |
| `lib/providers/providers.dart` | Providers de Riverpod |
| `lib/ui/theme/app_theme.dart` | Temas claro y oscuro |
| `lib/ui/shell/app_shell.dart` | Navegación de tres pestañas |
| `lib/ui/home/home_screen.dart` | Pantalla de inicio |
| `lib/ui/home/vehicle_card.dart` | Tarjeta de vehículo |
| `lib/ui/vehicle/vehicle_form_screen.dart` | Alta y edición de vehículo |
| `lib/ui/mileage/update_mileage_sheet.dart` | Hoja de actualización de kilometraje |
| `lib/ui/common/empty_state.dart` | Estado vacío reutilizable |
| `lib/ui/common/formatters.dart` | Formato de kilómetros y fechas en español |
| `test/domain/usage_rate_test.dart` | Tests del ritmo de uso |
| `test/data/vehicle_dao_test.dart` | Tests del DAO de vehículos |
| `test/data/mileage_dao_test.dart` | Tests del DAO de kilometraje |

---

## Tarea 0: Preparar el entorno de desarrollo

No hay tests: es instalación. La verificación es `flutter doctor`.

Flutter no necesita Android Studio, solo el SDK de Android. Instalando únicamente las *command-line tools* se baja de unos 8 GB a unos 3 y todo el proceso es automatizable, sin asistentes gráficos.

Todo se instala en `F:\dev`, no bajo el perfil del usuario: la ruta del perfil contiene espacios y Gradle y el SDK de Android los llevan mal.

**Ficheros:** ninguno.

- [ ] **Paso 1: Instalar el JDK 17**

El Java del sistema es el 8 y el plugin de Gradle para Android necesita el 17.

`winget` no está en el PATH de una consola no interactiva, así que se invoca por su ruta completa:

```powershell
& "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe" install --id EclipseAdoptium.Temurin.17.JDK --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
```

Esperado: termina con `Instalado correctamente`.

- [ ] **Paso 2: Descargar el SDK de Flutter y las command-line tools de Android**

La versión estable de Flutter se consulta en el índice oficial de versiones, para no fijar una URL que caduque:

```powershell
$ProgressPreference='SilentlyContinue'
$dl = "$env:TEMP\claude-dl"; New-Item -ItemType Directory -Force -Path $dl | Out-Null
$j = Invoke-RestMethod -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json' -UseBasicParsing
$rel = $j.releases | Where-Object { $_.hash -eq $j.current_release.stable -and $_.channel -eq 'stable' } | Select-Object -First 1
Invoke-WebRequest -Uri "$($j.base_url)/$($rel.archive)" -OutFile "$dl\flutter.zip" -UseBasicParsing
Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/commandlinetools-win-15859902_latest.zip' -OutFile "$dl\cmdline-tools.zip" -UseBasicParsing
```

Son unos 1,8 GB y 148 MB. Tarda varios minutos.

- [ ] **Paso 3: Extraer**

`tar` viene con Windows 11 y descomprime zip mucho más rápido que `Expand-Archive`.

```powershell
$dl = "$env:TEMP\claude-dl"
New-Item -ItemType Directory -Force -Path 'F:\dev' | Out-Null
tar -xf "$dl\flutter.zip" -C 'F:\dev'
tar -xf "$dl\cmdline-tools.zip" -C $dl
New-Item -ItemType Directory -Force -Path 'F:\dev\android-sdk\cmdline-tools' | Out-Null
Move-Item "$dl\cmdline-tools" 'F:\dev\android-sdk\cmdline-tools\latest'
```

El `sdkmanager` exige que las herramientas cuelguen de `cmdline-tools\latest`; con cualquier otro nombre de carpeta falla.

- [ ] **Paso 4: Instalar los componentes del SDK de Android y aceptar las licencias**

El `sdkmanager` pide confirmación por la entrada estándar, y en una consola no interactiva esa entrada está anulada: un pipe de PowerShell no le llega y el proceso se queda esperando. La forma que sí funciona es redirigir un fichero real a través de `cmd`, que crea su propia entrada estándar.

```powershell
$env:JAVA_HOME = (Get-ChildItem 'C:\Program Files\Eclipse Adoptium' -Filter 'jdk-17*' -Directory | Select-Object -First 1).FullName
$sdk = 'F:\dev\android-sdk'
$mgr = "$sdk\cmdline-tools\latest\bin\sdkmanager.bat"
$yes = "$env:TEMP\yes.txt"
Set-Content -Path $yes -Value (@('y') * 40) -Encoding ascii
cmd /c "`"$mgr`" --sdk_root=`"$sdk`" --licenses < `"$yes`""
cmd /c "`"$mgr`" --sdk_root=`"$sdk`" platform-tools `"platforms;android-36`" `"build-tools;36.0.0`""
```

Esperado: `All SDK package licenses accepted` y siete ficheros en `F:\dev\android-sdk\licenses`.

La versión de la plataforma tiene que coincidir con la que exija tu Flutter: la 3.44.9 pide la 36. Si `flutter doctor` reclama otra, instálala con el mismo comando cambiando el número.

El `sdkmanager` avisa de que está obsoleto en favor del nuevo binario `android`; sigue funcionando y es lo que espera `flutter doctor`.

- [ ] **Paso 5: Dejar las rutas en el PATH del usuario**

```powershell
$ruta = [Environment]::GetEnvironmentVariable('Path','User')
[Environment]::SetEnvironmentVariable('Path', "$ruta;F:\dev\flutter\bin;F:\dev\android-sdk\platform-tools", 'User')
[Environment]::SetEnvironmentVariable('ANDROID_HOME', 'F:\dev\android-sdk', 'User')
```

Reabre la terminal para que surta efecto.

- [ ] **Paso 6: Apuntar Flutter al SDK y al JDK**

```powershell
flutter config --android-sdk 'F:\dev\android-sdk'
flutter config --jdk-dir (Get-ChildItem 'C:\Program Files\Eclipse Adoptium' -Filter 'jdk-17*' | Select-Object -First 1).FullName
```

- [ ] **Paso 7: Comprobación final del entorno**

```bash
flutter doctor 2>&1 | grep -E "^\[" | head -6
```

Esperado: `[√] Flutter` y `[√] Android toolchain` sin cruces. Las líneas de Visual Studio, Chrome o Android Studio pueden llevar `!`; no bloquean la compilación para Android.

---

## Tarea 1: Crear el proyecto Flutter

**Ficheros:**
- Crear: todo el esqueleto del proyecto en la raíz
- Modificar: `android/app/build.gradle.kts`, `android/app/src/main/AndroidManifest.xml`

**Interfaces:**
- Produce: proyecto compilable con el paquete `com.dcastillo.car_care`.

- [ ] **Paso 1: Generar el proyecto en el directorio actual**

El directorio ya contiene `.git` y `docs/`; `flutter create` convive con ellos sin problema.

```bash
cd "F:/Documentos/IA/Aplicacion_Coche" && flutter create --project-name car_care --org com.dcastillo --platforms android --description "Seguimiento de mantenimientos de vehiculos" . 2>&1 | tail -3
```

Esperado: termina con `All done!` o similar.

- [ ] **Paso 2: Fijar minSdkVersion en 24**

Abre `android/app/build.gradle.kts` (si tu versión de Flutter genera Groovy en lugar de Kotlin DSL, el fichero será `android/app/build.gradle` y la sintaxis lleva espacio en vez de `=`).

Busca dentro de `defaultConfig`:

```kotlin
minSdk = flutter.minSdkVersion
```

Sustitúyelo por:

```kotlin
minSdk = 24
```

- [ ] **Paso 3: Poner el nombre visible de la aplicación**

En `android/app/src/main/AndroidManifest.xml`, dentro de la etiqueta `<application>`, cambia:

```xml
android:label="car_care"
```

por:

```xml
android:label="Mis Vehículos"
```

- [ ] **Paso 4: Verificar que analiza y compila**

```bash
flutter analyze 2>&1 | tail -2
```

Esperado: `No issues found!`

- [ ] **Paso 5: Verificar que el toolchain de Android construye**

```bash
flutter build apk --debug 2>&1 | tail -2
```

Esperado: una línea que empieza por `√ Built build\app\outputs\flutter-apk\app-debug.apk`. Este paso tarda varios minutos la primera vez porque Gradle descarga sus dependencias.

- [ ] **Paso 6: Commit**

```bash
git add -A && git commit -q -m "Crear proyecto Flutter para Android con minSdk 24"
```

---

## Tarea 2: Base de datos y tabla de vehículos

**Ficheros:**
- Crear: `lib/data/tables/vehicles.dart`, `lib/data/tables/mileage_readings.dart`, `lib/data/tables/settings.dart`, `lib/data/database.dart`, `lib/data/daos/vehicle_dao.dart`
- Crear: `test/data/vehicle_dao_test.dart`

**Interfaces:**
- Produce: `AppDatabase` con constructor `AppDatabase.forTesting(QueryExecutor)`; clases de fila `Vehicle`, `MileageReading`, `Setting`; `VehicleDao` con `watchActivos()`, `getById(int)`, `insertar(VehiclesCompanion)`, `actualizar(Vehicle)`, `archivar(int)`; enums `FuelType` y `MileageOrigin`.

- [ ] **Paso 1: Añadir las dependencias**

```bash
flutter pub add drift sqlite3_flutter_libs path_provider path 2>&1 | tail -2 && dart pub add -d drift_dev build_runner 2>&1 | tail -2
```

- [ ] **Paso 2: Poner sqlite3.dll en la raíz para los tests**

Los tests corren en Windows, no en Android, y ahí `sqlite3_flutter_libs` no aplica. Descarga desde `https://www.sqlite.org/download.html` el fichero de *Precompiled Binaries for Windows*, `sqlite-dll-win-x64-*.zip`, y extrae `sqlite3.dll` a la raíz del proyecto, junto a `pubspec.yaml`.

Verifica:

```bash
ls sqlite3.dll
```

Esperado: `sqlite3.dll`

- [ ] **Paso 3: Escribir la tabla de vehículos**

`lib/data/tables/vehicles.dart`:

```dart
import 'package:drift/drift.dart';

enum FuelType { gasolina, diesel, hibrido, electrico, glp }

class Vehicles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get marca => text().withLength(min: 1, max: 60)();
  TextColumn get modelo => text().withLength(min: 1, max: 60)();
  TextColumn get version => text().nullable()();
  IntColumn get anio => integer().nullable()();
  TextColumn get matricula => text().nullable()();
  TextColumn get combustible => textEnum<FuelType>()();
  DateTimeColumn get fechaMatriculacion => dateTime().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get fotoPath => text().nullable()();
  TextColumn get vin => text().nullable()();
  TextColumn get notas => text().nullable()();
  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get archivado => boolean().withDefault(const Constant(false))();
}
```

- [ ] **Paso 4: Escribir la tabla de lecturas de kilometraje**

`lib/data/tables/mileage_readings.dart`:

```dart
import 'package:drift/drift.dart';

import 'vehicles.dart';

enum MileageOrigin { manual, mantenimiento }

class MileageReadings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get fecha => dateTime()();
  IntColumn get km => integer()();
  TextColumn get origen => textEnum<MileageOrigin>()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {vehicleId, fecha},
      ];
}
```

- [ ] **Paso 5: Escribir la tabla de ajustes**

`lib/data/tables/settings.dart`:

```dart
import 'package:drift/drift.dart';

class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get avisoKmPorDefecto => integer().withDefault(const Constant(1000))();
  IntColumn get avisoDiasPorDefecto => integer().withDefault(const Constant(30))();
  IntColumn get diasRecordatorioLectura =>
      integer().withDefault(const Constant(15))();
  TextColumn get tema => text().withDefault(const Constant('automatico'))();
  DateTimeColumn get fechaUltimaCopia => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [ ] **Paso 6: Escribir la base de datos**

`lib/data/database.dart`:

```dart
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
```

- [ ] **Paso 7: Escribir el DAO de vehículos**

`lib/data/daos/vehicle_dao.dart`:

```dart
import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/vehicles.dart';

part 'vehicle_dao.g.dart';

@DriftAccessor(tables: [Vehicles])
class VehicleDao extends DatabaseAccessor<AppDatabase> with _$VehicleDaoMixin {
  VehicleDao(super.db);

  Stream<List<Vehicle>> watchActivos() {
    return (select(vehicles)
          ..where((v) => v.archivado.equals(false))
          ..orderBy([(v) => OrderingTerm(expression: v.creadoEn)]))
        .watch();
  }

  Future<Vehicle?> getById(int id) {
    return (select(vehicles)..where((v) => v.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertar(VehiclesCompanion vehiculo) {
    return into(vehicles).insert(vehiculo);
  }

  Future<bool> actualizar(Vehicle vehiculo) {
    return update(vehicles).replace(vehiculo);
  }

  Future<int> archivar(int id) {
    return (update(vehicles)..where((v) => v.id.equals(id)))
        .write(const VehiclesCompanion(archivado: Value(true)));
  }
}
```

- [ ] **Paso 8: Escribir el test que debe fallar**

`test/data/vehicle_dao_test.dart`:

```dart
import 'package:car_care/data/database.dart';
import 'package:car_care/data/tables/vehicles.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  VehiclesCompanion _mercedes() => const VehiclesCompanion(
        marca: Value('Mercedes-Benz'),
        modelo: Value('Clase B'),
        version: Value('B 180'),
        anio: Value(2009),
        combustible: Value(FuelType.diesel),
        color: Value('Rojo'),
      );

  test('inserta un vehiculo y lo recupera por id', () async {
    final id = await db.vehicleDao.insertar(_mercedes());

    final guardado = await db.vehicleDao.getById(id);

    expect(guardado, isNotNull);
    expect(guardado!.marca, 'Mercedes-Benz');
    expect(guardado.combustible, FuelType.diesel);
    expect(guardado.archivado, isFalse);
  });

  test('watchActivos emite los vehiculos no archivados', () async {
    await db.vehicleDao.insertar(_mercedes());

    final activos = await db.vehicleDao.watchActivos().first;

    expect(activos, hasLength(1));
    expect(activos.single.modelo, 'Clase B');
  });

  test('archivar excluye el vehiculo de watchActivos', () async {
    final id = await db.vehicleDao.insertar(_mercedes());

    await db.vehicleDao.archivar(id);
    final activos = await db.vehicleDao.watchActivos().first;

    expect(activos, isEmpty);
    expect((await db.vehicleDao.getById(id))!.archivado, isTrue);
  });

  test('la fila de ajustes se crea con los valores por defecto', () async {
    final ajustes = await db.select(db.settings).getSingle();

    expect(ajustes.avisoKmPorDefecto, 1000);
    expect(ajustes.avisoDiasPorDefecto, 30);
    expect(ajustes.diasRecordatorioLectura, 15);
    expect(ajustes.tema, 'automatico');
  });
}
```

- [ ] **Paso 9: Ejecutar el test para verificar que falla**

```bash
flutter test test/data/vehicle_dao_test.dart --reporter=failures-only 2>&1 | tail -5
```

Esperado: FALLA con errores de compilación del tipo `Target of URI hasn't been generated: 'database.g.dart'`. Es lo correcto: el código generado por Drift todavía no existe.

- [ ] **Paso 10: Generar el código de Drift**

```bash
dart run build_runner build --delete-conflicting-outputs 2>&1 | tail -3
```

Esperado: `Succeeded after ...` sin errores. Crea `lib/data/database.g.dart` y `lib/data/daos/vehicle_dao.g.dart`.

- [ ] **Paso 11: Ejecutar el test para verificar que pasa**

```bash
flutter test test/data/vehicle_dao_test.dart --reporter=failures-only 2>&1 | tail -3
```

Esperado: `All tests passed!`

Si falla con `Failed to load dynamic library 'sqlite3.dll'`, revisa el paso 2.

- [ ] **Paso 12: Borrar el widget test de ejemplo**

El que genera `flutter create` prueba la app de demostración y va a estorbar.

```bash
rm test/widget_test.dart
```

- [ ] **Paso 13: Commit**

```bash
git add -A && git commit -q -m "Añadir base de datos Drift con vehículos, lecturas y ajustes"
```

---

## Tarea 3: DAO de kilometraje

**Ficheros:**
- Crear: `lib/data/daos/mileage_dao.dart`, `test/data/mileage_dao_test.dart`
- Modificar: `lib/data/database.dart` (registrar el DAO)

**Interfaces:**
- Consume: `AppDatabase`, tabla `MileageReadings`, enum `MileageOrigin` de la Tarea 2.
- Produce: `MileageDao` con `registrar({required int vehicleId, required DateTime fecha, required int km, MileageOrigin origen})`, `watchUltima(int vehicleId)`, `ultimaLectura(int vehicleId)`, `lecturasDesde(int vehicleId, DateTime desde)`, `watchTodas(int vehicleId)`; y la función `soloFecha(DateTime)`.

- [ ] **Paso 1: Escribir el DAO**

`lib/data/daos/mileage_dao.dart`:

```dart
import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/mileage_readings.dart';

part 'mileage_dao.g.dart';

/// Normaliza una fecha a medianoche. La unicidad de lecturas es por día.
DateTime soloFecha(DateTime fecha) =>
    DateTime(fecha.year, fecha.month, fecha.day);

@DriftAccessor(tables: [MileageReadings])
class MileageDao extends DatabaseAccessor<AppDatabase> with _$MileageDaoMixin {
  MileageDao(super.db);

  /// Guarda una lectura. Si ya existe una del mismo día para ese vehículo,
  /// la sustituye.
  Future<void> registrar({
    required int vehicleId,
    required DateTime fecha,
    required int km,
    MileageOrigin origen = MileageOrigin.manual,
  }) {
    return into(mileageReadings).insert(
      MileageReadingsCompanion.insert(
        vehicleId: vehicleId,
        fecha: soloFecha(fecha),
        km: km,
        origen: origen,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Stream<MileageReading?> watchUltima(int vehicleId) {
    return _consultaUltima(vehicleId).watchSingleOrNull();
  }

  Future<MileageReading?> ultimaLectura(int vehicleId) {
    return _consultaUltima(vehicleId).getSingleOrNull();
  }

  SimpleSelectStatement<$MileageReadingsTable, MileageReading> _consultaUltima(
    int vehicleId,
  ) {
    return select(mileageReadings)
      ..where((l) => l.vehicleId.equals(vehicleId))
      ..orderBy([
        (l) => OrderingTerm(expression: l.fecha, mode: OrderingMode.desc),
      ])
      ..limit(1);
  }

  Future<List<MileageReading>> lecturasDesde(int vehicleId, DateTime desde) {
    return (select(mileageReadings)
          ..where((l) =>
              l.vehicleId.equals(vehicleId) &
              l.fecha.isBiggerOrEqualValue(soloFecha(desde)))
          ..orderBy([(l) => OrderingTerm(expression: l.fecha)]))
        .get();
  }

  Stream<List<MileageReading>> watchTodas(int vehicleId) {
    return (select(mileageReadings)
          ..where((l) => l.vehicleId.equals(vehicleId))
          ..orderBy([
            (l) => OrderingTerm(expression: l.fecha, mode: OrderingMode.desc),
          ]))
        .watch();
  }
}
```

- [ ] **Paso 2: Registrar el DAO en la base de datos**

En `lib/data/database.dart`, añade el import y amplía la lista `daos`:

```dart
import 'daos/mileage_dao.dart';
```

```dart
@DriftDatabase(
  tables: [Vehicles, MileageReadings, Settings],
  daos: [VehicleDao, MileageDao],
)
```

- [ ] **Paso 3: Escribir el test que debe fallar**

`test/data/mileage_dao_test.dart`:

```dart
import 'package:car_care/data/database.dart';
import 'package:car_care/data/tables/mileage_readings.dart';
import 'package:car_care/data/tables/vehicles.dart';
import 'package:drift/drift.dart';
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

  test('registra una lectura y la devuelve como ultima', () async {
    await db.mileageDao.registrar(
      vehicleId: vehicleId,
      fecha: DateTime(2026, 8, 1),
      km: 98420,
    );

    final ultima = await db.mileageDao.ultimaLectura(vehicleId);

    expect(ultima!.km, 98420);
    expect(ultima.origen, MileageOrigin.manual);
    expect(ultima.fecha, DateTime(2026, 8, 1));
  });

  test('la ultima lectura es la de fecha mas reciente, no la ultima insertada',
      () async {
    await db.mileageDao
        .registrar(vehicleId: vehicleId, fecha: DateTime(2026, 8, 5), km: 98900);
    await db.mileageDao
        .registrar(vehicleId: vehicleId, fecha: DateTime(2026, 8, 1), km: 98420);

    final ultima = await db.mileageDao.ultimaLectura(vehicleId);

    expect(ultima!.km, 98900);
  });

  test('dos lecturas del mismo dia dejan solo la ultima', () async {
    await db.mileageDao
        .registrar(vehicleId: vehicleId, fecha: DateTime(2026, 8, 1), km: 98420);
    await db.mileageDao
        .registrar(vehicleId: vehicleId, fecha: DateTime(2026, 8, 1), km: 98500);

    final todas = await db.mileageDao.watchTodas(vehicleId).first;

    expect(todas, hasLength(1));
    expect(todas.single.km, 98500);
  });

  test('la hora del dia no crea lecturas duplicadas', () async {
    await db.mileageDao.registrar(
        vehicleId: vehicleId, fecha: DateTime(2026, 8, 1, 9, 30), km: 98420);
    await db.mileageDao.registrar(
        vehicleId: vehicleId, fecha: DateTime(2026, 8, 1, 21, 15), km: 98460);

    final todas = await db.mileageDao.watchTodas(vehicleId).first;

    expect(todas, hasLength(1));
    expect(todas.single.km, 98460);
  });

  test('lecturasDesde filtra por fecha', () async {
    await db.mileageDao
        .registrar(vehicleId: vehicleId, fecha: DateTime(2026, 1, 10), km: 90000);
    await db.mileageDao
        .registrar(vehicleId: vehicleId, fecha: DateTime(2026, 7, 10), km: 97000);

    final recientes =
        await db.mileageDao.lecturasDesde(vehicleId, DateTime(2026, 6, 1));

    expect(recientes, hasLength(1));
    expect(recientes.single.km, 97000);
  });

  test('borrar el vehiculo arrastra sus lecturas', () async {
    await db.mileageDao
        .registrar(vehicleId: vehicleId, fecha: DateTime(2026, 8, 1), km: 98420);

    await (db.delete(db.vehicles)..where((v) => v.id.equals(vehicleId))).go();
    final todas = await db.mileageDao.watchTodas(vehicleId).first;

    expect(todas, isEmpty);
  });
}
```

- [ ] **Paso 4: Ejecutar el test para verificar que falla**

```bash
flutter test test/data/mileage_dao_test.dart --reporter=failures-only 2>&1 | tail -5
```

Esperado: FALLA por `mileage_dao.g.dart` no generado.

- [ ] **Paso 5: Regenerar el código de Drift**

```bash
dart run build_runner build --delete-conflicting-outputs 2>&1 | tail -3
```

Esperado: `Succeeded after ...`

- [ ] **Paso 6: Ejecutar los tests para verificar que pasan**

```bash
flutter test --reporter=failures-only 2>&1 | tail -3
```

Esperado: `All tests passed!` — pasan los del DAO de vehículos y los de kilometraje.

- [ ] **Paso 7: Commit**

```bash
git add -A && git commit -q -m "Añadir DAO de kilometraje con unicidad por día"
```

---

## Tarea 4: Cálculo del ritmo de uso

Lógica pura, sin Drift y sin Flutter. Es la pieza de la que dependerá el motor de vencimientos de la fase 2.

**Ficheros:**
- Crear: `lib/domain/usage_rate.dart`, `test/domain/usage_rate_test.dart`

**Interfaces:**
- Produce: clase `MileagePoint({required DateTime fecha, required int km})`; clase `UsageRateResult` con `double kmPorDia`, `bool esPorDefecto`, `bool get cocheParado`; función estática `UsageRate.calcular({required List<MileagePoint> lecturas, required DateTime ahora})`; constantes `kRitmoPorDefecto`, `kVentanaDias`, `kMinDiasEntreLecturas`, `kUmbralCocheParado`.

- [ ] **Paso 1: Escribir el test que debe fallar**

`test/domain/usage_rate_test.dart`:

```dart
import 'package:car_care/domain/usage_rate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ahora = DateTime(2026, 8, 9);

  test('sin lecturas devuelve el ritmo por defecto', () {
    final r = UsageRate.calcular(lecturas: const [], ahora: ahora);

    expect(r.kmPorDia, kRitmoPorDefecto);
    expect(r.esPorDefecto, isTrue);
  });

  test('con una sola lectura devuelve el ritmo por defecto', () {
    final r = UsageRate.calcular(
      lecturas: [MileagePoint(fecha: DateTime(2026, 7, 1), km: 90000)],
      ahora: ahora,
    );

    expect(r.esPorDefecto, isTrue);
  });

  test('calcula el ritmo entre la lectura mas antigua y la mas reciente', () {
    final r = UsageRate.calcular(
      lecturas: [
        MileagePoint(fecha: DateTime(2026, 7, 10), km: 90000),
        MileagePoint(fecha: DateTime(2026, 8, 9), km: 91500),
      ],
      ahora: ahora,
    );

    // 1.500 km en 30 días
    expect(r.kmPorDia, closeTo(50.0, 0.001));
    expect(r.esPorDefecto, isFalse);
  });

  test('ignora las lecturas anteriores a la ventana de 90 dias', () {
    final r = UsageRate.calcular(
      lecturas: [
        MileagePoint(fecha: DateTime(2025, 1, 1), km: 10000),
        MileagePoint(fecha: DateTime(2026, 7, 10), km: 90000),
        MileagePoint(fecha: DateTime(2026, 8, 9), km: 91500),
      ],
      ahora: ahora,
    );

    expect(r.kmPorDia, closeTo(50.0, 0.001));
  });

  test('lecturas demasiado juntas no bastan para calcular el ritmo', () {
    final r = UsageRate.calcular(
      lecturas: [
        MileagePoint(fecha: DateTime(2026, 8, 6), km: 90000),
        MileagePoint(fecha: DateTime(2026, 8, 9), km: 90300),
      ],
      ahora: ahora,
    );

    expect(r.esPorDefecto, isTrue);
  });

  test('el orden de la lista no afecta al resultado', () {
    final r = UsageRate.calcular(
      lecturas: [
        MileagePoint(fecha: DateTime(2026, 8, 9), km: 91500),
        MileagePoint(fecha: DateTime(2026, 7, 10), km: 90000),
      ],
      ahora: ahora,
    );

    expect(r.kmPorDia, closeTo(50.0, 0.001));
  });

  test('un coche parado se detecta como tal', () {
    final r = UsageRate.calcular(
      lecturas: [
        MileagePoint(fecha: DateTime(2026, 6, 1), km: 90000),
        MileagePoint(fecha: DateTime(2026, 8, 9), km: 90020),
      ],
      ahora: ahora,
    );

    expect(r.cocheParado, isTrue);
    expect(r.esPorDefecto, isFalse);
  });

  test('el ritmo por defecto nunca se considera coche parado', () {
    final r = UsageRate.calcular(lecturas: const [], ahora: ahora);

    expect(r.cocheParado, isFalse);
  });

  test('un retroceso de kilometros no produce un ritmo negativo', () {
    final r = UsageRate.calcular(
      lecturas: [
        MileagePoint(fecha: DateTime(2026, 7, 1), km: 95000),
        MileagePoint(fecha: DateTime(2026, 8, 9), km: 90000),
      ],
      ahora: ahora,
    );

    expect(r.esPorDefecto, isTrue);
    expect(r.kmPorDia, greaterThan(0));
  });
}
```

- [ ] **Paso 2: Ejecutar el test para verificar que falla**

```bash
flutter test test/domain/usage_rate_test.dart --reporter=failures-only 2>&1 | tail -5
```

Esperado: FALLA con `Target of URI doesn't exist: 'package:car_care/domain/usage_rate.dart'`.

- [ ] **Paso 3: Escribir la implementación**

`lib/domain/usage_rate.dart`:

```dart
/// Ritmo por defecto mientras no hay datos suficientes: 12.000 km al año.
const double kRitmoPorDefecto = 33.0;

/// Ventana de lecturas que se tiene en cuenta.
const int kVentanaDias = 90;

/// Separación mínima entre la primera y la última lectura de la ventana.
const int kMinDiasEntreLecturas = 7;

/// Por debajo de este ritmo el coche se considera parado.
const double kUmbralCocheParado = 1.0;

/// Lectura de kilometraje independiente de la capa de datos.
class MileagePoint {
  final DateTime fecha;
  final int km;

  const MileagePoint({required this.fecha, required this.km});
}

class UsageRateResult {
  final double kmPorDia;

  /// Cierto cuando no había lecturas suficientes y se ha usado el valor inicial.
  final bool esPorDefecto;

  const UsageRateResult({required this.kmPorDia, required this.esPorDefecto});

  /// Un coche parado no genera avisos por kilometraje. El valor por defecto
  /// nunca cuenta como coche parado: es una suposición, no una medición.
  bool get cocheParado => !esPorDefecto && kmPorDia < kUmbralCocheParado;
}

class UsageRate {
  const UsageRate._();

  static UsageRateResult calcular({
    required List<MileagePoint> lecturas,
    required DateTime ahora,
  }) {
    final inicioVentana = ahora.subtract(const Duration(days: kVentanaDias));
    final ventana = lecturas
        .where((l) => !l.fecha.isBefore(inicioVentana))
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    if (ventana.length >= 2) {
      final primera = ventana.first;
      final ultima = ventana.last;
      final dias = ultima.fecha.difference(primera.fecha).inDays;
      final km = ultima.km - primera.km;

      if (dias >= kMinDiasEntreLecturas && km >= 0) {
        return UsageRateResult(kmPorDia: km / dias, esPorDefecto: false);
      }
    }

    return const UsageRateResult(
      kmPorDia: kRitmoPorDefecto,
      esPorDefecto: true,
    );
  }
}
```

- [ ] **Paso 4: Ejecutar el test para verificar que pasa**

```bash
flutter test test/domain/usage_rate_test.dart --reporter=failures-only 2>&1 | tail -3
```

Esperado: `All tests passed!`

- [ ] **Paso 5: Comprobar que el dominio no depende de Drift ni de Flutter**

```bash
grep -E "package:(drift|flutter)/" lib/domain/usage_rate.dart | head -3
```

Esperado: sin salida.

- [ ] **Paso 6: Commit**

```bash
git add -A && git commit -q -m "Añadir cálculo del ritmo de uso a partir del histórico de lecturas"
```

---

## Tarea 5: Tema visual

**Ficheros:**
- Crear: `lib/ui/theme/app_theme.dart`, `lib/app.dart`
- Modificar: `lib/main.dart`

**Interfaces:**
- Produce: `AppTheme.claro()`, `AppTheme.oscuro()`, `AppTheme.cifras` (`TextStyle` con cifras tabulares); widget `CarCareApp`.

- [ ] **Paso 1: Añadir Riverpod y la localización**

```bash
flutter pub add flutter_riverpod intl 2>&1 | tail -2
```

Añade también las delegaciones de idioma. En `pubspec.yaml`, dentro de `dependencies`:

```yaml
  flutter_localizations:
    sdk: flutter
```

Y después:

```bash
flutter pub get 2>&1 | tail -2
```

- [ ] **Paso 2: Escribir el tema**

`lib/ui/theme/app_theme.dart`:

```dart
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

/// Azul petróleo. Deliberadamente distinto del rojo y el azul de los coches,
/// para que las fotos destaquen sobre la interfaz en lugar de competir con ella.
const Color _semilla = Color(0xFF0F5C6B);

const Color _fondoClaro = Color(0xFFF5F7F8);
const Color _superficieClara = Color(0xFFFFFFFF);
const Color _fondoOscuro = Color(0xFF11161A);
const Color _superficieOscura = Color(0xFF1A2126);

class AppTheme {
  const AppTheme._();

  /// Cifras de anchura fija: los kilómetros no bailan al actualizarse.
  static const TextStyle cifras = TextStyle(
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static ThemeData claro() => _base(Brightness.light);

  static ThemeData oscuro() => _base(Brightness.dark);

  static ThemeData _base(Brightness brillo) {
    final claro = brillo == Brightness.light;
    final esquema = ColorScheme.fromSeed(
      seedColor: _semilla,
      brightness: brillo,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: claro ? _fondoClaro : _fondoOscuro,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: claro ? _superficieClara : _superficieOscura,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: claro ? _fondoClaro : _fondoOscuro,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: claro ? _superficieClara : _superficieOscura,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
```

Si tu versión de Flutter da un error de tipo en `cardTheme`, sustituye `CardThemeData` por `CardTheme`: el nombre cambió en versiones recientes.

- [ ] **Paso 3: Escribir el widget raíz**

`lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'ui/theme/app_theme.dart';

class CarCareApp extends StatelessWidget {
  const CarCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis Vehículos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro(),
      darkTheme: AppTheme.oscuro(),
      themeMode: ThemeMode.system,
      locale: const Locale('es', 'ES'),
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const Scaffold(
        body: Center(child: Text('Mis Vehículos')),
      ),
    );
  }
}
```

- [ ] **Paso 4: Reescribir el punto de entrada**

`lib/main.dart`, sustituyendo todo el contenido:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  runApp(const ProviderScope(child: CarCareApp()));
}
```

- [ ] **Paso 5: Verificar que analiza y que los tests siguen pasando**

```bash
flutter analyze 2>&1 | tail -2 && flutter test --reporter=failures-only 2>&1 | tail -2
```

Esperado: `No issues found!` y `All tests passed!`

- [ ] **Paso 6: Commit**

```bash
git add -A && git commit -q -m "Añadir tema claro y oscuro y arranque con Riverpod"
```

---

## Tarea 6: Providers y navegación de tres pestañas

**Ficheros:**
- Crear: `lib/providers/providers.dart`, `lib/ui/shell/app_shell.dart`, `lib/ui/common/empty_state.dart`, `lib/ui/home/home_screen.dart`
- Modificar: `lib/app.dart` (usar el shell como `home`)

**Interfaces:**
- Consume: `AppDatabase`, `VehicleDao`, `MileageDao` de las tareas 2 y 3.
- Produce: `databaseProvider`, `vehiculosProvider` (`StreamProvider<List<Vehicle>>`), `ultimaLecturaProvider` (`StreamProvider.family<MileageReading?, int>`), `ritmoUsoProvider` (`FutureProvider.family<UsageRateResult, int>`); widgets `AppShell`, `HomeScreen`, `EmptyState`.

- [ ] **Paso 1: Escribir los providers**

`lib/providers/providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../domain/usage_rate.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final vehiculosProvider = StreamProvider<List<Vehicle>>((ref) {
  return ref.watch(databaseProvider).vehicleDao.watchActivos();
});

final ultimaLecturaProvider =
    StreamProvider.family<MileageReading?, int>((ref, vehicleId) {
  return ref.watch(databaseProvider).mileageDao.watchUltima(vehicleId);
});

final ritmoUsoProvider =
    FutureProvider.family<UsageRateResult, int>((ref, vehicleId) async {
  final db = ref.watch(databaseProvider);
  final ahora = DateTime.now();
  final lecturas = await db.mileageDao.lecturasDesde(
    vehicleId,
    ahora.subtract(const Duration(days: kVentanaDias)),
  );

  return UsageRate.calcular(
    lecturas: lecturas
        .map((l) => MileagePoint(fecha: l.fecha, km: l.km))
        .toList(),
    ahora: ahora,
  );
});
```

- [ ] **Paso 2: Escribir el estado vacío reutilizable**

`lib/ui/common/empty_state.dart`:

```dart
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final Widget? accion;

  const EmptyState({
    super.key,
    required this.icono,
    required this.titulo,
    required this.descripcion,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56, color: tema.colorScheme.outline),
            const SizedBox(height: 16),
            Text(titulo, style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              descripcion,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyMedium
                  ?.copyWith(color: tema.colorScheme.outline),
            ),
            if (accion != null) ...[
              const SizedBox(height: 24),
              accion!,
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Paso 3: Escribir la pantalla de inicio provisional**

Muestra la lista de vehículos en texto plano. La tarjeta bonita llega en la Tarea 8.

`lib/ui/home/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../common/empty_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiculos = ref.watch(vehiculosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis vehículos')),
      body: vehiculos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error al cargar: $e')),
        data: (lista) {
          if (lista.isEmpty) {
            return const EmptyState(
              icono: Icons.directions_car_outlined,
              titulo: 'Todavía no hay vehículos',
              descripcion:
                  'Añade tu primer coche para empezar a llevar su kilometraje.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (context, i) => ListTile(
              title: Text('${lista[i].marca} ${lista[i].modelo}'),
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Paso 4: Escribir el shell de navegación**

`lib/ui/shell/app_shell.dart`:

```dart
import 'package:flutter/material.dart';

import '../home/home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _indice = 0;

  static const _pantallas = [
    HomeScreen(),
    _PendienteFase2(
      titulo: 'Historial',
      descripcion: 'El historial de mantenimientos llega en la próxima fase.',
    ),
    _PendienteFase2(
      titulo: 'Ajustes',
      descripcion: 'Los ajustes llegan en la próxima fase.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indice, children: _pantallas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}

class _PendienteFase2 extends StatelessWidget {
  final String titulo;
  final String descripcion;

  const _PendienteFase2({required this.titulo, required this.descripcion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(descripcion, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
```

- [ ] **Paso 5: Enganchar el shell en la aplicación**

En `lib/app.dart`, añade el import y sustituye la propiedad `home`:

```dart
import 'ui/shell/app_shell.dart';
```

```dart
      home: const AppShell(),
```

- [ ] **Paso 6: Verificar**

```bash
flutter analyze 2>&1 | tail -2 && flutter test --reporter=failures-only 2>&1 | tail -2
```

Esperado: `No issues found!` y `All tests passed!`

- [ ] **Paso 7: Commit**

```bash
git add -A && git commit -q -m "Añadir navegación de tres pestañas y providers de datos"
```

---

## Tarea 7: Alta y edición de vehículo

**Ficheros:**
- Crear: `lib/ui/vehicle/vehicle_form_screen.dart`
- Modificar: `lib/ui/home/home_screen.dart` (botón de añadir)

**Interfaces:**
- Consume: `databaseProvider`, `VehicleDao.insertar/actualizar`, enum `FuelType`.
- Produce: `VehicleFormScreen({Vehicle? vehiculo})`. Sin argumento crea; con argumento edita.

- [ ] **Paso 1: Añadir image_picker**

```bash
flutter pub add image_picker 2>&1 | tail -2
```

- [ ] **Paso 2: Escribir la pantalla de formulario**

`lib/ui/vehicle/vehicle_form_screen.dart`:

```dart
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/database.dart';
import '../../data/tables/vehicles.dart';
import '../../providers/providers.dart';

const Map<FuelType, String> etiquetasCombustible = {
  FuelType.gasolina: 'Gasolina',
  FuelType.diesel: 'Diésel',
  FuelType.hibrido: 'Híbrido',
  FuelType.electrico: 'Eléctrico',
  FuelType.glp: 'GLP',
};

class VehicleFormScreen extends ConsumerStatefulWidget {
  final Vehicle? vehiculo;

  const VehicleFormScreen({super.key, this.vehiculo});

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formatoFecha = DateFormat('dd/MM/yyyy', 'es_ES');

  late final TextEditingController _marca;
  late final TextEditingController _modelo;
  late final TextEditingController _version;
  late final TextEditingController _anio;
  late final TextEditingController _matricula;
  late final TextEditingController _color;

  FuelType _combustible = FuelType.diesel;
  DateTime? _fechaMatriculacion;
  String? _fotoPath;
  bool _guardando = false;

  bool get _esEdicion => widget.vehiculo != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehiculo;
    _marca = TextEditingController(text: v?.marca ?? '');
    _modelo = TextEditingController(text: v?.modelo ?? '');
    _version = TextEditingController(text: v?.version ?? '');
    _anio = TextEditingController(text: v?.anio?.toString() ?? '');
    _matricula = TextEditingController(text: v?.matricula ?? '');
    _color = TextEditingController(text: v?.color ?? '');
    _combustible = v?.combustible ?? FuelType.diesel;
    _fechaMatriculacion = v?.fechaMatriculacion;
    _fotoPath = v?.fotoPath;
  }

  @override
  void dispose() {
    for (final c in [_marca, _modelo, _version, _anio, _matricula, _color]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    final elegida = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (elegida == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final carpeta = Directory(p.join(dir.path, 'fotos'));
    await carpeta.create(recursive: true);

    final destino = p.join(
      carpeta.path,
      '${DateTime.now().millisecondsSinceEpoch}${p.extension(elegida.path)}',
    );
    await File(elegida.path).copy(destino);

    setState(() => _fotoPath = destino);
  }

  Future<void> _elegirFechaMatriculacion() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaMatriculacion ?? DateTime(2015),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (elegida != null) setState(() => _fechaMatriculacion = elegida);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final dao = ref.read(databaseProvider).vehicleDao;
    String? textoONulo(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();

    if (_esEdicion) {
      await dao.actualizar(
        widget.vehiculo!.copyWith(
          marca: _marca.text.trim(),
          modelo: _modelo.text.trim(),
          version: Value(textoONulo(_version)),
          anio: Value(int.tryParse(_anio.text.trim())),
          matricula: Value(textoONulo(_matricula)),
          combustible: _combustible,
          fechaMatriculacion: Value(_fechaMatriculacion),
          color: Value(textoONulo(_color)),
          fotoPath: Value(_fotoPath),
        ),
      );
    } else {
      await dao.insertar(
        VehiclesCompanion(
          marca: Value(_marca.text.trim()),
          modelo: Value(_modelo.text.trim()),
          version: Value(textoONulo(_version)),
          anio: Value(int.tryParse(_anio.text.trim())),
          matricula: Value(textoONulo(_matricula)),
          combustible: Value(_combustible),
          fechaMatriculacion: Value(_fechaMatriculacion),
          color: Value(textoONulo(_color)),
          fotoPath: Value(_fotoPath),
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar vehículo' : 'Nuevo vehículo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _SelectorFoto(ruta: _fotoPath, onPulsar: _elegirFoto),
            const SizedBox(height: 24),
            TextFormField(
              controller: _marca,
              decoration: const InputDecoration(labelText: 'Marca'),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Indica la marca' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _modelo,
              decoration: const InputDecoration(labelText: 'Modelo'),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Indica el modelo' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _version,
              decoration: const InputDecoration(
                labelText: 'Versión',
                hintText: '2.0 TDI 150 CV DSG',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<FuelType>(
              initialValue: _combustible,
              decoration: const InputDecoration(labelText: 'Combustible'),
              items: FuelType.values
                  .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(etiquetasCombustible[f]!),
                      ))
                  .toList(),
              onChanged: (f) => setState(() => _combustible = f!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _anio,
              decoration: const InputDecoration(labelText: 'Año'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = int.tryParse(v.trim());
                if (n == null || n < 1950 || n > DateTime.now().year + 1) {
                  return 'Año no válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _matricula,
              decoration: const InputDecoration(labelText: 'Matrícula'),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _color,
              decoration: const InputDecoration(labelText: 'Color'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha de matriculación'),
              subtitle: Text(
                _fechaMatriculacion == null
                    ? 'Sin indicar — hace falta para calcular la ITV'
                    : _formatoFecha.format(_fechaMatriculacion!),
              ),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _elegirFechaMatriculacion,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(_esEdicion ? 'Guardar cambios' : 'Crear vehículo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectorFoto extends StatelessWidget {
  final String? ruta;
  final VoidCallback onPulsar;

  const _SelectorFoto({required this.ruta, required this.onPulsar});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return GestureDetector(
      onTap: onPulsar,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: tema.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          image: ruta == null
              ? null
              : DecorationImage(image: FileImage(File(ruta!)), fit: BoxFit.cover),
        ),
        child: ruta != null
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      size: 32, color: tema.colorScheme.outline),
                  const SizedBox(height: 8),
                  Text('Añadir foto', style: tema.textTheme.bodyMedium),
                ],
              ),
      ),
    );
  }
}
```

Si `DropdownButtonFormField` da error en `initialValue`, tu versión de Flutter usa el nombre antiguo: cámbialo por `value`.

- [ ] **Paso 3: Añadir el botón de nuevo vehículo en Inicio**

En `lib/ui/home/home_screen.dart`, añade los imports:

```dart
import '../vehicle/vehicle_form_screen.dart';
```

Y dentro del `Scaffold`, después de `body:`, añade:

```dart
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const VehicleFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Vehículo'),
      ),
```

- [ ] **Paso 4: Verificar**

```bash
flutter analyze 2>&1 | tail -2
```

Esperado: `No issues found!`

- [ ] **Paso 5: Probarlo en el móvil**

Conecta el móvil por USB con la depuración USB activada y ejecuta:

```bash
flutter run --release 2>&1 | tail -3
```

Crea el Mercedes-Benz Clase B 180 diésel de 2009 en rojo y comprueba que aparece en la lista al volver. Repite con el Seat León ST.

- [ ] **Paso 6: Commit**

```bash
git add -A && git commit -q -m "Añadir alta y edición de vehículos con foto"
```

---

## Tarea 8: Tarjeta de vehículo con kilometraje

**Ficheros:**
- Crear: `lib/ui/home/vehicle_card.dart`
- Modificar: `lib/ui/home/home_screen.dart` (usar la tarjeta)

**Interfaces:**
- Consume: `ultimaLecturaProvider`, `ritmoUsoProvider`, `VehicleFormScreen`.
- Produce: `formatearKm(int)` y `formatearFecha(DateTime)` en `lib/ui/common/formatters.dart`; `VehicleCard({required Vehicle vehiculo})`.

- [ ] **Paso 1: Escribir los formateadores**

`lib/ui/common/formatters.dart`:

```dart
import 'package:intl/intl.dart';

final _formatoKm = NumberFormat.decimalPattern('es_ES');
final _formatoFecha = DateFormat('dd/MM/yyyy', 'es_ES');

/// 142350 → "142.350 km"
String formatearKm(int km) => '${_formatoKm.format(km)} km';

/// 9 de agosto de 2026 → "09/08/2026"
String formatearFecha(DateTime fecha) => _formatoFecha.format(fecha);
```

- [ ] **Paso 2: Escribir la tarjeta**

`lib/ui/home/vehicle_card.dart`:

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers/providers.dart';
import '../common/formatters.dart';
import '../theme/app_theme.dart';
import '../vehicle/vehicle_form_screen.dart';

class VehicleCard extends ConsumerWidget {
  final Vehicle vehiculo;

  const VehicleCard({super.key, required this.vehiculo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final lectura = ref.watch(ultimaLecturaProvider(vehiculo.id));
    final ritmo = ref.watch(ritmoUsoProvider(vehiculo.id));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VehicleFormScreen(vehiculo: vehiculo),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vehiculo.fotoPath != null)
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Image.file(File(vehiculo.fotoPath!), fit: BoxFit.cover),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehiculo.marca} ${vehiculo.modelo}',
                    style: tema.textTheme.titleMedium,
                  ),
                  if (vehiculo.version != null)
                    Text(
                      vehiculo.version!,
                      style: tema.textTheme.bodySmall
                          ?.copyWith(color: tema.colorScheme.outline),
                    ),
                  const SizedBox(height: 16),
                  lectura.when(
                    loading: () => const SizedBox(height: 40),
                    error: (e, _) => Text('Error: $e'),
                    data: (l) => Text(
                      l == null ? 'Sin kilometraje' : formatearKm(l.km),
                      style: tema.textTheme.headlineMedium?.merge(
                        AppTheme.cifras.copyWith(
                          color: tema.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  ritmo.maybeWhen(
                    data: (r) => r.esPorDefecto
                        ? const SizedBox.shrink()
                        : Text(
                            r.cocheParado
                                ? 'Prácticamente parado'
                                : '≈ ${r.kmPorDia.round()} km al día',
                            style: tema.textTheme.bodySmall
                                ?.copyWith(color: tema.colorScheme.outline),
                          ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Paso 3: Usar la tarjeta en la pantalla de inicio**

En `lib/ui/home/home_screen.dart`, añade el import:

```dart
import 'vehicle_card.dart';
```

Y sustituye el `ListView.builder` completo por:

```dart
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: lista.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) => VehicleCard(vehiculo: lista[i]),
          );
```

- [ ] **Paso 4: Verificar**

```bash
flutter analyze 2>&1 | tail -2
```

Esperado: `No issues found!`

- [ ] **Paso 5: Commit**

```bash
git add -A && git commit -q -m "Mostrar los vehículos como tarjetas con kilometraje y ritmo de uso"
```

---

## Tarea 9: Actualizar el kilometraje

**Ficheros:**
- Crear: `lib/ui/mileage/update_mileage_sheet.dart`
- Modificar: `lib/ui/home/home_screen.dart` (segundo botón flotante)

**Interfaces:**
- Consume: `databaseProvider`, `MileageDao.registrar/ultimaLectura`, `vehiculosProvider`.
- Produce: `Future<void> mostrarHojaKilometraje(BuildContext, {Vehicle? vehiculo})`.

- [ ] **Paso 1: Escribir la hoja**

`lib/ui/mileage/update_mileage_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers/providers.dart';
import '../common/formatters.dart';
import '../theme/app_theme.dart';

Future<void> mostrarHojaKilometraje(
  BuildContext context, {
  required Vehicle vehiculo,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _HojaKilometraje(vehiculo: vehiculo),
    ),
  );
}

class _HojaKilometraje extends ConsumerStatefulWidget {
  final Vehicle vehiculo;

  const _HojaKilometraje({required this.vehiculo});

  @override
  ConsumerState<_HojaKilometraje> createState() => _HojaKilometrajeState();
}

class _HojaKilometrajeState extends ConsumerState<_HojaKilometraje> {
  final _controlador = TextEditingController();
  final _foco = FocusNode();
  String? _error;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _foco.requestFocus());
  }

  @override
  void dispose() {
    _controlador.dispose();
    _foco.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final km = int.tryParse(_controlador.text.trim().replaceAll('.', ''));
    if (km == null || km <= 0) {
      setState(() => _error = 'Introduce un número de kilómetros válido');
      return;
    }

    final dao = ref.read(databaseProvider).mileageDao;
    final anterior = await dao.ultimaLectura(widget.vehiculo.id);

    if (anterior != null && km < anterior.km && mounted) {
      final seguir = await _confirmarRetroceso(anterior.km, km);
      if (seguir != true) return;
    }

    setState(() => _guardando = true);
    await dao.registrar(
      vehicleId: widget.vehiculo.id,
      fecha: DateTime.now(),
      km: km,
    );

    ref.invalidate(ritmoUsoProvider(widget.vehiculo.id));
    if (mounted) Navigator.of(context).pop();
  }

  Future<bool?> _confirmarRetroceso(int anterior, int nuevo) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('El kilometraje ha bajado'),
        content: Text(
          'La última lectura era de ${formatearKm(anterior)} y estás '
          'introduciendo ${formatearKm(nuevo)}.\n\n'
          '¿Seguro que es correcto?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Corregir'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Es correcto'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final ultima = ref.watch(ultimaLecturaProvider(widget.vehiculo.id));

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.vehiculo.marca} ${widget.vehiculo.modelo}',
            style: tema.textTheme.titleMedium,
          ),
          ultima.maybeWhen(
            data: (l) => Text(
              l == null
                  ? 'Todavía sin kilometraje registrado'
                  : 'Última lectura: ${formatearKm(l.km)}',
              style: tema.textTheme.bodySmall
                  ?.copyWith(color: tema.colorScheme.outline),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controlador,
            focusNode: _foco,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: tema.textTheme.displaySmall?.merge(AppTheme.cifras),
            decoration: InputDecoration(
              hintText: '0',
              suffixText: 'km',
              errorText: _error,
            ),
            onSubmitted: (_) => _guardar(),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _guardando ? null : _guardar,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Paso 2: Añadir el acceso desde la pantalla de inicio**

En `lib/ui/home/home_screen.dart`, añade el import:

```dart
import '../mileage/update_mileage_sheet.dart';
```

Sustituye el `floatingActionButton` de la Tarea 7 por un par de botones, para que actualizar kilometraje sea la acción principal:

```dart
      floatingActionButton: vehiculos.maybeWhen(
        data: (lista) => lista.isEmpty
            ? FloatingActionButton.extended(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VehicleFormScreen()),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Vehículo'),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'nuevo-vehiculo',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const VehicleFormScreen(),
                      ),
                    ),
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton.extended(
                    heroTag: 'actualizar-km',
                    onPressed: () => _pedirKilometraje(context, lista),
                    icon: const Icon(Icons.speed),
                    label: const Text('Kilometraje'),
                  ),
                ],
              ),
        orElse: () => null,
      ),
```

Y añade este método a `HomeScreen`, fuera de `build`:

```dart
  Future<void> _pedirKilometraje(
    BuildContext context,
    List<Vehicle> vehiculos,
  ) async {
    if (vehiculos.length == 1) {
      return mostrarHojaKilometraje(context, vehiculo: vehiculos.single);
    }

    final elegido = await showModalBottomSheet<Vehicle>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: vehiculos
              .map((v) => ListTile(
                    leading: const Icon(Icons.directions_car_outlined),
                    title: Text('${v.marca} ${v.modelo}'),
                    onTap: () => Navigator.of(context).pop(v),
                  ))
              .toList(),
        ),
      ),
    );

    if (elegido != null && context.mounted) {
      await mostrarHojaKilometraje(context, vehiculo: elegido);
    }
  }
```

Necesitarás importar `../../data/database.dart` en `home_screen.dart` para el tipo `Vehicle`.

- [ ] **Paso 3: Verificar**

```bash
flutter analyze 2>&1 | tail -2 && flutter test --reporter=failures-only 2>&1 | tail -2
```

Esperado: `No issues found!` y `All tests passed!`

- [ ] **Paso 4: Probarlo en el móvil**

```bash
flutter run --release 2>&1 | tail -3
```

Comprueba: que el teclado numérico aparece solo, que la cifra se guarda, que la tarjeta se actualiza al cerrar la hoja, y que introducir un kilometraje menor que el anterior pide confirmación.

- [ ] **Paso 5: Commit**

```bash
git add -A && git commit -q -m "Añadir actualización rápida de kilometraje con validación de retroceso"
```

---

## Tarea 10: Generar e instalar el APK

**Ficheros:** ninguno nuevo.

- [ ] **Paso 1: Comprobación completa antes de compilar**

```bash
flutter analyze 2>&1 | tail -2 && flutter test --reporter=failures-only 2>&1 | tail -2
```

Esperado: `No issues found!` y `All tests passed!`

- [ ] **Paso 2: Compilar el APK de release**

```bash
flutter build apk --release 2>&1 | tail -2
```

Esperado: `√ Built build\app\outputs\flutter-apk\app-release.apk`

El APK va firmado con la clave de depuración. Sirve para instalarlo a mano; solo haría falta una clave propia para publicar en Play Store, que no está en los planes.

- [ ] **Paso 3: Instalar en el móvil**

Con el móvil conectado y la depuración USB activa:

```bash
flutter install --release 2>&1 | tail -2
```

Alternativa sin cable: copia `build\app\outputs\flutter-apk\app-release.apk` al teléfono y ábrelo desde el explorador de archivos, permitiendo la instalación de orígenes desconocidos.

- [ ] **Paso 4: Comprobación funcional en el móvil**

Sin el cable conectado, abre la aplicación y verifica:

1. Los dos vehículos aparecen con su foto y su kilometraje.
2. Al pulsar Kilometraje puedes elegir coche, escribir la cifra y guardarla en dos toques.
3. La cifra nueva se refleja en la tarjeta inmediatamente.
4. Cerrando y reabriendo la app los datos siguen ahí.
5. Con el móvil en tema oscuro, la aplicación también lo está y se lee bien.

- [ ] **Paso 5: Commit final de la fase**

```bash
git add -A && git commit -q -m "Cerrar fase 1: aplicación instalable con vehículos y kilometraje" --allow-empty && git tag fase-1
```

---

## Qué queda para las siguientes fases

**Fase 2** — tablas `MaintenanceSchedule` y `MaintenanceRecord`, motor de vencimientos con la regla del que llegue antes, los cuatro estados y sus colores, ficha del vehículo, alta y registro de mantenimientos, plantillas al crear vehículo, cálculo de la ITV e historial.

**Fase 3** — notificaciones locales, permiso `POST_NOTIFICATIONS`, recordatorio de lectura, pantalla de ajustes real y copia de seguridad en `.zip`.
