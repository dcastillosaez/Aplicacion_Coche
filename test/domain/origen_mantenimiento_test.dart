import 'package:car_care/domain/origen_mantenimiento.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sin ningun registro, el origen es desconocido', () {
    expect(calcularOrigen(null), OrigenMantenimiento.desconocido);
  });

  test('con el ultimo registro sembrado, el origen es historico', () {
    expect(calcularOrigen(true), OrigenMantenimiento.historico);
  });

  test('con el ultimo registro real, el origen es confirmado', () {
    expect(calcularOrigen(false), OrigenMantenimiento.confirmado);
  });
}
