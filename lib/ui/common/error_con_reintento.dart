import 'package:flutter/material.dart';

/// Estado de error genérico con un botón para reintentar la carga.
///
/// Se usa en cualquier pantalla que consuma un [AsyncValue] (o similar) y
/// necesite mostrar un mensaje claro en español junto con la forma de
/// recuperarse, en vez de dejar la pantalla en blanco o mostrar la
/// excepción cruda.
class ErrorConReintento extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const ErrorConReintento({
    super.key,
    required this.mensaje,
    required this.onReintentar,
  });

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
