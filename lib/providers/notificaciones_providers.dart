import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/avisos.dart';
import '../services/notificaciones.dart';
import 'mantenimiento_providers.dart';
import 'providers.dart';

/// Días de avisos que se programan por adelantado. Un año: suficiente para
/// que sigan llegando aunque la aplicación pase meses sin abrirse.
const int kDiasHorizonteAvisos = 365;

/// Cuántos recordatorios de lectura de kilometraje se programan seguidos.
/// Con el valor por defecto de 15 días son dos meses de cobertura: bastante
/// para que uno llegue aunque se ignore el anterior, sin llenar el móvil de
/// avisos si la aplicación se abandona.
const int kRecordatoriosDeLectura = 4;

final servicioNotificacionesProvider = Provider<ServicioNotificaciones>(
  (ref) => NotificacionesLocales(),
);

/// Punto de entrada para disparar [reprogramarAvisos] desde un widget.
///
/// `reprogramarAvisos` recibe un [Ref] de verdad, y un widget solo tiene un
/// `WidgetRef` (no es lo mismo: `WidgetRef` no implementa `Ref`). Se envuelve
/// en este provider de usar y tirar, y se lee con
/// `ref.refresh(reprogramacionDeAvisosProvider.future)` para forzar el
/// recálculo en cada llamada en vez de quedarse con el resultado cacheado de
/// la primera vez.
final reprogramacionDeAvisosProvider = FutureProvider<void>(reprogramarAvisos);

/// Dispara la reprogramación de avisos sin bloquear la interfaz.
///
/// La spec pide reprogramar tras guardar cualquier vehículo, lectura de
/// kilometraje, mantenimiento o registro, además de al arrancar y al volver
/// a primer plano (ver [RecalculoAlReanudar]). Se llama desde cada pantalla
/// de guardado sin `await`: lo importante es que el guardado en sí no
/// dependa de que el plugin de notificaciones funcione, así que un fallo
/// aquí solo se registra por `debugPrint`.
void dispararReprogramacionDeAvisos(WidgetRef ref) {
  ref.refresh(reprogramacionDeAvisosProvider.future).catchError((Object e) {
    debugPrint('No se pudieron reprogramar los avisos: $e');
  });
}

/// Recalcula todos los avisos de todos los vehículos y los reprograma desde
/// cero, cancelando lo anterior.
///
/// Se cancela y se reprograma entero, en lugar de llevar la cuenta de qué
/// notificación es de qué mantenimiento, porque evita toda una clase de
/// errores: avisos huérfanos de mantenimientos borrados, o duplicados tras
/// editar un intervalo. Son unas pocas decenas de alarmas.
Future<void> reprogramarAvisos(Ref ref) async {
  final servicio = ref.read(servicioNotificacionesProvider);
  final ahora = DateTime.now();
  final horizonte = ahora.add(const Duration(days: kDiasHorizonteAvisos));

  final vehiculos = await ref.read(vehiculosProvider.future);
  final ajustes = await ref.read(ajustesProvider.future);

  final avisos = <AvisoDeVehiculo>[];

  for (final vehiculo in vehiculos) {
    final nombre = '${vehiculo.marca} ${vehiculo.modelo}';
    final mantenimientos = await ref.read(
      vencimientosProvider(vehiculo.id).future,
    );
    final ritmo = await ref.read(ritmoUsoProvider(vehiculo.id).future);

    final datos = [
      for (final m in mantenimientos)
        if (!m.schedule.silenciado)
          DatosAviso(
            nombre: m.schedule.nombre,
            proximaFecha: m.vencimiento.proximaFecha,
            fechaEstimadaPorKm: m.vencimiento.fechaEstimadaPorKm,
            margenKm: m.schedule.avisoKm ?? ajustes.avisoKmPorDefecto,
            margenDias: m.schedule.avisoDias ?? ajustes.avisoDiasPorDefecto,
          ),
    ];

    for (final aviso in calcularAvisos(
      mantenimientos: datos,
      kmPorDia: ritmo.kmPorDia,
      ahora: ahora,
      horizonte: horizonte,
    )) {
      avisos.add(AvisoDeVehiculo(nombreVehiculo: nombre, aviso: aviso));
    }

    avisos.addAll(
      await _recordatoriosDeLectura(
        ref,
        vehiculo.id,
        nombre,
        ajustes.diasRecordatorioLectura,
        ahora,
        horizonte,
      ),
    );
  }

  avisos.sort((a, b) => a.aviso.fecha.compareTo(b.aviso.fecha));
  await servicio.programarAvisos(avisos);
}

/// Recordatorios para introducir el kilometraje.
///
/// No es un adorno: los avisos por kilómetros se calculan proyectando el
/// ritmo de uso desde la última lectura, así que cuanto más vieja es esa
/// lectura, peor la estimación. Esto es lo que mantiene útil a la mitad del
/// sistema de avisos.
Future<List<AvisoDeVehiculo>> _recordatoriosDeLectura(
  Ref ref,
  int vehicleId,
  String nombreVehiculo,
  int cadaCuantosDias,
  DateTime ahora,
  DateTime horizonte,
) async {
  // Un valor no positivo haría que el bucle de abajo nunca avanzara de
  // fecha: hoy es inalcanzable desde la interfaz (avisoDiasPorDefecto no
  // tiene pantalla de Ajustes todavía), pero es una guarda barata contra
  // cuando la tenga.
  if (cadaCuantosDias <= 0) return const [];

  final ultima = await ref.read(ultimaLecturaProvider(vehicleId).future);
  // Sin ninguna lectura todavía, se cuenta desde hoy.
  var fecha = (ultima?.fecha ?? ahora).add(Duration(days: cadaCuantosDias));

  final recordatorios = <AvisoDeVehiculo>[];
  while (recordatorios.length < kRecordatoriosDeLectura) {
    if (fecha.isAfter(ahora) && !fecha.isAfter(horizonte)) {
      recordatorios.add(
        AvisoDeVehiculo(
          nombreVehiculo: nombreVehiculo,
          aviso: AvisoProgramado(
            fecha: DateTime(fecha.year, fecha.month, fecha.day),
            nombres: const [
              NombreAviso(
                nombre: 'Actualiza el kilometraje',
                tipo: TipoAviso.recordatorioLectura,
              ),
            ],
          ),
        ),
      );
    } else if (fecha.isAfter(horizonte)) {
      break;
    }
    fecha = fecha.add(Duration(days: cadaCuantosDias));
  }
  return recordatorios;
}
