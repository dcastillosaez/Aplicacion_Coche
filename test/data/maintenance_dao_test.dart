import 'package:car_care/data/database.dart';
import 'package:car_care/data/tables/maintenance_schedules.dart';
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
        marca: Value('Seat'),
        modelo: Value('León ST'),
        combustible: Value(FuelType.diesel),
      ),
    );
  });
  tearDown(() => db.close());

  Future<int> crearSchedule({
    String nombre = 'Aceite y filtro',
    int orden = 0,
    int? vehiculo,
  }) {
    return db.maintenanceDao.insertarSchedule(
      MaintenanceSchedulesCompanion.insert(
        vehicleId: vehiculo ?? vehicleId,
        nombre: nombre,
        categoria: MaintenanceCategory.motor,
        intervalKm: const Value(15000),
        orden: Value(orden),
      ),
    );
  }

  Future<int> crearRecord(int? scheduleId, DateTime fecha, int km) {
    return db.maintenanceDao.insertarRecord(
      MaintenanceRecordsCompanion.insert(
        vehicleId: vehicleId,
        scheduleId: Value(scheduleId),
        fecha: fecha,
        km: km,
      ),
    );
  }

  test('inserta un mantenimiento y lo recupera por id', () async {
    final id = await crearSchedule();

    final guardado = await db.maintenanceDao.getSchedule(id);

    expect(guardado!.nombre, 'Aceite y filtro');
    expect(guardado.intervalKm, 15000);
    expect(guardado.activo, isTrue);
    expect(guardado.silenciado, isFalse);
  });

  test('watchSchedules devuelve solo los del vehiculo y en orden', () async {
    final otroVehiculo = await db.vehicleDao.insertar(
      const VehiclesCompanion(
        marca: Value('Mercedes-Benz'),
        modelo: Value('Clase B'),
        combustible: Value(FuelType.diesel),
      ),
    );
    await crearSchedule(nombre: 'Aceite', orden: 2);
    await crearSchedule(nombre: 'Frenos', orden: 1);
    await crearSchedule(nombre: 'De otro coche', vehiculo: otroVehiculo);

    final lista = await db.maintenanceDao.watchSchedules(vehicleId).first;

    expect(lista.map((s) => s.nombre), ['Frenos', 'Aceite']);
  });

  test('ultimoRecordDe devuelve el de fecha mas reciente', () async {
    final id = await crearSchedule();
    await crearRecord(id, DateTime(2026, 8, 1), 100000);
    await crearRecord(id, DateTime(2025, 1, 1), 80000);

    final ultimo = await db.maintenanceDao.ultimoRecordDe(id);

    expect(ultimo!.km, 100000);
  });

  test('ultimosRecordsPorSchedule da el mas reciente de cada uno', () async {
    final aceite = await crearSchedule(nombre: 'Aceite');
    final frenos = await crearSchedule(nombre: 'Frenos');
    await crearRecord(aceite, DateTime(2026, 5, 1), 95000);
    await crearRecord(aceite, DateTime(2025, 1, 1), 80000);
    await crearRecord(frenos, DateTime(2024, 3, 1), 60000);

    final mapa = await db.maintenanceDao.ultimosRecordsPorSchedule(vehicleId);

    expect(mapa[aceite]!.km, 95000);
    expect(mapa[frenos]!.km, 60000);
  });

  test('registrosRealesDe excluye los sembrados y ordena por fecha', () async {
    final id = await crearSchedule();
    await db.maintenanceDao.insertarRecord(
      MaintenanceRecordsCompanion.insert(
        vehicleId: vehicleId,
        scheduleId: Value(id),
        fecha: DateTime(2026, 1, 1),
        km: 90000,
        esSembrado: const Value(true),
      ),
    );
    await db.maintenanceDao.insertarRecord(
      MaintenanceRecordsCompanion.insert(
        vehicleId: vehicleId,
        scheduleId: Value(id),
        fecha: DateTime(2025, 1, 1),
        km: 75000,
      ),
    );
    await db.maintenanceDao.insertarRecord(
      MaintenanceRecordsCompanion.insert(
        vehicleId: vehicleId,
        scheduleId: Value(id),
        fecha: DateTime(2024, 1, 1),
        km: 60000,
      ),
    );

    final reales = await db.maintenanceDao.registrosRealesDe(id);

    expect(reales, hasLength(2));
    expect(reales.map((r) => r.km), [60000, 75000]);
  });

  test('borrar un mantenimiento no borra su historial', () async {
    final id = await crearSchedule();
    await crearRecord(id, DateTime(2026, 5, 1), 95000);

    await db.maintenanceDao.borrarSchedule(id);
    final registros = await db.maintenanceDao.watchRecords(vehicleId).first;

    expect(registros, hasLength(1));
    expect(registros.single.scheduleId, isNull);
    expect(registros.single.km, 95000);
  });

  test('borrar el vehiculo arrastra mantenimientos y registros', () async {
    final id = await crearSchedule();
    await crearRecord(id, DateTime(2026, 5, 1), 95000);

    await (db.delete(db.vehicles)..where((v) => v.id.equals(vehicleId))).go();

    expect(await db.maintenanceDao.watchSchedules(vehicleId).first, isEmpty);
    expect(await db.maintenanceDao.watchRecords(vehicleId).first, isEmpty);
  });
}
