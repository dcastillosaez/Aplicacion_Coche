import 'package:car_care/data/database.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../generated_migrations/schema.dart';

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('Verificación de esquemas con drift_dev schema', () {
    for (final v in GeneratedHelper.versions) {
      test('esquema v$v se instancia correctamente', () async {
        final connection = await verifier.startAt(v);
        await connection.close();
      });
    }

    test('migra de v1 a v6 y valida el esquema resultante', () async {
      final connection = await verifier.startAt(1);
      final db = AppDatabase.forTesting(connection);
      await verifier.migrateAndValidate(db, 6);
      await db.close();
    });

    test('migra de v2 a v6 y valida el esquema resultante', () async {
      final connection = await verifier.startAt(2);
      final db = AppDatabase.forTesting(connection);
      await verifier.migrateAndValidate(db, 6);
      await db.close();
    });

    test('migra de v3 a v6 y valida el esquema resultante', () async {
      final connection = await verifier.startAt(3);
      final db = AppDatabase.forTesting(connection);
      await verifier.migrateAndValidate(db, 6);
      await db.close();
    });

    test('migra de v4 a v6 y valida el esquema resultante', () async {
      final connection = await verifier.startAt(4);
      final db = AppDatabase.forTesting(connection);
      await verifier.migrateAndValidate(db, 6);
      await db.close();
    });

    test('migra de v5 a v6 y valida el esquema resultante', () async {
      final connection = await verifier.startAt(5);
      final db = AppDatabase.forTesting(connection);
      await verifier.migrateAndValidate(db, 6);
      await db.close();
    });
  });
}
