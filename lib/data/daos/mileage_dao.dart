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
          ..where(
            (l) =>
                l.vehicleId.equals(vehicleId) &
                l.fecha.isBiggerOrEqualValue(soloFecha(desde)),
          )
          ..orderBy([(l) => OrderingTerm(expression: l.fecha)]))
        .get();
  }

  /// Indica si una lectura de [km] en [fecha] es coherente con el
  /// historial del vehículo: un coche no desanda kilómetros, así que no
  /// puede ser menor que la lectura anterior a esa fecha ni mayor que la
  /// posterior. La lectura del propio día (si la hay) se trata como el
  /// caso "anterior": `registrar` la sustituye, así que solo hace falta
  /// que el valor nuevo no sea menor que el que ya había.
  Future<bool> esLecturaCoherente(int vehicleId, DateTime fecha, int km) async {
    final dia = soloFecha(fecha);

    final anterior =
        await (select(mileageReadings)
              ..where(
                (l) =>
                    l.vehicleId.equals(vehicleId) &
                    l.fecha.isSmallerThanValue(dia),
              )
              ..orderBy([
                (l) =>
                    OrderingTerm(expression: l.fecha, mode: OrderingMode.desc),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (anterior != null && km < anterior.km) return false;

    // Ascendente desde el propio día: la lectura del mismo día (si la hay,
    // como mucho una por la clave única) llega primero, y justo después la
    // más próxima en el futuro.
    final desde = await lecturasDesde(vehicleId, dia);
    for (final lectura in desde) {
      if (lectura.fecha.isAtSameMomentAs(dia)) {
        if (km < lectura.km) return false;
      } else {
        if (km > lectura.km) return false;
        break;
      }
    }

    return true;
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
