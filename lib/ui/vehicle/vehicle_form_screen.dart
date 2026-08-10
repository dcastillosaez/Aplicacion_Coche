import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/database.dart';
import '../../data/tables/vehicles.dart';
import '../../providers/providers.dart';

const Map<FuelType, String> etiquetasCombustible = {
  FuelType.gasolina: 'Gasolina',
  FuelType.diesel: 'Diésel',
  FuelType.hibrido: 'Híbrido',
  FuelType.electrico: 'Eléctrico',
  FuelType.glp: 'GLP',
};

class VehicleFormScreen extends ConsumerStatefulWidget {
  final Vehicle? vehiculo;

  const VehicleFormScreen({super.key, this.vehiculo});

  @override
  ConsumerState<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends ConsumerState<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formatoFecha = DateFormat('dd/MM/yyyy', 'es_ES');

  late final TextEditingController _marca;
  late final TextEditingController _modelo;
  late final TextEditingController _version;
  late final TextEditingController _anio;
  late final TextEditingController _matricula;
  late final TextEditingController _color;

  FuelType _combustible = FuelType.diesel;
  DateTime? _fechaMatriculacion;
  String? _fotoPath;
  bool _guardando = false;

  bool get _esEdicion => widget.vehiculo != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehiculo;
    _marca = TextEditingController(text: v?.marca ?? '');
    _modelo = TextEditingController(text: v?.modelo ?? '');
    _version = TextEditingController(text: v?.version ?? '');
    _anio = TextEditingController(text: v?.anio?.toString() ?? '');
    _matricula = TextEditingController(text: v?.matricula ?? '');
    _color = TextEditingController(text: v?.color ?? '');
    _combustible = v?.combustible ?? FuelType.diesel;
    _fechaMatriculacion = v?.fechaMatriculacion;
    _fotoPath = v?.fotoPath;
  }

  @override
  void dispose() {
    for (final c in [_marca, _modelo, _version, _anio, _matricula, _color]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    final elegida = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (elegida == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final carpeta = Directory(p.join(dir.path, 'fotos'));
    await carpeta.create(recursive: true);

    final destino = p.join(
      carpeta.path,
      '${DateTime.now().millisecondsSinceEpoch}${p.extension(elegida.path)}',
    );
    await File(elegida.path).copy(destino);

    final anterior = _fotoPath;
    if (anterior != null && anterior != destino) {
      try {
        await File(anterior).delete();
      } catch (_) {
        // Un fichero ya inexistente o un borrado fallido no debe impedir
        // guardar la foto nueva.
      }
    }

    if (!mounted) return;
    setState(() => _fotoPath = destino);
  }

  Future<void> _elegirFechaMatriculacion() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaMatriculacion ?? DateTime(2015),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (elegida == null) return;
    if (!mounted) return;
    setState(() => _fechaMatriculacion = elegida);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final dao = ref.read(databaseProvider).vehicleDao;
    String? textoONulo(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();

    try {
      if (_esEdicion) {
        await dao.actualizar(
          widget.vehiculo!.copyWith(
            marca: _marca.text.trim(),
            modelo: _modelo.text.trim(),
            version: Value(textoONulo(_version)),
            anio: Value(int.tryParse(_anio.text.trim())),
            matricula: Value(textoONulo(_matricula)),
            combustible: _combustible,
            fechaMatriculacion: Value(_fechaMatriculacion),
            color: Value(textoONulo(_color)),
            fotoPath: Value(_fotoPath),
          ),
        );
      } else {
        await dao.insertar(
          VehiclesCompanion(
            marca: Value(_marca.text.trim()),
            modelo: Value(_modelo.text.trim()),
            version: Value(textoONulo(_version)),
            anio: Value(int.tryParse(_anio.text.trim())),
            matricula: Value(textoONulo(_matricula)),
            combustible: Value(_combustible),
            fechaMatriculacion: Value(_fechaMatriculacion),
            color: Value(textoONulo(_color)),
            fotoPath: Value(_fotoPath),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se ha podido guardar el vehículo. Inténtalo de nuevo.',
          ),
        ),
      );
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar vehículo' : 'Nuevo vehículo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _SelectorFoto(ruta: _fotoPath, onPulsar: _elegirFoto),
            const SizedBox(height: 24),
            TextFormField(
              controller: _marca,
              decoration: const InputDecoration(labelText: 'Marca'),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Indica la marca' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _modelo,
              decoration: const InputDecoration(labelText: 'Modelo'),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Indica el modelo' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _version,
              decoration: const InputDecoration(
                labelText: 'Versión',
                hintText: '2.0 TDI 150 CV DSG',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<FuelType>(
              initialValue: _combustible,
              decoration: const InputDecoration(labelText: 'Combustible'),
              items: FuelType.values
                  .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(etiquetasCombustible[f]!),
                      ))
                  .toList(),
              onChanged: (f) => setState(() => _combustible = f!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _anio,
              decoration: const InputDecoration(labelText: 'Año'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return null;
                final n = int.tryParse(v.trim());
                if (n == null || n < 1950 || n > DateTime.now().year + 1) {
                  return 'Año no válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _matricula,
              decoration: const InputDecoration(labelText: 'Matrícula'),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _color,
              decoration: const InputDecoration(labelText: 'Color'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha de matriculación'),
              subtitle: Text(
                _fechaMatriculacion == null
                    ? 'Sin indicar — hace falta para calcular la ITV'
                    : _formatoFecha.format(_fechaMatriculacion!),
              ),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _elegirFechaMatriculacion,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(_esEdicion ? 'Guardar cambios' : 'Crear vehículo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectorFoto extends StatelessWidget {
  final String? ruta;
  final VoidCallback onPulsar;

  const _SelectorFoto({required this.ruta, required this.onPulsar});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return GestureDetector(
      onTap: onPulsar,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 180,
          width: double.infinity,
          color: tema.colorScheme.surfaceContainerHighest,
          child: ruta == null
              ? _marcador(tema)
              : Image.file(
                  File(ruta!),
                  fit: BoxFit.cover,
                  // Si el fichero ya no está en disco, se ofrece añadir otra
                  // foto en lugar de romper la pantalla.
                  errorBuilder: (_, _, _) => _marcador(tema),
                ),
        ),
      ),
    );
  }

  Widget _marcador(ThemeData tema) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined,
            size: 32, color: tema.colorScheme.outline),
        const SizedBox(height: 8),
        Text('Añadir foto', style: tema.textTheme.bodyMedium),
      ],
    );
  }
}
