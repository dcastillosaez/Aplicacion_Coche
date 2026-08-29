# Exportar e importar un vehículo

## 1. Por qué esto ahora

El diseño original de la v1 (`2026-08-09-app-mantenimiento-vehiculos-design.md`, sección 11) ya prometía copia de seguridad exportable, y la aplicación arrastra las señales de esa promesa sin cumplirla: `Settings.fechaUltimaCopia` existe en el esquema desde la fase 1 y nadie lo escribe nunca; `PhotoStorage` guarda rutas relativas explícitamente "para que la copia de seguridad en zip sea portable entre dispositivos"; la fila "Exportar copia de seguridad" de Ajustes solo muestra un `SnackBar` de función pendiente.

Esta fase no cierra esa promesa entera. Cierra una pieza distinta y más concreta: poder sacar **un vehículo suelto** de la aplicación, con todo su historial, y meterlo en otra instalación. El caso de uso que lo justifica es pasar un coche a otro móvil o a otra persona, no respaldar la aplicación completa.

Esa diferencia manda sobre casi todas las decisiones de aquí en adelante. Un respaldo se restaura en la misma aplicación que lo creó, sobre una base de datos que se va a reemplazar entera. Un vehículo exportado aterriza en un dispositivo ajeno, con sus propios coches dentro, con una versión de la aplicación que puede ser distinta, y sin permiso para tocar nada más que lo que trae.

## 2. Qué no entra

- **La copia de seguridad completa sigue pendiente.** No se implementa, y la fila de Ajustes que la anuncia se queda exactamente como está, con su `SnackBar`.
- **`Settings.fechaUltimaCopia` no se toca.** Exportar un coche no es un respaldo de la aplicación; marcarlo como tal haría que Ajustes mintiera sobre cuándo se hizo la última copia real.
- **Los ajustes globales no viajan** en el fichero. Márgenes de aviso por defecto, tema y recordatorio de lectura son del dispositivo, no del coche. Los márgenes propios de cada mantenimiento (`avisoKm`, `avisoDias`) sí viajan, porque son del mantenimiento.
- **No hay fusión de historiales.** Si el coche ya existe en el destino, se crea otro aparte o se reemplaza el existente. Comparar registros por fecha para mezclar dos historiales es con diferencia lo más difícil de hacer bien y de probar, y no resuelve el caso que motiva esta fase.
- **No se exporta a un formato legible fuera de la aplicación.** El fichero es para la aplicación. Imprimir o consultar el historial en el ordenador es otra necesidad y otra fase.
- **No hay migración de esquema.** Nada de esto añade ni cambia columnas.

## 3. El fichero

Un `.zip` con tres cosas:

```
manifest.json     versión de formato, aplicación, fecha, resumen legible
vehiculo.json     todos los datos
fotos/            la foto del coche, si tiene
```

El manifest va aparte y es diminuto a propósito: el importador lo lee primero y decide si sabe leer el resto antes de cargar nada más.

```json
{
  "app": "car_care",
  "formato": 1,
  "exportadoEn": "2026-08-28T17:04:11.000Z",
  "vehiculo": "Seat León 1.6 TDI"
}
```

`formato` es una versión **propia del fichero**, independiente del `schemaVersion` de Drift. Son dos cosas distintas y confundirlas ata el fichero a un detalle interno de la base de datos: el esquema puede subir de versión sin que cambie nada de lo que se exporta, y el formato puede cambiar sin tocar el esquema.

### 3.1 Estructura de `vehiculo.json`

- `vehiculo` — marca, modelo, versión, año, matrícula, combustible, fecha de matriculación, color y su tono, VIN, notas y `creadoEn`. Sin `id`. Sin `archivado`: un coche importado entra siempre como activo. `fotoPath` se reduce al nombre del fichero dentro de `fotos/`.
- `especificaciones` — la ficha técnica completa, o `null` si el coche no tiene.
- `mantenimientos` — cada uno con nombre, categoría, intervalos, márgenes propios, activo, silenciado, orden, fuente del intervalo, tipo, posición y `nombreAutogenerado`, **con sus registros anidados dentro**.
- `registrosSueltos` — las reparaciones puntuales sin mantenimiento asociado, las que hoy tienen `scheduleId` nulo.
- `lecturas` — kilometraje: fecha, km y origen.

Anidar los registros dentro de su mantenimiento es la decisión que hace todo lo demás sencillo: en el fichero no aparece ni un solo identificador de base de datos, así que al importar no hay nada que remapear y no existe la clase de fallo "el registro apunta a un mantenimiento que no es". La relación se reconstruye por la propia estructura del JSON.

### 3.2 Convenios de serialización

- **Fechas**: ISO 8601 en UTC, terminadas en `Z`. Se convierten a hora local al importar. Guardarlas con la hora local del emisor haría que un coche exportado en España y abierto en otro huso cambiara de día en el historial.
- **Enums**: por su nombre, igual que los guarda `textEnum` en la base de datos.
- **Importes**: número JSON con punto decimal, no cadena formateada.

### 3.3 Tolerancia entre versiones

El fichero puede viajar a un dispositivo con una versión distinta de la aplicación, así que la regla general al leer es: **campo desconocido, se ignora; campo ausente, valor por defecto**. Con eso, una versión nueva lee ficheros viejos y una vieja lee ficheros nuevos perdiendo solo lo que no entiende.

La excepción son los tres enums que la base de datos exige y no admiten nulo: `combustible` del vehículo, `categoria` del mantenimiento y `origen` de la lectura. Si traen un valor que esta versión no conoce, no hay ningún valor por defecto honesto que inventar, así que el fichero se rechaza con un mensaje claro. Es mejor no importar que importar un coche de gasolina como si fuera diésel.

## 4. Arquitectura

Tres piezas, una por capa, para que lo que puede fallar de verdad se pueda probar sin base de datos ni sistema de ficheros:

| Fichero | Capa | Responsabilidad |
|---|---|---|
| `lib/domain/exportacion/paquete_vehiculo.dart` | dominio | Las clases del fichero y su conversión desde y hacia JSON, con todas las validaciones de contenido. Dart puro: ni Drift ni Flutter. |
| `lib/data/exportacion/ensamblador_paquete.dart` | datos | Traduce en ambos sentidos entre los objetos de Drift y el paquete del dominio. |
| `lib/data/exportacion/archivo_paquete.dart` | datos | El zip y las fotos: escribir y leer `manifest.json`, `vehiculo.json` y los ficheros de imagen. |

El dominio no conoce Drift, así que el ensamblador es quien lee de los DAOs y construye las clases puras, y quien a la vuelta las convierte en `Companion` para insertarlas. Esa frontera es la misma que ya respeta el resto del proyecto y la que permite que la mayoría de los tests de esta fase no necesiten abrir nada.

## 5. Exportación

Se pulsa desde el detalle del vehículo. El `AppBar` ya lleva dos iconos —identidad técnica y editar— y un tercero lo satura, así que se añade un menú de tres puntos con "Exportar vehículo", que además deja sitio para lo que venga después.

El flujo:

1. Se borra la carpeta temporal de exportaciones anteriores y se genera el zip ahí.
2. El nombre del fichero se compone de marca, modelo, matrícula si la hay y fecha, sin acentos ni espacios: `seat-leon-1234abc-20260828.zip`.
3. Se abre la hoja de compartir de Android con ese fichero. Desde ahí el usuario elige WhatsApp, Drive, correo o guardarlo en Archivos.
4. `SnackBar` de confirmación.

Los criterios ya asentados en el proyecto se aplican tal cual: guarda de reentrada en el menú para que dos toques rápidos no lancen dos exportaciones, `if (!mounted) return;` después de cada `await`, y la escritura dentro de `try`/`catch` con mensaje en español para el usuario y el detalle técnico solo por `debugPrint`.

## 6. Importación

Se pulsa desde Ajustes, sección Datos, en una fila nueva "Importar vehículo" junto a la de copia de seguridad.

El selector del sistema se abre **sin filtrar por extensión**, y la validación se hace por contenido. Filtrar por tipo MIME es peor de lo que parece: muchos gestores de archivos de Android entregan un `.zip` como `application/octet-stream`, y el único efecto del filtro sería que el fichero correcto apareciera en gris.

El orden importa, y la regla es que **no se escribe nada hasta que el usuario confirma**:

1. Se lee `manifest.json`. Si el formato es más nuevo que el que entiende esta versión: "Este fichero se creó con una versión más reciente de la aplicación". Si no es un zip válido o le falta el manifest: "El fichero está dañado o no es una exportación de Mis Vehículos".
2. Se interpreta `vehiculo.json` entero en memoria, con todas sus validaciones, antes de tocar la base de datos.
3. **Vista previa** en un diálogo: marca, modelo, matrícula, cuántos mantenimientos, cuántos registros de historial, cuántas lecturas, si trae foto y cuándo se exportó. Como el fichero puede venir de otra persona, se ve qué se va a meter antes de meterlo.
4. **Detección de duplicado** contra todos los coches del dispositivo, archivados incluidos: primero por VIN y, si el fichero no trae VIN, por matrícula. En ambos casos normalizando mayúsculas, espacios y guiones, porque "1234 ABC" y "1234-abc" son el mismo coche.
5. Si hay coincidencia, el diálogo ofrece tres salidas: crear otro coche aparte, reemplazar el existente advirtiendo de que se borra su historial, o cancelar. La aplicación no decide sola en ningún caso.
6. **Escritura** completa dentro de `db.transaction(...)`: vehículo, ficha técnica, mantenimientos, sus registros y las lecturas. En modo reemplazo, el borrado del coche existente entra en la misma transacción y el `onDelete: cascade` del esquema se lleva por delante mantenimientos, registros, lecturas y ficha técnica.
7. Al terminar, se **reprograman las notificaciones**. Un coche importado puede traer mantenimientos ya vencidos, y sin este paso no avisarían hasta el siguiente arranque de la aplicación.

### 6.1 La foto y la transacción

La foto se copia al almacenamiento de la aplicación **antes** de abrir la transacción, porque hace falta su ruta relativa para insertar el vehículo. Eso rompe la atomicidad en un punto: si la transacción falla después, queda un fichero huérfano. Se resuelve borrando la copia en el `catch`, que es el único orden posible sin inventar rutas antes de tenerlas.

La foto importada recibe un nombre nuevo basado en la marca de tiempo, como hace hoy `vehicle_form_screen.dart`, para no pisar una foto existente que se llame igual.

### 6.2 Validar contenido, no solo sintaxis

Un fichero editado a mano o corrompido no puede reventar a mitad de la transacción, así que al interpretarlo se rechaza todo lo que la base de datos no aceptaría, y se rechaza antes de escribir:

- Marca o modelo vacíos, o de más de 60 caracteres; nombre de mantenimiento vacío o de más de 80. Son los límites que ya declaran las tablas.
- Kilómetros negativos, en lecturas o en registros.
- Un mantenimiento sin ningún intervalo, ni de kilómetros ni de meses. El formulario lo impide desde la fase 2 —la comprobación vive ahí porque SQLite no puede expresarla sin un `CHECK` que complicaría las migraciones—, pero un fichero no pasa por el formulario.
- Lecturas con fecha repetida dentro del propio fichero: se deduplican al leer, quedándose con la última. Si no, chocarían contra la clave única `{vehicleId, fecha}` con media importación ya escrita.

## 7. Dependencias nuevas

Tres, y ninguna sustituible por lo que ya hay en el proyecto:

- `archive` — generar y leer el zip. Dart puro, sin código nativo.
- `share_plus` — la hoja de compartir de Android.
- `file_picker` — el selector de fichero al importar.

La aplicación sigue sin permiso de internet. Ninguna de las tres lo necesita.

## 8. Pruebas

En el dominio, sin base de datos ni ficheros, que es donde vive casi todo lo que puede fallar:

- Ida y vuelta completa: un paquete con todos los campos rellenos sobrevive a `toJson` y `fromJson` sin perder nada.
- Un JSON con campos desconocidos se lee ignorándolos.
- Un JSON al que le faltan campos opcionales se lee con sus valores por defecto.
- Un enum obligatorio con valor desconocido se rechaza.
- Un mantenimiento sin intervalos se rechaza.
- Lecturas con fecha duplicada se deduplican.
- JSON corrupto y manifest ausente se rechazan con el error esperado.

En la capa de datos, el test que de verdad cubre esta fase de punta a punta: montar un coche con ficha técnica, mantenimientos, registros y lecturas en una base en memoria, exportarlo a zip, leerlo e importarlo en **otra** base, y comparar campo a campo. Más un caso de reemplazo que compruebe que el coche viejo desaparece entero y no deja mantenimientos ni lecturas huérfanas.

En la interfaz, siguiendo el patrón de `test/ui/`: el menú del detalle ofrece "Exportar vehículo", y el diálogo de duplicado ofrece las tres salidas. Los tests de widget sobrescriben el provider de datos en vez de abrir una base Drift real, porque los streams de Drift dejan temporizadores vivos que rompen `testWidgets`.

## 9. Riesgos asumidos

**El fichero no está cifrado ni firmado.** Contiene matrícula, VIN y el historial del coche. Quien reciba el zip puede leerlo y editarlo con cualquier descompresor. Es aceptable porque el fichero solo existe cuando el usuario decide compartirlo y va donde él lo manda, pero conviene tenerlo escrito: la validación de la sección 6.2 protege a la aplicación de un fichero manipulado, no protege el contenido de quien lo tenga.

**El formato queda congelado en cuanto exista el primer fichero exportado.** A partir de ahí, cualquier cambio en `vehiculo.json` tiene que seguir leyendo los ficheros de formato 1. La regla de la sección 3.3 es lo que hace ese compromiso soportable, y es la que hay que respetar al añadir campos: nuevos campos siempre opcionales, nunca obligatorios.
