import 'package:car_care/data/database.dart';
import 'package:car_care/data/tables/mileage_readings.dart';
import 'package:car_care/data/tables/vehicles.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late int vehicleId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    vehicleId = await db.vehicleDao.insertar(
      const VehiclesCompanion(
        marca: Value('Seat'),
        modelo: Value('León ST'),
        combustible: Value(FuelType.diesel),
      ),
    );
  });
  tearDown(() => db.close());

  test('registra una lectura y la devuelve como ultima', () async {
    await db.mileageDao.registrar(
      vehicleId: vehicleId,
      fecha: DateTime(2026, 8, 1),
      km: 98420,
    );

    final ultima = await db.mileageDao.ultimaLectura(vehicleId);

    expect(ultima!.km, 98420);
    expect(ultima.origen, MileageOrigin.manual);
    expect(ultima.fecha, DateTime(2026, 8, 1));
  });

  test('la ultima lectura es la de fecha mas reciente, no la ultima insertada',
      () async {
    await db.mileageDao
        .registrar(vehicleId: vehicleId, fecha: DateTime(2026, 8, 5), km: 98900);
    await db.mileageDao
        .registrar(vehicleId: vehicleId, fecha: DateTime(2026, 8, 1), km: 98420);

    final ultima = await db.mileageDao.ultimaLectura(vehicleId);

    expect(ultima!.km, 98900);
  });

  test('dos lecturas del mismo dia dejan solo la ultima', () async {
    await db.mileageDao
        .registrar(vehicleId: vehicleId, fecha: DateTime(2026, 8, 1), km: 98420);
    await db.mileageDao
        .registrar(vehicleId: vehicleId, fecha: DateTime(2026, 8, 1), km: 98500);

    final todas = await db.mileageDao.watchTodas(vehicleId).first;

    expect(todas, hasLength(1));
    expect(todas.single.km, 98500);
  });

  test('la hora del dia no crea lecturas duplicadas', () async {
    await db.mileageDao.registrar(
        vehicleId: vehicleId, fecha: DateTime(2026, 8, 1, 9, 30), km: 98420);
    await db.mileageDao.registrar(
        vehicleId: vehicleId, fecha: DateTime(2026, 8, 1, 21, 15), km: 98460);

    final todas = await db.mileageDao.watchTodas(vehicleId).first;

    expect(todas, hasLength(1));
    expect(todas.single.km, 98460);
  });

  test('lecturasDesde filtra por fecha', () async {
    await db.mileageDao
        .registrar(vehicleId: vehicleId, fecha: DateTime(2026, 1, 10), km: 90000);
    await db.mileageDao
        .registrar(vehicleId: vehicleId, fecha: DateTime(2026, 7, 10), km: 97000);

    final recientes =
        await db.mileageDao.lecturasDesde(vehicleId, DateTime(2026, 6, 1));

    expect(recientes, hasLength(1));
    expect(recientes.single.km, 97000);
  });

  test('borrar el vehiculo arrastra sus lecturas', () async {
    await db.mileageDao
        .registrar(vehicleId: vehicleId, fecha: DateTime(2026, 8, 1), km: 98420);

    await (db.delete(db.vehicles)..where((v) => v.id.equals(vehicleId))).go();
    final todas = await db.mileageDao.watchTodas(vehicleId).first;

    expect(todas, isEmpty);
  });
}
