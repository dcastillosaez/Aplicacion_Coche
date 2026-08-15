import 'package:car_care/data/database.dart';
import 'package:car_care/data/tables/vehicles.dart';
import 'package:car_care/providers/gastos_providers.dart';
import 'package:car_care/providers/mantenimiento_providers.dart';
import 'package:car_care/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Vehicle _vehiculo(int id, String modelo) => Vehicle(
  id: id,
  marca: 'Seat',
  modelo: modelo,
  combustible: FuelType.diesel,
  creadoEn: DateTime(2026, 1, 1),
  archivado: false,
);

MaintenanceRecord _registro({
  required int id,
  required int vehicleId,
  required double coste,
}) => MaintenanceRecord(
  id: id,
  vehicleId: vehicleId,
  fecha: DateTime(2026, 1, 1),
  km: 10000,
  coste: coste,
  esSembrado: false,
);

void main() {
  test(
    'atribuye cada registro solo al coche cuyo vehicleId coincide',
    () async {
      final coche1 = _vehiculo(1, 'León');
      final coche2 = _vehiculo(2, 'Ibiza');
      final registro1 = _registro(id: 1, vehicleId: 1, coste: 100);
      final registro2 = _registro(id: 2, vehicleId: 2, coste: 50);

      final container = ProviderContainer(
        overrides: [
          vehiculosProvider.overrideWith(
            (ref) => Stream.value([coche1, coche2]),
          ),
          historialProvider.overrideWith(
            (ref) => Stream.value([registro1, registro2]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final gastos = await container.read(gastosProvider.future);

      expect(gastos, hasLength(2));
      expect(gastos[0].vehiculo.id, 1);
      expect(gastos[0].resumen.total, 100);
      expect(gastos[1].vehiculo.id, 2);
      expect(gastos[1].resumen.total, 50);
    },
  );

  test('un registro de un vehiculo que ya no esta activo no se cuenta en '
      'ningun coche', () async {
    final coche1 = _vehiculo(1, 'León');
    // Registro de un vehículo archivado (vehicleId 99): no está en la
    // lista de vehiculosProvider, que solo devuelve los activos.
    final registroArchivado = _registro(id: 1, vehicleId: 99, coste: 500);

    final container = ProviderContainer(
      overrides: [
        vehiculosProvider.overrideWith((ref) => Stream.value([coche1])),
        historialProvider.overrideWith(
          (ref) => Stream.value([registroArchivado]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final gastos = await container.read(gastosProvider.future);

    expect(gastos, hasLength(1));
    expect(gastos[0].vehiculo.id, 1);
    expect(gastos[0].resumen.total, 0);
    expect(gastos[0].resumen.porAnio, isEmpty);
  });
}
