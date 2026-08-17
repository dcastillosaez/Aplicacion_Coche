import 'package:car_care/providers/permisos_providers.dart';
import 'package:car_care/providers/recalculo_al_reanudar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'permisoNotificacionesProvider se recalcula al volver a primer plano',
    () {
      expect(
        providersARecalcularAlReanudar,
        contains(permisoNotificacionesProvider),
      );
    },
  );
}
