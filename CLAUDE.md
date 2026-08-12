# Mis Vehículos (car_care)

App Android en Flutter para llevar el mantenimiento de dos coches: kilometraje, mantenimientos con avisos por km/tiempo, ITV, historial. Datos 100% locales (Drift/SQLite), sin permiso de internet, sin backend, sin login.

## Salida de consola: precisión y ahorro de tokens

**Sé preciso y conciso en todo lo que reportes por consola. Menciona solo lo imprescindible.**

- No vuelques logs, diffs ni salidas completas de comandos. Un `flutter test` exitoso se resume en una línea (`+94: All tests passed!`), no en la lista de los 94 tests.
- Usa siempre los modos silenciosos y acotados: `flutter test --reporter=failures-only`, `| Select-Object -Last N`, `git log --oneline`, `git status --short`.
- Cuando algo falla, ahí sí saca el detalle necesario para diagnosticar — el ahorro no aplica a lo que hace falta para arreglar algo.
- No repitas información que ya está en este fichero (rutas, comandos, arquitectura) a modo de resumen "por si acaso". Si hace falta, referencia la sección de este documento en vez de reexplicarla.
- No confirmes con frases de relleno ("Perfecto, ahora voy a...", "¡Listo!"). Resultado y punto.

## Estado del proyecto

- **Fase 1** (cimientos) y **Fase 2** (mantenimientos y avisos): completas y fusionadas. 94 tests, `flutter analyze` limpio.
- **Roadmap a partir de la fase 3**: identidad técnica del vehículo → motor de recomendaciones → catálogo de piezas → integración mantenimiento/piezas → compra. Notificaciones/ajustes/backup y componentes/facturas/gastos quedan deprioritizados, sin fase asignada. Sin plan de implementación todavía — solo el documento de visión.
- Repositorio: `https://github.com/dcastillosaez/Aplicacion_Coche` (privado). Rama de trabajo: `fase-1` (histórica; en ella se han implementado también las fases 2 en adelante). PR #1 abierto contra `main`.
- La app es **offline por diseño** (sin permiso `INTERNET`). Se mantiene así hasta la fase del catálogo de piezas, donde se convierte en una decisión explícita a tomar, no un descuido — ver el roadmap.

## Dónde está cada cosa

| Qué | Dónde |
|---|---|
| Diseño original (modelo de datos, decisiones, alcance) | `docs/superpowers/specs/2026-08-09-app-mantenimiento-vehiculos-design.md` |
| Plan de implementación, Fase 1 | `docs/superpowers/plans/2026-08-09-fase-1-cimientos-y-vehiculos.md` |
| Plan de implementación, Fase 2 | `docs/superpowers/plans/2026-08-10-fase-2-mantenimientos-y-avisos.md` |
| **Roadmap fase 3 en adelante** (identidad técnica, motor de recomendaciones, catálogo de piezas) | `docs/superpowers/specs/2026-08-12-roadmap-identidad-tecnica-catalogo-piezas.md` |
| Progreso de la ejecución tarea a tarea | `.superpowers/sdd/progress.md` (no versionado) |

Antes de planificar cualquier tarea de la fase 3, lee el roadmap completo — fija el modelo de datos objetivo (`VehicleSpecifications`, y más adelante `Parts`/`PartCompatibility`) y qué queda deliberadamente fuera hasta que el catálogo de piezas lo justifique.

## Arquitectura

Tres capas, regla estricta: `lib/domain/` **nunca** importa `package:drift/...` ni `package:flutter/...`. Es lógica pura, comprobada en revisiones anteriores porque romperla se intentó por accidente al menos una vez (ver `lib/domain/fuel_type.dart` y `maintenance_category.dart`, movidos desde la capa de datos por este motivo, con reexport desde `lib/data/tables/` para no romper la serialización de Drift ya persistida).

```
lib/data/       Drift (SQLite): tablas, DAOs, migraciones, PhotoStorage
lib/domain/     lógica pura: motor de vencimientos, ITV, ritmo de uso, plantillas, catálogos
lib/providers/  Riverpod: conecta datos y dominio con la interfaz
lib/ui/         pantallas y widgets, organizados por feature (home, vehicle, maintenance, mileage, history, theme, common)
```

Estado con Riverpod. Valores derivados (próximo km, próxima fecha, estado) **nunca se persisten**: se calculan siempre a partir de las lecturas y registros reales.

## Entorno de desarrollo — imprescindible, sin esto nada compila

Toolchain no está en el PATH de la shell, y **Gradle no arranca sin redirigir TMP/TEMP** (ver `README.md` para el porqué). Antepón esto a cada comando que use flutter/dart:

```powershell
$env:Path = "F:\dev\flutter\bin;F:\dev\android-sdk\platform-tools;$env:Path"
$env:JAVA_HOME = 'C:\Program Files\Eclipse Adoptium\jdk-17.0.20.8-hotspot'
$env:ANDROID_HOME = 'F:\dev\android-sdk'
$env:TMP = 'F:\dev\tmp'; $env:TEMP = 'F:\dev\tmp'
```

Verificación estándar tras cualquier cambio:

```powershell
flutter analyze
flutter test --reporter=failures-only
```

Compilar el APK (solo cuando haga falta probar en el móvil, tarda ~1 min):

```powershell
flutter build apk --release
```

No hay dispositivo Android conectado de forma permanente: la mayoría de las tareas se verifican con `analyze` + `test`, sin ver la pantalla. Extremar el cuidado con el código de interfaz por este motivo.

## Cómo se ejecutan las fases: proceso obligatorio

Este proyecto usa **subagent-driven-development**: brainstorming → diseño (spec) → plan de implementación → ejecución tarea a tarea, cada tarea implementada por un subagente y **revisada de forma independiente y adversarial por otro subagente** antes de continuar. No te saltes la revisión aunque el código "se vea bien".

Patrón que ha demostrado su valor: **las tareas de interfaz describen comportamiento y señalan qué fichero ya en el repo sirve de patrón, en vez de dictar código**. El código dictado en planes anteriores fue la fuente de varios defectos reales (ver historial de commits de la fase 2 — errores en el cálculo de ITV, retroceso de kilometraje, atribución incorrecta de avisos). Un subagente que copia literalmente un plan no cuestiona la aritmética; un revisor adversarial sí.

Criterios ya asentados en el código, que cualquier pantalla nueva debe seguir (están en `vehicle_form_screen.dart`, `update_mileage_sheet.dart`, `maintenance_form_screen.dart` como referencia):
- Todo `setState` o uso de `BuildContext` posterior a un `await`, precedido de `if (!mounted) return;`.
- Guarda de reentrada en botones de guardar.
- Escrituras en `try`/`catch`: mensaje claro en español al usuario (`SnackBar`), detalle técnico solo por `debugPrint`, nunca la excepción cruda en pantalla.
- Inserciones múltiples relacionadas van en `db.transaction(...)`.
- Al pintar una foto desde disco, `errorBuilder` (el fichero puede no existir).
- Fotos se guardan como ruta **relativa** vía `PhotoStorage`, nunca absoluta (rompería cualquier copia de seguridad futura entre dispositivos).
- Providers cuyo resultado depende de "hoy" se registran en `lib/providers/recalculo_al_reanudar.dart`.
- Tests de widget que abren la app real: sobrescriben el provider de datos en vez de abrir una base de datos Drift real (los streams de Drift dejan temporizadores vivos que rompen `testWidgets`). Ver `test/ui/*_test.dart` como patrón.

## Convenciones

- Toda la interfaz de usuario en español. Fechas `dd/MM/yyyy`, importes en euros con dos decimales, separador de miles con punto.
- Commits en español, sin coautoría ni menciones a herramientas (nunca `Co-Authored-By`).
- Sin dependencias nuevas salvo necesidad real y justificada.
- Migraciones de esquema: cada cambio sube `schemaVersion` y se prueba con datos reales pre-existentes, no solo con estructura vacía (patrón en `test/data/database_migration_test.dart`).

## Trampa conocida: `m.createTable()` usa siempre la definición actual de la tabla

Descubierto en la revisión final de la fase 3, sin fix aplicado porque no hay ninguna columna futura contra la que probarlo todavía — es una advertencia para cuando llegue el momento, no un bug de hoy.

`m.createTable(vehicleSpecifications)` en un paso `if (from < N)` de `onUpgrade` no crea la tabla "tal como era en la versión N": la crea con la definición **actual** de la clase Dart, la que esté en el código en el momento de compilar. Si una fase futura añade una columna a `VehicleSpecifications` (o a cualquier tabla) y sube `schemaVersion`, y el nuevo paso hace `m.addColumn(vehicleSpecifications, vehicleSpecifications.columnaNueva)`, un usuario que actualice desde antes de que existiera la tabla ejecutará primero el `createTable` (que ya trae la columna nueva, porque lee la clase Dart vigente) y después el `addColumn` sobre esa misma columna: `duplicate column name`, migración abortada.

No hay `drift_schemas/` ni esquemas versionados en este proyecto, así que no hay red de seguridad automática. Antes de añadir una columna a `VehicleSpecifications` (o a cualquier tabla creada en un paso `createTable` de una migración anterior), comprobarlo con un test de migración que encadene ambos pasos con datos reales, exactamente como ya se hace para las demás — es donde este problema se vería antes de llegar al móvil del usuario.
