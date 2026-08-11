import 'package:car_care/data/database.dart';
import 'package:car_care/data/tables/maintenance_schedules.dart';
import 'package:car_care/data/tables/vehicles.dart';
import 'package:car_care/domain/maintenance_due.dart';
import 'package:car_care/domain/usage_rate.dart';
import 'package:car_care/providers/mantenimiento_providers.dart';
import 'package:car_care/providers/providers.dart';
import 'package:car_care/ui/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Vehicle vehiculo(int id, String marca, String modelo) => Vehicle(
        id: id,
        marca: marca,
        modelo: modelo,
        combustible: FuelType.diesel,
        creadoEn: DateTime(2024, 1, 1),
        archivado: false,
      );

  // Igual que en vehicle_detail_screen_test.dart: se simulan los providers
  // en lugar de abrir una base de datos real, porque Inicio combina el
  // stream de vehículos con un vencimientosProvider por cada uno, y lo que
  // importa comprobar aquí es cómo encaja ese resultado en la pantalla, no
  // el cálculo en sí (ya cubierto en test/providers).
  Widget envolver({
    required List<Vehicle> vehiculos,
    required Map<int, List<MantenimientoConVencimiento>> vencimientos,
    required Map<int, EstadoMantenimiento> estados,
  }) {
    return ProviderScope(
      overrides: [
        vehiculosProvider.overrideWith((ref) => Stream.value(vehiculos)),
        ultimaLecturaProvider.overrideWith(
          (ref, id) => Stream<MileageReading?>.value(null),
        ),
        ritmoUsoProvider.overrideWith(
          (ref, id) async => const UsageRateResult(
            kmPorDia: kRitmoPorDefecto,
            esPorDefecto: true,
          ),
        ),
        estadoVehiculoProvider.overrideWith(
          (ref, id) async => estados[id] ?? EstadoMantenimiento.sinConfigurar,
        ),
        vencimientosProvider.overrideWith(
          (ref, id) async => vencimientos[id] ?? const [],
        ),
      ],
      child: const MaterialApp(
        locale: Locale('es', 'ES'),
        supportedLocales: [Locale('es', 'ES')],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: HomeScreen(),
      ),
    );
  }

  testWidgets(
    'un vehiculo sin mantenimientos configurados se distingue en su '
    'tarjeta y no cuenta como "todo al dia" en el resumen',
    (tester) async {
      final v1 = vehiculo(1, 'Seat', 'León ST');

      await tester.pumpWidget(
        envolver(
          vehiculos: [v1],
          vencimientos: const {1: []},
          estados: const {1: EstadoMantenimiento.sinConfigurar},
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Sin mantenimientos configurados. Toca para añadirlos.'),
        findsOneWidget,
      );
      // Sin nada configurado no hay nada que resumir: ni el aviso positivo
      // ni la cabecera de la lista global deben aparecer.
      expect(
        find.text('Todo al día. No hay ningún mantenimiento pendiente.'),
        findsNothing,
      );
      expect(find.text('Próximos mantenimientos'), findsNothing);
    },
  );

  testWidgets(
    'con todo lo configurado al dia, el resumen lo dice explicitamente',
    (tester) async {
      final v1 = vehiculo(1, 'Seat', 'León ST');
      const schedule = MaintenanceSchedule(
        id: 1,
        vehicleId: 1,
        nombre: 'Aceite y filtro',
        categoria: MaintenanceCategory.motor,
        intervalKm: 15000,
        activo: true,
        silenciado: false,
        orden: 0,
      );
      const item = MantenimientoConVencimiento(
        schedule: schedule,
        ultimoRegistro: null,
        vencimiento: Vencimiento(estado: EstadoMantenimiento.ok, kmProyectado: 5000),
      );

      await tester.pumpWidget(
        envolver(
          vehiculos: [v1],
          vencimientos: const {1: [item]},
          estados: const {1: EstadoMantenimiento.ok},
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Todo al día. No hay ningún mantenimiento pendiente.'),
        findsOneWidget,
      );
      expect(find.text('Próximos mantenimientos'), findsNothing);
    },
  );

  testWidgets(
    'el resumen global reune lo pendiente de varios vehiculos, ordenado '
    'por urgencia real y no por el orden de las tarjetas',
    (tester) async {
      // A propósito en el orden "equivocado": la tarjeta del vehículo con
      // lo menos urgente (atención) va primero, y la del más urgente
      // (vencido) va después. Si el resumen ordenara por posición de
      // tarjeta en vez de por urgencia, este test lo detectaría.
      final v1 = vehiculo(1, 'Seat', 'León ST');
      final v2 = vehiculo(2, 'Mercedes-Benz', 'Clase B');

      const scheduleFrenos = MaintenanceSchedule(
        id: 1,
        vehicleId: 1,
        nombre: 'Frenos',
        categoria: MaintenanceCategory.frenos,
        intervalKm: 30000,
        activo: true,
        silenciado: false,
        orden: 0,
      );
      const itemAtencion = MantenimientoConVencimiento(
        schedule: scheduleFrenos,
        ultimoRegistro: null,
        vencimiento: Vencimiento(
          estado: EstadoMantenimiento.atencion,
          kmProyectado: 29500,
          kmRestantes: 500,
          diasHastaVencimiento: 10,
        ),
      );

      const scheduleAceite = MaintenanceSchedule(
        id: 2,
        vehicleId: 2,
        nombre: 'Aceite y filtro',
        categoria: MaintenanceCategory.motor,
        intervalKm: 15000,
        activo: true,
        silenciado: false,
        orden: 0,
      );
      const itemVencido = MantenimientoConVencimiento(
        schedule: scheduleAceite,
        ultimoRegistro: null,
        vencimiento: Vencimiento(
          estado: EstadoMantenimiento.vencido,
          kmProyectado: 26400,
          kmRestantes: -11400,
          diasHastaVencimiento: -30,
        ),
      );

      await tester.pumpWidget(
        envolver(
          vehiculos: [v1, v2],
          vencimientos: const {
            1: [itemAtencion],
            2: [itemVencido],
          },
          estados: const {
            1: EstadoMantenimiento.atencion,
            2: EstadoMantenimiento.vencido,
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Próximos mantenimientos'), findsOneWidget);
      // Cada mantenimiento pendiente identifica a su vehículo.
      expect(find.text('Mercedes-Benz Clase B'), findsWidgets);
      expect(find.text('Seat León ST'), findsWidgets);
      // Cada fila del resumen global ofrece registrar directamente: solo
      // hay dos, una por vehículo (las tarjetas no llevan este botón).
      expect(find.byTooltip('Registrar realizado'), findsNWidgets(2));

      // El nombre de cada mantenimiento aparece dos veces: una en la
      // tarjeta de su vehículo y otra en la lista global. La última
      // aparición de cada uno (en orden de árbol/visual) es la del
      // resumen, porque el resumen va después de todas las tarjetas.
      final posicionesAceite = find.text('Aceite y filtro').evaluate().length;
      final posicionesFrenos = find.text('Frenos').evaluate().length;
      expect(posicionesAceite, 2);
      expect(posicionesFrenos, 2);

      final yGlobalAceite = tester
          .getTopLeft(find.text('Aceite y filtro').at(posicionesAceite - 1))
          .dy;
      final yGlobalFrenos = tester
          .getTopLeft(find.text('Frenos').at(posicionesFrenos - 1))
          .dy;

      // Lo vencido (Aceite y filtro, del segundo vehículo) debe aparecer
      // antes que lo que solo pide atención (Frenos, del primero), pese a
      // que la tarjeta de Frenos está por encima en la pantalla.
      expect(yGlobalAceite, lessThan(yGlobalFrenos));
    },
  );
}
