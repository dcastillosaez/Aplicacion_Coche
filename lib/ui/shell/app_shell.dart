import 'package:flutter/material.dart';

import '../expenses/expenses_screen.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _indice = 0;

  static const _pantallas = [
    HomeScreen(),
    HistoryScreen(),
    ExpensesScreen(),
    _PendienteFase2(
      titulo: 'Ajustes',
      descripcion: 'Los ajustes llegan en la próxima fase.',
    ),
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

class _PendienteFase2 extends StatelessWidget {
  final String titulo;
  final String descripcion;

  const _PendienteFase2({required this.titulo, required this.descripcion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(descripcion, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
