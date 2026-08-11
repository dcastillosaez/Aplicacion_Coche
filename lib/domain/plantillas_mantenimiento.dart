import 'fuel_type.dart';
import 'itv.dart' show mesesEntreItv;
import 'maintenance_category.dart';

/// Un mantenimiento habitual propuesto al dar de alta un vehículo.
///
/// Los intervalos son orientativos: valores razonables para partir de algo,
/// no cifras oficiales de ningún fabricante. Quien use la app debe
/// ajustarlos con el libro de mantenimiento de su coche delante — la
/// pantalla que muestra esta lista tiene que dejarlo claro.
class PlantillaMantenimiento {
  final String nombre;
  final MaintenanceCategory categoria;

  /// Nulo cuando el mantenimiento no tiene un kilometraje orientativo
  /// razonable (p. ej. la distribución, que depende del motor concreto) o
  /// cuando solo tiene sentido por tiempo.
  final int? intervalKm;

  /// Nulo cuando el mantenimiento no tiene un plazo orientativo razonable o
  /// cuando solo tiene sentido por kilómetros.
  final int? intervalMeses;

  const PlantillaMantenimiento({
    required this.nombre,
    required this.categoria,
    this.intervalKm,
    this.intervalMeses,
  });
}

/// Meses que se proponen para la ITV cuando el vehículo todavía no llega a
/// los cuatro años o no se conoce su fecha de matriculación: es la
/// periodicidad que le tocará en cuanto deje de estar exento, y evita
/// proponer un intervalo de 0 meses, que no significa nada para el usuario.
const _mesesItvPorDefecto = 24;

/// Mantenimientos habituales que se proponen al dar de alta un vehículo,
/// según su combustible, si el cambio es automático y, para la ITV, su
/// antigüedad a día de hoy.
///
/// Son un punto de partida, no una recomendación oficial: la app no conoce
/// las cifras que da el fabricante para cada motor concreto.
List<PlantillaMantenimiento> plantillasPara({
  required FuelType combustible,
  required bool esAutomatico,
  DateTime? fechaMatriculacion,
}) {
  final esElectrico = combustible == FuelType.electrico;
  final esDiesel = combustible == FuelType.diesel;
  // Los motores de gasolina llevan bujías, tanto si son puros como si
  // forman parte de un híbrido o queman GLP.
  final llevaBujias = combustible == FuelType.gasolina ||
      combustible == FuelType.hibrido ||
      combustible == FuelType.glp;

  return [
    if (!esElectrico) ...[
      const PlantillaMantenimiento(
        nombre: 'Aceite y filtro',
        categoria: MaintenanceCategory.motor,
        intervalKm: 15000,
        intervalMeses: 12,
      ),
      const PlantillaMantenimiento(
        nombre: 'Filtro de aire',
        categoria: MaintenanceCategory.motor,
        intervalKm: 30000,
        intervalMeses: 24,
      ),
    ],
    const PlantillaMantenimiento(
      nombre: 'Filtro de habitáculo',
      categoria: MaintenanceCategory.otro,
      intervalKm: 20000,
      intervalMeses: 12,
    ),
    if (esDiesel)
      const PlantillaMantenimiento(
        nombre: 'Filtro de combustible',
        categoria: MaintenanceCategory.motor,
        intervalKm: 40000,
        intervalMeses: 48,
      ),
    if (llevaBujias)
      const PlantillaMantenimiento(
        nombre: 'Bujías',
        categoria: MaintenanceCategory.motor,
        intervalKm: 60000,
        intervalMeses: 60,
      ),
    const PlantillaMantenimiento(
      nombre: 'Líquido de frenos',
      categoria: MaintenanceCategory.frenos,
      intervalMeses: 24,
    ),
    if (!esElectrico)
      const PlantillaMantenimiento(
        nombre: 'Refrigerante',
        categoria: MaintenanceCategory.motor,
        intervalKm: 60000,
        intervalMeses: 48,
      ),
    const PlantillaMantenimiento(
      nombre: 'Pastillas de freno delanteras',
      categoria: MaintenanceCategory.frenos,
      intervalKm: 40000,
    ),
    const PlantillaMantenimiento(
      nombre: 'Pastillas de freno traseras',
      categoria: MaintenanceCategory.frenos,
      intervalKm: 60000,
    ),
    const PlantillaMantenimiento(
      nombre: 'Discos de freno',
      categoria: MaintenanceCategory.frenos,
      intervalKm: 80000,
    ),
    const PlantillaMantenimiento(
      nombre: 'Neumáticos',
      categoria: MaintenanceCategory.neumaticos,
      intervalKm: 40000,
      intervalMeses: 72,
    ),
    const PlantillaMantenimiento(
      nombre: 'Batería',
      categoria: MaintenanceCategory.electricidad,
      intervalMeses: 60,
    ),
    // Sin intervalo a propósito: depende del motor concreto y la app no
    // puede saberlo. Que el dueño lo rellene con el libro delante.
    if (!esElectrico)
      const PlantillaMantenimiento(
        nombre: 'Correa o cadena de distribución',
        categoria: MaintenanceCategory.motor,
      ),
    if (esAutomatico)
      const PlantillaMantenimiento(
        nombre: 'Aceite de la caja automática',
        categoria: MaintenanceCategory.transmision,
        intervalKm: 60000,
        intervalMeses: 72,
      ),
    PlantillaMantenimiento(
      nombre: 'ITV',
      categoria: MaintenanceCategory.itv,
      intervalMeses: _mesesItvOrientativos(fechaMatriculacion),
    ),
  ];
}

int _mesesItvOrientativos(DateTime? fechaMatriculacion) {
  if (fechaMatriculacion == null) return _mesesItvPorDefecto;
  final meses = mesesEntreItv(fechaMatriculacion, DateTime.now());
  // meses == 0 mientras el vehículo está exento: no hay periodicidad real
  // que proponer todavía.
  return meses == 0 ? _mesesItvPorDefecto : meses;
}
