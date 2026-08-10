# Car Care

Aplicación Android hecha con Flutter para llevar el mantenimiento de los vehículos de casa: kilometraje, revisiones, ITV y avisos, todo en un mismo sitio. Esta fase 1 cubre el alta de vehículos y el registro de kilometraje.

## Tests y analizador

```
flutter test
flutter analyze
```

El analizador debe devolver `No issues found!`.

## Gradle no arranca en este equipo

En este Windows, `flutter build`, `flutter run` y `flutter install` fallan porque Gradle no consigue levantar el daemon: hay un fallo conocido con los sockets AF_UNIX de Windows, ajeno al proyecto. Queda pendiente de probar como solución un `netsh winsock reset` desde una consola con permisos de administrador seguido de un reinicio del equipo.

Mientras tanto, la forma de verificar los cambios es `flutter analyze` y `flutter test`.
