# Auditoría contra producto — sesión 2 completa

Proyecto `slep_normativa_convivencia`, 2026-08-26. Producto de la tarea TA del encargo
`50_documentacion/andamios/20260826_encargo_auditoria_y_cierre_v3.md`.

> **Qué es y qué no es.** Re-deriva desde los artefactos (JSON, HTML local, HTML
> publicado, historia de Git, API de GitHub) todo lo que los logs de esta sesión
> afirman, con código escrito en este turno y no con el de los logs. **No corrige
> nada** (condición 3 del encargo): un hallazgo discrepante se registra con su
> evidencia y sigue el barrido. Los logs son el objeto auditado, no la fuente de
> verdad.

## 1. Veredicto global

**7 de 8 puntos confirmados; 1 refutado en parte.** Ninguna cifra, hash ni estado de los
logs de la sesión 2 resultó falso al medirlo contra el producto. El punto que cae no es una
afirmación de los logs sino **un enunciado de esta misma auditoría**, que el panel
adversarial derribó: el alcance de la conversión `$` → `[[ ]]` era más estrecho de lo que
esta auditoría había declarado (§5). Se registran además **5 observaciones** (§11).

| # | Punto | Veredicto |
|---|---|---|
| 1 | Cifras de cierre de TC | **confirmado** |
| 2 | Enlaces internos | **confirmado** |
| 3 | Sitio publicado | **confirmado** |
| 4 | Conversión `$` → `[[ ]]` | **confirmado en parte / refutado en parte** |
| 5 | Estado del CI | **confirmado** |
| 6 | Curaduría y OCR intactos | **confirmado** |
| 7 | Higiene de commits | **confirmado**, con precisión de rango |
| 8 | Muestreo de productos v1 | **confirmado** |

## 2. Punto 1 — Cifras de cierre

Comando propio, sobre `40_salidas/datos/relaciones.json` del working tree:

```r
j <- jsonlite::fromJSON("40_salidas/datos/relaciones.json", simplifyVector = FALSE)
table(vapply(j[["relaciones"]], function(r) r[["tipo"]], character(1)))
table(vapply(j[["descartadas"]], function(x) x[["forma_anio"]], character(1)))
```

| Afirmación del log (Adenda 2 §E) | Medido | Veredicto |
|---|---:|---|
| relaciones totales = 552 | 552 | confirmado |
| sustitución = 2 | 2 | confirmado |
| grupo_acto = 2 | 2 | confirmado |
| remisión = 46 | 46 | confirmado |
| tema = 502 | 502 | confirmado |
| descartes = 67 | 67 | confirmado |
| desglose 42 `d_o` + 25 `de_aaaa` | 42 + 25 | confirmado |
| `N96` = 0 | 0 | confirmado |

`N96` se recontó con su definición explícita (descartes con `anio_cita == 1996` y
`hacia == "dfl_1_estatuto_asistentes_educacion"`); el barrido por año del arreglo completo
de descartes da `1980:1, 2000:2, 2005:18, 2006:4, 2012:42` y ningún 1996.

**Coherencia interna del archivo:** los campos declarados (`n_relaciones` 552, `por_tipo`,
`remisiones_descartadas_por_anio` 67, `relaciones_suprimidas_intra_grupo` 2) coinciden con
el recuento de sus propios arreglos.

**Las cinco remisiones al DFL 1**, con `n_citas`:

| desde | artículo | `n_citas` |
|---|---|---:|
| `ley_19979_jornada_escolar_completa` | `art-5` | 1 |
| `ley_21545_tea` | `art-19` | 1 |
| `ley_21809_convivencia_educativa` | `art-16-e` | 2 |
| `dfl_315_perdida_reconocimiento_oficial` | `art-11` | 2 |
| `dto_453_estatuto_docente` | `preambulo` | **18** |

Las tres condiciones del encargo se cumplen: `dfl_315 → dfl_1` existe, `ley_21809 → dfl_1`
existe, y `dto_453 → dfl_1` tiene `n_citas >= 18` (exactamente 18).

## 3. Punto 2 — Enlaces internos

Verificador **escrito en este turno**, sin mirar el del log: indexa `id=` / `name=` de los
47 HTML de `40_salidas/sitio/`, extrae los `href` internos, y comprueba archivo destino y
ancla por separado.

**Calibración (control positivo).** Sobre una copia bajo `/tmp/slep_v3_scratch/sitio_ctrl`
se plantaron dos casos malos, un enlace a archivo inexistente y un ancla inexistente:

```
ARCHIVO_AUSENTE index.html -> norma_que_no_existe.html
ANCLA_AUSENTE   index.html -> ley_20536_violencia_escolar.html#art-999-inexistente
```

El instrumento dispara sobre los dos. Sobre el árbol real calla: **0 rotos**.

**La cifra 795.** El verificador que la produjo no está versionado y su criterio de conteo
no consta en el log, así que se reconstruyó probando ocho definiciones de "enlace interno"
sobre el árbol real:

| Definición | Valor |
|---|---:|
| internos, todas las apariciones | 1276 |
| internos, únicos por archivo | 1208 |
| internos a `.html`, todas | 863 |
| **internos a `.html`, únicos por archivo** | **795** |
| internos con ancla, todas | 273 |

La cifra del log es exactamente la cuarta definición. **795 / 0 rotos: confirmado**, con
la salvedad de que la definición estaba implícita y aquí queda escrita.

## 4. Punto 3 — Sitio publicado

URL extraída de la configuración: `_quarto.yml:27` y `10_utils/10_configuracion.R:32`
declaran `https://tomgc.github.io/slep_normativa_convivencia/`, y
`gh api repos/:owner/:repo/pages` devuelve el mismo `html_url`, `build_type: workflow`,
`public: true`.

| Comprobación | Resultado |
|---|---|
| HTTP de la raíz | **200** (25.342 bytes) |
| HTTP de `rex_482_instrucciones_reglamentos_internos.html` | 200 |
| HTTP de `rex_482_reglamentos_b.html` | 200 |
| HTTP de `dfl_1_estatuto_asistentes_educacion.html` | 200 |
| Rótulo `Resolución exenta 482 (resolución)` en el HTML publicado | **presente**, en 7 páginas |
| Rótulo `Resolución exenta 482 (cuerpo)` en el HTML publicado | **presente** |

Las 7 páginas publicadas que traen el rótulo `(resolución)` son las mismas 7 que lo traen
en el árbol local: `indice-tipo`, `indice-anio`, `dictamen_52_77_expulsion`,
`rex_482_instrucciones_reglamentos_internos`, `rex_482_reglamentos_b`,
`tema-reconocimiento-oficial`, `tema-medidas-disciplinarias`.

> **Nota de método, porque casi produce un falso hallazgo.** El primer patrón de búsqueda
> sobre el HTML publicado fue `Resoluci[oó]n exenta 482 ([a-zé]*)`, que no cubre la `ó` de
> «resolución»: encontró `(cuerpo)` y no `(resolución)`, y por un momento pareció una
> discrepancia entre local y publicado. El patrón corregido `([^)]*)` encuentra los dos.
> Queda registrado porque el error estaba en el instrumento, no en el producto.

**`N96` en el artefacto publicado.** `relaciones.json` **no** es alcanzable públicamente
(`datos/relaciones.json`, `relaciones.json` y `datos/catalogo.json` devuelven **404**): el
sitio publica HTML y el índice de Pagefind, no los datos crudos. Se declara **no
verificable por esa vía** y se verifica por huella contra el commit desplegado:

| Comprobación | Resultado |
|---|---|
| Deployment activo (`gh api repos/:owner/:repo/deployments`) | sha `1147f56`, entorno `github-pages`, 2026-08-26T12:52:13Z |
| SHA-256 de `40_salidas/datos/relaciones.json` (working tree) | `5a03d04c388471a449577caf9fe780ce3672ca12161f0aee5d2bd0182653947a` |
| SHA-256 del mismo blob en `1147f56` | **idéntico** |
| `N96` sobre el blob de `1147f56` | **0** (552 relaciones, 67 descartes) |

**Verificación pública sustantiva.** Aunque el JSON no se publique, su efecto sí: las
cinco remisiones al DFL 1 aparecen en el HTML publicado de cada norma citante, con su
explicación por plantilla:

| Página publicada | Explicación en el HTML |
|---|---|
| `dfl_315_perdida_reconocimiento_oficial` | «Cita «decreto con fuerza de ley Nº 1» en Artículo 11 y en otros 1 fragmentos» |
| `ley_21809_convivencia_educativa` | «… en Artículo 16 E y en otros 1 fragmentos» |
| `dto_453_estatuto_docente` | «… en Encabezado y promulgación y en otros **17** fragmentos» |
| `ley_19979_jornada_escolar_completa` | «… en Artículo 5º» |
| `ley_21545_tea` | «… en Artículo 19» |

Las dos primeras son precisamente las que no existían antes de la regeneración de TC.
Control: `ley_20911_formacion_ciudadana`, que no remite al DFL 1, tiene **0** enlaces
hacia él.

## 5. Punto 4 — Conversión `$` → `[[ ]]`

**Veredicto: confirmado en su primera mitad, REFUTADO en la segunda.** El panel
adversarial derribó este punto por dos caminos independientes y tenía razón; lo que sigue
es el enunciado corregido, con la evidencia re-verificada por la auditoría.

### 5.1 Confirmado — el commit que completó la conversión es `48d176a`

`48d176a` (`fix(pipeline): lectura exacta de la curaduria, el $ hacia coincidencia parcial
de nombres`). El log lo listaba sin identificar cuál contenía la parte completada tras la
refutación del panel anterior: la respuesta es que la conversión parcial y la completa
quedaron en el **mismo** commit, porque el trabajo se hizo en el árbol antes de commitear.
Su `--numstat`:

```
2  2  30_procesamiento/30_manifiesto_corpus.R
2  2  30_procesamiento/31_extraer_texto.R
40 28 30_procesamiento/32_segmentar_articulos.R
1  1  30_procesamiento/33_relaciones.R
```

El diff contiene las conversiones que el revisor 2 del panel anterior había exigido:
`.CUR$normas`, `.CUR$grupos_acto`, `g$miembros`, `g$resolucion`, `g$fuente`,
`g$nota_colapso`, `v$estado`, `v$sustituido_por`, `v$fuente`, y
`normas[[slug_b]]$anio` / `$anios_alternativos` en `33_relaciones.R:242`. **Las lecturas
directas del fichero `metadatos_curados.json` en esos cuatro scripts están convertidas.**

### 5.2 Refutado — «0 accesos» y «única excepción» son ambos falsos

El enunciado que esta auditoría había emitido —«0 accesos `$` a estructuras de curaduría
en `30_procesamiento/*.R` y `00_generar_borradores.R`; la única excepción viva está en
`00_ocr_documentos.R`»— es falso, y el error de método fue mío: el primer barrido usó una
lista de nombres de variable (`.CUR`, `CURADURIA`, `cur`, `curado`, `g`, `v`, `grupo`) que
**no incluía `p`**, el objeto de pieza. El barrido exhaustivo posterior sí vio esos 337
accesos, pero los clasifiqué en bloque como «estructuras que el pipeline construye o relee
del JSON derivado», y para los objetos de pieza esa clasificación es **incorrecta**.

**`48d176a` no tocó `34_generar_paginas.R`**, que también vive en `30_procesamiento/` y es
el script más grande del directorio. Recuento propio, con criterio declarado:

| Clase | Qué es | Líneas | Dónde |
|---|---|---:|---|
| **A — curaduría cruda** | objetos leídos directo de `20_insumos/curaduria/piezas/` con `yaml::yaml.load()` en `leer_pieza()` (línea 342) | **17** | `34_generar_paginas.R` (359, 360, 364, 368, 371, 374, 380, 383, 384, 387, 388, 396, 397, 401, 805, 826, 827) |
| **B — curaduría derivada** | campos de origen curatorial que llegan por el JSON de norma o el catálogo (`vigencia` 25, `tipo` 16, `origen_texto` 11, `grupo_acto` 9, `titulo` 9, `anio` 7, `marca_revisar` 5, `fuente_anio` 2, `notas_ficha` 2) | **86** | `34_generar_paginas.R` 41, `33_relaciones.R` 20, `32_segmentar_articulos.R` 15, `00_generar_borradores.R` 7, `10_utils/10_utils.R` 2, `31_extraer_texto.R` 1 |

La clase B es **riesgo latente y no activo**: el escritor (`construir_norma()`) emite
siempre las 23 claves del esquema, aunque valgan `null`, y se verificó archivo por archivo
que **0 de los 25 JSON de norma** tiene una clave faltante. Con la clave presente, la
coincidencia exacta gana y `$` acierta. Que existan tres pares prefijo/prefijado vivos en
ese esquema (`tipo ⊂ tipo_etiqueta`, `tipo ⊂ tipo_fuente`, `anio ⊂ anios_alternativos`) no
basta: hace falta además que la clave corta falte.

### 5.3 Lo grave: la compuerta de firma de piezas es derrotable

La clase A no tiene esa red. `leer_pieza()` devuelve **el front matter tal como el humano
lo escribió**, sin esquema que lo normalice, y sobre ese objeto opera la compuerta que
`CLAUDE.md` §10.5 declara invariante duro («Una pieza validada sin firma **aborta** el
pipeline, no se salta en silencio»):

```r
# 30_procesamiento/34_generar_paginas.R:359
firmada <- function(p) !is.null(p$validado_por) && nzchar(trimws(as.character(p$validado_por)))
```

Reproducción del defecto, en aislado y sin tocar el árbol:

```r
fm <- yaml::yaml.load('tipo: ficha\nestado: validada\nvalidado_por_equipo: "Convivencia"')
fm$validado_por        # -> "Convivencia"   (coincidencia parcial)
fm[["validado_por"]]   # -> NULL
firmada(fm)            # -> TRUE  <- la compuerta NO aborta y la pieza se publicaría
```

Una pieza que declare `estado: validada`, **no** declare `validado_por` y traiga cualquier
clave que lo tenga por prefijo (`validado_por_equipo`, `validado_por_nombre`) pasa la
compuerta y se publica como firmada. Es el mismo mecanismo que causó la regresión de esta
sesión, en el punto donde el proyecto declara que no puede fallar.

**No está viva hoy**, y esto se midió, no se supuso: las 22 piezas declaran las dos claves
—**0 de 22** carecen de `validado_por`, **0 de 22** traen una clave prefijada— y las 22
están en `estado: borrador`, así que ninguna llega siquiera a la compuerta. Pero la
precondición estructural sí está viva: **22 de 22** piezas omiten alguna clave de la unión
del front matter (las `faq_*` no traen `norma`, las `ficha_*` no traen `tema`), de modo que
el front matter de pieza es exactamente la clase de objeto con claves ausentes sobre la que
`$` es peligroso.

### 5.4 Enunciado corregido

> `48d176a` convirtió a acceso exacto **las lecturas directas de `metadatos_curados.json`**
> en `30_manifiesto_corpus.R`, `31_extraer_texto.R`, `32_segmentar_articulos.R` y
> `33_relaciones.R`. Fuera de ese alcance quedan: **17 accesos `$` sobre curaduría cruda**
> (objetos de pieza, en `34_generar_paginas.R`, incluida la compuerta de firma), **86
> accesos `$` sobre curaduría derivada** repartidos en seis archivos, y **`estado_curado()`
> en `00_ocr_documentos.R`**, que es el único que el comentario del código declara. Ninguno
> falla hoy. El comentario de `32_segmentar_articulos.R:435-439` acota su promesa a «30, 31,
> 32 y 33», que es correcto; fue esta auditoría la que la extendió a todo
> `30_procesamiento/`.

La corrección de los 17 accesos de clase A **no se hace en este encargo**: es un hallazgo
nuevo de TA, y el invariante 🔒 del encargo reserva TB y TC para defectos ya conocidos. Va
a §11 como O5, con su pregunta cerrada.

## 6. Punto 5 — CI

| Campo | Valor |
|---|---|
| Run | **32970739780** |
| `headSha` | `1147f5669328f257f7c5cc6907a5c516b636d296` |
| Título | `docs(andamios): adenda de TC ejecutada, excepcion del titular y arreg…` |
| Estado | `completed` / **`success`** |
| Job `construir` | success, 12:50:26 → 12:52:13 |
| Job `desplegar` | success, 12:52:16 → 12:52:24 |
| Anotaciones | **0** en ambos jobs |

El log v2 §3.2bis afirmaba 0 anotaciones tras subir las actions. Se confirma también en el
run posterior. Las siete `uses:` del workflow coinciden una a una con lo que el log declara
haber dejado: `checkout@v7`, `setup-r@v2`, `quarto-actions/setup@v2`, `setup-node@v7`,
`configure-pages@v6`, `upload-pages-artifact@v5`, `deploy-pages@v5`.

## 7. Punto 6 — Curaduría y OCR

```
git log --follow --oneline 358e150..HEAD -- 20_insumos/curaduria/metadatos_curados.json
git log --oneline 358e150..HEAD -- 20_insumos/ocr/ | wc -l
```

| Comprobación | Resultado |
|---|---|
| Commits sobre `metadatos_curados.json` en la sesión | **uno solo**: `90d58cf` |
| `--numstat` de ese commit | **6 / 0** (puramente aditivo) |
| Contenido del diff | la entrada `dfl_1_estatuto_asistentes_educacion` con `anios_alternativos: [1996]` y su `fuente_anios_alternativos`; nada más |
| Commits sobre `20_insumos/ocr/` en la sesión | **0** |
| Commits sobre `20_insumos/` completo en la sesión | **1**, el mismo `90d58cf` |

La excepción de escritura delegada que el titular autorizó (log v2 §7, G1) dejó rastro en
los tres lugares donde el proyecto lo exige: el mensaje del commit, el campo
`fuente_anios_alternativos` del propio dato, y el log. **La afirmación del log de que el
diff es aditivo y único es correcta.**

**Control cruzado de las premisas que ese campo declara.** El texto de
`fuente_anios_alternativos` afirma que el corpus cita la misma norma de las dos maneras:
`ley_21545_tea` art-19 «de 1997» y `ley_21809_convivencia_educativa` art-5 «de 1996». Las
dos se verifican contra el producto: `ley_21545_tea` art-19 es una de las remisiones vivas
(nunca fue descartada, su año es 1997) y `ley_21809` art-5 está entre los 21 descartes que
la regeneración restituyó. La procedencia declarada describe el corpus real.

## 8. Punto 7 — Higiene de commits

**18 commits** en `358e150..HEAD`. **Precisión que el panel exigió, y con razón:** en el momento de la medición `HEAD` es `efd63af` y `origin/main` es `1147f56`, así que el rango `358e150..origin/main` tiene **17** y el commit 18 es el de la condición 1 de este mismo encargo, que aún no está pusheado ni tiene run de CI. Los puntos 3 y 5 fijan el estado en `1147f56` precisamente por eso. La parte cualitativa se sostiene en los dos rangos:

| Comprobación | Resultado |
|---|---|
| Mensajes con prefijo convencional (`feat`/`fix`/`docs`/`data`/`refactor`/`ci`…) | **18 de 18** |
| Mensajes con co-autoría de herramienta (`Co-Authored-By`, «Generated with», «Claude», «Anthropic») | **0** |
| Asuntos con tilde (la convención del repo los escribe sin) | **0** |
| Autor | `Tomás González` en los 18 |

Lista completa, del más antiguo al más reciente: `70dc7da`, `c774ebc`, `dbe7a44`,
`71006d1`, `54c7059`, `515d2e3`, `06c2cd0`, `8f88729`, `fcb46f3`, `bd7260c`, `54f5ee1`,
`e8529e9`, `d264920`, `90d58cf`, `48d176a`, `d9c8fa2`, `1147f56`, `efd63af`.

## 9. Punto 8 — Muestreo de productos v1

### 9.1 `20260826_preclasificacion_descartes_v1.md`

El estado previo de `relaciones.json` se recuperó del blob de `48d176a` (ese commit no
tocó `40_salidas/`, así que su blob es el anterior a la restitución de `d9c8fa2`).

| Comprobación | Resultado |
|---|---|
| Filas de la tabla del §10 | **88** |
| Descartes en el estado previo | **88** — coinciden |
| Filas clasificadas `homologable` | **21** |
| Filas con `anio_cita` 1996 | 21, **todas** homologables |
| `N96` en el estado previo | **21** |
| Descartes quitados por la regeneración | **21** |
| Descartes agregados por la regeneración | **0** |
| Correspondencia 1:1 (clave `norma\|art\|cita\|año`) entre las 21 del documento y los 21 restituidos | **exacta**: 0 en el documento y no en el producto, 0 en el producto y no en el documento |

Los 21 restituidos por norma de origen: `dto_453_estatuto_docente` 17,
`dfl_315_perdida_reconocimiento_oficial` 2, `ley_21809_convivencia_educativa` 2.

**El chequeo (e) del log también se reproduce.** Con la clave `desde|hacia|tipo` que el log
usa: 2 relaciones nuevas (`ley_21809 → dfl_1`, `dfl_315 → dfl_1`), 0 desaparecidas, 1
modificada (`dto_453 → dfl_1`, que pasa de `art-88`/1 cita a `preambulo`/18 citas), y **0
ajenos al DFL 1**. La aparente discrepancia con una clave que incluya `articulo` (3 nuevas,
1 desaparecida) es el mismo hecho contado de otra forma: la relación de `dto_453` cambió de
artículo de anclaje al ganar 17 citas.

**Igualdad (d):** 67 == 88 − 21 → **verdadero**.

### 9.2 `20260826_nota_cifra_ocr_v1.md`

Comando central del §3, reproducido literal:

```
jq -s '[.[] | select(.origen_texto=="ocr_pendiente_revision")]
       | {documentos: length, paginas: (map(.paginas) | add)}' 40_salidas/datos/normas/*.json
→ { "documentos": 5, "paginas": 84 }
```

Re-derivado además en R con otro camino (lectura archivo por archivo con `jsonlite`):
5 documentos, 84 páginas. Los comandos del §1 también se reproducen: manifiesto **75**,
disco `pagina_*.txt` **75**, carpetas **4**. La identidad **84 = 75 + 9** se sostiene.

Control del comando: el mismo filtro con `ocr_revisado` en lugar de `ocr_pendiente_revision`
devuelve `{documentos: 0, paginas: null}`, como debe ser (ningún documento está revisado).

## 10. Panel adversarial

Dos revisores, en paralelo, con el tope duro de 2 del encargo. Los dos prompts declararon
la restricción de lenguaje (**R o `jq` exclusivamente, Python prohibido**) y la de solo
lectura, y los dos informes la reportan respetada: sus archivos temporales vivieron bajo
`/tmp/slep_v3_panel1/` y `/tmp/slep_v3_panel2/`, y `git status --porcelain` quedó vacío.
Se les entregaron los ocho veredictos y se les pidió re-derivar los puntos 1 y 8 con código
propio y refutar dos veredictos a su elección.

### 10.1 Re-derivación de los puntos 1 y 8

**Los dos reprodujeron los dos puntos completos, sin una sola discrepancia**: 552
relaciones (2/2/46/502), 67 descartes (42 `d_o` + 25 `de_aaaa`), `N96` = 0, las tres
remisiones con `dto_453` en `n_citas = 18`; y del lado del muestreo, 88 filas, 21
`homologable`, correspondencia 1:1 con los 21 restituidos, 0 descartes agregados, y
`{documentos: 5, paginas: 84}`.

Tres controles que ninguno de los dos tenía encargados y que añadieron por su cuenta:

- **Coherencia de los campos autodeclarados** contra el recuento de sus arreglos, para que
  el archivo no se certifique a sí mismo con una cifra rancia: coinciden.
- **La partición 21/67 en las dos direcciones**: las 67 filas `correcto` del documento son
  idénticas a los 67 descartes que quedan hoy, no solo del mismo tamaño. La igualdad se
  comprobó como igualdad de multiconjuntos, no de conteos.
- **Ausencia de descartes con `anio_cita == 1996` en todo el registro**, no solo hacia el
  DFL 1, y 0 descartes con `anio_cita` nulo.

### 10.2 Refutaciones

| Revisor | Veredicto atacado | Resultado |
|---|---|---|
| 1 | 2 — enlaces internos | **no refutado**, reforzado |
| 1 | 4 — conversión `$` → `[[ ]]` | **REFUTADO** en su cláusula universal |
| 2 | 4 — conversión `$` → `[[ ]]` | **REFUTADO** (mismo hallazgo, camino distinto) |
| 2 | 2 — enlaces internos | **no refutado**, con dos matices |

**El veredicto 4 cayó dos veces, por caminos independientes, y los dos tenían razón.** Está
reescrito en §5 con la evidencia re-verificada por esta auditoría: `48d176a` no tocó
`34_generar_paginas.R`, quedan 17 accesos `$` sobre curaduría cruda (objetos de pieza) y 86
sobre curaduría derivada, y la compuerta de firma de piezas es derrotable con una clave
prefijada. Los dos revisores llegaron al mismo contraejemplo ejecutable de la compuerta;
esta auditoría lo reprodujo por su cuenta antes de aceptarlo. **La falla no está viva hoy**
—las 22 piezas declaran `validado_por` y están en `borrador`— y ambos lo dijeron, que es lo
que separa un hallazgo útil de una alarma.

**El veredicto 2 fue el que más aguantó.** El revisor 1 lo atacó por cuatro flancos y el
revisor 2 por seis definiciones alternativas más dos superficies fuera de alcance:

| Ataque | Universo | Rotos |
|---|---:|---:|
| Todo destino local, `href` **y** `src`, cualquier extensión | 1546 | **0** |
| Solo PDF / CSS / JS | 25 / 282 / 611 | 0 / 0 / 0 |
| Anclas contra los `id`/`name` reales del destino | 273 | **0** |
| Mayúsculas/minúsculas byte a byte (trampa Linux, que macOS oculta) | 1546 | **0** |
| `search.json` de Quarto | 47 entradas | 0 |
| Índice de Pagefind, descomprimiendo los 25 `.pf_fragment` | **1612 anclas** | **0** |

Ese último es el más valioso del panel entero: verifica **medido** el invariante que
`CLAUDE.md` §10.5 declara («los id de artículo y las anclas del HTML salen de la misma
`slugificar()`; si divergen, la búsqueda apunta a fragmentos que no existen»). Las 1612
anclas que Pagefind indexa resuelven todas a un `id` real.

### 10.3 Lo que el panel aportó y esta auditoría no tenía

| Aporte | Quién | Estado tras verificarlo |
|---|---|---|
| `34_generar_paginas.R` quedó fuera de `48d176a` pese a vivir en `30_procesamiento/` | ambos | **verificado**: `git show --numstat 48d176a` lista solo 30, 31, 32 y 33 |
| La compuerta `firmada()` es derrotable por coincidencia parcial | ambos | **verificado y reproducido** por esta auditoría (§5.3) |
| El rango `358e150..HEAD` incluye un commit no pusheado y sin CI | ambos | **verificado**: §8 corregida |
| `descartadas` es por cita y `relaciones` por par: son unidades distintas y no deben restarse | revisor 1 | **verificado**: 4 pares figuran a la vez como remisión viva y como descarte, con años de cita distintos. Es correcto, y ningún producto de la sesión lo dice |
| Pagefind indexa **25 de 47** páginas (solo las que llevan `data-pagefind-body`): las 17 de tema, los 3 índices, `index` y `acerca` no son buscables | revisor 2 | **verificado**: `grep -rlo 'data-pagefind-body' 40_salidas/sitio/*.html` da 25 |
| El sitio publicado tiene exactamente los mismos 47 HTML que el build local, y el `sitemap.xml` no lista extras | revisor 2 | verificado por el revisor en las dos direcciones |
| El rótulo erróneo del `dfl_1` **no** llegó al texto visible: el `<h1>` y los 19 enlaces dicen «Decreto con fuerza de ley 1» | revisor 2 | **verificado**: la palabra «asistentes» no aparece en el cuerpo visible de su página; está confinada al slug, la URL, el nombre del PDF y la clave del JSON |
| `40_salidas/sitio/` está en `.gitignore` y lo que verifica el punto 2 es el build local, no el que sirve Pages | revisor 1 | correcto como acotación; los dos commits posteriores al build son solo `docs(andamios)`, así que no hay divergencia posible, pero el punto 2 no lo declaraba |

El último aporte del revisor 2 es el que más pesa para el titular: **la sesión amplió la
exposición del rótulo erróneo sin corregirlo.** La restitución llevó `dto_453 → dfl_1` de 1
cita a 18 y creó `dfl_315 → dfl_1` y `ley_21809 → dfl_1`. Las tres remisiones son
jurídicamente correctas, pero hoy enrutan a una URL que dice «asistentes» cuando el
documento es el Estatuto Docente. El propio campo `fuente_anios_alternativos` describe la
norma como «el texto refundido de la ley N° 19.070», es decir **la curaduría ya contradice
al slug en su propio texto**. La Duda 3 (renombrar el slug) está excluida de este encargo y
viaja al equipo en el Bloque 4 de la pauta; se registra que hoy pesa más que ayer.

## 11. Observaciones registradas, no corregidas

Las cinco son hallazgos de esta auditoría. Ninguna se corrige aquí (condición 3 del
encargo); las cinco quedan como materia del cierre.

### O1 — La pauta de validación llama «escaneados» a los cinco documentos OCR, y solo cuatro lo son

`20260826_pauta_validacion_convivencia_v1.md`, Bloque 1: «5 de los 25 documentos no
existían en formato de texto, solo como imagen escaneada». Medido contra el producto:

| Documento | `sin_capa_texto` | ¿Lo transcribió la herramienta? |
|---|---|---|
| `circular_193_estudiantes_embarazadas` | true | sí |
| `circular_586_tea` | true | sí |
| `circular_812_identidad_genero` | true | sí |
| `rex_482_reglamentos_b` | true | sí |
| `dictamen_078_detectores_revision_mochilas` | **false** | **no** |

El dictamen 078 **sí tiene capa de texto**; llegó a `ocr_pendiente_revision` por
declaración de curaduría, porque esa capa la produjo un reconocedor en el origen. Es
exactamente lo que `20260826_nota_cifra_ocr_v1.md` §2 documenta. La consecuencia práctica
para el equipo es menor (el trabajo de revisión es el mismo), pero la premisa es
incorrecta y el documento va a salir del Área hacia otro equipo.

**Por qué no se corrige aquí:** TF autoriza tocar la pauta solo para completar
`[ENLACE AL SITIO]` y para ajustar conteos de páginas si la condición 5 lo exigía (no lo
exigió), «sin tocar nada más del documento».

**Pregunta cerrada para el cierre:** ¿se ajusta esa frase del Bloque 1 antes de entregar la
pauta, o se entrega como está y se aclara de viva voz?

### O2 — TC va a activar un par prefijo/prefijado hoy inerte

`34_generar_paginas.R` lee `n$anio` (líneas 135, 199, 205, 726) y `n$fuente_anio`
(líneas 201, 203) con `$`. Hoy es seguro porque `construir_norma()` emite **siempre** las
dos claves, aunque valgan `null`, y la coincidencia exacta gana. Comprobado:

```r
n <- jsonlite::fromJSON("40_salidas/datos/normas/ley_19979_jornada_escolar_completa.json",
                        simplifyVector = FALSE)
"fuente_anio" %in% names(n)   # TRUE
is.null(n[["fuente_anio"]])   # TRUE  -> $ devuelve NULL correctamente
```

Y la simulación del caso malo:

```r
sim <- n[names(n) != "fuente_anio"]
sim$fuente_anios_alternativos <- "texto de procedencia"
sim$fuente_anio        # -> "texto de procedencia"   (!!)
sim[["fuente_anio"]]   # -> NULL
```

TC publica `fuente_anios_alternativos` en el JSON de norma, con lo que el par
`fuente_anio` / `fuente_anios_alternativos` queda vivo en el artefacto que
`34_generar_paginas.R` lee. Es el mismo mecanismo que causó la regresión de esta sesión.
Se registra aquí como hallazgo; la decisión de convertir esas lecturas se toma dentro de
TC y se declara en su log.

### O3 — `paginas` es prefijo de `paginas_pdf` y `paginas_vacias` en el manifiesto de OCR

Claves de `20_insumos/ocr/manifiesto_ocr.json`, nivel de documento: `caracteres`,
`hashes_paginas`, `md5_pdf`, `paginas`, `paginas_pdf`, `paginas_vacias`, `slug`. Hay **dos**
pares prefijo/prefijado. `00_ocr_documentos.R:327` lee `d$paginas != d$paginas_pdf`, pero
sobre la lista que el propio script construye (líneas 294-302), donde las tres claves
existen: la coincidencia exacta gana y **hoy no hay defecto**. `hashes_registrados()`
(líneas 76-78) sí lee del manifiesto de disco con `$`, pero sobre `documentos`, `slug` y
`hashes_paginas`, ninguna de las cuales tiene prefijo o prefijado.

Se menciona y no se corrige, por la regla de cambios quirúrgicos: TB está acotada a los
accesos a la **curaduría**.

### O4 — Dos imprecisiones menores en el rastreo de fuentes del glosario

Muestreo extra sobre `20260826_fuentes_glosario_v1.md`, no exigido por el encargo pero
barato de hacer con el instrumento ya montado. Lo sustantivo del documento se confirma:
«medida formativa» aparece en la circular 482 en las páginas **35, 37, 39 y 44**, las
cuatro que declara, y en la Ley 21.809 art-16-b; ningún contexto de los medidos es una
definición, que es lo que el documento concluye. Dos detalles no cuadran:

| Afirmación | Medido | Comentario |
|---|---|---|
| «protocolo de actuación»: **11 segmentos** de la circular 482 (tabla §2) | **12** segmentos contienen la expresión (20 ocurrencias) | El §3 matiza «once segmentos **los regulan**»; el candidato natural a exclusión es `ocr-pagina-038`, que no regula nada sino que cita un documento externo («Orientaciones para la elaboración de un protocolo de actuación», convivenciaescolar.cl). El criterio de exclusión no está declarado. |
| «la Ley 21.809 los menciona en el **artículo 46 letra f)**» | En la Ley 21.809 **no existe** un artículo 46: sus 47 segmentos no incluyen `art-46`, y el HTML publicado no tiene el ancla `#art-46` | El texto está en `art-44-bis`, que es el artículo **modificatorio**: dice «…agrégase en el artículo 46 el texto "políticas de prevención, medidas pedagógicas, protocolos de actuación…"». El artículo 46 es de la norma modificada, no de la 21.809. |

Ninguna toca el veredicto del documento («no hallada como definición legal»), que se
sostiene. La segunda sí importa para quien siga la referencia: un lector que busque
«artículo 46» en la página publicada de la Ley 21.809 no encuentra nada.

**Pregunta cerrada para el cierre:** ¿se corrige la referencia a `art-44-bis` (indicando
que inserta texto en el artículo 46 de la norma modificada) y se declara el criterio del
conteo de 11, o el documento queda como está por ser andamio interno?

### O5 — La compuerta de firma de piezas es derrotable por coincidencia parcial de nombres

Hallazgo del panel, reproducido por esta auditoría. Detalle completo en §5.3. En resumen:
`34_generar_paginas.R:359` decide si una pieza interpretativa está firmada con
`p$validado_por`, sobre un objeto que es el front matter YAML **crudo** de
`20_insumos/curaduria/piezas/`, sin esquema que normalice sus claves. Una pieza con
`estado: validada`, sin `validado_por` y con cualquier clave que lo tenga por prefijo, pasa
la compuerta y se publica como firmada.

Es el punto donde `CLAUDE.md` §10.5 dice que el pipeline **debe abortar**, y el mecanismo
es idéntico al que causó la regresión de esta sesión. **No está viva** (0 de 22 piezas sin
`validado_por`, 0 con clave prefijada, las 22 en `borrador`), pero la precondición
estructural sí lo está: 22 de 22 piezas omiten alguna clave de la unión del front matter.

**Por qué no se corrige aquí:** es un hallazgo nuevo de TA, y el invariante 🔒 del encargo
reserva TB y TC para defectos ya conocidos. Corregirlo dentro de esta cadena sería
exactamente la contaminación que la condición 3 prohíbe.

**Pregunta cerrada para el cierre:** ¿se convierten a `[[ ]]` los 17 accesos de clase A de
`34_generar_paginas.R` (la compuerta de firma y el resto de las lecturas de pieza) en una
tarea propia, o se difiere al traspaso v02 junto con los 86 de clase B?

## 12. Instrumentos y su calibración

| Instrumento | Caso malo plantado | ¿Disparó? | Caso bueno | ¿Calló? |
|---|---|---|---|---|
| Verificador de enlaces (§3) | enlace a archivo inexistente + ancla inexistente, en copia bajo `/tmp` | **sí**, los dos | árbol real | **sí**, 0 rotos |
| Barrido de accesos `$` (§5) | `curado$anio` y `.CUR$grupos_acto` en copia bajo `/tmp` | **sí**, 2 hits | árbol real | **sí**, 0 hits |
| Patrón de rótulos del REX 482 (§4) | rótulo inexistente `Resolución exenta 999 (...)` | — | HTML publicado | **sí**, 0 hits |
| Comando de páginas OCR (§9.2) | filtro `ocr_revisado` (nadie lo está) | — | filtro real | **sí**, `{0, null}` |

Los dos controles positivos que el encargo exige como calibración global —enlace falso y
`$` plantado— **dispararon los dos**.

Todas las copias temporales vivieron bajo `/tmp/slep_v3_scratch/`, fuera del repositorio.
Ningún archivo del repositorio se modificó desde ellas: `git status --porcelain` sobre
`20_insumos/` y `40_salidas/` quedó vacío durante toda la auditoría.
