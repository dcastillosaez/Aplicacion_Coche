import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/maintenance_records.dart';
import '../tables/maintenance_schedules.dart';

part 'maintenance_dao.g.dart';

@DriftAccessor(tables: [MaintenanceSchedules, MaintenanceRecords])
class MaintenanceDao extends DatabaseAccessor<AppDatabase>
    with _$MaintenanceDaoMixin {
  MaintenanceDao(super.db);

  Stream<List<MaintenanceSchedule>> watchSchedules(int vehicleId) {
    return (select(maintenanceSchedules)
          ..where((s) => s.vehicleId.equals(vehicleId))
          ..orderBy([
            (s) => OrderingTerm(expression: s.orden),
            (s) => OrderingTerm(expression: s.nombre),
          ]))
        .watch();
  }

  Future<MaintenanceSchedule?> getSchedule(int id) {
    return (select(
      maintenanceSchedules,
    )..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertarSchedule(MaintenanceSchedulesCompanion schedule) {
    return into(maintenanceSchedules).insert(schedule);
  }

  Future<bool> actualizarSchedule(MaintenanceSchedule schedule) {
    return update(maintenanceSchedules).replace(schedule);
  }

  Future<int> borrarSchedule(int id) {
    return (delete(maintenanceSchedules)..where((s) => s.id.equals(id))).go();
  }

  Stream<List<MaintenanceRecord>> watchRecords(int vehicleId) {
    return (select(maintenanceRecords)
          ..where((r) => r.vehicleId.equals(vehicleId))
          ..orderBy([
            (r) => OrderingTerm(expression: r.fecha, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  Stream<List<MaintenanceRecord>> watchTodosLosRecords() {
    return (select(maintenanceRecords)..orderBy([
          (r) => OrderingTerm(expression: r.fecha, mode: OrderingMode.desc),
        ]))
        .watch();
  }

  Future<MaintenanceRecord?> ultimoRecordDe(int scheduleId) {
    return (select(maintenanceRecords)
          ..where((r) => r.scheduleId.equals(scheduleId))
          ..orderBy([
            (r) => OrderingTerm(expression: r.fecha, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Último registro de cada mantenimiento del vehículo, indexado por
  /// `scheduleId`. Una sola consulta en lugar de una por mantenimiento.
  Future<Map<int, MaintenanceRecord>> ultimosRecordsPorSchedule(
    int vehicleId,
  ) async {
    final todos =
        await (select(maintenanceRecords)
              ..where(
                (r) => r.vehicleId.equals(vehicleId) & r.scheduleId.isNotNull(),
              )
              ..orderBy([(r) => OrderingTerm(expression: r.fecha)]))
            .get();

    // Al ir en orden ascendente, el último que se escribe de cada clave es
    // el más reciente.
    return {for (final r in todos) r.scheduleId!: r};
  }

  Future<int> insertarRecord(MaintenanceRecordsCompanion record) {
    return into(maintenanceRecords).insert(record);
  }

  Future<int> borrarRecord(int id) {
    return (delete(maintenanceRecords)..where((r) => r.id.equals(id))).go();
  }
}
