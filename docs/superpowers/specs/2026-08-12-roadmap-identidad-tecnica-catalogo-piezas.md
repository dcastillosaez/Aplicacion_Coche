# Roadmap — De recordatorio de mantenimiento a asistente del coche

**Fecha:** 12 de agosto de 2026
**Estado:** visión aprobada, pendiente de brainstorming y spec detallado por fase antes de implementar

---

## 1. La idea en una frase

Hoy la app sabe esto:

```
Coche → mantenimientos → vencimientos
```

Le pedimos que sepa esto:

```
Coche → identidad técnica → mantenimiento realizado → mantenimiento previsto → piezas compatibles
```

La diferencia no es cosmética. Hoy la app puede decir "cambio de aceite dentro de 2.000 km". El objetivo es que además pueda decir con qué aceite, con qué filtro, y qué referencias concretas de qué fabricantes le valen a *ese* motor y no a otro con el mismo nombre comercial.

## 2. Reconciliación con lo ya planificado

El plan de la fase 2 dejaba anotado, sin desarrollar, un boceto de "fase 3" (notificaciones, ajustes reales, copia de seguridad) y una "fase 4" (componentes, facturas, gastos). Ese boceto queda descartado en su prioridad: este roadmap pasa a ocupar la Fase 3 en adelante. Notificaciones, ajustes y copia de seguridad no se abandonan como idea, pero no tienen fase asignada — se retoman cuando este roadmap esté maduro, no antes.

| Fase | Contenido |
|---|---|
| 1 y 2 | Cimientos, vehículos, mantenimientos y avisos. **Hechas.** |
| ~~3~~ | ~~Notificaciones, ajustes, backup~~ — deprioritizada, sin número de fase por ahora |
| ~~4~~ | ~~Componentes, facturas, gastos~~ — el concepto de "componente instalado con coste" se retoma más adelante, probablemente fundido con el modelo de piezas de la Fase 6 |
| **3** | **Identidad técnica del vehículo** |
| **4** | **Motor de recomendaciones y mantenimiento inteligente** |
| **5** | **Catálogo de piezas: decidir la fuente de datos** (no se asume TecDoc de antemano) |
| **6** | **Integración mantenimiento ↔ piezas** |
| **7** | **Compra** (especulativa, solo si 3–6 funcionan bien) |

## 3. La decisión de internet, explícita y aparcada

La aplicación no pide permiso `INTERNET` en el manifiesto de Android. Es una propiedad estructural, no una promesa: es *imposible* que un dato salga del móvil, falle lo que falle en el código. Las fases 3 y 4 de este roadmap no la necesitan y se diseñan para seguir siendo 100% manuales y offline.

La Fase 5 (catálogo de piezas) sí la necesita sin vuelta atrás — cualquier proveedor de catálogo, TecDoc incluido, es un servicio en la nube. Cuando llegue esa fase, hay que decidir con los ojos abiertos, y el riesgo real no es tanto de seguridad como de **negocio y de ingeniería**:

- El VIN no es un dato secreto — está en el parabrisas y en el permiso de circulación. Enviarlo a un proveedor de catálogo no es una fuga grave de privacidad.
- El riesgo de ingeniería real es dónde vive la clave de la API: si se embebe en el APK, es extraíble por cualquiera que lo descargue. Hace falta una solución deliberada (proxy propio, o un modelo de autenticación que no dependa de un secreto embebido), no una ocurrencia de última hora.
- El riesgo mayor es el de negocio: TecDoc es un producto B2B pensado para talleres y tiendas, con licencia de pago. El primer paso de la Fase 5 ("estudiar API/licencia") tiene que responder si existe algún plan razonable para dos coches particulares, o si es desproporcionado — y si lo es, buscar alternativa o descartar la fase.

Nada de esto bloquea empezar por la Fase 3.

## 4. Cómo evoluciona el modelo de datos

Lo que ya existe hoy y no se toca:

```
Vehicles              — marca, modelo, version (texto libre), anio, vin, combustible...
MaintenanceSchedules  — nombre, categoria, intervalKm, intervalMeses, avisoKm, avisoDias...
MaintenanceRecords    — fecha, km, coste, taller, esSembrado
MileageReadings
Settings
```

Dos datos ya existen y son la base de todo lo que sigue, y conviene decirlo porque cambia el trabajo real de la Fase 3: `Vehicles.vin` ya está en el esquema (nullable, sin usar todavía en ninguna pantalla), y `MaintenanceRecords.esSembrado` ya distingue un dato introducido a mano de uno que la app presenció — es exactamente la semilla del "estado de confianza" que se describe más abajo.

Lo que se añade, fase a fase:

```
Fase 3   VehicleSpecifications   — identidad técnica del vehículo (1:1 con Vehicle)
Fase 4   (sin tablas nuevas: lógica de dominio sobre lo que ya existe,
          más una columna `fuenteIntervalo` en MaintenanceSchedules)
Fase 5   Parts, PartCompatibility
Fase 6   MaintenancePartRecommendations
```

## 5. Fase 3 — Identidad técnica del vehículo

### Por qué antes que el catálogo

Un modelo comercial no identifica una pieza. "Volkswagen Golf 1.6 TDI" puede llevar motores, potencias, cajas y frenos distintos según el año y la generación. Sin una identidad técnica precisa, cualquier catálogo de piezas que se conecte después estaría adivinando. Construir esto primero evita tener que rehacerlo cuando llegue la Fase 5.

### Tabla nueva: `VehicleSpecifications`

Relación uno a uno con `Vehicles`, en tabla aparte y no como columnas sueltas en `Vehicles`, por dos motivos: la tabla de vehículos ya tiene bastantes columnas opcionales, y esta información es conceptualmente distinta — es la ficha técnica, no los datos administrativos del coche.

```
VehicleSpecifications
  vehicleId       FK a Vehicles, único (relación 1:1)
  generacion      texto, nullable        — "F30", "MK7"...
  motorCodigo     texto, nullable        — "B47", "EA288"...
  cilindradaCc    entero, nullable       — 1995
  potenciaKw      entero, nullable       — se muestra también en CV, calculado, no se
                                           guardan los dos para que no puedan desincronizarse
  tipoCaja        enum, nullable         — manual, automatica
  numeroMarchas   entero, nullable
  traccion        enum, nullable         — delantera, trasera, total
  codigoTecnico   texto, nullable        — identificador de variante de un catálogo externo
                                           (p. ej. el KType de TecDoc). Ver nota abajo.
  notasTecnicas   texto, nullable
```

`vin` **no se duplica aquí**: ya vive en `Vehicles.vin` desde la fase 1. Esta tabla es la ficha técnica; el VIN es un identificador administrativo del vehículo concreto, no de su especificación.

Todos los campos son opcionales. Nadie debe sentirse obligado a rellenar el código de motor para poder usar la app.

#### `codigoTecnico`: reservado, no manual

"BMW Serie 3 320d 2019" es ambiguo para buscar piezas; un identificador técnico unívoco de la variante no lo es. Los catálogos aftermarket lo resuelven con un código propio — TecDoc, por ejemplo, usa un identificador numérico llamado *KType* para enlazar cada variante de vehículo con las piezas compatibles.

Este campo se añade ya, en la Fase 3, pero **con una condición explícita: nunca se rellena a mano**. Nadie conoce el KType de su coche de memoria, y pedirlo en un formulario sería pedir un dato inventado. Se queda a `null` hasta que la Fase 5/6 lo resuelva automáticamente cruzando `VehicleSpecifications` contra el catálogo elegido — por generación, motor y potencia, no por el nombre comercial. Si esa fase nunca llega, el campo se queda vacío para siempre y no molesta a nadie: es la razón por la que es nullable y no una tabla aparte.

Una advertencia encontrada al documentar esto y que conviene no olvidar: el propio KType de TecDoc tiene limitaciones conocidas de granularidad (una misma variante técnica real puede mapear a varios KType, o viceversa, según el mercado). No hay que tratarlo como una verdad absoluta cuando llegue ese momento, solo como el mejor identificador disponible.

### Modelo comercial frente a variante técnica

`Vehicle.modelo` y `Vehicle.version` (texto libre, ya existente, p. ej. "320d" y "2.0 TDI 150 CV DSG") siguen siendo el resumen legible que se ve en las tarjetas y en las listas. `VehicleSpecifications` es la capa estructurada por debajo, pensada para poder cruzarse algún día contra un catálogo. No se sustituyen entre sí: uno es para leer, el otro para buscar piezas.

### Alta del VIN — manual, sin excepción en esta fase

Se ofrece un campo opcional al dar de alta o editar el vehículo, con una ayuda visual de dónde encontrarlo (parabrisas del lado del conductor, permiso de circulación). Sin búsqueda automática por matrícula, sin llamada a ningún servicio: es texto que el usuario copia a mano. Cualquier automatización de esto pertenece a una decisión posterior y explícita sobre acceso a internet (§3), no a esta fase.

### Pantalla

Se amplía la ficha del vehículo con una sección de identidad técnica, editable igual que el resto de datos del coche, con los mismos criterios ya asentados en el proyecto (guarda de reentrada, `try`/`catch` con mensaje en español, `if (!mounted)`).

### Decisión arquitectónica que fija esta fase, aunque su código llegue después

`VehicleSpecifications` es el único punto por el que cualquier futuro proveedor de piezas identificará un vehículo. Para que la Fase 5 pueda ser "elegir proveedor" y no "reescribir cómo se buscan piezas", el acceso al catálogo se diseña desde ahora detrás de una interfaz — un `PartsCatalogRepository` abstracto con implementaciones intercambiables (`Local`, y más adelante `Remote` para el proveedor que se elija). Si TecDoc resulta inviable por licencia (§3), se cambia la implementación sin tocar nada que dependa de ella.

Esto es una decisión de diseño, no una tarea de esta fase: **el código del repositorio no se escribe todavía**, porque no tendría ningún consumidor real hasta la Fase 6 y sería abstracción sin uso. Lo que fija ya la Fase 3 es la forma del dato que ese repositorio consumirá el día de mañana — `VehicleSpecifications`, con su `codigoTecnico` reservado — para que cuando llegue el momento de escribir la interfaz, encaje sin fricción.

## 6. Fase 4 — Motor de recomendaciones y mantenimiento inteligente

Todo lo que sigue se construye sobre datos que la app **ya tiene**. No hace falta ningún proveedor externo ni tabla nueva salvo una columna.

### Agrupación de mantenimientos próximos

Cuando dos o más mantenimientos vencen dentro de una misma ventana de kilómetros o de tiempo, se agrupan en la interfaz con un mensaje del tipo "puedes hacer estas operaciones juntas y ahorrar una visita al taller". Es una capa de presentación sobre `vencimientosProvider`, que ya devuelve la lista ordenada por urgencia — agrupar es cuestión de comparar `diasHastaVencimiento` entre elementos consecutivos.

Los umbrales de esa ventana (por ejemplo, 500 km o 15 días) **no se escriben como literales sueltos en el provider o en la pantalla**. Se agrupan en un único punto, del mismo modo que hoy `avisoKmPorDefecto`/`avisoDiasPorDefecto` viven en `Settings` y no repartidos por el código:

```
MaintenanceGroupingPolicy
  maxKmDiferencia
  maxDiasDiferencia
```

No hace falta construir una pantalla de ajustes para esto — eso solo se justifica si, tras usar la app, 500 km resultan ser demasiado poco o 15 días demasiado. Lo que sí evita esta forma es que, cuando llegue ese momento, cambiar el criterio signifique tocar un valor en un sitio y no rastrear varios ficheros.

### Mantenimientos sin ningún historial, distintos de los sembrados

Hoy un mantenimiento sin ningún `MaintenanceRecord` asociado y uno con un registro sembrado se comportan igual de cara al motor de vencimientos: ambos calculan si hace falta el dato. Pero de cara al usuario son cosas distintas — uno es "no sé si se ha hecho nunca", el otro es "sé que se hizo, antes de usar la app". Esta distinción **no necesita ninguna tabla nueva**: se deriva de lo que ya hay.

```
Sin ningún MaintenanceRecord              → desconocido
Con MaintenanceRecord, esSembrado = true  → histórico
Con MaintenanceRecord, esSembrado = false → confirmado
```

Se convierte en un enum de dominio (`OrigenMantenimiento`) y en un distintivo visual junto al `EstadoChip` ya existente, con textos honestos:

- 🟢 **Confirmado** — la app presenció el mantenimiento.
- 🟡 **Histórico** — dato introducido a mano, anterior a la app.
- ⚪ **Desconocido** — sin ningún registro. El texto de ayuda debe advertir explícitamente, no callar: "Si no sabes cuándo se hizo, consulta la documentación o la factura antes de asumir que está realizado."

Esto evita el caso peligroso de que un mantenimiento sin datos se vea igual que uno al día.

### Aprendizaje del patrón real de uso — sin tocar el intervalo configurado

La app ya calcula el ritmo de uso en km/día a partir de las lecturas de kilometraje (`lib/domain/usage_rate.dart`). La misma idea se aplica a los mantenimientos: si un `MaintenanceSchedule` tiene varios `MaintenanceRecord` reales (no sembrados), se puede calcular la media de kilómetros o meses entre ellos y mostrarla como información — "Tu patrón habitual: cambias el aceite cada ~15.000 km" — **sin alterar nunca el intervalo configurado**. Es un dato informativo, no una decisión automática. Lógica de dominio pura, sin dependencias nuevas.

### Fuente del intervalo: orientativo frente a específico

`MaintenanceSchedules` gana una columna `fuenteIntervalo` (enum: `orientativo`, `fabricante`, `usuario`). Todos los mantenimientos creados hasta ahora, y todos los que se creen antes de que exista un catálogo con datos oficiales por vehículo, son `orientativo` — es el valor por defecto y hoy es el único alcanzable. El valor `fabricante` solo se podrá asignar automáticamente cuando la Fase 6 conecte un mantenimiento con una regla de intervalo procedente del catálogo.

Aunque su valor más rico llega después, esta columna se añade ya, en esta fase, para no tener que hacer una migración adicional más adelante y para que la interfaz sea honesta desde ya:

- `orientativo` → "Intervalo orientativo: consulta el manual para confirmarlo."
- `fabricante` → "Según el intervalo oficial de tu vehículo."
- `usuario` → "Intervalo que has ajustado tú."

## 7. Fase 5 — Catálogo de piezas: decidir la fuente de datos

**Esta fase no asume TecDoc.** El título antiguo ("catálogo de piezas, proveedor externo") daba por hecho la conclusión antes de investigarla. El primer entregable no es código: es la respuesta a si TecDoc, o cualquier otro proveedor, tiene un plan viable para dos coches particulares (§3). Si la respuesta es no, esta fase busca alternativa o se aparca — no bloquea nada de lo construido en las fases 3 y 4, porque ninguna de ellas depende de que exista un catálogo.

Gracias a la interfaz `PartsCatalogRepository` prevista desde la Fase 3, "decidir el proveedor" es una decisión real y no un compromiso de facto: cabe perfectamente empezar con una implementación `Local` — un catálogo reducido, mantenido a mano, solo para las piezas de los dos coches propios — y añadir después una implementación `Remote` si un proveedor externo resulta viable. La primera no es un paso perdido de cara a la segunda: ambas cumplen la misma interfaz.

Alcance, sin cambios respecto a lo ya decidido:

- Decidir la fuente: ¿local y mantenida a mano, TecDoc, u otro proveedor? Estudiar API y licencia de cada candidata.
- Definir e implementar `PartsCatalogRepository` (la interfaz que ya fijó su forma la Fase 3) y su primera implementación concreta.
- Búsqueda por vehículo, por categoría, por referencia OE.
- Mostrar equivalencias entre fabricantes.
- Cobertura por categoría: aceites, filtros, bujías, frenos, baterías, neumáticos.

### Tablas nuevas

```
Parts
  id
  fabricante
  referencia
  ean            nullable
  nombre
  categoria
  descripcion    nullable
  imagenUrl      nullable

PartCompatibility
  partId              FK a Parts
  vehicleSpecificationId  FK a VehicleSpecifications
  notas               nullable
  validoDesde         nullable
  validoHasta         nullable
```

La relación de compatibilidad cuelga de `VehicleSpecifications`, no de `Vehicle` ni del nombre comercial: es la variante técnica la que determina si una pieza vale, no "Golf 1.6 TDI" como texto.

### Cómo se presenta: catálogo, no tienda

Regla explícita, ya decidida: la app no dice "compra este filtro". Dice:

```
Filtro de aire
Recomendado para tu vehículo
MANN-FILTER XXXXX — compatibilidad exacta

Alternativas
MAHLE XXXXX · Bosch XXXXX · Purflux XXXXX
```

Sin precios, sin stock, sin enlaces de compra. Eso es la Fase 7, y solo si esta fase demuestra que merece la pena.

### El aceite es un caso especial

No se modela como una pieza más. Necesita campos propios: viscosidad, especificación del fabricante, normativa, capacidad con y sin filtro. Se muestra como "aceites compatibles" (plural, varias marcas), nunca como una recomendación de marca única, para no convertir la pantalla en publicidad.

## 8. Fase 6 — Integración mantenimiento ↔ piezas

Aquí se cierra el círculo: cada mantenimiento puede llevar asociadas las piezas que necesita.

```
MaintenancePartRecommendations
  maintenanceCategoria   o vinculado al MaintenanceSchedule concreto — a decidir en el
                           brainstorming de esta fase
  partId                 FK a Parts
  prioridad
  recomendado             boolean
```

Con esto, "Cambio de aceite" puede desplegar aceite + filtro + arandela del tapón, cada uno con sus alternativas. Y el flujo de "registrar mantenimiento" (`register_maintenance_sheet.dart`, ya existente) se enriquece: en vez de solo apuntar kilómetros y coste, se puede marcar qué piezas concretas se han usado, dejando un historial mucho más rico — "Aceite 5W-30 XXXX + filtro MANN XXXXX — 82 €" en vez de "Aceite — 96.000 km".

## 9. Fase 7 — Compra

Precios, tiendas, stock, enlaces, cesta, historial de compras. Deliberadamente sin detallar: solo tiene sentido si las fases 3 a 6 funcionan bien y de verdad aportan valor antes de convertir la app en algo parecido a una tienda.

## 10. Qué no cambia

La arquitectura se mantiene tal cual: Flutter, Riverpod, Drift/SQLite, tres capas con el dominio sin depender de datos ni de Flutter. No hay rediseño, hay evolución del dominio. El objetivo declarado es pasar de "recordatorio de mantenimiento" a "asistente personal de mantenimiento del coche": sé qué coche tienes, sé qué se le ha hecho, sé cuánto lo usas, sé qué le toca, sé qué piezas necesita, te enseño cuáles son compatibles — sin que ningún eslabón de esa cadena dependa de un servicio externo hasta que la Fase 5 lo decida de forma explícita.

## 11. Próximos pasos

Este documento es la visión y el reparto en fases, no un plan de implementación. Antes de tocar código de la Fase 3, toca el mismo proceso ya seguido en las fases 1 y 2: brainstorming corto para cerrar los detalles que aquí quedan abiertos (nombres exactos de los campos, si `tipoCaja`/`traccion` merecen ser enums o texto libre, cómo se ve exactamente la sección nueva en la ficha del vehículo) y después un plan de implementación tarea a tarea con sus tests, ejecutado con subagente y revisión adversarial como el resto del proyecto.
