import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/gastos.dart';
import '../../providers/gastos_providers.dart';
import '../../providers/mantenimiento_providers.dart';
import '../../providers/providers.dart';
import '../common/empty_state.dart';
import '../common/error_con_reintento.dart';
import '../common/formatters.dart';
import '../maintenance/maintenance_form_screen.dart' show etiquetasCategoria;

/// Gastos por vehículo: el acumulado y su desglose por año, para cada
/// vehículo activo.
///
/// El dato solo es honesto si se dice también lo que falta: un vehículo con
/// mantenimientos sin coste anotado puede tener un total mucho más bajo del
/// real, y uno sin ningún coste anotado no es lo mismo que un vehículo que no
/// cuesta nada.
class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gastos = ref.watch(gastosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos')),
      body: gastos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) {
          debugPrint('Error al cargar los gastos: $e\n$st');
          return ErrorConReintento(
            mensaje: 'No se han podido cargar los gastos. Inténtalo de nuevo.',
            onReintentar: () {
              ref.invalidate(vehiculosProvider);
              ref.invalidate(historialProvider);
            },
          );
        },
        data: (lista) => lista.isEmpty
            ? const EmptyState(
                icono: Icons.euro_outlined,
                titulo: 'No hay coches que mostrar',
                descripcion:
                    'Los gastos aparecerán aquí en cuanto tengas algún '
                    'vehículo activo.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: lista.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) =>
                    _TarjetaGastosVehiculo(gastos: lista[i]),
              ),
      ),
    );
  }
}

/// Texto para los registros sin coste anotado, con el singular cuidado:
/// "1 mantenimiento sin coste anotado", no "1 mantenimientos".
String _textoRegistrosSinCoste(int cantidad) {
  final sustantivo = cantidad == 1 ? 'mantenimiento' : 'mantenimientos';
  return '$cantidad $sustantivo sin coste anotado';
}

class _TarjetaGastosVehiculo extends StatelessWidget {
  final GastosDeVehiculo gastos;

  const _TarjetaGastosVehiculo({required this.gastos});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final vehiculo = gastos.vehiculo;
    final resumen = gastos.resumen;
    final nombre = '${vehiculo.marca} ${vehiculo.modelo}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nombre, style: tema.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (resumen.porAnio.isEmpty)
              _SinCostesAnotados(resumen: resumen)
            else
              _ResumenConCostes(resumen: resumen),
          ],
        ),
      ),
    );
  }
}

/// Un vehículo sin ningún coste anotado no muestra un total de cero —se
/// leería como "este coche no me cuesta nada"— sino una explicación de que
/// todavía no hay nada que mostrar.
class _SinCostesAnotados extends StatelessWidget {
  final ResumenGastos resumen;

  const _SinCostesAnotados({required this.resumen});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final descripcion = resumen.registrosSinCoste > 0
        ? 'Todavía no hay costes anotados para este vehículo '
              '(${_textoRegistrosSinCoste(resumen.registrosSinCoste)}).'
        : 'Todavía no hay costes anotados para este vehículo.';

    return Text(
      descripcion,
      style: tema.textTheme.bodyMedium?.copyWith(
        color: tema.colorScheme.outline,
      ),
    );
  }
}

enum _VistaGastos { anio, categoria }

class _ResumenConCostes extends StatefulWidget {
  final ResumenGastos resumen;

  const _ResumenConCostes({required this.resumen});

  @override
  State<_ResumenConCostes> createState() => _ResumenConCostesState();
}

class _ResumenConCostesState extends State<_ResumenConCostes> {
  _VistaGastos _vista = _VistaGastos.anio;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final resumen = widget.resumen;
    final maxAnual = resumen.porAnio.isEmpty
        ? 0.0
        : resumen.porAnio
            .map((g) => g.total)
            .reduce((a, b) => a > b ? a : b);

    final maxCategoria = resumen.porCategoria.isEmpty
        ? 0.0
        : resumen.porCategoria
            .map((g) => g.total)
            .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatearCoste(resumen.total),
          style: tema.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (resumen.registrosSinCoste > 0) ...[
          const SizedBox(height: 4),
          Text(
            _textoRegistrosSinCoste(resumen.registrosSinCoste),
            style: tema.textTheme.bodySmall?.copyWith(
              color: tema.colorScheme.outline,
            ),
          ),
        ],
        if (resumen.porCategoria.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<_VistaGastos>(
              segments: const [
                ButtonSegment(
                  value: _VistaGastos.anio,
                  label: Text('Por año'),
                  icon: Icon(Icons.calendar_today_outlined, size: 16),
                ),
                ButtonSegment(
                  value: _VistaGastos.categoria,
                  label: Text('Por categoría'),
                  icon: Icon(Icons.pie_chart_outline, size: 16),
                ),
              ],
              selected: {_vista},
              onSelectionChanged: (nuevo) {
                setState(() => _vista = nuevo.first);
              },
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (_vista == _VistaGastos.anio) ...[
          for (final gastoAnual in resumen.porAnio)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FilaGastoAnual(gastoAnual: gastoAnual, maxAnual: maxAnual),
            ),
        ] else ...[
          for (final gastoCat in resumen.porCategoria)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FilaGastoCategoria(
                gastoCat: gastoCat,
                maxCategoria: maxCategoria,
                totalVehiculo: resumen.total,
              ),
            ),
        ],
      ],
    );
  }
}

/// Una fila del desglose por categoría: el nombre de la categoría, el
/// porcentaje sobre el total, el importe, y una barra proporcional.
class _FilaGastoCategoria extends StatelessWidget {
  final GastoPorCategoria gastoCat;
  final double maxCategoria;
  final double totalVehiculo;

  const _FilaGastoCategoria({
    required this.gastoCat,
    required this.maxCategoria,
    required this.totalVehiculo,
  });

  double get _factorBarra {
    if (maxCategoria <= 0) return 0;
    return (gastoCat.total / maxCategoria).clamp(0.0, 1.0);
  }

  String get _nombreCategoria {
    final cat = gastoCat.categoria;
    if (cat == null) return 'Reparación puntual';
    return etiquetasCategoria[cat] ?? cat.name;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final porcentaje = totalVehiculo > 0
        ? ((gastoCat.total / totalVehiculo) * 100).round()
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _nombreCategoria,
                style: tema.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$porcentaje%',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatearCoste(gastoCat.total),
              style: tema.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: tema.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: _factorBarra,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: tema.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Una fila del desglose por año: el año, una barra proporcional al importe
/// del año más caro de ese mismo coche, y el importe.
///
/// La proporción tiene dos trampas aritméticas: si el año más caro es 0 (p.
/// ej. porque todos los registros con coste anotado costaron 0), dividir
/// entre él da NaN; y `FractionallySizedBox.widthFactor` solo acepta valores
/// entre 0 y 1. Ambas se resuelven en [_factorBarra].
class _FilaGastoAnual extends StatelessWidget {
  final GastoAnual gastoAnual;
  final double maxAnual;

  const _FilaGastoAnual({required this.gastoAnual, required this.maxAnual});

  double get _factorBarra {
    if (maxAnual <= 0) return 0;
    return (gastoAnual.total / maxAnual).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            '${gastoAnual.anio}',
            style: tema.textTheme.bodyMedium,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: tema.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              widthFactor: _factorBarra,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: tema.colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 110px en vez de 90: un importe anual de cinco cifras como
        // "12.345,67 €" (11 caracteres) debe caber entero. El ellipsis
        // queda solo como red de seguridad para casos aún más extremos.
        SizedBox(
          width: 110,
          child: Text(
            formatearCoste(gastoAnual.total),
            textAlign: TextAlign.right,
            style: tema.textTheme.bodyMedium,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
