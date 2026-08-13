import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database.dart';
import '../../data/tables/maintenance_records.dart'
    show MaintenanceOperationKind;
import '../../data/tables/maintenance_schedules.dart';
import '../../providers/providers.dart';
import '../common/formatters.dart';

const Map<MaintenanceCategory, String> etiquetasCategoria = {
  MaintenanceCategory.motor: 'Motor',
  MaintenanceCategory.frenos: 'Frenos',
  MaintenanceCategory.neumaticos: 'Neumáticos',
  MaintenanceCategory.electricidad: 'Electricidad',
  MaintenanceCategory.suspension: 'Suspensión',
  MaintenanceCategory.transmision: 'Transmisión',
  MaintenanceCategory.carroceria: 'Carrocería',
  MaintenanceCategory.itv: 'ITV',
  MaintenanceCategory.otro: 'Otro',
  MaintenanceCategory.direccion: 'Dirección',
  MaintenanceCategory.climatizacion: 'Climatización',
  MaintenanceCategory.escapeEmisiones: 'Escape y emisiones',
  MaintenanceCategory.habitaculo: 'Habitáculo',
  MaintenanceCategory.seguridad: 'Seguridad',
};

const Map<MaintenanceType, String> etiquetasMaintenanceType = {
  // Motor
  MaintenanceType.aceiteMotor: 'Aceite motor',
  MaintenanceType.filtroAceite: 'Filtro de aceite',
  MaintenanceType.filtroAire: 'Filtro de aire',
  MaintenanceType.filtroCombustible: 'Filtro de combustible',
  MaintenanceType.bujias: 'Bujías',
  MaintenanceType.calentadores: 'Calentadores',
  MaintenanceType.bobinasEncendido: 'Bobinas de encendido',
  MaintenanceType.correaDistribucion: 'Correa de distribución',
  MaintenanceType.kitDistribucion: 'Kit de distribución',
  MaintenanceType.cadenaDistribucion: 'Cadena de distribución',
  MaintenanceType.tensorDistribucion: 'Tensor de distribución',
  MaintenanceType.correaAuxiliar: 'Correa auxiliar',
  MaintenanceType.tensorCorreaAuxiliar: 'Tensor de correa auxiliar',
  MaintenanceType.bombaAgua: 'Bomba de agua',
  MaintenanceType.refrigerante: 'Refrigerante',
  MaintenanceType.bombaAceite: 'Bomba de aceite',
  MaintenanceType.termostato: 'Termostato',
  MaintenanceType.radiador: 'Radiador',
  MaintenanceType.manguitosRefrigeracion: 'Manguitos de refrigeración',
  MaintenanceType.soportesMotor: 'Soportes de motor',
  MaintenanceType.admision: 'Admisión',
  MaintenanceType.inyectores: 'Inyectores',
  MaintenanceType.sistemaCombustible: 'Sistema de combustible',
  MaintenanceType.limpiezaDescarbonizacion: 'Limpieza / descarbonización',
  MaintenanceType.turbo: 'Turbo',
  MaintenanceType.otroMotor: 'Otro (motor)',
  // Frenos
  MaintenanceType.pastillasFreno: 'Pastillas de freno',
  MaintenanceType.discosFreno: 'Discos de freno',
  MaintenanceType.zapatasFreno: 'Zapatas de freno',
  MaintenanceType.tamboresFreno: 'Tambores de freno',
  MaintenanceType.liquidoFrenos: 'Líquido de frenos',
  MaintenanceType.pinzasFreno: 'Pinzas de freno',
  MaintenanceType.latiguillosFreno: 'Latiguillos de freno',
  MaintenanceType.sensorDesgasteFreno: 'Sensor de desgaste',
  MaintenanceType.cilindroMaestro: 'Cilindro maestro',
  MaintenanceType.servofreno: 'Servofreno',
  MaintenanceType.abs: 'ABS',
  MaintenanceType.sensoresAbs: 'Sensores ABS',
  MaintenanceType.frenoEstacionamiento: 'Freno de estacionamiento',
  MaintenanceType.frenoEstacionamientoElectrico:
      'Freno de estacionamiento eléctrico',
  MaintenanceType.otroFrenos: 'Otro (frenos)',
  // Neumáticos
  MaintenanceType.neumatico: 'Neumático',
  MaintenanceType.rotacionNeumaticos: 'Rotación de neumáticos',
  MaintenanceType.equilibrado: 'Equilibrado',
  MaintenanceType.alineacion: 'Alineación',
  MaintenanceType.reparacionPinchazo: 'Reparación de pinchazo',
  MaintenanceType.valvulas: 'Válvulas',
  MaintenanceType.tpms: 'TPMS / sensores de presión',
  MaintenanceType.kitAntipinchazos: 'Kit antipinchazos',
  MaintenanceType.ruedaRepuesto: 'Rueda de repuesto',
  MaintenanceType.otroNeumaticos: 'Otro (neumáticos)',
  // Electricidad
  MaintenanceType.bateria: 'Batería',
  MaintenanceType.alternador: 'Alternador',
  MaintenanceType.motorArranque: 'Motor de arranque',
  MaintenanceType.fusibles: 'Fusibles',
  MaintenanceType.reles: 'Relés',
  MaintenanceType.bombillas: 'Bombillas',
  MaintenanceType.iluminacionExterior: 'Iluminación exterior',
  MaintenanceType.iluminacionInterior: 'Iluminación interior',
  MaintenanceType.sensorElectrico: 'Sensor',
  MaintenanceType.cableado: 'Cableado',
  MaintenanceType.sistemaCarga: 'Sistema de carga',
  MaintenanceType.otroElectricidad: 'Otro (electricidad)',
  // Suspensión
  MaintenanceType.amortiguadores: 'Amortiguadores',
  MaintenanceType.muelles: 'Muelles',
  MaintenanceType.copelas: 'Copelas',
  MaintenanceType.rodamientosCopela: 'Rodamientos de copela',
  MaintenanceType.brazosSuspension: 'Brazos de suspensión',
  MaintenanceType.silentblocks: 'Silentblocks',
  MaintenanceType.rotulasSuspension: 'Rótulas',
  MaintenanceType.bieletasEstabilizadoras: 'Bieletas estabilizadoras',
  MaintenanceType.barraEstabilizadora: 'Barra estabilizadora',
  MaintenanceType.rodamientosRueda: 'Rodamientos de rueda',
  MaintenanceType.mangueta: 'Mangueta',
  MaintenanceType.suspensionNeumatica: 'Suspensión neumática',
  MaintenanceType.compresorSuspension: 'Compresor de suspensión',
  MaintenanceType.otroSuspension: 'Otro (suspensión)',
  // Dirección
  MaintenanceType.direccionAsistida: 'Dirección asistida',
  MaintenanceType.bombaDireccion: 'Bomba de dirección',
  MaintenanceType.cremallera: 'Cremallera',
  MaintenanceType.terminalDireccion: 'Terminal de dirección',
  MaintenanceType.rotulaDireccion: 'Rótula de dirección',
  MaintenanceType.columnaDireccion: 'Columna de dirección',
  MaintenanceType.volante: 'Volante',
  MaintenanceType.direccionElectrica: 'Dirección eléctrica',
  MaintenanceType.liquidoDireccion: 'Líquido de dirección',
  MaintenanceType.otroDireccion: 'Otro (dirección)',
  // Transmisión
  MaintenanceType.embrague: 'Embrague',
  MaintenanceType.kitEmbrague: 'Kit de embrague',
  MaintenanceType.volanteBimasa: 'Volante bimasa',
  MaintenanceType.cajaCambiosManual: 'Caja de cambios manual',
  MaintenanceType.cajaCambiosAutomatica: 'Caja de cambios automática',
  MaintenanceType.aceiteCajaCambios: 'Aceite de caja de cambios',
  MaintenanceType.filtroCajaCambios: 'Filtro de caja de cambios',
  MaintenanceType.convertidorPar: 'Convertidor de par',
  MaintenanceType.mecatronica: 'Mecatrónica',
  MaintenanceType.palieres: 'Palieres',
  MaintenanceType.juntasHomocineticas: 'Juntas homocinéticas',
  MaintenanceType.arbolTransmision: 'Árbol de transmisión',
  MaintenanceType.diferencial: 'Diferencial',
  MaintenanceType.aceiteDiferencial: 'Aceite de diferencial',
  MaintenanceType.transfer: 'Transfer',
  MaintenanceType.aceiteTransfer: 'Aceite de transfer',
  MaintenanceType.retenesTransmision: 'Retenes de transmisión',
  MaintenanceType.otroTransmision: 'Otro (transmisión)',
  // Climatización
  MaintenanceType.aireAcondicionado: 'Aire acondicionado',
  MaintenanceType.gasRefrigeranteAc: 'Gas refrigerante',
  MaintenanceType.compresorAc: 'Compresor A/C',
  MaintenanceType.condensadorAc: 'Condensador',
  MaintenanceType.evaporadorAc: 'Evaporador',
  MaintenanceType.filtroDeshidratador: 'Filtro deshidratador',
  MaintenanceType.ventiladorClimatizacion: 'Ventilador',
  MaintenanceType.motorVentilador: 'Motor del ventilador',
  MaintenanceType.calefaccion: 'Calefacción',
  MaintenanceType.radiadorCalefaccion: 'Radiador de calefacción',
  MaintenanceType.termostatoClimatizacion: 'Termostato de climatización',
  MaintenanceType.otroClimatizacion: 'Otro (climatización)',
  // Escape y emisiones
  MaintenanceType.escape: 'Escape',
  MaintenanceType.silencioso: 'Silencioso',
  MaintenanceType.catalizador: 'Catalizador',
  MaintenanceType.dpfFap: 'Filtro de partículas (DPF/FAP)',
  MaintenanceType.egr: 'EGR',
  MaintenanceType.sondaLambda: 'Sonda lambda',
  MaintenanceType.sensorNox: 'Sensor NOx',
  MaintenanceType.sensorTemperaturaEscape: 'Sensor de temperatura',
  MaintenanceType.adblueScr: 'AdBlue / SCR',
  MaintenanceType.inyectorAdblue: 'Inyector AdBlue',
  MaintenanceType.depositoAdblue: 'Depósito AdBlue',
  MaintenanceType.otroEscapeEmisiones: 'Otro (escape y emisiones)',
  // Carrocería
  MaintenanceType.paragolpes: 'Parachoques',
  MaintenanceType.capo: 'Capó',
  MaintenanceType.puertas: 'Puertas',
  MaintenanceType.porton: 'Portón',
  MaintenanceType.aletas: 'Aletas',
  MaintenanceType.espejos: 'Espejos',
  MaintenanceType.elevalunas: 'Elevalunas',
  MaintenanceType.cerraduras: 'Cerraduras',
  MaintenanceType.bisagras: 'Bisagras',
  MaintenanceType.escobillasLimpiaparabrisas: 'Escobillas limpiaparabrisas',
  MaintenanceType.brazosLimpiaparabrisas: 'Brazos limpiaparabrisas',
  MaintenanceType.motorLimpiaparabrisas: 'Motor limpiaparabrisas',
  MaintenanceType.lunaParabrisas: 'Luna / parabrisas',
  MaintenanceType.molduras: 'Molduras',
  MaintenanceType.juntasCarroceria: 'Juntas',
  MaintenanceType.techoSolar: 'Techo solar / panorámico',
  MaintenanceType.otroCarroceria: 'Otro (carrocería)',
  // Habitáculo
  MaintenanceType.filtroHabitaculo: 'Filtro de habitáculo',
  MaintenanceType.alfombrillas: 'Alfombrillas',
  MaintenanceType.asientos: 'Asientos',
  MaintenanceType.salpicadero: 'Salpicadero',
  MaintenanceType.instrumentacion: 'Instrumentación',
  MaintenanceType.pantallaInfotainment: 'Pantalla / infotainment',
  MaintenanceType.altavoces: 'Altavoces',
  MaintenanceType.otroHabitaculo: 'Otro (habitáculo)',
  // Seguridad
  MaintenanceType.airbag: 'Airbag',
  MaintenanceType.pretensorCinturon: 'Pretensor de cinturón',
  MaintenanceType.cinturonSeguridad: 'Cinturón de seguridad',
  MaintenanceType.esp: 'ESP / ESC',
  MaintenanceType.sensorImpacto: 'Sensor de impacto',
  MaintenanceType.camaraSeguridad: 'Cámara',
  MaintenanceType.radarSeguridad: 'Radar',
  MaintenanceType.adas: 'ADAS',
  MaintenanceType.sensorAparcamiento: 'Sensor de aparcamiento',
  MaintenanceType.otroSeguridad: 'Otro (seguridad)',
  // ITV
  MaintenanceType.inspeccionItv: 'ITV',
  MaintenanceType.preItv: 'Pre-ITV',
  MaintenanceType.inspeccionGeneral: 'Inspección general',
  MaintenanceType.inspeccionEmisiones: 'Inspección de emisiones',
  MaintenanceType.inspeccionFrenos: 'Inspección de frenos',
  MaintenanceType.inspeccionNeumaticos: 'Inspección de neumáticos',
  MaintenanceType.inspeccionLuces: 'Inspección de luces',
  MaintenanceType.otroItv: 'Otro (ITV)',
  // Otro
  MaintenanceType.mantenimientoGeneral: 'Mantenimiento general',
  MaintenanceType.reparacionGeneral: 'Reparación general',
  MaintenanceType.otro: 'Otro',
};

const Map<Posicion, String> etiquetasPosicion = {
  Posicion.delantera: 'Delantera',
  Posicion.trasera: 'Trasera',
  Posicion.izquierda: 'Izquierda',
  Posicion.derecha: 'Derecha',
  Posicion.delanteraIzquierda: 'Delantera izquierda',
  Posicion.delanteraDerecha: 'Delantera derecha',
  Posicion.traseraIzquierda: 'Trasera izquierda',
  Posicion.traseraDerecha: 'Trasera derecha',
  Posicion.ejeDelantero: 'Eje delantero',
  Posicion.ejeTrasero: 'Eje trasero',
};

const Map<MaintenanceOperationKind, String> etiquetasMaintenanceOperationKind =
    {
      MaintenanceOperationKind.preventivo: 'Preventivo',
      MaintenanceOperationKind.inspeccion: 'Inspección',
      MaintenanceOperationKind.reparacion: 'Reparación',
      MaintenanceOperationKind.sustitucion: 'Sustitución',
      MaintenanceOperationKind.otro: 'Otro',
    };

class MaintenanceFormScreen extends ConsumerStatefulWidget {
  final int vehicleId;
  final MaintenanceSchedule? schedule;

  const MaintenanceFormScreen({
    super.key,
    required this.vehicleId,
    this.schedule,
  });

  @override
  ConsumerState<MaintenanceFormScreen> createState() =>
      _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends ConsumerState<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombre;
  late final TextEditingController _intervalKm;
  late final TextEditingController _intervalMeses;
  late final TextEditingController _avisoKm;
  late final TextEditingController _avisoDias;

  /// Datos de siembra: solo tienen sentido al crear. Al editar ni se
  /// muestran ni se leen, porque a esas alturas ya habrá registros reales.
  late final TextEditingController _siembraKm;
  DateTime? _siembraFecha;

  late MaintenanceCategory _categoria;
  late bool _silenciado;

  MaintenanceType? _tipo;
  Posicion? _posicion;

  /// Si `_nombre` se regenera solo cuando cambian Tipo o Posición, o si el
  /// usuario ya lo editó a mano y por tanto se deja quieto para siempre.
  late bool _nombreAutogenerado;

  /// Mientras es `true`, el listener de `_nombre` (`_alEditarNombre`) no
  /// reacciona: distingue una reescritura programática hecha por
  /// `_regenerarNombreAutomatico` de una edición real del usuario, que es
  /// la única que debe apagar `_nombreAutogenerado`.
  bool _escribiendoNombreAutomatico = false;

  bool _guardando = false;

  /// Si se está borrando el mantenimiento (independiente de _guardando: no
  /// pueden solaparse, pero necesitan su propio texto de error y su propio
  /// guardado de reentrada).
  bool _borrando = false;

  bool get _esEdicion => widget.schedule != null;

  bool get _ocupado => _guardando || _borrando;

  @override
  void initState() {
    super.initState();
    final s = widget.schedule;
    _nombre = TextEditingController(text: s?.nombre ?? '');
    _intervalKm = TextEditingController(text: s?.intervalKm?.toString() ?? '');
    _intervalMeses = TextEditingController(
      text: s?.intervalMeses?.toString() ?? '',
    );
    _avisoKm = TextEditingController(text: s?.avisoKm?.toString() ?? '');
    _avisoDias = TextEditingController(text: s?.avisoDias?.toString() ?? '');
    _siembraKm = TextEditingController();
    _categoria = s?.categoria ?? MaintenanceCategory.motor;
    _silenciado = s?.silenciado ?? false;
    _tipo = s?.tipo;
    _posicion = s?.posicion;
    // En creación empieza en true: no hay nombre que proteger todavía, así
    // que elegir Tipo o Posición ya debe rellenarlo.
    _nombreAutogenerado = s?.nombreAutogenerado ?? true;
    _nombre.addListener(_alEditarNombre);
  }

  @override
  void dispose() {
    for (final c in [
      _nombre,
      _intervalKm,
      _intervalMeses,
      _avisoKm,
      _avisoDias,
      _siembraKm,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Válido si está vacío o es un entero mayor que 0. Para los intervalos:
  /// un intervalo de 0 no tiene sentido, siempre estaría vencido.
  String? _enteroPositivoOpcional(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = int.tryParse(v.trim());
    if (n == null || n <= 0) return 'Tiene que ser mayor que 0';
    return null;
  }

  /// Válido si está vacío o es un entero mayor o igual que 0. Para
  /// kilómetros y márgenes de aviso, que sí admiten el cero.
  String? _enteroNoNegativoOpcional(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = int.tryParse(v.trim());
    if (n == null || n < 0) return 'No puede ser negativo';
    return null;
  }

  // Un mantenimiento sin ningún intervalo no se puede calcular nunca: no
  // habría forma de saber cuándo toca. En vez de descubrirlo con un
  // SnackBar tras pulsar Guardar, el error se ancla al propio campo —igual
  // que el resto de validaciones del formulario— y se repite en los dos
  // campos cuando ambos están vacíos, para que sea imposible pasarlo por
  // alto sin importar cuál mires primero.
  String? _validarIntervalKm(String? v) {
    final error = _enteroPositivoOpcional(v);
    if (error != null) return error;
    if ((v == null || v.trim().isEmpty) && _intervalMeses.text.trim().isEmpty) {
      return 'Indica un intervalo por km o por meses';
    }
    return null;
  }

  String? _validarIntervalMeses(String? v) {
    final error = _enteroPositivoOpcional(v);
    if (error != null) return error;
    if ((v == null || v.trim().isEmpty) && _intervalKm.text.trim().isEmpty) {
      return 'Indica un intervalo por km o por meses';
    }
    return null;
  }

  /// Reacciona a cualquier cambio de `_nombre.text`. Solo apaga
  /// `_nombreAutogenerado` cuando el cambio lo hizo el usuario tecleando:
  /// mientras `_regenerarNombreAutomatico` reescribe el campo por su
  /// cuenta, `_escribiendoNombreAutomatico` está a `true` y este listener
  /// no hace nada.
  void _alEditarNombre() {
    if (_escribiendoNombreAutomatico || !_nombreAutogenerado) return;
    setState(() => _nombreAutogenerado = false);
  }

  /// Reescribe `_nombre` a partir de Tipo y Posición, solo si el usuario
  /// no lo ha editado a mano todavía (`_nombreAutogenerado`). Sin Tipo no
  /// hay nada que autogenerar, así que deja el campo vacío.
  void _regenerarNombreAutomatico() {
    if (!_nombreAutogenerado) return;
    final tipo = _tipo;
    var nuevoNombre = '';
    if (tipo != null) {
      nuevoNombre = etiquetasMaintenanceType[tipo]!;
      final posicion = _posicion;
      if (posicion != null) {
        nuevoNombre = '$nuevoNombre, ${etiquetasPosicion[posicion]}';
      }
    }
    _escribiendoNombreAutomatico = true;
    _nombre.text = nuevoNombre;
    _escribiendoNombreAutomatico = false;
  }

  Future<void> _elegirSiembraFecha() async {
    final elegida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );
    if (elegida == null) return;
    if (!mounted) return;
    setState(() => _siembraFecha = elegida);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final siembraKmTexto = _siembraKm.text.trim();
    final haySiembraKm = siembraKmTexto.isNotEmpty;
    final haySiembraFecha = _siembraFecha != null;
    // Sembrar exige los dos datos a la vez: un MaintenanceRecord no se
    // puede guardar con la fecha o el kilometraje a medias.
    if (haySiembraKm != haySiembraFecha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Para registrar el último mantenimiento indica la fecha y los '
            'kilómetros, o deja los dos en blanco.',
          ),
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    final db = ref.read(databaseProvider);
    final dao = db.maintenanceDao;
    int? entero(TextEditingController c) {
      final texto = c.text.trim();
      return texto.isEmpty ? null : int.tryParse(texto);
    }

    try {
      if (_esEdicion) {
        await dao.actualizarSchedule(
          widget.schedule!.copyWith(
            nombre: _nombre.text.trim(),
            categoria: _categoria,
            intervalKm: Value(entero(_intervalKm)),
            intervalMeses: Value(entero(_intervalMeses)),
            avisoKm: Value(entero(_avisoKm)),
            avisoDias: Value(entero(_avisoDias)),
            silenciado: _silenciado,
            tipo: Value(_tipo),
            posicion: Value(_posicion),
            nombreAutogenerado: _nombreAutogenerado,
          ),
        );
      } else {
        // La creación del mantenimiento y la siembra de su historial van en
        // la misma transacción: si la segunda escritura fallara tras la
        // primera, se quedaría un mantenimiento sin forma de sembrarlo más
        // tarde, porque editar nunca vuelve a ofrecer estos campos.
        await db.transaction(() async {
          final id = await dao.insertarSchedule(
            MaintenanceSchedulesCompanion.insert(
              vehicleId: widget.vehicleId,
              nombre: _nombre.text.trim(),
              categoria: _categoria,
              intervalKm: Value(entero(_intervalKm)),
              intervalMeses: Value(entero(_intervalMeses)),
              avisoKm: Value(entero(_avisoKm)),
              avisoDias: Value(entero(_avisoDias)),
              silenciado: Value(_silenciado),
              tipo: Value(_tipo),
              posicion: Value(_posicion),
              nombreAutogenerado: Value(_nombreAutogenerado),
            ),
          );

          if (haySiembraKm && haySiembraFecha) {
            await dao.insertarRecord(
              MaintenanceRecordsCompanion.insert(
                vehicleId: widget.vehicleId,
                scheduleId: Value(id),
                fecha: _siembraFecha!,
                km: int.parse(siembraKmTexto),
                esSembrado: const Value(true),
              ),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error al guardar el mantenimiento: $e');
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se ha podido guardar el mantenimiento. Inténtalo de nuevo.',
          ),
        ),
      );
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmarBorrar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar mantenimiento'),
        content: const Text(
          'Deja de calcularse y de aparecer en la ficha del vehículo. Los '
          'registros que ya tenga guardados no se borran, pero quedan '
          'sueltos, sin este mantenimiento al que pertenecían.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    if (!mounted) return;
    await _borrar();
  }

  Future<void> _borrar() async {
    final schedule = widget.schedule;
    if (schedule == null) return;
    setState(() => _borrando = true);

    final dao = ref.read(databaseProvider).maintenanceDao;
    try {
      await dao.borrarSchedule(schedule.id);
    } catch (e) {
      debugPrint('Error al borrar el mantenimiento: $e');
      if (!mounted) return;
      setState(() => _borrando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se ha podido borrar el mantenimiento. Inténtalo de nuevo.',
          ),
        ),
      );
      return;
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _esEdicion ? 'Editar mantenimiento' : 'Nuevo mantenimiento',
        ),
        actions: [
          if (_esEdicion)
            IconButton(
              onPressed: _ocupado ? null : _confirmarBorrar,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Borrar mantenimiento',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        // Los dos intervalos se validan en pareja: si no, al rellenar uno de
        // ellos el error del otro seguiría en pantalla hasta volver a pulsar
        // Guardar, diciendo que falta algo que ya se ha corregido.
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Aceite y filtro',
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Indica un nombre' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MaintenanceCategory>(
              initialValue: _categoria,
              decoration: InputDecoration(
                labelText: 'Categoría',
                helperText: _tipo != null
                    ? 'La marca el tipo elegido debajo'
                    : null,
              ),
              items: MaintenanceCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(etiquetasCategoria[c]!),
                    ),
                  )
                  .toList(),
              // Con un Tipo elegido, la categoría la marca
              // `tipo.categoria`: deshabilitado en vez de libre, para que
              // nunca puedan guardarse desincronizados.
              onChanged: _tipo == null
                  ? (c) => setState(() => _categoria = c!)
                  : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MaintenanceType?>(
              initialValue: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: [
                const DropdownMenuItem<MaintenanceType?>(
                  value: null,
                  child: Text('Sin tipo concreto'),
                ),
                ...MaintenanceType.values
                    .where((t) => t.categoria == _categoria)
                    .map(
                      (t) => DropdownMenuItem<MaintenanceType?>(
                        value: t,
                        child: Text(etiquetasMaintenanceType[t]!),
                      ),
                    ),
              ],
              onChanged: (t) {
                setState(() {
                  _tipo = t;
                  if (t != null) _categoria = t.categoria;
                  if (t == null || !t.admitePosicion) _posicion = null;
                });
                _regenerarNombreAutomatico();
              },
            ),
            if (_tipo?.admitePosicion == true) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<Posicion?>(
                initialValue: _posicion,
                decoration: const InputDecoration(labelText: 'Posición'),
                items: [
                  const DropdownMenuItem<Posicion?>(
                    value: null,
                    child: Text('Sin posición concreta'),
                  ),
                  ...Posicion.values.map(
                    (p) => DropdownMenuItem<Posicion?>(
                      value: p,
                      child: Text(etiquetasPosicion[p]!),
                    ),
                  ),
                ],
                onChanged: (p) {
                  setState(() => _posicion = p);
                  _regenerarNombreAutomatico();
                },
              ),
            ],
            const SizedBox(height: 20),
            Text('Intervalo', style: tema.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Indica al menos uno de los dos. Con los dos rellenos, avisa '
              'el que llegue antes.',
              style: tema.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _intervalKm,
                    decoration: const InputDecoration(labelText: 'Cada (km)'),
                    keyboardType: TextInputType.number,
                    validator: _validarIntervalKm,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _intervalMeses,
                    decoration: const InputDecoration(
                      labelText: 'Cada (meses)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validarIntervalMeses,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Márgenes de aviso propios', style: tema.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Opcionales. En blanco, se usan los márgenes generales de '
              'Ajustes.',
              style: tema.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _avisoKm,
                    decoration: const InputDecoration(
                      labelText: 'Aviso (km)',
                      hintText: 'General',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _enteroNoNegativoOpcional,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _avisoDias,
                    decoration: const InputDecoration(
                      labelText: 'Aviso (días)',
                      hintText: 'General',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _enteroNoNegativoOpcional,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Silenciado'),
              subtitle: const Text(
                'Sigue calculando su estado, pero no genera avisos.',
              ),
              value: _silenciado,
              onChanged: (v) => setState(() => _silenciado = v),
            ),
            if (!_esEdicion) ...[
              const SizedBox(height: 12),
              Text('Último realizado', style: tema.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text(
                'Opcional. Si ya se hizo antes de empezar a usar la app, '
                'indícalo para poder calcular el próximo vencimiento.',
                style: tema.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha'),
                subtitle: Text(
                  _siembraFecha == null
                      ? 'Sin indicar'
                      : formatearFecha(_siembraFecha!),
                ),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _elegirSiembraFecha,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _siembraKm,
                decoration: const InputDecoration(labelText: 'Kilómetros'),
                keyboardType: TextInputType.number,
                validator: _enteroNoNegativoOpcional,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _ocupado ? null : _guardar,
              child: Text(
                _esEdicion ? 'Guardar cambios' : 'Crear mantenimiento',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
