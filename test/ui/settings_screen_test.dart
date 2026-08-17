import 'package:car_care/data/database.dart';
import 'package:car_care/providers/mantenimiento_providers.dart';
import 'package:car_care/providers/permisos_providers.dart';
import 'package:car_care/providers/providers.dart';
import 'package:car_care/services/permisos.dart';
import 'package:car_care/ui/settings/settings_screen.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ServicioPermisosFalso implements ServicioPermisos {
  final bool concedido;
  int vecesAbierto = 0;

  _ServicioPermisosFalso({this.concedido = true});

  @override
  Future<bool> tienePermisoNotificaciones() async => concedido;

  @override
  Future<void> abrirAjustesDeLaAplicacion() async {
    vecesAbierto++;
  }
}

Setting _ajustesDePrueba({DateTime? fechaUltimaCopia}) => Setting(
  id: 1,
  avisoKmPorDefecto: 1000,
  avisoDiasPorDefecto: 30,
  diasRecordatorioLectura: 15,
  tema: 'automatico',
  fechaUltimaCopia: fechaUltimaCopia,
);

void main() {
  // Igual que en vehicle_specification_screen_test.dart: se sobrescribe
  // ajustesProvider en lugar de dejar que abra la base de datos real, porque
  // los streams de Drift dejan temporizadores vivos que un testWidgets no
  // resuelve. databaseProvider sí apunta a una base de datos real en
  // memoria, para poder comprobar el efecto de los guardados.
  Widget envolver({
    required Setting ajustes,
    required ServicioPermisos servicioPermisos,
    required AppDatabase db,
  }) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        ajustesProvider.overrideWith((ref) => Stream.value(ajustes)),
        servicioPermisosProvider.overrideWithValue(servicioPermisos),
        permisoNotificacionesProvider.overrideWith(
          (ref) => servicioPermisos.tienePermisoNotificaciones(),
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
        home: const SettingsScreen(),
      ),
    );
  }

  testWidgets('muestra los valores iniciales de notificaciones', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      envolver(
        ajustes: _ajustesDePrueba(),
        servicioPermisos: _ServicioPermisosFalso(),
        db: db,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1000'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
  });

  testWidgets('editar el margen de kilómetros y perder el foco lo guarda', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      envolver(
        ajustes: _ajustesDePrueba(),
        servicioPermisos: _ServicioPermisosFalso(),
        db: db,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Kilómetros de antelación'),
      '2000',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    final guardado = await db.select(db.settings).getSingle();
    expect(guardado.avisoKmPorDefecto, 2000);
  });

  testWidgets('un valor invalido revierte al ultimo valor guardado', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      envolver(
        ajustes: _ajustesDePrueba(),
        servicioPermisos: _ServicioPermisosFalso(),
        db: db,
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Días de antelación'),
      '0',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(find.text('30'), findsOneWidget);
  });

  testWidgets('tocar Oscuro guarda el nuevo tema', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      envolver(
        ajustes: _ajustesDePrueba(),
        servicioPermisos: _ServicioPermisosFalso(),
        db: db,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Oscuro'));
    await tester.pumpAndSettle();

    final guardado = await db.select(db.settings).getSingle();
    expect(guardado.tema, 'oscuro');
  });

  testWidgets('permiso denegado muestra el boton para abrir ajustes', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final servicio = _ServicioPermisosFalso(concedido: false);

    await tester.pumpWidget(
      envolver(ajustes: _ajustesDePrueba(), servicioPermisos: servicio, db: db),
    );
    await tester.pumpAndSettle();

    expect(find.text('Denegado'), findsOneWidget);
    await tester.tap(find.text('Abrir ajustes'));
    await tester.pumpAndSettle();

    expect(servicio.vecesAbierto, 1);
  });

  testWidgets('permiso concedido no muestra el boton para abrir ajustes', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      envolver(
        ajustes: _ajustesDePrueba(),
        servicioPermisos: _ServicioPermisosFalso(),
        db: db,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Concedido'), findsOneWidget);
    expect(find.text('Abrir ajustes'), findsNothing);
  });

  testWidgets('exportar copia muestra un aviso de funcion pendiente', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    // Superficie más alta que la por defecto: la sección "Datos" queda
    // fuera del viewport estándar de test y lo que queda fuera de la
    // ventana no llega a construirse (igual que en home_screen_test.dart).
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      envolver(
        ajustes: _ajustesDePrueba(),
        servicioPermisos: _ServicioPermisosFalso(),
        db: db,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Exportar copia de seguridad'));
    await tester.pump();

    expect(
      find.text('Esta función estará disponible en una próxima versión.'),
      findsOneWidget,
    );
  });

  testWidgets('sin copia previa, la fila de ultima copia no aparece', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      envolver(
        ajustes: _ajustesDePrueba(),
        servicioPermisos: _ServicioPermisosFalso(),
        db: db,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Última copia'), findsNothing);
  });

  testWidgets('con copia previa, se muestra la fecha formateada', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    // Ver comentario en el test de exportar: la fila "Última copia" queda
    // aún más abajo, fuera del viewport estándar de test.
    tester.view.physicalSize = const Size(1000, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      envolver(
        ajustes: _ajustesDePrueba(fechaUltimaCopia: DateTime(2026, 8, 1)),
        servicioPermisos: _ServicioPermisosFalso(),
        db: db,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('01/08/2026'), findsOneWidget);
  });
}
