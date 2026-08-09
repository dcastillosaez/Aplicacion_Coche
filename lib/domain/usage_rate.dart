/// Ritmo por defecto mientras no hay datos suficientes: 12.000 km al año.
const double kRitmoPorDefecto = 33.0;

/// Ventana de lecturas que se tiene en cuenta.
const int kVentanaDias = 90;

/// Separación mínima entre la primera y la última lectura de la ventana.
const int kMinDiasEntreLecturas = 7;

/// Por debajo de este ritmo el coche se considera parado.
const double kUmbralCocheParado = 1.0;

/// Lectura de kilometraje independiente de la capa de datos.
class MileagePoint {
  final DateTime fecha;
  final int km;

  const MileagePoint({required this.fecha, required this.km});
}

class UsageRateResult {
  final double kmPorDia;

  /// Cierto cuando no había lecturas suficientes y se ha usado el valor inicial.
  final bool esPorDefecto;

  const UsageRateResult({required this.kmPorDia, required this.esPorDefecto});

  /// Un coche parado no genera avisos por kilometraje. El valor por defecto
  /// nunca cuenta como coche parado: es una suposición, no una medición.
  bool get cocheParado => !esPorDefecto && kmPorDia < kUmbralCocheParado;
}

class UsageRate {
  const UsageRate._();

  static UsageRateResult calcular({
    required List<MileagePoint> lecturas,
    required DateTime ahora,
  }) {
    final inicioVentana = ahora.subtract(const Duration(days: kVentanaDias));
    final ventana = lecturas
        .where((l) => !l.fecha.isBefore(inicioVentana))
        .toList()
      ..sort((a, b) => a.fecha.compareTo(b.fecha));

    if (ventana.length >= 2) {
      final primera = ventana.first;
      final ultima = ventana.last;
      final dias = ultima.fecha.difference(primera.fecha).inDays;
      final km = ultima.km - primera.km;

      if (dias >= kMinDiasEntreLecturas && km >= 0) {
        return UsageRateResult(kmPorDia: km / dias, esPorDefecto: false);
      }
    }

    return const UsageRateResult(
      kmPorDia: kRitmoPorDefecto,
      esPorDefecto: true,
    );
  }
}
