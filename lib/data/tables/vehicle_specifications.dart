import 'package:drift/drift.dart';

import '../../domain/tipo_caja.dart';
import '../../domain/traccion.dart';
import 'vehicles.dart';

export '../../domain/tipo_caja.dart';
export '../../domain/traccion.dart';

/// Ficha técnica de un vehículo, en relación uno a uno con [Vehicles].
///
/// `vehicleId` es la clave primaria de esta tabla, no un `id` autoincremental
/// aparte: así la relación 1:1 queda forzada por el propio esquema, no solo
/// por convención en el código.
class VehicleSpecifications extends Table {
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();

  TextColumn get generacion => text().nullable()();
  TextColumn get motorCodigo => text().nullable()();
  IntColumn get cilindradaCc => integer().nullable()();

  /// Siempre en kilovatios, como en la ficha técnica oficial. El CV se
  /// calcula al mostrarlo (ver `lib/domain/potencia.dart`) y nunca se
  /// guarda aquí.
  IntColumn get potenciaKw => integer().nullable()();

  TextColumn get tipoCaja => textEnum<TipoCaja>().nullable()();
  IntColumn get numeroMarchas => integer().nullable()();
  TextColumn get traccion => textEnum<Traccion>().nullable()();

  /// Identificador de variante de un catálogo externo (p. ej. el KType de
  /// TecDoc). Nunca se rellena a mano: solo lo resolverá un catálogo, si
  /// alguna vez existe. Sin UI en esta fase.
  TextColumn get codigoTecnico => text().nullable()();

  TextColumn get notasTecnicas => text().nullable()();

  @override
  Set<Column> get primaryKey => {vehicleId};
}
