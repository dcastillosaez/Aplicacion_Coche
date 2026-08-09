import 'package:drift/drift.dart';

enum FuelType { gasolina, diesel, hibrido, electrico, glp }

class Vehicles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get marca => text().withLength(min: 1, max: 60)();
  TextColumn get modelo => text().withLength(min: 1, max: 60)();
  TextColumn get version => text().nullable()();
  IntColumn get anio => integer().nullable()();
  TextColumn get matricula => text().nullable()();
  TextColumn get combustible => textEnum<FuelType>()();
  DateTimeColumn get fechaMatriculacion => dateTime().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get fotoPath => text().nullable()();
  TextColumn get vin => text().nullable()();
  TextColumn get notas => text().nullable()();
  DateTimeColumn get creadoEn => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get archivado => boolean().withDefault(const Constant(false))();
}
