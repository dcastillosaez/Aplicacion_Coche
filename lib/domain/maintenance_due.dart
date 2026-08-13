import 'usage_rate.dart';

enum EstadoMantenimiento {
  /// No hay ningún dato de cuándo se hizo por última vez, así que no se
  /// puede calcular nada. No genera avisos.
  sinConfigurar,
  ok,
  proximo,
  atencion,
  vencido,
}

/// Lo que el motor necesita saber de un mantenimiento, sin acoplarse a la
/// capa de datos.
class DatosVencimiento {
  final int? intervalKm;
  final int? intervalMeses;
  final int? avisoKm;
  final int? avisoDias;
  final int? ultimoKm;
  final DateTime? ultimaFecha;

  const DatosVencimiento({
    this.intervalKm,
    this.intervalMeses,
    this.avisoKm,
    this.avisoDias,
    this.ultimoKm,
    this.ultimaFecha,
  });
}

class Vencimiento {
  final EstadoMantenimiento estado;

  /// Kilometraje al que toca. Nulo si el mantenimiento no va por kilómetros.
  final int? proximoKm;

  /// Fecha en la que toca. Nula si el mantenimiento no va por tiempo.
  final DateTime? proximaFecha;

  /// Kilómetros que faltan respecto a la proyección de hoy. Negativo si ya
  /// se pasó.
  final int? kmRestantes;

  /// Días naturales que faltan. Negativo si ya se pasó.
  final int? diasRestantes;

  /// Kilometraje estimado a día de hoy a partir de la última lectura y del
  /// ritmo de uso. Siempre es una estimación: el dato real es la lectura.
  final int kmProyectado;

  /// Cuándo se alcanzarán los kilómetros del vencimiento, al ritmo actual.
  /// Nula con el coche parado, porque no se alcanzarían nunca.
  final DateTime? fechaEstimadaPorKm;

  /// Cierto cuando la estimación se apoya en el ritmo por defecto y no en
  /// lecturas reales: es una suposición, y la interfaz debe decirlo.
  final bool estimacionEsSupuesta;

  /// De las dos vías, cuál llega antes. Nulo si solo hay una.
  final bool? venceAntesPorFecha;

  /// Días naturales hasta el vencimiento que llega antes de las dos vías: el
  /// menor entre [diasRestantes] y los días hasta [fechaEstimadaPorKm].
  /// Es la magnitud que refleja la severidad real del mantenimiento (más
  /// negativo cuanto más vencido), a diferencia de mirar solo [diasRestantes]
  /// que ignora los mantenimientos que van únicamente por kilómetros. Nulo
  /// cuando ninguna vía tiene una fecha calculable: por ejemplo, un
  /// mantenimiento solo por kilómetros con el coche parado.
  final int? diasHastaVencimiento;

  const Vencimiento({
    required this.estado,
    required this.kmProyectado,
    this.proximoKm,
    this.proximaFecha,
    this.kmRestantes,
    this.diasRestantes,
    this.fechaEstimadaPorKm,
    this.estimacionEsSupuesta = false,
    this.venceAntesPorFecha,
    this.diasHastaVencimiento,
  });
}

/// Días naturales entre dos fechas, inmune a los cambios de horario.
int diasNaturalesEntre(DateTime desde, DateTime hasta) {
  final a = DateTime.utc(desde.year, desde.month, desde.day);
  final b = DateTime.utc(hasta.year, hasta.month, hasta.day);
  return b.difference(a).inDays;
}

/// Suma meses sin desbordar a un día que no existe: el 31 de enero más un
/// mes es el 28 de febrero, no el 3 de marzo.
DateTime sumarMeses(DateTime fecha, int meses) {
  final totalMeses = fecha.month - 1 + meses;
  final anio = fecha.year + totalMeses ~/ 12;
  final mes = totalMeses % 12 + 1;
  final ultimoDiaDelMes = DateTime(anio, mes + 1, 0).day;
  return DateTime(anio, mes, fecha.day.clamp(1, ultimoDiaDelMes));
}

Vencimiento calcularVencimiento({
  required DatosVencimiento datos,
  required int kmActual,
  required DateTime fechaUltimaLectura,
  required UsageRateResult ritmo,
  required DateTime ahora,
  required int avisoKmPorDefecto,
  required int avisoDiasPorDefecto,
}) {
  final diasDesdeLectura = diasNaturalesEntre(fechaUltimaLectura, ahora);
  final kmProyectado = kmActual + (ritmo.kmPorDia * diasDesdeLectura).round();

  if (datos.ultimoKm == null || datos.ultimaFecha == null) {
    return Vencimiento(
      estado: EstadoMantenimiento.sinConfigurar,
      kmProyectado: kmProyectado,
    );
  }

  final margenKm = datos.avisoKm ?? avisoKmPorDefecto;
  final margenDias = datos.avisoDias ?? avisoDiasPorDefecto;

  int? proximoKm;
  int? kmRestantes;
  DateTime? fechaEstimadaPorKm;
  if (datos.intervalKm != null) {
    proximoKm = datos.ultimoKm! + datos.intervalKm!;
    kmRestantes = proximoKm - kmProyectado;
    if (!ritmo.cocheParado) {
      fechaEstimadaPorKm = ahora.add(
        Duration(days: (kmRestantes / ritmo.kmPorDia).round()),
      );
    }
  }

  DateTime? proximaFecha;
  int? diasRestantes;
  if (datos.intervalMeses != null) {
    proximaFecha = sumarMeses(datos.ultimaFecha!, datos.intervalMeses!);
    diasRestantes = diasNaturalesEntre(ahora, proximaFecha);
  }

  final vencidoPorKm = kmRestantes != null && kmRestantes <= 0;
  final vencidoPorFecha = diasRestantes != null && diasRestantes <= 0;

  final atencionPorKm = kmRestantes != null && kmRestantes <= margenKm;
  final atencionPorFecha = diasRestantes != null && diasRestantes <= margenDias;

  final proximoPorKm = kmRestantes != null && kmRestantes <= margenKm * 2;
  final proximoPorFecha =
      diasRestantes != null && diasRestantes <= margenDias * 2;

  final EstadoMantenimiento estado;
  if (vencidoPorKm || vencidoPorFecha) {
    estado = EstadoMantenimiento.vencido;
  } else if (atencionPorKm || atencionPorFecha) {
    estado = EstadoMantenimiento.atencion;
  } else if (proximoPorKm || proximoPorFecha) {
    estado = EstadoMantenimiento.proximo;
  } else {
    estado = EstadoMantenimiento.ok;
  }

  bool? venceAntesPorFecha;
  if (proximaFecha != null && fechaEstimadaPorKm != null) {
    venceAntesPorFecha = proximaFecha.isBefore(fechaEstimadaPorKm);
  }

  // Misma idea que venceAntesPorFecha, pero como cantidad: cuántos días
  // faltan hasta la vía que llega antes. Se necesita para ordenar por
  // severidad real, no solo por la vía de tiempo.
  final diasHastaVencimientoPorKm = fechaEstimadaPorKm != null
      ? diasNaturalesEntre(ahora, fechaEstimadaPorKm)
      : null;
  final int? diasHastaVencimiento;
  if (diasRestantes != null && diasHastaVencimientoPorKm != null) {
    diasHastaVencimiento = diasRestantes <= diasHastaVencimientoPorKm
        ? diasRestantes
        : diasHastaVencimientoPorKm;
  } else {
    diasHastaVencimiento = diasRestantes ?? diasHastaVencimientoPorKm;
  }

  return Vencimiento(
    estado: estado,
    kmProyectado: kmProyectado,
    proximoKm: proximoKm,
    proximaFecha: proximaFecha,
    kmRestantes: kmRestantes,
    diasRestantes: diasRestantes,
    fechaEstimadaPorKm: fechaEstimadaPorKm,
    estimacionEsSupuesta: ritmo.esPorDefecto,
    venceAntesPorFecha: venceAntesPorFecha,
    diasHastaVencimiento: diasHastaVencimiento,
  );
}
