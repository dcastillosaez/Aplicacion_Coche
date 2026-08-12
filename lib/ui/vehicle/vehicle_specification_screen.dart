import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/potencia.dart';
import '../../domain/tipo_caja.dart';
import '../../domain/traccion.dart';
import '../../providers/providers.dart';

/// Ficha técnica del vehículo: generación, motor, potencia, caja de cambios,
/// tracción y notas técnicas. Relación 1:1 con el vehículo, resuelta como
/// upsert por `VehicleSpecificationDao.guardar`: esta pantalla no necesita
/// distinguir si ya existía una ficha o se crea por primera vez.
///
/// Sin campo para `codigoTecnico`: depende de un catálogo externo que no
/// existe todavía (fases futuras), así que ningún flujo puede rellenarlo
/// hoy y mostrarlo aquí solo confundiría.
class VehicleSpecificationScreen extends ConsumerStatefulWidget {
  final int vehicleId;

  const VehicleSpecificationScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<VehicleSpecificationScreen> createState() =>
      _VehicleSpecificationScreenState();
}

class _VehicleSpecificationScreenState
    extends ConsumerState<VehicleSpecificationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _generacion;
  late final TextEditingController _motorCodigo;
  late final TextEditingController _cilindradaCc;
  late final TextEditingController _potenciaKw;
  late final TextEditingController _numeroMarchas;
  late final TextEditingController _notasTecnicas;

  TipoCaja? _tipoCaja;
  Traccion? _traccion;

  bool _guardando = false;

  /// Los campos se rellenan una única vez, la primera vez que el provider
  /// entrega algo (una ficha ya guardada o `null`). Si se volvieran a
  /// rellenar en cada emisión del stream, un guardado con éxito pisaría lo
  /// que el usuario estuviera escribiendo a continuación.
  bool _inicializado = false;

  @override
  void initState() {
    super.initState();
    _generacion = TextEditingController();
    _motorCodigo = TextEditingController();
    _cilindradaCc = TextEditingController();
    _potenciaKw = TextEditingController();
    _numeroMarchas = TextEditingController();
    _notasTecnicas = TextEditingController();
  }

  @override
  void dispose() {
    for (final c in [
      _generacion,
      _motorCodigo,
      _cilindradaCc,
      _potenciaKw,
      _numeroMarchas,
      _notasTecnicas,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _rellenarDesde(VehicleSpecification? ficha) {
    _generacion.text = ficha?.generacion ?? '';
    _motorCodigo.text = ficha?.motorCodigo ?? '';
    _cilindradaCc.text = ficha?.cilindradaCc?.toString() ?? '';
    _potenciaKw.text = ficha?.potenciaKw?.toString() ?? '';
    _numeroMarchas.text = ficha?.numeroMarchas?.toString() ?? '';
    _notasTecnicas.text = ficha?.notasTecnicas ?? '';
    _tipoCaja = ficha?.tipoCaja;
    _traccion = ficha?.traccion;
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final dao = ref.read(databaseProvider).vehicleSpecificationDao;
    String? textoONulo(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    int? numeroONulo(TextEditingController c) => int.tryParse(c.text.trim());

    try {
      await dao.guardar(
        VehicleSpecificationsCompanion.insert(
          vehicleId: Value(widget.vehicleId),
          generacion: Value(textoONulo(_generacion)),
          motorCodigo: Value(textoONulo(_motorCodigo)),
          cilindradaCc: Value(numeroONulo(_cilindradaCc)),
          potenciaKw: Value(numeroONulo(_potenciaKw)),
          tipoCaja: Value(_tipoCaja),
          numeroMarchas: Value(numeroONulo(_numeroMarchas)),
          traccion: Value(_traccion),
          notasTecnicas: Value(textoONulo(_notasTecnicas)),
        ),
      );
    } catch (e) {
      debugPrint('Error al guardar la ficha técnica: $e');
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se ha podido guardar la ficha técnica. Inténtalo de nuevo.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  /// Vacío es válido (el campo es opcional); si hay texto, tiene que ser un
  /// número, o quien lo escriba nunca sabría que se guardó como si no
  /// hubiera puesto nada.
  String? _validarNumeroOpcional(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    return int.tryParse(valor.trim()) == null ? 'Tiene que ser un número' : null;
  }

  @override
  Widget build(BuildContext context) {
    final especificacion =
        ref.watch(vehicleSpecificationProvider(widget.vehicleId));

    return Scaffold(
      appBar: AppBar(title: const Text('Identidad técnica')),
      body: especificacion.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) {
          debugPrint('Error al cargar la ficha técnica: $e\n$st');
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No se ha podido cargar la ficha técnica.'),
            ),
          );
        },
        data: (ficha) {
          if (!_inicializado) {
            _inicializado = true;
            _rellenarDesde(ficha);
          }
          return _formulario();
        },
      ),
    );
  }

  Widget _formulario() {
    final kw = int.tryParse(_potenciaKw.text.trim());

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          TextFormField(
            controller: _generacion,
            decoration: const InputDecoration(
              labelText: 'Generación',
              hintText: 'F30, MK7, B8...',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _motorCodigo,
            decoration: const InputDecoration(labelText: 'Código de motor'),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cilindradaCc,
            decoration: const InputDecoration(labelText: 'Cilindrada (cc)'),
            keyboardType: TextInputType.number,
            validator: _validarNumeroOpcional,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _potenciaKw,
            decoration: InputDecoration(
              labelText: 'Potencia (kW)',
              helperText: kw == null ? null : '≈ ${kwACv(kw)} CV',
            ),
            keyboardType: TextInputType.number,
            validator: _validarNumeroOpcional,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<TipoCaja?>(
            initialValue: _tipoCaja,
            decoration: const InputDecoration(labelText: 'Caja de cambios'),
            items: [
              const DropdownMenuItem<TipoCaja?>(
                value: null,
                child: Text('Sin especificar'),
              ),
              ...TipoCaja.values.map(
                (t) => DropdownMenuItem<TipoCaja?>(
                  value: t,
                  child: Text(etiquetasTipoCaja[t]!),
                ),
              ),
            ],
            onChanged: (t) => setState(() => _tipoCaja = t),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _numeroMarchas,
            decoration: const InputDecoration(labelText: 'Número de marchas'),
            keyboardType: TextInputType.number,
            validator: _validarNumeroOpcional,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Traccion?>(
            initialValue: _traccion,
            decoration: const InputDecoration(labelText: 'Tracción'),
            items: [
              const DropdownMenuItem<Traccion?>(
                value: null,
                child: Text('Sin especificar'),
              ),
              ...Traccion.values.map(
                (t) => DropdownMenuItem<Traccion?>(
                  value: t,
                  child: Text(etiquetasTraccion[t]!),
                ),
              ),
            ],
            onChanged: (t) => setState(() => _traccion = t),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notasTecnicas,
            decoration: const InputDecoration(labelText: 'Notas técnicas'),
            textCapitalization: TextCapitalization.sentences,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _guardando ? null : _guardar,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
