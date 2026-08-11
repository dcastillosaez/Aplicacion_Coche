import 'package:car_care/data/tables/vehicles.dart';
import 'package:car_care/domain/plantillas_mantenimiento.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('un diesel incluye filtro de combustible y no bujias', () {
    final p = plantillasPara(
        combustible: FuelType.diesel, esAutomatico: false);
    final nombres = p.map((e) => e.nombre).toList();

    expect(nombres, contains('Filtro de combustible'));
    expect(nombres, isNot(contains('Bujías')));
  });

  test('un gasolina incluye bujias', () {
    final p = plantillasPara(
        combustible: FuelType.gasolina, esAutomatico: false);

    expect(p.map((e) => e.nombre), contains('Bujías'));
  });

  test('un electrico no incluye aceite de motor', () {
    final p = plantillasPara(
        combustible: FuelType.electrico, esAutomatico: false);

    expect(p.map((e) => e.nombre), isNot(contains('Aceite y filtro')));
  });

  test('un cambio automatico añade el aceite de la caja', () {
    final p = plantillasPara(combustible: FuelType.diesel, esAutomatico: true);

    expect(p.map((e) => e.nombre), contains('Aceite de la caja automática'));
  });

  test('la distribucion se propone sin intervalo, para que lo ponga el dueño',
      () {
    final p = plantillasPara(
        combustible: FuelType.diesel, esAutomatico: false);
    final distribucion =
        p.firstWhere((e) => e.nombre == 'Correa o cadena de distribución');

    expect(distribucion.intervalKm, isNull);
    expect(distribucion.intervalMeses, isNull);
  });

  test('la itv de un coche de mas de diez anios se propone anual', () {
    final p = plantillasPara(
      combustible: FuelType.diesel,
      esAutomatico: false,
      fechaMatriculacion: DateTime(2009, 1, 1),
    );
    final itv = p.firstWhere((e) => e.nombre == 'ITV');

    expect(itv.intervalMeses, 12);
  });

  test('la itv de un coche de entre cuatro y diez anios se propone bienal',
      () {
    final p = plantillasPara(
      combustible: FuelType.diesel,
      esAutomatico: false,
      fechaMatriculacion: DateTime(2018, 1, 1),
    );
    final itv = p.firstWhere((e) => e.nombre == 'ITV');

    expect(itv.intervalMeses, 24);
  });
}
