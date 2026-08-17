import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/settings.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<int> actualizarTema(String tema) {
    return (update(settings)..where((s) => s.id.equals(1))).write(
      SettingsCompanion(tema: Value(tema)),
    );
  }

  Future<int> actualizarAvisoKmPorDefecto(int km) {
    return (update(settings)..where((s) => s.id.equals(1))).write(
      SettingsCompanion(avisoKmPorDefecto: Value(km)),
    );
  }

  Future<int> actualizarAvisoDiasPorDefecto(int dias) {
    return (update(settings)..where((s) => s.id.equals(1))).write(
      SettingsCompanion(avisoDiasPorDefecto: Value(dias)),
    );
  }

  Future<int> actualizarDiasRecordatorioLectura(int dias) {
    return (update(settings)..where((s) => s.id.equals(1))).write(
      SettingsCompanion(diasRecordatorioLectura: Value(dias)),
    );
  }
}
