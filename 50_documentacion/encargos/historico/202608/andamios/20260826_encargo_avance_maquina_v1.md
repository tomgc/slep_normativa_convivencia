# Encargo autónomo — avance de máquina (vía B), sesión 2

Proyecto: `slep_normativa_convivencia`. Patrón: `encargo_autonomo_claude_code_v1.md` (v1.3). Redactado por el asistente de análisis; ejecuta Claude Code.

## 1. Contrato

- **Modo:** autónomo, secuencial, todo en este turno. Subagentes: se admiten SOLO de solo-lectura para el panel adversarial de T1, tope duro 2.
- **ENTORNO:** filesystem local vía Claude Code, raíz `~/Projects/slep_normativa_convivencia`, macOS, R 4.5.2, Quarto 1.9.38 (fuente: traspaso_cierre_v01.md §1, leído por el redactor en esta sesión de chat).
- **INSUMOS:** todos por ruta desde la raíz del repositorio; ninguno se adjunta. Claves: `40_salidas/datos/relaciones.json` (hipótesis, se mide en FASE 0), `20_insumos/curaduria/metadatos_curados.json`, `20_insumos/curaduria/piezas/borradores/glosario.md`, `20_insumos/ocr/`, `.github/workflows/publicar.yml`, `10_utils/10_utils.R`, `30_procesamiento/33_relaciones.R`, `30_procesamiento/34_generar_paginas.R`, `CLAUDE.md`.
- **POSICIÓN:** toda ruta completa desde la raíz; ningún comando asume `cd` previo ni estado heredado; los scripts corren bajo `bash` explícito o `Rscript`, nunca el shell interactivo del titular. Primera acción de FASE 0: `git fetch` y comparación de `HEAD` local contra `origin/main` antes de operar.

### Regla de detención (lista medible)

1. Si `git status --porcelain` no sale vacío al inicio → detén la SESIÓN (worktree sucio no previsto).
2. Si `50_documentacion/activa/ESTADO.md` no existe o no contiene `sesion_abierta: true` → detén la SESIÓN (el candado de esta sesión debió quedar tomado en el turno anterior).
3. Si el conteo de descartes difiere de 88 o el de relaciones de 550 → congela T1, registra la duda (log 4.8); no ajustes la meta al número encontrado.
4. Si la sonda web de FASE 0 falla contra los dominios oficiales → congela T1 y T5, sigue con T2-T4.
5. Si el conteo de páginas OCR difiere de 75 en 4 carpetas → congela T4, registra la duda.
6. Si `grep -c 'pendiente de fuente' 20_insumos/curaduria/piezas/borradores/glosario.md` difiere de 5 → congela T5, registra la duda con el valor real.
7. Si cualquier verificación posterior a un cambio de T2 o T3 falla (render, CI local, conteos) → congela esa tarea, revierte SOLO con la autorización listada abajo.
8. Cualquier estado, conteo o resultado no enumerado en este encargo → congela ESTA tarea, regístrala como duda (4.8) y sigue con la próxima tarea independiente.

### Autorizaciones (lista cerrada)

- Escribir y modificar archivos SOLO en: `30_procesamiento/`, `10_utils/`, `.github/workflows/publicar.yml`, `40_salidas/` (solo vía regeneración por pipeline), `50_documentacion/andamios/` y `50_documentacion/andamios/logs/`.
- `Rscript 00_run_all.R` (o los pasos 33-36 individualmente) para regenerar salidas tras T2.
- `git add <rutas explícitas>` (nunca `git add .`), un commit atómico por tarea completada, `git push` al final de la cadena, condicionado a que toda verificación intermedia haya pasado.
- `git checkout -- <ruta>` SOLO para revertir una tarea congelada por la condición 7, únicamente sobre los archivos que esa tarea tocó, con la lista impresa antes de ejecutar.
- Lectura web (WebFetch/WebSearch) SOLO sobre bcn.cl, leychile.cl, supereduc.cl, diariooficial.interior.gob.cl y comunidadescolar.cl, solo lectura.
- Nada más.

### Reglas canónicas heredadas (referencia, no copia)

`CLAUDE.md` §10 (convenciones duras, `grupos_acto`); instrucciones del traspaso v01 §12, en particular: ⚠️ ningún script escribe en `20_insumos/curaduria/` ni `20_insumos/ocr/`; ⚠️ nada editado a mano en `40_salidas/`; ✅ antes de tocar el derivador, el diff de `relaciones.json` se re-deriva y los descartes/supresiones quedan registrados; 🔒 cita textual, trazabilidad por badge, solo derecho chileno, anclas públicas estables, reproducibilidad de `40_salidas/`.

## 2. Estado de partida (premisas marcadas)

- 550 relaciones vigentes y 88 descartes registrados en `40_salidas/datos/relaciones.json`, campo `descartadas` (hipótesis, se mide en FASE 0).
- Los descartes provienen del filtro de año en remisiones: candidatos cuyo año no calzó con ninguna norma del corpus (fuente: traspaso_cierre_v01.md §4.6 y §4.8, leído por el redactor).
- El grupo `grupo_acto` REX 482 tiene 2 slugs declarados en curaduría y sus rótulos visibles son idénticos porque `nombre_de()` no distingue resolución de cuerpo (hipótesis, se mide en FASE 0 localizando `nombre_de` y los dos slugs).
- El workflow de CI usa actions sobre Node 20 con aviso de deprecación (hipótesis, se mide en FASE 0 con grep de versiones en `.github/workflows/publicar.yml`).
- Existen 75 archivos `pagina_*.txt` en 4 carpetas de `20_insumos/ocr/` (hipótesis, se mide en FASE 0; el traspaso declara 84 páginas/5 documentos y la diferencia ya está registrada como inconsistencia de cifra: no la resuelvas, solo repórtala si el conteo difiere de 75).
- El glosario tiene 5 términos marcados "pendiente de fuente" (hipótesis, se mide en FASE 0).
- Hay acceso web de solo lectura a los dominios autorizados (hipótesis, se mide en FASE 0 con una sonda a bcn.cl).
- `ESTADO.md` existe con `sesion_abierta: true` (hipótesis, se mide en FASE 0; es condición de detención 2).

## 3. Contexto mínimo

Biblioteca pública de normativa de convivencia educativa (25 normas, 682 artículos), sitio Quarto+Pagefind publicado por CI en GitHub Pages. Fase 2 completa. Esta sesión avanza SOLO lo que no requiere firma humana ni el entregable de diseño: análisis, propuestas y dos fixes técnicos menores. Nada de lo que produzcas cambia estados de validación.

## 4. Invariantes (🔒)

- 🔒 Ningún estado `ocr_revisado` se cierra, ningún tema se aprueba, ninguna pieza interpretativa se publica: la firma humana es el invariante, no un trámite.
- 🔒 `20_insumos/curaduria/` y `20_insumos/ocr/` son de escritura humana exclusiva: tus propuestas van a `50_documentacion/andamios/`, jamás a esas rutas.
- 🔒 `40_salidas/` solo cambia por regeneración del pipeline.
- 🔒 Toda cifra reportada se recuenta programáticamente en el turno que la reporta.

## 5. Cadena de tareas y grafo de dependencias

Grafo: T1, T2, T3, T4 y T5 son mutuamente independientes; todas requieren FASE 0. Una tarea congelada no detiene a las demás. Orden de ejecución sugerido (determinista antes que convergente): T3 → T2 → T4 → T1 → T5.

### FASE 0 — Medición de hipótesis (sin modificar nada)

1. `git fetch`; comparar `HEAD` local vs `origin/main`; `git status --porcelain` vacío.
2. `cat 50_documentacion/activa/ESTADO.md` → contiene `sesion_abierta: true`.
3. Conteo programático (R o jq) de relaciones y descartes en `40_salidas/datos/relaciones.json` → 550 y 88.
4. `grep -rn 'nombre_de' 10_utils/ 30_procesamiento/ | head` y localización de los slugs `rex_482_*` en `20_insumos/curaduria/metadatos_curados.json`.
5. `grep -n 'node-version\|actions/' .github/workflows/publicar.yml`.
6. `find 20_insumos/ocr -name 'pagina_*.txt' | wc -l` → 75; `ls 20_insumos/ocr/` → 4 carpetas + manifiesto.
7. `grep -c 'pendiente de fuente' 20_insumos/curaduria/piezas/borradores/glosario.md` → 5 (si el marcador literal difiere, primero localiza el marcador real en el archivo y reporta cuál es).
8. Sonda web: fetch de una página de bcn.cl → responde.
Cada medición: valor esperado arriba; discrepancia → rama de detención correspondiente.

### T3 — Node 22 en CI (pendiente 12 del traspaso)

- Paso 0: leer `.github/workflows/publicar.yml` completo.
- Actualizar las versiones de actions/Node que emiten el aviso de deprecación a sus versiones vigentes (verifica las vigentes en la documentación oficial de cada action si la web está disponible; si no, usa la mayor versión estable referenciada en el propio marketplace de GitHub vía fetch, y si tampoco, congela T3).
- Verificación (condiciona el commit): el YAML parsea (`ruby -ryaml` o `python3 -c` NO están autorizados como stack: usa `Rscript -e 'yaml::read_yaml(".github/workflows/publicar.yml")'`); diff mínimo (solo líneas de versión).
- Criterio de éxito: diff contiene únicamente cambios de versión; calibración: el criterio dispara si el diff toca cualquier otra clave (caso malo: cámbiale mentalmente un nombre de job; debe fallar) y calla sobre el diff limpio.
- Commit atómico: `fix(ci): actions a Node 22, elimina aviso de deprecación`. La verificación real del workflow en verde queda para el push final; repórtalo como verificación diferida.

### T2 — Rótulos distintivos del grupo REX 482 (pendiente 6)

- Paso 0: leer la función `nombre_de()` (donde esté) y cómo consumen los rótulos `34_generar_paginas.R` y las plantillas.
- Implementar distinción de rótulo para miembros de un `grupo_acto` (p. ej. sufijo derivado del rol declarado en curaduría: la fuente del rol es la declaración de `grupos_acto`, no el basename del archivo — identidad desde la fuente, nunca compuesta desde un nombre).
- Regenerar (`Rscript 00_run_all.R` o pasos 34-36) y verificar ANTES del commit: (a) los dos rótulos del grupo ya no son idénticos en el HTML final (grep sobre `40_salidas/sitio/`), (b) diff de `relaciones.json` vacío (T2 no toca el derivador), (c) conteo de enlaces internos sin rotos si el pipeline lo reporta.
- Calibración del criterio (a): caso malo conocido = el estado actual (dos rótulos idénticos) debe hacer fallar el chequeo antes del cambio; caso bueno = tras el cambio, calla. Ejecuta el chequeo en ambos momentos y reporta ambas salidas.
- Commit atómico: `fix(sitio): rotulos distintivos para miembros de grupo_acto`.

### T4 — Pre-revisión asistida del OCR (acelera, no reemplaza)

- Solo lectura sobre `20_insumos/ocr/`. Producto: `50_documentacion/andamios/20260826_prerevision_ocr_v1.md`.
- Contenido: (a) patrones de error sistemáticos detectados por documento (confusiones tipográficas frecuentes, líneas truncadas, membretes — el traspaso marca membretes como zona de arranque); (b) lista priorizada de líneas sospechosas por documento con ruta `carpeta/pagina_NNN.txt:línea` y motivo; (c) estadística simple por documento (páginas, líneas, % sospechosas).
- Método sugerido (decides tú los detectores concretos, en R): heurísticas léxicas contra español jurídico (caracteres imposibles, dígitos incrustados en palabras, mayúsculas intercaladas, líneas < N caracteres en medio de párrafo). Doble pasada de motores solo si hay un segundo motor disponible localmente sin instalar nada; si no, decláralo no disponible y sigue (no es condición de éxito).
- Control positivo obligatorio: planta en una COPIA temporal (fuera de `20_insumos/`) 3 errores típicos conocidos y demuestra que el detector los encuentra; y demuestra que calla sobre 3 líneas limpias elegidas. Sin control positivo, no reportes "0 sospechosas" en ningún documento.
- 🔒 Ningún archivo de `20_insumos/ocr/` se modifica; ningún estado cambia.
- Commit atómico: `docs(andamios): pre-revision asistida OCR v1`.

### T1 — Pre-clasificación de los 88 descartes de remisiones

- Paso 0: extraer los 88 descartes con sus campos (norma origen, referencia detectada, año, motivo de descarte).
- Para cada descarte, clasificar programáticamente en: (a) descarte correcto (la referencia apunta a una norma fuera del corpus o inexistente en derecho chileno), (b) homologable (la norma referida SÍ está en el corpus bajo otro año: candidata a `anios_alternativos`), (c) ambiguo (requiere decisión humana). La verificación contra fuentes oficiales usa los dominios autorizados; recuerda la regla aprendida del traspaso: el número de una norma chilena NO la identifica sin año.
- Producto: `50_documentacion/andamios/20260826_preclasificacion_descartes_v1.md` con tabla de 88 filas (id, clasificación, evidencia con URL o razón, acción propuesta). Las homologaciones son PROPUESTAS: la escritura de `anios_alternativos` en curaduría es humana (🔒).
- Calibración: el clasificador debe reproducir como "descarte correcto" al menos un caso conocido de la sesión 1 (las falsas remisiones dto_453→dto_215 vía notas BCN, si alguna quedó entre los 88) y como coherente una remisión vigente de las 44 aceptadas (control bueno). Si ningún caso conocido está entre los 88, planta uno sintético en una copia y demuestra que el instrumento clasifica.
- Panel adversarial (tope 2 subagentes solo-lectura): re-derivar con código propio el conteo 88 y un muestreo de 10 clasificaciones antes de reportar.
- Verificación de completitud: filas de la tabla == descartes leídos == 88 (validez de lectura atada a la fuente).
- Commit atómico: `docs(andamios): preclasificacion de 88 descartes v1`.

### T5 — Rastreo de fuentes de los 5 términos del glosario

- Paso 0: extraer del glosario los 5 términos y su contexto.
- Para cada término, rastrear en los dominios autorizados la norma chilena que lo define (tipo, número, año, artículo, URL oficial del texto). Producto: `50_documentacion/andamios/20260826_fuentes_glosario_v1.md` con tabla término / norma propuesta / artículo / URL / ¿ya en corpus? / PDF propuesto a incorporar.
- La incorporación de cualquier PDF nuevo es GATE del titular: propones, no descargas al corpus ni corres `run_all()` con normas nuevas.
- Criterio de éxito: 5 filas, cada una con norma identificada con año o "no hallada" con la búsqueda documentada; calibración: un término debe ser resoluble con certeza (caso bueno esperable); si los 5 salen "no hallada", trata el instrumento como sospechoso y repórtalo como fallo de método, no como resultado.
- Commit atómico: `docs(andamios): rastreo de fuentes del glosario v1`.

## 6. Auto-auditoría, log y reporte

- Auditoría según riesgo: T1 con panel adversarial (arriba); T2-T5 con re-derivación por comandos distintos de los que produjeron el resultado.
- Log de cierre en `50_documentacion/andamios/logs/20260826_avance_maquina_log.md` con la plantilla fija del patrón (secciones 1-10, incluidas decisiones autónomas con alternativa y reversibilidad, y dudas como pendiente accionable con pregunta cerrada). Commit `docs()` atómico del log.
- Push único al final de la cadena.
- Reporte al chat: hashes por commit, cada verificación con su evidencia, tareas congeladas con su duda, ruta del log, y "lo que falló o sorprendió; si nada, decirlo explícitamente".
