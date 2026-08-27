# Re-clasificación de la clase B por univocidad (v1)

> Producto de T3 del encargo `20260826_encargo_endurecimiento_v5.md`, sesión 2.
> **Reemplaza a la clasificación de clase B de `20260826_auditoria_contra_producto_v1.md`
> §5.2 como insumo del traspaso v02.** Solo lectura: no se tocó ningún archivo de código
> para producirlo.
>
> Cierra la Duda 2 del log v4 (`20260826_correcciones_v4_log.md` §8), que pedía separar
> los accesos donde el par prefijo/prefijado es unívoco de aquellos donde la ambigüedad
> ya protege, antes de llevar la lista al traspaso.

## 1. Re-anclaje: qué contaba v3 y qué cuenta esto

La auditoría v3 declaró **86** de clase B (campos de origen curatorial que llegan por el
JSON de norma o el catálogo) en seis archivos. No enumeraba posiciones: daba totales por
clave y por archivo. Re-anclarla exigía primero averiguar **en qué unidad contaba**, y la
respuesta está en su propia tabla: la columna se titula «**Líneas**». v3 contaba líneas;
este documento cuenta **accesos**, que es la unidad en la que ocurre el defecto (una línea
con `if (is.null(n$anio)) ... else n$anio` es una línea y dos accesos).

Medido en las dos unidades, sobre el árbol de la auditoría (`7cc6fb6`) y sobre el de hoy,
con el criterio de v3 (las mismas nueve claves, los mismos seis archivos, excluidos los
objetos de pieza que son clase A):

| Archivo | v3 declaró | Líneas en `7cc6fb6` | Líneas hoy | Accesos hoy |
|---|---:|---:|---:|---:|
| `30_procesamiento/34_generar_paginas.R` | 41 | **37** | 33 | 39 |
| `30_procesamiento/33_relaciones.R` | 20 | 20 ✓ | 20 | 23 |
| `30_procesamiento/32_segmentar_articulos.R` | 15 | 15 ✓ | 15 | 17 |
| `00_generar_borradores.R` | 7 | 7 ✓ | 7 | 9 |
| `10_utils/10_utils.R` | 2 | 2 ✓ | 2 | 2 |
| `30_procesamiento/31_extraer_texto.R` | 1 | 1 ✓ | 1 | 1 |
| **Total** | **86** | **82** | **78** | **91** |

**Cinco de los seis archivos reproducen la cifra de v3 exactamente**, lo que confirma la
unidad. El sexto no: v3 declara 41 líneas en `34_generar_paginas.R` donde la re-medición
sobre su propio árbol da 37. Esas 4 líneas no se reconstruyen desde el documento de v3,
que no las enumera, y quedan registradas como diferencia sin explicar antes que
racionalizadas.

**Entre `7cc6fb6` y hoy, el único archivo que se movió es `34_generar_paginas.R`** (37 → 33
líneas): es el que T1 del encargo v4 convirtió a acceso exacto. Los otros cinco están
idénticos línea por línea. También desaparecieron los 2 accesos `$fuente_anio`, convertidos
con las lecturas de curaduría.

Método del barrido: **árbol de parseo** de R (`utils::getParseData()`), no expresión
regular. El regex cuenta los `$` que viven dentro de comentarios (hay uno, `curado$anio` en
`32_segmentar_articulos.R`) y no recupera el objeto sobre el que se aplica el operador, que
es justo lo que hace falta para saber qué esquema se lee. Nota de método:
`getParseData()` entrega los offsets de columna en **bytes** y las líneas de este corpus
traen tildes, de modo que extraer el objeto con `substr()` sobre la línea devolvía
`t$titulo` donde el código dice `n$titulo`; el barrido final trabaja sobre los bytes de
cada línea.

## 2. El clasificador y sus dos ejes

`$` sobre una lista resuelve por coincidencia parcial **solo cuando la clave exacta falta
y el prefijo identifica a UNA sola clave**. De ahí que cada acceso tenga dos ejes
independientes, y que los dos haya que medirlos por separado:

- **Presencia** — cuántas de las instancias reales del objeto traen la clave exacta. Se
  cuenta sobre los datos generados (`40_salidas/datos/`) y sobre los insumos que el código
  lee, nunca leyendo el escritor que los produce.
- **Hermandad** — cuántas claves del universo de ese esquema tienen a esta por **prefijo
  estricto**. Es la unidad con la que `$` decide.

**Orden de decisión, declarado.** La protección **estructural** (hermandad) se resuelve
antes que la **contingente** (presencia), porque no depende de que el escritor siga
emitiendo el campo:

| Cat. | Regla | Lectura |
|:---:|---|---|
| **iii** | dos o más hermanas | la ambigüedad protege: `$` devuelve `NULL` falte o no la clave |
| **0** | ninguna hermana | no hay a qué resolver: `$` devuelve `NULL` |
| **i** | una hermana **y** clave presente en el 100% | sin defecto posible hoy, pero la seguridad es **contingente**: depende de que el escritor no deje de emitir el campo |
| **ii** | una hermana **y** la clave puede faltar | **muerde**: riesgo real |

La categoría **(0)** no estaba en la taxonomía de tres del encargo. Se declara porque
existe y es mayoritaria: 75 de los 91 accesos no tienen ninguna hermana, y meterlos en
(i) los describiría como «seguros mientras el escritor coopere» cuando en realidad son
seguros pase lo que pase con el escritor. Queda registrada como duda de forma en el log,
no como decisión encubierta.

## 3. Calibración

Sin esta reproducción no se reporta la tabla. Dos niveles.

**Nivel 0 — la conducta de `$` en este intérprete**, medida y no supuesta:

| Caso | Resultado |
|---|---|
| clave exacta presente | devuelve el valor exacto |
| clave exacta presente **con valor `null`** | devuelve `NULL` (bloquea la parcial) |
| clave ausente, **1** hermana | **devuelve la hermana** (muerde) |
| clave ausente, **2** hermanas | `NULL` |
| clave ausente, **0** hermanas | `NULL` |

**Nivel 1 — los tres casos conocidos que el encargo exige reproducir:**

| Caso conocido | Veredicto esperado | Medición | Resultado |
|---|:---:|---|:---:|
| `anio` / `anios_alternativos` en `20_insumos/curaduria/metadatos_curados.json` (el defecto del DFL 1) | ii | presente 4/10; hermanas: `anios_alternativos` | **(ii)** ✓ |
| `paginas` con dos hermanas en `20_insumos/ocr/manifiesto_ocr.json` (O3) | iii | presente 4/4; hermanas: `paginas_pdf`, `paginas_vacias` | **(iii)** ✓ |
| `anio` en el objeto-norma, clave presente en 100% | i | presente 25/25; hermanas: `anios_alternativos` | **(i)** ✓ |

El caso del DFL 1 es el que hace visible que la clase B es segura **por dónde se lee, no
por qué se lee**: la misma clave `anio`, sobre la curaduría cruda, muerde; sobre el JSON
derivado, no.

## 4. Resumen por categoría

| Cat. | Accesos | Qué significa para el traspaso |
|:---:|---:|---|
| **0** — sin hermanas | **75** | cerrado; ni un cambio de esquema del escritor los activa mientras nadie añada una clave que extienda su nombre |
| **iii** — ambigüedad protege | **7** | cerrado por partida doble (`tipo` tiene dos hermanas: `tipo_etiqueta` y `tipo_fuente`) |
| **i** — contingente | **9** | **lo único que hay que vigilar**: seguro solo mientras el escritor emita el campo |
| **ii** — muerde | **0** | ninguno |
| **Total** | **91** | |

Distribución por archivo:

| Archivo | 0 | i | iii | ii | Total |
|---|---:|---:|---:|---:|---:|
| `30_procesamiento/34_generar_paginas.R` | 33 | 4 | 2 | 0 | 39 |
| `30_procesamiento/33_relaciones.R` | 22 | 0 | 1 | 0 | 23 |
| `30_procesamiento/32_segmentar_articulos.R` | 12 | 3 | 2 | 0 | 17 |
| `00_generar_borradores.R` | 5 | 2 | 2 | 0 | 9 |
| `10_utils/10_utils.R` | 2 | 0 | 0 | 0 | 2 |
| `30_procesamiento/31_extraer_texto.R` | 1 | 0 | 0 | 0 | 1 |
| **Total** | **75** | **9** | **7** | **0** | **91** |

### Los 9 accesos contingentes, que son la lista corta que importa

| Acceso | Dónde | Par |
|---|---|---|
| `n$anio` | `00_generar_borradores.R:93` (×2), `32_segmentar_articulos.R:521` (×2), `34_generar_paginas.R:135` (×2), `34_generar_paginas.R:746` (×2) | `anio` ⊂ `anios_alternativos` |
| `d$tipo` | `32_segmentar_articulos.R:451` | `tipo` ⊂ `tipo_etiqueta` |

Los ocho `n$anio` dependen de que `construir_norma()` siga emitiendo `anio` aunque valga
`null` (hoy: 25/25, de los cuales **4 son `null`**). El `d$tipo` lee la lista de tres
claves que devuelve `derivar_de_nombre()`, cuyo universo local no incluye `tipo_fuente`:
por eso su par es unívoco donde el del objeto-norma no lo es. Si alguna vez `anio` dejara
de emitirse para las normas sin año, esos ocho accesos devolverían el vector
`anios_alternativos` en silencio, que es exactamente el defecto del DFL 1 reproducido en
el JSON derivado.

## 5. Tabla completa (91 accesos)

| Archivo | Línea | Acceso | Esquema que lee | Cat. | Clave presente | Hermanas del prefijo |
|---|---:|---|---|:---:|---:|---|
| `00_generar_borradores.R` | 73 | `n$tipo` | 40_salidas/datos/normas/*.json | **iii** | 25/25 | tipo_etiqueta, tipo_fuente |
| `00_generar_borradores.R` | 91 | `n$titulo` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `00_generar_borradores.R` | 91 | `n$titulo` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `00_generar_borradores.R` | 93 | `n$anio` | 40_salidas/datos/normas/*.json | **i** | 25/25 | anios_alternativos |
| `00_generar_borradores.R` | 93 | `n$anio` | 40_salidas/datos/normas/*.json | **i** | 25/25 | anios_alternativos |
| `00_generar_borradores.R` | 97 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `00_generar_borradores.R` | 166 | `n$tipo` | 40_salidas/datos/normas/*.json | **iii** | 25/25 | tipo_etiqueta, tipo_fuente |
| `00_generar_borradores.R` | 178 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `00_generar_borradores.R` | 242 | `n$origen_texto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `10_utils/10_utils.R` | 116 | `n$grupo_acto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `10_utils/10_utils.R` | 117 | `n$grupo_acto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/31_extraer_texto.R` | 310 | `r$origen_texto` | extraccion.json [] + `texto` (en memoria) | **0** | 25/25 | — |
| `30_procesamiento/32_segmentar_articulos.R` | 377 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/32_segmentar_articulos.R` | 378 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/32_segmentar_articulos.R` | 386 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/32_segmentar_articulos.R` | 416 | `meta$origen_texto` | 40_salidas/intermedios/extraccion.json [] | **0** | 25/25 | — |
| `30_procesamiento/32_segmentar_articulos.R` | 451 | `d$tipo` | literal de derivar_de_nombre() | **i** | 25/25 | tipo_etiqueta |
| `30_procesamiento/32_segmentar_articulos.R` | 520 | `n$tipo` | 40_salidas/datos/normas/*.json | **iii** | 25/25 | tipo_etiqueta, tipo_fuente |
| `30_procesamiento/32_segmentar_articulos.R` | 520 | `n$origen_texto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/32_segmentar_articulos.R` | 521 | `n$anio` | 40_salidas/datos/normas/*.json | **i** | 25/25 | anios_alternativos |
| `30_procesamiento/32_segmentar_articulos.R` | 521 | `n$anio` | 40_salidas/datos/normas/*.json | **i** | 25/25 | anios_alternativos |
| `30_procesamiento/32_segmentar_articulos.R` | 523 | `n$marca_revisar` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/32_segmentar_articulos.R` | 524 | `n$marca_revisar` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/32_segmentar_articulos.R` | 530 | `x$tipo` | 40_salidas/datos/catalogo.json $normas[] | **iii** | 25/25 | tipo_etiqueta, tipo_fuente |
| `30_procesamiento/32_segmentar_articulos.R` | 567 | `n$marca_revisar` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/32_segmentar_articulos.R` | 568 | `n$marca_revisar` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/32_segmentar_articulos.R` | 571 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/32_segmentar_articulos.R` | 583 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/32_segmentar_articulos.R` | 590 | `n$marca_revisar` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 83 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 84 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 86 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 90 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 91 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 94 | `normas[[s]]$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 106 | `n$grupo_acto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 106 | `n$grupo_acto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 108 | `n$grupo_acto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 108 | `n$grupo_acto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 110 | `n$grupo_acto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 110 | `n$grupo_acto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 127 | `n$grupo_acto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 128 | `n$grupo_acto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 130 | `normas[[otro]]$grupo_acto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 133 | `n$grupo_acto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 151 | `n$tipo` | 40_salidas/datos/normas/*.json | **iii** | 25/25 | tipo_etiqueta, tipo_fuente |
| `30_procesamiento/33_relaciones.R` | 236 | `lectura$anio` | literal de anio_de_la_cita() | **0** | 3/3 | — |
| `30_procesamiento/33_relaciones.R` | 325 | `r$tipo` | relaciones + suprimidas_intra_grupo (en memoria) | **0** | 554/554 | — |
| `30_procesamiento/33_relaciones.R` | 327 | `r$tipo` | relaciones + suprimidas_intra_grupo (en memoria) | **0** | 554/554 | — |
| `30_procesamiento/33_relaciones.R` | 330 | `r$tipo` | relaciones + suprimidas_intra_grupo (en memoria) | **0** | 554/554 | — |
| `30_procesamiento/33_relaciones.R` | 336 | `r$tipo` | relaciones + suprimidas_intra_grupo (en memoria) | **0** | 554/554 | — |
| `30_procesamiento/33_relaciones.R` | 368 | `r$tipo` | relaciones + suprimidas_intra_grupo (en memoria) | **0** | 554/554 | — |
| `30_procesamiento/34_generar_paginas.R` | 72 | `r$tipo` | 40_salidas/datos/relaciones.json $relaciones[] | **0** | 552/552 | — |
| `30_procesamiento/34_generar_paginas.R` | 117 | `n$titulo` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 117 | `n$titulo` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 118 | `n$origen_texto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 119 | `n$origen_texto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 135 | `n$anio` | 40_salidas/datos/normas/*.json | **i** | 25/25 | anios_alternativos |
| `30_procesamiento/34_generar_paginas.R` | 135 | `n$anio` | 40_salidas/datos/normas/*.json | **i** | 25/25 | anios_alternativos |
| `30_procesamiento/34_generar_paginas.R` | 138 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 151 | `n$titulo` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 151 | `n$titulo` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 165 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 169 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 170 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 174 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 178 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 240 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 244 | `n$titulo` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 245 | `n$titulo` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 253 | `n$notas_ficha` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 255 | `n$notas_ficha` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 267 | `n$origen_texto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 482 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 483 | `n$origen_texto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 491 | `n$titulo` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 491 | `n$titulo` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 511 | `n$tipo` | 40_salidas/datos/normas/*.json | **iii** | 25/25 | tipo_etiqueta, tipo_fuente |
| `30_procesamiento/34_generar_paginas.R` | 514 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 516 | `capa$titulo` | literal de CAPAS_TEMA | **0** | 4/4 | — |
| `30_procesamiento/34_generar_paginas.R` | 550 | `x$origen_texto` | 40_salidas/datos/catalogo.json $normas[] | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 598 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 599 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 600 | `n$origen_texto` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 605 | `n$titulo` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 605 | `n$titulo` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 621 | `x$origen_texto` | 40_salidas/datos/catalogo.json $normas[] | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 733 | `n$tipo` | 40_salidas/datos/normas/*.json | **iii** | 25/25 | tipo_etiqueta, tipo_fuente |
| `30_procesamiento/34_generar_paginas.R` | 746 | `n$anio` | 40_salidas/datos/normas/*.json | **i** | 25/25 | anios_alternativos |
| `30_procesamiento/34_generar_paginas.R` | 746 | `n$anio` | 40_salidas/datos/normas/*.json | **i** | 25/25 | anios_alternativos |
| `30_procesamiento/34_generar_paginas.R` | 781 | `n$vigencia` | 40_salidas/datos/normas/*.json | **0** | 25/25 | — |

## 6. Anexo declarado — los sub-objetos que la lista de v3 no cubría

La clase B de v3 contaba el acceso `n$vigencia`, no el `$estado` que cuelga de él. Un
documento que declare `n$vigencia` seguro y deje sin examinar lo que se lee debajo
responde a medias, así que aquí van los **32** accesos sobre los sub-objetos `vigencia` y
`grupo_acto`, con el mismo clasificador. Es una extensión declarada, no parte del recuento
de 91.

Esquemas medidos:

| Sub-objeto | Instancias | Claves y presencia |
|---|---:|---|
| `vigencia` | 25 | `estado` 25/25, `sustituye_a` 25/25, `sustituido_por` **1/25**, `fuente` **1/25** |
| `grupo_acto` | 2 (no nulas) | `id`, `rol`, `resolucion`, `otros_miembros`, `nota_colapso`, `fuente`: 2/2 |

**Los 32 caen en (0): ninguna clave de estos dos esquemas es prefijo de otra.** Pero el
dato que importa es el otro: `vigencia` es el **único** lugar del esquema derivado donde
una clave sí falta de verdad (`sustituido_por` y `fuente` están en 1 de 25). Ahí no
protege la presencia; protege únicamente que ningún nombre extienda a otro. Una clave
nueva que se llamara `estado_anterior`, `fuente_sustitucion` o `sustituido_por_fuente`
convertiría esos accesos en (ii) el mismo día en que se añadiera.

| Archivo | Línea | Acceso | Cat. | Clave presente | Hermanas |
|---|---:|---|:---:|---:|---|
| `00_generar_borradores.R` | 97 | `n$vigencia$estado` | **0** | 25/25 | — |
| `00_generar_borradores.R` | 178 | `n$vigencia$estado` | **0** | 25/25 | — |
| `10_utils/10_utils.R` | 117 | `n$grupo_acto$rol` | **0** | 2/2 | — |
| `30_procesamiento/32_segmentar_articulos.R` | 377 | `n$vigencia$estado` | **0** | 25/25 | — |
| `30_procesamiento/32_segmentar_articulos.R` | 378 | `n$vigencia$sustituido_por` | **0** | 1/25 | — |
| `30_procesamiento/32_segmentar_articulos.R` | 386 | `n$vigencia$sustituye_a` | **0** | 25/25 | — |
| `30_procesamiento/32_segmentar_articulos.R` | 571 | `n$vigencia$estado` | **0** | 25/25 | — |
| `30_procesamiento/32_segmentar_articulos.R` | 583 | `n$vigencia$estado` | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 83 | `n$vigencia$estado` | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 84 | `n$vigencia$sustituido_por` | **0** | 1/25 | — |
| `30_procesamiento/33_relaciones.R` | 86 | `n$vigencia$fuente` | **0** | 1/25 | — |
| `30_procesamiento/33_relaciones.R` | 90 | `n$vigencia$sustituye_a` | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 91 | `n$vigencia$sustituye_a` | **0** | 25/25 | — |
| `30_procesamiento/33_relaciones.R` | 94 | `normas[[s]]$vigencia$fuente` | **0** | 1/25 | — |
| `30_procesamiento/33_relaciones.R` | 106 | `n$grupo_acto$id` | **0** | 2/2 | — |
| `30_procesamiento/33_relaciones.R` | 108 | `n$grupo_acto$resolucion` | **0** | 2/2 | — |
| `30_procesamiento/33_relaciones.R` | 110 | `n$grupo_acto$nota_colapso` | **0** | 2/2 | — |
| `30_procesamiento/33_relaciones.R` | 128 | `n$grupo_acto$otros_miembros` | **0** | 2/2 | — |
| `30_procesamiento/33_relaciones.R` | 130 | `normas[[otro]]$grupo_acto$rol` | **0** | 2/2 | — |
| `30_procesamiento/33_relaciones.R` | 133 | `n$grupo_acto$fuente` | **0** | 2/2 | — |
| `30_procesamiento/34_generar_paginas.R` | 138 | `n$vigencia$estado` | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 165 | `n$vigencia$estado` | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 169 | `n$vigencia$sustituido_por` | **0** | 1/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 170 | `n$vigencia$fuente` | **0** | 1/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 174 | `n$vigencia$sustituye_a` | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 178 | `n$vigencia$sustituye_a` | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 240 | `n$vigencia$estado` | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 482 | `n$vigencia$estado` | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 514 | `n$vigencia$estado` | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 598 | `n$vigencia$estado` | **0** | 25/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 599 | `n$vigencia$sustituido_por` | **0** | 1/25 | — |
| `30_procesamiento/34_generar_paginas.R` | 781 | `n$vigencia$estado` | **0** | 25/25 | — |

## 7. Re-derivación por un camino distinto

Todo lo anterior se midió con R. Se re-derivó con `jq` y `grep`, que no comparten ni el
lector de JSON ni el analizador de R:

| Cifra | R (árbol de parseo) | `jq` / `grep` | Coincide |
|---|---:|---:|:---:|
| Accesos de clase B, total | 91 | 90 | **no** (ver abajo) |
| `anio` presente en las normas | 25/25 | 25/25 | sí |
| `anio` con valor `null` en las normas | 4/25 | 4/25 | sí |
| `anio` presente en la curaduría | 4/10 | 4/10 | sí |
| `anios_alternativos` en la curaduría | 2/10 | 2/10 | sí |
| `dfl_1` declara `anio` | no | `false` | sí |
| `paginas` en el manifiesto OCR | 4/4 | 4/4 | sí |
| `vigencia.estado` | 25/25 | 25/25 | sí |
| `vigencia.sustituido_por` | 1/25 | 1/25 | sí |
| `vigencia.fuente` | 1/25 | 1/25 | sí |

**La discrepancia de 1 se resolvió y la razón importa.** El camino de `grep` borra los
comentarios con `sed 's/#.*$//'`, que también borra un `#` **dentro de una cadena**: en
`34_generar_paginas.R:516`, `c(sprintf("## %s {#%s}", capa$titulo, capa$id),`, se llevó
por delante el `capa$titulo` que sí es código. El árbol de parseo cuenta 39 accesos en ese
archivo y `grep` 38. **La cifra correcta es 91**, y la re-derivación cumplió su función:
encontró una diferencia y la diferencia era del instrumento barato, no del caro.

## 8. Lo que el traspaso v02 se lleva

1. **La clase B no tiene ningún acceso que muerda hoy** (0 de 91), y eso está medido sobre
   los datos, no argumentado desde el código que los escribe.
2. **La lista de vigilancia se reduce de 86 a 9.** Los otros 82 son seguros por estructura
   del vocabulario, no por cooperación del escritor: ningún cambio en `construir_norma()`
   los activa.
3. **Los 9 contingentes son ocho `n$anio` y un `d$tipo`**, y todos dependen del mismo
   hábito: que el escritor emita el campo aunque valga `null`. Ese hábito no está
   verificado por ninguna compuerta; es una convención de `construir_norma()`.
4. **El punto frágil real del esquema derivado es `vigencia`**, donde `sustituido_por` y
   `fuente` faltan en 24 de 25 casos. Hoy protege que ningún nombre extienda a otro. Es el
   sitio donde una clave nueva mal nombrada produciría un defecto vivo el mismo día.
5. **`options(warnPartialMatchDollar = TRUE)` (T2 de este encargo) cubre las cuatro
   observaciones anteriores en tiempo de ejecución**, sin depender de que esta tabla se
   mantenga al día. Esta tabla dice dónde mirar; la opción avisa cuando ocurra.
