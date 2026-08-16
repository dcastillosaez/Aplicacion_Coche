/// Lo que el cálculo de avisos necesita saber de un mantenimiento. No es una
/// fila de Drift ni un [Vencimiento] entero: solo las dos fechas en que puede
/// vencer y los márgenes con los que avisar, para que el dominio no dependa
/// de la capa de datos.
///
/// Quien construye estos datos (el provider) ya ha descartado los
/// mantenimientos inactivos y los silenciados.
class DatosAviso {
  final String nombre;

  /// Cuándo vence por tiempo. Nula si el mantenimiento no va por fecha.
  final DateTime? proximaFecha;

  /// Cuándo se alcanzarán sus kilómetros al ritmo actual. Nula si no va por
  /// kilómetros, o si el coche está parado y no se alcanzarían nunca.
  final DateTime? fechaEstimadaPorKm;

  final int margenKm;
  final int margenDias;

  const DatosAviso({
    required this.nombre,
    required this.margenKm,
    required this.margenDias,
    this.proximaFecha,
    this.fechaEstimadaPorKm,
  });
}

/// Una notificación a programar: un día concreto y los mantenimientos que la
/// motivan. Varios mantenimientos que caen el mismo día comparten aviso, para
/// no disparar una ráfaga de notificaciones que se acabe ignorando.
class AvisoProgramado {
  final DateTime fecha;
  final List<String> nombres;

  const AvisoProgramado({required this.fecha, required this.nombres});
}

/// Convierte los vencimientos de un vehículo en la lista de avisos a
/// programar, ordenada por fecha.
///
/// Cada mantenimiento puede generar hasta dos: uno al entrar en su margen de
/// aviso y otro al vencer. Solo se devuelven fechas futuras dentro del
/// [horizonte]: una alarma en el pasado no existe, y lo que ya venció se ve
/// en la ficha del vehículo sin necesidad de notificarlo.
List<AvisoProgramado> calcularAvisos({
  required List<DatosAviso> mantenimientos,
  required double kmPorDia,
  required DateTime ahora,
  required DateTime horizonte,
}) {
  final porDia = <DateTime, List<String>>{};

  void anotar(DateTime? fecha, String nombre) {
    if (fecha == null) return;
    final dia = DateTime(fecha.year, fecha.month, fecha.day);
    if (!dia.isAfter(ahora) || dia.isAfter(horizonte)) return;
    porDia.putIfAbsent(dia, () => []).add(nombre);
  }

  for (final m in mantenimientos) {
    // El vencimiento efectivo es el que llegue antes de las dos vías.
    final vencimiento = _laMasTemprana(m.proximaFecha, m.fechaEstimadaPorKm);

    // Cada vía entra en su margen por su cuenta, y el mantenimiento pasa a
    // "atención" en cuanto lo hace cualquiera de las dos.
    final atencionPorFecha = m.proximaFecha?.subtract(
      Duration(days: m.margenDias),
    );
    // Con el coche parado no se puede traducir un margen de kilómetros a
    // días, así que esa vía no aporta fecha de atención.
    final atencionPorKm = (m.fechaEstimadaPorKm == null || kmPorDia <= 0)
        ? null
        : m.fechaEstimadaPorKm!.subtract(
            Duration(days: (m.margenKm / kmPorDia).round()),
          );

    anotar(_laMasTemprana(atencionPorFecha, atencionPorKm), m.nombre);
    anotar(vencimiento, m.nombre);
  }

  final dias = porDia.keys.toList()..sort();

  return [
    for (final dia in dias) AvisoProgramado(fecha: dia, nombres: porDia[dia]!),
  ];
}

DateTime? _laMasTemprana(DateTime? a, DateTime? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a.isBefore(b) ? a : b;
}
