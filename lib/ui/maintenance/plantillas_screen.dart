import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../domain/plantillas_mantenimiento.dart';
import '../../providers/notificaciones_providers.dart';
import '../../providers/providers.dart';
import '../common/formatters.dart';
import 'maintenance_form_screen.dart' show etiquetasCategoria;

/// Tras dar de alta un vehículo, propone los mantenimientos habituales para
/// no tener que crearlos uno a uno. Se puede saltar sin ningún problema: no
/// es un paso obligatorio, solo un atajo.
class PlantillasScreen extends ConsumerStatefulWidget {
  final int vehicleId;

  const PlantillasScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<PlantillasScreen> createState() => _PlantillasScreenState();
}

class _PlantillasScreenState extends ConsumerState<PlantillasScreen> {
  late final Future<Vehicle?> _vehiculoFuture;

  bool _esAutomatico = false;
  List<PlantillaMantenimiento> _plantillas = const [];

  /// Índices de _plantillas que están marcados. Se recalcula cada vez que
  /// cambia _esAutomatico, así que se guarda por índice y no por objeto.
  final Set<int> _marcados = {};

  bool _listaCalculada = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _vehiculoFuture = ref
        .read(databaseProvider)
        .vehicleDao
        .getById(widget.vehicleId);
  }

  void _recalcularPlantillas(Vehicle vehiculo) {
    _plantillas = plantillasPara(
      combustible: vehiculo.combustible,
      esAutomatico: _esAutomatico,
      fechaMatriculacion: vehiculo.fechaMatriculacion,
    );
    // Todo marcado salvo la distribución: no tiene intervalo propio y hay
    // que rellenarla a mano con el motor delante.
    _marcados
      ..clear()
      ..addAll([
        for (var i = 0; i < _plantillas.length; i++)
          if (_plantillas[i].intervalKm != null ||
              _plantillas[i].intervalMeses != null)
            i,
      ]);
  }

  Future<void> _confirmar() async {
    if (_guardando) return;
    setState(() => _guardando = true);

    final db = ref.read(databaseProvider);
    try {
      // Una sola transacción para todos los mantenimientos elegidos: si
      // alguna escritura fallara a mitad, no debe quedar el vehículo con
      // solo la mitad de sus mantenimientos habituales.
      await db.transaction(() async {
        for (final i in _marcados) {
          final plantilla = _plantillas[i];
          await db.maintenanceDao.insertarSchedule(
            MaintenanceSchedulesCompanion.insert(
              vehicleId: widget.vehicleId,
              nombre: plantilla.nombre,
              categoria: plantilla.categoria,
              intervalKm: Value(plantilla.intervalKm),
              intervalMeses: Value(plantilla.intervalMeses),
              orden: Value(i),
              tipo: Value(plantilla.tipo),
              posicion: Value(plantilla.posicion),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('Error al crear los mantenimientos propuestos: $e');
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se han podido crear los mantenimientos. Inténtalo de nuevo.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    // Es el único sitio donde nacen varios mantenimientos de golpe. La
    // reprogramación del formulario de vehículo no vale aquí: se ejecuta
    // antes de llegar a esta pantalla, cuando el coche todavía no tiene
    // ninguno, así que sin esta llamada un vehículo recién dado de alta se
    // quedaría sin un solo aviso hasta el siguiente arranque.
    dispararReprogramacionDeAvisos(ref);
    Navigator.of(context).pop();
  }

  void _saltar() => Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantenimientos habituales'),
        actions: [
          TextButton(
            onPressed: _guardando ? null : _saltar,
            child: const Text('Saltar'),
          ),
        ],
      ),
      body: FutureBuilder<Vehicle?>(
        future: _vehiculoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final vehiculo = snapshot.data;
          if (vehiculo == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No se ha podido cargar el vehículo para proponer sus '
                  'mantenimientos.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!_listaCalculada) {
            _recalcularPlantillas(vehiculo);
            _listaCalculada = true;
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _AvisoOrientativo(),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Cambio automático'),
                subtitle: const Text(
                  'Añade el mantenimiento del aceite de la caja.',
                ),
                value: _esAutomatico,
                onChanged: (v) => setState(() {
                  _esAutomatico = v;
                  _recalcularPlantillas(vehiculo);
                }),
              ),
              const Divider(height: 24),
              for (var i = 0; i < _plantillas.length; i++)
                _FilaPlantilla(
                  plantilla: _plantillas[i],
                  marcada: _marcados.contains(i),
                  onCambiar: (marcada) => setState(() {
                    if (marcada) {
                      _marcados.add(i);
                    } else {
                      _marcados.remove(i);
                    }
                  }),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _guardando ? null : _confirmar,
                child: Text(
                  _marcados.isEmpty
                      ? 'Continuar sin añadir ninguno'
                      : 'Añadir ${_marcados.length} '
                            'mantenimiento${_marcados.length == 1 ? '' : 's'}',
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _guardando ? null : _saltar,
                child: const Text('Saltar este paso'),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Deja claro que los intervalos propuestos son orientativos, no cifras
/// oficiales del fabricante: la app no sabe qué recomienda el manual de
/// cada motor concreto.
class _AvisoOrientativo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tema.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: tema.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Los intervalos son orientativos, no cifras oficiales del '
              'fabricante. Ajústalos con el libro de mantenimiento del '
              'coche delante.',
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaPlantilla extends StatelessWidget {
  final PlantillaMantenimiento plantilla;
  final bool marcada;
  final ValueChanged<bool> onCambiar;

  const _FilaPlantilla({
    required this.plantilla,
    required this.marcada,
    required this.onCambiar,
  });

  String get _subtitulo {
    final categoria = etiquetasCategoria[plantilla.categoria];
    final km = plantilla.intervalKm;
    final meses = plantilla.intervalMeses;

    if (km == null && meses == null) {
      return '$categoria · sin intervalo, indícalo al editar';
    }
    final partes = [
      if (km != null) 'cada ${formatearKm(km)}',
      if (meses != null) 'cada $meses meses',
    ];
    return '$categoria · ${partes.join(' o ')}';
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(plantilla.nombre),
      subtitle: Text(_subtitulo),
      value: marcada,
      onChanged: (v) => onCambiar(v ?? false),
    );
  }
}
