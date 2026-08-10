import 'package:car_care/domain/maintenance_due.dart';
import 'package:car_care/domain/usage_rate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ahora = DateTime(2026, 8, 10);
  const ritmoMedido = UsageRateResult(kmPorDia: 50, esPorDefecto: false);
  const ritmoPorDefecto =
      UsageRateResult(kmPorDia: kRitmoPorDefecto, esPorDefecto: true);
  const cocheParado = UsageRateResult(kmPorDia: 0.2, esPorDefecto: false);

  Vencimiento calcular({
    int? intervalKm,
    int? intervalMeses,
    int? avisoKm,
    int? avisoDias,
    int? ultimoKm,
    DateTime? ultimaFecha,
    int kmActual = 100000,
    DateTime? fechaUltimaLectura,
    UsageRateResult ritmo = ritmoMedido,
  }) {
    return calcularVencimiento(
      datos: DatosVencimiento(
        intervalKm: intervalKm,
        intervalMeses: intervalMeses,
        avisoKm: avisoKm,
        avisoDias: avisoDias,
        ultimoKm: ultimoKm,
        ultimaFecha: ultimaFecha,
      ),
      kmActual: kmActual,
      fechaUltimaLectura: fechaUltimaLectura ?? ahora,
      ritmo: ritmo,
      ahora: ahora,
      avisoKmPorDefecto: 1000,
      avisoDiasPorDefecto: 30,
    );
  }

  test('sin ningun mantenimiento previo queda sin configurar', () {
    final v = calcular(intervalKm: 15000);

    expect(v.estado, EstadoMantenimiento.sinConfigurar);
    expect(v.proximoKm, isNull);
    expect(v.proximaFecha, isNull);
  });

  test('calcula el proximo kilometraje sumando el intervalo al ultimo', () {
    final v = calcular(intervalKm: 15000, ultimoKm: 135000,
        ultimaFecha: DateTime(2026, 5, 10));

    expect(v.proximoKm, 150000);
  });

  test('calcula la proxima fecha sumando los meses del intervalo', () {
    final v = calcular(intervalMeses: 12, ultimoKm: 135000,
        ultimaFecha: DateTime(2026, 5, 10));

    expect(v.proximaFecha, DateTime(2027, 5, 10));
  });

  test('esta ok cuando falta mucho por ambas vias', () {
    final v = calcular(
      intervalKm: 15000,
      intervalMeses: 12,
      ultimoKm: 99000,
      ultimaFecha: DateTime(2026, 8, 1),
    );

    expect(v.estado, EstadoMantenimiento.ok);
  });

  test('esta vencido cuando se ha pasado de kilometros', () {
    final v = calcular(intervalKm: 15000, ultimoKm: 80000,
        ultimaFecha: DateTime(2025, 1, 1), kmActual: 96000);

    expect(v.estado, EstadoMantenimiento.vencido);
    expect(v.kmRestantes, lessThanOrEqualTo(0));
  });

  test('esta vencido cuando se ha pasado de fecha aunque sobren kilometros',
      () {
    final v = calcular(
      intervalMeses: 12,
      ultimoKm: 99000,
      ultimaFecha: DateTime(2025, 1, 1),
    );

    expect(v.estado, EstadoMantenimiento.vencido);
  });

  test('pide atencion cuando entra en el margen de kilometros', () {
    // Faltan 800 km, el margen por defecto son 1.000.
    final v = calcular(intervalKm: 15000, ultimoKm: 85000,
        ultimaFecha: DateTime(2026, 8, 10), kmActual: 99200);

    expect(v.estado, EstadoMantenimiento.atencion);
  });

  test('pide atencion cuando entra en el margen de dias', () {
    // Vence en 20 días, el margen por defecto son 30.
    final v = calcular(
      intervalMeses: 12,
      ultimoKm: 99000,
      ultimaFecha: DateTime(2025, 8, 30),
    );

    expect(v.estado, EstadoMantenimiento.atencion);
  });

  test('avisa como proximo dentro del doble del margen', () {
    // Faltan 1.500 km: fuera del margen de 1.000, dentro de 2.000.
    final v = calcular(intervalKm: 15000, ultimoKm: 85500,
        ultimaFecha: DateTime(2026, 8, 10), kmActual: 99000);

    expect(v.estado, EstadoMantenimiento.proximo);
  });

  test('respeta el margen propio del mantenimiento sobre el general', () {
    // Faltan 1.500 km y el margen propio son 2.000: ya pide atención.
    final v = calcular(intervalKm: 15000, avisoKm: 2000, ultimoKm: 85500,
        ultimaFecha: DateTime(2026, 8, 10), kmActual: 99000);

    expect(v.estado, EstadoMantenimiento.atencion);
  });

  test('gana el vencimiento que llegue antes de los dos', () {
    // Por kilómetros faltarían 10.000 (200 días al ritmo actual), pero por
    // fecha vence en 10 días.
    final v = calcular(
      intervalKm: 15000,
      intervalMeses: 12,
      ultimoKm: 90000,
      ultimaFecha: DateTime(2025, 8, 20),
    );

    expect(v.estado, EstadoMantenimiento.atencion);
    expect(v.venceAntesPorFecha, isTrue);
  });

  test('proyecta los kilometros desde la ultima lectura con el ritmo', () {
    // Última lectura hace 10 días a 99.000 km, a 50 km/día: hoy ≈ 99.500.
    final v = calcular(
      intervalKm: 15000,
      ultimoKm: 90000,
      ultimaFecha: DateTime(2026, 1, 1),
      kmActual: 99000,
      fechaUltimaLectura: DateTime(2026, 7, 31),
    );

    expect(v.kmProyectado, 99500);
    expect(v.kmRestantes, 105000 - 99500);
  });

  test('con el coche parado no estima fecha por kilometros', () {
    final v = calcular(
      intervalKm: 15000,
      ultimoKm: 90000,
      ultimaFecha: DateTime(2026, 1, 1),
      ritmo: cocheParado,
    );

    expect(v.fechaEstimadaPorKm, isNull);
  });

  test('con el ritmo por defecto la estimacion se marca como supuesta', () {
    final v = calcular(
      intervalKm: 15000,
      ultimoKm: 90000,
      ultimaFecha: DateTime(2026, 1, 1),
      ritmo: ritmoPorDefecto,
    );

    expect(v.fechaEstimadaPorKm, isNotNull);
    expect(v.estimacionEsSupuesta, isTrue);
  });

  test('solo con intervalo de kilometros no calcula fecha de vencimiento', () {
    final v = calcular(intervalKm: 15000, ultimoKm: 99000,
        ultimaFecha: DateTime(2026, 8, 1));

    expect(v.proximaFecha, isNull);
    expect(v.diasRestantes, isNull);
    expect(v.proximoKm, isNotNull);
  });

  test('solo con intervalo de tiempo no calcula kilometraje de vencimiento',
      () {
    final v = calcular(intervalMeses: 12, ultimoKm: 99000,
        ultimaFecha: DateTime(2026, 8, 1));

    expect(v.proximoKm, isNull);
    expect(v.kmRestantes, isNull);
    expect(v.proximaFecha, isNotNull);
  });

  test('sumar meses no desborda a un dia inexistente', () {
    // 31 de enero más un mes: 28 de febrero, no el 3 de marzo.
    final v = calcular(intervalMeses: 1, ultimoKm: 99000,
        ultimaFecha: DateTime(2026, 1, 31));

    expect(v.proximaFecha, DateTime(2026, 2, 28));
  });

  test(
      'diasNaturalesEntre no pierde un dia en el cambio de hora de '
      'primavera', () {
    // El cambio de hora de 2026 en España es el 29 de marzo: los relojes
    // adelantan de 02:00 a 03:00. Sin normalizar a UTC, la resta de dos
    // medianoches locales pierde esa hora y el resultado trunca a 30 en
    // vez de 31.
    expect(diasNaturalesEntre(DateTime(2026, 3, 1), DateTime(2026, 4, 1)), 31);
  });
}
