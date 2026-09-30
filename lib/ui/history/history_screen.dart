import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/maintenance_category.dart';
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
  MaintenanceCategory? _filtroCategoria;
  final _busquedaController = TextEditingController();
  String _busqueda = '';

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  void _limpiarFiltros() {
    setState(() {
      _filtroVehiculoId = null;
      _filtroCategoria = null;
      _busqueda = '';
      _busquedaController.clear();
    });
  }

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
            filtroCategoria: _filtroCategoria,
            busqueda: _busqueda,
            busquedaController: _busquedaController,
            onVehiculoChanged: (id) => setState(() => _filtroVehiculoId = id),
            onCategoriaChanged: (cat) => setState(() => _filtroCategoria = cat),
            onBusquedaChanged: (texto) => setState(() => _busqueda = texto),
            onLimpiarFiltros: _limpiarFiltros,
          ),
        ),
      ),
    );
  }
}

/// Normaliza un texto para búsqueda insensible a mayúsculas y acentos.
String _normalizar(String texto) {
  return texto
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u');
}

/// Cuerpo de la pantalla una vez resueltos el historial y los vehículos: el
/// buscador, los filtros, y la lista o el estado vacío que corresponda.
class _ContenidoHistorial extends ConsumerWidget {
  final List<MaintenanceRecord> registros;
  final List<Vehicle> vehiculos;
  final int? filtroVehiculoId;
  final MaintenanceCategory? filtroCategoria;
  final String busqueda;
  final TextEditingController busquedaController;
  final ValueChanged<int?> onVehiculoChanged;
  final ValueChanged<MaintenanceCategory?> onCategoriaChanged;
  final ValueChanged<String> onBusquedaChanged;
  final VoidCallback onLimpiarFiltros;

  const _ContenidoHistorial({
    required this.registros,
    required this.vehiculos,
    required this.filtroVehiculoId,
    required this.filtroCategoria,
    required this.busqueda,
    required this.busquedaController,
    required this.onVehiculoChanged,
    required this.onCategoriaChanged,
    required this.onBusquedaChanged,
    required this.onLimpiarFiltros,
  });

  bool _coincideBusqueda({
    required MaintenanceRecord registro,
    required MaintenanceSchedule? schedule,
    required Vehicle? vehiculo,
    required String queryNorm,
  }) {
    if (queryNorm.isEmpty) return true;

    final campos = <String>[];
    if (schedule != null) {
      campos.add(schedule.nombre);
      final catEtiqueta = etiquetasCategoria[schedule.categoria];
      if (catEtiqueta != null) campos.add(catEtiqueta);
      if (schedule.tipo != null) {
        final tipoEtiqueta = etiquetasMaintenanceType[schedule.tipo];
        if (tipoEtiqueta != null) campos.add(tipoEtiqueta);
      }
      if (schedule.posicion != null) {
        final posEtiqueta = etiquetasPosicion[schedule.posicion];
        if (posEtiqueta != null) campos.add(posEtiqueta);
      }
    } else {
      campos.add('Reparación puntual');
    }

    if (registro.taller != null) campos.add(registro.taller!);
    if (registro.notas != null) campos.add(registro.notas!);
    if (registro.kind != null) {
      final kindEtiqueta = etiquetasMaintenanceOperationKind[registro.kind];
      if (kindEtiqueta != null) campos.add(kindEtiqueta);
    }
    if (vehiculo != null) {
      campos.add('${vehiculo.marca} ${vehiculo.modelo}');
    }

    for (final campo in campos) {
      if (_normalizar(campo).contains(queryNorm)) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final porVehiculoId = {for (final v in vehiculos) v.id: v};

    // Nombre del mantenimiento de cada registro, combinando los
    // mantenimientos vivos de todos los vehículos. Un registro solo puede
    // apuntar a un mantenimiento que sigue existiendo: si se borra, la base
    // de datos pone su scheduleId a nulo. Así que basta con mirar los
    // mantenimientos actuales de cada vehículo, no hace falta guardar nada
    // de los borrados.
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

    final categoriasPresentes =
        schedulesPorId.values.map((s) => s.categoria).toSet().toList()
          ..sort(
            (a, b) => (etiquetasCategoria[a] ?? '').compareTo(
              etiquetasCategoria[b] ?? '',
            ),
          );

    final queryNorm = _normalizar(busqueda.trim());
    final filtrados = registros.where((r) {
      if (filtroVehiculoId != null && r.vehicleId != filtroVehiculoId) {
        return false;
      }
      final schedule = schedulesPorId[r.scheduleId];
      if (filtroCategoria != null && schedule?.categoria != filtroCategoria) {
        return false;
      }
      final vehiculo = porVehiculoId[r.vehicleId];
      return _coincideBusqueda(
        registro: r,
        schedule: schedule,
        vehiculo: vehiculo,
        queryNorm: queryNorm,
      );
    }).toList();

    final hayFiltrosActivos =
        busqueda.trim().isNotEmpty ||
        filtroCategoria != null ||
        filtroVehiculoId != null;

    return Column(
      children: [
        if (registros.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: busquedaController,
              decoration: InputDecoration(
                hintText: 'Buscar por concepto, taller o notas...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: busqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Borrar búsqueda',
                        onPressed: () {
                          busquedaController.clear();
                          onBusquedaChanged('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: tema.colorScheme.outlineVariant,
                  ),
                ),
                filled: true,
                fillColor: tema.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
              ),
              onChanged: onBusquedaChanged,
            ),
          ),
          if (vehiculos.length > 1)
            _FiltroVehiculo(
              vehiculos: vehiculos,
              seleccionado: filtroVehiculoId,
              onChanged: onVehiculoChanged,
            ),
          if (categoriasPresentes.isNotEmpty)
            _FiltroCategorias(
              categorias: categoriasPresentes,
              seleccionada: filtroCategoria,
              onChanged: onCategoriaChanged,
            ),
        ],
        Expanded(
          child: filtrados.isEmpty
              ? (registros.isEmpty
                    ? const EmptyState(
                        icono: Icons.history,
                        titulo: 'Todavía no hay nada registrado',
                        descripcion:
                            'Aquí irá apareciendo cada mantenimiento y '
                            'reparación que registres.',
                      )
                    : (filtroVehiculoId != null &&
                            busqueda.trim().isEmpty &&
                            filtroCategoria == null
                        ? const EmptyState(
                            icono: Icons.history,
                            titulo: 'Sin registros para este vehículo',
                            descripcion:
                                'Prueba a quitar el filtro para ver el resto del '
                                'historial.',
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 56,
                                    color: tema.colorScheme.outline,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Sin resultados',
                                    style: tema.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No se encontraron intervenciones con los filtros actuales.',
                                    textAlign: TextAlign.center,
                                    style: tema.textTheme.bodyMedium?.copyWith(
                                      color: tema.colorScheme.outline,
                                    ),
                                  ),
                                  if (hayFiltrosActivos) ...[
                                    const SizedBox(height: 16),
                                    OutlinedButton.icon(
                                      onPressed: onLimpiarFiltros,
                                      icon: const Icon(
                                        Icons.filter_alt_off_outlined,
                                      ),
                                      label: const Text('Limpiar filtros'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )))
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

/// Filtro por categoría: "Todas" más un chip por cada categoría con mantenimientos.
class _FiltroCategorias extends StatelessWidget {
  final List<MaintenanceCategory> categorias;
  final MaintenanceCategory? seleccionada;
  final ValueChanged<MaintenanceCategory?> onChanged;

  const _FiltroCategorias({
    required this.categorias,
    required this.seleccionada,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ChoiceChip(
              label: const Text('Todas las categorías'),
              selected: seleccionada == null,
              onSelected: (_) => onChanged(null),
            ),
            for (final cat in categorias) ...[
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(etiquetasCategoria[cat] ?? cat.name),
                selected: seleccionada == cat,
                onSelected: (_) => onChanged(cat),
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
