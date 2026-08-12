/// Tipo de combustible del vehículo.
///
/// Vive en el dominio porque es un valor puro sin dependencias de Drift ni
/// de Flutter: el motor de plantillas de mantenimiento
/// ([lib/domain/plantillas_mantenimiento.dart]) necesita conocerlo, y
/// `lib/domain/` no puede importar la capa de datos. `Vehicles`
/// (`lib/data/tables/vehicles.dart`) importa y reexporta este fichero, así
/// que el resto del código sigue usando `FuelType` como si estuviera
/// definido allí.
///
/// El nombre del enum y el de sus valores forman parte del formato en el
/// que Drift guarda el combustible (columna `combustible`, vía
/// `textEnum`): se serializan como texto por nombre. No se pueden renombrar
/// sin romper los datos ya guardados en el dispositivo del usuario.
enum FuelType { gasolina, diesel, hibrido, electrico, glp }
