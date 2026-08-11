import 'package:flutter/material.dart';

import '../../domain/maintenance_due.dart';
import '../theme/status_colors.dart';

/// Distintivo de estado. Sin texto propio muestra la etiqueta del estado.
class EstadoChip extends StatelessWidget {
  final EstadoMantenimiento estado;
  final String? texto;

  const EstadoChip({super.key, required this.estado, this.texto});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final color = tema.coloresEstado.de(estado);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            texto ?? etiquetaEstado(estado),
            style: tema.textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
