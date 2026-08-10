import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../data/database.dart';
import '../../data/photo_storage.dart';
import '../../data/tables/vehicles.dart';
import '../../providers/providers.dart';
import '../common/formatters.dart';

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

  /// Foto que la base de datos referencia al entrar. No se borra del disco
  /// hasta que un guardado con éxito la sustituya: si se cancela la edición,
  /// la fila sigue apuntando a ella.
  String? _fotoOriginal;

  /// Fotos copiadas durante esta sesión del formulario. Las que no acaben
  /// guardadas se borran al salir para no dejar basura en el almacenamiento.
  final Set<String> _fotosDeLaSesion = {};

  bool _guardadoConExito = false;

  /// Si se está archivando el vehículo (independiente de _guardando: no
  /// pueden darse a la vez, cada acción deshabilita el botón de la otra).
  bool _archivando = false;

  bool get _esEdicion => widget.vehiculo != null;

  bool get _ocupado => _guardando || _archivando;

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
    // En base de datos la foto se guarda como ruta relativa; en el estado
    // del formulario se trabaja con la ruta absoluta, que es la que
    // necesitan File e Image.file.
    final fotoInicial =
        v?.fotoPath == null ? null : PhotoStorage.absoluta(v!.fotoPath!);
    _fotoPath = fotoInicial;
    _fotoOriginal = fotoInicial;
  }

  @override
  void dispose() {
    for (final c in [_marca, _modelo, _version, _anio, _matricula, _color]) {
      c.dispose();
    }
    for (final ruta in _fotosDeLaSesion) {
      if (_guardadoConExito && ruta == _fotoPath) continue;
      _borrarFoto(ruta);
    }
    super.dispose();
  }

  /// Borra una foto del almacenamiento interno. Que el fichero ya no exista
  /// o que el borrado falle nunca debe interrumpir el flujo.
  void _borrarFoto(String ruta) {
    try {
      final fichero = File(ruta);
      if (fichero.existsSync()) fichero.deleteSync();
    } catch (e) {
      debugPrint('No se pudo borrar la foto $ruta: $e');
    }
  }

  Future<void> _elegirFoto() async {
    final elegida = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (elegida == null) return;

    final carpeta = await PhotoStorage.carpetaFotos();

    final destino = p.join(
      carpeta.path,
      '${DateTime.now().millisecondsSinceEpoch}${p.extension(elegida.path)}',
    );
    await File(elegida.path).copy(destino);

    // Solo se borra al vuelo lo que se copió en esta misma sesión. La foto
    // original sigue en disco hasta que el guardado la sustituya de verdad.
    final anterior = _fotoPath;
    if (anterior != null && anterior != destino &&
        _fotosDeLaSesion.remove(anterior)) {
      _borrarFoto(anterior);
    }
    _fotosDeLaSesion.add(destino);

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
    // Se persiste la ruta relativa: la absoluta solo vale en este
    // dispositivo y no sobrevive a una restauración desde copia de
    // seguridad.
    final fotoPathRelativo =
        _fotoPath == null ? null : PhotoStorage.relativa(_fotoPath!);

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
            fotoPath: Value(fotoPathRelativo),
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
            fotoPath: Value(fotoPathRelativo),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al guardar el vehículo: $e');
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

    _guardadoConExito = true;

    // Ahora que la fila ya no la referencia, la foto que había antes puede irse.
    final original = _fotoOriginal;
    if (original != null && original != _fotoPath) _borrarFoto(original);

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmarArchivar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitar vehículo'),
        content: const Text(
          'Dejará de aparecer en la lista de Inicio. Sus datos no se '
          'borran: el vehículo se archiva en la base de datos.',
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
            child: const Text('Quitar vehículo'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    if (!mounted) return;
    await _archivar();
  }

  Future<void> _archivar() async {
    final vehiculo = widget.vehiculo;
    if (vehiculo == null) return;
    setState(() => _archivando = true);

    final dao = ref.read(databaseProvider).vehicleDao;
    try {
      await dao.archivar(vehiculo.id);
    } catch (e) {
      debugPrint('Error al archivar el vehículo: $e');
      if (!mounted) return;
      setState(() => _archivando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se ha podido quitar el vehículo. Inténtalo de nuevo.',
          ),
        ),
      );
      return;
    }

    // A propósito no se marca _guardadoConExito: archivar no cambia la foto
    // que la fila referencia en base de datos (sigue siendo _fotoOriginal),
    // así que dispose() debe limpiar cualquier foto elegida en esta sesión
    // y debe dejar _fotoOriginal intacta, igual que en una edición cancelada.
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar vehículo' : 'Nuevo vehículo'),
        actions: [
          if (_esEdicion)
            IconButton(
              onPressed: _ocupado ? null : _confirmarArchivar,
              icon: const Icon(Icons.archive_outlined),
              tooltip: 'Quitar vehículo',
            ),
        ],
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
                    : formatearFecha(_fechaMatriculacion!),
              ),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _elegirFechaMatriculacion,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _ocupado ? null : _guardar,
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
