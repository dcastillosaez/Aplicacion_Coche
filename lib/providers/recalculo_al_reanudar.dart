import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mantenimiento_providers.dart';
import 'notificaciones_providers.dart';
import 'providers.dart';

/// Providers que se recalculan cada vez que la app vuelve a primer plano,
/// tal y como pide el diseño: "se recalcula todo... al abrir la
/// aplicación". En la fase 2, el motor de vencimientos se añade aquí.
final providersARecalcularAlReanudar = <ProviderOrFamily>[
  ritmoUsoProvider,
  vencimientosProvider,
  estadoVehiculoProvider,
];

/// Widget sin apariencia propia que observa el ciclo de vida de la app e
/// invalida [providersARecalcularAlReanudar] cada vez que vuelve a primer
/// plano, para que no se queden con datos calculados antes de pasar un
/// tiempo en segundo plano.
class RecalculoAlReanudar extends ConsumerStatefulWidget {
  final Widget child;

  const RecalculoAlReanudar({super.key, required this.child});

  @override
  ConsumerState<RecalculoAlReanudar> createState() =>
      _RecalculoAlReanudarState();
}

class _RecalculoAlReanudarState extends ConsumerState<RecalculoAlReanudar>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      for (final provider in providersARecalcularAlReanudar) {
        ref.invalidate(provider);
      }
      // Invalidar y leer a continuación (dentro de reprogramarAvisos, vía
      // ref.refresh) da los valores ya recalculados. Un fallo del plugin no
      // debe interrumpir el ciclo de vida de la app, así que se contiene
      // aquí.
      ref.refresh(reprogramacionDeAvisosProvider.future).catchError((Object e) {
        debugPrint('No se pudieron reprogramar los avisos: $e');
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
