import 'package:flutter/material.dart';

import '../../domain/origen_mantenimiento.dart';

const _textoAdvertenciaDesconocido =
    'Si no sabes cuándo se hizo, consulta la documentación o la factura '
    'antes de asumir que está realizado.';

/// Distintivo de cuánto se puede confiar en el dato de "cuándo se hizo por
/// última vez" de un mantenimiento. A diferencia de `EstadoChip`, no usa
/// color para diferenciar sus estados —ese eje ya está reservado para el
/// estado de vencimiento—: usa un icono distinto por estado sobre un tono
/// neutro.
class OrigenChip extends StatelessWidget {
  final OrigenMantenimiento origen;

  const OrigenChip({super.key, required this.origen});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final color = tema.colorScheme.outline;

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icono(origen), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _etiqueta(origen),
            style: tema.textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );

    if (origen != OrigenMantenimiento.desconocido) return chip;

    return Tooltip(message: _textoAdvertenciaDesconocido, child: chip);
  }

  IconData _icono(OrigenMantenimiento origen) {
    switch (origen) {
      case OrigenMantenimiento.confirmado:
        return Icons.verified_outlined;
      case OrigenMantenimiento.historico:
        return Icons.history;
      case OrigenMantenimiento.desconocido:
        return Icons.help_outline;
    }
  }

  String _etiqueta(OrigenMantenimiento origen) {
    switch (origen) {
      case OrigenMantenimiento.confirmado:
        return 'Confirmado';
      case OrigenMantenimiento.historico:
        return 'Histórico';
      case OrigenMantenimiento.desconocido:
        return 'Desconocido';
    }
  }
}
