import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../providers/providers.dart';
import '../common/formatters.dart';
import '../theme/app_theme.dart';

Future<void> mostrarHojaKilometraje(
  BuildContext context, {
  required Vehicle vehiculo,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (contextHoja) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(contextHoja).bottom,
      ),
      child: SafeArea(child: _HojaKilometraje(vehiculo: vehiculo)),
    ),
  );
}

class _HojaKilometraje extends ConsumerStatefulWidget {
  final Vehicle vehiculo;

  const _HojaKilometraje({required this.vehiculo});

  @override
  ConsumerState<_HojaKilometraje> createState() => _HojaKilometrajeState();
}

class _HojaKilometrajeState extends ConsumerState<_HojaKilometraje> {
  final _controlador = TextEditingController();
  final _foco = FocusNode();
  String? _error;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _foco.requestFocus());
  }

  @override
  void dispose() {
    _controlador.dispose();
    _foco.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    // El botón se deshabilita al guardar, pero onSubmitted del teclado es
    // un segundo disparador: sin esta guarda, dos pulsaciones rápidas
    // ejecutarían el método dos veces en paralelo.
    if (_guardando) return;

    final km = int.tryParse(_controlador.text.trim().replaceAll('.', ''));
    if (km == null || km <= 0) {
      setState(() => _error = 'Introduce un número de kilómetros válido');
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    final dao = ref.read(databaseProvider).mileageDao;
    MileageReading? anterior;
    try {
      anterior = await dao.ultimaLectura(widget.vehiculo.id);
    } catch (e) {
      debugPrint('Error al comprobar el kilometraje anterior: $e');
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se ha podido comprobar el kilometraje anterior. '
            'Inténtalo de nuevo.',
          ),
        ),
      );
      return;
    }
    if (!mounted) return;

    if (anterior != null && km < anterior.km) {
      final seguir = await _confirmarRetroceso(anterior.km, km);
      if (!mounted) return;
      if (seguir != true) {
        setState(() => _guardando = false);
        return;
      }
    }

    try {
      await dao.registrar(
        vehicleId: widget.vehiculo.id,
        fecha: DateTime.now(),
        km: km,
      );
    } catch (e) {
      debugPrint('Error al registrar el kilometraje: $e');
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se ha podido guardar el kilometraje. Inténtalo de nuevo.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    ref.invalidate(ritmoUsoProvider(widget.vehiculo.id));
    Navigator.of(context).pop();
  }

  Future<bool?> _confirmarRetroceso(int anterior, int nuevo) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('El kilometraje ha bajado'),
        content: Text(
          'La última lectura era de ${formatearKm(anterior)} y estás '
          'introduciendo ${formatearKm(nuevo)}.\n\n'
          '¿Seguro que es correcto?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Corregir'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Es correcto'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final ultima = ref.watch(ultimaLecturaProvider(widget.vehiculo.id));

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.vehiculo.marca} ${widget.vehiculo.modelo}',
            style: tema.textTheme.titleMedium,
          ),
          ultima.maybeWhen(
            data: (l) => Text(
              l == null
                  ? 'Todavía sin kilometraje registrado'
                  : 'Última lectura: ${formatearKm(l.km)}',
              style: tema.textTheme.bodySmall
                  ?.copyWith(color: tema.colorScheme.outline),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controlador,
            focusNode: _foco,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: tema.textTheme.displaySmall?.merge(AppTheme.cifras),
            decoration: InputDecoration(
              hintText: '0',
              suffixText: 'km',
              errorText: _error,
            ),
            onSubmitted: (_) => _guardar(),
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
