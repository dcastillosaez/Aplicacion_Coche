/// Tipo de caja de cambios del vehículo.
///
/// El nombre del enum y el de sus valores forman parte del formato en el
/// que Drift guarda la columna `tipoCaja` de `VehicleSpecifications`, vía
/// `textEnum`: se serializan como texto por nombre. No se pueden renombrar
/// sin romper los datos ya guardados en el dispositivo del usuario.
enum TipoCaja { manual, automatica }

const Map<TipoCaja, String> etiquetasTipoCaja = {
  TipoCaja.manual: 'Manual',
  TipoCaja.automatica: 'Automática',
};
