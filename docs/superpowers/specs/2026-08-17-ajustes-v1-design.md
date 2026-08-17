# Ajustes v1

## 1. Por qué esto ahora

`Settings.tema` existe en el esquema desde la fase 1 y nadie lo lee: `MaterialApp` tiene `themeMode: ThemeMode.system` fijo en `lib/app.dart`, sin pasar por la base de datos. Es una incongruencia entre modelo e implementación, y arrastrarla más tiempo no aporta nada.

El destino "Ajustes" de la barra inferior sigue siendo el placeholder de la fase 1 (`_PendienteFase2` en `lib/ui/shell/app_shell.dart`). Los campos de notificación (`avisoKmPorDefecto`, `avisoDiasPorDefecto`, `diasRecordatorioLectura`) ya se usan como valores por defecto de cada mantenimiento, pero no hay ninguna pantalla para cambiarlos: solo se pueden tocar escribiendo directamente en la base de datos.

Esta fase construye la primera versión real de Ajustes: Notificaciones, Apariencia y Datos. No es "rellenar la pantalla que falta" — es cerrar el hueco entre lo que el modelo ya promete y lo que la aplicación permite hacer.

## 2. Qué no cambia

- No se añade un interruptor general "Activar notificaciones". El sistema ya distingue tres capas — permiso de Android, preferencias de la app, motor de avisos — y un interruptor que cancele todo las mezclaría. Esa separación se mantiene intacta; ver sección 3.
- No se implementa backup real. El botón "Exportar copia" queda preparado (sección 5) pero no escribe ni lee ningún fichero.
- No se toca `pedirPermiso()` ni el flujo de arranque en `app_shell.dart`: sigue pidiendo el permiso una vez al iniciar la app, exactamente igual que hoy.
- No hay migración de esquema. Los campos de `Settings` que esta fase usa (`tema`, `avisoKmPorDefecto`, `avisoDiasPorDefecto`, `diasRecordatorioLectura`, `fechaUltimaCopia`) ya existen desde la fase 1.
- La hora de entrega de los avisos (9:00, `kHoraDeAviso` en `lib/services/notificaciones.dart`) sigue fija. No forma parte de esta fase.

## 3. Las tres capas de notificaciones

La razón para no meter un interruptor "Activar notificaciones" es que ya existen tres preguntas distintas, cada una respondida por una capa distinta:

```
Permiso Android          ¿Puede Android mostrar notificaciones?
      ↓
Preferencias de la app    ¿Qué avisos quiero y con cuánta antelación?
      ↓
Motor de avisos           ¿Qué avisos corresponden hoy, según los datos reales?
```

Ajustes v1 solo toca la capa de en medio: los márgenes de antelación y el recordatorio de kilometraje. El permiso se muestra (capa 1) pero no se fuerza desde aquí más allá de llevar al usuario a la pantalla del sistema. El motor de avisos (capa 3) no cambia una línea.

Esta separación es la que permitirá, en una fase futura, filtros por tipo de aviso (mantenimientos / kilometraje / otros) sin rehacer nada de esto.

## 4. Notificaciones

### Campos

Tres valores editables, todos enteros positivos, todos con el mismo patrón de edición:

- **Avisar con ___ km de antelación** — `avisoKmPorDefecto`, valor inicial 1000.
- **Avisar con ___ días de antelación** — `avisoDiasPorDefecto`, valor inicial 30.
- **Recordar introducir kilometraje cada ___ días** — `diasRecordatorioLectura`, valor inicial 15.

Cada uno es un `TextField` numérico (patrón de `update_mileage_sheet.dart`), precargado con el valor actual. Al perder el foco:

- Si el texto es un entero positivo (`> 0`), se guarda vía `SettingsDao` y el campo queda como está.
- Si el texto está vacío o no es un entero positivo válido, el campo revierte al último valor guardado, sin diálogo ni `SnackBar` — es autocorrección silenciosa. No es un error del usuario que merezca una interrupción; simplemente no se acepta el cambio.

No hay guardado explícito ni botón "Guardar": cada campo se autoguarda de forma independiente, igual que el resto de esta pantalla (sección 8).

### Estado del permiso de notificaciones

Una fila de solo consulta, sin pedir permiso activamente: lee `Permission.notification.status` (paquete `permission_handler`, sección 7) y muestra "Concedido" o "Denegado" como texto.

Si no está concedido, aparece un botón "Abrir ajustes de la aplicación" que llama a `openAppSettings()` y lleva a la pantalla de ajustes de Android para esa app. Desde ahí el usuario concede el permiso fuera de la aplicación.

El estado se vuelve a consultar cuando la aplicación vuelve a primer plano — mismo mecanismo que ya usa `lib/providers/recalculo_al_reanudar.dart` para los providers que dependen de "ahora". Así, si el usuario concede el permiso desde Ajustes del sistema y vuelve a la app, la fila se actualiza sola sin tener que salir y volver a entrar en la pantalla.

Esta consulta es independiente de `pedirPermiso()`: esa función pide el permiso una vez, al arrancar la app, y no cambia. Esta fila solo consulta y, como mucho, navega — nunca dispara el diálogo del sistema.

## 5. Apariencia

Tres opciones excluyentes — Automático, Claro, Oscuro — en un `SegmentedButton<String>` (Material 3; no hay un widget de "elegir 1 de pocas opciones" ya usado en la app, y es el estándar de la librería para este caso).

Al tocar una opción se escribe de inmediato vía `SettingsDao.actualizarTema` con uno de los tres valores ya usados en el esquema (`'automatico'`, `'claro'`, `'oscuro'` — ver `Settings.tema.withDefault('automatico')`). El cambio se refleja al instante en toda la aplicación: no hace falta reiniciar ni navegar fuera de la pantalla.

Esto último depende del cambio de arquitectura de la sección 7: mientras `ajustesProvider` sea un `FutureProvider` de una sola lectura, escribir en la tabla no provoca ningún rebuild. Convertirlo en `StreamProvider` es lo que hace que `MaterialApp.themeMode` reaccione solo.

## 6. Datos

- **Exportar copia**: fila con icono y texto, tocable. Al pulsarla aparece un `SnackBar`: "Esta función estará disponible en una próxima versión". No hay lógica de backup detrás — ni fichero, ni selector del sistema, ni serialización.
- **Última copia**: fila que muestra la fecha de `Settings.fechaUltimaCopia`, formateada `dd/MM/yyyy`, **solo si no es nula**. Como hoy ningún código escribe ese campo, la fila no aparece nunca en la práctica. Queda preparada para cuando exista un backup real que sí lo actualice — entonces la fila aparecerá sin más cambios en esta pantalla.

## 7. Arquitectura

### `SettingsDao`

DAO nuevo, mismo patrón que `VehicleDao` / `MaintenanceDao` / `VehicleSpecificationDao`. Como `Settings` es una tabla de fila única (`id` fijo a `1`, sembrada en `beforeOpen`), todos los métodos actualizan esa fila:

- `actualizarTema(String tema)`
- `actualizarAvisoKmPorDefecto(int km)`
- `actualizarAvisoDiasPorDefecto(int dias)`
- `actualizarDiasRecordatorioLectura(int dias)`

Cada método hace un `update` puntual sobre la fila `id = 1`, sin transacción (son escrituras de un único valor, independientes entre sí).

### `ajustesProvider`: de `FutureProvider` a `StreamProvider`

Hoy (`lib/providers/mantenimiento_providers.dart`):

```dart
final ajustesProvider = FutureProvider<Setting>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.settings).getSingle();
});
```

Pasa a:

```dart
final ajustesProvider = StreamProvider<Setting>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.settings).watchSingle();
});
```

Esto es lo que permite que una escritura del `SettingsDao` se propague sola a cualquier consumidor — la pantalla de Ajustes y, sobre todo, `MaterialApp` en `lib/app.dart`. Todo el código que ya usa `ajustesProvider` (`lib/providers/notificaciones_providers.dart`) sigue funcionando igual: `ref.watch`/`ref.read` sobre un `StreamProvider` con `AsyncValue<Setting>` se comporta igual que con un `FutureProvider` para el caso de uso actual (esperar el primer valor).

### Tema en `app.dart`

`MaterialApp` pasa a leer `ajustesProvider` para fijar `themeMode`:

```dart
themeMode: switch (ajustes.valueOrNull?.tema) {
  'claro' => ThemeMode.light,
  'oscuro' => ThemeMode.dark,
  _ => ThemeMode.system, // 'automatico', o mientras carga
},
```

Mientras el `Stream` no ha emitido su primer valor (arranque en frío), se comporta como hoy: modo sistema.

### Pantalla

`lib/ui/settings/settings_screen.dart` sustituye a `_PendienteFase2` en `app_shell.dart`. Sigue los criterios ya asentados en la app (`CLAUDE.md`, verificados en `vehicle_form_screen.dart`): `if (!mounted) return` tras cada `await`, mensajes de error en español vía `SnackBar` con detalle técnico solo por `debugPrint`. No necesita guarda de reentrada de botón de guardar porque no hay un guardado global — cada campo se guarda solo.

## 8. Autoguardado, sin botón "Guardar"

Ningún control de esta pantalla se acumula en un estado "sin guardar" pendiente de confirmar. Cada interacción persiste en el momento:

- Los `TextField` numéricos, al perder el foco (si el valor es válido).
- El `SegmentedButton` de apariencia, al tocar una opción.

Esto es coherente con que `Settings` es una fila de preferencias vivas, no un formulario que se envía una vez. Es una diferencia deliberada con `vehicle_form_screen.dart` (que sí tiene un botón "Guardar" porque crea o reemplaza un registro completo).

## 9. Dependencia nueva: `permission_handler`

Única dependencia nueva de esta fase. Hace falta para dos cosas que `flutter_local_notifications` no resuelve:

- Consultar el estado del permiso sin pedirlo (`Permission.notification.status`).
- Abrir la pantalla de ajustes de la aplicación en Android (`openAppSettings()`).

La alternativa — un `MethodChannel` propio contra `ACTION_APPLICATION_DETAILS_SETTINGS` en `MainActivity.kt` — evita la dependencia pero añade código nativo Android sin cobertura de `flutter test` y sin ninguna ventaja real sobre un paquete estándar y muy usado. Se descarta.

## 10. Manejo de errores

- Las escrituras del `SettingsDao` van en `try`/`catch`: si fallan (caso extremo — es SQLite local, sin red de por medio), `SnackBar` en español ("No se ha podido guardar el cambio") y `debugPrint` del detalle técnico. El campo revierte al valor anterior.
- `openAppSettings()` y la consulta de `Permission.notification.status` son `Future`s: `if (!mounted) return` antes de cualquier `setState` posterior.
- La validación de los campos numéricos (entero positivo) ocurre en el cliente, antes de tocar el DAO — no hace falta manejar un valor inválido llegando a la base de datos.

## 11. Testing

- **`SettingsDao`**: test unitario por método (`actualizarTema`, `actualizarAvisoKmPorDefecto`, etc.), mismo patrón que los DAOs existentes — escribir y releer, comprobar que solo cambia el campo esperado.
- **`settings_screen.dart`**: test de widget con el provider de datos sobrescrito (patrón `test/ui/*_test.dart` — evita abrir una base de datos Drift real). Casos: valor inicial mostrado correctamente, edición válida persiste, edición inválida revierte, tocar una opción de apariencia llama al DAO.
- **Tema en `app.dart`**: test de que `themeMode` resuelve a `light`/`dark`/`system` según los tres valores posibles de `Settings.tema`, y a `system` cuando el provider aún no ha emitido.
- No hace falta test de migración: no hay cambio de esquema.

## 12. Orden de implementación

1. `SettingsDao` + conversión de `ajustesProvider` a `StreamProvider` (con sus tests).
2. Aplicación del tema en `app.dart` (con su test) — ya es visible y probable de verificar en caliente aunque la pantalla de Ajustes aún no exista.
3. Añadir `permission_handler` y la fila de estado de permiso.
4. Pantalla completa: Notificaciones + Apariencia + Datos, sustituyendo `_PendienteFase2`.

## 13. Qué queda fuera

- Backup/export real (selector de fichero, serialización, import con validación de versión de esquema) — sigue en el roadmap deprioritizado, sin fase asignada.
- Interruptor general de notificaciones y filtros por tipo de aviso (mantenimientos / kilometraje / otros) — la separación en tres capas de la sección 3 los deja listos para una fase futura, pero no se construyen aquí.
- Hora de entrega configurable — sigue fija a las 9:00.
- Aviso persistente en Ajustes si el permiso está denegado más allá de la fila de estado (por ejemplo, un banner en el resto de la app) — no se construye en esta fase.
