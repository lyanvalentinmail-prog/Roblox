# @ Movement Commands

Panel local en Luau con estética inspirada en Infinite Yield: consola gris oscura, cabecera arrastrable, lista de comandos desplazable, búsqueda al escribir, botones para minimizar/ocultar y barra de ejecución. No es una versión oficial de Infinite Yield.

## Estructura

- `commands/`: **16 comandos, cada uno en su propio ModuleScript**. Cada archivo devuelve `usage`, `description` y `run(ctx, args)`.
- `Main.client.lua`: GUI, registro de módulos y servicios compartidos de movimiento/limpieza.
- `Commands.client.lua`: versión autocontenida **generada**, para ejecutar sin un árbol de ModuleScripts.
- `tools/build.py`: empaquetador local sin dependencias externas.

Edita los comandos en `commands/` y regenera el archivo único:

```sh
python3 tools/build.py
python3 tools/build.py --check
```

Para agregar un comando, crea `commands/nombre.lua` con el mismo formato y vuelve a generar el archivo. La lista del GUI se construye automáticamente a partir de los módulos.

Úsalo únicamente en experiencias propias o con permiso. No incluye bypass de anticheat ni otorga permisos del servidor. La compatibilidad con Delta no se ha verificado: el servidor puede corregir o rechazar los cambios locales.

## Ejecución

**Archivo único:** coloca el contenido de `Commands.client.lua` en un **LocalScript** dentro de `StarterPlayer > StarterPlayerScripts` y ejecuta Play. También es autocontenido para un entorno que permita ejecutar Luau en el cliente; no descarga dependencias.

**Modo modular en Studio:** coloca `Main.client.lua` como LocalScript en `StarterPlayerScripts`. A su lado, crea una carpeta llamada `commands` y añade cada archivo de `commands/` como **ModuleScript**, con su nombre sin `.lua`. Ejecuta solo una de las dos variantes, no ambas.

El panel aparece al iniciar. Escribe un comando y pulsa **Ejecutar** o Enter. Acepta mayúsculas y los prefijos opcionales `;` y `!`. El botón **@** y RightShift muestran u ocultan el panel. La tecla `;` lo abre y enfoca la entrada. Al escribir se filtra la lista; al tocar una fila se prepara el comando para completarlo, **sin ejecutarlo todavía**. Pulsa `>` o Enter para ejecutar. Arrastra la cabecera para mover el panel; `−` minimiza y `×` oculta (no descarga el script).

| Comando | Efecto |
| --- | --- |
| `fly [velocidad]` | Vuelo del personaje; velocidad inicial 60 |
| `unfly` | Detiene cualquier vuelo |
| `vehiclefly [velocidad]` | Vuelo de la estructura del vehículo donde estás sentado |
| `unvehiclefly` | Detiene el vuelo |
| `flyspeed N` | Velocidad de vuelo de 1 a 500 |
| `speed N` | WalkSpeed de 0 a 500 |
| `jumppower N` | JumpPower de 0 a 500; activa UseJumpPower |
| `gravity N` | Gravedad local de 0 a 1000 |
| `noclip` / `clip` | Desactiva / restaura las colisiones originales del personaje |
| `infinitejump` / `uninfinitejump` | Activa / desactiva salto en el aire |
| `reset` | Desactiva modos y restaura valores iniciales |
| `help` | Ayuda de controles |
| `hide` | Oculta el panel |
| `unload` | Restaura valores, desconecta eventos y elimina la interfaz |

### Controles de vuelo

- PC: WASD, Espacio para subir y Ctrl izquierdo para bajar.
- Móvil: joystick para movimiento horizontal y salto para subir. Para bajar, detén el vuelo con `unfly`; no hay botón táctil dedicado de descenso.
- Los controles de vuelo se pausan mientras escribes en una caja de texto.
- Vehiclefly necesita un asiento y una estructura sin anclar. Solo funciona si el cliente tiene autoridad física sobre esa estructura; no intenta obtenerla por la fuerza.

### Ciclo de vida

Speed y JumpPower personalizados se reaplican tras reaparecer. Noclip e infinitejump permanecen activos hasta desactivarlos. El vuelo se detiene al morir, reaparecer o abandonar el vehículo. Volver a ejecutar el script limpia la instancia anterior. `reset` restaura velocidad y salto capturados al aparecer, y gravedad capturada al iniciar el panel.

## Prueba manual en Studio

1. Ejecutar en Play y comprobar que aparece un solo panel.
2. Probar `fly 60`, WASD, Espacio y Ctrl; escribir mientras vuelas y comprobar que no te desplazas. Ejecutar `unfly`.
3. Probar `speed 32`, `jumppower 80`, `gravity 100` y luego `reset`.
4. Probar `noclip` contra una pared y `clip` para recuperar las colisiones.
5. Activar `infinitejump`, saltar repetidamente y desactivarlo.
6. Sentarse en un vehículo sin anclar y probar `vehiclefly`; salir del asiento para detenerlo.
7. Reaparecer, volver a ejecutar el script y probar `unload`: no deben quedar fuerzas ni interfaces duplicadas.
8. Probar valores inválidos como `speed abc`, `gravity -1` y `fly 9999`: deben mostrar un error sin cerrar el panel.

No se dispone de Roblox Studio ni Delta en este entorno; estas pruebas requieren ejecutarse allí.

### Comprobaciones del nuevo GUI

- Filtrar `fly`: deben aparecer fly, flyspeed, unfly, vehiclefly y unvehiclefly.
- Seleccionar `speed`, completar `32` y ejecutar con Enter y con `>`.
- Minimizar y restaurar; ocultar con `×` y recuperar con `@`.
- Arrastrar la cabecera con ratón y en una pantalla táctil.
- Añadir un módulo y verificar que aparezca automáticamente tras regenerar.

La sintaxis de los 18 archivos Lua se validó con luaparse (Lua 5.3); eso no sustituye una prueba de las APIs de Roblox ni confirma compatibilidad con Delta.

## Panel v2: parámetros, alias y chat

La entrada admite parámetros posicionales o nombrados (no ambos a la vez):

```text
fly 80
fly --velocidad=80
vehiclefly --velocidad 60
speed --valor=32
jumppower --valor 90
gravity 100
noclip on
noclip off
infinitejump off
help speed
speed --help
```

Los parámetros numéricos mantienen los límites de la tabla anterior. Se rechazan valores ausentes, no numéricos, fuera de rango, nombres de parámetros desconocidos y argumentos sobrantes. `fly` y `vehiclefly` sin valor conservan la velocidad de vuelo actual. `noclip` e `infinitejump` sin argumento activan el modo.

Alias: `v` → fly, `vfly` → vehiclefly, `fs` → flyspeed, `ws` → speed, `jp` → jumppower, `grav` → gravity. Solo el nombre del comando ignora mayúsculas; los argumentos no se convierten indiscriminadamente.

### Chat

- **TextChatService (chat moderno):** `/fly 80`, `/ws 32`, `/noclip off`, `/help speed`. Se registran TextChatCommand locales con alias y se comprueba que el emisor sea el jugador local. Los slash commands reconocidos no son mensajes de chat ordinarios. Su disponibilidad efectiva depende del entorno y la configuración del chat; debe probarse en Roblox.
- **Chat clásico:** `;fly 80` o `!speed 32`, escuchando únicamente `LocalPlayer.Chatted`. Esos mensajes pueden ser visibles para otros jugadores; no se promete ocultarlos.
- No se escuchan simultáneamente ambos sistemas para evitar ejecuciones duplicadas. El script no ejecuta mensajes de otros jugadores ni otorga permisos de administración sobre ellos.
- `unload` elimina los comandos de chat creados y desconecta sus eventos.

### Interfaz

- Filtrado por nombre, descripción y alias, con contador de coincidencias.
- Filas con sintaxis y descripción; seleccionarlas prepara la entrada sin ejecutar.
- Tab completa la primera coincidencia visible, ↑/↓ recorre hasta 50 entradas de historial y Escape quita el foco.
- Barra de estado para errores y ayuda por comando, nuevo contraste oscuro y borde azul tenue.
- Se conservan arrastre, minimizar, ocultar, botón táctil @ y RightShift.

### Validación v2

`tools/test_commands.py` ejecuta el dispatcher real y los módulos con un estado simulado (requiere `lupa`). Incluye 21 casos de parámetros posicionales/nombrados, alias, límites, errores, toggles y ayuda. No simula la física, la interfaz ni el chat de Roblox.

```sh
python3 -m venv .cache/test-env
.cache/test-env/bin/pip install lupa
.cache/test-env/bin/python tools/test_commands.py
python3 tools/build.py --check
```

Prueba manual adicional: enviar `/fly 80` y `/unfly` en el chat moderno; comprobar que un mensaje ajeno no modifica tu estado; ejecutar `unload` y verificar que los slash commands desaparecen. En otra experiencia configurada con chat clásico, probar `;speed 32`. Verificar también Tab, historial, búsqueda por alias y `speed --help`. Estas pruebas de integración siguen pendientes.
