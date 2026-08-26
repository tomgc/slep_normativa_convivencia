# Encargo autónomo — avance de máquina v2, sesión 2

Proyecto: `slep_normativa_convivencia`. Patrón: `encargo_autonomo_claude_code_v1.md` (v1.3). Sucede a `20260826_encargo_avance_maquina_v1.md`; incorpora las autorizaciones que resuelven la Duda 1 y la desviación de subagentes del log anterior.

## 1. Contrato

- **Modo:** autónomo, secuencial, todo en este turno. Subagentes: SOLO de solo-lectura para el panel adversarial de TC, tope duro 2. **Todo prompt de subagente declara explícitamente: análisis en R o jq exclusivamente, Python prohibido (CLAUDE.md §7), sin escritura en el repositorio.**
- **ENTORNO:** filesystem local vía Claude Code, raíz `~/Projects/slep_normativa_convivencia`, macOS, R 4.5.2, Quarto 1.9.38 (fuente: log `20260826_avance_maquina_log.md`, leído por el redactor en esta sesión de chat).
- **INSUMOS:** todos por ruta desde la raíz; ninguno se adjunta. Claves: `.github/workflows/publicar.yml`, `00_generar_borradores.R`, `30_procesamiento/34_generar_paginas.R`, `20_insumos/curaduria/metadatos_curados.json` (solo lectura), `40_salidas/datos/relaciones.json`, `20_insumos/ocr/manifiesto_ocr.json`, `50_documentacion/andamios/logs/20260826_avance_maquina_log.md`, `CLAUDE.md`.
- **POSICIÓN:** toda ruta completa desde la raíz; ningún comando asume `cd` previo ni estado heredado; scripts bajo `bash` explícito o `Rscript`. Primera acción de FASE 0: `git fetch` y comparación de `HEAD` local contra `origin/main`.

### Regla de detención (lista medible)

1. Si `git status --porcelain` muestra algo distinto de vacío o de la única entrada tolerada `?? 50_documentacion/andamios/20260826_encargo_avance_maquina_v2.md` (este encargo, recién copiado por el titular) → detén la SESIÓN. Si muestra exactamente esa entrada, commitéala primero (`docs(andamios): encargo avance de maquina v2`) y sigue.
2. Si `50_documentacion/activa/ESTADO.md` no contiene `sesion_abierta: true` y `commit_cierre: 358e150` → detén la SESIÓN.
3. Si los conteos base difieren de 550 relaciones y 88 descartes en `40_salidas/datos/relaciones.json` → detén la SESIÓN (otro proceso tocó las salidas).
4. Si el conteo N96 de descartes cuyo destino es el DFL 1 citado "de 1996" difiere de 21 → congela TC, registra la duda con el valor real; no ajustes la meta.
5. Si `20_insumos/curaduria/metadatos_curados.json` NO contiene aún `anios_alternativos` con 1996 en la entrada del DFL 1 → congela TC con la duda "línea de curaduría pendiente de escritura humana" y sigue con las demás tareas.
6. Si tras el cambio de TA el diff de `.github/workflows/publicar.yml` toca cualquier línea que no sea una versión de action → revierte SOLO ese archivo (autorización abajo) y congela TA.
7. Si la verificación funcional de TB no puede hacerse sin ejecutar `00_generar_borradores.R` completo → congela TB (ese script no se ejecuta en este encargo; ver TB, Paso 0).
8. Cualquier estado, conteo o resultado no enumerado en este encargo → congela ESTA tarea, regístrala como duda (4.8) y sigue con la próxima tarea independiente.

### Autorizaciones (lista cerrada)

- Escribir y modificar archivos SOLO en: `.github/workflows/publicar.yml`, `00_generar_borradores.R`, `10_utils/10_utils.R` (solo para la definición compartida de TB), `30_procesamiento/`, `40_salidas/` (solo vía regeneración por pipeline), `50_documentacion/andamios/` y `50_documentacion/andamios/logs/`.
- Copias temporales de trabajo bajo `/tmp` para arneses y controles positivos (TB y TD), de solo consumo local, borradas al cerrar; nada del repo se modifica desde ellas.
- `git add 20_insumos/curaduria/metadatos_curados.json` SOLO en TC y SOLO si el diff contiene únicamente la línea escrita por el equipo (condición 5 verificada): commitear la escritura humana está autorizado; editarla, no.
- Lectura web SOLO sobre: github.com (incluye docs.github.com), bcn.cl, leychile.cl, supereduc.cl, diariooficial.interior.gob.cl. Solo lectura.
- `gh` SOLO en subcomandos de lectura: `gh run list`, `gh run view`, `gh api` con método GET. Ningún subcomando que escriba en GitHub.
- `Rscript 00_run_all.R` (o los pasos 33-36 individualmente) para regenerar salidas en TC; `Rscript -e` para parseo de YAML, arneses de prueba y conteos.
- `git add <rutas explícitas>` (nunca `git add .`), un commit atómico por tarea completada, `git push` único al final, condicionado a que toda verificación intermedia haya pasado.
- `git checkout -- <ruta>` SOLO para revertir una tarea congelada por las condiciones 6 o análogas, únicamente sobre los archivos que esa tarea tocó, con la lista impresa antes de ejecutar.
- Nada más.

### Reglas canónicas heredadas (referencia, no copia)

`CLAUDE.md` §7 (R-only, aplica también a subagentes) y §10; traspaso v01 §12: ⚠️ ningún script escribe en `20_insumos/curaduria/` ni `20_insumos/ocr/`; ⚠️ nada editado a mano en `40_salidas/`; ✅ antes de tocar el derivador, el diff de `relaciones.json` se re-deriva y los descartes/supresiones quedan registrados; 🔒 cita textual, trazabilidad por badge, solo derecho chileno, anclas públicas estables, reproducibilidad de `40_salidas/`.

## 2. Estado de partida (premisas marcadas)

- `HEAD` local esperado en `515d2e3` o posterior de la misma cadena pusheada (hipótesis, se mide en FASE 0 contra `origin/main`).
- 550 relaciones y 88 descartes vigentes (hipótesis, se mide en FASE 0; es condición de detención 3).
- 21 de los 88 descartes corresponden al DFL 1 citado "de 1996" (hipótesis, se mide en FASE 0; condición 4; el valor 21 proviene del log anterior, no de este entorno).
- El workflow ya fija `node-version: '22'`; el aviso de deprecación viene del runtime de las actions `checkout@v4`, `setup-node@v4`, `upload-pages-artifact@v3`, `deploy-pages@v4`, `configure-pages@v5`, `r-lib/actions/setup-r@v2`, `quarto-dev/quarto-actions/setup@v2` (fuente: log anterior; la lista exacta se re-lee del archivo en FASE 0 y prevalece la del archivo).
- `00_generar_borradores.R` define un `nombre_corto()` propio alrededor de la línea 39 (hipótesis, se mide en FASE 0 con grep; la línea exacta la fija el archivo, no este encargo).
- No se sabe dónde escribe `00_generar_borradores.R`; se presume que escribe en `20_insumos/curaduria/piezas/borradores/` (hipótesis, se mide en FASE 0 leyendo sus rutas de salida; si escribe ahí, el script NO se ejecuta: condición 7).
- El mecanismo `anios_alternativos` ya existe y se usa para el dictamen 52/77 (hipótesis, se mide en FASE 0 localizando esa entrada en `metadatos_curados.json` y su consumo en `33_relaciones.R`).
- La entrada del DFL 1 puede o no tener ya `anios_alternativos: [1996]` escrito por el equipo (hipótesis, se mide en FASE 0; gobierna la condición 5).
- El manifiesto OCR y el traspaso discrepan en la cifra de páginas (84/5 documentos vs 75/4 carpetas medidas) (fuente: log anterior e inconsistencia registrada en el acuse de esta sesión; TD la documenta, no la corrige).
- La verificación del CI en verde para `c774ebc` quedó diferida por falta de `gh` (fuente: log anterior §10; se cierra en TA).

## 3. Contexto mínimo

Continuación inmediata del encargo v1 dentro de la misma sesión 2. Cuatro tareas: descongelar T3 con el dominio que faltaba, cerrar la Duda 4, consumar la corrección de curaduría de la Duda 2 (la línea la escribe el equipo; tú regeneras y verificas) y documentar la discrepancia de cifra OCR. La Duda 3 (slug del DFL 1) está pendiente de decisión del titular: NADA en este encargo renombra slugs, mueve anclas ni incorpora normas nuevas.

## 4. Invariantes (🔒)

- 🔒 Ningún estado `ocr_revisado` se cierra, ningún tema se aprueba, ninguna pieza interpretativa se publica.
- 🔒 `20_insumos/curaduria/` y `20_insumos/ocr/` son de escritura humana exclusiva: este encargo los LEE, jamás los escribe.
- 🔒 `40_salidas/` solo cambia por regeneración del pipeline.
- 🔒 Anclas públicas estables: ningún slug, ruta ni ancla publicada cambia (la Duda 3 sigue abierta).
- 🔒 Toda cifra reportada se recuenta programáticamente en el turno que la reporta.

## 5. Cadena de tareas y grafo de dependencias

Grafo: TA, TB, TC y TD son mutuamente independientes; todas requieren FASE 0. TC tiene además una precondición externa (la línea de curaduría escrita por el equipo, condición 5): si falta, se congela sin arrastrar a nadie. Orden de ejecución: TD → TA → TB → TC (TC al final, para dar la máxima ventana a la escritura humana; si al llegar a TC la línea no está, congélala e igual cierra la cadena).

### FASE 0 — Medición de hipótesis (sin modificar nada)

1. `git fetch`; `git status --porcelain` (condición 1); `HEAD` vs `origin/main`.
2. `cat 50_documentacion/activa/ESTADO.md` → `sesion_abierta: true`, `commit_cierre: 358e150`.
3. Conteos de `relaciones.json` → 550 y 88 (jq o R).
4. Conteo N96: descartes cuyo destino es el DFL 1 con año citado 1996 → esperado 21. Guarda el comando: es el instrumento de calibración de TC.
5. `grep -n 'anios_alternativos' 20_insumos/curaduria/metadatos_curados.json` → localiza la entrada del dictamen 52/77 (patrón existente) y comprueba si la del DFL 1 ya está (gobierna condición 5).
6. `grep -n 'nombre_corto' 00_generar_borradores.R` y lectura de sus rutas de salida (gobierna condición 7).
7. Lectura completa de `.github/workflows/publicar.yml`; lista real de actions y versiones.
8. `gh run list --limit 5` → estado del workflow para los pushes de hoy (cierra la verificación diferida de `c774ebc`).
9. Lectura de `20_insumos/ocr/manifiesto_ocr.json` → documentos y páginas que declara (insumo de TD).

### TD — Nota documental: la cifra OCR (solo lectura)

- Producto: `50_documentacion/andamios/20260826_nota_cifra_ocr_v1.md`, breve: qué declara el manifiesto OCR, qué hay en disco (carpetas y `pagina_*.txt`), por dónde entró la transcripción del dictamen 078 (rastrea `origen_texto` en curaduría y su consumo en `31_extraer_texto.R` o donde corresponda), y de dónde sale exactamente la cifra "84 páginas / 5 documentos" del traspaso: qué suma reproduce y cuál es la cifra correcta para el traspaso v02, con el comando que la produce.
- Criterio de éxito: la nota reconcilia ambas cifras con evidencia por comando, o declara la fuente de la cifra 84 como no reproducible; calibración: el conteo de disco debe reproducir 75 (caso bueno conocido) y detectar una página plantada en copia temporal fuera de `20_insumos/` (caso malo dispara).
- Commit: `docs(andamios): nota de reconciliacion de cifra OCR`.

### TA — Actions del CI al runtime vigente (descongela T3; resuelve Duda 1)

- Paso 0: releer el workflow completo; para CADA action con aviso de deprecación, verificar su versión mayor vigente en su repositorio oficial en github.com (README o releases). Ninguna versión sale de memoria: cada una con su URL leída en este turno.
- Actualizar SOLO las líneas `uses:` que corresponda. Diff mínimo (condición 6).
- Verificación (condiciona el commit): (a) `Rscript -e 'yaml::read_yaml(".github/workflows/publicar.yml")'` parsea; (b) el diff contiene únicamente cambios en líneas `uses:`; calibración de (b): el chequeo debe fallar si el diff tocara cualquier otra clave (pruébalo sobre un diff sintético con un nombre de job cambiado: dispara; sobre el diff real limpio: calla).
- Tras el push final de la cadena: `gh run view` del run disparado → estado en verde o, si el run aún corre al cerrar el turno, repórtalo como verificación diferida CON el id del run para consultarlo.
- Commit: `fix(ci): actions al runtime vigente, elimina aviso de deprecacion`.

### TB — Alinear `nombre_corto()` del generador de borradores (resuelve Duda 4)

- Paso 0: leer `00_generar_borradores.R` completo y el `nombre_corto()` ya corregido de `30_procesamiento/34_generar_paginas.R`. Si el generador escribe en `20_insumos/curaduria/`, NO se ejecuta (condición 7): la verificación es a nivel de función.
- Preferencia de diseño (decides tú si el código lo permite): una sola definición compartida (p. ej. movida a `10_utils/10_utils.R` y consumida por ambos scripts) antes que dos copias alineadas; dos copias idénticas son el bug de mañana. Si compartirla exige refactor que toque más de lo quirúrgico (B.3), alinea las copias y registra la deuda como duda.
- Verificación (condiciona el commit): arnés en `Rscript -e` que carga SOLO las funciones necesarias (sin ejecutar el flujo del generador), aplica `nombre_corto()` a los dos slugs del REX 482 y comprueba que produce los rótulos distintivos `(resolución)` / `(cuerpo)` idénticos a los del sitio; calibración: el mismo arnés corrido sobre la versión previa del archivo (vía `git stash` o copia temporal fuera del repo) debe fallar mostrando los rótulos duplicados (caso malo dispara), y pasar tras el cambio (caso bueno calla). Además: `git status --porcelain -- 20_insumos/` vacío tras el arnés.
- Commit: `fix(borradores): nombre_corto alineado con grupo_acto` (o `refactor(utils): ...` si se comparte la definición).

### TC — Regeneración y verificación post-curaduría (consuma Duda 2)

- Paso 0: repetir la medición 5 de FASE 0. Si `anios_alternativos` con 1996 NO está en la entrada del DFL 1 → congela TC (condición 5) y termina la cadena con las demás tareas.
- Si está: verificar que el diff de `20_insumos/curaduria/metadatos_curados.json` contra `HEAD` contiene SOLO esa adición (cualquier otra línea cambiada → congela TC, duda). Commitear la línea del equipo como commit propio ANTES de regenerar: `data(curaduria): anios_alternativos 1996 para dfl_1 (decision del titular, duda 2)`.
- Regenerar con `Rscript 00_run_all.R`.
- Verificación (condiciona el commit de salidas), toda programática, sin aritmética manual:
  (a) el contador N96 de FASE 0, corrido sobre los descartes nuevos → 0 (calibración: ese mismo contador dio 21 antes de la regeneración; dispara sobre el estado previo, calla sobre el nuevo);
  (b) existen las relaciones `dfl_315 → dfl_1` y `ley_21809 → dfl_1`;
  (c) `dto_453 → dfl_1` declara `n_citas >= 18`;
  (d) descartes finales == 88 − N96 (ambos operandos medidos por comando en este turno);
  (e) el diff de `relaciones.json` solo agrega o modifica relaciones con destino DFL 1 y solo elimina descartes con destino DFL 1; cualquier otra diferencia → congela TC y revierte las salidas regenerándolas desde `HEAD` (checkout del JSON de curaduría NO: esa línea es del equipo);
  (f) verificador de enlaces internos calibrado (control positivo con enlace plantado) → 0 rotos;
  (g) manifiesto de incorporación 25/0/0.
- Panel adversarial (tope 2 subagentes solo-lectura, R/jq, Python prohibido): re-derivar (a)-(d) con código propio antes de reportar.
- Commit de salidas: `fix(relaciones): restituye remisiones al dfl_1 via anios_alternativos`.

## 6. Exclusiones declaradas

- Duda 3 (slug del DFL 1 / Ley 21.109): gate del titular pendiente; nada se renombra ni incorpora.
- Corrección de las líneas OCR (incluida la `у` cirílica): escritura humana exclusiva.
- Cierre de estados, temas, piezas; fases 3-4; ordenación §4.7; diseño visual: mismos motivos del encargo v1.
- Reintento de los 2 términos "no hallada" del glosario: la búsqueda ya quedó documentada; repetirla sin fuente nueva es convergencia sin criterio.

## 7. Auto-auditoría, log y reporte

- TC con panel adversarial (riesgo de datos); TA, TB y TD con re-derivación por comandos distintos de los que produjeron el resultado.
- Log de cierre en `50_documentacion/andamios/logs/20260826_avance_maquina_v2_log.md`, plantilla fija del patrón (secciones 1-10, decisiones autónomas con alternativa y reversibilidad, dudas como pendiente accionable con pregunta cerrada). Commit `docs()` atómico.
- Push único al final; luego la verificación de CI de TA.
- Reporte al chat: hashes por commit, verificaciones con evidencia, tareas congeladas con su duda, ruta del log, y "lo que falló o sorprendió; si nada, decirlo explícitamente".
