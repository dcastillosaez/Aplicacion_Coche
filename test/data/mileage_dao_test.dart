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

  test(
    'la ultima lectura es la de fecha mas reciente, no la ultima insertada',
    () async {
      await db.mileageDao.registrar(
        vehicleId: vehicleId,
        fecha: DateTime(2026, 8, 5),
        km: 98900,
      );
      await db.mileageDao.registrar(
        vehicleId: vehicleId,
        fecha: DateTime(2026, 8, 1),
        km: 98420,
      );

      final ultima = await db.mileageDao.ultimaLectura(vehicleId);

      expect(ultima!.km, 98900);
    },
  );

  test('dos lecturas del mismo dia dejan solo la ultima', () async {
    await db.mileageDao.registrar(
      vehicleId: vehicleId,
      fecha: DateTime(2026, 8, 1),
      km: 98420,
    );
    await db.mileageDao.registrar(
      vehicleId: vehicleId,
      fecha: DateTime(2026, 8, 1),
      km: 98500,
    );

    final todas = await db.mileageDao.watchTodas(vehicleId).first;

    expect(todas, hasLength(1));
    expect(todas.single.km, 98500);
  });

  test('la hora del dia no crea lecturas duplicadas', () async {
    await db.mileageDao.registrar(
      vehicleId: vehicleId,
      fecha: DateTime(2026, 8, 1, 9, 30),
      km: 98420,
    );
    await db.mileageDao.registrar(
      vehicleId: vehicleId,
      fecha: DateTime(2026, 8, 1, 21, 15),
      km: 98460,
    );

    final todas = await db.mileageDao.watchTodas(vehicleId).first;

    expect(todas, hasLength(1));
    expect(todas.single.km, 98460);
  });

  test('lecturasDesde filtra por fecha', () async {
    await db.mileageDao.registrar(
      vehicleId: vehicleId,
      fecha: DateTime(2026, 1, 10),
      km: 90000,
    );
    await db.mileageDao.registrar(
      vehicleId: vehicleId,
      fecha: DateTime(2026, 7, 10),
      km: 97000,
    );

    final recientes = await db.mileageDao.lecturasDesde(
      vehicleId,
      DateTime(2026, 6, 1),
    );

    expect(recientes, hasLength(1));
    expect(recientes.single.km, 97000);
  });

  test('una lectura anterior a la ultima conocida no es coherente aunque '
      'lecturasDesde no vea nada desde su fecha', () async {
    // La unica lectura es de hace 8 meses, a 13000 km. Se intenta registrar
    // un mantenimiento de hace 6 meses a 12500 km: lecturasDesde(hace 6
    // meses) no devuelve nada porque la unica lectura es anterior a ese
    // umbral, pero aceptar este valor haria retroceder el kilometraje del
    // coche.
    await db.mileageDao.registrar(
      vehicleId: vehicleId,
      fecha: DateTime(2026, 1, 1),
      km: 13000,
    );

    final coherente = await db.mileageDao.esLecturaCoherente(
      vehicleId,
      DateTime(2026, 3, 1),
      12500,
    );

    expect(coherente, isFalse);
  });

  test('una lectura coherente con el historico se acepta', () async {
    await db.mileageDao.registrar(
      vehicleId: vehicleId,
      fecha: DateTime(2026, 1, 1),
      km: 13000,
    );

    final coherente = await db.mileageDao.esLecturaCoherente(
      vehicleId,
      DateTime(2026, 3, 1),
      13500,
    );

    expect(coherente, isTrue);
  });

  test(
    'una lectura mayor que una posterior ya registrada no es coherente',
    () async {
      await db.mileageDao.registrar(
        vehicleId: vehicleId,
        fecha: DateTime(2026, 6, 1),
        km: 15000,
      );

      final coherente = await db.mileageDao.esLecturaCoherente(
        vehicleId,
        DateTime(2026, 3, 1),
        16000,
      );

      expect(coherente, isFalse);
    },
  );

  test('el mismo dia con una lectura menor a la ya guardada no es coherente '
      '(equivalente al caso ya cubierto antes de la correccion)', () async {
    await db.mileageDao.registrar(
      vehicleId: vehicleId,
      fecha: DateTime(2026, 8, 1),
      km: 98500,
    );

    final coherente = await db.mileageDao.esLecturaCoherente(
      vehicleId,
      DateTime(2026, 8, 1),
      98420,
    );

    expect(coherente, isFalse);
  });

  test('el mismo dia con una lectura mayor o igual si es coherente', () async {
    await db.mileageDao.registrar(
      vehicleId: vehicleId,
      fecha: DateTime(2026, 8, 1),
      km: 98420,
    );

    final coherente = await db.mileageDao.esLecturaCoherente(
      vehicleId,
      DateTime(2026, 8, 1),
      98500,
    );

    expect(coherente, isTrue);
  });

  test('sin ninguna lectura previa, cualquier valor es coherente', () async {
    final coherente = await db.mileageDao.esLecturaCoherente(
      vehicleId,
      DateTime(2026, 8, 1),
      50000,
    );

    expect(coherente, isTrue);
  });

  test('borrar el vehiculo arrastra sus lecturas', () async {
    await db.mileageDao.registrar(
      vehicleId: vehicleId,
      fecha: DateTime(2026, 8, 1),
      km: 98420,
    );

    await (db.delete(db.vehicles)..where((v) => v.id.equals(vehicleId))).go();
    final todas = await db.mileageDao.watchTodas(vehicleId).first;

    expect(todas, isEmpty);
  });
}
