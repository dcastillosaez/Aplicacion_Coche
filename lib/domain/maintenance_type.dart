import 'maintenance_category.dart';
import 'maintenance_operation_kind.dart';

/// Qué es exactamente un mantenimiento, dentro de su categoría: pastillas
/// de freno, correa de distribución, turbo... Cada tipo pertenece a una
/// única categoría (nunca aparece duplicado en dos), lleva una sugerencia
/// de [MaintenanceOperationKind] para cuando se registre por primera vez
/// (nunca un valor fijo — ver `MaintenanceRecord.kind`), y declara si
/// admite [Posicion] (delantera/trasera/...).
///
/// El nombre del enum y el de sus valores forman parte del formato en el
/// que Drift guarda el dato (columna `tipo` de `MaintenanceSchedules`, vía
/// `textEnum`): no se pueden renombrar sin romper los datos ya guardados
/// en el dispositivo.
///
/// Catálogo documentado en
/// `docs/superpowers/specs/2026-08-13-taxonomia-tipos-mantenimiento-design.md`,
/// sección 4: mismo orden, mismos valores.
enum MaintenanceType {
  // Motor
  aceiteMotor(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  filtroAceite(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  filtroAire(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  filtroCombustible(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  bujias(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  calentadores(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  bobinasEncendido(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  correaDistribucion(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  kitDistribucion(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  cadenaDistribucion(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  tensorDistribucion(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  correaAuxiliar(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  tensorCorreaAuxiliar(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  bombaAgua(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  refrigerante(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  bombaAceite(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  termostato(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  radiador(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  manguitosRefrigeracion(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  soportesMotor(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  admision(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  inyectores(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  sistemaCombustible(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  limpiezaDescarbonizacion(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.preventivo,
    admitePosicion: false,
  ),
  turbo(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  otroMotor(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Frenos
  pastillasFreno(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  discosFreno(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  zapatasFreno(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  tamboresFreno(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  liquidoFrenos(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  pinzasFreno(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  latiguillosFreno(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  sensorDesgasteFreno(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  cilindroMaestro(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  servofreno(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  abs(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  sensoresAbs(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  frenoEstacionamiento(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  frenoEstacionamientoElectrico(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  otroFrenos(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Neumáticos
  neumatico(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  rotacionNeumaticos(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.preventivo,
    admitePosicion: false,
  ),
  equilibrado(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  alineacion(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  reparacionPinchazo(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  valvulas(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  tpms(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  kitAntipinchazos(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  ruedaRepuesto(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  otroNeumaticos(
    categoria: MaintenanceCategory.neumaticos,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Electricidad
  bateria(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  alternador(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  motorArranque(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  fusibles(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  reles(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  bombillas(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  iluminacionExterior(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  iluminacionInterior(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  sensorElectrico(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  cableado(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  sistemaCarga(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  otroElectricidad(
    categoria: MaintenanceCategory.electricidad,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Suspensión
  amortiguadores(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  muelles(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  copelas(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  rodamientosCopela(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  brazosSuspension(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  silentblocks(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  rotulasSuspension(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  bieletasEstabilizadoras(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  barraEstabilizadora(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  rodamientosRueda(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  mangueta(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  suspensionNeumatica(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  compresorSuspension(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  otroSuspension(
    categoria: MaintenanceCategory.suspension,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Dirección
  direccionAsistida(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  bombaDireccion(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  cremallera(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  terminalDireccion(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  rotulaDireccion(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  columnaDireccion(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  volante(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  direccionElectrica(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  liquidoDireccion(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  otroDireccion(
    categoria: MaintenanceCategory.direccion,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Transmisión
  embrague(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  kitEmbrague(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  volanteBimasa(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  cajaCambiosManual(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  cajaCambiosAutomatica(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  aceiteCajaCambios(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  filtroCajaCambios(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  convertidorPar(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  mecatronica(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  palieres(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  juntasHomocineticas(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  arbolTransmision(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  diferencial(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  aceiteDiferencial(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  transfer(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  aceiteTransfer(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  retenesTransmision(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  otroTransmision(
    categoria: MaintenanceCategory.transmision,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Climatización
  aireAcondicionado(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  gasRefrigeranteAc(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  compresorAc(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  condensadorAc(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  evaporadorAc(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  filtroDeshidratador(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  ventiladorClimatizacion(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  motorVentilador(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  calefaccion(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  radiadorCalefaccion(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  termostatoClimatizacion(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  otroClimatizacion(
    categoria: MaintenanceCategory.climatizacion,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Escape y emisiones
  escape(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  silencioso(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  catalizador(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  dpfFap(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  egr(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  sondaLambda(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  sensorNox(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  sensorTemperaturaEscape(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  adblueScr(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  inyectorAdblue(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  depositoAdblue(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  otroEscapeEmisiones(
    categoria: MaintenanceCategory.escapeEmisiones,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Carrocería
  paragolpes(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  capo(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  puertas(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  porton(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  aletas(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  espejos(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  elevalunas(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  cerraduras(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  bisagras(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  escobillasLimpiaparabrisas(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  brazosLimpiaparabrisas(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  motorLimpiaparabrisas(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  lunaParabrisas(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  molduras(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  juntasCarroceria(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  techoSolar(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  otroCarroceria(
    categoria: MaintenanceCategory.carroceria,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Habitáculo
  filtroHabitaculo(
    categoria: MaintenanceCategory.habitaculo,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  alfombrillas(
    categoria: MaintenanceCategory.habitaculo,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  asientos(
    categoria: MaintenanceCategory.habitaculo,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  salpicadero(
    categoria: MaintenanceCategory.habitaculo,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  instrumentacion(
    categoria: MaintenanceCategory.habitaculo,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  pantallaInfotainment(
    categoria: MaintenanceCategory.habitaculo,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  altavoces(
    categoria: MaintenanceCategory.habitaculo,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  otroHabitaculo(
    categoria: MaintenanceCategory.habitaculo,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Seguridad
  airbag(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  pretensorCinturon(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  cinturonSeguridad(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  esp(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  sensorImpacto(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  camaraSeguridad(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  radarSeguridad(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  adas(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  sensorAparcamiento(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: true,
  ),
  otroSeguridad(
    categoria: MaintenanceCategory.seguridad,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // ITV / Inspección
  inspeccionItv(
    categoria: MaintenanceCategory.itv,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  preItv(
    categoria: MaintenanceCategory.itv,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  inspeccionGeneral(
    categoria: MaintenanceCategory.itv,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  inspeccionEmisiones(
    categoria: MaintenanceCategory.itv,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  inspeccionFrenos(
    categoria: MaintenanceCategory.itv,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  inspeccionNeumaticos(
    categoria: MaintenanceCategory.itv,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  inspeccionLuces(
    categoria: MaintenanceCategory.itv,
    defaultKind: MaintenanceOperationKind.inspeccion,
    admitePosicion: false,
  ),
  otroItv(
    categoria: MaintenanceCategory.itv,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),

  // Otro
  mantenimientoGeneral(
    categoria: MaintenanceCategory.otro,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  ),
  reparacionGeneral(
    categoria: MaintenanceCategory.otro,
    defaultKind: MaintenanceOperationKind.reparacion,
    admitePosicion: false,
  ),
  otro(
    categoria: MaintenanceCategory.otro,
    defaultKind: MaintenanceOperationKind.otro,
    admitePosicion: false,
  );

  final MaintenanceCategory categoria;
  final MaintenanceOperationKind defaultKind;
  final bool admitePosicion;

  const MaintenanceType({
    required this.categoria,
    required this.defaultKind,
    required this.admitePosicion,
  });
}
