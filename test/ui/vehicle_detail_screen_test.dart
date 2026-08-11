import 'package:car_care/data/database.dart';
import 'package:car_care/data/tables/maintenance_schedules.dart';
import 'package:car_care/data/tables/vehicles.dart';
import 'package:car_care/domain/maintenance_due.dart';
import 'package:car_care/providers/mantenimiento_providers.dart';
import 'package:car_care/providers/providers.dart';
import 'package:car_care/ui/vehicle/vehicle_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const vehicleId = 1;
  final vehiculo = Vehicle(
    id: vehicleId,
    marca: 'Seat',
    modelo: 'León ST',
    combustible: FuelType.diesel,
    creadoEn: DateTime(2024, 1, 1),
    archivado: false,
  );

  // Igual que en register_maintenance_sheet_test.dart: se simulan los
  // providers en lugar de abrir una base de datos real. Los streams de
  // Drift dejan temporizadores vivos al desmontarse que un testWidgets no
  // puede resolver, y esta ficha combina varios providers a la vez que ya
  // están cubiertos por separado en
  // test/providers/mantenimiento_providers_test.dart; lo que importa
  // comprobar aquí es cómo encaja su resultado en la pantalla.
  Widget envolver(
    Widget child, {
    required List<MantenimientoConVencimiento> vencimientos,
    required EstadoMantenimiento estado,
  }) {
    return ProviderScope(
      overrides: [
        vencimientosProvider.overrideWith((ref, id) async => vencimientos),
        estadoVehiculoProvider.overrideWith((ref, id) async => estado),
        ultimaLecturaProvider.overrideWith(
          (ref, id) => Stream<MileageReading?>.value(null),
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
        home: child,
      ),
    );
  }

  testWidgets(
    'un vehiculo sin mantenimientos configurados no aparece como al dia',
    (tester) async {
      await tester.pumpWidget(
        envolver(
          VehicleDetailScreen(vehiculo: vehiculo),
          vencimientos: const [],
          estado: EstadoMantenimiento.sinConfigurar,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sin mantenimientos configurados'), findsOneWidget);
      expect(find.text('Añadir mantenimiento'), findsWidgets);
      expect(find.text('Sin datos'), findsOneWidget);
      expect(find.text('Al día'), findsNothing);

      // Las acciones generales están accesibles aunque no haya nada
      // configurado todavía.
      expect(find.byTooltip('Editar vehículo'), findsOneWidget);
      expect(find.text('Registrar'), findsOneWidget);
    },
  );

  testWidgets(
    'un mantenimiento vencido se distingue con sus cifras, marcadas como '
    'estimacion supuesta sin lecturas',
    (tester) async {
      const schedule = MaintenanceSchedule(
        id: 1,
        vehicleId: vehicleId,
        nombre: 'Aceite y filtro',
        categoria: MaintenanceCategory.motor,
        intervalKm: 15000,
        activo: true,
        silenciado: false,
        orden: 0,
      );
      const vencimiento = Vencimiento(
        estado: EstadoMantenimiento.vencido,
        kmProyectado: 26400,
        proximoKm: 15000,
        kmRestantes: -11400,
        estimacionEsSupuesta: true,
      );
      const item = MantenimientoConVencimiento(
        schedule: schedule,
        ultimoRegistro: null,
        vencimiento: vencimiento,
      );

      await tester.pumpWidget(
        envolver(
          VehicleDetailScreen(vehiculo: vehiculo),
          vencimientos: const [item],
          estado: EstadoMantenimiento.vencido,
        ),
      );
      await tester.pumpAndSettle();

      // Aparece en la tarjeta destacada y en la lista completa.
      expect(find.text('Aceite y filtro'), findsWidgets);
      // Distintivo "Vencido": en la cabecera, en la tarjeta destacada y en
      // la fila de la lista.
      expect(find.text('Vencido'), findsWidgets);
      // La cifra de kilómetros restantes es siempre una proyección: debe
      // llevar el símbolo de estimación.
      expect(find.textContaining('≈ Vencido hace'), findsWidgets);
      // El kilometraje exacto al que tocaba, en cambio, no es una
      // estimación.
      expect(find.textContaining('Próximo cambio: 15.000 km'), findsWidgets);
      // Sin lecturas reales, el ritmo usado es el supuesto por defecto: la
      // ficha tiene que decirlo explícitamente, no solo marcarlo con ≈.
      expect(
        find.textContaining('se basan en un ritmo de uso supuesto'),
        findsOneWidget,
      );
    },
  );
}
