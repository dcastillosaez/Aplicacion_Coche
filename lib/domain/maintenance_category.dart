/// Categoría de un mantenimiento.
///
/// Vive en el dominio por el mismo motivo que [FuelType]
/// (`lib/domain/fuel_type.dart`): es un valor puro que el motor de
/// plantillas de mantenimiento necesita, y `lib/domain/` no puede depender
/// de la capa de datos. `MaintenanceSchedules`
/// (`lib/data/tables/maintenance_schedules.dart`) importa y reexporta este
/// fichero, así que el resto del código sigue usando `MaintenanceCategory`
/// como si estuviera definido allí.
///
/// El nombre del enum y el de sus valores forman parte del formato en el
/// que Drift guarda la categoría (columna `categoria`, vía `textEnum`): se
/// serializan como texto por nombre. No se pueden renombrar sin romper los
/// datos ya guardados en el dispositivo del usuario.
enum MaintenanceCategory {
  motor,
  frenos,
  neumaticos,
  electricidad,
  suspension,
  transmision,
  carroceria,
  itv,
  otro,
  direccion,
  climatizacion,
  escapeEmisiones,
  habitaculo,
  seguridad,
}
