# Fase 4 — Motor de recomendaciones y mantenimiento inteligente

> **Para agentes ejecutores:** SUB-SKILL OBLIGATORIA: usa `superpowers:subagent-driven-development` (recomendada) o `superpowers:executing-plans` para implementar este plan tarea a tarea. Los pasos usan casillas (`- [ ]`) para el seguimiento.

**Objetivo:** que la aplicación deje de ser un simple listado de avisos y empiece a ayudar a decidir: qué mantenimientos conviene hacer juntos, cuánto se puede confiar en cada dato de "última vez", y qué patrón de uso real tiene cada mantenimiento — todo sobre datos que la app ya tiene, sin ningún proveedor externo.

**Arquitectura:** cuatro piezas de dominio puras (agrupación, origen del dato, patrón real de uso, y la fuente del intervalo) que se apoyan en lo ya construido en las fases 2 y 3 — `Vencimiento.diasHastaVencimiento`, `esSembrado`, `vencimientosProvider` — más su superficie en la ficha del vehículo.

**Tech Stack:** Flutter, Drift (SQLite), Riverpod. Sin dependencias nuevas.

## Global Constraints

- Plataforma única: Android. `minSdkVersion` 24.
- Toda la interfaz en español. Fechas `dd/MM/yyyy`, separador de miles con punto.
- `lib/domain/` no puede importar `package:drift/...` ni `package:flutter/...`.
- Sin dependencias nuevas.
- Mensajes de commit en español, sin coautoría ni menciones a herramientas.
- **Entorno**: el toolchain no está en el PATH y la carpeta temporal debe redirigirse o Gradle no arranca. Antepón a cada comando de PowerShell:
  `$env:Path = "F:\dev\flutter\bin;F:\dev\android-sdk\platform-tools;$env:Path"; $env:JAVA_HOME = 'C:\Program Files\Eclipse Adoptium\jdk-17.0.20.8-hotspot'; $env:ANDROID_HOME = 'F:\dev\android-sdk'; $env:TMP = 'F:\dev\tmp'; $env:TEMP = 'F:\dev\tmp'`
- **Formato**: el proyecto usa el formateador estándar de Dart (`dart format`) desde el commit `a8e4470`. El código nuevo debe salir ya en ese estilo; si dudas, ejecuta `dart format` solo sobre el fichero que acabas de crear, nunca sobre ficheros existentes completos.
- Punto de partida: `flutter analyze` limpio, 104 tests pasando.

## Decisiones de diseño ya cerradas (no reabrir sin motivo)

Vienen del documento de visión (`docs/superpowers/specs/2026-08-12-roadmap-identidad-tecnica-catalogo-piezas.md`, §6) y de un cierre de detalles posterior:

- **La agrupación compara por kilómetros o por días, no todo traducido a días.** Dos mantenimientos que van solo por kilómetros se comparan por `kmRestantes` directamente, sin pasar por el ritmo de uso estimado. Dos que van por tiempo (o uno de cada) se comparan por `diasHastaVencimiento`. Basta con que se cumpla una de las dos condiciones para agrupar.
- **El origen del dato se deriva del registro más reciente**, no de "si alguna vez hubo un registro sembrado". Un mantenimiento que se sembró al configurarlo y después tuvo un registro real pasa a `confirmado`: lo último que la app sabe manda.
- **El patrón real de uso ignora los registros sembrados.** Solo cuenta lo que la app ha presenciado de verdad. Nunca modifica el intervalo configurado.
- **`fuenteIntervalo` se añade al esquema, con valor por defecto `orientativo`, pero sin ninguna forma de ponerlo a `usuario` o `fabricante` todavía.** El valor `fabricante` solo será alcanzable cuando exista un catálogo (fase 5/6); `usuario`, cuando se decida cómo detectar que alguien ajustó un intervalo a mano. Por ese motivo, y para no generar una pantalla que repita el mismo texto en todos los mantenimientos sin aportar nada, **esta fase no muestra el texto de `fuenteIntervalo` en ninguna pantalla**. Solo prepara el dato, igual que se hizo con `codigoTecnico` en la fase 3.
- **La migración de `fuenteIntervalo` toca una trampa ya documentada en `CLAUDE.md`** ("Trampa conocida: `m.createTable()` usa siempre la definición actual de la tabla"): `MaintenanceSchedules` se creó en el paso `from < 3` de una migración anterior, y ese paso siempre usará la definición *actual* de la clase Dart — que para este código ya incluye `fuenteIntervalo`. La Tarea 4 explica la guarda exacta y trae el test que lo demuestra.
- **La agrupación, el origen y el patrón real solo se muestran en la ficha del vehículo** (`vehicle_detail_screen.dart`), no en la pantalla de Inicio. Inicio existe para responder "¿tengo algo pendiente?" en tres segundos; añadirle más capas de información iría en contra de ese objetivo, ya fijado en la fase 2.

## Estructura de ficheros

| Fichero | Responsabilidad |
|---|---|
| `lib/domain/maintenance_grouping.dart` | `MaintenanceGroupingPolicy`, `agruparPorProximidad` |
| `lib/domain/origen_mantenimiento.dart` | `OrigenMantenimiento`, `calcularOrigen` |
| `lib/domain/patron_real_uso.dart` | `PatronRealUso`, `calcularPatronReal` |
| `lib/domain/fuente_intervalo.dart` | `FuenteIntervalo`, `etiquetasFuenteIntervalo` |
| `lib/data/tables/maintenance_schedules.dart` | Se amplía con la columna `fuenteIntervalo` |
| `lib/data/database.dart` | Se amplía con la migración v4→v5 |
| `lib/data/daos/maintenance_dao.dart` | Se amplía con `registrosRealesDe` |
| `lib/providers/mantenimiento_providers.dart` | Se amplía con `patronRealProvider` |
| `lib/ui/common/origen_chip.dart` | Distintivo visual del origen del dato |
| `lib/ui/vehicle/vehicle_detail_screen.dart` | Se amplía con el origen, la agrupación y el patrón real |
| `test/domain/maintenance_grouping_test.dart` | Tests de la agrupación |
| `test/domain/origen_mantenimiento_test.dart` | Tests del origen |
| `test/domain/patron_real_uso_test.dart` | Tests del patrón real |
| `test/data/database_migration_test.dart` | Se amplía con los tests de la migración v4→v5 |
| `test/data/maintenance_dao_test.dart` | Se amplía con el test de `registrosRealesDe` |

---

## Tarea 1: Agrupación de mantenimientos próximos

Lógica de dominio pura.

**Ficheros:**
- Crear: `lib/domain/maintenance_grouping.dart`, `test/domain/maintenance_grouping_test.dart`

**Interfaces:**
- Consume: `Vencimiento` de `lib/domain/maintenance_due.dart`.
- Produce: clase `MaintenanceGroupingPolicy` (campos `maxKmDiferencia`, `maxDiasDiferencia`, con valores por defecto 500 y 15); función `List<List<int>> agruparPorProximidad(List<Vencimiento> vencimientos, MaintenanceGroupingPolicy politica)`.

- [ ] **Paso 1: Escribir el test que debe fallar**

`test/domain/maintenance_grouping_test.dart`:

```dart
import 'package:car_care/domain/maintenance_due.dart';
import 'package:car_care/domain/maintenance_grouping.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const politica = MaintenanceGroupingPolicy();

  Vencimiento v({int? kmRestantes, int? diasHastaVencimiento}) => Vencimiento(
    estado: EstadoMantenimiento.proximo,
    kmProyectado: 0,
    kmRestantes: kmRestantes,
    diasHastaVencimiento: diasHastaVencimiento,
  );

  test('lista vacia da una lista de grupos vacia', () {
    expect(agruparPorProximidad([], politica), isEmpty);
  });

  test('un solo vencimiento forma su propio grupo', () {
    final grupos = agruparPorProximidad([v(kmRestantes: 500)], politica);

    expect(grupos, [
      [0],
    ]);
  });

  test('dos mantenimientos por km cerca entre si se agrupan', () {
    // 800 - 500 = 300, dentro de los 500 km por defecto.
    final grupos = agruparPorProximidad([
      v(kmRestantes: 500),
      v(kmRestantes: 800),
    ], politica);

    expect(grupos, [
      [0, 1],
    ]);
  });

  test('dos mantenimientos por km lejos entre si no se agrupan', () {
    // 3000 - 500 = 2500, fuera de los 500 km por defecto.
    final grupos = agruparPorProximidad([
      v(kmRestantes: 500),
      v(kmRestantes: 3000),
    ], politica);

    expect(grupos, [
      [0],
      [1],
    ]);
  });

  test('dos mantenimientos por tiempo cerca entre si se agrupan', () {
    // Diferencia de 10 días, dentro de los 15 por defecto.
    final grupos = agruparPorProximidad([
      v(diasHastaVencimiento: 20),
      v(diasHastaVencimiento: 30),
    ], politica);

    expect(grupos, [
      [0, 1],
    ]);
  });

  test(
    'un mantenimiento por km y otro por tiempo se agrupan si los dias '
    'coinciden aunque los km no sean comparables',
    () {
      // El primero no tiene diasHastaVencimiento (va solo por km) y el
      // segundo no tiene kmRestantes (va solo por tiempo): la comparación
      // por km no aplica a ninguno de los dos porque a uno le falta el
      // dato, así que solo puede agruparlos la vía de días. Se construyen
      // con diasHastaVencimiento próximos entre sí para que sea esa vía la
      // que decida.
      final grupos = agruparPorProximidad([
        v(kmRestantes: 500, diasHastaVencimiento: 20),
        v(diasHastaVencimiento: 25),
      ], politica);

      expect(grupos, [
        [0, 1],
      ]);
    },
  );

  test('una cadena de tres solo agrupa los que estan cerca entre si', () {
    // 0 y 1 están cerca (diferencia 200 km); 1 y 2 están lejos (diferencia
    // 5000 km): el grupo se corta entre el segundo y el tercero.
    final grupos = agruparPorProximidad([
      v(kmRestantes: 100),
      v(kmRestantes: 300),
      v(kmRestantes: 5300),
    ], politica);

    expect(grupos, [
      [0, 1],
      [2],
    ]);
  });

  test('el margen es inclusivo: justo en el limite tambien agrupa', () {
    // Diferencia exacta de 500 km, el límite por defecto.
    final grupos = agruparPorProximidad([
      v(kmRestantes: 0),
      v(kmRestantes: 500),
    ], politica);

    expect(grupos, [
      [0, 1],
    ]);
  });

  test('una politica mas estricta agrupa menos', () {
    const estricta = MaintenanceGroupingPolicy(
      maxKmDiferencia: 100,
      maxDiasDiferencia: 5,
    );
    final grupos = agruparPorProximidad([
      v(kmRestantes: 0),
      v(kmRestantes: 300),
    ], estricta);

    expect(grupos, [
      [0],
      [1],
    ]);
  });
}
```

- [ ] **Paso 2: Ejecutar el test para verificar que falla**

```powershell
flutter test test/domain/maintenance_grouping_test.dart --reporter=failures-only
```

Esperado: FALLA porque `lib/domain/maintenance_grouping.dart` no existe.

- [ ] **Paso 3: Escribir la implementación**

`lib/domain/maintenance_grouping.dart`:

```dart
import 'maintenance_due.dart';

/// Umbrales que deciden si dos mantenimientos próximos se muestran como
/// "puedes hacerlos juntos". No son una verdad fija —tras usar la app puede
/// convenir ajustarlos—, así que viven aquí y no como literales sueltos en
/// el provider o en la pantalla.
class MaintenanceGroupingPolicy {
  final int maxKmDiferencia;
  final int maxDiasDiferencia;

  const MaintenanceGroupingPolicy({
    this.maxKmDiferencia = 500,
    this.maxDiasDiferencia = 15,
  });
}

/// Agrupa los índices de [vencimientos] (una lista ya ordenada por
/// urgencia, típicamente la que devuelve `vencimientosProvider`) según
/// [politica].
///
/// Dos vencimientos consecutivos entran en el mismo grupo si, por
/// cualquiera de las dos vías, están lo bastante cerca: sus kilómetros
/// restantes difieren `maxKmDiferencia` o menos (cuando ambos tienen
/// kilómetros restantes), o sus días hasta el vencimiento difieren
/// `maxDiasDiferencia` o menos (cuando ambos tienen esa magnitud
/// calculada). Comparar los kilómetros de forma directa, sin traducirlos a
/// días, evita que dos mantenimientos que van solo por kilómetros dependan
/// de lo fiable que sea el ritmo de uso estimado.
///
/// Cada grupo tiene al menos un elemento; un grupo de un solo elemento
/// significa que ese mantenimiento no tiene ningún vecino cercano.
List<List<int>> agruparPorProximidad(
  List<Vencimiento> vencimientos,
  MaintenanceGroupingPolicy politica,
) {
  if (vencimientos.isEmpty) return [];

  final grupos = <List<int>>[
    [0],
  ];

  for (var i = 1; i < vencimientos.length; i++) {
    final anterior = vencimientos[i - 1];
    final actual = vencimientos[i];

    final cercaPorKm =
        anterior.kmRestantes != null &&
        actual.kmRestantes != null &&
        (anterior.kmRestantes! - actual.kmRestantes!).abs() <=
            politica.maxKmDiferencia;

    final cercaPorDias =
        anterior.diasHastaVencimiento != null &&
        actual.diasHastaVencimiento != null &&
        (anterior.diasHastaVencimiento! - actual.diasHastaVencimiento!).abs() <=
            politica.maxDiasDiferencia;

    if (cercaPorKm || cercaPorDias) {
      grupos.last.add(i);
    } else {
      grupos.add([i]);
    }
  }

  return grupos;
}
```

- [ ] **Paso 4: Ejecutar el test para verificar que pasa**

```powershell
flutter test test/domain/maintenance_grouping_test.dart --reporter=failures-only
```

Esperado: `All tests passed!`

Si algún caso falla, no cambies el valor esperado: los nueve casos están calculados a mano y son el contrato. Corrige la implementación.

- [ ] **Paso 5: Comprobar que el dominio sigue limpio**

```bash
grep -E "package:(drift|flutter)/" lib/domain/maintenance_grouping.dart
```

Esperado: sin salida.

- [ ] **Paso 6: Commit**

```bash
git add -A && git commit -q -m "Añadir la agrupación de mantenimientos próximos"
```

---

## Tarea 2: Origen del dato — confirmado, histórico o desconocido

Lógica de dominio pura.

**Ficheros:**
- Crear: `lib/domain/origen_mantenimiento.dart`, `test/domain/origen_mantenimiento_test.dart`

**Interfaces:**
- Produce: enum `OrigenMantenimiento { confirmado, historico, desconocido }`; función `OrigenMantenimiento calcularOrigen(bool? ultimoEsSembrado)`.

- [ ] **Paso 1: Escribir el test que debe fallar**

`test/domain/origen_mantenimiento_test.dart`:

```dart
import 'package:car_care/domain/origen_mantenimiento.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sin ningun registro, el origen es desconocido', () {
    expect(calcularOrigen(null), OrigenMantenimiento.desconocido);
  });

  test('con el ultimo registro sembrado, el origen es historico', () {
    expect(calcularOrigen(true), OrigenMantenimiento.historico);
  });

  test('con el ultimo registro real, el origen es confirmado', () {
    expect(calcularOrigen(false), OrigenMantenimiento.confirmado);
  });
}
```

- [ ] **Paso 2: Ejecutar el test para verificar que falla**

```powershell
flutter test test/domain/origen_mantenimiento_test.dart --reporter=failures-only
```

Esperado: FALLA porque el fichero no existe.

- [ ] **Paso 3: Escribir la implementación**

`lib/domain/origen_mantenimiento.dart`:

```dart
/// Cuánto se puede confiar en el dato de "cuándo se hizo por última vez"
/// de un mantenimiento.
///
/// Un mantenimiento sin ningún registro y uno sembrado a mano se comportan
/// igual de cara al motor de vencimientos —ambos calculan a partir del
/// mismo dato—, pero de cara al usuario son cosas distintas: uno es "no sé
/// si se ha hecho nunca", el otro es "sé que se hizo, antes de usar la
/// app".
enum OrigenMantenimiento {
  /// La app presenció el mantenimiento: hay un registro real (no sembrado)
  /// que lo confirma.
  confirmado,

  /// Dato introducido a mano al configurar el mantenimiento, anterior a la
  /// app. Es lo mejor que se sabe, pero no es un dato que la app haya visto
  /// ocurrir.
  historico,

  /// Sin ningún registro. No se sabe si el mantenimiento se ha hecho
  /// alguna vez.
  desconocido,
}

/// Determina el origen a partir de si el registro más reciente de ese
/// mantenimiento (si existe) está sembrado.
///
/// [ultimoEsSembrado] es el campo `esSembrado` del registro más reciente
/// del mantenimiento, o `null` si no hay ningún registro. Se usa siempre el
/// registro más reciente, no "si alguna vez hubo uno sembrado": un
/// mantenimiento que se sembró al configurarlo y después tuvo un registro
/// real pasa a confirmado.
OrigenMantenimiento calcularOrigen(bool? ultimoEsSembrado) {
  if (ultimoEsSembrado == null) return OrigenMantenimiento.desconocido;
  return ultimoEsSembrado
      ? OrigenMantenimiento.historico
      : OrigenMantenimiento.confirmado;
}
```

- [ ] **Paso 4: Ejecutar el test para verificar que pasa**

```powershell
flutter test test/domain/origen_mantenimiento_test.dart --reporter=failures-only
```

Esperado: `All tests passed!`

- [ ] **Paso 5: Commit**

```bash
git add -A && git commit -q -m "Añadir el origen del dato de cada mantenimiento"
```

---

## Tarea 3: Patrón real de uso

Lógica de dominio pura.

**Ficheros:**
- Crear: `lib/domain/patron_real_uso.dart`, `test/domain/patron_real_uso_test.dart`

**Interfaces:**
- Consume: `diasNaturalesEntre` de `lib/domain/maintenance_due.dart`.
- Produce: clase `PatronRealUso` (campos `kmMedioEntreCambios`, `diasMedioEntreCambios`, ambos `double`); función `PatronRealUso? calcularPatronReal(List<({DateTime fecha, int km})> registrosReales)`.

- [ ] **Paso 1: Escribir el test que debe fallar**

`test/domain/patron_real_uso_test.dart`:

```dart
import 'package:car_care/domain/patron_real_uso.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sin ningun registro no hay patron', () {
    expect(calcularPatronReal([]), isNull);
  });

  test('con un solo registro no hay patron', () {
    expect(
      calcularPatronReal([(fecha: DateTime(2026, 1, 1), km: 90000)]),
      isNull,
    );
  });

  test('con dos registros calcula el intervalo entre ellos', () {
    // Del 1 de enero de 2025 al 1 de enero de 2026: 365 días (2025 no es
    // bisiesto), 15.000 km de diferencia.
    final patron = calcularPatronReal([
      (fecha: DateTime(2025, 1, 1), km: 80000),
      (fecha: DateTime(2026, 1, 1), km: 95000),
    ]);

    expect(patron!.kmMedioEntreCambios, 15000);
    expect(patron.diasMedioEntreCambios, 365);
  });

  test('con tres registros promedia los dos intervalos', () {
    // 2024-01-01 a 2025-01-01: 366 días (2024 es bisiesto), 15.000 km.
    // 2025-01-01 a 2026-01-01: 365 días, 14.000 km.
    // Media: (15000+14000)/2 = 14500 km; (366+365)/2 = 365,5 días.
    final patron = calcularPatronReal([
      (fecha: DateTime(2024, 1, 1), km: 60000),
      (fecha: DateTime(2025, 1, 1), km: 75000),
      (fecha: DateTime(2026, 1, 1), km: 89000),
    ]);

    expect(patron!.kmMedioEntreCambios, 14500);
    expect(patron.diasMedioEntreCambios, 365.5);
  });

  test('el orden de la lista de entrada no importa', () {
    final ordenNatural = calcularPatronReal([
      (fecha: DateTime(2025, 1, 1), km: 80000),
      (fecha: DateTime(2026, 1, 1), km: 95000),
    ]);
    final ordenInvertido = calcularPatronReal([
      (fecha: DateTime(2026, 1, 1), km: 95000),
      (fecha: DateTime(2025, 1, 1), km: 80000),
    ]);

    expect(
      ordenInvertido!.kmMedioEntreCambios,
      ordenNatural!.kmMedioEntreCambios,
    );
    expect(
      ordenInvertido.diasMedioEntreCambios,
      ordenNatural.diasMedioEntreCambios,
    );
  });
}
```

- [ ] **Paso 2: Ejecutar el test para verificar que falla**

```powershell
flutter test test/domain/patron_real_uso_test.dart --reporter=failures-only
```

Esperado: FALLA porque el fichero no existe.

- [ ] **Paso 3: Escribir la implementación**

`lib/domain/patron_real_uso.dart`:

```dart
import 'maintenance_due.dart' show diasNaturalesEntre;

/// Patrón real de uso de un mantenimiento: la media de kilómetros y de
/// días que el usuario deja pasar entre un cambio y el siguiente, a partir
/// de lo que la app ha presenciado de verdad. Nunca cambia el intervalo
/// configurado: es solo información para quien lo lea.
class PatronRealUso {
  final double kmMedioEntreCambios;
  final double diasMedioEntreCambios;

  const PatronRealUso({
    required this.kmMedioEntreCambios,
    required this.diasMedioEntreCambios,
  });
}

/// Calcula el patrón real a partir de los registros reales (no sembrados)
/// de un mantenimiento, en cualquier orden.
///
/// Nulo si hay menos de dos registros: con uno solo no hay ningún
/// intervalo que medir todavía.
PatronRealUso? calcularPatronReal(
  List<({DateTime fecha, int km})> registrosReales,
) {
  if (registrosReales.length < 2) return null;

  final ordenados = [...registrosReales]
    ..sort((a, b) => a.fecha.compareTo(b.fecha));

  var sumaKm = 0;
  var sumaDias = 0;
  for (var i = 1; i < ordenados.length; i++) {
    sumaKm += ordenados[i].km - ordenados[i - 1].km;
    sumaDias += diasNaturalesEntre(ordenados[i - 1].fecha, ordenados[i].fecha);
  }

  final intervalos = ordenados.length - 1;
  return PatronRealUso(
    kmMedioEntreCambios: sumaKm / intervalos,
    diasMedioEntreCambios: sumaDias / intervalos,
  );
}
```

Usa `diasNaturalesEntre` en vez de `DateTime.difference(...).inDays` a propósito: es la misma función que ya evita el error de un día en los cambios de hora que se encontró y corrigió en la fase 2. Repetir `difference().inDays` aquí reintroduciría ese mismo fallo.

- [ ] **Paso 4: Ejecutar el test para verificar que pasa**

```powershell
flutter test test/domain/patron_real_uso_test.dart --reporter=failures-only
```

Esperado: `All tests passed!`

Si el caso de tres registros falla, revisa primero si 2024 se está contando como bisiesto (366 días) antes de tocar la implementación: el valor esperado ya lo tiene en cuenta.

- [ ] **Paso 5: Comprobar que el dominio sigue limpio**

```bash
grep -E "package:(drift|flutter)/" lib/domain/patron_real_uso.dart
```

Esperado: sin salida.

- [ ] **Paso 6: Commit**

```bash
git add -A && git commit -q -m "Añadir el cálculo del patrón real de uso"
```

---

## Tarea 4: Fuente del intervalo y migración v4→v5

La tarea más delicada de la fase: toca una trampa ya documentada en `CLAUDE.md` bajo el título "Trampa conocida: `m.createTable()` usa siempre la definición actual de la tabla". Léela antes de empezar.

**Ficheros:**
- Crear: `lib/domain/fuente_intervalo.dart`
- Modificar: `lib/data/tables/maintenance_schedules.dart`, `lib/data/database.dart`
- Test: `test/data/database_migration_test.dart` (ampliar)

**Interfaces:**
- Produce: enum `FuenteIntervalo { orientativo, fabricante, usuario }`; mapa `etiquetasFuenteIntervalo`; columna `MaintenanceSchedules.fuenteIntervalo`; `schemaVersion` 5.

- [ ] **Paso 1: Escribir el enum**

`lib/domain/fuente_intervalo.dart`:

```dart
/// De dónde sale el intervalo configurado para un mantenimiento.
///
/// El valor por defecto y, hoy, el único alcanzable es `orientativo`:
/// hasta que exista un catálogo de piezas que aporte intervalos oficiales
/// por vehículo, ningún mantenimiento puede tener una fuente distinta. La
/// columna se añade ya para no tener que migrar otra vez cuando llegue ese
/// momento.
///
/// El nombre del enum y el de sus valores forman parte del formato en el
/// que Drift guarda la columna `fuenteIntervalo` de `MaintenanceSchedules`,
/// vía `textEnum`: se serializan como texto por nombre. No se pueden
/// renombrar sin romper los datos ya guardados en el dispositivo del
/// usuario.
enum FuenteIntervalo { orientativo, fabricante, usuario }

const Map<FuenteIntervalo, String> etiquetasFuenteIntervalo = {
  FuenteIntervalo.orientativo:
      'Intervalo orientativo: consulta el manual para confirmarlo.',
  FuenteIntervalo.fabricante: 'Según el intervalo oficial de tu vehículo.',
  FuenteIntervalo.usuario: 'Intervalo que has ajustado tú.',
};
```

- [ ] **Paso 2: Añadir la columna a la tabla**

En `lib/data/tables/maintenance_schedules.dart`, añade el import y el export junto a los que ya hay para `MaintenanceCategory`:

```dart
import '../../domain/fuente_intervalo.dart';
```

```dart
export '../../domain/fuente_intervalo.dart';
```

Añade la columna al final de la clase, antes del cierre:

```dart
  /// Ver `FuenteIntervalo`. Todo mantenimiento tiene una fuente, incluso
  /// los que no la eligieron explícitamente: por defecto es orientativo.
  TextColumn get fuenteIntervalo =>
      textEnum<FuenteIntervalo>().withDefault(const Constant('orientativo'))();
```

- [ ] **Paso 3: Escribir la migración, con la guarda correcta**

En `lib/data/database.dart`, sube `schemaVersion` a 5:

```dart
  int get schemaVersion => 5;
```

Añade el paso de migración **después** del paso `from < 4` ya existente, sin tocarlo:

```dart
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
```

- [ ] **Paso 4: Escribir el test de migración v4→v5 (el caso real)**

Añade este test a `test/data/database_migration_test.dart`, dentro del mismo `main()` que ya contiene los anteriores. Reutiliza los imports ya presentes en el fichero (`dart:io`, `package:car_care/data/database.dart`, `package:drift/drift.dart` con `show Value`, `package:drift/native.dart`, `package:flutter_test/flutter_test.dart`, `package:path/path.dart as p`, `package:sqlite3/sqlite3.dart as sqlite3`).

```dart
  test(
    'migrar de v4 a v5 conserva los mantenimientos y añade la fuente '
    'orientativa por defecto',
    () async {
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

      final version = await db
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.data['user_version'], 5);

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
    },
  );
```

- [ ] **Paso 5: Escribir el test de migración v2→v5 (el caso de la trampa)**

Este es el que de verdad demuestra que la guarda está bien puesta. Añádelo justo después del anterior:

```dart
  test(
    'saltar de v2 a v5 de un tiro no falla por columna duplicada',
    () async {
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

      final version = await db
          .customSelect('PRAGMA user_version')
          .getSingle();
      expect(version.data['user_version'], 5);

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
    },
  );
```

Añade al fichero el import de `package:car_care/domain/fuente_intervalo.dart` si `FuenteIntervalo` no llega ya reexportado por otro import existente.

- [ ] **Paso 6: Ejecutar los tests para verificar que fallan**

```powershell
flutter test test/data/database_migration_test.dart --reporter=failures-only
```

Esperado: FALLAN porque el código generado por Drift todavía no conoce la columna nueva.

- [ ] **Paso 7: Regenerar el código de Drift**

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Esperado: `Succeeded after ...`

- [ ] **Paso 8: Ejecutar los tests para verificar que pasan**

```powershell
flutter test --reporter=failures-only
```

Esperado: `All tests passed!`

Si el test del paso 5 falla con `duplicate column name`, la guarda del paso 3 está mal puesta: revísala contra la explicación del comentario, no la cambies a ciegas.

- [ ] **Paso 9: Commit**

```bash
git add -A && git commit -q -m "Añadir la fuente del intervalo de cada mantenimiento"
```

---

## Tarea 5: Distintivo de origen en la ficha del vehículo

Describe comportamiento, no dicta código — mismo criterio que las tareas de interfaz de las fases 2 y 3.

**Ficheros:**
- Crear: `lib/ui/common/origen_chip.dart`
- Modificar: `lib/ui/vehicle/vehicle_detail_screen.dart`

**Interfaces:**
- Consume: `OrigenMantenimiento`, `calcularOrigen` de la Tarea 2.
- Produce: `OrigenChip({required OrigenMantenimiento origen})`.

**El patrón a seguir**: lee `lib/ui/common/estado_chip.dart` antes de escribir nada. Tu widget es su hermano, con una diferencia deliberada de intención: `EstadoChip` usa color para comunicar el estado de vencimiento, que es el eje de color que esta aplicación ya tiene reservado. `OrigenChip` comunica un eje distinto —cuánto se puede confiar en el dato—, y no debe competir visualmente con el primero. En vez de una paleta de color propia, usa un icono distinto por estado (por ejemplo, uno de verificación para confirmado, uno de historial para histórico, uno de interrogación para desconocido) sobre un tono neutro (`colorScheme.outline`), y deja que el icono y el texto comuniquen la diferencia, no el color.

**Los tres estados y su texto:**
- `confirmado`: "Confirmado".
- `historico`: "Histórico".
- `desconocido`: "Desconocido". Este es el único que necesita algo más que una etiqueta: envuélvelo en un `Tooltip` con el texto "Si no sabes cuándo se hizo, consulta la documentación o la factura antes de asumir que está realizado." — es la advertencia explícita que pide el diseño, para que "desconocido" no se lea como un simple estado neutro más.

**Dónde se muestra**: en `_FilaMantenimiento` y en `_TarjetaDestacada` de `vehicle_detail_screen.dart`, junto al `EstadoChip` que ya existe en cada una. Calcula el origen con `calcularOrigen(item.ultimoRegistro?.esSembrado)` — `item` es el `MantenimientoConVencimiento` que ambos widgets ya reciben.

- [ ] **Paso 1: Escribir `OrigenChip`**

- [ ] **Paso 2: Añadirlo junto a `EstadoChip` en `_FilaMantenimiento` y `_TarjetaDestacada`**

- [ ] **Paso 3: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando.

- [ ] **Paso 4: Commit**

```bash
git add -A && git commit -q -m "Mostrar el origen del dato de cada mantenimiento"
```

---

## Tarea 6: Agrupar mantenimientos próximos en la ficha del vehículo

Describe comportamiento, no dicta código.

**Ficheros:**
- Modificar: `lib/ui/vehicle/vehicle_detail_screen.dart`

**Interfaces:**
- Consume: `agruparPorProximidad`, `MaintenanceGroupingPolicy` de la Tarea 1.

**Qué construir**: en `_ContenidoMantenimientos`, donde hoy se recorre `for (final item in lista)` pintando cada `_FilaMantenimiento` suelta, calcula los grupos con `agruparPorProximidad(lista.map((m) => m.vencimiento).toList(), const MaintenanceGroupingPolicy())`. Para cada grupo con más de un elemento, presenta esas filas de forma visualmente conectada —por ejemplo, envueltas en una única tarjeta compartida con un texto de cabecera como "Puedes hacer esto junto y ahorrar una visita al taller", en vez de tarjetas sueltas idénticas a las demás—. Los grupos de un solo elemento se pintan exactamente como hoy, sin ningún cambio.

La decisión visual concreta —tarjeta compartida, separador, o cualquier otra— queda a tu criterio; lo que no es negociable es que el mensaje deje claro que esos mantenimientos concretos conviene hacerlos en la misma visita, y que un mantenimiento sin ningún vecino cercano no muestre ningún mensaje de agrupación.

- [ ] **Paso 1: Implementar la agrupación visual**

- [ ] **Paso 2: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando.

- [ ] **Paso 3: Commit**

```bash
git add -A && git commit -q -m "Agrupar los mantenimientos próximos que conviene hacer juntos"
```

---

## Tarea 7: Patrón real de uso en la ficha del vehículo

**Ficheros:**
- Modificar: `lib/data/daos/maintenance_dao.dart`, `lib/providers/mantenimiento_providers.dart`, `lib/ui/vehicle/vehicle_detail_screen.dart`
- Test: `test/data/maintenance_dao_test.dart` (ampliar)

**Interfaces:**
- Consume: `calcularPatronReal`, `PatronRealUso` de la Tarea 3.
- Produce: `MaintenanceDao.registrosRealesDe(int scheduleId)` (`Future<List<MaintenanceRecord>>`); `patronRealProvider` (`FutureProvider.family<PatronRealUso?, int>`, por `scheduleId`).

**Parte de datos — código completo**

En `lib/data/daos/maintenance_dao.dart`, añade este método a la clase, junto a `ultimoRecordDe`:

```dart
  /// Registros reales (no sembrados) de un mantenimiento, ordenados por
  /// fecha ascendente. Es la base del patrón real de uso: solo cuenta lo
  /// que la app ha presenciado de verdad.
  Future<List<MaintenanceRecord>> registrosRealesDe(int scheduleId) {
    return (select(maintenanceRecords)
          ..where(
            (r) => r.scheduleId.equals(scheduleId) & r.esSembrado.equals(false),
          )
          ..orderBy([(r) => OrderingTerm(expression: r.fecha)]))
        .get();
  }
```

Añade este test a `test/data/maintenance_dao_test.dart`, siguiendo el patrón de los tests ya existentes en ese fichero (base en memoria, un vehículo creado en el `setUp`):

```dart
  test('registrosRealesDe excluye los sembrados y ordena por fecha', () async {
    final id = await crearSchedule();
    await db.maintenanceDao.insertarRecord(
      MaintenanceRecordsCompanion.insert(
        vehicleId: vehicleId,
        scheduleId: Value(id),
        fecha: DateTime(2026, 1, 1),
        km: 90000,
        esSembrado: const Value(true),
      ),
    );
    await db.maintenanceDao.insertarRecord(
      MaintenanceRecordsCompanion.insert(
        vehicleId: vehicleId,
        scheduleId: Value(id),
        fecha: DateTime(2025, 1, 1),
        km: 75000,
      ),
    );
    await db.maintenanceDao.insertarRecord(
      MaintenanceRecordsCompanion.insert(
        vehicleId: vehicleId,
        scheduleId: Value(id),
        fecha: DateTime(2024, 1, 1),
        km: 60000,
      ),
    );

    final reales = await db.maintenanceDao.registrosRealesDe(id);

    expect(reales, hasLength(2));
    expect(reales.map((r) => r.km), [60000, 75000]);
  });
```

Usa el mismo helper `crearSchedule()` que ya define el fichero para las pruebas anteriores del DAO. Si el helper `crearRecord` existente en ese fichero no admite `esSembrado`, no lo modifiques: usa `db.maintenanceDao.insertarRecord(...)` directamente como en el ejemplo de arriba.

Ejecuta y verifica antes de seguir:

```powershell
flutter test test/data/maintenance_dao_test.dart --reporter=failures-only
```

Esperado: `All tests passed!`

**Parte de provider — código completo**

En `lib/providers/mantenimiento_providers.dart`, añade el import:

```dart
import '../domain/patron_real_uso.dart';
```

Y el provider, junto a `schedulesProvider`:

```dart
/// Patrón real de uso de un mantenimiento concreto. Nulo si hay menos de
/// dos registros reales: no hay patrón que mostrar todavía. No depende de
/// la fecha de hoy, así que no hace falta recalcularlo al volver a primer
/// plano.
final patronRealProvider = FutureProvider.family<PatronRealUso?, int>((
  ref,
  scheduleId,
) async {
  final registros = await ref
      .watch(databaseProvider)
      .maintenanceDao
      .registrosRealesDe(scheduleId);
  return calcularPatronReal(
    registros.map((r) => (fecha: r.fecha, km: r.km)).toList(),
  );
});
```

**Parte de interfaz — describe comportamiento**

En `_FilaMantenimiento` de `vehicle_detail_screen.dart`, observa `patronRealProvider(item.schedule.id)`. Cuando tenga datos y no sea nulo, añade una línea adicional discreta bajo el resumen del vencimiento que ya se muestra, del estilo "Tu patrón habitual: cambias cada ≈ [X] km" — usa `formatearKm` para la cifra, redondeando `kmMedioEntreCambios` al entero más cercano. Mientras carga o si es nulo (sin patrón todavía), no muestres nada en ese hueco: no es un error, es la ausencia normal de un dato que requiere historial.

- [ ] **Paso 1: Añadir `registrosRealesDe` y su test**

- [ ] **Paso 2: Añadir `patronRealProvider`**

- [ ] **Paso 3: Mostrar el patrón real en `_FilaMantenimiento`**

- [ ] **Paso 4: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y todos los tests pasando.

- [ ] **Paso 5: Commit**

```bash
git add -A && git commit -q -m "Mostrar el patrón real de uso de cada mantenimiento"
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
git add -A && git commit -q -m "Cerrar la fase 4: motor de recomendaciones" --allow-empty
```

---

## Qué queda para después

La Fase 5 (decidir la fuente del catálogo de piezas) y las siguientes están descritas en `docs/superpowers/specs/2026-08-12-roadmap-identidad-tecnica-catalogo-piezas.md`, sin plan de implementación todavía.
