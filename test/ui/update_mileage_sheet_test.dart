import 'package:car_care/data/database.dart';
import 'package:car_care/data/tables/vehicles.dart';
import 'package:car_care/providers/providers.dart';
import 'package:car_care/ui/mileage/update_mileage_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'el contenido de la hoja de kilometraje queda por encima del teclado',
    (tester) async {
      const alturaTeclado = 300.0;

      final vehiculoDePrueba = Vehicle(
        id: 1,
        marca: 'Seat',
        modelo: 'León',
        combustible: FuelType.diesel,
        creadoEn: DateTime(2026, 1, 1),
        archivado: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          // La hoja solo necesita saber cuál fue la última lectura. Se
          // simula en vez de abrir una base de datos real: este test
          // comprueba geometría, y los streams de Drift dejan
          // temporizadores vivos al desmontarse que el test no puede
          // resolver.
          overrides: [
            ultimaLecturaProvider.overrideWith(
              (ref, id) => Stream<MileageReading?>.value(null),
            ),
          ],
          child: MaterialApp(
            // Envuelve el Navigator (y por tanto el overlay donde vive la
            // hoja modal) con un MediaQuery que simula el teclado abierto,
            // igual que hace el sistema operativo en un móvil real.
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                viewInsets: const EdgeInsets.only(bottom: alturaTeclado),
              ),
              child: child!,
            ),
            home: Scaffold(
              // Igual que HomeScreen: un Scaffold con resizeToAvoidBottomInset
              // (el valor por defecto) cuyo body es el que abre la hoja. Este
              // Scaffold elimina el viewInsets.bottom del MediaQuery de su
              // body, así que el contexto del botón NO debe usarse para
              // calcular el padding de la hoja.
              body: Builder(
                builder: (contextBoton) => Center(
                  child: ElevatedButton(
                    onPressed: () => mostrarHojaKilometraje(
                      contextBoton,
                      vehiculo: vehiculoDePrueba,
                    ),
                    child: const Text('Kilometraje'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Kilometraje'));
      await tester.pumpAndSettle();

      expect(find.text('Guardar'), findsOneWidget);

      final vista = tester.view;
      final alturaPantalla = vista.physicalSize.height / vista.devicePixelRatio;

      final bordeInferiorContenido =
          tester.getBottomLeft(find.widgetWithText(FilledButton, 'Guardar')).dy;

      // El borde inferior del contenido de la hoja debe quedar por encima
      // del teclado simulado, no detrás de él.
      expect(
        bordeInferiorContenido,
        lessThanOrEqualTo(alturaPantalla - alturaTeclado),
      );
    },
  );
}
