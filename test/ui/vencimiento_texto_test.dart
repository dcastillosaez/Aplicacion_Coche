import 'package:car_care/domain/maintenance_due.dart';
import 'package:car_care/ui/common/vencimiento_texto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('necesitaAvisoRitmoSupuesto', () {
    test('avisa cuando el mismo vencimiento tiene cifra por km y esa '
        'estimación se apoya en el ritmo supuesto', () {
      const v = Vencimiento(
        estado: EstadoMantenimiento.atencion,
        kmProyectado: 14200,
        kmRestantes: 800,
        estimacionEsSupuesta: true,
      );

      expect(necesitaAvisoRitmoSupuesto([v]), isTrue);
    });

    test('no avisa cuando cada condición pertenece a un vencimiento distinto: '
        'la lista global de Inicio mezcla vehículos con ritmos distintos, y '
        'atribuirlo mal señalaría como dudosa una cifra fiable', () {
      // ITV de un coche recién añadido: solo va por fecha, sin cifra en
      // kilómetros, pero su ritmo es supuesto por falta de lecturas.
      const itv = Vencimiento(
        estado: EstadoMantenimiento.proximo,
        kmProyectado: 0,
        diasRestantes: 20,
        estimacionEsSupuesta: true,
      );
      // Aceite de otro coche con historial real: cifra por kilómetros
      // perfectamente fiable, con un ritmo medido y no supuesto.
      const aceite = Vencimiento(
        estado: EstadoMantenimiento.atencion,
        kmProyectado: 14200,
        kmRestantes: 800,
        estimacionEsSupuesta: false,
      );

      expect(necesitaAvisoRitmoSupuesto([itv, aceite]), isFalse);
    });

    test('no avisa sin ningún vencimiento', () {
      expect(necesitaAvisoRitmoSupuesto(const []), isFalse);
    });
  });
}
