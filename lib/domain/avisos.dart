/// Lo que el cálculo de avisos necesita saber de un mantenimiento. No es una
/// fila de Drift ni un [Vencimiento] entero: solo las dos fechas en que puede
/// vencer y los márgenes con los que avisar, para que el dominio no dependa
/// de la capa de datos.
///
/// Quien construye estos datos (el provider) ya ha descartado los
/// mantenimientos inactivos y los silenciados.
class DatosAviso {
  final String nombre;

  /// Cuándo vence por tiempo. Nula si el mantenimiento no va por fecha.
  final DateTime? proximaFecha;

  /// Cuándo se alcanzarán sus kilómetros al ritmo actual. Nula si no va por
  /// kilómetros, o si el coche está parado y no se alcanzarían nunca.
  final DateTime? fechaEstimadaPorKm;

  final int margenKm;
  final int margenDias;

  const DatosAviso({
    required this.nombre,
    required this.margenKm,
    required this.margenDias,
    this.proximaFecha,
    this.fechaEstimadaPorKm,
  });
}

/// Qué motiva un aviso: distingue el recordatorio de kilometraje (que no es
/// un mantenimiento) y, entre los mantenimientos, si ya está vencido o solo
/// ha entrado en su margen de aviso. El texto que llega al usuario depende
/// de esto: mentir sobre cuál de los tres es el motivo real fue justo el
/// defecto que esto corrige.
enum TipoAviso {
  recordatorioLectura,
  mantenimientoVencido,
  mantenimientoEnMargen,
}

/// Un motivo concreto dentro de un [AvisoProgramado]: un nombre y de qué
/// tipo es.
class NombreAviso {
  final String nombre;
  final TipoAviso tipo;

  const NombreAviso({required this.nombre, required this.tipo});
}

/// Una notificación a programar: un día concreto y los mantenimientos que la
/// motivan. Varios mantenimientos que caen el mismo día comparten aviso, para
/// no disparar una ráfaga de notificaciones que se acabe ignorando.
class AvisoProgramado {
  final DateTime fecha;
  final List<NombreAviso> nombres;

  const AvisoProgramado({required this.fecha, required this.nombres});
}

/// Convierte los vencimientos de un vehículo en la lista de avisos a
/// programar, ordenada por fecha.
///
/// Cada mantenimiento puede generar hasta dos: uno al entrar en su margen de
/// aviso y otro al vencer. Solo se devuelven días dentro del [horizonte] que
/// no hayan quedado ya atrás: un aviso de hoy se conserva (aunque la hora a
/// la que se entrega, más tarde, ya haya pasado — eso lo decide quien
/// programa la notificación, no el cálculo del día), y lo que venció ayer o
/// antes no se notifica porque ya se ve en la ficha del vehículo.
List<AvisoProgramado> calcularAvisos({
  required List<DatosAviso> mantenimientos,
  required double kmPorDia,
  required DateTime ahora,
  required DateTime horizonte,
}) {
  final hoy = DateTime(ahora.year, ahora.month, ahora.day);
  final finHorizonte = DateTime(horizonte.year, horizonte.month, horizonte.day);

  final porDia = <DateTime, List<NombreAviso>>{};

  void anotar(DateTime? fecha, String nombre, TipoAviso tipo) {
    if (fecha == null) return;
    final dia = DateTime(fecha.year, fecha.month, fecha.day);
    if (dia.isBefore(hoy) || dia.isAfter(finHorizonte)) return;
    final nombres = porDia.putIfAbsent(dia, () => []);
    // Si el margen de aviso es 0, la fecha de atención coincide con la de
    // vencimiento: sin esta guarda, el mismo mantenimiento se anotaría dos
    // veces ese día. Se anota primero el vencimiento (más abajo), así que
    // cuando colisionan gana el tipo más preciso: "vencido", no "en margen".
    if (!nombres.any((n) => n.nombre == nombre)) {
      nombres.add(NombreAviso(nombre: nombre, tipo: tipo));
    }
  }

  for (final m in mantenimientos) {
    // El vencimiento efectivo es el que llegue antes de las dos vías.
    final vencimiento = _laMasTemprana(m.proximaFecha, m.fechaEstimadaPorKm);

    // Cada vía entra en su margen por su cuenta, y el mantenimiento pasa a
    // "atención" en cuanto lo hace cualquiera de las dos. Se resta el
    // margen con aritmética de calendario (día - N), no con
    // Duration(days: N): restar una duración son 24 horas absolutas, y
    // cruzando un cambio de horario eso no siempre son N días naturales.
    final atencionPorFecha = m.proximaFecha == null
        ? null
        : DateTime(
            m.proximaFecha!.year,
            m.proximaFecha!.month,
            m.proximaFecha!.day - m.margenDias,
          );
    // Con el coche parado no se puede traducir un margen de kilómetros a
    // días, así que esa vía no aporta fecha de atención.
    final margenDiasPorKm = (m.fechaEstimadaPorKm == null || kmPorDia <= 0)
        ? null
        : (m.margenKm / kmPorDia).round();
    final atencionPorKm = margenDiasPorKm == null
        ? null
        : DateTime(
            m.fechaEstimadaPorKm!.year,
            m.fechaEstimadaPorKm!.month,
            m.fechaEstimadaPorKm!.day - margenDiasPorKm,
          );

    // Se anota primero el vencimiento: si coincide con la fecha de
    // atención (margen de 0 días), la guarda de "anotar" hace que gane el
    // tipo "vencido", que es el correcto ese día.
    anotar(vencimiento, m.nombre, TipoAviso.mantenimientoVencido);
    anotar(
      _laMasTemprana(atencionPorFecha, atencionPorKm),
      m.nombre,
      TipoAviso.mantenimientoEnMargen,
    );
  }

  final dias = porDia.keys.toList()..sort();

  return [
    for (final dia in dias) AvisoProgramado(fecha: dia, nombres: porDia[dia]!),
  ];
}

/// El texto de la notificación para un [AvisoProgramado]. Vive en el
/// dominio, no en el servicio de notificaciones, porque es lógica pura
/// derivada solo de los datos del aviso: no depende del plugin ni de nada
/// que no se pueda probar sin Flutter.
///
/// Compone hasta tres frases, una por cada tipo de motivo presente ese día,
/// para no mezclar mensajes falsos: un recordatorio de kilometraje no habla
/// de mantenimientos, y un vencimiento no dice "necesita atención" (eso es
/// solo para lo que aún está dentro de margen).
String cuerpoDeAviso(AvisoProgramado aviso) {
  final vencidos = _nombresDeTipo(aviso, TipoAviso.mantenimientoVencido);
  final enMargen = _nombresDeTipo(aviso, TipoAviso.mantenimientoEnMargen);
  final hayRecordatorio = aviso.nombres.any(
    (n) => n.tipo == TipoAviso.recordatorioLectura,
  );

  final partes = <String>[
    if (vencidos.isNotEmpty) _frase(vencidos, 'ha vencido', 'han vencido'),
    if (enMargen.isNotEmpty)
      _frase(enMargen, 'necesita atención', 'necesitan atención'),
    if (hayRecordatorio) 'Hace tiempo que no actualizas el kilometraje',
  ];

  return partes.join('. ');
}

List<String> _nombresDeTipo(AvisoProgramado aviso, TipoAviso tipo) => [
  for (final n in aviso.nombres)
    if (n.tipo == tipo) n.nombre,
];

String _frase(List<String> nombres, String singular, String plural) {
  final cuantos = nombres.length;
  final cabecera = cuantos == 1
      ? '1 mantenimiento $singular'
      : '$cuantos mantenimientos $plural';
  return '$cabecera: ${nombres.join(', ')}';
}

DateTime? _laMasTemprana(DateTime? a, DateTime? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a.isBefore(b) ? a : b;
}
