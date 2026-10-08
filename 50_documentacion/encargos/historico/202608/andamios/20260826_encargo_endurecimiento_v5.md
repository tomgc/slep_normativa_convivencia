# Encargo autónomo — endurecimiento de compuerta y corrección sistémica (v5), sesión 2

Proyecto: `slep_normativa_convivencia`. Patrón: `encargo_autonomo_claude_code_v1.md` (v1.3). Sucede al encargo v4; ejecuta las decisiones aprobadas sobre sus Dudas 1, 2, 4 y 5. La Duda 3 (vocabulario de `relaciones.json`) queda EXCLUIDA: viaja al traspaso v02 como zona frágil. Propósito: que la compuerta de firma sea inderrotable por el front matter que una persona escribirá a mano, y que la coincidencia parcial de `$` deje de ser un defecto silencioso en todo el proyecto.

## 1. Contrato

- **Modo:** autónomo, secuencial, todo en este turno. Subagentes: SOLO de solo-lectura para el panel adversarial de T1, tope duro 2 (los reintentos ante fallos de infraestructura no cuentan contra el tope, como en v4). **Todo prompt de subagente declara: R o jq exclusivamente, Python prohibido (CLAUDE.md §7), sin escritura en el repositorio.**
- **ENTORNO:** filesystem local vía Claude Code, raíz `~/Projects/slep_normativa_convivencia`, macOS, R 4.5.2, Quarto 1.9.38 (fuente: logs de la sesión, leídos por el redactor).
- **INSUMOS:** por ruta desde la raíz. Claves: `30_procesamiento/34_generar_paginas.R`, `30_procesamiento/32_segmentar_articulos.R`, `10_utils/10_configuracion.R`, `10_utils/10_utils.R`, `00_run_all.R`, `20_insumos/curaduria/piezas/borradores/` (solo lectura), `50_documentacion/andamios/logs/20260826_correcciones_v4_log.md` (§8, tablas de conducta y familias del panel), `20260826_auditoria_contra_producto_v1.md` (lista de clase B), `CLAUDE.md` §10.5.
- **POSICIÓN:** rutas completas desde la raíz; `bash` explícito o `Rscript`; FASE 0 abre con `git fetch` y `HEAD` vs `origin/main`.

### Regla de detención (lista medible)

1. `git status --porcelain` vacío o ÚNICAMENTE la entrada `??` de este encargo bajo `50_documentacion/andamios/`. Si es así, commitéalo primero (`docs(andamios): encargo v5`) y sigue. Cualquier otra entrada → detén la SESIÓN.
2. Si `ESTADO.md` no contiene `sesion_abierta: true` y `commit_cierre: 358e150` → detén la SESIÓN.
3. Si alguna de las 22 piezas reales cae en un caso que la compuerta endurecida ABORTA → congela T1, NO commitees, registra qué pieza y qué regla: el endurecimiento no puede romper el corpus real, y si lo rompe, la decisión es del titular.
4. Si la regeneración de T1 no deja los archivos versionados de `40_salidas/` byte a byte idénticos a la línea base → congela T1, restaura regenerando desde `HEAD`, registra el diff.
5. Si bajo las opciones de T2 la corrida real del pipeline emite UNA O MÁS advertencias de coincidencia parcial → congela T2 (deja la configuración fuera del commit), registra CADA advertencia con su ubicación como hallazgo: son accesos vivos que las auditorías no vieron, y corregirlos excede este encargo.
6. Si el mecanismo de elevación a error de T2 no puede acotarse al pipeline (es decir, si convertiría en error advertencias ajenas a la coincidencia parcial) → congela esa mitad de T2, deja las opciones como advertencia simple y registra la limitación con su evidencia.
7. Cualquier estado, conteo o resultado no enumerado → congela ESTA tarea, duda al log, sigue con la próxima independiente.

### Autorizaciones (lista cerrada)

- Escribir y modificar SOLO en: `30_procesamiento/34_generar_paginas.R`, `30_procesamiento/32_segmentar_articulos.R` (solo el comentario de T4), `10_utils/10_configuracion.R`, `10_utils/10_utils.R`, `00_run_all.R` (solo si la compuerta de advertencias de T2 vive ahí por diseño), `40_salidas/` (solo vía regeneración), `50_documentacion/andamios/` y `50_documentacion/andamios/logs/`.
- Copias temporales bajo `/tmp/slep_v5_scratch` y `/tmp/slep_v5_panel{1,2}/`, borradas al cerrar.
- `gh` SOLO en subcomandos de lectura.
- Regeneración EXCLUSIVAMENTE mediante `Rscript 00_run_all.R`.
- `git add <rutas explícitas>`, un commit atómico por tarea, push al cierre, y UN segundo push solo-documentación si la evidencia de CI debe quedar en el log.
- `git checkout -- <ruta>` SOLO para restaurar una tarea congelada, con la lista impresa antes.
- Nada más. Sin lectura web fuera de `gh`.

### Reglas canónicas heredadas (referencia, no copia)

`CLAUDE.md` §7 y §10.5 (la compuerta ante una pieza inválida ABORTA; no se salta en silencio); traspaso v01 §12; los 🔒 de siempre. **La sesión NO se cierra: `ESTADO.md` no se toca.**

## 2. Estado de partida (premisas marcadas — se re-miden en FASE 0)

- Conducta actual de la compuerta según la tabla de la Duda 1 del log v4: tres casos ⚠ de `estado` (ausente, `Validada`, con espacios) omiten en silencio; `tipo` ausente pasa la compuerta y revienta lejos; seis valores no-carácter de `validado_por` publican como firmados; `[]`/`{}` desaparecen sin rastro; `archivo:`/`cuerpo:` en el front matter secuestran los campos de confianza (hipótesis: el arnés de T1 re-mide TODA la tabla sobre el código real antes de tocar nada; la tabla del log es el objeto a reproducir, no la fuente de verdad).
- 22 piezas reales, todas `estado: borrador`, `tipo` y `estado` bien escritos, 0 con `validado_por` no-carácter, 0 con `archivo`/`cuerpo` en el front matter (hipótesis; gobierna la condición 3).
- Ni `10_utils/10_configuracion.R` ni `10_utils/10_utils.R` fijan `options()` (hipótesis, grep).
- 86 accesos de clase B enumerados en la auditoría v3 (hipótesis; la lista de la auditoría prevalece sobre el número, misma regla que v4: los números de línea pueden haber envejecido con los commits de v4).
- `30_procesamiento/32_segmentar_articulos.R` líneas 436-438 con el pendiente falso sobre `estado_curado()` (hipótesis; localizar por contenido, no por número de línea).
- 28 archivos versionados en `40_salidas/` (hipótesis; la línea base se toma en FASE 0).

## 3. Contexto mínimo

Cierre de la brecha semántica que la v4 dejó registrada: el acceso exacto impidió el secuestro por prefijo, pero la compuerta todavía acepta firmas que no son nombres, omite en silencio estados mal escritos y es secuestrable por coincidencia exacta. Todo eso lo va a escribir a mano el equipo de convivencia en cuanto empiece la vía A. Después de este encargo, el proyecto queda listo para entregar la pauta.

## 4. Invariantes (🔒)

Los de siempre (nada cierra estados ni publica; `20_insumos/` solo lectura; `40_salidas/` solo por regeneración; anclas estables; cifras recontadas), más los dos propios:

- 🔒 **El endurecimiento no cambia el veredicto de ninguna pieza real**: 22 en total, 22 en borrador, 0 publicables, antes y después; regeneración byte a byte idéntica (condiciones 3 y 4).
- 🔒 **Toda regla nueva de la compuerta aborta con un mensaje que nombra el archivo de la pieza y la clave ofensora**: el destinatario del error es una persona del equipo de convivencia, no un programador.

## 5. Cadena de tareas y grafo

Grafo: T4 y T3 independientes de todo; T1 antes que T2 (la corrida final de T2 se hace ya con la compuerta endurecida, y su no-op es la verificación integral de la cadena). Orden: T4 → T3 → T1 → T2.

### FASE 0 — Medición (sin modificar nada)

1. Porcelain (condición 1); `HEAD` vs `origin/main`.
2. `ESTADO.md` (condición 2).
3. Conteo y estados de las 22 piezas; verificación de la premisa de la condición 3 sobre el corpus real.
4. `grep -n 'options(' 10_utils/10_configuracion.R 10_utils/10_utils.R 00_run_all.R`.
5. Localizar por contenido el comentario obsoleto en `32_segmentar_articulos.R`.
6. Extraer la lista de clase B de la auditoría v3 y re-anclarla al estado actual de los archivos (los números de línea de v3 envejecieron dos encargos atrás).
7. `sha256` de los archivos versionados de `40_salidas/` (línea base).

### T4 — Comentario obsoleto (un commit de una línea)

- Reescribir el comentario para que diga la verdad actual: `estado_curado()` alineado en `851f021` y las lecturas del manifiesto en `81179e3`.
- Verificación: diff acotado al comentario; `parse()` limpio.
- Commit: `docs(codigo): comentario de 32_segmentar al dia con 851f021 y 81179e3`.

### T3 — Re-clasificación de la clase B por univocidad (solo lectura)

- Para cada acceso de la lista re-anclada, determinar contra el esquema REAL de los datos que ese código lee: (i) la clave exacta existe siempre → sin defecto posible hoy; (ii) la clave exacta puede faltar y el prefijo es UNÍVOCO → muerde (riesgo real); (iii) la clave exacta puede faltar y hay dos o más hermanas → la ambigüedad protege. La determinación de "existe siempre" se hace por conteo sobre los datos generados (`40_salidas/datos/`), no por lectura del código que los produce.
- Producto: `50_documentacion/andamios/20260826_reclasificacion_clase_b_v1.md` — tabla completa con archivo, línea actual, acceso, categoría y evidencia (el conteo o el par), más el resumen por categoría. Este documento reemplaza a la clasificación v3 como insumo del traspaso v02.
- Calibración obligatoria: el clasificador debe reproducir los tres casos ya conocidos con el veredicto conocido — `anio`/`anios_alternativos` como (ii) muerde, `paginas` con dos hermanas como (iii) protegido, y un acceso cualquiera con clave presente en 100% como (i). Sin esa reproducción, no reportes la tabla.
- Commit: `docs(andamios): clase B reclasificada por univocidad`.

### T1 — Endurecimiento semántico de la compuerta

- Paso 0: arnés que reproduce la tabla COMPLETA de la Duda 1 (los 11 casos de conducta más las familias (a) seis valores no-carácter, (b) `[]`/`{}`, (c) secuestro de `archivo`/`cuerpo`) sobre el código actual, para confirmar el punto de partida ANTES de tocar nada.
- Implementar las cinco medidas aprobadas, con diseño a tu criterio dentro de estos resultados obligatorios:
  (a) `validado_por` solo acepta lo que puede ser un nombre: tipo carácter, no vacío tras `trimws()`, con al menos una letra; todo otro tipo o valor → ABORTA nombrando archivo y clave.
  (b) `firmada()` no puede devolver `NA` (la pieza con `[]`/`{}` ABORTA, no desaparece).
  (c) `leer_pieza()` rechaza con ABORTA un front matter que declare `archivo` o `cuerpo`.
  (d) `estado` se normaliza con `tolower(trimws())`; fuera de {`borrador`, `validada`} → ABORTA (con lo cual `Validada` y `" validada "` pasan a ser válidos y normalizados, no errores: la normalización es para aceptar lo bien intencionado y abortar lo desconocido).
  (e) pieza sin `tipo` o sin `estado` → ABORTA en la compuerta, no aguas abajo.
- Arnés posterior: la MISMA tabla completa sobre el código nuevo. Criterios de éxito: los seis valores no-carácter ABORTAN; `[]` ABORTA; el secuestro ABORTA; `Validada` y `" validada "` se aceptan normalizados; sin `tipo` o sin `estado` ABORTA en la compuerta; el caso legítimo (nombre real + fecha) publica; `borrador` sigue en borrador. Publicar la tabla antes/después completa en el log.
- **Panel adversarial (tope 2, solo lectura, R/jq):** atacar la compuerta nueva con casos propios no listados (unicode, nombres de un carácter, listas de nombres, `estado` numérico, claves duplicadas en el YAML mismo) e intentar refutar "ninguna pieza real cambia de veredicto".
- Regenerar con `Rscript 00_run_all.R`: 22/22/0 antes y después; byte a byte contra la línea base (condiciones 3 y 4).
- Commit: `fix(sitio): compuerta de firma endurecida segun 10.5 (duda 1 de v4)`.

### T2 — La coincidencia parcial deja de ser silenciosa en todo el proyecto

- Añadir en `10_utils/10_configuracion.R`: `options(warnPartialMatchDollar = TRUE, warnPartialMatchArgs = TRUE, warnPartialMatchAttr = TRUE)`, con comentario de dos líneas que remita al defecto del DFL 1 y a este encargo.
- **Elevación a compuerta:** diseña el mecanismo para que una advertencia de coincidencia parcial durante `run_all()` haga FALLAR la corrida (y por tanto el CI), sin convertir en error advertencias ajenas (condición 6). Opciones a evaluar (decides tú con evidencia): `withCallingHandlers` que promueve a error solo las advertencias cuyo mensaje corresponde a coincidencia parcial, envolviendo la ejecución de los pasos; o un recuento al final de `run_all()` que aborta si el contador es > 0. El mecanismo elegido queda documentado en el log con la alternativa descartada.
- Verificación en tres frentes, todos previos al commit:
  1. **Demostración positiva:** script de juguete bajo `/tmp/slep_v5_scratch/` con un acceso `$` parcial unívoco, ejecutado bajo el mismo mecanismo → la corrida FALLA señalando el acceso.
  2. **Corrida real:** `Rscript 00_run_all.R` completa sin ninguna advertencia de coincidencia parcial (condición 5 si aparece alguna) y con salidas byte a byte idénticas a la línea base.
  3. **El idioma del CI** (`Rscript -e 'source("00_run_all.R"); run_all()'`) sigue corriendo una sola vez (la lección de v4 no se deshace).
- Commit: `feat(config): coincidencia parcial promovida a error del pipeline`.

## 6. Exclusiones declaradas

- Duda 3 de v4 (vocabulario `tema`/`temas`, `cita`/`cita_literal`): traspaso v02, zona frágil; queda además cubierta en tiempo de ejecución por T2.
- Corrección de los accesos clase B que T3 clasifique como "muerde": la reclasificación es el insumo; la corrección se decide con el traspaso.
- Slug del DFL 1, cierre de estados, publicación de piezas, entrega de la pauta: gates humanos intactos.

## 7. Auto-auditoría, log y reporte

- T1 con panel; T2-T4 con re-derivación por comandos distintos.
- Log en `50_documentacion/andamios/logs/20260826_endurecimiento_v5_log.md`, plantilla fija. Commit atómico.
- Push al cierre; segundo push solo-documentación si la evidencia de CI lo requiere.
- Reporte al chat: hashes, la tabla antes/después de la compuerta completa, veredicto del panel, congeladas con su duda, ruta del log, y "lo que falló o sorprendió; si nada, decirlo explícitamente". **La sesión queda abierta: `ESTADO.md` no se toca.**
