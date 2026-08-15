import 'package:car_care/domain/gastos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sin registros da un resumen vacío', () {
    final r = calcularResumenGastos([]);

    expect(r.total, 0);
    expect(r.porAnio, isEmpty);
    expect(r.registrosSinCoste, 0);
  });

  test('suma los costes de un mismo año en una sola entrada', () {
    final r = calcularResumenGastos([
      (fecha: DateTime(2026, 1, 15), coste: 120.50),
      (fecha: DateTime(2026, 7, 3), coste: 79.50),
    ]);

    expect(r.total, 200);
    expect(r.porAnio, hasLength(1));
    expect(r.porAnio.single.anio, 2026);
    expect(r.porAnio.single.total, 200);
  });

  test('ordena los años del más reciente al más antiguo', () {
    final r = calcularResumenGastos([
      (fecha: DateTime(2024, 5, 1), coste: 10),
      (fecha: DateTime(2026, 5, 1), coste: 30),
      (fecha: DateTime(2025, 5, 1), coste: 20),
    ]);

    expect(r.porAnio.map((g) => g.anio), [2026, 2025, 2024]);
    expect(r.porAnio.map((g) => g.total), [30, 20, 10]);
    expect(r.total, 60);
  });

  test('los registros sin coste no suman, pero se cuentan', () {
    final r = calcularResumenGastos([
      (fecha: DateTime(2026, 1, 1), coste: 50),
      (fecha: DateTime(2026, 2, 1), coste: null),
      (fecha: DateTime(2026, 3, 1), coste: null),
    ]);

    expect(r.total, 50);
    expect(r.registrosSinCoste, 2);
    expect(r.porAnio.single.total, 50);
  });

  test('un año en el que solo hay registros sin coste no aparece', () {
    // Si apareciera con total 0, se leería como "ese año no gasté nada",
    // que es justo lo contrario de lo que la app sabe: no lo apunté.
    final r = calcularResumenGastos([
      (fecha: DateTime(2026, 1, 1), coste: 50),
      (fecha: DateTime(2025, 1, 1), coste: null),
    ]);

    expect(r.porAnio.map((g) => g.anio), [2026]);
    expect(r.registrosSinCoste, 1);
  });

  test('un coste de cero cuenta como coste anotado, no como ausencia', () {
    // Un mantenimiento que salió gratis (garantía, favor de un amigo) es un
    // dato real, distinto de no haber apuntado nada.
    final r = calcularResumenGastos([(fecha: DateTime(2026, 1, 1), coste: 0)]);

    expect(r.registrosSinCoste, 0);
    expect(r.porAnio, hasLength(1));
    expect(r.porAnio.single.total, 0);
  });
}
