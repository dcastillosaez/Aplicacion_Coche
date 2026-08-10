import 'package:drift/drift.dart';

import 'maintenance_schedules.dart';
import 'vehicles.dart';

class MaintenanceRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();

  /// Nulo en reparaciones puntuales que no responden a ningún mantenimiento
  /// configurado. Si se borra el mantenimiento, el registro sobrevive.
  IntColumn get scheduleId => integer()
      .nullable()
      .references(MaintenanceSchedules, #id, onDelete: KeyAction.setNull)();

  DateTimeColumn get fecha => dateTime()();
  IntColumn get km => integer()();
  RealColumn get coste => real().nullable()();
  TextColumn get taller => text().nullable()();
  TextColumn get notas => text().nullable()();

  /// Dato anterior a la instalación de la app, introducido a mano para
  /// poder calcular el primer vencimiento. Cuenta para los cálculos y se
  /// distingue en el historial.
  BoolColumn get esSembrado => boolean().withDefault(const Constant(false))();
}
