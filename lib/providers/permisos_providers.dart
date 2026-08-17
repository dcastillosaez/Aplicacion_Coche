import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/permisos.dart';

final servicioPermisosProvider = Provider<ServicioPermisos>(
  (ref) => PermisosDelSistema(),
);

final permisoNotificacionesProvider = FutureProvider<bool>((ref) {
  return ref.watch(servicioPermisosProvider).tienePermisoNotificaciones();
});
