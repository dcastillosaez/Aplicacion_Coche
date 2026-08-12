import 'package:drift/drift.dart';

class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get avisoKmPorDefecto =>
      integer().withDefault(const Constant(1000))();
  IntColumn get avisoDiasPorDefecto =>
      integer().withDefault(const Constant(30))();
  IntColumn get diasRecordatorioLectura =>
      integer().withDefault(const Constant(15))();
  TextColumn get tema => text().withDefault(const Constant('automatico'))();
  DateTimeColumn get fechaUltimaCopia => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
