# Log — auditoría contra producto e insumos de validación (v3), sesión 2

Encargo: `50_documentacion/andamios/20260826_encargo_auditoria_y_cierre_v3.md`.
Fecha: 2026-08-26. Ejecutó: Claude Code, macOS, R 4.5.2, Quarto 1.9.38, Pagefind 1.5.2.
Sucede a `20260826_avance_maquina_v2_log.md` y cierra la fase de máquina de la sesión 2.

---

## 1. Resumen de la sesión

**Las seis tareas completas. Ninguna congelada.** La cadena corrió en el orden del grafo:
TA sola primero (auditoría con panel), luego TB, TD, TE, TF, y TC al final con la única
regeneración.

- **TA** auditó contra producto todo lo reportado en la sesión: 7 de 8 puntos confirmados.
  El que cae no es una afirmación de los logs sino **un enunciado de la propia auditoría**,
  que el panel adversarial derribó por dos caminos independientes. Se registran 5
  observaciones, ninguna corregida (condición 3).
- **TB** alineó `estado_curado()` en `00_ocr_documentos.R` con el arreglo de `48d176a`,
  verificado por arnés sin ejecutar el script (condición 7 respetada).
- **TD** listó las 5 piezas y 7 líneas que citan el REX 482 con el rótulo antiguo.
- **TE** produjo la tabla de los 34 temas frágiles, con enlace directo al fragmento exacto.
- **TF** generó el CSV del cruce prellenado con las 25 normas y completó el enlace de la
  pauta. La condición 5 no exigió corregir ningún conteo: los cinco coinciden.
- **TC** hizo viajar `fuente_anios_alternativos` al JSON y a la ficha, con los cinco
  chequeos pasando y el diff acotado a lo que la condición 6 permite.

**El hallazgo de la sesión no lo encontró la auditoría sino el panel**, y es el de mayor
consecuencia: la compuerta que impide publicar una pieza interpretativa sin firma es
derrotable por coincidencia parcial de nombres. No está viva; queda como O5 con su pregunta
cerrada.

## 2. Inventario de commits

| Hash | Tarea | Mensaje |
|---|---|---|
| `efd63af` | condición 1 | `docs(andamios): encargo v3, pauta de validacion y formato de cruce` |
| `7cc6fb6` | TA | `docs(andamios): auditoria contra producto de la sesion 2` |
| `851f021` | TB | `fix(ocr): acceso exacto a curaduria, mismo defecto de 48d176a` |
| `9987e11` | TD | `docs(andamios): borradores con rotulo antiguo del rex 482` |
| `fd44447` | TE | `docs(andamios): tabla de temas fragiles para validacion` |
| `056a37f` | TF | `docs(andamios): csv de cruce prellenado y pauta con enlace y cifras verificadas` |
| `2125d2a` | TC | `feat(sitio): procedencia de anios_alternativos visible en la ficha` |
| este | cierre | `docs(andamios): log de auditoria y cierre v3` |

## 3. Cambios sustantivos

### 3.1 FASE 0 — medición

Las diez mediciones, todas contra producto y ninguna heredada del encargo:

| # | Qué | Esperado | Medido |
|---|---|---|---|
| 1 | `git status --porcelain` | solo los 3 `??` autorizados | los 3, y ninguno más → commiteados |
| 1 | `HEAD` vs `origin/main` | — | `1147f56` en ambos antes del commit |
| 1 | `git log 358e150..HEAD` | — | 17 commits previos |
| 2 | `ESTADO.md` | `sesion_abierta: true`, `commit_cierre: 358e150` | los dos |
| 3 | relaciones / por tipo / descartes / `N96` | 552 / 46 remisión / 67 / 0 | 552 (2/2/46/502) / 67 / 0 |
| 4 | `$` en `00_ocr_documentos.R` sobre curaduría | — | 2 accesos, líneas 84-85 (`estado_curado()`) |
| 5 | `fuente_anios_alternativos` en `40_salidas/` | 0 | **0** |
| 6 | marcador de fragilidad de temas | 34 | **34** (tabla ⚠ de la indagación §2) |
| 7 | borradores | 22 | **22** |
| 8 | páginas OCR: 193 / 586 / 812 / rex_482 / dictamen 078 | 16 / 1 / 10 / 48 / 9 | **idénticos**, condición 5 no exigió corrección |
| 9 | URL pública | — | `https://tomgc.github.io/slep_normativa_convivencia/` (`_quarto.yml:27`, `10_configuracion.R:32`, y `gh api …/pages`) |
| 10 | CI del último push | — | run `32970739780`, `completed/success`, 0 anotaciones |

### 3.2 TA — Auditoría contra producto

Producto: `50_documentacion/andamios/20260826_auditoria_contra_producto_v1.md` (581 líneas).
El detalle está ahí; lo que importa aquí es el saldo.

| Punto | Veredicto |
|---|---|
| 1 Cifras de cierre | confirmado |
| 2 Enlaces internos (795 / 0 rotos) | confirmado, con la definición reconstruida |
| 3 Sitio publicado | confirmado |
| 4 Conversión `$` → `[[ ]]` | **confirmado en parte / refutado en parte** |
| 5 CI | confirmado |
| 6 Curaduría y OCR intactos | confirmado |
| 7 Higiene de commits | confirmado, con precisión de rango |
| 8 Muestreo de productos v1 | confirmado |

Dos resultados vale la pena destacar porque no eran deducibles del encargo:

- **La cifra 795 sí es reproducible.** El verificador que la produjo no está versionado y su
  criterio no constaba, así que se probaron ocho definiciones de «enlace interno» sobre el
  árbol real: 1276, 1208, 863, **795**, 273… La cuarta —href únicos por archivo con destino
  `.html`— da 795 exacto. La definición queda escrita.
- **`relaciones.json` no se publica** (404 en las tres rutas plausibles), así que `N96 = 0`
  en el artefacto publicado se verificó por huella: el deployment activo es `1147f56` y el
  blob de ese commit tiene el mismo SHA-256 que el working tree. Y por efecto: las cinco
  remisiones al DFL 1 se leen en el HTML publicado de cada norma citante.

### 3.3 TB — `[[ ]]` exacto en `00_ocr_documentos.R`

Dos líneas de código y siete de comentario. `estado_curado()` pasa a
`[["normas"]][[slug]]` y `cur[["origen_texto"]]`, quedando idéntica a `origen_curado()` de
`31_extraer_texto.R`. **El script no se ejecutó** (condición 7): la compuerta `--rehacer`
sigue intacta y el manifiesto de OCR sin tocar.

Arnés (`/tmp/slep_v3_scratch/tb/arnes.R`), que transcribe las dos versiones de la función y
las alimenta sin cargar el pipeline:

| Caso | Versión con `$` | Versión con `[[ ]]` |
|---|---|---|
| curaduría real, las 10 entradas | idéntica a la nueva | idéntica a la vieja (**no-op comprobado**) |
| entrada mínima del DFL 1: `$anio` | **1996** (coincidencia parcial) | `NULL` |
| entrada mínima del DFL 1: `$fuente_anio` | el texto de `fuente_anios_alternativos` | `NULL` |
| curaduría plantada con `origen_texto_declarado` y sin `origen_texto` | **`ocr_revisado`** — creería que está revisado y bloquearía `--rehacer` | `NA` |
| curaduría plantada con `normas_historicas` y sin `normas` | **`ocr_revisado`** | `NA` |

`parse()` limpio (33 expresiones de nivel superior). Diff acotado: las únicas dos líneas de
código modificadas son las de `estado_curado()`.

### 3.4 TD — Borradores con el rótulo antiguo

Producto: `50_documentacion/andamios/20260826_borradores_rotulo_rex482_v1.md`.
**5 de 22 piezas, 7 líneas, 7 menciones**, todas citando `rex_482_reglamentos_b`, así que
en las siete el rótulo correcto es el mismo (`Resolución exenta 482 (cuerpo)`). Los enlaces
no cambian: ya apuntan al archivo y al ancla correctos.

Instrumento calibrado en los dos sentidos sobre tres piezas sintéticas bajo `/tmp`: caza el
rótulo antiguo, calla sobre los dos nuevos. El barrido real dio 5, de modo que el control
positivo que el encargo pedía solo para el resultado 0 no era obligatorio; se hizo igual.

De paso quedó registrado que `glosario.md` llama al mismo documento «circular 482» en otras
seis líneas: una tercera forma de nombrarlo, que conviene unificar en la misma pasada.

### 3.5 TE — La tabla de los 34 temas frágiles

Producto: `50_documentacion/andamios/20260826_tabla_temas_fragiles_v1.md`.

El marcador **existe y su conteo es 34** por dos vías independientes (condición 4
satisfecha): la tabla ⚠ de `20260825_indagacion_pre_cierre.md` §2, y una re-derivación
programática de `asignar_temas()` sobre `TEMAS_PALABRAS_CLAVE` hecha en este turno. Los dos
conjuntos son **idénticos** (0 en uno y no en el otro, en ambas direcciones), y la
reconstrucción de temas contra los 25 JSON publicados da **0 discrepancias**.

**Una decisión de forma que el encargo dejaba abierta.** El encargo pide «una fila por caso
con norma, artículo, tema asignado», pero la asignación de tema es **al documento**, no al
artículo. La columna «Dónde aparece» no dice que el tema esté asignado a ese artículo: dice
dónde está **la única aparición de la palabra clave que disparó el tema para todo el
documento**, que es el sitio exacto que el revisor tiene que leer para decidir. Se localizó
en **34 de 34** casos, uno solo por caso, y la tabla lo declara en un párrafo propio.

Verificación: 34 filas, las 34 con 8 columnas, las 34 con enlace, las 34 con las tres
columnas del equipo vacías. Muestreo de cuatro enlaces (tres del encargo más uno de página
OCR) contra el sitio publicado: HTTP 200 y ancla presente en los cuatro; control positivo
con un ancla inexistente → 0.

### 3.6 TF — CSV del cruce y pauta

`50_documentacion/andamios/cruce_referencia_instrumentos.csv`: 25 filas, una por norma del
catálogo, separador `;`, UTF-8, cabecera exacta con las 7 columnas del formato, columnas 1
y 2 llenas y 3 a 7 vacías. `documento_referencia` usa `nombre_corto()` —que ya distingue
los dos miembros del REX 482— más el título oficial cuando existe, sin reescribirlo.

Verificado: re-abre con `read.csv2()` con 25 filas, cabecera idéntica, slugs en el mismo
orden que el catálogo, tildes intactas y las cinco columnas del equipo vacías en las 25
filas.

Sobre la pauta: **una sola línea modificada**, la 5, con la URL. Los cinco conteos de
páginas que la pauta declara coinciden con el producto (condición 5 no exigió corrección) y
se comprobaron uno a uno antes de tocar el archivo.

### 3.7 TC — Procedencia de los años alternativos en la ficha

Dos cambios, y la regeneración:

- `32_segmentar_articulos.R`: `construir_norma()` escribe `fuente_anios_alternativos` al
  JSON de la norma, junto a `anios_alternativos` y con el mismo trato que `fuente_anio`.
- `34_generar_paginas.R`: la ficha gana una línea, **solo cuando la curaduría declaró algún
  año alternativo**:

  > **Años de cita reconocidos** 1997, 1996 *(dato curado — el DFL N° 1 del Ministerio de
  > Educación… Verificado en Ley Chile (BCN, idNorma 60439) el 2026-08-26…)*

  La forma es la de `fuente_anio`, que ya existía: mismo `<dt>/<dd>`, misma clase
  `procedencia`, mismo prefijo «dato curado —». Aparece en **2** páginas (el DFL 1 y el
  dictamen 52/77) y en **ninguna** de las otras 23, que es exactamente el conjunto de
  normas con `anios_alternativos` no vacío.

Los cinco chequeos que condicionaban el commit:

| Chequeo | Resultado | Evidencia |
|---|---|---|
| (a) presencia en el HTML de la ficha del DFL 1, calibrado | **PASA** | 5 pruebas: **las 5 FALLAN antes** de regenerar y **las 5 PASAN después** |
| (b) diff acotado según condición 6 | **PASA** | 50 líneas agregadas, **todas** `"fuente_anios_alternativos":`, **0 eliminadas**; nada fuera de las 25 fichas de norma y el catálogo |
| (c) `relaciones.json` idéntico byte a byte | **PASA** | mismo SHA-256 antes y después, e idéntico al blob de `HEAD` |
| (d) enlaces internos | **PASA** | 795 enlaces, **0 rotos**, con el verificador calibrado de TA |
| (e) manifiesto de incorporación | **PASA** | 25 documentos, **25 sin cambio / 0 nuevos / 0 modificados** |

**Efecto lateral bienvenido:** el dictamen 52/77, que tenía la misma forma desde la sesión 1
y era el hueco preexistente que la Duda 6 mencionaba, también gana su procedencia visible.

## 4. Auditoría de diagnóstico

- **TA**: panel adversarial de dos revisores (§5), más re-derivación propia de cada punto
  con código escrito en este turno y no tomado de los logs.
- **TB**: arnés que aísla la función y la alimenta con cuatro entradas, dos de ellas
  plantadas; el caso malo reproduce el defecto y el bueno lo evita, sin cambiar el
  comportamiento sobre la curaduría real.
- **TD**: control del instrumento en los dos sentidos (un caso malo, dos buenos).
- **TE**: re-derivación programática independiente de la tabla ⚠, cruzada con ella.
- **TF**: el CSV se verificó releyéndolo con `read.csv2()`, no inspeccionando lo escrito.
- **TC**: el chequeo (a) corrió **antes** de la regeneración y falló, que es la única forma
  de saber que después mide algo.

## 5. El panel adversarial

Dos revisores en paralelo (tope duro del encargo), ambos con la restricción de lenguaje
declarada en el prompt (**R o `jq` exclusivamente, Python prohibido**) y la de solo lectura.
Los dos informes la reportan respetada, con sus temporales bajo `/tmp/slep_v3_panel1/` y
`/tmp/slep_v3_panel2/`.

**Re-derivación de los puntos 1 y 8: los dos los reprodujeron completos, sin una sola
discrepancia.** Añadieron por su cuenta tres controles que esta auditoría no tenía: la
coherencia de los campos autodeclarados contra sus arreglos, la partición 21/67 verificada
**en las dos direcciones** (las 67 filas `correcto` son idénticas a los 67 descartes que
quedan, no solo del mismo tamaño), y la ausencia de descartes de 1996 en todo el registro y
no solo hacia el DFL 1.

**El veredicto 4 cayó dos veces, por caminos independientes, y los dos tenían razón.**
`48d176a` **no tocó `34_generar_paginas.R`**, que vive en `30_procesamiento/` y es el script
más grande del directorio. Quedan **17 accesos `$` sobre curaduría cruda** (los objetos de
pieza, cuyo front matter YAML se lee directo de `20_insumos/curaduria/piezas/` sin esquema
que lo normalice) y **86 sobre curaduría derivada**. El error de método fue mío: el primer
barrido usó una lista de nombres de variable que no incluía `p`, y el barrido exhaustivo
posterior clasificó esos accesos en bloque como «estructuras derivadas», lo que para los
objetos de pieza es falso.

Lo grave está en dónde cae: `firmada()` (línea 359) decide con `p$validado_por` si una
pieza interpretativa está firmada. Una pieza con `estado: validada`, sin `validado_por` y
con cualquier clave que lo tenga por prefijo **pasa la compuerta y se publica**. Es el punto
donde `CLAUDE.md` §10.5 dice que el pipeline debe abortar. Esta auditoría lo reprodujo por
su cuenta antes de aceptarlo, y midió que **no está viva**: 0 de 22 piezas sin
`validado_por`, 0 con clave prefijada, las 22 en `borrador`.

**El veredicto 2 fue el que más aguantó**, y salió reforzado. El revisor 2 descomprimió los
25 `.pf_fragment` del índice de Pagefind y verificó que **las 1612 anclas indexadas resuelven
todas** a un `id` real del HTML: es la comprobación **medida** del invariante que
`CLAUDE.md` §10.5 declara sobre `slugificar()`, que hasta ahora se daba por supuesta.

## 6. Verificación de invariantes 🔒

| Invariante | Comprobación | Resultado |
|---|---|---|
| Nada cierra `ocr_revisado`, aprueba temas ni publica piezas | `git log 358e150..HEAD -- 20_insumos/`; estados en el catálogo | **cumplido**: 5 documentos siguen en `ocr_pendiente_revision`, 0 en `ocr_revisado`, 22 piezas en `borrador` |
| `20_insumos/curaduria/` y `20_insumos/ocr/` solo se leen | `git status --porcelain -- 20_insumos/` tras cada tarea | **vacío** en toda la cadena; el único commit de la sesión sobre esa ruta sigue siendo `90d58cf` |
| `40_salidas/` solo cambia por regeneración | único cambio, el de TC vía `run_all()` completo | **cumplido**: 50 líneas, todas del campo nuevo |
| Anclas públicas estables | ningún slug ni `id` cambió; verificador de enlaces 0 rotos antes y después | **cumplido** |
| Toda cifra recontada en el turno que la reporta | `Rscript` y `jq` en el mismo turno, más dos revisores independientes | **cumplido** |
| La auditoría no corrige lo que audita (condición 3) | las 5 observaciones de TA quedan registradas y sin tocar | **cumplido**: O5 se detectó en TA y **no** se arregló en TC, aunque TC tocaba justo ese archivo |
| Subagentes en R/jq, Python prohibido, solo lectura | declarado en ambos prompts; ambos lo reportan respetado | **cumplido** |
| Duda 3 (slug del DFL 1) intacta | ningún renombre; viaja en el Bloque 4 de la pauta | **cumplido** |

## 7. Decisiones del usuario registradas en gates

**Ninguna nueva.** Todas las autorizaciones usadas venían escritas en la lista cerrada del
encargo: escritura en `00_ocr_documentos.R`, `30_procesamiento/`, `50_documentacion/andamios/`;
`/tmp/slep_v3_scratch`; lectura web sobre el sitio y `github.com`; `gh` de lectura;
`run_all()` para TC; `git add` de rutas explícitas.

La excepción G1 de la adenda anterior (escritura delegada en curaduría) **no se ejerció ni
se extendió**: `20_insumos/curaduria/` no se tocó en toda la cadena.

## 7bis. Decisiones autónomas

| # | Decisión | Alternativa descartada | Reversibilidad |
|---|---|---|---|
| D1 | **Convertir a `[[ ]]` las lecturas de `anio` y `fuente_anio` en el bloque de `34_generar_paginas.R` que TC edita** (4 accesos). | Dejarlas con `$` por ser cambio quirúrgico. | Reversible: 4 accesos en la función que ya estaba abierta. Es TC la que crea el par vivo `fuente_anio` ⊂ `fuente_anios_alternativos` en el JSON de norma; introducir el campo y dejar la lectura ambigua sería repetir el defecto de la sesión a sabiendas. Los otros 82 accesos de clase B **no** se tocaron: eso es O5 y es del cierre. |
| D2 | **En TE, interpretar «artículo» como el segmento donde está la aparición única de la palabra clave**, y declararlo en la tabla. | Dejar la columna vacía o repetir el slug, porque el tema es del documento. | N/A, es de forma. Sin esa columna el equipo no sabe qué leer; con ella y sin la aclaración, creería que el tema está asignado al artículo. Se hicieron las dos cosas. |
| D3 | **BOM UTF-8 al frente del CSV.** | Sin BOM, como lo escribe `write.csv2()`. | Reversible: 3 bytes. Excel en Windows sin BOM lee las tildes como mojibake, y el circuito del formato termina en Excel. Se comprobó antes de decidir que `read.csv2()` en R 4.5 lee el archivo con BOM sin ensuciar el nombre de la primera columna, así que la verificación del encargo se cumple igual. |
| D4 | **`documento_referencia` = `nombre_corto()` + título oficial**, sin recortar ni reescribir el título. | Solo el nombre corto (más limpio en Excel) o un título resumido. | Reversible: una columna regenerable. «Ley 20.536» sola no basta para que el equipo reconozca la norma; reescribir el título rompería la fidelidad normativa. Las 4 normas sin título derivable quedan con el nombre corto solo. |
| D5 | **Ejecutar la regeneración como `Rscript -e 'source("00_run_all.R"); run_all()'`.** | `Rscript 00_run_all.R`, que es lo que el encargo escribe. | N/A. `Rscript 00_run_all.R` **solo define la función y no ejecuta nada**: se corrió primero así y produjo cero salida y cero cambios. Ver §10. |

## 8. Dudas y pendientes abiertos

Las cinco observaciones de TA son, cada una, una pregunta cerrada para el cierre. Están
desarrolladas con su evidencia en `20260826_auditoria_contra_producto_v1.md` §11; aquí van
sus preguntas.

### Duda 1 (O5) — La compuerta de firma de piezas es derrotable

`34_generar_paginas.R:359` decide con `p$validado_por`, sobre el front matter YAML crudo de
`20_insumos/curaduria/piezas/`. Una pieza `estado: validada` sin `validado_por` y con una
clave que lo tenga por prefijo se publica como firmada. No está viva (0 de 22 piezas la
exponen), pero es el punto que `CLAUDE.md` §10.5 declara invariante duro.

**Pregunta cerrada.** ¿Se convierten a `[[ ]]` los 17 accesos de clase A de
`34_generar_paginas.R` en una tarea propia, o se difiere al traspaso v02 junto con los 86 de
clase B?

**Qué quedó bloqueado.** Nada hoy: ninguna pieza está publicada. Es riesgo diferido en la
compuerta más sensible del proyecto.

### Duda 2 (O1) — La pauta llama «escaneados» a los cinco documentos OCR, y solo cuatro lo son

El dictamen 078 sí tiene capa de texto (`sin_capa_texto: false`); llegó a
`ocr_pendiente_revision` por declaración de curaduría. TF autoriza tocar la pauta solo para
el enlace y los conteos, así que no se corrigió.

**Pregunta cerrada.** ¿Se ajusta esa frase del Bloque 1 antes de entregar la pauta, o se
entrega como está y se aclara de viva voz?

**Qué quedó bloqueado.** Nada; la carga de revisión para el equipo es la misma.

### Duda 3 (O4) — Dos imprecisiones en el rastreo de fuentes del glosario

`20260826_fuentes_glosario_v1.md` declara 11 segmentos de la circular 482 con «protocolo de
actuación» y se miden **12** (el criterio de exclusión no consta; el candidato natural es la
página 38, que cita un documento externo en vez de regular); y sitúa la mención de la Ley
21.809 en un «artículo 46 letra f)» que **no existe** en esa ley: el texto está en
`art-44-bis`, que es el artículo modificatorio, y el artículo 46 es de la norma modificada.

**Pregunta cerrada.** ¿Se corrige la referencia a `art-44-bis` y se declara el criterio del
conteo de 11, o el documento queda como está por ser andamio interno?

**Qué quedó bloqueado.** Nada. El veredicto del documento («no hallada como definición
legal») se verificó y se sostiene.

### Duda 4 (O3) — `paginas` es prefijo de `paginas_pdf` y `paginas_vacias` en el manifiesto de OCR

Dos pares prefijo/prefijado vivos en `20_insumos/ocr/manifiesto_ocr.json`.
`00_ocr_documentos.R:327` lee `d$paginas`, pero sobre la lista que el propio script
construye, donde las tres claves existen: hoy no hay defecto. TB estaba acotada a la
curaduría y no se tocó.

**Pregunta cerrada.** ¿Se alinean también las lecturas del manifiesto en
`00_ocr_documentos.R`, o queda como deuda declarada?

### Duda 5 — Sigue abierta la Duda 3 del traspaso: el slug del DFL 1

Sin cambios; el encargo la excluye y viaja al equipo en el Bloque 4 de la pauta. **Lo que sí
cambió es su peso**, y lo hizo notar el panel: la restitución de esta sesión llevó
`dto_453 → dfl_1` de 1 cita a 18 y creó dos remisiones más, todas correctas en derecho y
todas enrutando hoy a una URL que dice «asistentes» cuando el documento es el Estatuto
Docente. El propio campo `fuente_anios_alternativos` describe la norma como «el texto
refundido de la ley N° 19.070»: la curaduría ya contradice al slug en su propio texto.

El panel acotó además la decisión con un dato útil: el rótulo erróneo **no llegó al texto
visible**. El `<h1>` y los 19 enlaces dicen «Decreto con fuerza de ley 1»; «asistentes» vive
solo en el slug, la URL, el nombre del PDF y la clave del JSON. Renombrar rompe URLs
públicas y nada más: no hay texto que reescribir.

## 9. Estado de cifras y datos críticos

Todas recontadas programáticamente en el turno de cierre.

| Cifra | Valor | Comando |
|---|---:|---|
| Relaciones vigentes | 552 | `Rscript` sobre `relaciones.json`, `table()` por tipo |
| Por tipo | 2 sust. / 2 grupo_acto / 46 remisión / 502 tema | idem |
| Descartes | 67 (42 `d_o` + 25 `de_aaaa`) | `table(forma_anio)` |
| `N96` | **0** | filtro `anio_cita == 1996 & hacia == dfl_1…` |
| Enlaces internos / rotos | 795 / **0** | verificador propio calibrado, definición D4 |
| Manifiesto de incorporación | 25 / 0 / 0 | `jq` sobre `manifiesto_corpus.json` |
| Normas del catálogo | 25 | `catalogo.json` |
| Artículos | 682 | idem |
| Páginas en `ocr_pendiente_revision` | 84 en 5 documentos | `jq -s` sobre `normas/*.json` |
| Piezas en borrador | 22 de 22 | front matter de `piezas/borradores/` |
| Asignaciones de tema frágiles | 34 | re-derivación de `asignar_temas()` |
| Filas del CSV de cruce | 25 | `read.csv2()` |
| Commits de la cadena | 8 (7 de tarea + este) | `git log` |
| `40_salidas/` versionado modificado por TC | 26 archivos, +50 / −0 | `git diff --numstat` |

## 10. Notas para el revisor

- **Lo que falló.** Nada del repositorio. De mis instrumentos, dos, y los dos quedan
  registrados porque casi producen hallazgos falsos: (1) el patrón `[a-zé]*` con que busqué
  los rótulos del REX 482 en el HTML publicado **no cubre la `ó` de «resolución»**, y por un
  momento pareció que el sitio publicado no traía el rótulo `(resolución)` que sí trae; (2)
  el primer barrido de accesos `$` usó una lista de nombres de variable que **no incluía
  `p`**, y de ahí salió el veredicto 4 que el panel derribó. En los dos casos el error
  estaba en el instrumento y no en el producto.
- **Lo que sorprendió.** Que **`Rscript 00_run_all.R` no ejecuta nada.** El archivo define
  `run_all()` y termina; hay que invocarla. El encargo lo escribe de la primera forma, y los
  encargos anteriores también. Se corrió así primero: salió con código 0, cero líneas de
  log y cero cambios en el árbol, que es exactamente la forma que tiene un paso de pipeline
  de parecer ejecutado sin haberlo estado. Vale la pena corregir la fórmula en los encargos
  futuros o darle a `00_run_all.R` un `if (!interactive()) run_all()` al final.
- **Lo segundo que sorprendió.** Que el hallazgo de más consecuencia de la sesión —la
  compuerta de firma derrotable— lo encontrara el panel y no la auditoría, **y que estuviera
  a tres líneas del código que TC iba a editar**. La condición 3 del encargo lo dejó donde
  corresponde: registrado, no corregido. Sin esa condición escrita de antemano, la
  tentación de arreglarlo de paso habría sido difícil de resistir y la auditoría habría
  quedado contaminada por el auditado.
- **El panel se pagó solo, otra vez.** Fue el mismo patrón de la adenda anterior: los
  revisores confirmaron todo lo aritmético sin discrepancias y refutaron lo que el auditor
  había enunciado con más amplitud de la que podía sostener. Es el segundo encargo seguido
  en que la refutación cae sobre el alcance de una afirmación, no sobre una cifra.
- **Copias temporales.** Todo bajo `/tmp/slep_v3_scratch/` y `/tmp/slep_v3_panel{1,2}/`,
  fuera del repositorio, borradas al cerrar. Ningún archivo del repositorio se modificó desde
  ellas: `git status --porcelain -- 20_insumos/` quedó vacío en toda la cadena.
- **Push.** Uno solo al cierre. El segundo push que el encargo autorizaba de antemano queda
  sin usar salvo que la evidencia de CI lo exija; si se usa, se registra en una adenda a este
  log.

---

## Adenda — evidencia de CI posterior al push (segundo push, autorizado de antemano)

El encargo autoriza «UN segundo push autorizado de antemano si la evidencia del CI
posterior al primero debe quedar registrada en el log». Esta adenda es ese caso, y por eso
el commit que la trae es el segundo y último push de la cadena. La tensión que el log v2
tuvo que improvisar (§10, «hubo dos push, no uno») queda resuelta por diseño.

### El run del push de cierre

| Campo | Valor |
|---|---|
| Run | **32976901286** |
| `headSha` | `6b4ab7188a617399b7763f8f2172626b321bf4f1` |
| Estado | `completed` / **`success`** |
| Job `construir` | success, 13:53:25 → 13:55:02 UTC |
| Job `desplegar` | success, 13:55:06 → 13:56:16 UTC |
| Anotaciones | **0** en ambos jobs |
| Deployment activo | sha `6b4ab71`, 13:55:03 UTC |

Sin avisos de deprecación: las actions que el encargo v2 subió a `node24` siguen limpias
tres runs después.

### Verificación de TC en producción, no solo en el build local

El punto 2 de la auditoría quedó acotado al build local porque `40_salidas/sitio/` está en
`.gitignore` y lo que sirve Pages lo reconstruye el runner. Con el deployment de `6b4ab71`
ya activo, el cambio de TC se comprueba **sobre el HTML que sirve GitHub Pages**:

| Comprobación | Resultado |
|---|---|
| `dfl_1_estatuto_asistentes_educacion.html` publicado | **HTTP 200** |
| Línea nueva en la ficha publicada | `Años de cita reconocidos</dt><dd>1997, 1996 <span class="procedencia">(dato curado — el DFL N° 1 del Ministerio de Educación, que fija el texto refundido de la ley N° 19.070…` |
| Control negativo: `ley_20536_violencia_escolar.html` publicado | **0** apariciones de la línea, como corresponde a una norma sin años alternativos |

El chequeo (a) de TC, que se calibró contra el árbol local (fallaba antes, pasaba después),
se confirma ahora en el artefacto que el equipo de convivencia va a abrir.

### Estado al cierre

`HEAD` == `origin/main` == el commit de esta adenda. Árbol limpio. Copias temporales de
`/tmp/slep_v3_scratch/` borradas.
