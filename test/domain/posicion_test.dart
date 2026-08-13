import 'package:car_care/domain/posicion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tiene los diez valores esperados', () {
    expect(Posicion.values, hasLength(10));
    expect(
      Posicion.values.map((p) => p.name),
      containsAll([
        'delantera', 'trasera', 'izquierda', 'derecha',
        'delanteraIzquierda', 'delanteraDerecha',
        'traseraIzquierda', 'traseraDerecha',
        'ejeDelantero', 'ejeTrasero',
      ]),
    );
  });
}
