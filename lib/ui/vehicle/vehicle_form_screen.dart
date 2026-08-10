import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../data/database.dart';
import '../../data/photo_storage.dart';
import '../../data/tables/vehicles.dart';
import '../../domain/catalogo_vehiculos.dart';
import '../../domain/colores_vehiculo.dart';
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

  final _marcaFocus = FocusNode();
  final _modeloFocus = FocusNode();

  /// Tono ARGB elegido en la paleta. Independiente del texto de [_color]:
  /// así, tras elegir una muestra, el nombre se puede reescribir a mano
  /// (p. ej. "azul mystery") sin perder el tono ya seleccionado.
  int? _colorValor;

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
    _colorValor = v?.colorValor;
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
    _marcaFocus.dispose();
    _modeloFocus.dispose();
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

  /// Marcas del catálogo que empiezan o contienen el texto escrito. Vacío el
  /// texto, se sugieren todas.
  Iterable<String> _opcionesMarca(TextEditingValue value) {
    final texto = value.text.trim().toLowerCase();
    if (texto.isEmpty) return marcasConocidas;
    return marcasConocidas.where((m) => m.toLowerCase().contains(texto));
  }

  /// Modelos sugeridos para la marca actualmente escrita. Si la marca no
  /// está en el catálogo, no hay sugerencias y el campo es texto libre.
  Iterable<String> _opcionesModelo(TextEditingValue value) {
    final modelos = modelosDe(_marca.text);
    final texto = value.text.trim().toLowerCase();
    if (texto.isEmpty) return modelos;
    return modelos.where((m) => m.toLowerCase().contains(texto));
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
    // Un coche sin nombre de color tampoco tiene tono: si no, la tarjeta
    // pintaría un distintivo de color para un vehículo que, según su ficha,
    // no lo tiene.
    final nombreColor = textoONulo(_color);
    final colorValor = nombreColor == null ? null : _colorValor;

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
            color: Value(nombreColor),
            colorValor: Value(colorValor),
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
            color: Value(nombreColor),
            colorValor: Value(colorValor),
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
            Autocomplete<String>(
              textEditingController: _marca,
              focusNode: _marcaFocus,
              optionsBuilder: _opcionesMarca,
              // La lista solo sugiere: si la marca no está en el catálogo,
              // el campo se comporta como texto libre normal.
              fieldViewBuilder: (context, controller, focusNode, _) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Marca'),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Indica la marca'
                      : null,
                );
              },
              // No se toca el modelo ya escrito al cambiar de marca: la
              // lista de sugerencias del modelo se actualiza para la marca
              // nueva, pero el texto libre que ya hubiera se respeta.
              onSelected: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Autocomplete<String>(
              textEditingController: _modelo,
              focusNode: _modeloFocus,
              optionsBuilder: _opcionesModelo,
              fieldViewBuilder: (context, controller, focusNode, _) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Modelo'),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Indica el modelo'
                      : null,
                );
              },
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
            _PaletaColor(
              colorValorSeleccionado: _colorValor,
              onSeleccionar: (c) => setState(() {
                if (c == null) {
                  _color.clear();
                  _colorValor = null;
                } else {
                  _color.text = c.nombre;
                  _colorValor = c.valor;
                }
              }),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _color,
              decoration: const InputDecoration(
                labelText: 'Color',
                hintText: 'Editable: p. ej. "azul mystery"',
              ),
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

/// Paleta visual de colores habituales de carrocería. Al pulsar una muestra
/// se comunican nombre y tono a la vez; el nombre se puede seguir editando
/// después en el campo de texto de debajo sin perder el tono elegido.
class _PaletaColor extends StatelessWidget {
  final int? colorValorSeleccionado;
  final ValueChanged<ColorVehiculo?> onSeleccionar;

  const _PaletaColor({
    required this.colorValorSeleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final c in coloresVehiculo)
          _MuestraColor(
            color: Color(c.valor),
            etiqueta: c.nombre,
            seleccionada: colorValorSeleccionado == c.valor,
            onPulsar: () => onSeleccionar(c),
          ),
        _MuestraSinColor(
          seleccionada: colorValorSeleccionado == null,
          onPulsar: () => onSeleccionar(null),
        ),
      ],
    );
  }
}

class _MuestraColor extends StatelessWidget {
  final Color color;
  final String etiqueta;
  final bool seleccionada;
  final VoidCallback onPulsar;

  const _MuestraColor({
    required this.color,
    required this.etiqueta,
    required this.seleccionada,
    required this.onPulsar,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    // El check se pinta blanco o negro según la luminancia de la muestra,
    // para que se vea tanto sobre tonos claros como oscuros.
    final marcaClara =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark;

    return Tooltip(
      message: etiqueta,
      child: InkWell(
        onTap: onPulsar,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: seleccionada
                  ? tema.colorScheme.primary
                  : tema.colorScheme.outlineVariant,
              width: seleccionada ? 3 : 1,
            ),
          ),
          child: seleccionada
              ? Icon(
                  Icons.check,
                  size: 18,
                  color: marcaClara ? Colors.white : Colors.black,
                )
              : null,
        ),
      ),
    );
  }
}

/// Muestra para dejar el vehículo sin color, que es el estado de los
/// vehículos dados de alta antes de esta paleta.
class _MuestraSinColor extends StatelessWidget {
  final bool seleccionada;
  final VoidCallback onPulsar;

  const _MuestraSinColor({
    required this.seleccionada,
    required this.onPulsar,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Tooltip(
      message: 'Sin color',
      child: InkWell(
        onTap: onPulsar,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: tema.colorScheme.surface,
            border: Border.all(
              color: seleccionada
                  ? tema.colorScheme.primary
                  : tema.colorScheme.outlineVariant,
              width: seleccionada ? 3 : 1,
            ),
          ),
          child: Icon(
            Icons.close,
            size: 18,
            color: tema.colorScheme.outline,
          ),
        ),
      ),
    );
  }
}
