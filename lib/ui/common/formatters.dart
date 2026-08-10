import 'package:intl/intl.dart';

final _formatoKm = NumberFormat.decimalPattern('es_ES');
final _formatoFecha = DateFormat('dd/MM/yyyy', 'es_ES');

/// 142350 → "142.350 km"
String formatearKm(int km) => '${_formatoKm.format(km)} km';

/// 9 de agosto de 2026 → "09/08/2026"
String formatearFecha(DateTime fecha) => _formatoFecha.format(fecha);
