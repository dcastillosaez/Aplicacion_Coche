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
  });
}
