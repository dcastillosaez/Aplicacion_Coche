import 'package:flutter/services.dart';

/// Servicio para recibir y gestionar atajos de la aplicación (App Shortcuts de Android).
class ServicioShortcuts {
  static const MethodChannel _canal = MethodChannel(
    'com.dcastillo.car_care/shortcuts',
  );

  final void Function(String shortcut)? onShortcutRecibido;

  ServicioShortcuts({this.onShortcutRecibido}) {
    _canal.setMethodCallHandler((call) async {
      if (call.method == 'onShortcut' && call.arguments is String) {
        onShortcutRecibido?.call(call.arguments as String);
      }
    });
  }

  /// Consulta si la app se abrió desde un shortcut estático en frío.
  Future<String?> obtenerShortcutInicial() async {
    try {
      return await _canal.invokeMethod<String>('getInitialShortcut');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
