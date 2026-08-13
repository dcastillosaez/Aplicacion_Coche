import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../domain/maintenance_due.dart';
import '../domain/patron_real_uso.dart';
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

final schedulesProvider = StreamProvider.family<List<MaintenanceSchedule>, int>(
  (ref, vehicleId) {
    return ref.watch(databaseProvider).maintenanceDao.watchSchedules(vehicleId);
  },
);

/// Patrón real de uso de un mantenimiento concreto. Nulo si hay menos de
/// dos registros reales: no hay patrón que mostrar todavía. No depende de
/// la fecha de hoy, así que no hace falta recalcularlo al volver a primer
/// plano.
final patronRealProvider = FutureProvider.family<PatronRealUso?, int>((
  ref,
  scheduleId,
) async {
  final registros = await ref
      .watch(databaseProvider)
      .maintenanceDao
      .registrosRealesDe(scheduleId);
  return calcularPatronReal(
    registros.map((r) => (fecha: r.fecha, km: r.km)).toList(),
  );
});

/// Todo lo registrado, de todos los vehículos, para el historial.
final historialProvider = StreamProvider<List<MaintenanceRecord>>((ref) {
  return ref.watch(databaseProvider).maintenanceDao.watchTodosLosRecords();
});

/// Mantenimientos de un vehículo con su vencimiento ya calculado, ordenados
/// por urgencia: lo más vencido primero.
final vencimientosProvider =
    FutureProvider.family<List<MantenimientoConVencimiento>, int>((
      ref,
      vehicleId,
    ) async {
      final db = ref.watch(databaseProvider);
      final schedules = await ref.watch(schedulesProvider(vehicleId).future);
      final ritmo = await ref.watch(ritmoUsoProvider(vehicleId).future);
      final ultimaLectura = await ref.watch(
        ultimaLecturaProvider(vehicleId).future,
      );
      final ajustes = await ref.watch(ajustesProvider.future);
      final ultimos = await db.maintenanceDao.ultimosRecordsPorSchedule(
        vehicleId,
      );

      final ahora = DateTime.now();

      // Kilometraje de referencia: lo mejor que la app sabe del coche. Un
      // vehículo recién dado de alta no tiene lecturas, pero si se le han
      // sembrado mantenimientos con su último cambio a un kilometraje dado, el
      // coche no puede tener menos km que ese: es un suelo fiable. Entre todos
      // los candidatos (la lectura y el último registro de cada mantenimiento)
      // se toma el de mayor kilometraje, junto con SU fecha, para que la
      // proyección por ritmo cuente los días transcurridos desde ese dato y no
      // desde hoy mismo.
      final candidatos = [
        if (ultimaLectura != null)
          (km: ultimaLectura.km, fecha: ultimaLectura.fecha),
        for (final r in ultimos.values) (km: r.km, fecha: r.fecha),
      ];
      final int kmActual;
      final DateTime fechaLectura;
      if (candidatos.isEmpty) {
        kmActual = 0;
        fechaLectura = ahora;
      } else {
        final mejor = candidatos.reduce((a, b) => a.km >= b.km ? a : b);
        kmActual = mejor.km;
        fechaLectura = mejor.fecha;
      }

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

      resultado.sort(
        (a, b) => urgenciaVencimiento(a).compareTo(urgenciaVencimiento(b)),
      );
      return resultado;
    });

/// Estado general del vehículo: el peor de sus mantenimientos.
final estadoVehiculoProvider = FutureProvider.family<EstadoMantenimiento, int>((
  ref,
  vehicleId,
) async {
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
/// atención, y dentro de cada grupo lo que antes llega de las dos vías —no
/// solo la de tiempo, que dejaría empatados (y al final del grupo) a todos
/// los mantenimientos que van solo por kilómetros.
///
/// Pública porque también la usa Inicio para ordenar la lista global de
/// próximos vencimientos, que combina mantenimientos de varios vehículos: es
/// el mismo criterio de urgencia, no una copia.
int urgenciaVencimiento(MantenimientoConVencimiento m) {
  final base = switch (m.vencimiento.estado) {
    EstadoMantenimiento.vencido => 0,
    EstadoMantenimiento.atencion => 1000000,
    EstadoMantenimiento.proximo => 2000000,
    EstadoMantenimiento.ok => 3000000,
    EstadoMantenimiento.sinConfigurar => 4000000,
  };
  final dias = m.vencimiento.diasHastaVencimiento ?? 9999;
  return base + dias.clamp(-9999, 9999);
}
