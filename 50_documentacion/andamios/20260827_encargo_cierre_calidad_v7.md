# Encargo autónomo — indexación de piezas y cierre documental (v7), sesión 2

Proyecto: `slep_normativa_convivencia`. Patrón: `encargo_autonomo_claude_code_v1.md` (v1.3). Sucede al encargo v6. Tres tareas cortas: consumar y verificar el push de la cadena v6 en el runner, corregir E-c (las piezas publicadas no entran al buscador) con la decisión ya aprobada por el titular, y aplicar por delegación explícita el diff del README de piezas. E-d queda como pendiente operativo de la vía A (las 2 FAQ con anclas rancias se corrigen al registrarse su validación) y el no-determinismo del manifiesto y de `pagefind-entry.json` viaja al traspaso v02: ninguno de los dos se toca aquí.

## 1. Contrato

- **Modo:** autónomo, secuencial, todo en este turno. Sin subagentes: ninguna tarea lo amerita.
- **ENTORNO:** filesystem local vía Claude Code, raíz `~/Projects/slep_normativa_convivencia`, macOS, R 4.5.2, Quarto 1.9.38; runner con versiones ya fijadas por v6 (fuente: log v6, leído por el redactor).
- **INSUMOS:** por ruta desde la raíz. Claves: `30_procesamiento/34_generar_paginas.R` (`pagina_norma()` línea ~263 como referencia del atributo, `pagina_pieza()` como objetivo), `50_documentacion/andamios/20260827_diff_propuesto_readme_piezas.md`, `20_insumos/curaduria/piezas/README.md`, guion del ensayo `50_documentacion/andamios/20260827_ensayo_general_v1.md`, `CLAUDE.md`.
- **POSICIÓN:** rutas completas desde la raíz; `bash` explícito o `Rscript`; FASE 0 abre con `git fetch` y `HEAD` vs `origin/main`.

### Regla de detención (lista medible)

1. Porcelain vacío o SOLO la entrada `??` de este encargo → commitéalo (`docs(andamios): encargo v7`) y sigue. Otra cosa → detén la SESIÓN.
2. `ESTADO.md` sin `sesion_abierta: true` + `commit_cierre: 358e150` → detén la SESIÓN.
3. Clones: `git remote remove origin` inmediato y verificado; un clon con remote no ejecuta nada.
4. Si el diff de andamiaje del sitio desplegado contra el HTML local NO cae a 0 con las versiones fijadas → repórtalo con el diff, no arregles nada (T1 queda con esa mitad congelada).
5. Si el README real difiere del que el diff propuesto tomó como base (el diff no aplica limpio) → congela T3, reporta el conflicto; no improvises una fusión.
6. Si tras T2 la regeneración del repo real NO es byte a byte idéntica (con 0 piezas publicadas, el cambio no debe tocar ninguna salida) → congela T2, restaura regenerando desde `HEAD`, registra el diff.
7. Cualquier estado, conteo o resultado no enumerado → congela ESTA tarea, duda al log, sigue.

### Autorizaciones (lista cerrada)

- Escribir SOLO en: `30_procesamiento/34_generar_paginas.R`, `40_salidas/` (solo vía regeneración), `50_documentacion/andamios/` y `50_documentacion/andamios/logs/`, y **`20_insumos/curaduria/piezas/README.md` ÚNICAMENTE en T3, por delegación explícita del titular dada en el chat de esta sesión** (registrarla en §7 del log como decisión del usuario en gate, igual que la entrada de curaduría de la Duda 2). Ningún otro archivo de `20_insumos/` se toca.
- Clones bajo `/tmp/slep_v7_*`, sin remote, con escritura libre dentro, borrados y verificados al cerrar.
- `gh` solo lectura; fetch de la URL pública del sitio.
- Regeneración por `Rscript 00_run_all.R` (real) y equivalente en el clon.
- `git push origin main` (T1 y push de cierre) + UN push adicional solo-documentación para la adenda final de CI.
- `git checkout -- <ruta>` solo para restaurar tarea congelada, lista impresa antes.
- Nada más.

### Reglas canónicas heredadas

`CLAUDE.md` §7 y §10.5; los 🔒 de siempre. **La sesión NO se cierra: `ESTADO.md` no se toca.** Ninguna pieza real se publica.

## 2. Estado de partida (premisas marcadas — se re-miden en FASE 0)

- `HEAD` local en `66a99d5`; `origin/main` puede estar en `7bbb452` (push de v6 pendiente) o ya sincronizado si el titular envió la autorización previa (hipótesis; FASE 0 lo mide y T1 actúa según el caso).
- `data-pagefind-body` lo emite solo `pagina_norma()`; 0 URLs de pieza en el índice de Pagefind del ensayo (fuente: log v6; hipótesis local, se re-mide sobre el código).
- El diff propuesto del README está en `20260827_diff_propuesto_readme_piezas.md` y el README real coincide con su base (hipótesis; condición 5).
- Con 0 piezas publicadas, cambiar `pagina_pieza()` no altera ninguna salida del repo real (hipótesis; condición 6 la convierte en verificación).

## 3. Contexto mínimo

Último encargo de máquina antes de entregar la pauta y cerrar la sesión. Las tres tareas son el remanente aprobado del análisis del ensayo v6.

## 4. Invariantes (🔒)

Los de siempre, más: la delegación de T3 cubre UN archivo y UN cambio (el diff propuesto), nada más; los clones no empujan y se borran.

## 5. Cadena de tareas y grafo

Grafo: T1 primero (deja el runner verificado con la cadena v6); T2 después (su push viaja con el cierre); T3 independiente. Orden: T1 → T3 → T2 → push de cierre y adenda.

### FASE 0 — Medición (sin modificar nada)

1. Porcelain, `HEAD` vs `origin/main`.
2. `ESTADO.md`.
3. `grep -n 'data-pagefind' 30_procesamiento/34_generar_paginas.R`.
4. Diff de aplicabilidad: el texto base que el diff propuesto asume vs el README real (condición 5).
5. Línea base sha256 de `40_salidas/`.

### T1 — Push de la cadena v6 y verificación en runner

- Si `origin/main` está atrás: `git push origin main`. Si ya está sincronizado, salta al run existente.
- Verificar y reportar con evidencia literal: (a) run en verde con id; (b) el paso de autoprueba de la compuerta visible en el log del runner y en verde; (c) las versiones instaladas en el runner son las fijadas (líneas del log que las declaran); (d) 2 páginas muestreadas del sitio desplegado byte a byte idénticas al HTML local — el diff de 15 líneas de andamiaje debe caer a 0 (condición 4 si no cae).

### T3 — README de piezas por delegación (decisión del titular)

- Aplicar el diff propuesto tal como está escrito en `20260827_diff_propuesto_readme_piezas.md`: el bloque nuevo bajo "Front matter obligatorio" y el reemplazo de la frase de "Estructura". Nada más que eso.
- Verificación: diff del README acotado exactamente a esos dos cambios; el archivo re-abre limpio; ninguna otra ruta de `20_insumos/` en el porcelain.
- Commit: `docs(curaduria): readme de piezas al dia con la compuerta ronda 2 (delegacion del titular)`.

### T2 — E-c: las piezas publicadas entran al buscador

- Incorporar en `pagina_pieza()` la emisión de `data-pagefind-body` (mismo mecanismo que `pagina_norma()`), con la decisión aprobada: el material de apoyo publicado debe ser encontrable. Si el archivo excluye del índice otras páginas por diseño (portadas, índices), respeta esas exclusiones: el cambio cubre SOLO las páginas de pieza.
- Verificación en dos frentes:
  1. **Repo real:** regeneración → byte a byte idéntico a la línea base (condición 6: con 0 publicadas no cambia nada) y `parse()` limpio.
  2. **Clon** (`/tmp/slep_v7_clon`, condición 3): repetir el paso 1 del guion del ensayo (publicar la pieza candidata con firma sintética), regenerar el clon y verificar que la URL de la pieza APARECE en el índice de Pagefind y que las 25 normas siguen indexadas (25 + 1). Control en ambas direcciones: antes del cambio el clon daba 0 piezas indexadas; después, 1.
- Commit: `fix(sitio): piezas publicadas indexadas en el buscador (E-c del ensayo)`.

### Cierre — push y adenda

- Push de T3 + T2; verificación del run (verde, autoprueba en verde); adenda al log con la evidencia; push solo-documentación final.

## 6. Exclusiones declaradas

- E-d (anclas rancias de las 2 FAQ): pendiente operativo de la vía A; el pipeline ya avisa y abortaría su publicación.
- No-determinismo de `estado` del manifiesto y `pagefind-entry.json`: traspaso v02.
- Todo lo demás que ya vive en gates: slug del DFL 1, publicación real, cierre de sesión.

## 7. Auto-auditoría, log y reporte

- Re-derivación por comandos distintos en las tres tareas; el conteo Pagefind del clon se mide con un instrumento que primero demuestre que encuentra una URL de norma conocida (prueba de humo, lección v6).
- Log en `50_documentacion/andamios/logs/20260827_cierre_calidad_v7_log.md`, plantilla fija, con la delegación de T3 registrada en §7.
- Reporte al chat: hashes, evidencia por tarea (incluido el 25+1 del clon), congeladas con su duda, ruta del log, y "lo que falló o sorprendió; si nada, decirlo explícitamente". **La sesión queda abierta.**
