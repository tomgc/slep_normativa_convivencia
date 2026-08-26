# Encargo autónomo — auditoría contra producto e insumos de validación (v3), sesión 2

Proyecto: `slep_normativa_convivencia`. Patrón: `encargo_autonomo_claude_code_v1.md` (v1.3). Sucede a los encargos v1 y v2 dentro de la sesión 2. Propósito doble: (1) auditar CONTRA PRODUCTO todo lo reportado en esta sesión, re-derivándolo desde los artefactos y no desde los logs; (2) dejar corregidos los dos defectos conocidos y generados los insumos que la validación humana necesita.

## 1. Contrato

- **Modo:** autónomo, secuencial, todo en este turno. Subagentes: SOLO de solo-lectura para el panel adversarial de TA, tope duro 2. **Todo prompt de subagente declara: análisis en R o jq exclusivamente, Python prohibido (CLAUDE.md §7), sin escritura en el repositorio.**
- **ENTORNO:** filesystem local vía Claude Code, raíz `~/Projects/slep_normativa_convivencia`, macOS, R 4.5.2, Quarto 1.9.38 (fuente: logs de la sesión, leídos por el redactor).
- **INSUMOS:** por ruta desde la raíz. Claves: los tres logs/adendas de `50_documentacion/andamios/logs/`, `40_salidas/` completo, `20_insumos/curaduria/metadatos_curados.json` (solo lectura), `00_ocr_documentos.R`, `00_generar_borradores.R`, `30_procesamiento/`, `10_utils/10_utils.R`, `_quarto.yml` (o donde viva la configuración de publicación), `50_documentacion/andamios/20260826_pauta_validacion_convivencia_v1.md` y `50_documentacion/andamios/20260826_formato_cruce_referencia_instrumentos.md` (recién copiados por el titular), `CLAUDE.md`.
- **POSICIÓN:** rutas completas desde la raíz; scripts bajo `bash` explícito o `Rscript`; primera acción de FASE 0: `git fetch` y `HEAD` vs `origin/main`.

### Regla de detención (lista medible)

1. `git status --porcelain` debe estar vacío o contener ÚNICAMENTE entradas `??` de estos tres archivos recién copiados por el titular: el propio encargo v3, `20260826_pauta_validacion_convivencia_v1.md` y `20260826_formato_cruce_referencia_instrumentos.md`, todos bajo `50_documentacion/andamios/`. Si es así, commitéalos primero (`docs(andamios): encargo v3, pauta de validacion y formato de cruce`) y sigue. Cualquier otra entrada → detén la SESIÓN.
2. Si `50_documentacion/activa/ESTADO.md` no contiene `sesion_abierta: true` y `commit_cierre: 358e150` → detén la SESIÓN.
3. Si la auditoría TA encuentra una discrepancia entre lo reportado en los logs y lo medido contra producto → NO la corrijas: regístrala como hallazgo de auditoría con su evidencia y sigue auditando. Corregir sería contaminar la auditoría con el auditado.
4. Si el marcador de las asignaciones frágiles de tema no existe o su conteo difiere de 34 → congela TE, registra la duda con lo hallado; no fabriques la tabla desde otra fuente.
5. Si los conteos de páginas OCR por documento difieren de los que la pauta declara → corrige la pauta con el valor medido y regístralo (aquí el producto corrige al documento, no al revés, porque la pauta aún no se entrega).
6. Si tras el cambio de plantilla de TC el diff de `40_salidas/` regenerado toca algo más que las fichas de norma (y los subproductos directos de esa plantilla) → congela TC, revierte regenerando desde `HEAD` y registra la duda.
7. Si la verificación de TB exigiera ejecutar `00_ocr_documentos.R` → congela TB: ese script NO se ejecuta (compuerta `--rehacer` intacta); su verificación es por arnés.
8. Cualquier estado, conteo o resultado no enumerado → congela ESTA tarea, duda al log (4.8), sigue con la próxima independiente.

### Autorizaciones (lista cerrada)

- Escribir y modificar SOLO en: `00_ocr_documentos.R`, `30_procesamiento/`, `10_utils/10_utils.R`, `40_salidas/` (solo vía regeneración por pipeline), `50_documentacion/andamios/` y `50_documentacion/andamios/logs/` (incluye corregir la pauta y completar su `[ENLACE AL SITIO]`).
- Copias temporales bajo `/tmp/slep_v3_scratch` para arneses y controles positivos, borradas al cerrar; nada del repo se modifica desde ellas.
- Lectura web SOLO sobre: github.com, la URL pública del sitio del proyecto tal como la declare la configuración del repositorio (dominio github.io o el que la configuración indique), bcn.cl, leychile.cl. Solo lectura.
- `gh` SOLO en subcomandos de lectura (`gh run list`, `gh run view`, `gh api` GET).
- `Rscript 00_run_all.R` (o pasos 33-36) para la regeneración de TC; `Rscript -e` para arneses y conteos.
- `git add <rutas explícitas>` (nunca `git add .`), un commit atómico por tarea, push al cierre de la cadena, y UN segundo push autorizado de antemano si la evidencia del CI posterior al primero debe quedar registrada en el log (lección del encargo v2: esa tensión se resuelve aquí, no se improvisa).
- `git checkout -- <ruta>` SOLO para revertir una tarea congelada, sobre los archivos que esa tarea tocó, con la lista impresa antes.
- Nada más.

### Reglas canónicas heredadas (referencia, no copia)

`CLAUDE.md` §7 y §10; traspaso v01 §12 (⚠️ nada escribe en `20_insumos/curaduria/` ni `20_insumos/ocr/`; ⚠️ nada a mano en `40_salidas/`; ✅ derivador con descartes registrados; 🔒 cita textual, trazabilidad por badge, solo derecho chileno, anclas estables, reproducibilidad). La excepción de escritura delegada en curaduría fue puntual, de la sesión anterior, y NO rige en este encargo.

## 2. Estado de partida (premisas marcadas — TODAS se re-miden aquí; los logs son el objeto auditado, no la fuente de verdad)

- Cifras reportadas al cierre de TC: 552 relaciones (46 remisión), 67 descartes, N96 = 0, 795 enlaces / 0 rotos, manifiesto 25/0/0 (fuente: reporte de Claude Code en el chat; hipótesis para este encargo, se re-derivan en TA).
- La conversión completa a acceso exacto `[[ ]]` en `30_procesamiento/` quedó hecha tras la refutación del panel, en algún commit no identificado en el reporte (hipótesis, TA lo localiza).
- El estado del CI tras el último push no fue reportado (hipótesis, TA lo mide con `gh`).
- `00_ocr_documentos.R` conserva lecturas de curaduría con `$` (hipótesis, se mide con grep en FASE 0).
- `fuente_anios_alternativos` no aparece en ningún artefacto de `40_salidas/` (hipótesis, se mide con grep).
- Existe un marcador de fragilidad en las asignaciones de tema, con 34 casos (hipótesis, condición 4; localizarlo en `40_salidas/datos/` o en el derivador).
- 22 borradores en `20_insumos/curaduria/piezas/borradores/` (hipótesis, conteo).
- Páginas OCR por documento según la pauta: 193→16, 586→1, 812→10, rex_482 cuerpo→48, dictamen 078→9 (hipótesis, condición 5).
- La URL pública del sitio está declarada en la configuración del repo (hipótesis, FASE 0 la extrae; si no está, la infiere de `gh api` sobre el repositorio y lo declara).
- Los mensajes de commit de la sesión no llevan co-autoría de herramienta (hipótesis, TA lo verifica; es convención de CLAUDE.md).

## 3. Contexto mínimo

Última fase de la sesión 2. El titular pidió: confirmar contra producto que TODO lo reportado en la sesión es real, despejar toda duda pendiente, y dejar listos los insumos de la validación humana. Después de este encargo viene el cierre de sesión.

## 4. Invariantes (🔒)

- 🔒 Nada cierra `ocr_revisado`, aprueba temas ni publica piezas.
- 🔒 `20_insumos/curaduria/` y `20_insumos/ocr/` solo se leen.
- 🔒 `40_salidas/` solo cambia por regeneración.
- 🔒 Anclas públicas estables; la Duda 3 (slug del DFL 1) va en la pauta al equipo de convivencia y aquí no se toca.
- 🔒 Toda cifra reportada se recuenta programáticamente en el turno que la reporta.
- 🔒 La auditoría no corrige lo que audita (condición 3): hallazgo y corrección viven en tareas distintas, y las correcciones de este encargo (TB, TC) atacan defectos ya conocidos, no hallazgos nuevos de TA.

## 5. Cadena de tareas y grafo

Grafo: TA primero y sola (auditar antes de volver a tocar nada). Después TB, TD, TE, TF independientes entre sí; TC al final (única regeneración de la cadena, y su verificación absorbe el estado dejado por TB — que no toca el pipeline — y TF — que no toca `40_salidas/`). Una congelada no arrastra a las demás.

### FASE 0 — Medición (sin modificar nada)

1. `git fetch`; porcelain (condición 1); `HEAD` vs `origin/main`; `git log --oneline 358e150..HEAD` completo de la sesión.
2. `cat 50_documentacion/activa/ESTADO.md` (condición 2).
3. Conteos base de `relaciones.json`: relaciones totales y por tipo, descartes, N96.
4. `grep -n '\$' 00_ocr_documentos.R` acotado a los accesos a la estructura de curaduría (léelo entero para distinguirlos).
5. `grep -rn 'fuente_anios_alternativos' 40_salidas/ | wc -l` → esperado 0.
6. Localizar el marcador de fragilidad de temas y contarlo → esperado 34 (condición 4).
7. `ls 20_insumos/curaduria/piezas/borradores/ | wc -l` → esperado 22.
8. Conteo de `pagina_*.txt` por carpeta de `20_insumos/ocr/` y páginas del dictamen 078 según su fuente declarada → contra la pauta (condición 5).
9. Extraer la URL pública del sitio de la configuración del repo.
10. `gh run list --limit 3` → estado del CI del último push.

### TA — Auditoría contra producto de toda la sesión (solo lectura + escritura del informe)

Producto: `50_documentacion/andamios/20260826_auditoria_contra_producto_v1.md`. Cada punto con su comando y su veredicto (confirmado / discrepante / no verificable), sin corregir nada (condición 3):

1. **Cifras de cierre**: re-derivar con código propio (no el de los logs) relaciones 552, por tipo (46 remisión), descartes 67, N96 = 0, y que `dfl_315 → dfl_1` y `ley_21809 → dfl_1` existen con `dto_453 → dfl_1` en `n_citas >= 18`.
2. **Enlaces internos**: verificador independiente re-calibrado en este turno (control positivo: enlace y ancla falsos plantados en copia bajo `/tmp` disparan; el árbol real calla) → 795 / 0 rotos o el valor real.
3. **Sitio publicado**: fetch de la URL pública → HTTP 200; los rótulos `Resolución exenta 482 (resolución)` y `(cuerpo)` presentes en el HTML publicado; N96 = 0 también en el artefacto publicado si `relaciones.json` (o su huella) es alcanzable públicamente; si no lo es, decláralo no verificable por esa vía y verifícalo en `40_salidas/` local con huella contra el commit desplegado.
4. **Conversión `[[ ]]`**: localizar el commit que completó la conversión tras la refutación del panel; `grep` de accesos `$` residuales sobre listas de curaduría en `30_procesamiento/` y `00_generar_borradores.R` (control positivo: plantar un acceso `$` en copia bajo `/tmp` y demostrar que el grep lo caza) → esperado 0 residuales fuera de `00_ocr_documentos.R`.
5. **CI**: veredicto del run del último push (id, estado, anotaciones).
6. **Curaduría**: `git log --follow` de `metadatos_curados.json` en la sesión → un solo commit (`90d58cf`), diff aditivo +6/−0; `20_insumos/ocr/` sin ningún commit en la sesión.
7. **Higiene de commits**: lista completa `358e150..HEAD`; mensajes conformes a convención y sin co-autoría de herramienta.
8. **Muestreo de productos v1**: sobre `20260826_preclasificacion_descartes_v1.md`, verificar que las 21 filas homologables corresponden 1:1 con los 21 descartes que TC restituyó (los grupos deben cuadrar con N96 pre y las relaciones post); sobre la nota de cifra OCR, reproducir su comando central.
- **Panel adversarial (tope 2, solo lectura, R/jq):** re-derivar los puntos 1 y 8 con código propio e intentar refutar dos veredictos de TA a su elección.
- Criterio de éxito: informe completo con veredicto por punto; calibración global: los dos controles positivos plantados (enlace falso, `$` plantado) dispararon.
- Commit: `docs(andamios): auditoria contra producto de la sesion 2`.

### TB — `[[ ]]` exacto en `00_ocr_documentos.R` (corrige defecto conocido)

- Paso 0: leer el archivo completo; identificar todos los accesos `$` a estructuras de curaduría.
- Convertir a `[[ ]]`; NO ejecutar el script (condición 7).
- Verificación: arnés en `/tmp` que aísla las funciones de lectura y las alimenta con la entrada mínima del DFL 1 (caso malo: la versión con `$` reproduce la coincidencia parcial `anio`↔`anios_alternativos`; caso bueno: la versión nueva devuelve `NULL` donde corresponde); `Rscript -e 'parse(file="00_ocr_documentos.R")'` limpio; diff acotado a esos accesos.
- Commit: `fix(ocr): acceso exacto a curaduria, mismo defecto de 48d176a`.

### TD — Borradores que citan el REX 482 con rótulo antiguo (solo lectura)

- Producto: `50_documentacion/andamios/20260826_borradores_rotulo_rex482_v1.md`: lista de piezas afectadas con ruta y líneas.
- Control del instrumento: si el barrido da 0 afectadas, plantar en `/tmp` una pieza con el rótulo antiguo y demostrar que el barrido la caza antes de reportar 0.
- Commit: `docs(andamios): borradores con rotulo antiguo del rex 482`.

### TE — Tabla de los 34 temas frágiles (insumo del Bloque 2 de la pauta)

- Desde el marcador medido en FASE 0 (condición 4), generar `50_documentacion/andamios/20260826_tabla_temas_fragiles_v1.md`: una fila por caso con norma, artículo, tema asignado, motivo de la fragilidad si el dato existe, enlace directo a la página pública del artículo (URL de FASE 0.9), y columnas vacías `veredicto` / `tema_correcto` / `firma` para el equipo.
- Verificación: filas == conteo del marcador; muestreo de 3 enlaces contra el sitio publicado → HTTP 200.
- Commit: `docs(andamios): tabla de temas fragiles para validacion`.

### TF — CSV del cruce prellenado + pauta con cifras verificadas

- Generar `50_documentacion/andamios/cruce_referencia_instrumentos.csv` según el formato del documento de cruce: separador `;`, UTF-8, cabecera exacta con las 7 columnas, una fila por norma del catálogo (columnas `slug` y `documento_referencia` llenas desde el catálogo de `40_salidas/datos/`, el resto vacías).
- Verificación: filas == número de normas del catálogo; el CSV re-abre limpio con `read.csv2()` en R (mismo dialecto que Excel en español).
- Sobre la pauta: completar `[ENLACE AL SITIO]` con la URL de FASE 0.9 y ajustar los conteos de páginas si la condición 5 lo exigió, sin tocar nada más del documento.
- Commit: `docs(andamios): csv de cruce prellenado y pauta con enlace y cifras verificadas`.

### TC — Publicar `fuente_anios_alternativos` en la ficha de norma (única regeneración)

- Paso 0: localizar la plantilla de ficha de norma en `30_procesamiento/` (o `34_plantillas_sitio/`) y cómo llegan los metadatos curados a ella.
- Mostrar la procedencia cuando exista: en la ficha de la norma, junto a los años, algo como "Años de cita reconocidos: 1997, 1996 (fuente: declaración de curaduría, BCN)" — redacción final tuya, sobria y coherente con los badges existentes.
- Regenerar con `Rscript 00_run_all.R`.
- Verificación (condiciona el commit): (a) chequeo de presencia en el HTML de la ficha del DFL 1, calibrado: corre ANTES de la regeneración (falla: la procedencia no está) y DESPUÉS (pasa); (b) diff de `40_salidas/` acotado según condición 6; (c) `relaciones.json` idéntico byte a byte (esta tarea no toca datos); (d) verificador de enlaces → 0 rotos; (e) manifiesto 25/0/0.
- Commit: `feat(sitio): procedencia de anios_alternativos visible en la ficha`.

## 6. Exclusiones declaradas

- Duda 3 (slug del DFL 1): viaja al equipo de convivencia dentro de la pauta (Bloque 4); aquí nada se renombra ni incorpora.
- Módulo de análisis de reglamentos: fase nueva, se define en sesión propia con el cruce ya llenado.
- Corrección de líneas OCR, cierre de estados, publicación de piezas: firma humana.
- Todo hallazgo discrepante de TA: se registra, no se corrige (condición 3); su corrección se planifica en el cierre.

## 7. Auto-auditoría, log y reporte

- TA lleva su panel (arriba). TB-TF: re-derivación por comandos distintos de los que produjeron cada resultado.
- Log en `50_documentacion/andamios/logs/20260826_auditoria_y_cierre_v3_log.md`, plantilla fija (secciones 1-10; decisiones autónomas con alternativa y reversibilidad; dudas con pregunta cerrada). Commit atómico.
- Push al cierre; segundo push solo-documentación autorizado si la evidencia de CI lo requiere.
- Reporte al chat: veredicto global de la auditoría (confirmado / discrepancias, con lista), hashes, verificaciones con evidencia, congeladas con su duda, ruta del log, y "lo que falló o sorprendió; si nada, decirlo explícitamente".
