# Log — endurecimiento de compuerta y corrección sistémica (v5), sesión 2

Encargo: `50_documentacion/andamios/20260826_encargo_endurecimiento_v5.md`.
Ejecutado el 2026-08-27 en modo autónomo, secuencial, en un solo turno.
Orden pedido y cumplido: FASE 0 → T4 → T3 → T1 (con panel) → T2.
**La sesión NO se cierra: `ESTADO.md` no se tocó** (verificado: `git status --porcelain --
50_documentacion/activa/ESTADO.md` vacío; sigue con `sesion_abierta: true` y
`commit_cierre: 358e150`).

## 1. Resumen de la sesión

Las cuatro tareas se ejecutaron completas. Ninguna quedó congelada. Ninguna de las siete
condiciones de detención se disparó.

- **T4** puso al día un comentario que dejaba un pendiente inexistente en el archivo más
  leído del pipeline.
- **T3** re-clasificó la clase B por univocidad y el resultado cambia cómo hay que leerla:
  de 91 accesos, **ninguno muerde hoy** y la lista de vigilancia real baja de 86 a **9**.
- **T1** cerró las cinco medidas aprobadas sobre la compuerta de firma. De los 25 casos de
  conducta medidos, **17 cambiaron de veredicto** y las 22 piezas reales no cambiaron
  ninguno.
- **T2** dejó la coincidencia parcial de nombres visible en todo el proyecto y la convirtió
  en fallo de la corrida, con un mecanismo que **no depende del idioma en que R hable**.

Lo que sorprendió está en §10, y no es poco: el mensaje de estas advertencias está
traducido, y el diseño obvio (un patrón de texto escrito a mano) habría producido una
compuerta que se apaga sola en el runner de CI sin decirlo.

## 2. Inventario de commits

| Commit | Mensaje | Numstat |
|---|---|---|
| `ae44b64` | `docs(andamios): encargo v5` | 118 / 0 en el encargo |
| `e48f3b0` | `docs(codigo): comentario de 32_segmentar al dia con 851f021 y 81179e3` | 3 / 4 en `30_procesamiento/32_segmentar_articulos.R` |
| `c00e31a` | `docs(andamios): clase B reclasificada por univocidad` | 340 / 0 en el producto de T3 |
| `31ef7b7` | `fix(sitio): compuerta de firma endurecida segun 10.5 (duda 1 de v4)` | 143 / 15 en `30_procesamiento/34_generar_paginas.R` |
| `8ba40c1` | `feat(config): coincidencia parcial promovida a error del pipeline` | 69 / 1 en `00_run_all.R`; 9 / 0 en `10_utils/10_configuracion.R` |

`HEAD` = `8ba40c170f44e5b681e245e0ba1b0f7121da8de6`. Árbol limpio (`git status --porcelain`
vacío). Sin push todavía.

## 3. FASE 0 — medición

| # | Qué | Medido |
|---|---|---|
| 1 | Porcelain y sincronía | única entrada `??` era este encargo → commiteado como `ae44b64` y se siguió. `HEAD` == `origin/main` == `3c3ea0d` al abrir |
| 2 | `ESTADO.md` | `sesion_abierta: true`, `commit_cierre: 358e150` (vive en `50_documentacion/activa/`, no en la raíz) |
| 3 | Piezas | **22**, todas `tipo` correcto y `estado: borrador` como `character`; **0** con `validado_por` no-carácter (las 22 declaran la clave con valor `null`); **0** con `archivo`/`cuerpo` en el front matter. **Premisa de la condición 3 confirmada** |
| 4 | `options(` | **0** en `10_configuracion.R`, `10_utils.R` y `00_run_all.R`, y **0 en todo el repo** (barrido ampliado por cuenta propia) |
| 5 | Comentario obsoleto | `30_procesamiento/32_segmentar_articulos.R:436-439`, localizado por contenido |
| 6 | Clase B re-anclada | ver §4.2: v3 contaba **líneas**, no accesos |
| 7 | Línea base de `40_salidas/` | **28** archivos versionados; sha256 del conjunto de hashes: `25eec8681b8dd12eb693d82cfc14a8b646efb1f7b45e065fe87ca3cd7c7c2c71` |

## 4. Cambios sustantivos

### 4.1 T4 — El comentario que prometía un pendiente inexistente

`32_segmentar_articulos.R` decía que `estado_curado()` en `00_ocr_documentos.R` quedaba
«fuera del alcance» y «conviene alinearlo». Estaba alineado desde `851f021`, y `81179e3`
convirtió además sus lecturas del manifiesto. Antes de reescribirlo se verificaron los tres
hechos, no se aceptaron del log v4:

- `00_ocr_documentos.R:96-101` usa `[[ ]]`;
- `git show --stat 851f021` toca solo `00_ocr_documentos.R`, y `81179e3` igual;
- barrido propio: **no queda ninguna lectura del archivo de curaduría por `$`** en el
  proyecto (los cuatro scripts que abren `metadatos_curados.json` y el que abre las piezas
  usan todos `[[ ]]`; la única aparición de `curado$anio` está dentro de un comentario).

El comentario nuevo dice eso y nada más. Verificación: diff acotado a esas líneas (3 / 4),
`parse()` limpio.

### 4.2 T3 — La clase B, re-anclada y re-clasificada

Producto: **`50_documentacion/andamios/20260826_reclasificacion_clase_b_v1.md`** (340
líneas), que reemplaza a la clasificación de v3 como insumo del traspaso v02.

**El re-anclaje empezó por averiguar en qué unidad contaba v3**, porque el número no
cuadraba. La respuesta está en la propia tabla de la auditoría: su columna se titula
«Líneas». Medido en las dos unidades sobre el árbol de la auditoría (`7cc6fb6`) y sobre el
de hoy, con el criterio de v3 (nueve claves, seis archivos, excluidos los objetos de pieza
que son clase A):

| Archivo | v3 declaró | Líneas en `7cc6fb6` | Líneas hoy | Accesos hoy |
|---|---:|---:|---:|---:|
| `34_generar_paginas.R` | 41 | **37** | 33 | 39 |
| `33_relaciones.R` | 20 | 20 ✓ | 20 | 23 |
| `32_segmentar_articulos.R` | 15 | 15 ✓ | 15 | 17 |
| `00_generar_borradores.R` | 7 | 7 ✓ | 7 | 9 |
| `10_utils/10_utils.R` | 2 | 2 ✓ | 2 | 2 |
| `31_extraer_texto.R` | 1 | 1 ✓ | 1 | 1 |
| **Total** | **86** | **82** | **78** | **91** |

Cinco de los seis archivos reproducen la cifra de v3 exactamente. El sexto no (41 declaradas
frente a 37 medidas sobre su propio árbol) y esas 4 líneas **no se reconstruyen** desde el
documento de v3, que no las enumera: quedan registradas como diferencia sin explicar, no
racionalizadas. Entre `7cc6fb6` y hoy el único archivo que se movió es
`34_generar_paginas.R`, que es el que T1 de v4 convirtió.

**El clasificador tiene dos ejes** (presencia, medida sobre los datos; hermandad, medida
sobre el universo de claves del esquema) y un orden de decisión declarado: la protección
**estructural** se resuelve antes que la **contingente**. Categorías y resultado:

| Cat. | Regla | Accesos |
|:---:|---|---:|
| **iii** | dos o más hermanas: la ambigüedad protege | **7** |
| **0** | ninguna hermana: no hay a qué resolver | **75** |
| **i** | una hermana y clave presente al 100%: seguro solo mientras el escritor coopere | **9** |
| **ii** | una hermana y la clave puede faltar: **muerde** | **0** |

La categoría **(0)** no estaba en la taxonomía de tres del encargo. Se declaró en vez de
plegarla a (i), porque son 75 de 91 y describirlos como «seguros mientras el escritor
coopere» sería falso: son seguros pase lo que pase con el escritor. Queda como duda de
forma (§8, D-f).

**Calibración, en dos niveles, y sin ella no se reporta la tabla:**

- Nivel 0, la conducta de `$` en este intérprete, medida: clave exacta gana; clave exacta
  **con valor `null`** bloquea la parcial; ausente con **1** hermana **muerde**; ausente con
  2 o con 0 hermanas devuelve `NULL`.
- Nivel 1, los tres casos conocidos: `anio`/`anios_alternativos` en la curaduría → **(ii)**
  (presente 4/10); `paginas` en el manifiesto OCR → **(iii)** (hermanas `paginas_pdf` y
  `paginas_vacias`); `anio` en el objeto-norma → **(i)** (25/25). Los tres reproducen.

**Anexo declarado**: 32 accesos más sobre los sub-objetos `vigencia` y `grupo_acto`, que la
lista de v3 no cubría. Los 32 caen en (0), pero el hallazgo es otro: `vigencia` es el
**único** lugar del esquema derivado donde una clave falta de verdad (`sustituido_por` y
`fuente` están en 1 de 25), así que ahí no protege la presencia sino solo que ningún nombre
extienda a otro.

### 4.3 T1 — La compuerta de firma, endurecida

**Paso 0.** Un arnés reprodujo la tabla COMPLETA de la Duda 1 sobre el código real, no
sobre un modelo: extrae `leer_pieza()`, `cargar_piezas()`, `pagina_pieza()` y compañía del
árbol de parseo del archivo y las ejecuta contra piezas sintéticas, sustituyendo solo
`ruta_insumos`. Resultado: **25 de 25 casos coinciden con la tabla del log v4**, incluidas
las tres familias del panel. El punto de partida quedó confirmado antes de tocar nada.

**Las cinco medidas**, con diseño propio dentro de los resultados obligatorios:

- **(a)** `escalar_texto()` exige `is.character` + longitud 1 + no `NA`; sobre eso,
  `nzchar(trimws())` y **al menos una letra**. La longitud 1 no estaba en la letra del
  encargo y se añadió: un `validado_por: [Ana, Beto]` recicla en `sprintf()` y duplica el
  párrafo de firma.
- **(b)** `firmada()` envuelve todo en `isTRUE()` y es total: no puede devolver `NA`.
- **(c)** `leer_pieza()` rechaza `archivo` y `cuerpo` en el front matter, y además exige que
  el front matter sea una lista de `campo: valor` (una secuencia YAML o un escalar no traen
  `tipo`, y sin esa comprobación reventaban aguas abajo con un error de subíndice).
- **(d)** `estado` se normaliza con `tolower(trimws())` tras validarlo; fuera de
  {`borrador`, `validada`} aborta.
- **(e)** falta de `tipo` o de `estado` aborta en la compuerta.


**La tabla completa antes / después**, medida por el mismo arnés sobre los dos árboles.
25 casos; **17 cambian de veredicto, 8 se mantienen**:

| # | Front matter probado | Antes (v4) | Después (v5) | |
|---|---|---|---|:-:|
| 01 | `estado validada + firma valida` | PUBLICA | **PUBLICA** | = |
| 02 | `estado validada, sin validado_por` | ABORTA | **ABORTA** | = |
| 03 | `estado validada, validado_por vacio` | ABORTA | **ABORTA** | = |
| 04 | `estado validada, validado_por ~` | ABORTA | **ABORTA** | = |
| 05 | `estado validada, clave prefijada (O5)` | ABORTA | **ABORTA** | = |
| 06 | `estado borrador + firma valida` | OMITE | **OMITE** | = |
| 07 | `SIN clave estado` | OMITE | **ABORTA** | **→** |
| 08 | `estado: Validada (mayuscula)` | OMITE | **PUBLICA** | **→** |
| 09 | `estado: ' validada ' (espacios)` | OMITE | **PUBLICA** | **→** |
| 10 | `tipo desconocido (minuta)` | ABORTA | **ABORTA** | = |
| 11 | `SIN clave tipo` | REVIENTA-DESPUES | **ABORTA** | **→** |
| a1 | `validado_por: no` | PUBLICA | **ABORTA** | **→** |
| a1 | `validado_por: off` | PUBLICA | **ABORTA** | **→** |
| a1 | `validado_por: false` | PUBLICA | **ABORTA** | **→** |
| a1 | `validado_por: N` | PUBLICA | **ABORTA** | **→** |
| a2 | `validado_por: true` | PUBLICA | **ABORTA** | **→** |
| a3 | `validado_por: 0` | PUBLICA | **ABORTA** | **→** |
| a3 | `validado_por: 12345` | PUBLICA | **ABORTA** | **→** |
| a4 | `validado_por: "null"` | PUBLICA | **PUBLICA** | = |
| a5 | `validado_por: .nan` | PUBLICA | **ABORTA** | **→** |
| a6 | `validado_por: 2026-08-26` | PUBLICA | **ABORTA** | **→** |
| b1 | `validado_por: []` | OMITE | **ABORTA** | **→** |
| b2 | `validado_por: {}` | OMITE | **ABORTA** | **→** |
| c1 | `front matter declara cuerpo` | PUBLICA | **ABORTA** | **→** |
| c2 | `front matter declara archivo` | PUBLICA | **ABORTA** | **→** |

Criterios de éxito del encargo, comprobados uno a uno por el arnés:

| Criterio | Resultado |
|---|:---:|
| todo valor **no-carácter** de `validado_por` ABORTA (`no`, `off`, `false`, `N`, `true`, `0`, `12345`, `.nan`, `2026-08-26`) | **OK** |
| `[]` y `{}` ABORTAN | **OK** |
| el secuestro de `archivo`/`cuerpo` ABORTA | **OK** |
| `Validada` y `" validada "` se aceptan normalizadas | **OK** |
| sin `tipo` o sin `estado` ABORTA en la compuerta | **OK** |
| el caso legítimo (nombre real + fecha) publica | **OK** |
| `borrador` sigue en borrador | **OK** |

**Residuo declarado, no tapado.** El encargo pide que «los seis valores no-carácter
ABORTEN». Los valores no-carácter de esa tabla son **cinco filas** y las cinco abortan. La
sexta, `validado_por: "null"` **entrecomillado**, es un valor *carácter* con letras, y la
regla (a) —«texto, no vacío, con al menos una letra»— no puede distinguirlo de un apellido.
Sigue publicando. No se añadió una lista negra de literales porque eso es una regla nueva y
no una de las cinco aprobadas; queda como duda (§8, D-b).

**El secuestro, demostrado sobre el código anterior** (no argumentado): con
`cuerpo: "TEXTO INYECTADO"` en el front matter, `names(p)` daba
`tipo | estado | validado_por | cuerpo | archivo | cuerpo`, `p[["cuerpo"]]` devolvía el
texto del YAML, y la página generada traía el texto inyectado y **no** el cuerpo revisado.
Con la compuerta nueva, aborta.

**Regeneración.** `Rscript 00_run_all.R`, única vía usada. Log: «Piezas interpretativas: 22
en total, 0 validadas y publicables», idéntico antes y después. Los **28** archivos
versionados de `40_salidas/` quedaron **byte a byte idénticos** a la línea base (28 de 28
`OK` con `shasum -c`). Cero páginas `pieza-*.qmd` y cero `pieza-*.html`. `20_insumos/` sin
un solo cambio en toda la cadena.

### 4.4 T2 — La coincidencia parcial deja de ser silenciosa

**Las opciones**, en `10_utils/10_configuracion.R`, junto a la guarda de locale porque son
la misma clase de cosa (un invariante del entorno de ejecución que se fija al arrancar):
`options(warnPartialMatchDollar = TRUE, warnPartialMatchArgs = TRUE, warnPartialMatchAttr = TRUE)`.

**El mecanismo de elevación, y por qué no es el obvio.** El encargo ofrecía dos caminos y
pedía elegir con evidencia.

*Elegido:* `withCallingHandlers` alrededor de la ejecución de cada paso, en `00_run_all.R`
(`ejecutar_paso()`), que promueve a error **solo** las advertencias de coincidencia parcial.

*Descartado:* un recuento al final de `run_all()` que aborte si el contador es > 0. Se
descartó con razón concreta: para cuando el contador se lee, el pipeline ya escribió
`40_salidas/` con el valor equivocado dentro. La promoción falla **antes** de que el valor
viaje. La ventaja del recuento —ver todos los accesos de una vez— no compensa publicar un
dato incorrecto y enterarse después.

**El hallazgo que cambió el diseño: el mensaje está traducido.** Medido en R 4.5.2:

| Idioma | `$` parcial | argumento / atributo parcial |
|---|---|---|
| es | `encuentros parciales de 'anio' to 'anios_alternativos'` | `argumentos parcialmente correctos de 'verb' a 'verbose'` |
| en | `partial match of 'anio' to 'anios_alternativos'` | `partial argument match of 'verb' to 'verbose'` |

La condición de la advertencia es `simpleWarning` a secas: no hay clase por la que filtrar.
Escribir el patrón a mano habría atado la compuerta a una locale y la habría convertido en
**un no-op silencioso** en cuanto el runner hablara otro idioma, que es exactamente la clase
de fallo que esta opción existe para impedir. El workflow declara `LANG: es_ES.UTF-8`, pero
si el runner no tiene instaladas las traducciones de R, R responde en inglés igual.

Por eso el prefijo **se deriva**: al arrancar, `derivar_prefijos_parciales()` provoca las
tres coincidencias parciales sobre nombres de sonda y se queda con lo que R responda hasta
la primera comilla. Y si R **no** avisa ante una coincidencia provocada a propósito, la
función aborta: una compuerta desarmada que no lo dice es peor que no tenerla.

**Verificación en tres frentes, todos previos al commit.**

*1. Demostración positiva.* Un paso de juguete bajo `/tmp/slep_v5_scratch/juguete/` que
reproduce el defecto del DFL 1 (`curado <- list(anios_alternativos = 1996L); curado$anio`),
ejecutado por el `ejecutar_paso()` real. Falla, y señala el acceso:

```
coincidencia parcial de nombres.
  Aviso de R: encuentros parciales de 'anio' to 'anios_alternativos'
  Llamada:    curado$anio
  La clave exacta no estaba y R devolvió otra que la tiene por comienzo.
  Cambia ese acceso a [[ ]], que no adivina.
```

Control negativo en el mismo arnés: un paso con `as.integer("no es un numero")`, `log(-1)`
y un `warning()` propio **no** falla. Condición 6 satisfecha con evidencia, no por diseño.

Y las tres corridas, en tres idiomas:

| Entorno | Prefijos derivados | Juguete | Advertencias ajenas |
|---|---|---|---|
| locale del titular (`LC_MESSAGES=es_ES.UTF-8`) | `encuentros parciales de `, `argumentos parcialmente correctos de ` | **falla** | no falla |
| `LANGUAGE=en` | `partial match of `, `partial argument match of ` | **falla** | no falla |
| `LANG=C.UTF-8 LC_ALL=C.UTF-8` | `partial match of `, `partial argument match of ` | **falla** | no falla |

*2. Corrida real.* `Rscript 00_run_all.R`: 7 pasos, 13,6 s, salida 0, **cero advertencias de
coincidencia parcial** (condición 5 no se disparó) y **28 de 28** archivos byte a byte
idénticos a la línea base. La única línea `WARN` del log es la de siempre («Remisiones
descartadas por anio discordante: 67»).

*3. El idioma del CI.* `Rscript -e 'source("00_run_all.R"); run_all()'` imprime `PASO 30:`
**una** vez y `RESUMEN:` **una** vez. La lección de v4 no se deshizo. La guarda de
`commandArgs()` sigue viva: `Rscript 00_run_all.R --from 32` rechaza con su mensaje.

**Alcance declarado del mecanismo.** R avisa solo cuando la coincidencia parcial
**resuelve**: un prefijo con dos o más hermanas devuelve `NULL` sin avisar, porque ahí no
hubo coincidencia. La compuerta caza el defecto, no la fragilidad; el mapa de la fragilidad
es el producto de T3. Y una coincidencia parcial que ocurra dentro de un
`suppressWarnings()` del propio pipeline no la ve nadie (§8, D-g).

## 5. El panel adversarial

Dos revisores, tope duro respetado, **solo lectura**, R y `jq` exclusivamente con Python
prohibido declarado en ambos prompts, escritura confinada a `/tmp/slep_v5_panel1/` y
`/tmp/slep_v5_panel2/`. Ninguno tocó el repositorio (verificado: `git status --porcelain`
vacío antes y después). No hubo relanzamientos.

### 5.1 La afirmación 🔒 que se les pidió refutar: NO REFUTADA

Revisor 1 la atacó de frente y midió por su cuenta: 23 `.md` encontrados, 22 tras excluir
`README.md`, log `identical()` entre las dos versiones, 0 publicables en ambas. Y explicó
**por qué** no pudo refutarla, que vale más que el resultado: las 22 son uniformes en el
único eje que separa las dos versiones (sin `estado: validada` no se toca `firmada()`; sin
un `validado_por` no nulo no se toca la validación de tipo). Su frase, que este log adopta:
*el endurecimiento no es un no-op, es un no-op sobre este corpus concreto, y deja de serlo
con la primera pieza que el equipo valide*.

Revisor 2 llegó al mismo resultado por otro camino y añadió la prueba que más importa: **el
sembrador y la compuerta siguen alineados**, porque el front matter que emite
`00_generar_borradores.R` (`validado_por: null`) cae en la rama `is.null(v)` y no genera
reparo.

### 5.2 Lo que el panel sí encontró y esta cadena SÍ corrigió

Tres hallazgos entraron al código, como decisiones autónomas (§7bis). Los tres viven dentro
de las funciones que el encargo mandaba modificar y sirven a los dos 🔒 del propio encargo.

| # | Hallazgo | Corrección |
|---|---|---|
| H-8 (rev. 1) | La comprobación de firma quedaba en un `stop()` aparte, **detrás** de los reparos nuevos: con una pieza de `tipo` mal en otro archivo, la pieza validada-sin-firma —el caso que §10.5 considera grave— no aparecía hasta la segunda corrida. Y el comentario que yo mismo escribí prometía lo contrario | Se movió al mismo colector de reparos. Verificado: tres piezas malas, una de ellas validada sin firma, salen **todas** en una corrida |
| H-1 / H-2 (rev. 1 y 2) | `yaml::yaml.load()` no estaba envuelto: una clave duplicada —el error más probable al editar a mano— abortaba con `Duplicate map key: 'estado'`, en inglés y **sin nombrar el archivo**, con 22 piezas donde buscar | `tryCatch` que nombra el archivo, traduce el contexto y avisa de que los números de línea del lector cuentan desde el primer `---`, no desde el principio del archivo |
| secundario (rev. 1 y 2) | El `stop()` preexistente de «Pieza sin front matter» era el único que emitía la **ruta absoluta de la máquina del titular**, cinco líneas encima de dos reglas nuevas que sí usan la relativa. En un repositorio público y con logs de CI públicos, eso además filtra estructura | Ruta relativa, y el mensaje dice qué tiene que tener el archivo |

### 5.3 Lo que el panel encontró y esta cadena NO corrigió

Todo lo demás va a §8 como duda, con su reproducción. La razón es la misma para todos: son
reglas nuevas, no las cinco aprobadas, y el encargo reserva esa decisión. Verificados por
esta cadena y no aceptados del informe:

- **`titulo` es el gemelo exacto del agujero de `tipo` que se acaba de cerrar.** Medido aquí:
  una pieza validada y firmada **sin `titulo`** pasa la compuerta, `pagina_pieza()` funciona,
  y el índice muere con `values must be length 1, but FUN(X[[1]]) result is length 0`. Y
  `titulo: no` publica con `title: false` en el `.qmd`. Es la misma familia `as.character()`
  que motivó todo el endurecimiento, viva en el campo de al lado.
- **Dos de las 92 anclas de las piezas reales apuntan a fragmentos inexistentes.** Recontado
  por esta cadena contra los `id` de artículo de los 25 JSON:
  `dictamen_078_detectores_revision_mochilas.html#materia` en `faq_revision_de_mochilas.md` y
  `#concordancias` en `faq_seguridad_y_deteccion.md`; ese documento solo tiene
  `ocr-pagina-001`…`009`. **No está publicado hoy** (0 piezas publicables, 0
  `pieza-*.html`), así que el enlace muerto es latente, no vivo. Pero el sitio promete que
  cada afirmación enlaza al artículo que la respalda, y hoy nada lo comprueba.

### 5.4 Lo que el panel declaró que no pudo probar

Se registra porque acota el alcance de su veredicto: ninguno de los dos ejecutó
`34_generar_paginas.R` completo (escribe dentro del repo y tenían prohibido escribir), ni
renderizó con Quarto, ni corrió en Linux, que es donde vive el CI. El revisor 1 descartó
además dos sospechas por medición: el BOM UTF-8 lo descarta `readLines` en esta plataforma,
y `[[:alpha:]]` sigue reconociendo letras no ASCII incluso forzando `LC_CTYPE=C`.

## 6. Verificación de invariantes 🔒

| Invariante | Comprobación | Resultado |
|---|---|---|
| Nada cierra estados ni publica piezas | log del paso 34 y `ls` del sitio | **cumplido**: 22 piezas, 0 publicables, 0 `pieza-*.qmd`, 0 `pieza-*.html` |
| `20_insumos/` solo se lee | `git status --porcelain -- 20_insumos/` y `git diff --stat 3c3ea0d..HEAD -- 20_insumos/` | **vacío** en toda la cadena |
| `40_salidas/` solo por regeneración | tres corridas, todas por `Rscript 00_run_all.R` o `source(); run_all()` | **cumplido** |
| Anclas estables | 28 de 28 archivos versionados byte a byte idénticos; sha256 del conjunto `25eec868…` antes y después | **cumplido** |
| Toda cifra recontada en su turno | `Rscript`, `jq`, `git`, `shasum` en el mismo turno | **cumplido** |
| **El endurecimiento no cambia el veredicto de ninguna pieza real** (propio de v5) | arnés sobre las 22 reales con el código de v4 y con el de v5, y log del paso 34 en las dos regeneraciones | **cumplido**: «22 en total, 0 validadas y publicables» las cuatro veces |
| **Toda regla nueva aborta nombrando archivo y clave ofensora** (propio de v5) | se provocó cada aborto y se leyó el texto | **cumplido para las reglas nuevas**, y además se corrigieron dos abortos preexistentes que no lo cumplían (§5.2). Lo que sigue sin cumplirlo son los errores aguas abajo de campos que la compuerta no valida (§8, D-c) |
| Subagentes en R/jq, Python prohibido, solo lectura | declarado en los dos prompts; `git status` vacío antes y después | **cumplido**; tope de 2 respetado, sin relanzamientos |
| `ESTADO.md` no se toca | `git status --porcelain -- 50_documentacion/activa/ESTADO.md` | **vacío**; sigue `sesion_abierta: true`, `commit_cierre: 358e150` |
| `00_ocr_documentos.R` no se ejecuta | no se invocó | **cumplido** |

## 7. Decisiones del usuario registradas en gates

Ninguna. Todas las autorizaciones usadas venían en la lista cerrada del encargo. El push
queda pendiente de tu OK explícito, como manda el contrato global.

## 7bis. Decisiones autónomas

| # | Decisión | Alternativa descartada | Reversibilidad |
|---|---|---|---|
| D1 | **La comprobación de firma se movió al colector de reparos** de `revisar_pieza()`, en vez de quedar en su `stop()` aparte. | Dejarla donde estaba y suavizar el comentario. | Reversible: un bloque. Se hizo **con evidencia del panel** (H-8): mi propio comentario prometía «una sola corrida tiene que decir todo lo que hay que arreglar» y el código hacía lo contrario, además de **demoter** el caso que §10.5 considera grave por detrás de los reparos nuevos. |
| D2 | **`yaml::yaml.load()` envuelto en `tryCatch`** que nombra el archivo y explica el desfase de los números de línea. | Dejar salir el error crudo del lector. | Reversible: 10 líneas. El error más probable de una persona editando a mano (duplicar un campo) salía en inglés y sin decir de qué archivo hablaba. Es literalmente el 🔒 «nombra el archivo de la pieza». |
| D3 | **Ruta relativa** en el `stop()` preexistente de «pieza sin front matter». | Ceñirse a las cinco medidas y no tocarlo. | Reversible: una línea. Era el único aborto que filtraba `/Users/<usuario>/…` en un repositorio **público** con logs de CI públicos, y dejaba el bloque contradiciéndose consigo mismo. |
| D4 | **`escalar_texto()` exige longitud 1**, que la medida (a) no nombraba. | Aceptar un vector de nombres. | Reversible: una condición. Un `validado_por: [Ana, Beto]` recicla en `sprintf()` y **duplica el párrafo de firma** en el HTML publicado. |
| D5 | **`leer_pieza()` exige que el front matter sea un mapa** `campo: valor`. | Ceñirse a `archivo`/`cuerpo`. | Reversible: tres líneas. Una secuencia YAML o un escalar no traen `tipo`, y sin esto reventaban aguas abajo con un error de subíndice, que es justo lo que la medida (e) prohíbe. |
| D6 | **Categoría (0) declarada** en T3, fuera de la taxonomía de tres del encargo. | Plegarla a (i). | Es documentación. Son 75 de 91 accesos y (i) los describiría como «seguros mientras el escritor coopere», que es falso: no tienen ninguna hermana a la que resolver. |
| D7 | **El patrón de la compuerta de T2 se deriva en tiempo de ejecución** en vez de escribirse. | Un patrón de texto fijo, que es el diseño obvio. | Reversible: una función. Se descartó **con medición**: el mensaje está traducido, y un patrón fijo habría producido una compuerta que se apaga sola en un runner que hable otro idioma, sin decirlo. |

## 8. Dudas y pendientes abiertos

Ninguna tarea quedó congelada. Todo lo que sigue son preguntas cerradas para el titular,
verificadas por esta cadena y no aceptadas de un informe.

### D-a — `titulo` y `fuentes` no están en la compuerta, y `titulo` revienta aguas abajo

Es el gemelo exacto del agujero de `tipo` que T1 acaba de cerrar. Medido aquí: pieza
validada y firmada **sin `titulo`** → la compuerta **pasa**, `pagina_pieza()` **funciona**,
y el índice `piezas.qmd` muere con `values must be length 1, but FUN(X[[1]]) result is
length 0`, sin nombrar el archivo. `titulo: no` publica `title: false` y el índice rotula la
pieza «FALSE». `fuentes` como cadena revienta con `subíndice fuera de los límites`; `fuentes`
sin `articulo`, con el mismo error de longitud.

No se corrigió porque la medida (e) del encargo enumera `tipo` y `estado`, y añadir `titulo`,
`fecha_validacion` y `fuentes` es una regla nueva.

**Pregunta cerrada.** El `README.md` de piezas declara **ocho** campos bajo «Front matter
obligatorio» (`tipo`, `titulo`, `estado`, `validado_por`, `fecha_validacion`, `fuentes`,
`generado_por`, `generado_el`) y la compuerta valida **tres**. ¿Se extiende `revisar_pieza()`
a los que el generador llega a leer (`titulo`, `fecha_validacion`, `fuentes`), o se deja como
está?

### D-b — `validado_por` publica cualquier cadena con una letra

Publicaron como firmadas, medido por el panel: `"no"`, `"false"`, `!!str false`, `N/A`,
`s/i`, `pendiente`, `nO`, `x`, `e`, `1a2`, `¿¿¿a`, y `2026-08-26T10:00:00Z` (la marca de
tiempo ISO, que R devuelve como carácter, a diferencia de `2026-08-26` que sí aborta).
También `"null"` entrecomillado, que es la sexta fila de la familia (a) del log v4.

La regla aprobada es «texto, no vacío, con al menos una letra», y eso es lo que hace. Una
lista negra de literales (`null`, `NA`, `pendiente`, `s/i`, `N/A`) sería una regla nueva.
Hay además un detalle incómodo: el propio mensaje de error dice «escribe UN nombre entre
comillas», y seguir esa instrucción con `validado_por: "no"` publica la pieza firmada por
«no».

**Pregunta cerrada.** ¿Se añade una lista negra de literales, se exige un mínimo de dos
caracteres alfabéticos y un espacio (nombre y apellido), o esto se resuelve en la **pauta**
al equipo y no en el código?

### D-c — Los errores aguas abajo siguen sin nombrar el archivo

`values must be length 1…` y `subíndice fuera de los límites` salen en jerga de R sin decir
qué pieza los causó. También el candado de conteo final, `Se esperaban %d páginas .qmd y hay
%d`, que es aritmética de programador. Se cierra si se cierra D-a, salvo el candado.

### D-d — Colisión de slug: una pieza firmada puede desaparecer

`slug_pieza()` usa el `basename`, y `fs::dir_ls(recurse = TRUE)` recorre subdirectorios. Dos
piezas `expulsion.md` en carpetas distintas —o `expulsion.md` y `Expulsión.md`— dan el mismo
`pieza-expulsion`: ambas pasan como publicables, el segundo `.qmd` sobreescribe al primero,
el índice enlaza las dos al mismo destino, y el único aviso es el candado de conteo, que no
nombra nada. **No es hipotético**: el `README.md` de piezas dice «una pieza validada puede
quedarse donde está o moverse», y copiar en vez de mover produce exactamente este par.

**Pregunta cerrada.** ¿Se aborta ante slugs de pieza repetidos, nombrando los dos archivos?

### D-e — Dos de las 92 anclas de las piezas reales apuntan a fragmentos inexistentes

Recontado por esta cadena: `faq_revision_de_mochilas.md` →
`dictamen_078_detectores_revision_mochilas.html#materia`, y `faq_seguridad_y_deteccion.md` →
`…#concordancias`. Ese documento es OCR y sus únicos `id` son `ocr-pagina-001`…`009`.
**Latente, no vivo**: las 22 piezas están sin publicar, así que hoy no hay ningún enlace
muerto en el sitio. Pero el sitio promete que cada afirmación enlaza al artículo que la
respalda, y nada lo comprueba.

Corregir las dos anclas exige escribir en `20_insumos/curaduria/piezas/`, que **no está en
la lista de autorizaciones** de este encargo, y además es contenido interpretativo que firma
una persona.

**Pregunta cerrada.** ¿Se añade al pipeline una compuerta que verifique las anclas de
`fuentes` contra los `id` reales antes de publicar, y se corrigen esas dos en la curaduría?

### D-f — La taxonomía de T3 necesitó una cuarta categoría

El encargo enumeraba (i), (ii) y (iii). El caso «puede faltar pero no tiene ninguna hermana»
—75 de 91 accesos— no encaja en ninguna: no es «existe siempre», y no hay ambigüedad que
proteja porque no hay a qué resolver. Se declaró como **(0)**. Queda constancia porque es una
extensión de lo enumerado, no una lectura de lo enumerado.

### D-g — Alcance del mecanismo de T2, declarado

Dos límites, ninguno corregible sin cambiar el alcance del encargo: (1) R avisa solo cuando
la coincidencia parcial **resuelve**, así que un prefijo con dos o más hermanas sigue
devolviendo `NULL` en silencio (T3 es el mapa de eso); (2) una coincidencia parcial dentro
de un `suppressWarnings()` del propio pipeline no llega al manejador, porque el
`suppressWarnings` interior corre primero. Hay tres en el pipeline
(`10_utils/10_utils.R:99` en `formatear_numero()`, `32_segmentar_articulos.R:531` y
`33_relaciones.R:60`), los tres sobre `as.integer`.

### D-h — Cuatro asperezas menores del panel, sin corregir

- **`estado` con espacio duro.** `trimws()` recorta `[ \t\r\n]` pero no U+00A0, que es lo que
  inserta un copiar-pegar desde Word. `estado: "validada<NBSP>"` aborta con «el campo
  `estado` dice `validada `. Solo valen `borrador` y `validada`», que para quien no programa
  se lee como una contradicción. Igual con la `а` cirílica.
- **`tipo` no se normaliza y `estado` sí.** `tipo: Ficha` aborta; `estado: Validada` se
  acepta. La medida (d) nombraba solo `estado`.
- **`README.md` se excluye por comparación exacta y sensible a mayúsculas.** `Readme.md`
  o `LEEME.md` se parsearían como pieza. Irrelevante hoy en macOS con el corpus actual;
  relevante en el runner Linux.
- **Un archivo en Latin-1 revienta en `trimws()`**, antes de llegar a la compuerta, con
  `input string 5 is invalid UTF-8` y sin nombrar el archivo. Escenario realista: el flujo
  documentado es editar el `.md` a mano, y firmar es justo cuando se escribe un nombre con
  tilde.

### D-i — Cuatro líneas de la clase B de v3 que no se reconstruyen

v3 declaró 41 líneas en `34_generar_paginas.R`; re-medidas sobre su propio árbol
(`7cc6fb6`), con su propio criterio, salen 37. Los otros cinco archivos coinciden exactos.
El documento de v3 no enumera líneas, así que la diferencia no se puede localizar. Se
registra sin racionalizar.

### Heredadas y no tocadas

La Duda 3 de v4 (vocabulario `tema`/`temas`, `cita`/`cita_literal` en `relaciones.json`)
sigue excluida y viaja al traspaso v02 como zona frágil, **pero desde hoy está cubierta en
tiempo de ejecución** por la compuerta de T2: un refactor que active ese puente ya no
devolverá el campo equivocado en silencio, hará fallar la corrida.

## 9. Estado de cifras y datos críticos

Todas recontadas programáticamente en el turno, con el comando que las produjo.

| Cifra | Valor | Comando |
|---|---:|---|
| Piezas / publicables, antes y después | 22 / **0** | log del paso 34 en las dos regeneraciones |
| Casos de conducta de la compuerta medidos | 25 | arnés propio sobre el árbol de parseo del archivo |
| Casos que coinciden con la tabla del log v4 (antes) | **25 de 25** | arnés sobre `HEAD~1` del cambio |
| Casos que cambian de veredicto | **17**; 8 se mantienen | arnés sobre los dos árboles |
| Accesos de clase B re-anclados | **91** (78 líneas) | `utils::getParseData()` sobre los seis archivos |
| Clase B que muerde | **0** | clasificador calibrado contra tres casos conocidos |
| Clase B contingente (lista de vigilancia) | **9** | ídem |
| Accesos del anexo sobre sub-objetos | 32, todos (0) | ídem |
| Archivos versionados de `40_salidas/` | **28** | `git ls-files 40_salidas/` |
| Idénticos byte a byte tras tres corridas | **28 de 28** | `shasum -a 256 -c` contra la línea base |
| sha256 del conjunto de hashes, antes y después | `25eec8681b8dd12eb693d82cfc14a8b646efb1f7b45e065fe87ca3cd7c7c2c71` | `shasum -a 256 <28 archivos> \| shasum -a 256` |
| Advertencias de coincidencia parcial en la corrida real | **0** | `grep -inE 'encuentros parciales\|partial match' run_t2.log` |
| Anclas declaradas por las 22 piezas / rotas | 92 / **2** | recuento propio contra los `id` de los 25 JSON |
| Casos que atacó el panel | 87 (rev. 1) + los frentes A/B/C (rev. 2) | informes del panel |
| Pasos del pipeline / duración | 7 / 13,6 s | `RESUMEN` del log de la corrida |

## 10. Notas para el revisor

**Lo que falló o sorprendió.** Tres cosas, y ninguna es cosmética.

1. **El mensaje de las advertencias de coincidencia parcial está traducido.** El diseño
   obvio de T2 —un patrón de texto escrito a mano— habría producido una compuerta que se
   apaga sola en cuanto el runner de CI hablara otro idioma, sin emitir ni un aviso. Es la
   misma forma de fallo que la compuerta existe para impedir, instalada dentro de la
   compuerta misma. Se descubrió midiendo la forma del mensaje antes de escribir el patrón,
   no después.

2. **v3 contaba líneas, no accesos, y por eso el 86 no cuadraba con nada.** La pista estaba
   en el encabezado de su propia tabla. Cinco de los seis archivos reproducen su cifra exacta
   una vez contada en la unidad correcta. Sin ese paso, el re-anclaje habría sido un número
   nuevo sin relación con el viejo.

3. **La corrección de T1 demotó, sin querer, el caso que §10.5 considera grave.** Al mover
   los reparos nuevos delante del `stop()` de la firma, una pieza validada sin firma quedaba
   escondida detrás de cualquier errata de `tipo` en otro archivo. Lo encontró el panel, y lo
   encontró contrastándolo contra un comentario que yo mismo había escrito prometiendo lo
   contrario. Es el argumento más limpio a favor del panel que ha dado esta cartera: no
   refutó un dato, refutó la coherencia entre el código y su propia justificación.

**Dos apuntes de método.** El arnés de T1 no reimplementa la compuerta: extrae las
definiciones reales del árbol de parseo del archivo y sustituye una sola función
(`ruta_insumos`). Por eso la tabla «antes» se pudo medir sobre el código de v4 y la «después»
sobre el de v5 con exactamente el mismo instrumento. Y el barrido de T3 tuvo que trabajar
sobre los **bytes** de cada línea: `getParseData()` entrega los offsets en bytes y las líneas
de este corpus traen tildes, de modo que extraer el objeto con `substr()` devolvía
`t$titulo` donde el código dice `n$titulo`. Un barrido que no lo note reporta objetos
inventados con aspecto de dato medido.

**Lo que este encargo deja listo.** La compuerta de firma ya no es derrotable por lo que una
persona escribe a mano en los casos que el equipo va a escribir, y el proyecto avisa —y
falla— cuando un `$` adivina un nombre. Con eso, la vía A puede empezar: lo que falta antes
de entregar la pauta es decidir D-a, D-b y D-d, que son las tres preguntas sobre qué más
tiene que rechazar la compuerta.

---

# Adenda — verificación en el runner (segundo push, solo documentación)

Las dos comprobaciones que ningún panel pudo medir (§5.4: nadie corrió el pipeline completo,
nadie corrió en Linux) se hicieron aquí, sobre el runner real. **Las cinco pasan.** No se
tocó nada del código para conseguirlo.

## A. Push y run

`git push origin main` → `3c3ea0d..e95093e  main -> main`.

| | |
|---|---|
| Run | **33076947015** |
| Estado | **completed / success**, 1 m 57 s, disparado por push a `main` el 2026-08-27T13:27:50Z |
| Jobs | `construir` (98533507335) ✓ 1 m 41 s · `desplegar` (98534033046) ✓ 9 s |
| Pasos fallidos | **0** en ambos jobs |
| Anotaciones | **0** en ambos jobs (`gh api .../check-runs/<job>/annotations` → `0`) |

## B. Las cinco comprobaciones, con evidencia literal del log del runner

### a. El pipeline corrió UNA sola vez — **PASA**

```
grep -c 'RESUMEN:' (paso «Correr el pipeline completo») = 1
grep -c 'RESUMEN:' (log entero del run)                 = 1
grep -c 'PASO 30:' (paso)                               = 1
```

Evidencia literal:

```
RESUMEN: 7 pasos ejecutados, 0 saltados, 30.0s en total.
```

La lección de v4 sobrevive al idioma del CI (`Rscript -e 'source("00_run_all.R"); run_all()'`)
en Linux, no solo en macOS.

### b. Cero advertencias de coincidencia parcial, en cualquier idioma — **PASA**

```
grep -icE 'encuentros parciales|partial match'          = 0
grep -icE 'parcialmente correctos|coincidencia parcial' = 0
```

El segundo grep es propio y amplía el pedido: cubre la forma española del aviso de
argumento/atributo y el texto que emitiría la propia compuerta al promover.

### c. La compuerta estuvo ACTIVA — **PASA**, por un método que no es el pedido

**No existe la línea de arranque que la comprobación suponía, y se declara antes de buscarla.**
Localizado en el código primero: el bloque de la compuerta (`00_run_all.R:28-94`) **no imprime
nada** al armarse (barrido de `cat|print|message|log_msg|writeLines` en esas líneas: ninguna
coincidencia). `derivar_prefijos_parciales()` solo `stop()` si no puede derivar. Buscar en el
log una línea que el código no emite habría dado un falso negativo.

El método que el código sí permite es el **contrapositivo**, y tiene cuatro eslabones, los
cuatro verificados:

1. `PREFIJOS_PARCIAL <- derivar_prefijos_parciales()` está en el **nivel superior** de
   `00_run_all.R:73`, así que se evalúa al hacer `source("00_run_all.R")`, antes de `run_all()`.
   El comando del workflow es exactamente `Rscript -e 'source("00_run_all.R"); run_all()'`.
2. **Control negativo, medido en este turno** (no argumentado): se extrajo la función real del
   árbol de parseo del archivo y se corrió con las opciones **apagadas**. Aborta:
   ```
   No se pudo derivar el aviso de coincidencia parcial: R no avisó ante una provocada a propósito.
     Revisa que 10_utils/10_configuracion.R fije options(warnPartialMatchDollar = TRUE).
     Sin ese aviso esta compuerta no vigila nada.
   ```
   Con las opciones encendidas deriva `<encuentros parciales de >` y
   `<argumentos parcialmente correctos de >`. El detector de compuerta desarmada **dispara de
   verdad**; sin este control, «no salió el mensaje, luego estaba armada» sería una inferencia
   sin probar.
3. En el log del runner ese mensaje aparece **0 veces**
   (`grep -ic 'No se pudo derivar el aviso'` = 0; `grep -ic 'compuerta no vigila'` = 0) **y el
   paso concluyó `success`**. Si las opciones no hubieran estado activas en el runner, el paso
   habría fallado ahí mismo.
4. `ejecutar_paso()` es la **única** vía por la que corren los pasos: 1 sitio de llamada
   (`00_run_all.R:170`) y **0** `source(fs::path(ROOT` directos restantes.

De 1–4 se sigue que en el runner las opciones estaban puestas, los prefijos se derivaron y los
7 pasos corrieron bajo el manejador.

**Lo que este método NO prueba, y conviene decirlo:** que el manejador *dispararía* en el
runner, porque allí no ocurrió ninguna coincidencia parcial que promover. La demostración
positiva (el paso de juguete que falla señalando `curado$anio`) sigue existiendo solo en macOS.
Cerrar ese hueco exigiría introducir una coincidencia parcial deliberada en el pipeline, que es
tocar el código, y esta verificación tenía prohibido tocar nada. Queda como hueco residual
declarado.

### d. Conteo de piezas en el runner — **PASA**

Evidencia literal:

```
[2026-08-27 13:29:04] [34_generar_paginas] [INFO] Piezas interpretativas: 22 en total, 0 validadas y publicables.
```

Idéntico a las tres corridas de macOS. El endurecimiento no cambia el veredicto de ninguna
pieza real tampoco en Linux.

### e. El sitio desplegado — **PASA**

**Método, declarado.** Las dos páginas se capturaron con `curl` **antes** de que aterrizara el
deployment nuevo (13:28:32Z, cuando el sitio servía todavía el artefacto del día anterior) y
otra vez **después** (13:31:23Z). Se comparan por `sha256` del cuerpo completo. La ventana se
consiguió capturando inmediatamente después del push, mientras el job `construir` seguía en
curso.

| Página | HTTP | Bytes | sha256 antes | sha256 después | |
|---|:-:|---:|---|---|:-:|
| `index.html` | **200** | 25 342 | `22470bd101c848ea…` | `22470bd101c848ea…` | **idéntico** |
| `ley_20536_violencia_escolar.html` | **200** | 36 479 | `6a15f70fe59af0da…` | `6a15f70fe59af0da…` | **idéntico** |

Y **sí hubo despliegue nuevo**, que es lo que hace significativa la identidad: la cabecera
`last-modified` pasó de `Wed, 26 Aug 2026 18:03:41 GMT` a `Thu, 27 Aug 2026 13:29:41 GMT`, y el
`etag` de `"6a8f2a7d-62fe"` a `"6a903bc5-62fe"`. Contenido igual, artefacto nuevo. El runner
declaró además **47 páginas HTML**, el mismo número que la corrida local.

*Límite del método:* son 2 páginas de 47, las que se pidieron. Una diferencia en una página no
muestreada no la habría visto esta comprobación.

## C. Lo que apareció de paso, y no estaba en el encargo

### C.1 El runner ya no corre el entorno declarado

| Componente | Declarado (`ENTORNO` del encargo v5 / `CLAUDE.md` §10.3) | Runner (medido) |
|---|---|---|
| R | 4.5.2 | **4.6.1** (`/opt/R/4.6.1/bin/R`) |
| Quarto | 1.9.38 / «Quarto 1.9» | **1.10.18** |

El workflow no fija ninguna de las dos: `r-lib/actions/setup-r@v2` con `r-version: 'release'` y
`quarto-dev/quarto-actions/setup@v2` sin `version`. Ambos toman lo último publicado.

La consecuencia se puede ver: **mi HTML local y el desplegado difieren**, con el corpus y los
datos byte a byte idénticos. Las 15 líneas que cambian son todas andamiaje de Quarto
(`<meta name="generator" content="quarto-1.9.38">` frente a `quarto-1.10.18`, los hash de los
CSS empaquetados, una regla `@media screen` nueva). **El contenido normativo no cambia.** El
`generator` de las dos capturas del sitio dice `quarto-1.10.18`, y el run del día anterior
(`32997403718`) también usó R 4.6.1 y Quarto 1.10.18: por eso los dos despliegues salen
idénticos byte a byte.

Eso acota lo que prueba la comprobación (e): prueba que **este cambio** no alteró el sitio
publicado, bajo una cadena de herramientas idéntica en los dos despliegues. **No** prueba que el
sitio sea reproducible entre cadenas distintas, y de hecho no lo es. El encabezado del propio
workflow dice que «lo que se ve en línea siempre proviene de una corrida reproducible»; hoy es
reproducible respecto de los PDF, no respecto de la versión de Quarto.

**Pregunta cerrada (D-j).** ¿Se fija la versión de Quarto (y la de R) en `publicar.yml`, y se
actualiza a la vez el stack declarado en `CLAUDE.md` §10.3, o la deriva se acepta declarándola?

### C.2 El runner habla dos idiomas a la vez, y eso valida el diseño de T2

En el **mismo paso** del mismo job, con `LANG: es_ES.UTF-8` declarado:

```
also installing the dependencies ‘rappdirs’, ‘sys’, ‘cachem’, …     <- inglés
probando la URL 'https://packagemanager.posit.co/cran/…'            <- español
```

Recuento: 40 líneas con la forma inglesa (`downloaded source packages` /
`installing *binary* package`), 0 con su equivalente español. El catálogo de traducciones de R
en ese runner está **incompleto**, así que el idioma de un mensaje concreto no se deduce de
`LANG`: depende de si ese `msgid` en particular está traducido en esa versión de R, que además
ya no es la del entorno declarado (4.6.1, no 4.5.2).

Es exactamente el escenario contra el que se tomó la decisión D7. Un patrón de texto escrito a
mano en español habría tenido una probabilidad real de no coincidir en este runner, y la
compuerta se habría apagado **sin decirlo**. El prefijo derivado en tiempo de ejecución no
depende de esa lotería.

**Honestidad sobre el alcance:** no se observó ninguna advertencia de coincidencia parcial en el
runner, así que **no** se sabe en qué idioma la habría emitido allí. Lo medido es que el runner
mezcla los dos, no que ese aviso en concreto salga en uno u otro.

## D. Estado al cierre de la adenda

`origin/main` = `e95093e` más el commit de esta adenda. Sitio publicado y respondiendo 200.
`ESTADO.md` sigue sin tocarse: `sesion_abierta: true`, `commit_cierre: 358e150`. La sesión
sigue abierta.
