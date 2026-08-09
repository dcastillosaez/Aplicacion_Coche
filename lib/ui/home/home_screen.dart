import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../common/empty_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiculos = ref.watch(vehiculosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis vehículos')),
      body: vehiculos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error al cargar: $e')),
        data: (lista) {
          if (lista.isEmpty) {
            return const EmptyState(
              icono: Icons.directions_car_outlined,
              titulo: 'Todavía no hay vehículos',
              descripcion:
                  'Añade tu primer coche para empezar a llevar su kilometraje.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lista.length,
            itemBuilder: (context, i) => ListTile(
              title: Text('${lista[i].marca} ${lista[i].modelo}'),
            ),
          );
        },
      ),
    );
  }
}
