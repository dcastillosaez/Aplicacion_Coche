import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../domain/maintenance_due.dart';
import 'providers.dart';

class MantenimientoConVencimiento {
  final MaintenanceSchedule schedule;
  final MaintenanceRecord? ultimoRegistro;
  final Vencimiento vencimiento;

  const MantenimientoConVencimiento({
    required this.schedule,
    required this.ultimoRegistro,
    required this.vencimiento,
  });
}

final ajustesProvider = FutureProvider<Setting>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.settings).getSingle();
});

final schedulesProvider =
    StreamProvider.family<List<MaintenanceSchedule>, int>((ref, vehicleId) {
  return ref.watch(databaseProvider).maintenanceDao.watchSchedules(vehicleId);
});

/// Mantenimientos de un vehículo con su vencimiento ya calculado, ordenados
/// por urgencia: lo más vencido primero.
final vencimientosProvider =
    FutureProvider.family<List<MantenimientoConVencimiento>, int>(
        (ref, vehicleId) async {
  final db = ref.watch(databaseProvider);
  final schedules = await ref.watch(schedulesProvider(vehicleId).future);
  final ritmo = await ref.watch(ritmoUsoProvider(vehicleId).future);
  final ultimaLectura =
      await ref.watch(ultimaLecturaProvider(vehicleId).future);
  final ajustes = await ref.watch(ajustesProvider.future);
  final ultimos = await db.maintenanceDao.ultimosRecordsPorSchedule(vehicleId);

  final ahora = DateTime.now();
  final kmActual = ultimaLectura?.km ?? 0;
  final fechaLectura = ultimaLectura?.fecha ?? ahora;

  final resultado = <MantenimientoConVencimiento>[];
  for (final s in schedules.where((s) => s.activo)) {
    final ultimo = ultimos[s.id];
    resultado.add(
      MantenimientoConVencimiento(
        schedule: s,
        ultimoRegistro: ultimo,
        vencimiento: calcularVencimiento(
          datos: DatosVencimiento(
            intervalKm: s.intervalKm,
            intervalMeses: s.intervalMeses,
            avisoKm: s.avisoKm,
            avisoDias: s.avisoDias,
            ultimoKm: ultimo?.km,
            ultimaFecha: ultimo?.fecha,
          ),
          kmActual: kmActual,
          fechaUltimaLectura: fechaLectura,
          ritmo: ritmo,
          ahora: ahora,
          avisoKmPorDefecto: ajustes.avisoKmPorDefecto,
          avisoDiasPorDefecto: ajustes.avisoDiasPorDefecto,
        ),
      ),
    );
  }

  resultado.sort((a, b) => _urgencia(a).compareTo(_urgencia(b)));
  return resultado;
});

/// Estado general del vehículo: el peor de sus mantenimientos.
final estadoVehiculoProvider =
    FutureProvider.family<EstadoMantenimiento, int>((ref, vehicleId) async {
  final lista = await ref.watch(vencimientosProvider(vehicleId).future);
  if (lista.isEmpty) return EstadoMantenimiento.sinConfigurar;

  for (final estado in [
    EstadoMantenimiento.vencido,
    EstadoMantenimiento.atencion,
    EstadoMantenimiento.proximo,
    EstadoMantenimiento.ok,
  ]) {
    if (lista.any((m) => m.vencimiento.estado == estado)) return estado;
  }
  return EstadoMantenimiento.sinConfigurar;
});

/// Orden de urgencia para la lista: primero lo vencido, después lo que pide
/// atención, y dentro de cada grupo lo que antes llega.
int _urgencia(MantenimientoConVencimiento m) {
  final base = switch (m.vencimiento.estado) {
    EstadoMantenimiento.vencido => 0,
    EstadoMantenimiento.atencion => 1000000,
    EstadoMantenimiento.proximo => 2000000,
    EstadoMantenimiento.ok => 3000000,
    EstadoMantenimiento.sinConfigurar => 4000000,
  };
  final dias = m.vencimiento.diasRestantes ?? 9999;
  return base + dias.clamp(-9999, 9999);
}
