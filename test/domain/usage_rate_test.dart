import 'package:car_care/domain/usage_rate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ahora = DateTime(2026, 8, 9);

  test('sin lecturas devuelve el ritmo por defecto', () {
    final r = UsageRate.calcular(lecturas: const [], ahora: ahora);

    expect(r.kmPorDia, kRitmoPorDefecto);
    expect(r.esPorDefecto, isTrue);
  });

  test('con una sola lectura devuelve el ritmo por defecto', () {
    final r = UsageRate.calcular(
      lecturas: [MileagePoint(fecha: DateTime(2026, 7, 1), km: 90000)],
      ahora: ahora,
    );

    expect(r.esPorDefecto, isTrue);
  });

  test('calcula el ritmo entre la lectura mas antigua y la mas reciente', () {
    final r = UsageRate.calcular(
      lecturas: [
        MileagePoint(fecha: DateTime(2026, 7, 10), km: 90000),
        MileagePoint(fecha: DateTime(2026, 8, 9), km: 91500),
      ],
      ahora: ahora,
    );

    // 1.500 km en 30 días
    expect(r.kmPorDia, closeTo(50.0, 0.001));
    expect(r.esPorDefecto, isFalse);
  });

  test('ignora las lecturas anteriores a la ventana de 90 dias', () {
    final r = UsageRate.calcular(
      lecturas: [
        MileagePoint(fecha: DateTime(2025, 1, 1), km: 10000),
        MileagePoint(fecha: DateTime(2026, 7, 10), km: 90000),
        MileagePoint(fecha: DateTime(2026, 8, 9), km: 91500),
      ],
      ahora: ahora,
    );

    expect(r.kmPorDia, closeTo(50.0, 0.001));
  });

  test('lecturas demasiado juntas no bastan para calcular el ritmo', () {
    final r = UsageRate.calcular(
      lecturas: [
        MileagePoint(fecha: DateTime(2026, 8, 6), km: 90000),
        MileagePoint(fecha: DateTime(2026, 8, 9), km: 90300),
      ],
      ahora: ahora,
    );

    expect(r.esPorDefecto, isTrue);
  });

  test('el orden de la lista no afecta al resultado', () {
    final r = UsageRate.calcular(
      lecturas: [
        MileagePoint(fecha: DateTime(2026, 8, 9), km: 91500),
        MileagePoint(fecha: DateTime(2026, 7, 10), km: 90000),
      ],
      ahora: ahora,
    );

    expect(r.kmPorDia, closeTo(50.0, 0.001));
  });

  test('un coche parado se detecta como tal', () {
    final r = UsageRate.calcular(
      lecturas: [
        MileagePoint(fecha: DateTime(2026, 6, 1), km: 90000),
        MileagePoint(fecha: DateTime(2026, 8, 9), km: 90020),
      ],
      ahora: ahora,
    );

    expect(r.cocheParado, isTrue);
    expect(r.esPorDefecto, isFalse);
  });

  test('el ritmo por defecto nunca se considera coche parado', () {
    final r = UsageRate.calcular(lecturas: const [], ahora: ahora);

    expect(r.cocheParado, isFalse);
  });

  test('un retroceso de kilometros no produce un ritmo negativo', () {
    final r = UsageRate.calcular(
      lecturas: [
        MileagePoint(fecha: DateTime(2026, 7, 1), km: 95000),
        MileagePoint(fecha: DateTime(2026, 8, 9), km: 90000),
      ],
      ahora: ahora,
    );

    expect(r.esPorDefecto, isTrue);
    expect(r.kmPorDia, greaterThan(0));
  });
}
