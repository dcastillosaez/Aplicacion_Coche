import 'maintenance_due.dart' show sumarMeses;

/// Periodicidad de la ITV para turismos según la normativa española, en
/// meses. Devuelve 0 mientras el vehículo está exento.
///
/// Hasta los 4 años: exento. De 4 a 10: cada 2 años. A partir de 10: anual.
int mesesEntreItv(DateTime fechaMatriculacion, DateTime enFecha) {
  // sumarMeses recorta al último día real del mes de destino: sin ella, un
  // coche matriculado el 29 de febrero desborda el aniversario a marzo.
  final diezAnios = sumarMeses(fechaMatriculacion, 120);
  final cuatroAnios = sumarMeses(fechaMatriculacion, 48);

  if (enFecha.isBefore(cuatroAnios)) return 0;
  return enFecha.isBefore(diezAnios) ? 24 : 12;
}

/// Fecha de la próxima inspección.
///
/// Sin inspecciones previas se toma la primera obligatoria, a los cuatro
/// años de matricular. Con una previa, se le suma la periodicidad que
/// correspondía a la antigüedad del vehículo en esa inspección — es una
/// simplificación deliberada: la normativa mira la antigüedad en el momento
/// de inspeccionar, no en el de la anterior, y en el año de transición
/// puede desviarse. Como el usuario puede corregir la fecha a mano, no
/// compensa complicarlo.
DateTime? proximaItv({
  required DateTime? fechaMatriculacion,
  DateTime? ultimaItv,
}) {
  if (fechaMatriculacion == null) return null;

  if (ultimaItv == null) {
    return sumarMeses(fechaMatriculacion, 48);
  }

  final meses = mesesEntreItv(fechaMatriculacion, ultimaItv);
  if (meses == 0) {
    // ultimaItv es anterior a que el vehículo cumpliera los cuatro años
    // (fecha incoherente o inspección voluntaria): la primera ITV
    // obligatoria es fija y no depende de ella.
    return sumarMeses(fechaMatriculacion, 48);
  }
  return sumarMeses(ultimaItv, meses);
}
