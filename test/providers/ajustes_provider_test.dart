import 'dart:async';

import 'package:car_care/data/database.dart';
import 'package:car_care/providers/mantenimiento_providers.dart';
import 'package:car_care/providers/providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ajustesProvider emite un nuevo valor tras escribir en el DAO', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final primero = await container.read(ajustesProvider.future);
    expect(primero.tema, 'automatico');

    // Se suscribe ANTES de escribir, para no arriesgarse a perder el
    // evento: el Completer captura el primer valor con tema 'oscuro' que
    // llegue después de este punto, venga cuando venga.
    final segundoValor = Completer<Setting>();
    final sub = container.listen(ajustesProvider, (previo, actual) {
      actual.whenData((s) {
        if (s.tema == 'oscuro' && !segundoValor.isCompleted) {
          segundoValor.complete(s);
        }
      });
    });
    addTearDown(sub.close);

    await db.settingsDao.actualizarTema('oscuro');

    final segundo = await segundoValor.future.timeout(
      const Duration(seconds: 2),
    );
    expect(segundo.tema, 'oscuro');
  });
}
