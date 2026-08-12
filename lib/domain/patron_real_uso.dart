import 'maintenance_due.dart' show diasNaturalesEntre;

/// Patrón real de uso de un mantenimiento: la media de kilómetros y de
/// días que el usuario deja pasar entre un cambio y el siguiente, a partir
/// de lo que la app ha presenciado de verdad. Nunca cambia el intervalo
/// configurado: es solo información para quien lo lea.
class PatronRealUso {
  final double kmMedioEntreCambios;
  final double diasMedioEntreCambios;

  const PatronRealUso({
    required this.kmMedioEntreCambios,
    required this.diasMedioEntreCambios,
  });
}

/// Calcula el patrón real a partir de los registros reales (no sembrados)
/// de un mantenimiento, en cualquier orden.
///
/// Nulo si hay menos de dos registros: con uno solo no hay ningún
/// intervalo que medir todavía.
PatronRealUso? calcularPatronReal(
  List<({DateTime fecha, int km})> registrosReales,
) {
  if (registrosReales.length < 2) return null;

  final ordenados = [...registrosReales]
    ..sort((a, b) => a.fecha.compareTo(b.fecha));

  var sumaKm = 0;
  var sumaDias = 0;
  for (var i = 1; i < ordenados.length; i++) {
    sumaKm += ordenados[i].km - ordenados[i - 1].km;
    sumaDias += diasNaturalesEntre(ordenados[i - 1].fecha, ordenados[i].fecha);
  }

  final intervalos = ordenados.length - 1;
  return PatronRealUso(
    kmMedioEntreCambios: sumaKm / intervalos,
    diasMedioEntreCambios: sumaDias / intervalos,
  );
}
