# Encargo v12: Capa de precedencia determinística del buscador

> **Destino:** `50_documentacion/andamios/20260910_encargo_v12_precedencia_v1.md`
> **Tipo:** vía B (autónomo; nada de lo que produce exige firma humana: la única decisión humana del encargo ya está firmada).
> **Patrón:** `encargo_autonomo_claude_code_v1.md` v1.5, con el tope de subagentes bajado a 2 por regla del proyecto (`traspaso_cierre_v04.md` §8, decisión 6).
> **Emitido:** 2026-09-10, sesión 5.
> **Insumo normativo de diseño:** `50_documentacion/activa/decisiones/20260910_decision_precedencia_buscador.md` (en adelante, «la decisión»). Manda sobre este encargo: si ambos divergen, se congela la tarea y se registra.
> **Insumos de hallazgos:** `50_documentacion/andamios/20260909_integracion_revision_externa_v1.md`, `20260909_revision_externa_motor_rolA_v1.md`, `20260909_revision_externa_motor_rolB_v1.md`.
> **Log:** `50_documentacion/andamios/logs/20260910_precedencia_buscador_v12_log.md`

---

## 0. Por qué existe este encargo

El buscador encuentra el ancla correcta, pero no la pone primera: con el criterio del titular (ancla esperada en posición 1) resuelve 0 de las 10 consultas históricas (hipótesis, se mide en T1; fuente del valor: `traspaso_cierre_v04.md` §3). El piso R0 del v11 pone primero toda página que coincide literalmente con la consulta, y así «bullying» entrega antes una ley que contiene la palabra que la norma del tema (fuente: `busqueda.html`, función `buscarConExpansion()`, leído en la sesión que emite este encargo). La decisión fija cuatro reglas en orden, dos tablas de norma principal, una tabla de niveles y tres respuestas esperadas nuevas. Este encargo las implementa, extiende el instrumento para que la mejora sea demostrable por posición y no por presencia, y lleva al código todas las adopciones de las revisiones externas que tocan el motor léxico y no exigen decisión humana.

---

## 1. Contrato

### 1.1 Modo, subagentes y plan de concurrencia

- **Modo autónomo, todo en este turno.**
- **Subagentes admitidos, tope duro de 2 simultáneos**, de cualquier rol; la sesión principal que orquesta no cuenta. Tope de simultaneidad, no de total.
- **Sin olas paralelas de escritura.** Toda tarea de escritura de este encargo toca `10_utils/10_configuracion.R`, `30_procesamiento/34_plantillas_sitio/busqueda.html` o regenera el sitio que otra tarea mide; en paralelo se pisarían. Las tareas corren en serie en el orden del grafo de §5.1, cada una a cargo del orquestador o de un subagente de escritura, de a uno.
- **Subagentes de lectura:** 1 en T1 (re-derivación independiente de las respuestas esperadas de los estratos nuevos), lanzado después de que el subagente de escritura de T1 haya devuelto; hasta 2 en FASE R (panel). Nunca más de 2 vivos.
- FASE R y FASE L, fuera del grafo, siempre, en ese orden.

### 1.2 Regla de detención (lista medible)

Congela la tarea afectada y sus descendientes, regístrala como duda (log, §4.1) y sigue con la siguiente tarea independiente si:

1. Al iniciar FASE 0, `git status --porcelain` contiene alguna línea que empiece con ` M`, `M `, ` D` o `D `, o alguna línea `??` distinta de las dos rutas de insumo que T0 commitea (la decisión y este encargo), o `git stash list` no está vacío. Aquí se detiene la SESIÓN entera.
2. `git rev-parse HEAD` difiere de `git rev-parse origin/main` tras `git fetch --quiet`. Sesión entera.
3. `grep -E '^sesion_abierta:' 50_documentacion/activa/ESTADO.md` no devuelve `sesion_abierta: true`. Sesión entera.
4. `git remote get-url origin` no devuelve `https://github.com/tomgc/slep_normativa_convivencia.git`. Sesión entera.
5. El inventario de anclas no da **806** segmentos con ancla o **848 de 848** destinos resueltos en FASE 0: T2 a T5 se congelan, salvo que el log demuestre con comando que la diferencia es anterior a este encargo. Del mismo modo, si la medición del buscador de FASE 0 con el instrumento vigente no da **8 de 10** históricas presentes, T1 a T5 se congelan hasta que el log registre la cifra real y su causa.
6. Tras cualquier regeneración del sitio, el conjunto de `id` por página difiere de la copia previa de FASE 0 (🔒1): `git revert` del commit de la tarea y congelamiento.
7. Tras T3, T4 o T5, alguna consulta de cualquier estrato empeora su posición respecto de la línea base que T1 midió con las esperadas de la decisión (🔒8): `git revert` del commit de la tarea que lo causó y congelamiento.
8. Una tarea necesita escribir fuera de su ALCANCE: se congela; la ruta y su `git diff --stat -- <ruta>` van al log; nada se commitea.
9. Un cambio necesitaría escribir en `20_insumos/` (🔒2): se congela sin excepción.
10. Un cambio necesitaría editar la decisión o este encargo (🔒9): se congela; la divergencia se registra con pregunta cerrada.
11. Un bug no converge al tercer intento (tope 1.4).
12. El despliegue de GitHub Pages queda en rojo tras un push y el reintento también: `git revert` del commit que lo causó, push de la reversión, congelamiento.
13. **Cláusula residual:** cualquier estado, conteo o resultado no enumerado en este encargo → congela ESTA tarea, regístrala como duda (§4.1 del log) y sigue con la próxima tarea independiente.

### 1.3 Autorizaciones (lista cerrada)

**Lectura:** cualquier archivo del repositorio, y el directorio de hooks que devuelve `git config core.hooksPath` (para leer el hook antes de commitear).

**Escritura y creación, por tarea (es también el ALCANCE de §1.7):**

| Ruta | Tarea |
|---|---|
| `50_documentacion/activa/decisiones/20260910_decision_precedencia_buscador.md` (solo `git add`; no se edita) | T0 |
| `50_documentacion/andamios/20260910_encargo_v12_precedencia_v1.md` (solo `git add`; no se edita) | T0 |
| `10_utils/10_configuracion.R` | T6, T2, T4 |
| `30_procesamiento/31_extraer_texto.R` | T6 |
| `tests/consultas_evaluacion.R` | T1 |
| `tests/medir_buscador.R` | T1, T3, T4, T5 |
| `tests/consulta_pagefind.mjs` | T1 |
| `tests/evaluar_precedencia.mjs` (nuevo) | T3, T5 |
| `30_procesamiento/34_generar_paginas.R` | T2, T3, T4 |
| `_quarto.yml` (solo la clave `resources:` del proyecto, si el archivo de datos del buscador la necesita para llegar al sitio) | T2 |
| `30_procesamiento/36_indexar_pagefind.R` (solo si el archivo de datos del buscador se escribe después del render, como alternativa a `_quarto.yml`) | T2 |
| `30_procesamiento/34_plantillas_sitio/busqueda.html` | T3, T4, T5 |
| `30_procesamiento/33_relaciones.R` | T4 |
| `CLAUDE.md` (solo §10.6: una fila nueva y el retiro de la más antigua) | T7 |
| `50_documentacion/andamios/logs/20260910_precedencia_buscador_v12_log.md` | FASE 0 a FASE L |
| `50_documentacion/andamios/lab_motor_v9/salida_v11/v12/` (nuevo; escritura de trabajo no versionada: salidas del instrumento, copias previas, caché apartada) | todas |

**Acciones:**

- Regenerar el sitio por pipeline (`bash -c 'Rscript -e "source(\"00_run_all.R\"); run_all()"'` desde la raíz), en cualquier tarea. `40_salidas/` nunca a mano. `40_salidas/datos/relaciones.json` cambia solo por pipeline y solo en T4 (🔒3).
- Servir el sitio en modo lectura para medir (el servidor local que levanta `tests/medir_buscador.R`), en cualquier tarea.
- Mover (`mv`, nunca `rm`) `40_salidas/intermedios/extraccion.json` a `50_documentacion/andamios/lab_motor_v9/salida_v11/v12/extraccion_v12_previo.json`, **solo en T6 y solo después de** registrar en el log `md5sum 40_salidas/intermedios/extraccion.json`. Existe para forzar el reprocesamiento que la huella del paso 30 no dispara (fuente: `traspaso_cierre_v04.md` §11.1 P8). No se borra nunca.
- `git add <rutas explícitas del ALCANCE>`, `git commit`, `git push origin main`: un commit por tarea terminada, más los `fix(auditoria)` de FASE R y el `docs(log)` de FASE L. Push después de cada commit de tarea. Verificación del workflow de publicación por `head_sha` tras cada push, obligatoria.
- `git revert <hash propio>` bajo las condiciones 6, 7 y 12 de §1.2.

**Nada más.** Ningún subagente hereda autorizaciones.

### 1.4 Topes de esfuerzo

1. **3 intentos por bug.** Al tercer fix fallido la tarea se congela con la evidencia de los tres intentos.
2. **2 ciclos de reparación en FASE R.** Lo que sobrevive al segundo va al log como pendiente.
3. **1 reintento por comando** que falla por causa transitoria (red, lock, timeout, workflow en cola). Al segundo fallo es hallazgo.

### 1.5 Reglas canónicas heredadas (se referencian, no se copian)

- `CLAUDE.md` §4 (gobernanza), §7 (reglas técnicas: R único lenguaje de análisis, `here::here()`, `.by=`, sin `$` sobre estructuras leídas de disco) y §10.5 (fidelidad normativa; `.qmd` no se editan a mano; ids y anclas desde `slugificar()`).
- `POLITICA_PROYECTO.md` §5.3 punto 10 y §5.4: toda decisión metodológica como constante nombrada en `10_utils/10_configuracion.R`.
- La decisión es normativa para T2 a T5: se implementa como está escrita; no se reinterpreta, no se completa y no se «mejora».
- Reparación quirúrgica desde el primer minuto: se corrige lo que la tarea nombra y nada más.
- Un `source()` transitivo de `10_utils/10_configuracion.R` pisa cualquier constante sustituida antes en la misma sesión R (fuente: `traspaso_cierre_v04.md` §6, bug 3). Todo control plantado sobre una constante se hace por argumento o archivo alternativo, nunca sustituyendo la constante antes de un `source()`.
- JavaScript solo en `busqueda.html` (código del sitio) y en los dos auxiliares de `tests/` declarados en §2; toda cifra la produce R.
- Python: prohibido; ni un sondeo de disponibilidad. Reproducir literalmente en el prompt de cada subagente.

### 1.6 Prohibiciones

- Escribir en `20_insumos/` (🔒2), editar a mano cualquier archivo bajo `40_salidas/`, y correr `00_ocr_documentos.R` con cualquier bandera.
- Publicar, validar o tocar el estado de ninguna pieza interpretativa (🔒5).
- `git push --force`, `--no-verify`, `git add -A`, `git add .`, reescribir historia publicada.
- Escribir en `busqueda.html` o en cualquier JavaScript un slug, un ancla o un número de norma: todo llega por el archivo de datos que exporta el pipeline (A-13).
- Cambiar una respuesta esperada del conjunto de evaluación distinta de las tres que fija la decisión (§8), o cualquier valor esperado de este encargo después de ver una medición.
- Inventar un alias, una fila de precedencia, un ancla o una cifra: lo que no está en la decisión o en los datos queda fuera.
- Instalar paquetes de npm o modificar `package.json` y `package-lock.json`.
- Acceso `$` sobre estructuras leídas de disco; `[[ ]]` siempre.

### 1.7 Contrato de entorno

1. **ENTORNO:** Claude Code abierto en la raíz del repositorio `slep_normativa_convivencia`, en la estación del titular (macOS), rama `main`, remoto `origin` en GitHub, con despliegue a GitHub Pages por el workflow `.github/workflows/publicar.yml`. La identidad se verifica en FASE 0 (§1.2, condiciones 3 y 4); ninguna ruta de este encargo depende de la carpeta personal del titular.
2. **INSUMOS** (todos por ruta desde la raíz del repositorio; ninguno se pasa aparte):
   - La decisión y este encargo: `50_documentacion/activa/decisiones/20260910_decision_precedencia_buscador.md` y `50_documentacion/andamios/20260910_encargo_v12_precedencia_v1.md` (hipótesis: presentes y sin versionar al iniciar; se mide en FASE 0).
   - `50_documentacion/traspasos/traspaso_cierre_v04.md` (fuente: `ls 50_documentacion/traspasos/` en la sesión que emite).
   - `50_documentacion/andamios/20260909_integracion_revision_externa_v1.md`, `50_documentacion/andamios/20260909_revision_externa_motor_rolA_v1.md`, `50_documentacion/andamios/20260909_revision_externa_motor_rolB_v1.md` (fuente: `ls 50_documentacion/andamios/` en la sesión que emite).
   - `tests/consultas_evaluacion.R`, `tests/medir_buscador.R`, `tests/consulta_pagefind.mjs`, `tests/inventario_anclas.R` (fuente: `wc -l tests/*` en la sesión que emite).
   - `40_salidas/datos/catalogo.json`, `40_salidas/datos/normas/*.json`, `40_salidas/datos/relaciones.json` (fuente: `ls 40_salidas/datos` en la sesión que emite).
   - `50_documentacion/activa/50_datos_versionados_autorizados.md` (fuente: lectura en la sesión que emite).
3. **POSICIÓN:** toda ruta completa desde la raíz del repositorio; ningún comando asume `cd` previo; los scripts corren bajo `bash` explícito (`bash -c '...'`), nunca el shell interactivo del titular; R por `Rscript` con `here::here()`; JavaScript por `node` solo para los dos auxiliares de `tests/`. Primera fase: `git fetch --quiet` y comparación de `HEAD` contra `origin/main`.
4. **LOG:** `50_documentacion/andamios/logs/20260910_precedencia_buscador_v12_log.md`.
5. **ALCANCE:** la tabla de §1.3, por tarea, más `50_documentacion/andamios/lab_motor_v9/salida_v11/v12/` como escritura de trabajo no versionada. Chequeo programático al cierre de cada fase y global en FASE R.
6. **PRUEBAS** (sin arnés `testthat`). Tres comandos, los tres con salida esperada:
   - **Anclas:** `Rscript tests/inventario_anclas.R` → `segmentos_con_ancla: 806` y `destinos_resueltos: 848 de 848`, más el volcado de `id` por página que compara 🔒1.
   - **Buscador:** `Rscript tests/medir_buscador.R --sitio 40_salidas/sitio --salida 50_documentacion/andamios/lab_motor_v9/salida_v11/v12` → desde T1, el reporte por estrato de §5.5 con la posición del ancla esperada como cifra principal.
   - **Datos versionados:** `git diff --stat <PUNTO DE RETORNO>..HEAD -- 40_salidas/datos/` → vacío en toda tarea salvo T4, donde cambia solo `relaciones.json` y solo por la clave nueva (🔒3).
7. **PUNTO DE RETORNO:** FASE 0 registra `git rev-parse --short HEAD` en el encabezado del log después de medir la condición 1 de §1.2. Toda reversión es `git revert` de un commit propio; `reset`, `restore` y `checkout --` no están autorizados.

---

## 2. Ambigüedades resueltas antes de redactar

1. **De dónde sale la cifra principal.** Alternativas: (a) reimplementar las reglas en R dentro de `tests/medir_buscador.R`, como hace hoy con el orden y la expansión; (b) extraer del `busqueda.html` publicado el bloque de precedencia y ejecutarlo con `node` sobre el JSON crudo del runner, y que R calcule posiciones, MRR y todo lo demás sobre la lista que ese bloque devuelve. **Decisión: (b) para la cifra principal, y (a) solo como re-derivación independiente en FASE R.** La (b) mide el código que se publica, sin una segunda implementación que diverja (A-13); la (a) conserva su valor como auditor que no comparte código con el productor (patrón v1.5, §3.2). El auxiliar `tests/evaluar_precedencia.mjs` no calcula cifras: recibe resultados crudos y datos, devuelve la lista ordenada con la regla que ubicó cada página.
2. **Cómo llegan las tablas y los metadatos al sitio.** Alternativas: (a) inyectarlos en cada página, como hoy la tabla de alias (47 copias; fuente: `traspaso_cierre_v04.md` §11.1 P5); (b) un único archivo JSON de datos del buscador junto al sitio, que `busqueda.html` carga en la primera búsqueda. **Decisión: (b).** Las anclas por norma no caben con sentido en 47 copias, y la (b) cierra el pendiente P5 de la tabla repetida. El archivo vive bajo `40_salidas/sitio/`, que no se versiona (fuente: `git check-ignore -v 40_salidas/sitio/index.html` → `.gitignore:57`, en la sesión que emite), así que el hook de datos no aplica. Si falla su carga, rige la tabla de degradación de T5.
3. **Cómo se muestra una norma principal que Pagefind no devolvió.** Alternativas: (a) agregar a cada página un filtro oculto por slug y consultarlo; (b) componer el resultado con los datos exportados (título de la norma, etiqueta y ancla del artículo de respaldo). **Decisión: (b).** No cambia el HTML de ninguna página de norma (🔒4) y usa datos que el pipeline ya valida.
4. **Estratos derivados frente a «lenguaje del equipo» (A-15).** Las consultas que este encargo agrega se derivan del catálogo y de las tablas de la decisión; no son consultas del equipo. **Decisión:** se reportan por estrato, separadas de las 10 históricas, y ninguna cifra mezcla estratos. Las 10 históricas siguen siendo la única cifra comparable con el v11.
5. **Navegador para A-09 y A-17.** Medir la degradación bloqueando archivos y la latencia fría y caliente exige un navegador. **Decisión:** FASE 0 mide si hay uno utilizable sin instalar nada (hipótesis, se mide); si lo hay, T5 lo usa; si no, T5 verifica los caminos de degradación con `node` simulando la falla y registra como duda la medición en navegador para el titular. No se instala nada (§1.6).
6. **Dónde se deriva la lista de normas citadas y no incluidas (B-03, B-04).** Alternativas: (a) en `34_generar_paginas.R`, con expresiones propias; (b) en `33_relaciones.R`, que ya reconoce citas de normas en el texto, como una clave nueva de `relaciones.json`. **Decisión: (b).** Reconocer una cita es responsabilidad del derivador de relaciones, y duplicar sus expresiones en otro script sería la duplicación que A-13 objeta. `relaciones.json` es dato autorizado (`50_datos_versionados_autorizados.md`); el cambio se acota a una clave nueva y todas las demás quedan idénticas (🔒3).

---

## 3. Estado de partida (premisas marcadas)

- Sitio: 47 páginas HTML, 25 normas, 806 segmentos con ancla, 848 destinos (fuente: `traspaso_cierre_v04.md` §3; se recuentan en FASE 0).
- Buscador: 8 de 10 históricas con el ancla esperada presente y 0 de 10 en posición 1; las ocho presentes en posiciones 6, 26, 13, 12, 2, 7, 2 y 8; C02 y C07 ausentes (hipótesis, se mide en T1; valores de `traspaso_cierre_v04.md` §3).
- `busqueda.html` activa una entrada de alias cuando la consulta comparte con ella al menos una raíz distintiva de 6 caracteres, y la unión pone primero las páginas de la consulta original (fuente: funciones `variantesDe()` y `buscarConExpansion()`, leídas en la sesión que emite).
- `tests/medir_buscador.R` reimplementa en R el orden y la expansión, y el comentario de cabecera de `busqueda.html` dice que el instrumento extrae el bloque de orden del archivo (fuente: ambos archivos, leídos en la sesión que emite). La discrepancia se corrige en T3.
- `tests/consultas_evaluacion.R` define 10 históricas y 4 de clase `sin_respuesta` (fuente: lectura en la sesión que emite; `stopifnot` del propio archivo).
- `ALIAS_CONSULTA` tiene 183 filas con columnas `entrada`, `alias`, `clave_fuente`, `fuente` (fuente: `10_utils/10_configuracion.R`, leído en la sesión que emite; `stopifnot(nrow(ALIAS_CONSULTA) == 183L)` del propio archivo).
- El catálogo tiene 6 valores de `tipo` (`ley`, `dfl`, `dto`, `circular`, `rex`, `dictamen`), 5 normas con `origen_texto` igual a `ocr_pendiente_revision` y una norma con `vigencia.estado` igual a `sustituido` (fuente: recuento programático sobre `40_salidas/datos/catalogo.json` en la sesión que emite; se recuenta en FASE 0).
- `tipo` y `numero` del catálogo salen del nombre del archivo (fuente: `30_procesamiento/32_segmentar_articulos.R:55`, leído en la sesión que emite).
- `40_salidas/datos/relaciones.json` guarda 67 remisiones descartadas, todas hacia normas del corpus, y ninguna lista de normas citadas y no incluidas (fuente: recuento programático sobre la clave `descartadas` en la sesión que emite).
- `MAX_BLOQUES_FICHA <- 5L` se define en `30_procesamiento/31_extraer_texto.R:146` y no en `10_utils/10_configuracion.R` (fuente: `grep -rn` en la sesión que emite).
- La huella de caché del paso 30 no incluye la versión del código; editar el extractor no reprocesa nada salvo que se aparte `40_salidas/intermedios/extraccion.json` (fuente: `traspaso_cierre_v04.md` §11.1 P8).
- `CLAUDE.md` §10.6 tiene 5 filas, que es el tope del contrato global (fuente: conteo en la sesión que emite; `traspaso_cierre_v04.md` §7).
- `tests/medir_buscador.R` ya no usa `on.exit()` en el nivel superior (fuente: `grep -n on.exit tests/*.R` en la sesión que emite); el pendiente P5 correspondiente está cerrado.
- `40_salidas/sitio/` y `40_salidas/sitio_src/` están bajo `.gitignore`, y `50_documentacion/andamios/lab_motor_v9/salida_v11/` también (fuente: `git check-ignore` en la sesión que emite).
- Hay un navegador utilizable sin instalación desde Claude Code (hipótesis, se mide en FASE 0).

---

## 4. Invariantes 🔒 (cada uno con su comando; FASE R los corre todos)

| # | Invariante | Por qué | Comando de verificación | Esperado |
|---|---|---|---|---|
| 🔒1 | El conjunto de `id` de encabezado por página no cambia | Las citas copiadas fuera del sitio apuntan a esas anclas | `Rscript tests/inventario_anclas.R` y `diff` de su volcado contra la copia previa de FASE 0 en `50_documentacion/andamios/lab_motor_v9/salida_v11/v12/`, contado con `wc -l` | `0` |
| 🔒2 | `20_insumos/` sin cambios | Escritura humana exclusiva | `git diff --name-only <PUNTO DE RETORNO>..HEAD -- 20_insumos/ \| wc -l`; control positivo: el mismo comando sobre `tests/` | `0` y `> 0` |
| 🔒3 | Datos versionados idénticos, salvo la clave nueva de `relaciones.json` | Ninguna tarea cambia texto, catálogo ni relaciones existentes | `git diff --stat <PUNTO DE RETORNO>..HEAD -- 40_salidas/datos/` y, en R, `identical()` de cada clave de `relaciones.json` antes y después, excluida la clave nueva de T4 | solo `relaciones.json` en el diff; todas las claves previas `TRUE` |
| 🔒4 | Texto visible del articulado de cada página de norma idéntico | Fidelidad normativa | `Rscript` que extrae con `rvest::html_text2()` el nodo del articulado por página antes (FASE 0) y después, normaliza espacios y compara | `paginas_distintas: 0` |
| 🔒5 | Ninguna pieza publicada | Firma humana | `grep -rlE '^estado: *validada' 20_insumos/curaduria/piezas/ \| wc -l` y número de páginas HTML del sitio | `0` y el número medido en FASE 0 |
| 🔒6 | Sin Python; JavaScript solo donde §2 lo declara | `CLAUDE.md` §7 | `git diff --name-only <PUNTO DE RETORNO>..HEAD \| grep -cE '\.py$'` y `git diff --name-only <PUNTO DE RETORNO>..HEAD \| grep -E '\.(mjs\|js)$'` | `0`, y a lo más `tests/consulta_pagefind.mjs` y `tests/evaluar_precedencia.mjs` |
| 🔒7 | Ningún archivo de datos versionado fuera de `40_salidas/datos/` | `50_datos_versionados_autorizados.md` | `git ls-files \| grep -E '\.(csv\|json\|xlsx\|parquet\|rds\|txt)$' \| grep -vcE '^40_salidas/datos/'` | igual al valor medido en FASE 0 |
| 🔒8 | Ninguna consulta de ningún estrato empeora su posición respecto de la línea base de T1 | La mejora es pareada o no es mejora (A-15) | `Rscript tests/medir_buscador.R --sitio 40_salidas/sitio --salida 50_documentacion/andamios/lab_motor_v9/salida_v11/v12 --comparar-con <tabla de línea base de T1>` | `empeoran: 0` |
| 🔒9 | La decisión y este encargo no cambian después de T0 | Son la vara | `md5sum` de ambos archivos en T0 y en FASE R | idénticos |

---

## 5. Cadena de tareas

### 5.1 Grafo

- T0 (insumos) no depende de nada y va primero.
- T6 (`MAX_BLOQUES_FICHA`) requiere T0.
- T1 (instrumento v12 y línea base) requiere T6: mide sobre el sitio que T6 regenera.
- T2 (tablas y datos exportados) requiere T1 y T6.
- T3 (capa de precedencia) requiere T2.
- T4 (estado «sin resultado firme») requiere T3.
- T5 (degradación y latencia) requiere T4.
- T7 (fila de `CLAUDE.md`) requiere que T0 a T5 hayan terminado o quedado congeladas; corre igual.
- FASE R y FASE L no son descendientes de ninguna tarea; corren aunque toda la cadena quede congelada.

### 5.2 FASE 0 (orquestador; abre el log antes de medir nada)

1. `mkdir -p 50_documentacion/andamios/logs 50_documentacion/andamios/lab_motor_v9/salida_v11/v12` y crear el log con encabezado (meta, fecha, repo y rama, ENTORNO, grafo de §5.1, plan de §1.1, topes de §1.4), el slot `## J. Juicio (lo rellena FASE L)` vacío y los bloques vacíos de §4.1 y §4.2 del log.
2. Mediciones con pre-registro (`esperado:` escrito antes de correr; `obtenido:` literal después):
   - `esperado: https://github.com/tomgc/slep_normativa_convivencia.git` → `git remote get-url origin`. Condición 4 de §1.2.
   - `esperado: sesion_abierta: true` → `grep -E '^sesion_abierta:' 50_documentacion/activa/ESTADO.md`. Condición 3.
   - `esperado: dos líneas, ambas ??, las dos rutas de insumo` → `git fetch --quiet && git status --porcelain && git stash list`. Condición 1.
   - `esperado: iguales` → `git rev-parse HEAD origin/main`. Condición 2. Recién entonces, PUNTO DE RETORNO: `git rev-parse --short HEAD` al encabezado del log.
   - `esperado: una ruta` → `git config core.hooksPath`, y lectura del hook de pre-push antes de cualquier commit.
   - `esperado: 47` → `find 40_salidas/sitio -name '*.html' | wc -l` (si `40_salidas/sitio/` no existe, regenerar por pipeline y registrarlo).
   - `esperado: segmentos_con_ancla: 806 y destinos_resueltos: 848 de 848` → `Rscript tests/inventario_anclas.R`, con su volcado copiado como copia previa de 🔒1 en `50_documentacion/andamios/lab_motor_v9/salida_v11/v12/`. Condición 5.
   - `esperado: 47 páginas extraídas` → copia previa de 🔒4 (texto del articulado por página) en la misma carpeta.
   - `esperado: valor medido` → comando de 🔒7; el valor pasa a ser el esperado de FASE R.
   - `esperado: tipos 6, OCR 5, sustituidas 1, niveles 1/2/3 = 17/3/5` → `Rscript` sobre `40_salidas/datos/catalogo.json` con la tabla del §6 de la decisión (fuente de los valores: recuento programático en la sesión que emite).
   - `esperado: 1 definición en 31_extraer_texto.R, 0 en 10_configuracion.R` → `grep -n 'MAX_BLOQUES_FICHA *<-' 30_procesamiento/31_extraer_texto.R 10_utils/10_configuracion.R`.
   - `esperado: resueltas: 8 de 10` → `Rscript tests/medir_buscador.R --sitio 40_salidas/sitio --salida 50_documentacion/andamios/lab_motor_v9/salida_v11/v12` con el instrumento vigente (cuenta presencia). Segunda parte de la condición 5.
   - `esperado: el paso 33 no depende de la huella del paso 30 (hipótesis)` → lectura de la entrada del paso 33 en `PASOS` de `00_run_all.R` y de la cabecera de `30_procesamiento/33_relaciones.R`, con las líneas literales en el log; T4 lo necesita para que su cambio llegue a `relaciones.json`.
   - `esperado: no disponible (hipótesis)` → navegador utilizable sin instalar: `test -d node_modules/playwright; test -d node_modules/puppeteer; ls -d "/Applications/Google Chrome.app" "/Applications/Chromium.app" 2>&1`. El resultado decide la rama de T5 (§2, ambigüedad 5).
3. Anexar la sección `### FASE 0` al log.

### 5.3 T0: Insumos del encargo al repositorio (orquestador)

**Meta:** que la vara del encargo quede versionada antes de la primera medición.

**ALCANCE:** `50_documentacion/activa/decisiones/20260910_decision_precedencia_buscador.md`, `50_documentacion/andamios/20260910_encargo_v12_precedencia_v1.md` (solo `git add`).

**Pasos:** `md5sum` de ambos archivos al log (línea base de 🔒9); `git add` de las dos rutas; `git commit -m "docs(andamios): decisión de precedencia del buscador y encargo v12 (sesión 5)"`; push; workflow por `head_sha`.

**Criterio:** `esperado: vacío` → `git status --porcelain` después del commit.

**Cierre de fase:** no toca código (declararlo); sección del log.

### 5.4 T6: `MAX_BLOQUES_FICHA` a su fuente canónica (orquestador o subagente de escritura)

**Meta:** cerrar el último residuo de constantes fuera de `10_utils/10_configuracion.R` sin que cambie ningún dato.

**ALCANCE:** `10_utils/10_configuracion.R`, `30_procesamiento/31_extraer_texto.R`, y el movimiento autorizado de `40_salidas/intermedios/extraccion.json`.

**Pasos:**

1. Paso 0: leer `30_procesamiento/31_extraer_texto.R` (líneas 130 a 160) y la sección de `10_utils/10_configuracion.R` donde viven `REGEX_FICHA_ORIGEN` y `REGEX_PIE_ORIGEN`.
2. Registrar la definición y su comentario explicativo antes del cambio. Moverlos, con valor idéntico, junto a esas dos expresiones regulares; en `30_procesamiento/31_extraer_texto.R` queda solo el uso.
3. Calibración del conteo de reprocesados, caso malo conocido: sin apartar la caché, `bash -c 'Rscript -e "source(\"00_run_all.R\"); run_all()"'` → `esperado: 25 reutilizados, 0 reextraídos`.
4. `md5sum 40_salidas/intermedios/extraccion.json` al log, `mv` autorizado, pipeline completo → `esperado: 25 reextraídos, 0 reutilizados`.

**Criterio de éxito:**

- `esperado: vacío` → `git diff --stat -- 40_salidas/datos/` (🔒3: cambia la ubicación, no el valor).
- `esperado: 0` → 🔒1; `esperado: paginas_distintas: 0` → 🔒4.
- `esperado: 0 definiciones y 1 o más usos en 31_extraer_texto.R; 1 definición en 10_configuracion.R` → `grep -n 'MAX_BLOQUES_FICHA' 30_procesamiento/31_extraer_texto.R 10_utils/10_configuracion.R`.

**Cierre de fase:** verificación, regresión (PRUEBAS completo, porque tocó el extractor), alcance, commit `chore(configuracion): MAX_BLOQUES_FICHA a su fuente canónica (T6, P5)`, push, workflow por `head_sha`, sección del log.

### 5.5 T1: Instrumento v12 y línea base por posición (subagente de escritura; después, 1 de lectura)

**Meta:** que toda cifra del buscador se reporte por posición del ancla esperada, por estrato, con comparación pareada contra una línea base medida antes de tocar el orden (A-15, A-19, A-08, B-18, D-09 del log v11).

**ALCANCE:** `tests/consultas_evaluacion.R`, `tests/medir_buscador.R`, `tests/consulta_pagefind.mjs`.

**Pasos:**

1. Paso 0: leer los cuatro archivos de `tests/`, `busqueda.html` y los §3 a §8 de la decisión.
2. **Respuestas esperadas (decisión §8).** En `tests/consultas_evaluacion.R`: columna nueva `ancla_esperada_v11` con la esperada actual de las 10 históricas; `ancla_esperada` de C01, C03 y C06 pasa a la de la decisión; el conjunto aceptado de cada una contiene la esperada nueva y la anterior. Ninguna otra esperada cambia (§1.6).
3. **Esperadas a nivel de página.** Una esperada con la forma `<archivo>.html`, sin `#`, se cumple con cualquier resultado de esa página; la posición es la de la página en la lista mostrada.
4. **Estratos derivados**, construidos por código R dentro de `tests/consultas_evaluacion.R` que solo lee `40_salidas/datos/catalogo.json`, `40_salidas/datos/normas/*.json` y las constantes de la decisión, con validez de lectura. Columna `clase`:
   - `titular`: «dfl 1» → `dfl_1_estatuto_asistentes_educacion.html`; «bullying» → `ley_21809_convivencia_educativa.html#art-16-b`; «celular» → `ley_21801_celulares.html#art-10-bis`.
   - `norma_numero` (A-19): por norma, o por grupo de acto, las formas «<tipo> <número con punto de miles>», «<tipo> <número sin punto ni ceros a la izquierda>» y, si el número tiene 3 o más dígitos y es único, «<número>». Tipo escrito con el primer sinónimo de la decisión (§3, regla 1). Formas idénticas se cuentan una vez. Esperada: la página de la norma; en el grupo de acto del REX 482, `rex_482_instrucciones_reglamentos_internos.html`.
   - `articulo_nombrado` (A-08): las 10 primeras normas del catálogo, en su orden, con al menos un segmento cuya etiqueta empiece por «Artículo»; de cada una, el segmento de etiqueta «Artículo …» en la posición `ceiling(n/2)` de esos segmentos. Consulta: «<tipo> <número> <etiqueta>». Esperada: esa ancla.
   - `tema`: el nombre de cada uno de los 17 temas. Esperada: la página de la norma principal del §4 de la decisión. Mide el mecanismo, no la elección.
   - `alias_principal`: la frase de cada fila del §5 de la decisión con norma principal. Esperada: esa página. La fila «sin norma principal» se mide aparte: la regla que ubica la posición 1 no puede ser la 2.
   - `historica` y `sin_respuesta`: como hoy.
   La validez de lectura imprime el número de consultas por clase; `esperado:` de cada número es el que devuelve la re-derivación independiente del paso 7.
5. **`tests/consulta_pagefind.mjs`:** agregar el tiempo de inicialización y marcar la primera búsqueda de cada proceso como fría (A-17, aproximación fuera del navegador). Nada más en JavaScript.
6. **`tests/medir_buscador.R`:**
   - cifra principal por clase: consultas en posición 1 sobre el total de la clase; MRR; mediana de posición; ausentes. Ninguna cifra mezcla clases.
   - históricas: tabla consulta por consulta con la posición contra `ancla_esperada` y contra `ancla_esperada_v11`, y la regla que ubicó la página en posición 1 (antes de T3, «literal»).
   - intervalo de confianza del 95 % por remuestreo de la proporción en posición 1, para las históricas y para la unión de los estratos derivados, con `B_REMUESTREO <- 2000L` y semilla fija nombrada en el script (A-15, prueba del revisor).
   - recall@K de la lista cruda y cobertura del conjunto de anclas, como hoy (A-07, B-18).
   - argumento `--esperadas v11|decision` (por defecto `decision`).
   - argumento `--comparar-con <ruta>`: escribe, o lee si existe, la tabla de posiciones por consulta en la carpeta de salida, e imprime `empeoran: N`, `mejoran: N`, `cambian: N`, con la lista (🔒8).
   - latencia: fría y caliente separadas, mediana y máximo.
7. **Re-derivación independiente de los estratos (subagente de lectura, lanzado cuando el de escritura ya devolvió):** recibe el §4 de este encargo y la decisión, no el código de T1; produce con R propio la lista de consultas y esperadas por clase; `esperado: diff vacío` contra la de T1 (ordenadas por `clase` y `consulta`).

**Criterio de éxito y calibración:**

- Caso malo conocido: `--modo replica --esperadas v11` → `esperado: presentes 1 de 10` (la línea base del v9, que el v11 reprodujo; fuente: `traspaso_cierre_v04.md` §3).
- Caso conocido del v11: `--esperadas v11` → `esperado: presentes 8 de 10; en posición 1, 0 de 10; posiciones 6, 26, 13, 12, 2, 7, 2 y 8; C02 y C07 ausentes` (hipótesis del traspaso; si difiere, se registra la cifra real y su causa antes de seguir).
- Control adversarial por posición (D-09): con `--consultas` apuntando a una copia temporal fuera del árbol donde la esperada de una histórica se reemplaza por el ancla que hoy ocupa su posición 1 → `esperado: en posición 1 sube exactamente en 1`; y otra copia donde se reemplaza por un `id` existente que no aparece en la lista → `esperado: esa consulta pasa a ausente`.
- Control del remuestreo: con una copia donde las 10 históricas estén en posición 1 → `esperado: intervalo con límite superior 1`.
- Línea base oficial: `--esperadas decision --comparar-con 50_documentacion/andamios/lab_motor_v9/salida_v11/v12/linea_base_t1.rds` sobre el sitio de T6 → `esperado: en posición 1, 0 de 10 históricas (hipótesis)`; la tabla queda como la vara de 🔒8 para T2 a T5.

**Cierre de fase:** verificación, regresión (anclas y datos versionados; el buscador es el propio instrumento), alcance, commit `feat(tests): instrumento v12 por posición, estratos derivados y línea base (T1)`, push, workflow por `head_sha`, sección del log con la tabla de línea base completa.

### 5.6 T2: Tablas de precedencia y datos exportados del buscador (subagente de escritura)

**Meta:** que las tablas de la decisión vivan en R, se validen contra los datos antes de escribir nada, y lleguen al sitio como un archivo de datos, sin cambiar todavía el comportamiento del buscador.

**ALCANCE:** `10_utils/10_configuracion.R`, `30_procesamiento/34_generar_paginas.R`, y según la elección del paso 4, `_quarto.yml` (clave `resources:`) o `30_procesamiento/36_indexar_pagefind.R`.

**Pasos:**

1. Paso 0: leer los §3 a §7 de la decisión, `30_procesamiento/34_generar_paginas.R` completo (en particular el bloque que arma `datos_buscador` y la función `anclas_disponibles()`) y `_quarto.yml`.
2. **Constantes en `10_utils/10_configuracion.R`**, como `data.frame` o vectores con nombre y con la decisión citada como fuente en su comentario: `PRECEDENCIA_TEMAS` (17 filas: `tema`, `slug`, `ancla`), `PRECEDENCIA_ALIAS` (6 filas: `alias`, `slug`, `ancla`; `NA` en la fila sin norma principal), `NIVEL_FUENTE_TIPO` (los 6 tipos con su nivel), `NIVEL_FUENTE_OCR` (3), `ORIGENES_CITABLES`, `SINONIMOS_TIPO_CONSULTA`, `MIN_DIGITOS_NUMERO_SOLO` (3) y `FUENTES_ALIAS_NOMBRAN_NORMA` (`remision`, `denominacion`, `titulo`). `stopifnot()` estructural en el propio archivo (filas, nombres de columna, sin duplicados). Ninguna validación que lea datos de disco dentro de `10_configuracion.R`: ese archivo se carga antes de que los datos existan.
3. **Validación en `30_procesamiento/34_generar_paginas.R`, antes de escribir cualquier archivo:** toda norma y toda ancla de `PRECEDENCIA_TEMAS` y `PRECEDENCIA_ALIAS` existen en `40_salidas/datos/normas/`; todo tema de `PRECEDENCIA_TEMAS` existe en `TEMAS_PALABRAS_CLAVE`; todo alias de `PRECEDENCIA_ALIAS` existe en `ALIAS_CONSULTA` con `clave_fuente` igual a `temas`; todo `tipo` del catálogo está en `NIVEL_FUENTE_TIPO` (A-13, A-20). Un fallo es `stop()` con la lista completa.
4. **Exportación:** un único archivo de datos del buscador bajo `40_salidas/sitio/` con: las constantes que hoy van en `datos_buscador`; la tabla de alias con `clave_fuente`; las tablas de precedencia; y por norma, `slug`, nombre corto, `tipo`, número crudo y normalizado, grupo de acto, `origen_texto`, `vigencia`, **nivel ya calculado en R** con la tabla del §6, y la lista de anclas con su etiqueta. Elegir entre `resources:` en `_quarto.yml` y escritura en `30_procesamiento/36_indexar_pagefind.R` por lo que el render conserve, y registrar la elección con su evidencia. La inyección por página de `datos_buscador` se mantiene intacta en esta tarea: la retira T3 cuando `busqueda.html` ya lea el archivo.
5. Regenerar por pipeline.

**Criterio de éxito y calibración:**

- `esperado: 25 normas, 17 filas de tema, 6 filas de alias, 806 anclas, niveles 17/3/5` → lectura en R del archivo exportado en `40_salidas/sitio/`.
- Controles negativos (A-13, A-20), por archivo alternativo o argumento, nunca sustituyendo la constante antes de un `source()` (§1.5): con una fila de tema que apunta a un ancla inexistente, `esperado: stop() antes de escribir y ninguna marca de modificación nueva en 40_salidas/sitio_src/`; con un tipo inventado en una copia temporal del catálogo fuera del árbol, `esperado: stop() nombrando el tipo`. Caso bueno: las tablas reales, `esperado: sin stop()`.
- `esperado: empeoran: 0, cambian: 0` → `Rscript tests/medir_buscador.R --sitio 40_salidas/sitio --salida 50_documentacion/andamios/lab_motor_v9/salida_v11/v12 --comparar-con 50_documentacion/andamios/lab_motor_v9/salida_v11/v12/linea_base_t1.rds` (T2 no cambia el orden).
- 🔒1 `esperado: 0`; 🔒3 `esperado: vacío`; 🔒4 `esperado: paginas_distintas: 0`.

**Cierre de fase:** verificación, regresión (PRUEBAS completo), alcance, commit `feat(buscador): tablas de precedencia y datos exportados del buscador (T2)`, push, workflow por `head_sha`, sección del log.

### 5.7 T3: Capa de precedencia en `busqueda.html` (orquestador o subagente de escritura)

**Meta:** que el orden de resultados aplique las reglas 1 a 4 de la decisión, medido con el código que se publica.

**ALCANCE:** `30_procesamiento/34_plantillas_sitio/busqueda.html`, `30_procesamiento/34_generar_paginas.R` (solo para retirar la inyección por página de la tabla de alias), `tests/evaluar_precedencia.mjs` (nuevo), `tests/medir_buscador.R` (solo el cableado del evaluador).

**Pasos:**

1. Paso 0: leer `busqueda.html`, el §3 de la decisión, el archivo de datos que exporta T2 y `tests/medir_buscador.R`.
2. **Bloque de precedencia.** Llevar a funciones puras (sin DOM y sin red), entre las marcas de una línea `// == INICIO BLOQUE DE PRECEDENCIA ==` y `// == FIN BLOQUE DE PRECEDENCIA ==`, todo lo que hoy decide qué se busca y en qué orden se muestra: troceo, variantes, unión y orden. Las funciones reciben la consulta, una función de búsqueda inyectada y los datos exportados, y devuelven la lista de páginas con sus sub-resultados ordenados, la regla que ubicó cada página y el estado. Un interruptor `precedencia` en falso reproduce exactamente el orden del v11 (piso R0).
3. **Reglas de la decisión**, con el interruptor en verdadero:
   - Regla 1: tipo y número con sinónimos y número normalizado; número único de 3 o más dígitos; frase de alias `remision`, `denominacion` o `titulo`; artículo nombrado.
   - Regla 2: filas por alias primero (todas las raíces distintivas presentes; gana la de más raíces; empate por aparición), tabla por tema después; el artículo lo elige la coincidencia con los sub-resultados de esa página y el ancla de respaldo solo sin coincidencia; la norma principal se compone con los datos exportados si Pagefind no la devolvió.
   - Regla 3: grupo A (consulta completa) antes que grupo B (solo variantes); dentro de cada grupo, nivel exportado por R; una norma sustituida nunca antes que su sustituta.
   - Regla 4: orden de Pagefind dentro de cada nivel; sub-resultados por relevancia como hoy.
   - Varias normas o temas: por aparición en la consulta; cada página ocupa una sola posición, la de su regla más alta.
4. **Datos:** `30_procesamiento/34_plantillas_sitio/busqueda.html` carga el archivo de datos exportado en la primera búsqueda. Retirar de `30_procesamiento/34_generar_paginas.R` la inyección por página de la tabla de alias (cierra el P5 de la tabla repetida en 47 páginas); si la carga falla, la página conserva la búsqueda literal (el camino completo de falla lo cierra T5).
5. **Comentario de cabecera:** corregir la frase que dice que el instrumento extrae el bloque de orden, para que describa lo que desde este encargo es cierto.
6. **`tests/evaluar_precedencia.mjs`:** extrae el bloque de precedencia de una página del sitio publicado (`40_salidas/sitio/index.html`), carga el archivo de datos del sitio y el runtime de Pagefind del sitio, ejecuta el bloque sobre las consultas que recibe y devuelve JSON con la lista ordenada, la regla por página, el estado y los tiempos. No calcula ninguna cifra. Argumento para fijar el interruptor `precedencia`.
7. **`tests/medir_buscador.R`:** argumento `--evaluador js|r`, por defecto `js` desde esta tarea; `r` conserva la reimplementación en R para la re-derivación de FASE R.
8. Regenerar por pipeline.

**Criterio de éxito y calibración:**

- Caso bueno conocido: `--evaluador js` con `precedencia` en falso → `esperado: cambian: 0` contra `linea_base_t1.rds`. Si cambia algo, el bloque no reproduce el v11 y la tarea no sigue.
- Con `precedencia` en verdadero, contra `linea_base_t1.rds`:
  - `esperado: empeoran: 0` en todas las clases (🔒8, condición 7 de §1.2).
  - históricas: `esperado: 8 o más de 10 en posición 1`. Es umbral de ingeniería, no prueba de mejora (A-15); la medida que decide es la pareada, consulta por consulta, con su regla.
  - titular: `esperado: 3 de 3`; `norma_numero`: `esperado: todas`, con cualquier diferencia entre formas listada (A-19); `articulo_nombrado`: `esperado: 10 de 10`; `tema`: `esperado: 17 de 17`; `alias_principal`: `esperado: todas`, y en la fila sin norma principal, `esperado: regla de la posición 1 distinta de 2`.
- Control adversarial por posición (D-09), con un archivo de datos alternativo fuera del árbol donde la fila del tema «uso de dispositivos móviles» apunta a `rex_181_celulares` con ancla `documento` → `esperado: «celular» y la consulta de ese tema pierden la posición 1 de la Ley 21.801, y el instrumento lo reporta`.
- Latencia con y sin precedencia: se registra.
- 🔒1 `esperado: 0`; 🔒3 `esperado: vacío`; 🔒4 `esperado: paginas_distintas: 0`; 🔒6.

**Cierre de fase:** verificación, regresión (PRUEBAS completo), alcance, commit `feat(buscador): capa de precedencia determinística (T3, P1)`, push, workflow por `head_sha`, sección del log.

### 5.8 T4: Estado «sin resultado firme» y normas citadas no incluidas (subagente de escritura)

**Meta:** que una consulta sin respuesta en el corpus lo diga, y muestre qué normas citadas por el corpus faltan (B-03, parte derivada de B-04).

**ALCANCE:** `30_procesamiento/33_relaciones.R`, `10_utils/10_configuracion.R` (solo las constantes nuevas de esta tarea), `30_procesamiento/34_generar_paginas.R` (solo para llevar la lista al archivo de datos), `30_procesamiento/34_plantillas_sitio/busqueda.html`, `tests/medir_buscador.R` (solo el reporte del estado).

**Pasos:**

1. Paso 0: leer `30_procesamiento/33_relaciones.R` completo (cómo reconoce una cita de norma y cómo la resuelve contra el catálogo) y `00_run_all.R` (si el paso 33 corre siempre o depende de una huella; hipótesis: corre siempre, se registra lo leído).
2. **Derivación en `30_procesamiento/33_relaciones.R`:** registrar las citas literales de normas que no resuelven a ninguna norma del catálogo, agrupadas por norma citada (`tipo`, `numero`, `anio` o nulo), con número de menciones y hasta `TOPE_MENCIONES_CITADA` referencias `slug#ancla` de donde se citan, y escribirlas como una clave nueva `citadas_no_incluidas` de `relaciones.json`. Las claves existentes no cambian. Las constantes nuevas van a `10_utils/10_configuracion.R`.
3. **`30_procesamiento/34_generar_paginas.R`:** lleva la lista al archivo de datos del buscador.
4. **`30_procesamiento/34_plantillas_sitio/busqueda.html`:** cuando el bloque devuelve el estado «sin resultado firme» (la consulta completa no devuelve páginas y no se activa la regla 1 ni la 2), la página muestra un mensaje breve y factual, la lista de normas citadas y no incluidas ordenada por menciones, y debajo, rotulados como relacionados, los resultados de las variantes. Sin primera persona.
5. Regenerar por pipeline.

**Criterio de éxito y calibración:**

- Caso bueno plantado por el propio corpus: `esperado: la lista contiene el DFL 2 de 1998 y la Ley 21.128` (hipótesis: el Dictamen 52/77 cita ambos en su materia; fuente: `40_salidas/datos/normas/dictamen_52_77_expulsion.json`, leído en la sesión que emite). Control negativo: `esperado: ninguna norma del catálogo figura en la lista` (por ejemplo, la Ley 20.370, citada muchas veces, no aparece).
- 🔒3: `esperado: solo relaciones.json en git diff --stat; identical() TRUE para cada clave previa`.
- `sin_respuesta`: `esperado: estado «sin resultado firme» en 4 de 4`. Todas las demás clases: `esperado: 0 consultas con ese estado`.
- `esperado: empeoran: 0` contra `linea_base_t1.rds`.
- 🔒1 `esperado: 0`; 🔒4 `esperado: paginas_distintas: 0`.

**Cierre de fase:** verificación, regresión (PRUEBAS completo), alcance, commit `feat(buscador): estado sin resultado firme y normas citadas no incluidas (T4, B-03)`, push, workflow por `head_sha`, sección del log.

### 5.9 T5: Tabla de degradación y latencia (orquestador o subagente de escritura)

**Meta:** que cada componente del buscador tenga declarado qué pasa si falla, y que esa conducta esté probada (A-09); y registrar la latencia fría y caliente (A-17).

**ALCANCE:** `30_procesamiento/34_plantillas_sitio/busqueda.html`, `tests/evaluar_precedencia.mjs`, `tests/medir_buscador.R`.

**Pasos:**

1. Escribir en el comentario de cabecera de `30_procesamiento/34_plantillas_sitio/busqueda.html` la tabla de degradación, una fila por componente, con las columnas «componente | falla | qué se omite | qué ve el usuario | rótulo visible». Filas mínimas: runtime de Pagefind; archivo de datos del buscador (no carga o no se puede leer); tabla de precedencia ausente dentro de un archivo que sí carga; una variante que falla. Rótulo visible siempre que el orden no aplique las reglas de la decisión.
2. Implementar en `30_procesamiento/34_plantillas_sitio/busqueda.html` cada camino de la tabla que aún no exista.
3. Argumento `--simular-falla <componente>` en `tests/evaluar_precedencia.mjs`, y su paso a través de `tests/medir_buscador.R`.
4. Rama con navegador (si FASE 0 lo encontró): 30 búsquedas frías y 30 calientes sobre las históricas en el sitio servido localmente; mediana y p90 de cada una. Rama sin navegador: registrar la medición como duda para el titular, con el comando que la haría.

**Criterio de éxito y calibración:**

- Por fila de la tabla, `esperado:` la conducta escrita en la tabla, obtenida con `--simular-falla`. Control: sin falla simulada, `esperado: cambian: 0` contra la tabla de posiciones que dejó T4.
- `esperado: empeoran: 0` contra `linea_base_t1.rds`.
- Latencia: se registra; no bloquea.

**Cierre de fase:** verificación, regresión (PRUEBAS completo), alcance, commit `feat(buscador): tabla de degradación y caminos de falla (T5, A-09)`, push, workflow por `head_sha`, sección del log.

### 5.10 T7: Fila de `CLAUDE.md` §10.6 (orquestador, serie)

**ALCANCE:** `CLAUDE.md` (§10.6). Una fila para este encargo, escrita desde el estado real por tarea (completada o congelada, con hashes de `git log`), y retiro de la fila más antigua para conservar el tope de 5 filas (decisión D-08 del log v11, aceptada en la sesión 5). `esperado: 5 filas` → conteo de filas de datos de la tabla de §10.6 después del cambio. Commit `docs(claude): fila de la sesión 5, encargo v12 (T7)`, push, workflow por `head_sha`.

---

## 6. FASE R: Auditoría propia y reparación (penúltima, obligatoria)

Corre siempre, después de la última tarea de la cadena (congeladas incluidas) y antes de FASE L. Regla de oro: la reparación cambia el trabajo, nunca el criterio, la tolerancia, el valor esperado ni la meta.

1. **Inventario de afirmaciones auditables**, derivado del log y no de la memoria: cada línea `Verificación:` y cada cifra de las secciones por fase, cada 🔒 de §4 con su comando, y el alcance global. Numerado `R-01`, `R-02`, ..., anexado al log **antes** de auditar nada. Lo que no está en el inventario no se auditó.
2. **Re-derivación independiente:** cada afirmación se re-deriva con un comando distinto del que la produjo. Las posiciones del evaluador `js` se re-derivan con `--evaluador r`, que no comparte código con el bloque publicado, y ambas tablas deben coincidir consulta por consulta; toda diferencia es hallazgo. El conteo de anclas, con `grep -o 'id="'` sobre el HTML contra el de `rvest`. Hay riesgo de cifras e invariantes: hasta 2 subagentes de lectura re-derivan 🔒1, 🔒3, 🔒4 y 🔒8 recibiendo la afirmación y el repositorio, no el razonamiento ni el código que las produjeron.
3. **Invariantes 🔒:** el comando de cada uno de los nueve de §4, PASA/FALLA con salida literal.
4. **Chequeo global de alcance:** `git diff --name-only <PUNTO DE RETORNO>..HEAD` ⊆ unión de los ALCANCE de §1.3 más el log; y `git status --porcelain` (lo no commiteado es hallazgo, no se limpia).
5. **Regresión completa:** los tres comandos de PRUEBAS sobre el estado final, con `esperado:` y `obtenido:`.
6. **Control positivo de la propia auditoría:** al menos una afirmación se audita además con un caso plantado (una posición alterada en una copia temporal de la tabla del evaluador fuera del árbol, que la comparación `js` frente a `r` debe detectar; un archivo fuera de alcance simulado en un diff de prueba). Una auditoría que solo confirmó no auditó.
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
- Estado por tarea: T0 · T6 · T1 · T2 · T3 · T4 · T5 · T7, cada una completada (<hash>) | congelada (<condición>) | no ejecutada (depende de ...).
- Commits: <N>, rango <hash_inicial>..<hash_final>, de los cuales <k> fix(auditoria).
- Auditoría (FASE R): <veredicto>; hallazgos B/R/A = <b>/<r>/<a>; reparados <n>; abiertos <m> (<ids>).
- Invariantes: <n>/9 PASA; FALLA: <nombres o ninguno>.
- Cifras críticas: históricas en posición 1, línea base → final; por estrato; 806 / 848 / 47: <intactas o alteradas, con evidencia>.
- Decisiones autónomas de mayor riesgo: hasta 3, irreversibles primero, cada una con la alternativa descartada.
- Desviaciones respecto del encargo: <dónde difiere | ninguna>.
- Dudas abiertas: <N>; las 3 más bloqueantes con su pregunta cerrada.
- Errores propios: <N> registrados; los que costaron más de un turno.
- Qué debe verificar el revisor por sí mismo: <lo no medible con independencia en esta sesión>.
- No publicado / queda al usuario: <push retenido, decisión pendiente | nada>.
```

4. **Grep de privacidad sobre el log:** `grep -nE '[0-9]{1,2}\.?[0-9]{3}\.?[0-9]{3}-[0-9kK]' 50_documentacion/andamios/logs/20260910_precedencia_buscador_v12_log.md` → esperado vacío; lectura del archivo para confirmar que no contiene filas de datos ni nombres de personas. Un hit se reemplaza por un conteo o un hash antes del commit y la sustitución se declara.
5. **Verificación observable del archivo:** `ls -l <LOG> && wc -l <LOG>`; `grep -c '^### FASE' <LOG>` igual al número de fases ejecutadas (FASE 0, T0, T6, T1, T2, T3, T4, T5, T7 y FASE R: 10 si ninguna quedó sin ejecutar; congeladas incluidas); `grep -c '^esperado:' <LOG>` igual a `grep -c '^obtenido:' <LOG>`; `grep -c '^## J' <LOG>` = 1 con el bloque relleno. Si un conteo difiere, se anexa la sección o línea faltante con su estado real; no se ajusta el conteo.
6. **Commit propio y siempre:** `git add 50_documentacion/andamios/logs/20260910_precedencia_buscador_v12_log.md` (solo el log) y `git commit -m "docs(log): encargo v12, capa de precedencia del buscador"`; push autorizado, viaja.
7. **Estado de cierre declarado:** qué quedó commiteado, qué NO se publica y qué queda al usuario, con `git log -1 --format=%h` del commit `docs(log)`.

---

## 8. Reporte final (en el chat)

1. **Primera línea, sin excepción:** la salida literal de `ls -l <LOG> && wc -l <LOG>` y el hash del commit `docs(log)`.
2. **Segundo bloque:** el bloque J copiado tal cual del log.
3. Después: la tabla de las 10 históricas con posición en la línea base y al final, con esperada de la decisión y con esperada v11, y la regla que ubicó la posición 1; el resumen por estrato con su intervalo; «dfl 1», «bullying» y «celular»; la lista de normas citadas y no incluidas; la tabla de degradación con su prueba; latencia; hashes y estado del workflow por `head_sha`; pendientes y `# REVISAR`; y «lo que falló o sorprendió; si nada, decirlo explícitamente».

Nada más en el chat. El detalle vive en el log.

---

## 9. Contrato de subagentes (ocho reglas, vigentes en todo el encargo)

1. **Tope:** 2 subagentes simultáneos, de cualquier rol, panel de FASE R incluido. El orquestador no cuenta, no se reemplaza y no se delega.
2. **Dos roles, y ninguno más.** *Lectura:* medir, re-derivar, auditar, buscar; sin escritura en el árbol. *Escritura:* implementar una tarea dentro de su ALCANCE; sin git, sin log, sin borrar, sin lanzar subagentes.
3. **Serie para escritura:** en este encargo ninguna tarea de escritura corre en paralelo con otra (§1.1). El orquestador espera el retorno, lo verifica (regla 5) y commitea con las rutas explícitas del ALCANCE.
4. **Lo que recibe cada subagente:** la tarea con su criterio de término y su ALCANCE, los 🔒 de §4 con su porqué, la POSICIÓN (rutas desde la raíz, `bash` explícito, `Rscript`), la prohibición literal de Python (§1.5), la regla del `source()` transitivo (§1.5), la regla «sin git, sin borrar, nada fuera de ALCANCE, ante duda detente y devuelve», y el formato de retorno: rutas tocadas (lista), comandos corridos con salida literal, `esperado:` / `obtenido:` de su verificación, dudas con pregunta cerrada. Nunca recibe autorizaciones destructivas ni el derecho a ampliar su alcance.
5. **Su retorno es hipótesis.** El orquestador verifica con comando propio antes de commitear: `git diff --name-only` contra la lista de rutas declarada (idénticas), el chequeo de la tarea y la regresión. «Listo» sin evidencia es tarea no hecha. Un subagente que tocó fuera de su ALCANCE congela la tarea: sus cambios no se commitean y el hecho va al log como hallazgo de alcance.
6. **Sin anidamiento.** Un subagente no lanza subagentes.
7. **Fallo de subagente.** Un reintento con el mismo contrato; al segundo fallo la tarea la hace el orquestador en serie, o se congela. Nunca se relanza con un contrato más laxo.
8. **Registro.** La sección de log de cada tarea lleva `Subagentes:` (rol, ALCANCE, qué devolvió, con qué comando lo verificó el orquestador). Lo que un subagente devolvió y el orquestador no verificó entra al log como duda, no como hecho.

---

## 10. Lo que este encargo deja fuera, con razón

- **Presentación visible de resultados (v13):** B-08 y B-09 (rótulo con nivel, tipo y estado impreso), B-15 (botón «Copiar cita»), B-14 (enlace al texto vigente en LeyChile y línea de portada), B-01 en su parte derivada («versión del texto: no declarada»), B-05 (nota de sustitución como encabezado), B-18 en su parte de presentación (tipo visible y términos coincidentes) y B-19 (prueba en teléfono real). Dependen de este orden y se aceptan contra él sin retroceso de posición.
- **Decisiones del titular pendientes:** D-A (A-16, B-11: hash por segmento y estado «requiere revalidación»), D-B (A-01 a A-05, A-10, A-12: vía semántica), D-C (B-02 y B-20: enlace «¿No encontraste lo que buscabas?» y dueño) y D-D (B-10: forma de la firma).
- **Capa 1 y capa 3 del diseño, y vía A:** A-14, A-18 (sugerencias), B-06 (capa 1), B-07 (índice de situaciones, escritura humana), B-12, B-13 y B-16. Van a la especificación v2 o a la pauta de validación.
- **A-11 y P8 (huella de caché con versión de código):** cambian el criterio de reprocesamiento de todo el pipeline y exigen su propia línea base; mezclarlos con la capa de precedencia rompe «un cambio conceptual por intervención» (`SETTINGS_Y_PROMPTS_OPERACIONALES.md` §1.2.6).
- **Índice lateral de `pagina_pieza()` (P5):** no hay pieza publicable contra la cual verificarlo; lo lleva el encargo que publique la primera pieza (`traspaso_cierre_v04.md` §11.1 P5).
- **`indice-tema.html` sin encabezados con `id` (P5):** no toca el orden de resultados.
- **D9 de la compuerta (posición local frente a producción):** el runner lee el índice por ruta local; medir el sitio publicado exige un modo nuevo del runner que no está en el ALCANCE. Queda como duda.
- **D-06 y D-07 del log v11:** se aplican en el encargo que edite el laboratorio; este no lo edita.
- **A-17 en un equipo y una red institucionales, y la prueba de B-19:** exigen el dispositivo de referencia del titular.
