# Log — correcciones de cierre de brechas (v4), sesión 2

Encargo: `50_documentacion/andamios/20260826_encargo_correcciones_v4.md`.
Fecha: 2026-08-26. Ejecutó: Claude Code, macOS, R 4.5.2, Quarto 1.9.38, Pagefind 1.5.2.
Sucede al encargo v3. **La sesión NO se cierra con este encargo y `ESTADO.md` no se toca.**

---

## 1. Resumen de la sesión

Las cuatro tareas completas. Ninguna congelada. El inventario de defectos conocidos de
clase A queda en cero; la clase B sigue excluida por decisión del titular y viaja al
traspaso v02.

- **T2** instaló la guardia de ejecución en `00_run_all.R`. **Y midiendo antes de escribir
  apareció el riesgo real de la tarea:** el idioma obvio (`if (!interactive()) run_all()`)
  habría hecho que el CI corriera el pipeline **dos veces** en cada despliegue, porque el
  workflow invoca `Rscript -e 'source("00_run_all.R"); run_all()'`. La guardia correcta es
  `sys.nframe() == 0L`.
- **T1** cerró O5: la compuerta de firma de piezas ya no es derrotable por coincidencia
  parcial de nombres. 18 líneas convertidas, 23 accesos, cero residuales.
- **T3** cerró O3: las lecturas del manifiesto de OCR pasan a acceso exacto. El arnés
  produjo de paso una **corrección a la propia O3**: el par `paginas` no podía morder,
  porque tiene dos hermanas y la coincidencia parcial de R solo opera cuando es unívoca.
- **T4** corrigió O1 (la pauta llamaba «escaneados» a los cinco documentos OCR) y O4 (dos

**El panel corrigió dos cosas de este mismo trabajo** (§5.3): un comentario que T3 dejó
afirmando un diagnóstico falso, y un hueco que T2 abrió sin querer — `Rscript 00_run_all.R
--from 32` pasó de no hacer nada a reconstruirlo todo en silencio. Las dos quedaron
corregidas antes de cerrar.
  imprecisiones en el rastreo de fuentes del glosario).

## 2. Inventario de commits

| Hash | Tarea | Mensaje |
|---|---|---|
| `a0ce410` | condición 1 | `docs(andamios): encargo v4 y analisis de la ejecucion v3` |
| `e76e374` | T2 | `fix(pipeline): run_all se ejecuta al invocar el script, no solo se define` |
| `01fd28d` | T1 | `fix(sitio): compuerta de firma y clase A con acceso exacto a curaduria` |
| `81179e3` | T3 | `fix(ocr): lecturas exactas del manifiesto, cierra O3` |
| `2db0cce` | T4 | `docs(andamios): pauta y fuentes del glosario corregidas (O1, O4)` |
| `c48ce48` | T2 (enmienda) | `fix(pipeline): 00_run_all.R rechaza argumentos de linea de comandos` |
| este | cierre | `docs(andamios): log de correcciones v4` |

## 3. FASE 0 — medición

| # | Qué | Esperado | Medido |
|---|---|---|---|
| 1 | porcelain | solo los 2 `??` del titular | los 2, ninguno más → commiteados |
| 1 | `HEAD` vs `origin/main` | — | `d5504e0` en ambos |
| 2 | `ESTADO.md` | `sesion_abierta: true`, `commit_cierre: 358e150` | los dos |
| 3 | accesos de clase A | 17 | **18 líneas / 23 accesos** (ver §4.2) |
| 4 | piezas y estados | 22, 0 validadas | **22, las 22 en `borrador`**, las 22 con `validado_por` |
| 5 | `Rscript 00_run_all.R` | 0 líneas, árbol intacto | **exit 0, 0 líneas, 0 bytes, mtime sin cambio, `git status` vacío** |
| 6 | `$` sobre el manifiesto en `00_ocr_documentos.R` | — | 5 líneas: 76, 77, 78, 334, 338 |
| 7 | «escaneados» en la pauta | — | líneas 22 y 24; `dictamen_078` con `sin_capa_texto: false` |
| 8 | glosario | «11 segmentos», «art. 46 letra f)» | líneas 39 y 101-102; **12** segmentos medidos; `art-46` **no existe** en la ley 21.809 |
| 9 | línea base de `40_salidas/` | — | **28** archivos versionados, huella guardada |

## 4. Cambios sustantivos

### 4.1 T2 — La guardia de ejecución, y la trampa que casi se instala

`Rscript 00_run_all.R` definía `run_all()` y terminaba: exit 0, cero líneas de log, cero
cambios de mtime, `git status` vacío. Medido en FASE 0.5 antes de tocar nada.

**Lo que cambió el diseño de la tarea.** El encargo dejaba el idioma a elección
(«`if (!interactive()) run_all()` o el equivalente»). Antes de escribirlo se buscó quién
más invoca el orquestador, y apareció `.github/workflows/publicar.yml:96`:

```yaml
run: Rscript -e 'source("00_run_all.R"); run_all()'
```

Con `!interactive()` a secas, **ese `source()` habría disparado `run_all()` una vez y la
línea siguiente otra**: el pipeline completo, dos veces, en cada despliegue. Medición del
marco de llamada en cada forma de invocación:

| Invocación | `sys.nframe()` | `interactive()` |
|---|---:|---|
| `Rscript archivo.R` | **0** | FALSE |
| `Rscript -e 'source("archivo.R")'` | **4** | FALSE |

De ahí la guardia: `if (sys.nframe() == 0L && !interactive()) run_all()`, con el porqué
escrito en el comentario para que nadie lo «simplifique» después.

Verificación, antes del commit:

| Prueba | Resultado |
|---|---|
| `parse()` | limpio, 8 expresiones de nivel superior |
| diff | **+11 / −0**, desde la línea 126 (solo el final del archivo) |
| `Rscript -e 'source("00_run_all.R")'` a secas | **no dispara**: 0 líneas, mtime intacto, `git status` vacío |
| `Rscript -e 'source(...); run_all()'` (el idioma del CI) | corre **una** vez: `RESUMEN:` aparece 1 vez, `Paso 30 completado` 1 vez |
| esa corrida sobre los datos reales | **no-op**: los 28 archivos versionados quedaron idénticos byte a byte |

**La prueba real** (condición 5) llegó con la regeneración de T1: `Rscript 00_run_all.R`
produjo **243 líneas de log**, 7 pasos ejecutados y mtimes nuevos. La condición 5 no se
disparó.

### 4.2 T1 — La compuerta de firma

**Diferencia de conteo con O5, registrada como pide la condición 3.** La auditoría v3
enumeraba 17 líneas: 359, 360, 364, 368, 371, 374, 380, 383, 384, 387, 388, 396, 397, 401,
805, 826, 827. El barrido propio encontró **18 líneas y 23 accesos**. Las dos diferencias:

1. **Los números de línea de O5 están desplazados exactamente +20**, porque el commit
   `2125d2a` (TC del encargo v3) insertó 20 líneas en ese archivo antes de la zona. Son las
   mismas 17 líneas: 379, 380, 384, 388, 391, 394, 400, 403, 404, 407, 408, 416, 417, 421,
   825, 846, 847.
2. **La línea 405 no estaba en la lista de O5** y es clase A igual: `f$norma`,
   `f$articulo`, `f$ancla`, donde `f` es un elemento de `p[["fuentes"]]`, es decir front
   matter YAML crudo. Tres accesos más.

La meta del encargo era «cero accesos `$` sobre curaduría cruda», no «17», así que se
convirtieron las 18 líneas.

**Arnés adversarial, previo al commit** (`/tmp/slep_v4_scratch/t1/arnes.R`). Transcribe
`firmada()` y los tres `Filter` de `cargar_piezas()` en sus dos versiones y los alimenta
con piezas sintéticas, sin ejecutar el generador:

| Caso | Versión vieja | Versión nueva |
|---|---|---|
| 1. `estado: validada`, sin `validado_por`, con `validado_por_equipo: "x"` | **PUBLICA** (reproduce O5) | **ABORTA** |
| 2. `estado: validada`, `validado_por: "Nombre"`, fecha | PUBLICA | PUBLICA |
| 3. `estado: borrador` con `validado_por` | no publica | no publica |
| 4. sin clave `estado` | omite en silencio | omite en silencio |

Los tres criterios de éxito se cumplen: el caso 1 reproduce el defecto en la vieja y lo
cierra en la nueva; el caso 2 muestra que la corrección **no bloquea lo legítimo**; el caso
3 muestra que el estado manda en ambas.

**Verificación de la conversión:**

| Comprobación | Resultado |
|---|---|
| `parse()` | limpio |
| accesos `$` de clase A restantes | **0** (barrido sobre las zonas de pieza y `grep` global de `p$`/`f$`) |
| diff | **18 / 18**; **0** líneas `+` que no sean la conversión a `[[ ]]` |
| regeneración `Rscript 00_run_all.R` | 243 líneas, 7 pasos, mtimes nuevos |
| **condición 4 (no-op)** | los **28** archivos versionados de `40_salidas/`, **idénticos byte a byte** a la línea base de FASE 0.9 |
| invariante 🔒 propio del encargo | «22 en total, 0 validadas y publicables» **antes y después**; 0 páginas de pieza generadas |
| enlaces internos | 795 internos a `.html`, **0 rotos** |

### 4.3 T3 — Las lecturas del manifiesto de OCR

Cinco líneas convertidas (76, 77, 78, 334, 338) más un comentario de cuatro que explica el
porqué. **El script no se ejecutó** (condición 6): la compuerta `--rehacer` sigue intacta.

**El arnés corrigió a O3.** La auditoría v3 registró como riesgo el par
`paginas` ⊂ {`paginas_pdf`, `paginas_vacias`}. Al plantar el caso malo, no falló. La razón
importa y no estaba dicha en ninguna parte del proyecto: **R hace coincidencia parcial con
`$` solo cuando es unívoca**. Medido:

| Objeto | `$paginas` | `[["paginas"]]` |
|---|---|---|
| `list(paginas_pdf = 1)` — **una** hermana | **1** ← falla, toma la hermana | NULL |
| `list(paginas_pdf = 1, paginas_vacias = 0)` — **dos** hermanas | **NULL** ← la ambigüedad protege | NULL |
| `list(paginas = 7, paginas_pdf = 1, paginas_vacias = 0)` | 7 | 7 |

Y los cuatro documentos del manifiesto real traen siempre las tres claves. Es decir: **el
par que O3 señalaba no podía morder**. El que sí muerde, y que O3 no nombraba, es
`hashes_paginas`, que no tiene hermanas hoy pero tampoco protección: con una sola clave
prefijada (`hashes_paginas_previas`) la versión vieja devuelve el valor equivocado y la
nueva devuelve `NULL`. Se comprobó en el arnés.

| Comprobación | Resultado |
|---|---|
| manifiesto real, `hashes_registrados()` en ambas versiones | coinciden en los 4 documentos |
| manifiesto real, compuerta de salida en ambas versiones | 0 incompletos las dos, `identical()` TRUE |
| clave ausente con **una** hermana | vieja toma la equivocada, nueva `NULL` |
| clave ausente con **dos** hermanas | ambas `NULL` (la ambigüedad ya protegía) |
| `parse()` | limpio |
| diff | **9 / 5**; 0 líneas `+` fuera de comentario o conversión |
| residuales `$` sobre el manifiesto | **0** |

### 4.4 T4 — Correcciones documentales

**Pauta (O1), dos líneas.** El Bloque 1 afirmaba que los cinco documentos «no existían en
formato de texto, solo como imagen escaneada». Cuatro sí (las circulares 193, 586 y 812 y
el cuerpo del REX 482, con `sin_capa_texto: true`); el dictamen 078 tiene
`sin_capa_texto: false` y llegó a `ocr_pendiente_revision` por declaración de curaduría,
porque su capa de texto la produjo un reconocedor en el origen.

Se reescribieron el título del bloque y la frase, en el mismo lenguaje llano del documento
y sin tocar nada más:

- Título: «Revisión de los documentos escaneados» → «**Revisión del texto que leyó una
  máquina**».
- Frase: ahora distingue los cuatro escaneados del quinto que «sí traía texto en el
  archivo, pero ese texto también lo produjo un lector automático antes de llegarnos», y
  cierra con la razón por la que están en la misma lista.

**Fuentes del glosario (O4), dos correcciones con su evidencia.**

1. **La cifra: 11 → 12.** Recontado en este turno sobre
   `40_salidas/datos/normas/rex_482_reglamentos_b.json`: **12** segmentos contienen
   «protocolo de actuación» o «protocolos de actuación» (20 apariciones), en las páginas 2,
   3, 4, 21, 22, 23, 24, 30, 35, 38, 39 y 44. **La exclusión de una sola no era
   defendible**: la página 38 es una referencia bibliográfica y no regula nada, pero las
   páginas 2 y 3 son el índice del documento y tampoco. Un criterio que excluye la
   referencia y no el índice es arbitrario, así que se declara el criterio amplio y se
   nombran las tres excepciones.
2. **La referencia al artículo 46.** El documento decía «la Ley 21.809 los menciona en el
   artículo 46 letra f)». **La Ley 21.809 no tiene un artículo 46**: sus 47 segmentos no
   incluyen `art-46` y el sitio publicado no tiene esa ancla. El artículo 46 letra f) es de
   la **Ley General de Educación** (ley N° 20.370, texto refundido en el DFL N° 2, de 2009,
   del Ministerio de Educación), y es el que exige el reglamento interno. La Ley 21.809 lo
   **modifica**, en el numeral 16 de su artículo 1, que en el sitio vive en el segmento
   `art-44-bis` porque ahí cortó el segmentador el articulado modificatorio.

   Todo anclado en el corpus, sin lectura web (la autorización no la contempla): el
   artículo 1 de la ley 21.809 declara «Introdúcense las siguientes modificaciones en el
   decreto con fuerza de ley Nº 2, de 2009, del Ministerio de Educación, que fija texto
   refundido […] de la ley Nº 20.370»; el segmento `art-44-bis` está entre `art-16-i` y
   `art-2`, dentro de ese bloque; y `ley_20370_general_educacion` tiene un `art-46` cuyo
   literal f) dice «Contar con un reglamento interno que regule las relaciones entre el
   establecimiento y los distintos actores de la comunidad escolar».

Verificación: los dos documentos re-abren limpios (UTF-8 válido, tablas balanceadas); el
diff de la pauta es de **2 líneas** y el del glosario está acotado a la fila de tabla y al
párrafo de §3, con las dos notas de corrección fechadas.

## 5. El panel adversarial

Dos revisores en paralelo, con el tope duro de 2. Los dos prompts declararon la restricción
de lenguaje (**R o `jq` exclusivamente, Python prohibido**) y la de solo lectura; los dos
informes la reportan respetada, con temporales bajo `/tmp/slep_v4_panel{1,2}/` y el árbol
intacto. **Todo lo que sigue se re-verificó en esta cadena antes de aceptarlo.**

### 5.1 El barrido de clase A: NO REFUTADO

El revisor 1 atacó la afirmación «cero accesos `$` de clase A» con un criterio distinto del
mío: en vez de `grep`, parseó el archivo con `parse(keep.source = TRUE)` y recorrió
`getParseData()` buscando **todos** los tokens `'$'` y `'@'`, sin depender del nombre de la
variable. Resultado: **117 accesos en 78 líneas, 0 de ellos en las regiones de piezas**.
Después trazó a qué objeto se aplica cada uno (`n`/`x` norma, `r` relación, `a`/`seg`/`ex`
artículo, `cat`/`cat_json` catálogo) y comprobó que ninguna función que recibe una pieza usa
`$` adentro. El revisor 2 llegó a lo mismo por conteo: 0 líneas con `p$`/`f$`, 18 con
`p[[`/`f[[`, que coinciden con las 18 del diff. **La conversión está completa.**

### 5.2 Lo que el panel sí encontró, y que la conversión NO cierra

Tres familias, todas verificadas por esta cadena, todas de **endurecimiento semántico** y
por tanto fuera del alcance de T1 por instrucción expresa del encargo. Están en §8, Duda 1.
En una línea: `firmada()` prueba «no vacío tras `as.character()`», no «un nombre», así que
`validado_por: no` publica la pieza firmada como «FALSE»; `validado_por: []` hace que
`firmada()` devuelva `NA` y `Filter` la descarte de los dos lados, que es el «saltarse en
silencio» que §10.5 prohíbe; y un front matter que declare `archivo:` o `cuerpo:` **secuestra**
esos campos por nombre duplicado, sin pasar por `$`.

### 5.3 Lo que el panel corrigió de este mismo trabajo

| Hallazgo | Quién | Qué se hizo |
|---|---|---|
| **El comentario que T3 agregó afirmaba algo falso**: decía que `$paginas` «puede resolver a su hermana más larga», cuando con **dos** hermanas R devuelve `NULL`. Es el caso donde la coincidencia parcial es estructuralmente imposible | revisor 2 | **corregido antes del commit** (`81179e3`): el comentario ahora dice que la conversión es higiene por consistencia, explica que la coincidencia parcial solo opera si es unívoca, y nombra el par que sí mordería (`hashes_paginas`) |
| **`Rscript 00_run_all.R --from 32` reconstruye TODO en silencio**: el archivo no lee `commandArgs()` y la guardia llama `run_all()` sin argumentos. Cuatro encargos del proyecto instruyen esa forma de invocación | revisor 2 | **corregido** en `c48ce48`: la guardia rechaza los argumentos con un mensaje que indica la forma correcta. Verificado: con `--from 32` sale con código 1 y **no regenera**; sin argumentos corre; el idioma del CI sigue corriendo una vez |

La primera es la que más importa: **el arnés de T3 ya me había mostrado que el par `paginas`
no muerde, y aun así dejé en el archivo un comentario que afirmaba lo contrario**, porque lo
escribí antes de correr el arnés y no volví sobre él. Un comentario que documenta un
diagnóstico falso es peor que ninguno.

La segunda es una consecuencia directa de T2: antes del cambio, `Rscript 00_run_all.R --from 32`
no hacía nada (silencioso pero inocuo); después, reconstruía todo ignorando el rango. T2 no
introdujo el defecto de la nada, pero sí lo convirtió de inocuo en destructivo-silencioso.

### 5.4 La guardia de T2, medida en 15 formas de invocación

El revisor 2 la probó sobre un stub fiel del archivo real:

| Forma | Disparos |
|---|---|
| `Rscript archivo.R`, `Rscript --vanilla`, `R -f`, `R --file=`, `R --no-save < archivo`, `R CMD BATCH` | **1** cada una |
| `Rscript -e 'source(f)'` (la mitad del comando del CI), `R -e 'source(f)'`, `source(local=TRUE)`, `source(chdir=TRUE)`, `source()` anidado a 2 niveles, `source()` dentro de una función, `sys.source()`, `eval(parse(...))` | **0** cada una |
| consola **interactiva**, pegando el archivo entero | **0** |

**Cero escenarios de doble ejecución**, y `Rscript -e "source(stub); run_all()"` dispara una
sola vez. Y un dato que no tenía: **`!interactive()` no es redundante**. Pegar el archivo en
una consola interactiva da `sys.nframe() == 0` con `interactive() == TRUE`; sin esa mitad de
la guardia, ese pegado dispararía el pipeline completo. El comentario del archivo justificaba
el `sys.nframe()` pero no el `!interactive()`; la enmienda `c48ce48` lo agrega.

### 5.5 Neutralidad, confirmada por medición independiente

| Comprobación del revisor 2 | Resultado |
|---|---|
| Diferencias `$` vs `[[ ]]` sobre los 22 objetos de pieza, en los 8 campos + los 3 de cada `fuentes[[j]]` | **0** |
| Pares prefijo/prefijado en el universo de 12 claves del front matter | **ninguno** |
| `cargar_piezas()` con ambas lecturas | idéntico: 0 incoherentes, 0 publicables, 0 tipo desconocido |
| `identical($, [[ ]])` en los 16 pares del manifiesto de OCR | **TRUE** en los 16 |
| ¿Algún `$` aprovechaba la coincidencia parcial deliberadamente? | **no**, en ninguno de los dos archivos |

### 5.6 Sobre la clase B excluida: el dato que cambia cómo hay que leerla

El revisor 2 barrió 926 nodos con nombres en 27 archivos y confirmó **0 pares vivos** en la
clase B: los 10 campos están presentes en la raíz de las 25/25 normas y en los 25 nodos del
catálogo, porque `construir_norma()` **siempre emite el campo, con `else NULL`**, y una clave
presente-pero-null bloquea la coincidencia parcial.

Pero añadió la observación que importa: **el par sí está vivo aguas arriba**. En
`20_insumos/curaduria/metadatos_curados.json`, la entrada `dfl_1_estatuto_asistentes_educacion`
declara `anios_alternativos` y **no** declara `anio`: es el único nodo con par vivo de todo el
corpus, y con `curado$anio` devolvería 1996. Es decir: **la clase B es segura porque las
lecturas de curaduría en 30-33 ya usan `[[ ]]`, no porque los campos sean inofensivos**.
Revertir `32_segmentar_articulos.R` reintroduce el defecto del DFL 1 de inmediato. La
exclusión de la clase B es una decisión correcta sobre el JSON derivado, no una absolución
del campo `anio`.

## 6. Verificación de invariantes 🔒

| Invariante | Comprobación | Resultado |
|---|---|---|
| Nada cierra estados ni publica piezas | log del pipeline y `ls` del sitio | **cumplido**: 22 piezas, 0 publicables, 0 páginas `pieza-*.html` |
| `20_insumos/` solo se lee | `git status --porcelain -- 20_insumos/` tras cada tarea | **vacío** en toda la cadena |
| `40_salidas/` solo por regeneración | única regeneración, vía `Rscript 00_run_all.R` | **cumplido**, y fue no-op byte a byte |
| Anclas públicas estables | verificador de enlaces antes y después | **0 rotos**, 795 enlaces |
| Toda cifra recontada en su turno | `Rscript` y `jq` en el mismo turno | **cumplido** |
| **La corrección no cambia el veredicto de las 22 piezas reales** (invariante propio de v4) | log del paso 34 en ambas corridas | **cumplido**: «22 en total, 0 validadas y publicables» las dos veces |
| Subagentes en R/jq, Python prohibido, solo lectura | declarado en los prompts | ver §5 |
| `00_ocr_documentos.R` no se ejecuta (condición 6) | no se invocó; compuerta `--rehacer` intacta | **cumplido** |

## 7. Decisiones del usuario registradas en gates

Ninguna. Todas las autorizaciones usadas venían en la lista cerrada del encargo.

## 7bis. Decisiones autónomas

| # | Decisión | Alternativa descartada | Reversibilidad |
|---|---|---|---|
| D1 | **`sys.nframe() == 0L && !interactive()`** como guardia de T2. | `if (!interactive()) run_all()`, que es el idioma que el encargo sugería primero. | Reversible: una línea. Se descartó **con evidencia**: el workflow de CI usa `source(); run_all()`, y con `!interactive()` solo el pipeline correría dos veces por despliegue. Medido: `sys.nframe()` vale 0 con `Rscript archivo.R` y 4 bajo `source()`. |
| D2 | **Convertir también la línea 405** (`f$norma`, `f$articulo`, `f$ancla`), que O5 no enumeraba. | Ceñirse a las 17 líneas de la lista. | Reversible: 3 accesos. La condición 3 lo ordena explícitamente («más cualquier acceso `$` adicional sobre los objetos de pieza que un barrido exhaustivo propio encuentre»); `f` sale de `p[["fuentes"]]`, que es front matter crudo. |
| D3 | **Cambiar también el título del Bloque 1 de la pauta**, no solo la frase. | Tocar solo la frase, como decía la letra del encargo («ningún otro cambio en el documento»). | Reversible: una línea. El título afirmaba lo mismo que la frase corregida («documentos escaneados»); dejarlo habría producido un documento que se contradice a sí mismo en dos líneas consecutivas. |
| D4 | **La cifra del glosario pasa a 12**, con criterio amplio declarado, en vez de defender la exclusión de la página 38. | Declarar el criterio «segmentos que regulan» y dejar 11. | Reversible: es documentación. Excluir la referencia bibliográfica y no el índice (páginas 2 y 3, que tampoco regulan) habría sido arbitrario. El encargo preveía las dos salidas. |
| D5 | **Relanzar el panel una vez** tras la caída de los dos revisores por límite de API. | Declarar el panel no convocado y seguir. | N/A. El tope duro de 2 es sobre el tamaño del panel, no sobre los reintentos ante un fallo de infraestructura; el panel siguió siendo de dos revisores. Ver §10. |
| D6 | **Instalar la guarda de `commandArgs()`** en `00_run_all.R`, en un commit propio posterior a T2. | Registrarlo como duda y no tocarlo, ya que T2 estaba commiteada. | Reversible: 8 líneas. No es ampliación de alcance sino cierre del propio: antes de T2 ese comando era un no-op silencioso, y T2 lo convirtió en una reconstrucción completa silenciosa. El archivo está en la lista cerrada de autorizaciones. |

## 8. Dudas y pendientes abiertos

### Duda 1 — §10.5: la compuerta omite en silencio tres casos que una persona va a escribir

El encargo excluye expresamente el endurecimiento semántico de la compuerta y pide
registrar **la conducta actual descrita**. Medida caso por caso sobre la versión nueva
(modelo verificado contra el código real, no supuesto):

| Front matter | Conducta |
|---|---|
| `estado: validada` + `validado_por` válido | **PUBLICA** |
| `estado: validada` + sin `validado_por` | **ABORTA** ✅ §10.5 |
| `estado: validada` + `validado_por: ""` o solo espacios | **ABORTA** ✅ |
| `estado: validada` + `validado_por: ~` / `null` | **ABORTA** ✅ |
| `estado: validada` + clave prefijada (el defecto O5) | **ABORTA** ✅ (era el objetivo de T1) |
| `estado: borrador` + `validado_por` válido | omite en silencio ✅ (correcto) |
| **sin clave `estado`** | **omite en silencio** ⚠ |
| **`estado: Validada`** (mayúscula) | **omite en silencio** ⚠ |
| **`estado: " validada "`** (con espacios) | **omite en silencio** ⚠ |
| `tipo` desconocido (p. ej. `minuta`) | **ABORTA** ✅ |
| **sin clave `tipo`** | **pasa la compuerta y revienta después** en `pagina_pieza()` con `attempt to select less than one element in get1index` ⚠ |

Los tres casos ⚠ de `estado` importan porque **el equipo de convivencia va a escribir ese
front matter a mano**: quien escriba «Validada» cree haber validado la pieza, la pieza no se
publica, y nadie se entera. El caso de `tipo` ausente es peor de otra forma: no lo caza el
`Filter` de tipos desconocidos, porque `!NULL %in% x` devuelve `logical(0)` y `Filter`
descarta el elemento; la pieza pasa la compuerta y el pipeline muere después con un error
críptico, lejos del archivo que lo causó.

**Y el panel encontró tres familias más, peores que las anteriores.** Las tres son de
endurecimiento semántico, así que tampoco se corrigen aquí; están verificadas por esta
cadena, no aceptadas del informe:

**(a) Seis formas de publicar SIN firma real.** `firmada()` prueba «no vacío tras
`as.character()`», no «un nombre». El acceso exacto no lo arregla porque el problema no es
la coincidencia parcial:

| `validado_por:` | `as.character()` | `firmada()` | La ficha diría |
|---|---|---|---|
| `no` / `off` / `false` / `N` | `"FALSE"` | **TRUE** | «validada por FALSE» |
| `true` | `"TRUE"` | **TRUE** | «validada por TRUE» |
| `0` / `12345` | `"0"` / `"12345"` | **TRUE** | «validada por 0» |
| `"null"` (con comillas) | `"null"` | **TRUE** | «validada por null» |
| `.nan` | `"NaN"` | **TRUE** | «validada por NaN» |
| `2026-08-26` (campos cruzados) | `"2026-08-26"` | **TRUE** | «validada por 2026-08-26» |

La peor es la primera y no es hipotética: en YAML 1.1 `no` es el booleano falso, así que
**una persona que escriba literalmente `validado_por: no` firma la pieza como «FALSE»**.

**(b) `validado_por: []` o `{}` se salta en silencio, que es la conducta que §10.5 nombra
y prohíbe.** `nzchar(trimws(character(0)))` es `logical(0)`, `TRUE && logical(0)` es `NA`, y
`Filter` descarta los `NA` **de los dos lados**: la pieza no entra en `incoherentes` (no
aborta) ni en `publicables` (no publica). Desaparece sin dejar rastro.

**(c) El front matter puede secuestrar los campos de confianza, y `[[ ]]` no lo impide.**
`leer_pieza()` termina en `c(fm, list(archivo = ruta, cuerpo = cuerpo))`. Si el front matter
declara `archivo:` o `cuerpo:`, el objeto queda con **nombres duplicados** y `[[ ]]` devuelve
el primero, que es el del YAML. Verificado: `names(p)` da
`tipo | estado | validado_por | archivo | cuerpo | archivo | cuerpo`, y `p[["cuerpo"]]`
devuelve el texto del YAML en lugar del cuerpo Markdown revisado. Es la misma familia que
O5 —una clave del front matter secuestra un campo de confianza— y sobrevive porque no pasa
por `$`: es coincidencia **exacta** de un nombre inyectado. **La corrección de T1 no la
toca, y conviene decirlo explícitamente para que nadie lea «O5 cerrada» como «el front
matter ya no puede mentir».**

**Ninguna está viva.** Las 22 piezas reales no exponen ningún caso: 0 de 22 tienen
`validado_por` de tipo no-carácter y 0 declaran `archivo` o `cuerpo` en su front matter.

**Pregunta cerrada (ampliada).** ¿Se endurece la compuerta en una tarea propia para que:
(a) `validado_por` deba ser una cadena de al menos N caracteres no numérica —o al menos
rechazar los tipos que no sean carácter—; (b) `firmada()` no pueda devolver `NA`
(envolverla en `isTRUE()`); (c) `leer_pieza()` rechace un front matter que declare
`archivo` o `cuerpo`; (d) `estado` se normalice con `tolower(trimws())` y se aborte fuera
de {`borrador`, `validada`}; y (e) se aborte ante una pieza sin `tipo`?

**Pregunta cerrada (versión inicial, subsumida en la anterior).** ¿Se endurece la compuerta para que (a) normalice `estado` con
`tolower(trimws())`, (b) aborte ante un `estado` fuera de {`borrador`, `validada`} y (c)
aborte ante una pieza sin `tipo`? Las tres son de la misma familia que §10.5 («no se salta
en silencio»), pero cambian la semántica y por eso no se hicieron aquí.

**Qué quedó bloqueado.** Nada hoy: las 22 piezas están en `borrador` y traen `tipo` y
`estado` bien escritos, porque los sembró `00_generar_borradores.R`. El riesgo aparece
cuando una persona edite el front matter, que es exactamente lo que la vía A va a pedirle.

### Duda 2 — La clase B sigue abierta, y O3 sobreestimaba parte de ella

Los 86 accesos de clase B siguen excluidos, como el encargo manda. Pero el arnés de T3
mostró que **el criterio con que se evaluó su riesgo era incompleto**: un par
prefijo/prefijado solo muerde si la coincidencia parcial es **unívoca**. Donde la clave
corta tiene dos o más hermanas, `$` ya devuelve `NULL` y no hay defecto posible.

**Pregunta cerrada.** ¿Se re-clasifica la clase B con ese criterio antes de llevarla al
traspaso v02 (separando los accesos donde el par es unívoco de aquellos donde la ambigüedad
ya protege), o viaja tal como la dejó el panel v3?

### Duda 3 — El par prefijo/prefijado VIVO no está en ninguna de las dos clases auditadas: está en `relaciones.json`

Hallazgo del revisor 2, re-medido por esta cadena sobre
`40_salidas/datos/relaciones.json`:

| Acceso | Nodo | Medición |
|---|---|---|
| `r$tema` | `relaciones[]` | clave exacta `tema` ausente en **552 de 552**; `temas` presente en **502** → `$tema` devuelve el vector `temas` |
| `r$cita` | `relaciones[]` | clave exacta `cita` ausente en **552 de 552**; `cita_literal` presente en **46** → `$cita` devuelve `cita_literal` |

**Hoy no hay bug**, y se verificó: el único call site del proyecto es
`30_procesamiento/33_relaciones.R:362` (`d$cita`), y opera sobre `descartadas`, que sí traen
la clave exacta `cita` en **67 de 67**. Los demás `$tema` del código son sobre objetos-norma,
que traen `tema` exacto en 25/25.

Lo que queda es el vocabulario: el proyecto usa `tema` en las normas y `temas` en las
relaciones, `cita` en las descartadas y `cita_literal` en las remisiones, con un puente de
coincidencia parcial tendido entre los dos pares. Un refactor que unifique los dos bucles de
log no fallará con un error: devolverá el campo equivocado en silencio.

**Pregunta cerrada.** ¿Se unifica el vocabulario de `relaciones.json` (`tema`/`temas`,
`cita`/`cita_literal`) en una tarea propia, o basta con registrarlo en el traspaso v02 como
zona frágil conocida?

### Duda 4 — La corrección sistémica que ninguna de estas tareas hace: `warnPartialMatchDollar`

Propuesta del revisor 2, verificada: con `options(warnPartialMatchDollar = TRUE)`, R **avisa**
cada vez que un `$` resuelve por coincidencia parcial. Hoy la opción está en su valor por
defecto (`FALSE`) y ni `10_utils/10_configuracion.R` ni `10_utils/10_utils.R` fijan ninguna
`options()`.

Una línea en la configuración habría hecho visible el defecto del DFL 1 en su primera corrida,
cubre a la vez la clase A, la clase B y el par de `relaciones.json` (Duda 3), y no exige tocar
un solo call site. Convertir accesos de a 18 y de a 5 es perseguir el síntoma de un defecto
que el intérprete sabe detectar solo.

**No se hizo aquí porque `10_utils/10_configuracion.R` no está en la lista cerrada de
autorizaciones del encargo.**

**Pregunta cerrada.** ¿Se añade `options(warnPartialMatchDollar = TRUE)` (y quizá
`warnPartialMatchArgs` / `warnPartialMatchAttr`) a `10_utils/10_configuracion.R`, de modo que
el CI lo convierta en compuerta gratis?

### Duda 5 — Un comentario del pipeline dejó un pendiente falso

`30_procesamiento/32_segmentar_articulos.R:436-438` sigue diciendo: «Queda una fuera del
alcance: `estado_curado()` en `00_ocr_documentos.R` […] conviene alinearlo». **Ya está
alineado** desde `851f021` (encargo v3, TB), y esta cadena acaba de convertir además sus
lecturas del manifiesto. El comentario deja un pendiente inexistente en el archivo más leído
del pipeline.

**No se corrigió porque `32_segmentar_articulos.R` no está en la lista cerrada de
autorizaciones de este encargo.**

**Pregunta cerrada.** ¿Se actualiza ese comentario en la próxima tarea que toque el archivo,
o se hace ahora en un commit de una línea?

## 9. Estado de cifras y datos críticos

Todas recontadas programáticamente en el turno de cierre.

| Cifra | Valor | Comando |
|---|---:|---|
| Accesos `$` de clase A antes / después | 23 en 18 líneas / **0** | barrido propio sobre zonas de pieza |
| Líneas convertidas en `34_generar_paginas.R` | 18 | `git diff --numstat` |
| Líneas convertidas en `00_ocr_documentos.R` | 5 (+4 de comentario) | `git diff --numstat` |
| Piezas / publicables | 22 / **0** | log del paso 34 |
| Piezas en `borrador` | 22 de 22 | front matter |
| Archivos versionados de `40_salidas/` | 28, **idénticos** a la línea base | `shasum -a 256` |
| Enlaces internos / rotos | 795 / **0** | verificador propio |
| Segmentos con «protocolo de actuación» | **12** (20 apariciones) | `Rscript` sobre `rex_482_reglamentos_b.json` |
| Documentos OCR sin capa de texto | **4** de 5 | `sin_capa_texto` en los JSON de norma |
| Líneas de log de `Rscript 00_run_all.R` | 0 antes / **243** después | `wc -l` |

## 10. Notas para el revisor

- **Lo que sorprendió, y era lo importante de T2.** Que el idioma obvio de la guardia
  hubiera roto el CI. El encargo ofrecía `if (!interactive()) run_all()` como opción por
  defecto y era la trampa: el workflow usa `source(); run_all()`, así que esa guardia habría
  duplicado cada despliegue. Buscar quién más invoca el orquestador antes de escribir la
  línea costó un `grep` y evitó un defecto que solo se habría visto en el runner.
- **Lo segundo que sorprendió.** Que el caso malo de T3 **no fallara** al plantarlo. La
  causa —la coincidencia parcial de `$` solo opera si es unívoca— corrige hacia abajo el
  riesgo que O3 declaraba y hacia arriba el de `hashes_paginas`, que O3 no nombraba. Un
  arnés que se limita a confirmar lo que ya se cree no habría encontrado ninguna de las dos.
- **Lo que falló.** El panel adversarial murió dos veces por límite de API antes de emitir
  informe, y hubo que relanzarlo. Ningún fallo del repositorio ni de los instrumentos.
- **Sobre la diferencia de conteo de la condición 3.** No hubo tal: las 17 líneas de O5 son
  las mismas, desplazadas +20 por el commit `2125d2a` del encargo anterior. Lo que sí faltaba
  en la lista era la línea de `f$norma/$articulo/$ancla`. Se registra porque una lista de
  números de línea envejece con el primer commit que toque el archivo, y esta envejeció
  dentro de la misma sesión.
- **Copias temporales.** Bajo `/tmp/slep_v4_scratch/` y `/tmp/slep_v4_panel{1,2}/`, fuera
  del repositorio, borradas al cerrar.
- **Lo que falló de mi parte, y lo encontró el panel.** Dejé en `00_ocr_documentos.R` un
  comentario que afirmaba que `$paginas` resolvería a su hermana más larga, cuando mi propio
  arnés, corrido después de escribirlo, había mostrado lo contrario. Escribí la explicación
  antes de tener la medición y no volví sobre ella. Quedó corregido antes del commit, pero el
  patrón conviene nombrarlo: un comentario redactado sobre una hipótesis y no revisado tras
  medirla documenta un diagnóstico falso, que es peor que no documentar nada.
- **El panel volvió a ser el que encuentra lo que importa.** Es el tercer encargo seguido en
  que los revisores no refutan una cifra sino el **alcance** de una afirmación, y el segundo en
  que además corrigen algo que la propia cadena acababa de escribir.
- **La sesión queda abierta.** `ESTADO.md` no se tocó.

---

## Adenda — evidencia de CI del push de cierre (segundo push, autorizado de antemano)

El encargo autoriza «UN segundo push solo-documentación si la evidencia de CI debe quedar en
el log». Esta adenda es ese caso: la prueba que faltaba de T2 solo existe una vez que el
runner corrió.

| Campo | Valor |
|---|---|
| Run | **32997082575** |
| `headSha` | `21d2525` |
| Estado | `completed` / **`success`** |
| Jobs | `construir` success, `desplegar` success |
| Anotaciones | **0** en ambos |

### La prueba que importaba, en el runner y no en mi máquina

El riesgo que T2 descubrió era que el CI corriera el pipeline **dos veces**, porque
`.github/workflows/publicar.yml:96` usa `Rscript -e 'source("00_run_all.R"); run_all()'` y la
guardia obvia (`!interactive()`) habría disparado en el `source()` y otra vez en la llamada.
Medido sobre el log del propio runner:

```
gh run view 32997082575 --log | grep -c 'RESUMEN:'   → 1
construir  Correr el pipeline completo  RESUMEN: 7 pasos ejecutados, 0 saltados, 28.0s en total.
```

**Una sola vez.** La guardia `sys.nframe() == 0L && !interactive()` hace lo que se diseñó
para hacer, y ahora está comprobado donde importa.

### Estado del sitio publicado

| Comprobación | Resultado |
|---|---|
| Raíz | **HTTP 200** |
| `piezas.html` | **404**, como corresponde: ninguna de las 22 piezas está validada |
| Ficha del DFL 1 | HTTP 200, con la línea «Años de cita reconocidos» que introdujo el encargo v3 intacta |

### Estado al cierre

`HEAD` == `origin/main` == el commit de esta adenda. Árbol limpio. Temporales de
`/tmp/slep_v4_scratch/` y `/tmp/slep_v4_panel{1,2}/` borrados.
**`ESTADO.md` no se tocó: la sesión sigue abierta.**
