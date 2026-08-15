import 'package:car_care/domain/maintenance_category.dart';
import 'package:car_care/domain/maintenance_operation_kind.dart';
import 'package:car_care/domain/maintenance_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tiene 175 tipos', () {
    expect(MaintenanceType.values, hasLength(175));
  });

  test('cada categoría tiene al menos un tipo', () {
    for (final categoria in MaintenanceCategory.values) {
      expect(
        MaintenanceType.values.where((t) => t.categoria == categoria),
        isNotEmpty,
        reason: 'La categoría $categoria no tiene ningún tipo asociado',
      );
    }
  });

  test('los tipos resueltos por solapamiento quedan en la categoría '
      'correcta (spec §4)', () {
    expect(MaintenanceType.turbo.categoria, MaintenanceCategory.motor);
    expect(MaintenanceType.egr.categoria, MaintenanceCategory.escapeEmisiones);
    expect(
      MaintenanceType.dpfFap.categoria,
      MaintenanceCategory.escapeEmisiones,
    );
    expect(
      MaintenanceType.catalizador.categoria,
      MaintenanceCategory.escapeEmisiones,
    );
    expect(
      MaintenanceType.sondaLambda.categoria,
      MaintenanceCategory.escapeEmisiones,
    );
    expect(
      MaintenanceType.filtroHabitaculo.categoria,
      MaintenanceCategory.habitaculo,
    );
    expect(MaintenanceType.calentadores.categoria, MaintenanceCategory.motor);
    expect(MaintenanceType.abs.categoria, MaintenanceCategory.frenos);
    expect(MaintenanceType.sensoresAbs.categoria, MaintenanceCategory.frenos);
    expect(MaintenanceType.airbag.categoria, MaintenanceCategory.seguridad);
    expect(MaintenanceType.termostato.categoria, MaintenanceCategory.motor);
    expect(
      MaintenanceType.termostatoClimatizacion.categoria,
      MaintenanceCategory.climatizacion,
    );
  });

  test('turbo sugiere reparación por defecto, pero no es un valor fijo', () {
    expect(MaintenanceType.turbo.defaultKind, MaintenanceOperationKind.reparacion);
  });

  test('las piezas por eje o lado admiten posición', () {
    expect(MaintenanceType.pastillasFreno.admitePosicion, isTrue);
    expect(MaintenanceType.amortiguadores.admitePosicion, isTrue);
    expect(MaintenanceType.neumatico.admitePosicion, isTrue);
  });

  test('el líquido de frenos no admite posición', () {
    expect(MaintenanceType.liquidoFrenos.admitePosicion, isFalse);
  });

  test('cada categoría tiene un tipo "otro" como válvula de escape', () {
    final categoriasConOtro = MaintenanceType.values
        .where((t) => t.defaultKind == MaintenanceOperationKind.otro)
        .map((t) => t.categoria)
        .toSet();
    expect(categoriasConOtro, containsAll(MaintenanceCategory.values));
  });
}
