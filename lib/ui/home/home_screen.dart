import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../common/empty_state.dart';
import '../vehicle/vehicle_form_screen.dart';
import 'vehicle_card.dart';

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

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: lista.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, i) => VehicleCard(vehiculo: lista[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const VehicleFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Vehículo'),
      ),
    );
  }
}
