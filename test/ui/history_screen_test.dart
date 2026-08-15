import 'dart:async';

import 'package:car_care/data/database.dart';
import 'package:car_care/data/tables/maintenance_schedules.dart';
import 'package:car_care/data/tables/vehicles.dart';
import 'package:car_care/providers/mantenimiento_providers.dart';
import 'package:car_care/providers/providers.dart';
import 'package:car_care/ui/common/formatters.dart';
import 'package:car_care/ui/history/history_screen.dart';
import 'package:car_care/ui/maintenance/maintenance_form_screen.dart'
    show etiquetasCategoria;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final seat = Vehicle(
    id: 1,
    marca: 'Seat',
    modelo: 'León ST',
    combustible: FuelType.diesel,
    creadoEn: DateTime(2024, 1, 1),
    archivado: false,
  );
  final mercedes = Vehicle(
    id: 2,
    marca: 'Mercedes-Benz',
    modelo: 'Clase B',
    combustible: FuelType.diesel,
    creadoEn: DateTime(2024, 1, 1),
    archivado: false,
  );

  const aceite = MaintenanceSchedule(
    id: 10,
    vehicleId: 1,
    nombre: 'Aceite y filtro',
    categoria: MaintenanceCategory.motor,
    intervalKm: 15000,
    activo: true,
    silenciado: false,
    orden: 0,
    fuenteIntervalo: FuenteIntervalo.orientativo,
    nombreAutogenerado: false,
  );

  // Igual que en vehicle_detail_screen_test.dart: se simulan los providers
  // en lugar de abrir una base de datos real, porque los streams de Drift
  // dejan temporizadores vivos que un testWidgets no puede resolver.
  Widget envolver({
    required List<MaintenanceRecord> registros,
    required List<Vehicle> vehiculos,
    Map<int, List<MaintenanceSchedule>> schedulesPorVehiculo = const {},
  }) {
    return ProviderScope(
      overrides: [
        historialProvider.overrideWith((ref) => Stream.value(registros)),
        vehiculosTodosProvider.overrideWith((ref) => Stream.value(vehiculos)),
        schedulesProvider.overrideWith(
          (ref, vehicleId) =>
              Stream.value(schedulesPorVehiculo[vehicleId] ?? const []),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('es', 'ES'),
        supportedLocales: const [Locale('es', 'ES')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HistoryScreen(),
      ),
    );
  }

  testWidgets('sin registros muestra el estado vacio', (tester) async {
    await tester.pumpWidget(
      envolver(registros: const [], vehiculos: [seat, mercedes]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Todavía no hay nada registrado'), findsOneWidget);
  });

  testWidgets(
    'cada entrada indica el vehiculo al que pertenece, y se distinguen '
    'los sembrados',
    (tester) async {
      final registroConSchedule = MaintenanceRecord(
        id: 1,
        vehicleId: 1,
        scheduleId: 10,
        fecha: DateTime(2026, 5, 1),
        km: 95000,
        coste: 120.5,
        esSembrado: false,
      );
      final registroPuntual = MaintenanceRecord(
        id: 2,
        vehicleId: 2,
        fecha: DateTime(2026, 4, 1),
        km: 60000,
        esSembrado: false,
      );
      final registroSembrado = MaintenanceRecord(
        id: 3,
        vehicleId: 1,
        scheduleId: 10,
        fecha: DateTime(2025, 1, 1),
        km: 80000,
        esSembrado: true,
      );

      await tester.pumpWidget(
        envolver(
          registros: [registroConSchedule, registroPuntual, registroSembrado],
          vehiculos: [seat, mercedes],
          schedulesPorVehiculo: {
            1: [aceite],
          },
        ),
      );
      await tester.pumpAndSettle();

      // El nombre del mantenimiento configurado aparece cuando el registro
      // sigue apuntando a un schedule vivo.
      expect(find.text('Aceite y filtro'), findsWidgets);
      // Sin schedule asociado (nunca lo tuvo o se borró), un rótulo honesto
      // que no inventa un nombre.
      expect(find.text('Reparación puntual'), findsOneWidget);
      // Cada entrada dice a qué coche pertenece.
      expect(find.text('Seat León ST'), findsWidgets);
      expect(find.text('Mercedes-Benz Clase B'), findsWidgets);
      // El registro sembrado se distingue como dato anterior a la app.
      expect(
        find.text('Dato anterior a la app, introducido a mano'),
        findsOneWidget,
      );
      expect(find.text(formatearCoste(120.5)), findsOneWidget);
    },
  );

  testWidgets('el filtro por vehiculo deja solo sus registros', (tester) async {
    final registroSeat = MaintenanceRecord(
      id: 1,
      vehicleId: 1,
      fecha: DateTime(2026, 5, 1),
      km: 95000,
      esSembrado: false,
    );
    final registroMercedes = MaintenanceRecord(
      id: 2,
      vehicleId: 2,
      fecha: DateTime(2026, 4, 1),
      km: 60000,
      esSembrado: false,
    );

    await tester.pumpWidget(
      envolver(
        registros: [registroSeat, registroMercedes],
        vehiculos: [seat, mercedes],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('95.000 km'), findsOneWidget);
    expect(find.text('60.000 km'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Seat León ST'));
    await tester.pumpAndSettle();

    expect(find.text('95.000 km'), findsOneWidget);
    expect(find.text('60.000 km'), findsNothing);
  });

  testWidgets(
    'un vehiculo archivado con historial muestra su marca, su modelo y el '
    'nombre real de su mantenimiento',
    (tester) async {
      final vendido = Vehicle(
        id: 3,
        marca: 'Renault',
        modelo: 'Clio',
        combustible: FuelType.gasolina,
        creadoEn: DateTime(2023, 1, 1),
        archivado: true,
      );
      const revision = MaintenanceSchedule(
        id: 20,
        vehicleId: 3,
        nombre: 'Revisión general',
        categoria: MaintenanceCategory.motor,
        intervalKm: 20000,
        activo: true,
        silenciado: false,
        orden: 0,
        fuenteIntervalo: FuenteIntervalo.orientativo,
        nombreAutogenerado: false,
      );
      final registroVendido = MaintenanceRecord(
        id: 4,
        vehicleId: 3,
        scheduleId: 20,
        fecha: DateTime(2026, 2, 1),
        km: 150000,
        esSembrado: false,
      );

      await tester.pumpWidget(
        envolver(
          registros: [registroVendido],
          vehiculos: [seat, mercedes, vendido],
          schedulesPorVehiculo: {
            3: [revision],
          },
        ),
      );
      await tester.pumpAndSettle();

      // El nombre y la categoría del mantenimiento se resuelven aunque el
      // vehículo esté archivado: no hay razón para perderlos.
      expect(find.text('Revisión general'), findsOneWidget);
      expect(
        find.text(etiquetasCategoria[MaintenanceCategory.motor]!),
        findsOneWidget,
      );
      // La marca y el modelo reales, no "Vehículo no disponible".
      expect(find.text('Vehículo no disponible'), findsNothing);
      expect(find.text('Reparación puntual'), findsNothing);
      // Pero se marca discretamente como archivado (en el filtro y en la
      // propia entrada): no debe parecer que el coche sigue en uso.
      expect(find.text('Renault Clio (archivado)'), findsWidgets);
    },
  );

  testWidgets(
    'mientras los mantenimientos siguen cargando, no se afirma que un '
    'registro sea una reparacion puntual',
    (tester) async {
      final registroConSchedule = MaintenanceRecord(
        id: 1,
        vehicleId: 1,
        scheduleId: 10,
        fecha: DateTime(2026, 5, 1),
        km: 95000,
        esSembrado: false,
      );

      final historialCompleter = Completer<List<MaintenanceRecord>>();
      final vehiculosCompleter = Completer<List<Vehicle>>();
      final schedulesController = StreamController<List<MaintenanceSchedule>>();
      addTearDown(schedulesController.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            historialProvider.overrideWith(
              (ref) => Stream.fromFuture(historialCompleter.future),
            ),
            vehiculosTodosProvider.overrideWith(
              (ref) => Stream.fromFuture(vehiculosCompleter.future),
            ),
            schedulesProvider.overrideWith(
              (ref, vehicleId) => schedulesController.stream,
            ),
          ],
          child: MaterialApp(
            locale: const Locale('es', 'ES'),
            supportedLocales: const [Locale('es', 'ES')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HistoryScreen(),
          ),
        ),
      );

      // El historial y los vehículos ya han llegado, pero los mantenimientos
      // del vehículo todavía no han emitido su primer valor.
      historialCompleter.complete([registroConSchedule]);
      vehiculosCompleter.complete([seat]);
      await tester.pump();
      await tester.pump();

      // No se afirma nada que pueda ser falso mientras se carga: ni el
      // rótulo genérico ni, por supuesto, uno inventado.
      expect(find.text('Reparación puntual'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      schedulesController.add([aceite]);
      await tester.pumpAndSettle();

      expect(find.text('Aceite y filtro'), findsOneWidget);
    },
  );
}
