import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/notificaciones_providers.dart';
import '../../providers/permisos_providers.dart';
import '../expenses/expenses_screen.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _indice = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializarAvisos());
  }

  /// Un fallo del plugin de notificaciones no debe impedir que la
  /// aplicación se abra: se intenta la reprogramación aunque el usuario
  /// deniegue el permiso, y cualquier excepción queda contenida aquí.
  Future<void> _inicializarAvisos() async {
    try {
      final servicio = ref.read(servicioNotificacionesProvider);
      await servicio.inicializar();
      await servicio.pedirPermiso();
      ref.invalidate(permisoNotificacionesProvider);
      final _ = await ref.refresh(reprogramacionDeAvisosProvider.future);
    } catch (e) {
      debugPrint('No se pudieron inicializar los avisos: $e');
    }
  }

  static const _pantallas = [
    HomeScreen(),
    HistoryScreen(),
    ExpensesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indice, children: _pantallas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.euro_outlined),
            selectedIcon: Icon(Icons.euro),
            label: 'Gastos',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
