import 'package:car_care/domain/avisos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final ahora = DateTime(2026, 1, 1);
  final horizonte = DateTime(2027, 1, 1);

  List<AvisoProgramado> calcular(
    List<DatosAviso> datos, {
    double kmPorDia = 50,
    DateTime? ahoraPersonalizado,
  }) {
    return calcularAvisos(
      mantenimientos: datos,
      kmPorDia: kmPorDia,
      ahora: ahoraPersonalizado ?? ahora,
      horizonte: horizonte,
    );
  }

  List<String> nombresDe(AvisoProgramado aviso) =>
      aviso.nombres.map((n) => n.nombre).toList();

  test('sin mantenimientos no hay avisos', () {
    expect(calcular([]), isEmpty);
  });

  test('un mantenimiento por fecha genera aviso de atención y de '
      'vencimiento', () {
    // Vence el 1 de marzo, con 30 días de margen: atención el 30 de enero
    // (marzo 1 menos 30 días exactos: 1 día de enero + 28 de febrero + 1
    // día extra hasta marzo 1 no cuadra en 30 días con el 31 de enero,
    // que solo son 29 días antes de marzo 1; el 30 de enero sí son 30).
    final avisos = calcular([
      DatosAviso(
        nombre: 'Líquido de frenos',
        proximaFecha: DateTime(2026, 3, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
    ]);

    expect(avisos, hasLength(2));
    expect(avisos.first.fecha, DateTime(2026, 1, 30));
    expect(nombresDe(avisos.first), ['Líquido de frenos']);
    expect(avisos.first.nombres.single.tipo, TipoAviso.mantenimientoEnMargen);
    expect(avisos.last.fecha, DateTime(2026, 3, 1));
    expect(avisos.last.nombres.single.tipo, TipoAviso.mantenimientoVencido);
  });

  test('los avisos salen ordenados por fecha', () {
    final avisos = calcular([
      DatosAviso(
        nombre: 'Tardío',
        proximaFecha: DateTime(2026, 6, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
      DatosAviso(
        nombre: 'Temprano',
        proximaFecha: DateTime(2026, 3, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
    ]);

    final fechas = avisos.map((a) => a.fecha).toList();
    final ordenadas = [...fechas]..sort();
    expect(fechas, ordenadas);
  });

  test('dos mantenimientos que caen el mismo día se funden en un aviso', () {
    final avisos = calcular([
      DatosAviso(
        nombre: 'Aceite',
        proximaFecha: DateTime(2026, 3, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
      DatosAviso(
        nombre: 'Filtro de aire',
        proximaFecha: DateTime(2026, 3, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
    ]);

    // Dos fechas distintas (atención y vencimiento), no cuatro avisos.
    expect(avisos, hasLength(2));
    expect(nombresDe(avisos.first), ['Aceite', 'Filtro de aire']);
    expect(nombresDe(avisos.last), ['Aceite', 'Filtro de aire']);
  });

  test('lo que ya venció no genera aviso', () {
    final avisos = calcular([
      DatosAviso(
        nombre: 'Vencido hace tiempo',
        proximaFecha: DateTime(2025, 6, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
    ]);

    expect(avisos, isEmpty);
  });

  test('un mantenimiento ya en atención solo avisa de su vencimiento', () {
    // Vence en 10 días y el margen es de 30: la fecha de atención ya pasó.
    final avisos = calcular([
      DatosAviso(
        nombre: 'Ya en atención',
        proximaFecha: DateTime(2026, 1, 11),
        margenKm: 1000,
        margenDias: 30,
      ),
    ]);

    expect(avisos, hasLength(1));
    expect(avisos.single.fecha, DateTime(2026, 1, 11));
  });

  test('nada más allá del horizonte', () {
    final avisos = calcular([
      DatosAviso(
        nombre: 'Muy lejano',
        proximaFecha: DateTime(2028, 1, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
    ]);

    expect(avisos, isEmpty);
  });

  test('por kilómetros, el margen se traduce a días con el ritmo de uso', () {
    // Alcanza los km el 1 de marzo (59 días). Con 1.000 km de margen a
    // 50 km/día, entra en atención 20 días antes: el 9 de febrero.
    final avisos = calcular([
      DatosAviso(
        nombre: 'Pastillas',
        fechaEstimadaPorKm: DateTime(2026, 3, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
    ]);

    expect(avisos, hasLength(2));
    expect(avisos.first.fecha, DateTime(2026, 2, 9));
    expect(avisos.last.fecha, DateTime(2026, 3, 1));
  });

  test('con las dos vías gana la que llega antes', () {
    // Por fecha vencería el 1 de junio; por km, el 1 de marzo.
    final avisos = calcular([
      DatosAviso(
        nombre: 'Aceite y filtro',
        proximaFecha: DateTime(2026, 6, 1),
        fechaEstimadaPorKm: DateTime(2026, 3, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
    ]);

    expect(avisos.last.fecha, DateTime(2026, 3, 1));
  });

  test('con el coche parado, un mantenimiento solo por km no avisa', () {
    // Sin fechaEstimadaPorKm no hay ninguna fecha con la que programar.
    final avisos = calcular([
      const DatosAviso(nombre: 'Solo km', margenKm: 1000, margenDias: 30),
    ]);

    expect(avisos, isEmpty);
  });

  test('con ritmo cero no se divide por cero al traducir el margen de km', () {
    final avisos = calcular([
      DatosAviso(
        nombre: 'Pastillas',
        fechaEstimadaPorKm: DateTime(2026, 3, 1),
        margenKm: 1000,
        margenDias: 30,
      ),
    ], kmPorDia: 0);

    // El vencimiento sigue siendo programable aunque el margen por km no se
    // pueda traducir a días.
    expect(avisos.map((a) => a.fecha), contains(DateTime(2026, 3, 1)));
    expect(avisos.every((a) => a.fecha.isAfter(ahora)), isTrue);
  });

  test('un aviso que cae hoy se conserva, no solo lo que cae después', () {
    // "ahora" incluye una hora del día (las 8:00): el vencimiento cae
    // exactamente hoy. Antes se descartaba por comparar por instante en
    // vez de por día natural, perdiendo el aviso del propio día.
    final avisos = calcular([
      DatosAviso(
        nombre: 'Justo hoy',
        proximaFecha: DateTime(2026, 1, 1),
        margenKm: 1000,
        margenDias: 0,
      ),
    ], ahoraPersonalizado: DateTime(2026, 1, 1, 8));

    expect(avisos, hasLength(1));
    expect(avisos.single.fecha, DateTime(2026, 1, 1));
  });

  test('con margen de 0 días no se duplica el nombre el mismo día', () {
    final avisos = calcular([
      DatosAviso(
        nombre: 'Aceite',
        proximaFecha: DateTime(2026, 3, 1),
        margenKm: 1000,
        margenDias: 0,
      ),
    ]);

    // Atención y vencimiento coinciden en el mismo día: un aviso, no dos, y
    // sin el nombre repetido dentro de él.
    expect(avisos, hasLength(1));
    expect(nombresDe(avisos.single), ['Aceite']);
    expect(avisos.single.nombres.single.tipo, TipoAviso.mantenimientoVencido);
  });

  group('cuerpoDeAviso', () {
    test('un recordatorio de kilometraje no habla de mantenimientos', () {
      final texto = cuerpoDeAviso(
        AvisoProgramado(
          fecha: DateTime(2026, 1, 1),
          nombres: const [
            NombreAviso(
              nombre: 'Actualiza el kilometraje',
              tipo: TipoAviso.recordatorioLectura,
            ),
          ],
        ),
      );

      expect(texto, isNot(contains('mantenimiento')));
      expect(texto, contains('kilometraje'));
    });

    test('un vencimiento dice que ha vencido, no que necesita atención', () {
      final texto = cuerpoDeAviso(
        AvisoProgramado(
          fecha: DateTime(2026, 1, 1),
          nombres: const [
            NombreAviso(nombre: 'Aceite', tipo: TipoAviso.mantenimientoVencido),
          ],
        ),
      );

      expect(texto, contains('vencido'));
      expect(texto, isNot(contains('necesita atención')));
    });

    test('lo que está en margen sigue diciendo que necesita atención', () {
      final texto = cuerpoDeAviso(
        AvisoProgramado(
          fecha: DateTime(2026, 1, 1),
          nombres: const [
            NombreAviso(
              nombre: 'Aceite',
              tipo: TipoAviso.mantenimientoEnMargen,
            ),
          ],
        ),
      );

      expect(texto, contains('necesita atención'));
    });
  });
}
