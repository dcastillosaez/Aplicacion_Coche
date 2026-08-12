/// Tracción del vehículo.
///
/// El nombre del enum y el de sus valores forman parte del formato en el
/// que Drift guarda la columna `traccion` de `VehicleSpecifications`, vía
/// `textEnum`: se serializan como texto por nombre. No se pueden renombrar
/// sin romper los datos ya guardados en el dispositivo del usuario.
enum Traccion { delantera, trasera, total }

const Map<Traccion, String> etiquetasTraccion = {
  Traccion.delantera: 'Delantera',
  Traccion.trasera: 'Trasera',
  Traccion.total: 'Total',
};
