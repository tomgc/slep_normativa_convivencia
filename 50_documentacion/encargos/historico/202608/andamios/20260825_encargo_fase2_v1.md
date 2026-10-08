# Encargo autónomo — Fase 2 de `slep_normativa_convivencia` (v1)

> Patrón: `encargo_autonomo_claude_code_v1.md` (v1.3). Continúa el bootstrap
> (`20260825_bootstrap_log.md`) y la sesión de OCR y curaduría
> (`20260825_ocr_curaduria_log.md`). Alcance fijado por
> `50_documentacion/activa/decisiones/20260825_decision_funcionalidad_sitio.md`.
> Incluye, fusionado como T1, el encargo puntual de la compuerta de
> `00_ocr_documentos.R --rehacer` que no llegó a enviarse.

---

## 1. Encabezado de contrato

**Modo y disciplina:** modo autónomo, secuencial, todo en este turno.
**No se admiten subagentes.**

**Meta:** dejar el sitio con la fase 2 funcional: compuerta que protege las
correcciones humanas del OCR, flujo de incorporación de normas nuevas por
manifiesto, dictamen 78/2026 incorporado, campo `vigencia` operando (065
sustituido por 078), recomendador de artículos relacionados por metadatos,
páginas temáticas que cruzan las fuentes por tema, y la infraestructura de
piezas interpretativas (fichas resumen, FAQ, glosario) con sus borradores
generados pero NO publicados hasta validación del equipo de convivencia.

**Regla de detención (lista medible):**

1. Si `git status --porcelain` no está vacío o `git rev-parse HEAD` difiere
   de `git ls-remote origin main` tras `git fetch`, detén la sesión: estado
   no previsto del repositorio.
2. Si el conteo de PDFs en `20_insumos/normativa/` no es 25 (los 24 del
   corpus + el dictamen 78/2026 que el equipo declaró depositado), congela
   T3 y sus descendientes (T4, T5, T6) y sigue con T1 y T7; no proceses un
   corpus distinto del declarado.
3. Si el PDF del dictamen 78 no tiene capa de texto (menos de 500
   caracteres alfabéticos), NO le apliques OCR (no está autorizado en este
   encargo): congela T3 y descendientes, registra la duda y sigue.
4. Si `20_insumos/curaduria/metadatos_curados.json` no valida contra su
   esquema actual o algún `origen_texto` sale del dominio
   {capa_texto_pdf, ocr_pendiente_revision, ocr_revisado}, detén la sesión:
   la capa de curaduría es la fuente de verdad del estado de revisión.
5. Si una pieza interpretativa (ficha, FAQ, glosario) apareciera publicada
   en el sitio sin `validado_por` no nulo, la fase que la produjo FALLA:
   corrige antes de commitear; si no puedes, congela esa tarea.
6. Cualquier estado, conteo o resultado no enumerado en este encargo →
   congela ESTA tarea, regístrala como duda (log §8) y sigue con la
   próxima tarea independiente.

**Autorizaciones explícitas (lista cerrada):**

- `mkdir -p` dentro de `/Users/tomgc/Projects/slep_normativa_convivencia/`.
- Renombrar el PDF del dictamen 78 dentro de `20_insumos/normativa/` al
  nombre canónico de §5-T3, solo tras verificar md5 antes = después de la
  copia en el mismo turno.
- Copias de respaldo hacia `_archivo/YYYYMMDD/` (fuera de Git).
- `git add <rutas explícitas>` (nunca `git add -A` ni `git add .`),
  `git commit`, `git push origin main` (autorizado para esta cadena;
  el proyecto sigue en fase de constructor único).
- `npx pagefind` y `npm ci` locales al proyecto.
- Instalación de paquetes R vía `instalar_si_falta()`.
- Nada más. En particular: ningún `rm` sobre `20_insumos/`, ningún OCR
  nuevo, ninguna edición de PDFs ni de páginas OCR transcritas.

**Reglas canónicas heredadas:** `CLAUDE.md` (raíz), POLITICA y SETTINGS en
disco según la decisión de no versionarlos. R exclusivo, pipe nativo,
dplyr `.by=`, `here::here()`. Commits atómicos por fase, grep de privacidad
antes de cada commit, sin coautoría.

**Contrato de entorno:**

1. **ENTORNO:** filesystem local del titular vía Claude Code, macOS.
2. **INSUMOS:** todo vive en el repo:
   `20_insumos/normativa/` (25 PDFs, hipótesis, se mide en FASE 0),
   `20_insumos/ocr/` (75 páginas transcritas, hipótesis, se mide en FASE 0),
   `20_insumos/curaduria/metadatos_curados.json` (hipótesis, se mide en
   FASE 0), decisión funcional en
   `50_documentacion/activa/decisiones/20260825_decision_funcionalidad_sitio.md`
   (hipótesis, se mide en FASE 0). Nada llega "aparte".
3. **POSICIÓN:** rutas completas desde
   `/Users/tomgc/Projects/slep_normativa_convivencia/`; ningún comando
   asume `cd` previo; scripts de shell bajo `bash` explícito. Primera
   acción: `git fetch` y comparación de refs local vs `origin/main`.

---

## 2. Estado de partida (premisas marcadas)

- HEAD local y `origin/main` en `d58986b`, worktree limpio (fuente:
  reporte de cierre de la sesión OCR leído por el equipo; se re-mide en
  FASE 0, condición de detención 1).
- El corpus tiene 24 PDFs con suma de conjunto
  `c1a2bdac9f0f5da37745f03ac5f53076` (fuente: log
  `20260825_ocr_curaduria_log.md` §6; se re-mide en FASE 0).
- El equipo depositó el PDF del Dictamen N°78/2026 de la Superintendencia
  en `20_insumos/normativa/` (fuente: confirmación del equipo en el turno
  de este encargo; nombre y capa de texto se miden en FASE 0).
- `origen_texto` vale `capa_texto_pdf` en 20 documentos y
  `ocr_pendiente_revision` en 4 (fuente: log OCR §6; se re-mide).
- El dictamen 065 está sustituido por el 78/2026 y hoy lo declara una
  banda escrita ad hoc (fuente: log OCR §6; T4 la reemplaza por el
  mecanismo genérico de `vigencia`).
- `00_ocr_documentos.R --rehacer` regenera transcripciones sin compuerta
  que proteja correcciones humanas (fuente: log OCR §9; T1 la agrega).
- Los 3 dictámenes tienen año curado; los 4 OCR siguen sin `titulo` ni
  `anio` (fuente: log OCR §§6-8; se re-mide en FASE 0).

---

## 3. Contexto mínimo suficiente

Sitio público de normativa de convivencia (Quarto + Pagefind en GitHub
Pages, pipeline R en 5 pasos, todo `40_salidas/` regenerable por
`00_run_all.R`). La unidad de recuperación es el artículo. La capa de
curaduría (`20_insumos/curaduria/`) es de escritura humana exclusiva. Los
invariantes de contenido del proyecto están en la decisión funcional del
2026-08-25 y son ley para este encargo.

---

## 4. Invariantes (🔒)

- 🔒 **Regla canónica del equipo:** todo lo que se muestra declara su tipo
  de fuente; el texto normativo se cita textual, con "leer en contexto";
  solo derecho chileno en la capa normativa.
- 🔒 **Nada interpretativo publicado sin `validado_por`.** Fichas, FAQ y
  glosario se generan como borradores en
  `20_insumos/curaduria/piezas/borradores/` y el generador del sitio SOLO
  publica piezas con `validado_por` y `fecha_validacion` no nulos.
- 🔒 **Las relaciones del recomendador son datos, no generación libre.**
  Cada relación tiene tipo declarado (tema compartido / remisión textual /
  sustitución) y su explicación se compone por plantilla desde ese tipo.
- 🔒 **PDFs y transcripciones OCR read-only para el pipeline.** Ningún
  script escribe en `20_insumos/ocr/` salvo `00_ocr_documentos.R` bajo las
  reglas de T1, ni en `metadatos_curados.json` jamás.
- 🔒 **Anclas públicas estables.** Ningún id `art-*` ni URL existente
  cambia. Lo nuevo agrega, no renombra.
- 🔒 **Reproducibilidad:** `run_all()` sigue regenerando todo `40_salidas/`
  desde `20_insumos/` sin pasos manuales.

---

## 5. Cadena de tareas y fases

**Grafo de dependencias:** T1 independiente. T2 requiere FASE 0. T3
requiere T2. T4 requiere T3. T5 requiere T3. T6 requiere T5. T7
independiente de T2-T6 (solo requiere FASE 0). T8 requiere todo lo no
congelado. Una tarea congelada arrastra solo a sus descendientes.

### FASE 0 — Mediciones (sin modificar nada)

| # | Medición | Valor esperado |
|---|---|---|
| 0.1 | `git fetch` + refs local vs `origin/main`; `git status --porcelain` | iguales; vacío |
| 0.2 | Conteo de PDFs en `20_insumos/normativa/` | 25 |
| 0.3 | md5 del conjunto de los 24 PDFs originales | `c1a2bdac9f0f5da37745f03ac5f53076` |
| 0.4 | Identificar el PDF del dictamen 78 por su nombre real; `pdf_text()` sobre él | ≥ 500 caracteres alfabéticos (si no: detención 3) |
| 0.5 | Validación de `metadatos_curados.json` y dominio de `origen_texto` | 20/4/0 según premisas |
| 0.6 | Conteo de páginas en `20_insumos/ocr/` | 75 |
| 0.7 | `jq` sobre catálogo: normas 24, artículos 682, sin año 4 | valores citados |

### T1 — Compuerta de `--rehacer` (fusiona el encargo puntual pendiente)

1. Regla: para cada documento, `--rehacer` ABORTA si (a) su estado en
   `metadatos_curados.json` es `ocr_revisado`, o (b) algún
   `pagina_NNN.txt` difiere del hash registrado en el manifiesto de su
   generación original (señal de corrección humana). El aborto lista qué
   documento y qué condición lo bloqueó.
2. `--forzar <slug>` explícito, por documento, es la única forma de pasar
   la compuerta; antes de regenerar copia las páginas actuales a
   `_archivo/YYYYMMDD/ocr_<slug>/`.
3. El manifiesto de generación gana los hashes por página si aún no los
   tiene, sin tocar el contenido de las páginas.

**Criterio de éxito calibrado (con caso plantado, obligatorio):** editar
una palabra en una copia temporal del flujo (o en una página real,
restaurándola por md5 en el mismo turno), correr `--rehacer` y verificar el
aborto (caso malo dispara); sobre páginas intactas y estado no revisado,
`--rehacer` procede (caso bueno calla); `--forzar` deja el respaldo en
`_archivo/` (verificar existencia y md5). Commit
`feat: compuerta de proteccion de correcciones ocr`.

### T2 — Manifiesto de incorporación de normas

1. `30_procesamiento/30_manifiesto_corpus.R` (o integrado al paso 31, a tu
   criterio, registrado en el log): manifiesto por hash de cada PDF de
   `20_insumos/normativa/`. En cada corrida, clasifica: sin cambio /
   nuevo / modificado, procesa SOLO nuevos y modificados, y reporta al
   final qué entró y qué metadatos quedan pendientes de curación (tema
   revisable, ficha, relaciones).
2. El manifiesto vive en `40_salidas/` (derivado, regenerable); la
   curaduría sigue en su archivo humano.
3. Documentar el flujo en el README: "dejar el PDF con nombre canónico y
   correr `00_run_all.R`".

**Criterio de éxito calibrado:** con corpus sin cambios, la corrida marca
25/0/0 y el pipeline completo sigue regenerando idéntico (md5 de
`catalogo.json` estable entre dos corridas seguidas); caso malo plantado:
tocar la fecha de un PDF no dispara (el hash manda), alterar un byte de una
COPIA registrada como corpus de prueba en `/tmp` sí dispara "modificado".
Commit `feat: manifiesto de incorporacion del corpus`.

### T3 — Incorporación del dictamen 78/2026

1. Renombrar al canónico `dictamen_078_detectores_revision_mochilas.pdf`
   (si el nombre real difiere, resolver por número de norma y registrar).
2. Dejar que el flujo de T2 lo detecte como nuevo y lo procese completo
   (extracción, segmentación, catálogo, página, índice de búsqueda).
3. Curar en `metadatos_curados.json`: año 2026, tema(s) coherentes con el
   065 (seguridad escolar / revisión de pertenencias), y la relación de
   sustitución 078 → 065 con procedencia "verificación web del asistente,
   2026-08-25 (Boletín Jurídico OLR; sustituye al Dictamen N°65)". El
   título se extrae del propio texto si la estructura es inequívoca; si
   no, `null` + marca de revisión (no inventar).

**Criterio de éxito:** catálogo pasa a 25 normas; búsqueda de "detectores"
devuelve el 078; su ficha muestra badge de fuente y año. Calibración: el
conteo esperado (25) se declara antes de correr; un valor distinto detiene.
Commit `feat: dictamen 78/2026 incorporado`.

### T4 — Campo `vigencia` en el esquema

1. Esquema de norma gana `vigencia`: `vigente` (default) o
   `sustituido_por: <slug>`, con procedencia obligatoria en la curaduría.
2. `dictamen_065` pasa a `sustituido_por: dictamen_078_...`; la banda ad
   hoc se reemplaza por la banda genérica del mecanismo, que enlaza a la
   norma sustituta; la norma sustituta muestra el vínculo inverso
   ("sustituye a…").
3. El índice y los resultados de búsqueda marcan visualmente lo sustituido.

**Criterio de éxito:** `jq` cuenta 1 norma sustituida y 24 vigentes; el
HTML del 065 contiene la banda genérica con enlace al 078 y viceversa;
ninguna otra página cambió de ancla (diff de ids contra la corrida
anterior = 0 cambios). Commit `feat: vigencia de normas en esquema y sitio`.

### T5 — Relaciones y recomendador por metadatos

1. `30_procesamiento/3X_relaciones.R` genera
   `40_salidas/datos/relaciones.json` con tres tipos, cada uno medible:
   (a) **remisión textual**: la norma A menciona a la norma B del corpus
   (regex sobre número de norma, calibrada con control positivo y con un
   caso que NO debe disparar: el propio número de la norma A);
   (b) **tema compartido**: intersección de temas del diccionario;
   (c) **sustitución**: desde el campo `vigencia`.
2. Cada relación lleva su explicación por plantilla ("La ley X remite a la
   ley Y en su artículo Z", "Comparten temática: expulsiones",
   "Sustituido por…"). Nada generativo libre (🔒).
3. Bloque "Normas y artículos relacionados" al final de cada página de
   norma, DESPUÉS del articulado, con la explicación visible por ítem,
   orden: sustitución > remisión > tema.

**Criterio de éxito calibrado:** control positivo: la ley 20.536 debe
relacionarse con la LGE por remisión (modifica el DFL 2/2009 citando la
LGE) o, si la remisión textual no dispara, la ausencia se registra como
hallazgo, no se fuerza; control negativo: ninguna norma se relaciona
consigo misma (conteo = 0); toda relación mostrada existe en
`relaciones.json` (conteo HTML ≤ conteo JSON). Commit
`feat: relaciones y recomendador por metadatos`.

### T6 — Páginas temáticas

1. Una página por tema del diccionario (15 + los que aporte la curaduría),
   generada por el pipeline: qué dice cada fuente sobre el tema, agrupado
   por capa (leyes → decretos → circulares/REX → dictámenes), con
   extractos textuales anclados ("leer en contexto") y badges de fuente.
2. Índice de temas navegable desde el header, hermano del buscador.
3. Las normas sustituidas aparecen al final de su capa con su marca.

**Criterio de éxito:** nº de páginas temáticas = nº de temas con ≥ 1
norma; cada extracto enlaza a un ancla existente (verificación de enlaces:
0 rotos, medido igual que en el bootstrap); spot-check: la página TEA
contiene ley 21545 y circular 586. Commit `feat: paginas tematicas`.

### T7 — Infraestructura de piezas interpretativas (borradores)

1. Esquema de pieza en `20_insumos/curaduria/piezas/` con front matter
   obligatorio: `tipo` (ficha/faq/glosario), `estado`
   (borrador/validada), `validado_por: null`, `fecha_validacion: null`,
   `fuentes[]` (cada afirmación debe poder anclarse a un artículo).
2. El generador del sitio publica SOLO `estado: validada` con
   `validado_por` no nulo (🔒; detención 5).
3. Generar BORRADORES iniciales en `piezas/borradores/`, marcados
   `estado: borrador`: fichas resumen de las 9 leyes; 8-12 FAQ de casos
   reales derivadas de los temas del corpus (cada respuesta = extracto
   textual + ancla, sin interpretación más allá de ordenar); glosario con
   los términos definibles desde el corpus con cita al artículo que los
   define (p. ej. expulsión y cancelación de matrícula desde el dictamen
   52/77; deberes desde la LGE). Un término sin definición normativa en el
   corpus NO se define de memoria: queda listado como "pendiente de fuente".
4. README de curaduría: cómo valida el equipo de convivencia (editar
   `estado`, `validado_por`, fecha) y qué pasa al validar.

**Criterio de éxito calibrado:** con todos los borradores en
`estado: borrador`, el sitio publicado contiene 0 piezas interpretativas
(control que debe callar); cambiando UNA pieza a `validada` con
`validado_por` de prueba en una corrida local NO commiteada, aparece
exactamente 1 (control que debe disparar); revertir antes del commit y
verificar por `git status` que la curaduría quedó intacta. Commit
`feat: infraestructura de piezas interpretativas con borradores`.

### T8 — Cierre

1. `00_escanear_proyecto.R`; verificación de reproducibilidad (borrar
   `40_salidas/` y regenerar); re-derivación del push por `ls-remote`.
2. Log con plantilla fija en
   `50_documentacion/andamios/logs/20260825_fase2_log.md` (o fecha real),
   incluyendo la verificación de los 6 invariantes 🔒 con evidencia.
3. Grep de privacidad antes de cada commit de documentación.
4. Commit `docs: log de fase 2` + push.

---

## 6. Auto-auditoría antes de reportar

Riesgo principal: publicar interpretación sin validar o alterar anclas.
Re-derivaciones obligatorias con comandos distintos: conteo de piezas
publicadas por grep sobre el HTML final (no por la variable del
generador); estabilidad de anclas por diff de la lista de ids extraída del
HTML antes y después de la cadena; conteos de catálogo por `jq` fresco.

## 7. Reporte final al chat

Hashes por commit, tabla FASE 0, conteos (normas, artículos, relaciones
por tipo, páginas temáticas, borradores generados), veredicto de la
compuerta con su caso plantado, URL de la página temática TEA y de la
ficha del 065 sustituido, dudas congeladas, ruta del log, y "lo que falló
o sorprendió; si nada, decirlo explícitamente".

## 8. Exclusiones declaradas (con razón)

- Validación de piezas interpretativas: gate del equipo de convivencia
  por invariante; el encargo entrega borradores y mecanismo.
- Búsqueda semántica: fase 3 por decisión funcional.
- Capa de evidencia científica: fase 4, sesión de research aparte.
- Rediseño visual y auditoría mobile/AA: esperan el entregable de Claude
  Design (insumo inexistente).
- Revisión humana de las 75 páginas OCR: trabajo del equipo, no
  delegable a la herramienta.
