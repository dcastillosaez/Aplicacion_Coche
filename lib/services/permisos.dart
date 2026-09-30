import 'package:permission_handler/permission_handler.dart';

/// La puerta de salida a los permisos del sistema operativo.
///
/// Existe como interfaz, igual que `ServicioNotificaciones`, para poder
/// sustituirla por un doble de prueba: el plugin real necesita el lado
/// nativo de Android y no funciona en un test de Dart.
abstract class ServicioPermisos {
  /// Consulta el estado actual del permiso de notificaciones sin pedirlo.
  Future<bool> tienePermisoNotificaciones();

  /// Consulta si la aplicación tiene permiso para programar alarmas exactas.
  Future<bool> puedeProgramarAlarmasExactas();

  /// Consulta si la aplicación está exenta de las optimizaciones de batería
  /// (modo sin restricciones).
  Future<bool> tieneBateriaOptimizadaIgnorada();

  /// Muestra el diálogo del sistema para solicitar la exclusión de batería.
  Future<bool> solicitarIgnorarOptimizacionBateria();

  /// Abre la pantalla del sistema correspondiente a alarmas exactas o ajustes.
  Future<void> abrirAjustesDeAlarmasExactas();

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
  Future<bool> puedeProgramarAlarmasExactas() async {
    final estado = await Permission.scheduleExactAlarm.status;
    return estado.isGranted;
  }

  @override
  Future<bool> tieneBateriaOptimizadaIgnorada() async {
    final estado = await Permission.ignoreBatteryOptimizations.status;
    return estado.isGranted;
  }

  @override
  Future<bool> solicitarIgnorarOptimizacionBateria() async {
    final estado = await Permission.ignoreBatteryOptimizations.request();
    return estado.isGranted;
  }

  @override
  Future<void> abrirAjustesDeAlarmasExactas() async {
    await openAppSettings();
  }

  @override
  Future<void> abrirAjustesDeLaAplicacion() async {
    await openAppSettings();
  }
}
