import 'package:car_care/providers/permisos_providers.dart';
import 'package:car_care/services/permisos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ServicioPermisosFalso implements ServicioPermisos {
  final bool concedido;
  final bool alarmasExactas;
  final bool bateriaOptimizadaIgnorada;
  int vecesAbierto = 0;
  int vecesAbiertoAlarmas = 0;
  int vecesSolicitadoBateria = 0;

  _ServicioPermisosFalso({
    required this.concedido,
    this.alarmasExactas = true,
    this.bateriaOptimizadaIgnorada = true,
  });

  @override
  Future<bool> tienePermisoNotificaciones() async => concedido;

  @override
  Future<bool> puedeProgramarAlarmasExactas() async => alarmasExactas;

  @override
  Future<bool> tieneBateriaOptimizadaIgnorada() async =>
      bateriaOptimizadaIgnorada;

  @override
  Future<bool> solicitarIgnorarOptimizacionBateria() async {
    vecesSolicitadoBateria++;
    return true;
  }

  @override
  Future<void> abrirAjustesDeAlarmasExactas() async {
    vecesAbiertoAlarmas++;
  }

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

  test('permisoAlarmasExactasProvider expone el estado', () async {
    final servicio = _ServicioPermisosFalso(
      concedido: true,
      alarmasExactas: false,
    );
    final container = ProviderContainer(
      overrides: [servicioPermisosProvider.overrideWithValue(servicio)],
    );
    addTearDown(container.dispose);

    final exactas = await container.read(permisoAlarmasExactasProvider.future);
    expect(exactas, isFalse);
  });

  test('optimizacionBateriaIgnoradaProvider expone el estado', () async {
    final servicio = _ServicioPermisosFalso(
      concedido: true,
      bateriaOptimizadaIgnorada: false,
    );
    final container = ProviderContainer(
      overrides: [servicioPermisosProvider.overrideWithValue(servicio)],
    );
    addTearDown(container.dispose);

    final ignorada = await container.read(
      optimizacionBateriaIgnoradaProvider.future,
    );
    expect(ignorada, isFalse);
  });
}
