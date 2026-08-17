# Notificaciones — Plan de implementación

> **Para agentes ejecutores:** SUB-SKILL OBLIGATORIA: usa `superpowers:subagent-driven-development` (recomendada) o `superpowers:executing-plans` para implementar este plan tarea a tarea. Los pasos usan casillas (`- [ ]`) para el seguimiento.

**Objetivo:** que el móvil avise de un mantenimiento antes de que se pase, sin necesidad de abrir la aplicación — completando la primera de las cuatro metas del diseño original.

**Arquitectura:** una función de dominio pura que convierte los vencimientos de un coche en una lista de avisos con fecha; un servicio con interfaz propia que envuelve el plugin de notificaciones (para que la lógica sea testeable sin el plugin nativo); y un provider que los une y reprograma todo cuando cambian los datos.

**Tech Stack:** Flutter, Drift (SQLite), Riverpod, `flutter_local_notifications`, `timezone`.

**Spec de referencia:** `docs/superpowers/specs/2026-08-15-gastos-y-notificaciones-design.md`, sección 4. Ante cualquier duda de diseño no cubierta aquí, es la fuente de verdad.

## Global Constraints

- Plataforma única: Android. `minSdkVersion` 24.
- Toda la interfaz y los textos de las notificaciones, en español.
- `lib/domain/` no puede importar `package:drift/...` ni `package:flutter/...`.
- **Sin cambios en el esquema de la base de datos.** `schemaVersion` se queda en 6 y no se toca `lib/data/`. Todo lo que hace falta (`Settings.diasRecordatorioLectura`, `MaintenanceSchedules.silenciado`) ya existe.
- **La aplicación sigue sin permiso de `INTERNET`.** El único permiso nuevo es `POST_NOTIFICATIONS`. Si alguien se ve añadiendo `INTERNET` al manifiesto, ha entendido algo mal.
- **Dos dependencias nuevas, y solo dos**: `flutter_local_notifications` y `timezone`. Ninguna más — en particular, **no añadas `flutter_timezone`**: la Tarea 2 explica cómo se resuelve la hora local sin ella.
- Mensajes de commit en español, sin coautoría ni menciones a herramientas.
- El proyecto usa el formateador estándar de Dart (`dart format`, "tall style", 80 columnas) desde el commit `a8e4470`. Ejecuta `dart format` solo sobre ficheros que crees tú desde cero, nunca sobre ficheros existentes completos.
- **Entorno**: el toolchain no está en el PATH y la carpeta temporal debe redirigirse o Gradle no arranca. Antepón a cada comando de PowerShell:
  `$env:Path = "F:\dev\flutter\bin;F:\dev\android-sdk\platform-tools;$env:Path"; $env:JAVA_HOME = 'C:\Program Files\Eclipse Adoptium\jdk-17.0.20.8-hotspot'; $env:ANDROID_HOME = 'F:\dev\android-sdk'; $env:TMP = 'F:\dev\tmp'; $env:TEMP = 'F:\dev\tmp'`
- Punto de partida: rama `gastos-y-notificaciones`, `flutter analyze` limpio, 146 tests pasando.

## Decisiones de diseño ya cerradas (no reabrir)

De la spec, sección 4:

- **Dos disparos por mantenimiento**: al entrar en el margen de aviso configurado (estado `atencion`) y al vencer.
- **Una notificación por coche y por día**, no una por mantenimiento. Si varias transiciones caen el mismo día natural, se funden en una sola.
- **Los mantenimientos con `silenciado == true` no generan notificación**, aunque su estado se siga calculando. Los que tienen `activo == false`, tampoco.
- **Lo que ya está vencido no genera notificación.** Solo se programan fechas futuras: una alarma en el pasado no existe, y repetir lo que la ficha ya muestra en rojo no aporta nada.
- **Horizonte de programación: un año.**
- **Hora de entrega: las 9:00**, fija, sin ajuste en la interfaz.
- **Se cancela todo y se reprograma desde cero** en cada recálculo, en lugar de llevar la cuenta de qué notificación corresponde a qué mantenimiento. Evita avisos huérfanos de mantenimientos borrados y duplicados tras editar un intervalo.
- **Si el usuario deniega el permiso, la aplicación funciona exactamente igual que hoy**: calcula y muestra los vencimientos, simplemente no avisa. Nunca se bloquea ni se insiste.
- **Nada de alarmas exactas** (`SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`): exigen permiso especial y justificación ante Google Play, y un aviso de mantenimiento no necesita precisión de minutos.

## La hora local sin una tercera dependencia

`flutter_local_notifications` programa con `zonedSchedule`, que exige un `TZDateTime` del paquete `timezone`. Ese paquete no sabe por sí solo en qué zona está el dispositivo: la vía habitual es añadir `flutter_timezone` para preguntárselo al sistema.

**Aquí no se hace así.** Se inicializa `timezone` con UTC y se convierte a mano: para programar las 9:00 locales de un día dado, se construye ese instante como `DateTime` local y se pasa a UTC con `.toUtc()`, que ya aplica el desfase que el dispositivo tenga en ese momento.

El precio, asumido y documentado: una notificación programada meses antes de un cambio de horario estacional llegará con una hora de diferencia (a las 8:00 o a las 10:00 en vez de a las 9:00), porque el desfase se calcula con el vigente al programar, no con el que habrá ese día. Para un aviso de mantenimiento de coche es irrelevante, y ahorra una dependencia entera. Como además todo se reprograma cada vez que se abre la aplicación, en la práctica el desfase se corrige solo.

## Estructura de ficheros

| Fichero | Responsabilidad |
|---|---|
| `lib/domain/avisos.dart` | `DatosAviso`, `AvisoProgramado`, `calcularAvisos` — cálculo puro |
| `lib/services/notificaciones.dart` | `ServicioNotificaciones` (interfaz) y `NotificacionesLocales` (implementación sobre el plugin) |
| `lib/providers/notificaciones_providers.dart` | `servicioNotificacionesProvider`, `reprogramarAvisos` |
| `lib/ui/shell/app_shell.dart` | Pide el permiso la primera vez y dispara la reprogramación |
| `lib/providers/recalculo_al_reanudar.dart` | Reprograma también al volver a primer plano |
| `pubspec.yaml` | Dos dependencias nuevas |
| `android/app/src/main/AndroidManifest.xml` | Permiso `POST_NOTIFICATIONS` |
| `test/domain/avisos_test.dart` | Tests del cálculo |
| `test/providers/notificaciones_providers_test.dart` | Test de la reprogramación con un servicio falso |

---

## Tarea 1: Cálculo de avisos

Lógica de dominio pura. Es el corazón de la fase y la única parte con aritmética delicada.

**Ficheros:**
- Crear: `lib/domain/avisos.dart`
- Test: `test/domain/avisos_test.dart`

**Interfaces:**
- Consume: nada (recibe primitivas, para no depender de Drift).
- Produce: `class DatosAviso`, `class AvisoProgramado`, función `List<AvisoProgramado> calcularAvisos({...})`.

**El modelo, y por qué así.** El dominio no recibe mantenimientos de Drift ni `Vencimiento` completos: recibe lo mínimo para decidir cuándo avisar. Quien llama (el provider, Tarea 3) ya ha filtrado los mantenimientos inactivos y silenciados, y ha sacado las dos fechas de vencimiento del motor que ya existe.

**Cómo se calcula la fecha de entrada en "atención".** Un mantenimiento puede vencer por dos vías a la vez, y pasa a `atencion` en cuanto **cualquiera** de las dos entra en su margen. Así que:

- Por tiempo: `proximaFecha` menos `margenDias` días.
- Por kilómetros: `fechaEstimadaPorKm` menos los días que se tarda en recorrer `margenKm` al ritmo actual, es decir `margenKm / kmPorDia` días.
- La fecha de atención efectiva es **la más temprana** de las dos que existan.

Y el vencimiento efectivo es la más temprana entre `proximaFecha` y `fechaEstimadaPorKm`.

- [ ] **Paso 1: Escribir el test que falla**

Crea `test/domain/avisos_test.dart`:

```dart
import 'package:car_care/domain/avisos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ahora = DateTime(2026, 1, 1);
  final horizonte = DateTime(2027, 1, 1);

  List<AvisoProgramado> calcular(List<DatosAviso> datos, {double kmPorDia = 50}) {
    return calcularAvisos(
      mantenimientos: datos,
      kmPorDia: kmPorDia,
      ahora: ahora,
      horizonte: horizonte,
    );
  }

  test('sin mantenimientos no hay avisos', () {
    expect(calcular([]), isEmpty);
  });

  test('un mantenimiento por fecha genera aviso de atención y de '
      'vencimiento', () {
    // Vence el 1 de marzo, con 30 días de margen: atención el 31 de enero.
    final avisos = calcular([
      DatosAviso(
        nombre: 'Líquido de frenos',
        proximaFecha: DateTime(2026, 3, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
    ]);

    expect(avisos, hasLength(2));
    expect(avisos.first.fecha, DateTime(2026, 1, 31));
    expect(avisos.first.nombres, ['Líquido de frenos']);
    expect(avisos.last.fecha, DateTime(2026, 3, 1));
  });

  test('los avisos salen ordenados por fecha', () {
    final avisos = calcular([
      DatosAviso(
        nombre: 'Tardío',
        proximaFecha: DateTime(2026, 6, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
      DatosAviso(
        nombre: 'Temprano',
        proximaFecha: DateTime(2026, 3, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
    ]);

    final fechas = avisos.map((a) => a.fecha).toList();
    final ordenadas = [...fechas]..sort();
    expect(fechas, ordenadas);
  });

  test('dos mantenimientos que caen el mismo día se funden en un aviso', () {
    final avisos = calcular([
      DatosAviso(
        nombre: 'Aceite',
        proximaFecha: DateTime(2026, 3, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
      DatosAviso(
        nombre: 'Filtro de aire',
        proximaFecha: DateTime(2026, 3, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
    ]);

    // Dos fechas distintas (atención y vencimiento), no cuatro avisos.
    expect(avisos, hasLength(2));
    expect(avisos.first.nombres, ['Aceite', 'Filtro de aire']);
    expect(avisos.last.nombres, ['Aceite', 'Filtro de aire']);
  });

  test('lo que ya venció no genera aviso', () {
    final avisos = calcular([
      DatosAviso(
        nombre: 'Vencido hace tiempo',
        proximaFecha: DateTime(2025, 6, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
    ]);

    expect(avisos, isEmpty);
  });

  test('un mantenimiento ya en atención solo avisa de su vencimiento', () {
    // Vence en 10 días y el margen es de 30: la fecha de atención ya pasó.
    final avisos = calcular([
      DatosAviso(
        nombre: 'Ya en atención',
        proximaFecha: DateTime(2026, 1, 11),
        margenKm: 1000,
        margenDias: 30,
      ),
    ]);

    expect(avisos, hasLength(1));
    expect(avisos.single.fecha, DateTime(2026, 1, 11));
  });

  test('nada más allá del horizonte', () {
    final avisos = calcular([
      DatosAviso(
        nombre: 'Muy lejano',
        proximaFecha: DateTime(2028, 1, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
    ]);

    expect(avisos, isEmpty);
  });

  test('por kilómetros, el margen se traduce a días con el ritmo de uso', () {
    // Alcanza los km el 1 de marzo (59 días). Con 1.000 km de margen a
    // 50 km/día, entra en atención 20 días antes: el 9 de febrero.
    final avisos = calcular([
      DatosAviso(
        nombre: 'Pastillas',
        fechaEstimadaPorKm: DateTime(2026, 3, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
    ]);

    expect(avisos, hasLength(2));
    expect(avisos.first.fecha, DateTime(2026, 2, 9));
    expect(avisos.last.fecha, DateTime(2026, 3, 1));
  });

  test('con las dos vías gana la que llega antes', () {
    // Por fecha vencería el 1 de junio; por km, el 1 de marzo.
    final avisos = calcular([
      DatosAviso(
        nombre: 'Aceite y filtro',
        proximaFecha: DateTime(2026, 6, 1),
        fechaEstimadaPorKm: DateTime(2026, 3, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
    ]);

    expect(avisos.last.fecha, DateTime(2026, 3, 1));
  });

  test('con el coche parado, un mantenimiento solo por km no avisa', () {
    // Sin fechaEstimadaPorKm no hay ninguna fecha con la que programar.
    final avisos = calcular([
      const DatosAviso(nombre: 'Solo km', margenKm: 1000, margenDias: 30),
    ]);

    expect(avisos, isEmpty);
  });

  test('con ritmo cero no se divide por cero al traducir el margen de km', () {
    final avisos = calcular([
      DatosAviso(
        nombre: 'Pastillas',
        fechaEstimadaPorKm: DateTime(2026, 3, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
    ], kmPorDia: 0);

    // El vencimiento sigue siendo programable aunque el margen por km no se
    // pueda traducir a días.
    expect(avisos.map((a) => a.fecha), contains(DateTime(2026, 3, 1)));
    expect(avisos.every((a) => a.fecha.isAfter(ahora)), isTrue);
  });
}
```

- [ ] **Paso 2: Ejecutar el test y comprobar que falla**

```powershell
flutter test test/domain/avisos_test.dart --reporter=failures-only
```

Esperado: falla al compilar, porque `lib/domain/avisos.dart` todavía no existe.

- [ ] **Paso 3: Escribir la implementación**

Crea `lib/domain/avisos.dart`:

```dart
/// Lo que el cálculo de avisos necesita saber de un mantenimiento. No es una
/// fila de Drift ni un [Vencimiento] entero: solo las dos fechas en que puede
/// vencer y los márgenes con los que avisar, para que el dominio no dependa
/// de la capa de datos.
///
/// Quien construye estos datos (el provider) ya ha descartado los
/// mantenimientos inactivos y los silenciados.
class DatosAviso {
  final String nombre;

  /// Cuándo vence por tiempo. Nula si el mantenimiento no va por fecha.
  final DateTime? proximaFecha;

  /// Cuándo se alcanzarán sus kilómetros al ritmo actual. Nula si no va por
  /// kilómetros, o si el coche está parado y no se alcanzarían nunca.
  final DateTime? fechaEstimadaPorKm;

  final int margenKm;
  final int margenDias;

  const DatosAviso({
    required this.nombre,
    required this.margenKm,
    required this.margenDias,
    this.proximaFecha,
    this.fechaEstimadaPorKm,
  });
}

/// Una notificación a programar: un día concreto y los mantenimientos que la
/// motivan. Varios mantenimientos que caen el mismo día comparten aviso, para
/// no disparar una ráfaga de notificaciones que se acabe ignorando.
class AvisoProgramado {
  final DateTime fecha;
  final List<String> nombres;

  const AvisoProgramado({required this.fecha, required this.nombres});
}

/// Convierte los vencimientos de un vehículo en la lista de avisos a
/// programar, ordenada por fecha.
///
/// Cada mantenimiento puede generar hasta dos: uno al entrar en su margen de
/// aviso y otro al vencer. Solo se devuelven fechas futuras dentro del
/// [horizonte]: una alarma en el pasado no existe, y lo que ya venció se ve
/// en la ficha del vehículo sin necesidad de notificarlo.
List<AvisoProgramado> calcularAvisos({
  required List<DatosAviso> mantenimientos,
  required double kmPorDia,
  required DateTime ahora,
  required DateTime horizonte,
}) {
  final porDia = <DateTime, List<String>>{};

  void anotar(DateTime? fecha, String nombre) {
    if (fecha == null) return;
    final dia = DateTime(fecha.year, fecha.month, fecha.day);
    if (!dia.isAfter(ahora) || dia.isAfter(horizonte)) return;
    porDia.putIfAbsent(dia, () => []).add(nombre);
  }

  for (final m in mantenimientos) {
    // El vencimiento efectivo es el que llegue antes de las dos vías.
    final vencimiento = _laMasTemprana(m.proximaFecha, m.fechaEstimadaPorKm);

    // Cada vía entra en su margen por su cuenta, y el mantenimiento pasa a
    // "atención" en cuanto lo hace cualquiera de las dos.
    final atencionPorFecha = m.proximaFecha == null
        ? null
        : m.proximaFecha!.subtract(Duration(days: m.margenDias));
    // Con el coche parado no se puede traducir un margen de kilómetros a
    // días, así que esa vía no aporta fecha de atención.
    final atencionPorKm = (m.fechaEstimadaPorKm == null || kmPorDia <= 0)
        ? null
        : m.fechaEstimadaPorKm!.subtract(
            Duration(days: (m.margenKm / kmPorDia).round()),
          );

    anotar(_laMasTemprana(atencionPorFecha, atencionPorKm), m.nombre);
    anotar(vencimiento, m.nombre);
  }

  final dias = porDia.keys.toList()..sort();

  return [
    for (final dia in dias) AvisoProgramado(fecha: dia, nombres: porDia[dia]!),
  ];
}

DateTime? _laMasTemprana(DateTime? a, DateTime? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a.isBefore(b) ? a : b;
}
```

- [ ] **Paso 4: Ejecutar el test y comprobar que pasa**

```powershell
flutter test test/domain/avisos_test.dart --reporter=failures-only
```

Esperado: `+11: All tests passed!`

Si algún caso falla, **no ajustes el test para que pase**: comprueba primero cuál de los dos tiene razón. Los comentarios de cada test explican la aritmética esperada; si la implementación no coincide, casi siempre es la implementación la que está mal.

- [ ] **Paso 5: Verificar el proyecto completo**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y `+157: All tests passed!` (146 previos + 11 nuevos).

- [ ] **Paso 6: Commit**

```bash
git add lib/domain/avisos.dart test/domain/avisos_test.dart
git commit -q -m "Añadir el cálculo de avisos de mantenimiento"
```

---

## Tarea 2: Dependencias, permiso y servicio de notificaciones

La capa que toca el plugin nativo. Se aísla tras una interfaz para que la Tarea 3 sea testeable sin él.

**Ficheros:**
- Modificar: `pubspec.yaml`
- Modificar: `android/app/src/main/AndroidManifest.xml`
- Crear: `lib/services/notificaciones.dart`

**Interfaces:**
- Consume: `AvisoProgramado` (Tarea 1).
- Produce: `abstract class ServicioNotificaciones` con tres métodos (`inicializar`, `pedirPermiso`, `programarAvisos`), y `class NotificacionesLocales implements ServicioNotificaciones`.

- [ ] **Paso 1: Añadir las dos dependencias**

```powershell
flutter pub add flutter_local_notifications timezone
```

Comprueba después que `pubspec.yaml` solo ha ganado esas dos líneas y que `flutter pub get` termina sin errores. **No añadas `flutter_timezone`** (ver la sección "La hora local sin una tercera dependencia" del plan; si no la has leído, léela ahora, porque explica la decisión que gobierna todo este fichero).

- [ ] **Paso 2: Añadir el permiso al manifiesto**

En `android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>` y **fuera** de `<application>`, junto al bloque `<queries>` que ya existe:

```xml
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

Ese es el **único** permiso que se añade. No añadas `INTERNET`, ni `SCHEDULE_EXACT_ALARM`, ni `USE_EXACT_ALARM`, ni `RECEIVE_BOOT_COMPLETED`.

- [ ] **Paso 3: Escribir el servicio**

Crea `lib/services/notificaciones.dart`:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/avisos.dart';

/// Hora del día a la que se entregan los avisos.
const int kHoraDeAviso = 9;

/// La puerta de salida a las notificaciones del sistema.
///
/// Existe como interfaz, y no como llamadas sueltas al plugin, para que la
/// lógica de reprogramación se pueda probar con una implementación falsa: el
/// plugin real necesita el lado nativo de Android y no funciona en un test
/// de Dart.
abstract class ServicioNotificaciones {
  Future<void> inicializar();

  /// Pide el permiso al usuario si hace falta. Devuelve si se concedió.
  /// Nunca insiste ni bloquea: si dice que no, la aplicación sigue igual.
  Future<bool> pedirPermiso();

  /// Cancela todo lo programado y programa estos avisos desde cero.
  Future<void> programarAvisos(List<AvisoDeVehiculo> avisos);
}

/// Un aviso ya listo para programar: qué coche, qué día y qué decir.
class AvisoDeVehiculo {
  final String nombreVehiculo;
  final AvisoProgramado aviso;

  const AvisoDeVehiculo({required this.nombreVehiculo, required this.aviso});
}

/// Implementación real sobre `flutter_local_notifications`.
class NotificacionesLocales implements ServicioNotificaciones {
  final _plugin = FlutterLocalNotificationsPlugin();

  static const _detalles = NotificationDetails(
    android: AndroidNotificationDetails(
      'mantenimientos',
      'Mantenimientos',
      channelDescription: 'Avisos de mantenimientos próximos y vencidos',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
  );

  @override
  Future<void> inicializar() async {
    // Se inicializa la base de datos de zonas horarias pero se deja la zona
    // local en UTC a propósito: la conversión a hora local la hace
    // _instanteDeEntrega con el desfase del dispositivo, y así no hace falta
    // una dependencia más solo para averiguar el nombre de la zona.
    tz_data.initializeTimeZones();

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  @override
  Future<bool> pedirPermiso() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return false;
    return await android.requestNotificationsPermission() ?? false;
  }

  @override
  Future<void> programarAvisos(List<AvisoDeVehiculo> avisos) async {
    await _plugin.cancelAll();

    var id = 0;
    for (final a in avisos) {
      await _plugin.zonedSchedule(
        id++,
        a.nombreVehiculo,
        _cuerpo(a.aviso),
        _instanteDeEntrega(a.aviso.fecha),
        _detalles,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// Las 9:00 locales del día del aviso, expresadas como instante UTC.
  ///
  /// El desfase que se aplica es el que el dispositivo tiene *ahora*, no el
  /// que tendrá ese día: un aviso programado a varios meses vista, con un
  /// cambio de horario estacional de por medio, llegará una hora antes o
  /// después. Para un recordatorio de mantenimiento es irrelevante, y como
  /// todo se reprograma al abrir la aplicación, en la práctica se corrige.
  static tz.TZDateTime _instanteDeEntrega(DateTime dia) {
    final local = DateTime(dia.year, dia.month, dia.day, kHoraDeAviso);
    return tz.TZDateTime.from(local.toUtc(), tz.UTC);
  }

  static String _cuerpo(AvisoProgramado aviso) {
    final cuantos = aviso.nombres.length;
    final cabecera = cuantos == 1
        ? '1 mantenimiento necesita atención'
        : '$cuantos mantenimientos necesitan atención';
    return '$cabecera: ${aviso.nombres.join(', ')}';
  }
}
```

- [ ] **Paso 4: Verificar que compila**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y `+157: All tests passed!` (sin tests nuevos: esta tarea es la capa que envuelve el plugin, y probarla exigiría el lado nativo de Android — por eso existe la interfaz, que es lo que la Tarea 3 sí prueba con un doble).

Si `flutter analyze` protesta por algún nombre de clase o método del plugin (las APIs cambian entre versiones mayores), consulta la versión que `flutter pub add` haya instalado y adapta la llamada, **sin cambiar el comportamiento descrito**: cancelar todo, programar con modo inexacto, y pedir el permiso sin insistir. Documenta el ajuste en tu informe.

- [ ] **Paso 5: Comprobar que el APK sigue compilando**

Esta tarea toca el manifiesto y añade plugins nativos, así que es la primera de la fase que puede romper la compilación de Android sin que `flutter analyze` diga nada:

```powershell
flutter build apk --release
```

Esperado: el APK se construye. Si falla por versión mínima de SDK o por Gradle, resuélvelo y documéntalo en tu informe.

- [ ] **Paso 6: Commit**

```bash
git add pubspec.yaml pubspec.lock android/app/src/main/AndroidManifest.xml lib/services/notificaciones.dart
git commit -q -m "Añadir el servicio de notificaciones locales"
```

---

## Tarea 3: Reprogramación de avisos

Une el cálculo puro de la Tarea 1 con el servicio de la Tarea 2, y decide cuándo se reprograma.

**Ficheros:**
- Crear: `lib/providers/notificaciones_providers.dart`
- Modificar: `lib/ui/shell/app_shell.dart`
- Modificar: `lib/providers/recalculo_al_reanudar.dart`
- Test: `test/providers/notificaciones_providers_test.dart`

**Interfaces:**
- Consume: `calcularAvisos`, `DatosAviso`, `AvisoProgramado` (Tarea 1); `ServicioNotificaciones`, `AvisoDeVehiculo` (Tarea 2); `vehiculosProvider`, `ritmoUsoProvider` y `ultimaLecturaProvider` (`lib/providers/providers.dart`); `vencimientosProvider` y `ajustesProvider` (`lib/providers/mantenimiento_providers.dart`).
- Produce: `servicioNotificacionesProvider` (`Provider<ServicioNotificaciones>`), `Future<void> reprogramarAvisos(Ref ref)`.

**Contexto del código existente que necesitas conocer:**

- `vencimientosProvider` es un `FutureProvider.family<List<MantenimientoConVencimiento>, int>` por `vehicleId`. Cada `MantenimientoConVencimiento` tiene `schedule` (con `nombre`, `activo`, `silenciado`, `avisoKm`, `avisoDias`) y `vencimiento` (con `proximaFecha`, `fechaEstimadaPorKm`). Solo devuelve los mantenimientos con `activo == true`, así que ese filtro ya está hecho; **el de `silenciado` no**, y tienes que aplicarlo tú.
- `ajustesProvider` es un `FutureProvider<Setting>` con `avisoKmPorDefecto`, `avisoDiasPorDefecto` y `diasRecordatorioLectura`. Los márgenes de cada mantenimiento (`schedule.avisoKm`, `schedule.avisoDias`) son nulos cuando se heredan de estos valores por defecto.
- `ritmoUsoProvider` es un `FutureProvider.family<UsageRateResult, int>`; `UsageRateResult` tiene `kmPorDia` (`double`).
- `ultimaLecturaProvider` es un `StreamProvider.family<MileageReading?, int>`; `MileageReading` tiene `fecha` (`DateTime`).
- El nombre de un vehículo se compone como `'${v.marca} ${v.modelo}'` en todo el proyecto.
- `recalculo_al_reanudar.dart` tiene una lista `providersARecalcularAlReanudar` y un widget que los invalida al volver a primer plano. Léelo entero antes de tocarlo.

- [ ] **Paso 1: Escribir el provider y la función de reprogramación**

Crea `lib/providers/notificaciones_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/avisos.dart';
import '../services/notificaciones.dart';
import 'mantenimiento_providers.dart';
import 'providers.dart';

/// Días de avisos que se programan por adelantado. Un año: suficiente para
/// que sigan llegando aunque la aplicación pase meses sin abrirse.
const int kDiasHorizonteAvisos = 365;

/// Cuántos recordatorios de lectura de kilometraje se programan seguidos.
/// Con el valor por defecto de 15 días son dos meses de cobertura: bastante
/// para que uno llegue aunque se ignore el anterior, sin llenar el móvil de
/// avisos si la aplicación se abandona.
const int kRecordatoriosDeLectura = 4;

final servicioNotificacionesProvider = Provider<ServicioNotificaciones>(
  (ref) => NotificacionesLocales(),
);

/// Recalcula todos los avisos de todos los vehículos y los reprograma desde
/// cero, cancelando lo anterior.
///
/// Se cancela y se reprograma entero, en lugar de llevar la cuenta de qué
/// notificación es de qué mantenimiento, porque evita toda una clase de
/// errores: avisos huérfanos de mantenimientos borrados, o duplicados tras
/// editar un intervalo. Son unas pocas decenas de alarmas.
Future<void> reprogramarAvisos(Ref ref) async {
  final servicio = ref.read(servicioNotificacionesProvider);
  final ahora = DateTime.now();
  final horizonte = ahora.add(const Duration(days: kDiasHorizonteAvisos));

  final vehiculos = await ref.read(vehiculosProvider.future);
  final ajustes = await ref.read(ajustesProvider.future);

  final avisos = <AvisoDeVehiculo>[];

  for (final vehiculo in vehiculos) {
    final nombre = '${vehiculo.marca} ${vehiculo.modelo}';
    final mantenimientos = await ref.read(
      vencimientosProvider(vehiculo.id).future,
    );
    final ritmo = await ref.read(ritmoUsoProvider(vehiculo.id).future);

    final datos = [
      for (final m in mantenimientos)
        if (!m.schedule.silenciado)
          DatosAviso(
            nombre: m.schedule.nombre,
            proximaFecha: m.vencimiento.proximaFecha,
            fechaEstimadaPorKm: m.vencimiento.fechaEstimadaPorKm,
            margenKm: m.schedule.avisoKm ?? ajustes.avisoKmPorDefecto,
            margenDias: m.schedule.avisoDias ?? ajustes.avisoDiasPorDefecto,
          ),
    ];

    for (final aviso in calcularAvisos(
      mantenimientos: datos,
      kmPorDia: ritmo.kmPorDia,
      ahora: ahora,
      horizonte: horizonte,
    )) {
      avisos.add(AvisoDeVehiculo(nombreVehiculo: nombre, aviso: aviso));
    }

    avisos.addAll(
      await _recordatoriosDeLectura(
        ref,
        vehiculo.id,
        nombre,
        ajustes.diasRecordatorioLectura,
        ahora,
        horizonte,
      ),
    );
  }

  avisos.sort((a, b) => a.aviso.fecha.compareTo(b.aviso.fecha));
  await servicio.programarAvisos(avisos);
}

/// Recordatorios para introducir el kilometraje.
///
/// No es un adorno: los avisos por kilómetros se calculan proyectando el
/// ritmo de uso desde la última lectura, así que cuanto más vieja es esa
/// lectura, peor la estimación. Esto es lo que mantiene útil a la mitad del
/// sistema de avisos.
Future<List<AvisoDeVehiculo>> _recordatoriosDeLectura(
  Ref ref,
  int vehicleId,
  String nombreVehiculo,
  int cadaCuantosDias,
  DateTime ahora,
  DateTime horizonte,
) async {
  final ultima = await ref.read(ultimaLecturaProvider(vehicleId).future);
  // Sin ninguna lectura todavía, se cuenta desde hoy.
  var fecha = (ultima?.fecha ?? ahora).add(Duration(days: cadaCuantosDias));

  final recordatorios = <AvisoDeVehiculo>[];
  while (recordatorios.length < kRecordatoriosDeLectura) {
    if (fecha.isAfter(ahora) && !fecha.isAfter(horizonte)) {
      recordatorios.add(
        AvisoDeVehiculo(
          nombreVehiculo: nombreVehiculo,
          aviso: AvisoProgramado(
            fecha: DateTime(fecha.year, fecha.month, fecha.day),
            nombres: const ['Actualiza el kilometraje'],
          ),
        ),
      );
    } else if (fecha.isAfter(horizonte)) {
      break;
    }
    fecha = fecha.add(Duration(days: cadaCuantosDias));
  }
  return recordatorios;
}
```

- [ ] **Paso 2: Escribir el test con un servicio falso**

Crea `test/providers/notificaciones_providers_test.dart`:

```dart
import 'package:car_care/data/database.dart';
import 'package:car_care/data/tables/vehicles.dart';
import 'package:car_care/domain/avisos.dart';
import 'package:car_care/providers/notificaciones_providers.dart';
import 'package:car_care/providers/providers.dart';
import 'package:car_care/services/notificaciones.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Doble de prueba: se limita a apuntar qué se le pidió programar.
class ServicioFalso implements ServicioNotificaciones {
  List<AvisoDeVehiculo> programados = [];
  int vecesProgramado = 0;

  @override
  Future<void> inicializar() async {}

  @override
  Future<bool> pedirPermiso() async => true;

  @override
  Future<void> programarAvisos(List<AvisoDeVehiculo> avisos) async {
    programados = avisos;
    vecesProgramado++;
  }
}

Vehicle _vehiculo() => Vehicle(
  id: 1,
  marca: 'Seat',
  modelo: 'León',
  combustible: FuelType.diesel,
  creadoEn: DateTime(2026, 1, 1),
  archivado: false,
);

/// `reprogramarAvisos` recibe un `Ref`, y un `ProviderContainer` no lo es.
/// En vez de retorcer la firma de la función de producción para que encaje
/// en el test, se envuelve en un provider de usar y tirar: leerlo da un
/// `Ref` de verdad, del mismo contenedor con las sobrescrituras aplicadas.
final _disparador = FutureProvider((ref) => reprogramarAvisos(ref));

void main() {
  test('sin vehículos no se programa ningún aviso', () async {
    final servicio = ServicioFalso();
    final container = ProviderContainer(
      overrides: [
        servicioNotificacionesProvider.overrideWithValue(servicio),
        vehiculosProvider.overrideWith((ref) => Stream.value([])),
      ],
    );
    addTearDown(container.dispose);

    await container.read(_disparador.future);

    expect(servicio.vecesProgramado, 1);
    expect(servicio.programados, isEmpty);
  });

  test('un vehículo sin lecturas recibe recordatorios de kilometraje',
      () async {
    final servicio = ServicioFalso();
    final container = ProviderContainer(
      overrides: [
        servicioNotificacionesProvider.overrideWithValue(servicio),
        vehiculosProvider.overrideWith((ref) => Stream.value([_vehiculo()])),
        ultimaLecturaProvider(1).overrideWith((ref) => Stream.value(null)),
        vencimientosProvider(1).overrideWith((ref) => []),
      ],
    );
    addTearDown(container.dispose);

    await container.read(_disparador.future);

    expect(servicio.programados, hasLength(kRecordatoriosDeLectura));
    expect(
      servicio.programados.first.aviso.nombres,
      ['Actualiza el kilometraje'],
    );
  });
}
```

Dos cosas que pueden hacer falta y que solo verás al ejecutar:

- **`ajustesProvider`** lee la tabla `Settings` de la base de datos real. Si el test falla porque intenta abrirla, sobrescríbelo construyendo un `Setting` a mano con `avisoKmPorDefecto: 1000`, `avisoDiasPorDefecto: 30` y `diasRecordatorioLectura: 15`, que son los valores por defecto del esquema. Mira la definición de la tabla en `lib/data/tables/settings.dart` para los campos exactos que exige el constructor.
- **`ritmoUsoProvider`** también consulta la base de datos. Si hace falta, sobrescríbelo con un `UsageRateResult` construido a mano (`lib/domain/usage_rate.dart` tiene la clase; `const UsageRateResult(kmPorDia: 50, esPorDefecto: false)` sirve).

Añade solo las sobrescrituras que el test necesite de verdad para pasar: una sobrescritura de más oculta qué dependencias tiene realmente la función.

- [ ] **Paso 3: Ejecutar el test**

```powershell
flutter test test/providers/notificaciones_providers_test.dart --reporter=failures-only
```

Esperado: `+2: All tests passed!`

- [ ] **Paso 4: Disparar la reprogramación desde la aplicación**

Dos enganches, ambos descritos por comportamiento:

**Al arrancar**: en `lib/ui/shell/app_shell.dart`, convierte el widget en `ConsumerStatefulWidget` si hace falta y, una sola vez tras el primer fotograma, inicializa el servicio, pide el permiso y reprograma. Que el usuario deniegue el permiso no debe romper nada: la reprogramación se intenta igual (el sistema simplemente no mostrará nada), y la aplicación sigue funcionando como hoy. Envuelve todo en `try`/`catch` con `debugPrint` del detalle: un fallo del plugin **nunca** debe impedir que la aplicación se abra.

**Al volver a primer plano**: en `lib/providers/recalculo_al_reanudar.dart`, después de invalidar los providers de la lista, dispara también la reprogramación. Ten en cuenta que invalidar y leer a continuación devuelve los valores recalculados, que es justo lo que quieres.

Recuerda el criterio del proyecto: todo uso de `BuildContext` después de un `await` va precedido de `if (!mounted) return;`.

- [ ] **Paso 5: Verificar**

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Esperado: `No issues found!` y `+159: All tests passed!` (157 + 2 nuevos).

- [ ] **Paso 6: Commit**

```bash
git add lib/providers/notificaciones_providers.dart test/providers/notificaciones_providers_test.dart lib/ui/shell/app_shell.dart lib/providers/recalculo_al_reanudar.dart
git commit -q -m "Reprogramar los avisos al abrir la app y al reanudarla"
```

---

## Tarea 4: Verificación final y APK

**Ficheros:** ninguno nuevo.

- [ ] **Paso 1: Verificación completa**

```powershell
flutter analyze
flutter test --reporter=failures-only
flutter build apk --release
```

Esperado: `No issues found!`, `+159: All tests passed!` y el APK construido.

- [ ] **Paso 2: Comprobar que el permiso quedó en el APK**

```powershell
F:\dev\android-sdk\build-tools\35.0.0\aapt.exe dump permissions build\app\outputs\flutter-apk\app-release.apk
```

Esperado: aparece `android.permission.POST_NOTIFICATIONS` y **no aparece** `android.permission.INTERNET`. Si la ruta de `aapt` no existe, busca la versión de `build-tools` instalada en `F:\dev\android-sdk\build-tools\`. Si no encuentras la herramienta, dilo en tu informe en vez de darlo por bueno: es la única comprobación objetiva de que la aplicación sigue siendo incapaz de salir a la red.

- [ ] **Paso 3: Commit de cierre**

```bash
git commit -q --allow-empty -m "Cerrar las notificaciones"
```

---

## Qué queda fuera

- **Abrir la ficha del vehículo al tocar la notificación.** La spec lo menciona, pero exige una `navigatorKey` global y manejar el arranque en frío desde una notificación, que es una fuente de complejidad desproporcionada frente a su valor: tocar la notificación ya abre la aplicación. Se deja anotado como mejora, no como parte de esta fase.
- La pantalla de Ajustes, donde vivirían la hora de entrega y el interruptor general de avisos.
- La copia de seguridad exportable.
