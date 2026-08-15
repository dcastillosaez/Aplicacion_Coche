import 'package:drift/drift.dart';

import '../../domain/fuente_intervalo.dart';
import '../../domain/maintenance_category.dart';
import '../../domain/maintenance_type.dart';
import '../../domain/posicion.dart';
import 'vehicles.dart';

export '../../domain/fuente_intervalo.dart';
export '../../domain/maintenance_category.dart';
export '../../domain/maintenance_type.dart';
export '../../domain/posicion.dart';

class MaintenanceSchedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();
  TextColumn get nombre => text().withLength(min: 1, max: 80)();
  TextColumn get categoria => textEnum<MaintenanceCategory>()();

  /// Al menos uno de los dos intervalos debe tener valor. La comprobación
  /// vive en el formulario: SQLite no puede expresarla sin un CHECK que
  /// complicaría las migraciones.
  IntColumn get intervalKm => integer().nullable()();
  IntColumn get intervalMeses => integer().nullable()();

  /// Márgenes de aviso propios. A nulo, se heredan los de Settings.
  IntColumn get avisoKm => integer().nullable()();
  IntColumn get avisoDias => integer().nullable()();

  BoolColumn get activo => boolean().withDefault(const Constant(true))();

  /// Sigue calculando su estado, pero no genera notificación.
  BoolColumn get silenciado => boolean().withDefault(const Constant(false))();

  IntColumn get orden => integer().withDefault(const Constant(0))();

  /// Ver `FuenteIntervalo`. Todo mantenimiento tiene una fuente, incluso
  /// los que no la eligieron explícitamente: por defecto es orientativo.
  TextColumn get fuenteIntervalo =>
      textEnum<FuenteIntervalo>().withDefault(const Constant('orientativo'))();

  /// Qué es, del catálogo. Nulo en los mantenimientos ya configurados
  /// antes de que existiera este campo, y en cualquiera nuevo que no use
  /// el catálogo: siguen funcionando igual, solo con nombre libre.
  TextColumn get tipo => textEnum<MaintenanceType>().nullable()();

  /// Dónde, cuando el tipo lo admite (`MaintenanceType.admitePosicion`).
  TextColumn get posicion => textEnum<Posicion>().nullable()();

  /// Si `nombre` se generó solo a partir de tipo+posición (y por tanto se
  /// regenera si cambian) o si el usuario lo editó a mano (y por tanto se
  /// queda quieto para siempre, aunque cambie el tipo o la posición).
  BoolColumn get nombreAutogenerado =>
      boolean().withDefault(const Constant(false))();
}
