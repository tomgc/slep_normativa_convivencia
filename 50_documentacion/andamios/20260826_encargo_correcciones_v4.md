# Encargo autónomo — correcciones de cierre de brechas (v4), sesión 2

Proyecto: `slep_normativa_convivencia`. Patrón: `encargo_autonomo_claude_code_v1.md` (v1.3). Sucede al encargo v3; ejecuta las recomendaciones aprobadas del análisis `20260826_analisis_ejecucion_v3.md`. Objetivo: dejar el inventario de defectos conocidos en cero antes de entregar la pauta de validación. La clase B (86 accesos sobre curaduría derivada) queda EXCLUIDA: viaja al traspaso v02 con la clasificación del panel v3 como insumo.

## 1. Contrato

- **Modo:** autónomo, secuencial, todo en este turno. Subagentes: SOLO de solo-lectura para el panel adversarial de T1, tope duro 2. **Todo prompt de subagente declara: R o jq exclusivamente, Python prohibido (CLAUDE.md §7), sin escritura en el repositorio.**
- **ENTORNO:** filesystem local vía Claude Code, raíz `~/Projects/slep_normativa_convivencia`, macOS, R 4.5.2, Quarto 1.9.38 (fuente: logs de la sesión, leídos por el redactor).
- **INSUMOS:** por ruta desde la raíz. Claves: `30_procesamiento/34_generar_paginas.R`, `00_run_all.R`, `00_ocr_documentos.R`, `20_insumos/curaduria/piezas/borradores/` (solo lectura), `50_documentacion/andamios/20260826_pauta_validacion_convivencia_v1.md`, `50_documentacion/andamios/20260826_fuentes_glosario_v1.md`, `50_documentacion/andamios/20260826_auditoria_contra_producto_v1.md` (§ de O5, para la lista exacta de los 17 accesos), `CLAUDE.md` §10.5.
- **POSICIÓN:** rutas completas desde la raíz; `bash` explícito o `Rscript`; FASE 0 abre con `git fetch` y `HEAD` vs `origin/main`.

### Regla de detención (lista medible)

1. `git status --porcelain` vacío o ÚNICAMENTE entradas `??` de estos dos archivos recién copiados por el titular bajo `50_documentacion/andamios/`: este encargo v4 y `20260826_analisis_ejecucion_v3.md`. Si es así, commitéalos primero (`docs(andamios): encargo v4 y analisis de la ejecucion v3`) y sigue. Cualquier otra entrada → detén la SESIÓN.
2. Si `ESTADO.md` no contiene `sesion_abierta: true` y `commit_cierre: 358e150` → detén la SESIÓN.
3. Si el conteo de accesos de clase A en `34_generar_paginas.R` difiere de 17, la lista de O5 en la auditoría prevalece sobre este encargo: convierte LOS QUE ESA LISTA ENUMERA más cualquier acceso `$` adicional sobre los objetos de pieza que un barrido exhaustivo propio encuentre, y registra la diferencia de conteo como duda. La meta es "cero accesos `$` sobre curaduría cruda en ese archivo", no "17".
4. Si tras la regeneración de T1 las salidas NO son byte a byte idénticas → congela T1, NO commitees las salidas, regenera desde `HEAD` para restaurar, y registra el diff como duda: la conversión debía ser de comportamiento neutro sobre los datos reales.
5. Si la regeneración vuelve a producir cero líneas de log y cero cambios de mtime → la guardia de T2 falló: congela T1 y T2 juntas y registra la evidencia (es exactamente la trampa que T2 existe para cerrar).
6. Si la verificación de T3 exigiera ejecutar `00_ocr_documentos.R` → congela T3 (compuerta `--rehacer` intacta; verificación por arnés).
7. Cualquier estado, conteo o resultado no enumerado → congela ESTA tarea, duda al log, sigue con la próxima independiente.

### Autorizaciones (lista cerrada)

- Escribir y modificar SOLO en: `30_procesamiento/34_generar_paginas.R`, `00_run_all.R`, `00_ocr_documentos.R`, `40_salidas/` (solo vía regeneración por pipeline), `50_documentacion/andamios/` y `50_documentacion/andamios/logs/`.
- Copias temporales bajo `/tmp/slep_v4_scratch` (y `/tmp/slep_v4_panel{1,2}/` para el panel), borradas al cerrar.
- `gh` SOLO en subcomandos de lectura.
- Regeneración EXCLUSIVAMENTE mediante `Rscript 00_run_all.R` DESPUÉS de la guardia de T2 (esa invocación es a la vez la regeneración de T1 y la prueba de T2).
- `git add <rutas explícitas>`, un commit atómico por tarea, push al cierre, y UN segundo push solo-documentación si la evidencia de CI debe quedar en el log.
- `git checkout -- <ruta>` SOLO para restaurar una tarea congelada, con la lista impresa antes.
- Nada más. Sin lectura web fuera de `gh`: nada en este encargo la necesita.

### Reglas canónicas heredadas (referencia, no copia)

`CLAUDE.md` §7 y §10 (en particular §10.5: el pipeline debe abortar ante una pieza inválida en la compuerta de firma); traspaso v01 §12; los 🔒 de siempre: nada cierra estados ni publica piezas, `20_insumos/` solo se lee, `40_salidas/` solo por regeneración, anclas estables, toda cifra recontada en el turno.

## 2. Estado de partida (premisas marcadas — se re-miden en FASE 0)

- 17 accesos `$` de clase A en `34_generar_paginas.R`, incluida `firmada()` en la línea 359, enumerados en la auditoría contra producto §O5 (hipótesis, condición 3; la lista de la auditoría prevalece).
- 22 piezas en `borradores/`, 0 con `estado: validada` (hipótesis, conteo; es la condición que mantiene a O5 no viva mientras se corrige).
- `Rscript 00_run_all.R` define `run_all()` y no la invoca (hipótesis, se mide ejecutándolo ANTES de la guardia: cero líneas y árbol intacto es el resultado esperado y es inocuo).
- Pares prefijo/prefijado `paginas` / `paginas_pdf` / `paginas_vacias` en el manifiesto de OCR, leídos con `$` en `00_ocr_documentos.R` (hipótesis, grep; hoy sin defecto vivo según O3).
- La pauta llama "escaneados" a los 5 documentos del Bloque 1 y el dictamen 078 tiene capa de texto (hipótesis, grep sobre la pauta + `sin_capa_texto` en el manifiesto).
- `20260826_fuentes_glosario_v1.md` cita un "artículo 46 letra f)" de la Ley 21.809 que no existe (el texto vive en el artículo modificatorio 44 bis) y declara 11 segmentos donde se miden 12 (hipótesis, ambas se re-miden: grep en el documento y conteo sobre la circular 482).

## 3. Contexto mínimo

Última fase de máquina antes de entregar la pauta al equipo de convivencia. T1 es la condición de seguridad de la vía A: la compuerta de firma debe ser inderrotable antes de que existan las primeras piezas validadas. La sesión NO se cierra con este encargo: al terminar, reporta y espera.

## 4. Invariantes (🔒)

Los seis del encargo v3, más uno propio: **la corrección de la compuerta no cambia el veredicto sobre ninguna de las 22 piezas reales** (todas en borrador antes y después; la regeneración debe ser un no-op byte a byte).

## 5. Cadena de tareas y grafo

Grafo: T2 → T1 (T1 regenera usando la guardia que T2 instala; condición 5 los ata); T3 y T4 independientes de todo. Orden: T2 → T1 → T3 → T4.

### FASE 0 — Medición (sin modificar nada)

1. Porcelain (condición 1); `HEAD` vs `origin/main`.
2. `ESTADO.md` (condición 2).
3. Barrido exhaustivo propio de accesos `$` en `34_generar_paginas.R` sobre objetos de pieza y curaduría cruda; cruce contra la lista de O5 (condición 3).
4. Conteo de piezas y de sus `estado:` en `borradores/`.
5. `Rscript 00_run_all.R` tal cual → registrar líneas de salida (esperado 0) y `git status` intacto.
6. `grep -n '\$paginas' 00_ocr_documentos.R` y lectura del bloque.
7. `grep -n 'escaneado' 50_documentacion/andamios/20260826_pauta_validacion_convivencia_v1.md`; `jq '.documentos[] | {doc, sin_capa_texto}' 20_insumos/ocr/manifiesto_ocr.json` (ajusta la ruta de claves a la real).
8. Sobre el documento de fuentes del glosario: localizar la cita "46 letra f)" y recontar los segmentos de "protocolo de actuación" en la circular 482 con el criterio explícito que uses.
9. `sha256` de todos los archivos versionados de `40_salidas/` (línea base del no-op de T1).

### T2 — Guardia de ejecución en `00_run_all.R`

- Añadir al final la invocación condicionada a ejecución no interactiva (el idioma exacto lo decides tú: `if (!interactive()) run_all()` o el equivalente que el archivo ya sugiera por estilo), con un comentario de una línea que remita a este encargo.
- Verificación (condiciona el commit): `parse()` limpio; el diff toca solo el final del archivo; la PRUEBA REAL queda diferida a la regeneración de T1 (condición 5).
- Commit: `fix(pipeline): run_all se ejecuta al invocar el script, no solo se define`.

### T1 — Compuerta de firma y clase A en `34_generar_paginas.R`

- Convertir a `[[ ]]` todos los accesos de clase A (lista de O5 + barrido propio, condición 3), `firmada()` incluida. Si §10.5 exige abortar ante pieza inválida y el código actual solo la omite, ese endurecimiento NO se hace aquí: se registra como duda con la conducta actual descrita (cambiar la semántica de la compuerta excede una conversión de acceso y merece decisión del titular).
- **Arnés adversarial previo al commit** (`/tmp/slep_v4_scratch/t1/`), con piezas sintéticas; la versión vieja y la nueva de las funciones se transcriben al arnés, sin ejecutar el generador completo:
  1. pieza `estado: validada`, sin `validado_por`, con `validado_por_equipo: "x"` → vieja: **pasa como firmada** (reproduce O5); nueva: **no pasa**.
  2. pieza `estado: validada`, `validado_por: "Nombre"`, fecha → ambas: pasa (la corrección no bloquea lo legítimo).
  3. pieza `estado: borrador` con `validado_por` presente → ambas: no se publica (el estado manda).
  4. pieza sin `estado` → registrar la conducta de ambas versiones (insumo de la duda de §10.5 si difiere de abortar).
- **Panel adversarial (tope 2, solo lectura, R/jq):** atacar la compuerta nueva con variantes propias (claves prefijadas distintas, `validado_por` vacío o NULL, mayúsculas en `estado`) e intentar refutar el barrido "cero `$` de clase A restantes".
- Regenerar con `Rscript 00_run_all.R` (prueba de T2): evidencia de ejecución = líneas de log del pipeline y mtimes nuevos; evidencia de neutralidad = `sha256` idéntico a la línea base de FASE 0.9 en todo archivo versionado (condición 4).
- Commit: `fix(sitio): compuerta de firma y clase A con acceso exacto a curaduria`.

### T3 — Lecturas del manifiesto en `00_ocr_documentos.R`

- Convertir a `[[ ]]` las lecturas de `paginas` y todo par prefijado del manifiesto; el script NO se ejecuta (condición 6).
- Verificación: arnés con manifiesto real (no-op) y manifiesto plantado sin `paginas` pero con `paginas_pdf` (vieja: coincidencia parcial; nueva: `NULL`); `parse()` limpio; diff acotado.
- Commit: `fix(ocr): lecturas exactas del manifiesto, cierra O3`.

### T4 — Correcciones documentales (O1 y O4)

- **Pauta, Bloque 1:** reescribir la frase que llama "escaneados" a los cinco: cuatro fueron escaneados y leídos por la herramienta; el dictamen 078 ya traía texto, pero ese texto tampoco ha sido revisado por una persona y por eso está en la misma lista. Mantener el lenguaje llano de la pauta; ningún otro cambio en el documento.
- **Fuentes del glosario:** corregir la referencia al artículo modificatorio (44 bis) con su denominación exacta según Ley Chile; alinear el conteo con lo medido en FASE 0.8 declarando el criterio en una línea (si la exclusión de la página 38 es defendible, se declara; si no, la cifra pasa a 12).
- Verificación: los dos documentos re-abren limpios; diffs acotados a las líneas citadas; toda cifra nueva con su comando.
- Commit: `docs(andamios): pauta y fuentes del glosario corregidas (O1, O4)`.

## 6. Exclusiones declaradas

- Clase B (86 accesos): traspaso v02, con la clasificación del panel v3.
- Endurecimiento semántico de la compuerta (§10.5, abortar vs omitir): si aplica, queda como duda para el titular (ver T1).
- Slug del DFL 1, cierre de estados, publicación, módulo de reglamentos: sin cambios en sus gates.

## 7. Auto-auditoría, log y reporte

- T1 con panel; T2-T4 con re-derivación por comandos distintos.
- Log en `50_documentacion/andamios/logs/20260826_correcciones_v4_log.md`, plantilla fija. Commit atómico.
- Push al cierre; segundo push solo-documentación si la evidencia de CI lo requiere.
- Reporte al chat: hashes, verificaciones con evidencia (el arnés de la compuerta con sus 4 casos en ambas versiones), congeladas con su duda, ruta del log, y "lo que falló o sorprendió; si nada, decirlo explícitamente". **La sesión queda abierta: no toques `ESTADO.md`.**
