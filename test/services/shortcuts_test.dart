import 'package:car_care/services/shortcuts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const canal = MethodChannel('com.dcastillo.car_care/shortcuts');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canal, null);
  });

  test('obtenerShortcutInicial devuelve el shortcut entregado por Android', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canal, (MethodCall call) async {
          if (call.method == 'getInitialShortcut') {
            return 'historial';
          }
          return null;
        });

    final servicio = ServicioShortcuts();
    final shortcut = await servicio.obtenerShortcutInicial();

    expect(shortcut, 'historial');
  });

  test('obtenerShortcutInicial devuelve null si la plataforma devuelve null', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canal, (MethodCall call) async {
          if (call.method == 'getInitialShortcut') {
            return null;
          }
          return null;
        });

    final servicio = ServicioShortcuts();
    final shortcut = await servicio.obtenerShortcutInicial();

    expect(shortcut, isNull);
  });

  test('invoca onShortcutRecibido al llegar evento onShortcut desde la plataforma', () async {
    String? recibido;
    ServicioShortcuts(
      onShortcutRecibido: (s) {
        recibido = s;
      },
    );

    // Simular que Android invoca onShortcut en segundo plano
    final byteData = const StandardMethodCodec().encodeMethodCall(
      const MethodCall('onShortcut', 'gastos'),
    );

    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage('com.dcastillo.car_care/shortcuts', byteData, (_) {});

    expect(recibido, 'gastos');
  });
}
