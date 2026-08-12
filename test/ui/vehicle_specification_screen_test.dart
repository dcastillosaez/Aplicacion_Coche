import 'package:car_care/data/database.dart';
import 'package:car_care/providers/providers.dart';
import 'package:car_care/ui/vehicle/vehicle_specification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const vehicleId = 1;

  // Igual que en vehicle_detail_screen_test.dart: se simula el provider en
  // lugar de abrir una base de datos real, porque los streams de Drift
  // dejan temporizadores vivos al desmontarse que un testWidgets no puede
  // resolver.
  Widget envolver(VehicleSpecification? ficha) {
    return ProviderScope(
      overrides: [
        vehicleSpecificationProvider.overrideWith(
          (ref, id) => Stream<VehicleSpecification?>.value(ficha),
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
        home: const VehicleSpecificationScreen(vehicleId: vehicleId),
      ),
    );
  }

  testWidgets(
    'al abrir la pantalla con una ficha ya guardada, los campos se rellenan',
    (tester) async {
      const ficha = VehicleSpecification(
        vehicleId: vehicleId,
        motorCodigo: 'B47',
        potenciaKw: 140,
      );

      await tester.pumpWidget(envolver(ficha));
      await tester.pumpAndSettle();

      expect(find.text('B47'), findsOneWidget);
    },
  );

  testWidgets(
    'al escribir la potencia en kW, aparece el CV calculado',
    (tester) async {
      await tester.pumpWidget(envolver(null));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Potencia (kW)'),
        '140',
      );
      await tester.pump();

      expect(find.text('≈ 190 CV'), findsOneWidget);
    },
  );
}
