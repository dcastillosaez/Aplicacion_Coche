/// De dónde sale el intervalo configurado para un mantenimiento.
///
/// El valor por defecto y, hoy, el único alcanzable es `orientativo`:
/// hasta que exista un catálogo de piezas que aporte intervalos oficiales
/// por vehículo, ningún mantenimiento puede tener una fuente distinta. La
/// columna se añade ya para no tener que migrar otra vez cuando llegue ese
/// momento.
///
/// El nombre del enum y el de sus valores forman parte del formato en el
/// que Drift guarda la columna `fuenteIntervalo` de `MaintenanceSchedules`,
/// vía `textEnum`: se serializan como texto por nombre. No se pueden
/// renombrar sin romper los datos ya guardados en el dispositivo del
/// usuario.
enum FuenteIntervalo { orientativo, fabricante, usuario }

const Map<FuenteIntervalo, String> etiquetasFuenteIntervalo = {
  FuenteIntervalo.orientativo:
      'Intervalo orientativo: consulta el manual para confirmarlo.',
  FuenteIntervalo.fabricante: 'Según el intervalo oficial de tu vehículo.',
  FuenteIntervalo.usuario: 'Intervalo que has ajustado tú.',
};
