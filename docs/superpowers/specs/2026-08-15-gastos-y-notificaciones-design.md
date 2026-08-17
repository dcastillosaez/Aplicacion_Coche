# Gastos y notificaciones

**Fecha:** 15 de agosto de 2026
**Estado:** diseño aprobado, pendiente de plan de implementación

## 1. Por qué esto y no el catálogo de piezas

El roadmap (`2026-08-12-roadmap-identidad-tecnica-catalogo-piezas.md`) situaba aquí la Fase 5: decidir la fuente de datos del catálogo de piezas. Ese documento ya dejaba escrito que el primer entregable no era código, sino la respuesta a si existe un proveedor viable para dos coches particulares, y que si la respuesta era no, la fase se aparcaba.

La investigación se hizo y la respuesta es **no**:

- **TecDoc / TecAlliance.** El acceso asequible (~219 €/año) es una web con usuario y contraseña, no una API. La API real es un producto B2B para talleres y tiendas, cara y de integración pesada. No existe un plan para desarrollador particular.
- **Envoltorios de terceros** (RapidAPI, Apify). Revenden o extraen por su cuenta datos de TecDoc. Legalidad dudosa y ninguna garantía de continuidad: la app se rompería el día que el intermediario desaparezca.
- **Open Labor Project.** Tiene plan gratuito (10 peticiones al día) con especificaciones de fluidos, pero se apoya en datos NHTSA, del mercado estadounidense. Un Seat León ST no se vende allí.
- **Tiendas españolas** (Autodoc, Mister Auto, Motointegrator). Todas buscan por matrícula y VIN, pero ninguna publica una API para terceros.

La Fase 5 queda aparcada, sin descartar. Nada de lo construido en las fases 3 y 4 depende de ella, tal como se previó.

En su lugar, esta fase cierra dos huecos del **diseño original de la v1** (`2026-08-09-app-mantenimiento-vehiculos-design.md`) que nunca llegaron a implementarse, y que responden a dos de las cuatro metas declaradas de la aplicación:

| Meta original | Estado hoy |
|---|---|
| 1. Saber qué toca hacer, **antes** de que se pase | A medias: la app lo calcula, pero solo lo cuenta si la abres |
| 4. Saber cuánto cuesta mantener cada coche | Sin hacer: el coste se guarda desde la fase 2, pero no se muestra agregado en ninguna parte |

## 2. Qué no cambia

- La arquitectura de tres capas y la regla de que `lib/domain/` no depende de Drift ni de Flutter.
- El modelo de datos. **Ninguna de las dos partes añade tablas ni columnas**, así que esta fase no sube `schemaVersion` ni necesita migración. Es la primera fase desde la 2 de la que se puede decir esto.
- La aplicación sigue **sin permiso de `INTERNET`**. Las notificaciones son locales; el permiso que se añade (`POST_NOTIFICATIONS`) no abre ninguna vía de salida de datos. La propiedad estructural "es imposible que un dato salga del móvil" se mantiene intacta.
- El cálculo de vencimientos (`lib/domain/maintenance_due.dart`) no se toca. Las dos partes de esta fase leen lo que ese motor ya produce.

## 3. Parte A — Gastos

### Dónde vive

Cuarto destino de la barra de navegación de `lib/ui/shell/app_shell.dart`, entre Historial y Ajustes:

```
Inicio · Historial · Gastos · Ajustes
```

Material 3 admite hasta cinco destinos sin apretarse. El destino de Ajustes sigue siendo el marcador de posición que ya existe desde la fase 1; esta fase no lo toca.

### Qué muestra

Una tarjeta por vehículo activo, con:

- El **total acumulado** de ese coche: la suma de `MaintenanceRecords.coste` de todos sus registros.
- El **desglose por año natural**, ordenado del más reciente al más antiguo, con una barra proporcional que permita comparar unos años con otros de un vistazo.

Los vehículos archivados no aparecen, por coherencia con el resto de la aplicación (Inicio tampoco los muestra).

### La honestidad del dato

`coste` es un campo opcional: un mantenimiento puede registrarse sin él. Un total que ignore eso en silencio se lee como "he gastado poco" cuando en realidad significa "no lo apunté". Por eso la pantalla indica, por cada coche, **cuántos registros no tienen coste anotado**. Es el mismo criterio que la aplicación ya aplica en otros sitios (el aviso de "ritmo de uso supuesto", el símbolo ≈ en las cifras estimadas): decir de dónde sale cada número y cuándo no es fiable.

Un coche sin ningún coste registrado no muestra una tarjeta con un cero, sino un texto que explica que todavía no hay nada anotado.

### Sin dependencias

Las barras comparativas se dibujan con widgets nativos de Flutter (anchos proporcionales dentro de un `LayoutBuilder` o equivalente). Un paquete de gráficos no está justificado para un gráfico de barras de una sola dimensión.

### Alcance deliberadamente pequeño

Fuera de esta fase, por decisión explícita: desglose por categoría o por tipo de mantenimiento, coste por kilómetro, medias mensuales o anuales, y cualquier gasto que no sea un mantenimiento (seguro, ITV, impuesto de circulación, combustible). Esto último implicaría una tabla nueva, un formulario de alta y decidir cómo se modelan los gastos recurrentes; es una fase en sí misma si algún día hace falta.

## 4. Parte B — Notificaciones

### Qué se notifica

Dos disparos por mantenimiento:

1. Cuando **entra en el margen de aviso** que el propio mantenimiento tiene configurado (`avisoKm` / `avisoDias`, o los valores por defecto de `Settings`). Es el estado `atencion` del motor de vencimientos, y es exactamente para lo que esos márgenes existen desde la fase 2.
2. Cuando **vence**.

Un mantenimiento con `silenciado` a `true` calcula su estado con normalidad pero no genera ninguna notificación. Ese campo ya existe en el modelo desde la fase 2, previsto para esto.

### Cómo se agrupan

**Una notificación por coche y por día**, no una por mantenimiento. El coche es la unidad natural de acción: se va al taller con un coche concreto, no con un mantenimiento suelto. Con dos coches y una quincena de mantenimientos cada uno, notificar por mantenimiento produciría ráfagas que se acaban ignorando.

El texto resume lo que estará pendiente en esa fecha:

```
Seat León — 3 mantenimientos necesitan atención
Aceite y filtro, pastillas delanteras, filtro de aire
```

Al tocarla, la aplicación se abre por Inicio, que ya muestra los avisos pendientes de los dos coches. Llevar directamente a la ficha del vehículo concreto exigiría una clave de navegación global y distinguir si la aplicación estaba ya abierta o arrancando de cero: demasiada complejidad para el extra que aporta, así que queda anotado como mejora y fuera de esta fase.

Si varias transiciones caen el mismo día natural, se funden en una sola notificación. Si la práctica demuestra que sigue siendo ruidoso, subir la ventana de agrupación de un día a una semana es un cambio de una constante, no de arquitectura.

### El problema de los kilómetros, y cómo se resuelve

Una notificación local se programa para un instante concreto. Los mantenimientos que van por fecha se traducen directamente. Los que van por kilómetros no: "faltan 1.000 km" no es una fecha.

La traducción ya existe en el dominio desde la fase 2: `Vencimiento.fechaEstimadaPorKm` proyecta el kilometraje restante sobre el ritmo de uso medido del coche. Esta fase la reutiliza tal cual.

La consecuencia hay que asumirla y decirla: **los avisos por kilómetros son aproximados**. Si el coche se usa más de lo previsto, la notificación llega tarde; si se usa menos, llega pronto. La mitigación es la reprogramación (abajo) y el recordatorio de lectura, que mantienen la estimación fresca. Los avisos por fecha, en cambio, son exactos.

Cuando el ritmo de uso es el supuesto por defecto en lugar de uno medido (`Vencimiento.estimacionEsSupuesta`), la aplicación ya marca esas cifras en pantalla con ≈ y un aviso explícito. Las notificaciones derivadas de una estimación supuesta se programan igual, pero su texto debe reflejar esa incertidumbre en lugar de afirmar una cifra exacta.

### Cuándo se reprograma

Se cancela todo y se reprograma desde cero:

- Al volver la aplicación a primer plano. El patrón ya está montado en `lib/providers/recalculo_al_reanudar.dart`, que hoy invalida `ritmoUsoProvider`, `vencimientosProvider` y `estadoVehiculoProvider`.
- Después de guardar cualquier vehículo, lectura de kilometraje, mantenimiento o registro.

Cancelar y reprogramar entero, en lugar de llevar la cuenta de qué notificación corresponde a qué mantenimiento, evita toda una clase de errores de sincronización (avisos huérfanos de mantenimientos borrados, duplicados tras editar un intervalo). El coste es despreciable: son unas pocas decenas de alarmas.

**Horizonte de programación: un año.** Suficiente para que los avisos sigan llegando aunque la aplicación pase meses sin abrirse, y muy por debajo de cualquier límite de Android.

**Lo que ya está vencido no genera notificación.** Solo se programan fechas futuras: una alarma en el pasado no existe. Un mantenimiento que ya se pasó no se avisa al reprogramar —o bien se avisó en su momento, o bien la aplicación no estaba instalada entonces—, pero sigue apareciendo como vencido en pantalla, que es donde esa información no caduca. La notificación sirve para enterarse de algo nuevo, no para repetir lo que la ficha ya muestra en rojo.

### Recordatorio de kilometraje

Si pasan `Settings.diasRecordatorioLectura` días (15 por defecto) sin una lectura de un coche, se avisa. El campo existe en la tabla desde la fase 1 y nunca se ha usado.

No es un adorno: los avisos por kilómetros se calculan proyectando el ritmo de uso desde la última lectura real, así que cuanto más vieja es esa lectura, peor es la estimación. Este recordatorio es lo que mantiene útil a la mitad del sistema de avisos.

### Hora de entrega

Las 9:00, hora local. Fijo en esta fase, sin ajuste en la interfaz. Si resulta incómodo, convertirlo en un ajuste es trivial una vez exista la pantalla de Ajustes.

### Arquitectura

Tres piezas con responsabilidades separadas:

```
lib/domain/    Cálculo puro: dadas las fechas de vencimiento de un coche,
               qué avisos tocan y en qué fecha cada uno. Sin Flutter, sin
               plugins, sin efectos secundarios. Es lo que se prueba con
               tests unitarios.

lib/services/  Interfaz del servicio de notificaciones (programar, cancelar
               todo) más su implementación real sobre el plugin. Carpeta
               nueva, ya prevista en el diseño original de la v1.

lib/providers/ Une las dos: observa los datos, pide al dominio qué hay que
               programar, y se lo encarga al servicio.
```

La interfaz en `lib/services/` es lo que permite probar la lógica sin depender del plugin nativo: los tests usan una implementación falsa que se limita a registrar qué se le pidió programar. Sin esa separación, el cálculo de avisos sería imposible de probar en un test de Dart puro.

### El coste honesto: dos dependencias y un permiso

- **`flutter_local_notifications`**. No hay forma de emitir notificaciones locales programadas en Flutter sin ella, salvo escribir el código nativo de Android a mano, que sería peor en todo. La norma del proyecto ("sin dependencias nuevas salvo necesidad real y justificada") se cumple: la necesidad es real y no hay alternativa razonable.
- **`timezone`**. La anterior la exige para programar en hora local (`zonedSchedule`). No es una elección independiente.
- **Permiso `POST_NOTIFICATIONS`** en el manifiesto de Android, obligatorio desde Android 13. Se solicita al usuario la primera vez que hace falta, no al arrancar la aplicación. Si lo deniega, la aplicación sigue funcionando exactamente igual que hoy: calcula y muestra los vencimientos, simplemente no avisa.

Se descarta usar alarmas exactas (`SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`), que exigen un permiso especial y una justificación ante Google Play. Un aviso de mantenimiento no necesita precisión de minutos: que llegue esa mañana es suficiente.

## 5. Orden de implementación

**Gastos primero, notificaciones después.** Son dos subsistemas independientes: no comparten datos ni código, más allá de leer lo que ya existe. Gastos no tiene dependencias nuevas, ni permisos, ni migración, ni riesgo; notificaciones concentra todo lo delicado de esta fase. Hacer gastos primero deja valor entregado en el móvil antes de entrar en la parte que puede complicarse.

Cada uno con su plan de implementación, ejecutados en secuencia.

## 6. Qué queda fuera

- La pantalla de Ajustes real: sigue siendo el marcador de posición de la fase 1. Los valores de `Settings` se siguen usando desde la base de datos, pero no hay forma de cambiarlos desde la aplicación.
- La copia de seguridad exportable, prevista en el diseño original de la v1 y todavía sin hacer. Es relevante porque el APK va firmado con clave de depuración, así que ciertas reinstalaciones pueden borrar los datos sin aviso.
- Cualquier gasto que no sea un mantenimiento, y cualquier desglose de gastos más allá del total por coche y por año (ver §3).
- La Fase 5 del roadmap (catálogo de piezas), aparcada por falta de fuente de datos viable, no descartada.
