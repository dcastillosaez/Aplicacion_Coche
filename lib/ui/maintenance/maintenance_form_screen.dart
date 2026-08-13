import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/tables/maintenance_schedules.dart';
import '../../providers/providers.dart';
import '../common/formatters.dart';

const Map<MaintenanceCategory, String> etiquetasCategoria = {
  MaintenanceCategory.motor: 'Motor',
  MaintenanceCategory.frenos: 'Frenos',
  MaintenanceCategory.neumaticos: 'Neumáticos',
  MaintenanceCategory.electricidad: 'Electricidad',
  MaintenanceCategory.suspension: 'Suspensión',
  MaintenanceCategory.transmision: 'Transmisión',
  MaintenanceCategory.carroceria: 'Carrocería',
  MaintenanceCategory.itv: 'ITV',
  MaintenanceCategory.otro: 'Otro',
  MaintenanceCategory.direccion: 'Dirección',
  MaintenanceCategory.climatizacion: 'Climatización',
  MaintenanceCategory.escapeEmisiones: 'Escape y emisiones',
  MaintenanceCategory.habitaculo: 'Habitáculo',
  MaintenanceCategory.seguridad: 'Seguridad',
};

class MaintenanceFormScreen extends ConsumerStatefulWidget {
  final int vehicleId;
  final MaintenanceSchedule? schedule;

  const MaintenanceFormScreen({
    super.key,
    required this.vehicleId,
    this.schedule,
  });

  @override
  ConsumerState<MaintenanceFormScreen> createState() =>
      _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends ConsumerState<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombre;
  late final TextEditingController _intervalKm;
  late final TextEditingController _intervalMeses;
  late final TextEditingController _avisoKm;
  late final TextEditingController _avisoDias;

  /// Datos de siembra: solo tienen sentido al crear. Al editar ni se
  /// muestran ni se leen, porque a esas alturas ya habrá registros reales.
  late final TextEditingController _siembraKm;
  DateTime? _siembraFecha;

  late MaintenanceCategory _categoria;
  late bool _silenciado;

  bool _guardando = false;

  /// Si se está borrando el mantenimiento (independiente de _guardando: no
  /// pueden solaparse, pero necesitan su propio texto de error y su propio
  /// guardado de reentrada).
  bool _borrando = false;

  bool get _esEdicion => widget.schedule != null;

  bool get _ocupado => _guardando || _borrando;

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    _nombre = TextEditingController(text: s?.nombre ?? '');
    _intervalKm = TextEditingController(text: s?.intervalKm?.toString() ?? '');
    _intervalMeses = TextEditingController(
      text: s?.intervalMeses?.toString() ?? '',
    );
    _avisoKm = TextEditingController(text: s?.avisoKm?.toString() ?? '');
    _avisoDias = TextEditingController(text: s?.avisoDias?.toString() ?? '');
    _siembraKm = TextEditingController();
    _categoria = s?.categoria ?? MaintenanceCategory.motor;
    _silenciado = s?.silenciado ?? false;
  }

  @override
  void dispose() {
    for (final c in [
      _nombre,
      _intervalKm,
      _intervalMeses,
      _avisoKm,
      _avisoDias,
      _siembraKm,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Válido si está vacío o es un entero mayor que 0. Para los intervalos:
  /// un intervalo de 0 no tiene sentido, siempre estaría vencido.
  String? _enteroPositivoOpcional(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = int.tryParse(v.trim());
    if (n == null || n <= 0) return 'Tiene que ser mayor que 0';
    return null;
  }

  /// Válido si está vacío o es un entero mayor o igual que 0. Para
  /// kilómetros y márgenes de aviso, que sí admiten el cero.
  String? _enteroNoNegativoOpcional(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = int.tryParse(v.trim());
    if (n == null || n < 0) return 'No puede ser negativo';
    return null;
  }

  // Un mantenimiento sin ningún intervalo no se puede calcular nunca: no
  // habría forma de saber cuándo toca. En vez de descubrirlo con un
  // SnackBar tras pulsar Guardar, el error se ancla al propio campo —igual
  // que el resto de validaciones del formulario— y se repite en los dos
  // campos cuando ambos están vacíos, para que sea imposible pasarlo por
  // alto sin importar cuál mires primero.
  String? _validarIntervalKm(String? v) {
    final error = _enteroPositivoOpcional(v);
    if (error != null) return error;
    if ((v == null || v.trim().isEmpty) && _intervalMeses.text.trim().isEmpty) {
      return 'Indica un intervalo por km o por meses';
    }
    return null;
  }

  String? _validarIntervalMeses(String? v) {
    final error = _enteroPositivoOpcional(v);
    if (error != null) return error;
    if ((v == null || v.trim().isEmpty) && _intervalKm.text.trim().isEmpty) {
      return 'Indica un intervalo por km o por meses';
    }
    return null;
  }

  Future<void> _elegirSiembraFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (elegida == null) return;
    if (!mounted) return;
    setState(() => _siembraFecha = elegida);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final siembraKmTexto = _siembraKm.text.trim();
    final haySiembraKm = siembraKmTexto.isNotEmpty;
    final haySiembraFecha = _siembraFecha != null;
    // Sembrar exige los dos datos a la vez: un MaintenanceRecord no se
    // puede guardar con la fecha o el kilometraje a medias.
    if (haySiembraKm != haySiembraFecha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Para registrar el último mantenimiento indica la fecha y los '
            'kilómetros, o deja los dos en blanco.',
          ),
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    final db = ref.read(databaseProvider);
    final dao = db.maintenanceDao;
    int? entero(TextEditingController c) {
      final texto = c.text.trim();
      return texto.isEmpty ? null : int.tryParse(texto);
    }

    try {
      if (_esEdicion) {
        await dao.actualizarSchedule(
          widget.schedule!.copyWith(
            nombre: _nombre.text.trim(),
            categoria: _categoria,
            intervalKm: Value(entero(_intervalKm)),
            intervalMeses: Value(entero(_intervalMeses)),
            avisoKm: Value(entero(_avisoKm)),
            avisoDias: Value(entero(_avisoDias)),
            silenciado: _silenciado,
          ),
        );
      } else {
        // La creación del mantenimiento y la siembra de su historial van en
        // la misma transacción: si la segunda escritura fallara tras la
        // primera, se quedaría un mantenimiento sin forma de sembrarlo más
        // tarde, porque editar nunca vuelve a ofrecer estos campos.
        await db.transaction(() async {
          final id = await dao.insertarSchedule(
            MaintenanceSchedulesCompanion.insert(
              vehicleId: widget.vehicleId,
              nombre: _nombre.text.trim(),
              categoria: _categoria,
              intervalKm: Value(entero(_intervalKm)),
              intervalMeses: Value(entero(_intervalMeses)),
              avisoKm: Value(entero(_avisoKm)),
              avisoDias: Value(entero(_avisoDias)),
              silenciado: Value(_silenciado),
            ),
          );

          if (haySiembraKm && haySiembraFecha) {
            await dao.insertarRecord(
              MaintenanceRecordsCompanion.insert(
                vehicleId: widget.vehicleId,
                scheduleId: Value(id),
                fecha: _siembraFecha!,
                km: int.parse(siembraKmTexto),
                esSembrado: const Value(true),
              ),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error al guardar el mantenimiento: $e');
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

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmarBorrar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar mantenimiento'),
        content: const Text(
          'Deja de calcularse y de aparecer en la ficha del vehículo. Los '
          'registros que ya tenga guardados no se borran, pero quedan '
          'sueltos, sin este mantenimiento al que pertenecían.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    if (!mounted) return;
    await _borrar();
  }

  Future<void> _borrar() async {
    final schedule = widget.schedule;
    if (schedule == null) return;
    setState(() => _borrando = true);

    final dao = ref.read(databaseProvider).maintenanceDao;
    try {
      await dao.borrarSchedule(schedule.id);
    } catch (e) {
      debugPrint('Error al borrar el mantenimiento: $e');
      if (!mounted) return;
      setState(() => _borrando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se ha podido borrar el mantenimiento. Inténtalo de nuevo.',
          ),
        ),
      );
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esEdicion ? 'Editar mantenimiento' : 'Nuevo mantenimiento',
        ),
        actions: [
          if (_esEdicion)
            IconButton(
              onPressed: _ocupado ? null : _confirmarBorrar,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Borrar mantenimiento',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        // Los dos intervalos se validan en pareja: si no, al rellenar uno de
        // ellos el error del otro seguiría en pantalla hasta volver a pulsar
        // Guardar, diciendo que falta algo que ya se ha corregido.
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Aceite y filtro',
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Indica un nombre' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MaintenanceCategory>(
              initialValue: _categoria,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: MaintenanceCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(etiquetasCategoria[c]!),
                    ),
                  )
                  .toList(),
              onChanged: (c) => setState(() => _categoria = c!),
            ),
            const SizedBox(height: 20),
            Text('Intervalo', style: tema.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Indica al menos uno de los dos. Con los dos rellenos, avisa '
              'el que llegue antes.',
              style: tema.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _intervalKm,
                    decoration: const InputDecoration(labelText: 'Cada (km)'),
                    keyboardType: TextInputType.number,
                    validator: _validarIntervalKm,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _intervalMeses,
                    decoration: const InputDecoration(
                      labelText: 'Cada (meses)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validarIntervalMeses,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Márgenes de aviso propios', style: tema.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Opcionales. En blanco, se usan los márgenes generales de '
              'Ajustes.',
              style: tema.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _avisoKm,
                    decoration: const InputDecoration(
                      labelText: 'Aviso (km)',
                      hintText: 'General',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _enteroNoNegativoOpcional,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _avisoDias,
                    decoration: const InputDecoration(
                      labelText: 'Aviso (días)',
                      hintText: 'General',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _enteroNoNegativoOpcional,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Silenciado'),
              subtitle: const Text(
                'Sigue calculando su estado, pero no genera avisos.',
              ),
              value: _silenciado,
              onChanged: (v) => setState(() => _silenciado = v),
            ),
            if (!_esEdicion) ...[
              const SizedBox(height: 12),
              Text('Último realizado', style: tema.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                'Opcional. Si ya se hizo antes de empezar a usar la app, '
                'indícalo para poder calcular el próximo vencimiento.',
                style: tema.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha'),
                subtitle: Text(
                  _siembraFecha == null
                      ? 'Sin indicar'
                      : formatearFecha(_siembraFecha!),
                ),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _elegirSiembraFecha,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _siembraKm,
                decoration: const InputDecoration(labelText: 'Kilómetros'),
                keyboardType: TextInputType.number,
                validator: _enteroNoNegativoOpcional,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _ocupado ? null : _guardar,
              child: Text(
                _esEdicion ? 'Guardar cambios' : 'Crear mantenimiento',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
