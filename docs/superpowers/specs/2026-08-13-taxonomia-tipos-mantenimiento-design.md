# Taxonomía de tipos de mantenimiento: categoría, tipo, posición y kind

**Fecha:** 13 de agosto de 2026
**Estado:** diseño aprobado, pendiente de plan de implementación

## 1. La idea

Hoy un mantenimiento solo tiene `categoria` (un enum de 9 valores: motor, frenos, neumáticos...) y un `nombre` libre. Para distinguir "pastillas delanteras" de "pastillas traseras" no hay más remedio que meterlo en el propio texto del nombre, escrito a mano cada vez. No hay forma de preguntar "¿qué tipo de pieza es esto?" ni "¿en qué lado del coche?" sin analizar el texto.

Esta fase añade tres ejes nuevos, independientes entre sí:

- **Tipo** (`MaintenanceType`): qué es, exactamente — pastillas de freno, correa de distribución, turbo... Cada tipo pertenece a una única categoría.
- **Posición** (`Posicion`): dónde, cuando aplica — delantera, trasera, eje trasero... No todos los tipos la admiten.
- **Kind de la intervención** (`MaintenanceOperationKind`): qué se hizo realmente cada vez que se registra — reparación, sustitución, inspección. No es un dato del mantenimiento configurado, sino de cada registro: el turbo puede repararse un año y sustituirse el siguiente.

El objetivo declarado es preparar el terreno para la Fase 5/6 del roadmap (catálogo de piezas): `MaintenanceType` es lo que después se relacionará con `PartCompatibility`, y `Posicion` evita que el catálogo tenga que duplicar cada pieza por cada lado del coche.

## 2. Qué no cambia

- La arquitectura de tres capas y la regla de que `lib/domain/` no depende de Drift ni de Flutter.
- Los mantenimientos ya configurados en el dispositivo: `tipo`, `posicion` y `kind` nacen opcionales (`nullable`), sin ningún intento de adivinarlos a partir del nombre existente. Un mantenimiento sin tipo sigue funcionando exactamente igual que hoy.
- `MaintenanceCategory` no pierde ni renombra ningún valor existente (ver §3): solo se le añaden cinco categorías nuevas.
- El cálculo de vencimientos (`lib/domain/maintenance_due.dart`) no cambia: tipo/posición/kind son metadatos descriptivos, no entran en ninguna fórmula.

## 3. `MaintenanceCategory`: ampliación

Los 9 valores actuales se mantienen con su nombre exacto — no se pueden renombrar sin romper los datos ya guardados en el dispositivo (regla ya documentada en `CLAUDE.md` para este mismo enum). Se añaden 5 nuevos:

```dart
enum MaintenanceCategory {
  motor, frenos, neumaticos, electricidad, suspension,   // ya existían
  transmision, carroceria, itv, otro,                    // ya existían
  direccion, climatizacion, escapeEmisiones,              // nuevos
  habitaculo, seguridad,                                  // nuevos
}
```

## 4. `MaintenanceType`: catálogo completo

*Enhanced enum* de Dart 3: cada valor lleva sus propios metadatos, sin mapas paralelos que se puedan desincronizar.

```dart
enum MaintenanceType {
  aceiteMotor(
    categoria: MaintenanceCategory.motor,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: false,
  ),
  pastillasFreno(
    categoria: MaintenanceCategory.frenos,
    defaultKind: MaintenanceOperationKind.sustitucion,
    admitePosicion: true,
  ),
  // ... resto del catálogo, ver tabla completa más abajo
  ;

  final MaintenanceCategory categoria;
  final MaintenanceOperationKind defaultKind;
  final bool admitePosicion;

  const MaintenanceType({
    required this.categoria,
    required this.defaultKind,
    required this.admitePosicion,
  });
}
```

`defaultKind` es solo una **sugerencia** para rellenar el formulario de "Registrar realizado" — nunca se copia al mantenimiento configurado ni se recalcula sobre registros ya guardados (§7, condición 3).

### Resolución de solapamientos

La propuesta original tenía siete tipos que aparecían en más de una categoría. Regla aplicada: la categoría es el sistema funcional al que pertenece la pieza, no su ubicación física, y ningún tipo se duplica en dos ramas.

| Tipo | Aparecía en | Categoría final | Motivo |
|---|---|---|---|
| Turbo | Motor y Escape/Emisiones | **Motor** | Sobrealimentación del motor, no tratamiento de emisiones |
| EGR, DPF/FAP, Catalizador, Sonda lambda | Motor y Escape/Emisiones | **Escape y emisiones** | Su propósito principal es reducir emisiones |
| Filtro de habitáculo | Motor, Climatización y Habitáculo | **Habitáculo** | Confort del habitáculo, sin duplicar |
| Calentadores | Motor y Electricidad | **Motor** | Arranque en frío del propio motor diésel |
| ABS, sensores ABS | Frenos y Seguridad | **Frenos** | Es un sistema de frenada, aunque tenga electrónica |
| Airbags | Habitáculo y Seguridad | **Seguridad** | Junto al resto de seguridad pasiva |
| Termostato | Motor y Climatización | **Los dos, como tipos distintos** | Son piezas físicamente distintas: `termostato` (refrigeración del motor) y `termostatoClimatizacion` (aire acondicionado) |

### Catálogo completo

`defaultKind` abreviado: **S** = sustitución, **R** = reparación, **I** = inspección, **P** = preventivo, **O** = otro. `Pos.` = admite posición.

#### Motor (`motor`)

| Tipo | Kind | Pos. |
|---|---|---|
| aceiteMotor | S | |
| filtroAceite | S | |
| filtroAire | S | |
| filtroCombustible | S | |
| bujias | S | |
| calentadores | S | |
| bobinasEncendido | R | |
| correaDistribucion | S | |
| kitDistribucion | S | |
| cadenaDistribucion | S | |
| tensorDistribucion | S | |
| correaAuxiliar | S | |
| tensorCorreaAuxiliar | S | |
| bombaAgua | S | |
| refrigerante | S | |
| bombaAceite | R | |
| termostato | R | |
| radiador | R | |
| manguitosRefrigeracion | R | |
| soportesMotor | R | |
| admision | R | |
| inyectores | R | |
| sistemaCombustible | R | |
| limpiezaDescarbonizacion | P | |
| turbo | R | |
| otroMotor | O | |

#### Frenos (`frenos`)

| Tipo | Kind | Pos. |
|---|---|---|
| pastillasFreno | S | ✓ |
| discosFreno | S | ✓ |
| zapatasFreno | S | ✓ |
| tamboresFreno | S | ✓ |
| liquidoFrenos | S | |
| pinzasFreno | R | ✓ |
| latiguillosFreno | S | ✓ |
| sensorDesgasteFreno | S | ✓ |
| cilindroMaestro | R | |
| servofreno | R | |
| abs | R | |
| sensoresAbs | R | ✓ |
| frenoEstacionamiento | R | |
| frenoEstacionamientoElectrico | R | |
| otroFrenos | O | |

#### Neumáticos (`neumaticos`)

| Tipo | Kind | Pos. |
|---|---|---|
| neumatico | S | ✓ |
| rotacionNeumaticos | P | |
| equilibrado | I | |
| alineacion | I | |
| reparacionPinchazo | R | ✓ |
| valvulas | S | ✓ |
| tpms | R | ✓ |
| kitAntipinchazos | S | |
| ruedaRepuesto | I | |
| otroNeumaticos | O | |

*Nota: `alineacion` y `equilibrado` son operaciones/servicio más que inspecciones puras, pero con los cinco valores actuales de `MaintenanceOperationKind` es donde mejor encajan. Si en el futuro hace falta más precisión, valorar añadir `ajuste`/`servicio` — no se introduce ahora para no ampliar el modelo sin necesidad.*

#### Electricidad (`electricidad`)

| Tipo | Kind | Pos. |
|---|---|---|
| bateria | S | |
| alternador | R | |
| motorArranque | R | |
| fusibles | S | |
| reles | R | |
| bombillas | S | ✓ |
| iluminacionExterior | R | ✓ |
| iluminacionInterior | R | ✓ |
| sensorElectrico | R | |
| cableado | R | |
| sistemaCarga | R | |
| otroElectricidad | O | |

#### Suspensión (`suspension`)

| Tipo | Kind | Pos. |
|---|---|---|
| amortiguadores | S | ✓ |
| muelles | S | ✓ |
| copelas | S | ✓ |
| rodamientosCopela | S | ✓ |
| brazosSuspension | R | ✓ |
| silentblocks | S | ✓ |
| rotulasSuspension | S | ✓ |
| bieletasEstabilizadoras | S | ✓ |
| barraEstabilizadora | R | |
| rodamientosRueda | S | ✓ |
| mangueta | R | ✓ |
| suspensionNeumatica | R | ✓ |
| compresorSuspension | R | |
| otroSuspension | O | |

#### Dirección (`direccion`)

| Tipo | Kind | Pos. |
|---|---|---|
| direccionAsistida | R | |
| bombaDireccion | R | |
| cremallera | R | |
| terminalDireccion | S | ✓ |
| rotulaDireccion | S | ✓ |
| columnaDireccion | R | |
| volante | R | |
| direccionElectrica | R | |
| liquidoDireccion | S | |
| otroDireccion | O | |

#### Transmisión (`transmision`)

| Tipo | Kind | Pos. |
|---|---|---|
| embrague | S | |
| kitEmbrague | S | |
| volanteBimasa | S | |
| cajaCambiosManual | R | |
| cajaCambiosAutomatica | R | |
| aceiteCajaCambios | S | |
| filtroCajaCambios | S | |
| convertidorPar | R | |
| mecatronica | R | |
| palieres | S | ✓ |
| juntasHomocineticas | S | ✓ |
| arbolTransmision | R | |
| diferencial | R | |
| aceiteDiferencial | S | |
| transfer | R | |
| aceiteTransfer | S | |
| retenesTransmision | S | |
| otroTransmision | O | |

#### Climatización (`climatizacion`)

| Tipo | Kind | Pos. |
|---|---|---|
| aireAcondicionado | R | |
| gasRefrigeranteAc | S | |
| compresorAc | R | |
| condensadorAc | R | |
| evaporadorAc | R | |
| filtroDeshidratador | S | |
| ventiladorClimatizacion | R | |
| motorVentilador | R | |
| calefaccion | R | |
| radiadorCalefaccion | R | |
| termostatoClimatizacion | R | |
| otroClimatizacion | O | |

#### Escape y emisiones (`escapeEmisiones`)

| Tipo | Kind | Pos. |
|---|---|---|
| escape | R | |
| silencioso | S | |
| catalizador | R | |
| dpfFap | R | |
| egr | R | |
| sondaLambda | R | ✓ |
| sensorNox | R | ✓ |
| sensorTemperaturaEscape | R | |
| adblueScr | R | |
| inyectorAdblue | R | |
| depositoAdblue | R | |
| otroEscapeEmisiones | O | |

#### Carrocería (`carroceria`)

| Tipo | Kind | Pos. |
|---|---|---|
| paragolpes | R | ✓ |
| capo | R | |
| puertas | R | ✓ |
| porton | R | |
| aletas | R | ✓ |
| espejos | S | ✓ |
| elevalunas | R | ✓ |
| cerraduras | R | ✓ |
| bisagras | R | ✓ |
| escobillasLimpiaparabrisas | S | |
| brazosLimpiaparabrisas | R | |
| motorLimpiaparabrisas | R | |
| lunaParabrisas | R | |
| molduras | R | |
| juntasCarroceria | R | |
| techoSolar | R | |
| otroCarroceria | O | |

#### Habitáculo (`habitaculo`)

| Tipo | Kind | Pos. |
|---|---|---|
| filtroHabitaculo | S | |
| alfombrillas | S | |
| asientos | R | |
| salpicadero | R | |
| instrumentacion | R | |
| pantallaInfotainment | R | |
| altavoces | R | ✓ |
| otroHabitaculo | O | |

#### Seguridad (`seguridad`)

| Tipo | Kind | Pos. |
|---|---|---|
| airbag | R | ✓ |
| pretensorCinturon | R | ✓ |
| cinturonSeguridad | R | ✓ |
| esp | R | |
| sensorImpacto | R | |
| camaraSeguridad | R | ✓ |
| radarSeguridad | R | ✓ |
| adas | R | |
| sensorAparcamiento | R | ✓ |
| otroSeguridad | O | |

#### ITV / Inspección (`itv`)

| Tipo | Kind | Pos. |
|---|---|---|
| inspeccionItv | I | |
| preItv | I | |
| inspeccionGeneral | I | |
| inspeccionEmisiones | I | |
| inspeccionFrenos | I | |
| inspeccionNeumaticos | I | |
| inspeccionLuces | I | |
| otroItv | O | |

#### Otro (`otro`)

| Tipo | Kind | Pos. |
|---|---|---|
| mantenimientoGeneral | O | |
| reparacionGeneral | R | |
| otro | O | |

## 5. `MaintenanceOperationKind` y `Posicion`

```dart
enum MaintenanceOperationKind { preventivo, inspeccion, reparacion, sustitucion, otro }

enum Posicion {
  delantera, trasera, izquierda, derecha,
  delanteraIzquierda, delanteraDerecha, traseraIzquierda, traseraDerecha,
  ejeDelantero, ejeTrasero,
}
```

Renombrado desde el `MaintenanceTypeKind` de la propuesta inicial: describe **la intervención realizada**, no una propiedad fija del tipo — de ahí el nombre.

`Posicion` es metadato de localización, independiente del tipo: `tipo = pastillasFreno, posicion = delantera`, nunca `tipo = pastillasFrenoDelanteras`. Deja el catálogo limpio para cuando se conecte con la compatibilidad de piezas (Fase 5/6).

## 6. Dónde vive cada dato

| Campo | Tabla | Nullable | Motivo |
|---|---|---|---|
| `tipo` | `MaintenanceSchedules` | sí | Qué es — estable mientras el mantenimiento esté configurado así |
| `posicion` | `MaintenanceSchedules` | sí | Dónde — igual de estable que el tipo |
| `nombreAutogenerado` | `MaintenanceSchedules` | no (`bool`, default `false`) | Ver condición 2 más abajo |
| `kind` | `MaintenanceRecords` | sí | Qué se hizo — puede variar de un registro a otro del mismo mantenimiento |

`categoria` (ya existente, no nullable) se mantiene en `MaintenanceSchedules`: sigue siendo obligatoria porque un mantenimiento sin `tipo` (todos los ya configurados, y cualquiera nuevo que no use el catálogo) sigue necesitando clasificarse.

## 7. Cuatro condiciones de diseño, no negociables

Fijadas explícitamente para evitar problemas cuando esto se conecte con el catálogo de piezas:

1. **`MaintenanceType.categoria` es la única fuente de verdad.** No puede guardarse `categoria = motor` con `tipo = pastillasFreno`. En el formulario, si hay un tipo elegido, la categoría se deriva de él y deja de ser editable por separado; solo vuelve a ser libre si el tipo se deja sin elegir.
2. **Nunca se sobrescribe un nombre editado a mano.** El nombre se autogenera ("Pastillas de freno delanteras") solo mientras `nombreAutogenerado` sea `true`. En cuanto el usuario edita el campo Nombre directamente, `nombreAutogenerado` pasa a `false` y no vuelve a regenerarse aunque después cambie el tipo o la posición.
3. **`defaultKind` nunca contamina el historial.** Es una sugerencia que rellena el campo `kind` al abrir "Registrar realizado"; en cuanto el registro se guarda, `kind` queda fijo en ese valor para siempre. Si el catálogo cambia `defaultKind` de un tipo más adelante, los registros ya guardados no se alteran — es un valor copiado, no calculado al leer.
4. **`Posicion` no sustituye información técnica más específica.** Los diez valores de §5 bastan para esta fase; no se crean variantes por tipo (nada de `posicionFrenoDelantera` frente a `posicionSuspensionDelantera`). Si algún día hace falta algo más fino, es una ampliación de `Posicion`, no un tipo nuevo por combinación.

## 8. Migración

`schemaVersion` sube de 5 a 6. `MaintenanceSchedules` y `MaintenanceRecords` se crearon las dos en el paso `if (from < 3)` de una migración anterior — la misma trampa de `m.createTable()` ya documentada en `CLAUDE.md` aplica aquí exactamente igual que en la Fase 4 con `fuenteIntervalo`:

```dart
if (from >= 3 && from < 6) {
  await m.addColumn(maintenanceSchedules, maintenanceSchedules.tipo);
  await m.addColumn(maintenanceSchedules, maintenanceSchedules.posicion);
  await m.addColumn(maintenanceSchedules, maintenanceSchedules.nombreAutogenerado);
  await m.addColumn(maintenanceRecords, maintenanceRecords.kind);
}
```

El paso existente `if (from >= 3 && from < 5)` que añadió `fuenteIntervalo` (Fase 4) no se toca. Como en la Fase 4, hacen falta dos tests de migración: el caso realista (v5→v6 con un mantenimiento y un registro ya existentes, comprobando que sobreviven con los campos nuevos a `null`) y el caso trampa (saltar desde antes de la v3 directo a la v6 de un tirón, comprobando que no revienta con "duplicate column name").

## 9. Interfaz

Descrito por comportamiento, no dictado — mismo criterio que el resto de tareas de interfaz del proyecto.

**Formulario del mantenimiento** (`maintenance_form_screen.dart`): cascada Categoría → Tipo → Posición. El desplegable de Tipo se filtra por la Categoría elegida (o, si se elige un Tipo primero, la Categoría se deriva y deja de ser editable — condición 1). Posición solo aparece si `tipo.admitePosicion` es `true`. Al elegir Tipo o Posición, el campo Nombre se rellena solo mientras `nombreAutogenerado` sea `true` (condición 2); en cuanto el usuario lo edita a mano, deja de regenerarse.

**Registrar realizado** (`register_maintenance_sheet.dart`): un selector de `kind` junto a fecha y kilómetros, opcional, con `schedule.tipo?.defaultKind` como sugerencia inicial si el mantenimiento tiene tipo (condición 3). Si no tiene tipo, el selector aparece vacío, sin sugerencia.

**Plantillas** (`plantillas_mantenimiento.dart`): las ~15 plantillas actuales se enriquecen con `tipo`/`posicion` donde encajan de forma directa (p. ej. "Pastillas de freno delanteras" → `tipo: pastillasFreno, posicion: delantera`). Es una ampliación aditiva del propio fichero, sin cambiar su forma.

**Pantallas que ya muestran cada mantenimiento** (ficha del vehículo, historial): añaden tipo/posición como distintivo visual junto a lo que ya muestran (categoría, `EstadoChip`, `OrigenChip`), sin rediseñar nada existente. El detalle exacto (icono, texto, ubicación) queda para el plan de implementación, siguiendo el mismo patrón que `OrigenChip` en la Fase 4.

## 10. Qué queda fuera de esta fase

- Cualquier pantalla de administración del catálogo: `MaintenanceType` vive en código, no en base de datos.
- `MaintenanceOperationKind` con valores adicionales tipo `ajuste`/`servicio` (nota en §4, catálogo de neumáticos).
- Conectar `MaintenanceType` con piezas compatibles: eso es la Fase 6 del roadmap (`docs/superpowers/specs/2026-08-12-roadmap-identidad-tecnica-catalogo-piezas.md`), que ya preveía exactamente este dato como enganche.
- Backfill de tipo/posición sobre mantenimientos ya configurados: quedan sin tipo hasta que alguien los edite a mano.
