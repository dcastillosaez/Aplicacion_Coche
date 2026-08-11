import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/tables/mileage_readings.dart' show MileageOrigin;
import '../../providers/mantenimiento_providers.dart';
import '../../providers/providers.dart';
import '../common/formatters.dart';

/// Abre la hoja para registrar un mantenimiento ya realizado.
///
/// Si [schedule] no es nulo, se llega desde ese mantenimiento concreto de la
/// ficha y queda preseleccionado. Si es nulo, se llega desde la ficha del
/// vehículo en general y hay que elegir cuál (o dejarlo como reparación
/// puntual, sin mantenimiento asociado).
Future<void> mostrarRegistroMantenimiento(
  BuildContext context, {
  required int vehicleId,
  MaintenanceSchedule? schedule,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (contextHoja) => Padding(
      // El hueco del teclado se calcula con el contexto del propio builder
      // de la hoja, no con el de quien la abre: ese segundo contexto puede
      // venir de un Scaffold que ya se ha restado su propio viewInsets,
      // dejando la hoja tapada por el teclado.
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(contextHoja).bottom,
      ),
      child: SafeArea(
        child: _HojaRegistroMantenimiento(
          vehicleId: vehicleId,
          scheduleInicial: schedule,
        ),
      ),
    ),
  );
}

class _HojaRegistroMantenimiento extends ConsumerStatefulWidget {
  final int vehicleId;
  final MaintenanceSchedule? scheduleInicial;

  const _HojaRegistroMantenimiento({
    required this.vehicleId,
    this.scheduleInicial,
  });

  @override
  ConsumerState<_HojaRegistroMantenimiento> createState() =>
      _HojaRegistroMantenimientoState();
}

class _HojaRegistroMantenimientoState
    extends ConsumerState<_HojaRegistroMantenimiento> {
  final _formKey = GlobalKey<FormState>();
  final _kmController = TextEditingController();
  final _costeController = TextEditingController();
  final _tallerController = TextEditingController();
  final _notasController = TextEditingController();

  int? _scheduleSeleccionadoId;
  late DateTime _fecha;

  /// El kilometraje solo se rellena por defecto una vez, con la última
  /// lectura conocida en cuanto llega. A partir de ahí es cosa del usuario.
  bool _kmInicializado = false;

  bool _guardando = false;

  bool get _esReparacionPuntual => _scheduleSeleccionadoId == null;

  @override
  void initState() {
    super.initState();
    _scheduleSeleccionadoId = widget.scheduleInicial?.id;
    _fecha = DateUtils.dateOnly(DateTime.now());
  }

  @override
  void dispose() {
    _kmController.dispose();
    _costeController.dispose();
    _tallerController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (elegida == null) return;
    if (!mounted) return;
    setState(() => _fecha = elegida);
  }

  String? _validarKm(String? v) {
    final texto = (v ?? '').trim();
    if (texto.isEmpty) return 'Indica los kilómetros';
    final n = int.tryParse(texto);
    if (n == null || n < 0) return 'Introduce un número válido';
    return null;
  }

  String? _validarCoste(String? v) {
    final texto = (v ?? '').trim();
    if (texto.isEmpty) return null;
    final n = double.tryParse(texto.replaceAll(',', '.'));
    if (n == null || n < 0) return 'Introduce un importe válido';
    return null;
  }

  Future<void> _guardar() async {
    // El botón se deshabilita al guardar, pero por si acaso: sin esta
    // guarda, dos pulsaciones rápidas ejecutarían el guardado dos veces en
    // paralelo.
    if (_guardando) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final km = int.parse(_kmController.text.trim());
    final costeTexto = _costeController.text.trim();
    final coste =
        costeTexto.isEmpty ? null : double.parse(costeTexto.replaceAll(',', '.'));
    final taller = _tallerController.text.trim();
    final notas = _notasController.text.trim();
    final scheduleId = _scheduleSeleccionadoId;
    final fecha = _fecha;

    final db = ref.read(databaseProvider);
    var seRegistroKm = false;

    try {
      // El mantenimiento realizado y la actualización del kilometraje van en
      // la misma transacción: son dos caras del mismo hecho ("hoy he hecho
      // esto, y el coche está a tantos km"), y una escritura a medias
      // dejaría datos inconsistentes entre las dos tablas. El mismo criterio
      // que la siembra al crear un mantenimiento en maintenance_form_screen.
      await db.transaction(() async {
        await db.maintenanceDao.insertarRecord(
          MaintenanceRecordsCompanion.insert(
            vehicleId: widget.vehicleId,
            scheduleId: Value(scheduleId),
            fecha: fecha,
            km: km,
            coste: Value(coste),
            taller: Value(taller.isEmpty ? null : taller),
            notas: Value(notas.isEmpty ? null : notas),
          ),
        );

        // MileageDao.registrar sustituye la lectura existente de ese mismo
        // día (hay una única lectura posible por día y vehículo). Si ese día
        // ya tiene una lectura mayor que el kilometraje del mantenimiento,
        // sobrescribirla la rebajaría y falsearía el dato: se omite el
        // registro de kilometraje y solo queda el mantenimiento.
        final lecturasDelDia =
            await db.mileageDao.lecturasDesde(widget.vehicleId, fecha);
        final huboLecturaEseDia = lecturasDelDia.isNotEmpty &&
            DateUtils.isSameDay(lecturasDelDia.first.fecha, fecha);
        final kmLecturaEseDia =
            huboLecturaEseDia ? lecturasDelDia.first.km : null;

        if (kmLecturaEseDia == null || km >= kmLecturaEseDia) {
          await db.mileageDao.registrar(
            vehicleId: widget.vehicleId,
            fecha: fecha,
            km: km,
            origen: MileageOrigin.mantenimiento,
          );
          seRegistroKm = true;
        }
      });
    } catch (e) {
      debugPrint('Error al guardar el mantenimiento realizado: $e');
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se ha podido guardar el mantenimiento. Inténtalo de nuevo.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    // vencimientosProvider y estadoVehiculoProvider cachean su resultado
    // porque hacen una consulta directa al DAO en lugar de observar un
    // stream: sin invalidarlos, la ficha seguiría mostrando el vencimiento
    // de antes de guardar. ritmoUsoProvider solo hace falta recalcularlo si
    // de verdad se ha tocado el kilometraje.
    if (seRegistroKm) {
      ref.invalidate(ritmoUsoProvider(widget.vehicleId));
    }
    ref.invalidate(vencimientosProvider(widget.vehicleId));
    ref.invalidate(estadoVehiculoProvider(widget.vehicleId));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    final schedulesAsync = ref.watch(schedulesProvider(widget.vehicleId));
    final schedules = schedulesAsync.valueOrNull ?? const <MaintenanceSchedule>[];
    final opciones = List<MaintenanceSchedule>.of(schedules);
    final inicial = widget.scheduleInicial;
    if (inicial != null && !opciones.any((s) => s.id == inicial.id)) {
      opciones.insert(0, inicial);
    }

    final ultima = ref.watch(ultimaLecturaProvider(widget.vehicleId));
    if (!_kmInicializado) {
      final lectura = ultima.valueOrNull;
      if (lectura != null) {
        _kmInicializado = true;
        // Se difiere al siguiente frame: mutar el controlador aquí mismo
        // dispararía el listener interno del TextField mientras este mismo
        // widget todavía se está construyendo.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _kmController.text = lectura.km.toString();
        });
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registrar mantenimiento realizado',
                style: tema.textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int?>(
                initialValue: _scheduleSeleccionadoId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Mantenimiento'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text(
                      'Reparación puntual (sin mantenimiento asociado)',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ...opciones.map(
                    (s) => DropdownMenuItem<int?>(
                      value: s.id,
                      child: Text(s.nombre, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (id) => setState(() => _scheduleSeleccionadoId = id),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha'),
                subtitle: Text(formatearFecha(_fecha)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _elegirFecha,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kmController,
                decoration: const InputDecoration(
                  labelText: 'Kilómetros',
                  suffixText: 'km',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _validarKm,
              ),
              ultima.maybeWhen(
                data: (l) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l == null
                        ? 'Todavía sin kilometraje registrado'
                        : 'Última lectura: ${formatearKm(l.km)}',
                    style: tema.textTheme.bodySmall
                        ?.copyWith(color: tema.colorScheme.outline),
                  ),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _costeController,
                decoration: const InputDecoration(
                  labelText: 'Coste',
                  suffixText: '€',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                validator: _validarCoste,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tallerController,
                decoration: const InputDecoration(labelText: 'Taller'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notasController,
                decoration: const InputDecoration(labelText: 'Notas'),
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 3,
              ),
              if (_esReparacionPuntual) ...[
                const SizedBox(height: 4),
                Text(
                  'No corresponde a ningún mantenimiento configurado.',
                  style: tema.textTheme.bodySmall
                      ?.copyWith(color: tema.colorScheme.outline),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
