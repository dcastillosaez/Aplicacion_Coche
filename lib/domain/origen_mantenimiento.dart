/// Cuánto se puede confiar en el dato de "cuándo se hizo por última vez"
/// de un mantenimiento.
///
/// Un mantenimiento sin ningún registro y uno sembrado a mano se comportan
/// igual de cara al motor de vencimientos —ambos calculan a partir del
/// mismo dato—, pero de cara al usuario son cosas distintas: uno es "no sé
/// si se ha hecho nunca", el otro es "sé que se hizo, antes de usar la
/// app".
enum OrigenMantenimiento {
  /// La app presenció el mantenimiento: hay un registro real (no sembrado)
  /// que lo confirma.
  confirmado,

  /// Dato introducido a mano al configurar el mantenimiento, anterior a la
  /// app. Es lo mejor que se sabe, pero no es un dato que la app haya visto
  /// ocurrir.
  historico,

  /// Sin ningún registro. No se sabe si el mantenimiento se ha hecho
  /// alguna vez.
  desconocido,
}

/// Determina el origen a partir de si el registro más reciente de ese
/// mantenimiento (si existe) está sembrado.
///
/// [ultimoEsSembrado] es el campo `esSembrado` del registro más reciente
/// del mantenimiento, o `null` si no hay ningún registro. Se usa siempre el
/// registro más reciente, no "si alguna vez hubo uno sembrado": un
/// mantenimiento que se sembró al configurarlo y después tuvo un registro
/// real pasa a confirmado.
OrigenMantenimiento calcularOrigen(bool? ultimoEsSembrado) {
  if (ultimoEsSembrado == null) return OrigenMantenimiento.desconocido;
  return ultimoEsSembrado
      ? OrigenMantenimiento.historico
      : OrigenMantenimiento.confirmado;
}
