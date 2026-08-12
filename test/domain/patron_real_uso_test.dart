import 'package:car_care/domain/patron_real_uso.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sin ningun registro no hay patron', () {
    expect(calcularPatronReal([]), isNull);
  });

  test('con un solo registro no hay patron', () {
    expect(
      calcularPatronReal([(fecha: DateTime(2026, 1, 1), km: 90000)]),
      isNull,
    );
  });

  test('con dos registros calcula el intervalo entre ellos', () {
    // Del 1 de enero de 2025 al 1 de enero de 2026: 365 días (2025 no es
    // bisiesto), 15.000 km de diferencia.
    final patron = calcularPatronReal([
      (fecha: DateTime(2025, 1, 1), km: 80000),
      (fecha: DateTime(2026, 1, 1), km: 95000),
    ]);

    expect(patron!.kmMedioEntreCambios, 15000);
    expect(patron.diasMedioEntreCambios, 365);
  });

  test('con tres registros promedia los dos intervalos', () {
    // 2024-01-01 a 2025-01-01: 366 días (2024 es bisiesto), 15.000 km.
    // 2025-01-01 a 2026-01-01: 365 días, 14.000 km.
    // Media: (15000+14000)/2 = 14500 km; (366+365)/2 = 365,5 días.
    final patron = calcularPatronReal([
      (fecha: DateTime(2024, 1, 1), km: 60000),
      (fecha: DateTime(2025, 1, 1), km: 75000),
      (fecha: DateTime(2026, 1, 1), km: 89000),
    ]);

    expect(patron!.kmMedioEntreCambios, 14500);
    expect(patron.diasMedioEntreCambios, 365.5);
  });

  test('el orden de la lista de entrada no importa', () {
    final ordenNatural = calcularPatronReal([
      (fecha: DateTime(2025, 1, 1), km: 80000),
      (fecha: DateTime(2026, 1, 1), km: 95000),
    ]);
    final ordenInvertido = calcularPatronReal([
      (fecha: DateTime(2026, 1, 1), km: 95000),
      (fecha: DateTime(2025, 1, 1), km: 80000),
    ]);

    expect(
      ordenInvertido!.kmMedioEntreCambios,
      ordenNatural!.kmMedioEntreCambios,
    );
    expect(
      ordenInvertido.diasMedioEntreCambios,
      ordenNatural.diasMedioEntreCambios,
    );
  });
}
