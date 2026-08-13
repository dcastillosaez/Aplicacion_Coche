import 'package:car_care/data/database.dart';
import 'package:car_care/data/tables/vehicles.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late int vehicleId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    vehicleId = await db.vehicleDao.insertar(
      const VehiclesCompanion(
        marca: Value('BMW'),
        modelo: Value('Serie 3'),
        combustible: Value(FuelType.diesel),
      ),
    );
  });
  tearDown(() => db.close());

  test('sin ficha guardada, getFor y watchFor devuelven null', () async {
    expect(await db.vehicleSpecificationDao.getFor(vehicleId), isNull);
    expect(await db.vehicleSpecificationDao.watchFor(vehicleId).first, isNull);
  });

  test('guardar crea la ficha la primera vez', () async {
    await db.vehicleSpecificationDao.guardar(
      VehicleSpecificationsCompanion.insert(
        vehicleId: Value(vehicleId),
        motorCodigo: const Value('B47'),
        potenciaKw: const Value(140),
      ),
    );

    final guardada = await db.vehicleSpecificationDao.getFor(vehicleId);

    expect(guardada!.motorCodigo, 'B47');
    expect(guardada.potenciaKw, 140);
  });

  test('guardar dos veces actualiza en vez de duplicar', () async {
    await db.vehicleSpecificationDao.guardar(
      VehicleSpecificationsCompanion.insert(
        vehicleId: Value(vehicleId),
        motorCodigo: const Value('B47'),
      ),
    );
    await db.vehicleSpecificationDao.guardar(
      VehicleSpecificationsCompanion.insert(
        vehicleId: Value(vehicleId),
        motorCodigo: const Value('B48'),
      ),
    );

    final todas = await db.select(db.vehicleSpecifications).get();
    final guardada = await db.vehicleSpecificationDao.getFor(vehicleId);

    expect(todas, hasLength(1));
    expect(guardada!.motorCodigo, 'B48');
  });

  test('borrar el vehiculo arrastra su ficha tecnica', () async {
    await db.vehicleSpecificationDao.guardar(
      VehicleSpecificationsCompanion.insert(
        vehicleId: Value(vehicleId),
        motorCodigo: const Value('B47'),
      ),
    );

    await (db.delete(db.vehicles)..where((v) => v.id.equals(vehicleId))).go();

    expect(await db.select(db.vehicleSpecifications).get(), isEmpty);
  });
}
