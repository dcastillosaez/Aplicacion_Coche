import 'package:car_care/domain/itv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('periodicidad', () {
    test('menos de cuatro anios esta exento', () {
      expect(mesesEntreItv(DateTime(2024, 1, 1), DateTime(2026, 8, 10)), 0);
    });

    test('de cuatro a diez anios toca cada dos anios', () {
      expect(mesesEntreItv(DateTime(2018, 1, 1), DateTime(2026, 8, 10)), 24);
    });

    test('pasados diez anios toca cada anio', () {
      expect(mesesEntreItv(DateTime(2009, 1, 1), DateTime(2026, 8, 10)), 12);
    });

    test('el limite de los diez anios cuenta el dia exacto', () {
      expect(mesesEntreItv(DateTime(2016, 8, 10), DateTime(2026, 8, 10)), 12);
      expect(mesesEntreItv(DateTime(2016, 8, 11), DateTime(2026, 8, 10)), 24);
    });

    test(
        'un vehiculo matriculado el 29 de febrero no desborda el aniversario '
        'a marzo', () {
      // 2016 fue bisiesto y 2026 no: el aniversario de los diez años cae el
      // 28 de febrero, no se desborda al 1 de marzo.
      expect(mesesEntreItv(DateTime(2016, 2, 29), DateTime(2026, 2, 28)), 12);
      expect(mesesEntreItv(DateTime(2016, 2, 29), DateTime(2026, 2, 27)), 24);
    });
  });

  group('proxima inspeccion', () {
    test('sin fecha de matriculacion no se puede calcular', () {
      expect(proximaItv(fechaMatriculacion: null), isNull);
    });

    test('sin inspecciones previas toca a los cuatro anios de matricular',
        () {
      expect(
        proximaItv(fechaMatriculacion: DateTime(2023, 5, 20)),
        DateTime(2027, 5, 20),
      );
    });

    test('un coche joven suma dos anios a la ultima inspeccion', () {
      expect(
        proximaItv(
          fechaMatriculacion: DateTime(2018, 3, 1),
          ultimaItv: DateTime(2025, 3, 1),
        ),
        DateTime(2027, 3, 1),
      );
    });

    test('un coche de mas de diez anios suma uno', () {
      expect(
        proximaItv(
          fechaMatriculacion: DateTime(2009, 6, 15),
          ultimaItv: DateTime(2026, 6, 15),
        ),
        DateTime(2027, 6, 15),
      );
    });

    test(
        'con una ultima itv incoherente anterior a la exencion, la primera '
        'es fija a los cuatro anios', () {
      // Matriculado 2024-01-01: el coche seguía exento el 2027-09-01, así
      // que esa fecha no puede ser el punto de partida. La primera ITV
      // obligatoria es 2028-01-01, independientemente de ultimaItv.
      expect(
        proximaItv(
          fechaMatriculacion: DateTime(2024, 1, 1),
          ultimaItv: DateTime(2027, 9, 1),
        ),
        DateTime(2028, 1, 1),
      );
    });
  });
}
