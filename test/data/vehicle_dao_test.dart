import 'package:car_care/data/database.dart';
import 'package:car_care/data/tables/vehicles.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  VehiclesCompanion mercedes() => const VehiclesCompanion(
        marca: Value('Mercedes-Benz'),
        modelo: Value('Clase B'),
        version: Value('B 180'),
        anio: Value(2009),
        combustible: Value(FuelType.diesel),
        color: Value('Rojo'),
      );

  test('inserta un vehiculo y lo recupera por id', () async {
    final id = await db.vehicleDao.insertar(mercedes());

    final guardado = await db.vehicleDao.getById(id);

    expect(guardado, isNotNull);
    expect(guardado!.marca, 'Mercedes-Benz');
    expect(guardado.combustible, FuelType.diesel);
    expect(guardado.archivado, isFalse);
  });

  test('watchActivos emite los vehiculos no archivados', () async {
    await db.vehicleDao.insertar(mercedes());

    final activos = await db.vehicleDao.watchActivos().first;

    expect(activos, hasLength(1));
    expect(activos.single.modelo, 'Clase B');
  });

  test('archivar excluye el vehiculo de watchActivos', () async {
    final id = await db.vehicleDao.insertar(mercedes());

    await db.vehicleDao.archivar(id);
    final activos = await db.vehicleDao.watchActivos().first;

    expect(activos, isEmpty);
    expect((await db.vehicleDao.getById(id))!.archivado, isTrue);
  });

  test('actualizar persiste los cambios de un vehiculo existente', () async {
    final id = await db.vehicleDao.insertar(mercedes());
    final original = (await db.vehicleDao.getById(id))!;

    final actualizado = original.copyWith(
      marca: 'Seat',
      modelo: 'León',
      color: const Value('Azul'),
    );
    final ok = await db.vehicleDao.actualizar(actualizado);

    expect(ok, isTrue);
    final guardado = await db.vehicleDao.getById(id);
    expect(guardado!.marca, 'Seat');
    expect(guardado.modelo, 'León');
    expect(guardado.color, 'Azul');
  });

  test('la fila de ajustes se crea con los valores por defecto', () async {
    final ajustes = await db.select(db.settings).getSingle();

    expect(ajustes.avisoKmPorDefecto, 1000);
    expect(ajustes.avisoDiasPorDefecto, 30);
    expect(ajustes.diasRecordatorioLectura, 15);
    expect(ajustes.tema, 'automatico');
  });
}
