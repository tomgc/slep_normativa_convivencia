# Encargo autónomo — Bootstrap de `slep_normativa_convivencia` (v1)

> Patrón: `encargo_autonomo_claude_code_v1.md` (v1.3). Sesión NEW PROJECT,
> Rama A (proyecto 100% público, POLITICA §8.2): leyes nacionales chilenas,
> sin datos personales.

---

## 1. Encabezado de contrato

**Modo y disciplina:** modo autónomo, secuencial, todo en este turno.
**No se admiten subagentes.**

**Meta:** dejar el repositorio con estructura canónica Rama A, los PDFs
normalizados en `20_insumos/normativa/`, un pipeline R que extrae y segmenta
las normas por artículo en JSON, un sitio Quarto mínimo (home + una página
por norma con artículos anclados + índices) con búsqueda Pagefind a nivel de
artículo, y despliegue a GitHub Pages vía GitHub Actions.

**Regla de detención (lista medible):**

1. Si `ls` de `normativa/` no arroja 24 archivos PDF, detén FASE 0 y
   reporta el listado real; no ajustes la meta al número encontrado.
2. Si `pdftools::pdf_text()` sobre la muestra de FASE 0 devuelve texto
   vacío o basura (menos de 500 caracteres alfabéticos en un PDF de ley),
   congela la rama de extracción (T3 en adelante) y registra la norma
   afectada como duda; continúa con las demás normas.
3. Si `git remote get-url origin` no devuelve
   `https://github.com/tomgc/slep_normativa_convivencia.git` (o su forma
   SSH equivalente), detén la sesión: repositorio equivocado.
4. Si el worktree contiene archivos no previstos en este encargo (algo
   distinto de `normativa/` y artefactos de sistema como `.DS_Store`),
   congela T1 y reporta el inventario antes de crear estructura.
5. Cualquier estado, conteo o resultado no enumerado en este encargo →
   congela ESTA tarea, regístrala como duda (log §8) y sigue con la
   próxima tarea independiente.

**Autorizaciones explícitas (lista cerrada):**

- `mkdir -p` dentro de `/Users/tomgc/Projects/slep_normativa_convivencia/`.
- `mv` de los PDFs desde `normativa/` a `20_insumos/normativa/` con los
  nombres nuevos de la tabla §5.2, solo tras verificar md5 origen = destino
  por archivo en el mismo turno (copiar, comparar, luego eliminar origen).
- `rm -d normativa/` solo cuando quede vacía tras el paso anterior.
- `rm` de `482 REGLAMENTOS.pdf` SOLO si su md5 es idéntico al de
  `22.  REX 482 INSTRUCCIONES REGLAMENTOS.pdf`, medido en el mismo turno.
  Si difieren, conservar ambos y registrar duda.
- `git init`, `git add <rutas explícitas>` (nunca `git add -A` ni
  `git add .`), `git commit`, `git push origin main`. El push directo a
  `main` está autorizado SOLO para este encargo de bootstrap.
- `gh api` de solo-configuración para habilitar GitHub Pages con fuente
  "GitHub Actions". Si `gh` no está autenticado, congela T7 y deja el paso
  como pendiente manual del equipo.
- `npm install`/`npx` únicamente para Pagefind, local al proyecto.
- Instalación de paquetes R vía `instalar_si_falta()`.
- Nada más.

**Reglas canónicas heredadas:** `CLAUDE.md` (raíz del repo tras T1),
`POLITICA_PROYECTO.md` y `SETTINGS_Y_PROMPTS_OPERACIONALES.md` (van a
`50_documentacion/activa/` en T1). R exclusivo para el pipeline; bash/YAML
auxiliares. Pipe nativo `|>`, dplyr >= 1.1 con `.by=`, `here::here()` en
todo script. Commits atómicos por fase, sin coautoría de la herramienta.

**Contrato de entorno:**

1. **ENTORNO:** filesystem local del titular vía Claude Code, macOS.
2. **INSUMOS:** los 24 PDFs en
   `/Users/tomgc/Projects/slep_normativa_convivencia/normativa/`
   (hipótesis, se mide en FASE 0). Este encargo es autocontenido: no hay
   archivos que lleguen "aparte".
3. **POSICIÓN:** toda ruta completa desde
   `/Users/tomgc/Projects/slep_normativa_convivencia/`; ningún comando
   asume `cd` previo. Los scripts de shell corren bajo `bash` explícito,
   nunca el shell interactivo del titular. El repo remoto existe y está
   vacío (hipótesis, se mide en FASE 0 con `git ls-remote`); antes de
   cualquier push, `git fetch` y comparación de refs.

---

## 2. Estado de partida (premisas marcadas)

- El directorio del proyecto existe en
  `/Users/tomgc/Projects/slep_normativa_convivencia/` (fuente: mensaje del
  equipo en este turno; se re-mide en FASE 0).
- Contiene una carpeta `normativa/` con 24 PDFs, dos de ellos posiblemente
  duplicados (`22.  REX 482 INSTRUCCIONES REGLAMENTOS.pdf` y
  `482 REGLAMENTOS.pdf`) (hipótesis, se mide en FASE 0 con `ls` y md5).
- El remoto `https://github.com/tomgc/slep_normativa_convivencia.git` existe,
  es público y está vacío (hipótesis, se mide en FASE 0).
- `git`, `quarto`, `node`/`npx`, `gh` y R están disponibles en la máquina
  (hipótesis, se mide en FASE 0; cada ausencia congela solo las tareas que
  la requieren).
- Los PDFs tienen capa de texto extraíble (hipótesis, se mide en FASE 0
  sobre una muestra de 3 y en T3 sobre el total).
- No existe aún estructura canónica ni git local (hipótesis, se mide en
  FASE 0 con `ls -la` y `git status`).

---

## 3. Contexto mínimo suficiente

Biblioteca pública de normativa de convivencia educativa para el equipo de
convivencia del SLEP Costa Central. Sitio estático en GitHub Pages, sin
backend: la búsqueda corre 100% en el navegador. Arquitectura por capas:
`20_insumos/normativa/` (PDFs, read-only) → `30_procesamiento/` (extracción,
segmentación, generación de páginas) → `40_salidas/` (JSON estructurado +
sitio renderizado). El corpus se indexa a nivel de ARTÍCULO, no de
documento: la unidad de recuperación que el equipo necesita es "ley X,
artículo Y". Fase 2 futura (fuera de este encargo): embeddings
precalculados para búsqueda semántica.

---

## 4. Invariantes (🔒)

- 🔒 **Los PDFs son read-only.** Nunca se editan ni se regeneran; el
  pipeline solo los lee. Razón: son la fuente legal de verdad.
- 🔒 **Ningún dato personal entra al repo.** Si un PDF resultara contener
  datos de personas naturales (no se espera: son normas publicadas),
  congelar su procesamiento y registrar duda. Razón: repo público.
- 🔒 **El texto extraído no se "corrige" editorialmente.** Limpieza
  permitida: guiones de corte de línea, saltos, encabezados/pies de página
  repetidos. Prohibido: parafrasear, resumir o alterar el texto legal.
  Razón: fidelidad normativa; un resumen alterado en un sitio institucional
  es un riesgo jurídico.
- 🔒 **Reproducibilidad:** `00_run_all.R` regenera todo `40_salidas/` desde
  `20_insumos/` sin pasos manuales.
- 🔒 **Gobernanza de commits:** rutas explícitas, sin `git add -A`, sin
  coautoría de herramienta, grep de privacidad antes de cada commit de
  documentación (POLITICA §6).

---

## 5. Cadena de tareas y fases

**Grafo de dependencias:** T1 requiere FASE 0. T2 requiere T1. T3 requiere
T2. T4 requiere T3. T5 requiere T4. T6 requiere T4 (no requiere T5). T7
requiere T6. T8 (log y escáner) requiere todo lo no congelado. Una tarea
congelada arrastra solo a sus descendientes.

### FASE 0 — Mediciones (sin modificar nada)

Cada medición con valor esperado; discrepancia → regla de detención §1.

| # | Comando | Valor esperado |
|---|---|---|
| 0.1 | `ls -la /Users/tomgc/Projects/slep_normativa_convivencia/` | solo `normativa/` (+ residuos de sistema) |
| 0.2 | `ls /Users/tomgc/Projects/slep_normativa_convivencia/normativa/ \| wc -l` | 24 |
| 0.3 | `md5 "…/normativa/22.  REX 482 INSTRUCCIONES REGLAMENTOS.pdf" "…/normativa/482 REGLAMENTOS.pdf"` | hashes; decide la autorización de `rm` |
| 0.4 | `git ls-remote https://github.com/tomgc/slep_normativa_convivencia.git` | salida vacía (repo sin refs) |
| 0.5 | `quarto --version`, `node --version`, `npx --version`, `gh auth status`, `Rscript --version` | versiones; ausencia congela la tarea dependiente |
| 0.6 | `Rscript` con `pdftools::pdf_text()` sobre 3 PDFs (una ley, un decreto, un dictamen) | ≥ 500 caracteres alfabéticos por documento |
| 0.7 | En la misma muestra, `grep` programático del patrón `Art[íi]culo\s+\d+` | ≥ 1 coincidencia por documento con articulado; los dictámenes/circulares pueden dar 0 (se registra, no detiene) |

### T1 — Scaffold Rama A + primer commit

1. Crear estructura canónica completa (POLITICA §1.1) incluidas
   `20_insumos/` y `40_salidas/` en el repo.
2. `00_run_all.R` (stub funcional), `00_escanear_proyecto.R`,
   `10_utils/10_utils.R` (bootstrapping con `instalar_si_falta`, `log_msg`),
   `10_utils/10_configuracion.R` (rutas vía `here::here()`, sin data root
   externo), guarda `asegurar_locale_utf8()` en el punto de arranque y
   marcador `50_documentacion/activa/50_locale_utf8.md`.
3. `.gitignore` estándar SIN bloque de datos (Rama A) + exclusiones de
   sitio: `/.quarto/`, `node_modules/`, `_archivo/`, `.DS_Store`.
4. Copiar a `50_documentacion/activa/`: `POLITICA_PROYECTO.md`,
   `SETTINGS_Y_PROMPTS_OPERACIONALES.md`; `CLAUDE.md` a la raíz. Si estas
   copias no están disponibles en la máquina, congelar SOLO este paso como
   pendiente manual (el equipo las depositará) y continuar.
5. `README.md` mínimo: qué es, estructura, cómo regenerar, aviso de que el
   contenido normativo proviene de fuentes oficiales.
6. Commit `feat: estructura canónica rama A` + push (tras 0.4 verificado).

**Criterio de éxito:** `git status --porcelain` vacío tras el push;
`tree -L 2` coincide con la estructura canónica. Calibración: el criterio
dispara si falta cualquiera de las carpetas de decena (probar removiendo
mentalmente una en el check: el conteo esperado de decenas es 5).

### T2 — Normalización de insumos

Mover cada PDF a `20_insumos/normativa/` con esta tabla exacta (origen →
destino). Verificación por archivo: md5 antes y después.

| Origen (en `normativa/`) | Destino (en `20_insumos/normativa/`) |
|---|---|
| `01. 20370 LGE.pdf` | `ley_20370_general_educacion.pdf` |
| `02. 20536 VIOLENCIA ESCOLAR.pdf` | `ley_20536_violencia_escolar.pdf` |
| `03. 20845 INCLUSION SEP.pdf` | `ley_20845_inclusion_escolar.pdf` |
| `04. 20911 FORMACIÓN CIUDADANA.pdf` | `ley_20911_formacion_ciudadana.pdf` |
| `05. 19979 JEC.pdf` | `ley_19979_jornada_escolar_completa.pdf` |
| `06. 21545 LEY TEA.pdf` | `ley_21545_tea.pdf` |
| `07. 21430 PROTECCIÓN Y DERECHOS NIÑEZ.pdf` | `ley_21430_garantias_ninez.pdf` |
| `08. 21801 CELULARES.pdf` | `ley_21801_celulares.pdf` |
| `23. 21809 LEY DE CONVIVENCIA.pdf` | `ley_21809_convivencia_educativa.pdf` |
| `09. DLF 315 PÉRDIDA RO.pdf` | `dfl_315_perdida_reconocimiento_oficial.pdf` |
| `10. DFL 1 MINEDUC ESTATUTO ASISTENTES.pdf` | `dfl_1_estatuto_asistentes_educacion.pdf` |
| `11. DTO 215 UNIFORME.pdf` | `dto_215_uniforme_escolar.pdf` |
| `12. DTO 24 CONSEJOS ESCOLARES.pdf` | `dto_24_consejos_escolares.pdf` |
| `13. DTO 453 ESTATUTO PROFESIONALES DE LA EDUCACION.pdf` | `dto_453_estatuto_docente.pdf` |
| `14. DTO 565 CGPMA.pdf` | `dto_565_centros_padres_apoderados.pdf` |
| `15. CIRULAR 193 EMBARAZOS.pdf` | `circular_193_estudiantes_embarazadas.pdf` |
| `16. CIRCULAR 586 LEY TEA.pdf` | `circular_586_tea.pdf` |
| `17. CIRCULAR 812 IDENTIDAD DE GÉNERO.pdf` | `circular_812_identidad_genero.pdf` |
| `18. REX 181 CELULARES.pdf` | `rex_181_celulares.pdf` |
| `22.  REX 482 INSTRUCCIONES REGLAMENTOS.pdf` | `rex_482_instrucciones_reglamentos_internos.pdf` |
| `19. DICTÁMENES 52 Y 77 EXPULSION.pdf` | `dictamen_52_77_expulsion.pdf` |
| `20. DICTÁMEN 065 REVISIÓN DE MOCHILAS.pdf` | `dictamen_065_revision_mochilas.pdf` |
| `21. DICTÁMEN 71 EXPULSIONES Y CANCELACIONES DE MATRÍCULA.pdf` | `dictamen_71_expulsion_cancelacion_matricula.pdf` |
| `482 REGLAMENTOS.pdf` | duplicado presunto: ver autorización §1; si difiere, `rex_482_reglamentos_b.pdf` + duda |

Los nombres de origen se transcriben del listado del equipo (fuente:
mensaje del equipo en este turno); si un nombre real difiere en espacios o
tildes, resolver por coincidencia de número de norma y registrar la
discrepancia. Antes de mover: imprimir el plan completo origen → destino
(pasada de solo impresión); la lista impresa es lo autorizado.

Depositar `20_insumos/normativa/README.md` con la tabla de equivalencias
(nombre original → nombre canónico) y la excepción declarada de POLITICA
§1.2.4 invertida: aquí los insumos SÍ se renombran, por decisión del equipo
(sesión 2026-08-25).

Commit `feat: insumos normalizados` + push.

**Criterio de éxito:** 23 o 24 PDFs en destino (según resultado del md5 del
duplicado), 0 archivos restantes en `normativa/`, suma de md5 del conjunto
origen = suma del conjunto destino (calibración: el criterio dispara si un
archivo se corrompe o se pierde en el `mv`; se calibra con un md5 recalculado
sobre 1 archivo control antes y después).

### T3 — Extracción y segmentación por artículo

1. `30_procesamiento/31_extraer_texto.R`: `pdftools::pdf_text()` por PDF →
   texto plano limpio (unir cortes de línea con guion, colapsar espacios,
   remover encabezados repetidos por página detectados programáticamente).
   Validez de lectura: `stopifnot(nchar(texto_total) > 0)` por documento y
   conteo de páginas leído = `pdftools::pdf_info()$pages`.
2. `30_procesamiento/32_segmentar_articulos.R`: segmentación por regex de
   articulado (`Artículo N`, `Artículo N bis/ter`, transitorios). Documentos
   sin articulado (circulares, dictámenes, REX) se segmentan por secciones
   numeradas si existen; si no, quedan como documento único con `articulo =
   NA`. Salida: `40_salidas/datos/normas/<slug>.json` con
   `{slug, tipo, numero, titulo, anio, tema[], articulos[{id, etiqueta,
   texto}]}`.
3. `40_salidas/datos/catalogo.json`: catálogo maestro con metadatos por
   norma. `tipo`, `numero` y `slug` se derivan del nombre canónico del
   archivo (fuente que los gobierna tras T2); `titulo`, `anio` y `tema[]`
   se extraen del propio texto cuando sea posible; lo no extraíble queda
   `null` con marca `# REVISAR` en el JSON de trabajo y duda en el log
   (no inventar años ni títulos).
4. Integrar 31 y 32 a `00_run_all.R`.

Commit `feat: pipeline extraccion y segmentacion` + push.

**Criterios de éxito calibrados:**

- Conteo programático: nº de JSON = nº de PDFs procesados; cada ley con
  patrón `Artículo` en 0.7 produce ≥ 5 artículos. Calibración caso malo:
  correr el segmentador sobre un texto sin la palabra "Artículo" debe dar 0
  segmentos (control positivo del instrumento); caso bueno: la muestra de
  0.6/0.7.
- Spot-check 1:1: para 2 normas, comparar el texto del artículo 1 del JSON
  contra la primera página del PDF renderizada; coincidencia literal módulo
  espacios.
- "0 documentos fallidos" solo se reporta si el detector de fallas dispara
  sobre un caso plantado (un PDF de prueba vacío generado en `/tmp`).

### T4 — Sitio Quarto mínimo

1. `_quarto.yml` en raíz; fuentes qmd GENERADAS por
   `30_procesamiento/33_generar_paginas.R` en `40_salidas/sitio_src/`
   (nunca editadas a mano), render a `40_salidas/sitio/`. Ajustes finos de
   configuración Quarto: decisión autónoma, registrada en el log.
2. Páginas: home con propósito y buscador; una página por norma (metadatos
   + artículos con anclas `#art-N`); índices por tipo de norma, por año y
   por tema; página "acerca de" institucional (sin firmas personales).
3. Español como idioma del sitio (`lang: es`).

Commit `feat: sitio quarto minimo` + push.

**Criterio de éxito:** `quarto render` sale con código 0; nº de páginas de
norma generadas = nº de JSON; un ancla `#art-1` verificada por grep en el
HTML de 2 normas. Calibración: el check de conteo dispara si se elimina un
qmd generado (probar en seco con el conteo esperado declarado antes del
render).

### T5 — Búsqueda Pagefind (requiere T4; independiente de T6)

1. `npx pagefind --site 40_salidas/sitio` post-render, integrado al final
   de `00_run_all.R` (llamada `system2` documentada en una línea).
2. Indexación a nivel de artículo: marcar cada artículo en el HTML con
   `data-pagefind-body` o atributos de sección para que el resultado apunte
   al ancla del artículo, no solo a la página.
3. UI de Pagefind en la home y en el header del sitio.

Commit `feat: busqueda pagefind` + push.

**Criterio de éxito:** el índice existe (`40_salidas/sitio/pagefind/`);
búsqueda de un término plantado y único (insertar temporalmente un token de
control en un artículo, indexar, buscar, encontrar, retirar el token y
reindexar) demuestra que el instrumento encuentra lo que existe; una
búsqueda de un término real ("expulsión") devuelve ≥ 1 resultado apuntando
a un dictamen.

### T6 — Despliegue GitHub Actions → Pages (requiere T4)

1. `.github/workflows/publicar.yml`: en push a `main`, setup R + Quarto +
   Node, correr `00_run_all.R`, render, Pagefind, publicar
   `40_salidas/sitio/` a Pages (acción oficial de Pages). Explicación de
   una línea por bloque YAML no obvio. `LANG` UTF-8 en el workflow
   (POLITICA §5.2bis).
2. Habilitar Pages con fuente "GitHub Actions" vía `gh api`; si no hay
   auth, pendiente manual.

Commit `ci: despliegue a github pages` + push.

**Criterio de éxito:** corrida del workflow en verde
(`gh run list --limit 1`) y `curl -s -o /dev/null -w "%{http_code}"
https://tomgc.github.io/slep_normativa_convivencia/` = 200. Si el 200
tarda por propagación, reintentar 3 veces con espera; si persiste ≠ 200,
duda, no falla silenciosa.

### T7 — Habilitación Pages (si quedó pendiente de T6.2)

Solo si `gh` estaba autenticado y T6 no lo resolvió. Si no, instrucción
manual de una línea en el reporte final.

### T8 — Escáner, log y cierre

1. Correr `00_escanear_proyecto.R`.
2. Log honesto con plantilla fija (§4 del patrón) en
   `50_documentacion/andamios/logs/20260825_bootstrap_log.md`: resumen,
   inventario de commits, cambios sustantivos, bugs, invariantes 🔒 con
   PASA/FALLA y evidencia, decisiones autónomas con alternativa descartada
   y reversibilidad, dudas como pendientes accionables (pregunta cerrada),
   estado de cifras (md5 del corpus), notas al revisor.
3. Grep de privacidad y coautoría antes del commit de documentación.
4. Commit `docs: log de bootstrap` + push.

---

## 6. Auto-auditoría antes de reportar

Sin riesgo de datos sensibles: aplica el principio general, no el panel.
Re-derivación con comandos distintos: el push se confirma con
`git ls-remote origin main` contra el hash local, no con el mensaje de git;
el conteo de artículos se re-deriva leyendo los JSON con `jq` (o R), no
reutilizando la variable del pipeline; el sitio se verifica abriendo el
HTML renderizado, no asumiendo el exit code.

## 7. Reporte final al chat

Hashes de todos los commits, tabla de verificaciones con evidencia,
conteos (PDFs, JSON, artículos totales, páginas), URL del sitio, veredicto
del duplicado 482, ruta del log, dudas congeladas, y "lo que falló o
sorprendió; si nada, decirlo explícitamente".

## 8. Exclusiones declaradas (backlog, no entran a esta cadena)

- Búsqueda semántica con embeddings: decisión de diseño pendiente de la
  entrevista de funcionalidad (gate de usuario).
- Sintetizador por ley, recomendador de artículos relacionados, sección de
  literatura científica: misma razón (entrevista pendiente).
- Diseño visual del sitio: llegará desde Claude Design (insumo inexistente
  hoy).
- Ordenación del repositorio (§4.7 de SETTINGS): no aplica a un repo recién
  nacido.
