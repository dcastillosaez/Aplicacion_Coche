import '../../domain/maintenance_due.dart';
import 'formatters.dart';

/// Textos y avisos para presentar un [Vencimiento] con las cifras honestas
/// que rigen toda la app: el kilometraje que se muestra como dato es
/// siempre el real, nunca el proyectado; toda cifra derivada de una
/// proyección lleva ≈; y si esa proyección se apoya en un ritmo de uso
/// supuesto por falta de lecturas, se advierte con texto, no solo con el
/// símbolo. Compartido entre la ficha del vehículo y la pantalla de Inicio
/// para que las cifras se lean igual en toda la app.

/// Kilómetros que faltan hasta el próximo cambio, proyectados a partir de la
/// última lectura real y el ritmo de uso: siempre una estimación, siempre
/// marcada con ≈. Negativo (vencido) se expresa como "hace" en vez de
/// "faltan".
String? textoKmRestantes(Vencimiento v) {
  final km = v.kmRestantes;
  if (km == null) return null;
  final cifra = formatearKm(km.abs());
  return km >= 0 ? '≈ Faltan $cifra' : '≈ Vencido hace $cifra';
}

/// Días naturales hasta la fecha de vencimiento: a diferencia del
/// kilometraje, no depende de ningún ritmo supuesto, así que no lleva ≈.
String? textoDiasRestantes(Vencimiento v) {
  final dias = v.diasRestantes;
  if (dias == null) return null;
  final abs = dias.abs();
  final unidad = abs == 1 ? 'día' : 'días';
  return dias >= 0 ? 'Faltan $abs $unidad' : 'Vencido hace $abs $unidad';
}

/// Días hasta el vencimiento para un mantenimiento que solo va por
/// kilómetros: no hay una fecha real que consultar, así que se traduce el
/// kilometraje restante a días al ritmo de uso actual. Es una proyección
/// como [textoKmRestantes], así que lleva ≈. Solo aporta algo cuando no
/// existe ya una vía de tiempo real: si [Vencimiento.diasRestantes] no es
/// nulo, esa es la cifra que manda y esta queda fuera.
String? textoDiasEstimadosPorKm(Vencimiento v) {
  if (v.diasRestantes != null) return null;
  final dias = v.diasHastaVencimiento;
  if (dias == null) return null;
  final abs = dias.abs();
  final unidad = abs == 1 ? 'día' : 'días';
  return dias >= 0 ? '≈ Faltan $abs $unidad' : '≈ Vencido hace $abs $unidad';
}

/// Kilometraje exacto al que toca, calculado a partir del último real más el
/// intervalo: no es una proyección, así que no lleva ≈.
String? textoProximoKm(Vencimiento v) => v.proximoKm == null
    ? null
    : 'Próximo cambio: ${formatearKm(v.proximoKm!)}';

/// Fecha exacta a la que toca: tampoco es una estimación.
String? textoProximaFecha(Vencimiento v) => v.proximaFecha == null
    ? null
    : 'Próxima fecha: ${formatearFecha(v.proximaFecha!)}';

/// Resumen de una línea con las cifras disponibles: kilómetros restantes,
/// días por fecha y, si no hay vía de fecha, los días estimados por
/// kilómetros. Vacío si el mantenimiento todavía no tiene ningún dato con
/// el que calcular nada (por ejemplo, recién configurado y sin registrar
/// todavía).
String resumenVencimiento(Vencimiento v) => [
      textoKmRestantes(v),
      textoDiasRestantes(v),
      textoDiasEstimadosPorKm(v),
    ].whereType<String>().join(' · ');

/// Aviso a mostrar cuando, entre las cifras visibles, alguna estimación se
/// apoya en el ritmo de uso por defecto en vez de en lecturas reales: no
/// basta con el símbolo ≈, hay que decirlo explícitamente.
const String avisoRitmoSupuesto =
    'Las cifras con ≈ se basan en un ritmo de uso supuesto: todavía no hay '
    'lecturas suficientes para medirlo.';

/// Si, entre los vencimientos dados, hace falta mostrar [avisoRitmoSupuesto]:
/// solo cuando hay alguna cifra estimada por kilómetros y esa estimación se
/// apoya en el ritmo por defecto.
bool necesitaAvisoRitmoSupuesto(Iterable<Vencimiento> vencimientos) =>
    vencimientos.any((v) => v.kmRestantes != null) &&
    vencimientos.any((v) => v.estimacionEsSupuesta);
