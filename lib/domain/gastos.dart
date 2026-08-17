/// Lo gastado en un año natural concreto.
class GastoAnual {
  final int anio;
  final double total;

  const GastoAnual({required this.anio, required this.total});
}

/// Lo que se ha gastado en un vehículo: el acumulado, su desglose por año y
/// cuántos registros no llevan coste anotado.
///
/// Ese último dato no es un detalle: un total que ignore en silencio los
/// registros sin coste se lee como "he gastado poco" cuando en realidad
/// significa "no lo apunté". La pantalla tiene que poder decirlo.
class ResumenGastos {
  final double total;

  /// Ordenado del año más reciente al más antiguo. Solo contiene años con
  /// algún coste anotado.
  final List<GastoAnual> porAnio;

  final int registrosSinCoste;

  const ResumenGastos({
    required this.total,
    required this.porAnio,
    required this.registrosSinCoste,
  });
}

/// Agrega los mantenimientos realizados de un vehículo en un [ResumenGastos].
///
/// Un coste nulo significa "no se apuntó" y no suma; un coste de cero es un
/// dato real (una reparación en garantía, por ejemplo) y sí cuenta como
/// registro con coste anotado.
ResumenGastos calcularResumenGastos(
  List<({DateTime fecha, double? coste})> registros,
) {
  var total = 0.0;
  var sinCoste = 0;
  final porAnio = <int, double>{};

  for (final registro in registros) {
    final coste = registro.coste;
    if (coste == null) {
      sinCoste++;
      continue;
    }
    total += coste;
    porAnio.update(
      registro.fecha.year,
      (acumulado) => acumulado + coste,
      ifAbsent: () => coste,
    );
  }

  final anios = porAnio.keys.toList()..sort((a, b) => b.compareTo(a));

  return ResumenGastos(
    total: total,
    porAnio: [
      for (final anio in anios) GastoAnual(anio: anio, total: porAnio[anio]!),
    ],
    registrosSinCoste: sinCoste,
  );
}
