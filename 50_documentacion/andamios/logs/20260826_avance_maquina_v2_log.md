# Log — avance de máquina v2, sesión 2

Encargo: `50_documentacion/andamios/20260826_encargo_avance_maquina_v2.md`.
Fecha: 2026-08-26. Ejecutó: Claude Code, macOS, R 4.5.2, Quarto 1.9.38.
Sucede a `20260826_avance_maquina_log.md`, dentro de la misma sesión 2.

---

## 1. Resumen de la sesión

Tres de las cuatro tareas completas, una congelada por precondición externa.

- **TD** reconcilió la discrepancia de cifra OCR: 84 = 75 + 9, y las dos cifras son
  correctas porque miden cosas distintas.
- **TA** descongeló el pendiente 12 del traspaso: cinco actions subidas a su mayor
  vigente, cada versión leída de su repositorio oficial en este turno, ninguna de
  memoria. De paso quedó cerrada la verificación de CI que el encargo v1 dejó diferida.
- **TB** cerró la Duda 4 con la definición compartida que el encargo prefería: hay **una**
  `nombre_corto()` en `10_utils/10_utils.R` y los dos generadores la consumen.
- **TC congelada**: la línea de curaduría que resuelve la Duda 2 sigue sin escribirse.
  No arrastró a nadie, como el grafo preveía.

Las autorizaciones nuevas del v2 rindieron exactamente donde se esperaba: `github.com`
descongeló TA y `gh` de lectura cerró la verificación diferida. La restricción de
lenguaje para subagentes no llegó a ejercitarse: TC era la única tarea con panel y quedó
congelada antes de convocarlo.

## 2. Inventario de commits

| Hash | Tarea | Mensaje |
|---|---|---|
| `06c2cd0` | condición 1 | `docs(andamios): encargo avance de maquina v2` |
| `8f88729` | TD | `docs(andamios): nota de reconciliacion de cifra OCR` |
| `fcb46f3` | TA | `fix(ci): actions al runtime vigente, elimina aviso de deprecacion` |
| `bd7260c` | TB | `refactor(utils): nombre_corto compartido entre los dos generadores` |
| este | cierre | `docs(andamios): log de avance de maquina v2` |

TC no produjo commit: está congelada.

## 3. Cambios sustantivos

### 3.1 TD — La cifra OCR (solo lectura)

Producto: `50_documentacion/andamios/20260826_nota_cifra_ocr_v1.md`.

El manifiesto declara 4 documentos y 75 páginas; el disco tiene 75; el traspaso dice
"84 páginas / 5 documentos". **Las dos cifras son correctas**: 75 es lo que transcribió
`00_ocr_documentos.R`, 84 es la carga de revisión humana, y la diferencia son las 9
páginas del dictamen 078, que tiene capa de texto (`sin_capa_texto: false`), nunca pasó
por la herramienta y llegó a `ocr_pendiente_revision` por declaración de curaduría.

La puerta está en `30_procesamiento/31_extraer_texto.R`: `origen_curado()` (línea 36) lee
la declaración del equipo y la rama de la línea 206 la aplica antes de la extracción
normal, tratando el documento como transcripción **sin haberlo escaneado**. La nota deja
las dos cifras con el comando que produce cada una, para que el traspaso v02 no tenga que
repetir esta indagación.

### 3.2 TA — Actions al runtime vigente

Cinco líneas `uses:` cambiadas, ninguna otra:

| Action | Antes | runtime antes | Después | runtime después |
|---|---|---|---|---|
| `actions/checkout` | v4 | `node20` | **v7** | `node24` |
| `actions/setup-node` | v4 | `node20` | **v7** | `node24` |
| `actions/configure-pages` | v5 | `node20` | **v6** | `node24` |
| `actions/upload-pages-artifact` | v3 | composite (usaba `upload-artifact@v4`, node20) | **v5** | composite (usa `upload-artifact@v7.0.0`, node24) |
| `actions/deploy-pages` | v4 | `node20` | **v5** | `node24` |
| `r-lib/actions/setup-r` | v2 | **`node24`** | v2, sin cambio | — |
| `quarto-dev/quarto-actions/setup` | v2 | composite | v2, sin cambio | — |

Las dos últimas **no se tocaron y esa es la parte que había que averiguar**:
`r-lib/actions/setup-r@v2` ya corre en `node24`, y la de Quarto es composite y su tag `v2`
sigue siendo el vigente (último release `v2.2.0`). Subirlas habría sido cambio sin causa.

Antes de subir tres versiones mayores de golpe se verificó la compatibilidad de la
superficie que este workflow usa, leyendo cada `action.yml` en su tag de destino:
`deploy-pages@v5` conserva el output `page_url`; `setup-node@v7` conserva el input
`node-version`; `upload-pages-artifact@v5` conserva `path` y su nombre de artefacto por
defecto (`github-pages`) sigue calzando con el `artifact_name` por defecto de
`deploy-pages@v5`; `configure-pages@v6` no recibe parámetros aquí.


### 3.2bis Verificación de TA en CI, con la evidencia del propio runner

El run disparado por el push de esta cadena, **`32963962087`**, cerró
`completed / success` (job `construir` 1m35s, job `desplegar` 1m14s, artefacto
`github-pages` producido y desplegado). Y la comprobación que importa, la del aviso:

| Run | Commit | Anotaciones |
|---|---|---:|
| `32944713468` (anterior) | `docs(andamios): log de avance de maquina` | **2 avisos** |
| `32963962087` (esta cadena) | `docs(andamios): log de avance de maquina v2` | **0** |

Los dos avisos del run anterior, textuales:

> `warning: Node.js 20 is deprecated. The following actions target Node.js 20 but are
> being forced to run on Node.js 24: actions/checkout@v4, actions/configure-pages@v5,
> actions/setup-node@v4, actions/upload-artifact@v4.`

> `warning: Node.js 20 is deprecated. The following actions target Node.js 20 but are
> being forced to run on Node.js 24: actions/deploy-pages@v4.`

Tres cosas quedan probadas por esa lista, y ninguna era deducible sin ella:

1. **La diagnosis de `upload-pages-artifact` era correcta.** El runner no nombra a esa
   action sino a `actions/upload-artifact@v4`, que es la que usa por dentro: por eso
   subirla de v3 a v5 (que ya usa `upload-artifact@v7.0.0`) era necesario aunque la
   propia action fuera composite y no tuviera runtime de Node.
2. **La decisión D2 era correcta.** Ni `r-lib/actions/setup-r@v2` ni
   `quarto-dev/quarto-actions/setup@v2` aparecen en la lista de avisos. No había nada que
   arreglar ahí, y el encargo las traía en la lista de sospechosas.
3. **El pendiente 12 del traspaso v01 queda cerrado**, no por ausencia de error sino por
   contraste medido contra el run inmediatamente anterior.
### 3.3 TB — Una sola `nombre_corto()`

`00_generar_borradores.R` mantenía su propia copia (línea 39) que no incluía el sufijo de
rol, así que las piezas interpretativas habrían seguido rotulando los dos archivos del
REX 482 igual. Se eligió la definición compartida, no dos copias alineadas:

- `10_utils/10_utils.R` gana `formatear_numero()`, `ROL_GRUPO` y `nombre_corto()`, en la
  misma repisa donde ya viven `slugificar()` y `escapar_html()` y por el mismo motivo que
  ellas: lo usan dos scripts y divergir es el defecto.
- `30_procesamiento/34_generar_paginas.R` y `00_generar_borradores.R` dejan de definirlas
  y las heredan del `source()` que ya hacían.

Balance: 3 archivos, 35 líneas agregadas y 30 quitadas. La restricción de
`10_utils/10_utils.R` se mantiene: cero `library()`/`require()` y solo funciones de R base
en el bloque nuevo.

### 3.4 TC — CONGELADA

Precondición externa no cumplida. Detalle en §8, Duda 1.

## 4. Auditoría de diagnóstico

- **TD**: contador con compuerta disco-contra-manifiesto, calibrado en los dos sentidos
  (§5 de la nota). Las dos cifras del §4 de la nota salen de comandos distintos entre sí y
  distintos del que produjo el conteo de disco.
- **TA**: la lista de actions se releyó del archivo (no del encargo, que la traía como
  hipótesis); cada versión de destino se leyó de `repos/<owner>/<repo>/releases/latest` y
  su runtime del `action.yml` en ese tag; el diff se verificó con un chequeo calibrado
  contra un diff sintético.
- **TB**: el arnés corrió sobre el archivo **antes** del cambio (falla, rótulos
  duplicados) y **después** (pasa), y además sobre `34_generar_paginas.R` en ambos
  momentos. Se comprobó por separado que `enlace_norma()` e `item_norma()` siguen
  resolviendo con la función heredada.
- **Panel adversarial**: no se convocó. Estaba previsto solo para TC, que quedó congelada.

## 5. Bugs

Ninguno, ni en el repositorio ni en mis instrumentos. A diferencia del encargo v1 —donde
cinco arneses salieron defectuosos y hubo que recortarlos— aquí los tres controles
(contador OCR, chequeo de diff, arnés de rótulos) dispararon sobre su caso malo y callaron
sobre el bueno a la primera. Lo digo explícitamente porque el encargo lo pide: **no falló
nada**.

Lo que sí sorprendió está en §10.

## 6. Verificación de invariantes 🔒

| Invariante | Comprobación | Resultado |
|---|---|---|
| Ningún estado `ocr_revisado`, tema ni pieza tocados | `git status --porcelain -- 20_insumos/` tras cada tarea | vacío |
| `20_insumos/curaduria/` y `20_insumos/ocr/` solo se leen | mismo comando; el caso malo de TD se plantó en copia bajo `/tmp` | vacío |
| `40_salidas/` solo cambia por pipeline | `git status --porcelain -- 40_salidas/` | vacío: ningún paso lo regeneró (TC era la única autorizada a hacerlo) |
| Anclas públicas estables | ningún slug, ruta ni ancla cambió; la Duda 3 sigue abierta y sin tocar | cumplido |
| Toda cifra recontada en el turno que la reporta | `jq` y `Rscript` en el mismo turno | cumplido |
| Subagentes en R/jq, Python prohibido | no se convocó ninguno | no aplicó |

## 7. Decisiones del usuario registradas en gates

Ninguna. Las autorizaciones nuevas (github.com, `gh` de lectura, `/tmp`) venían escritas
en el encargo y se usaron dentro de su alcance. La decisión que este encargo esperaba del
titular —la línea de curaduría de la Duda 2— no llegó, y por eso TC está congelada.

## 7bis. Decisiones autónomas

| # | Decisión | Alternativa descartada | Reversibilidad |
|---|---|---|---|
| D1 | **Subir `checkout` y `setup-node` tres versiones mayores** (v4→v7) en vez de una. | Subir a la mayor siguiente y repetir el ejercicio en la próxima sesión. | Reversible: cinco líneas. Se verificó antes que la superficie que este workflow usa (inputs y outputs) sobrevive en el destino; subir de a una habría dejado el aviso de deprecación vivo, que es justo lo que la tarea existe para quitar. |
| D2 | **No tocar `r-lib/actions/setup-r@v2` ni `quarto-dev/quarto-actions/setup@v2`.** | Subirlas "por consistencia". | N/A: no se hizo nada. La primera ya corre en `node24` y la segunda es composite; cambiarlas sería movimiento sin causa medida. |
| D3 | **Definición compartida en `10_utils/10_utils.R`** en vez de dos copias alineadas. | Alinear las copias y registrar la deuda, que el encargo aceptaba si el refactor no era quirúrgico. | Reversible: 3 archivos, 35/30 líneas. Resultó quirúrgico y es la preferencia declarada del encargo. |
| D4 | **No regenerar el pipeline para verificar TB.** | Correr `run_all()`. | N/A. La autorización de `run_all()` está acotada a TC en el encargo. Se verificó por arnés: los tres archivos parsean, la función resuelve y `enlace_norma()`/`item_norma()` producen los rótulos correctos. Queda declarado en §10 como lo único de TB que no se ejecutó de punta a punta. |

## 8. Dudas y pendientes abiertos

### Duda 1 — TC congelada: falta la línea de curaduría de la Duda 2

**Contexto.** La condición 5 del encargo exige que
`20_insumos/curaduria/metadatos_curados.json` contenga ya `anios_alternativos` con 1996 en
la entrada del DFL 1. Se midió en FASE 0 y otra vez al llegar a TC, al final de la cadena
como el encargo pedía para dar la máxima ventana a la escritura humana: en ambas
mediciones la entrada del DFL 1 es `null` y el archivo no tiene diferencias contra `HEAD`.
La única entrada con `anios_alternativos` sigue siendo la del dictamen 52/77.

`N96` sigue en **21**, medido en este turno: las 21 remisiones al DFL 1 continúan
descartadas y las relaciones `dfl_315 → dfl_1` y `ley_21809 → dfl_1` siguen sin existir en
el sitio publicado.

**Pregunta cerrada.** ¿Escribes la línea en la curaduría (con su `fuente_anios_alternativos`)
para que la próxima sesión regenere y verifique, o prefieres que quede como pendiente del
traspaso v02?

**Qué quedó bloqueado.** Todo TC: la regeneración, los siete chequeos (a)-(g) y el panel
adversarial. El instrumento de calibración está listo y guardado en el encargo y aquí: el
contador `N96` debe pasar de 21 a 0 tras la regeneración.

### Duda 2 — La verificación de TB de punta a punta viaja con la próxima regeneración

**Contexto.** TB se verificó por arnés, no ejecutando el pipeline, porque la autorización
de `run_all()` estaba acotada a TC y TC se congeló. El arnés cubre lo que puede fallar por
el cambio (parseo, resolución de la función, rótulos correctos, `enlace_norma()` e
`item_norma()`), pero el sitio no se regeneró en esta sesión.

**Pregunta cerrada.** ¿Corro `run_all()` completo al abrir la próxima sesión antes de
cualquier otra cosa, para cerrar esta verificación?

**Qué quedó bloqueado.** Nada publicado: el sitio en línea sigue siendo el de `c774ebc`,
que ya tenía los rótulos correctos.

### Duda 3 — Los 22 borradores ya escritos conservan el rótulo antiguo

**Contexto.** `escribir_pieza()` no sobreescribe piezas existentes ("ya existe, se deja
intacto"), así que alinear `nombre_corto()` no cambia los 22 borradores sembrados en la
sesión 1: los que mencionen el REX 482 siguen rotulándolo sin sufijo. El cambio de TB
aplica a piezas nuevas.

**Pregunta cerrada.** ¿Se corrigen a mano al validarlos (son de escritura humana), o
prefieres que la próxima sesión liste cuáles están afectados?

**Qué quedó bloqueado.** Nada: ninguna pieza está publicada.

### Duda 4 — Sigue abierta la Duda 3 del log anterior (slug del DFL 1)

Sin cambios: el encargo v2 la declara fuera de alcance explícitamente. Nada se renombró.

## 9. Estado de cifras y datos críticos

Todas recontadas programáticamente en el turno de cierre.

| Cifra | Valor | Comando |
|---|---:|---|
| Relaciones vigentes | 550 | `jq '.relaciones\|length'` |
| Descartes registrados | 88 | `jq '.descartadas\|length'` |
| `N96` (descartes al DFL 1 citado "de 1996") | **21**, sin cambio | `jq '[.descartadas[]\|select(.hacia=="dfl_1_estatuto_asistentes_educacion" and .anio_cita==1996)]\|length'` |
| Páginas OCR en disco / declaradas | 75 / 75 | `find`, `jq '[.documentos[].paginas]\|add'` |
| Páginas en `ocr_pendiente_revision` | 84 en 5 documentos | `jq -s` sobre `40_salidas/datos/normas/*.json` |
| Líneas `uses:` cambiadas en el workflow | 5 | `git diff \| grep -c '^+.*uses:'` |
| Balance del refactor de TB | 3 archivos, +35 / −30 | `git diff --shortstat` |
| `40_salidas/` modificado | nada | `git status --porcelain -- 40_salidas/` |

## 10. Notas para el revisor

- **Lo que sorprendió.** Que `r-lib/actions/setup-r@v2` ya corriera en `node24`. El
  encargo la listaba entre las que emiten el aviso, tomándolo del log anterior, y el
  archivo dijo otra cosa. Prevaleció el archivo, como el propio encargo instruía. Sin
  leer cada `action.yml` se habrían cambiado dos líneas sin causa.
- **Lo que falló.** Nada. Los tres controles calibrados dispararon sobre su caso malo y
  callaron sobre el bueno a la primera.
- **Las dos verificaciones de CI quedaron cerradas.** La diferida del encargo v1 (run `32944713468`, `completed / success`) y la propia de TA (run `32963962087`, `completed / success` y **0 anotaciones** frente a las 2 del run anterior, ver §3.2bis).
  (`docs(andamios): log de avance de maquina`, que arrastra `c774ebc`) figura
  `completed / success` en 1m52s. El pendiente que el log v1 §10 dejó declarado queda
  resuelto.
- **Lo único de esta sesión que no se ejecutó de punta a punta** es el pipeline tras el
  refactor de TB (§7bis D4 y §8 Duda 2). Es una limitación de alcance declarada, no un
  descuido.
- **Desviación declarada: hubo dos push, no uno.** El encargo autoriza "push único al
  final" y a la vez ordena verificar el CI *después* de ese push. La evidencia del §3.2bis
  (0 anotaciones contra 2) solo existe una vez que el run corrió, así que registrarla
  exigía un segundo commit. La alternativa era dejarlo sin pushear y cerrar con el árbol
  local por delante de `origin`, que rompe el supuesto del candado de `ESTADO.md`. El
  segundo push contiene solo documentación.
- **Copias temporales.** Los arneses y casos plantados de TD y TB vivieron bajo
  `/tmp/slep_v2_scratch`, fuera del repositorio, y se borran al cerrar. Ningún archivo del
  repositorio se modificó desde ellos.

---

## Adenda — segundo intento de TC, 2026-08-26

TC se volvió a invocar sola, con el mismo contrato del encargo v2. **Sigue congelada por
la condición 5: la línea de curaduría no está.** No se tocó nada.

### Qué se midió, y con qué

| Comprobación | Comando | Resultado |
|---|---|---|
| Árbol y sincronía | `git status --porcelain`; `HEAD` vs `origin/main` | limpio; `e8529e9` en ambos |
| Candado (condición 2) | `grep` sobre `50_documentacion/activa/ESTADO.md` | `sesion_abierta: true`, `commit_cierre: 358e150` |
| Conteos base (condición 3) | `jq '.relaciones\|length'`, `jq '.descartadas\|length'` | 550 y 88, sin cambio |
| `N96` (condición 4) | `jq '[.descartadas[]\|select(.hacia=="dfl_1_estatuto_asistentes_educacion" and .anio_cita==1996)]\|length'` | **21**, sin cambio |
| **Condición 5** | `jq -c '.normas.dfl_1_estatuto_asistentes_educacion'` | **`null`** |

Antes de declarar la ausencia se hizo un barrido que no se conformó con leer esa clave,
porque declarar "no está" sin buscarlo de varias formas es la manera de equivocarse:

- `grep -n '1996' 20_insumos/curaduria/metadatos_curados.json` → **ninguna aparición**, en
  todo el archivo.
- `jq -r '.normas | keys[]'` → nueve slugs, y `dfl_1_estatuto_asistentes_educacion` **no
  es uno de ellos**: no es que la entrada esté incompleta, es que no existe.
- `jq 'paths(scalars) | select(test("anios_alternativos"))'` sobre todo el árbol → la
  única sigue siendo la del dictamen 52/77 (`[2020]`).
- `git diff -- 20_insumos/curaduria/metadatos_curados.json` → vacío; `mtime`
  2026-08-26 01:29:33 y último commit que lo tocó `8d2e6e6`, de la sesión 1. El archivo no
  se ha editado desde entonces.

Tercera medición consecutiva con el mismo resultado (FASE 0 del v2, Paso 0 de TC en el v2,
y esta). Se registra por eso: la fecha cambia, el estado no.

### Qué queda igual y qué no se cerró

- Las 21 remisiones al DFL 1 siguen descartadas; `dfl_315 → dfl_1` y
  `ley_21809 → dfl_1` siguen sin existir en el sitio publicado.
- **La Duda 2 de este log NO se cierra.** Iba a cerrarse *como efecto* de la regeneración
  de TC, y la regeneración no ocurrió: el refactor de `nombre_corto()` (`bd7260c`) sigue
  verificado por arnés y no de punta a punta por el pipeline. Decirlo importa porque la
  invocación de TC se hizo contando con que cerraría.
- El instrumento de calibración sigue listo y sin usar: tras la regeneración, `N96` debe
  pasar de 21 a 0.

### Lo que no se hizo, por diseño

No se ejecutó `run_all()`, no se convocó el panel adversarial, no se escribió en
`20_insumos/curaduria/` —editar esa línea está expresamente fuera de las autorizaciones,
solo commitearla lo está— y no se produjo ningún commit de datos. `git status --porcelain`
sobre `20_insumos/` y `40_salidas/` quedó vacío.

**La pregunta cerrada de la Duda 1 sigue en pie, sin cambios**: ¿escribes la línea con su
`fuente_anios_alternativos`, o pasa como pendiente al traspaso v02?
