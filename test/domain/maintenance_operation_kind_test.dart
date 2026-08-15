import 'package:car_care/domain/maintenance_operation_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tiene los cinco valores esperados', () {
    expect(MaintenanceOperationKind.values, hasLength(5));
    expect(
      MaintenanceOperationKind.values.map((k) => k.name),
      containsAll(['preventivo', 'inspeccion', 'reparacion', 'sustitucion', 'otro']),
    );
  });
}
