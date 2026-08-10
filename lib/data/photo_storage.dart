import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resuelve las rutas de las fotos de los vehículos.
///
/// En base de datos (columna `fotoPath` de Vehicles) solo se guarda la ruta relativa
/// dentro del directorio de la app (p.ej. `fotos/1700000000000.jpg`), para
/// que la copia de seguridad en zip de la fase 3 sea portable entre
/// dispositivos. Esta clase conecta esa ruta relativa con la ruta absoluta
/// real en este dispositivo, que es la que necesitan `File` e `Image.file`.
class PhotoStorage {
  const PhotoStorage._();

  static const carpeta = 'fotos';

  static String? _directorioBase;

  /// Resuelve y cachea el directorio de documentos de la app. Se llama una
  /// vez en `main()`, antes de `runApp`, para que [absoluta] pueda resolver
  /// rutas de forma síncrona durante la construcción de la interfaz.
  static Future<void> inicializar() async {
    final dir = await getApplicationDocumentsDirectory();
    _directorioBase = dir.path;
  }

  /// Directorio `fotos` dentro del almacenamiento de la app, creándolo si
  /// hace falta.
  static Future<Directory> carpetaFotos() async {
    final dir = await getApplicationDocumentsDirectory();
    _directorioBase ??= dir.path;
    final carpetaFotos = Directory(p.join(dir.path, carpeta));
    await carpetaFotos.create(recursive: true);
    return carpetaFotos;
  }

  /// Ruta relativa (la que se persiste en base de datos) a partir de la
  /// ruta absoluta de un fichero dentro de la carpeta de fotos.
  static String relativa(String rutaAbsoluta) =>
      p.join(carpeta, p.basename(rutaAbsoluta));

  /// Ruta absoluta en este dispositivo a partir de la ruta relativa
  /// guardada en base de datos. Requiere haber llamado antes a
  /// [inicializar].
  static String absoluta(String rutaRelativa) {
    final base = _directorioBase;
    if (base == null) {
      throw StateError(
        'PhotoStorage.inicializar() no se ha llamado todavía.',
      );
    }
    return p.join(base, rutaRelativa);
  }
}
