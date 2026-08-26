# Traspaso de cierre v01 — slep_normativa_convivencia

## 1. Identificación

Proyecto: `slep_normativa_convivencia` (biblioteca pública de normativa de
convivencia educativa, SLEP Costa Central). Versión v01, fecha 2026-08-26,
sesión 1 (fundacional). Foco: bootstrap completo del proyecto (estructura,
corpus, pipeline, sitio publicado) más fase 2 funcional (relaciones,
temáticas, piezas interpretativas) y ciclo de correcciones del derivador.
Entorno: Claude Code sobre macOS, R 4.5.2, Quarto 1.9.38, Pagefind,
GitHub Pages. Archivos principales: todo el repositorio nace en esta
sesión; los de mayor actividad fueron `30_procesamiento/31-36`,
`10_utils/`, `20_insumos/curaduria/`, `.github/workflows/publicar.yml`.

## 2. Resumen ejecutivo

La sesión creó el proyecto desde cero y lo dejó publicado y operativo. Se
propuso una biblioteca buscable de normativa de convivencia con citación
textual rigurosa; se logró: 25 normas procesadas en 682 artículos, sitio en
https://tomgc.github.io/slep_normativa_convivencia/ con búsqueda Pagefind a
nivel de artículo, facetas, 17 páginas temáticas, recomendador de
relaciones por metadatos (550 relaciones auditables), capa de curaduría
humana, OCR señalizado de 5 documentos y despliegue automático en CI. Las
piezas interpretativas (22 borradores: fichas, FAQ, glosario) existen pero
no se publican hasta validación del equipo de convivencia, por invariante.
Queda pendiente el trabajo humano (revisión de 84 páginas OCR, validación
de temas y borradores) y las fases 3 (búsqueda semántica) y 4 (evidencia
científica). Estado general: estable, publicado, sin bugs activos
conocidos.

## 3. Estado al cierre

Funciona (última ejecución exitosa en esta sesión, 2026-08-26): pipeline
completo `run_all()` regenerando `40_salidas/` desde cero; CI en verde
sobre `df7bdc2`; sitio HTTP 200; compuerta `--rehacer` con caso plantado;
manifiesto de incorporación 25/0/0; 1.169 enlaces internos, 0 rotos. No
funciona: nada conocido; único aviso, deprecación de Node 20 en las
actions (preexistente, no bloqueante). Delta respecto a v00: no existe
v00; todo es nuevo.

## 4. Registro detallado de cambios

El detalle técnico por cambio vive en los cinco logs de andamios de la
sesión; cada bloque los referencia en vez de duplicarlos.

1. **Bootstrap** (`20260825_bootstrap_log.md`): estructura canónica Rama A,
   normalización snake_case de 24 PDFs, extracción y segmentación por
   artículo, sitio Quarto, Pagefind por artículo, CI a Pages. Verificado
   con controles positivos plantados. Categoría: infraestructura_pipeline.
2. **Especificación funcional** (decisión
   `20260825_decision_funcionalidad_sitio.md`): entrevista al equipo
   convertida en invariantes de contenido (trazabilidad de fuente, cita
   textual, solo derecho chileno, validación de lo interpretativo) y fases
   1-4. Categoría: gobernanza_docs.
3. **OCR señalizado** (`20260825_ocr_curaduria_log.md`): 75 páginas de 4
   escaneados con Apple Vision, publicadas como transcripción rebajada
   (anclas por página, tipografía y banda propias, faceta `texto`), capa
   de curaduría de escritura humana exclusiva. Categoría: ocr_curaduria.
4. **Curaduría de metadatos**: años de dictámenes con procedencia
   declarada, nota 16 A-E en ley 20536, banda de vigencia del 065.
   Categoría: ocr_curaduria.
5. **Fase 2** (`20260825_fase2_log.md`): compuerta `--rehacer`, manifiesto
   de incorporación por hash, dictamen 78/2026 incorporado, campo
   `vigencia` (065 sustituido por 078 con bandas mutuas), 553 relaciones
   iniciales, 17 páginas temáticas, 22 borradores interpretativos con
   candado de publicación por `validado_por`. Categorías:
   relaciones_derivador, sitio_navegacion, contenido_interpretativo.
6. **Resolución de dudas de fase 2**
   (`20260825_resolucion_dudas_fase2_log.md`): 078 a transcripción por
   declaración de curaduría (`origen_texto` como anulación), filtro de año
   en remisiones (46 descartes registrados, nunca silenciosos),
   segmentación de dictámenes por numerales (resultó aditiva: 0 anclas
   rotas), glosario con 5 términos "pendiente de fuente". Categorías:
   relaciones_derivador, ocr_curaduria, contenido_interpretativo.
7. **Indagación pre-cierre**
   (`20260825_indagacion_pre_cierre.md`): auditoría de solo lectura que
   destapó 74 remisiones falsas publicadas (dto_453→dto_215 vía notas
   marginales BCN), la duplicidad de slugs del REX 482 y 34 asignaciones
   de tema frágiles. Categoría: relaciones_derivador.
8. **Fixes del derivador y grupo de acto**
   (`20260826_fixes_remision_grupo_acto_log.md`): forma `D.O. dd.mm.aaaa`
   con ventana 300 y corte por cabeza de nota; tipo `grupo_acto` declarado
   una vez en curaduría con roles derivados; remate que centraliza la
   supresión intra-grupo para todos los tipos presentes y futuros. Estado
   final: 550 relaciones (2 sustitución, 2 grupo_acto, 44 remisión, 502
   tema), 88 descartes registrados. Categoría: relaciones_derivador.
9. **Prompt de diseño para Claude Design**
   (`20260825_prompt_claude_design_v1.md`): brief entregado al equipo; el
   entregable visual aún no llega. Categoría: diseno_visual.

## 5. Backlog acumulativo

Primer cierre: el backlog nace en esta sesión como archivo independiente
en `50_documentacion/activa/backlog_acumulativo.md` (tramo 1→17). Ver ese
archivo; no se duplica aquí.

## 6. Bugs de la sesión

Los ocho con causa raíz y verificación viven en los logs de andamios
(numerados 1-7 más los tres de la resolución de dudas). Patrones generales
aprendidos, como reglas:

- Una huella de caché debe cubrir TODO lo que determina la salida del
  paso, incluidas declaraciones de curaduría, no solo los bytes del
  insumo (falló dos veces con la misma estructura: transcripción y
  `origen_texto`).
- Un filtro que reduce resultados debe registrar lo que descarta; si no,
  es indistinguible de un derivador que nunca los encontró.
- Los controles anti-duplicado por identidad de slug no ven identidades
  de fondo (dos slugs, un acto): la identidad se declara en curaduría.
- Palabras clave de tema producen falsos positivos convincentes
  ("trans" → transitorio); toda clasificación derivada necesita tabla de
  disparadores revisable por humanos.
- Quarto no limpia su directorio de salida: todo candado de publicación
  debe verificarse sobre el HTML final, no sobre los qmd generados.

Todos los bugs de la sesión: resueltos.

## 7. Aprendizajes y restricciones descubiertas

- La calibración con caso plantado atrapó los cinco defectos graves de la
  sesión; ninguna revisión de código lo hizo. Regla: ningún criterio de
  éxito sin su caso malo que dispare.
- Los PDFs de la BCN traen aparato de modificaciones como nota marginal
  intercalada al aplanar columnas; cualquier extractor posicional debe
  medir distancias reales antes de fijar ventanas (mediana 132, máx 230).
- El número de una norma chilena NO la identifica (homónimos por año y
  ministerio); toda remisión por número necesita el año o revisión.
- OCR: cuerpo confiable, membretes no; la revisión humana empieza por
  encabezados.

## 8. Decisiones de diseño

Las de peso arquitectónico están replicadas como archivo:
`20260825_decision_funcionalidad_sitio.md` (invariantes de contenido y
fases). Las operativas, con alternativas y reversibilidad, en las tablas
"Decisiones autónomas" de los logs de andamios (E1-E6 del OCR; D1 y
posteriores de fase 2). Las tres estructurales que gobiernan el futuro:
(1) curaduría humana en archivos que ningún script escribe, con
procedencia obligatoria por dato; (2) lo interpretativo se publica solo
validado; (3) relaciones como datos tipados con explicación por
plantilla, nunca generación libre.

## 9. Constantes y parámetros

| Constante | Valor anterior | Valor nuevo | Archivo | Motivo |
|---|---|---|---|---|
| ventana de año, forma `de AAAA` | — | 60 | `30_procesamiento/33_relaciones.R` | distancia en prosa |
| ventana de año, forma `D.O.` | — | 300 | mismo | nota marginal intercalada; 42/42 detectados, 360 no agrega |
| corte de ventana `D.O.` | — | cabeza de nota (tipo+número+coma) | mismo | proteger citas vecinas |

Fuente canónica de las vigentes: `10_utils/10_configuracion.R` y los
scripts `30_procesamiento/31-36`.

## 10. Arquitectura de archivos

Escáner regenerado en este cierre (ver salida de
`00_escanear_proyecto.R`). Estructura canónica Rama A sin desviaciones;
particularidad del proyecto: `20_insumos/curaduria/` como capa de
escritura humana exclusiva y `20_insumos/ocr/` como transcripciones
versionadas fuera del pipeline regenerable.

## 11. Pendientes y ruta sugerida

Inventario (tipo, impacto, complejidad, criterio de éxito):

1. **Revisión humana de 84 páginas OCR** (5 documentos). Tipo: bloqueante
   de contenido. Impacto: alto (desbloquea cita textual de circulares 193,
   586, 812, REX 482 cuerpo y dictamen 078; probablemente resuelve los 5
   términos del glosario). Complejidad: trabajo humano, flujo listo
   (README + compuerta protege correcciones). Precaución: empezar por
   membretes. Éxito: `origen_texto: ocr_revisado` con firma en curaduría.
2. **Validación de temas: 34 asignaciones frágiles** (tabla ⚠ en
   `20260825_indagacion_pre_cierre.md` §2). Tipo: bloqueante de calidad.
   Impacto: alto (sustenta páginas temáticas y 502 relaciones de tema).
   Complejidad: baja por asignación. Éxito: tabla revisada y curaduría
   corregida donde falle.
3. **Validación de los 22 borradores interpretativos** por el equipo de
   convivencia. Tipo: funcionalidad. Impacto: alto (activa fichas, FAQ y
   glosario). Éxito: primeras piezas con `validado_por` publicadas.
4. **Lectura de los 88 descartes de remisiones**
   (`relaciones.json`, campo `descartadas`). Tipo: deuda de calidad.
   Éxito: cada descarte confirmado u homologado vía `anios_alternativos`.
5. **Glosario: 5 términos pendientes de fuente.** Depende del pendiente 1
   o de incorporar la norma que los define. Tipo: funcionalidad.
6. **Rótulos idénticos de los slugs del grupo REX 482** (`nombre_de()`
   no distingue resolución de cuerpo). Tipo: mejora visual. Complejidad:
   baja.
7. **`dictamen_065` con 4 segmentos** (prosa continua; granularidad
   requeriría otro criterio y movería anclas). Tipo: deuda técnica
   aceptada; documentada, sin acción sugerida.
8. **Diseño visual**: aplicar el entregable de Claude Design cuando
   llegue (brief ya entregado). Tipo: mejora visual. Impacto: usabilidad.
9. **Fase 3: búsqueda semántica** (embeddings precalculados, similitud en
   navegador). Tipo: funcionalidad. Precaución: presentación siempre
   subordinada a la cita textual (invariante).
10. **Fase 4: capa de evidencia científica** (sesión de research aparte
    para el barrido inicial). Tipo: funcionalidad futura.
11. **Adoptar ESTADO.md (estándar Fase 2 de SETTINGS §2.1bis)** en el
    próximo cierre. Tipo: gobernanza. Este cierre lo declara
    `no adoptado`.
12. **Aviso de deprecación Node 20 en las actions.** Tipo: deuda técnica
    menor. Éxito: workflow sin el aviso.

Deuda técnica, zonas frágiles: el diccionario de temas por palabras clave
es la pieza con menor respaldo humano del sistema (principio en tensión:
clasificación derivada sin validación); la doble identidad del REX 482
está contenida por `grupos_acto` pero cualquier futura norma multiarchivo
debe declararse en el grupo al incorporarse.

Auditoría de cierre: sin respuestas "no".

Compuerta de dudas: vacío declarado (las dudas de la sesión se
resolvieron dentro de la sesión; constan en los logs).

Ruta sugerida para la sesión 2, con dos vías según disponibilidad del
equipo de convivencia:

**Vía A (con el equipo): sesión de validación humana, no de
construcción.** Bloque 1: revisar UN documento OCR completo de punta a
punta (sugerencia: circular 812 — corta, 10 páginas, alta demanda de
consulta) para estrenar el flujo `ocr_revisado` y detectar fricciones del
procedimiento antes de industrializarlo. Bloque 2: barrer la tabla de 34
temas frágiles (sí/no por fila). Bloque 3: validar y publicar las
primeras 3-5 piezas interpretativas. Criterio de éxito: primer documento
`ocr_revisado` y primeras piezas publicadas. Relleno: pendientes 4 y 6.

**Vía B (sin el equipo): encargo autónomo de avance de máquina.**
(1) Pre-clasificación programática de los 88 descartes contra fuentes
oficiales, dejando solo los ambiguos para decisión humana; (2) rótulos
distintivos del grupo REX 482; (3) actions a Node 22 y preparación de
ESTADO.md; (4) pre-revisión asistida del OCR: patrones de error
sistemáticos, doble pasada de motores y lista priorizada de líneas
sospechosas por documento (acelera la revisión humana, no la reemplaza
ni cambia estados); (5) rastreo en fuentes oficiales de las normas que
definen los 5 términos del glosario, proponiendo PDFs a incorporar.

Si el entregable de Claude Design llegó, se antepone como bloque propio
en cualquiera de las dos vías. Lo que NO admite avance de máquina en
ninguna vía: cerrar estados `ocr_revisado`, aprobar temas y publicar
piezas interpretativas — la firma humana es el invariante, no un
trámite. Diferir: fases 3 y 4 hasta que lo publicado tenga validación
humana (publicar interpretación sin validar por acelerar fases rompería
el invariante central).

## 12. Instrucciones específicas para la próxima sesión

- ⚠️ NO publicar ninguna pieza interpretativa sin `validado_por` y fecha
  en la curaduría.
- ⚠️ NO correr `00_ocr_documentos.R --rehacer` sin leer el aborto de la
  compuerta; `--forzar` solo con respaldo verificado en `_archivo/`.
- ⚠️ NO editar a mano nada en `40_salidas/` (se regenera) ni permitir que
  un script escriba en `20_insumos/curaduria/` o `20_insumos/ocr/`.
- ✅ ANTES de tocar el derivador de relaciones, verificar que el diff de
  `relaciones.json` se re-deriva y que los descartes/supresiones quedan
  registrados, no silenciados.
- ✅ ANTES de incorporar una norma nueva, nombre canónico snake_case y
  `run_all()`; si es multiarchivo, declarar `grupos_acto` en curaduría.
- 🔒 Cita textual, trazabilidad de fuente por badge, solo derecho chileno,
  anclas públicas estables, reproducibilidad de `40_salidas/`.

## 13. Fragmentos de código de referencia

Sin patrones sueltos que copiar: los patrones de la sesión (escritura
atómica, huella de manifiesto de tres componentes, compuerta con caso
plantado, supresión centralizada de relaciones) viven ejecutables en
`10_utils/10_utils.R` y `30_procesamiento/31-36`, y `CLAUDE.md` §10
documenta las convenciones duras (incluido `grupos_acto`).

## 14. Reapertura

Mensaje de apertura pre-armado para la sesión 2:

> Sesión CONTINUATION de `slep_normativa_convivencia`. El protocolo
> (POLITICA_PROYECTO.md y SETTINGS_Y_PROMPTS_OPERACIONALES.md) vive en la
> knowledge base y se lee desde ahí. Adjunto: `traspaso_cierre_v01.md`.
> Estado: sitio publicado y estable, 25 normas, fase 2 completa, 0 piezas
> interpretativas publicadas.
>
> **Certeza declarada al cierre de la sesión 1** (respuesta del asistente
> a la pregunta del equipo, transcrita para calibrar esta apertura): la
> certeza es alta pero estratificada, y es sobre la coherencia y
> calibración de la evidencia reportada, no sobre los bytes (el asistente
> no ejecutó nada en la máquina). Muy alta (95%+) en la disciplina del
> proceso: re-derivaciones independientes, casos plantados que
> dispararon, diffs exactos, y un sistema que atrapó sus propios errores
> cinco veces (duplicado 482, tema "trans", pieza fantasma de Quarto,
> remisiones falsas, huella incompleta) — instrumentos que funcionan, no
> suerte. Alta pero no total (85-90%) en el contenido derivado: las 550
> relaciones y los temas pasaron controles programáticos, pero 34
> asignaciones de tema son frágiles por diseño y nadie humano ha leído
> los 88 descartes. Sin certeza, deliberada y honestamente marcada: la
> fidelidad de las 84 páginas OCR (señalizadas, no citables) y la calidad
> de los 22 borradores interpretativos (0 publicados). Residuo
> irreducible: todo descansa en la fidelidad de los reportes de Claude
> Code, internamente consistentes entre sí y contra verificaciones web;
> la auditoría independiente real es del equipo, con el sitio delante. El
> riesgo residual mayor no es un bug: es que la validación humana se
> postergue y el sitio opere indefinidamente con su capa más útil sin
> respaldo del equipo de convivencia.
>
> Foco propuesto (ruta del traspaso §11): vía A si el equipo de
> convivencia está disponible — validar, no construir: un documento OCR
> completo de punta a punta (sugerencia: circular 812), la tabla de 34
> temas frágiles, y las primeras 3-5 piezas interpretativas publicadas.
> Vía B si no lo está — encargo autónomo de avance de máquina:
> pre-clasificar los 88 descartes, rótulos del grupo REX 482, Node 22 y
> ESTADO.md, pre-revisión asistida del OCR y rastreo de las normas que
> definen los 5 términos del glosario. El diseño de Claude Design se
> antepone si llegó. En ninguna vía se cierran estados `ocr_revisado`,
> se aprueban temas ni se publican piezas sin firma humana.

Documentos para la próxima sesión: (1) protocolo en knowledge base, no se
adjunta: `POLITICA_PROYECTO.md`, `SETTINGS_Y_PROMPTS_OPERACIONALES.md`;
(2) opcionales según foco: `CLAUDE.md` si corre Claude Code;
(3) específicos, sí se adjuntan: `traspaso_cierre_v01.md`; si el foco es
validación, además `20260825_indagacion_pre_cierre.md` (tabla de temas) y
el README de curaduría. El backlog y el escáner no se adjuntan. Nota: si
algún archivo listado cambió entre sesiones, adjuntar la versión más
actualizada y avisarlo al abrir.

## 15. Errores del asistente

| # | Desviación | Regla violada | Corrección | Estado |
|---|---|---|---|---|
| 1 | El asistente escribió "el encargo adjunto" en el mensaje para Claude Code, cuando el equipo nunca adjunta: todo artefacto vive en el repo y se refiere por ruta | Realidad operativa declarada por el equipo (settings de interacción) | Mensaje reescrito con ruta completa; regla incorporada al flujo de la sesión | Corregido en el turno siguiente |
