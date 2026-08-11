import 'package:car_care/data/database.dart';
import 'package:car_care/data/tables/maintenance_schedules.dart';
import 'package:car_care/data/tables/vehicles.dart';
import 'package:car_care/domain/maintenance_due.dart';
import 'package:car_care/providers/mantenimiento_providers.dart';
import 'package:car_care/providers/providers.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late int vehicleId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    vehicleId = await db.vehicleDao.insertar(
      const VehiclesCompanion(
        marca: Value('Seat'),
        modelo: Value('León ST'),
        combustible: Value(FuelType.diesel),
      ),
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<int> crearSchedule(
    String nombre, {
    int? intervalKm,
    int? intervalMeses,
  }) {
    return db.maintenanceDao.insertarSchedule(
      MaintenanceSchedulesCompanion.insert(
        vehicleId: vehicleId,
        nombre: nombre,
        categoria: MaintenanceCategory.motor,
        intervalKm: Value(intervalKm),
        intervalMeses: Value(intervalMeses),
      ),
    );
  }

  Future<void> crearRecord(int scheduleId, DateTime fecha, int km) {
    return db.maintenanceDao.insertarRecord(
      MaintenanceRecordsCompanion.insert(
        vehicleId: vehicleId,
        scheduleId: Value(scheduleId),
        fecha: fecha,
        km: km,
      ),
    );
  }

  test(
    'ordena por severidad real, no solo por la via de tiempo',
    () async {
      final ahora = DateTime.now();
      // Fija el kilometraje actual con una lectura real: así el resto del
      // test solo depende de los kilómetros de cada mantenimiento, no de la
      // corrección del kilometraje de referencia (que se prueba aparte).
      await db.mileageDao.registrar(
        vehicleId: vehicleId,
        fecha: ahora,
        km: 500000,
      );

      // Muy vencido por km: 435.000 km de retraso.
      final severoKm = await crearSchedule('Severo por km', intervalKm: 15000);
      await crearRecord(severoKm, DateTime(2024, 1, 1), 50000);

      // Vencido por km, pero solo por 5 km.
      final leveKm = await crearSchedule('Leve por km', intervalKm: 15000);
      await crearRecord(leveKm, DateTime(2024, 1, 1), 484995);

      // Vencido por tiempo desde hace mucho (intervalo corto, revisión
      // antigua): con mucho más retraso que "Ambas vias" pero menos que
      // "Severo por km".
      final soloTiempo = await crearSchedule('Solo tiempo', intervalMeses: 3);
      await crearRecord(
        soloTiempo,
        ahora.subtract(const Duration(days: 500)),
        400000,
      );

      // Vencido solo por fecha (por km aún falta mucho): el menos vencido
      // de los cuatro.
      final ambas = await crearSchedule(
        'Ambas vias',
        intervalKm: 15000,
        intervalMeses: 3,
      );
      await crearRecord(
        ambas,
        ahora.subtract(const Duration(days: 100)),
        496000,
      );

      final lista =
          await container.read(vencimientosProvider(vehicleId).future);

      expect(
        lista.every((m) => m.vencimiento.estado == EstadoMantenimiento.vencido),
        isTrue,
      );
      expect(lista.map((m) => m.schedule.nombre), [
        'Severo por km',
        'Solo tiempo',
        'Ambas vias',
        'Leve por km',
      ]);
    },
  );

  test(
    'un vehiculo sin lecturas usa el km sembrado en sus mantenimientos como '
    'suelo, y no lo da por al dia',
    () async {
      // Vehículo recién dado de alta: ninguna lectura de kilometraje.
      final schedule = await crearSchedule('Aceite y filtro', intervalKm: 15000);
      // Sembrado hace más de un año a 48.000 km: con el ritmo por defecto
      // (33 km/día) la proyección hasta hoy supera de sobra los 63.000 km
      // del próximo cambio.
      await crearRecord(
        schedule,
        DateTime.now().subtract(const Duration(days: 500)),
        48000,
      );

      final lista =
          await container.read(vencimientosProvider(vehicleId).future);

      expect(lista.single.vencimiento.estado, isNot(EstadoMantenimiento.ok));
      expect(lista.single.vencimiento.kmProyectado, greaterThanOrEqualTo(48000));
    },
  );
}
