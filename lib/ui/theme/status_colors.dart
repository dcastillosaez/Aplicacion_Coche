import 'package:flutter/material.dart';

import '../../domain/maintenance_due.dart';

/// Los cuatro estados en tonos desaturados: legibles, pero sin efecto
/// semáforo de juguete. El color aquí es información, no decoración.
class ColoresEstado {
  final Color ok;
  final Color proximo;
  final Color atencion;
  final Color vencido;
  final Color sinConfigurar;

  const ColoresEstado({
    required this.ok,
    required this.proximo,
    required this.atencion,
    required this.vencido,
    required this.sinConfigurar,
  });

  static const claro = ColoresEstado(
    ok: Color(0xFF2E7D5B),
    proximo: Color(0xFF2C6E9B),
    atencion: Color(0xFFB0741F),
    vencido: Color(0xFFB3453A),
    sinConfigurar: Color(0xFF8A9199),
  );

  static const oscuro = ColoresEstado(
    ok: Color(0xFF6FBF9A),
    proximo: Color(0xFF7FB6DC),
    atencion: Color(0xFFE0A857),
    vencido: Color(0xFFE58C82),
    sinConfigurar: Color(0xFF8A9199),
  );

  Color de(EstadoMantenimiento estado) => switch (estado) {
    EstadoMantenimiento.ok => ok,
    EstadoMantenimiento.proximo => proximo,
    EstadoMantenimiento.atencion => atencion,
    EstadoMantenimiento.vencido => vencido,
    EstadoMantenimiento.sinConfigurar => sinConfigurar,
  };
}

extension ColoresEstadoDelTema on ThemeData {
  ColoresEstado get coloresEstado => brightness == Brightness.light
      ? ColoresEstado.claro
      : ColoresEstado.oscuro;
}

String etiquetaEstado(EstadoMantenimiento estado) => switch (estado) {
  EstadoMantenimiento.ok => 'Al día',
  EstadoMantenimiento.proximo => 'Próximo',
  EstadoMantenimiento.atencion => 'Conviene hacerlo',
  EstadoMantenimiento.vencido => 'Vencido',
  EstadoMantenimiento.sinConfigurar => 'Sin datos',
};
