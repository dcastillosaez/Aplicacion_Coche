import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers/mantenimiento_providers.dart';
import '../../providers/notificaciones_providers.dart';
import '../../providers/permisos_providers.dart';
import '../../providers/providers.dart';
import '../common/formatters.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ajustes = ref.watch(ajustesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ajustes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) {
          debugPrint('Error al cargar los ajustes: $e\n$st');
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No se han podido cargar los ajustes.'),
            ),
          );
        },
        data: (setting) => _Contenido(ajustes: setting),
      ),
    );
  }
}

class _Contenido extends ConsumerWidget {
  final Setting ajustes;

  const _Contenido({required this.ajustes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        const _CabeceraSeccion(titulo: 'Notificaciones'),
        const SizedBox(height: 8),
        _CampoNumericoAutoguardado(
          key: const ValueKey('avisoKm'),
          etiqueta: 'Kilómetros de antelación',
          ayuda: 'Avisar cuando falten estos kilómetros',
          sufijo: 'km',
          valorInicial: ajustes.avisoKmPorDefecto,
          alGuardar: (v) async {
            await ref
                .read(databaseProvider)
                .settingsDao
                .actualizarAvisoKmPorDefecto(v);
            dispararReprogramacionDeAvisos(ref);
          },
        ),
        const SizedBox(height: 12),
        _CampoNumericoAutoguardado(
          key: const ValueKey('avisoDias'),
          etiqueta: 'Días de antelación',
          ayuda: 'Avisar cuando falten estos días',
          sufijo: 'días',
          valorInicial: ajustes.avisoDiasPorDefecto,
          alGuardar: (v) async {
            await ref
                .read(databaseProvider)
                .settingsDao
                .actualizarAvisoDiasPorDefecto(v);
            dispararReprogramacionDeAvisos(ref);
          },
        ),
        const SizedBox(height: 12),
        _CampoNumericoAutoguardado(
          key: const ValueKey('recordatorio'),
          etiqueta: 'Recordatorio de kilometraje',
          ayuda: 'Cada cuántos días recordar introducirlo',
          sufijo: 'días',
          valorInicial: ajustes.diasRecordatorioLectura,
          alGuardar: (v) async {
            await ref
                .read(databaseProvider)
                .settingsDao
                .actualizarDiasRecordatorioLectura(v);
            dispararReprogramacionDeAvisos(ref);
          },
        ),
        const SizedBox(height: 12),
        const _EstadoPermiso(),
        const SizedBox(height: 24),
        const _CabeceraSeccion(titulo: 'Apariencia'),
        const SizedBox(height: 8),
        _SelectorTema(temaActual: ajustes.tema),
        const SizedBox(height: 24),
        const _CabeceraSeccion(titulo: 'Datos'),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.upload_outlined),
          title: const Text('Exportar copia de seguridad'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Esta función estará disponible en una próxima versión.',
                ),
              ),
            );
          },
        ),
        if (ajustes.fechaUltimaCopia != null)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history_outlined),
            title: const Text('Última copia'),
            subtitle: Text(formatearFecha(ajustes.fechaUltimaCopia!)),
          ),
      ],
    );
  }
}

class _CabeceraSeccion extends StatelessWidget {
  final String titulo;

  const _CabeceraSeccion({required this.titulo});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Text(
      titulo,
      style: tema.textTheme.titleSmall?.copyWith(
        color: tema.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _EstadoPermiso extends ConsumerWidget {
  const _EstadoPermiso();

  Future<void> _abrirAjustes(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(servicioPermisosProvider).abrirAjustesDeLaAplicacion();
    } catch (e) {
      debugPrint('No se han podido abrir los ajustes de la aplicación: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se han podido abrir los ajustes.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permiso = ref.watch(permisoNotificacionesProvider);

    return permiso.when(
      loading: () => const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.notifications_outlined),
        title: Text('Permiso de notificaciones'),
        subtitle: Text('Comprobando...'),
      ),
      error: (e, st) {
        debugPrint('Error al comprobar el permiso de notificaciones: $e\n$st');
        return const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.notifications_outlined),
          title: Text('Permiso de notificaciones'),
          subtitle: Text('No se ha podido comprobar'),
        );
      },
      data: (concedido) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.notifications_outlined),
        title: const Text('Permiso de notificaciones'),
        subtitle: Text(concedido ? 'Concedido' : 'Denegado'),
        trailing: concedido
            ? null
            : TextButton(
                onPressed: () => _abrirAjustes(context, ref),
                child: const Text('Abrir ajustes'),
              ),
      ),
    );
  }
}

class _SelectorTema extends ConsumerWidget {
  final String temaActual;

  const _SelectorTema({required this.temaActual});

  Future<void> _guardar(
    BuildContext context,
    WidgetRef ref,
    String tema,
  ) async {
    try {
      await ref.read(databaseProvider).settingsDao.actualizarTema(tema);
    } catch (e) {
      debugPrint('No se ha podido guardar el tema: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se ha podido guardar el cambio.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'automatico', label: Text('Automático')),
        ButtonSegment(value: 'claro', label: Text('Claro')),
        ButtonSegment(value: 'oscuro', label: Text('Oscuro')),
      ],
      selected: {temaActual},
      onSelectionChanged: (seleccion) =>
          _guardar(context, ref, seleccion.first),
    );
  }
}

/// Campo numérico que se guarda solo al perder el foco, sin botón "Guardar".
/// Un valor vacío o no positivo revierte al último valor guardado, sin
/// molestar con un error: no es una equivocación que merezca interrumpir,
/// simplemente no se acepta el cambio.
class _CampoNumericoAutoguardado extends StatefulWidget {
  final String etiqueta;
  final String ayuda;
  final String sufijo;
  final int valorInicial;
  final Future<void> Function(int nuevoValor) alGuardar;

  const _CampoNumericoAutoguardado({
    super.key,
    required this.etiqueta,
    required this.ayuda,
    required this.sufijo,
    required this.valorInicial,
    required this.alGuardar,
  });

  @override
  State<_CampoNumericoAutoguardado> createState() =>
      _CampoNumericoAutoguardadoState();
}

class _CampoNumericoAutoguardadoState
    extends State<_CampoNumericoAutoguardado> {
  late final TextEditingController _controlador;
  late final FocusNode _foco;
  late int _ultimoValorValido;

  @override
  void initState() {
    super.initState();
    _ultimoValorValido = widget.valorInicial;
    _controlador = TextEditingController(text: widget.valorInicial.toString());
    _foco = FocusNode()..addListener(_alCambiarFoco);
  }

  @override
  void dispose() {
    _foco.removeListener(_alCambiarFoco);
    _controlador.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _alCambiarFoco() {
    if (_foco.hasFocus) return;
    _confirmarOrevertir();
  }

  Future<void> _confirmarOrevertir() async {
    final valor = int.tryParse(_controlador.text.trim());
    if (valor == null || valor <= 0) {
      _controlador.text = _ultimoValorValido.toString();
      return;
    }
    if (valor == _ultimoValorValido) return;

    try {
      await widget.alGuardar(valor);
      _ultimoValorValido = valor;
      _controlador.text = valor.toString();
    } catch (e) {
      debugPrint('No se ha podido guardar "${widget.etiqueta}": $e');
      if (!mounted) return;
      _controlador.text = _ultimoValorValido.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se ha podido guardar el cambio.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controlador,
      focusNode: _foco,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: widget.etiqueta,
        helperText: widget.ayuda,
        suffixText: widget.sufijo,
      ),
      onSubmitted: (_) => _foco.unfocus(),
    );
  }
}
