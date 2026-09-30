import 'package:car_care/data/database.dart';
import 'package:car_care/data/tables/vehicles.dart';
import 'package:car_care/domain/gastos.dart';
import 'package:car_care/domain/maintenance_category.dart';
import 'package:car_care/providers/gastos_providers.dart';
import 'package:car_care/ui/common/formatters.dart';
import 'package:car_care/ui/expenses/expenses_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Vehicle _vehiculo() => Vehicle(
  id: 1,
  marca: 'Seat',
  modelo: 'León',
  combustible: FuelType.diesel,
  creadoEn: DateTime(2026, 1, 1),
  archivado: false,
);

// Igual que en vehicle_detail_screen_test.dart: se sobrescribe el provider
// de datos en vez de abrir una base de datos Drift real. Los streams de
// Drift dejan temporizadores vivos al desmontarse que un testWidgets no
// puede resolver.
Widget _app(List<GastosDeVehiculo> gastos) {
  return ProviderScope(
    overrides: [gastosProvider.overrideWith((ref) => gastos)],
    child: const MaterialApp(home: ExpensesScreen()),
  );
}

void main() {
  testWidgets('muestra el total y el desglose por año', (tester) async {
    await tester.pumpWidget(
      _app([
        GastosDeVehiculo(
          vehiculo: _vehiculo(),
          resumen: const ResumenGastos(
            total: 350,
            porAnio: [
              GastoAnual(anio: 2026, total: 200),
              GastoAnual(anio: 2025, total: 150),
            ],
            registrosSinCoste: 0,
          ),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Seat León'), findsOneWidget);
    expect(find.text(formatearCoste(350)), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('2025'), findsOneWidget);
    expect(find.text(formatearCoste(200)), findsOneWidget);
    expect(find.text(formatearCoste(150)), findsOneWidget);
  });

  testWidgets('avisa de los mantenimientos sin coste anotado', (tester) async {
    await tester.pumpWidget(
      _app([
        GastosDeVehiculo(
          vehiculo: _vehiculo(),
          resumen: const ResumenGastos(
            total: 100,
            porAnio: [GastoAnual(anio: 2026, total: 100)],
            registrosSinCoste: 2,
          ),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('sin coste anotado'), findsOneWidget);
  });

  testWidgets('un coche sin costes no muestra un total de cero', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app([
        GastosDeVehiculo(
          vehiculo: _vehiculo(),
          resumen: const ResumenGastos(
            total: 0,
            porAnio: [],
            registrosSinCoste: 0,
          ),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.text('Seat León'), findsOneWidget);
    expect(find.text(formatearCoste(0)), findsNothing);
  });

  testWidgets('permite alternar entre desglose por año y por categoría', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app([
        GastosDeVehiculo(
          vehiculo: _vehiculo(),
          resumen: const ResumenGastos(
            total: 300,
            porAnio: [
              GastoAnual(anio: 2026, total: 300),
            ],
            porCategoria: [
              GastoPorCategoria(
                categoria: MaintenanceCategory.motor,
                total: 200,
                cantidad: 2,
              ),
              GastoPorCategoria(
                categoria: MaintenanceCategory.frenos,
                total: 100,
                cantidad: 1,
              ),
            ],
            registrosSinCoste: 0,
          ),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    // Por defecto se muestra la vista por año
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('Motor'), findsNothing);

    // Cambiar a vista por categoría
    await tester.tap(find.text('Por categoría'));
    await tester.pumpAndSettle();

    expect(find.text('Motor'), findsOneWidget);
    expect(find.text('Frenos'), findsOneWidget);
    expect(find.text(formatearCoste(200)), findsOneWidget);
    expect(find.text(formatearCoste(100)), findsOneWidget);
    expect(find.text('67%'), findsOneWidget);
    expect(find.text('33%'), findsOneWidget);

    // Volver a vista por año
    await tester.tap(find.text('Por año'));
    await tester.pumpAndSettle();

    expect(find.text('2026'), findsOneWidget);
    expect(find.text('Motor'), findsNothing);
  });
}
