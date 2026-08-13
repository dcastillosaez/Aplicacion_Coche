import 'package:car_care/data/database.dart';
import 'package:car_care/providers/mantenimiento_providers.dart';
import 'package:car_care/providers/providers.dart';
import 'package:car_care/ui/maintenance/register_maintenance_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'el contenido de la hoja de registro de mantenimiento queda por encima '
    'del teclado',
    (tester) async {
      const alturaTeclado = 300.0;
      const vehicleId = 1;

      await tester.pumpWidget(
        ProviderScope(
          // Igual que en update_mileage_sheet_test: se simulan los
          // providers en lugar de abrir una base de datos real. Este test
          // comprueba geometría, y los streams de Drift dejan
          // temporizadores vivos al desmontarse que el test no puede
          // resolver.
          overrides: [
            ultimaLecturaProvider.overrideWith(
              (ref, id) => Stream<MileageReading?>.value(null),
            ),
            schedulesProvider.overrideWith(
              (ref, id) => Stream<List<MaintenanceSchedule>>.value(
                const <MaintenanceSchedule>[],
              ),
            ),
          ],
          child: MaterialApp(
            // La hoja usa formatearFecha, que necesita los datos de
            // formato de es_ES cargados. En la app real los carga
            // MaterialApp al resolver estos delegados (ver app.dart); aquí
            // hay que declararlos igual o la fecha por defecto revienta al
            // construir la hoja.
            locale: const Locale('es', 'ES'),
            supportedLocales: const [Locale('es', 'ES')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
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
              // Igual que la ficha del vehículo: un Scaffold con
              // resizeToAvoidBottomInset (el valor por defecto) cuyo body es
              // el que abre la hoja. Este Scaffold elimina el
              // viewInsets.bottom del MediaQuery de su body, así que el
              // contexto del botón NO debe usarse para calcular el padding
              // de la hoja.
              body: Builder(
                builder: (contextBoton) => Center(
                  child: ElevatedButton(
                    onPressed: () => mostrarRegistroMantenimiento(
                      contextBoton,
                      vehicleId: vehicleId,
                    ),
                    child: const Text('Registrar'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      expect(find.text('Guardar'), findsOneWidget);

      // A diferencia de la hoja de kilometraje, esta tiene bastantes más
      // campos y no cabe entera en el hueco que deja un teclado de 300px:
      // hace falta desplazarse dentro de su propio scroll para llegar al
      // botón, igual que en un móvil real. Si el padding usara el contexto
      // equivocado, el hueco calculado para el teclado sería menor (o
      // cero) y el scroll disponible sería mayor, dejando el botón por
      // detrás del teclado incluso después de desplazarse hasta el final:
      // la comprobación de más abajo seguiría detectándolo.
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pumpAndSettle();

      final vista = tester.view;
      final alturaPantalla = vista.physicalSize.height / vista.devicePixelRatio;

      final bordeInferiorContenido = tester
          .getBottomLeft(find.widgetWithText(FilledButton, 'Guardar'))
          .dy;

      // El borde inferior del contenido de la hoja debe quedar por encima
      // del teclado simulado, no detrás de él.
      expect(
        bordeInferiorContenido,
        lessThanOrEqualTo(alturaPantalla - alturaTeclado),
      );
    },
  );
}
