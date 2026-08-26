# Log — avance de máquina (vía B), sesión 2

Encargo: `50_documentacion/andamios/20260826_encargo_avance_maquina_v1.md`.
Fecha: 2026-08-26. Ejecutó: Claude Code, macOS, R 4.5.2, Quarto 1.9.38.

---

## 1. Resumen de la sesión

Cuatro de las cinco tareas del encargo quedaron completas y una congelada. Se ejecutó la
vía B del traspaso v01: avance que no toca ninguna firma humana. El sitio ganó rótulos
distintivos para los dos archivos del REX 482; se produjeron tres documentos de análisis
(pre-revisión asistida del OCR, pre-clasificación de los 88 descartes de remisión y
rastreo de fuentes de los 5 términos del glosario); y T3 (actions a Node 22) se congeló
porque su verificación exige un dominio que el propio encargo no autoriza.

Lo importante de la sesión no son los dos rótulos: son **dos hallazgos que estaban
publicados y nadie había visto**. (1) El filtro de año está partiendo en dos un mismo
destino según cómo lo cite cada legislador, y eso borró del sitio dos remisiones reales,
una de ellas desde la ley de convivencia educativa. (2) La norma que el corpus llama
`dfl_1_estatuto_asistentes_educacion` **no es** el Estatuto de los Asistentes: es el
Estatuto Docente, y el corpus no contiene ninguna norma sobre asistentes de la educación.
Ninguno de los dos se corrigió: los dos son decisión del titular.

## 2. Inventario de commits

| Hash | Tarea | Mensaje |
|---|---|---|
| `70dc7da` | apertura | `docs(estado): adopta ESTADO.md, sesion 2 abierta` |
| `c774ebc` | T2 | `fix(sitio): rotulos distintivos para miembros de grupo_acto` |
| `dbe7a44` | T4 | `docs(andamios): pre-revision asistida OCR v1` |
| `71006d1` | T5 | `docs(andamios): rastreo de fuentes del glosario v1` |
| `54c7059` | T1 | `docs(andamios): preclasificacion de 88 descartes v1` |
| este | cierre | `docs(andamios): log de avance de maquina` |

## 3. Cambios sustantivos

### 3.1 T2 — Rótulos distintivos para miembros de un grupo de acto

Un solo cambio, en `30_procesamiento/34_generar_paginas.R`: `nombre_corto()` añade un
sufijo cuando la norma pertenece a un `grupo_acto`. El sufijo sale del campo `rol` que
`32_segmentar_articulos.R` **ya derivaba** de la declaración de curaduría (qué slug está
nombrado como `resolucion`), no del basename del archivo. No hubo que inventar
vocabulario: `33_relaciones.R` ya componía sus explicaciones desde esos mismos dos roles.

Antes: los dos archivos se rotulaban `Resolución exenta 482` y el sitio ofrecía dos
enlaces indistinguibles. Ahora: `Resolución exenta 482 (resolución)` y
`Resolución exenta 482 (cuerpo)`.

### 3.2 T4 — Pre-revisión asistida del OCR

Producto: `50_documentacion/andamios/20260826_prerevision_ocr_v1.md`, más el detector en
`50_documentacion/andamios/20260826_prerevision_ocr_detector.R`. Solo lectura sobre
`20_insumos/ocr/`. 108 líneas en el tramo fuerte sobre 3.512 líneas de 75 páginas.

El detector se recortó dos veces contra sus propios falsos positivos, y las dos
calibraciones quedaron escritas en el producto porque explican por qué la lista es corta.
El hallazgo con mayor valor por unidad de esfuerzo: en 5 líneas el reconocedor escribió la
conjunción `у` **cirílica** en lugar de la `y` latina. Se ven idénticas; ningún revisor
humano las encontraría leyendo.

### 3.3 T1 — Pre-clasificación de los 88 descartes

Producto: `50_documentacion/andamios/20260826_preclasificacion_descartes_v1.md`. Los 88
descartes colapsan en **seis grupos**, cada uno una norma citada con un año: 67 descartes
correctos, 21 homologables, 0 ambiguos. Detalle y evidencia en el propio documento.

### 3.4 T5 — Rastreo de fuentes del glosario

Producto: `50_documentacion/andamios/20260826_fuentes_glosario_v1.md`. De los 5 términos:
3 resueltos (DFL 2 de 1998 art. 6 d) para cancelación de matrícula y debido proceso;
Ley 21.109 art. 6 como anclaje de dupla psicosocial) y 2 declarados **no hallada** con la
búsqueda documentada. En las 25 normas del corpus existe **una sola** fórmula de
definición para cualquiera de los cinco: `procedimiento justo y racional`, en la circular
482, página 12, hoy no citable por estar en `ocr_pendiente_revision`.

### 3.5 T3 — CONGELADA

No se tocó `.github/workflows/publicar.yml`. Razón en §8, Duda 1.

## 4. Auditoría de diagnóstico

- **Panel adversarial de T1** (2 revisores de solo lectura, tope duro del encargo
  respetado). El primero re-derivó con código propio los conteos: coincide en todo. El
  segundo intentó refutar cinco afirmaciones de clasificación: las cinco confirmadas, con
  dos matices que se incorporaron al producto y una pieza de evidencia que esta sesión no
  tenía. **Esa evidencia se volvió a verificar en este turno antes de usarla**, no se
  tomó por buena.
- **T2** se verificó con comandos distintos de los que produjeron el resultado: chequeo de
  rótulos sobre el HTML final, huella `sha256` de los 28 JSON de `40_salidas/datos/` antes
  y después, y verificador de enlaces internos independiente.
- **T4 y T5** se re-derivaron por conteo programático en el mismo turno del reporte.

## 5. Defectos encontrados, en mis propios instrumentos y en los datos

| # | Dónde | Síntoma | Causa | Corrección |
|---|---|---|---|---|
| 1 | verificador de enlaces (mío) | 307 enlaces "rotos" | no normalizaba el prefijo `./` que emite Quarto | normalización + control positivo con enlace y ancla falsos plantados |
| 2 | detector OCR v1 (mío) | 623 líneas marcadas, casi todas español legítimo | "fuera del léxico" a secas sobre un léxico de 8.144 palabras | exigir distancia de edición 1 contra el corpus |
| 3 | detector OCR v2 (mío) | falsos positivos por morfología (`comprendan`→`comprenden`) | distancia 1 no distingue conjugación de error de lectura | exigir además par confundible por forma (i/l, j/i, f/t) |
| 4 | detector OCR v3 (mío) | `º` y `ª` marcados como letra ajena | son ordinales del español, categoría Unicode `L` | añadidos al alfabeto permitido |
| 5 | clasificador de descartes (mío) | contradecía mi lectura de los contextos | ventana corta y firma de la norma destino contaminada por el encabezado BCN | se abandonó la regla automática: la clase la fija el grupo, con evidencia leída |
| 6 | datos publicados | 21 remisiones reales ausentes del sitio | a `dfl_1` le falta `anios_alternativos: [1996]` | **no corregido**: es acto humano (§8, Duda 2) |
| 7 | datos publicados | slug que nombra una norma que el archivo no es | el PDF llegó rotulado así desde el equipo | **no corregido**: mover anclas públicas es decisión del titular (§8, Duda 3) |

Los cinco primeros son míos y se corrigieron dentro de la sesión. Que un instrumento de
verificación tenga defectos no es anecdótico: el verificador de enlaces habría reportado
"307 rotos" sobre un sitio sano, y el detector de OCR habría entregado una lista de 623
líneas inútil. Ninguno de los dos se detectó leyendo el código: los detectó el control
positivo.

## 6. Verificación de invariantes 🔒

| Invariante | Comprobación | Resultado |
|---|---|---|
| Ningún estado `ocr_revisado` cerrado, ningún tema aprobado, ninguna pieza publicada | `git status --porcelain -- 20_insumos/` | vacío |
| `20_insumos/curaduria/` y `20_insumos/ocr/` intactos | mismo comando | vacío |
| `40_salidas/` solo cambia por pipeline | `run_all()` completo; `sha256` de los 28 JSON idéntico antes y después | sin cambios |
| Toda cifra recontada en el turno que la reporta | conteos con `jq` y R en el mismo turno | cumplido |
| Enlaces internos sin rotos | verificador independiente, calibrado | 795 enlaces, 0 rotos |
| `relaciones.json` sin tocar por T2 | diff de huellas | idéntico: 550 relaciones, 88 descartes |

## 7. Decisiones del usuario registradas en gates

Ninguna. La sesión corrió en modo autónomo de principio a fin; las decisiones que
requieren al titular quedaron en §8 como dudas con pregunta cerrada, sin ejecutarse.

## 7bis. Decisiones autónomas

| # | Decisión | Alternativa descartada | Reversibilidad |
|---|---|---|---|
| D1 | **No detener la sesión** pese a que la regla 1 se dispara literalmente: `git status --porcelain` traía un archivo sin seguimiento. Se identificó: es el propio encargo, que el titular acababa de dejar en una ruta autorizada. `HEAD` coincidía con `origin/main`. | Detener la sesión por su propio insumo. | Reversible: nada se había modificado al comprobarlo. Mismo criterio que la D1 del log de fase 2, por la misma causa. |
| D2 | **El sufijo de rótulo usa las palabras `resolución` y `cuerpo`**, que son las que `33_relaciones.R` ya emplea para esos roles. | Inventar un rótulo más explícito ("cuerpo aprobado"). | Reversible: una constante. Reusar el vocabulario existente evita que el sitio llame de dos maneras a la misma cosa. |
| D3 | **El detector de OCR entrega dos tramos** y solo el fuerte encabeza la lista de trabajo. | Entregar las 704 líneas marcadas como una sola lista. | Reversible. El control positivo midió que el tramo débil marca 2 de cada 3 líneas limpias. |
| D4 | **El detector de OCR se versionó en `50_documentacion/andamios/`**, no en `30_procesamiento/`. | Dejarlo en un directorio temporal (el reporte quedaría citando un script inexistente) o sumarlo al pipeline. | Reversible: es un archivo. No es paso de `run_all()` y no debe serlo. |
| D5 | **La clasificación de T1 se decide por grupo, no fila por fila**, tras comprobar que los seis grupos son homogéneos. | Sostener la regla automática que ya sabía equivocada. | Reversible: la tabla trae las 88 filas con su contexto para revisarlas una por una. |
| D6 | **T3 se congela en vez de aplicar versiones recordadas de memoria.** | Subir las actions a las versiones que yo recuerde. | N/A: no se hizo nada. "Nada se inventa" incluye números de versión. |

## 8. Dudas y pendientes abiertos

### Duda 1 — T3 no se puede verificar con los dominios que el encargo autoriza

**Contexto.** El encargo restringe la lectura web a cinco dominios legales chilenos
("Nada más"), pero T3 pide verificar las versiones vigentes de las actions "en la
documentación oficial de cada action" y, en su defecto, "en el propio marketplace de
GitHub vía fetch". Ambas rutas caen en `github.com`, que no está autorizado. La propia
cadena de respaldo de T3 termina en "y si tampoco, congela T3".

Medición adicional de FASE 0 que conviene tener a la vista: el workflow **ya** fija
`node-version: '22'` en `actions/setup-node@v4`. El aviso de deprecación de Node 20 no se
refiere a esa línea sino al *runtime* de las propias actions (`checkout@v4`,
`setup-node@v4`, `upload-pages-artifact@v3`, `deploy-pages@v4`, `configure-pages@v5`,
`r-lib/actions/setup-r@v2`, `quarto-dev/quarto-actions/setup@v2`). Quien ejecute esto sin
notar la diferencia "arregla" la línea equivocada.

**Pregunta cerrada.** ¿Autorizas lectura web sobre `github.com` para verificar las
versiones vigentes, o prefieres indicarme tú las versiones a las que subir cada action?

**Qué quedó bloqueado.** El pendiente 12 del traspaso v01. No es bloqueante: el CI corre.

### Duda 2 — 21 remisiones reales están ausentes del sitio por un año de cita

**Contexto.** El DFL N° 1 del Ministerio de Educación se cita legítimamente como "de 1996"
(promulgación, 10-09-1996) y como "de 1997" (publicación, 22-01-1997). El corpus registra
1997, así que las 21 citas que dicen 1996 se descartan. Consecuencia medida sobre
`relaciones.json`: **`dfl_315 → dfl_1` y `ley_21809 → dfl_1` no existen** y
`dto_453 → dfl_1` declara `n_citas: 1` habiendo 18 segmentos citantes. El mecanismo de
arreglo ya existe y ya se usa para el dictamen 52/77.

**Pregunta cerrada.** ¿Agrego `anios_alternativos: [1996]` a
`dfl_1_estatuto_asistentes_educacion`? La respuesta es una línea en
`20_insumos/curaduria/metadatos_curados.json`, y la escribe una persona.

**Qué quedó bloqueado.** Dos remisiones del sitio publicado.

### Duda 3 — El slug `dfl_1_estatuto_asistentes_educacion` nombra una norma que no es

**Contexto.** El documento fija el texto refundido de la ley 19.070 (Estatuto de los
**Profesionales** de la Educación): 154 apariciones de "profesionales de la educación",
0 de "asistentes de la educación". El PDF llegó así rotulado desde el equipo
(`20_insumos/normativa/README.md`, línea 48). El Estatuto de los Asistentes es la Ley
21.109, de 2018, y no está en el corpus. El rótulo erróneo ya viajó al catálogo, al
manifiesto, a cinco anclas del borrador de glosario y al PDF publicado.

**Pregunta cerrada.** ¿El PDF es el que se quería (Estatuto Docente mal rotulado, y hay
que renombrar el slug) o se quería la Ley 21.109 y hay que incorporarla además?

**Qué quedó bloqueado.** Renombrar mueve anclas públicas estables, que es invariante 🔒.

### Duda 4 — El generador de borradores mantiene su propio `nombre_corto()`

**Contexto.** T2 cambió el rótulo en `34_generar_paginas.R`. `00_generar_borradores.R`
tiene una función homónima propia (línea 39) que no cambió, así que las piezas
interpretativas que se generen seguirán rotulando los dos archivos del REX 482 igual. No
se tocó porque está en la raíz del repositorio, fuera de las rutas que el encargo
autoriza a modificar.

**Pregunta cerrada.** ¿Alineo también el generador de borradores en la próxima sesión?

**Qué quedó bloqueado.** Nada publicado: las piezas siguen sin validar.

## 9. Estado de cifras y datos críticos

Todas recontadas programáticamente en el turno de cierre.

| Cifra | Valor | Cómo se obtuvo |
|---|---|---|
| Relaciones vigentes | 550 (502 tema, 44 remisión, 2 grupo_acto, 2 sustitución) | `jq '.relaciones\|length'` y `.por_tipo` |
| Descartes registrados | 88 | `jq '.descartadas\|length'` |
| Descartes clasificados | 67 correctos + 21 homologables + 0 ambiguos | recuento sobre la tabla del producto |
| Páginas HTML del sitio | 47 | `ls -1 40_salidas/sitio/*.html \| wc -l` |
| Enlaces internos / rotos | 795 / 0 | verificador propio, calibrado |
| Páginas y líneas de OCR | 75 páginas en 4 carpetas, 3.512 líneas | `find` y `wc -l` |
| Líneas OCR del tramo fuerte | 108 | recuento sobre el producto |
| Términos del glosario resueltos | 3 de 5 | recuento sobre el producto |
| JSON de `40_salidas/datos/` | 28, idénticos antes y después de T2 | `shasum -a 256` |

## 10. Notas para el revisor

- **Lo que sorprendió.** Que el filtro de año, que la sesión 1 introdujo para matar 74
  remisiones falsas, estuviera además matando 21 verdaderas por la misma mecánica. El
  filtro no está mal: le falta un dato de curaduría que el pipeline ya sabe consumir. Es
  el mismo patrón que la sesión 1 anotó como regla aprendida ("un filtro que reduce
  resultados debe registrar lo que descarta"): el registro de descartes es exactamente lo
  que permitió encontrarlo.
- **Lo que falló.** Cinco defectos en mis propios instrumentos (§5), todos detectados por
  controles positivos y ninguno por revisión de código. Ninguno alcanzó a contaminar un
  producto entregado.
- **Una desviación menor a corregir en el próximo encargo.** Uno de los subagentes del
  panel usó `python3` para su verificación cruzada. No tocó el repositorio y su resultado
  coincidió con el de `jq`, pero `CLAUDE.md` §7 prohíbe Python como lenguaje de análisis
  en este proyecto: el prompt del subagente debe declararlo.
- **Sin acceso a los logs de CI.** El encargo no autoriza `gh`, así que el "verde" del
  workflow tras `c774ebc` queda como verificación diferida, declarada como tal.
