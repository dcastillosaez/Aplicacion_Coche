/// Dónde está una pieza, cuando el tipo de mantenimiento lo necesita
/// (`MaintenanceType.admitePosicion`). Es metadato de localización,
/// independiente del tipo: `tipo = pastillasFreno, posicion = delantera`,
/// nunca un tipo por cada combinación.
///
/// El nombre del enum y el de sus valores forman parte del formato en el
/// que Drift guarda el dato (columna `posicion`, vía `textEnum`): no se
/// pueden renombrar sin romper los datos ya guardados en el dispositivo.
enum Posicion {
  delantera,
  trasera,
  izquierda,
  derecha,
  delanteraIzquierda,
  delanteraDerecha,
  traseraIzquierda,
  traseraDerecha,
  ejeDelantero,
  ejeTrasero,
}
