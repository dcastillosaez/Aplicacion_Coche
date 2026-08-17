import 'package:car_care/providers/permisos_providers.dart';
import 'package:car_care/services/permisos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ServicioPermisosFalso implements ServicioPermisos {
  final bool concedido;
  int vecesAbierto = 0;

  _ServicioPermisosFalso({required this.concedido});

  @override
  Future<bool> tienePermisoNotificaciones() async => concedido;

  @override
  Future<void> abrirAjustesDeLaAplicacion() async {
    vecesAbierto++;
  }
}

void main() {
  test('permisoNotificacionesProvider expone el estado concedido', () async {
    final servicio = _ServicioPermisosFalso(concedido: true);
    final container = ProviderContainer(
      overrides: [servicioPermisosProvider.overrideWithValue(servicio)],
    );
    addTearDown(container.dispose);

    final concedido = await container.read(
      permisoNotificacionesProvider.future,
    );

    expect(concedido, isTrue);
  });

  test('permisoNotificacionesProvider expone el estado denegado', () async {
    final servicio = _ServicioPermisosFalso(concedido: false);
    final container = ProviderContainer(
      overrides: [servicioPermisosProvider.overrideWithValue(servicio)],
    );
    addTearDown(container.dispose);

    final concedido = await container.read(
      permisoNotificacionesProvider.future,
    );

    expect(concedido, isFalse);
  });
}
