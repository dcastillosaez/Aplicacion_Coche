import 'package:car_care/domain/gastos.dart';
import 'package:car_care/domain/maintenance_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sin registros da un resumen vacío', () {
    final r = calcularResumenGastos([]);

    expect(r.total, 0);
    expect(r.porAnio, isEmpty);
    expect(r.porCategoria, isEmpty);
    expect(r.registrosSinCoste, 0);
  });

  test('suma los costes de un mismo año en una sola entrada', () {
    final r = calcularResumenGastos([
      (fecha: DateTime(2026, 1, 15), coste: 120.50, categoria: null),
      (fecha: DateTime(2026, 7, 3), coste: 79.50, categoria: null),
    ]);

    expect(r.total, 200);
    expect(r.porAnio, hasLength(1));
    expect(r.porAnio.single.anio, 2026);
    expect(r.porAnio.single.total, 200);
  });

  test('ordena los años del más reciente al más antiguo', () {
    final r = calcularResumenGastos([
      (fecha: DateTime(2024, 5, 1), coste: 10, categoria: null),
      (fecha: DateTime(2026, 5, 1), coste: 30, categoria: null),
      (fecha: DateTime(2025, 5, 1), coste: 20, categoria: null),
    ]);

    expect(r.porAnio.map((g) => g.anio), [2026, 2025, 2024]);
    expect(r.porAnio.map((g) => g.total), [30, 20, 10]);
    expect(r.total, 60);
  });

  test('los registros sin coste no suman, pero se cuentan', () {
    final r = calcularResumenGastos([
      (fecha: DateTime(2026, 1, 1), coste: 50, categoria: null),
      (fecha: DateTime(2026, 2, 1), coste: null, categoria: null),
      (fecha: DateTime(2026, 3, 1), coste: null, categoria: null),
    ]);

    expect(r.total, 50);
    expect(r.registrosSinCoste, 2);
    expect(r.porAnio.single.total, 50);
  });

  test('un año en el que solo hay registros sin coste no aparece', () {
    final r = calcularResumenGastos([
      (fecha: DateTime(2026, 1, 1), coste: 50, categoria: null),
      (fecha: DateTime(2025, 1, 1), coste: null, categoria: null),
    ]);

    expect(r.porAnio.map((g) => g.anio), [2026]);
    expect(r.registrosSinCoste, 1);
  });

  test('un coste de cero cuenta como coste anotado, no como ausencia', () {
    final r = calcularResumenGastos([
      (fecha: DateTime(2026, 1, 1), coste: 0, categoria: null),
    ]);

    expect(r.registrosSinCoste, 0);
    expect(r.porAnio, hasLength(1));
    expect(r.porAnio.single.total, 0);
  });

  test('agrega y ordena los gastos por categoría de mayor a menor importe', () {
    final r = calcularResumenGastos([
      (
        fecha: DateTime(2026, 1, 1),
        coste: 80,
        categoria: MaintenanceCategory.frenos,
      ),
      (
        fecha: DateTime(2026, 2, 1),
        coste: 120,
        categoria: MaintenanceCategory.motor,
      ),
      (
        fecha: DateTime(2026, 3, 1),
        coste: 50,
        categoria: MaintenanceCategory.motor,
      ),
      (
        fecha: DateTime(2026, 4, 1),
        coste: 45,
        categoria: MaintenanceCategory.itv,
      ),
      (
        fecha: DateTime(2026, 5, 1),
        coste: null,
        categoria: MaintenanceCategory.neumaticos,
      ),
    ]);

    expect(r.total, 295);
    expect(r.registrosSinCoste, 1);
    expect(r.porCategoria, hasLength(3));

    // Motor: 120 + 50 = 170 (2 operaciones)
    expect(r.porCategoria[0].categoria, MaintenanceCategory.motor);
    expect(r.porCategoria[0].total, 170);
    expect(r.porCategoria[0].cantidad, 2);

    // Frenos: 80 (1 operación)
    expect(r.porCategoria[1].categoria, MaintenanceCategory.frenos);
    expect(r.porCategoria[1].total, 80);
    expect(r.porCategoria[1].cantidad, 1);

    // ITV: 45 (1 operación)
    expect(r.porCategoria[2].categoria, MaintenanceCategory.itv);
    expect(r.porCategoria[2].total, 45);
    expect(r.porCategoria[2].cantidad, 1);
  });
}
