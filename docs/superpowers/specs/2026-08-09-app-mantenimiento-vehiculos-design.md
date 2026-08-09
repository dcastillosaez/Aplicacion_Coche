# Diseño — App de mantenimiento de vehículos

**Fecha:** 9 de agosto de 2026
**Estado:** aprobado, pendiente de plan de implementación

---

## 1. Qué resuelve

Una aplicación Android para llevar el mantenimiento de dos coches particulares. Cuatro problemas concretos:

1. Saber qué toca hacer próximamente, antes de que se pase.
2. Guardar qué se hizo, cuándo y a cuántos kilómetros.
3. Tener las facturas y documentos en un sitio.
4. Saber cuánto cuesta mantener cada coche.

Los puntos 3 y 4 quedan fuera de la primera versión, pero el modelo de datos los contempla desde el principio para no tener que migrar nada después.

Los vehículos son un Mercedes-Benz Clase B 180 diésel de 2009 en rojo y un Seat León ST 2.0 TDI de 150 CV con cambio DSG en azul mystery. La aplicación no está atada a esos dos: admite cualquier número de vehículos sin tocar código.

## 2. Decisiones tomadas

| Decisión | Elección | Por qué |
|---|---|---|
| Plataforma | Android únicamente | Es el móvil del usuario. Compilar para iOS desde Windows exigiría un Mac o un servicio de CI de pago. |
| Stack | Flutter + Drift (SQLite) | Una sola base de código, notificaciones locales fiables, consultas tipadas, y deja abierta la puerta a iOS si algún día cambia el móvil. |
| Datos | Locales, sin backend | Dos coches y un usuario no justifican autenticación, red ni sincronización. Copia de seguridad exportable a mano. |
| Alcance v1 | Núcleo | Vehículos, kilometraje, mantenimientos, avisos e historial. Componentes, facturas y gastos en la v2. |
| Avisos por km | Estimación del ritmo de uso + recordatorio de lectura | Es la única forma de que un aviso de kilometraje llegue *antes* de pasarse, dado que la app solo conoce los km que se le introducen. |
| Distribución | APK instalado a mano | Sin Play Store, sin cuenta de desarrollador, sin coste, sin caducidad. |

## 3. Alcance

**Dentro de la v1**

- Alta y edición de vehículos, con foto.
- Registro del kilometraje en dos toques desde la pantalla de inicio.
- Mantenimientos con intervalo por kilómetros, por tiempo, o ambos.
- Motor de vencimientos con la regla "lo que ocurra primero".
- Notificaciones locales por fecha y por kilometraje estimado.
- Recordatorio periódico para introducir el kilometraje.
- Registro de mantenimientos realizados, incluyendo coste y taller.
- Historial cronológico de ambos vehículos.
- Plantillas de mantenimientos habituales al crear un vehículo.
- Cálculo automático de la periodicidad de la ITV.
- Tema claro y oscuro.
- Exportar e importar copia de seguridad.

**Fuera de la v1**

Inventario de componentes, biblioteca de facturas con foto o PDF, pantalla de gastos con gráficos, reconocimiento automático de facturas, conexión OBD, diagnóstico de averías, búsqueda de talleres y sincronización en la nube.

## 4. Arquitectura

Tres capas, con una regla que gobierna el resto: **el cálculo de vencimientos no toca ni la base de datos ni la interfaz**. Es una función pura que recibe datos y devuelve estados, así que se puede probar entera sin emulador ni base de datos de por medio.

```
lib/
  data/          Drift: tablas, DAOs, migraciones, backup y restauración
  domain/        modelos de dominio, motor de vencimientos, estados, plantillas
  ui/            pantallas, componentes reutilizables, tema
  services/      notificaciones locales, acceso a ficheros
```

Gestión de estado con Riverpod. La base de datos vive en el directorio privado de la aplicación. Sin red, sin login, sin permisos de internet.

Cada fichero tiene una responsabilidad y un tamaño manejable. En cuanto un fichero de pantalla empieza a acumular lógica de cálculo, esa lógica se baja a `domain/`.

## 5. Modelo de datos

Dos diferencias respecto al borrador inicial, ambas deliberadas.

**El kilometraje es un histórico, no un número.** Guardar solo `currentMileage` en el vehículo significa pisar el valor anterior cada vez. Sin las lecturas anteriores no se puede calcular el ritmo de uso, y sin ritmo de uso no hay estimación ni notificaciones de kilometraje. El kilometraje actual pasa a ser, sencillamente, la lectura más reciente.

**Las fechas y kilómetros de vencimiento no se guardan, se calculan.** Un valor derivado almacenado acaba desincronizándose con los datos reales tarde o temprano. El "último realizado" sale del registro más reciente de ese mantenimiento; el "próximo" de sumarle el intervalo.

Esto plantea un caso práctico: al crear el mantenimiento del aceite, el último cambio ya ocurrió antes de que existiera la aplicación. Se resuelve permitiendo introducir esa fecha y kilometraje al crear el mantenimiento, lo que genera un registro inicial con `esSembrado = true`. Cuenta para todos los cálculos y aparece en el historial identificado como dato anterior a la app.

### Tablas

**Vehicle**

| Campo | Tipo | Notas |
|---|---|---|
| id | int, PK autoincremental | |
| marca | texto | obligatorio |
| modelo | texto | obligatorio |
| version | texto | opcional, p. ej. "2.0 TDI 150 CV DSG" |
| anio | int | opcional |
| matricula | texto | opcional |
| combustible | enum | gasolina, diésel, híbrido, eléctrico, GLP |
| fechaMatriculacion | fecha | opcional, necesaria para calcular la ITV |
| color | texto | opcional |
| fotoPath | texto | opcional, ruta relativa dentro del directorio de la app |
| vin | texto | opcional |
| notas | texto | opcional |
| creadoEn | fecha y hora | |
| archivado | booleano | por defecto falso, para vehículos vendidos |

**MileageReading**

| Campo | Tipo | Notas |
|---|---|---|
| id | int, PK | |
| vehicleId | int, FK | borrado en cascada |
| fecha | fecha | |
| km | int | |
| origen | enum | manual, mantenimiento |

Índice por `(vehicleId, fecha)`. Se admite una lectura por día y vehículo: si se introduce una segunda el mismo día, se sustituye la anterior.

**MaintenanceSchedule**

| Campo | Tipo | Notas |
|---|---|---|
| id | int, PK | |
| vehicleId | int, FK | cascada |
| nombre | texto | |
| categoria | enum | motor, frenos, neumáticos, electricidad, suspensión, transmisión, carrocería, ITV, otro |
| intervalKm | int, nullable | |
| intervalMeses | int, nullable | |
| avisoKm | int, nullable | si es nulo, hereda el valor por defecto de ajustes |
| avisoDias | int, nullable | ídem |
| activo | booleano | |
| silenciado | booleano | no notifica, pero sigue calculando el estado |
| orden | int | para ordenar la lista manualmente |

Restricción: al menos uno de `intervalKm` o `intervalMeses` debe tener valor.

**MaintenanceRecord**

| Campo | Tipo | Notas |
|---|---|---|
| id | int, PK | |
| vehicleId | int, FK | cascada |
| scheduleId | int, FK nullable | nulo para reparaciones puntuales sin mantenimiento asociado |
| fecha | fecha | |
| km | int | |
| coste | decimal, nullable | en euros |
| taller | texto, nullable | |
| notas | texto, nullable | |
| esSembrado | booleano | dato anterior a la instalación de la app |
| invoiceId | int, FK nullable | reservado para la v2 |

Al guardar un registro se crea también una `MileageReading` con origen `mantenimiento`, salvo que ya exista una lectura igual o superior ese mismo día.

**Tablas definidas pero sin interfaz en la v1**

`Component` y `Invoice`, con la estructura del borrador original. Se crean en el esquema inicial para evitar una migración en la v2.

**Settings**, tabla Drift de una única fila con identificador fijo, para que los ajustes viajen en la copia de seguridad junto al resto de los datos: `avisoKmPorDefecto` = 1.000, `avisoDiasPorDefecto` = 30, `diasRecordatorioLectura` = 15, `tema` = automático, `fechaUltimaCopia` = nulo.

### Migraciones

Drift con versión de esquema explícita desde la 1. Cada cambio futuro añade un paso de migración con su test.

## 6. Motor de vencimientos

Es el núcleo de la aplicación y donde se concentra el esfuerzo de pruebas.

### Ritmo de uso

Se toman las lecturas de los últimos 90 días y se calcula:

```
ritmo = (km de la lectura más reciente − km de la lectura más antigua de la ventana)
        / días transcurridos entre ambas
```

Requiere al menos dos lecturas separadas por 7 días o más. Es un cálculo deliberadamente simple: determinista, fácil de probar y suficientemente preciso para avisos con margen de días.

Si no hay datos suficientes, se usa un valor inicial de 33 km/día, equivalente a 12.000 km al año. En cuanto existen dos lecturas válidas, el valor real sustituye al inicial.

Si una lectura es inferior a la anterior, se marca como incoherente y se pide confirmación al usuario antes de guardarla; si la confirma, se descartan las lecturas anteriores a efectos del cálculo del ritmo, porque lo más probable es que se haya corregido un error de tecleo.

Un ritmo calculado por debajo de 1 km/día se trata como coche parado: `fechaEstimadaKm` no se calcula, la pantalla muestra los kilómetros restantes sin traducirlos a días, y los vencimientos por kilómetros no generan notificación. Solo la generan los de fecha. Esto elimina además cualquier división por cero.

### Vencimiento de cada mantenimiento

Para un mantenimiento con último registro conocido:

```
proximoKm    = ultimoKm    + intervalKm
proximaFecha = ultimaFecha + intervalMeses

kmActual         = última lectura registrada
kmProyectadoHoy  = kmActual + ritmo × (días desde esa lectura)
kmRestantes      = proximoKm - kmProyectadoHoy
diasRestantes    = proximaFecha - hoy
fechaEstimadaKm  = hoy + kmRestantes / ritmo
```

**Vence el que llegue antes.** Si un mantenimiento tiene ambos intervalos, la fecha efectiva de vencimiento es la menor entre `proximaFecha` y `fechaEstimadaKm`.

Si el mantenimiento no tiene ningún registro previo y tampoco se sembró, se considera pendiente de configurar y aparece marcado como tal, sin generar avisos.

### Estados

Sea `margen` el aviso configurado para ese mantenimiento (en kilómetros, en días, o ambos):

- **Vencido** — `kmRestantes <= 0` o `diasRestantes <= 0`.
- **Atención** — dentro del margen configurado por cualquiera de las dos vías.
- **Próximo** — dentro del doble del margen.
- **Ok** — el resto.

### Presentación de las cifras

Los kilómetros mostrados como dato son siempre los realmente introducidos. La proyección aparece marcada con `≈` y nunca sustituye al valor real:

```
Cambio de aceite · León
Faltan ≈ 1.200 km  (≈ 24 días al ritmo actual)
Próximo: 150.000 km · o 10/05/2027
```

### Recálculo

Se recalcula todo y se reprograman las notificaciones al abrir la aplicación y después de guardar cualquier vehículo, lectura, mantenimiento o registro. No hay caché persistente de resultados.

## 7. Notificaciones

`flutter_local_notifications` con `zonedSchedule` en la zona horaria del dispositivo.

Se usa el modo **inexacto** (`inexactAllowWhileIdle`). Los avisos son de escala de días, no de minutos, así que no compensa pedir el permiso de alarmas exactas que Android 14 restringe.

Permiso `POST_NOTIFICATIONS` solicitado en el primer arranque, con una pantalla previa que explica para qué sirve. Si el usuario lo deniega, la aplicación funciona igual y muestra los avisos al abrirla, con un aviso persistente en Ajustes ofreciendo activarlos.

Identificadores de notificación deterministas, derivados del `scheduleId`. Antes de reprogramar se cancelan todas las pendientes de ese vehículo, para que no queden avisos huérfanos de mantenimientos borrados o modificados.

Por cada mantenimiento activo y no silenciado se programa **una sola notificación**: la del vencimiento más cercano de los dos posibles. Si el mantenimiento ya está vencido y no se ha registrado, se repite un recordatorio semanal, con un máximo de cuatro.

El recordatorio de lectura de kilometraje se programa a los `diasRecordatorioLectura` desde la última lectura introducida, sea cual sea su origen. Si el usuario actualiza los kilómetros por su cuenta, el contador se reinicia y no le llega el recordatorio.

## 8. Pantallas

**Navegación inferior de tres pestañas: Inicio · Historial · Ajustes.** Con dos vehículos, una pestaña separada de "Vehículos" mostraría exactamente lo mismo que ya se ve en Inicio. El botón de añadir vehículo va al final de la lista de Inicio. Si el número de vehículos creciera, se añade la cuarta pestaña sin más.

**Inicio.** Saludo breve. Una tarjeta por vehículo con foto, kilometraje como cifra grande, chip de estado general y los tres vencimientos más cercanos. Debajo, la lista global de próximos mantenimientos de todos los vehículos ordenada por urgencia. Botón flotante para actualizar el kilometraje.

**Actualizar kilometraje.** Hoja inferior con un único campo numérico grande, teclado abierto al aparecer, selector de vehículo solo si hay más de uno y botón de guardar. Dos toques desde abrir la aplicación.

**Ficha del vehículo.** Cabecera con foto, kilometraje y estado. El vencimiento más cercano destacado. Lista de mantenimientos configurados con su estado y sus cifras. Accesos a registrar mantenimiento y a editar el vehículo. Las secciones de componentes, gastos y documentos aparecen deshabilitadas con la nota de que llegan en la próxima versión, para no dar la sensación de que faltan.

**Crear o editar mantenimiento.** Nombre, categoría, intervalo por kilómetros y por meses (al menos uno), márgenes de aviso propios o heredados, interruptor de silenciado, y los datos del último realizado para sembrar el cálculo.

**Registrar mantenimiento realizado.** Qué mantenimiento, fecha, kilometraje, coste, taller y notas. Actualiza el kilometraje de paso.

**Historial.** Línea temporal descendente con los registros de todos los vehículos, filtrable por vehículo y por categoría. Cada entrada muestra kilometraje, fecha, nombre y coste.

**Ajustes.** Márgenes de aviso por defecto, frecuencia del recordatorio de lectura, tema, estado del permiso de notificaciones, y exportar e importar copia de seguridad.

## 9. Plantillas al crear un vehículo

Al añadir un vehículo se ofrece una lista de mantenimientos habituales para marcar, con intervalos genéricos y **todos editables**: aceite y filtro, filtro de aire, filtro de habitáculo, filtro de combustible, líquido de frenos, refrigerante, pastillas de freno, discos, neumáticos, batería, distribución, bujías o calentadores según combustible, e ITV.

**Los intervalos propuestos son valores razonables para un vehículo diésel moderno, no cifras oficiales del fabricante.** No se van a inventar los intervalos de Mercedes ni de Seat: el usuario los ajusta con el libro de mantenimiento delante. La pantalla lo dice explícitamente.

Dos añadidos específicos que una lista genérica dejaría fuera:

- **Aceite de la caja DSG**, propuesto al marcar el cambio automático en la versión del vehículo. Es un mantenimiento real con su propio intervalo que suele descubrirse tarde.
- **Distribución**, incluida siempre en la lista pero sin intervalo propuesto, porque depende del motor concreto. Se pide al usuario que lo introduzca.

### ITV

Es lo único que se puede calcular con certeza, a partir de la normativa española vigente para turismos:

- Menos de 4 años desde la matriculación: exento.
- De 4 a 10 años: cada 2 años.
- Más de 10 años: cada año.

La próxima ITV se calcula como la fecha de la última más la periodicidad que corresponda a la edad del vehículo; si no hay ninguna registrada, como fecha de matriculación más 4 años. El Clase B de 2009 entra en revisión anual.

## 10. Dirección visual

Referencias: mucho aire, tarjetas de esquinas amplias, el kilometraje como protagonista, y el color reservado en exclusiva para comunicar estado.

Superficies casi blancas con un punto frío en el tema claro y grises azulados profundos en el oscuro, evitando el negro puro. Un azul petróleo sobrio como color de acento, deliberadamente distinto del rojo y el azul de los coches del usuario, para que la foto de cada vehículo destaque sobre la interfaz en lugar de competir con ella.

Los cuatro estados en tonos desaturados y legibles, sin efecto semáforo. Cifras en tipografía tabular para que los kilómetros no bailen al actualizarse. Escala de espaciado de 8 píxeles, radios amplios en tarjetas, sombras muy suaves y sin tarjetas anidadas dentro de otras tarjetas.

Tema oscuro real desde el primer día, con su propia paleta y no como inversión del claro. Toda la interfaz en español, importes en euros, fechas en formato día/mes/año y separador de miles con punto.

## 11. Copia de seguridad

Exportación a un fichero `.zip` que contiene la base de datos SQLite y un `manifest.json` con la versión del esquema y la fecha. Se usa el formato comprimido desde la v1 aunque de momento solo lleve un fichero, para que la v2 pueda añadir las facturas sin cambiar el formato ni romper las copias antiguas.

El usuario elige dónde guardarlo mediante el selector del sistema, de modo que puede dejarlo en Drive, en la memoria del móvil o enviárselo a sí mismo. La importación valida la versión del esquema, avisa de que va a reemplazar los datos actuales y exige confirmación.

## 12. Pruebas

El motor de vencimientos se construye con los tests primero. Es lógica pura y sus casos se pueden fijar por escrito de antemano:

- Vencido por kilómetros pero no por fecha, y al revés.
- Ambos vencidos, comprobando que gana el más antiguo.
- Mantenimiento solo con intervalo de kilómetros, y solo con intervalo de tiempo.
- Ritmo desconocido, con una única lectura o con ninguna.
- Lecturas incoherentes, con un valor inferior al anterior.
- Coche parado durante meses.
- Mantenimiento sembrado sin registros posteriores.
- Cambio de año y de horario de verano en los cálculos de fechas.

Ahí es donde un fallo silencioso costaría un mantenimiento saltado, así que ahí va el esfuerzo. Se añaden tests de los DAOs de Drift y de las migraciones. La interfaz se comprueba a mano en el móvil.

## 13. Riesgos

**La estimación de kilómetros puede fallar.** Si el uso del coche cambia bruscamente, la fecha estimada se desvía. Se mitiga con el recordatorio periódico de lectura y marcando siempre las cifras estimadas con `≈`, para que nunca se confundan con un dato real.

**Android puede retrasar las notificaciones.** Con el modo inexacto y la optimización de batería, un aviso puede llegar horas más tarde. Es irrelevante para avisos de escala de días. Ajustes incluirá un acceso directo a la exclusión de optimización de batería por si algún aviso se retrasara demasiado.

**Datos solo en el móvil.** Si se pierde el teléfono sin copia reciente, se pierden los datos. Se mitiga recordando la copia de seguridad desde Ajustes cuando han pasado más de 90 días desde la última.

## 14. Requisitos previos de entorno

En el equipo actual no hay ni Flutter ni el SDK de Android, y el Java instalado es el 8. Antes de escribir código hay que instalar el JDK 17, el SDK de Android con sus herramientas de línea de comandos y el SDK de Flutter, y verificar que `flutter doctor` no reporta problemas. Es el primer bloque del plan de implementación.
