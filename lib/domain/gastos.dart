import 'maintenance_category.dart';

/// Lo gastado en un año natural concreto.
class GastoAnual {
  final int anio;
  final double total;

  const GastoAnual({required this.anio, required this.total});
}

/// Lo gastado en una categoría de mantenimiento concreta.
class GastoPorCategoria {
  final MaintenanceCategory? categoria;
  final double total;
  final int cantidad;

  const GastoPorCategoria({
    required this.categoria,
    required this.total,
    required this.cantidad,
  });
}

/// Lo que se ha gastado en un vehículo: el acumulado, su desglose por año y
/// categoría, y cuántos registros no llevan coste anotado.
///
/// Ese último dato no es un detalle: un total que ignore en silencio los
/// registros sin coste se lee como "he gastado poco" cuando en realidad
/// significa "no lo apunté". La pantalla tiene que poder decirlo.
class ResumenGastos {
  final double total;

  /// Ordenado del año más reciente al más antiguo. Solo contiene años con
  /// algún coste anotado.
  final List<GastoAnual> porAnio;

  /// Desglose por categoría, ordenado de mayor a menor importe total.
  final List<GastoPorCategoria> porCategoria;

  final int registrosSinCoste;

  const ResumenGastos({
    required this.total,
    required this.porAnio,
    this.porCategoria = const [],
    required this.registrosSinCoste,
  });
}

/// Agrega los mantenimientos realizados de un vehículo en un [ResumenGastos].
///
/// Un coste nulo significa "no se apuntó" y no suma; un coste de cero es un
/// dato real (una reparación en garantía, por ejemplo) y sí cuenta como
/// registro con coste anotado.
ResumenGastos calcularResumenGastos(
  List<({DateTime fecha, double? coste, MaintenanceCategory? categoria})>
  registros,
) {
  var total = 0.0;
  var sinCoste = 0;
  final porAnio = <int, double>{};
  final porCatTotal = <MaintenanceCategory?, double>{};
  final porCatCantidad = <MaintenanceCategory?, int>{};

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
    porCatTotal.update(
      registro.categoria,
      (acumulado) => acumulado + coste,
      ifAbsent: () => coste,
    );
    porCatCantidad.update(
      registro.categoria,
      (cant) => cant + 1,
      ifAbsent: () => 1,
    );
  }

  final anios = porAnio.keys.toList()..sort((a, b) => b.compareTo(a));
  final categorias = porCatTotal.keys.toList()
    ..sort((a, b) {
      final comp = porCatTotal[b]!.compareTo(porCatTotal[a]!);
      if (comp != 0) return comp;
      return porCatCantidad[b]!.compareTo(porCatCantidad[a]!);
    });

  return ResumenGastos(
    total: total,
    porAnio: [
      for (final anio in anios) GastoAnual(anio: anio, total: porAnio[anio]!),
    ],
    porCategoria: [
      for (final cat in categorias)
        GastoPorCategoria(
          categoria: cat,
          total: porCatTotal[cat]!,
          cantidad: porCatCantidad[cat]!,
        ),
    ],
    registrosSinCoste: sinCoste,
  );
}
