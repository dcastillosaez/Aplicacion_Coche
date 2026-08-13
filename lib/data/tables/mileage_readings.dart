import 'package:drift/drift.dart';

import 'vehicles.dart';

enum MileageOrigin { manual, mantenimiento }

class MileageReadings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get vehicleId =>
      integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get fecha => dateTime()();
  IntColumn get km => integer()();
  TextColumn get origen => textEnum<MileageOrigin>()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {vehicleId, fecha},
  ];
}
