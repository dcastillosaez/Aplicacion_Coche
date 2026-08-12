import 'maintenance_due.dart';

/// Umbrales que deciden si dos mantenimientos próximos se muestran como
/// "puedes hacerlos juntos". No son una verdad fija —tras usar la app puede
/// convenir ajustarlos—, así que viven aquí y no como literales sueltos en
/// el provider o en la pantalla.
class MaintenanceGroupingPolicy {
  final int maxKmDiferencia;
  final int maxDiasDiferencia;

  const MaintenanceGroupingPolicy({
    this.maxKmDiferencia = 500,
    this.maxDiasDiferencia = 15,
  });
}

/// Agrupa los índices de [vencimientos] (una lista ya ordenada por
/// urgencia, típicamente la que devuelve `vencimientosProvider`) según
/// [politica].
///
/// Dos vencimientos consecutivos entran en el mismo grupo si, por
/// cualquiera de las dos vías, están lo bastante cerca: sus kilómetros
/// restantes difieren `maxKmDiferencia` o menos (cuando ambos tienen
/// kilómetros restantes), o sus días hasta el vencimiento difieren
/// `maxDiasDiferencia` o menos (cuando ambos tienen esa magnitud
/// calculada). Comparar los kilómetros de forma directa, sin traducirlos a
/// días, evita que dos mantenimientos que van solo por kilómetros dependan
/// de lo fiable que sea el ritmo de uso estimado.
///
/// Cada grupo tiene al menos un elemento; un grupo de un solo elemento
/// significa que ese mantenimiento no tiene ningún vecino cercano.
List<List<int>> agruparPorProximidad(
  List<Vencimiento> vencimientos,
  MaintenanceGroupingPolicy politica,
) {
  if (vencimientos.isEmpty) return [];

  final grupos = <List<int>>[
    [0],
  ];

  for (var i = 1; i < vencimientos.length; i++) {
    final anterior = vencimientos[i - 1];
    final actual = vencimientos[i];

    final cercaPorKm =
        anterior.kmRestantes != null &&
        actual.kmRestantes != null &&
        (anterior.kmRestantes! - actual.kmRestantes!).abs() <=
            politica.maxKmDiferencia;

    final cercaPorDias =
        anterior.diasHastaVencimiento != null &&
        actual.diasHastaVencimiento != null &&
        (anterior.diasHastaVencimiento! - actual.diasHastaVencimiento!).abs() <=
            politica.maxDiasDiferencia;

    if (cercaPorKm || cercaPorDias) {
      grupos.last.add(i);
    } else {
      grupos.add([i]);
    }
  }

  return grupos;
}
