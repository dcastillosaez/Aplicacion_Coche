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

  testWidgets(
    'el resumen "todo al dia" menciona el vehiculo sin mantenimientos '
    'configurados en vez de callarlo',
    (tester) async {
      final v1 = vehiculo(1, 'Seat', 'León ST');
      final v2 = vehiculo(2, 'BMW', 'X3');

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
        vencimiento:
            Vencimiento(estado: EstadoMantenimiento.ok, kmProyectado: 5000),
      );

      await tester.pumpWidget(
        envolver(
          vehiculos: [v1, v2],
          vencimientos: const {1: [item], 2: []},
          estados: const {
            1: EstadoMantenimiento.ok,
            2: EstadoMantenimiento.sinConfigurar,
          },
        ),
      );
      await tester.pumpAndSettle();

      // El banner genérico ya no basta: hay un vehículo sin configurar y no
      // se puede decir "todo al día" sin mencionarlo.
      expect(
        find.text('Todo al día. No hay ningún mantenimiento pendiente.'),
        findsNothing,
      );
      expect(
        find.text(
          'Todo al día en lo configurado. BMW X3 todavía no tiene ningún '
          'mantenimiento configurado.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'la tarjeta de un vehiculo recorta a los 3 mantenimientos mas proximos',
    (tester) async {
      // Superficie más alta que la por defecto: con varias filas de
      // mantenimiento el contenido no cabe en el viewport estándar de test,
      // y lo que queda fuera de la ventana no llega a construirse.
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final v1 = vehiculo(1, 'Seat', 'León ST');

      MantenimientoConVencimiento item(int id, String nombre) =>
          MantenimientoConVencimiento(
            schedule: MaintenanceSchedule(
              id: id,
              vehicleId: 1,
              nombre: nombre,
              categoria: MaintenanceCategory.motor,
              intervalKm: 15000,
              activo: true,
              silenciado: false,
              orden: id,
            ),
            ultimoRegistro: null,
            // Estado "ok": no son pendientes, así que no aparecen en el
            // resumen global y el recorte que se comprueba es solo el de
            // la tarjeta.
            vencimiento: const Vencimiento(
              estado: EstadoMantenimiento.ok,
              kmProyectado: 5000,
            ),
          );

      final lista = [
        item(1, 'Aceite y filtro'),
        item(2, 'Frenos'),
        item(3, 'Neumáticos'),
        item(4, 'Batería'),
      ];

      await tester.pumpWidget(
        envolver(
          vehiculos: [v1],
          vencimientos: {1: lista},
          estados: const {1: EstadoMantenimiento.ok},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aceite y filtro'), findsOneWidget);
      expect(find.text('Frenos'), findsOneWidget);
      expect(find.text('Neumáticos'), findsOneWidget);
      // El cuarto mantenimiento queda fuera del máximo de 3 de la tarjeta.
      expect(find.text('Batería'), findsNothing);
    },
  );

  testWidgets(
    'el resumen global recorta a los 5 mantenimientos pendientes mas '
    'urgentes y cuenta los restantes',
    (tester) async {
      // Dos tarjetas con tres filas cada una más la lista global no caben
      // en el viewport estándar de test: hace falta una superficie más alta
      // para que todo el contenido llegue a construirse.
      tester.view.physicalSize = const Size(1000, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final v1 = vehiculo(1, 'Seat', 'León ST');
      final v2 = vehiculo(2, 'BMW', 'X3');

      MantenimientoConVencimiento item(
        int id,
        int vehicleId,
        String nombre,
        int diasHastaVencimiento,
      ) =>
          MantenimientoConVencimiento(
            schedule: MaintenanceSchedule(
              id: id,
              vehicleId: vehicleId,
              nombre: nombre,
              categoria: MaintenanceCategory.motor,
              intervalKm: 30000,
              activo: true,
              silenciado: false,
              orden: id,
            ),
            ultimoRegistro: null,
            vencimiento: Vencimiento(
              estado: EstadoMantenimiento.vencido,
              kmProyectado: 5000,
              diasHastaVencimiento: diasHastaVencimiento,
            ),
          );

      // Seis mantenimientos vencidos entre los dos vehículos, tres por
      // coche (así ninguna tarjeta recorta por su cuenta y lo único que se
      // ejercita es el máximo de 5 del resumen global). Cuanto más negativo
      // diasHastaVencimiento, más urgente y antes aparece.
      final v1Items = [
        item(1, 1, 'Correa distribución', -60),
        item(2, 1, 'Frenos', -50),
        item(3, 1, 'Batería', -40),
      ];
      final v2Items = [
        item(4, 2, 'Aceite y filtro', -30),
        item(5, 2, 'Neumáticos', -20),
        item(6, 2, 'Filtro de aire', -10),
      ];

      await tester.pumpWidget(
        envolver(
          vehiculos: [v1, v2],
          vencimientos: {1: v1Items, 2: v2Items},
          estados: const {
            1: EstadoMantenimiento.vencido,
            2: EstadoMantenimiento.vencido,
          },
        ),
      );
      await tester.pumpAndSettle();

      // Los 5 más urgentes aparecen dos veces: una en la tarjeta de su
      // vehículo y otra en el resumen global.
      for (final nombre in [
        'Correa distribución',
        'Frenos',
        'Batería',
        'Aceite y filtro',
        'Neumáticos',
      ]) {
        expect(find.text(nombre).evaluate().length, 2, reason: nombre);
      }
      // El sexto, el menos urgente, solo aparece en la tarjeta de su
      // vehículo: el resumen global lo deja fuera por el máximo de 5.
      expect(find.text('Filtro de aire').evaluate().length, 1);

      expect(
        find.text('Y 1 mantenimiento más pendiente, en su ficha.'),
        findsOneWidget,
      );
    },
  );
}
