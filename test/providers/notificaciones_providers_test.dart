import 'package:car_care/data/database.dart';
import 'package:car_care/data/tables/vehicles.dart';
import 'package:car_care/domain/avisos.dart';
import 'package:car_care/domain/usage_rate.dart';
import 'package:car_care/providers/mantenimiento_providers.dart';
import 'package:car_care/providers/notificaciones_providers.dart';
import 'package:car_care/providers/providers.dart';
import 'package:car_care/services/notificaciones.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Doble de prueba: se limita a apuntar qué se le pidió programar.
class ServicioFalso implements ServicioNotificaciones {
  List<AvisoDeVehiculo> programados = [];
  int vecesProgramado = 0;

  @override
  Future<void> inicializar() async {}

  @override
  Future<bool> pedirPermiso() async => true;

  @override
  Future<void> programarAvisos(List<AvisoDeVehiculo> avisos) async {
    programados = avisos;
    vecesProgramado++;
  }
}

Vehicle _vehiculo() => Vehicle(
  id: 1,
  marca: 'Seat',
  modelo: 'León',
  combustible: FuelType.diesel,
  creadoEn: DateTime(2026, 1, 1),
  archivado: false,
);

Setting _ajustesDePrueba() => const Setting(
  id: 1,
  avisoKmPorDefecto: 1000,
  avisoDiasPorDefecto: 30,
  diasRecordatorioLectura: 15,
  tema: 'automatico',
);

/// `reprogramarAvisos` recibe un `Ref`, y un `ProviderContainer` no lo es.
/// En vez de retorcer la firma de la función de producción para que encaje
/// en el test, se envuelve en un provider de usar y tirar: leerlo da un
/// `Ref` de verdad, del mismo contenedor con las sobrescrituras aplicadas.
final _disparador = FutureProvider((ref) => reprogramarAvisos(ref));

void main() {
  test('sin vehículos no se programa ningún aviso', () async {
    final servicio = ServicioFalso();
    final container = ProviderContainer(
      overrides: [
        servicioNotificacionesProvider.overrideWithValue(servicio),
        vehiculosProvider.overrideWith((ref) => Stream.value([])),
        ajustesProvider.overrideWith((ref) => Stream.value(_ajustesDePrueba())),
      ],
    );
    addTearDown(container.dispose);

    await container.read(_disparador.future);

    expect(servicio.vecesProgramado, 1);
    expect(servicio.programados, isEmpty);
  });

  test(
    'un vehículo sin lecturas recibe recordatorios de kilometraje',
    () async {
      final servicio = ServicioFalso();
      final container = ProviderContainer(
        overrides: [
          servicioNotificacionesProvider.overrideWithValue(servicio),
          vehiculosProvider.overrideWith((ref) => Stream.value([_vehiculo()])),
          ultimaLecturaProvider(1).overrideWith((ref) => Stream.value(null)),
          vencimientosProvider(1).overrideWith((ref) => []),
          ajustesProvider.overrideWith(
            (ref) => Stream.value(_ajustesDePrueba()),
          ),
          ritmoUsoProvider(1).overrideWith(
            (ref) => const UsageRateResult(kmPorDia: 50, esPorDefecto: false),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(_disparador.future);

      expect(servicio.programados, hasLength(kRecordatoriosDeLectura));
      final nombres = servicio.programados.first.aviso.nombres;
      expect(nombres, hasLength(1));
      expect(nombres.single.nombre, 'Actualiza el kilometraje');
      expect(nombres.single.tipo, TipoAviso.recordatorioLectura);
    },
  );

  test(
    'con diasRecordatorioLectura en 0 no se cuelga y no genera recordatorios',
    () async {
      final servicio = ServicioFalso();
      final container = ProviderContainer(
        overrides: [
          servicioNotificacionesProvider.overrideWithValue(servicio),
          vehiculosProvider.overrideWith((ref) => Stream.value([_vehiculo()])),
          ultimaLecturaProvider(1).overrideWith((ref) => Stream.value(null)),
          vencimientosProvider(1).overrideWith((ref) => []),
          ajustesProvider.overrideWith(
            (ref) => Stream.value(
              const Setting(
                id: 1,
                avisoKmPorDefecto: 1000,
                avisoDiasPorDefecto: 30,
                diasRecordatorioLectura: 0,
                tema: 'automatico',
              ),
            ),
          ),
          ritmoUsoProvider(1).overrideWith(
            (ref) => const UsageRateResult(kmPorDia: 50, esPorDefecto: false),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(_disparador.future);

      expect(servicio.programados, isEmpty);
    },
    // El timeout es una red parcial, no una garantía: si la guarda contra
    // valores no positivos fallara, el bucle de _recordatoriosDeLectura es
    // síncrono y bloquearía el isolate, así que el temporizador en el que se
    // apoya este timeout nunca llegaría a dispararse y la suite se quedaría
    // colgada. Se deja porque no cuesta nada, pero quien toque esa guarda no
    // debe confiar en que el test avise por sí solo.
    timeout: const Timeout(Duration(seconds: 5)),
  );
}
