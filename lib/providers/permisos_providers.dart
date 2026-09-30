import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/permisos.dart';

final servicioPermisosProvider = Provider<ServicioPermisos>(
  (ref) => PermisosDelSistema(),
);

final permisoNotificacionesProvider = FutureProvider<bool>((ref) {
  return ref.watch(servicioPermisosProvider).tienePermisoNotificaciones();
});

final permisoAlarmasExactasProvider = FutureProvider<bool>((ref) {
  return ref.watch(servicioPermisosProvider).puedeProgramarAlarmasExactas();
});

final optimizacionBateriaIgnoradaProvider = FutureProvider<bool>((ref) {
  return ref.watch(servicioPermisosProvider).tieneBateriaOptimizadaIgnorada();
});
