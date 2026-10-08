# Enmiendas al encargo v10 (correcciones visibles)

> **Encargo enmendado:** `50_documentacion/andamios/20260908_encargo_correcciones_visibles_v1.md`
> **Este archivo:** `50_documentacion/andamios/20260908_encargo_correcciones_visibles_v1_enmiendas.md`
> **Creado:** 2026-09-09, encargo v11, T5, hueco 4 de P7.
> **Por qué un archivo al lado y no una edición del encargo:** `50_documentacion/andamios/` está
> congelado (`POLITICA_PROYECTO.md` §1.3.1, alcance). Una enmienda a un andamio **se registra, no
> se reescribe**: reescribir el encargo borraría la prueba de que su tabla original tenía siete
> filas y de que la octava ruta se autorizó durante la ejecución, que es justamente lo que hay que
> poder demostrar dentro de seis meses.

---

## 0. Qué problema cierra este archivo

El log del v10 lo dejó escrito como el pendiente «más barato de cerrar y más caro de explicar»
(`50_documentacion/andamios/logs/20260908_correcciones_visibles_v10_log.md`, **línea 549**):

> **La enmienda de §3 consta en este log y en ninguna otra parte.** El archivo del encargo no se
> reescribió (su tabla sigue con siete filas), de modo que quien cruce §3 contra
> `git diff --name-only` hallará un octavo archivo sin autorización visible. **No se repara aquí
> porque el encargo no está en la tabla de escritura**; queda señalado como el pendiente más barato
> de cerrar y más caro de explicar dentro de seis meses.

Es el cuarto hueco de P7 (`50_documentacion/traspasos/traspaso_cierre_v03.md` §11.1). Este archivo
lo cierra: a partir de aquí, la octava ruta tiene autorización visible fuera del log.

---

## 1. La enmienda, transcrita de su fuente

**Fuente:** `50_documentacion/andamios/logs/20260908_correcciones_visibles_v10_log.md`,
sección `#### 3.3.1 Enmienda de autorizaciones del emisor (no es incumplimiento del ejecutor)`,
**línea 362**; el enunciado de la enmienda, **líneas 382 a 386**.

> Se aplicó la **regla de detención de §8** («un cambio exige escribir fuera de la tabla de §3») y
> se consultó al emisor, que **amplió §3** con la ruta
> `50_documentacion/activa/50_datos_versionados_autorizados.md` bajo seis condiciones. Queda
> constancia de que esto es una **enmienda de autorizaciones del emisor**, no un incumplimiento del
> ejecutor: el ejecutor se detuvo antes de escribir fuera de la tabla.

### 1.1 La causa

El push del bloque B3 fue rechazado por el hook global de pre-push con **18 hallazgos R1**, uno por
cada JSON de datos del commit. El archivo que R1 consulta,
`50_documentacion/activa/50_datos_versionados_autorizados.md`, **no existía**: el hook global se
instaló en la estación el **2026-09-01** y este repositorio versiona sus JSON desde el bootstrap del
**2026-08-25**, así que esos archivos nunca se habían enfrentado a él. Sin ese archivo la lista de
globs queda vacía y R1 rechaza **toda** extensión de datos, incluidos los JSON que el proyecto
versiona por diseño (`CLAUDE.md` §10.4).

### 1.2 La tabla de §3 del encargo v10, tal como sigue estando

Siete filas, sin la octava (`50_documentacion/andamios/20260908_encargo_correcciones_visibles_v1.md`
§3, líneas 50 a 58):

| Ruta | Bloque |
|---|---|
| `30_procesamiento/34_plantillas_sitio/busqueda.html` | B1 |
| `30_procesamiento/34_plantillas_sitio/estilo.css` | B2 |
| `_quarto.yml` | B2 |
| El script de extracción o segmentación que produce el preámbulo, en `30_procesamiento/` | B3 |
| `50_documentacion/andamios/20260908_medicion_correcciones_v1.md` | medición y auditoría |
| `50_documentacion/andamios/20260908_pendientes_firma_humana_v1.md` | B4 |
| `50_documentacion/andamios/logs/20260908_correcciones_visibles_v10_log.md` | log |

### 1.3 La octava fila, que es lo que esta enmienda declara

| Ruta | Bloque | Origen de la autorización |
|---|---|---|
| `50_documentacion/activa/50_datos_versionados_autorizados.md` | B3 | **Ampliación explícita del emisor durante la ejecución**, bajo las seis condiciones de §2. Commit propio `082a26d`. |

---

## 2. Las seis condiciones bajo las que se amplió, y su cumplimiento

Transcritas del log del v10, **líneas 388 a 410**:

1. §3 ampliada con esa ruta. Archivo nuevo; no toca nada existente.
2. Autoriza `40_salidas/datos/` y nada más. **Con una desviación declarada de la letra de la
   instrucción**: el patrón pedido, `40_salidas/datos/**/*.json`, se probó contra el mecanismo real
   del hook (`case "$ruta" in $glob`, en `bash`) y **deja fuera** `relaciones.json`, que es uno de
   los 18 del push, porque exige un `/` después de `datos/`. Se usaron dos líneas,
   `40_salidas/datos/*.json` y `40_salidas/datos/**/*.json`, que cubren los dos niveles que hoy
   tienen archivos y ninguna otra ruta: la prueba muestra `NO` para `40_salidas/sitio/search.json`,
   `40_salidas/intermedios/extraccion.json`, `20_insumos/curaduria/metadatos_curados.json`,
   `package.json` y un `40_salidas/datos/algo.csv`. La prueba está transcrita en el propio archivo
   de autorización.
3. La justificación se apoya en hechos de ese turno: los 28 JSON versionados enumerados con
   `git ls-files 40_salidas/datos | grep '[.]json$'` y pesados con `wc -c` en la misma corrida, y
   `maneja_sensibles: false` citado del encabezado de `ESTADO.md`.
4. Commit propio y separado, `082a26d` («chore(hooks): declara los JSON de datos como versionados
   autorizados»), pusheado **antes** del de B3. Para que quedara antes en la historia se deshizo el
   commit de B3 con `git reset --soft` (nada se pierde; el commit no estaba publicado) y se rehizo
   con su mensaje original, guardado antes de la operación.
5. Registrado en el log como enmienda del emisor, con su causa.
6. Regresión de anclas corrida de nuevo antes del push. En verde. No hubo que revertir.

---

## 3. La desviación declarada respecto del patrón del hook

`50_documentacion/traspasos/traspaso_cierre_v03.md` §4.6 la resume así:

> **Desviación declarada y correcta:** el patrón que el emisor pidió (`40_salidas/datos/**/*.json`)
> se probó contra el mecanismo real del hook y deja fuera `relaciones.json`, porque exige un `/`
> después de `datos/`. Se usaron dos líneas que cubren los dos niveles con archivos y ninguna otra
> ruta, con la prueba de señuelos transcrita en el propio archivo.

La desviación es **de la letra de la instrucción, no de su propósito**: la instrucción pedía
autorizar `40_salidas/datos/` y nada más, y el patrón literal autorizaba **menos** que eso, dejando
fuera tres de los cuatro archivos del primer nivel.

### 3.1 Verificación independiente de esa desviación, 2026-09-09

La tarea T6 del encargo v11 ejercitó en seco el mecanismo R1 del hook sobre diez rutas señuelo, con
la función `autorizado()` y el `awk` de extracción copiados literalmente del hook. Resultado:
**5 aceptadas, 5 rechazadas**, con las cinco aceptadas bajo `40_salidas/datos/` (los dos niveles,
`relaciones.json` incluido) y las cinco rechazadas fuera. Y el control positivo confirma la razón
de las dos líneas: **borrando el glob `40_salidas/datos/*.json`, `catalogo.json`,
`manifiesto_corpus.json` y `relaciones.json` pasan a RECHAZADA** y solo sobreviven los de
`normas/`. La afirmación central del archivo de autorizaciones queda comprobada un año después de
escrita por un instrumento que no la conocía.

Evidencia completa: `50_documentacion/andamios/logs/20260909_indice_y_expansion_v11_log.md`,
sección `### FASE T6`.

---

## 4. Qué NO enmienda este archivo

- **No reabre el encargo v10 ni ninguna de sus decisiones.** Su tabla de §3 sigue teniendo siete
  filas y así debe quedar: la octava fila es una ampliación posterior y datada, y confundirlas
  borraría la trazabilidad que este archivo existe para dar.
- **No amplía ninguna autorización hoy.** `50_datos_versionados_autorizados.md` sigue autorizando
  `40_salidas/datos/` y nada más, verificado el 2026-09-09.
- **No toca el residuo de las dos expresiones regulares** que el log del v10 declaró en su línea
  356; ese es el hueco 1 de P7 y lo cierra la misma tarea T5 del v11, moviéndolas a
  `10_utils/10_configuracion.R`.
