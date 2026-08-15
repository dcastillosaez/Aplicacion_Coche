import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers/mantenimiento_providers.dart';
import '../../providers/providers.dart';
import '../common/empty_state.dart';
import '../common/error_con_reintento.dart';
import '../common/formatters.dart';
import '../maintenance/maintenance_form_screen.dart'
    show
        etiquetasCategoria,
        etiquetasMaintenanceOperationKind,
        etiquetasMaintenanceType,
        etiquetasPosicion;

/// Historial de todos los vehículos: la línea temporal de todo lo que se les
/// ha hecho. No es una lista técnica, es la prueba de que el coche está
/// cuidado —algo especialmente útil al venderlo—, así que cada entrada tiene
/// que ser legible por sí sola: qué se hizo, cuándo, a cuántos kilómetros, a
/// qué coche y por cuánto.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  /// Nulo significa "todos los vehículos".
  int? _filtroVehiculoId;

  @override
  Widget build(BuildContext context) {
    final historial = ref.watch(historialProvider);
    // Todos los vehículos, no solo los activos: un registro de historial
    // puede pertenecer a un vehículo archivado (p. ej. vendido), y sigue
    // teniendo derecho a mostrar su marca y modelo reales.
    final vehiculos = ref.watch(vehiculosTodosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: historial.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) {
          debugPrint('Error al cargar el historial: $e\n$st');
          return ErrorConReintento(
            mensaje: 'No se ha podido cargar el historial. Inténtalo de nuevo.',
            onReintentar: () => ref.invalidate(historialProvider),
          );
        },
        data: (registros) => vehiculos.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) {
            debugPrint('Error al cargar los vehículos: $e\n$st');
            return ErrorConReintento(
              mensaje:
                  'No se han podido cargar los vehículos. Inténtalo de '
                  'nuevo.',
              onReintentar: () => ref.invalidate(vehiculosTodosProvider),
            );
          },
          data: (listaVehiculos) => _ContenidoHistorial(
            registros: registros,
            vehiculos: listaVehiculos,
            filtroVehiculoId: _filtroVehiculoId,
            onFiltroChanged: (id) => setState(() => _filtroVehiculoId = id),
          ),
        ),
      ),
    );
  }
}

/// Cuerpo de la pantalla una vez resueltos el historial y los vehículos: el
/// filtro, y la lista o el estado vacío que corresponda.
class _ContenidoHistorial extends ConsumerWidget {
  final List<MaintenanceRecord> registros;
  final List<Vehicle> vehiculos;
  final int? filtroVehiculoId;
  final ValueChanged<int?> onFiltroChanged;

  const _ContenidoHistorial({
    required this.registros,
    required this.vehiculos,
    required this.filtroVehiculoId,
    required this.onFiltroChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final porVehiculoId = {for (final v in vehiculos) v.id: v};

    // Nombre del mantenimiento de cada registro, combinando los
    // mantenimientos vivos de todos los vehículos. Un registro solo puede
    // apuntar a un mantenimiento que sigue existiendo: si se borra, la base
    // de datos pone su scheduleId a nulo. Así que basta con mirar los
    // mantenimientos actuales de cada vehículo, no hace falta guardar nada
    // de los borrados.
    //
    // Cada stream de mantenimientos se resuelve por separado (uno por
    // vehículo), así que no basta con el `.when` de un único provider: hay
    // que esperar a que todos hayan emitido antes de afirmar el nombre de un
    // registro. Mientras alguno siga cargando, un registro con mantenimiento
    // vivo podría mostrarse falsamente como "Reparación puntual".
    final estadosSchedules = [
      for (final v in vehiculos) ref.watch(schedulesProvider(v.id)),
    ];

    if (estadosSchedules.any((s) => !s.hasValue && !s.hasError)) {
      return const Center(child: CircularProgressIndicator());
    }

    AsyncValue<List<MaintenanceSchedule>>? conError;
    for (final estado in estadosSchedules) {
      if (estado.hasError) {
        conError = estado;
        break;
      }
    }
    if (conError != null) {
      debugPrint(
        'Error al cargar los mantenimientos: '
        '${conError.error}\n${conError.stackTrace}',
      );
      return ErrorConReintento(
        mensaje:
            'No se han podido cargar los mantenimientos. Inténtalo de '
            'nuevo.',
        onReintentar: () {
          for (final v in vehiculos) {
            ref.invalidate(schedulesProvider(v.id));
          }
        },
      );
    }

    final schedulesPorId = <int, MaintenanceSchedule>{};
    for (final estado in estadosSchedules) {
      for (final s in estado.value ?? const []) {
        schedulesPorId[s.id] = s;
      }
    }

    final filtrados = filtroVehiculoId == null
        ? registros
        : registros.where((r) => r.vehicleId == filtroVehiculoId).toList();

    return Column(
      children: [
        if (vehiculos.length > 1)
          _FiltroVehiculo(
            vehiculos: vehiculos,
            seleccionado: filtroVehiculoId,
            onChanged: onFiltroChanged,
          ),
        Expanded(
          child: filtrados.isEmpty
              ? EmptyState(
                  icono: Icons.history,
                  titulo: registros.isEmpty
                      ? 'Todavía no hay nada registrado'
                      : 'Sin registros para este vehículo',
                  descripcion: registros.isEmpty
                      ? 'Aquí irá apareciendo cada mantenimiento y '
                            'reparación que registres.'
                      : 'Prueba a quitar el filtro para ver el resto del '
                            'historial.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtrados.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final r = filtrados[i];
                    return _FilaHistorial(
                      registro: r,
                      vehiculo: porVehiculoId[r.vehicleId],
                      schedule: r.scheduleId == null
                          ? null
                          : schedulesPorId[r.scheduleId],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Nombre a mostrar de un vehículo. Si está archivado (p. ej. vendido) se
/// marca con un sufijo discreto: sigue teniendo historial, pero no hay que
/// dar a entender que el coche continúa en uso.
String _nombreVehiculo(Vehicle v) {
  final nombre = '${v.marca} ${v.modelo}';
  return v.archivado ? '$nombre (archivado)' : nombre;
}

/// Tipo (y posición, si la hay) del mantenimiento configurado, listo para
/// mostrar como texto secundario, p. ej. "Pastillas de freno (Delantera)".
/// Nulo si el mantenimiento no tiene tipo asignado.
String? _tipoYPosicion(MaintenanceSchedule schedule) {
  final tipo = schedule.tipo;
  if (tipo == null) return null;
  final etiquetaTipo = etiquetasMaintenanceType[tipo]!;
  final posicion = schedule.posicion;
  if (posicion == null) return etiquetaTipo;
  return '$etiquetaTipo (${etiquetasPosicion[posicion]})';
}

/// Filtro simple y siempre visible: "Todos" más un distintivo por coche.
class _FiltroVehiculo extends StatelessWidget {
  final List<Vehicle> vehiculos;
  final int? seleccionado;
  final ValueChanged<int?> onChanged;

  const _FiltroVehiculo({
    required this.vehiculos,
    required this.seleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('Todos'),
              selected: seleccionado == null,
              onSelected: (_) => onChanged(null),
            ),
            for (final v in vehiculos) ...[
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(_nombreVehiculo(v)),
                selected: seleccionado == v.id,
                onSelected: (_) => onChanged(v.id),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Una entrada del historial. El nombre depende de si el registro sigue
/// apuntando a un mantenimiento vivo:
///
/// - Con `schedule` resuelto: es un mantenimiento configurado, se muestra su
///   nombre real.
/// - Sin `schedule` (scheduleId nulo): puede ser una reparación puntual que
///   nunca tuvo mantenimiento asociado, o uno que se borró después —la base
///   de datos anula el enlace precisamente para no perder el registro—. No
///   hay forma de distinguir un caso del otro a partir del dato guardado, así
///   que se usa un rótulo honesto que vale para ambos, en vez de inventar un
///   nombre que ya no se puede conocer.
class _FilaHistorial extends StatelessWidget {
  final MaintenanceRecord registro;
  final Vehicle? vehiculo;
  final MaintenanceSchedule? schedule;

  const _FilaHistorial({
    required this.registro,
    required this.vehiculo,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final titulo = schedule?.nombre ?? 'Reparación puntual';
    final tipoYPosicion = schedule == null ? null : _tipoYPosicion(schedule!);
    final kind = registro.kind;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(titulo, style: tema.textTheme.titleMedium),
                ),
                if (registro.coste != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    formatearCoste(registro.coste!),
                    style: tema.textTheme.titleMedium,
                  ),
                ],
              ],
            ),
            if (schedule != null) ...[
              const SizedBox(height: 2),
              Text(
                etiquetasCategoria[schedule!.categoria]!,
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.outline,
                ),
              ),
            ],
            if (tipoYPosicion != null) ...[
              const SizedBox(height: 2),
              Text(
                tipoYPosicion,
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.outline,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                _Dato(
                  icono: Icons.event_outlined,
                  texto: formatearFecha(registro.fecha),
                ),
                _Dato(
                  icono: Icons.speed_outlined,
                  texto: formatearKm(registro.km),
                ),
                _Dato(
                  icono: Icons.directions_car_outlined,
                  texto: vehiculo == null
                      ? 'Vehículo no disponible'
                      : _nombreVehiculo(vehiculo!),
                ),
                if (kind != null)
                  _Dato(
                    icono: Icons.build_circle_outlined,
                    texto: etiquetasMaintenanceOperationKind[kind]!,
                  ),
              ],
            ),
            if (registro.taller != null) ...[
              const SizedBox(height: 6),
              Text(
                'Taller: ${registro.taller}',
                style: tema.textTheme.bodySmall,
              ),
            ],
            if (registro.notas != null) ...[
              const SizedBox(height: 4),
              Text(registro.notas!, style: tema.textTheme.bodySmall),
            ],
            if (registro.esSembrado) ...[
              const SizedBox(height: 8),
              _EtiquetaSembrado(),
            ],
          ],
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _Dato({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 16, color: tema.colorScheme.outline),
        const SizedBox(width: 4),
        Text(texto, style: tema.textTheme.bodySmall),
      ],
    );
  }
}

/// Distingue los registros sembrados: datos anteriores a la app,
/// introducidos a mano al configurar un mantenimiento, y no algo que la
/// propia app haya presenciado.
class _EtiquetaSembrado extends StatelessWidget {
  const _EtiquetaSembrado();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.history_edu_outlined,
          size: 14,
          color: tema.colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            'Dato anterior a la app, introducido a mano',
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
