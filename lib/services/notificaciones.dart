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
      settings: const InitializationSettings(
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

    final ahora = DateTime.now();
    var id = 0;
    for (final a in avisos) {
      final instante = _instanteDeEntrega(a.aviso.fecha);
      // El dominio conserva los avisos de hoy (para no perderlos si la app
      // se abre antes de la hora de entrega), pero si esa hora ya pasó
      // programar la alarma no tiene sentido: el plugin la entregaría de
      // inmediato o nunca, según la implementación. Se omite sin más.
      if (instante.isBefore(ahora)) continue;
      await _plugin.zonedSchedule(
        id: id++,
        title: a.nombreVehiculo,
        body: cuerpoDeAviso(a.aviso),
        scheduledDate: instante,
        notificationDetails: _detalles,
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
}
