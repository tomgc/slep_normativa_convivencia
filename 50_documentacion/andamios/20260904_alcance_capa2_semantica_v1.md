# Alcance de la capa 2: búsqueda semántica sobre el corpus normativo

> **Fecha:** 2026-09-05 (encargo emitido el 2026-09-04, sesión 3).
> **Autor:** A2, encargo v9 (`50_documentacion/andamios/20260904_encargo_alcance_motor_busqueda_v1.md`, sección A2).
> **Naturaleza:** documento de ALCANCE. Especifica y mide; no construye ni integra nada al pipeline ni al sitio.
> **Reproducibilidad:** toda cifra marcada *medida* sale de `Rscript 50_documentacion/andamios/20260904_medicion_corpus_semantica.R` corrido desde la raíz del repo el 2026-09-05 (salida en consola y tablas `a2_*.csv` / `a2_*.json` en `50_documentacion/andamios/lab_motor_v9/`). Las cifras marcadas *calculadas* son aritmética explícita sobre cifras medidas. Las marcadas *hipótesis* no se midieron y llevan su comando de verificación.
> **Convención de anclas:** `pagina.html#id`, donde `id` es el `id` de la unidad en `40_salidas/datos/normas/<slug>.json` y a la vez el `id` del `<h2>` del sitio generado (verificado en la sección 5).
> **Corrección de fase 3 (2026-09-06).** Este documento fue auditado (`20260904_auditoria_alcance_motor_v1.md`, 20 filas contra A2) y contrastado por el panel adversarial (`20260904_panel_adversarial_motor_v1.md` §14, hallazgos H-1, H-5, H-7, H-12, H-16, H-17, H-19 y H-20). Toda cifra corregida se re-derivó en el turno de corrección con `Rscript 50_documentacion/andamios/lab_motor_v9/a2_correcciones_fase3.R` (salida completa en `a2_correcciones_fase3_salida.txt`), cada una con su control positivo y su control negativo en el mismo bloque. Los cambios están marcados con **(corregido en fase 3: <id>)** en su propia línea.

---

## 0. Decisión en una página

| Pregunta del encargo | Respuesta | Sustento |
|---|---|---|
| Unidad de recuperación | El **segmento** del JSON (806 unidades), no el artículo (682): los cuatro dictámenes y las tres REX aportan **0 artículos** y son la fuente de la respuesta esperada en **2 de las 10** consultas del conjunto de evaluación (C01, C10), o en **4** contando las anclas aceptadas (C01, C02, C06, C10). Artículo o segmento completo por defecto; **ventana deslizante** solo sobre las unidades que exceden 512 tokens estimados (227 de 806), lo que da 1 160 fragmentos firmados (1 344 con OCR). | §1, §2 (medido y calculado) |
| ¿Cabe el índice de vectores en el navegador? | **Sí, el índice.** 722 unidades firmadas × 384 dimensiones en int8 = 311,5 KB (0,85 s a 3 Mbps); 1 160 fragmentos firmados en int8 = 500,5 KB. En float32 a 1 024 dimensiones sobre todos los fragmentos son 5,3 MB: no cabe. Lo que **no** cabe sin medirlo es el modelo que vectoriza la consulta, que no se midió (sin red). | §3 (calculado) |
| Línea base del Pagefind actual | Con las 10 consultas en lenguaje del equipo tal como se escriben: **3 de 10** devuelven la página correcta entre las 3 primeras, **1 de 10** el artículo correcto entre los 3 primeros sub-resultados por puntaje, **0 de 10** en lo que la interfaz muestra. Con el término canónico de la norma (**cota superior no alcanzable hoy**, ver la fila siguiente): 9 de 10 páginas, 5 de 10 artículos, 3 de 10 en la interfaz; **desdoblada por citabilidad (H-16), 8 de 10 páginas y 4 de 10 artículos con unidad citable**: en las dos lecturas la única que cae es C09, cuya única respuesta aceptada está en texto OCR sin revisar. | §6 (medido) |
| Dónde vive el índice | **Opción recomendada: Pagefind con expansión de vocabulario y reordenamiento de sub-resultados (opción 3) como vía léxica obligatoria, más un índice vectorial estático int8 en el navegador (opción 1) como vía semántica**, con la consulta vectorizada por un servicio (Worker) mientras no se mida el peso de un modelo en el navegador. **Condición explícita (H-12):** la cota de la opción 3 se apoya en la variante `canonico`, que es un mapeo manual de A2 y **no** lo que la capa 1 entrega hoy; la recomendación queda condicionada a que exista la tabla de alias curados que A1 propone en su §2.4. **Consecuencia de degradación (H-17):** sin el Worker sobrevive la capa 2 **léxica**, no la semántica, porque no hay vector de consulta. Vectorize (opción 2) no aporta nada que un archivo de 0,5 MB no resuelva a esta escala ni a 100 normas (2,0 MB calculados). | §4 |
| Candidatos a recuperar antes de reordenar | **K = 30 por vía** (60 fusionados). Con el término canónico, 9 de 10 respuestas aparecen **hasta** el rango 28 en la lectura por sub-resultado (con K = 27 son 8); la décima (consejo escolar) aparece en el rango 65 y es el caso que el reordenamiento debe resolver, no la recuperación. | §4bis (medido) |
| OCR sin revisar | 84 unidades en 5 documentos (recuento propio). **Devolverlas marcadas**, en un bloque aparte y después de las firmadas, nunca como fundamento citable ni como insumo de la capa 3. Excluirlas deja sin respuesta a "nombre social" (C09), cuya única unidad es OCR. | §4quater (medido) |
| Temporalidad | Filtro por año de publicación sostenible en 21 de 25 normas (4 sin año). Una sola sustitución en el corpus. "Qué regía en 2021": 12 normas determinables, 4 indeterminables. El vacío real es la vigencia **por artículo** (la ley 21.809 reescribe artículos de la LGE que siguen en el corpus con su redacción de 2011). | §4ter (medido) |

**(corregido en fase 3: CIF-A2-11)** La primera versión de la fila "Unidad de recuperación" afirmaba que los dictámenes y las REX "son lo que más consulta el equipo". **Se retira: no hay artefacto en el repositorio del que se pueda derivar frecuencia de consulta**, y este mismo documento declara en §5 que no existe registro de consultas reales. La sustituye el recuento verificable de arriba: anclas esperadas en un dictamen o una REX, 2 de 10 (C01, C10); con anclas aceptadas, 4 de 10 (C01, C02, C06, C10); control positivo del mismo clasificador, 7 anclas esperadas en una ley o un decreto; control negativo, patrón `^zzqq` → 0.

**(corregido en la ronda de cierre: V-2)** La fila "Línea base del Pagefind actual" encadenaba el desdoble con un "porque" que el recuento no sostiene: atribuía la caída a C09 **y** a que C04, C05 y C08 traen una página OCR como primer sub-resultado. Re-derivado consulta por consulta en el turno de cierre (`lab_motor_v9/a2_cierre_v9.R`, variante `canonico`): en la lectura A alcanzan el top 3 nueve consultas y en la lectura C cinco (C01, C02, C04, C09, C10); al exigir unidad citable **la única que cae, en las dos lecturas, es C09** (9 → 8 y 5 → 4). C04 conserva el rango 3 con ancla firmada, y C05 (rango 28) y C08 (rango 4) no estaban en el top 3 con ninguna ancla, de modo que su primer sub-resultado OCR no explica nada del desdoble. Ese hecho existe y es otro: es el que §6.6 punto 5 ya presentaba bien, como dato aparte. Control positivo del detector: `es_ocr_ancla("circular_812_identidad_genero.html#ocr-pagina-008")` → `TRUE`; control negativo: `es_ocr_ancla("zzqq.html#x")` → `FALSE`; control de fidelidad de la reimplementación contra la columna publicada en `a2_linea_base_pagefind.csv` (lectura A): 10 de 10 celdas.

---

## 1. Dimensionamiento del corpus como unidad de recuperación (medido)

### 1.1 Recuento

```
Rscript 50_documentacion/andamios/20260904_medicion_corpus_semantica.R   # sección "TAREA 1"
```

| Cifra | Valor | Origen |
|---|---|---|
| Archivos `40_salidas/datos/normas/*.json` | 25 | `fs::dir_ls(ruta_normas(), glob = "*.json")` |
| `catalogo.json`: `n_normas` / `n_articulos` | 25 / 682 | leído con `[[ ]]` |
| Unidades de recuperación (elementos de `articulos` en los 25 JSON) | **806** | `nrow(unidades)` |
| De ellas, artículos (`es_articulo == TRUE`) | **682** (coincide con el catálogo) | `sum(unidades[["es_articulo"]])` |
| Segmentos no artículo con texto firmado (preámbulos, MATERIA, ANTECEDENTES, numerales de dictámenes, "Documento completo" de las REX) | 40 | `count(unidades, origen_texto, es_articulo)` |
| Páginas OCR sin revisar (`origen_texto == "ocr_pendiente_revision"`) | 84 | ídem |
| Documentos con texto firmado / con OCR | 20 / 5 | tabla `a2_ocr_unidades.csv` |

**Consecuencia:** `n_articulos = 682` es el recuento de artículos, no de unidades buscables. Los cuatro dictámenes y las tres REX aportan **0 artículos y 82 unidades** (`4 + 9 + 9 + 10 + 1 + 1 + 48` del catálogo, tabla `a2_distribucion_articulos.csv`), de las cuales **25 son segmentos firmados** (dictámenes 065, 52-77 y 71, REX 181 y REX 482 instrucciones) y **57 son páginas OCR sin revisar** (48 del cuerpo de la REX 482 y 9 del dictamen 078); y son justamente las fuentes que responden "mochila", "expulsión" y "celular". La unidad de la capa 2 es el **segmento** (806), con el artículo como caso particular.

**(corregido en fase 3: CIF-A2-01)** La primera versión decía "34 segmentos (`4 + 9 + 10 + 9 + 1 + 1`)": seis sumandos para siete documentos, porque omitía las 48 páginas OCR del cuerpo de la REX 482, que sí es una de las tres REX. Recuento del turno de corrección sobre `catalogo.json`, documento por documento: rex_181 1, rex_482_instrucciones 1, rex_482_reglamentos_b 48, dictamen_52_77 9, dictamen_065 4, dictamen_71 10, dictamen_078 9 → **7 documentos, 82 segmentos, 0 artículos**. Control positivo del mismo comando (el instrumento sí ve artículos): `ley_20845` aporta 37. Control negativo: slugs `^zzqq` → 0. La consecuencia que el párrafo sostiene (la unidad es el segmento, no el artículo) se refuerza.

### 1.2 Regla de estimación de tokens (declarada, no medida)

No hay tokenizador ni API disponibles (red y cuota prohibidas). Se declaran dos reglas y se reportan ambas:

- `tok_c4 = ceiling(caracteres / 4)`: heurística habitual para tokenizadores BPE, calibrada en inglés. Es la regla primaria.
- `tok_c35 = ceiling(caracteres / 3,5)`: cota conservadora para español, que produce más tokens por carácter. Se usa para las decisiones de ventana, donde subestimar es el riesgo.

Ambas son **estimaciones**. Verificación pendiente cuando haya red: tokenizar `a2_distribucion_articulos.csv` con el tokenizador del modelo elegido y comparar contra `tok_c4`.

### 1.3 Distribución del largo de los 682 artículos (medida; tabla `a2_resumen_distribucion.csv`)

| Estadístico | Caracteres | Palabras | tok_c4 | tok_c35 |
|---|---|---|---|---|
| mínimo | 59 | 10 | 15 | 17 |
| p10 | 243,3 | 38 | 61,1 | 70,1 |
| p25 | 448 | 69 | 112,3 | 128,3 |
| **mediana** | **888,5** | **138** | **222,5** | **254,5** |
| p75 | 1 819,5 | 279 | 455,5 | 520,5 |
| **p90** | **3 117,9** | **485,7** | **780** | **891** |
| p95 | 4 610,7 | 689,6 | 1 152,9 | 1 317,8 |
| p99 | 11 939,5 | 1 847,6 | 2 985,4 | 3 411,9 |
| **máximo** | **27 167** | **4 189** | **6 792** | **7 762** |

El máximo es `ley_20845_inclusion_escolar.html#art-3` (27 167 caracteres): un artículo modificatorio que transporta entero el procedimiento de expulsión del art. 6 d) de la ley de subvenciones. Es a la vez el artículo más largo y una de las respuestas del conjunto de evaluación (C06).

Otras unidades (misma tabla): las 806 unidades tienen mediana 1 024,5 caracteres (256,5 tok_c4), p90 3 602 (901) y máximo 27 167. Los 40 segmentos no artículo firmados tienen mediana 1 607 (402), p90 8 711,7 (2 178,6) y máximo 20 769 (5 193): es el segmento `dictamen_065_revision_mochilas.html#fuentes`, que contiene el cuerpo completo del dictamen (ver hallazgo H3, §8). Las 84 páginas OCR tienen mediana 2 848,5 (712,5), p90 3 951,5 (988,3) y máximo 4 840 (1 210).

### 1.4 Cuántas unidades exceden una ventana (medido; tabla `a2_excesos_ventana.csv`)

Ventana de referencia declarada: **512 tokens**, largo máximo de secuencia típico de la clase de modelos de embedding pequeños y base (hipótesis de clase; el modelo concreto lo fija A4 con su documentación). Se reportan también 256, 1 024, 2 048 y 8 192.

| Ventana (tokens) | Artículos sobre la ventana (c4) | % | Artículos (c35) | Unidades 806 (c4) | Unidades (c35) |
|---|---|---|---|---|---|
| 256 | 302 | 44,3 | 340 | 403 | 441 |
| **512** | **149** | **21,8** | **175** | **227** | **261** |
| 1 024 | 39 | 5,7 | 54 | 56 | 83 |
| 2 048 | 12 | 1,8 | 15 | 17 | 20 |
| 8 192 | 0 | 0,0 | 0 | 0 | 0 |

El cero de la fila 8 192 tiene su control positivo en la misma tabla: el mismo comando cuenta 302 artículos sobre 256 tokens.

---

## 2. Unidad de fragmentación (decisión sustentada en §1)

**Decisión: unidad completa (artículo o segmento) como fragmento único cuando cabe en 512 tokens; ventana deslizante de 400 tokens con solapamiento de 50 (paso 350) solo para las 227 unidades que exceden 512 tokens (c4). No se fragmenta por inciso.**

Por qué no el inciso (párrafo): medido sobre los 682 artículos, partiendo por línea en blanco (`stringr::str_split(texto, "\n\\s*\n")`):

- 1 766 párrafos; solo 294 artículos tienen más de un párrafo; máximo 47 párrafos en un artículo.
- El párrafo no resuelve el problema del largo: 87 párrafos superan 512 tokens (c4) y el más largo tiene 12 580 caracteres. Mediana del párrafo: 334,5 caracteres.
- El inciso no tiene ancla en el sitio (`34_generar_paginas.R` emite un `<h2 id>` por unidad, no por párrafo), así que un resultado a nivel de inciso violaría el invariante 1 (rastreable a un ancla pública estable) salvo que se mapee de vuelta a su unidad, que es exactamente lo que hace la ventana deslizante con `id_unidad` como metadato.

Por qué no el artículo completo sin más: 149 artículos (21,8 %) exceden 512 tokens; con c35 son 175. Un modelo que trunca a 512 vectorizaría solo **el primer 7,5 %** (2 048 de 27 167 caracteres) de `ley_20845#art-3` (6 792 tokens c4) y el plazo de quince días para la reconsideración (C06) está en el carácter 22 381 de 27 167: quedaría fuera del vector.

**(corregido en fase 3: CIF-A2-03)** La primera versión decía "el primer cuarto". Recontado en el turno de corrección: `nchar` = 27 167, `512 × 4 = 2 048` caracteres, `100 × 2 048 / 27 167 = 7,54 %`, aproximadamente un treceavo. El corte deja fuera mucho más de lo que "un cuarto" sugiere, así que el argumento se refuerza. Control negativo del mismo localizador: `str_locate(texto, "zzqq inexistente")` → `NA`; control positivo: `"quince d"` en el carácter 22 381, que es `> 2 048`.

Aritmética de la ventana (calculada; tabla `a2_fragmentacion.csv`): `n_frag = 1` si `tok <= 512`; si no, `ceiling((tok - 50) / 350)`.

| Conjunto | Unidades | Fragmentos (c4) | Fragmentos (c35) |
|---|---|---|---|
| Artículos (firmados) | 682 | 1 052 | 1 145 |
| Segmentos no artículo firmados | 40 | 108 | 119 |
| Páginas OCR sin revisar | 84 | 184 | 215 |
| **Total firmadas** | **722** | **1 160** | **1 264** |
| Total | 806 | 1 344 | 1 479 |

Cada fragmento lleva `slug`, `id` (ancla), `n_fragmento`, `origen_texto`, `estado_vigencia` y `anio`. El resultado que se muestra es siempre la **unidad** (una vez por ancla, con el mejor fragmento como puntaje), nunca el fragmento suelto.

---

## 3. Peso del índice de embeddings (calculado sobre cifras medidas)

Fórmula: `bytes = N × dim × bytes_por_dim + N × 57,8`, donde 57,8 bytes es el costo medido de los metadatos mínimos (`slug`, `id`) por unidad (`nchar(jsonlite::toJSON(unidades[, c("slug","id")]), "bytes") / 806`). Formatos: float32 = 4 bytes/dimensión, int8 = 1, binario = 1/8. Tiempo de descarga: `bytes × 8 / 3 000 000` (3 Mbps, conexión móvil declarada por el encargo). Tabla completa (45 configuraciones): `a2_peso_indice.csv`.

**Declaración de fórmula y unidad, para que la síntesis no compare peras con manzanas (CON-A4-07 / H-18).** Toda cifra de peso de este documento (a) **suma los 57,8 bytes de metadatos por unidad**, porque lo que se descarga es un archivo, no un arreglo de vectores desnudo, y (b) se calcula sobre los **1 160 fragmentos firmados**, que es lo que este documento decide indexar (§2 y §4quater). Otros documentos del encargo dimensionan el mismo objeto sin metadatos y sobre los 682 artículos: `682 × 1 024 = 698 368` bytes sin metadatos contra `682 × 1 024 + 682 × 57,8 = 737 788` (720,5 KiB) con ellos. **Ninguna de las dos es errónea y ninguna cambia el veredicto** (el índice cabe en todas), pero son dos fórmulas y tres universos, y la tabla única de la fase 4 no puede traer tres valores del mismo objeto: fijar una sola es tarea de la síntesis, y se reporta al orquestador.

| N (conjunto) | dim | float32 | int8 | binario |
|---|---|---|---|---|
| 682 (artículos) | 384 | 1 061,5 KB (2,90 s) | 294,2 KB (0,80 s) | 70,5 KB (0,19 s) |
| 682 | 768 | 2 084,5 KB (5,69 s) | 550,0 KB (1,50 s) | 102,4 KB (0,28 s) |
| 682 | 1 024 | 2 766,5 KB (7,55 s) | 720,5 KB (1,97 s) | 123,7 KB (0,34 s) |
| **722 (unidades firmadas)** | **384** | 1 123,7 KB (3,07 s) | **311,5 KB (0,85 s)** | 74,6 KB (0,20 s) |
| 722 | 768 | 2 206,7 KB (6,03 s) | 582,2 KB (1,59 s) | 108,4 KB (0,30 s) |
| 722 | 1 024 | 2 928,7 KB (8,00 s) | 762,7 KB (2,08 s) | 131,0 KB (0,36 s) |
| 806 (todas) | 384 | 1 254,5 KB (3,43 s) | 347,7 KB (0,95 s) | 83,3 KB (0,23 s) |
| 806 | 1 024 | 3 269,5 KB (8,93 s) | 851,5 KB (2,33 s) | 146,2 KB (0,40 s) |
| **1 160 (fragmentos firmados, ventana)** | **384** | 1 805,5 KB (4,93 s) | **500,5 KB (1,37 s)** | 119,8 KB (0,33 s) |
| 1 160 | 768 | 3 545,5 KB (9,68 s) | 935,5 KB (2,55 s) | 174,2 KB (0,48 s) |
| 1 160 | 1 024 | 4 705,5 KB (12,85 s) | 1 225,5 KB (3,35 s) | 210,5 KB (0,57 s) |
| 1 344 (todos los fragmentos) | 1 024 | 5 451,9 KB (14,89 s) | 1 419,9 KB (3,88 s) | **243,9 KB (0,67 s)** |

**(corregido en fase 3: CIF-A2-02)** La celda binaria de la última fila decía "146,2 KB (0,40 s)", que es el valor de la fila `806 × 1 024` de dos filas más arriba: error de transcripción, no de cálculo. Re-derivado con la fórmula que este mismo §3 declara: `1 344 × 1 024 / 8 + 1 344 × 57,7916 = 249 703,9` bytes = **243,9 KB**, y `249 703,9 × 8 / 3 000 000 = 0,67 s`. Control de la misma fórmula sobre la fila vecina: `806 × 1 024` binario = 146,2 KB (0,40 s), que es de dónde venía el número mal copiado. El artefacto ya traía el valor correcto (`a2_peso_indice.csv`, fila `fragmentos_todos_ventana,1344,1024,binario` → `kb_total = 243.9`, `seg_a_3mbps = 0.67`), así que no hubo que recalcularlo. Ninguna recomendación usa esta fila (la elegida es int8 × 384).

**Contraste con lo que el sitio ya descarga** (medido; tabla `a2_referencias_peso_sitio.csv`):

| Referencia | Bytes | KB |
|---|---|---|
| `40_salidas/sitio/pagefind/` completo (55 archivos) | 1 521 719 | 1 486,1 |
| `pagefind/index/` | 457 993 | 447,3 |
| `pagefind/fragment/` | 416 553 | 406,8 |
| `wasm.es.pagefind` | 72 349 | 70,7 |
| `pagefind.js` + `pagefind-ui.js` | 45 555 + 119 987 | 161,7 |
| Los 47 HTML del sitio | 3 048 234 | 2 976,8 |
| HTML más pesado (`dfl_1_estatuto_asistentes_educacion.html`) | 305 372 | 298,2 |

Pagefind carga sus fragmentos bajo demanda, así que una visita típica no baja los 1,49 MB; pero el presupuesto de "una búsqueda" ya incluye 70,7 KB de WASM y 44,5 KB de JS antes del primer resultado. Un índice vectorial de **311,5 a 500,5 KB en int8 a 384 dimensiones** es del mismo orden que `pagefind/index/` (447,3 KB) y pesa **entre 1,04 y 1,68 veces la página más pesada del sitio** (298,2 KB), muy por debajo de los 2 976,8 KB del HTML completo. **Cabe.** Un índice float32 a 768 o 1 024 dimensiones (2,2 a 4,7 MB) pesa más que todo el HTML del sitio junto: no cabe como descarga de un sitio estático.

**(corregido en fase 3: CIF-A2-07)** La primera versión decía "y menor que la página más pesada del sitio", y es falso en los dos extremos del rango. Recontado en el turno de corrección: `722 × 384 + 722 × 57,7916 = 318 974` bytes y `1 160 × 384 + 1 160 × 57,7916 = 512 478`, contra `fs::file_size("40_salidas/sitio/dfl_1_estatuto_asistentes_educacion.html") = 305 372` bytes; **ambos la superan** (1,04× y 1,68×). Control positivo de la misma comparación (algo que sí es menor): el índice binario de 682 × 384 pesa 70,5 KB < 298,2 KB → `TRUE`. El veredicto "cabe" no cambia: la referencia que lo sostiene es el HTML completo del sitio (2 976,8 KB) y el propio `pagefind/index/`.

Compresión (medida sobre un proxy sintético, `a2_compresibilidad_proxy.csv`, 806 vectores aleatorios normalizados de 384 dimensiones): gzip deja float32 en el 92,6 % de su tamaño (no comprime) e int8 en el 59,9 %. Los archivos reales de Pagefind ya vienen comprimidos: `pagefind/index/` pasa de 457 993 a 458 114 bytes con gzip (no reduce). Conclusión calculada: **no contar con gzip para hacer caber float32; cuantizar a int8 es lo que reduce 4 veces.** Hipótesis que esto no valida: la pérdida de calidad de int8 frente a float32 en este corpus; se mide con el conjunto de evaluación de §5 cuando existan vectores.

**Lo que este cálculo no incluye y domina la decisión:** el peso del modelo que vectoriza la consulta en el navegador. No se midió (sin red) y no se cita de memoria. Verificación: descargar el artefacto ONNX cuantizado del modelo elegido y medir `fs::file_size()`; hasta entonces, la vía semántica en el navegador se especifica con la consulta vectorizada por un servicio (Worker) y el índice estático en el navegador. Costo por consulta de esa llamada, en tokens (calculado): las 10 consultas de evaluación tienen 49,2 caracteres en promedio y 66 como máximo, es decir 17 tokens (c4) o 19 (c35) como máximo; una llamada de embedding por consulta cuesta del orden de 20 tokens. Costo de vectorizar el corpus en cada build (calculado): 301 659 tokens c4 (344 755 c35) para las 722 unidades firmadas, 357 759 c4 si se incluye el OCR; con fragmentación por ventana el solapamiento suma 50 tokens por fragmento adicional, es decir `(1 160 - 722) × 50 = 21 900` tokens más. Los precios los cita A4; aquí solo se deja la cantidad.

---

## 4. Búsqueda híbrida: especificación (no elección entre motores)

La decisión de §0bis es fusión. Esta sección fija **cómo** se fusiona, **qué** gana siempre la vía léxica, **qué** se conserva por resultado, y recién después compara **dónde vive** el índice.

### 4.1 Vías y candidatos

- **Vía léxica (L):** Pagefind sobre el índice existente, consultado por su API (`pagefind.search(termino, {filters})`), a nivel de **sub-resultado** (una entrada por ancla `<h2 id>`), con puntaje `s_L = suma de balanced_score de las coincidencias del sub-resultado` y desempate por `score` de página. Devuelve los K_L primeros.
- **Vía semántica (V):** similitud coseno entre el vector de la consulta y los vectores de los fragmentos; se agrupa por unidad (`slug#id`) quedándose con el máximo. Devuelve las K_V primeras unidades.
- **K_L = K_V = 30** (sustento en §4bis). Unión máxima: 60 candidatos.

### 4.2 Fusión: Reciprocal Rank Fusion

`rrf(u) = w_L / (k + rango_L(u)) + w_V / (k + rango_V(u))`, con `k = 60`, `w_L = w_V = 1`, y `rango = ∞` (término nulo) si la unidad no está en la lista de esa vía. Ejemplo: una unidad primera en léxica y tercera en vectorial vale `1/61 + 1/63 = 0,0322`; una que solo aparece primera en vectorial vale `1/61 = 0,0164`.

Por qué RRF y no una suma ponderada de puntajes: `s_L` de Pagefind es una suma de pesos de coincidencias (medida en §6: valores **entre 214,3 y 109 411,3 en una misma consulta**, C06 sin filtro, y entre 73,3 y 402 811,3 sobre las 51 consultas con resultado) y la similitud coseno vive en [-1, 1]; son inconmensurables. RRF usa solo rangos, no exige normalizar ni calibrar, y con `k = 60` una posición 1 frente a una posición 5 apenas cambia el resultado (0,0164 frente a 0,0154), lo que evita que una sola vía domine por ruido. Los parámetros `k`, `w_L`, `w_V`, `K_L`, `K_V` se declaran en un JSON de configuración y se reportan en cada respuesta.

**(corregido en fase 3: CIF-A2-06)** La primera versión escribía el rango como "entre 214 y 99 782". Los dos valores existen y salen de la misma consulta, pero **99 782,74 no es el máximo**: es el cuarto valor. Aplanados los sub-resultados de C06 sin filtro en el turno de corrección (104 sub-resultados con ancla): máximo `109 411,32` (`ley_20845#art-20-transitorio`), luego `108 607,00`, `105 145,56` y `99 782,74`; mínimo `214,27`. Sobre las 51 consultas con resultado, `73,3` a `402 811,3`. Control positivo del aplanador: encuentra el valor que la primera versión citaba (hay un sub-resultado entre 99 782 y 99 783 en C06 sin filtro → `TRUE`). El argumento (la dispersión hace inconmensurables los puntajes) sale reforzado.

### 4.3 Consultas que la vía léxica gana siempre

Regla de clasificación de la consulta, antes de recuperar, por expresión regular sobre el texto normalizado (minúsculas, sin diacríticos):

| Clase | Patrón (orientativo; se deriva y prueba en runtime, no se escribe a mano en producción) | Comportamiento |
|---|---|---|
| Identificador de norma | `ley\s*n?º?\s*\d{1,2}\.?\d{3}`, `decreto\s*(supremo\s*)?n?º?\s*\d+`, `dfl\s*n?º?\s*\d+`, `(dictamen\|circular\|rex\|resolucion exenta)\s*n?º?\s*\d+` | **Solo léxica** (`w_V = 0`) y coincidencia exacta contra `numero` del catálogo **anclada** en la posición 1, antes de cualquier fusión. |
| Identificador de artículo | `art(iculo\|\.)?\s*\d+\s*(bis\|ter\|quater\|quinquies)?`, opcionalmente seguido de identificador de norma | Igual: coincidencia exacta contra `id` de unidad (`art-10-bis`) anclada en 1. Si no hay norma, se anclan todas las unidades con ese `id` (hay 25 normas; el `art-3` existe en varias). |
| Figura jurídica exacta | Frase que coincide con una entrada del vocabulario controlado de la capa 1 (`cancelación de matrícula`, `medida cautelar`, `encargado de convivencia`) | Léxica con `w_L = 2`; la vectorial sigue activa (`w_V = 1`) para no perder paráfrasis del resto de la consulta. |
| Lenguaje natural (todo lo demás) | | `w_L = w_V = 1`. |

Garantía de no degradación: una unidad **anclada** por identificador se emite con `rrf = +∞` y rótulo `coincidencia_exacta = true`; la fusión solo ordena lo que viene después. Prueba de regresión obligatoria: las consultas `ley 21.801`, `artículo 10 bis`, `dictamen 65` y `circular 482` deben devolver su norma en la posición 1 con `coincidencia_exacta = true`, y esa prueba corre contra el mismo arnés de §6.

Alias históricos ("circular 482" contra "REX 482") no son problema de la fusión: son problema del vocabulario de la capa 1, que resuelve el alias antes de clasificar. Aquí solo se exige que el identificador resuelto llegue a la clase "identificador de norma".

### 4.4 Puntajes conservados por resultado (contrato del JSON de respuesta)

Cada resultado devuelto conserva **todos** sus puntajes intermedios; es el insumo de cualquier evaluación futura y de la auditoría:

```
{ "slug": "...", "id": "art-10-bis", "ancla": "ley_21801_celulares.html#art-10-bis",
  "clase_consulta": "lenguaje_natural | identificador_norma | identificador_articulo | figura_juridica",
  "coincidencia_exacta": false,
  "lexica":   { "rango": 1, "score_pagina": 7.92, "suma_balanced": 4097.1, "n_coincidencias": 8 },
  "vectorial": { "rango": 3, "cos": 0.71, "fragmento": 2, "n_fragmentos": 4 },
  "rrf": 0.0322, "rango_fusion": 1,
  "reranking": { "aplicado": true, "puntaje": 0.83, "rango_final": 1 } | { "aplicado": false },
  "origen_texto": "capa_texto_pdf", "vigencia": "vigente", "anio": 2026,
  "parametros": { "k": 60, "w_L": 1, "w_V": 1, "K_L": 30, "K_V": 30 } }
```

Un campo ausente es un error, no un valor por defecto: si la vía vectorial no corrió, `vectorial` vale `null` con `motivo`.

### 4.5 Dónde vive el índice: comparación de las tres opciones

La comparación es de infraestructura. Las tres tienen las dos vías; lo que cambia es dónde se almacena y calcula la vía vectorial, y en la opción 3, qué reemplaza a la vía vectorial mientras no exista.

| Criterio | Opción 1: índice vectorial estático en el navegador | Opción 2: Vectorize (Cloudflare) | Opción 3: Pagefind + expansión de vocabulario (A1) + reordenamiento de sub-resultados |
|---|---|---|---|
| Peso descargado por el visitante | 311,5 KB (722 unidades) a 500,5 KB (1 160 fragmentos), int8 × 384 dimensiones (calculado §3). Más el índice Pagefind actual (447,3 KB de `index/`, medido). | Solo Pagefind. El índice vectorial vive en Cloudflare. | Solo Pagefind más el JSON del vocabulario (peso: lo mide A1). |
| Latencia por consulta | Pagefind: 0,70 a 27,48 ms por consulta en Node sobre HTTP local (medido §6; la primera consulta paga la carga de fragmentos). Producto punto de 1 160 × 384 int8 en JS: hipótesis de pocos milisegundos; verificar con `performance.now()` en el arnés. Más **una llamada de red** para vectorizar la consulta (Worker → API de embeddings) mientras no haya modelo en el navegador. | Dos llamadas de red por consulta (Worker → Workers AI para el vector de la consulta; Worker → Vectorize). Latencia: la mide A4 contra documentación. | Cero llamadas de red. Solo Pagefind. |
| Costo por consulta | ~20 tokens de embedding (calculado §3). Precio: A4. | Igual más la consulta a Vectorize (límites gratuitos: A4). | Cero. |
| Costo por build | 301 659 tokens c4 para vectorizar las 722 unidades firmadas, más 21 900 de solapamiento (calculado §3). | Igual, más la carga a Vectorize (escritura). | Cero. |
| Mantenimiento | Un paso más del pipeline en R (`3x_vectorizar.R`) que escribe un binario en `40_salidas/`; el JSON de vectores se regenera con el manifiesto de huellas existente. Sin servicio que administrar salvo el Worker que custodia la clave. | Dos servicios administrados con su ciclo de vida (índice, namespaces, versiones del modelo) y un Worker. Desfase entre el sitio publicado y el índice remoto si un despliegue falla a medias. | Ninguno nuevo: el vocabulario es un JSON estático que ya construye A1; el reordenamiento es un `process_result` en `busqueda.html`. |
| Qué se rompe a 100 normas (×4, extrapolación lineal calculada) | 4 640 fragmentos firmados × 384 int8 ≈ 2,0 MB (1 781 760 + 268 192 bytes). Sigue cabiendo; en 3 Mbps son 5,5 s, ya incómodo: habría que partir el índice por norma o por tema. Pagefind: 447,3 × 4 ≈ 1,8 MB de `index/` y 1,6 MB de `fragment/`, cargados bajo demanda. | Nada de peso; el costo por consulta y por build escala ×4. | Pagefind escala igual que en la opción 1. El vocabulario crece con el corpus. |
| Cobertura medida sobre las 10 consultas (§6) | La vía vectorial no se midió (prohibido gastar cuota). Lo que se sabe: hay **3 consultas cuya palabra clave no aparece** en su unidad objetivo (C02 "celular", C04 "bullying", C06 "apelar"), y de ellas **solo C04 no comparte ninguna palabra de contenido** con su objetivo (0 de 1). El residuo que solo una vía por significado puede rescatar es **1 de 10**; las otras dos las alcanza una expansión de vocabulario. | Ídem. | Cota superior medida con el término canónico: 9 de 10 páginas y 5 de 10 artículos en el top 3 (**8 y 4 si se exige unidad citable**, H-16); con reordenamiento de sub-resultados la interfaz pasaría de 0 a 3 de 10 sin tocar el índice. **La cota no es alcanzable con la capa 1 tal como está hoy** (H-12): es un mapeo manual de A2. |

**(corregido en fase 3: CIF-A2-05 = H-20)** La primera versión escribía "las 3 consultas sin ninguna palabra de contenido en la unidad objetivo". La columna que este mismo documento midió dice otra cosa, y §5 la publica bien: C02 tiene 2 de 3 términos en su objetivo ("sala", "clases"), C06 tiene 3 de 5 ("dias", "apoderado", "expulsion") y **solo C04 tiene 0** (de 1). Recontado en el turno de corrección sobre `a2_consultas_evaluacion.csv`: consultas con cero términos de contenido en su unidad objetivo → **C04**, una sola. Control positivo de la misma columna (que no es toda cero): C09 y C10 con 4 de 4. El cuantificador estaba mal, el dato no: lo que falta en cada una es la **palabra clave**, no todas las palabras. Con 1 de 10 en vez de 3 de 10, el orden que esta misma sección recomienda (léxica primero, vectorial después) queda **más firme**, y la urgencia de la vía vectorial baja.

**Recomendación:** opción 3 como vía léxica obligatoria y primera en construirse (no requiere red, cuota ni servicio, y su techo medido es 9 de 10 páginas), y opción 1 como vía semántica, con el índice int8 × 384 estático en el navegador y la consulta vectorizada por el Worker que A4 especifica. Razón concreta: la única función que exige servicio es vectorizar 20 tokens por consulta; llevar además el índice a Vectorize agrega dos servicios administrados para servir un archivo de 0,5 MB. La opción 2 se descarta a esta escala y a 100 normas; se reconsideraría si el índice superara el peso de la página más pesada del sitio partido por norma (298,2 KB), que a 384 int8 ocurre recién **por sobre 691 fragmentos por norma**.

**(corregido en fase 3: CIF-A2-12)** El umbral decía "700 fragmentos por norma". Re-derivado con la fórmula del propio §3 y los bytes medidos: `305 372 / (384 + 57,7916) = 691,2`. Se escribe 691, no 700: un redondeo al alza vuelve el criterio menos exigente de lo que la aritmética sostiene, y el 700 no estaba declarado como redondeo.

**Dos condiciones que esta recomendación no puede omitir, levantadas por el panel adversarial (`…panel_adversarial_motor_v1.md` §12):**

1. **(H-12) El 9 de 10 de la opción 3 es una cota, no un rendimiento alcanzable hoy.** La variante `canonico` es un mapeo manual de A2 (§6.3: "no se leyó el vocabulario de A1"), y el panel midió las mismas 10 consultas contra el resolutor real de A1: con el contrato AND que A1 recomienda, **0 de 10** llegan a una página aceptada y 9 devuelven cero sugerencias; con OR, que A1 mide y no recomienda, 7 de 10. La recomendación de construir primero la opción 3 **queda condicionada** a que exista la tabla de alias curados que A1 propone en su §2.4; sin ella, lo que la opción 3 entrega no es la cota sino la línea base `sin_filtro` (3 de 10 páginas). Nadie puede escribir "la opción 3 alcanza 9 de 10" sin esta condición. La cifra de A1 es del panel, no medida por A2: A2 no leyó el vocabulario de A1 (§7, punto 6).
2. **(H-17) Sin el Worker, la capa 2 no sobrevive entera.** Bajo esta recomendación la consulta se vectoriza en el Worker, así que ante una caída del servicio sobrevive la **capa 2 léxica** (Pagefind, estática, cero llamadas de red) y **no** la capa 2 semántica, que se queda sin vector de consulta y degrada a solo léxica. El índice vectorial sigue descargándose (es un archivo estático) y queda inutilizable hasta que vuelva el servicio. La alternativa que eliminaría la dependencia es vectorizar la consulta en el navegador, y su costo es exactamente lo que este documento declara **no medido** (el peso del modelo, §3 y §9). El plan de degradación de A4 §6 debe hacer esta misma distinción; se reporta al orquestador.

---

## 4bis. Reranking: especificación

**Qué reordena:** los hasta 60 candidatos fusionados (§4.1), no el corpus. Entrada: consulta más, por candidato, el texto de la unidad (o del mejor fragmento) y sus metadatos (`origen_texto`, `vigencia`, `anio`). Salida: un puntaje por candidato y el orden final, conservando `rango_fusion` (§4.4).

**Tres niveles, del más barato al más caro; el motor usa el más alto disponible y declara cuál usó:**

| Nivel | Qué hace | Costo por consulta | Si no está disponible |
|---|---|---|---|
| R0, determinístico (siempre disponible) | Reordena por `rrf` con tres ajustes de metadatos: unidades con `origen_texto` no firmado van **después** de todas las firmadas (§4quater); unidades `sustituido` reciben un factor 0,8 sobre `rrf` salvo que la consulta lleve filtro temporal (§4ter); unidades con `coincidencia_exacta` quedan primeras. | Cero. | No aplica: es el piso. |
| R1, cross-encoder por API | Puntaje consulta-candidato por un modelo de reranking sobre 30 a 60 pares. | 30 a 60 pares de (≤ 19 + ≤ 512) tokens; con 30 candidatos de largo típico 256 tokens: ≈ 8 250 tokens (calculado: `30 × (256 + 19)`); peor caso 30 × 531 = 15 930. Precio: A4. | Cae a R0 y lo declara en `reranking.aplicado = false`. |
| R2, LLM en modo lista | Un modelo recibe la consulta y los 30 candidatos y devuelve un orden con justificación de una línea por candidato. | Mismo volumen de entrada que R1 más el prompt y ~30 líneas de salida. | Cae a R1 o R0. La justificación generada es **nivel 4 (inferencia del modelo)** y no se muestra como fundamento: es de la capa 3, no de esta. |

**Cuántos candidatos hay que recuperar (medido en §6, lectura C, variante `canonico`, tabla `a2_linea_base_resumen.csv`):** rango en que aparece el ancla aceptada por consulta: C01 = 1, C02 = 1, C03 = 18, C04 = 3, C05 = 28, C06 = 4, C07 = 65, C08 = 4, C09 = 2, C10 = 1. Es decir, **K = 4 cubre 7 de 10** (y K = 10 no agrega ninguna: sigue en 7); K = 28 cubre 9 de 10; solo K = 65 cubre las 10. Con la consulta tal como la escribe el equipo (variante `sin_filtro`) los rangos son C05 = 4, C06 = 2, C10 = 8 y las otras 7 no aparecen en ningún K: la vía léxica sola no las recupera y ningún reranking arregla lo que no fue recuperado.

**(corregido en fase 3: CIF-A2-04 y CIF-A2-10)** La primera versión decía "K = 4 cubre 6 de 10", y §0 decía "9 de 10 aparecen **antes** del rango 28". Recontado en el turno de corrección sobre los mismos diez rangos, con el barrido completo de K: `K=0` cubre 0, `K=3` 5, `K=4` **7**, `K=10` 7, `K=27` **8**, `K=28` **9**, `K=30` 9, `K=65` 10, `K=1000` 10. Es decir: K = 4 cubre 7, no 6; y la novena (C05) aparece **exactamente** en el rango 28, no antes, de modo que "antes del rango 28" son 8 y "hasta el rango 28" son 9. Controles del mismo contador en el mismo bloque: K = 1 000 cubre 10 de 10 y K = 0 cubre 0. **La decisión K = 30 no cambia.**

**Decisión: K = 30 por vía.** Cubre 9 de 10 en la cota léxica; la décima (C07, "quiénes tienen que estar en el consejo escolar", ancla `dto_24_consejos_escolares.html#art-3`, rango 65) falla porque "consejo escolar" aparece en 32 unidades y Pagefind puntúa por suma de coincidencias, con lo que `ley_19979#art-1` (14 633 puntos) supera a `dto_24#art-3` (2 048,6). Ese es el caso que se le pide resolver al reranking: la unidad correcta es la que *define* la integración, no la que más veces nombra al consejo. Si con K = 30 y R1 el conjunto de §5 no alcanza 8 de 10 en el top 3, se sube K a 60 y se vuelve a medir; no se sube por convención.

**Lo que se declara fuera de alcance (§0bis):** entrenar un reranker propio.

---

## 4ter. Dimensión temporal: especificación y suficiencia de los datos

### 4ter.1 Datos disponibles (medido; tabla `a2_temporalidad.csv`)

| Cifra | Valor | Comando |
|---|---|---|
| Normas con `anio` no nulo | **21 de 25** | `sum(!is.na(normas_cat[["anio"]]))` |
| Normas sin año | 4: `circular_193_estudiantes_embarazadas`, `circular_586_tea`, `circular_812_identidad_genero`, `rex_482_reglamentos_b` | ídem |
| Normas con `fuente_anio` curada | 4 | `sum(!is.na(normas_cat[["fuente_anio"]]))` |
| Normas con `vigencia.estado != "vigente"` | **1** (`dictamen_065_revision_mochilas`, `sustituido`) | `sum(normas_cat[["estado"]] != "vigente")` |
| Normas con `sustituido_por` | 1 | ídem |
| Normas con `sustituye_a` no vacío | 1 (`dictamen_078`) | `sum(normas_cat[["n_sustituye_a"]] > 0)` |
| Normas con algún campo `fecha*` en `vigencia` | **0** (control positivo: 25 tienen el campo `estado`) | `grepl("fecha", campos_vigencia)` |
| Faceta `anio` del índice Pagefind | 16 valores, incluido `sin año determinado` = 4 | `pagefind.filters()` vía el arnés |

La granularidad es el **año de publicación**: no hay mes ni día, ni fecha de sustitución (la sustitución se fecha por el `anio` de la norma que sustituye, 2026 para el dictamen 078).

### 4ter.2 Semántica del filtro

- **"Qué rige hoy"** (`fecha = 2026-09-05`): unidades cuya norma tiene `estado == "vigente"`. Medido: **24 normas**. Equivale al filtro `vigencia: vigente` que el índice Pagefind ya expone (faceta medida: `vigente = 24`, `sustituida = 1`).
- **"Qué regía en `A`"** (`A = 2021`): norma con `anio <= A` y (`estado == "vigente"` o `anio_sustituto > A`). Medido para 2021: **12 normas determinables** (`ley_19979`, `ley_20370`, `ley_20536`, `ley_20845`, `ley_20911`, `dfl_1`, `dfl_315`, `dto_24`, `dto_215`, `dto_453`, `dto_565`, `rex_482_instrucciones`), **9 posteriores a 2021** y **4 indeterminables** (sin año). Las indeterminables se devuelven **marcadas** "año no determinado", nunca se ocultan: ocultarlas afirmaría una fecha que nadie curó.
- Con granularidad de año, "regía en 2021" no distingue enero de diciembre: una norma publicada en 2021 se devuelve con la marca "publicada ese año; verificar mes en el PDF". No hay ninguna en el corpus con `anio == 2021` (la tabla lo muestra: 2018 y luego 2022), así que hoy la ambigüedad es teórica.

### 4ter.3 Marca de una norma sustituida (nunca ocultarla)

Una unidad de `dictamen_065` se devuelve siempre que la recuperación la traiga, con: insignia `sustituida`, enlace a `sustituido_por` (`dictamen_078_detectores_revision_mochilas.html`), el `anio` de ambas, y la nota de que el sustituto está en OCR sin revisar (medido: `dictamen_078` tiene `origen_texto = ocr_pendiente_revision`). En R0 recibe factor 0,8 sobre `rrf` cuando no hay filtro temporal; con filtro "regía en 2022" recibe factor 1. El caso C01 de §6 es exactamente este: la única doctrina **firmada** sobre revisión de mochilas está en la norma sustituida, y la vigente no es citable todavía. Ocultar la sustituida dejaría la consulta sin ningún fundamento citable.

### 4ter.4 Suficiencia: el dato que falta no es la fecha, es el artículo

Con 21 de 25 años, 1 sustitución y 0 fechas exactas, el filtro temporal por norma es implementable y casi trivial. El vacío que la medición deja a la vista es otro: la vigencia **por artículo**. `ley_21809_convivencia_educativa` (2026) reescribe el art. 16 B de la LGE y el corpus conserva `ley_20536_violencia_escolar.html#art-16-b` (2011) como unidad vigente sin relación con `ley_21809_convivencia_educativa.html#art-16-b`; lo mismo con el "encargado de convivencia escolar" (`ley_20536#art-unico`) que la ley 21.809 convierte en "coordinador de convivencia educativa" (`#art-15`, `#art-4-3`). Ninguna de las 552 relaciones lo representa (tipos medidos en `relaciones.json`: `tema` 502, `remision` 46, `sustitucion` 2, `grupo_acto` 2). Es un hallazgo para el orquestador (H4, §8), no una propuesta de este documento: por §0bis, una relación nueva entra solo con regla determinística, y esa regla, **para este caso concreto** (la vigencia por artículo entre dos redacciones del mismo artículo), exige un metadato curado por artículo que hoy no existe.

**(corregido en fase 3: CON-A2-06r)** Se agregan las tres palabras de alcance. La subordinada, leída fuera del párrafo, parecía declarar no derivable **toda** ampliación de la ontología, y eso es falso: A3 §8.2 sí deriva tipos nuevos sin metadato curado (`modifica`, 8 pares, y `reglamenta`, 2). Lo que A2 afirma, y sigue siendo verdadero y medido, es más angosto: para vincular `ley_20536#art-16-b` con `ley_21809#art-16-b` no hay señal en el texto (los únicos 2 segmentos del corpus con nota marginal de la BCN están en `dfl_1`, y el art. 16 B de la 20.536 no trae nota, ni "D.O.", ni mención de la 21.809). Para la evaluación tipo por tipo, ver A3 §8.2. No cambia ninguna conclusión de A2 ni de A3.

---

## 4quater. Tratamiento del OCR no revisado en la recuperación

### 4quater.1 Recuento propio (medido; tabla `a2_ocr_unidades.csv`)

Valores válidos leídos de `10_utils/10_configuracion.R`: `ORIGENES_TEXTO = capa_texto_pdf, ocr_pendiente_revision, ocr_revisado, sin_texto`. Firmados: `capa_texto_pdf` y `ocr_revisado`. Presentes en el corpus: `capa_texto_pdf` y `ocr_pendiente_revision` (todos dentro de `ORIGENES_TEXTO`: `TRUE`).

| Documento | Unidades OCR sin revisar | Caracteres | tok_c4 |
|---|---|---|---|
| `circular_193_estudiantes_embarazadas` | 16 | 28 224 | 7 061 |
| `circular_586_tea` | 1 | 2 717 | 680 |
| `circular_812_identidad_genero` | 10 | 36 856 | 9 217 |
| `dictamen_078_detectores_revision_mochilas` | 9 | 31 272 | 7 821 |
| `rex_482_reglamentos_b` | 48 | 125 207 | 31 321 |
| **Total** | **84 en 5 documentos** | 224 276 | 56 100 |

Control positivo del mismo comando: 722 unidades firmadas en 20 documentos. La cifra heredada de `ESTADO.md` (84 páginas en 5 documentos) queda **confirmada por recuento propio**. Con ventana deslizante son 184 fragmentos (c4).

En el índice Pagefind existente estas unidades ya están separadas por la faceta `texto` (medida: `OCR sin revisar = 5`, `verificado = 20` páginas) y el generador emite un `<h2 id="ocr-pagina-NNN">` por página, nunca `art-N`. **Recorrido exhaustivo** de los 25 JSON de `40_salidas/datos/normas/`: de las **84** unidades con `origen_texto = ocr_pendiente_revision`, **84 llevan un id de la forma `ocr-pagina-N` y 0 empiezan por `art-`**; control positivo del mismo recorrido (el instrumento sí ve ids de artículo): **682** unidades firmadas con id `art-`; las 5 normas afectadas son `circular_193`, `circular_586`, `circular_812`, `dictamen_078` y `rex_482_reglamentos_b`. Las anclas `#ocr-pagina-008` y `#ocr-pagina-009` verificadas en §5 son la ilustración, no la verificación.

**(corregido en fase 3: UNI-A2-02)** El universal ("nunca `art-N`") es verdadero, pero lo que la primera versión exhibía como verificación era la existencia de dos anclas, es decir un caso positivo, no el recorrido que la palabra "nunca" exige. Se sustituye por el recuento exhaustivo de arriba, con su control positivo, y las dos anclas quedan como ejemplo.

### 4quater.2 Las tres opciones, contra los datos

| Opción | Qué pasa con C09 ("nombre social") | Qué pasa con C01 ("mochila") | Riesgo |
|---|---|---|---|
| Excluir | Cero resultados: ninguna unidad firmada contiene "nombre social" (medido: 0 firmadas, 2 OCR). El motor afirmaría, por omisión, que la normativa no dice nada. | Devuelve solo `dictamen_065` (sustituido); el vigente desaparece. | Falso negativo sistemático en identidad de género, embarazo y TEA, que son 3 de los 5 documentos OCR. |
| Devolver marcadas | Devuelve `circular_812#ocr-pagina-008` con rótulo "texto sin revisar, no citable, ver PDF". | Devuelve ambos: `065` (firmado, sustituido) y `078` (vigente, OCR), cada uno con su marca. | Que la marca no viaje con el texto copiado (ataque de A5); se mitiga con **la marca dentro del texto** (ver restricción 4), el bloque aparte y el enlace al PDF en el propio fragmento. |
| Solo si no hay alternativa firmada | Igual que "marcadas" en C09. | Oculta `078` porque `065` es firmado: le esconde al equipo que existe un pronunciamiento vigente. | Regla que depende de que la alternativa firmada sea *correcta*, cosa que el motor no sabe. |

**Recomendación: devolverlas marcadas**, con **cuatro** restricciones que no son opcionales: (1) van en un **bloque aparte** al final de la lista, bajo el rótulo literal `AVISO_OCR_PENDIENTE` de `10_configuracion.R` ("Texto obtenido por OCR, en revisión; el PDF oficial es la fuente"); (2) en R0 se ordenan **después** de toda unidad firmada, cualquiera sea su `rrf`; (3) **no son elegibles como fundamento** de la capa 3 ni como cita en ninguna salida generada: el arnés antialucinación de A3 debe rechazar un ancla `#ocr-pagina-*` como cita; (4) **la marca va dentro del texto del resultado, no solo en el DOM que lo rodea.** El usuario puede excluirlas con el filtro `texto: verificado` que ya existe (medido en §6: la variante `texto_verificado` reduce los candidatos de 152,7 a 127,9 en promedio y deja C09 sin respuesta, como corresponde).

**(corregido en fase 3: H-1)** La primera versión mitigaba el ataque "la marca no viaja con el texto copiado" solo con el bloque aparte y el enlace al PDF. El bloque aparte es DOM: al copiar y pegar fuera del sitio, la CSS y el contenedor no viajan y el texto sí. Se agrega la restricción 4: cada resultado OCR se emite con un prefijo textual literal (`[texto sin revisar, no citable]`) **dentro** de la cadena del fragmento, del mismo modo que A3 §7.2 fija sus marcas de nivel entre corchetes, para que sobreviva al copiado. El enlace al PDF en el propio fragmento se conserva: sí viaja.

**(corregido en fase 3: H-7)** Se declara sin ambigüedad qué significa la restricción (3), porque A2 y A3 decidieron cosas distintas y la contradicción quedó abierta para la síntesis. La regla de A2 es: **el texto OCR sin revisar puede entrar a la recuperación y a la pantalla, marcado, pero no al contexto del modelo como evidencia ni a ninguna cita generada.** Consecuencia que A2 acepta por escrito: **C09 ("nombre social") no tiene hoy respuesta citable** y el motor debe decirlo con esas palabras, ofreciendo la página OCR como *ubicación* (dónde mirar en el PDF oficial) y nunca como *fundamento*. Es la única de las 10 consultas en esa situación: recontado en el turno de corrección, **1 de 10** consultas tiene todas sus anclas aceptadas en texto OCR sin revisar (C09; control positivo del detector: 19 anclas en total, 2 de ellas OCR; control negativo: `es_ocr_ancla("zzqq.html#x")` → `FALSE`). Si la capa 3 decide en cambio pasar el contenido OCR al modelo, esa decisión es de A3 y debe venir con el arnés que la controle (hoy no existe: H-13 del panel).

---

## 5. Conjunto de evaluación: 10 consultas en lenguaje del equipo

Criterio de construcción: preguntas como las hace un equipo de convivencia, no como las redacta la ley ("apelar" y no "reconsideración"; "celular" y no "dispositivos móviles electrónicos de comunicación personal"; "bullying" y no "acoso escolar"). Cada consulta tiene un ancla esperada (donde vive el texto que responde), anclas alternativas aceptadas, y una cita del JSON de la norma que justifica la elección. Tabla completa con citas: `a2_consultas_evaluacion.csv`.

| id | Consulta | Ancla esperada | Alternativas aceptadas | Origen | Cita (JSON de la norma) y por qué |
|---|---|---|---|---|---|
| C01 | pueden revisar la mochila de un alumno | `dictamen_065_revision_mochilas.html#fuentes` | `#materia` de la misma | firmado, **sustituido** | "...la intromisión no autorizada en pertenencias particulares representa, en sí mismo, una medida vulneratoria de derechos..." Única doctrina firmada; el cuerpo quedó bajo el rótulo FUENTES (H3). El vigente (078) es OCR. |
| C02 | se puede usar el celular en la sala de clases | `ley_21801_celulares.html#art-10-bis` | `rex_181_celulares.html#documento` | firmado | "Prohíbese el uso de dispositivos móviles electrónicos de comunicación personal ... en los establecimientos educacionales que imparten niveles de educación parvularia, básica o media. Excepcionalmente..." "celular" no aparece en ninguna unidad firmada (medido: 0). |
| C03 | es obligatorio tener un encargado de convivencia en el colegio | `ley_20536_violencia_escolar.html#art-unico` | `ley_21809_convivencia_educativa.html#art-15`, `#art-4-3` | firmado | "Todos los establecimientos educacionales deberán contar con un encargado de convivencia escolar..." La ley 21.809 (2026) lo renombra coordinador y homologa a los encargados (H4). |
| C04 | qué es el bullying | `ley_21809_convivencia_educativa.html#art-16-b` | `ley_20536_violencia_escolar.html#art-16-b` | firmado | "Se entenderá por acoso escolar toda acción u omisión constitutiva de agresión u hostigamiento reiterado..." (redacción 2026). "bullying" solo aparece en `ley_21430` (art-36, art-41) y en una página OCR. |
| C05 | una alumna embarazada puede seguir yendo al colegio | `ley_20370_general_educacion.html#art-11` | ninguna firmada | firmado | "El embarazo y la maternidad en ningún caso constituirán impedimento para ingresar y permanecer en los establecimientos de educación de cualquier nivel..." La circular 193 lo desarrolla, pero es OCR. |
| C06 | cuántos días tiene el apoderado para apelar una expulsión | `ley_20845_inclusion_escolar.html#art-3` | `dictamen_52_77_expulsion.html#num-3` | firmado | "...quienes podrán pedir la reconsideración de la medida dentro de quince días de su notificación, ante la misma autoridad, quien resolverá previa consulta al Consejo de Profesores." El dictamen explica los 5 días del procedimiento Aula Segura. |
| C07 | quiénes tienen que estar en el consejo escolar | `dto_24_consejos_escolares.html#art-3` | ninguna | firmado | "El Consejo Escolar es un órgano integrado, a lo menos, por: a) El Director del establecimiento, quien lo presidirá; b) El representante legal de la entidad sostenedora..." |
| C08 | el colegio puede obligar a los alumnos a usar uniforme | `dto_215_uniforme_escolar.html#art-1` | `#art-3` | firmado | "...podrán, con acuerdo del respectivo Centro de Padres y Apoderados, Consejo de Profesores, y previa consulta al Centro de Alumnos(as) y al Comité de Seguridad Escolar, establecer el uso obligatorio del uniforme escolar." |
| C09 | un alumno trans pide que lo llamen por su nombre social | `circular_812_identidad_genero.html#ocr-pagina-008` | `#ocr-pagina-009` | **OCR sin revisar** | "c) USO DEL NOMBRE SOCIAL EN TODOS LOS ESPACIOS EDUCATIVOS: Las niñas, niños y estudiantes trans mantienen su nombre legal en tanto no se produzca el cambio de la partida de nacimiento..." Ninguna unidad firmada contiene "nombre social" (medido: 0). Caso de prueba de §4quater. |
| C10 | se puede suspender al alumno mientras dura el proceso de expulsión | `dictamen_52_77_expulsion.html#num-3` | `ley_21809_convivencia_educativa.html#art-16-e` | firmado | "...la facultad de los Directores de establecimientos educacionales de aplicar la medida cautelar de suspensión de clases a 'miembros de la comunidad escolar que hubieren incurrido en alguna de las faltas graves o gravísimas...'" El art. 16 E de la ley 21.809 acota la suspensión de resguardo a quince días hábiles. |

**Verificación de anclas (medida, nota operativa (a) del orquestador):** el conjunto tiene **19 pares (consulta, ancla)** que cubren **18 anclas distintas** (10 esperadas + 8 alternativas propias; `dictamen_52_77_expulsion.html#num-3` cuenta dos veces, porque es alternativa de C06 y ancla esperada de C10). Las 18 se buscaron como `id="<ancla>"` en su archivo de `40_salidas/sitio/` con `readLines()` + `stringr::str_count(fixed(...))`: **las 18 existen, 0 no existen**, con exactamente una coincidencia en cada una de las 19 filas (tabla `a2_verificacion_anclas.csv`, que tiene 19 filas porque indexa pares, que es lo correcto). Control negativo del verificador: `id="art-9999"` en `ley_21801_celulares.html` da 0. **Verificación de citas (nota (b)):** el `patron_cita` de cada fila se encontró en el texto de la unidad esperada del JSON: **10 de 10**.

**(corregido en fase 3: ANC-A2-01)** La primera versión decía "las 19 anclas aceptadas (10 esperadas + 9 alternativas) … 19 existen". Recontado en el turno de corrección sobre `a2_consultas_evaluacion.csv`: pares (consulta, ancla) **19**, anclas **distintas 18**, esperadas distintas 10, alternativas que no son ninguna esperada **8**; la repetida es `dictamen_52_77_expulsion.html#num-3`. Sobre `a2_verificacion_anclas.csv`: 19 filas, 18 anclas distintas, 19 filas con exactamente una coincidencia en el HTML, 18 anclas distintas que existen y 0 que no. El hecho sustantivo no cambia (ninguna ancla del conjunto está rota); lo que estaba mal era llamar "anclas" a lo que son pares. **El artefacto no se toca:** 19 filas es lo correcto para pares consulta-ancla.

**Cobertura léxica de la consulta en su unidad objetivo** (medida, columna `terminos_en_objetivo`; términos de contenido de la consulta, plegados a ASCII, presentes como subcadena en el texto plegado de la unidad): C01 1 de 3 (`mochila`), C02 2 de 3 (`sala`, `clases`, pero no `celular`), C03 2 de 5, **C04 0 de 1** (`bullying`), C05 1 de 3, C06 3 de 5 (no `apelar`), C07 2 de 3, C08 2 de 4 (no `colegio`, no `obligar`), C09 4 de 4, C10 4 de 4. Es una aproximación declarada, no un dato de uso: no hay registro de consultas reales.

Este conjunto es de A2 y no del equipo: diez consultas plausibles escritas por quien leyó el corpus. Se declara como línea de partida a reemplazar por consultas reales en cuanto exista un registro.

### 5.1 C11: la consulta cuya respuesta correcta es "esa norma no está en el corpus" **(agregada en fase 3: H-5)**

Las diez consultas de arriba comparten un supuesto que el panel adversarial señaló y que ninguna de ellas pone a prueba: **todas tienen respuesta dentro del corpus.** Un motor que nunca enfrenta el caso contrario no puede distinguir "no encontré" de "no existe aquí", y esa es la clase de error que en un sitio institucional se lee como afirmación normativa. Se agrega el caso, medido en el turno de corrección:

| id | Consulta | Respuesta correcta | Ancla que el motor debe ofrecer | Qué se exige |
|---|---|---|---|---|
| C11 | qué dice la ley aula segura | **La ley 21.128 no está en el corpus.** Lo que sí está es el pronunciamiento que la interpreta. | `dictamen_52_77_expulsion.html#num-1` a `#num-5` (los numerales que la citan) | El motor devuelve la fuente que **cita** la norma y declara con esas palabras que **el texto de la norma citada no está en la biblioteca**, con enlace al PDF oficial fuera del sitio. Fallar en silencio, o presentar el dictamen como si fuera la ley, es el defecto que este caso caza. |

Medición del turno de corrección (`a2_correcciones_fase3_salida.txt`, bloque H-5): de las **25** normas del corpus, **0** tienen `numero` 21.128 o 21128 (control positivo del mismo comando: `numero` 21.801 → 1). **7** segmentos mencionan "aula segura" y **8** mencionan el número 21.128, y **todos** están en `dictamen_52_77_expulsion` (control positivo del mismo detector: "inclusión escolar" aparece en 7 segmentos; control negativo: "zzqqxw" en 0). Contra el índice Pagefind existente, en modo lectura, la consulta `aula segura` devuelve **8 páginas** y `ley 21.128` devuelve **1** (`dictamen_52_77_expulsion`, 113 palabras coincidentes).

**Por qué esto importa para el diseño y no es una consulta más:** como la consulta *sí* recupera fragmentos, una regla del tipo "si no hay fragmentos, decir que no está" **no se dispara nunca** en este caso. La declaración de ausencia no puede colgar del recuento de resultados: tiene que colgar de un dato, y el dato disponible es que ninguna norma del catálogo tiene ese `numero`. La regla que esto exige es determinística y barata: **si la consulta se clasifica como "identificador de norma" (§4.3) y el identificador resuelto no existe en `catalogo.json`, el motor lo declara antes de mostrar resultados**, y los resultados que muestre son los que *citan* esa norma, rotulados como tales. C11 no entra en la línea base de §6, que está medida sobre las diez originales.

---

## 6. Línea base: las 10 consultas contra el Pagefind existente (medido, modo lectura)

### 6.1 Instrumento

- Índice consultado: `40_salidas/sitio/pagefind/` tal como está (Pagefind 1.5.2, `pagefind-entry.json`: 25 páginas indexadas, idioma `es`). **No se reindexó nada**: `40_salidas/` tiene 277 archivos y mtime máximo `2026-08-27 12:38:58` antes y después de la medición (verificado por el propio script, sección CIERRE), y `git status --porcelain -- 40_salidas 20_insumos 30_procesamiento` devuelve **0 líneas**; **control positivo del mismo comando** (para distinguir "sin cambios" de "el comando no ve nada"): `git status --porcelain -- 50_documentacion` devuelve **7 líneas** en la corrida de corrección que dejó `a2_correcciones_fase3_salida.txt`, entre ellas este mismo documento. Ese número no es estable (crece a medida que otros agentes escriben en `50_documentacion/`); lo que el control demuestra, y es lo único que se le pide, es que **el comando sí devuelve líneas cuando hay cambios**, de modo que el vacío de la primera línea es una invariante cumplida y no un pathspec mal escrito. **(corregido en fase 3: CER-GEN-01.)**
- Acceso: la API JavaScript es la única interfaz. `pagefind.js` carga con `fetch()`, así que el sitio se sirvió con `servr::httd()` en `127.0.0.1:8767` desde un proceso aparte lanzado por el script, y se mató por PID al terminar. **El instrumento que verificaba el apagado estaba roto y su cero no valía nada; ver el recuadro siguiente.**

**(corregido en fase 3: CER-A2-01) El cero del servidor era un cero de instrumento roto.** La primera versión escribía "0 procesos `servr` en ese puerto tras `tools::pskill()`; `pgrep -f 'servr::httd' | wc -l` = 0 al cierre". Dos defectos: (a) **el comando citado no era el que corría** (el script ejecutaba `pgrep -f "port = 8767"`) y (b) **no había control positivo**, es decir nadie mostró que ese `pgrep` devolviera ≥ 1 mientras el proceso vivía. Al calibrarlo en el turno de corrección resultó que el patrón de la fase 1 **no puede coincidir nunca**: R sustituye los espacios de la expresión de `-e` por `~+~` en la línea de comandos del proceso, que queda

```
/Library/…/exec/R --no-echo --no-restore -e servr::httd("…/40_salidas/sitio",~+~port~+~=~+~8791,~+~daemon~+~=~+~FALSE,…)
```

de modo que cualquier patrón con espacios devuelve 0 con el servidor **vivo**. Los tres patrones, medidos sobre el mismo proceso, con el servidor arriba y después de matarlo:

| patrón | con el servidor vivo (PID 37851) | tras `pskill` |
|---|---|---|
| `pgrep -f servr::httd` | **1** | **0** |
| `pgrep -f 8791` (el puerto) | **1** | **0** |
| `pgrep -f "port = 8791"` (el de la fase 1) | **0** ← falso cero | 0 |
| `ps -p 37851` | vive: `TRUE` | vive: `FALSE` |
| el puerto responde | sí | no |

El cero del cierre de la fase 1 era, por casualidad, **cierto** (no quedó ningún servidor: se comprueba hoy con el patrón bueno), pero no estaba **medido**: un patrón que devuelve 0 en las dos condiciones no distingue nada. `20260904_medicion_corpus_semantica.R` quedó corregido: el patrón pasa a `servr::httd` (sin espacios), el recuento **anterior** al `pskill` se imprime como control positivo (líneas 512-518) y la línea de cierre publica el par completo más `ps -p <pid>` y el estado del puerto (líneas 553-563), con una advertencia explícita si el control positivo diera 0, porque entonces el cero de abajo no probaría nada. Verificado ejecutando ese mismo bloque, extraído literalmente del archivo, sobre un puerto aparte: `pgrep -f 'servr::httd' antes de pskill: 1 | despues: 0 | ps -p 38519 (el proceso concreto vive): FALSE | el puerto 8795 responde: FALSE`.
- Arnés: `lab_motor_v9/a2_consulta_pagefind.mjs` (55 líneas): recibe un JSON de consultas, llama `pagefind.search(consulta, {filters})`, y por cada página devuelta guarda `score`, y por cada `sub_result` el `anchor.id`, su orden en el documento y la suma de `balanced_score` de sus coincidencias. Entrada: `a2_consultas_pagefind_entrada.json`; salida cruda: `a2_resultados_pagefind.json`. Toda la evaluación (cruce con anclas, rangos, tablas) está en R.
- **Control positivo (C0):** `"mochila"` devuelve 3 páginas; la primera es `dictamen_065_revision_mochilas.html` con 2 sub-resultados y el primero es `#materia` ("MATERIA"). Reproduce literalmente la receta del orquestador. **PASA.**
- **Control negativo (CNEG):** `"xyzzy"` **no devuelve cero**: devuelve 4 páginas (`dfl_1#art-18-x`, `#art-19-x`, `ley_20845#art-3`, `rex_482_b#ocr-pagina-038`, `dto_453#art-42-a`). Hipótesis: coincidencia por prefijo o similitud sobre la última palabra de la consulta, que Pagefind aplica para búsqueda mientras se escribe; verificar con `pagefind.search("xyzzy", {})` variando `ranking.termSimilarity`. Consecuencia metodológica: **"no aparece" se mide por ancla, nunca por recuento de resultados**, y cualquier control negativo de otra capa que use Pagefind debe contar anclas, no resultados.

### 6.2 Métrica: qué cuenta como "el artículo correcto entre los tres primeros"

Pagefind devuelve **páginas** (una por norma) y, dentro de cada una, **sub-resultados** (uno por `<h2 id>` con coincidencias). La interfaz actual (`busqueda.html`: `showSubResults: true`, `pageSize: 8`) muestra las páginas por `score` y, bajo cada una, sus sub-resultados. Verificado en el código de `pagefind.js` (`calculate_sub_results`): los sub-resultados se construyen recorriendo las coincidencias **en orden de posición en el documento**, no por puntaje; y en `pagefind-ui.js` se muestran **como máximo 3 por página**, descartando el primero si apunta a la página sin ancla. Por eso se reportan tres lecturas:

- **A (página):** rango de la primera página cuyo nombre coincide con el de un ancla aceptada. Es "la norma correcta".
- **B (interfaz):** lista aplanada tal como la ve el usuario: páginas por `score`, dentro de cada una sus sub-resultados en orden de documento, máximo 3, sin el sub-resultado sin ancla. Rango de la primera entrada que coincide con un ancla aceptada. Es "lo que se ve".
- **C (sub-resultado por puntaje):** todos los sub-resultados con ancla de todas las páginas, ordenados por `suma_balanced` (desempate por `score` de página). Es "el artículo correcto" con la información que el índice ya tiene, y es la lectura comparable con un motor a nivel de fragmento.

"Aceptada" = cualquiera de las anclas de la columna "alternativas" de §5; la tabla `a2_linea_base_pagefind.csv` trae además el rango de la ancla primaria sola (`rango_primaria`). K declarado: **todos los resultados que Pagefind devuelve, sin corte**, lo que da en promedio 2,6 páginas y 152,7 sub-resultados por consulta en la variante base.

**(corregido en fase 3: UNI-A2-03)** La primera versión afirmaba entre paréntesis "Pagefind devuelve todas las páginas con coincidencia" **sin comando propio**, y no es una frase decorativa: de ella depende que los guiones de la línea base ("no aparece en ningún resultado") signifiquen ausencia y no truncamiento. Medido en el turno de corrección contra el índice existente, en modo lectura, con consultas de cobertura máxima:

| consulta | páginas devueltas | sub-resultados con ancla |
|---|---|---|
| `educacion` | **25** | 640 |
| `de` | **25** | 804 |
| `escolar` | 23 | 237 |
| `articulo` | 22 | 746 |

El índice tiene **25 páginas** (`pagefind-entry.json`, `page_count`), y dos consultas distintas devuelven **las 25**: no hay corte por debajo del corpus completo, que es exactamente lo que la lectura de la línea base necesita. Control del extremo opuesto, en el mismo bloque: `mochila` devuelve 3.

### 6.3 Variantes medidas

| Variante | Texto enviado | Filtros | Qué mide |
|---|---|---|---|
| `sin_filtro` | la consulta tal cual | ninguno | **La línea base que pide el encargo.** |
| `texto_verificado` | ídem | `texto: verificado` | Efecto de excluir el OCR (§4quater). |
| `vigente_verificado` | ídem | `texto: verificado`, `vigencia: vigente` | Efecto de sumar el filtro temporal (§4ter). |
| `terminos_clave` | solo palabras de contenido | ninguno | Efecto de quitar palabras funcionales. |
| `canonico` | el término con que la **norma** nombra el asunto (mapeo manual de A2; no se leyó el vocabulario de A1) | ninguno | **Cota superior** de una expansión de vocabulario perfecta. |
| `canonico_verificado` | ídem | `texto: verificado` | Cota superior sin OCR. |

### 6.4 Resultados por consulta (tabla `a2_linea_base_pagefind.csv`)

Rango de la ancla aceptada; `–` = no aparece en ningún resultado. `pág.` = páginas devueltas.

| id | Consulta | `sin_filtro` pág. | A | B | C | Primer resultado (A) | `canonico` pág. | A | B | C | Primer sub-resultado (C) |
|---|---|---|---|---|---|---|---|---|---|---|---|
| C01 | mochila | 1 | – | – | – | `dictamen_078` (OCR) | 2 | 1 | 2 | 1 | `dictamen_065#fuentes` |
| C02 | celular en clases | **0** | – | – | – | (nada) | 2 | 1 | 3 | 1 | `ley_21801#art-10-bis` |
| C03 | encargado de convivencia | 4 | – | – | – | `ley_20370` | 10 | 2 | 6 | 18 | `dto_453#art-147-bis` |
| C04 | bullying | 1 | – | – | – | `ley_21430` | 7 | 1 | – | 3 | `rex_482_b#ocr-pagina-029` |
| C05 | alumna embarazada | 3 | 3 | – | 4 | `rex_482_b` (OCR) | 7 | 7 | 13 | 28 | `circular_193#ocr-pagina-014` |
| C06 | días para apelar expulsión | 3 | 1 | – | 2 | `ley_20845` | 5 | 2 | 10 | 4 | `dictamen_52_77#num-1` |
| C07 | quiénes en el consejo escolar | 9 | – | – | – | `ley_21809` | 16 | 3 | – | 65 | `ley_19979#art-1` |
| C08 | obligar a usar uniforme | **0** | – | – | – | (nada) | 5 | 1 | 2 | 4 | `rex_482_b#ocr-pagina-020` |
| C09 | nombre social | **0** | – | – | – | (nada) | 12 | 1 | – | 2 | `ley_21430#art-66` |
| C10 | suspender durante expulsión | 5 | 1 | – | 8 | `ley_21809` | 3 | 1 | 7 | 1 | `dictamen_52_77#num-3` |

Las variantes con filtro (`texto_verificado`, `vigente_verificado`) reproducen los rangos de `sin_filtro` salvo C05 en la lectura A (pasa de 3 a 2 al caer `rex_482_b`); `terminos_clave` rescata **C09 en A (rango 1) y en C (rango 17), y C06 en B (rango 3)**. `canonico_verificado` **difiere de `canonico` en 12 de las 30 celdas** (10 consultas × 3 lecturas), no en 5; la tabla completa está en `a2_linea_base_pagefind.csv` y son estas:

| consulta | A (página) | B (interfaz) | C (sub-resultado) |
|---|---|---|---|
| C03 | 2 → 1 | 6 → 3 | – |
| C04 | – | – | 3 → 2 |
| C05 | 7 → 5 | 13 → 7 | 28 → 7 |
| C06 | – | 10 → 7 | – |
| C07 | – | – | 65 → 54 |
| C08 | – | – | 4 → 2 |
| **C09** | **1 → no aparece** | – | **2 → no aparece** |
| C10 | – | 7 → 4 | – |

**(corregido en fase 3: CIF-A2-08 y CIF-A2-09)** Dos enunciados universales del mismo párrafo que ningún comando exhaustivo sostenía. Re-derivados celda por celda en el turno de corrección, comparando las 30 celdas de cada par de variantes: (a) `terminos_clave` aparece donde `sin_filtro` **no** aparece en **3** celdas (C09 A = 1, C06 B = 3, **C09 C = 17**), y el "nada más" de la primera versión contradecía al resumen de §6.5 del propio documento, donde `terminos_clave` en la lectura C ya mostraba K máximo 17; (b) `canonico` y `canonico_verificado` difieren en **12** celdas, no en las 5 que la enumeración listaba: faltaban C03 (A y B), C05 (B), C06 (B) y C10 (B). Control positivo del comparador en ambos casos: 30 celdas comparadas, 18 iguales en el segundo par, 6 celdas del primer par donde ambas variantes aparecen. La conclusión que el párrafo sostiene (el filtro de texto verificado mejora los rangos y borra C09) no cambia: se refuerza, porque las mejoras son más de las que se habían contado.

### 6.5 Resumen (tabla `a2_linea_base_resumen.csv`)

| Variante | Lectura | top 1 | **top 3** | top 10 | no aparece | K máx. para cubrir las halladas | candidatos promedio | ms promedio |
|---|---|---|---|---|---|---|---|---|
| **sin_filtro** | A página | 2 | **3** | 3 | 7 | 3 | 2,6 | 9,94 |
| | B interfaz | 0 | **0** | 0 | 10 | – | 152,7 | |
| | C sub-resultado | 0 | **1** | 3 | 7 | 8 | 152,7 | |
| texto_verificado | A / B / C | 2 / 0 / 0 | 3 / 0 / 1 | 3 / 0 / 3 | 7 / 10 / 7 | 2 / – / 8 | 2,0 / 127,9 | 3,86 |
| vigente_verificado | A / B / C | 2 / 0 / 0 | 3 / 0 / 1 | 3 / 0 / 3 | 7 / 10 / 7 | 2 / – / 8 | 2,0 / 127,9 | 3,80 |
| terminos_clave | A / B / C | 3 / 0 / 0 | 4 / 1 / 2 | 4 / 1 / 3 | 6 / 9 / 6 | 3 / 3 / 17 | 4,1 / 93,5 | 0,65 |
| **canonico** (cota) | A página | 6 | **9** | 10 | 0 | 7 | 6,9 | 1,63 |
| | B interfaz | 0 | **3** | 6 | 3 | 13 | 120,4 | |
| | C sub-resultado | 3 | **5** | 7 | 0 | 65 | 120,4 | |
| canonico_verificado | A / B / C | 6 / 0 / 3 | 8 / 4 / 5 | 9 / 7 / 7 | 1 / 3 / 1 | 5 / 7 / 54 | 5,0 / 93,4 | 1,28 |

Latencia: milisegundos por `pagefind.search()` más la carga de datos de cada resultado, medidos en Node 26 sobre HTTP local, no en un navegador ni en red; la variante `sin_filtro` corrió primero y paga la carga de fragmentos (27,48 ms en C01, 0,70 ms en C09).

### 6.6 Lectura de la línea base

1. **Respuesta al encargo:** con las consultas tal como las escribe el equipo, el Pagefind actual pone la **norma** correcta en el top 3 en **3 de 10** (C05, C06, C10), el **artículo** correcto en el top 3 por puntaje en **1 de 10** (C06), y en la interfaz **0 de 10**. Tres consultas devuelven cero páginas (C02, C08, C09): Pagefind **intersecta** los términos (una página tiene que satisfacerlos todos), de modo que basta un término cuya coincidencia caiga en otras páginas para vaciar el resultado. Otras cuatro devuelven páginas pero no la correcta.

   **(corregido en fase 3: UNI-A2-01)** La primera versión explicaba los tres ceros con "Pagefind exige todas las palabras y 'celular', 'colegio'/'obligar' y 'nombre social' … no coinciden": un universal sobre el comportamiento de una herramienta de terceros, sin comando, sin cita y en tensión con el control negativo del propio §6.1, donde `xyzzy` devuelve 4 páginas. La documentación de Pagefind no es cita disponible (su dominio no está en la lista de red autorizada del encargo), así que se zanjó con un experimento propio sobre el índice existente, en modo lectura:

   | consulta | páginas | qué muestra |
   |---|---|---|
   | `mochila` | 3 (065, 078, dto_215) | control positivo |
   | `mochila zzqqxw` | **2** (065, 078) | agregar un término inexistente **no vacía** el resultado: lo intersecta. `dto_215` cae |
   | `zzqqxw mochila` | **2** (065, 078) | el orden de los términos no cambia nada |
   | `mochila uniforme` | **2** (dto_215, 078) | dos términos que sí existen: cae `dictamen_065`, que solo tiene el primero |
   | `xyzzy` | 4 | un término inexistente, solo, coincide por prefijo o similitud |

   Lo que la medición sostiene, y es lo que se escribe arriba: **la conjunción existe** (en los tres pares medidos, agregar un término solo redujo el conjunto de páginas: 3 → 2), pero **"coincidir" no es "aparecer literalmente"** (con `zzqqxw` en la consulta, las palabras coincidentes de `dictamen_065` subieron de 9 a 10). Por eso un término ausente del corpus no garantiza cero, y por eso el cero de las tres consultas es una **intersección vacía**, no una palabra faltante. La consecuencia metodológica del §6.1 se mantiene intacta y se refuerza: "no aparece" se mide por ancla, nunca por recuento de resultados.
2. **El techo léxico está en la página, no en el artículo.** Con el término canónico, 9 de 10 normas quedan en el top 3, pero solo 5 de 10 artículos: Pagefind puntúa por suma de coincidencias y premia unidades largas que repiten el término (C07: `ley_19979#art-1` con 14 633 puntos frente a `dto_24#art-3` con 2 048,6). Eso es lo que la vía semántica y el reranking tienen que aportar; una expansión de vocabulario sola no lo resuelve.
3. **La interfaz actual esconde el artículo correcto por construcción.** B da 0 de 10 sin filtro y 3 de 10 con el término canónico, porque muestra 3 sub-resultados por página en orden de documento, y el primero es casi siempre `#preambulo` (verificado en C06: `ley_20845` en rango 1 con 38 sub-resultados, `#preambulo`, `#art-1`, `#art-12` visibles y `#art-3` invisible). Esto se corrige sin tocar el índice, ordenando `sub_results` por puntaje en el `process_result` de `busqueda.html` (archivo de `30_procesamiento/`, fuera de mi autorización: hallazgo H2, §8).
4. **Los filtros de faceta funcionan como se especifica en §4ter y §4quater** y cuestan cero: `texto: verificado` y `vigencia: vigente` se aplican en el índice actual sin reindexar.
5. **La cota de 9 de 10 no son nueve respuestas utilizables (agregado en fase 3: H-16).** Hasta aquí la línea base contaba igual un acierto que apunta a una unidad firmada y uno que apunta a una página OCR sin revisar, que este mismo documento declara **no citable** (§4quater.2). Desdoblada, con la variante `canonico`:

   | lectura | aciertos en el top 3 | **con unidad citable** | **solo con texto sin revisar** |
   |---|---|---|---|
   | A (página) | 9 de 10 | **8 de 10** | 1 (C09) |
   | C (sub-resultado por puntaje) | 5 de 10 | **4 de 10** | 1 (C09) |

   Tres datos más del mismo recuento: **1 de 10** consultas tiene todas sus anclas aceptadas en texto OCR (C09), de modo que **9 de 10** son resolubles citablemente en el mejor de los casos; **3 de 10** traen una página OCR sin revisar como **primer sub-resultado por puntaje** en la variante `canonico` (C04 `rex_482_b#ocr-pagina-029`, C05 `circular_193#ocr-pagina-014`, C08 `rex_482_b#ocr-pagina-020`; control positivo del detector: los otros 7 son firmados); y la reimplementación que produjo la columna citable coincide con la publicada en **10 de 10** celdas en la lectura A y en **9 de 10** en la C, difiriendo solo donde el ancla es OCR, que es donde debe diferir. Toda cifra de cobertura de este documento que se lleve a la síntesis debe viajar con las dos columnas: quien lea "9 de 10" sin el desdoble supondrá nueve respuestas que se pueden citar, y son ocho.

---

## 7. Qué decidí, qué dejé fuera

**Decidido:** unidad = segmento con ventana solo sobre el 28 % que excede 512 tokens; índice int8 × 384 estático en el navegador, vía léxica Pagefind con expansión y reordenamiento de sub-resultados, fusión RRF `k = 60`, K = 30 por vía, tres niveles de reranking con R0 determinístico como piso, OCR devuelto marcado en bloque aparte y no citable, filtro temporal por año con marca en vez de ocultamiento.

**Dejado fuera, con razón:** (1) vectorizar el corpus o cualquier consulta: prohibido gastar cuota, así que la vía semántica queda especificada y no medida; (2) medir el peso de un modelo de embeddings en el navegador: sin red; (3) precios: los cita A4 con URL; (4) Vectorize: descartado a esta escala por §4.5; (5) reranker propio: fuera por §0bis; (6) leer el vocabulario de A1 para la variante `canonico`: el encargo prohíbe leer archivos ajenos, así que la cota es un mapeo manual declarado.

**Cambiado en fase 3, tras la auditoría y el panel adversarial:** la recomendación de §4.5 **no cambia de opción**, pero deja de ser incondicional: la opción 3 se construye primero y su techo de 9 de 10 solo se realiza con la tabla de alias curados de A1 (H-12); la cobertura se reporta desdoblada por citabilidad, porque 9 de 10 páginas son 8 con unidad citable (H-16); el OCR sin revisar lleva su marca **dentro del texto** además del bloque aparte (H-1) y no entra al contexto del modelo como evidencia, con la consecuencia aceptada por escrito de que C09 se queda sin respuesta citable (H-7); el conjunto de evaluación gana C11, el caso "esa norma no está en el corpus" (H-5); y el plan de degradación distingue capa 2 léxica de capa 2 semántica (H-17). Cada corrección vive **al lado de la afirmación que corrige**, con su recuento y su control, marcada con `(corregido en fase 3: <id>)`: hay **20 marcas** en el cuerpo, recontadas en la ronda de cierre con un patrón que no se cuenta a sí mismo, porque las menciones de la plantilla escriben el identificador en minúscula y entre ángulos: `grep -c 'corregido en fase 3: [A-Z]'` sobre este archivo → **20**, en 20 líneas distintas, mientras que el patrón llano da **22** líneas (las 20 más el encabezado y esta oración) y **23** ocurrencias (esta oración aporta dos: la plantilla y el comando que publica la cifra). **(corregido en la ronda de cierre: N-4)** La primera versión de esta oración publicaba 21 con el patrón llano, cifra que ya no reproducía al escribirse: la oración se cuenta a sí misma. En la misma ronda se repararon otros dos defectos que la corrección de fase 3 introdujo, cada uno marcado `(corregido en la ronda de cierre: <id>)` al lado de la afirmación que corrige: la atribución causal de §0 (V-2) y la afirmación de uso que sobrevivía en §8 (N-5); son **3** marcas de cierre (`grep -c 'corregido en la ronda de cierre: [A-Z]'` → 3, por la misma razón que el patrón anterior). Ninguna conclusión de este documento cambió de signo: las cifras corregidas apuntan todas en la dirección que el argumento ya sostenía, salvo dos que lo debilitan y así se dicen (la cota `canonico` no es alcanzable hoy, y el índice int8 supera a la página más pesada en vez de quedar por debajo).

---

## 8. Hallazgos para el orquestador (se reportan, no se corrigen)

| # | Hallazgo | Evidencia | A quién le importa |
|---|---|---|---|
| H1 | Pagefind no devuelve cero para un término inexistente (`xyzzy` → 4 páginas). Cualquier control negativo basado en "0 resultados" **de Pagefind** es inválido; debe contar anclas. | §6.1 | **quien mande un término al buscador de texto completo**: las 5 entradas del glosario de A1 con `accion: buscar_texto` (`cancelación de matrícula`, `medida formativa`, `debido proceso escolar`, `protocolo de actuación`, `dupla psicosocial`); AUD |
| H2 | La interfaz de búsqueda del sitio muestra como máximo 3 sub-resultados por norma en orden de documento; el artículo correcto queda oculto en normas largas (0 de 10 sin filtro, 3 de 10 con término canónico). Corrección barata en `busqueda.html` (`process_result` ordenando `sub_results` por `weighted_locations`), fuera de mi autorización. | §6.4, §6.6 | orquestador, encargo de corrección |
| H3 | El segmentador de dictámenes deja el cuerpo completo del dictamen 065 (20 769 caracteres) bajo el rótulo `FUENTES` (`#fuentes`); los dictámenes 52-77 y 71 sí tienen numerales. La ancla "correcta" para "mochila" apunta a un encabezado que dice FUENTES. | §1.3, §5 | `32_segmentar_articulos.R`, vía A |
| H4 | No existe vigencia por artículo ni relación "modifica artículo": la ley 21.809 reescribe el art. 16 B y el art. 15 de la LGE y el corpus conserva ambas redacciones como vigentes sin vínculo. El vocabulario "encargado de convivencia" (2011) contra "coordinador de convivencia educativa" (2026) es el caso visible. | §4ter.4 | A3 (ontología, tarea 8), A1 (alias), curaduría |
| H5 | `catalogo.json` reporta `n_articulos = 682`, pero las unidades buscables son 806; los 4 dictámenes y 3 REX aportan **0 artículos y 82 unidades**, y son la fuente de la respuesta esperada en 2 de las 10 consultas de evaluación (4 contando las anclas aceptadas). Toda cifra de "682 artículos" en los documentos del encargo debe leerse como "682 artículos de 806 unidades". | §1.1, §0 | A4 (tarea 8), SINT |
| H6 | El dictamen 078, vigente y sustituto del 065, es OCR sin revisar: la única doctrina **citable** sobre revisión de mochilas es la de la norma sustituida. Cualquier capa 3 que responda "mochila" con el 078 rompe el invariante 4. | §4quater.2, §5 C01 | A3, A5 |
| H7 | El conjunto de evaluación no tenía ninguna consulta cuya respuesta correcta fuera "esa norma no está en el corpus". Se agrega C11 (§5.1) con su medición: 0 de 25 normas es la ley 21.128, y los 8 segmentos que la citan están todos en `dictamen_52_77`. La regla que el caso exige no puede colgar del recuento de resultados, porque la consulta **sí** recupera fragmentos. | §5.1 (medido en fase 3) | A3 (regla 10 del prompt), A4 (clase "identificador de norma" en el Worker), SINT |

**(corregido en fase 3: CON-A2-09 = H-19)** H1 estaba dirigido a "A1 (su control negativo `xyzzy`)" y la atribución era falsa: el control negativo de A1 no corre contra Pagefind sino contra su propio resolutor sobre `vocabulario.json`, donde `xyzzy` sí devuelve 0. El hallazgo sobre Pagefind es correcto y sigue en pie; lo que se corrige es a quién le importa. Donde sí toca a la capa 1 es en las **5 entradas del glosario que declaran `accion: buscar_texto`** (de 892), porque esas mandan el término al buscador de texto completo, y ahí el cero de Pagefind no es cero. La cifra y los cinco términos son del panel adversarial y de la auditoría, no medidos por A2: A2 no leyó el vocabulario de A1 (§7, punto 6).

**(corregido en la ronda de cierre: N-5)** La fila H5 arrastraba la misma afirmación de uso que `CIF-A2-11` retiró de §0 (que esos documentos serían "las fuentes más consultadas"), y §8 es justamente el canal por el que un hallazgo viaja a A4 y a la síntesis: la corrección de §0 estaba incompleta mientras la afirmación siguiera viva aquí. Se retira con el mismo argumento (no hay artefacto en el repositorio del que se pueda derivar frecuencia de consulta) y se reemplaza por el recuento que §0 y §1.1 ya sostienen, re-derivado en el turno de cierre sobre `catalogo.json` y `a2_consultas_evaluacion.csv`: 7 documentos, **82 segmentos, 0 artículos**; anclas esperadas en un dictamen o una REX, **2 de 10** (C01, C10); con anclas aceptadas, **4 de 10** (C01, C02, C06, C10). Control positivo del mismo comando: `ley_20845` aporta 37 artículos; control negativo: slugs `^zzqq` → 0. Rastreo posterior sobre todo el archivo: la cadena retirada sobrevive en **1** línea, que es esta nota, y en **0** filas de la tabla de arriba.

---

## 9. Residuos declarados

| Qué | Estado | Razón |
|---|---|---|
| Tokens por unidad | **Estimado** (c4 y c35) | Sin tokenizador ni API. Verificación: tokenizar `a2_distribucion_articulos.csv` con el modelo elegido. |
| Peso del modelo de embeddings en el navegador | **No medido** | Sin red. Verificación: `fs::file_size()` del artefacto ONNX cuantizado. |
| Calidad de la vía vectorial y de int8 frente a float32 sobre las 10 consultas | **No medido** | Prohibido consumir cuota. Se mide con §5 cuando exista un build con vectores. |
| Precios de embeddings y reranking | **Diferido a A4** | Este documento entrega cantidades en tokens (§3, §4bis), no precios. |
| Latencia de Pagefind | **Medida en Node, no en navegador** | Es la única interfaz posible sin navegador; el orden de magnitud (1 a 30 ms) es lo que se necesita. |
| Compresibilidad de vectores | **Proxy sintético** | No hay vectores reales; sirve solo para no suponer que gzip comprime float32. |
| Conjunto de evaluación | **10 consultas de A2, no del equipo** | No hay registro de consultas reales. Se declara como línea de partida. |
| Variante `canonico` | **Mapeo manual de A2; cota superior NO alcanzable con la capa 1 de hoy** | Prohibido leer el vocabulario de A1, así que no es una medición de A1. El panel adversarial sí pasó estas 10 consultas por el resolutor real de A1 y midió 0 de 10 bajo el contrato AND que A1 recomienda (7 de 10 bajo OR, que A1 mide y no recomienda): la cota se realiza solo si existe la tabla de alias curados que A1 propone en su §2.4 (H-12). |
| Cobertura de la línea base | **Debe leerse desdoblada por citabilidad** | Un acierto sobre texto OCR sin revisar no es una respuesta citable (§4quater.2). Con `canonico`: 9 de 10 páginas, 8 si se exige unidad citable; 5 de 10 artículos, 4 si se exige (H-16). |
| Degradación sin el Worker | **Sobrevive la capa 2 léxica, no la semántica** | La consulta se vectoriza en el Worker mientras no se mida el peso de un modelo en el navegador; sin servicio no hay vector de consulta y el índice estático queda inutilizable (H-17). |
| C11 ("esa norma no está en el corpus") | **Agregada en fase 3, medida, fuera de la línea base de §6** | El caso se midió contra el índice existente (§5.1), pero la línea base de §6 está corrida sobre las 10 consultas originales y no se re-midió: C11 no entra en ninguna de sus cifras. |
| Extrapolación a 100 normas | **Calculada, lineal** | Sin corpus de 100 normas; declarada como hipótesis de escala. |
| Patrones de clasificación de consulta (§4.3) | **Orientativos** | El encargo prohíbe escribir a mano patrones dependientes de locale; se derivan y prueban en runtime cuando se implemente. |

---

## 10. Comandos y cifras

Todas las filas marcadas "script" salen de `Rscript 50_documentacion/andamios/20260904_medicion_corpus_semantica.R` corrido desde la raíz del repo el 2026-09-05 (salida completa en consola; tablas en `50_documentacion/andamios/lab_motor_v9/`). Las filas que citan `a2_correcciones_fase3_salida.txt` se re-derivaron el 2026-09-06 con `Rscript 50_documentacion/andamios/lab_motor_v9/a2_correcciones_fase3.R`, que lee los mismos artefactos y el índice Pagefind en modo lectura, escribe solo en `lab_motor_v9/` con prefijo `a2_`, y cierra verificando que `40_salidas/` no cambió (376 archivos y mtime máximo `2026-08-27 12:45:05` antes y después, contando ocultos).

| Cifra | Valor | Comando / tabla |
|---|---|---|
| Archivos JSON de normas | 25 | script, TAREA 1: `fs::dir_ls(ruta_normas(), glob = "*.json")` |
| Unidades / artículos / no artículo firmados / páginas OCR | 806 / 682 / 40 / 84 | script, TAREA 1: `count(unidades, origen_texto, es_articulo)` |
| Distribución de largo (min, mediana, p90, max) de artículos | 59 / 888,5 / 3 117,9 / 27 167 caracteres | `a2_resumen_distribucion.csv` |
| Artículos sobre 512 tokens (c4 / c35) | 149 / 175; unidades 227 / 261 | `a2_excesos_ventana.csv` |
| Párrafos, artículos con >1 párrafo, párrafos > 512 tok | 1 766 / 294 / 87 | script, TAREA 1 |
| Fragmentos con ventana 400/50 (firmados / todos) | 1 160 / 1 344 | `a2_fragmentacion.csv` |
| Peso índice int8 × 384: 722 unidades / 1 160 fragmentos | 311,5 KB / 500,5 KB | `a2_peso_indice.csv` |
| Peso float32 × 1 024: 1 344 fragmentos | 5 451,9 KB | `a2_peso_indice.csv` |
| Metadatos por unidad | 57,8 bytes | script, TAREA 3 |
| `pagefind/` completo / `index/` / `fragment/` / wasm | 1 521 719 / 457 993 / 416 553 / 72 349 bytes | `a2_referencias_peso_sitio.csv` (`fs::dir_info`) |
| HTML del sitio (47) / más pesado | 3 048 234 / 305 372 bytes | ídem |
| gzip proxy float32 / int8 | 0,926 / 0,599 | `a2_compresibilidad_proxy.csv` |
| Tokens c4 corpus firmado / todo / artículos | 301 659 / 357 759 / 269 243 | `sum(tok_c4)` sobre `a2_distribucion_articulos.csv` |
| Consultas de evaluación: caracteres medio / máx, tok_c4 máx | 49,2 / 66 / 17 | `nchar()` sobre `a2_consultas_evaluacion.csv` |
| Normas con año / sin año / `fuente_anio` | 21 / 4 / 4 | `a2_temporalidad.csv` |
| Estado ≠ vigente / `sustituido_por` / `sustituye_a` / campo fecha | 1 / 1 / 1 / 0 (control: 25 con `estado`) | `a2_temporalidad.csv` |
| Rige hoy / regía en 2021 / indeterminables | 24 / 12 / 4 | `a2_temporalidad.csv` |
| Relaciones por tipo | tema 502, remisión 46, sustitución 2, grupo_acto 2 (552) | `jsonlite::fromJSON("40_salidas/datos/relaciones.json")`, `table(tipo)` |
| Unidades OCR / documentos / firmadas / documentos | 84 / 5 / 722 / 20 | `a2_ocr_unidades.csv` |
| `ORIGENES_TEXTO` | 4 valores | `source("10_utils/10_configuracion.R")` |
| Anclas del conjunto: pares / anclas distintas / existen / control negativo | 19 pares / 18 distintas / 18 existen / 0 (`art-9999`) | `a2_verificacion_anclas.csv`, `a2_consultas_evaluacion.csv` |
| Citas halladas en el JSON | 10 de 10 | `a2_consultas_evaluacion.csv`, `patron_hallado` |
| Facetas del índice: texto, vigencia, año sin determinar | 20 verificado + 5 OCR; 24 vigente + 1 sustituida; 4 | `pagefind.filters()` vía `a2_consulta_pagefind.mjs` |
| Páginas indexadas por Pagefind | 25 | `40_salidas/sitio/pagefind/pagefind-entry.json` |
| Línea base `sin_filtro` top 3: A / B / C | 3 / 0 / 1 de 10 | `a2_linea_base_resumen.csv` |
| Cota `canonico` top 3: A / B / C | 9 / 3 / 5 de 10 | ídem |
| Cota `canonico` top 3 **con unidad citable**: A / C | **8 / 4 de 10** | `a2_correcciones_fase3_salida.txt`, bloque H-16 |
| Consultas cuya única respuesta aceptada es OCR sin revisar | **1 de 10** (C09) | ídem (control: 19 anclas, 2 OCR) |
| Primer sub-resultado por puntaje que es página OCR (`canonico`) | **3 de 10** (C04, C05, C08) | ídem (control: los otros 7 firmados) |
| K máximo para cubrir las halladas (`canonico`, C) | 65 (9 de 10 **hasta** K = 28; 8 con K = 27; **7 con K = 4**) | `a2_linea_base_resumen.csv`, `a2_linea_base_pagefind.csv` |
| Aporte de los 4 dictámenes y las 3 REX | **0 artículos, 82 unidades** (25 firmadas + 57 OCR) | `catalogo.json` (control: ley_20845 → 37 artículos) |
| Rango de `s_L` en una misma consulta (C06 sin filtro) / en el conjunto | **214,3 a 109 411,3** / 73,3 a 402 811,3 | `a2_resultados_pagefind.json`, aplanado |
| Fracción de `ley_20845#art-3` que cabe en 512 tokens | **7,54 %** (2 048 de 27 167 car.) | `a2_correcciones_fase3_salida.txt` |
| Índice int8 × 384 frente a la página más pesada | **1,04× y 1,68×** (318 974 y 512 478 contra 305 372 bytes) | ídem (control: 682 × 384 binario, 70,5 KB, sí es menor) |
| Umbral de fragmentos por norma que reabre Vectorize | **691,2** | `305 372 / (384 + 57,7916)` |
| Diferencias `canonico` vs `canonico_verificado` | **12 de 30 celdas** (18 iguales) | `a2_linea_base_pagefind.csv`, comparación celda a celda |
| Rescates de `terminos_clave` sobre `sin_filtro` | **3** (C09 A = 1, C06 B = 3, C09 C = 17) | ídem |
| Máximo de páginas por consulta (sin corte) | **25 de 25 indexadas** (`educacion`, `de`) | `a2_experimentos_fase3.csv` |
| Conjunción de Pagefind: `mochila` / `mochila zzqqxw` | 3 / **2** páginas (no 0) | ídem |
| Ley 21.128 (Aula Segura) en el corpus / segmentos que la citan | **0 de 25 normas** / 8 segmentos, todos en `dictamen_52_77` | `a2_correcciones_fase3_salida.txt`, bloque H-5 |
| Control C0 / CNEG | 3 páginas, `#materia` primero / 4 páginas | script, TAREA 6 |
| Latencia por consulta (Node) | 0,70 a 27,48 ms | `a2_linea_base_pagefind.csv`, `ms_busqueda` |
| `40_salidas/` antes y después | 277 archivos, mtime máx. 2026-08-27 12:38:58, sin cambios | script, CIERRE |
| Servidor local: control positivo / cero | **1 proceso con el servidor vivo / 0 tras `pskill`** (`pgrep -f servr::httd`; `ps -p <pid>` → `TRUE` / `FALSE`) | `a2_correcciones_fase3_salida.txt`, bloque CER-A2-01 |
| Invariante de no escritura / su control positivo | `git status --porcelain -- 40_salidas 20_insumos 30_procesamiento` → **0 líneas** / `-- 50_documentacion` → **7 líneas** (no vacío; el número varía con lo que otros agentes escriban) | ídem, bloque CER-GEN-01 |
