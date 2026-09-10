# Encargo v11: Índice lateral, expansión de consulta, cierre de P7 e instrumento versionado

> **Destino:** `50_documentacion/andamios/20260909_encargo_v11_indice_y_expansion_v1.md`
> **Tipo:** vía B (autónomo; nada de lo que produce exige firma humana).
> **Patrón:** `encargo_autonomo_claude_code_v1.md` v1.5, con el tope de subagentes bajado a 2 por regla aprendida del proyecto (traspaso v03 §6, regla 2).
> **Emitido:** 2026-09-09, sesión 4. **Insumo de diseño:** `50_documentacion/andamios/20260909_integracion_revision_externa_v1.md` (adopciones con destino v11).
> **Log:** `50_documentacion/andamios/logs/20260909_indice_y_expansion_v11_log.md`

---

## 0. Por qué existe este encargo

Tres cosas del producto, medidas en la sesión 3, y una deuda de instrumental. El índice lateral de cada página de norma contiene una sola entrada, «Normas relacionadas», porque los encabezados de artículo no llegan al índice del tema (hipótesis, se mide en FASE 0). El buscador resuelve 3 de 10 consultas de evaluación y en 3 de las 7 restantes el índice no devuelve ninguna página porque exige todos los términos y el equipo pregunta con palabras que el corpus no usa (fuente: `traspaso_cierre_v03.md` §3 y §7, leído en la sesión que emite este encargo; se recuenta en FASE 0). El encargo v10 dejó cuatro huecos de autorización con residuos: dos expresiones regulares fuera de su fuente canónica, `CLAUDE.md` §10.6 detenido en el 2026-08-26, el laboratorio y los instrumentos sin versionar, y una enmienda de autorizaciones que consta solo en el log (fuente: `traspaso_cierre_v03.md` §11.1 P7). Y el conjunto de diez consultas con anclas verificadas, que es lo único que convierte un cambio del buscador en algo demostrable, vive fuera del repositorio (fuente: escáner del 2026-09-09, `50_documentacion/andamios/lab_motor_v9/a2_consultas_evaluacion.csv` presente en disco y ausente de `git ls-files`; se confirma en FASE 0).

---

## 1. Contrato

### 1.1 Modo, subagentes y plan de concurrencia

- **Modo autónomo, todo en este turno.**
- **Subagentes admitidos, tope duro de 2 simultáneos** (de cualquier rol; la sesión principal que orquesta no cuenta). Es tope de simultaneidad, no de total. Motivo del tope, más bajo que el del patrón: siete cortes por límite de sesión en cuatro días con cinco agentes, dos con pérdida total (fuente: `traspaso_cierre_v03.md` §6 regla 2).
- **Plan de concurrencia por olas** (solo tareas independientes en el grafo de §5.1 y con ALCANCE disjunto):
  - Ola 1: T4 (instrumento) y T6 (verificaciones de lectura). Un subagente de escritura y uno de lectura.
  - Ola 2: T1 (índice lateral) y T5 (cierre de P7). Dos subagentes de escritura con alcances disjuntos.
  - Ola 3: T2 (expansión de consulta), sola: su ALCANCE intersecta con T1 y con T5.
  - T7 (fila de `CLAUDE.md` para este encargo) la hace el orquestador en serie, al final de la cadena.
  - FASE R y FASE L, fuera del grafo, siempre, en ese orden.
- Dentro de una ola nadie commitea: el orquestador espera a la ola entera, verifica cada retorno con comando propio y commitea por tarea, en orden del grafo.

### 1.2 Regla de detención (lista medible)

Congela la tarea afectada y sus descendientes, regístrala como duda (log §4.1) y sigue con la siguiente tarea independiente si:

1. `git status --porcelain` no está vacío al iniciar FASE 0, o `git stash list` no está vacío. Aquí se detiene la SESIÓN entera, no una tarea.
2. `git rev-parse HEAD` difiere de `git rev-parse origin/main` tras `git fetch --quiet`. Sesión entera.
3. `grep -E '^sesion_abierta:' 50_documentacion/activa/ESTADO.md` no devuelve `true`. Sesión entera.
4. La línea base del buscador medida en FASE 0 con el instrumento de T4 no da **3 de 10**: la premisa está mal y T1 y T2 se congelan hasta que el log registre la cifra real y su causa; T4, T5 y T6 siguen.
5. El inventario de anclas de FASE 0 no da **806** segmentos con ancla en el HTML publicado, o los destinos verificables contra el sitio no dan **848**: se registra la cifra real como nueva referencia solo si el log demuestra con comando que la diferencia es anterior a este encargo (`git log -1 --format=%h -- 40_salidas/datos/`); de lo contrario T1 y T2 se congelan.
6. Tras cualquier regeneración del sitio, el conjunto de `id` de encabezado por página difiere del de FASE 0 (🔒1): se revierte el commit de la tarea con `git revert` y la tarea se congela.
7. Tras cualquier regeneración, alguna de las **3 consultas hoy resueltas** deja de resolverse: reversión y congelamiento de la tarea que la causó.
8. Una tarea necesita escribir fuera de su ALCANCE: se congela; la ruta y su `git diff --stat -- <ruta>` van al log; nada se commitea.
9. Un cambio necesitaría escribir en `20_insumos/` (🔒2): se congela sin excepción.
10. Un bug no converge al tercer intento (tope 1.4).
11. El despliegue de GitHub Pages queda en rojo tras un push y el segundo intento (un reintento, tope 1.4) también: se revierte el commit que lo causó, se pushea la reversión y la tarea se congela.
12. **Cláusula residual:** cualquier estado, conteo o resultado no enumerado en este encargo → congela ESTA tarea, regístrala como duda (§4.1 del log) y sigue con la próxima tarea independiente.

### 1.3 Autorizaciones (lista cerrada)

**Lectura:** cualquier archivo del repositorio; `$HERRAMIENTAS_DEV_PATH/plantillas/10_locale.R` (para D8) y el directorio de hooks que devuelve `git config core.hooksPath` (para D4 y para leer el hook antes de commitear).

**Escritura y creación, por tarea (es también el ALCANCE de §1.7):**

| Ruta | Tarea |
|---|---|
| `30_procesamiento/34_generar_paginas.R` | T1, T2 |
| `_quarto.yml` | T1 |
| `30_procesamiento/34_plantillas_sitio/busqueda.html` | T2 |
| `30_procesamiento/34_plantillas_sitio/estilo.css` | T1 (solo si el índice poblado necesita la regla de desplazamiento; ver T1) |
| `10_utils/10_configuracion.R` | T2 (tabla de alias y palabras vacías), T5 (dos expresiones regulares) |
| `30_procesamiento/31_extraer_texto.R` | T5 |
| `CLAUDE.md` (solo §10.1 y §10.6) | T5, T7 |
| `.gitignore` | T5 |
| `50_documentacion/andamios/lab_motor_v9/**/*.R` y `**/*.md` (solo `git add`; no se editan) | T5 |
| `50_documentacion/andamios/20260908_encargo_correcciones_visibles_v1_enmiendas.md` (nuevo) | T5 |
| `tests/consultas_evaluacion.R` (nuevo) | T4 |
| `tests/medir_buscador.R` (nuevo) | T4 |
| `tests/consulta_pagefind.mjs` (nuevo; copia de `lab_motor_v9/a2_consulta_pagefind.mjs`, adaptada solo en rutas) | T4 |
| `tests/inventario_anclas.R` (nuevo) | T4 |
| `50_documentacion/andamios/logs/20260909_indice_y_expansion_v11_log.md` | FASE 0 a FASE L |
| `50_documentacion/andamios/lab_motor_v9/salida_v11/` (nuevo; escritura de trabajo: copias previas, salidas del instrumento, `extraccion_v11_previo.json`; no se versiona, hipótesis de que la carpeta está bajo `.gitignore` medida en FASE 0) | todas |

**Acciones:**

- Regenerar el sitio por pipeline (`Rscript 00_run_all.R` desde la raíz, con `bash` explícito), en cualquier tarea. `40_salidas/` nunca a mano.
- Servir el sitio en modo lectura para medir (cualquier servidor estático local sobre `40_salidas/sitio/`), en cualquier tarea.
- Mover (`mv`, nunca `rm`) `40_salidas/intermedios/extraccion.json` a `50_documentacion/andamios/lab_motor_v9/salida_v11/extraccion_v11_previo.json`, **solo en T5 y solo después de** registrar en el log `md5sum 40_salidas/intermedios/extraccion.json`; existe para forzar el reprocesamiento que la huella del paso 30 no dispara (fuente: `traspaso_cierre_v03.md` §6, bug 1). No se borra nunca.
- `git add <rutas explícitas del ALCANCE>`, `git commit`, `git push origin main`: un commit por tarea terminada más los `fix(auditoria)` de FASE R y el `docs(log)` de FASE L. Push después de cada commit de tarea. Verificación de CI por `head_sha` tras cada push, obligatoria.
- `git revert <hash propio>` bajo las condiciones 6, 7 y 11 de §1.2.

**Nada más.** Ningún subagente hereda autorizaciones.

### 1.4 Topes de esfuerzo

1. **3 intentos por bug.** Al tercer fix fallido la tarea se congela con la evidencia de los tres intentos.
2. **2 ciclos de reparación en FASE R.** Lo que sobrevive al segundo va al log como pendiente.
3. **1 reintento por comando** que falla por causa transitoria (red, lock, timeout, CI en cola). Al segundo fallo es hallazgo.

### 1.5 Reglas canónicas heredadas (se referencian, no se copian)

- `CLAUDE.md` §4 (gobernanza), §7 (reglas técnicas: R-only, `here::here()`, `.by=`, sin `$` sobre estructuras leídas de disco), §10.5 (convenciones del proyecto: fidelidad normativa, `.qmd` no se editan a mano, ids y anclas desde `slugificar()`).
- `POLITICA_PROYECTO.md` §5.4 (constantes centralizadas en `10_utils/10_configuracion.R`), §5.6 checklist.
- Reparación quirúrgica desde el primer minuto: se corrige lo que la tarea nombra y nada más (fuente: `traspaso_cierre_v03.md` §6 regla 6).
- Control positivo adversarial contra el instrumento, no benévolo (regla 7).
- Python: prohibido sin borde; ni un sondeo de disponibilidad. Reproducir literalmente en el prompt de cada subagente.

### 1.6 Prohibiciones

- Escribir en `20_insumos/` (🔒2), editar a mano cualquier archivo bajo `40_salidas/`, y correr `00_ocr_documentos.R` con cualquier bandera.
- Publicar, validar o tocar el estado de ninguna pieza interpretativa (🔒5).
- `git push --force`, `--no-verify`, `git add -A`, `git add .`, reescribir historia publicada.
- Inventar un alias, un año, un título o una cifra: lo que no esté en el laboratorio o en los datos queda fuera.
- Acceso `$` sobre estructuras leídas de disco; `[[ ]]` siempre.

### 1.7 Contrato de entorno

1. **ENTORNO:** filesystem local vía Claude Code en la estación del titular (macOS), repositorio `slep_normativa_convivencia`, rama `main`, remoto `origin` (GitHub, Pages con despliegue por Actions).
2. **INSUMOS** (todos por ruta desde la raíz del repositorio; ninguno se pasa aparte):
   - `50_documentacion/traspasos/traspaso_cierre_v03.md` (fuente: eco de `/apertura` del 2026-09-09, `git ls-files | grep traspaso`).
   - `50_documentacion/andamios/20260909_integracion_revision_externa_v1.md` (hipótesis: el titular lo depositó tras la sesión 4; se mide en FASE 0 con `ls`).
   - `50_documentacion/andamios/20260908_medicion_correcciones_v1.md` (instrumentos del v10 transcritos; fuente: escáner del 2026-09-09).
   - `50_documentacion/andamios/20260908_encargo_correcciones_visibles_v1.md` y `50_documentacion/andamios/logs/20260908_correcciones_visibles_v10_log.md` (fuente: escáner).
   - `50_documentacion/andamios/lab_motor_v9/a2_consultas_evaluacion.csv`, `a2_consulta_pagefind.mjs`, `vocabulario.json`, `a1_alias_prueba.csv` (fuente: escáner; existen en disco, no versionados; se confirma en FASE 0).
   - `50_documentacion/activa/50_datos_versionados_autorizados.md` (fuente: escáner).
   - `$HERRAMIENTAS_DEV_PATH/plantillas/10_locale.R` (hipótesis: la variable de entorno resuelve; se mide en FASE 0 con `test -f`).
3. **POSICIÓN:** toda ruta completa desde la raíz del repositorio; ningún comando asume `cd` previo; los scripts corren bajo `bash` explícito (`bash -c '...'`), nunca el shell interactivo del titular; R por `Rscript` con `here::here()`; JavaScript solo dentro de `busqueda.html` (código del sitio) y en el runner `tests/consulta_pagefind.mjs` (ver §2, ambigüedad 2). Primera fase: `git fetch --quiet` y comparación de `HEAD` contra `origin/main`.
4. **LOG:** `50_documentacion/andamios/logs/20260909_indice_y_expansion_v11_log.md`.
5. **ALCANCE:** la tabla de §1.3, por tarea (más `lab_motor_v9/salida_v11/` como escritura de trabajo no versionada). Chequeo programático al cierre de cada fase y global en FASE R.
6. **PRUEBAS** (sin arnés `testthat`: `tests/` está vacío, fuente: escáner). Tres comandos que lo sustituyen, los tres con salida esperada:
   - **Anclas:** `Rscript tests/inventario_anclas.R` (T4 lo crea a partir del instrumento transcrito en `20260908_medicion_correcciones_v1.md`) → imprime `segmentos_con_ancla: 806` y `destinos_resueltos: 848 de 848`, y escribe `50_documentacion/andamios/lab_motor_v9/salida_v11/ids_por_pagina.txt` con el conjunto ordenado de `id` por página. La comparación byte a byte de ese archivo antes y después de cada regeneración es 🔒1.
   - **Buscador:** `Rscript tests/medir_buscador.R --sitio 40_salidas/sitio` → imprime `resueltas: N de 10`, la tabla consulta por consulta con posición del ancla esperada, MRR, cobertura del conjunto de anclas por consulta y, para la clase «sin respuesta», si devolvió vacío. Valor esperado tras T1: `3 de 10` y las mismas tres; tras T2: `6 de 10` o más y las mismas tres entre ellas.
   - **Datos versionados:** `git diff --stat <PUNTO DE RETORNO>..HEAD -- 40_salidas/datos/` → vacío en toda tarea salvo T5, donde también debe ser vacío después del reprocesamiento forzado (las regex cambian de archivo, no de valor).
7. **PUNTO DE RETORNO:** FASE 0 mide `git status --porcelain` (vacío) y `git stash list` (vacío) y registra `git rev-parse --short HEAD` en el encabezado del log. Toda reversión es `git revert` de un commit propio; `reset`, `restore` y `checkout --` no están autorizados.

---

## 2. Ambigüedades resueltas antes de redactar

1. **Qué se versiona del laboratorio.** `50_datos_versionados_autorizados.md` autoriza solo `40_salidas/datos/` para archivos de datos y el hook de pre-push rechaza el resto (fuente: `traspaso_cierre_v03.md` §4.6). Alternativas: (a) ampliar la autorización al laboratorio; (b) versionar solo `.R` y `.md` del laboratorio y llevar `.gitignore` a excluir `csv`, `json`, `txt` y `bak` de esa carpeta; (c) dejarlo sin versionar. **Decisión: (b).** La (a) contradice el predicado D4 de la compuerta (ninguna ruta de datos fuera de `40_salidas/datos/` autorizada) y la (c) mantiene la zona frágil 3. Los datos del laboratorio son derivables desde sus scripts; el conjunto de diez consultas, que sí debe persistir, se versiona como código (ambigüedad 3).
2. **El runner de Pagefind.** El índice solo se consulta desde JavaScript (API pública de Pagefind, WASM), y el laboratorio ya tiene `a2_consulta_pagefind.mjs` (fuente: escáner). Alternativas: (a) reimplementar en R; (b) R orquesta, cuenta y reporta, y un runner JS mínimo devuelve JSON crudo por consulta. **Decisión: (b).** La (a) no existe: no hay lector R del índice de Pagefind. El runner es auxiliar declarado, no reemplaza código de análisis, y su única función es invocar `pagefind.search()` y devolver resultados sin procesar; toda cifra la produce R.
3. **Forma del conjunto de evaluación.** Alternativas: `csv` en `tests/` (rechazado por el hook, ambigüedad 1) o `tests/consultas_evaluacion.R` con `tibble::tribble()` (datos como código, R-only, con columnas `id`, `consulta`, `ancla_esperada`, `anclas_conjunto`, `clase`, `fuente`). **Decisión: la segunda.** Se le añade la clase `sin_respuesta` con 3 a 5 consultas construidas cuya respuesta correcta es «no está en el corpus» (adopción A-15 y B-03), marcadas `fuente: construida_v11`; las diez originales llevan `fuente: v9_reconstruida` y `clase: historica`.
4. **Fuente de los alias para la expansión.** Alternativas: (a) esperar alias curados por el equipo (vía A); (b) usar la tabla construida del v9 (`a1_alias_prueba.csv` y `vocabulario.json`) como constante en R, cada fila con `fuente`, invisible para el lector, reemplazable por curación. **Decisión: (b).** La expansión no publica texto ni afirma nada: solo cambia qué páginas devuelve el índice, y el instrumento mide si mejora o degrada. La (a) deja el techo en 3 de 10 sin fecha. Condición: ningún alias se inventa en este encargo; entran solo los que ya existen en el laboratorio, y la tabla declara `fuente = "v9_construido"` en todas sus filas.
5. **Cuarto hueco de P7 (la enmienda de §3 del v10 que consta solo en el log).** Alternativas: editar `20260908_encargo_correcciones_visibles_v1.md` o crear un archivo de enmiendas al lado. **Decisión: archivo al lado.** `andamios/` está congelado (`POLITICA_PROYECTO.md` §1.3.1, alcance); una enmienda a un andamio se registra, no se reescribe.
6. **Niveles del índice lateral.** Si el JSON de la norma declara estructura (títulos, capítulos, párrafos) por encima del artículo, esa estructura va al nivel 2 y los artículos al nivel 3; si no la declara, los artículos van al nivel 2. Se decide por norma, en FASE 0 de T1, midiendo el JSON, no adivinando. `toc-depth` acompaña al nivel que corresponda.

---

## 3. Estado de partida (premisas marcadas)

- Sitio publicado: 47 páginas HTML, 25 normas, 682 artículos, 806 segmentos con ancla, 848 destinos verificables contra el sitio (fuente: `traspaso_cierre_v03.md` §3 y §7; se recuentan en FASE 0).
- Buscador: 3 de 10 consultas de evaluación resueltas con la interfaz propia sobre la API de Pagefind, tope 5 sub-resultados por norma (fuente: `traspaso_cierre_v03.md` §4.2; se recuenta en FASE 0).
- Índice lateral de las páginas de norma con una sola entrada (fuente: `traspaso_cierre_v03.md` §3). Causa atribuida: los encabezados se emiten dentro del contenedor de indexación (hipótesis, se mide en FASE 0 leyendo `34_generar_paginas.R` y una página generada).
- `dfl_1` tiene 220 encabezados con `id` (hipótesis, se mide en FASE 0).
- Pagefind exige todos los términos de la consulta (fuente: `traspaso_cierre_v03.md` §7). Que ignore palabras vacías del español y que normalice tildes en el índice es desconocido (hipótesis, se mide en FASE 0 de T2).
- El vocabulario del v9 tiene 892 entradas y cubre 21 % de los términos de las consultas construidas (fuente: `traspaso_cierre_v03.md` §7 y §11.1 P1).
- `REGEX_FICHA_ORIGEN` y `REGEX_PIE_ORIGEN` viven en `30_procesamiento/31_extraer_texto.R` y no en `10_utils/10_configuracion.R` (fuente: `traspaso_cierre_v03.md` §9; se confirma en FASE 0 con `grep -n`).
- La huella de caché del paso 30 no incluye la versión del código; editar el extractor no reprocesa nada salvo que se aparte `40_salidas/intermedios/extraccion.json` (fuente: `traspaso_cierre_v03.md` §6, bug 1).
- `CLAUDE.md` §10.6 termina en la fila del 2026-08-26 y §10.1 dice «24 PDF oficiales» (fuente: `CLAUDE.md` leído en la sesión 4).
- `tests/` existe y está vacío; `.github/` no aparece en el escáner porque ignora ocultos (fuente: escáner del 2026-09-09; el flujo de CI se localiza en FASE 0 con `ls .github/workflows/`).
- `50_datos_versionados_autorizados.md` autoriza `40_salidas/datos/` y nada más, y el hook de pre-push lo aplica (fuente: `traspaso_cierre_v03.md` §4.6).
- El laboratorio `lab_motor_v9/` tiene 128 archivos no versionados, entre ellos un `.R.bak` (fuente: escáner y `traspaso_cierre_v03.md` §10; se recuenta en FASE 0 con `find ... | wc -l`).
- Los hooks del repositorio se leen antes de cualquier commit (`git config core.hooksPath` → kit; fuente: eco de `/apertura`).
- El instrumento del v10 mide con el bloque de orden extraído del propio `busqueda.html`, y en modo réplica reproduce la línea base exacta (fuente: `traspaso_cierre_v03.md` §4.2; su transcripción está en `20260908_medicion_correcciones_v1.md`, ruta según escáner).

---

## 4. Invariantes 🔒 (cada uno con su comando; FASE R los corre todos)

| # | Invariante | Por qué | Comando de verificación | Esperado |
|---|---|---|---|---|
| 🔒1 | El conjunto de `id` de encabezado por página no cambia | Las citas ya copiadas fuera del sitio apuntan a esas anclas | `Rscript tests/inventario_anclas.R && diff 50_documentacion/andamios/lab_motor_v9/salida_v11/ids_por_pagina.txt 50_documentacion/andamios/lab_motor_v9/salida_v11/ids_por_pagina_previo.txt \| wc -l` | `0` |
| 🔒2 | `20_insumos/` sin cambios | Escritura humana exclusiva; sin delegación | `git diff --name-only <PUNTO DE RETORNO>..HEAD -- 20_insumos/ \| wc -l` y control positivo: el mismo comando sobre `30_procesamiento/` debe dar > 0 | `0` y `> 0` |
| 🔒3 | Datos versionados idénticos | Ninguna tarea cambia texto ni relaciones | `git diff --stat <PUNTO DE RETORNO>..HEAD -- 40_salidas/datos/` | vacío |
| 🔒4 | Texto visible de cada página de norma idéntico salvo el marcado de encabezado | Fidelidad normativa | `Rscript` que extrae con `rvest::html_text2()` el nodo del articulado por página antes (FASE 0) y después de T1, normaliza espacios y compara; la copia previa va a `lab_motor_v9/salida_v11/texto_por_pagina_previo.rds` | `paginas_distintas: 0` |
| 🔒5 | Ninguna pieza publicada | Firma humana | `grep -rlE '^estado: *validada' 20_insumos/curaduria/piezas/ \| wc -l` y número de páginas HTML del sitio | `0` y `47` (recontado en FASE 0) |
| 🔒6 | R-only en entregables | `CLAUDE.md` §7 | `git diff --name-only <PUNTO DE RETORNO>..HEAD \| grep -cE '\.py$'` | `0` |
| 🔒7 | Ningún archivo de datos versionado fuera de `40_salidas/datos/` | D4 y `50_datos_versionados_autorizados.md` | `git ls-files \| grep -E '\.(csv\|json\|xlsx\|parquet\|rds\|txt)$' \| grep -vcE '^40_salidas/datos/'` | igual al valor medido en FASE 0 (no crece) |
| 🔒8 | Las 3 consultas resueltas hoy siguen resueltas | Nada retrocede | `Rscript tests/medir_buscador.R --sitio 40_salidas/sitio` | las mismas tres presentes en `resueltas` |

---

## 5. Cadena de tareas

### 5.1 Grafo

- T4 (instrumento) es independiente.
- T6 (verificaciones D4 y D8, lectura) es independiente.
- T5 (cierre de P7) es independiente.
- T1 (índice lateral) requiere T4.
- T2 (expansión de consulta) requiere T1, T4 y T5.
- T7 (fila de `CLAUDE.md` para este encargo) requiere que T1, T2, T4 y T5 hayan terminado o quedado congeladas; corre igual.
- FASE R y FASE L no son descendientes de ninguna tarea; corren aunque toda la cadena quede congelada.

### 5.2 FASE 0 (orquestador; abre el log antes de medir nada)

1. `mkdir -p 50_documentacion/andamios/logs && ` crear el log con encabezado (meta, fecha, repo y rama, hash de HEAD, ENTORNO, grafo copiado de §5.1, plan de concurrencia de §1.1, topes de §1.4) y el slot `## J. Juicio (lo rellena FASE L)` vacío, más los bloques vacíos de §4.1 y §4.2 del log.
2. PUNTO DE RETORNO: `git fetch --quiet && git status --porcelain && git stash list && git rev-parse --short HEAD origin/main`. Condiciones 1 y 2 de §1.2.
3. Hooks: `git config core.hooksPath` y lectura del hook de pre-push antes de cualquier commit.
4. Mediciones con pre-registro (`esperado:` escrito antes de correr; `obtenido:` literal después):
   - `esperado: true` → `grep -E '^sesion_abierta:' 50_documentacion/activa/ESTADO.md`.
   - `esperado: 4 archivos presentes` → `ls -l 50_documentacion/andamios/lab_motor_v9/a2_consultas_evaluacion.csv 50_documentacion/andamios/lab_motor_v9/a2_consulta_pagefind.mjs 50_documentacion/andamios/lab_motor_v9/vocabulario.json 50_documentacion/andamios/lab_motor_v9/a1_alias_prueba.csv`. Si `a2_consultas_evaluacion.csv` falta, reconstruirlo desde la sección correspondiente de `50_documentacion/andamios/20260904_alcance_capa2_semantica_v1.md` (versionado) y dejar constancia.
   - `esperado: 0` → `git ls-files 50_documentacion/andamios/lab_motor_v9/ | wc -l`.
   - `esperado: ignorado` → `git check-ignore -v 50_documentacion/andamios/lab_motor_v9/vocabulario.json` (el árbol está limpio con 128 archivos no versionados, así que alguna regla los ignora; la línea exacta va al log porque T5 la reemplaza). Si no está ignorado, condición 1 de §1.2 no se cumple y la sesión se detiene.
   - `esperado: 128` → `find 50_documentacion/andamios/lab_motor_v9 -type f | wc -l`.
   - `esperado: presente` → `ls -l 50_documentacion/andamios/20260909_integracion_revision_externa_v1.md`.
   - `esperado: 1 archivo` → `test -f "$HERRAMIENTAS_DEV_PATH/plantillas/10_locale.R" && echo 1`.
   - `esperado: 2 líneas en 31_extraer_texto.R, 0 en 10_configuracion.R` → `grep -n 'REGEX_FICHA_ORIGEN\|REGEX_PIE_ORIGEN' 30_procesamiento/31_extraer_texto.R 10_utils/10_configuracion.R`.
   - `esperado: 47` → `find 40_salidas/sitio -name '*.html' | wc -l` (regenerar antes con `bash -c 'Rscript 00_run_all.R'` si `40_salidas/sitio/` no existe, y registrar que se regeneró).
   - `esperado: ruta del flujo de CI` → `ls .github/workflows/`.
   - `esperado: 1` → `grep -c 'data-pagefind-body' 30_procesamiento/34_generar_paginas.R` o el atributo equivalente que declare el contenedor de indexación (leer el archivo; si el contenedor se declara de otra forma, registrar cuál).
   - `esperado: los encabezados de artículo se emiten como HTML crudo o dentro de un bloque que el índice de Quarto no recorre` → lectura de `34_generar_paginas.R` y de `40_salidas/sitio_src/<slug>.qmd`, con el slug de `dfl_1` leído de `40_salidas/datos/catalogo.json` en R, no compuesto a mano, con las líneas literales en el log. Es la hipótesis de causa de P2; si es otra, registrarla antes de T1.
   - `esperado: 220` → conteo en R de encabezados con `id` en el HTML publicado de `dfl_1` (`rvest`, selector `h1[id], h2[id], h3[id], h4[id]` dentro del articulado).
   - `esperado: valor medido` → 🔒7 (`git ls-files | grep -E '\.(csv|json|xlsx|parquet|rds|txt)$' | grep -vcE '^40_salidas/datos/'`); el valor obtenido pasa a ser el esperado de FASE R.
   - Copias previas para 🔒1 y 🔒4: se generan **después de T4**, en la primera acción de la Ola 2, con `esperado: 806` y `esperado: 47 páginas`; FASE 0 solo registra que quedan pendientes de T4.
5. Anexar la sección `### FASE 0` al log.

### 5.3 T4: Instrumento versionado (Ola 1, subagente de escritura)

**Meta:** que cualquier cambio futuro del buscador o del generador sea demostrable con dos comandos versionados.

**ALCANCE:** `tests/consultas_evaluacion.R`, `tests/medir_buscador.R`, `tests/consulta_pagefind.mjs`, `tests/inventario_anclas.R`.

**Pasos:**

1. Paso 0: leer `20260908_medicion_correcciones_v1.md` (instrumentos transcritos), `lab_motor_v9/a2_consultas_evaluacion.csv` y `lab_motor_v9/a2_consulta_pagefind.mjs`. No modificar sin leer.
2. `tests/consultas_evaluacion.R`: `tibble::tribble()` con las diez consultas históricas (columnas de §2.3) más 3 a 5 consultas de clase `sin_respuesta` (temas que el corpus no contiene y que el equipo podría preguntar: licencia de conducir, contrato de un docente, pensión alimenticia; `ancla_esperada = NA`). Validez de lectura: `stopifnot(nrow(x) == 10L + n_sin_respuesta)`.
3. `tests/consulta_pagefind.mjs`: copia del runner del laboratorio, con las rutas parametrizadas por argumento (ruta del sitio, consulta). Devuelve JSON crudo: por resultado, URL, `id` de sub-resultado y puntaje. Nada más en JS.
4. `tests/medir_buscador.R`: llama al runner por consulta con `system2("node", ...)`, aplica en R el mismo orden y tope que `busqueda.html` (leyendo esos parámetros desde `10_utils/10_configuracion.R` cuando T2 los centralice; hasta entonces, desde constantes nombradas en el propio script con `# REVISAR: leer de 10_configuracion.R tras T2`), y reporta: `resueltas: N de 10` con tabla consulta por consulta (posición del ancla esperada o `ausente`), MRR sobre las diez, cobertura del conjunto de anclas por consulta (adopción B-18), recall@K de la lista cruda para K en {30, 65, 100} (adopción A-07), y para la clase `sin_respuesta` si la lista devuelta fue vacía. Argumento `--modo replica` que reproduce el bundle anterior al v10 para calibración (el v10 lo hizo; fuente: `traspaso_cierre_v03.md` §4.2).
5. `tests/inventario_anclas.R`: cuenta segmentos con ancla y destinos que resuelven, imprime `segmentos_con_ancla:` y `destinos_resueltos:` y escribe `50_documentacion/andamios/lab_motor_v9/salida_v11/ids_por_pagina.txt` (conjunto ordenado de `id` por página, una línea por `id`, con validez de lectura sobre el número de páginas); con `--previo` escribe `ids_por_pagina_previo.txt`.

**Criterio de éxito y calibración:**

- `Rscript tests/medir_buscador.R --sitio 40_salidas/sitio` → `esperado: resueltas: 3 de 10`; en `--modo replica` → `esperado: 1 de 10` (caso malo conocido: el instrumento debe reproducir la línea base del v9). Si el sitio actual no da 3, condición 4 de §1.2.
- Control positivo adversarial del instrumento: en una copia temporal de `tests/consultas_evaluacion.R` fuera del árbol, cambiar el ancla esperada de una de las tres resueltas por un `id` existente pero incorrecto; `esperado: resueltas: 2 de 10`. Un instrumento que siga diciendo 3 está roto.
- `Rscript tests/inventario_anclas.R` → `esperado: segmentos_con_ancla: 806` y `destinos_resueltos: 848 de 848`; control positivo: sobre una copia temporal del sitio con un `id` borrado a mano de una página, `esperado: 805` y un destino sin resolver. Si el sitio real no da 806 y 848, condición 5 de §1.2.
- Clase `sin_respuesta`: `esperado: al menos una de ellas devuelve resultados` (el estado vacío no existe todavía; es la línea base que el v12 corregirá). Se registra; no bloquea.

**Cierre de fase:** verificación, regresión (los tres comandos de PRUEBAS; el de anclas es el propio instrumento recién creado), alcance, commit `feat(tests): instrumento de evaluación del buscador y de anclas (T4)`, push, CI por `head_sha`, sección del log.

### 5.4 T6: Verificaciones de lectura D4 y D8 (Ola 1, subagente de lectura)

**Meta:** cerrar dos dudas de la compuerta con evidencia, sin escribir en el árbol.

**ALCANCE:** ninguno (solo lectura; el orquestador anexa el resultado al log).

- **D4:** ejecutar el mecanismo del hook de pre-push (el que lee `50_datos_versionados_autorizados.md`) en seco sobre diez rutas señuelo: cinco bajo `40_salidas/datos/` (dos niveles, `relaciones.json` incluido) y cinco fuera (`20_insumos/x.csv`, `50_documentacion/andamios/lab_motor_v9/vocabulario.json`, `tests/x.csv`, `10_utils/x.rds`, `40_salidas/intermedios/extraccion.json`). `esperado: 5 aceptadas, 5 rechazadas`, con la salida literal.
- **D8:** `diff "$HERRAMIENTAS_DEV_PATH/plantillas/10_locale.R" 10_utils/10_locale.R | wc -l` → `esperado: 0`; y ejercicio deliberado de la falla: en un proceso R aparte, forzar un locale no UTF-8 (`Sys.setlocale("LC_CTYPE", "C")`) y llamar a la guarda; `esperado: error con el mensaje de la guarda`. Sin tocar el archivo.

**Cierre de fase:** no toca código (declararlo); sección del log con ambas evidencias; sin commit propio.

### 5.5 T1: Índice lateral de las páginas de norma (Ola 2, subagente de escritura)

**Meta:** que el índice lateral de cada página de norma liste sus encabezados con `id`, sin cambiar ningún `id`, sin sacar nada del contenedor que Pagefind indexa y sin cambiar el texto.

**ALCANCE:** `30_procesamiento/34_generar_paginas.R`, `_quarto.yml`, `30_procesamiento/34_plantillas_sitio/estilo.css` (solo para la regla de desplazamiento del índice, si Quarto no la trae).

**Pasos:**

1. Paso 0: leer `34_generar_paginas.R` completo y el `.qmd` generado de `dfl_1` y de una norma corta; confirmar o refutar la causa registrada en FASE 0.
2. Antes de tocar nada, las copias previas para 🔒1 y 🔒4 (primera acción de la ola; ver §5.2 punto 4, último ítem).
3. Ambigüedad 6: medir en R si los JSON de `40_salidas/datos/normas/*.json` declaran estructura por encima del artículo (campo de título, capítulo o párrafo); registrar cuántas normas la declaran. Con estructura: nivel 2 estructura, nivel 3 artículo; sin ella, nivel 2 artículo. `toc-depth` en `_quarto.yml` acorde.
4. Cambiar en `34_generar_paginas.R` la emisión de los encabezados de artículo para que el índice de Quarto los recorra, **manteniendo** el `id` que produce `slugificar()` (explícito en el encabezado) y **manteniendo** el encabezado dentro del contenedor de indexación. Si la solución exige sacar los encabezados del contenedor, la tarea se congela: el índice dejaría de contener los números de artículo y las consultas por número retrocederían (condición 8 de §1.2 por alcance de diseño, registrada como duda con pregunta cerrada).
5. Regenerar por pipeline. Nada a mano.
6. Si el índice poblado no se desplaza dentro del panel lateral (Quarto trae `overflow-y` en el margen; hipótesis, se mide con `getComputedStyle` en la página de `dfl_1` a 1280 px), agregar solo la regla de desplazamiento en `estilo.css`. Ninguna otra regla: no es un rediseño.

**Criterio de éxito y calibración:**

- Índice lateral de `dfl_1`: `esperado: tantas entradas como encabezados con id medidos en FASE 0 (220, hipótesis)`, contadas en R sobre el HTML publicado (`nav#TOC a` o el selector que Quarto use, medido). Caso bueno: una norma corta con todos sus encabezados. Caso malo plantado: en una copia temporal fuera del árbol, una página con un encabezado sin `id`; el conteo de entradas del índice debe diferir del de encabezados con `id`, y la comparación debe decirlo.
- 🔒1: `diff` de `ids_por_pagina.txt` contra la copia previa → `esperado: 0 líneas`.
- 🔒4: `esperado: paginas_distintas: 0`.
- 🔒8 y PRUEBAS del buscador: `esperado: resueltas: 3 de 10, las mismas tres`. Si Pagefind dejó de indexar los encabezados (consultas por número de artículo retroceden), condición 7 de §1.2.
- Peso de la página de `dfl_1` antes y después (`wc -c`): se registra; un aumento mayor a 20 % (constante `TOLERANCIA_PESO_PAGINA <- 0.20` en el comando) es hallazgo ADVIERTE, no bloquea.

**Cierre de fase:** verificación, regresión (PRUEBAS completo), alcance, commit `fix(sitio): índice lateral con los encabezados de artículo (T1, P2)`, push, CI por `head_sha`, sección del log.

### 5.6 T5: Cierre de los cuatro huecos de P7 (Ola 2, subagente de escritura)

**Meta:** que ningún residuo del v10 sobreviva, con los cuatro cierres en la tabla de este encargo.

**ALCANCE:** `10_utils/10_configuracion.R`, `30_procesamiento/31_extraer_texto.R`, `CLAUDE.md` (§10.1 y §10.6), `.gitignore`, `50_documentacion/andamios/lab_motor_v9/**/*.R` y `**/*.md` (solo `git add`), `50_documentacion/andamios/20260908_encargo_correcciones_visibles_v1_enmiendas.md`, más el movimiento autorizado de `40_salidas/intermedios/extraccion.json`.

**Pasos:**

1. **Hueco 1, regex.** Mover `REGEX_FICHA_ORIGEN` y `REGEX_PIE_ORIGEN` de `31_extraer_texto.R` a `10_utils/10_configuracion.R`, valor idéntico byte a byte (registrar ambas definiciones antes y después). Forzar el reprocesamiento: `md5sum 40_salidas/intermedios/extraccion.json` al log, `mv` autorizado, `bash -c 'Rscript 00_run_all.R'`. `esperado: 25 documentos reextraídos, 0 reutilizados` (el pipeline lo imprime; fuente: `traspaso_cierre_v03.md` §6). Después: 🔒3 `git diff --stat -- 40_salidas/datos/` → `esperado: vacío` (el cambio es de ubicación, no de valor). Caso malo conocido para calibrar el conteo de reprocesados: sin mover el archivo, el pipeline dice `25 reutilizados`; se corre primero así y se registra.
2. **Hueco 2, `CLAUDE.md`.** §10.1: «24 PDF oficiales» pasa a «25 PDF oficiales» solo si `ls 20_insumos/normativa/*.pdf | wc -l` da 25 (`esperado: 25`; si da 24, la cifra correcta es 24 y el sitio publica 25 normas por otra razón que se registra como duda, sin editar). §10.6: dos filas nuevas, una por sesión, escritas desde `traspaso_cierre_v02.md` (en `50_documentacion/traspasos/archivo/`, hipótesis; medir con `ls`) y `traspaso_cierre_v03.md`, con las rutas de sus encargos y logs. Sin adjetivos; una fila por sesión, formato de las existentes.
3. **Hueco 3, laboratorio e instrumentos.** `.gitignore`: si la regla medida en FASE 0 ignora la carpeta entera, se reemplaza por reglas que excluyan de `50_documentacion/andamios/lab_motor_v9/` las extensiones `csv`, `json`, `txt`, `bak`, `rds` y `mjs`, más la subcarpeta `salida_v11/` completa; ninguna otra línea de `.gitignore` se toca y el `git diff` del archivo va al log. Luego `git add` solo de los `.R` y `.md` del laboratorio: `esperado: N archivos añadidos` donde N es `find lab_motor_v9 -type f \( -name '*.R' -o -name '*.md' \) | wc -l` medido antes. Verificar con `git status --porcelain 50_documentacion/andamios/lab_motor_v9/ | grep -vE '\.(R|md)$'` → `esperado: vacío`. El `.R.bak` no se versiona ni se borra. La prueba de señuelos del hook (T6) es la calibración de que ningún dato entra.
4. **Hueco 4, enmienda del v10.** Crear `20260908_encargo_correcciones_visibles_v1_enmiendas.md` con: la enmienda de §3 tal como consta en `logs/20260908_correcciones_visibles_v10_log.md` (transcrita, con la ruta y el número de línea del log), las seis condiciones bajo las que se amplió, y la desviación declarada del patrón del hook (`traspaso_cierre_v03.md` §4.6). No se edita el encargo original.

**Criterio de éxito y calibración:** los cuatro comandos `esperado:` anteriores más `grep -c 'REGEX_FICHA_ORIGEN\|REGEX_PIE_ORIGEN' 30_procesamiento/31_extraer_texto.R` → `esperado: solo usos, ninguna definición` (registrar el número de usos) y en `10_configuracion.R` `esperado: 2 definiciones`.

**Cierre de fase:** verificación, regresión (PRUEBAS completo, porque tocó el extractor), alcance, commit `chore(instrumental): cierre de los cuatro huecos de P7 (T5)`, push, CI por `head_sha`, sección del log.

### 5.7 T2: Expansión de la consulta (Ola 3, un subagente de escritura o el orquestador)

**Meta:** que el buscador resuelva consultas en el lenguaje del equipo sin que retroceda ninguna de las que hoy resuelve, con toda constante en R.

**ALCANCE:** `30_procesamiento/34_plantillas_sitio/busqueda.html`, `10_utils/10_configuracion.R`, `30_procesamiento/34_generar_paginas.R`.

**Pasos:**

1. Paso 0: leer `busqueda.html` (interfaz propia del v10), `10_configuracion.R` (ya con las regex de T5), `lab_motor_v9/a1_alias_prueba.csv` y `vocabulario.json`.
2. **Mediciones previas con pre-registro** (sobre el sitio de T1, sin publicar):
   - D7: correr las 7 consultas perdidas con expansión manual por los alias del laboratorio contra el índice actual (runner de T4). `esperado: 5 de 7 recuperan la página correcta` (predicado de D7). Se registra el valor real; T2 sigue en cualquier caso, porque el mecanismo vale por sí mismo, pero el criterio de 6 de 10 se reevalúa: si D7 da menos de 3 de 7, el criterio pasa a `mejora pareada sin retroceso` y se declara en el log antes de implementar.
   - A-18: cada una de las diez consultas con y sin tildes; `esperado: mismo conjunto de páginas`. Si difiere, la normalización NFD sin marcas combinantes y a minúsculas entra a la expansión.
   - A-19: las 25 normas consultadas en tres formas del número («ley 20536», «ley 20.536», «20.536»); `esperado: top-1 igual en las tres formas para las 25`. Si alguna forma pierde, se emite un metadato indexable con las tres formas desde `34_generar_paginas.R` y se normaliza la consulta; si ninguna pierde, no se toca el generador y se registra.
   - B-06: las diez consultas con y sin sus palabras vacías («de», «la», «en», «el», «para»); `esperado: mismo conjunto`. Si Pagefind no las ignora, la lista de palabras vacías entra como constante en R y se eliminan de la consulta antes de buscar.
3. **Constantes en R (`10_configuracion.R`):** `TOPE_SUB_RESULTADOS` (5, hoy en el cuerpo de `busqueda.html`; fuente: `traspaso_cierre_v03.md` §9), `ALIAS_CONSULTA` (tibble con `termino`, `alias`, `fuente = "v9_construido"`, solo filas ya existentes en el laboratorio; ninguna inventada), `PALABRAS_VACIAS_CONSULTA` (si B-06 lo exige). `34_generar_paginas.R` escribe desde ellas un artefacto que `busqueda.html` consume (JSON incrustado en la plantilla o archivo junto al sitio; decidir por lo que el generador ya hace con la plantilla, registrar la elección). Ningún JSON de alias se edita a mano.
4. **Mecanismo en `busqueda.html`:** normalizar la consulta (A-18 si aplica; B-06 si aplica); construir las variantes por alias; ejecutar la consulta original y cada variante contra la API de Pagefind; unir por página conservando el mejor puntaje; la consulta original conserva precedencia ante empate (piso R0, adopción A-08 en su parte aplicable). El orden y el tope siguen siendo los del v10, ahora leídos de las constantes.
5. Regenerar por pipeline. Medir con `tests/medir_buscador.R`, que desde T2 lee las constantes de `10_configuracion.R` (quitar el `# REVISAR` de T4 y registrar que se quitó).

**Criterio de éxito y calibración:**

- `esperado: resueltas: 6 de 10 o más, y las 3 históricas entre ellas` (🔒8). La cifra de ingeniería es 6; la medida que decide es la pareada: ninguna retrocede, y el log lista una por una cuáles de las 7 se resolvieron. Nota metodológica, del insumo de diseño: 3 frente a 6 de 10 no es distinguible estadísticamente (p = 0,3698, prueba exacta de Fisher, recalculada en la sesión 4); no se afirma «mejora significativa», se afirma la tabla.
- Caso malo plantado: un alias adversarial en una copia temporal de `ALIAS_CONSULTA` fuera del árbol («artículo» → «página») debe hacer retroceder al menos una de las tres históricas en la copia; si el instrumento no lo ve, está roto.
- Caso bueno: con `ALIAS_CONSULTA` vacío, `esperado: 3 de 10`, idéntico a T1.
- Clase `sin_respuesta`: se registra qué devuelve tras la expansión; `esperado: la expansión no convierte una consulta sin respuesta en una con resultados espurios` (ninguna de ellas pasa de vacío a no vacío por un alias). Si ocurre, el alias responsable se retira y se registra.
- Latencia: tiempo de la búsqueda con y sin expansión sobre las diez, medido en el runner; se registra (adopción A-17 se acepta en v12; aquí solo la cifra).

**Cierre de fase:** verificación, regresión (PRUEBAS completo), alcance, commit `feat(buscador): expansión de consulta con alias y constantes centralizadas (T2, P1)`, push, CI por `head_sha`, sección del log.

### 5.8 T7: Fila de `CLAUDE.md` §10.6 para este encargo (orquestador, serie)

**ALCANCE:** `CLAUDE.md` (§10.6, una fila). Escrita desde el estado real por tarea (completada o congelada, con hashes de `git log`), no desde lo planeado. Commit `docs(claude): fila de la sesión 4, encargo v11 (T7)`, push, CI.

---

## 6. FASE R: Auditoría propia y reparación (penúltima, obligatoria)

Corre siempre, después de la última tarea de la cadena (congeladas incluidas) y antes de FASE L. Regla de oro: la reparación cambia el trabajo, nunca el criterio, la tolerancia, el valor esperado ni la meta.

1. **Inventario de afirmaciones auditables**, derivado del log y no de la memoria: cada línea `Verificación:` y cada cifra de las secciones por fase, cada 🔒 de §4 con su comando, y el alcance global. Numerado `R-01`, `R-02`, ..., anexado al log **antes** de auditar nada. Lo que no está en el inventario no se auditó.
2. **Re-derivación independiente:** cada afirmación se re-deriva con un comando distinto del que la produjo (una cifra de `medir_buscador.R` se re-deriva contando en el JSON crudo del runner; el conteo de anclas, con `grep -o 'id="' | wc -l` sobre el HTML contra el conteo de `rvest`). Riesgo de cifras e invariantes presente: un subagente de lectura (dentro del tope de 2) re-deriva las de mayor riesgo (🔒1, 🔒3, 🔒4, 🔒8) recibiendo la afirmación y el repositorio, no el razonamiento ni el código que las produjo.
3. **Invariantes 🔒:** el comando de cada uno de los ocho de §4, PASA/FALLA con salida literal.
4. **Chequeo global de alcance:** `git diff --name-only <PUNTO DE RETORNO>..HEAD` ⊆ unión de los ALCANCE de §1.3 más el log; y `git status --porcelain` (lo no commiteado es hallazgo, no se limpia).
5. **Regresión completa:** los tres comandos de PRUEBAS sobre el estado final, con `esperado:` y `obtenido:`.
6. **Control positivo de la propia auditoría:** al menos una afirmación se audita además con un caso plantado (una cifra alterada en una copia temporal del log fuera del árbol; un archivo fuera de alcance simulado en un diff de prueba). Una auditoría que solo confirmó no auditó.
7. **Veredicto por hallazgo, con severidad:** **BLOQUEA** (gobernanza de datos, 🔒 en FALLA, datos alterados, alcance violado, historia divergente: no se repara, se congela la tarea de origen y se registra como duda con pregunta cerrada; si compromete el repositorio completo, se detiene la sesión y se pasa a FASE L); **REPARA** (defecto del propio trabajo, dentro del ALCANCE, sin tocar un 🔒, con verificación calibrada disponible: se corrige en el paso 8); **ADVIERTE** (sin efecto sobre la meta ni los invariantes, o riesgo no medible en esta sesión: se registra, no se corrige). «0 hallazgos» se declara junto con el control positivo del paso 6, o no se declara.
8. **Ciclo de reparación, máximo 2 ciclos.** Por cada REPARA: (a) causa raíz, no síntoma; (b) fix quirúrgico dentro del ALCANCE; (c) re-verificación con el mismo chequeo que lo detectó, que ahora debe pasar, **y** con uno distinto; (d) regresión; (e) commit propio `fix(auditoria): R-NN <hallazgo>`; (f) fila en la tabla de auditoría. Cerrado el ciclo, se repiten los pasos 2 a 5 sobre lo tocado. Un hallazgo que sobrevive al segundo ciclo, o cuya reparación destapa uno nuevo en otra parte, se congela y se registra como pendiente.
9. **Prohibiciones de la fase:** ajustar un criterio, una tolerancia o un valor esperado para que pase; ampliar un ALCANCE; tocar un 🔒; borrar o editar evidencia ya escrita en el log; reparar un BLOQUEA; lanzar la reparación en un subagente sin que el orquestador la verifique.
10. **Salida:** la **tabla de auditoría** en el log con las columnas fijas `id | afirmación | comando de re-derivación | esperado | obtenido | severidad | acción | commit | re-verificación`, y el **veredicto global**: `APROBADO`, `APROBADO CON ADVERTENCIAS`, `OBSERVADO` (REPARA abiertos tras dos ciclos) o `BLOQUEADO`. El veredicto va al bloque J.

---

## 7. FASE L: Cierre del log (última, obligatoria)

Corre siempre, también con tareas congeladas, con FASE R en `BLOQUEADO` o tras una detención de sesión.

1. **Estado del árbol antes de tocar el log:** `git status --porcelain` → esperado vacío, o solo el propio log. Otra cosa es hallazgo: se anota en la sección de cierre y no se «limpia».
2. **Cierre del log:** completar las secciones consolidadas (resumen; inventario de commits derivado de `git log <PUNTO DE RETORNO>..HEAD --oneline`, una línea por commit rotulada con su fase; tabla de auditoría; verificación de invariantes; decisiones del usuario registradas; estado de cifras críticas; dudas y pendientes consolidados con su pregunta cerrada intacta; errores propios consolidados; notas para el revisor; estado de cierre). Las secciones por fase no se reescriben ni se resumen.
3. **Bloque J:** rellenar el slot reservado en FASE 0 con los doce campos fijos, una línea por campo, copiando del detalle (hashes de `git log`, conteos de la tabla de auditoría), nunca de memoria:

```markdown
## J. Juicio
- Meta y resultado: <qué se pidió> → <cumplida | parcial | no cumplida>, en una línea.
- Estado por tarea: T4 · T6 · T1 · T5 · T2 · T7, cada una completada (<hash>) | congelada (<condición>) | no ejecutada (depende de ...).
- Commits: <N>, rango <hash_inicial>..<hash_final>, de los cuales <k> fix(auditoria).
- Auditoría (FASE R): <veredicto>; hallazgos B/R/A = <b>/<r>/<a>; reparados <n>; abiertos <m> (<ids>).
- Invariantes: <n>/8 PASA; FALLA: <nombres o ninguno>.
- Cifras críticas: 806 / 848 / 47 / 3 de 10 antes → N de 10 después: <intactas o alteradas, con evidencia>.
- Decisiones autónomas de mayor riesgo: hasta 3, irreversibles primero, cada una con la alternativa descartada.
- Desviaciones respecto del encargo: <dónde difiere | ninguna>.
- Dudas abiertas: <N>; las 3 más bloqueantes con su pregunta cerrada.
- Errores propios: <N> registrados; los que costaron más de un turno.
- Qué debe verificar el revisor por sí mismo: <lo no medible con independencia en esta sesión>.
- No publicado / queda al usuario: <push retenido, decisión pendiente | nada>.
```

4. **Grep de privacidad sobre el log:** `grep -nE '[0-9]{1,2}\.?[0-9]{3}\.?[0-9]{3}-[0-9kK]' 50_documentacion/andamios/logs/20260909_indice_y_expansion_v11_log.md` → esperado vacío; lectura del archivo para confirmar que no contiene filas de datos ni nombres de personas. Un hit se reemplaza por un conteo o un hash antes del commit y la sustitución se declara.
5. **Verificación observable del archivo:** `ls -l <LOG> && wc -l <LOG>`; `grep -c '^### FASE' <LOG>` igual al número de fases ejecutadas (FASE 0, T4, T6, T1, T5, T2, T7, FASE R: 8 si ninguna quedó sin ejecutar; congeladas incluidas); `grep -c '^esperado:' <LOG>` igual a `grep -c '^obtenido:' <LOG>`; `grep -c '^## J' <LOG>` = 1 con el bloque relleno. Si un conteo difiere, se anexa la sección o línea faltante con su estado real; no se ajusta el conteo.
6. **Commit propio y siempre:** `git add 50_documentacion/andamios/logs/20260909_indice_y_expansion_v11_log.md` (solo el log) y `git commit -m "docs(log): encargo v11, índice lateral y expansión de consulta"`; push autorizado, viaja.
7. **Estado de cierre declarado:** qué quedó commiteado, qué NO se publica y qué queda al usuario, con `git log -1 --format=%h` del commit `docs(log)`.

---

## 8. Reporte final (en el chat)

1. **Primera línea, sin excepción:** la salida literal de `ls -l <LOG> && wc -l <LOG>` y el hash del commit `docs(log)`.
2. **Segundo bloque:** el bloque J copiado tal cual del log.
3. Después: `resueltas: N de 10` antes y después con la tabla consulta por consulta; índice lateral de `dfl_1` (entradas frente a encabezados con `id`); los cuatro huecos de P7 con su evidencia; D4, D7 y D8 con su valor; hashes y estado de CI por `head_sha`; pendientes y `# REVISAR`; y «lo que falló o sorprendió; si nada, decirlo explícitamente».

Nada más en el chat. El detalle vive en el log.

---

## 9. Contrato de subagentes (ocho reglas, vigentes en todo el encargo)

1. **Tope:** 2 subagentes simultáneos, de cualquier rol, panel de lectura de FASE R incluido. El orquestador no cuenta, no se reemplaza y no se delega.
2. **Dos roles, y ninguno más.** *Lectura:* medir, re-derivar, auditar, buscar; sin escritura en el árbol. *Escritura:* implementar una tarea dentro de su ALCANCE; sin git, sin log, sin borrar, sin lanzar subagentes.
3. **Olas:** solo corren en paralelo tareas independientes en el grafo de §5.1 y con ALCANCE disjunto (§1.1). Dentro de una ola nadie commitea; el orquestador espera a la ola entera, verifica cada retorno (regla 5) y commitea por tarea, en orden del grafo, con las rutas explícitas de cada ALCANCE.
4. **Lo que recibe cada subagente:** la tarea con su criterio de término y su ALCANCE, los 🔒 de §4 con su porqué, la POSICIÓN (rutas desde la raíz, `bash` explícito, `Rscript`), la prohibición literal de Python (§1.5), la regla «sin git, sin borrar, nada fuera de ALCANCE, ante duda detente y devuelve», y el formato de retorno: rutas tocadas (lista), comandos corridos con salida literal, `esperado:` / `obtenido:` de su verificación, dudas con pregunta cerrada. Nunca recibe autorizaciones destructivas ni el derecho a ampliar su alcance.
5. **Su retorno es hipótesis.** El orquestador verifica con comando propio antes de commitear: `git diff --name-only` contra la lista de rutas declarada (idénticas), el chequeo de la tarea y la regresión. «Listo» sin evidencia es tarea no hecha. Un subagente que tocó fuera de su ALCANCE congela la tarea: sus cambios no se commitean y el hecho va al log como hallazgo de alcance.
6. **Sin anidamiento.** Un subagente no lanza subagentes.
7. **Fallo de subagente.** Un reintento con el mismo contrato; al segundo fallo la tarea la hace el orquestador en serie, o se congela. Nunca se relanza con un contrato más laxo.
8. **Registro.** La sección de log de cada tarea lleva `Subagentes:` (rol, ALCANCE, qué devolvió, con qué comando lo verificó el orquestador). Lo que un subagente devolvió y el orquestador no verificó entra al log como duda, no como hecho.

---

## 10. Lo que este encargo deja fuera, con razón

- **P3, P4, P5, P6:** exigen delegación registrada de escritura en `20_insumos/` o al equipo de convivencia (gate del titular).
- **P8 (huella de caché con versión de código):** deuda real; queda para el v12 con la regla generalizada de A-11, porque su corrección toca `30_manifiesto_corpus.R` y el criterio de reprocesamiento, y este encargo ya fuerza un reprocesamiento controlado en T5 que sirve de línea base.
- **Salidas estáticas visibles (B-03, B-08, B-14, B-15, A-20, B-09):** v12, por orden de construcción decidido en la integración (§5 pregunta 4).
- **Especificación v2 del motor:** redacción, no ejecución; tarea de sesión.
- **D1, D2, D3, D5, D6:** D1 y D6 exigen al equipo o al titular; D2 exige 30 consultas nuevas que serían construidas (misma objeción que A-15); D3 exige un teléfono real (v12); D5 es cruce documental que no cabe en un encargo de producto.
- **Decisiones D-A a D-D de la integración:** del titular.
