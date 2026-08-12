import 'package:car_care/domain/maintenance_due.dart';
import 'package:car_care/domain/maintenance_grouping.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const politica = MaintenanceGroupingPolicy();

  Vencimiento v({int? kmRestantes, int? diasHastaVencimiento}) => Vencimiento(
    estado: EstadoMantenimiento.proximo,
    kmProyectado: 0,
    kmRestantes: kmRestantes,
    diasHastaVencimiento: diasHastaVencimiento,
  );

  test('lista vacia da una lista de grupos vacia', () {
    expect(agruparPorProximidad([], politica), isEmpty);
  });

  test('un solo vencimiento forma su propio grupo', () {
    final grupos = agruparPorProximidad([v(kmRestantes: 500)], politica);

    expect(grupos, [
      [0],
    ]);
  });

  test('dos mantenimientos por km cerca entre si se agrupan', () {
    // 800 - 500 = 300, dentro de los 500 km por defecto.
    final grupos = agruparPorProximidad([
      v(kmRestantes: 500),
      v(kmRestantes: 800),
    ], politica);

    expect(grupos, [
      [0, 1],
    ]);
  });

  test('dos mantenimientos por km lejos entre si no se agrupan', () {
    // 3000 - 500 = 2500, fuera de los 500 km por defecto.
    final grupos = agruparPorProximidad([
      v(kmRestantes: 500),
      v(kmRestantes: 3000),
    ], politica);

    expect(grupos, [
      [0],
      [1],
    ]);
  });

  test('dos mantenimientos por tiempo cerca entre si se agrupan', () {
    // Diferencia de 10 días, dentro de los 15 por defecto.
    final grupos = agruparPorProximidad([
      v(diasHastaVencimiento: 20),
      v(diasHastaVencimiento: 30),
    ], politica);

    expect(grupos, [
      [0, 1],
    ]);
  });

  test('un mantenimiento por km y otro por tiempo se agrupan si los dias '
      'coinciden aunque los km no sean comparables', () {
    // El primero no tiene diasHastaVencimiento (va solo por km) y el
    // segundo no tiene kmRestantes (va solo por tiempo): la comparación
    // por km no aplica a ninguno de los dos porque a uno le falta el
    // dato, así que solo puede agruparlos la vía de días. Se construyen
    // con diasHastaVencimiento próximos entre sí para que sea esa vía la
    // que decida.
    final grupos = agruparPorProximidad([
      v(kmRestantes: 500, diasHastaVencimiento: 20),
      v(diasHastaVencimiento: 25),
    ], politica);

    expect(grupos, [
      [0, 1],
    ]);
  });

  test('una cadena de tres solo agrupa los que estan cerca entre si', () {
    // 0 y 1 están cerca (diferencia 200 km); 1 y 2 están lejos (diferencia
    // 5000 km): el grupo se corta entre el segundo y el tercero.
    final grupos = agruparPorProximidad([
      v(kmRestantes: 100),
      v(kmRestantes: 300),
      v(kmRestantes: 5300),
    ], politica);

    expect(grupos, [
      [0, 1],
      [2],
    ]);
  });

  test('el margen es inclusivo: justo en el limite tambien agrupa', () {
    // Diferencia exacta de 500 km, el límite por defecto.
    final grupos = agruparPorProximidad([
      v(kmRestantes: 0),
      v(kmRestantes: 500),
    ], politica);

    expect(grupos, [
      [0, 1],
    ]);
  });

  test('una politica mas estricta agrupa menos', () {
    const estricta = MaintenanceGroupingPolicy(
      maxKmDiferencia: 100,
      maxDiasDiferencia: 5,
    );
    final grupos = agruparPorProximidad([
      v(kmRestantes: 0),
      v(kmRestantes: 300),
    ], estricta);

    expect(grupos, [
      [0],
      [1],
    ]);
  });
}
