import 'package:car_care/data/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('actualizarTema cambia solo el tema', () async {
    await db.settingsDao.actualizarTema('oscuro');

    final ajustes = await db.select(db.settings).getSingle();
    expect(ajustes.tema, 'oscuro');
    expect(ajustes.avisoKmPorDefecto, 1000);
  });

  test('actualizarAvisoKmPorDefecto cambia solo ese campo', () async {
    await db.settingsDao.actualizarAvisoKmPorDefecto(2000);

    final ajustes = await db.select(db.settings).getSingle();
    expect(ajustes.avisoKmPorDefecto, 2000);
    expect(ajustes.avisoDiasPorDefecto, 30);
  });

  test('actualizarAvisoDiasPorDefecto cambia solo ese campo', () async {
    await db.settingsDao.actualizarAvisoDiasPorDefecto(60);

    final ajustes = await db.select(db.settings).getSingle();
    expect(ajustes.avisoDiasPorDefecto, 60);
    expect(ajustes.diasRecordatorioLectura, 15);
  });

  test('actualizarDiasRecordatorioLectura cambia solo ese campo', () async {
    await db.settingsDao.actualizarDiasRecordatorioLectura(7);

    final ajustes = await db.select(db.settings).getSingle();
    expect(ajustes.diasRecordatorioLectura, 7);
    expect(ajustes.tema, 'automatico');
  });
}
