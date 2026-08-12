# Car Care

Aplicación Android hecha con Flutter para llevar el mantenimiento de los vehículos de casa: kilometraje, revisiones, ITV y avisos, todo en un mismo sitio. Esta fase 1 cubre el alta de vehículos y el registro de kilometraje.

## Tests y analizador

```
flutter test
flutter analyze
```

El analizador debe devolver `No issues found!`.

## Compilar el APK en este equipo

Hay que redirigir la carpeta temporal antes de compilar. Sin eso, Gradle ni siquiera arranca:

```powershell
$env:TMP = 'F:\dev\tmp'; $env:TEMP = 'F:\dev\tmp'
flutter build apk --release
```

El APK queda en `build\app\outputs\flutter-apk\app-release.apk`.

### Por qué

En este Windows, el `connect` de sockets AF_UNIX falla con `Invalid argument` **solo** dentro de la carpeta temporal del perfil de usuario. En cualquier otra ruta funciona, y el `bind` funciona incluso ahí, así que no es un problema del volumen ni del sistema de ficheros: es algo específico de esa carpeta.

Java 17 implementa los pipes internos de sus selectores NIO sobre AF_UNIX, y Gradle los usa para hablar con su propio daemon. De ahí que el síntoma visible fuera un desconcertante `Unable to establish loopback connection` en cualquier build. Redirigir `TMP` y `TEMP` a una carpeta fuera del perfil lo resuelve por completo.

También está desactivada la compilación incremental de Kotlin en `android/gradle.properties`: calcula rutas relativas entre las fuentes y el proyecto, y como los plugins viven en la caché de paquetes de Dart en `C:` mientras el proyecto está en `F:`, fallaba con `different roots`.
