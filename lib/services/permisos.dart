import 'package:permission_handler/permission_handler.dart';

/// La puerta de salida a los permisos del sistema operativo.
///
/// Existe como interfaz, igual que `ServicioNotificaciones`, para poder
/// sustituirla por un doble de prueba: el plugin real necesita el lado
/// nativo de Android y no funciona en un test de Dart.
abstract class ServicioPermisos {
  /// Consulta el estado actual del permiso de notificaciones sin pedirlo.
  Future<bool> tienePermisoNotificaciones();

  /// Abre la pantalla de ajustes de la aplicación en el sistema.
  Future<void> abrirAjustesDeLaAplicacion();
}

/// Implementación real sobre `permission_handler`.
class PermisosDelSistema implements ServicioPermisos {
  @override
  Future<bool> tienePermisoNotificaciones() async {
    final estado = await Permission.notification.status;
    return estado.isGranted;
  }

  @override
  Future<void> abrirAjustesDeLaAplicacion() async {
    await openAppSettings();
  }
}
