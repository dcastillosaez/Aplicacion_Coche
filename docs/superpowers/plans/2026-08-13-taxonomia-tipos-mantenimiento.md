# Taxonomía de tipos, posición y kind de mantenimiento — Plan de implementación

> **Para agentes ejecutores:** SUB-SKILL OBLIGATORIA: usa `superpowers:subagent-driven-development` (recomendada) o `superpowers:executing-plans` para implementar este plan tarea a tarea. Los pasos usan casillas (`- [ ]`) para el seguimiento.

**Objetivo:** que cada mantenimiento pueda decir qué es exactamente (tipo, de un catálogo de ~175 valores en 14 categorías), dónde está (posición, cuando aplica) y qué se hizo realmente cada vez que se registra (kind: reparación, sustitución, inspección...), sin perder ni un dato de lo ya configurado.

**Arquitectura:** dos enums de dominio nuevos (`MaintenanceOperationKind`, `Posicion`), un tercero grande (`MaintenanceType`, *enhanced enum* con metadatos propios: categoría, kind por defecto, si admite posición) y la ampliación de `MaintenanceCategory` — todo en `lib/domain/`, sin dependencias de Drift ni Flutter. Tres columnas nuevas en `MaintenanceSchedules` (tipo, posición, si el nombre es autogenerado) y una en `MaintenanceRecords` (kind), todas opcionales salvo la última.

**Tech Stack:** Flutter, Drift (SQLite), Riverpod. Sin dependencias nuevas.

**Spec de referencia:** `docs/superpowers/specs/2026-08-13-taxonomia-tipos-mantenimiento-design.md` — este plan implementa ese documento sección por sección; ante cualquier duda de diseño no cubierta aquí, es la fuente de verdad.

## Global Constraints

- Plataforma única: Android. `minSdkVersion` 24.
- Toda la interfaz en español. Fechas `dd/MM/yyyy`, separador de miles con punto.
- `lib/domain/` no puede importar `package:drift/...` ni `package:flutter/...`.
- Sin dependencias nuevas.
- Mensajes de commit en español, sin coautoría ni menciones a herramientas.
- El proyecto usa el formateador estándar de Dart (`dart format`, "tall style", 80 columnas) desde el commit `a8e4470`. El código nuevo debe salir ya en ese estilo; nunca ejecutar `dart format` sobre un fichero existente completo (reformatea zonas ajenas) — solo sobre el fichero recién creado, o a mano en los bloques añadidos a un fichero existente.
- **Entorno**: el toolchain no está en el PATH y la carpeta temporal debe redirigirse o Gradle no arranca. Antepón a cada comando de PowerShell:
  `$env:Path = "F:\dev\flutter\bin;F:\dev\android-sdk\platform-tools;$env:Path"; $env:JAVA_HOME = 'C:\Program Files\Eclipse Adoptium\jdk-17.0.20.8-hotspot'; $env:ANDROID_HOME = 'F:\dev\android-sdk'; $env:TMP = 'F:\dev\tmp'; $env:TEMP = 'F:\dev\tmp'`
- Punto de partida: `flutter analyze` limpio, 124 tests pasando, `schemaVersion` en 5.

## Decisiones de diseño ya cerradas (no reabrir sin motivo)

Vienen de la spec (§7, las cuatro condiciones no negociables):

1. **`MaintenanceType.categoria` es la única fuente de verdad.** En el formulario, si hay un tipo elegido, la categoría se deriva de él y deja de ser editable por separado.
2. **Nunca se sobrescribe un nombre editado a mano.** El nombre se autogenera solo mientras `nombreAutogenerado` sea `true`; en cuanto el usuario edita el campo Nombre directamente, pasa a `false` para siempre (hasta que se borre el mantenimiento).
3. **`defaultKind` nunca contamina el historial.** Es una sugerencia que rellena el campo `kind` al abrir "Registrar realizado"; en cuanto el registro se guarda, `kind` queda fijo en ese valor para siempre, sin recalcularse si el catálogo cambia más adelante.
4. **`Posicion` no sustituye información técnica más específica.** Los diez valores ya fijados bastan para esta fase; nunca se crean tipos por combinación de tipo+posición (`pastillasFrenoDelantera` no existe).

Y de la propia mecánica de este proyecto:

- **La migración toca la misma trampa de `m.createTable()` ya documentada en `CLAUDE.md`.** `MaintenanceSchedules` y `MaintenanceRecords` se crearon las dos en el paso `if (from < 3)` de una migración anterior, así que cualquier columna nueva en cualquiera de las dos exige la guarda `from >= 3 && from < 6`, igual que `fuenteIntervalo` en la fase 4 usó `from >= 3 && from < 5`.
- **`tipo`, `posicion` y `kind` nacen opcionales, sin backfill.** Los mantenimientos y registros ya guardados en el dispositivo del usuario siguen funcionando exactamente igual, sin ningún intento de adivinar su tipo a partir del nombre existente.
- **Las etiquetas visibles (español) de `MaintenanceType`, `Posicion` y `MaintenanceOperationKind` viven en la capa de UI**, no en el dominio — mismo patrón que `etiquetasCategoria`, que ya vive en `lib/ui/maintenance/maintenance_form_screen.dart` en vez de en `lib/domain/maintenance_category.dart`.

## Estructura de ficheros

| Fichero | Responsabilidad |
|---|---|
| `lib/domain/maintenance_category.dart` | Se amplía con 5 categorías nuevas |
| `lib/domain/maintenance_operation_kind.dart` | `MaintenanceOperationKind` (nuevo) |
| `lib/domain/posicion.dart` | `Posicion` (nuevo) |
| `lib/domain/maintenance_type.dart` | `MaintenanceType`, el catálogo completo (nuevo) |
| `lib/data/tables/maintenance_schedules.dart` | Se amplía con `tipo`, `posicion`, `nombreAutogenerado` |
| `lib/data/tables/maintenance_records.dart` | Se amplía con `kind` |
| `lib/data/database.dart` | Se amplía con la migración v5→v6 |
| `lib/domain/plantillas_mantenimiento.dart` | Se amplía con `tipo`/`posicion` en `PlantillaMantenimiento` |
| `lib/ui/maintenance/maintenance_form_screen.dart` | Cascada Categoría→Tipo→Posición, nombre autogenerado, mapas de etiquetas |
| `lib/ui/maintenance/register_maintenance_sheet.dart` | Selector de `kind` con sugerencia |
| `lib/ui/vehicle/vehicle_detail_screen.dart` | Distintivo de tipo/posición en `_FilaMantenimiento` y `_TarjetaDestacada` |
| `lib/ui/history/history_screen.dart` | Distintivo de tipo/posición/kind en `_FilaHistorial` |
| `test/domain/maintenance_type_test.dart` | Tests del catálogo (nuevo) |
| `test/data/database_migration_test.dart` | Se amplía con los tests de la migración v5→v6 |
| `test/data/maintenance_dao_test.dart` | Se amplía si hace falta un helper nuevo |

---

## Tarea 1: `MaintenanceOperationKind`, `Posicion` y ampliación de `MaintenanceCategory`

Lógica de dominio pura, sin dependencias.

**Ficheros:**
- Crear: `lib/domain/maintenance_operation_kind.dart`
- Crear: `lib/domain/posicion.dart`
- Modificar: `lib/domain/maintenance_category.dart`
- Modificar: `lib/ui/maintenance/maintenance_form_screen.dart` (solo el mapa `etiquetasCategoria`)
- Test: `test/domain/maintenance_operation_kind_test.dart`, `test/domain/posicion_test.dart`

**Interfaces:**
- Produce: `enum MaintenanceOperationKind`, `enum Posicion`, y los 5 valores nuevos de `MaintenanceCategory`.

- [ ] **Paso 1: Escribir `lib/domain/maintenance_operation_kind.dart`**

```dart
/// Qué se hizo realmente en un mantenimiento registrado: no es una
/// propiedad fija del tipo de mantenimiento (un turbo puede repararse una
/// vez y sustituirse la siguiente), sino un dato de cada
/// `MaintenanceRecord`. `MaintenanceType.defaultKind` solo aporta una
/// sugerencia inicial al registrar, nunca un valor fijo.
///
/// El nombre del enum y el de sus valores forman parte del formato en el
/// que Drift guarda el dato (columna `kind`, vía `textEnum`): no se pueden
/// renombrar sin romper los datos ya guardados en el dispositivo.
enum MaintenanceOperationKind { preventivo, inspeccion, reparacion, sustitucion, otro }
```

- [ ] **Paso 2: Escribir `lib/domain/posicion.dart`**

```dart
/// Dónde está una pieza, cuando el tipo de mantenimiento lo necesita
/// (`MaintenanceType.admitePosicion`). Es metadato de localización,
/// independiente del tipo: `tipo = pastillasFreno, posicion = delantera`,
/// nunca un tipo por cada combinación.
///
/// El nombre del enum y el de sus valores forman parte del formato en el
/// que Drift guarda el dato (columna `posicion`, vía `textEnum`): no se
/// pueden renombrar sin romper los datos ya guardados en el dispositivo.
enum Posicion {
  delantera,
  trasera,
  izquierda,
  derecha,
  delanteraIzquierda,
  delanteraDerecha,
  traseraIzquierda,
  traseraDerecha,
  ejeDelantero,
  ejeTrasero,
}
```

- [ ] **Paso 3: Ampliar `lib/domain/maintenance_category.dart`**

Añade los 5 valores nuevos al final del enum existente, sin tocar los 9 ya presentes:

```dart
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
  direccion,
  climatizacion,
  escapeEmisiones,
  habitaculo,
  seguridad,
}
```

- [ ] **Paso 4: Ampliar `etiquetasCategoria` en `lib/ui/maintenance/maintenance_form_screen.dart`**

El mapa ya existente queda así (añade las 5 últimas entradas, no toques las 9 primeras):

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
  MaintenanceCategory.direccion: 'Dirección',
  MaintenanceCategory.climatizacion: 'Climatización',
  MaintenanceCategory.escapeEmisiones: 'Escape y emisiones',
  MaintenanceCategory.habitaculo: 'Habitáculo',
  MaintenanceCategory.seguridad: 'Seguridad',
};
```

- [ ] **Paso 5: Escribir `test/domain/maintenance_operation_kind_test.dart`**

```dart
import 'package:car_care/domain/maintenance_operation_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tiene los cinco valores esperados', () {
    expect(MaintenanceOperationKind.values, hasLength(5));
    expect(
      MaintenanceOperationKind.values.map((k) => k.name),
      containsAll(['preventivo', 'inspeccion', 'reparacion', 'sustitucion', 'otro']),
    );
  });
}
```

- [ ] **Paso 6: Escribir `test/domain/posicion_test.dart`**

```dart
import 'package:car_care/domain/posicion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tiene los diez valores esperados', () {
    expect(Posicion.values, hasLength(10));
    expect(
      Posicion.values.map((p) => p.name),
      containsAll([
        'delantera', 'trasera', 'izquierda', 'derecha',
        'delanteraIzquierda', 'delanteraDerecha',
        'traseraIzquierda', 'traseraDerecha',
        'ejeDelantero', 'ejeTrasero',
      ]),
    );
  });
}
```

- [ ] **Paso 7: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando (124 + 2 nuevos = 126).

- [ ] **Paso 8: Commit**

```bash
git add -A && git commit -q -m "Añadir los enums de kind, posición y ampliar las categorías de mantenimiento"
```

---

## Tarea 2: Catálogo completo de `MaintenanceType`

Lógica de dominio pura. Es la tarea más grande en volumen de código, pero mecánica: transcribe literalmente la tabla de la spec (§4).

**Ficheros:**
- Crear: `lib/domain/maintenance_type.dart`
- Test: `test/domain/maintenance_type_test.dart`

**Interfaces:**
- Consume: `MaintenanceCategory` (Tarea 1, ya ampliado), `MaintenanceOperationKind` (Tarea 1).
- Produce: `enum MaintenanceType` con getters `categoria` (`MaintenanceCategory`), `defaultKind` (`MaintenanceOperationKind`), `admitePosicion` (`bool`).

- [ ] **Paso 1: Escribir `lib/domain/maintenance_type.dart`**

```dart
import 'maintenance_category.dart';
import 'maintenance_operation_kind.dart';

/// Qué es exactamente un mantenimiento, dentro de su categoría: pastillas
/// de freno, correa de distribución, turbo... Cada tipo pertenece a una
/// única categoría (nunca aparece duplicado en dos), lleva una sugerencia
/// de [MaintenanceOperationKind] para cuando se registre por primera vez
/// (nunca un valor fijo — ver `MaintenanceRecord.kind`), y declara si
/// admite [Posicion] (delantera/trasera/...).
///
/// El nombre del enum y el de sus valores forman parte del formato en el
/// que Drift guarda el dato (columna `tipo` de `MaintenanceSchedules`, vía
/// `textEnum`): no se pueden renombrar sin romper los datos ya guardados
/// en el dispositivo.
///
/// Catálogo documentado en
/// `docs/superpowers/specs/2026-08-13-taxonomia-tipos-mantenimiento-design.md`,
/// sección 4: mismo orden, mismos valores.
enum MaintenanceType {
  // Motor
  aceiteMotor(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  filtroAceite(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  filtroAire(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  filtroCombustible(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  bujias(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  calentadores(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  bobinasEncendido(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  correaDistribucion(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  kitDistribucion(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  cadenaDistribucion(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  tensorDistribucion(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  correaAuxiliar(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  tensorCorreaAuxiliar(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  bombaAgua(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  refrigerante(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  bombaAceite(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  termostato(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  radiador(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  manguitosRefrigeracion(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  soportesMotor(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  admision(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  inyectores(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  sistemaCombustible(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  limpiezaDescarbonizacion(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.preventivo,
    admitePosicion: false,
  ),
  turbo(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  otroMotor(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Frenos
  pastillasFreno(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  discosFreno(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  zapatasFreno(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  tamboresFreno(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  liquidoFrenos(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  pinzasFreno(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  latiguillosFreno(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  sensorDesgasteFreno(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  cilindroMaestro(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  servofreno(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  abs(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  sensoresAbs(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  frenoEstacionamiento(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  frenoEstacionamientoElectrico(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  otroFrenos(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Neumáticos
  neumatico(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  rotacionNeumaticos(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.preventivo,
    admitePosicion: false,
  ),
  equilibrado(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  alineacion(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  reparacionPinchazo(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  valvulas(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  tpms(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  kitAntipinchazos(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  ruedaRepuesto(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  otroNeumaticos(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Electricidad
  bateria(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  alternador(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  motorArranque(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  fusibles(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  reles(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  bombillas(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  iluminacionExterior(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  iluminacionInterior(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  sensorElectrico(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  cableado(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  sistemaCarga(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  otroElectricidad(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Suspensión
  amortiguadores(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  muelles(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  copelas(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  rodamientosCopela(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  brazosSuspension(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  silentblocks(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  rotulasSuspension(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  bieletasEstabilizadoras(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  barraEstabilizadora(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  rodamientosRueda(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  mangueta(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  suspensionNeumatica(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  compresorSuspension(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  otroSuspension(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Dirección
  direccionAsistida(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  bombaDireccion(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  cremallera(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  terminalDireccion(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  rotulaDireccion(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  columnaDireccion(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  volante(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  direccionElectrica(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  liquidoDireccion(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  otroDireccion(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Transmisión
  embrague(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  kitEmbrague(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  volanteBimasa(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  cajaCambiosManual(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  cajaCambiosAutomatica(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  aceiteCajaCambios(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  filtroCajaCambios(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  convertidorPar(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  mecatronica(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  palieres(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  juntasHomocineticas(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  arbolTransmision(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  diferencial(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  aceiteDiferencial(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  transfer(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  aceiteTransfer(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  retenesTransmision(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  otroTransmision(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Climatización
  aireAcondicionado(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  gasRefrigeranteAc(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  compresorAc(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  condensadorAc(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  evaporadorAc(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  filtroDeshidratador(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  ventiladorClimatizacion(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  motorVentilador(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  calefaccion(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  radiadorCalefaccion(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  termostatoClimatizacion(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  otroClimatizacion(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Escape y emisiones
  escape(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  silencioso(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  catalizador(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  dpfFap(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  egr(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  sondaLambda(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  sensorNox(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  sensorTemperaturaEscape(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  adblueScr(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  inyectorAdblue(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  depositoAdblue(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  otroEscapeEmisiones(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Carrocería
  paragolpes(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  capo(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  puertas(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  porton(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  aletas(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  espejos(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  elevalunas(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  cerraduras(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  bisagras(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  escobillasLimpiaparabrisas(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  brazosLimpiaparabrisas(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  motorLimpiaparabrisas(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  lunaParabrisas(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  molduras(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  juntasCarroceria(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  techoSolar(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  otroCarroceria(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Habitáculo
  filtroHabitaculo(
    categoria: MaintenanceCategory.habitaculo,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  alfombrillas(
    categoria: MaintenanceCategory.habitaculo,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  asientos(
    categoria: MaintenanceCategory.habitaculo,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  salpicadero(
    categoria: MaintenanceCategory.habitaculo,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  instrumentacion(
    categoria: MaintenanceCategory.habitaculo,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  pantallaInfotainment(
    categoria: MaintenanceCategory.habitaculo,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  altavoces(
    categoria: MaintenanceCategory.habitaculo,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  otroHabitaculo(
    categoria: MaintenanceCategory.habitaculo,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Seguridad
  airbag(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  pretensorCinturon(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  cinturonSeguridad(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  esp(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  sensorImpacto(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  camaraSeguridad(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  radarSeguridad(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  adas(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  sensorAparcamiento(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  otroSeguridad(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // ITV / Inspección
  inspeccionItv(
    categoria: MaintenanceCategory.itv,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  preItv(
    categoria: MaintenanceCategory.itv,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  inspeccionGeneral(
    categoria: MaintenanceCategory.itv,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  inspeccionEmisiones(
    categoria: MaintenanceCategory.itv,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  inspeccionFrenos(
    categoria: MaintenanceCategory.itv,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  inspeccionNeumaticos(
    categoria: MaintenanceCategory.itv,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  inspeccionLuces(
    categoria: MaintenanceCategory.itv,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  otroItv(
    categoria: MaintenanceCategory.itv,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Otro
  mantenimientoGeneral(
    categoria: MaintenanceCategory.otro,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),
  reparacionGeneral(
    categoria: MaintenanceCategory.otro,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  otro(
    categoria: MaintenanceCategory.otro,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),
  ;

  final MaintenanceCategory categoria;
  final MaintenanceOperationKind defaultKind;
  final bool admitePosicion;

  const MaintenanceType({
    required this.categoria,
    required this.defaultKind,
    required this.admitePosicion,
  });
}
```

- [ ] **Paso 2: Escribir `test/domain/maintenance_type_test.dart`**

```dart
import 'package:car_care/domain/maintenance_category.dart';
import 'package:car_care/domain/maintenance_operation_kind.dart';
import 'package:car_care/domain/maintenance_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tiene 175 tipos', () {
    expect(MaintenanceType.values, hasLength(175));
  });

  test('cada categoría tiene al menos un tipo', () {
    for (final categoria in MaintenanceCategory.values) {
      expect(
        MaintenanceType.values.where((t) => t.categoria == categoria),
        isNotEmpty,
        reason: 'La categoría $categoria no tiene ningún tipo asociado',
      );
    }
  });

  test('los tipos resueltos por solapamiento quedan en la categoría '
      'correcta (spec §4)', () {
    expect(MaintenanceType.turbo.categoria, MaintenanceCategory.motor);
    expect(MaintenanceType.egr.categoria, MaintenanceCategory.escapeEmisiones);
    expect(
      MaintenanceType.dpfFap.categoria,
      MaintenanceCategory.escapeEmisiones,
    );
    expect(
      MaintenanceType.catalizador.categoria,
      MaintenanceCategory.escapeEmisiones,
    );
    expect(
      MaintenanceType.sondaLambda.categoria,
      MaintenanceCategory.escapeEmisiones,
    );
    expect(
      MaintenanceType.filtroHabitaculo.categoria,
      MaintenanceCategory.habitaculo,
    );
    expect(MaintenanceType.calentadores.categoria, MaintenanceCategory.motor);
    expect(MaintenanceType.abs.categoria, MaintenanceCategory.frenos);
    expect(MaintenanceType.sensoresAbs.categoria, MaintenanceCategory.frenos);
    expect(MaintenanceType.airbag.categoria, MaintenanceCategory.seguridad);
    expect(MaintenanceType.termostato.categoria, MaintenanceCategory.motor);
    expect(
      MaintenanceType.termostatoClimatizacion.categoria,
      MaintenanceCategory.climatizacion,
    );
  });

  test('turbo sugiere reparación por defecto, pero no es un valor fijo', () {
    expect(MaintenanceType.turbo.defaultKind, MaintenanceOperationKind.reparacion);
  });

  test('las piezas por eje o lado admiten posición', () {
    expect(MaintenanceType.pastillasFreno.admitePosicion, isTrue);
    expect(MaintenanceType.amortiguadores.admitePosicion, isTrue);
    expect(MaintenanceType.neumatico.admitePosicion, isTrue);
  });

  test('el líquido de frenos no admite posición', () {
    expect(MaintenanceType.liquidoFrenos.admitePosicion, isFalse);
  });

  test('cada categoría tiene un tipo "otro" como válvula de escape', () {
    final categoriasConOtro = MaintenanceType.values
        .where((t) => t.defaultKind == MaintenanceOperationKind.otro)
        .map((t) => t.categoria)
        .toSet();
    expect(categoriasConOtro, containsAll(MaintenanceCategory.values));
  });
}
```

- [ ] **Paso 3: Ejecutar y verificar antes de seguir**

```powershell
flutter test test/domain/maintenance_type_test.dart --reporter=failures-only
```

Esperado: `All tests passed!`. Si el test de longitud (175) falla, cuenta los valores del enum escrito en el Paso 1 contra la tabla completa de la spec (§4) — es la fuente de verdad, categoría por categoría.

- [ ] **Paso 4: Verificar el proyecto completo**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando (126 + 8 nuevos = 134).

- [ ] **Paso 5: Commit**

```bash
git add -A && git commit -q -m "Añadir el catálogo completo de tipos de mantenimiento"
```

---

## Tarea 3: Columnas nuevas y migración v5→v6

La tarea más delicada de la fase: toca la misma trampa de `m.createTable()` que la Tarea 4 de la fase 4 ya resolvió con `fuenteIntervalo`.

**Ficheros:**
- Modificar: `lib/data/tables/maintenance_schedules.dart`
- Modificar: `lib/data/tables/maintenance_records.dart`
- Modificar: `lib/data/database.dart`
- Test: `test/data/database_migration_test.dart` (ampliar)

**Interfaces:**
- Consume: `MaintenanceType`, `Posicion` (Tareas 1 y 2), `MaintenanceOperationKind` (Tarea 1).
- Produce: `MaintenanceSchedule.tipo` (`MaintenanceType?`), `MaintenanceSchedule.posicion` (`Posicion?`), `MaintenanceSchedule.nombreAutogenerado` (`bool`), `MaintenanceRecord.kind` (`MaintenanceOperationKind?`).

- [ ] **Paso 1: Ampliar `lib/data/tables/maintenance_schedules.dart`**

Añade tres columnas al final de la clase, sin tocar nada de lo existente:

```dart
import 'package:drift/drift.dart';

import '../../domain/fuente_intervalo.dart';
import '../../domain/maintenance_category.dart';
import '../../domain/maintenance_type.dart';
import '../../domain/posicion.dart';
import 'vehicles.dart';

export '../../domain/fuente_intervalo.dart';
export '../../domain/maintenance_category.dart';
export '../../domain/maintenance_type.dart';
export '../../domain/posicion.dart';

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

  /// Ver `FuenteIntervalo`. Todo mantenimiento tiene una fuente, incluso
  /// los que no la eligieron explícitamente: por defecto es orientativo.
  TextColumn get fuenteIntervalo =>
      textEnum<FuenteIntervalo>().withDefault(const Constant('orientativo'))();

  /// Qué es, del catálogo. Nulo en los mantenimientos ya configurados
  /// antes de que existiera este campo, y en cualquiera nuevo que no use
  /// el catálogo: siguen funcionando igual, solo con nombre libre.
  TextColumn get tipo => textEnum<MaintenanceType>().nullable()();

  /// Dónde, cuando el tipo lo admite (`MaintenanceType.admitePosicion`).
  TextColumn get posicion => textEnum<Posicion>().nullable()();

  /// Si `nombre` se generó solo a partir de tipo+posición (y por tanto se
  /// regenera si cambian) o si el usuario lo editó a mano (y por tanto se
  /// queda quieto para siempre, aunque cambie el tipo o la posición).
  BoolColumn get nombreAutogenerado =>
      boolean().withDefault(const Constant(false))();
}
```

- [ ] **Paso 2: Ampliar `lib/data/tables/maintenance_records.dart`**

```dart
import 'package:drift/drift.dart';

import '../../domain/maintenance_operation_kind.dart';
import 'maintenance_schedules.dart';
import 'vehicles.dart';

export '../../domain/maintenance_operation_kind.dart';

class MaintenanceRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();

  /// Nulo en reparaciones puntuales que no responden a ningún mantenimiento
  /// configurado. Si se borra el mantenimiento, el registro sobrevive.
  IntColumn get scheduleId => integer().nullable().references(
    MaintenanceSchedules,
    #id,
    onDelete: KeyAction.setNull,
  )();

  DateTimeColumn get fecha => dateTime()();
  IntColumn get km => integer()();
  RealColumn get coste => real().nullable()();
  TextColumn get taller => text().nullable()();
  TextColumn get notas => text().nullable()();

  /// Dato anterior a la instalación de la app, introducido a mano para
  /// poder calcular el primer vencimiento. Cuenta para los cálculos y se
  /// distingue en el historial.
  BoolColumn get esSembrado => boolean().withDefault(const Constant(false))();

  /// Qué se hizo realmente esta vez: reparación, sustitución, inspección...
  /// Nulo en los registros ya guardados antes de que existiera este campo,
  /// y en cualquiera nuevo que no lo rellene. No se recalcula nunca a
  /// partir de `MaintenanceType.defaultKind`: es un valor fijado al
  /// guardar, no una vista sobre el catálogo.
  TextColumn get kind => textEnum<MaintenanceOperationKind>().nullable()();
}
```

- [ ] **Paso 3: Migración en `lib/data/database.dart`**

Añade el import y sube `schemaVersion` a 6, con el paso nuevo después del existente (no toques el paso `if (from >= 3 && from < 5)`):

```dart
  @override
  int get schemaVersion => 6;

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
      // v5 -> v6: se añade la taxonomía de tipos de mantenimiento (tipo,
      // posición y si el nombre es autogenerado en maintenance_schedules;
      // kind en maintenance_records).
      //
      // Misma trampa que el paso anterior: maintenance_schedules y
      // maintenance_records se crean las dos en el paso "from < 3" de
      // arriba, con la definición ACTUAL de sus clases Dart, que ya
      // incluye estas columnas. La guarda "from >= 3" evita duplicarlas
      // en quien salte desde v1 o v2 directo a v6.
      if (from >= 3 && from < 6) {
        await m.addColumn(maintenanceSchedules, maintenanceSchedules.tipo);
        await m.addColumn(
          maintenanceSchedules,
          maintenanceSchedules.posicion,
        );
        await m.addColumn(
          maintenanceSchedules,
          maintenanceSchedules.nombreAutogenerado,
        );
        await m.addColumn(maintenanceRecords, maintenanceRecords.kind);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) {
        await into(settings).insert(const SettingsCompanion());
      }
    },
  );
```

- [ ] **Paso 4: Test del caso realista (v5→v6) en `test/data/database_migration_test.dart`**

Añade este test al final del fichero, antes del cierre de `main()`, con el mismo estilo que el test "migrar de v4 a v5" ya existente (esquema crudo con SQL, sin abrir Drift hasta el final):

```dart
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
```

- [ ] **Paso 5: Test del caso trampa (saltar directo a v6) en `test/data/database_migration_test.dart`**

```dart
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
```

- [ ] **Paso 6: Añadir los imports que hagan falta al principio de `test/data/database_migration_test.dart`**

Si no están ya (revisa antes de duplicar):

```dart
import 'package:car_care/domain/maintenance_type.dart';
import 'package:car_care/domain/posicion.dart';
```

- [ ] **Paso 7: Ejecutar los dos tests nuevos por separado antes de seguir**

```powershell
flutter test test/data/database_migration_test.dart --reporter=failures-only
```

Esperado: `All tests passed!` — todos los de migración, los ya existentes más los dos nuevos.

- [ ] **Paso 8: Verificar el proyecto completo**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando (134 + 2 nuevos = 136).

- [ ] **Paso 9: Commit**

```bash
git add -A && git commit -q -m "Añadir tipo, posición y kind al esquema, migración v5 a v6"
```

---

## Tarea 4: Cascada Categoría → Tipo → Posición en el formulario de mantenimiento

Describe comportamiento, no dicta código — mismo criterio que las tareas de interfaz de las fases 2, 3 y 4.

**Ficheros:**
- Modificar: `lib/ui/maintenance/maintenance_form_screen.dart`

**Interfaces:**
- Consume: `MaintenanceType` (Tarea 2, con `categoria`/`admitePosicion`), `Posicion` (Tarea 1), `MaintenanceSchedule.tipo`/`posicion`/`nombreAutogenerado` (Tarea 3).
- Produce: `etiquetasMaintenanceType` (`Map<MaintenanceType, String>`), `etiquetasPosicion` (`Map<Posicion, String>`) — los usarán las Tareas 5 y 7.

**Los mapas de etiquetas, código completo** (van junto a `etiquetasCategoria`, al principio del fichero):

```dart
const Map<MaintenanceType, String> etiquetasMaintenanceType = {
  // Motor
  MaintenanceType.aceiteMotor: 'Aceite motor',
  MaintenanceType.filtroAceite: 'Filtro de aceite',
  MaintenanceType.filtroAire: 'Filtro de aire',
  MaintenanceType.filtroCombustible: 'Filtro de combustible',
  MaintenanceType.bujias: 'Bujías',
  MaintenanceType.calentadores: 'Calentadores',
  MaintenanceType.bobinasEncendido: 'Bobinas de encendido',
  MaintenanceType.correaDistribucion: 'Correa de distribución',
  MaintenanceType.kitDistribucion: 'Kit de distribución',
  MaintenanceType.cadenaDistribucion: 'Cadena de distribución',
  MaintenanceType.tensorDistribucion: 'Tensor de distribución',
  MaintenanceType.correaAuxiliar: 'Correa auxiliar',
  MaintenanceType.tensorCorreaAuxiliar: 'Tensor de correa auxiliar',
  MaintenanceType.bombaAgua: 'Bomba de agua',
  MaintenanceType.refrigerante: 'Refrigerante',
  MaintenanceType.bombaAceite: 'Bomba de aceite',
  MaintenanceType.termostato: 'Termostato',
  MaintenanceType.radiador: 'Radiador',
  MaintenanceType.manguitosRefrigeracion: 'Manguitos de refrigeración',
  MaintenanceType.soportesMotor: 'Soportes de motor',
  MaintenanceType.admision: 'Admisión',
  MaintenanceType.inyectores: 'Inyectores',
  MaintenanceType.sistemaCombustible: 'Sistema de combustible',
  MaintenanceType.limpiezaDescarbonizacion: 'Limpieza / descarbonización',
  MaintenanceType.turbo: 'Turbo',
  MaintenanceType.otroMotor: 'Otro (motor)',
  // Frenos
  MaintenanceType.pastillasFreno: 'Pastillas de freno',
  MaintenanceType.discosFreno: 'Discos de freno',
  MaintenanceType.zapatasFreno: 'Zapatas de freno',
  MaintenanceType.tamboresFreno: 'Tambores de freno',
  MaintenanceType.liquidoFrenos: 'Líquido de frenos',
  MaintenanceType.pinzasFreno: 'Pinzas de freno',
  MaintenanceType.latiguillosFreno: 'Latiguillos de freno',
  MaintenanceType.sensorDesgasteFreno: 'Sensor de desgaste',
  MaintenanceType.cilindroMaestro: 'Cilindro maestro',
  MaintenanceType.servofreno: 'Servofreno',
  MaintenanceType.abs: 'ABS',
  MaintenanceType.sensoresAbs: 'Sensores ABS',
  MaintenanceType.frenoEstacionamiento: 'Freno de estacionamiento',
  MaintenanceType.frenoEstacionamientoElectrico:
      'Freno de estacionamiento eléctrico',
  MaintenanceType.otroFrenos: 'Otro (frenos)',
  // Neumáticos
  MaintenanceType.neumatico: 'Neumático',
  MaintenanceType.rotacionNeumaticos: 'Rotación de neumáticos',
  MaintenanceType.equilibrado: 'Equilibrado',
  MaintenanceType.alineacion: 'Alineación',
  MaintenanceType.reparacionPinchazo: 'Reparación de pinchazo',
  MaintenanceType.valvulas: 'Válvulas',
  MaintenanceType.tpms: 'TPMS / sensores de presión',
  MaintenanceType.kitAntipinchazos: 'Kit antipinchazos',
  MaintenanceType.ruedaRepuesto: 'Rueda de repuesto',
  MaintenanceType.otroNeumaticos: 'Otro (neumáticos)',
  // Electricidad
  MaintenanceType.bateria: 'Batería',
  MaintenanceType.alternador: 'Alternador',
  MaintenanceType.motorArranque: 'Motor de arranque',
  MaintenanceType.fusibles: 'Fusibles',
  MaintenanceType.reles: 'Relés',
  MaintenanceType.bombillas: 'Bombillas',
  MaintenanceType.iluminacionExterior: 'Iluminación exterior',
  MaintenanceType.iluminacionInterior: 'Iluminación interior',
  MaintenanceType.sensorElectrico: 'Sensor',
  MaintenanceType.cableado: 'Cableado',
  MaintenanceType.sistemaCarga: 'Sistema de carga',
  MaintenanceType.otroElectricidad: 'Otro (electricidad)',
  // Suspensión
  MaintenanceType.amortiguadores: 'Amortiguadores',
  MaintenanceType.muelles: 'Muelles',
  MaintenanceType.copelas: 'Copelas',
  MaintenanceType.rodamientosCopela: 'Rodamientos de copela',
  MaintenanceType.brazosSuspension: 'Brazos de suspensión',
  MaintenanceType.silentblocks: 'Silentblocks',
  MaintenanceType.rotulasSuspension: 'Rótulas',
  MaintenanceType.bieletasEstabilizadoras: 'Bieletas estabilizadoras',
  MaintenanceType.barraEstabilizadora: 'Barra estabilizadora',
  MaintenanceType.rodamientosRueda: 'Rodamientos de rueda',
  MaintenanceType.mangueta: 'Mangueta',
  MaintenanceType.suspensionNeumatica: 'Suspensión neumática',
  MaintenanceType.compresorSuspension: 'Compresor de suspensión',
  MaintenanceType.otroSuspension: 'Otro (suspensión)',
  // Dirección
  MaintenanceType.direccionAsistida: 'Dirección asistida',
  MaintenanceType.bombaDireccion: 'Bomba de dirección',
  MaintenanceType.cremallera: 'Cremallera',
  MaintenanceType.terminalDireccion: 'Terminal de dirección',
  MaintenanceType.rotulaDireccion: 'Rótula de dirección',
  MaintenanceType.columnaDireccion: 'Columna de dirección',
  MaintenanceType.volante: 'Volante',
  MaintenanceType.direccionElectrica: 'Dirección eléctrica',
  MaintenanceType.liquidoDireccion: 'Líquido de dirección',
  MaintenanceType.otroDireccion: 'Otro (dirección)',
  // Transmisión
  MaintenanceType.embrague: 'Embrague',
  MaintenanceType.kitEmbrague: 'Kit de embrague',
  MaintenanceType.volanteBimasa: 'Volante bimasa',
  MaintenanceType.cajaCambiosManual: 'Caja de cambios manual',
  MaintenanceType.cajaCambiosAutomatica: 'Caja de cambios automática',
  MaintenanceType.aceiteCajaCambios: 'Aceite de caja de cambios',
  MaintenanceType.filtroCajaCambios: 'Filtro de caja de cambios',
  MaintenanceType.convertidorPar: 'Convertidor de par',
  MaintenanceType.mecatronica: 'Mecatrónica',
  MaintenanceType.palieres: 'Palieres',
  MaintenanceType.juntasHomocineticas: 'Juntas homocinéticas',
  MaintenanceType.arbolTransmision: 'Árbol de transmisión',
  MaintenanceType.diferencial: 'Diferencial',
  MaintenanceType.aceiteDiferencial: 'Aceite de diferencial',
  MaintenanceType.transfer: 'Transfer',
  MaintenanceType.aceiteTransfer: 'Aceite de transfer',
  MaintenanceType.retenesTransmision: 'Retenes de transmisión',
  MaintenanceType.otroTransmision: 'Otro (transmisión)',
  // Climatización
  MaintenanceType.aireAcondicionado: 'Aire acondicionado',
  MaintenanceType.gasRefrigeranteAc: 'Gas refrigerante',
  MaintenanceType.compresorAc: 'Compresor A/C',
  MaintenanceType.condensadorAc: 'Condensador',
  MaintenanceType.evaporadorAc: 'Evaporador',
  MaintenanceType.filtroDeshidratador: 'Filtro deshidratador',
  MaintenanceType.ventiladorClimatizacion: 'Ventilador',
  MaintenanceType.motorVentilador: 'Motor del ventilador',
  MaintenanceType.calefaccion: 'Calefacción',
  MaintenanceType.radiadorCalefaccion: 'Radiador de calefacción',
  MaintenanceType.termostatoClimatizacion: 'Termostato de climatización',
  MaintenanceType.otroClimatizacion: 'Otro (climatización)',
  // Escape y emisiones
  MaintenanceType.escape: 'Escape',
  MaintenanceType.silencioso: 'Silencioso',
  MaintenanceType.catalizador: 'Catalizador',
  MaintenanceType.dpfFap: 'Filtro de partículas (DPF/FAP)',
  MaintenanceType.egr: 'EGR',
  MaintenanceType.sondaLambda: 'Sonda lambda',
  MaintenanceType.sensorNox: 'Sensor NOx',
  MaintenanceType.sensorTemperaturaEscape: 'Sensor de temperatura',
  MaintenanceType.adblueScr: 'AdBlue / SCR',
  MaintenanceType.inyectorAdblue: 'Inyector AdBlue',
  MaintenanceType.depositoAdblue: 'Depósito AdBlue',
  MaintenanceType.otroEscapeEmisiones: 'Otro (escape y emisiones)',
  // Carrocería
  MaintenanceType.paragolpes: 'Parachoques',
  MaintenanceType.capo: 'Capó',
  MaintenanceType.puertas: 'Puertas',
  MaintenanceType.porton: 'Portón',
  MaintenanceType.aletas: 'Aletas',
  MaintenanceType.espejos: 'Espejos',
  MaintenanceType.elevalunas: 'Elevalunas',
  MaintenanceType.cerraduras: 'Cerraduras',
  MaintenanceType.bisagras: 'Bisagras',
  MaintenanceType.escobillasLimpiaparabrisas: 'Escobillas limpiaparabrisas',
  MaintenanceType.brazosLimpiaparabrisas: 'Brazos limpiaparabrisas',
  MaintenanceType.motorLimpiaparabrisas: 'Motor limpiaparabrisas',
  MaintenanceType.lunaParabrisas: 'Luna / parabrisas',
  MaintenanceType.molduras: 'Molduras',
  MaintenanceType.juntasCarroceria: 'Juntas',
  MaintenanceType.techoSolar: 'Techo solar / panorámico',
  MaintenanceType.otroCarroceria: 'Otro (carrocería)',
  // Habitáculo
  MaintenanceType.filtroHabitaculo: 'Filtro de habitáculo',
  MaintenanceType.alfombrillas: 'Alfombrillas',
  MaintenanceType.asientos: 'Asientos',
  MaintenanceType.salpicadero: 'Salpicadero',
  MaintenanceType.instrumentacion: 'Instrumentación',
  MaintenanceType.pantallaInfotainment: 'Pantalla / infotainment',
  MaintenanceType.altavoces: 'Altavoces',
  MaintenanceType.otroHabitaculo: 'Otro (habitáculo)',
  // Seguridad
  MaintenanceType.airbag: 'Airbag',
  MaintenanceType.pretensorCinturon: 'Pretensor de cinturón',
  MaintenanceType.cinturonSeguridad: 'Cinturón de seguridad',
  MaintenanceType.esp: 'ESP / ESC',
  MaintenanceType.sensorImpacto: 'Sensor de impacto',
  MaintenanceType.camaraSeguridad: 'Cámara',
  MaintenanceType.radarSeguridad: 'Radar',
  MaintenanceType.adas: 'ADAS',
  MaintenanceType.sensorAparcamiento: 'Sensor de aparcamiento',
  MaintenanceType.otroSeguridad: 'Otro (seguridad)',
  // ITV
  MaintenanceType.inspeccionItv: 'ITV',
  MaintenanceType.preItv: 'Pre-ITV',
  MaintenanceType.inspeccionGeneral: 'Inspección general',
  MaintenanceType.inspeccionEmisiones: 'Inspección de emisiones',
  MaintenanceType.inspeccionFrenos: 'Inspección de frenos',
  MaintenanceType.inspeccionNeumaticos: 'Inspección de neumáticos',
  MaintenanceType.inspeccionLuces: 'Inspección de luces',
  MaintenanceType.otroItv: 'Otro (ITV)',
  // Otro
  MaintenanceType.mantenimientoGeneral: 'Mantenimiento general',
  MaintenanceType.reparacionGeneral: 'Reparación general',
  MaintenanceType.otro: 'Otro',
};

const Map<Posicion, String> etiquetasPosicion = {
  Posicion.delantera: 'Delantera',
  Posicion.trasera: 'Trasera',
  Posicion.izquierda: 'Izquierda',
  Posicion.derecha: 'Derecha',
  Posicion.delanteraIzquierda: 'Delantera izquierda',
  Posicion.delanteraDerecha: 'Delantera derecha',
  Posicion.traseraIzquierda: 'Trasera izquierda',
  Posicion.traseraDerecha: 'Trasera derecha',
  Posicion.ejeDelantero: 'Eje delantero',
  Posicion.ejeTrasero: 'Eje trasero',
};
```

Un test rápido de que `etiquetasMaintenanceType` cubre los 175 valores evita el error más probable de transcripción: al terminar el Paso 1, ejecuta

```powershell
flutter test test/domain/maintenance_type_test.dart --reporter=failures-only
```

y además, antes del Paso 2, añade temporalmente (o verifica a mano) que `etiquetasMaintenanceType.length == MaintenanceType.values.length` — si no coincide, falta o sobra una entrada en el mapa.

**Qué construir en el formulario (comportamiento, no código dictado):**

- Añade, después del desplegable de Categoría ya existente, un desplegable de **Tipo** (`MaintenanceType?`, opcional, con una opción "Sin tipo concreto" además de los valores del catálogo) y, cuando el tipo elegido tenga `admitePosicion == true`, un desplegable de **Posición** (`Posicion?`) que aparece y desaparece dinámicamente.
- El desplegable de Tipo solo ofrece los valores de `MaintenanceType.values` cuya `categoria` coincida con la categoría ya elegida — usa `etiquetasMaintenanceType` para las etiquetas, filtrando por `t.categoria == _categoria`.
- **Condición 1 (categoría derivada del tipo):** en cuanto se elige un Tipo, la Categoría deja de ser un desplegable libre — se fija a `tipo.categoria` y se muestra sin permitir cambiarla directamente (por ejemplo, deshabilitando el desplegable de Categoría mientras haya un Tipo elegido). Solo vuelve a ser editable si el Tipo se pone a "Sin tipo concreto".
- **Condición 2 (nombre autogenerado, editable):** añade el campo `bool _nombreAutogenerado`, inicializado desde `widget.schedule?.nombreAutogenerado ?? false`. Cuando el usuario elige un Tipo o una Posición y `_nombreAutogenerado` es `true` (o el campo Nombre está vacío, en el caso de creación), reescribe `_nombre.text` con `etiquetasMaintenanceType[tipo]` seguido de `, ${etiquetasPosicion[posicion]}` si hay posición (por ejemplo "Pastillas de freno, Delantera" — el separador exacto es tu criterio, mientras sea legible). En cuanto el usuario edita el campo Nombre directamente (usa un `onChanged` o compara el texto tras cada `setState`), `_nombreAutogenerado` pasa a `false` y no se vuelve a tocar el campo Nombre automáticamente, aunque después cambien Tipo o Posición.
- Al guardar (`_guardar`), incluye `tipo: Value(_tipo)`, `posicion: Value(_posicion)` y `nombreAutogenerado: Value(_nombreAutogenerado)` tanto en la rama de creación como en la de edición, igual que el resto de campos.
- El botón de borrar ya existente (Tarea de la fase 4) no cambia.

- [ ] **Paso 1: Añadir los mapas de etiquetas**

- [ ] **Paso 2: Verificar cobertura del mapa contra el catálogo**

```powershell
flutter test test/domain/maintenance_type_test.dart --reporter=failures-only
```

- [ ] **Paso 3: Añadir la cascada Categoría → Tipo → Posición y la lógica de nombre autogenerado**

- [ ] **Paso 4: Guardar tipo, posición y nombreAutogenerado al crear y al editar**

- [ ] **Paso 5: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando.

- [ ] **Paso 6: Commit**

```bash
git add -A && git commit -q -m "Añadir la cascada de tipo y posición al formulario de mantenimiento"
```

---

## Tarea 5: Selector de `kind` en "Registrar realizado"

Describe comportamiento, no dicta código.

**Ficheros:**
- Modificar: `lib/ui/maintenance/register_maintenance_sheet.dart`
- Modificar: `lib/ui/maintenance/maintenance_form_screen.dart` (solo el mapa de etiquetas nuevo)

**Interfaces:**
- Consume: `MaintenanceOperationKind` (Tarea 1), `MaintenanceType.defaultKind` (Tarea 2), `MaintenanceSchedule.tipo` (Tarea 3).
- Produce: `etiquetasMaintenanceOperationKind` (`Map<MaintenanceOperationKind, String>`), usado también por la Tarea 7.

**El mapa de etiquetas, código completo** (añádelo junto a `etiquetasMaintenanceType` en `maintenance_form_screen.dart`):

```dart
const Map<MaintenanceOperationKind, String> etiquetasMaintenanceOperationKind = {
  MaintenanceOperationKind.preventivo: 'Preventivo',
  MaintenanceOperationKind.inspeccion: 'Inspección',
  MaintenanceOperationKind.reparacion: 'Reparación',
  MaintenanceOperationKind.sustitucion: 'Sustitución',
  MaintenanceOperationKind.otro: 'Otro',
};
```

**Qué construir:** en `_HojaRegistroMantenimiento`, añade un `DropdownButtonFormField<MaintenanceOperationKind?>` para `kind`, opcional (con una opción "Sin especificar" además de los cinco valores), colocado junto a fecha/kilómetros/coste. Sigue el mismo patrón que el desplegable de "Mantenimiento" ya existente (`DropdownButtonFormField<int?>`, `isExpanded: true`).

**Sugerencia inicial (condición 3):** cuando el usuario elige un mantenimiento en el desplegable "Mantenimiento" (`_scheduleSeleccionadoId` cambia) y ese `MaintenanceSchedule` tiene `tipo` no nulo, rellena el desplegable de `kind` con `schedule.tipo!.defaultKind` — pero solo como valor inicial de esa selección, no forzado: si el usuario lo cambia a mano, se queda con lo que él elija. Si el mantenimiento elegido no tiene `tipo`, o es "Reparación puntual", el desplegable de `kind` queda vacío ("Sin especificar"), sin ninguna sugerencia.

Para encontrar el `MaintenanceSchedule` completo a partir del id seleccionado, usa `opciones.firstWhere((s) => s.id == id)` sobre la lista `opciones` que el `build()` ya construye.

Al guardar (`_guardar`), añade `kind: Value(_kind)` a la construcción de `MaintenanceRecordsCompanion.insert(...)` que ya existe.

- [ ] **Paso 1: Añadir el mapa de etiquetas en `maintenance_form_screen.dart`**

- [ ] **Paso 2: Añadir el campo `MaintenanceOperationKind? _kind` y el desplegable en la hoja de registro**

- [ ] **Paso 3: Rellenar `_kind` con la sugerencia al elegir un mantenimiento con tipo**

- [ ] **Paso 4: Guardar `kind` en el registro**

- [ ] **Paso 5: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando.

- [ ] **Paso 6: Commit**

```bash
git add -A && git commit -q -m "Sugerir el kind de la intervención al registrar un mantenimiento"
```

---

## Tarea 6: Enriquecer las plantillas con tipo y posición

Dato de dominio, no interfaz — mismo criterio que las Tareas 1 y 2.

**Ficheros:**
- Modificar: `lib/domain/plantillas_mantenimiento.dart`

**Interfaces:**
- Consume: `MaintenanceType`, `Posicion` (Tareas 1 y 2).
- Produce: `PlantillaMantenimiento.tipo` (`MaintenanceType?`), `PlantillaMantenimiento.posicion` (`Posicion?`).

- [ ] **Paso 1: Ampliar la clase y las 15 plantillas existentes**

Reescribe el fichero completo — mismo contenido que ya existe, con `tipo`/`posicion` añadidos donde encajan de forma directa (el resto se queda a `null`, sin forzar ninguno):

```dart
import 'fuel_type.dart';
import 'itv.dart' show mesesEntreItv;
import 'maintenance_category.dart';
import 'maintenance_type.dart';
import 'posicion.dart';

/// Un mantenimiento habitual propuesto al dar de alta un vehículo.
///
/// Los intervalos son orientativos: valores razonables para partir de algo,
/// no cifras oficiales de ningún fabricante. Quien use la app debe
/// ajustarlos con el libro de mantenimiento de su coche delante — la
/// pantalla que muestra esta lista tiene que dejarlo claro.
class PlantillaMantenimiento {
  final String nombre;
  final MaintenanceCategory categoria;

  /// Nulo cuando la plantilla no encaja de forma directa en un tipo del
  /// catálogo, o cuando no aporta nada frente al nombre libre.
  final MaintenanceType? tipo;
  final Posicion? posicion;

  /// Nulo cuando el mantenimiento no tiene un kilometraje orientativo
  /// razonable (p. ej. la distribución, que depende del motor concreto) o
  /// cuando solo tiene sentido por tiempo.
  final int? intervalKm;

  /// Nulo cuando el mantenimiento no tiene un plazo orientativo razonable o
  /// cuando solo tiene sentido por kilómetros.
  final int? intervalMeses;

  const PlantillaMantenimiento({
    required this.nombre,
    required this.categoria,
    this.tipo,
    this.posicion,
    this.intervalKm,
    this.intervalMeses,
  });
}

/// Meses que se proponen para la ITV cuando el vehículo todavía no llega a
/// los cuatro años o no se conoce su fecha de matriculación: es la
/// periodicidad que le tocará en cuanto deje de estar exento, y evita
/// proponer un intervalo de 0 meses, que no significa nada para el usuario.
const _mesesItvPorDefecto = 24;

/// Mantenimientos habituales que se proponen al dar de alta un vehículo,
/// según su combustible, si el cambio es automático y, para la ITV, su
/// antigüedad a día de hoy.
///
/// Son un punto de partida, no una recomendación oficial: la app no conoce
/// las cifras que da el fabricante para cada motor concreto.
List<PlantillaMantenimiento> plantillasPara({
  required FuelType combustible,
  required bool esAutomatico,
  DateTime? fechaMatriculacion,
}) {
  final esElectrico = combustible == FuelType.electrico;
  final esDiesel = combustible == FuelType.diesel;
  // Los motores de gasolina llevan bujías, tanto si son puros como si
  // forman parte de un híbrido o queman GLP.
  final llevaBujias =
      combustible == FuelType.gasolina ||
      combustible == FuelType.hibrido ||
      combustible == FuelType.glp;

  return [
    if (!esElectrico) ...[
      const PlantillaMantenimiento(
        nombre: 'Aceite y filtro',
        categoria: MaintenanceCategory.motor,
        tipo: MaintenanceType.aceiteMotor,
        intervalKm: 15000,
        intervalMeses: 12,
      ),
      const PlantillaMantenimiento(
        nombre: 'Filtro de aire',
        categoria: MaintenanceCategory.motor,
        tipo: MaintenanceType.filtroAire,
        intervalKm: 30000,
        intervalMeses: 24,
      ),
    ],
    const PlantillaMantenimiento(
      nombre: 'Filtro de habitáculo',
      categoria: MaintenanceCategory.habitaculo,
      tipo: MaintenanceType.filtroHabitaculo,
      intervalKm: 20000,
      intervalMeses: 12,
    ),
    if (esDiesel)
      const PlantillaMantenimiento(
        nombre: 'Filtro de combustible',
        categoria: MaintenanceCategory.motor,
        tipo: MaintenanceType.filtroCombustible,
        intervalKm: 40000,
        intervalMeses: 48,
      ),
    if (llevaBujias)
      const PlantillaMantenimiento(
        nombre: 'Bujías',
        categoria: MaintenanceCategory.motor,
        tipo: MaintenanceType.bujias,
        intervalKm: 60000,
        intervalMeses: 60,
      ),
    const PlantillaMantenimiento(
      nombre: 'Líquido de frenos',
      categoria: MaintenanceCategory.frenos,
      tipo: MaintenanceType.liquidoFrenos,
      intervalMeses: 24,
    ),
    if (!esElectrico)
      const PlantillaMantenimiento(
        nombre: 'Refrigerante',
        categoria: MaintenanceCategory.motor,
        tipo: MaintenanceType.refrigerante,
        intervalKm: 60000,
        intervalMeses: 48,
      ),
    const PlantillaMantenimiento(
      nombre: 'Pastillas de freno delanteras',
      categoria: MaintenanceCategory.frenos,
      tipo: MaintenanceType.pastillasFreno,
      posicion: Posicion.delantera,
      intervalKm: 40000,
    ),
    const PlantillaMantenimiento(
      nombre: 'Pastillas de freno traseras',
      categoria: MaintenanceCategory.frenos,
      tipo: MaintenanceType.pastillasFreno,
      posicion: Posicion.trasera,
      intervalKm: 60000,
    ),
    const PlantillaMantenimiento(
      nombre: 'Discos de freno',
      categoria: MaintenanceCategory.frenos,
      tipo: MaintenanceType.discosFreno,
      intervalKm: 80000,
    ),
    const PlantillaMantenimiento(
      nombre: 'Neumáticos',
      categoria: MaintenanceCategory.neumaticos,
      tipo: MaintenanceType.neumatico,
      intervalKm: 40000,
      intervalMeses: 72,
    ),
    const PlantillaMantenimiento(
      nombre: 'Batería',
      categoria: MaintenanceCategory.electricidad,
      tipo: MaintenanceType.bateria,
      intervalMeses: 60,
    ),
    // Sin tipo ni intervalo a propósito: depende del motor concreto y la
    // app no puede saberlo. Que el dueño lo rellene con el libro delante.
    if (!esElectrico)
      const PlantillaMantenimiento(
        nombre: 'Correa o cadena de distribución',
        categoria: MaintenanceCategory.motor,
      ),
    if (esAutomatico)
      const PlantillaMantenimiento(
        nombre: 'Aceite de la caja automática',
        categoria: MaintenanceCategory.transmision,
        tipo: MaintenanceType.aceiteCajaCambios,
        intervalKm: 60000,
        intervalMeses: 72,
      ),
    PlantillaMantenimiento(
      nombre: 'ITV',
      categoria: MaintenanceCategory.itv,
      tipo: MaintenanceType.inspeccionItv,
      intervalMeses: _mesesItvOrientativos(fechaMatriculacion),
    ),
  ];
}

int _mesesItvOrientativos(DateTime? fechaMatriculacion) {
  if (fechaMatriculacion == null) return _mesesItvPorDefecto;
  final meses = mesesEntreItv(fechaMatriculacion, DateTime.now());
  // meses == 0 mientras el vehículo está exento: no hay periodicidad real
  // que proponer todavía.
  return meses == 0 ? _mesesItvPorDefecto : meses;
}
```

Nota: la plantilla "Filtro de habitáculo" cambia de categoría `otro` a `habitaculo` (la categoría nueva de la Tarea 1) — es la misma resolución de solapamiento de la spec §4, no un cambio de comportamiento para el usuario (sigue siendo la misma plantilla, con el mismo nombre e intervalo).

- [ ] **Paso 2: Revisar si algún test existente sobre `plantillasPara` verifica la categoría exacta de "Filtro de habitáculo"**

```powershell
grep -rn "Filtro de habitáculo\|plantillasPara" test/
```

Si algún test espera `MaintenanceCategory.otro` para esa plantilla, actualízalo a `MaintenanceCategory.habitaculo` — es el único cambio de comportamiento de esta tarea, y está documentado en la spec.

- [ ] **Paso 3: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando.

- [ ] **Paso 4: Commit**

```bash
git add -A && git commit -q -m "Enriquecer las plantillas de mantenimiento con tipo y posición"
```

---

## Tarea 7: Mostrar tipo, posición y kind donde ya se muestra cada mantenimiento

Describe comportamiento, no dicta código.

**Ficheros:**
- Modificar: `lib/ui/vehicle/vehicle_detail_screen.dart`
- Modificar: `lib/ui/history/history_screen.dart`

**Interfaces:**
- Consume: `etiquetasMaintenanceType`, `etiquetasPosicion` (Tarea 4), `etiquetasMaintenanceOperationKind` (Tarea 5), `MaintenanceSchedule.tipo`/`posicion` (Tarea 3), `MaintenanceRecord.kind` (Tarea 3).

**Dónde y qué mostrar:**

- En `_FilaMantenimiento` y `_TarjetaDestacada` de `vehicle_detail_screen.dart`: cuando `item.schedule.tipo` no sea nulo, añade una línea o distintivo discreto con `etiquetasMaintenanceType[item.schedule.tipo]`, seguido de `etiquetasPosicion[item.schedule.posicion]` entre paréntesis si `posicion` tampoco es nulo (p. ej. "Pastillas de freno (Delantera)"). Sigue el mismo criterio visual que `OrigenChip` (Fase 4): no compite con el color de `EstadoChip`, es información secundaria. Si `tipo` es nulo, no se muestra nada nuevo — el mantenimiento se ve exactamente igual que hoy.
- En `_FilaHistorial` de `history_screen.dart`: junto a la línea de categoría ya existente (`etiquetasCategoria[schedule!.categoria]!`), si `schedule.tipo` no es nulo añade el tipo (y posición, igual que arriba). Además, si `registro.kind` no es nulo, muestra `etiquetasMaintenanceOperationKind[registro.kind]` como un dato más en el `Wrap` de la fila (junto a fecha y kilómetros, mismo patrón que los `_Dato` ya existentes con icono).

La decisión visual concreta (icono, disposición exacta, si es una línea de texto o una cápsula) queda a tu criterio dentro de ese espíritu; lo no negociable es que un mantenimiento o registro sin tipo/kind no muestre ningún hueco vacío ni placeholder.

- [ ] **Paso 1: Añadir tipo/posición en `_FilaMantenimiento` y `_TarjetaDestacada`**

- [ ] **Paso 2: Añadir tipo/posición y kind en `_FilaHistorial`**

- [ ] **Paso 3: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando.

- [ ] **Paso 4: Commit**

```bash
git add -A && git commit -q -m "Mostrar tipo, posición y kind en la ficha del vehículo y el historial"
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

Esperado: `No issues found!`, todos los tests pasando, y el APK construido.

- [ ] **Paso 2: Commit**

```bash
git add -A && git commit -q -m "Cerrar la taxonomía de tipos, posición y kind de mantenimiento" --allow-empty
```
