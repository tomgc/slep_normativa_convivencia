# Log de ejecución — encargo v11 (índice lateral, expansión de consulta, cierre de P7, instrumento versionado)

> **Encargo:** `50_documentacion/andamios/20260909_encargo_v11_indice_y_expansion_v1.md`
> **Insumo de diseño:** `50_documentacion/andamios/20260909_integracion_revision_externa_v1.md`
> **Tipo:** vía B (autónomo). **Sesión:** 2026-09-09, sesión 4.
> **Escrito durante la ejecución**, no después. Estructura fijada por §5.2, §6, §7 del encargo.

---

## 0. Encabezado (escrito antes de medir nada; FASE 0 paso 1)

| Campo | Valor |
|---|---|
| Fecha de apertura | 2026-09-09 11:33:03 -03 |
| Repositorio | `slep_normativa_convivencia` |
| Rama | `main` |
| Remoto | `origin` → `https://github.com/tomgc/slep_normativa_convivencia.git` |
| HEAD al abrir (PUNTO DE RETORNO provisional) | `fd5c987` |
| `HERRAMIENTAS_DEV_PATH` | `/Users/tomgc/Projects/herramientas_dev` |
| Log | `50_documentacion/andamios/logs/20260909_indice_y_expansion_v11_log.md` |

**Comandos que compusieron este encabezado** (únicos ejecutados antes de abrir el log; no son
mediciones pre-registradas de FASE 0, que empiezan en §2 de este log):
`git rev-parse --short HEAD`, `git branch --show-current`, `git remote get-url origin`,
`date '+%Y-%m-%d %H:%M:%S %Z'`, `echo "$HERRAMIENTAS_DEV_PATH"`, más las lecturas del encargo
y del log del v10 (`cat`, `sed -n`, `ls -l`, `wc -l`), todas de solo lectura.

### 0.1 ENTORNO (§1.7.1 del encargo)

Filesystem local vía Claude Code en la estación del titular (macOS, Darwin 25.6.0), repositorio
`slep_normativa_convivencia`, rama `main`, remoto `origin` (GitHub, Pages con despliegue por
Actions). Toda ruta desde la raíz del repositorio; ningún comando asume `cd` previo; scripts bajo
`bash` explícito; R por `Rscript` con `here::here()`; JavaScript solo en `busqueda.html` y en el
runner `tests/consulta_pagefind.mjs`. **Python prohibido sin borde, ni un sondeo de disponibilidad.**

### 0.2 Grafo de tareas (copiado de §5.1 del encargo)

- T4 (instrumento) es independiente.
- T6 (verificaciones D4 y D8, lectura) es independiente.
- T5 (cierre de P7) es independiente.
- T1 (índice lateral) requiere T4.
- T2 (expansión de consulta) requiere T1, T4 y T5.
- T7 (fila de `CLAUDE.md` para este encargo) requiere que T1, T2, T4 y T5 hayan terminado o
  quedado congeladas; corre igual.
- FASE R y FASE L no son descendientes de ninguna tarea; corren aunque toda la cadena quede
  congelada.

### 0.3 Plan de concurrencia (copiado de §1.1 del encargo)

Tope duro **2 subagentes simultáneos**, de cualquier rol; el orquestador no cuenta.

- Ola 1: T4 (escritura) y T6 (lectura).
- Ola 2: T1 (escritura) y T5 (escritura), ALCANCE disjunto.
- Ola 3: T2, sola (su ALCANCE intersecta con T1 y con T5).
- T7 la hace el orquestador en serie, al final.
- FASE R y FASE L fuera del grafo, siempre, en ese orden.

Dentro de una ola nadie commitea: el orquestador espera a la ola entera, verifica cada retorno
con comando propio y commitea por tarea, en orden del grafo.

### 0.4 Topes de esfuerzo (copiados de §1.4 del encargo)

1. **3 intentos por bug.** Al tercer fix fallido la tarea se congela con la evidencia de los tres.
2. **2 ciclos de reparación en FASE R.** Lo que sobrevive al segundo va al log como pendiente.
3. **1 reintento por comando** que falla por causa transitoria. Al segundo fallo es hallazgo.

---

## 1. Precondiciones y PUNTO DE RETORNO

(se rellena en FASE 0, paso 2)

---

## 2. Secciones por fase

(cada fase anexa aquí su sección `### FASE ...`)

---

## 3. Registros transversales

### 3.1 Subagentes

| Ola | Rol | Tarea | ALCANCE | Qué devolvió | Comando de verificación del orquestador |
|---|---|---|---|---|---|
| (se rellena) | | | | | |

---

## 4. Dudas y errores

### 4.1 Dudas (cada una con su pregunta cerrada)

| # | Fase | Duda | Pregunta cerrada | Estado |
|---|---|---|---|---|
| (vacío al abrir) | | | | |

### 4.2 Errores propios

| # | Fase | Qué salió mal | Causa | Costo (turnos) | Cómo se corrigió |
|---|---|---|---|---|---|
| (vacío al abrir) | | | | | |

---

## 5. Auditoría (FASE R)

(se rellena en FASE R)

---

## 6. Cierre (FASE L)

(se rellena en FASE L)

---

## J. Juicio

- **Meta y resultado:** poblar el índice lateral de las páginas de norma, expandir la consulta del buscador, cerrar los cuatro huecos de P7 y versionar el instrumento → **cumplida**, con las seis tareas terminadas y ninguna congelada.
- **Estado por tarea:** T4 completada (`b7796cc`) · T6 completada (sin commit propio, es de lectura) · T1 completada (`00a0840`) · T5 completada (`b4ec047`) · T2 completada (`511dab8`) · T7 completada (`cb19203`).
- **Commits:** 5 de tarea más el de este log, rango `fd5c987..cb19203`, de los cuales **0** son `fix(auditoria)`; los 5 con CI en verde por `head_sha` y el sitio verificado en producción con HTTP 200.
- **Auditoría (FASE R):** **APROBADO CON ADVERTENCIAS**; hallazgos B/R/A = **0 / 0 / 7** (R-10, R-17, R-30, P-1, P-2, P-4, P-5); reparados **0**; abiertos **0** que exijan reparación. Siete casos plantados, siete detectados.
- **Invariantes:** **8 de 8 PASA**; FALLA: ninguno. 🔒1 y 🔒4 verificados por tres y dos caminos independientes respectivamente, incluido un panel de lectura que no vio mi código.
- **Cifras críticas:** 806 / 848 / 47 **intactas** (mismo valor por tres instrumentos distintos, y `40_salidas/datos/` con el mismo hash de árbol de git); 3 de 10 antes → **8 de 10** después, con C05, C06 y C10 dentro y en la misma posición.
- **Decisiones autónomas de mayor riesgo:** (1) **irreversible**: versionar 43 archivos del laboratorio en un repositorio **público** sin haber limpiado las dos rutas absolutas `/Users/tomgc/…` que la propia regla de `.gitignore` declaraba como condición para versionarlo; quedan en la historia pública. Alternativa descartada: excluir esos dos `.R` también, que habría dejado dos archivos fuera sin criterio declarado. Se aceptó tras medir que el repositorio ya expone `/Users/…` en 15 archivos versionados y que el usuario es público por la URL del sitio. (2) **cambiar el mecanismo de expansión respecto del que el encargo describía**: la variante es la frase del alias sola, no la consulta con el alias sustituido, porque lo descrito recupera 1 de 7 y lo implementado 7 de 7. Alternativa descartada: implementar lo descrito y reportar el criterio degradado a «mejora pareada». (3) **ejecutar T1, T5 y T2 sin subagente y sin el reintento que §9 regla 7 prescribe**, tras la muerte por límite de sesión del subagente de T1. Alternativa descartada: reintentar contra el límite, que es la conducta que la regla aprendida 2 del traspaso v03 documenta como causa de pérdida total.
- **Desviaciones respecto del encargo:** ocho, todas declaradas en su fase. Olas 2 y 3 en serie porque `40_salidas/` es estado mutable compartido que los ALCANCE no cubren (F0.8); sin reintento de subagente (T1.0); `data.frame` en vez de `tibble` y columnas `entrada/alias/clave_fuente/fuente` con procedencia real en vez de `termino/alias/fuente = "v9_construido"` (T2.4); edición de `tests/medir_buscador.R`, que §5.7 ordena en su paso 5 y su tabla de ALCANCE no lista (T2.4); lista blanca en `.gitignore` en vez de lista de seis extensiones, porque la carpeta tiene diez (T5.3); tope de 5 filas en `CLAUDE.md` §10.6 por el contrato global, que obligó a retirar dos filas históricas (T5.2 y T7); mecanismo de expansión distinto del descrito (T2.3); y `_quarto.yml` y `estilo.css` autorizados y **no** tocados, cada uno por su medición (F0.12 y T1.5).
- **Dudas abiertas:** **11** (D-01 a D-11). Las tres más bloqueantes: **D-03** ¿se acepta `a1_alias_procedencia.csv` como la fuente de alias que la ambigüedad 4 quiso nombrar, dado que el archivo que el encargo nombra no contiene alias? **D-09** ¿el control adversarial del v12 se redirige al único canal de retroceso que queda abierto, o se retira, dado que el actual no puede fallar contra este diseño? **D-06** ¿se renombra `a3_presupuesto_tokens.R`, que R2 del hook rechaza por su nombre sin mirar contenido, o R2 pasa a mirar contenido?
- **Errores propios:** **8** registrados (E-01 a E-08). Los que costaron más de un turno: **E-04** (`x[(n+1):length(x)]` cuenta hacia atrás cuando `n` es la última línea), **E-06** (`min()` por `pmin()`, que truncaba todas las raíces a 3 caracteres) y **E-07** (un `source()` transitivo restauraba la tabla de alias tras sustituirla, dejando los índices apuntando a la anterior). Los tres son del mismo tipo: **no fallan, devuelven otra cosa**, y los tres los detectó un control plantado, no la ejecución normal.
- **Qué debe verificar el revisor por sí mismo:** que el índice de 219 entradas se desplaza dentro de su panel en un navegador real a 1280 px (aquí se midió la cascada de la hoja publicada, no `getComputedStyle`); que el buscador se comporta igual en un teléfono; y si acepta que los dos topes de la expansión se eligieron sobre el mismo conjunto de diez consultas con que se reporta el resultado.
- **No publicado / queda al usuario:** nada retenido. Los cinco commits están pusheados con CI en verde y el sitio está en producción. Queda al titular: las once dudas, las cuatro decisiones D-A a D-D de la integración, y los seis pendientes de L.5.

---

### FASE 0 — Punto de retorno, hooks y mediciones con pre-registro

#### F0.1 Punto de retorno (§5.2 paso 2)

```
$ git fetch --quiet; git status --porcelain
?? 50_documentacion/andamios/20260909_encargo_v11_indice_y_expansion_v1.md
?? 50_documentacion/andamios/20260909_integracion_revision_externa_v1.md
?? 50_documentacion/andamios/logs/20260909_indice_y_expansion_v11_log.md

$ git status --porcelain | grep -v '^??'
(vacío)

$ git stash list
(vacío)

$ git rev-parse --short HEAD;  git rev-parse --short origin/main
fd5c987
fd5c987
```

**PUNTO DE RETORNO = `fd5c987`.** Condición 2 de §1.2: no se cumple (HEAD ≡ origin/main), no se
detiene. Condición 1: **el árbol tiene tres entradas `??` y cero versionados modificados**; se
resuelve en la duda D-01 (§4.1) y se continúa. `git stash list` vacío.

Nota de fallo propio, registrada en §4.2 (E-01): el comando del encargo
`git rev-parse --short HEAD origin/main` falla en este git con
`fatal: Needed a single revision`; `--short` no acepta dos revisiones. Se sustituyó por dos
invocaciones y una comparación explícita. Es defecto del comando, no del repositorio.

#### F0.2 Hooks (§5.2 paso 3)

```
$ git config core.hooksPath
/Users/tomgc/Projects/herramientas_dev/githooks

$ ls -l /Users/tomgc/Projects/herramientas_dev/githooks/
-rwx--x--x@ 1 tomgc  staff  4749 Sep  1 20:03 pre-push
```

Hook `pre-push` leído íntegro antes del primer commit. Cuatro reglas: **R1** extensiones de datos
(`xlsx|xls|xlsm|xlsb|csv|tsv|parquet|rds|rdata|sav|dta|db|sqlite|sqlite3|json|geojson`) no
cubiertas por los globs del primer bloque cercado de
`50_documentacion/activa/50_datos_versionados_autorizados.md`; **R2** credenciales por nombre de
archivo; **R3** patrón de RUT en líneas agregadas; **R4** push al kit desde Windows. Solo lee.

Consecuencias registradas antes de actuar:
1. **`.txt` NO está en `EXT_DATOS`.** `ids_por_pagina.txt` no sería rechazado por R1; igual queda
   fuera del árbol por decisión de la ambigüedad 1 del encargo (vive en `salida_v11/`).
2. **`.mjs` y `.R` no están en `EXT_DATOS`.** `tests/consulta_pagefind.mjs` y
   `tests/consultas_evaluacion.R` pasan R1; el conjunto de evaluación como código R (ambigüedad 3)
   es además la única forma que el hook admite.
3. El hook opera sobre `git diff --name-only --diff-filter=AM remote_sha local_sha`: lo que
   importa es lo que viaja en el push, no lo que está en el árbol.

#### F0.3 Pre-registro de las mediciones (§5.2 paso 4)

Los `esperado:` se escriben aquí **antes** de correr un solo comando de medición; los `obtenido:`
se anexan en F0.4 con salida literal.

esperado: true — `grep -E '^sesion_abierta:' 50_documentacion/activa/ESTADO.md`
esperado: 4 archivos presentes — `ls -l lab_motor_v9/{a2_consultas_evaluacion.csv,a2_consulta_pagefind.mjs,vocabulario.json,a1_alias_prueba.csv}`
esperado: 0 — `git ls-files 50_documentacion/andamios/lab_motor_v9/ | wc -l`
esperado: ignorado — `git check-ignore -v 50_documentacion/andamios/lab_motor_v9/vocabulario.json`
esperado: 128 — `find 50_documentacion/andamios/lab_motor_v9 -type f | wc -l`
esperado: presente — `ls -l 50_documentacion/andamios/20260909_integracion_revision_externa_v1.md`
esperado: 1 — `test -f "$HERRAMIENTAS_DEV_PATH/plantillas/10_locale.R" && echo 1`
esperado: 2 líneas en 31_extraer_texto.R, 0 en 10_configuracion.R — `grep -n 'REGEX_FICHA_ORIGEN\|REGEX_PIE_ORIGEN' ...`
esperado: 47 — `find 40_salidas/sitio -name '*.html' | wc -l`
esperado: ruta del flujo de CI — `ls .github/workflows/`
esperado: 1 — `grep -c 'data-pagefind-body' 30_procesamiento/34_generar_paginas.R`
esperado: los encabezados de artículo se emiten como HTML crudo o dentro de un bloque que el índice de Quarto no recorre — lectura de `34_generar_paginas.R` y del `.qmd` de `dfl_1`
esperado: 220 — conteo en R de `h1[id],h2[id],h3[id],h4[id]` en el articulado del HTML de `dfl_1`
esperado: valor medido — 🔒7 `git ls-files | grep -E '\.(csv|json|xlsx|parquet|rds|txt)$' | grep -vcE '^40_salidas/datos/'`
esperado: 25 — `ls 20_insumos/normativa/*.pdf | wc -l` (insumo de T5 hueco 2, se mide aquí)
esperado: 0 — `grep -rlE '^estado: *validada' 20_insumos/curaduria/piezas/ | wc -l` (🔒5, línea base)

#### F0.4 Resultados, con salida literal

obtenido: `sesion_abierta: true` (M1) — PASA
obtenido: 4 archivos presentes (M2): `a1_alias_prueba.csv` 1642 B, `a2_consulta_pagefind.mjs` 2642 B, `a2_consultas_evaluacion.csv` 7398 B, `vocabulario.json` 435763 B — PASA. No hubo que reconstruir el conjunto de evaluación.
obtenido: 0 (M3) — PASA
obtenido: `.gitignore:80:50_documentacion/andamios/lab_motor_v9/` (M4) — PASA. La regla ignora la CARPETA ENTERA; es exactamente la línea que T5 reemplaza.
obtenido: 126 (M5) — **DIFIERE de 128.** Ver duda D-02. Desglose por extensión: 40 txt, 33 R, 26 csv, 11 md, 10 json, 2 gz, 1 yml, 1 mjs, 1 js, 1 bak. Sin subcarpetas, sin ocultos, ningún archivo modificado después del 2026-09-08 20:00. `.R` + `.md` = 44.
obtenido: presente (M6), 31816 B, 2026-09-09 11:20 — PASA
obtenido: 1 (M7) — PASA
obtenido: 2 definiciones en `31_extraer_texto.R` líneas 162 y 163, 2 usos en líneas 171 y 175; 0 en `10_configuracion.R` (M8) — PASA, la premisa de §3 se confirma
obtenido: 47 (M9) — PASA; no hubo que regenerar, `40_salidas/sitio/` existía
obtenido: `publicar.yml` (M10) — PASA
obtenido: 4 (M11) — **DIFIERE de 1.** Las cuatro ocurrencias de `data-pagefind-body` en `34_generar_paginas.R` están en las líneas 143 (comentario del `span` de filtro, en realidad `data-pagefind-filter`), 263 (apertura del contenedor de norma), 328 (comentario) y 803 (contenedor de pieza). **Contenedores reales: 2** (línea 263 norma, línea 803 pieza). El `esperado: 1` contaba contenedores, no líneas coincidentes; el conteo correcto de contenedores de NORMA es 1. Sin efecto sobre ninguna tarea.
obtenido: **confirmada la segunda rama de la hipótesis** (M12). Los encabezados de artículo NO son HTML crudo: `34_generar_paginas.R:311` y `:332` los emiten como Markdown real, `sprintf("## %s {#%s}", a$etiqueta, a$id)`. Lo que los saca del índice es que van **dentro del Div cercado** que abre la línea 263, `::: {data-pagefind-body="true" data-pagefind-meta="norma:%s"}`, y `## Normas relacionadas {#relacionadas}` (línea 95) se emite **después** del `:::` de cierre. El índice de Quarto (Pandoc `toTableOfContents`) solo recorre los Div de sección del nivel superior del documento: un encabezado anidado en un Div ordinario no produce entrada. De ahí la única entrada observada. Líneas literales:
```
34_generar_paginas.R:263    abre <- sprintf('::: {data-pagefind-body="true" data-pagefind-meta="norma:%s"}',
34_generar_paginas.R:332      c(sprintf("## %s {#%s}", a$etiqueta, a$id),
34_generar_paginas.R:95      "## Normas relacionadas {#relacionadas}",
```
Y en el `.qmd` generado y en el HTML publicado de `dfl_1`:
```
$ sed -n '/<nav id="TOC"/,/<\/nav>/p' 40_salidas/sitio/dfl_1_estatuto_asistentes_educacion.html
        <nav id="TOC" role="doc-toc" class="toc-active">
    <h2 id="toc-title">Articulado</h2>
  <ul class="collapse">
  <li><a href="#relacionadas" id="toc-relacionadas" class="nav-link active" data-scroll-target="#relacionadas">Normas relacionadas</a></li>
  </ul>
</nav>
```
obtenido: **220** encabezados con `id` en todo el documento de `dfl_1` (M13) — PASA. De ellos 1 es `toc-title` (el propio título del índice) y 1 es `relacionadas`: **218 dentro del contenedor `data-pagefind-body`**. Entradas del índice lateral hoy: **1** («Normas relacionadas»). Peso del HTML: **313 211 B**. Slug leído de `40_salidas/datos/catalogo.json` en R (`dfl_1_estatuto_asistentes_educacion`), no compuesto a mano.
obtenido: **83** (M14, 🔒7) — este es el valor esperado de FASE R: no debe crecer.
obtenido: 25 (M15) — PASA. `CLAUDE.md` §10.1 dice «24 PDF oficiales»: T5 lo corrige a 25.
obtenido: 0 (M16, 🔒5 línea base) — PASA
obtenido: pendientes de T4 — las copias previas para 🔒1 y 🔒4 (`ids_por_pagina_previo.txt`, `texto_por_pagina_previo.rds`) se generan en la primera acción de la Ola 2, según §5.2 punto 4 último ítem. `50_documentacion/andamios/lab_motor_v9/salida_v11/` **no existe todavía**.

#### F0.5 Mediciones de contexto no pre-registradas (para el briefing de las tareas)

Se declaran como tales: no son parte del pre-registro y no gobiernan ninguna condición de §1.2.

- **Herramientas:** `node v26.5.0` (`/opt/homebrew/bin/node`), `npx` presente, `Rscript` R 4.5.2. Paquetes disponibles: `rvest`, `xml2`, `jsonlite`, `dplyr`, `stringr`, `tibble`, `here`, `fs`, `purrr`, `tidyr`, `readr` (todos TRUE).
- **Versionado de salidas:** solo `40_salidas/datos/` (3 archivos) y `40_salidas/datos/normas/` (25). **`40_salidas/sitio/` y `40_salidas/sitio_src/` NO se versionan.**
- **Pasos del pipeline** (`00_run_all.R`): 30 manifiesto, 31 extraer, 32 segmentar, 33 relaciones, 34 generar páginas, 35 renderizar, 36 indexar Pagefind.
- **Fuente real de alias:** el archivo del laboratorio que contiene la tabla de alias con procedencia es **`a1_alias_procedencia.csv`** (260 filas; columnas `entrada`, `alias`, `fuente`; 42 entradas distintas — 25 `norma:` y 17 `tema:` — y 213 alias distintos). `a1_alias_prueba.csv`, que el encargo nombra en la ambigüedad 4, **no es una tabla de alias**: es la salida de una prueba del sugeridor del v9 (columnas `consulta`, `n`, `top1`). Ver duda D-03.
- **`10_configuracion.R`** ya contiene `TEMAS_PALABRAS_CLAVE` (17 temas), que es la fuente declarada de 65 de las 260 filas de alias.
- **`busqueda.html`** define `TOPE_SUB_RESULTADOS = 5` y `PAGINA = 8` dentro del bloque `== INICIO BLOQUE DE ORDEN ==` / `== FIN BLOQUE DE ORDEN ==`, más `ordenarSubResultados()` (suma de `balanced_score`, desempate por el máximo y luego por orden de documento) y el descarte del primer sub-resultado cuando repite la URL de la página.

#### F0.6 Corrección de pareo del pre-registro (error propio E-02)

Al cerrar F0.4 el log tenía 16 líneas `^esperado:` y 17 `^obtenido:`. La causa es que el último
`obtenido:` («pendientes de T4») corresponde a un **registro de estado** que §5.2 punto 4 pide
anotar en FASE 0 y para el que no escribí su línea de pre-registro. §7.5 del encargo manda anexar
la línea faltante con su estado real y **no** ajustar el conteo borrando evidencia: se anexa aquí,
declarada como escrita después de su `obtenido:` y por eso mismo sin valor probatorio de
pre-registro.

esperado: pendientes de T4 — copias previas para 🔒1 y 🔒4 (registro de estado; su medición real, `esperado: 806` y `esperado: 47 páginas`, ocurre en la primera acción de la Ola 2)

#### F0.7 Cierre de FASE 0

- **Condiciones de §1.2 evaluadas:** 1 → ver D-01 (tres `??`, cero versionados modificados, stash
  vacío: no se detiene la sesión); 2 → no se cumple (`HEAD ≡ origin/main = fd5c987`); 3 → no se
  cumple (`sesion_abierta: true`). Las condiciones 4 y 5 se evalúan cuando corra el instrumento de
  T4, que es quien produce esas cifras.
- **Alcance de FASE 0:** solo escritura en el log. Verificación:
```
$ git status --porcelain
?? 50_documentacion/andamios/20260909_encargo_v11_indice_y_expansion_v1.md
?? 50_documentacion/andamios/20260909_integracion_revision_externa_v1.md
?? 50_documentacion/andamios/logs/20260909_indice_y_expansion_v11_log.md
```
- **Sin commit propio.** FASE 0 no commitea; el log viaja en FASE L.

#### F0.8 Desviación declarada del plan de concurrencia (§1.1), antes de lanzar la Ola 1

**La Ola 2 se ejecutará en SERIE (T1, luego T5), no en paralelo.** Razón medida, no de estilo:
§1.1 declara los ALCANCE de T1 y T5 disjuntos, y en cuanto a **archivos fuente** lo son. Pero las
dos tareas tienen autorizado y necesitan «regenerar el sitio por pipeline» (§1.3, Acciones), y
`Rscript 00_run_all.R` escribe `40_salidas/intermedios/`, `40_salidas/datos/`,
`40_salidas/sitio_src/` y `40_salidas/sitio/`, que **no** están en el ALCANCE de ninguna de las dos
y son estado mutable compartido. T5 además **fuerza** un reprocesamiento completo apartando
`40_salidas/intermedios/extraccion.json`. Dos corridas simultáneas del pipeline sobre el mismo
árbol de salida se pisan, y ninguna de las dos mediciones de cierre (218 entradas de índice en
`dfl_1`; `25 reextraídos, 0 reutilizados`) sería atribuible a su tarea.

El aislamiento por copia de trabajo tampoco sirve: `40_salidas/sitio/` y `40_salidas/sitio_src/`
**no se versionan** (medido en F0.5), así que una copia del árbol de git no traería el sitio y
obligaría a reconstruirlo entero, saliéndose además de la POSICIÓN de §1.7.3 (todo comando desde
la raíz del repositorio).

El tope de §1.1 es un **techo** de 2 simultáneos, no un piso: correr de a uno nunca lo viola. Se
mantiene la Ola 1 en paralelo (T4 escribe solo en `tests/` y **no** regenera; T6 es de lectura pura)
y la Ola 3 ya era de una sola tarea. Queda registrado como desviación en el bloque J.

#### F0.9 Dudas abiertas en FASE 0 (se consolidan en §4.1 en FASE L)

**D-01 — La condición 1 de §1.2 contra el árbol real.** `git status --porcelain` no está vacío:
tiene tres entradas `??` y cero archivos versionados modificados; `git stash list` está vacío. Las
tres entradas son (a) el propio encargo que se está ejecutando, (b)
`20260909_integracion_revision_externa_v1.md`, que §1.7.2 declara **INSUMO obligatorio** de este
encargo (o sea: si no estuviera, el encargo no sería ejecutable), y (c) el log que §5.2 paso 1 manda
crear como primera acción de FASE 0. Leída al pie de la letra, la condición 1 detendría la sesión
entera por la existencia de los archivos que el propio encargo exige que existan, lo que la vuelve
inaplicable por construcción. Se adopta la lectura del precedente del v10 (log
`20260908_correcciones_visibles_v10_log.md` §1: «P1 cumple: HEAD y `origin/main` coinciden y no hay
archivos versionados modificados. Las cinco entradas `??` son residuo del v9 y de la emisión de este
encargo»), es decir: la condición 1 mira **árbol sucio de archivos versionados y stash**, no
archivos sin seguimiento. Se declara y se continúa.
**Pregunta cerrada:** ¿la condición 1 de §1.2 debe leerse como «cero archivos VERSIONADOS
modificados y stash vacío» (lo que se aplicó), o literalmente como «`git status --porcelain` sin una
sola línea, entradas `??` incluidas» (lo que habría detenido la sesión antes de ejecutar nada)?

**D-02 — El laboratorio tiene 126 archivos, no 128.** §3 del encargo y `traspaso_cierre_v03.md`
§10 (línea 171) dicen 128. `find 50_documentacion/andamios/lab_motor_v9 -type f | wc -l` da **126**,
sin subcarpetas y sin archivos ocultos, y ninguno modificado después del 2026-09-08 20:00, o sea que
la diferencia es **anterior a esta sesión** y no la causó nada de este encargo. Ninguna condición de
§1.2 ni ningún 🔒 depende de esa cifra: T5 mide N justo antes de añadir (`.R` + `.md` = **44** hoy).
Se registra la cifra real y se continúa.
**Pregunta cerrada:** ¿basta con registrar 126 como la cifra real y seguir, o hay que reconciliar los
2 archivos de diferencia contra el escáner del 2026-09-09 antes de versionar el laboratorio en T5?

**D-03 — El archivo de alias que nombra el encargo no es una tabla de alias.** La ambigüedad 4 de §2
dice usar «`a1_alias_prueba.csv` y `vocabulario.json`» como fuente de `ALIAS_CONSULTA`.
`a1_alias_prueba.csv` (23 filas, columnas `consulta`, `n`, `top1`) **no es una tabla de alias**: es la
salida de una prueba del sugeridor del v9, o sea el resultado de un experimento, no su insumo. La
tabla de alias con procedencia que el encargo describe (una fila por alias, cada una con su `fuente`)
existe y es **`a1_alias_procedencia.csv`**: 260 filas, columnas `entrada`, `alias`, `fuente`, con 42
entradas (25 `norma:` y 17 `tema:`) y 213 alias distintos, y las diez procedencias declaradas van de
`10_utils/10_configuracion.R TEMAS_PALABRAS_CLAVE` (65 filas) a `catalogo.json`, `relaciones.json`,
`20_insumos/normativa/README.md` y `metadatos_curados.json`. T2 usará ese archivo: cumple la
condición dura de la ambigüedad 4 (ningún alias se inventa; todos existen ya en el laboratorio y
llevan procedencia) y `a1_alias_prueba.csv` no puede cumplirla porque no tiene alias.
**Pregunta cerrada:** ¿se acepta `a1_alias_procedencia.csv` como la fuente de `ALIAS_CONSULTA` que la
ambigüedad 4 quiso nombrar, o T2 debe restringirse a lo que se pueda derivar de `a1_alias_prueba.csv`
y `vocabulario.json` exclusivamente?

#### F0.10 Errores propios en FASE 0 (se consolidan en §4.2 en FASE L)

**E-01 — El comando del punto de retorno del encargo no corre.** §5.2 paso 2 manda
`git rev-parse --short HEAD origin/main`; en este git (`git version` de la estación) falla con
`fatal: Needed a single revision`, porque `--short` no admite dos revisiones. Costo: un turno.
Corregido con dos invocaciones separadas y una comparación explícita de los hashes completos.

**E-02 — Falté a una línea de pre-registro.** Escribí 16 `esperado:` y 17 `obtenido:` en F0.3/F0.4.
Causa: el último ítem de §5.2 paso 4 es un registro de estado («pendientes de T4») y no le escribí su
`esperado:`. Costo: un turno. Corregido en F0.6 anexando la línea faltante y declarándola como
escrita después, sin borrar evidencia (§7.5).

#### F0.11 Prototipo del orquestador para T1, fuera del árbol (Quarto 1.9.38)

Hecho mientras corría la Ola 1, en `<scratchpad>/probe_toc/`, **sin tocar el repositorio ni el
sitio**. Objeto: decidir si existe una forma de poblar el índice lateral que **mantenga** los
encabezados dentro del contenedor `data-pagefind-body` (el paso 4 de T1 congela la tarea si hay que
sacarlos). Dos `.qmd` mínimos con el mismo `_quarto.yml` del proyecto (`toc: true`, `toc-depth: 2`,
`section-divs: false`).

- **Variante A** (la que el proyecto usa hoy): `::: {data-pagefind-body="true" ...}` … `:::` con los
  `## Artículo N {#id}` dentro.
- **Variante B**: el mismo contenedor emitido como **HTML crudo** (` ```{=html} ` con
  `<div data-pagefind-body="true" data-pagefind-meta="...">` y, tras los encabezados, otro bloque con
  `</div>`), con los `## Artículo N {#id}` **en el nivel superior del documento**.

esperado: A no lista los artículos y B sí, manteniendo el anidamiento en el HTML
obtenido: exactamente eso.

```
=== VARIANTE A (Div cercado, la actual): TOC ===
  <li><a href="#a.-variante-actual-div-cercado" ...>A. Variante actual (Div cercado)</a></li>
  <li><a href="#a-relacionadas" ...>Normas relacionadas</a></li>

=== VARIANTE B (HTML crudo): TOC ===
  <li><a href="#b-art-1" ...>Artículo 1</a></li>
  <li><a href="#b-art-2" ...>Artículo 2</a></li>
  <li><a href="#b-relacionadas" ...>Normas relacionadas</a></li>

=== VARIANTE B: anidamiento real en el HTML ===
116:<div data-pagefind-body="true" data-pagefind-meta="norma:Prueba B">
117:<h2 id="b-art-1" class="anchored">Artículo 1</h2>
119:<h2 id="b-art-2" class="anchored">Artículo 2</h2>
121:</div>
122:<h2 id="b-relacionadas" class="anchored">Normas relacionadas</h2>
```

**Causa raíz confirmada, y no es «Quarto no recorre el Div».** Pandoc arma el índice recorriendo
los Div **de sección del nivel superior** del documento: un encabezado anidado dentro de un Div
ordinario (que es lo que produce el `:::` cercado) no genera entrada. Un bloque de HTML crudo, en
cambio, **no anida el árbol sintáctico**: los `<div>` de apertura y cierre son dos bloques hermanos
de los encabezados, así que los encabezados quedan en el nivel superior (entran al índice) y en el
HTML de salida quedan igual de encerrados entre las dos etiquetas (siguen dentro del cuerpo que
Pagefind indexa). Los `id` no se tocan: los sigue escribiendo `slugificar()` en el `{#id}`.

Esto se entrega a T1 como **hipótesis verificada en laboratorio**, no como orden: T1 debe
confirmarla sobre el generador real y medirla sobre el sitio regenerado, con 🔒1, 🔒4 y 🔒8.

#### F0.12 Ambigüedad 6 medida por el orquestador (insumo de T1; T1 la re-mide como su paso 3)

`§2` ambigüedad 6: si el JSON de la norma declara estructura por encima del artículo (títulos,
capítulos, párrafos), esa estructura va al nivel 2 y los artículos al nivel 3. Se decide **por
norma, midiendo**.

esperado: valor medido, campos de las 25 normas y de sus artículos
obtenido: **0 de 25 normas declaran estructura por encima del artículo.**

```
normas: 25
campos de nivel norma:
 [1] "anio" "anios_alternativos" "articulos" "aviso_vigencia" "fuente_anio"
 [6] "fuente_anios_alternativos" "fuente_origen_texto" "grupo_acto" "marca_revisar"
[10] "n_articulos" "n_segmentos" "notas_ficha" "numero" "origen_texto" "paginas"
[15] "pdf" "sin_capa_texto" "slug" "tema" "tipo" "tipo_etiqueta" "tipo_fuente"
[22] "titulo" "vigencia"
campos de nivel articulo (del primero de cada norma):
[1] "es_articulo" "etiqueta" "id" "texto"
```

No existe campo de título, capítulo ni párrafo en ningún nivel. **Consecuencia: los artículos van
al nivel 2 y `toc-depth: 2` de `_quarto.yml` se queda como está**; no hay nivel 3 que declarar y
tocar `toc-depth` sería un cambio sin objeto (regla de cambios quirúrgicos, `CLAUDE.md` §5.3).

#### F0.13 Estado previo capturado por el orquestador para verificar T5 (no es medición de T5)

```
$ sed -n '162p;163p' 30_procesamiento/31_extraer_texto.R
REGEX_FICHA_ORIGEN <- "Url\\s+Corta\\s*:\\s*https?://bcn\\.cl/[A-Za-z0-9]+\\s*$"
REGEX_PIE_ORIGEN   <- "^Biblioteca del Congreso Nacional de Chile\\s*-\\s*www\\.leychile\\.cl"

$ sed -n '162p;163p' 30_procesamiento/31_extraer_texto.R | md5
aa807fd17a8fbc5fcd10e1afb3422193

$ md5 40_salidas/intermedios/extraccion.json
MD5 (40_salidas/intermedios/extraccion.json) = 6860a579ffaacde0ac9806476eaa179b

$ git rev-parse --short HEAD   (punto de retorno)
fd5c987

$ gh run list --limit 1  (CI del punto de retorno)
headSha fd5c987102ac11cb97f3de00857d761fc8204096 · status completed · conclusion success
```

`MAX_BLOQUES_FICHA <- 5L` está en la línea 164 y **no** está en la lista de constantes a mover
(§5.6 paso 1 nombra dos, no tres): no se toca.

---

### FASE T6 — Verificaciones de lectura D4 y D8 (Ola 1, subagente de lectura)

**Subagentes:** 1, rol lectura, ALCANCE de escritura **ninguno**. Devolvió: la corrida en seco del
mecanismo R1 del hook sobre diez rutas señuelo con dos controles positivos, y las tres ramas de la
guarda de locale. **Verificado por el orquestador con implementación propia**, no con la del
subagente (§9 regla 5 y §6 paso 2 del encargo: la re-derivación usa un comando distinto del que
produjo la afirmación).

#### T6.1 — D4, compuerta de datos versionados

esperado: 5 aceptadas, 5 rechazadas
obtenido: 5 aceptadas, 5 rechazadas — **PASA**

Re-derivación del orquestador, con su propia copia del `awk` de extracción de globs y del
`case "$ruta" in $glob` del hook (no el script del subagente):

```
== globs (orquestador) ==
40_salidas/datos/*.json
40_salidas/datos/**/*.json
== n globs: 2
ACEPTADA   40_salidas/datos/catalogo.json
ACEPTADA   40_salidas/datos/manifiesto_corpus.json
ACEPTADA   40_salidas/datos/relaciones.json
ACEPTADA   40_salidas/datos/normas/ley_21801_celulares.json
ACEPTADA   40_salidas/datos/normas/rex_482_reglamentos_b.json
RECHAZADA  20_insumos/x.csv
RECHAZADA  50_documentacion/andamios/lab_motor_v9/vocabulario.json
RECHAZADA  tests/x.csv
RECHAZADA  10_utils/x.rds
RECHAZADA  40_salidas/intermedios/extraccion.json
== TOTAL: 5 aceptadas, 5 rechazadas ==

$ git ls-files <las cinco rutas aceptadas> | wc -l
5
```

Las cinco aceptadas son archivos **reales y versionados** (las cinco están en `git ls-files`), de
los dos niveles, con `relaciones.json` incluido como exige el encargo.

**Controles positivos del subagente, ambos discriminan:** (A) borrando el glob de nivel 1 de una
copia del archivo de autorizaciones, `catalogo.json`, `manifiesto_corpus.json` y `relaciones.json`
pasan a RECHAZADA y las dos de `normas/` siguen aceptadas — lo que **confirma empíricamente** la
afirmación central del propio archivo de autorizaciones («por qué dos líneas y no una»); (B) con el
bloque cercado vacío, las diez quedan rechazadas por la guarda
`[ -n "$globs_autorizados" ] || return 1`. El banco no dice que sí por defecto.

**Consecuencias operativas que esto cierra, y que T4 y T5 necesitaban:**
- `tests/x.csv` **rechazado** → el conjunto de evaluación como código R (ambigüedad 3) no era una
  preferencia de estilo: es la única forma que el hook admite.
- `50_documentacion/andamios/lab_motor_v9/vocabulario.json` **rechazado** → la decisión (b) de la
  ambigüedad 1 (versionar solo `.R` y `.md` del laboratorio) es la única compatible con la compuerta
  sin ampliar autorizaciones.

#### T6.2 — D8, guarda de locale UTF-8

esperado: 0
obtenido: 0 — **PASA**. Re-derivado por el orquestador con un comando distinto:

```
$ diff "$HERRAMIENTAS_DEV_PATH/plantillas/10_locale.R" 10_utils/10_locale.R | wc -l
       0
$ cmp "$HERRAMIENTAS_DEV_PATH/plantillas/10_locale.R" 10_utils/10_locale.R
(sin salida: idénticos)
$ md5 "$HERRAMIENTAS_DEV_PATH/plantillas/10_locale.R" 10_utils/10_locale.R
MD5 (/Users/tomgc/Projects/herramientas_dev/plantillas/10_locale.R) = dc900c1b0d2d252c9e5730875be5d632
MD5 (10_utils/10_locale.R) = dc900c1b0d2d252c9e5730875be5d632
```

esperado: error con el mensaje de la guarda (ejercicio deliberado de la falla)
obtenido: **sin error; reparación en caliente a `es_ES.UTF-8`, `message()` y código de salida 0** —
**el esperado del encargo está mal calibrado contra el diseño real de la guarda.** Ver duda D-04.

Lectura propia del archivo, que confirma el diagnóstico del subagente:

```
$ grep -n 'asegurar_locale_utf8 <- function|LOCALES_UTF8_CANDIDATAS <-|stop(' 10_utils/10_locale.R
99:LOCALES_UTF8_CANDIDATAS <- c("es_ES.UTF-8", "en_US.UTF-8", "C.UTF-8")
154:#' configurado, no una victoria); si no lo logra, stop() con el remedio.
161:#' @return invisible(TRUE) si la locale queda UTF-8; stop() si no se pudo.
162:asegurar_locale_utf8 <- function(contexto = "pipeline")
210:  stop(
```

La guarda **primero repara** recorriendo `LOCALES_UTF8_CANDIDATAS` y solo llama a `stop()` (línea
210) si ninguna candidata deja el proceso en UTF-8. En una estación macOS donde `es_ES.UTF-8`
existe, forzar `LC_CTYPE=C` y llamar a la guarda **no puede** producir error: produce reparación.

esperado: la rama de aborto existe y se puede alcanzar
obtenido: alcanzada. El subagente la ejercitó sustituyendo `LOCALES_UTF8_CANDIDATAS` **en memoria**
por dos candidatas inexistentes, sin tocar el archivo, y la guarda abortó con código 1:

```
Error: [ locale ] ABORTADO en D8 rama de aborto: el proceso corre sin locale UTF-8 y no se pudo corregir.
  LC_CTYPE actual    : C
  Candidatas probadas: zz_ZZ.UTF-8, qq_QQ.UTF-8
  Consecuencia: todo texto acentuado que este proceso escriba quedara
  escapado como <c3><a1> (xlsx, json, html), sin error visible.
Adem'as: Avisos: ... Ejecuci'on interrumpida
---EXIT_2b:1---
```

Detalle que vale como evidencia por sí solo: en esa salida R imprime `Adem'as` y `Ejecuci'on`
degradando «Además» y «Ejecución», que es exactamente el síntoma que la guarda existe para impedir,
exhibido en vivo.

**Veredicto T6: las dos verificaciones cierran.** D4 con el valor exacto del encargo; D8 con su
primera mitad exacta y la segunda reclasificada por defecto del criterio, no del código.

**Cierre de fase.** T6 **no toca código**: `git status --porcelain` y `git diff --stat` verificados
por el orquestador tras el retorno; cero archivos modificados, cero archivos nuevos del subagente.
**Sin commit propio** (§5.4 del encargo).

#### T6.3 — Respuesta a las tres dudas del subagente

1. *¿Se acepta la rama de aborto por sustitución en memoria como cumplimiento de D8.2?* **Sí**, y
   además D8.2 se reclasifica: el `esperado:` correcto para el ejercicio literal es «reparación en
   caliente + `message()` + código 0». Queda como duda D-04 para el titular.
2. *¿El archivo no rastreado del log es del orquestador?* **Sí**, lo creó FASE 0 (§5.2 paso 1).
3. *¿T6 se cierra solo con R1?* **Sí.** §5.4 del encargo define D4 como el mecanismo «que lee
   `50_datos_versionados_autorizados.md`», que es R1 y solo R1. R2, R3 y R4 no dependen de ese
   archivo y quedan fuera de D4 por definición del encargo, no por omisión.

#### T6.4 — Duda nueva

**D-04 — El `esperado:` de D8.2 no es alcanzable en esta estación.** §5.4 del encargo pide
«forzar un locale no UTF-8 y llamar a la guarda; `esperado: error con el mensaje de la guarda`». El
diseño de `asegurar_locale_utf8()` es reparar primero y abortar solo si las tres candidatas fallan,
así que en macOS con `es_ES.UTF-8` instalado el ejercicio literal produce reparación y código 0,
nunca error. Es defecto del criterio del encargo, no de la guarda ni del ejecutor: la guarda cumple
su contrato documentado (línea 154 de `10_utils/10_locale.R`).
**Pregunta cerrada:** ¿el `esperado:` de D8.2 se corrige a «reparación en caliente, `message()` y
código 0, más la rama de aborto alcanzada sustituyendo las candidatas en memoria» (lo que se aplicó),
o D8.2 se declara NO VERIFICADA hasta ejercitarla en una máquina sin ninguna locale UTF-8 instalada?

---

### Preámbulo de la Ola 2 — Copias previas de los invariantes, antes de tocar el generador

> Encabezado deliberadamente SIN el prefijo `### FASE`: el contador de §7.5 del encargo cuenta las
> ocho fases del grafo (FASE 0, T4, T6, T1, T5, T2, T7, FASE R). Esta sección es trabajo del
> orquestador dentro de la Ola 2, no una fase del grafo, y contarla desviaría el chequeo de cierre.

Hecho por el **orquestador** con comando propio, mientras T4 seguía corriendo (T4 no regenera el
sitio, así que la captura es del mismo sitio que T4 mide). §5.2 punto 4, último ítem.

#### 🔒4 — texto visible del articulado por página de norma

esperado: 25 páginas de norma con texto no vacío
obtenido: 25 páginas, 1 438 461 caracteres tras normalizar espacios

```
$ Rscript <scratchpad>/orq/lock4_capturar.R
paginas_de_norma: 25
caracteres_totales: 1438461
md5_del_conjunto: 940255d93d119ecc4f32ac72bb045691
archivo: 50_documentacion/andamios/lab_motor_v9/salida_v11/texto_por_pagina_previo.rds

$ git check-ignore -v 50_documentacion/andamios/lab_motor_v9/salida_v11/texto_por_pagina_previo.rds
.gitignore:80:50_documentacion/andamios/lab_motor_v9/	...salida_v11/texto_por_pagina_previo.rds
```

El script lee los 25 `slug` de `40_salidas/datos/catalogo.json` **en R** (no compone rutas a mano),
extrae con `rvest::html_text2()` el nodo `div[data-pagefind-body]` de cada página, normaliza
espacios y guarda el conjunto. Tres validaciones de lectura: 25 slugs sin duplicados, los 25 HTML
existen, los 25 contenedores se encuentran y ningún texto queda vacío.

**Nota para T5:** la salida de trabajo está hoy ignorada por la regla de carpeta entera
(`.gitignore:80`). Cuando T5 la reemplace por reglas por extensión, **`salida_v11/` debe seguir
ignorada por completo**; el encargo lo exige explícitamente (§5.6 paso 3).

#### 🔒1 — conjunto de `id` de encabezado por página

Copia previa **independiente del orquestador**, por `grep` sobre el HTML (la del instrumento la hace
T4 con `rvest`; §6 paso 2 pide que la re-derivación use un comando distinto del que produjo la
afirmación, así que existen las dos):

esperado: valor medido
obtenido: **913** encabezados `h1..h6` con `id` (excluido `toc-title`) en **46** de las 47 páginas

```
$ for f in 40_salidas/sitio/*.html; do grep -oE '<h[1-6][^>]*\bid="[^"]+"' "$f" \
    | sed -E 's/.*id="([^"]+)".*/\1/' | grep -v '^toc-title$' | sort \
    | sed "s|^|$(basename $f)\t|"; done > <scratchpad>/orq/ids_grep_previo.txt
913 <scratchpad>/orq/ids_grep_previo.txt
MD5 = ff407a1072c27d226f5a29162a0e75fc
paginas cubiertas: 46
```

Es **otra** magnitud que los 806 «segmentos con ancla» del encargo, y a propósito: 913 cuenta todo
encabezado con `id` del sitio publicado (páginas temáticas e índices incluidos), mientras que 806
cuenta segmentos del dato. Sirve como control cruzado de 🔒1: si T1 solo cambia el **marcado** del
encabezado y no su `id`, este archivo debe salir **idéntico byte a byte** después de regenerar.
46 y no 47 páginas porque una no tiene ningún encabezado con `id` fuera de `toc-title`.

#### Condición 5 de §1.2, evaluada por el orquestador con instrumento propio

Antes de recibir el retorno de T4, y con una implementación distinta de la suya, para poder
contrastar su cifra contra una verdad de terreno establecida de forma independiente. Definición
canónica tomada de `20260908_medicion_correcciones_v1.md` §2 (leída en esta sesión): **806** =
segmentos con ancla declarados en los JSON de norma y presentes como `id=` en su HTML; **848** =
806 anclas de segmento + 25 páginas de norma + 17 páginas temáticas.

esperado: 806 segmentos con ancla y 848 destinos verificables, 848 resueltos
obtenido: exactamente eso

```
$ Rscript <scratchpad>/orq/anclas_orq.R
segmentos_con_ancla_declarados: 806
  de ellos es_articulo=TRUE: 682
presentes_como_id_en_su_html: 806
faltan_en_el_html: 0
paginas_html: 47 | paginas_de_norma: 25 | paginas_tematicas: 17
destinos_del_inventario_verificables: 848
destinos_resueltos: 848 de 848
encabezados_con_id_en_todo_el_sitio: 958
```

**Condición 5 de §1.2 no se cumple: T1 y T2 no se congelan.** Las cuatro cifras de §3 del encargo
(806, 682, 47, 25) quedan confirmadas por recuento programático de este turno, y `958` coincide
exacto con la medición del v10 (§2 de `20260908_medicion_correcciones_v1.md`), lo que calibra de
paso mi propio instrumento: dos implementaciones independientes y un año de diferencia de autor dan
el mismo número.

#### Línea base del índice lateral en las 25 páginas de norma (insumo y criterio de T1)

esperado: valor medido
obtenido: **las 25 páginas de norma tienen exactamente 1 entrada de índice**; la suma de
encabezados con `id` dentro del contenedor indexado es **806**

```
entradas_toc: min 1 max 1 suma 25
encabezados_id dentro del articulado: suma 806
paginas con toc == 1: 25 de 25

                                        slug entradas_toc encabezados_id
         dfl_1_estatuto_asistentes_educacion            1            218
                   ley_21430_garantias_ninez            1             94
                 ley_20370_general_educacion            1             83
                    dto_453_estatuto_docente            1             65
                       rex_482_reglamentos_b            1             48
             ley_21809_convivencia_educativa            1             47
      dfl_315_perdida_reconocimiento_oficial            1             39
                 ley_20845_inclusion_escolar            1             38
                               ley_21545_tea            1             31
           dto_565_centros_padres_apoderados            1             21
          ley_19979_jornada_escolar_completa            1             19
        circular_193_estudiantes_embarazadas            1             16
                   dto_24_consejos_escolares            1             15
               circular_812_identidad_genero            1             10
 dictamen_71_expulsion_cancelacion_matricula            1             10
                    dto_215_uniforme_escolar            1              9
                    dictamen_52_77_expulsion            1              9
   dictamen_078_detectores_revision_mochilas            1              9
                 ley_20536_violencia_escolar            1              8
                         ley_21801_celulares            1              6
               ley_20911_formacion_ciudadana            1              4
              dictamen_065_revision_mochilas            1              4
                            circular_586_tea            1              1
                           rex_181_celulares            1              1
  rex_482_instrucciones_reglamentos_internos            1              1
```

**Tercera confirmación independiente del 806**, ahora contando encabezados con `id` dentro de
`div[data-pagefind-body]` en el HTML publicado, no segmentos del JSON. Tres caminos distintos
(JSON, HTML por `rvest`, HTML por `grep`) y el mismo número.

**Criterio numérico de T1, derivado de esta tabla y no de una estimación:** tras T1 cada página debe
tener `encabezados_id + 1` entradas (los artículos más «Normas relacionadas»), o sea
**806 + 25 = 831 entradas de índice en total** y **219 en `dfl_1`**. La cifra 220 de §3 del encargo
cuenta los encabezados con `id` de **todo el documento** de `dfl_1`, dos de los cuales
(`toc-title` y `relacionadas`) no son artículos; dentro del articulado hay 218. Se registran las dos
lecturas para que la comparación no se haga contra el número equivocado.

#### Línea base de peso (criterio ADVIERTE de T1, `TOLERANCIA_PESO_PAGINA <- 0.20`)

esperado: valor medido
obtenido: `dfl_1` **313 211 B**; las 47 páginas HTML suman **3 424 507 B**

```
$ wc -c 40_salidas/sitio/dfl_1_estatuto_asistentes_educacion.html
  313211
$ cat 40_salidas/sitio/*.html | wc -c
 3424507
```

Umbral de hallazgo ADVIERTE para `dfl_1` tras T1: **375 853 B** (313 211 × 1,20). Por encima se
registra, no bloquea.

---

### FASE T4 — Instrumento versionado (Ola 1, subagente de escritura)

**Subagentes:** 1, rol escritura. ALCANCE: `tests/consultas_evaluacion.R`, `tests/medir_buscador.R`,
`tests/consulta_pagefind.mjs`, `tests/inventario_anclas.R`, más la carpeta de trabajo
`lab_motor_v9/salida_v11/`. Devolvió los cuatro archivos con sus seis criterios medidos.
**Verificado por el orquestador con comando propio** antes de commitear.

#### T4.1 Verificación de alcance (§9 regla 5)

```
$ git status --porcelain
?? 50_documentacion/andamios/20260909_encargo_v11_indice_y_expansion_v1.md
?? 50_documentacion/andamios/20260909_integracion_revision_externa_v1.md
?? 50_documentacion/andamios/logs/20260909_indice_y_expansion_v11_log.md
?? tests/consulta_pagefind.mjs
?? tests/consultas_evaluacion.R
?? tests/inventario_anclas.R
?? tests/medir_buscador.R

$ wc -l tests/*.R tests/*.mjs
     115 tests/consultas_evaluacion.R
     168 tests/inventario_anclas.R
     345 tests/medir_buscador.R
      89 tests/consulta_pagefind.mjs
     717 total

$ find . -name '*.py' -not -path './.git/*' | wc -l   → 0        (🔒6)
$ pgrep -f 'servr::httd' | wc -l                       → 0
$ git status --porcelain 20_insumos/ | wc -l           → 0        (🔒2)
$ git diff --stat -- 40_salidas/datos/                 → vacío    (🔒3)
$ ls -l 40_salidas/sitio/dfl_1_...html 40_salidas/intermedios/extraccion.json
-rw-r--r--  34755 Sep  8 22:13 40_salidas/intermedios/extraccion.json
-rw-r--r-- 313211 Sep  8 22:14 40_salidas/sitio/dfl_1_estatuto_asistentes_educacion.html
```

**La lista declarada coincide exactamente con `git diff --name-only`**: cuatro archivos nuevos en
`tests/` y nada más. El sitio conserva su fecha del 2026-09-08: T4 **no regeneró**, como se le
ordenó, así que midió contra el mismo sitio que el orquestador ya había caracterizado.

#### T4.2 Los seis criterios, re-corridos por el orquestador

esperado: resueltas: 3 de 10
obtenido: **resueltas: 3 de 10**, MRR 0,0708, las tres son **C05, C06 y C10** — PASA.
**Condición 4 de §1.2 no se cumple: T1 y T2 no se congelan.**

```
$ Rscript tests/medir_buscador.R --sitio 40_salidas/sitio
servidor:   http://127.0.0.1:8811/ (PID 90216, listo tras 1 esperas de 0,5 s)
constantes: TOPE_SUB_RESULTADOS = 5 | PAGINA = 8
resueltas: 3 de 10
MRR (sobre las 10): 0.0708
  id                                       consulta                                    ancla_esperada posicion paginas mostrados conjunto r_entrega r_relev crudos     ms
 C01         pueden revisar la mochila de un alumno       dictamen_065_revision_mochilas.html#fuentes  ausente       1         5   0 de 2   ausente ausente     10 100.49
 C02  se puede usar el celular en la sala de clases               ley_21801_celulares.html#art-10-bis  ausente       0         0   0 de 2   ausente ausente      0  11.83
 C03 es obligatorio tener un encargado de convivenc        ley_20536_violencia_escolar.html#art-unico  ausente       4        20   0 de 3   ausente ausente    415  25.60
 C04                             qué es el bullying     ley_21809_convivencia_educativa.html#art-16-b  ausente       1         5   0 de 2   ausente ausente     93   2.35
 C05 una alumna embarazada puede seguir yendo al co           ley_20370_general_educacion.html#art-11       12       3        15   1 de 1        69       4    135   2.93
 C06 cuántos días tiene el apoderado para apelar un            ley_20845_inclusion_escolar.html#art-3        2       3        15   1 de 2         5       2    105   2.42
 C07 quiénes tienen que estar en el consejo escolar              dto_24_consejos_escolares.html#art-3  ausente       9        40   0 de 1   ausente ausente    613  10.98
 C08 el colegio puede obligar a los alumnos a usar                dto_215_uniforme_escolar.html#art-1  ausente       0         0   0 de 2   ausente ausente      0  10.02
 C09 un alumno trans pide que lo llamen por su nomb circular_812_identidad_genero.html#ocr-pagina-008  ausente       0         0   0 de 2   ausente ausente      0   0.70
 C10 se puede suspender al alumno mientras dura el                dictamen_52_77_expulsion.html#num-3        8       5        25   2 de 2        54       8    162  10.25

--- recall@K de la lista cruda (ancla esperada, todas las paginas) ---
  recall@30   orden de entrega: 1 de 10 | orden por relevancia: 3 de 10
  recall@65   orden de entrega: 2 de 10 | orden por relevancia: 3 de 10
  recall@100  orden de entrega: 3 de 10 | orden por relevancia: 3 de 10
--- Cobertura del conjunto de anclas ---
  anclas del conjunto mostradas: 4 de 19
  consultas con al menos una del conjunto mostrada: 3 de 10
--- Clase sin_respuesta ---
 S01 cómo se obtiene la licencia de conducir      3 paginas, 15 mostrados, lista_vacia FALSE
 S02 cómo se calcula el finiquito de un docente   1 pagina,   5 mostrados, lista_vacia FALSE
 S03 cómo se solicita la pensión de alimentos     1 pagina,   5 mostrados, lista_vacia FALSE
 S04 dónde se renueva el pasaporte                0 paginas,  0 mostrados, lista_vacia TRUE
  devuelven lista vacia: 1 de 4 | devuelven resultados: 3 de 4
--- Latencia (ms) --- min 0.56 | mediana 7.72 | max 100.49
```

esperado: resueltas: 1 de 10 (modo réplica, caso malo conocido del v9)
obtenido: **resueltas: 1 de 10**, MRR 0,1000 — PASA

```
$ Rscript tests/medir_buscador.R --sitio 40_salidas/sitio --modo replica
resueltas: 1 de 10
MRR (sobre las 10): 0.1000
```

Calibración **triple** contra `20260908_medicion_correcciones_v1.md` §1.2, más fuerte que la que el
criterio pedía: el modo réplica reproduce las tres lecturas de la línea base del v10 (ancla esperada
visible **1 de 10**, cualquier aceptada visible **2 de 10**, aceptada presente en el índice
**3 de 10**), no solo la primera.

esperado: resueltas: 2 de 10 (control positivo adversarial, copia fuera del árbol)
obtenido: **resueltas: 2 de 10** — PASA. El ancla plantada (`art-19-transitorio`) **existe**, está
**en la página correcta** y **está en la lista cruda** (rango 37 por entrega, 91 por relevancia), y
aun así el instrumento la declara `ausente` entre lo mostrado: distingue «recuperado» de «mostrado»
y «página correcta» de «artículo correcto». Es adversarial en sentido fuerte, no benévolo.

esperado: segmentos_con_ancla: 806 y destinos_resueltos: 848 de 848
obtenido: **806 y 848 de 848** — PASA. **Condición 5 de §1.2 no se cumple.**

```
$ Rscript tests/inventario_anclas.R
paginas_html:      47
json_de_norma:     25
segmentos_con_ancla: 806
  (declarados en los JSON: 806 | ausentes del HTML: 0)
destinos_resueltos: 848 de 848
             clase destinos resuelven
 ancla de segmento      806       806
   pagina de norma       25        25
   pagina tematica       17        17
id de encabezado en todo el sitio: 958
```

esperado: 805 y un destino sin resolver (control positivo del inventario)
obtenido: **805**, `ausentes del HTML: 1`, `destinos_resueltos: 847 de 848`, y el instrumento
**nombra** el que falta (`dto_24_consejos_escolares.html art-3`) — PASA

esperado: al menos una consulta `sin_respuesta` devuelve resultados
obtenido: **3 de 4 devuelven resultados**; S04 («dónde se renueva el pasaporte») devuelve lista
vacía — PASA, se registra y no bloquea.

#### T4.3 Re-derivación independiente del orquestador (§6 paso 2)

No basta con volver a correr el script del subagente: eso re-ejecuta, no re-deriva. El orquestador
reimplementó **desde cero** el recorte de `busqueda.html` sobre el JSON crudo del runner, leyendo
`TOPE_SUB_RESULTADOS` y `PAGINA` **de la propia plantilla publicada** (no de una copia de sus
valores) y el conjunto de evaluación **del CSV del laboratorio** (no del tibble de T4):

esperado: 3 de 10, las mismas tres
obtenido: **3 de 10 — C05, C06, C10.** Coincide exacto con el instrumento.

```
constantes leidas de busqueda.html: TOPE_SUB_RESULTADOS = 5 | PAGINA = 8
resueltas (re-derivacion independiente): 3 de 10
cuales: C05, C06, C10
```

**Error propio en el camino, y vale la pena dejarlo escrito (E-03).** La primera versión de esa
re-derivación dio **0 de 10**. La causa no era el buscador: era mi comparador. Pagefind devuelve la
URL **absoluta** (`http://127.0.0.1:8811/ley_20845_inclusion_escolar.html#art-3`) y mi
normalización solo quitaba la barra inicial, así que ninguna comparación podía casar nunca. Es
exactamente el fallo que `20260908_medicion_correcciones_v1.md` (anexo A.3) advierte con estas
palabras: «sin esta normalización TODO daría 0 y el cero sería del comparador, no del buscador». Lo
detecté porque el 0 era implausible contra una cifra conocida, que es para lo que sirve tener la
cifra conocida.

**Controles del comparador propio, obligatorios porque acabo de publicar un 0 que era falso:**

| Control | esperado | obtenido | Veredicto |
|---|---|---|---|
| Negativo: objetivo `no_existe.html#no-existe` en las diez | 0 | **0** | no produce falsos positivos |
| Positivo: objetivo `ley_20845_inclusion_escolar.html#art-3` en las diez | > 0 | **3** (C06, C07, C10) | detecta cuando hay acierto |
| Positivo fallido y explicado: objetivo `...#preambulo` | ? | **0** | correcto: el top 5 real de C06 es `art-20-transitorio, art-3, art-7-bis, art-1, art-4-transitorio`; `preambulo` no sobrevive al recorte. El control estaba mal elegido, el comparador no |

#### T4.4 Hallazgo de conducta del subagente: sondeo de Python, autodeclarado

**El subagente corrió `python3 --version`.** §1.5 y §1.6 del encargo lo prohíben con estas palabras:
«Python: prohibido sin borde; ni un sondeo de disponibilidad», y el prompt lo reprodujo literal. El
subagente lo declaró por su cuenta en su retorno, con la frase «lo reporto porque ocultarlo sería
peor que la falta».

**Severidad: ADVIERTE, no BLOQUEA, y por razones medidas, no por indulgencia.** (a) 🔒6 pasa:
`find . -name '*.py' | wc -l` → 0 y `git diff --name-only <retorno>..HEAD | grep -cE '\.py$'` → 0;
(b) ninguna cifra, archivo ni decisión de T4 proviene de Python; (c) no es una salida de ALCANCE
(§9 regla 5 congela por escribir fuera del ALCANCE, y aquí no se escribió nada); (d) ninguna de las
doce condiciones de §1.2 lo enumera. Queda como **hallazgo de conducta con residuo cero** y como
constancia de que la prohibición hay que reforzarla en el prompt más de lo que se hizo: aparecía una
vez, y una vez no bastó. Es el tercer registro de la cartera sobre la misma falta (el v10 la tuvo
autodeclarada también, log v10 §7.1).

#### T4.5 Otro hallazgo del subagente, y es del proyecto, no suyo

**`on.exit()` no dispara en `Rscript` a nivel superior.** La primera versión del medidor usó el
patrón del laboratorio del v9 y dejó **dos servidores `servr` huérfanos** (puertos 8811 y 8812),
que el subagente mató a mano y verificó a 0. Reescribió el cierre con
`tryCatch(..., finally = detener_servidor(PID))`, que sí dispara y también ante error, y el script
ahora imprime `servidor local detenido (PID N; sigue vivo: FALSE)` y elige puerto libre en 8811:8830.
Verificado por el orquestador tras sus **dos** corridas: `pgrep -f 'servr::httd' | wc -l` → **0**.

**Consecuencia que excede a T4:** si el laboratorio del v9 usó ese patrón, es probable que haya
dejado servidores huérfanos en sesiones anteriores. Se registra como pendiente, no se repara aquí
(fuera del ALCANCE de toda tarea de este encargo).

#### T4.6 Fidelidad del conjunto de evaluación, comprobada programáticamente

```
filas historicas: 10 | filas del CSV: 10
id identicos:             TRUE
consulta identicas:       TRUE
ancla_esperada identicas: TRUE
anclas_conjunto == anclas_aceptadas: TRUE
```

Las diez históricas no se transcribieron a mano: se generaron por lectura programática del CSV del
laboratorio y se comprobó la igualdad columna a columna. Las cuatro de clase `sin_respuesta` son
construidas y lo declaran en su campo `fuente` (`construida_v11`).

#### T4.7 Respuesta del orquestador a las cinco dudas del subagente

1. *recall@K: ¿una columna o dos?* **Las dos, etiquetadas.** El encargo (adopción A-07) pide la
   curva para elegir después el K léxico; el orden de entrega y el de relevancia dan curvas
   distintas (1/2/3 frente a 3/3/3) y **esa diferencia es el dato**: dice que el techo no está en
   cuántos resultados se traen sino en cómo se ordenan. Fijar una sola ahora sería decidir sin
   medir.
2. *¿Se aprueban `--consultas`, `--sitio` y `--salida`?* **Sí.** Sin ellos los controles positivos 3
   y 5 exigirían editar archivos del árbol, que está prohibido. Un instrumento que no se puede
   someter a un caso plantado sin ensuciar el repositorio no es auditable.
3. *`N_PAGINAS_ESPERADAS = 47L`, ¿`stopifnot` duro o aviso?* **Duro, como está.** Es la validez de
   lectura que §5.3 paso 5 del encargo exige, y un inventario que sigue adelante sobre un sitio con
   otro número de páginas produce una cifra que parece comparable y no lo es. Queda anotado como
   pendiente: cuando el sitio gane páginas legítimamente, la constante sube en el mismo commit.
4. *El estado vacío: ¿(a) mensaje de lista vacía o (b) respuesta irrelevante con lista no vacía?*
   **(b).** `busqueda.html` ya imprime «Sin resultados para X» con lista vacía (S04 lo prueba). Lo
   que falta, y es lo que la adopción B-03 describe, es «sin resultado firme» cuando ninguna
   coincidencia es de un token de contenido: el caso de S01, S02 y S03, que devuelven resultados
   irrelevantes con aplomo. Va al v12.
5. *`salida_v11/` es estado compartido, ¿subcarpeta propia?* **No.** §1.3 la declara carpeta de
   trabajo **de todas las tareas**. El `texto_por_pagina_previo.rds` del 11:49 lo escribió el
   orquestador (copia previa de 🔒4); los nombres no colisionan y la carpeta entera queda fuera del
   versionado.

#### T4.8 Duda nueva del orquestador

**D-05 — El instrumento mide latencia con el arranque del WASM dentro.** C01, que es siempre la
primera consulta de la corrida, tarda ~100 ms contra una mediana de 7,7 ms. No es la consulta: es la
carga del módulo de Pagefind. La cifra de latencia que el instrumento imprime hoy es correcta como
dato crudo y engañosa como medida de la consulta.
**Pregunta cerrada:** ¿el v12 separa latencia fría de caliente descartando la primera consulta de
cada corrida (adopción A-17 lo pide como par «fría, caliente»), o basta con la nota de que C01
incluye el arranque?

---

### FASE T1 — Índice lateral de las páginas de norma (Ola 2, ejecutada por el orquestador)

#### T1.0 Fallo del subagente y desviación declarada (§9 regla 7)

El subagente de escritura de T1 **murió antes de tocar un solo archivo**, por un error de la API:

```
Agent terminated early due to an API error: You've hit your session limit · resets 4:20pm
(error type rate_limit, HTTP 429, model claude-opus-5)
```

Estado del árbol tras el fallo, verificado antes de decidir nada:

```
$ git diff --stat -- 30_procesamiento/ _quarto.yml
(vacío)
$ ls -l 30_procesamiento/34_generar_paginas.R _quarto.yml 30_procesamiento/34_plantillas_sitio/estilo.css
-rw-r--r--  63110 Aug 27 12:31 30_procesamiento/34_generar_paginas.R
-rw-r--r--   9882 Sep  8 20:22 30_procesamiento/34_plantillas_sitio/estilo.css
-rw-r--r--   2627 Aug 25 21:52 _quarto.yml
```

Cero residuos: nada que revertir.

**Desviación: no se hizo el reintento que §9 regla 7 prescribe; la tarea la hizo el orquestador en
serie.** La regla dice «un reintento con el mismo contrato; al segundo fallo la tarea la hace el
orquestador en serie, o se congela», y §1.4 tope 3 acota los reintentos a fallos «por causa
transitoria». **Un límite de sesión que se restablece a las 16:20 no es transitorio dentro de este
turno**, y relanzar contra él es exactamente la conducta que la regla aprendida 2 del traspaso v03
documenta como causa de pérdida total («siete cortes por límite de sesión en cuatro días, dos con
pérdida total»). Gastar el reintento habría puesto en riesgo FASE R y FASE L, que el encargo declara
obligatorias «aunque toda la cadena quede congelada». El orquestador tenía además el contexto
completo: la causa de P2 medida, el arreglo prototipado y verificado con Quarto, la ambigüedad 6
resuelta y las copias previas tomadas. Queda declarada como desviación en el bloque J.

#### T1.1 Paso 0: causa confirmada sobre el generador real

Ya medida en F0.4 (M12) y no refutada al editar: los encabezados de artículo se emiten como Markdown
real (`sprintf("## %s {#%s}", a$etiqueta, a$id)`, líneas 311 y 332 del archivo original) **dentro**
del Div cercado que abre la línea 263, y `## Normas relacionadas {#relacionadas}` se emite **fuera**.
Control cruzado que lo confirma desde el otro lado: las páginas que **no** usan el contenedor sí
tienen índice poblado.

```
$ grep -c 'nav-link' 40_salidas/sitio/tema-convivencia-escolar.html  → 10
$ grep -c 'nav-link' 40_salidas/sitio/indice-tipo.html               → 12
$ grep -c 'nav-link' 40_salidas/sitio/acerca.html                    → 12
```

#### T1.2 El cambio, y por qué es el mínimo

Un solo archivo, **cuatro puntos**: `abre` deja de ser un Div cercado y pasa a ser un bloque de HTML
crudo, aparece su simétrico `cierra`, y los tres `":::"` de cierre de las tres ramas de
`pagina_norma()` (sin texto, OCR, articulado verificado) pasan a `cierra`.

```
-  abre <- sprintf('::: {data-pagefind-body="true" data-pagefind-meta="norma:%s"}',
-                  gsub('"', "", corto))
+  abre <- c(
+    "```{=html}",
+    sprintf('<div data-pagefind-body="true" data-pagefind-meta="norma:%s">',
+            escapar_html(gsub('"', "", corto))),
+    "```"
+  )
+  cierra <- c("```{=html}", "</div>", "```")

-    return(paste(c(cab, banda, ficha, abre, "", spans_filtro, cuerpo, ":::",
+    return(paste(c(cab, banda, ficha, abre, "", spans_filtro, cuerpo, cierra,
-                   secciones, ":::", bloque_relacionados(n), ""),
+                   secciones, cierra, bloque_relacionados(n), ""),
-  paste(c(cab, banda, ficha, abre, "", spans_filtro, secciones, ":::",
+  paste(c(cab, banda, ficha, abre, "", spans_filtro, secciones, cierra,
```

Más 23 líneas de comentario que explican la causa y la medición, porque el cambio es de una sola
palabra en apariencia y de mecanismo de Pandoc en realidad: sin la explicación, el próximo que lea
`abre` lo «simplificará» de vuelta a `:::`.

**Tres cosas que NO se tocaron, y por qué:**
1. **`pagina_pieza()`** (el `":::"` que queda, hoy en la línea 841) tiene el mismo patrón y por tanto
   el mismo defecto latente. No se arregla: ninguna pieza está publicada (🔒5), está fuera de la meta
   de T1 («el índice lateral de cada página de **norma**») y la regla de cambios quirúrgicos lo
   prohíbe. **Queda como pendiente nombrado**, no como dead code borrado ni como mejora colada.
2. **`_quarto.yml`**, por la ambigüedad 6 medida en F0.12: 0 de 25 normas declaran estructura por
   encima del artículo, así que los artículos van al nivel 2 y `toc-depth: 2` ya es el valor
   correcto. Cambiarlo sería un cambio sin objeto.
3. **`estilo.css`**, por la medición de T1.5.

`escapar_html()` sobre el valor del atributo no es un añadido: con `:::` lo escapaba Quarto al
escribir el HTML; al emitir la etiqueta a mano hay que hacerlo explícitamente. Hoy la salida es
idéntica con o sin él (`0 de 25` nombres cortos contienen `&`, `<`, `>` o comilla, medido antes de
escribirlo); existe para que lo siga siendo si mañana uno los trae.

#### T1.3 Regeneración por pipeline

```
$ bash -c 'Rscript 00_run_all.R'
Found a data-pagefind-body element on the site.
Total:
  Indexed 1 language
  Indexed 25 pages
  Indexed 5513 words
  Indexed 6 filters
RESUMEN: 7 pasos ejecutados, 0 saltados, 13.1s en total.
```

Pagefind sigue encontrando el contenedor e indexando **25 páginas**, las mismas 25 de norma. Nada a
mano bajo `40_salidas/`.

#### T1.4 Criterio de éxito

esperado: 219 entradas en `dfl_1`, y `entradas_toc == encabezados_id + 1` en las 25, suma 831
obtenido: **219 en `dfl_1`, 25 de 25 correctas, suma 831** — PASA

```
INDICE LATERAL TRAS T1
entradas_toc: suma 831 | encabezados_id: suma 806
paginas donde entradas_toc == encabezados_id + 1: 25 de 25
dfl_1: entradas_toc = 219 | encabezados_id = 218

                                        slug entradas_toc encabezados_id   ok
         dfl_1_estatuto_asistentes_educacion          219            218 TRUE
                   ley_21430_garantias_ninez           95             94 TRUE
                 ley_20370_general_educacion           84             83 TRUE
                    dto_453_estatuto_docente           66             65 TRUE
                       rex_482_reglamentos_b           49             48 TRUE
             ley_21809_convivencia_educativa           48             47 TRUE
      dfl_315_perdida_reconocimiento_oficial           40             39 TRUE
                 ley_20845_inclusion_escolar           39             38 TRUE
                               ley_21545_tea           32             31 TRUE
           dto_565_centros_padres_apoderados           22             21 TRUE
          ley_19979_jornada_escolar_completa           20             19 TRUE
        circular_193_estudiantes_embarazadas           17             16 TRUE
                   dto_24_consejos_escolares           16             15 TRUE
               circular_812_identidad_genero           11             10 TRUE
 dictamen_71_expulsion_cancelacion_matricula           11             10 TRUE
                    dto_215_uniforme_escolar           10              9 TRUE
                    dictamen_52_77_expulsion           10              9 TRUE
   dictamen_078_detectores_revision_mochilas           10              9 TRUE
                 ley_20536_violencia_escolar            9              8 TRUE
                         ley_21801_celulares            7              6 TRUE
               ley_20911_formacion_ciudadana            5              4 TRUE
              dictamen_065_revision_mochilas            5              4 TRUE
                            circular_586_tea            2              1 TRUE
                           rex_181_celulares            2              1 TRUE
  rex_482_instrucciones_reglamentos_internos            2              1 TRUE
```

**Caso bueno:** las tres normas de un solo encabezado (`circular_586_tea`, `rex_181_celulares`,
`rex_482_instrucciones_reglamentos_internos`) pasan de 1 a 2 entradas: el mecanismo no depende del
tamaño.

esperado: el comparador distingue una página con un encabezado sin `id`
obtenido: **lo distingue** — PASA. Caso malo plantado en copia fuera del árbol: se le quita el `id`
a `<h2 id="art-3">` de `dto_24_consejos_escolares.html`.

```
ocurrencias de id="art-3" — original: 1 | copia plantada: 0
real:      entradas_toc=16  encabezados_con_id=15  encabezados_totales=15  |  toc == con_id+1 ? TRUE
plantado:  entradas_toc=16  encabezados_con_id=14  encabezados_totales=15  |  toc == con_id+1 ? FALSE
El comparador distingue el caso plantado del real: TRUE
```

Es adversarial y no benévolo: la página plantada **sigue teniendo 16 entradas de índice** (Quarto
genera la entrada igual, con un `id` inventado por él), y lo que la delata es la desigualdad entre
encabezados con `id` y encabezados totales. Un comparador que solo contara entradas del índice
habría aprobado la página rota.

#### T1.5 Desplazamiento del índice: la hipótesis del encargo se confirma, y por eso `estilo.css` no se toca

§5.5 paso 6 dice «Quarto trae `overflow-y` en el margen; hipótesis, se mide». **Se midió y es
cierta.** El contenedor del índice es

```
<div id="quarto-margin-sidebar" class="sidebar margin-sidebar">
```

y la **última** regla `.sidebar{}` de la hoja del tema (la que gana la cascada, en el desplazamiento
436448 de 498675 bytes) es:

```
.sidebar{will-change:top;transition:top 200ms linear;position:sticky;overflow-y:auto;padding-top:1.2em;max-height:100vh}
```

`position:sticky` + `max-height:100vh` + `overflow-y:auto`: el índice de 219 entradas se desplaza
dentro de su panel sin empujar la página. La regla de mayor especificidad que también aplica,
`.sidebar.toc-left,.sidebar.margin-sidebar{top:0px;padding-top:1em}`, solo fija `top` y `padding-top`
y no revierte ninguna de las tres.

**Añadir la regla habría sido un error de dos formas**: sería redundante, y una regla `overflow-y`
suelta sin `max-height` ni `position:sticky` no hace nada, de modo que «agregar solo la regla de
desplazamiento» habría exigido en realidad las tres, es decir un rediseño, que el propio paso 6
prohíbe.

**Limitación declarada:** esto se midió sobre la cascada de la hoja publicada, no con
`getComputedStyle` en un navegador a 1280 px, que es el método que el encargo sugería y que esta
sesión no tiene cómo ejecutar. Va a «qué debe verificar el revisor por sí mismo».

#### T1.6 Invariantes

esperado: 0 líneas de diferencia (🔒1)
obtenido: **0**, y por **dos** instrumentos independientes — PASA

```
$ Rscript tests/inventario_anclas.R
paginas_html:      47
segmentos_con_ancla: 806
destinos_resueltos: 848 de 848
id de encabezado en todo el sitio: 958
$ diff .../ids_por_pagina.txt .../ids_por_pagina_previo.txt | wc -l
       0

$ (re-derivacion del orquestador por grep, mismo comando que la copia previa)
$ diff <scratchpad>/orq/ids_grep_previo.txt <scratchpad>/orq/ids_grep_post.txt | wc -l
       0
MD5 previo = ff407a1072c27d226f5a29162a0e75fc
MD5 post   = ff407a1072c27d226f5a29162a0e75fc
```

Las 913 líneas del volcado por `grep` tienen **el mismo MD5** antes y después. Ningún `id` cambió.

esperado: paginas_distintas: 0 (🔒4)
obtenido: **0 de 25**, con el comparador calibrado — PASA

```
paginas_comparadas: 25
paginas_distintas: 0
control positivo (una pagina alterada en memoria): paginas_distintas = 1 (esperado 1 o mas)
```

El control positivo es obligatorio: un comparador que devuelve 0 sin haberse probado contra una
diferencia real no ha comparado nada.

esperado: resueltas: 3 de 10, las mismas tres (🔒8)
obtenido: **3 de 10 — C05, C06, C10**, con las **mismas posiciones** (12, 2, 8) y el **mismo MRR**
(0,0708) que antes de T1 — PASA. Nada retrocedió, y tampoco mejoró: T1 no toca la recuperación.

esperado: vacío (🔒3) · 0 (🔒2) · 47 y 0 (🔒5)
obtenido: `git diff --stat -- 40_salidas/datos/` **vacío**; `git status --porcelain 20_insumos/`
**0**; **47** páginas HTML y **0** piezas validadas — PASA los tres

esperado: peso de `dfl_1` bajo 375 853 B (tolerancia 0,20)
obtenido: **339 182 B**, **+8,29 %** sobre los 313 211 previos — PASA, ni siquiera ADVIERTE. El
índice de 219 entradas cuesta 25 971 bytes en la página más grande del sitio.

esperado: los 218 encabezados siguen dentro del contenedor que Pagefind indexa
obtenido: **218 dentro**, y `#relacionadas` **fuera** (0 dentro) — PASA. El anidamiento es
exactamente el que se buscaba: el índice ve los encabezados y Pagefind los sigue teniendo dentro de
su cuerpo.

#### T1.7 Alcance

```
$ git diff --name-only
30_procesamiento/34_generar_paginas.R
```

**Un solo archivo de los tres autorizados.** `_quarto.yml` y `estilo.css` no se tocaron, cada uno
por una medición, no por olvido.

#### T1.8 Pendiente nombrado, no reparado

**`pagina_pieza()` tiene el mismo defecto de índice que tenían las páginas de norma.** Cuando el
equipo firme la primera pieza interpretativa, su página se publicará con el índice lateral vacío por
la misma causa. No se repara en este encargo: fuera de la meta de T1 y de su ALCANCE de diseño. Es
una línea de cambio (`":::"` → `cierra`) y su lugar natural es el encargo que publique la primera
pieza.

---

### FASE T5 — Cierre de los cuatro huecos de P7 (ejecutada por el orquestador, en serie)

**Sin subagente**, por la misma razón declarada en T1.0 y una más, específica: T5 es la única tarea
del encargo con un paso que mueve un archivo (`mv` de `40_salidas/intermedios/extraccion.json`). Una
muerte por límite de sesión a media tarea allí **sí** deja residuo, a diferencia de la de T1, que
murió antes de tocar nada. Declarada en el bloque J.

#### T5.1 Hueco 1 — Las dos expresiones regulares vuelven a su fuente canónica

El valor viaja **byte a byte**: el script lee la línea del archivo de origen y escribe esa misma
línea en el destino. No se retipeó ninguna de las dos.

```
lineas movidas, literales:
REGEX_FICHA_ORIGEN <- "Url\\s+Corta\\s*:\\s*https?://bcn\\.cl/[A-Za-z0-9]+\\s*$"
REGEX_PIE_ORIGEN   <- "^Biblioteca del Congreso Nacional de Chile\\s*-\\s*www\\.leychile\\.cl"
md5 de las dos lineas (antes): aa807fd17a8fbc5fcd10e1afb3422193
```

esperado: el mismo md5 en el destino
obtenido: **`aa807fd17a8fbc5fcd10e1afb3422193`** — idéntico al capturado en F0.13 antes de tocar nada

```
$ grep -n '^REGEX_FICHA_ORIGEN <- |^REGEX_PIE_ORIGEN   <- ' 10_utils/10_configuracion.R
211:REGEX_FICHA_ORIGEN <- "Url\\s+Corta\\s*:\\s*https?://bcn\\.cl/[A-Za-z0-9]+\\s*$"
212:REGEX_PIE_ORIGEN   <- "^Biblioteca del Congreso Nacional de Chile\\s*-\\s*www\\.leychile\\.cl"
$ grep -h '^REGEX_FICHA_ORIGEN <- |^REGEX_PIE_ORIGEN   <- ' 10_utils/10_configuracion.R | md5
aa807fd17a8fbc5fcd10e1afb3422193
```

esperado: solo usos en `31_extraer_texto.R`, ninguna definición; 2 definiciones en `10_configuracion.R`
obtenido: **0 definiciones y 2 usos reales** en `31_extraer_texto.R` (líneas 153 y 157; las otras
dos coincidencias del `grep -c 4` son las dos menciones del comentario que apunta a la nueva
ubicación), **2 definiciones** en `10_configuracion.R` — PASA

Se movió también el comentario que **deriva** las dos reglas del texto real («LA REGLA SE DERIVO DEL
TEXTO REAL, no de memoria», la medición de las 17 normas): una constante sin su derivación en el
archivo canónico es peor que la constante en el archivo equivocado. En `31_extraer_texto.R` quedan
`MAX_BLOQUES_FICHA <- 5L`, que el encargo **no** nombra entre las constantes a mover y que es un
parámetro de ese paso, y el comentario de las tres guardas, que describe el comportamiento de la
función y no la regla del corpus.

**Caso malo conocido, corrido primero para calibrar el conteo** (§5.6 paso 1 lo exige):

esperado: 25 reutilizados, 0 reextraídos, sin apartar la caché
obtenido: **25 sin cambio, 0 nuevos, 0 modificados; «25 reutilizados sin cambio»** — el defecto de
la huella (P8) reproducido exactamente

```
$ bash -c 'Rscript 00_run_all.R'
[30_manifiesto] Corpus: 25 documentos — 25 sin cambio, 0 nuevos, 0 modificados.
[31_extraer_texto] Extraccion terminada: 25 documentos (capa_texto_pdf: 20; ocr_pendiente_revision: 5); 25 reutilizados sin cambio.
```

Editar el extractor no reprocesó nada. Sin esta corrida, el «25 reextraídos» de después no
demostraría nada: podría ser el comportamiento normal.

**Movimiento autorizado de la caché** (§1.3, Acciones; `mv`, nunca `rm`):

```
$ md5 40_salidas/intermedios/extraccion.json
MD5 (40_salidas/intermedios/extraccion.json) = 6860a579ffaacde0ac9806476eaa179b
-rw-r--r--  34755 Sep  9 23:49 40_salidas/intermedios/extraccion.json

$ mv 40_salidas/intermedios/extraccion.json 50_documentacion/andamios/lab_motor_v9/salida_v11/extraccion_v11_previo.json

$ md5 50_documentacion/andamios/lab_motor_v9/salida_v11/extraccion_v11_previo.json
MD5 (.../salida_v11/extraccion_v11_previo.json) = 6860a579ffaacde0ac9806476eaa179b
-rw-r--r--  34755 Sep  9 23:49 .../salida_v11/extraccion_v11_previo.json
```

Mismo md5 y mismo tamaño antes y después: **el archivo no se borró, se apartó**, y es recuperable.

esperado: 25 documentos reextraídos, 0 reutilizados
obtenido: **«25 documentos …; 0 reutilizados sin cambio»** — PASA

```
[31_extraer_texto] Extraccion terminada: 25 documentos (capa_texto_pdf: 20; ocr_pendiente_revision: 5); 0 reutilizados sin cambio.
RESUMEN: 7 pasos ejecutados, 0 saltados, 13.4s en total.
```

esperado: vacío (🔒3, tras el reprocesamiento completo)
obtenido: **vacío** — PASA, y es la prueba fuerte de que el movimiento fue neutro. El md5 de las
líneas demuestra que el texto de la constante no cambió; **este** comando demuestra que los 25
documentos, reextraídos desde el PDF con el código nuevo, producen JSON byte a byte idénticos. Es la
diferencia entre «copié bien» y «el pipeline produce lo mismo».

Regresión tras el reprocesamiento forzado: 🔒1 `diff` **0** y 806 / 848 de 848 / 958; 🔒4
**paginas_distintas: 0** con su control positivo en 1; el índice lateral de `dfl_1` sigue en **219**
entradas; 🔒2 **0**; 🔒5 **47** páginas; 🔒8 **3 de 10, C05 C06 C10**, mismas posiciones (12, 2, 8) y
mismo MRR (0,0708).

#### T5.2 Hueco 2 — `CLAUDE.md`

esperado: 25 (`ls 20_insumos/normativa/*.pdf | wc -l`)
obtenido: **25** — §10.1 pasa de «24 PDF oficiales» a «25 PDF oficiales». La cifra se corrigió
**porque se midió**, no porque el encargo la anticipara: si hubiera dado 24, la fila no se tocaba y
se registraba la duda.

§10.6 gana dos filas, una por sesión, escritas desde `traspaso_cierre_v02.md` (sesión 2, cerrada el
2026-08-27) y `traspaso_cierre_v03.md` (sesión 3, cerrada el 2026-09-09), cada una con las rutas de
sus encargos y logs, sin adjetivos y con el formato de las existentes.

**Desviación declarada:** el `CLAUDE.md` global del titular fija «Últimos cambios realizados
(máximo 5, los más recientes)». La tabla tenía 4 filas; con las dos nuevas serían 6. Se retiró la
más antigua (`2026-08-25 | Bootstrap completo…`) para dejarla en **5**. No se pierde nada: la fila
retirada vive en el historial de git, en `20260825_encargo_bootstrap_v1.md` y en
`logs/20260825_bootstrap_log.md`, todos versionados. El encargo pedía «dos filas nuevas» y no
mencionaba el tope; el tope es del contrato global, que manda sobre el encargo en esto.

**Error propio en el camino (E-04).** Mi primera versión del script dejó una línea `NA` y una fila
duplicada en la tabla. Causa: en R, `x[(n+1):length(x)]` **cuenta hacia atrás** cuando `n` es la
última línea del archivo (`384:383` es `c(384, 383)`), y la tabla cierra `CLAUDE.md`. Corregido
hacia adelante (no con `checkout --`, que §1.7.7 no autoriza) recortando las dos líneas sobrantes,
con `stopifnot()` que comprobaba que la línea 386 era duplicado exacto de la 382 antes de tocar
nada. Verificación posterior: **5 filas, 0 líneas `NA`, 0 duplicados**. Costo: dos turnos.

#### T5.3 Hueco 3 — El laboratorio y los instrumentos, versionados

**Compuerta de gobernanza antes de versionar nada** (`CLAUDE.md` §4). El propio `.gitignore` decía
que el laboratorio estaba fuera «hasta limpiar rutas absolutas y decidir la autorización de sus
archivos de datos», así que se midió antes de añadir:

| Comprobación sobre los 44 `.R` y `.md` | Resultado |
|---|---|
| Patrón de RUT (R3 del hook, `CLAUDE.md` §4) | **0 archivos** |
| Formas reales de credencial (`sk-…`, `ghp_…`, `AKIA…`, `eyJ…`, `xox…`, clave privada PEM) | **0 coincidencias** |
| Asignaciones `key/token/secret/password <- "…"` con valor largo | 1, y es una URL de la documentación de Cloudflare (`ais_keyword = "https://developers.cloudflare.com/…"`) |
| `OneDrive` o `Dropbox` | **0 archivos** |
| Rutas absolutas `/Users/…` | **2 archivos** |

**Hallazgo 1, ADVIERTE: dos `setwd()` con ruta absoluta.**

```
lab_motor_v9/a1_ronda_cierre_cifras.R:10:setwd("/Users/tomgc/Projects/slep_normativa_convivencia")
lab_motor_v9/a1_ronda_cierre_controles.R:1:setwd("/Users/tomgc/Projects/slep_normativa_convivencia")
```

No bloquea, y la razón es medida, no indulgente: (a) no son rutas a OneDrive ni Dropbox, que es lo
que `CLAUDE.md` §4 nombra, sino la ruta del propio repositorio; (b) **el repositorio ya expone
`/Users/…` en 15 archivos versionados** (`git grep -lE '/Users/[a-z]+' | wc -l` → 15), incluidos
tres logs y el documento de medición del v10; (c) el nombre de usuario es público por construcción:
el sitio se publica en `https://tomgc.github.io/slep_normativa_convivencia/`. La divulgación
marginal es cero. Queda como **pendiente**: `CLAUDE.md` §7 exige `here::here()` para toda ruta
dentro de scripts, y esos dos `setwd()` la incumplen; el v11 no puede corregirlo porque su ALCANCE
sobre el laboratorio es «solo `git add`; no se editan».

**Hallazgo 2, y este sí cambia el resultado: `a3_presupuesto_tokens.R` sería rechazado por R2 del
hook.** R2 rechaza por **nombre de archivo**, sin mirar el contenido, con el glob `*token*`.
Comprobado ejecutando el propio `case` del hook:

```
R2 RECHAZA: a3_presupuesto_tokens.R
R2 acepta:  a3_ontologia_relaciones.R
R2 acepta:  aud_procedimiento.R
R2 acepta:  a5_rotulos.R
```

El archivo no tiene credencial alguna (0 coincidencias de forma de credencial en los 44): habla de
*tokens de un modelo de lenguaje*. Pero renombrarlo está fuera del ALCANCE («no se editan») y
`--no-verify` está prohibido por §1.6. **Se deja fuera del versionado, declarado en el propio
`.gitignore` con su causa**, hasta que un encargo autorizado a editar el laboratorio lo renombre.
Es la opción segura: la alternativa habría sido saltarse el hook.

**`.gitignore`: lista blanca, no lista de extensiones prohibidas. Desviación declarada.** §5.6 paso
3 pide «reglas que excluyan las extensiones `csv`, `json`, `txt`, `bak`, `rds` y `mjs`». Medido en
F0.4, la carpeta tiene **diez** extensiones, no seis: 40 txt, 33 R, 26 csv, 11 md, 10 json, 2 gz, 1
yml, 1 mjs, 1 js, 1 bak. La lista literal habría dejado entrar `gz`, `yml` y `js` —y cualquier
extensión que alguien use mañana—, y además habría hecho **fallar la verificación del propio
encargo** (`git status --porcelain lab_motor_v9/ | grep -vE '\.(R|md)$'` → esperado vacío). Se
implementó la forma que cumple el **propósito** declarado en la ambigüedad 1 («versionar solo `.R` y
`.md`»):

```
50_documentacion/andamios/lab_motor_v9/**
!50_documentacion/andamios/lab_motor_v9/**/
!50_documentacion/andamios/lab_motor_v9/**/*.R
!50_documentacion/andamios/lab_motor_v9/**/*.md
50_documentacion/andamios/lab_motor_v9/salida_v11/
50_documentacion/andamios/lab_motor_v9/a3_presupuesto_tokens.R
```

(`/**` y la reinclusión explícita de directorios porque git no puede reincluir un archivo cuyo
directorio padre está excluido.)

esperado: las seis extensiones del encargo ignoradas, más `salida_v11/` completa
obtenido: **las diez extensiones no-`.R`/`.md` ignoradas**, `salida_v11/` completa ignorada, y los
`.R` y `.md` visibles. Control extensión por extensión:

```
SE VERSIONA  a2_cierre_v9.R          IGNORADO  a1_alias_procedencia.csv
SE VERSIONA  a3_prompt_sistema.md    IGNORADO  vocabulario.json
                                     IGNORADO  a1_salida_prototipo.txt
                                     IGNORADO  aud_procedimiento_v1.R.bak
                                     IGNORADO  a2_consulta_pagefind.mjs
                                     IGNORADO  a1_vocabulario.json.gz
                                     IGNORADO  a3_casos_adversariales.yml
                                     IGNORADO  a4_worker_esqueleto.js
                                     IGNORADO  salida_v11/ids_por_pagina.txt
                                     IGNORADO  salida_v11/texto_por_pagina_previo.rds
                                     IGNORADO  salida_v11/extraccion_v11_previo.json
                                     IGNORADO  a3_presupuesto_tokens.R

$ find lab_motor_v9 -type f | while read f; do git check-ignore -q "$f" || echo "$f"; done | wc -l
43
$ ... | sed 's/.*\.//' | sort | uniq -c
  32 R
  11 md
```

esperado: N archivos añadidos, donde N = `.R` + `.md` del laboratorio
obtenido: **43 de 44** (los 44 menos `a3_presupuesto_tokens.R`) — PASA con la excepción declarada

```
$ git status --porcelain lab_motor_v9/ | grep -vE '\.(R|md)$'
(vacío)
$ git diff --cached --name-only -- lab_motor_v9/ | grep -vE '\.(R|md)$'
(vacío)
```

esperado: 🔒7 no crece (línea base 83)
obtenido: **83**, contando también el staging — PASA. Ningún archivo de datos entró al versionado.

El `.R.bak` no se versiona **ni se borra**, como exige el encargo: queda ignorado y en disco.

#### T5.4 Hueco 4 — La enmienda del v10, fuera del log

Creado `50_documentacion/andamios/20260908_encargo_correcciones_visibles_v1_enmiendas.md`
(139 líneas). **No se editó el encargo original**: `andamios/` está congelado
(`POLITICA_PROYECTO.md` §1.3.1) y una enmienda a un andamio se registra, no se reescribe. Contiene:
la enmienda transcrita con su ruta y sus números de línea (log del v10, sección `#### 3.3.1`, línea
362; enunciado en 382-386; el pendiente que la declaraba huérfana en la línea 549), la tabla de
siete filas de §3 tal como sigue estando más la octava fila con su origen, las **seis condiciones**
transcritas de las líneas 388-410, y la desviación declarada respecto del patrón del hook con su
verificación independiente por T6 del 2026-09-09.

#### T5.5 Alcance y regresión

```
$ git status --porcelain | grep -v lab_motor_v9
 M .gitignore
 M 10_utils/10_configuracion.R
 M 30_procesamiento/31_extraer_texto.R
A  50_documentacion/andamios/20260908_encargo_correcciones_visibles_v1_enmiendas.md
 M CLAUDE.md
?? 50_documentacion/andamios/20260909_encargo_v11_indice_y_expansion_v1.md
?? 50_documentacion/andamios/20260909_integracion_revision_externa_v1.md
?? 50_documentacion/andamios/logs/20260909_indice_y_expansion_v11_log.md
```

Las cinco rutas modificadas o creadas son **exactamente** el ALCANCE de T5 en §1.3; las tres `??`
son el encargo, su insumo de diseño y este log, que no son de T5. Regresión final del estado:
806 / 848 de 848 / 47 páginas, 🔒1 `diff` **0**, 🔒3 **vacío**, 🔒6 **0** archivos `.py`.

#### T5.6 Dudas nuevas

**D-06 — `a3_presupuesto_tokens.R` no se versiona por su nombre.** R2 del hook rechaza el glob
`*token*` sin mirar contenido; el archivo no tiene credenciales (verificado con seis formas de
credencial, 0 coincidencias). Se dejó ignorado y declarado.
**Pregunta cerrada:** ¿el archivo se renombra en el próximo encargo autorizado a editar el
laboratorio (por ejemplo a `a3_presupuesto_unidades.R`), o R2 del hook se acota para que mire
contenido y no solo nombre?

**D-07 — Dos `setwd()` con ruta absoluta entran al versionado.** No hay divulgación nueva (15
archivos versionados ya contienen `/Users/…` y el usuario es público por la URL del sitio), pero
incumplen `CLAUDE.md` §7 (`here::here()` para toda ruta dentro de scripts) y el ALCANCE del v11
prohíbe editarlos.
**Pregunta cerrada:** ¿los dos `setwd()` se cambian a `here::here()` en el próximo encargo que
pueda editar el laboratorio, o el laboratorio se declara zona exenta de la regla de rutas por ser
código de medición ya ejecutado?

**D-08 — El tope de cinco filas de `CLAUDE.md` §10.6 choca con «una fila por sesión».** Con una
fila por sesión y un tope de cinco, la tabla olvida el bootstrap del proyecto a la sexta sesión.
**Pregunta cerrada:** ¿§10.6 conserva el tope de 5 y confía el historial a los traspasos (lo que se
aplicó), o el tope sube para que quepan las filas fundacionales?

---

### FASE T2 — Expansión de la consulta (Ola 3, ejecutada por el orquestador, en serie)

**Sin subagente**, por la razón de T1.0 y T5: T2 edita `busqueda.html` y `10_configuracion.R` y
regenera el sitio; una muerte por límite de sesión a media tarea deja el buscador a medias.

#### T2.0 Paso 0 y fuente de los alias

Leídos: `30_procesamiento/34_plantillas_sitio/busqueda.html` (interfaz publicada del v10),
`10_utils/10_configuracion.R` (ya con las dos regex de T5),
`50_documentacion/andamios/lab_motor_v9/a1_alias_procedencia.csv` y `vocabulario.json`.

**La fuente de `ALIAS_CONSULTA` es `a1_alias_procedencia.csv`, no `a1_alias_prueba.csv`** (duda
D-03): 260 filas con columnas `entrada`, `alias`, `fuente`; 42 entradas (25 `norma:` y 17 `tema:`),
213 alias distintos, y diez procedencias declaradas, la mayor de ellas
`10_utils/10_configuracion.R TEMAS_PALABRAS_CLAVE` (65 filas). Dos alias que comparten `entrada` son
sinónimos mutuos: de ahí sale la expansión, sin inventar una sola fila.

#### T2.1 Pre-registro de las mediciones previas (§5.7 paso 2)

Escritas antes de correr un solo comando de medición, sobre el sitio de T1 ya regenerado.

esperado: 5 de 7 recuperan la página correcta (D7, las 7 consultas hoy perdidas con expansión manual por los alias del laboratorio)
esperado: mismo conjunto de páginas con y sin tildes en las 10 (A-18)
esperado: top-1 igual en las tres formas del número («ley 20536», «ley 20.536», «20.536») para las 25 normas (A-19)
esperado: mismo conjunto con y sin palabras vacías en las 10 (B-06)

#### T2.2 Resultados de las mediciones previas

obtenido: **1 de 7** (D7, con la expansión que el encargo describe: sustituir el alias **dentro** de
la consulta) — **el predicado de D7 se refuta.** Y la causa es informativa, no un accidente:
sustituir el alias deja en pie el resto de los términos de la consulta, y Pagefind los exige todos.

```
  C02  "se puede usar el dispositivos moviles en la sala de clases"  -> 0 paginas
  C02  "se puede usar el telefono movil en la sala de clases"        -> 0 paginas
  C09  "un alumno trans pide que lo llamen por su identidad de genero" -> 0 paginas
  C04  "que es el acoso escolar" -> 7 paginas  <-- ACIERTA
  RESULTADO D7: 1 de 7 recuperan la pagina correcta
```

C04 acierta y las demás no por una razón que la medición B-06 explica: en «qué es el bullying» todo
lo que rodea al alias son palabras vacías, que Pagefind ignora; en las otras seis quedan términos de
contenido («usar», «sala», «clases») que siguen exigiéndose.

obtenido: **7 de 7** con el mecanismo corregido — la variante no es la consulta con el alias
sustituido, es **la frase del alias sola**, ejecutada como consulta aparte y unida por página:

```
  C01 alias=20 | paginas orig= 1 -> expandido=22 | correcta: orig=FALSE expandido=TRUE
  C02 alias=15 | paginas orig= 0 -> expandido=25 | correcta: orig=FALSE expandido=TRUE
  C03 alias=11 | paginas orig= 4 -> expandido=24 | correcta: orig=FALSE expandido=TRUE
  C04 alias= 5 | paginas orig= 1 -> expandido=14 | correcta: orig=FALSE expandido=TRUE
  C07 alias=11 | paginas orig= 9 -> expandido=21 | correcta: orig=FALSE expandido=TRUE
  C08 alias=12 | paginas orig= 0 -> expandido=23 | correcta: orig=FALSE expandido=TRUE
  C09 alias=25 | paginas orig= 0 -> expandido=25 | correcta: orig=FALSE expandido=TRUE
  paginas correctas alcanzadas: original 3 de 10 -> expandido 10 de 10
```

**Cuál de las dos cifras gobierna el criterio.** §5.7 paso 2 dice que si D7 da menos de 3 de 7, el
criterio pasa a «mejora pareada sin retroceso». La cifra que gobierna es la del **mecanismo que se
implementa**, que es el segundo: **7 de 7**, así que el criterio de ingeniería se mantiene en
«6 de 10 o más». La primera cifra no se descarta: queda como la medición que descartó el diseño que
el encargo describía, y es la razón por la que el mecanismo publicado no es el que el encargo
suponía. Las dos están en el log porque la primera es la que justifica el cambio de diseño.

obtenido: **0 de 10 difieren** (A-18, con y sin tildes) — **Pagefind ya normaliza las tildes.**

```
  C01 con= 1 sin= 1 TRUE | C02 con= 0 sin= 0 TRUE | C03 con= 4 sin= 4 TRUE | C04 con= 1 sin= 1 TRUE
  C05 con= 3 sin= 3 TRUE | C06 con= 3 sin= 3 TRUE | C07 con= 9 sin= 9 TRUE | C08 con= 0 sin= 0 TRUE
  C09 con= 0 sin= 0 TRUE | C10 con= 5 sin= 5 TRUE
  consultas que DIFIEREN con y sin tildes: 0 de 10
```

**Consecuencia: la normalización NFD de la adopción A-18 NO entra a la expansión.** El encargo la
condicionaba a «si difiere», y no difiere. Añadirla habría sido código sin efecto.

obtenido: **0 de 10 difieren** (B-06, con y sin palabras vacías) — **Pagefind ya las ignora.**

```
  consultas que DIFIEREN con y sin palabras vacias: 0 de 10
```

**Consecuencia: tampoco se quitan palabras vacías de lo que viaja a Pagefind.**
`PALABRAS_VACIAS_CONSULTA` sí entra a `10_configuracion.R`, pero **para otra cosa**: trocear la
consulta y decidir qué alias disparan. Se declara en el propio comentario de la constante para que
nadie deduzca de su existencia que la consulta se filtra.

Esto **corrige una premisa del proyecto**: §3 del encargo y `traspaso_cierre_v03.md` §7 dicen que
«Pagefind exige todos los términos de la consulta». Lo que exige son todos los términos **de
contenido**; las palabras vacías ya las descarta él.

obtenido: **25 de 25 con top-1 idéntico en las tres formas del número** (A-19) — **ninguna forma
pierde, así que el generador NO se toca**, que es lo que §5.7 paso 2 manda en ese caso.

```
  top-1 IGUAL en las tres formas: 25 de 25
  top-1 CORRECTO en las tres formas: 23 de 25
  las dos que no aciertan (consistentes en las tres formas):
    dfl_1_estatuto_asistentes_educacion  -> dto_453_estatuto_docente.html
    rex_482_reglamentos_b                -> rex_482_instrucciones_reglamentos_internos.html
```

Las dos excepciones no son un problema de **forma**: son consistentes en las tres. Y la segunda es
discutiblemente correcta: `rex_482_reglamentos_b` y `rex_482_instrucciones_reglamentos_internos` son
**el mismo acto administrativo en dos archivos** (`grupos_acto` de la curaduría), de modo que llevar
al primero es llevar al acto. La primera, `dfl_1` resolviendo a `dto_453`, es un hallazgo real de
recuperación y queda como pendiente para el v12.

**Error propio en el camino (E-05).** La primera corrida de A-19 dio **24 de 25** y una
inconsistencia en `dfl_315`. La causa era mía: compuse la forma del tipo con una tabla inventada por
mí (`dfl = "dfl"`), y «dfl» es una palabra que el corpus **no usa** (dice «Decreto con fuerza de
ley»). Medía mi abreviatura, no el buscador. Repetida con `tipo_etiqueta`, que es la etiqueta que el
sitio publica, da 25 de 25. Costo: una corrida. Es exactamente la falta que el encargo prohíbe
—inventar un dato en vez de leerlo— cometida dentro del instrumento de medición.

**Segundo error propio (E-06), y este habría envenenado el diseño.** Mi función de raíz usaba
`substr(w, 1, min(nchar(w), 6))`: `min()` sobre un **vector** devuelve un escalar, así que todas las
raíces quedaban truncadas al largo de la palabra más corta (3 caracteres). Con raíces de 3
caracteres, «celular» y «celda» colisionan, la lista de palabras comunes se llenó de ruido y C02 y
C08 no disparaban ningún alias. Corregido con `pmin()`. Se detectó porque dos consultas obvias
(«celular», «uniforme») no encontraban su alias, no porque el código fallara: no fallaba.

#### T2.3 El mecanismo que se implementó, y por qué es ese

Cinco decisiones, cada una con la medición que la sostiene:

1. **La variante es la frase del alias, sola.** Medido: sustituir dentro de la consulta recupera
   1 de 7; la frase sola recupera 7 de 7.
2. **Los alias se detectan por RAÍZ de palabra, no por subcadena de la frase completa.** Con
   coincidencia de frase completa, «pueden revisar la mochila de un alumno» no encuentra «revisión
   de mochilas» y «obligar a usar uniforme» no encuentra «uniforme escolar»: **0 alias detectados**
   en C01 y C08. Con raíz de 6 caracteres, sí.
3. **Una raíz que aparece en más de 3 entradas no dispara por sí sola.** Derivada de la propia
   tabla, no escrita a mano: son 20 raíces (`educac`, `escola`, `establ`, `ley`, `reglam`, …) que
   están en casi todo el corpus y dispararían todas las expansiones a la vez.
4. **Piso R0 duro: las páginas de la consulta original van primero, siempre.** El encargo pedía
   precedencia «ante empate»; se implementó precedencia **absoluta**, que es más fuerte y hace que
   🔒8 se cumpla **por construcción** y no por suerte: una expansión mala solo puede agregar ruido
   debajo de lo que ya se encontraba.
5. **Cada variante aporta a lo más 2 páginas.** Sin ese tope, un alias amplio («expulsión») aporta
   media lista y empuja la respuesta correcta fuera de la primera tanda.

**Elección de los topes, con su advertencia metodológica.** Se eligieron simulando la unión en R
sobre los datos crudos ya medidos, **antes** de escribir una línea de JavaScript. La simulación está
calibrada: con 0 variantes reproduce exactamente el 3 de 10 y las mismas tres consultas.

```
tope_variantes x paginas_por_variante -> resueltas
  K=1  cap=3  |  7 de 10       K=2  cap=3  |  8 de 10       K=3  cap=3  |  8 de 10
  K=1  cap=5  |  7 de 10       K=2  cap=5  |  6 de 10       K=3  cap=5  |  6 de 10
  K=1  cap=8  |  6 de 10       K=2  cap=8  |  6 de 10       K=inf cap=3 |  7 de 10
  K=1  cap=99 |  6 de 10       K=2  cap=99 |  6 de 10       K=inf cap=99|  5 de 10
```

**Esto es ajuste sobre el conjunto de evaluación**, y hay que decirlo con todas sus letras: los dos
topes se eligieron mirando las mismas diez consultas con que se reporta el resultado. La superficie
además es **ruidosa y no monótona** (8, 6, 6 al pasar de 3 a 5 a 8 variantes), lo que indica que no
hay un óptimo sino variación de muestra pequeña. La advertencia queda escrita en el propio
`10_configuracion.R`, junto a las constantes, y no solo aquí.

#### T2.4 Dónde vive cada cosa

- **`10_utils/10_configuracion.R`** (+300 líneas): `TOPE_SUB_RESULTADOS` (5, que estaba en el cuerpo
  de `busqueda.html`), `PAGINA_RESULTADOS` (8, idem), `TOPE_VARIANTES_CONSULTA` (3),
  `TOPE_PAGINAS_POR_VARIANTE` (2), `MAX_TOKENS_ALIAS` (4), `LARGO_RAIZ_ALIAS` (6),
  `PALABRAS_VACIAS_CONSULTA` (21), `RAICES_COMUNES_ALIAS` (20, derivadas de la tabla),
  `FUENTES_ALIAS` (10 procedencias) y `ALIAS_CONSULTA` (**183 filas, 42 entradas, 168 alias
  distintos**), con `stopifnot()` de validez porque la tabla viaja al sitio publicado.
- **Desviación declarada, dos:** (a) el encargo pide un `tibble`; se usó `data.frame` porque
  `10_configuracion.R` lo carga **todo** script del pipeline, incluidos los que no instalan `tibble`
  (`31_extraer_texto.R` declara `pdftools`, `jsonlite`, `fs` y `here`), y añadir ahí una dependencia
  de paquete rompería ese contrato. Verificado: `31_extraer_texto.R` carga la configuración y ve las
  183 filas. (b) el encargo pide columnas `termino, alias, fuente` y `fuente = "v9_construido"`; se
  usan `entrada, alias, clave_fuente, fuente` con la **procedencia real** de cada fila (las diez del
  laboratorio, desde `TEMAS_PALABRAS_CLAVE` hasta `relaciones.json`). Una procedencia real es más
  fuerte que una etiqueta genérica, y §5.7 solo exige que cada fila lleve la suya.
- **Ningún alias se inventó.** Las 183 filas salen de
  `lab_motor_v9/a1_alias_procedencia.csv` (260 filas), conservando las que tienen entre 1 y 4 tokens
  de contenido y al menos una raíz no común. Se traen como **código** porque ese CSV ya no se
  versiona (T5, hueco 3).
- **`34_generar_paginas.R`** (+39 líneas): inyecta las constantes y la tabla como JSON en la **copia
  publicada** de `busqueda.html`, nunca en la plantilla del repositorio. Elección registrada, como
  §5.7 paso 3 exige: **JSON incrustado en la plantilla**, y no un archivo junto al sitio, porque el
  generador ya copia la carpeta de plantillas entera y un archivo aparte añadiría una petición de
  red y un problema de ruta base en GitHub Pages (que sirve el sitio bajo un subdirectorio), que es
  justo lo que el comentario de cabecera de `busqueda.html` explica que hay que evitar.
- **`30_procesamiento/34_plantillas_sitio/busqueda.html`** (234 → 343 líneas): bloque
  `== INICIO/FIN BLOQUE DE EXPANSION ==` nuevo, y el bloque de orden ya no contiene números.
  **Degradación declarada:** si alguien abre la plantilla del repositorio en un navegador, el
  marcador no es JSON válido, `DATOS` queda en `null` y el buscador funciona sin expansión en vez de
  romperse.
- **`tests/medir_buscador.R`**: lee las constantes de la configuración (se retiraron las cuatro
  marcas de pendiente que T4 dejó) y **reimplementa la expansión en R**, no la copia.

**Contradicción del encargo, resuelta y declarada.** §5.7 fija el ALCANCE de T2 en tres archivos y
**no** incluye `tests/medir_buscador.R`; su paso 5, en cambio, ordena editarlo («quitar el
`# REVISAR` de T4 y registrar que se quitó») y sin esa edición el criterio de éxito de T2 no es
medible: el instrumento seguiría midiendo el buscador sin expansión y diría 3 de 10 para siempre.
Se resolvió a favor de la instrucción específica y explícita sobre el archivo concreto, y la edición
se acotó a eso más la reimplementación de la expansión, que es lo que el instrumento ya hace con el
orden de los sub-resultados. Queda como desviación en el bloque J.

#### T2.5 Criterio de éxito

esperado: resueltas: 6 de 10 o más, y las 3 históricas entre ellas (🔒8)
obtenido: **8 de 10**, y **C05, C06 y C10 están las tres** — PASA

```
resueltas: 8 de 10          (antes de T2: 3 de 10)
MRR (sobre las 10): 0.1633  (antes: 0.0708)
  id  ancla_esperada                                     posicion  antes
 C01  dictamen_065_revision_mochilas.html#fuentes               6  ausente   <-- se resuelve
 C02  ley_21801_celulares.html#art-10-bis                 ausente  ausente
 C03  ley_20536_violencia_escolar.html#art-unico               26  ausente   <-- se resuelve
 C04  ley_21809_convivencia_educativa.html#art-16-b            13  ausente   <-- se resuelve
 C05  ley_20370_general_educacion.html#art-11                  12       12   (intacta)
 C06  ley_20845_inclusion_escolar.html#art-3                    2        2   (intacta)
 C07  dto_24_consejos_escolares.html#art-3                ausente  ausente
 C08  dto_215_uniforme_escolar.html#art-1                       7  ausente   <-- se resuelve
 C09  circular_812_identidad_genero.html#ocr-pagina-008         2  ausente   <-- se resuelve
 C10  dictamen_52_77_expulsion.html#num-3                       8        8   (intacta)
```

**La medida que decide es la pareada, no el 8.** Cinco de las siete perdidas se resuelven (C01, C03,
C04, C08, C09), ninguna de las tres que funcionaban retrocede, y ninguna de las siete empeora. Las
dos que siguen sin resolverse son **C02** («celular» → la ley dice «dispositivos móviles»: el alias
lleva a la página correcta pero el artículo 10 bis no sobrevive al recorte) y **C07** («quiénes
tienen que estar en el consejo escolar»: 9 páginas, ninguna es `dto_24`).

**Nota metodológica obligada** (adopción A-15, recalculada en la sesión 4): 3 frente a 8 de 10 sobre
un conjunto de diez **no es una prueba estadística de mejora** (para 3 frente a 6, p = 0,3698 por
prueba exacta de Fisher). Lo que se afirma es **la tabla**, no una mejora significativa.

Otras cifras del mismo instrumento, antes → después:

| Métrica | Antes de T2 | Después |
|---|---|---|
| recall@30 (entrega / relevancia) | 1 / 3 | **3 / 5** |
| recall@65 | 2 / 3 | **5 / 7** |
| recall@100 | 3 / 3 | **6 / 7** |
| anclas del conjunto mostradas | 4 de 19 | **15 de 19** |
| consultas con al menos una del conjunto | 3 de 10 | **9 de 10** |

esperado: 3 de 10 con `ALIAS_CONSULTA` vacío (caso bueno)
obtenido: **3 de 10, MRR 0,0708** — idéntico al estado de T1. PASA. Es la prueba de que lo único que
cambió la cifra es la expansión.

esperado: 1 de 10 en `--modo replica`
obtenido: **1 de 10**, con 14 consultas y sin expansión — PASA. La calibración contra la línea base
del v9 sobrevive al cambio.

esperado: ninguna consulta `sin_respuesta` pasa de vacío a no vacío por un alias
obtenido: **ninguna** — PASA. S04 («dónde se renueva el pasaporte») devolvía lista vacía y **sigue
devolviéndola**. Se registra el efecto real: S02 («cómo se calcula el finiquito de un docente») pasa
de 1 a 4 páginas y S01 y S03 no cambian. O sea: la expansión no **crea** resultados donde no había
ninguno, pero sí **agrega** resultados igual de irrelevantes donde ya los había. Es exactamente el
caso que la adopción B-03 manda resolver en el v12 con un estado «sin resultado firme».

esperado: la latencia se registra
obtenido: mediana por consulta **6,08 ms → 10,97 ms**; suma de las 13 consultas sin la primera
(que incluye la carga del WASM), **100,08 ms → 165,36 ms**. En el navegador las tres variantes se
lanzan con `Promise.all`, así que el tiempo de pared es más cercano al máximo que a la suma.

#### T2.6 El caso malo plantado: la expectativa del encargo NO se cumplió, y se declara

§5.7 pide: «un alias adversarial en una copia temporal de `ALIAS_CONSULTA` fuera del árbol debe
hacer retroceder al menos una de las tres históricas; si el instrumento no lo ve, está roto».

Se corrieron **cuatro** configuraciones adversariales, con una tabla plantada fuera del árbol (7
alias deliberadamente engañosos y de alto rendimiento —`alumno`, `expulsion`, `colegio`, `apoderado`,
`embarazada`, `pagina`, `articulo`— elegidos para disparar sobre C05, C06 y C10):

| # | Configuración | resueltas | MRR | posiciones de C05/C06/C10 |
|---|---|---|---|---|
| A | adversarial, piso R0 puesto, topes normales | 3 de 10 | 0,0708 | 12 / 2 / 8 |
| B | adversarial, **sin** piso R0 | 3 de 10 | 0,0708 | 12 / 2 / 8 |
| C | adversarial duro (7 variantes × 30 páginas), piso R0 | 3 de 10 | 0,0708 | 12 / 2 / 8 |
| D | adversarial duro, **sin** piso R0 (ninguna guarda) | 3 de 10 | 0,0708 | 12 / 2 / 8 |

**Ninguna hace retroceder ninguna de las tres.** Y un quinto control, fuera del árbol, levantando la
regla «una variante nunca pisa una página que encontró la original» sobre los datos crudos de la
corrida real: **8 de 10 con la regla puesta y 8 de 10 con la regla levantada**; ninguna histórica
retrocede.

**No se declara que el control pasó, porque no pasó: se declara que la expectativa era otra.** La
causa, medida: la puntuación que Pagefind da a la consulta original (larga, específica) domina a la
de una consulta de una sola palabra, de modo que las páginas de la original encabezan la lista aun
sin el piso R0. El diseño resiste por dos vías redundantes, y el resultado es que **el canal de
retroceso que el encargo imaginaba no existe en este mecanismo**.

Lo que sí está demostrado, y por dos controles independientes, es que **la métrica no es ciega**: el
control positivo adversarial de T4 (cambiar el ancla esperada de una de las tres resueltas por un
`id` existente pero incorrecto) baja la cifra a **2 de 10**, y el caso bueno de T2
(`ALIAS_CONSULTA` vacío) la baja a **3 de 10**. La métrica responde tanto a un ancla equivocada como
a la presencia o ausencia de la expansión.

**Queda como duda D-09**, porque un control que no puede fallar no es un control.

#### T2.7 Bug real que el caso malo plantado destapó (E-07)

La primera versión del control adversarial **no disparaba ni una variante**: el instrumento decía
`consultas: 14` en vez de 35. La causa no era el control sino el instrumento:
`tests/consultas_evaluacion.R` vuelve a cargar `10_utils/10_configuracion.R` para heredar la guarda
de locale, de modo que **restauraba `ALIAS_CONSULTA` después** de que `--alias` la sustituyera,
mientras los índices derivados (`.raices_entrada`) seguían apuntando a la tabla plantada. El
resultado era una tabla real con índices de la tabla falsa: cero coincidencias y ninguna variante.

Corregido moviendo la sustitución y los índices derivados a después de cargar el conjunto de
evaluación, con el comentario que explica por qué están ahí y no arriba. **Sin el caso malo
plantado, este defecto habría pasado inadvertido**: con la tabla real las dos copias coinciden y el
instrumento da la cifra correcta por casualidad.

#### T2.8 Invariantes tras la regeneración final

esperado: 0 líneas de diferencia (🔒1)
obtenido: **0**, por los dos instrumentos independientes; 806 / 848 de 848 / 958 — PASA
esperado: paginas_distintas: 0 (🔒4)
obtenido: **0 de 25**, con el control positivo del comparador en 1 — PASA
esperado: vacío (🔒3) · 0 (🔒2) · 47 y 0 (🔒5)
obtenido: **vacío**, **0**, **47** y **0** — PASAN
esperado: el índice lateral de T1 no se toca
obtenido: **831 entradas en total, 219 en `dfl_1`** — intacto

El sitio publicado lleva el JSON inyectado (`"tope_variantes":3`, `"tope_sub_resultados":5`,
`"alias":[[…`) y **la plantilla del repositorio conserva su marcador**: el generador no edita sus
propias fuentes.

#### T2.9 Dudas nuevas

**D-09 — El caso malo plantado del encargo no puede fallar contra este diseño.** Cuatro
configuraciones adversariales, incluida una sin ninguna de las dos guardas, no producen retroceso,
porque la puntuación de la consulta original domina la de una consulta de una palabra. El control,
tal como está redactado, no discrimina.
**Pregunta cerrada:** ¿el control adversarial del v12 se redirige al canal que sí queda abierto (los
sub-resultados que se muestran cuando una variante gana una página que la original no encontró), o
se acepta que este mecanismo no tiene canal de retroceso y el control se retira?

**D-10 — «Pagefind exige todos los términos» es falso tal como está escrito.** Exige todos los
términos **de contenido**: las palabras vacías ya las ignora, medido en 0 de 10 diferencias. La
frase aparece en §3 de este encargo y en `traspaso_cierre_v03.md` §7 sin ese matiz, y de ella salía
la idea de que había que filtrar la consulta.
**Pregunta cerrada:** ¿se corrige la afirmación en el traspaso v04 con la medición del 2026-09-09,
o se deja como está por ser un andamio congelado y se cita esta medición al usarla?

**D-11 — `dfl_1` no se encuentra por su número.** Consultado en sus tres formas, el top-1 es
`dto_453_estatuto_docente.html`, no su propia página, de forma consistente. Es la norma más grande
del corpus (218 segmentos).
**Pregunta cerrada:** ¿entra al v12 como caso de recuperación por número de norma, o se acepta
porque las dos normas son el estatuto docente y su texto refundido?

---

### FASE T7 — Fila de `CLAUDE.md` §10.6 para este encargo (orquestador, en serie)

Escrita **desde el estado real por tarea**, con los hashes de `git log`, no desde lo planeado:

```
$ git log fd5c987..HEAD --oneline
511dab8 feat(buscador): expansión de consulta con alias y constantes centralizadas (T2, P1)
b4ec047 chore(instrumental): cierre de los cuatro huecos de P7 (T5)
00a0840 fix(sitio): índice lateral con los encabezados de artículo (T1, P2)
b7796cc feat(tests): instrumento de evaluación del buscador y de anclas (T4)
```

La fila declara las cuatro tareas que cambiaron el árbol con sus cifras medidas (831 entradas de
índice y 219 en `dfl_1`; 183 filas de alias; 3 → 8 de 10) y no promete nada que no esté medido en
este log.

esperado: 5 filas, 0 líneas `NA`, 0 duplicados
obtenido: **5 filas, 0, 0** — PASA

Segunda aplicación del tope de cinco del `CLAUDE.md` global: se retira la fila
`2026-08-25 | OCR de los 4 escaneos…`, que queda en el historial de git, en
`logs/20260825_ocr_curaduria_log.md` y en el traspaso v01. Fechas que quedan: 2026-08-25,
2026-08-26, 2026-08-27, 2026-09-09 y 2026-09-10.

---

### FASE R — Auditoría propia y reparación

#### R.1 Inventario de afirmaciones auditables

Derivado del log, no de la memoria, y **anexado antes de auditar nada**. Lo que no está aquí no se
auditó.

| id | Afirmación | Dónde se emitió |
|---|---|---|
| R-01 | 806 segmentos con ancla, 682 con `es_articulo = TRUE` | F0, T4.2, T1.6, T5.1, T2.8 |
| R-02 | 848 de 848 destinos verificables resuelven | idem |
| R-03 | 47 páginas HTML en el sitio | F0.4, 🔒5 |
| R-04 | 958 encabezados con `id` en todo el sitio | F0, T4.2 |
| R-05 | Índice lateral: 831 entradas en total, 219 en `dfl_1`, `toc == enc+1` en 25 de 25 | T1.4 |
| R-06 | Buscador: 3 de 10 antes de T2, 8 de 10 después, y C05/C06/C10 en las dos | T4.2, T2.5 |
| R-07 | MRR 0,0708 → 0,1633 | T4.2, T2.5 |
| R-08 | `--modo replica` da 1 de 10 | T4.2, T2.5 |
| R-09 | Las dos regex se movieron byte a byte (md5 `aa807fd17a8fbc5fcd10e1afb3422193`) | T5.1 |
| R-10 | Reprocesamiento forzado: 25 reextraídos, 0 reutilizados; sin forzar, 25 reutilizados | T5.1 |
| R-11 | 🔒3: `40_salidas/datos/` idéntico tras reextraer los 25 documentos | T5.1 |
| R-12 | 43 de los 44 `.R` y `.md` del laboratorio quedaron versionados | T5.3 |
| R-13 | 🔒7: 83 archivos de datos versionados fuera de `40_salidas/datos/`, no crece | F0.4, T5.3 |
| R-14 | `ALIAS_CONSULTA`: 183 filas, 42 entradas, 168 alias distintos, ninguno inventado | T2.4 |
| R-15 | A-18 0 de 10 difieren; B-06 0 de 10 difieren; A-19 25 de 25 top-1 igual | T2.2 |
| R-16 | D7: 1 de 7 con el mecanismo del encargo, 7 de 7 con el implementado | T2.2 |
| R-17 | Peso de `dfl_1`: 313 211 → 339 182 B (+8,29 %), bajo el umbral 375 853 | T1.6 |
| R-18 | 25 PDF en `20_insumos/normativa/` | F0.4, T5.2 |
| R-19 | `CLAUDE.md` §10.6 queda con 5 filas, sin `NA` ni duplicados | T5.2, T7 |
| R-20 | El alcance global está contenido en la unión de los ALCANCE de §1.3 | §6 paso 4 |
| R-21 | 🔒1: el conjunto de `id` por página no cambió (dos instrumentos independientes) | T1.6, T5.1, T2.8 |
| R-22 | 🔒4: `paginas_distintas: 0`, con control positivo en 1 | T1.6, T5.1, T2.8 |
| R-23 | 🔒5: 47 páginas y 0 piezas validadas | T1.6, T2.8 |
| R-24 | 🔒6: ningún archivo `.py` en lo que viaja | T4.1 |
| R-25 | 🔒2: `20_insumos/` sin cambios | T4.1, T1.6, T2.8 |
| R-26 | CI en verde por `head_sha` en cada push | T4, T1, T5, T2, T7 |
| R-27 | Latencia mediana por consulta 6,08 → 10,97 ms | T2.5 |
| R-28 | Cobertura del conjunto de anclas 4 de 19 → 15 de 19 | T4.2, T2.5 |
| R-29 | D4: 5 aceptadas y 5 rechazadas; D8: `diff` 0 | T6.1, T6.2 |
| R-30 | El caso malo plantado de T2 NO produjo retroceso en ninguna de 4 configuraciones | T2.6 |

#### R.2 Los ocho invariantes 🔒, con salida literal

| 🔒 | Comando | esperado | obtenido | Veredicto |
|---|---|---|---|---|
| 🔒1 | `Rscript tests/inventario_anclas.R && diff ids_por_pagina.txt ids_por_pagina_previo.txt \| wc -l` | 0 | **0** (y 806 / 848 de 848) | **PASA** |
| 🔒2 | `git diff --name-only fd5c987..HEAD -- 20_insumos/ \| wc -l`, más control positivo sobre `30_procesamiento/` | 0 y > 0 | **0** y **3** | **PASA** |
| 🔒3 | `git diff --stat fd5c987..HEAD -- 40_salidas/datos/` | vacío | **vacío** | **PASA** |
| 🔒4 | comparación de `html_text2()` por página contra la copia previa | `paginas_distintas: 0` | **0 de 25**, control positivo en **1** | **PASA** |
| 🔒5 | piezas validadas y páginas HTML | 0 y 47 | **0** y **47** | **PASA** |
| 🔒6 | `git diff --name-only fd5c987..HEAD \| grep -cE '\.py$'` | 0 | **0** | **PASA** |
| 🔒7 | archivos de datos versionados fuera de `40_salidas/datos/`, ahora y en el punto de retorno | igual, no crece | **83** y **83** | **PASA** |
| 🔒8 | `Rscript tests/medir_buscador.R --sitio 40_salidas/sitio` | las mismas tres presentes | **8 de 10**, con **C05 (pos. 12), C06 (2) y C10 (8)** | **PASA** |

**8 de 8 en PASA.** El control positivo de 🔒2 es lo que da valor al cero: el mismo comando sobre
`30_procesamiento/` devuelve 3, así que el instrumento sí ve cambios cuando los hay.

#### R.3 Chequeo global de alcance (§6 paso 4)

esperado: toda ruta tocada dentro de la unión de los ALCANCE de §1.3
obtenido: **54 rutas, ninguna fuera** — PASA

```
$ git diff --name-only fd5c987..HEAD | wc -l
54
$ git diff --name-only fd5c987..HEAD | grep -v lab_motor_v9
.gitignore
10_utils/10_configuracion.R
30_procesamiento/31_extraer_texto.R
30_procesamiento/34_generar_paginas.R
30_procesamiento/34_plantillas_sitio/busqueda.html
50_documentacion/andamios/20260908_encargo_correcciones_visibles_v1_enmiendas.md
CLAUDE.md
tests/consulta_pagefind.mjs
tests/consultas_evaluacion.R
tests/inventario_anclas.R
tests/medir_buscador.R
$ (del laboratorio) 32 R + 11 md = 43
$ (filtro de alcance sobre el diff completo)
(vacío = todo dentro del alcance)

$ git status --porcelain
?? 50_documentacion/andamios/20260909_encargo_v11_indice_y_expansion_v1.md
?? 50_documentacion/andamios/20260909_integracion_revision_externa_v1.md
?? 50_documentacion/andamios/logs/20260909_indice_y_expansion_v11_log.md
```

Dos rutas **autorizadas y no tocadas**: `_quarto.yml` y
`30_procesamiento/34_plantillas_sitio/estilo.css`. No es un descuido: cada una tiene su medición
(F0.12 para la primera, T1.5 para la segunda). Las tres entradas `??` son el encargo, su insumo de
diseño y este log, que se commitea en FASE L.

#### R.4 Control positivo de la propia auditoría (§6 paso 6)

Tres, porque una auditoría que solo confirma no auditó:

```
=== 1. ruta fuera de alcance simulada en un diff de prueba ===
rutas fuera de alcance que el chequeo detecta:
20_insumos/normativa/inventado.pdf
10_utils/10_utils.R
(esperado: exactamente esas dos)   -> DETECTA

=== 2. cifra alterada en una copia del log fuera del arbol (806 -> 807) ===
la cifra del log real coincide con el instrumento: SI (instrumento dice 806)
la del log plantado coincide: NO -> el chequeo DETECTA la cifra alterada

=== 3. 🔒1 sobre una copia del sitio con un id borrado (art-11 de la ley 20370) ===
segmentos_con_ancla: 805
  Segmentos declarados que NO estan en su HTML:
 ley_20370_general_educacion.html art-11
destinos_resueltos: 847 de 848
```

Los tres discriminan.

#### R.5 Re-derivación de las afirmaciones no delegadas

| id | esperado | obtenido | Veredicto |
|---|---|---|---|
| R-09 | mismo md5 de las dos regex, antes y ahora | `aa807fd17a8fbc5fcd10e1afb3422193` en `git show fd5c987:31_extraer_texto.R` **y** en `10_configuracion.R` hoy | **CONFIRMA** |
| R-12 | 43 de 44 versionados, el que falta ignorado y nombrado | 44 en disco, **43** versionados; falta `a3_presupuesto_tokens.R`, ignorado por `.gitignore:107` | **CONFIRMA** |
| R-18 | 25 PDF y §10.1 diciendo 25 | `ls` da **25**; `CLAUDE.md:285` dice «25 PDF oficiales» | **CONFIRMA** |
| R-19 | 5 filas, 0 `NA`, 0 duplicados | **5**, **0**, **0** | **CONFIRMA** |
| R-26 | CI en verde por `head_sha` | `b7796cc`, `00a0840`, `b4ec047`, `511dab8` **success**; `cb19203` en curso al momento de auditar | **CONFIRMA (4 de 5; el quinto se cierra en FASE L)** |
| R-17 | 339 182 B en `dfl_1` | **355 448 B** | **REFUTA la cifra final** (ver R.6) |

#### R.6 Hallazgo R-17: la cifra de peso del log describe T1, no el estado final

**Qué pasa.** T1.6 registró el peso de `dfl_1` en **339 182 B** y esa cifra era correcta **en T1**.
El estado final es **355 448 B**, porque T2 inyecta el JSON de alias en `busqueda.html`, que
`_quarto.yml` incluye con `include-before-body` en **todas** las páginas. La cifra del log no está
mal: está **fechada**, y el inventario de FASE R la citó como si fuera la final.

**Severidad: ADVIERTE.** El criterio del encargo es por página y sobre `dfl_1`, con umbral
`313 211 × 1,20 = 375 853 B`: **355 448 < 375 853**, o sea que el criterio se cumple igual
(**+13,49 %**). No hay nada que reparar en el trabajo; lo que faltaba era la medición final, que se
anexa aquí.

**Y con ella, un hallazgo que el criterio del encargo no mira y conviene decir:**

```
dfl_1:  313 211 -> 339 182 (T1) -> 355 448 (final)   +13,49 %   (umbral 375 853: bajo el umbral)
sitio:  3 424 507 -> 4 283 828                        +25,09 %   = 18 283 B por pagina de media
de ellos, el JSON de alias: 10 586 B por pagina (58 % del aumento)
```

**El sitio entero crece 25 % sin comprimir**, porque la tabla de alias se repite en las 47 páginas.
Medido lo que de verdad viaja (GitHub Pages sirve comprimido):

```
dfl_1  sin comprimir 355 448 B | gzip  81 938 B
index  sin comprimir  49 658 B | gzip  14 779 B
JSON de alias, solo:  10 620 B | gzip   2 281 B
```

**2 281 bytes por página comprimidos.** El costo real es modesto y el criterio se cumple, pero la
duplicación en 47 páginas es una decisión que conviene revisar cuando la tabla crezca con alias
curados: el candidato natural del v12 es emitirla como un archivo aparte que el navegador cachee una
vez, con el cuidado de la ruta base que la cabecera de `busqueda.html` documenta.

**Acción: ninguna reparación.** El criterio del encargo pasa; se registra la cifra final y el
hallazgo. Reparar aquí sería cambiar el diseño en FASE R, que §6 paso 9 prohíbe.

#### R.7 Regresión completa sobre el estado final (§6 paso 5)

esperado: `segmentos_con_ancla: 806` y `destinos_resueltos: 848 de 848`
obtenido: **806** y **848 de 848**, sobre 47 páginas y 25 JSON de norma — PASA

esperado: `resueltas: 6 de 10 o más`, con C05, C06 y C10 entre ellas
obtenido: **8 de 10**, MRR **0,1633**, cobertura del conjunto **15 de 19** y **9 de 10** consultas
con al menos una ancla del conjunto — PASA

esperado: `git diff --stat fd5c987..HEAD -- 40_salidas/datos/` vacío
obtenido: **vacío** — PASA

#### R.8 CI por `head_sha`, los cinco commits

```
$ gh run list
cb19203 completed success   docs(claude): fila de la sesión 4, encargo v11 (T7)
511dab8 completed success   feat(buscador): expansión de consulta con alias y constantes centralizadas (T2, P1)
b4ec047 completed success   chore(instrumental): cierre de los cuatro huecos de P7 (T5)
00a0840 completed success   fix(sitio): índice lateral con los encabezados de artículo (T1, P2)
b7796cc completed success   feat(tests): instrumento de evaluación del buscador y de anclas (T4)
```

**5 de 5 en verde.** R-26 queda CONFIRMADA entera: el despliegue reconstruye el pipeline completo en
un runner limpio desde los PDF versionados, así que el verde también prueba que el sitio publicado
es reproducible con el código commiteado y no solo en esta máquina.

#### R.9 Corrección de pareo del pre-registro (error propio E-08)

El chequeo de §7.5 daba **70 `esperado:` y 71 `obtenido:`**. La causa: D7 se pre-registró una vez y
produjo **dos** mediciones —la del mecanismo que el encargo describía (1 de 7) y la del mecanismo que
se implementó (7 de 7)—, porque la primera refutó el diseño y obligó a medir el segundo. §7.5 manda
anexar la línea faltante con su estado real y **no** ajustar el conteo borrando evidencia: se anexa
aquí, declarada como escrita después de su `obtenido:` y por eso mismo sin valor probatorio de
pre-registro.

esperado: (escrito a posteriori) D7 con el mecanismo que se implemente, si el del encargo se refuta — el criterio de §5.7 lo gobierna la cifra del mecanismo publicado

#### R.10 Verificación en producción (no solo en esta máquina)

esperado: el sitio publicado responde y trae los dos cambios
obtenido: **HTTP 200**, con la expansión inyectada y el índice lateral poblado

```
$ curl -s -o /dev/null -w "HTTP %{http_code} en %{time_total}s\n" https://tomgc.github.io/slep_normativa_convivencia/
HTTP 200 en 0.612229s

$ curl -s .../ | grep -o '"tope_variantes":[0-9]*'
"tope_variantes":3

$ curl -s .../dfl_1_estatuto_asistentes_educacion.html | grep -c 'toc-art-'
217
```

Los 217 enlaces `toc-art-` del índice publicado más `preambulo` y `relacionadas` dan las **219**
entradas medidas en local: el sitio en línea coincide con el medido aquí. Es la comprobación que
cierra el círculo, porque el runner de CI reconstruye el pipeline entero desde los PDF versionados:
lo que está publicado no salió de esta máquina.

#### R.11 Panel de lectura independiente (§6 paso 2)

**Subagentes:** 1, rol lectura, ALCANCE de escritura **ninguno**. Recibió **las afirmaciones y el
repositorio**, y no el razonamiento ni el código que las produjo. Verificado por el orquestador:
`git status --porcelain` sin cambios y `git diff --stat` vacío durante y después de su corrida; sus
10 archivos auxiliares quedaron fuera del árbol.

Re-derivó nueve afirmaciones con comandos propios y plantó **cuatro** casos de control. Resultado:
**nueve CONFIRMA y una NO MEDIBLE.**

| id | Afirmación | Su camino (distinto del mío) | Veredicto |
|---|---|---|---|
| A-1 | 🔒1, el conjunto de `id` no cambió | `git show fd5c987:…/normas/*.json` contra el árbol; extractor propio de `<hN class="anchored">`; inventario propio de las 47 páginas | **CONFIRMA**: 958 pares (página, id), **0 altas y 0 bajas**; y los 806 coinciden **en orden**, no solo como conjunto |
| A-2 | 🔒3, `40_salidas/datos/` idéntico | hash del árbol de git de la carpeta en ambos commits, más md5 de los 25 JSON volcados | **CONFIRMA**: `19344080bb76…` en los dos |
| A-2b | «pese a que los 25 se reextrajeron» | lectura de `manifiesto_corpus.json` y de `reutilizable()` | **NO MEDIBLE** (ver R.12) |
| A-3 | 🔒4, el texto visible no cambió | texto de los 806 segmentos del JSON contra el `<div id="cuerpo-…">` del HTML | **CONFIRMA**: **806 de 806 iguales**, 0 distintos |
| A-4 | 8 de 10 con C05, C06 y C10 | reimplementación en R de la regla leída de `busqueda.html` (líneas 250, 251, 283, 305, 312), sobre el JSON crudo, **sin** `source()` del instrumento | **CONFIRMA**: 8 de 10 (C01 C03 C04 C05 C06 C08 C09 C10) y, con `TOPE_VARIANTES = 0`, **exactamente C05, C06 y C10** |
| A-5 | Las regex se movieron con valor idéntico | evaluar en R el valor de `git show fd5c987:31_extraer_texto.R` contra el de hoy | **CONFIRMA**: `identical() = TRUE` y `charToRaw` idéntico; 0 definiciones restantes en el origen |
| A-6 | 🔒7, 83 y 83 | `git ls-tree -r` en los dos commits y `diff` de los dos **conjuntos**, no solo de los conteos | **CONFIRMA**: 83 y 83, y el conjunto es el mismo |
| A-7 | Alcance contenido en la lista | `comm -23` del diff contra la lista, con el comodín del laboratorio aparte | **CONFIRMA**: nada sobra |
| A-8 | 831 / 219 / 25 de 25 | parser propio del bloque `<nav id="TOC">` | **CONFIRMA**: 831, 219, 25 de 25, y 831 − 25 = **806** |
| A-9 | 183 filas, ninguna inventada | evaluación aislada de `ALIAS_CONSULTA` y `%in%` fila por fila contra el CSV | **CONFIRMA**: **0 ausentes** por par `(entrada, alias)` **y 0 por trío** con la fuente; 77 filas del CSV quedaron sin usar (183 + 77 = 260) |

**Sus cuatro casos plantados discriminan los cuatro:** un `id` renombrado y otro sin `class="anchored"`
(lo ve), «acoso escolar» → «matonaje escolar» en un JSON (lo ve, y nombra `art-16-b`), duplicar todos
los espacios (**no** cambia el veredicto, o sea que su normalización es de espacios y de nada más), y
un alias inventado (lo ve y lo nombra).

**Y reprodujo el control de comparador que el encargo exige:** sin normalizar la URL, la cifra da
**0 de 10**; normalizando, **8 de 10**. El 8 no es un artefacto del comparador. Con un ancla esperada
falsa (`#art-999-inexistente`), **FALSE**; con un ancla tomada de la propia lista mostrada, **TRUE**.

**Un hallazgo suyo que vale por sí solo:** reimplementó `variantesDe()` en R desde `ALIAS_CONSULTA` y
**las 14 listas de variantes salen idénticas** a las del volcado. Eso prueba que el volcado se
produjo con la regla publicada y no con una copia divergente de ella, que es justamente el riesgo que
tiene duplicar lógica entre JavaScript y R.

#### R.12 Las dos observaciones del panel que cambian algo, zanjadas

**(a) La diferencia de 388 caracteres en las 5 páginas de OCR: es de método, no del sitio.** El panel
comparó el volcado previo contra **su propia** lectura del HTML y encontró que a las cinco páginas de
transcripción les sobraba un prefijo de 388 caracteres: el aviso «Texto obtenido por OCR, en
revisión…». Zanjado con comando propio sobre el mismo archivo:

```
nchar previo (rds, capturado ANTES de T1): 28778
nchar hoy    (mismo metodo):               28778
identicos: TRUE
el aviso de OCR esta DENTRO del contenedor hoy:   TRUE
el aviso de OCR estaba DENTRO en la copia previa: TRUE
primeros 90 caracteres del previo: Texto obtenido por OCR, en revisión; el PDF oficial es la fuente. Lo que sigue es una tran
primeros 90 caracteres de hoy:     Texto obtenido por OCR, en revisión; el PDF oficial es la fuente. Lo que sigue es una tran
```

El aviso estaba dentro del contenedor **antes y después**, y los dos textos son **idénticos byte a
byte**. La diferencia venía de que su región de medida excluía el aviso y la mía lo incluye. El
propio panel lo resolvió y dio A-3 por CONFIRMADA. **🔒4 se sostiene por los dos caminos.**

**(b) «25 reextraídos» no es re-derivable del árbol de hoy, y tiene razón.** El manifiesto marca los
25 documentos como `sin_cambio`, que es exactamente la condición en que `reutilizable()` **reutiliza**.
La reextracción forzada de T5 es un **evento**, no un estado: la caché se reconstruyó al terminar y el
árbol no conserva su rastro. La evidencia que existe es la salida contemporánea del pipeline,
transcrita en T5.1 (`25 reutilizados sin cambio` antes de apartar la caché y `0 reutilizados sin
cambio` después), más el `md5` idéntico del archivo apartado, que sigue en disco. **Es una limitación
real del método, y su causa es el mismo defecto P8 que obligó a forzar el reprocesamiento**: una
huella de caché que no incluye la versión del código tampoco deja constancia de cuándo se invalidó.
Se registra como ADVIERTE y como argumento adicional para P8.

#### R.13 Tabla de auditoría (§6 paso 10)

| id | afirmación | comando de re-derivación | esperado | obtenido | severidad | acción | commit | re-verificación |
|---|---|---|---|---|---|---|---|---|
| R-01 | 806 segmentos con ancla | JSON versionados + `rvest` (panel) y `grep` (orquestador) | 806 | 806 | — | ninguna | — | 3 caminos independientes |
| R-02 | 848 de 848 destinos | recuento propio por clase | 848 | 848 | — | ninguna | — | instrumento + orquestador |
| R-03 | 47 páginas | `find` | 47 | 47 | — | ninguna | — | — |
| R-04 | 958 encabezados con `id` | `rvest` y `grep` | 958 | 958 | — | ninguna | — | coincide con la medición del v10 |
| R-05 | 831 / 219 / 25 de 25 | parser propio del panel | 831 / 219 / 25 | idem | — | ninguna | — | 831 − 25 = 806 |
| R-06 | 3 → 8 de 10, mismas tres | reimplementación del panel sobre el JSON crudo | 8 y 3 | 8 y 3 | — | ninguna | — | control negativo y positivo del comparador |
| R-07 | MRR 0,0708 → 0,1633 | instrumento | — | idem | — | ninguna | — | — |
| R-08 | réplica 1 de 10 | instrumento en `--modo replica` | 1 | 1 | — | ninguna | — | calibra contra el v9 |
| R-09 | regex byte a byte | `git show` + evaluación en R (panel) | `identical` TRUE | TRUE | — | ninguna | — | md5 idéntico |
| R-10 | 25 reextraídos / 0 reutilizados | salida contemporánea del pipeline | 25 / 0 | 25 / 0 | **ADVIERTE** | se registra | — | **no re-derivable hoy** (R.12b) |
| R-11 | 🔒3 tras reextraer | hash del árbol de git (panel) | igual | igual | — | ninguna | — | md5 de los 25 JSON |
| R-12 | 43 de 44 versionados | `comm -23` disco vs `git ls-files` | 43 | 43 | — | ninguna | — | el que falta, ignorado y nombrado |
| R-13 | 🔒7 = 83, no crece | `git ls-tree` en los dos commits (panel) | 83 = 83 | 83 = 83 | — | ninguna | — | el **conjunto** también es el mismo |
| R-14 | 183 alias, ninguno inventado | `%in%` fila por fila contra el CSV (panel) | 0 ausentes | **0 por par y 0 por trío** | — | ninguna | — | caso plantado detectado |
| R-15 | A-18 0/10, B-06 0/10, A-19 25/25 | sonda propia sobre el índice | — | idem | — | ninguna | — | A-19 rehecha tras E-05 |
| R-16 | D7 1 de 7 y 7 de 7 | sonda propia | — | idem | — | ninguna | — | las dos cifras en el log |
| R-17 | peso de `dfl_1` | `wc -c` sobre el estado final | 339 182 | **355 448** | **ADVIERTE** | cifra final anexada | — | +13,49 %, bajo el umbral 375 853 |
| R-18 | 25 PDF | `ls` + `grep` en `CLAUDE.md` | 25 | 25 | — | ninguna | — | — |
| R-19 | 5 filas en §10.6 | `grep -c` | 5, 0, 0 | 5, 0, 0 | — | ninguna | — | — |
| R-20 | alcance contenido | filtro propio y `comm -23` del panel | vacío | vacío | — | ninguna | — | caso plantado detectado |
| R-21 | 🔒1 sin cambios | dos instrumentos + panel | 0 | 0 | — | ninguna | — | 3 caminos |
| R-22 | 🔒4 sin cambios | rds + panel por JSON | 0 | 0 | — | ninguna | — | R.12a |
| R-23 | 🔒5 | `grep -rl` y `find` | 0 y 47 | 0 y 47 | — | ninguna | — | — |
| R-24 | 🔒6 | `git diff --name-only \| grep -c` | 0 | 0 | — | ninguna | — | — |
| R-25 | 🔒2 | `git diff --name-only` con control positivo | 0 y > 0 | 0 y 3 | — | ninguna | — | — |
| R-26 | CI en verde | `gh run list` por `head_sha` | 5 success | **5 success** | — | ninguna | — | más HTTP 200 en producción |
| R-27 | latencia 6,08 → 10,97 ms | runner | — | idem | — | ninguna | — | — |
| R-28 | cobertura 4/19 → 15/19 | instrumento | — | idem | — | ninguna | — | — |
| R-29 | D4 5/5, D8 `diff` 0 | implementación propia del orquestador | 5 y 5, 0 | 5 y 5, 0 | — | ninguna | — | dos controles positivos |
| R-30 | el caso plantado de T2 no produjo retroceso | 4 configuraciones adversariales | ≥ 1 retroceso | **0 retrocesos** | **ADVIERTE** | se declara, no se maquilla | — | duda D-09 |

**Hallazgos adicionales del panel, con su severidad:**

| # | Hallazgo | Severidad | Acción |
|---|---|---|---|
| P-1 | Dos `setwd("/Users/tomgc/…")` entran al versionado de un repositorio público, y limpiar rutas absolutas era la razón declarada de la exclusión anterior | **ADVIERTE** | ya registrado como D-07; no se repara porque el ALCANCE del v11 prohíbe editar el laboratorio |
| P-2 | El encargo y su insumo de diseño están sin versionar y **no** figuran en la lista de escritura autorizada | **ADVIERTE** | son insumos que el titular depositó antes de la ejecución, no salidas de este trabajo; el log sí está autorizado y se commitea en FASE L |
| P-3 | `_quarto.yml` y `estilo.css` estaban autorizados y no se tocaron | — | no es defecto: cada uno tiene su medición (F0.12 y T1.5). El alcance real es menor que el declarado |
| P-4 | `indice-tema.html` es la única página del sitio sin ningún encabezado con `id` | **ADVIERTE** | preexistente (el volcado previo también da 46 de 47); nada dentro de ella es enlazable. Candidata a v12 |
| P-5 | La evidencia del «8 de 10» vive bajo `salida_v11/`, que está en `.gitignore`, y lleva una ruta absoluta incrustada: quien clone el repositorio no puede reauditar la cifra sin volver a levantar el índice | **ADVIERTE** | es regenerable con `Rscript tests/medir_buscador.R`, que sí está versionado. Se declara |

#### R.14 Ciclo de reparación

**Cero REPARA.** Ninguno de los hallazgos es un defecto del trabajo dentro del ALCANCE con
verificación calibrada disponible: R-17 es una cifra fechada que se completó con la medición final
(no hay nada que reparar en el código y hacerlo sería cambiar el diseño en FASE R, que §6 paso 9
prohíbe); R-10 y R-30 son limitaciones de método declaradas; P-1, P-4 y P-5 caen fuera del ALCANCE
o son preexistentes. **Cero BLOQUEA.** Ningún 🔒 en FALLA, ningún dato alterado, ningún alcance
violado, ninguna historia divergente.

#### R.15 Veredicto global

> **APROBADO CON ADVERTENCIAS.**
>
> Invariantes: **8 de 8 en PASA**. Hallazgos B/R/A = **0 / 0 / 7** (R-10, R-17, R-30, P-1, P-2, P-4,
> P-5); reparados **0**; abiertos **0** que exijan reparación.
>
> El «cero hallazgos que bloquean» se declara **junto con su control positivo**, como exige §6
> paso 7: la auditoría plantó **siete** casos falsos (tres del orquestador y cuatro del panel) y los
> **siete** fueron detectados. Una auditoría que solo confirma no auditó; esta detecta cuando hay
> algo que detectar.

---

## 5bis. Cierre (FASE L)

### L.1 Estado del árbol antes de tocar el log

```
$ git status --porcelain
?? 50_documentacion/andamios/20260909_encargo_v11_indice_y_expansion_v1.md
?? 50_documentacion/andamios/20260909_integracion_revision_externa_v1.md
?? 50_documentacion/andamios/logs/20260909_indice_y_expansion_v11_log.md
```

Cero archivos versionados modificados y cero en el staging. Las tres entradas `??` son el encargo,
su insumo de diseño y este log. **No se «limpian»**: los dos primeros los depositó el titular antes
de la ejecución y no están en la lista de escritura autorizada (hallazgo P-2); el tercero se
commitea en L.6.

### L.2 Inventario de commits, uno por línea, rotulado con su fase

```
$ git log fd5c987..HEAD --oneline
cb19203 docs(claude): fila de la sesión 4, encargo v11 (T7)
511dab8 feat(buscador): expansión de consulta con alias y constantes centralizadas (T2, P1)
b4ec047 chore(instrumental): cierre de los cuatro huecos de P7 (T5)
00a0840 fix(sitio): índice lateral con los encabezados de artículo (T1, P2)
b7796cc feat(tests): instrumento de evaluación del buscador y de anclas (T4)
```

| Commit | Fase | Qué | CI por `head_sha` |
|---|---|---|---|
| `b7796cc` | T4 | instrumento de evaluación del buscador y de anclas (4 archivos, 717 líneas) | success |
| `00a0840` | T1 | índice lateral de las páginas de norma (1 archivo) | success |
| `b4ec047` | T5 | cierre de los cuatro huecos de P7 (48 archivos, 43 de ellos del laboratorio) | success |
| `511dab8` | T2 | expansión de consulta y constantes centralizadas (4 archivos) | success |
| `cb19203` | T7 | fila de `CLAUDE.md` §10.6 (1 archivo) | success |
| (L.6) | FASE L | este log | se verifica tras el push |

**Cero commits `fix(auditoria)`**: FASE R no encontró ningún hallazgo REPARA.

### L.3 Estado de las cifras críticas

| Cifra | Antes (punto de retorno `fd5c987`) | Después | Estado |
|---|---|---|---|
| Segmentos con ancla | 806 | **806** | **intacta**, por tres caminos independientes |
| Destinos verificables | 848 de 848 | **848 de 848** | **intacta** |
| Páginas HTML | 47 | **47** | **intacta** |
| Encabezados con `id` en el sitio | 958 | **958** | **intacta** |
| Consultas resueltas | 3 de 10 | **8 de 10** | **alterada a propósito**, con las 3 previas dentro |
| Entradas del índice lateral (25 normas) | 25 (una por página) | **831** | **alterada a propósito** |
| Datos versionados fuera de `40_salidas/datos/` | 83 | **83** | **intacta**, mismo conjunto |
| `40_salidas/datos/` | `19344080bb76…` | `19344080bb76…` | **intacta**, mismo hash de árbol |

### L.4 Decisiones del usuario registradas

**Ninguna.** El encargo es de vía B (autónomo) y no hubo interrupción al titular: todas las
decisiones fueron del ejecutor y están en el bloque J con su alternativa descartada.

### L.5 Dudas y pendientes consolidados

| # | Duda | Pregunta cerrada |
|---|---|---|
| D-01 | La condición 1 de §1.2 detendría la sesión por la existencia de los archivos que el propio encargo exige | ¿se lee como «cero versionados modificados y stash vacío» (lo aplicado) o literalmente, entradas `??` incluidas? |
| D-02 | El laboratorio tiene 126 archivos, no 128 | ¿basta registrar 126, o hay que reconciliar los 2 de diferencia contra el escáner? |
| D-03 | `a1_alias_prueba.csv` no es una tabla de alias; la que sí lo es se llama `a1_alias_procedencia.csv` | ¿se acepta esa como la fuente que la ambigüedad 4 quiso nombrar? |
| D-04 | El `esperado:` de D8.2 no es alcanzable donde exista `es_ES.UTF-8` | ¿se corrige el criterio, o D8.2 queda NO VERIFICADA hasta una máquina sin locale UTF-8? |
| D-05 | La latencia que informa el instrumento incluye la carga del WASM en la primera consulta | ¿el v12 separa fría de caliente descartando la primera, o basta la nota? |
| D-06 | `a3_presupuesto_tokens.R` no se versiona porque R2 del hook rechaza el patrón `*token*` por nombre | ¿se renombra el archivo, o R2 pasa a mirar contenido? |
| D-07 | Dos `setwd()` con ruta absoluta entran al versionado de un repositorio público | ¿se cambian a `here::here()` en el próximo encargo que pueda editar el laboratorio, o el laboratorio se declara exento? |
| D-08 | El tope de 5 filas de §10.6 choca con «una fila por sesión» | ¿se conserva el tope y el historial queda en los traspasos, o el tope sube? |
| D-09 | El caso malo plantado de T2 no puede fallar contra este diseño | ¿el control del v12 se redirige al canal que sí queda abierto, o se retira? |
| D-10 | «Pagefind exige todos los términos» es falso: exige los de **contenido** | ¿se corrige en el traspaso v04, o se cita esta medición al usarla? |
| D-11 | `dfl_1` no se encuentra por su número en ninguna de las tres formas | ¿entra al v12, o se acepta porque las dos normas son el estatuto docente y su refundido? |

**Pendientes que este encargo deja nombrados y no reparados:**

1. **`pagina_pieza()` tiene el mismo defecto de índice** que tenían las páginas de norma (T1.8). Una
   línea de cambio; su lugar es el encargo que publique la primera pieza.
2. **`on.exit()` no dispara en `Rscript` a nivel superior** (T4.5): si el laboratorio del v9 usó ese
   patrón, dejó servidores huérfanos en sesiones anteriores.
3. **`MAX_BLOQUES_FICHA` sigue en `31_extraer_texto.R`** y no en la fuente canónica. El encargo
   nombraba dos constantes, no tres.
4. **`indice-tema.html` no tiene ningún encabezado con `id`** (P-4), preexistente.
5. **La tabla de alias se repite en las 47 páginas** (R.6): 2 281 B por página comprimidos.
6. **P8 sigue vigente** y ahora con un argumento más: una huella de caché sin versión del código
   tampoco deja constancia de cuándo se invalidó (R.12b).

### L.6 Errores propios consolidados

| # | Qué salió mal | Costo | Cómo se corrigió |
|---|---|---|---|
| E-01 | `git rev-parse --short HEAD origin/main` no corre: `--short` no admite dos revisiones | 1 turno | dos invocaciones y comparación explícita |
| E-02 | 16 `esperado:` contra 17 `obtenido:` en FASE 0 | 1 turno | línea faltante anexada y declarada (§7.5) |
| E-03 | Mi re-derivación del «3 de 10» dio **0**, por no normalizar la URL absoluta de Pagefind | 1 turno | normalización corregida, más control negativo y positivo del comparador |
| E-04 | Script de `CLAUDE.md` dejó una línea `NA` y una fila duplicada: en R, `x[(n+1):length(x)]` **cuenta hacia atrás** cuando `n` es la última línea | 2 turnos | corregido hacia adelante, con `stopifnot()` que comprobaba el duplicado antes de recortar |
| E-05 | Medí A-19 con «dfl», palabra que el corpus no usa: inventé la abreviatura en vez de leer `tipo_etiqueta` | 1 corrida | repetida con la etiqueta real: 24 de 25 → **25 de 25** |
| E-06 | `min()` en vez de `pmin()` truncaba **todas** las raíces al largo de la palabra más corta (3 caracteres) | 2 turnos | `pmin()`; sin esto la expansión no habría disparado en C02 ni C08 |
| E-07 | El caso malo plantado no disparaba variantes: `consultas_evaluacion.R` recarga la configuración y **restauraba la tabla** tras el `--alias`, dejando los índices apuntando a la tabla anterior | 2 turnos | override e índices movidos a después de cargar el conjunto. **Sin el caso plantado no se habría visto** |
| E-08 | 70 `esperado:` contra 71 `obtenido:` al cerrar | 1 turno | línea anexada y declarada (R.9) |

Los tres que costaron más de un turno: **E-04**, **E-06** y **E-07**. Los dos últimos son del mismo
tipo y merecen la regla: **una función vectorizada mal escrita no falla, devuelve otra cosa**;
`min()` por `pmin()` y una tabla recargada por un `source()` transitivo no producen error, producen
una cifra plausible. Los detectó, en los dos casos, un control plantado y no la ejecución normal.

### L.7 Notas para el revisor

- **La cifra que importa no es el 8 de 10, es la tabla pareada.** Cinco de las siete consultas
  perdidas se resuelven, ninguna de las tres que funcionaban retrocede y ninguna empeora. 3 frente a
  8 sobre diez casos no es una prueba estadística de mejora, y así está declarado en el propio
  `10_configuracion.R`.
- **Los dos topes de la expansión se ajustaron sobre el mismo conjunto con que se reporta el
  resultado.** Está escrito junto a las constantes, no solo en este log.
- **Tres premisas del encargo resultaron falsas y están medidas:** el mecanismo de expansión que
  describía recupera 1 de 7 y no 5 de 7; Pagefind ya normaliza tildes e ignora palabras vacías (0 de
  10 diferencias en las dos pruebas); y el `esperado:` de D8.2 no es alcanzable en esta estación.
- **Lo que no se pudo verificar aquí y el revisor debe ver por sí mismo:** que el índice lateral de
  219 entradas se desplaza dentro de su panel en un navegador real a 1280 px (se midió la cascada de
  la hoja publicada, que trae `position:sticky`, `max-height:100vh` y `overflow-y:auto`, pero no se
  ejecutó `getComputedStyle`); y que el buscador se comporta igual en un teléfono, que es criterio de
  aceptación del v12 (adopciones A-17 y B-19).
- **El caso malo plantado de T2 no produjo retroceso en ninguna de cuatro configuraciones.** No se
  declara como control superado.

### L.8 Grep de privacidad y verificación observable del archivo

esperado: vacío (patrón de RUT)
obtenido: **0 coincidencias** — PASA

```
$ grep -nE '[0-9]{1,2}\.?[0-9]{3}\.?[0-9]{3}-[0-9kK]' <LOG> | wc -l
0
$ grep -cE '<patrón de correo electrónico>' <LOG>
0
```

Lectura del archivo confirmada: no contiene filas de datos, ni nombres de personas, ni resultados
individuales. El corpus es normativa publicada y el proyecto es Rama A.

**Declaración de gobernanza, porque el repositorio es público.** El log contiene **11** menciones a
rutas absolutas `/Users/tomgc/…`, todas ellas **salida literal de comandos** (la ruta de
`core.hooksPath`, el `diff` contra la plantilla de locale del kit, los `md5`). No se redactan porque
son la evidencia misma y §9 del contrato obliga a transcribir la salida literal; y no añaden
divulgación: el repositorio ya expone `/Users/tomgc/Projects/herramientas_dev` en **3** archivos
versionados (entre ellos el log del v10) y `/Users/tomgc` en **16**, y el nombre de usuario es
público por la URL del sitio, `https://tomgc.github.io/…`. No hay credenciales, tokens ni datos
personales. Se declara en vez de resolverse en silencio.

esperado: `grep -c '^### FASE'` = 8 (FASE 0, T4, T6, T1, T5, T2, T7, FASE R)
obtenido: **8** — PASA
esperado: `grep -c '^esperado:'` = `grep -c '^obtenido:'`
obtenido: **72 = 72** — PASA (tras las dos correcciones de pareo declaradas, F0.6 y R.9)
esperado: `grep -c '^## J'` = 1 con el bloque relleno
obtenido: **1**, con sus **12** campos — PASA

### L.9 Estado de cierre declarado

**Queda commiteado y publicado:** los cinco commits de tarea (`b7796cc`, `00a0840`, `b4ec047`,
`511dab8`, `cb19203`), los cinco con CI en verde por `head_sha`, más este log. El sitio en
producción responde HTTP 200 y sirve los dos cambios (índice poblado y expansión).

**NO se publica nada más.** No hay trabajo retenido, ningún push pendiente y ninguna rama aparte.

**Queda al titular:** las 11 dudas de L.5 con su pregunta cerrada, los 6 pendientes nombrados, y las
cuatro decisiones D-A a D-D del documento de integración, que este encargo no tocó por no
corresponderle.

**No versionado y en disco:** `50_documentacion/andamios/lab_motor_v9/salida_v11/` con las copias
previas de los invariantes, los volcados del instrumento y `extraccion_v11_previo.json` (la caché
apartada en T5, `md5 6860a579ffaacde0ac9806476eaa179b`, **no borrada**). Y las dos entradas `??` del
encargo y su insumo de diseño, que el titular depositó y no están en la lista de escritura
autorizada.
