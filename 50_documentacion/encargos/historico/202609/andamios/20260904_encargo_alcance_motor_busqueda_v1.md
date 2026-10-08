# Encargo v9 — Alcance del motor de búsqueda asistida

> **Destino en el repositorio:** `50_documentacion/andamios/20260904_encargo_alcance_motor_busqueda_v1.md`
> **Tipo:** vía B (autónomo, sin firma humana requerida para lo que produce).
> **Naturaleza:** encargo de ALCANCE. Produce especificaciones medidas y prototipos de laboratorio. **No** integra nada al pipeline ni al sitio publicado.
> **Emitido:** 2026-09-04, sesión 3.

---

## 0. Encuadre del proyecto (leer antes de todo lo demás)

Este proyecto es un ejercicio académico-técnico sobre literatura pública: derecho chileno publicado (leyes, decretos, circulares, resoluciones, dictámenes). No maneja datos personales y no es un servicio institucional del SLEP. Ese encuadre elimina la exigencia de cuenta institucional y de gobernanza de datos sensibles, pero **no** elimina tres invariantes que siguen mandando sobre el diseño:

1. **Cita textual y trazabilidad.** Todo lo que el motor devuelva debe ser rastreable a un artículo con ancla pública estable, o estar rotulado como no normativo.
2. **Firma humana sobre lo interpretativo.** Nada interpretativo se publica sin `validado_por` (fuente: `traspaso_cierre_v02.md` §12, 🔒). En un prototipo esto se cumple **rotulando** la salida como no validada, no bloqueándola.
3. **Solo derecho chileno.** El motor no razona sobre normativa extranjera ni sobre literatura no oficial.
4. **Texto OCR no revisado no es evidencia recuperable.** Hay 84 páginas en 5 documentos cuyo texto proviene de reconocimiento automático sin firma humana (fuente: `ESTADO.md`, sección Bloqueantes). Un motor que las devuelva como fundamento normativo rompe el invariante de cita textual. Toda capa de recuperación debe poder excluirlas o marcarlas, y ese comportamiento se especifica, no se supone.
5. **Las relaciones se derivan de metadatos, nunca se infieren.** Las 552 relaciones existentes salen de reglas sobre metadatos con explicación por plantilla (fuente: `traspaso_cierre_v02.md`). Ningún modelo genera, propone ni completa una relación entre normas. Un tipo de relación que no se pueda derivar programáticamente no se incorpora.

El encargo diseña tres capas, que son tres problemas distintos y no deben mezclarse:

- **Capa 1 — sugerencia de conceptos mientras se escribe.** Vocabulario controlado servido como JSON estático. Sin LLM, sin backend.
- **Capa 2 — búsqueda semántica.** Recuperación por significado sobre los artículos del corpus. Declarada Fase 3 diferida en el traspaso v02; este encargo la especifica, no la construye.
- **Capa 3 — orientación sobre cómo abordar un tema.** Dos variantes: precalculada y firmada (estática, respeta la compuerta) o en vivo contra una API detrás de un Worker con Access.

---

## 0bis. Insumo externo evaluado (adopciones y rechazos ya decididos)

El Área de Monitoreo aportó un diseño conceptual elaborado con otro asistente ("sistema de inteligencia normativa", 19 secciones). **Ya fue evaluado. Las decisiones de esta sección son firmes y ningún agente vuelve a discutirlas**, salvo que encuentre evidencia medida que las contradiga, en cuyo caso lo reporta como hallazgo en vez de actuar por su cuenta.

**Se adopta:**

| Idea | Por qué entra |
|---|---|
| Búsqueda híbrida (léxica + vectorial) con fusión de rangos, en vez de elegir una | Los embeddings fallan justamente en lo que este corpus tiene de más consultado: números de ley, números de artículo, nombres exactos de figuras jurídicas |
| Reranking sobre los candidatos recuperados, conservando los puntajes de cada motor | Los puntajes conservados son el insumo de cualquier evaluación posterior de calidad |
| Vigencia y temporalidad como dimensión de consulta de primera clase | "Qué estaba vigente en 2021" y "qué rige hoy" son preguntas distintas; el corpus ya tiene `vigencia` y `sustituido_por` desde la sesión 1 |
| Separación explícita en cuatro niveles: fuente primaria, pronunciamiento oficial, orientación experta, inferencia del modelo | Es el invariante de firma del proyecto expresado como capas; el sitio ya tiene cuatro insignias de fuente en `estilo.css` |
| La capa experta como estructura de datos y no como prosa (tema, preguntas relacionadas, qué debe considerarse, documentos prioritarios) | Es precalculable y firmable, así que pasa la compuerta; la prosa suelta no |
| Descomponer preguntas complejas en subpreguntas antes de recuperar | Mejora la cobertura, pero entra **solo como opción con costo medido**, no como decisión tomada |
| Estructurar el análisis de un caso en vez de entregar una conclusión inmediata | Coincide con lo que la compuerta exige: síntesis documental rotulada, no dictamen |

**Se rechaza, con razón:**

| Idea | Por qué no entra |
|---|---|
| Construir el grafo normativo desde cero con 12 tipos de relación | El grafo ya existe con 4 tipos y 552 aristas medidas. Ampliar la ontología es una decisión, no un punto de partida, y tipos como `CONTRADICE` exigen un juicio jurídico que ningún metadato sostiene |
| Clasificación automática del corpus por modelo (materias, normas modificadas, conceptos) | Colisiona de frente con `metadatos_curados.json`, que es de escritura humana exclusiva y con procedencia obligatoria por dato. Es la capa que la sesión 1 construyó a propósito |
| Stack completo con D1, R2, AI Search, Vectorize y Workers AI | Sobreingeniería para 25 normas y 682 artículos: el corpus entero cabe en un archivo servido estáticamente, los PDFs ya los sirve GitHub Pages, y un grafo de 552 aristas no necesita una base de datos |
| Módulos de ingesta, normalización y OCR | Ya existen, funcionan y están probados desde clon limpio. Rediseñarlos es trabajo destruido |
| Entrenar un reranker propio con datos de uso | Un equipo pequeño sobre 682 unidades no va a producir el volumen que eso exige. Se declara fuera de alcance y se dice por qué, en vez de dejarlo como promesa |
| Afirmaciones sobre lo que Cloudflare AI Search soporta hoy | No vienen de la documentación oficial. Entran como hipótesis a verificar en A4, no como base de diseño |

**Lo que el documento externo no vio, y sí manda aquí:** el corpus tiene 84 páginas de OCR sin firma que no son citables, y las relaciones de este proyecto no se infieren. Cualquier diseño que ignore esas dos cosas es inaplicable por bien construido que esté.

---

## 1. Precondiciones bloqueantes

Comprobar **antes** de escribir una sola línea. Si alguna falla, **detenerse y reportar**, sin trabajar.

| # | Precondición | Comando |
|---|---|---|
| P1 | El encargo v8 (medición de legibilidad) terminó y pusheó, o no fue lanzado | `git log --oneline -5` y buscar `docs(andamios): medicion de legibilidad del sitio v1` |
| P2 | Árbol limpio y sincronizado con el remoto | `git fetch --quiet && git status --porcelain && git rev-parse HEAD origin/main` |
| P3 | Sesión abierta por esta máquina | `grep -E '^(sesion_abierta\|maquina):' 50_documentacion/activa/ESTADO.md` |
| P4 | Existe la carpeta de destino | `ls -d 50_documentacion/andamios/logs` |

**P1 es la que importa:** dos encargos escribiendo el mismo árbol de trabajo en paralelo es la forma segura de perder trabajo. Si v8 sigue corriendo, este encargo espera. Si v8 ya pusheó, hacer `git pull --rebase` antes de empezar y dejar constancia del hash resultante en el log.

---

## 2. Autorizaciones (lista exhaustiva; todo lo no listado está prohibido)

**Lectura:** cualquier archivo del repositorio, sin restricción.

**Escritura, solo estos archivos:**

| Archivo | Autor |
|---|---|
| `50_documentacion/andamios/20260904_alcance_capa1_vocabulario_v1.md` | A1 |
| `50_documentacion/andamios/20260904_prototipo_vocabulario.R` | A1 |
| `50_documentacion/andamios/20260904_alcance_capa2_semantica_v1.md` | A2 |
| `50_documentacion/andamios/20260904_medicion_corpus_semantica.R` | A2 |
| `50_documentacion/andamios/20260904_alcance_capa3_orientacion_v1.md` | A3 |
| `50_documentacion/andamios/20260904_alcance_arquitectura_cloudflare_v1.md` | A4 |
| `50_documentacion/andamios/20260904_panel_adversarial_motor_v1.md` | A5 |
| `50_documentacion/andamios/20260904_auditoria_alcance_motor_v1.md` | AUD |
| `50_documentacion/andamios/20260904_alcance_motor_busqueda_sintesis_v1.md` | SINT |
| `50_documentacion/andamios/logs/20260904_alcance_motor_busqueda_v9_log.md` | orquestador |

Ningún archivo tiene dos autores. Un agente que necesite corregir el archivo de otro **no lo edita**: lo reporta al orquestador (ver §6).

**Salidas de laboratorio:** los prototipos escriben sus artefactos en `50_documentacion/andamios/lab_motor_v9/` (crear si no existe). Esa carpeta es desechable y se declara como tal en el log.

**Red:** autorizada exclusivamente hacia `developers.cloudflare.com`, `www.cloudflare.com`, `docs.claude.com`, `www.anthropic.com` y `github.com` (este último solo para `gh run`). Cualquier otro dominio está prohibido. **Si no hay red disponible, las verificaciones que la exigen se registran como NO MEDIDAS y se declaran como hipótesis con su comando de verificación; no se rellenan de memoria.**

**Commits y push:** hasta cinco commits, uno por fase, cada uno pusheado. La verificación de CI posterior al push está explícitamente autorizada y esperada; no cuenta como push adicional.

---

## 3. Prohibiciones

- Escribir en `20_insumos/` por cualquier motivo. No hay delegación vigente y este encargo no pide ninguna.
- Escribir en `40_salidas/`, en `30_procesamiento/`, en `10_utils/`, en `_quarto.yml` o en cualquier `00_*.R`.
- Regenerar el pipeline, correr `00_ocr_documentos.R`, o modificar `estilo.css`.
- Publicar, validar o tocar el estado de ninguna pieza interpretativa.
- **Python.** El proyecto es R-only (`CLAUDE.md` §7). Esta prohibición debe reproducirse literalmente en el prompt de cada subagente, sin excepción. Un subagente ya violó esta regla en la sesión 2 por omisión en el prompt.
- Acceso `$` sobre estructuras leídas de disco. `[[ ]]` exacto, siempre (regla aprendida 1 de la sesión 2).
- Consumir cuota real de ninguna API de modelo. Los costos se **calculan**, no se prueban gastando.

---

## 4. Estándar de rigor (aplica a todo agente, en todas las fases)

Estas cinco reglas vienen de defectos medidos en la sesión 2. No son estilo.

1. **Ninguna cifra sin recuento programático del mismo turno.** Una cifra heredada de un documento anterior, de la memoria o de aritmética mental no es una fuente. Si la cifra viene del traspaso, se recuenta contra el artefacto.
2. **Ningún cero sin control positivo calibrado.** Antes de reportar "0 coincidencias", plantar un caso que el instrumento *debe* encontrar y mostrar que lo encuentra. Los siete defectos de instrumento de la sesión 2 los cazó un caso plantado; ninguno la lectura del código.
3. **"Salió con código 0" no es "se ejecutó".** La evidencia es el cambio observable y contado: mtimes, líneas escritas, conteos antes y después.
4. **Un enunciado universal exige el comando exhaustivo que lo sostiene.** "Todos los artículos", "ninguna página", "siempre" solo se escriben con el comando pegado al lado. Si no hay comando, se acota el enunciado.
5. **Ningún patrón dependiente de locale se escribe a mano.** Se deriva en runtime provocando el caso.

**Herramientas:** R exclusivamente para todo análisis y prototipo. R moderno: pipe nativo `|>`, `dplyr >= 1.1` con `.by=` (no `group_by`/`ungroup`), `here::here()` para toda ruta dentro de scripts. Bash solo como auxiliar (git, ls, wc). `jsonlite` para JSON.

---

## 5. Fases

### FASE 1 — Trabajo paralelo (hasta 5 agentes simultáneos)

Los cinco agentes corren en paralelo. Cada uno recibe: el encuadre de §0, el estándar de §4, sus autorizaciones de §2 y la prohibición literal de Python. Ninguno lee el archivo de salida de otro (evita la convergencia artificial que hace inútil el panel de A5).

---

#### A1 — Capa 1: vocabulario controlado

**Objetivo:** especificar, y demostrar con un prototipo medido, el índice de sugerencias que se dispara mientras alguien escribe.

**Tareas:**

1. **Inventariar el universo real del vocabulario**, recontando cada cifra:
   - Páginas temáticas (`40_salidas/sitio_src/tema-*.qmd`): cuántas y con qué nombre canónico.
   - Términos del glosario (`20_insumos/curaduria/piezas/borradores/glosario.md`): cuántos, cuáles tienen fuente normativa y cuáles quedaron pendientes.
   - Encabezados de artículo con `id` en el sitio generado: cuántos, y cómo se distribuyen por norma.
   - Nombres y rótulos de las normas, incluidos los **alias históricos** (el caso conocido es "circular 482" contra "REX 482"; buscar exhaustivamente si hay otros, y decir con qué comando se buscó).
2. **Medir la cobertura del vocabulario contra el lenguaje real de las consultas.** No hay registro de consultas, así que la aproximación declarada es: extraer los términos de mayor frecuencia del corpus que **no** aparecen en el vocabulario y evaluar cuáles serían consultas plausibles. Declarar la aproximación como tal; no presentarla como dato de uso.
3. **Prototipo** `20260904_prototipo_vocabulario.R`: construye `lab_motor_v9/vocabulario.json` desde los artefactos existentes. Medir y reportar: número de entradas, peso del archivo en KB, peso comprimido con gzip, y tiempo de construcción.
4. **Especificar el contrato del JSON**: esquema de cada entrada (término, tipo, destino canónico, alias, peso), reglas de desambiguación y comportamiento ante prefijos de 1, 2 y 3 caracteres.
5. **Presupuesto de latencia en el navegador**: con el peso medido en el punto 3, estimar el costo de descarga en una conexión móvil de 3 Mbps y decidir si el índice se carga completo o por fragmentos. La estimación se declara como cálculo, no como medición.

**Criterio de éxito, con caso plantado:** el prototipo debe resolver correctamente estas cuatro consultas y las cuatro se prueban en el propio script, con su salida en el documento:
- `"celu"` debe sugerir el tema de uso de dispositivos móviles y la Ley 21.801.
- `"circular 482"` debe resolver al mismo destino que `"REX 482"`.
- `"mochila"` debe llegar al tema de revisión de pertenencias y a los dictámenes 065 y 078, con la marca de sustitución visible.
- `"xyzzy"` (término inexistente) debe devolver cero resultados. **Este es el control negativo, y su contraparte positiva es obligatoria:** mostrar en el mismo bloque que el instrumento sí devuelve resultados para un término conocido, o el cero no vale.

---

#### A2 — Capa 2: búsqueda semántica

**Objetivo:** decidir, con números medidos, si la recuperación semántica cabe en el navegador o exige servicio, y con qué granularidad.

**Tareas:**

1. **Dimensionar el corpus como unidad de recuperación.** Recontar artículos, y para cada uno medir el largo en caracteres y una estimación de tokens con la regla declarada que se use (declararla; no citar una regla de memoria como si fuera medición). Reportar mínimo, mediana, p90 y máximo, y cuántos artículos exceden una ventana de fragmento razonable.
2. **Decidir la unidad de fragmentación** (artículo completo, inciso, o ventana deslizante) y justificarla con la distribución medida en el punto 1, no con criterio general.
3. **Calcular el peso del índice de embeddings** para tres configuraciones de dimensionalidad, en float32 y en versión cuantizada, con la aritmética explícita. Contrastar contra el presupuesto de descarga de un sitio estático.
4. **Especificar la búsqueda híbrida, no elegir entre motores.** La decisión de §0bis es fusión, no reemplazo. Especificar: cómo se combinan el rango léxico y el rango vectorial, con qué método de fusión y qué parámetros; qué consultas debe ganar siempre la vía léxica (números de ley, números de artículo, nombres exactos de figuras jurídicas) y cómo se garantiza que la vía semántica no las degrade; y qué puntajes se conservan por resultado, que son el insumo de toda evaluación futura. Comparar las tres opciones de infraestructura (índice en el navegador, Vectorize, o Pagefind con expansión de sinónimos desde A1) por peso, latencia, costo, mantenimiento y qué se rompe si el corpus crece a 100 normas, **pero la comparación es de dónde vive el índice, no de si hay una o dos vías de recuperación**.

4bis. **Especificar el reranking.** Qué reordena los candidatos recuperados, con qué costo por consulta, y qué pasa si esa etapa no está disponible. Medir cuántos candidatos hay que recuperar antes de reordenar para que la respuesta correcta esté entre ellos: ese número sale de las diez consultas del punto 5, no de una convención.

4ter. **Especificar la dimensión temporal.** El corpus ya tiene `vigencia` y `sustituido_por` (sesión 1). Especificar cómo se filtra por vigencia a una fecha dada, qué devuelve "qué regía en 2021" frente a "qué rige hoy", y cómo se marca en los resultados una norma sustituida sin ocultarla, que sigue siendo referencia histórica. Verificar contra los datos reales cuántas normas del corpus tienen fecha suficiente para sostener este filtro; si son pocas, decirlo con la cifra.

4quater. **Especificar el tratamiento del OCR no revisado en la recuperación.** Cuántas unidades de recuperación provienen de texto sin firma (recuento propio, no la cifra heredada), y qué hace el motor con ellas: excluirlas, devolverlas marcadas, o devolverlas solo cuando no hay alternativa firmada. Recomendar una de las tres con su razón.
5. **Construir el conjunto de evaluación.** Diez consultas realistas de convivencia escolar redactadas en el lenguaje del equipo (no en el lenguaje de la ley), cada una con su respuesta correcta esperada identificada por ancla de artículo. Este conjunto es el entregable más valioso de A2: sin él, ninguna decisión posterior sobre semántica es verificable.
6. **Medir la línea base.** Correr esas diez consultas contra el Pagefind actual y reportar cuántas devuelven el artículo correcto entre los tres primeros resultados. Sin línea base no hay forma de saber si la semántica mejora algo. **Restricción dura de esta tarea:** se consulta el índice existente en `40_salidas/`, en modo lectura. Está prohibido correr `36_indexar_pagefind.R` o cualquier reindexación: regenerar el índice para medirlo cambia justamente lo que se está midiendo, y además escribe en una carpeta prohibida. Si el índice existente no se puede consultar sin regenerarlo, la tarea se declara NO MEDIDA y se reporta el impedimento.

**Criterio de éxito:** el documento permite decidir entre las tres arquitecturas sin volver a medir, y la línea base de Pagefind está reportada con las diez consultas y sus resultados, una por una.

---

#### A3 — Capa 3: orientación sobre cómo abordar un tema

**Objetivo:** diseñar la capa que el equipo pidió ("que oriente cómo documentar, abordar y responder") sin romper la compuerta de firma.

**Tareas:**

1. **Especificar la variante precalculada.** Una "ruta de abordaje" por tema: qué pregunta responde, qué artículos la fundan (por ancla), qué piezas interpretativas la acompañan, qué pasos sugiere y qué queda fuera de lo que la normativa resuelve. Definir el esquema de front matter, incluido el campo de firma, y verificar que el esquema propuesto **pasa la compuerta de firma vigente** leyendo el código real de la compuerta, no su documentación.
2. **Escribir una ruta de abordaje completa de ejemplo**, para un tema con normativa rica y no ambigua, con todas sus anclas resueltas contra el sitio generado. Verificar ancla por ancla que existe; una ruta con anclas rancias es exactamente el defecto que la compuerta de anclas abortó en el ensayo general.
3. **Especificar la variante en vivo.** Contrato del prompt del sistema: qué puede afirmar el modelo, qué debe citar, cómo se rotula la salida como no validada, y cómo se comporta ante una consulta que la normativa no resuelve. Incluir el formato exacto de la salida.
4. **Diseñar el arnés antialucinación.** Cómo se verifica programáticamente que toda cita de la salida corresponde a un ancla existente, y qué pasa cuando no. Esta verificación es del lado del cliente y no depende del modelo.
5. **Redactar seis casos adversariales** de consulta con su comportamiento esperado: una consulta fuera de dominio, una sobre normativa extranjera, una que pide consejo jurídico individual, una sobre una norma sustituida, una que induce a inventar un artículo inexistente, y una que pega datos de un estudiante real. Para la última, especificar la advertencia de interfaz y la regla de no pegar datos personales.

6. **Formalizar la capa experta como estructura de datos, no como prosa.** Cada entrada declara: el tema, las formas en que el equipo pregunta por él (que no son las palabras de la ley), qué debe considerarse siempre al abordarlo, los documentos prioritarios por ancla, y la firma. Escribir el esquema y **tres entradas completas y verificadas**, no una. Verificar que el esquema pasa la compuerta de firma real. Esta es la pieza que convierte la consulta en una búsqueda informada antes de recuperar nada, y es lo que distingue este motor de un RAG sobre PDFs.

7. **Especificar la separación en cuatro niveles y su marca visual.** Fuente primaria (lo que dice la norma), pronunciamiento oficial (cómo la interpreta una autoridad), orientación experta (cómo el equipo recomienda abordarlo) e inferencia del modelo (la conclusión generada). Nunca se mezclan en una misma línea de salida. Verificar qué insignias existen ya en `30_procesamiento/34_plantillas_sitio/estilo.css` y cuáles faltan; el nivel 4 es el que hoy no tiene marca y es el único que la compuerta no cubre porque todavía no existe.

8. **Decidir sobre la ontología de relaciones, sin ampliarla por decreto.** Hoy hay cuatro tipos derivados de metadatos. Evaluar, uno por uno, qué tipos adicionales del diseño externo (modifica, deroga, complementa, reglamenta, interpreta, desarrolla) son **derivables programáticamente** desde los metadatos y el texto ya disponibles, y cuáles exigirían un juicio jurídico. Los primeros se proponen con su regla de derivación y su recuento estimado; los segundos se rechazan por escrito. `contradice` es el caso de prueba: si algún agente lo propone, debe exhibir la regla determinística que lo produce o descartarlo.

9. **Especificar la descomposición de preguntas complejas como opción, con su costo.** Cuántas llamadas adicionales implica, cuánto suma al costo por consulta según los precios que mida A4, y qué gana en las diez consultas de evaluación de A2. Entra al diseño solo si el documento muestra la ganancia; si no se puede medir, se declara como no evaluada y no se recomienda.

**Criterio de éxito:** la variante precalculada es implementable sin decisiones abiertas, y la variante en vivo tiene su prompt y su arnés escritos, no descritos.

---

#### A4 — Arquitectura Cloudflare

**Objetivo:** cerrar la viabilidad técnica y de costo con datos verificados contra la documentación oficial, no contra artículos de terceros.

**Tareas:**

1. **Verificar contra `developers.cloudflare.com` y `www.cloudflare.com`**, citando la URL de cada dato: límites del plan gratuito de Workers (solicitudes diarias, CPU por invocación, subrequests por solicitud, tamaño del Worker), límites del plan gratuito de Zero Trust y Access (número de usuarios, retención de logs, métodos de identidad disponibles), y límites gratuitos de Vectorize y Workers AI.
2. **Resolver la pregunta abierta del diseño:** ¿puede Access proteger un subdominio `workers.dev`, o exige un dominio propio en una zona de Cloudflare? Responder con la cita de la documentación. Si la documentación no lo dice explícitamente, decirlo y proponer el experimento que lo zanjaría, en vez de inferirlo.
3. **Verificar que el consumo de CPU del proxy cabe en el límite gratuito.** El punto fino: el tiempo de espera de una llamada saliente no cuenta como CPU. Confirmarlo contra la documentación y citar dónde lo dice. Si el modelo responde en streaming, verificar además si el paso a través del Worker altera esa contabilidad.
4. **Calcular el costo real de operación** de la capa 3 en vivo, que es de la API del modelo y no de Cloudflare: costo por consulta según el tamaño de contexto que el diseño de A3 implica, y costo mensual para tres escenarios de uso declarados (bajo, medio, alto), con la aritmética visible y el precio citado desde `docs.claude.com` o `www.anthropic.com`.
5. **Especificar el Worker**: rutas, manejo del secreto, límite de tasa por usuario, política de CORS contra el origen de GitHub Pages, y qué se registra y qué no. Incluir el diagrama de despliegue en texto: qué queda en GitHub Pages, qué en Cloudflare, y por dónde viaja cada solicitud.
6. **Declarar el plan de degradación**: qué ve el usuario cuando el Worker no responde, cuando se agota la cuota diaria, y cuando la API devuelve error. La capa 1 debe seguir funcionando en los tres casos.

7. **Verificar qué es y qué soporta hoy Cloudflare AI Search**, citando documentación oficial: si ofrece búsqueda híbrida administrada, con qué método de fusión, si incluye reranking, qué filtros por metadatos admite, y qué parte de eso está en el plan gratuito. El diseño externo lo da por sentado; aquí entra como hipótesis hasta que la cita exista. Si no se puede verificar, se declara no verificado.

8. **Justificar el stack mínimo, no el máximo.** Para cada componente propuesto por el diseño externo (D1, R2, Vectorize, AI Search, Workers AI), responder con números del corpus real medidos por A2: qué problema resuelve que no se resuelva con un archivo estático servido desde GitHub Pages, a partir de qué tamaño de corpus empieza a pagarse solo, y qué costo de mantenimiento agrega. **Un componente que no pasa esa prueba se descarta explícitamente en el documento.** Para 25 normas, 682 artículos y 552 relaciones, la hipótesis por defecto es que casi todo cabe estático y el Worker existe solo para custodiar la clave de la API; refutarla con datos si corresponde, pero refutarla, no ignorarla.

**Criterio de éxito:** cada límite citado tiene su URL oficial; ningún número proviene de un blog de terceros; la pregunta de `workers.dev` queda respondida o explícitamente declarada como no resuelta con su experimento.

---

#### A5 — Panel adversarial

**Objetivo:** intentar derribar el diseño. A5 **no propone**; ataca.

**Restricción de método:** A5 no lee los documentos de A1 a A4 mientras los escriben. Recibe el encuadre de §0 y las tareas de A1 a A4, y construye sus ataques desde ahí. En la fase 2 contrasta sus ataques contra los documentos ya escritos.

**Tareas:**

1. **Enumerar los modos de falla del producto**, no del código: qué pasa cuando el motor sugiere el artículo equivocado con confianza; cuando la normativa cambia y el índice no; cuando la consulta correcta se hace con las palabras equivocadas; cuando el equipo empieza a confiar en la salida no validada como si estuviera validada.
2. **Atacar el invariante de firma.** ¿Existe algún camino por el cual contenido no validado termine indistinguible de contenido validado a los ojos de quien lee? Recorrerlo concretamente sobre el diseño propuesto.
3. **Atacar la premisa de la capa 1.** ¿Qué fracción de las consultas plausibles del equipo *no* está cubierta por un vocabulario derivado del corpus? El corpus habla en lenguaje legal; el equipo no.
4. **Cuestionar el orden de construcción.** Si solo se pudiera construir una capa, ¿cuál entrega más valor por unidad de esfuerzo? Responder con argumento, no con preferencia.
5. **Identificar qué de este encargo es sobreingeniería** para un ejercicio académico, y decirlo con nombre y apellido. Blancos concretos: el stack de cinco servicios de Cloudflare frente a un corpus de 682 unidades, la descomposición de preguntas en subpreguntas, y el reranking. Si alguno no se justifica, decirlo aunque esté adoptado en §0bis.

6. **Atacar las adopciones de §0bis.** Esa sección fija decisiones tomadas sin medición previa. A5 es el único agente autorizado a impugnarlas, y debe intentarlo con al menos tres: si la búsqueda híbrida vale su complejidad en un corpus tan chico; si la capa experta estructurada sobrevive al hecho de que hay 0 piezas validadas hoy; y si la separación en cuatro niveles se sostiene cuando el usuario copia y pega la respuesta fuera del sitio, donde ninguna insignia viaja con el texto.

**Criterio de éxito:** al menos un hallazgo que obligue a cambiar el diseño, o la declaración explícita y argumentada de que no lo hay. Un panel que confirma todo no corrió.

---

### FASE 2 — Auditoría independiente (agente AUD, secuencial, después de que los cinco terminen)

**Regla que gobierna esta fase:** la auditoría **no corrige lo que audita**. Hallazgo y corrección viven en tareas distintas (regla aprendida 8 de la sesión 2). AUD escribe hallazgos y congela; la corrección es de la fase 3 y la ejecutan los autores.

AUD no participó en la fase 1 y no reutiliza el razonamiento de ningún autor. Re-deriva desde los artefactos.

**Tareas:**

1. **Re-derivar toda cifra** de los cinco documentos contra los artefactos del repositorio, de forma independiente. Reportar cada cifra como confirmada, refutada o no verificable, con el comando usado en cada caso.
2. **Verificar toda ancla** citada en cualquiera de los documentos contra el sitio generado. Una ancla que no resuelve es un hallazgo bloqueante.
3. **Cazar enunciados universales sin comando** ("todos", "ninguno", "siempre", "cualquier") y exigir el comando o la acotación.
4. **Cazar ceros sin control positivo.** Cada cero reportado debe tener su control al lado.
5. **Verificar que las citas a documentación externa resuelven** a la URL declarada y dicen lo que el documento afirma que dicen.
6. **Cruzar autorizaciones contra escrituras reales**: `git diff --stat` de la fase 1 contra la tabla de §2. Cualquier archivo escrito fuera de la lista es un hallazgo bloqueante.
7. **Buscar contradicciones entre documentos.** A2 y A4 pueden haber decidido cosas incompatibles sobre dónde vive el índice; A3 y A5 sobre el rotulado. Enumerarlas.
8. **Correr el control positivo de la propia auditoría:** plantar un error conocido (una cifra falsa en un archivo desechable de `lab_motor_v9/`) y demostrar que el procedimiento de auditoría lo detecta. Una auditoría que no se prueba a sí misma no distingue "no hay errores" de "no busqué".

**Clasificación de hallazgos:** bloqueante (impide usar el documento), mayor (cambia una conclusión), menor (precisión), mejorable (calidad sin error). Los cuatro niveles se corrigen en la fase 3; los "mejorable" que se decidan no corregir se declaran con su razón.

---

### FASE 3 — Corrección (los autores, en paralelo)

Cada autor corrige **su propio** archivo contra los hallazgos que le corresponden. Nadie edita el archivo de otro. Cada corrección se anota en el log con el número de hallazgo, el cambio y su verificación.

**Segunda pasada de AUD, acotada:** re-verificar solo los hallazgos bloqueantes y mayores, y confirmar que la corrección no introdujo un defecto nuevo. Si un hallazgo sigue abierto después de la corrección, se declara abierto en la síntesis; no se cierra por cansancio.

---

### FASE 4 — Síntesis (agente SINT)

Escribe `20260904_alcance_motor_busqueda_sintesis_v1.md`, que es el único documento que el Área de Monitoreo va a leer completo. Contiene:

1. **Decisión recomendada por capa**, con su razón en una línea y su costo estimado.
2. **Orden de construcción propuesto**, con el criterio que lo ordena.
3. **Lo que quedó sin resolver**, con la medición pendiente que lo resolvería.
4. **Los hallazgos del panel adversarial que cambiaron el diseño**, nombrados.
5. **Lo que este encargo declara fuera de alcance** y por qué.
6. **Una tabla de todas las cifras** del paquete, cada una con su comando de origen.

**Prohibido en la síntesis:** repetir el contenido de los documentos de fase 1. La síntesis decide y remite; no resume.

---

## 6. Coordinación y manejo de conflictos entre agentes

- Un agente que detecta un error en el trabajo de otro **no lo corrige**: lo reporta al orquestador, que lo enruta como hallazgo a la fase 3.
- Si dos agentes llegan a conclusiones incompatibles, **ninguno cede por cortesía**. La contradicción se documenta en la síntesis con ambos argumentos y su evidencia, y se resuelve midiendo o se declara abierta.
- El orquestador no promedia opiniones ni fabrica consenso.

---

## 7. Log (entregable de primera clase)

`50_documentacion/andamios/logs/20260904_alcance_motor_busqueda_v9_log.md`, escrito **durante** la ejecución, no reconstruido al final. Secciones obligatorias:

1. **FASE 0:** salida literal de las cuatro precondiciones, con el hash de partida.
2. **Por agente:** qué hizo, qué comandos corrió (literales), qué midió, qué decidió y qué dejó fuera. Cada cifra con su comando al lado.
3. **Controles positivos:** todos, con su salida literal. Incluido el de la auditoría.
4. **Hallazgos de auditoría:** tabla completa con clasificación, y su estado tras la fase 3.
5. **Correcciones:** una fila por corrección, con hallazgo, cambio y verificación.
6. **Invariantes verificados al cierre:** `20_insumos/` sin cambios (`git diff --stat` sobre esa ruta debe ser vacío, con el comando pegado), `40_salidas/` sin cambios, ningún archivo escrito fuera de la tabla de §2.
7. **Delegaciones ejercidas:** ninguna esperada. Si alguna fue necesaria, no se ejerce: se detiene el encargo y se reporta.
8. **Errores del propio ejecutor:** todo error cometido durante la ejecución, con la regla que violó y cómo se corrigió. Esta sección vacía es sospechosa y debe justificarse.
9. **Residuos declarados:** lo que no se midió, lo que se estimó, y lo que se decidió no hacer, cada uno con su razón.
10. **Commits:** hash y mensaje de cada uno, con `git rev-parse HEAD origin/main` al final.

---

## 8. Reglas de detención

Detenerse y reportar, sin continuar, si:

- Alguna precondición de §1 falla.
- Una tarea exige escribir fuera de la tabla de §2.
- Una tarea exige una delegación de escritura en `20_insumos/`.
- Una verificación exige red hacia un dominio no autorizado.
- Se detecta que una premisa del encargo es falsa (por ejemplo, que un artefacto que se da por existente no existe). En ese caso **no se improvisa un sustituto**: se reporta la contradicción, como se hizo con la T3 congelada del encargo v1.

Un aborto por regla de detención es información, no fracaso.

---

## 9. Formato del reporte final en el chat de Claude Code

1. Veredicto de las precondiciones.
2. Una línea por agente con lo que produjo.
3. Recuento de hallazgos por clasificación y cuántos quedaron abiertos.
4. La decisión recomendada por capa, en tres líneas.
5. Hashes de los commits y `git rev-parse HEAD origin/main`.
6. Estado de CI del último despliegue, verificado por `head_sha`.

Nada más. El detalle vive en el log.
