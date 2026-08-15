/// Qué se hizo realmente en un mantenimiento registrado: no es una
/// propiedad fija del tipo de mantenimiento (un turbo puede repararse una
/// vez y sustituirse la siguiente), sino un dato de cada
/// `MaintenanceRecord`. `MaintenanceType.defaultKind` solo aporta una
/// sugerencia inicial al registrar, nunca un valor fijo.
///
/// El nombre del enum y el de sus valores forman parte del formato en el
/// que Drift guarda el dato (columna `kind`, vía `textEnum`): no se pueden
/// renombrar sin romper los datos ya guardados en el dispositivo.
enum MaintenanceOperationKind {
  preventivo,
  inspeccion,
  reparacion,
  sustitucion,
  otro,
}
