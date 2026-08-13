import 'package:car_care/domain/potencia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('convierte kilovatios a caballos de vapor métricos', () {
    // 1 kW = 1,35962 CV. 140 kW es la potencia real de ejemplo del roadmap.
    expect(kwACv(140), 190);
  });

  test('redondea al entero mas cercano, no trunca', () {
    // 100 kW = 135,962 CV -> redondea a 136, no a 135.
    expect(kwACv(100), 136);
  });

  test('cero kilovatios da cero CV', () {
    expect(kwACv(0), 0);
  });
}
