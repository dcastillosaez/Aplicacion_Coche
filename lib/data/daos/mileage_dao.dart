import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/mileage_readings.dart';

part 'mileage_dao.g.dart';

/// Normaliza una fecha a medianoche. La unicidad de lecturas es por día.
DateTime soloFecha(DateTime fecha) =>
    DateTime(fecha.year, fecha.month, fecha.day);

@DriftAccessor(tables: [MileageReadings])
class MileageDao extends DatabaseAccessor<AppDatabase> with _$MileageDaoMixin {
  MileageDao(super.db);

  /// Guarda una lectura. Si ya existe una del mismo día para ese vehículo,
  /// la sustituye.
  Future<void> registrar({
    required int vehicleId,
    required DateTime fecha,
    required int km,
    MileageOrigin origen = MileageOrigin.manual,
  }) {
    return into(mileageReadings).insert(
      MileageReadingsCompanion.insert(
        vehicleId: vehicleId,
        fecha: soloFecha(fecha),
        km: km,
        origen: origen,
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Stream<MileageReading?> watchUltima(int vehicleId) {
    return _consultaUltima(vehicleId).watchSingleOrNull();
  }

  Future<MileageReading?> ultimaLectura(int vehicleId) {
    return _consultaUltima(vehicleId).getSingleOrNull();
  }

  SimpleSelectStatement<$MileageReadingsTable, MileageReading> _consultaUltima(
    int vehicleId,
  ) {
    return select(mileageReadings)
      ..where((l) => l.vehicleId.equals(vehicleId))
      ..orderBy([
        (l) => OrderingTerm(expression: l.fecha, mode: OrderingMode.desc),
      ])
      ..limit(1);
  }

  Future<List<MileageReading>> lecturasDesde(int vehicleId, DateTime desde) {
    return (select(mileageReadings)
          ..where((l) =>
              l.vehicleId.equals(vehicleId) &
              l.fecha.isBiggerOrEqualValue(soloFecha(desde)))
          ..orderBy([(l) => OrderingTerm(expression: l.fecha)]))
        .get();
  }

  Stream<List<MileageReading>> watchTodas(int vehicleId) {
    return (select(mileageReadings)
          ..where((l) => l.vehicleId.equals(vehicleId))
          ..orderBy([
            (l) => OrderingTerm(expression: l.fecha, mode: OrderingMode.desc),
          ]))
        .watch();
  }
}
