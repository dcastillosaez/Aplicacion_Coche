// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final v6File = File('drift_schemas/drift_schema_v6.json');
  final v6 = jsonDecode(v6File.readAsStringSync()) as Map<String, dynamic>;

  Map<String, dynamic> clone(Map<String, dynamic> source) {
    return jsonDecode(jsonEncode(source)) as Map<String, dynamic>;
  }

  void removeTable(Map<String, dynamic> schema, String tableName) {
    final entities = schema['entities'] as List<dynamic>;
    final idx = entities.indexWhere((e) => e['data']['name'] == tableName);
    if (idx != -1) {
      final id = entities[idx]['id'] as int;
      entities.removeAt(idx);
      final fixedSql = schema['fixed_sql'] as List<dynamic>;
      fixedSql.removeWhere((s) => s['name'] == tableName);
      for (final e in entities) {
        (e['references'] as List<dynamic>).remove(id);
      }
    }
  }

  // Schema v5:
  // - maintenance_schedules: without 'tipo', 'posicion', 'nombre_autogenerado'
  // - maintenance_records: without 'kind'
  final v5 = clone(v6);
  final sched5 = (v5['entities'] as List<dynamic>).firstWhere(
    (e) => e['data']['name'] == 'maintenance_schedules',
  );
  (sched5['data']['columns'] as List<dynamic>).removeWhere(
    (c) => ['tipo', 'posicion', 'nombre_autogenerado'].contains(c['name']),
  );
  final rec5 = (v5['entities'] as List<dynamic>).firstWhere(
    (e) => e['data']['name'] == 'maintenance_records',
  );
  (rec5['data']['columns'] as List<dynamic>).removeWhere(
    (c) => c['name'] == 'kind',
  );
  const sched5Sql =
      'CREATE TABLE IF NOT EXISTS "maintenance_schedules" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "vehicle_id" INTEGER NOT NULL REFERENCES vehicles (id) ON DELETE CASCADE, "nombre" TEXT NOT NULL, "categoria" TEXT NOT NULL, "interval_km" INTEGER NULL, "interval_meses" INTEGER NULL, "aviso_km" INTEGER NULL, "aviso_dias" INTEGER NULL, "activo" INTEGER NOT NULL DEFAULT 1 CHECK ("activo" IN (0, 1)), "silenciado" INTEGER NOT NULL DEFAULT 0 CHECK ("silenciado" IN (0, 1)), "orden" INTEGER NOT NULL DEFAULT 0, "fuente_intervalo" TEXT NOT NULL DEFAULT \'orientativo\');';
  const rec5Sql =
      'CREATE TABLE IF NOT EXISTS "maintenance_records" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "vehicle_id" INTEGER NOT NULL REFERENCES vehicles (id) ON DELETE CASCADE, "schedule_id" INTEGER NULL REFERENCES maintenance_schedules (id) ON DELETE SET NULL, "fecha" INTEGER NOT NULL, "km" INTEGER NOT NULL, "coste" REAL NULL, "taller" TEXT NULL, "notas" TEXT NULL, "es_sembrado" INTEGER NOT NULL DEFAULT 0 CHECK ("es_sembrado" IN (0, 1)));';
  ((v5['fixed_sql'] as List<dynamic>).firstWhere(
        (s) => s['name'] == 'maintenance_schedules',
      )['sql']
      as List<dynamic>)[0]['sql'] = sched5Sql;
  ((v5['fixed_sql'] as List<dynamic>).firstWhere(
        (s) => s['name'] == 'maintenance_records',
      )['sql']
      as List<dynamic>)[0]['sql'] = rec5Sql;
  File('drift_schemas/drift_schema_v5.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(v5),
  );

  // Schema v4:
  // - maintenance_schedules: without 'fuente_intervalo'
  final v4 = clone(v5);
  final sched4 = (v4['entities'] as List<dynamic>).firstWhere(
    (e) => e['data']['name'] == 'maintenance_schedules',
  );
  (sched4['data']['columns'] as List<dynamic>).removeWhere(
    (c) => c['name'] == 'fuente_intervalo',
  );
  const sched4Sql =
      'CREATE TABLE IF NOT EXISTS "maintenance_schedules" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "vehicle_id" INTEGER NOT NULL REFERENCES vehicles (id) ON DELETE CASCADE, "nombre" TEXT NOT NULL, "categoria" TEXT NOT NULL, "interval_km" INTEGER NULL, "interval_meses" INTEGER NULL, "aviso_km" INTEGER NULL, "aviso_dias" INTEGER NULL, "activo" INTEGER NOT NULL DEFAULT 1 CHECK ("activo" IN (0, 1)), "silenciado" INTEGER NOT NULL DEFAULT 0 CHECK ("silenciado" IN (0, 1)), "orden" INTEGER NOT NULL DEFAULT 0);';
  ((v4['fixed_sql'] as List<dynamic>).firstWhere(
        (s) => s['name'] == 'maintenance_schedules',
      )['sql']
      as List<dynamic>)[0]['sql'] = sched4Sql;
  File('drift_schemas/drift_schema_v4.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(v4),
  );

  // Schema v3:
  // - remove vehicle_specifications
  final v3 = clone(v4);
  removeTable(v3, 'vehicle_specifications');
  File('drift_schemas/drift_schema_v3.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(v3),
  );

  // Schema v2:
  // - remove maintenance_records and maintenance_schedules
  final v2 = clone(v3);
  removeTable(v2, 'maintenance_records');
  removeTable(v2, 'maintenance_schedules');
  File('drift_schemas/drift_schema_v2.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(v2),
  );

  // Schema v1:
  // - vehicles without 'color_valor'
  final v1 = clone(v2);
  final veh1 = (v1['entities'] as List<dynamic>).firstWhere(
    (e) => e['data']['name'] == 'vehicles',
  );
  (veh1['data']['columns'] as List<dynamic>).removeWhere(
    (c) => c['name'] == 'color_valor',
  );
  const veh1Sql =
      'CREATE TABLE IF NOT EXISTS "vehicles" ("id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "marca" TEXT NOT NULL, "modelo" TEXT NOT NULL, "version" TEXT NULL, "anio" INTEGER NULL, "matricula" TEXT NULL, "combustible" TEXT NOT NULL, "fecha_matriculacion" INTEGER NULL, "color" TEXT NULL, "foto_path" TEXT NULL, "vin" TEXT NULL, "notas" TEXT NULL, "creado_en" INTEGER NOT NULL DEFAULT (CAST(strftime(\'%s\', CURRENT_TIMESTAMP) AS INTEGER)), "archivado" INTEGER NOT NULL DEFAULT 0 CHECK ("archivado" IN (0, 1)));';
  ((v1['fixed_sql'] as List<dynamic>).firstWhere((s) => s['name'] == 'vehicles')[
        'sql'
      ]
      as List<dynamic>)[0]['sql'] = veh1Sql;
  File('drift_schemas/drift_schema_v1.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(v1),
  );

  print('Generated schemas v1 through v5 successfully');
}
