import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/gastos.dart';
import '../../providers/gastos_providers.dart';
import '../common/empty_state.dart';
import '../common/formatters.dart';

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
          return _ErrorConReintento(
            mensaje: 'No se han podido cargar los gastos. Inténtalo de nuevo.',
            onReintentar: () => ref.invalidate(gastosProvider),
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

class _ErrorConReintento extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const _ErrorConReintento({required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onReintentar,
              child: const Text('Reintentar'),
            ),
          ],
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

class _ResumenConCostes extends StatelessWidget {
  final ResumenGastos resumen;

  const _ResumenConCostes({required this.resumen});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final maxAnual = resumen.porAnio
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
        const SizedBox(height: 16),
        for (final gastoAnual in resumen.porAnio)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _FilaGastoAnual(gastoAnual: gastoAnual, maxAnual: maxAnual),
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
          child: Text('${gastoAnual.anio}', style: tema.textTheme.bodyMedium),
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
        SizedBox(
          width: 90,
          child: Text(
            formatearCoste(gastoAnual.total),
            textAlign: TextAlign.right,
            style: tema.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
