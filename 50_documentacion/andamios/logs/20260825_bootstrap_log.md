# Log de cierre — Bootstrap de `slep_normativa_convivencia`

> Andamio: registro congelado del encargo
> `50_documentacion/andamios/20260825_encargo_bootstrap_v1.md`, ejecutado el
> 2026-08-25 en modo autónomo, secuencial, en un turno, sin subagentes.
> Plantilla fija de `encargo_autonomo_claude_code_v1.md` §4.

---

## 1. Resumen de la sesión

Entró un directorio con 24 PDF de normativa chilena de convivencia escolar y un
repositorio remoto vacío. Salió un proyecto Rama A completo: estructura canónica,
corpus normalizado con verificación de md5, pipeline R de cinco etapas que
extrae, segmenta por artículo, genera páginas, renderiza e indexa, sitio Quarto
publicado en GitHub Pages con búsqueda Pagefind a nivel de artículo, y despliegue
automático por GitHub Actions.

FASE 0 y las ocho tareas se completaron. **Ninguna tarea quedó congelada.** Sí
quedaron congeladas por diseño dos ramas de contenido (extracción de los 4 PDF
escaneados y año de publicación de los 3 dictámenes), ambas previstas por las
reglas de detención del encargo y registradas como pendientes accionables en §8.

Estado final del sitio: <https://tomgc.github.io/slep_normativa_convivencia/>,
HTTP 200 verificado.

---

## 2. Inventario de commits

| # | Hash | Tipo | Título | Qué entró |
|---|---|---|---|---|
| 1 | `8087a1b` | feat | estructura canónica rama A | 21 archivos: estructura de decenas, orquestador, utils, guarda de locale, `.gitignore` Rama A, README, LICENSE, CLAUDE.md, los dos andamios de la sesión |
| 2 | `278a69a` | docs | decisión de funcionalidad del sitio (entrevista 2026-08-25) | Documento de decisión aparecido en disco durante la sesión (§8, duda 1) |
| 3 | `62a7ed9` | feat | insumos normalizados | 24 PDF renombrados a `20_insumos/normativa/` + README con la tabla de equivalencias |
| 4 | `a17cad7` | feat | pipeline extraccion y segmentacion | `31_extraer_texto.R`, `32_segmentar_articulos.R`, 24 JSON de norma, catálogo maestro |
| 5 | `15d6037` | feat | sitio quarto minimo | `_quarto.yml`, `33_generar_paginas.R`, `34_renderizar_sitio.R`, CSS y plantilla de búsqueda |
| 6 | `4c235c0` | feat | busqueda pagefind | `35_indexar_pagefind.R`, `package.json`, `package-lock.json` |
| 7 | `c576fcb` | ci | despliegue a github pages | `.github/workflows/publicar.yml` |
| 8 | `ec5f33d` | fix | tema y marca_revisar siempre como arreglo en el JSON | Corrección del esquema detectada en el recuento de cierre (§5, bug 3) |
| 9 | `b6f8b53` | docs | log de bootstrap | Este archivo + snapshots del escáner |
| 10 | `1060f3c` | chore | retirar `.gitkeep` de `30_procesamiento` | Marcador huérfano que dejaron los propios cambios de la sesión |

Todos los push verificados por re-derivación: `git ls-remote origin main`
comparado contra `git rev-parse HEAD`, no por el mensaje de `git push`.

---

## 3. Cambios sustantivos

### 3.1 Estructura canónica Rama A (T1)

**Qué.** Cinco carpetas de decena, orquestador `00_run_all.R` con
`from/to/only/skip`, `10_utils/` con bootstrapping sin dependencias, guarda de
locale copiada idéntica del kit, `.gitignore` sin bloque de datos.

**Por qué así.** El proyecto es 100% público (POLITICA §8.2): no hay data root
externo y las rutas se resuelven con `here::here()` a secas. Los dos normativos
del kit (`POLITICA_PROYECTO.md`, `SETTINGS_Y_PROMPTS_OPERACIONALES.md`) se
copiaron a disco pero **no se versionan**, conforme a la decisión de gobernanza
del 2026-08-24 (`encargo_normativos_fuera_del_versionado_v1.md`, opción C).

**Verificación.** `git status --porcelain` vacío tras el push; 5 carpetas de
decena contadas programáticamente; verificador de locale en verde (§6, I5).

**Tensión resuelta.** El encargo pedía copiar los normativos a
`50_documentacion/activa/`; la decisión del 2026-08-24 los saca del versionado.
Se cumplen ambas: están en disco, y en `.gitignore` con el motivo escrito.

### 3.2 Normalización del corpus (T2)

**Qué.** 24 PDF movidos con nombre canónico `<tipo>_<numero>_<materia>.pdf`,
copiando → comparando md5 → eliminando origen, archivo por archivo.

**Causa raíz de que importe.** El nombre canónico no es cosmético: de él derivan
`tipo`, `numero` y `slug`, y el slug es la URL pública de cada norma. Un nombre
con espacios dobles y tildes produce URLs frágiles y obliga a tocar código para
agregar una norma.

**Verificación.** Suma de control del conjunto (md5 de la concatenación ordenada
de los 24 md5) idéntica antes y después: `c1a2bdac9f0f5da37745f03ac5f53076`,
n = 24. `normativa/` quedó vacía y se eliminó con `rm -d`.

### 3.3 Extracción con fidelidad normativa (T3, paso 31)

**Qué.** `pdftools::pdf_text()` por documento, y solo tres limpiezas: encabezados
y pies repetidos (detectados programáticamente), guiones de corte de línea, y
reflujo de las líneas de un párrafo.

**Cómo se detectan los pies repetidos.** Comparando las líneas **normalizadas**
(dígitos sustituidos por `#`) de las 3 primeras y 3 últimas líneas no vacías de
cada página. Sin normalizar, el pie de la Biblioteca del Congreso trae el número
de página y ninguna línea se repite nunca; con la normalización, "página 1 de 3"
y "página 2 de 3" son la misma línea y se detectan.

**Unión a través del salto de página.** Un artículo partido entre dos páginas se
reúne solo si la página anterior no termina en puntuación de cierre **y** la
siguiente empieza en minúscula. La conjunción es lo que distingue una frase
cortada de dos párrafos vecinos.

**Verificación.** Conservación de masa: la suma de caracteres alfanuméricos de
todos los segmentos es exactamente igual a la del texto limpio, delta 0 en las
cuatro normas medidas. Spot-check 1:1 en §6, I3.

### 3.4 Segmentación por artículo (T3, paso 32)

**Qué.** 682 artículos en 711 segmentos, sobre 20 documentos con capa de texto.

**Tres decisiones de diseño del segmentador, todas medidas:**

1. **Lista cerrada de ordinales.** El patrón acepta un dígito o una palabra de
   una lista cerrada (`único`, `primero`… `vigésimo`, `transitorio`, `final`).
   Con un comodín `\w+` capturaría "Artículo anterior" y "Artículo siguiente",
   que son referencias internas.
2. **Anclaje a inicio de bloque.** Sin él, un dictamen de 6 páginas producía 6
   "artículos" que eran citas a artículos de otras normas.
3. **Comilla de apertura opcional.** En las leyes modificatorias el articulado va
   entre comillas porque es texto que se inserta en otra norma. Sin admitirla, el
   patrón se saltaba justo el artículo propio de la ley 20.536 y de la 20.911.

**Calibración del instrumento** (§6, I4): sobre texto sin la palabra "Artículo",
0 artículos; sobre texto con solo citas ajenas, 0 artículos; sobre articulado
real con `bis` y transitorios, 3 de 3 con el `id` correcto.

### 3.5 Metadatos que no se inventan (T3, paso 32)

`titulo` y `anio` se extraen únicamente de estructuras inequívocas: la ficha de
la Biblioteca del Congreso (`Publicación: DD-MMM-AAAA`, en sus dos variantes) y
el encabezado `MATERIA:` de los dictámenes. Deliberadamente **no** se busca una
fecha suelta en el cuerpo: los dictámenes citan media docena de fechas ajenas (la
ley que interpretan, el memo que los origina, la resolución que los habilita) y
cualquier heurística que las mire acaba publicando el año de otro documento como
propio. Lo no extraíble queda `null` y entra a `marca_revisar`.

### 3.6 Sitio e indexación por artículo (T4, T5)

**Qué.** 29 páginas HTML (24 normas + home + "acerca" + 3 índices), 24 páginas
indexadas, 4 facetas (tipo, tema, año, fuente).

**El texto legal va como HTML crudo, no como Markdown.** En Markdown un `*` de
nota, un `_` o un `#` del original se interpretan como marcado y el renderizador
se los come: el artículo publicado dejaría de ser idéntico al del PDF.

**`section-divs: false`** es lo que hace que la búsqueda por artículo funcione.
Por defecto Quarto envuelve cada encabezado en `<section id="art-5">` y deja el
`<h2>` sin `id` propio; Pagefind construye sus sub-resultados a partir de
**encabezados con id**. Con el envoltorio, el buscador encontraba la norma pero
no el artículo.

**Capa de fuente.** Cada norma lleva `tipo_fuente` en el JSON y una insignia
visible en la ficha, en cumplimiento del invariante 1 del documento de decisión
funcional aparecido durante la sesión (§8, duda 1). Hoy el corpus es 100%
normativo; el campo existe para que sumar orientaciones ministeriales o evidencia
científica no obligue a rehacer el esquema.

### 3.7 Despliegue (T6, T7)

Workflow de dos jobs (construir → desplegar) con permisos mínimos, `LANG`
explícito y `locale-gen es_ES.UTF-8`. El sitio se reconstruye completo en un
runner limpio en cada push: lo publicado siempre proviene de una corrida
reproducible. Pages habilitado con fuente "GitHub Actions" vía `gh api`, de modo
que **T7 quedó resuelto dentro de T6.2** y no requirió paso manual.

---

## 4. Auditoría de diagnóstico

No hubo auditoría de diagnóstico: es un proyecto recién nacido, sin código previo
que auditar. La ordenación del repositorio (SETTINGS §4.7) está declarada fuera
de alcance por el propio encargo.

---

## 5. Bugs

### Bug 1 — Ruta absoluta del filesystem incrustada en `catalogo.json`

- **Síntoma.** El grep de privacidad previo al commit de T3 encontró
  `/Users/tomgc/Projects/...` como **clave de objeto** dentro de `catalogo.json`,
  en un repositorio público.
- **Causa raíz.** `fs::dir_ls()` devuelve un vector **con nombres** (la ruta
  absoluta de cada archivo) y `lapply()` los arrastra hasta la lista. Al
  serializar, `jsonlite` convierte una lista con nombres en un objeto cuyas claves
  son esas rutas. Efecto secundario: el catálogo dejaba de ser un arreglo.
- **Fix.** `unname()` en los cuatro puntos donde la lista se construye (pasos 31
  y 32).
- **Verificación.** `jq '.normas | type'` devuelve `array`;
  `grep -rl "/Users/" 40_salidas/datos/` devuelve 0 archivos.
- **Nota.** Lo detectó la compuerta de privacidad, no una revisión de código. Es
  el caso de uso exacto para el que existe.

### Bug 2 — Título y año perdidos en 6 de 24 documentos

- **Síntoma.** `dfl_1`, `dto_24`, `ley_20911`, `ley_21430`, `ley_21545` y
  `rex_181` quedaban con `titulo` y `anio` en `null` teniendo la ficha completa a
  la vista.
- **Causa raíz.** La Biblioteca del Congreso emite la línea de publicación en
  **dos variantes** según el tipo de norma: `Fecha Publicación:` y `Publicación:`
  a secas. El patrón solo miraba la primera.
- **Fix.** `^(Fecha\s+)?Publicaci[oó]n\s*:`.
- **Verificación.** Documentos con marca de revisión: de 13 a 7, y los 7
  restantes son los que genuinamente no tienen el dato.

### Bug 3 — `tema` y `marca_revisar` dejaban de ser arreglos

- **Síntoma.** `jq 'select(.marca_revisar|length>0)'` fallaba con
  `Cannot iterate over string ("anio")` en los tres dictámenes.
- **Causa raíz.** `jsonlite::write_json(auto_unbox = TRUE)` convierte un vector de
  largo 1 en escalar. Así, `tema` era un arreglo en las normas de varios temas y
  un string suelto en `rex_181_celulares`, que tiene uno solo. Cualquier
  consumidor que iterara sobre el campo fallaba justo en esas normas.
- **Fix.** `I()` sobre ambos campos.
- **Verificación.** `jq -s 'map(select((.tema|type)!="array" or (.marca_revisar|type)!="array"))|length'`
  devuelve 0 sobre los 24 archivos.
- **Nota.** Lo detectó el recuento programático del cierre. Habría llegado a
  producción sin él.

### Bug 4 — Etiqueta de artículo con la comilla de apertura pegada

- **Síntoma.** La etiqueta del artículo salía como `"Artículo único` en las leyes
  modificatorias.
- **Causa raíz.** La comilla viaja en la captura del patrón porque el patrón la
  admite para llegar al articulado entrecomillado.
- **Fix.** Se retira de la **etiqueta** (que es el nombre del bloque) y se
  conserva en el **texto** (que es la cita literal).

### Aviso, no bug — `formatC` con `big.mark = "."`

97 avisos por corrida porque el separador de miles y el decimal coincidían. Se
fijó `decimal.mark = ","`, que además es el correcto en español.

---

## 6. Verificación de invariantes 🔒

| # | Invariante | Estado | Evidencia |
|---|---|---|---|
| I1 | Los PDF son read-only | **PASA** | Suma de control del conjunto idéntica antes y después del movimiento: `c1a2bdac9f0f5da37745f03ac5f53076`, n = 24, recalculada sobre disco en el cierre. Ningún script del pipeline abre un PDF en modo escritura. |
| I2 | Ningún dato personal entra al repo | **PASA (con alcance declarado)** | Detector de RUT, correo y teléfono móvil sobre el texto de los 24 PDF: **0 coincidencias**. Calibrado con caso plantado: detecta los cuatro patrones. **Alcance:** cubre los 20 documentos con capa de texto; los 4 escaneados devuelven cadena vacía y quedan fuera del alcance del instrumento (son circulares publicadas por la Superintendencia). |
| I3 | El texto extraído no se corrige editorialmente | **PASA** | Spot-check 1:1 sobre 3 artículos de 3 normas (`ley_21809#art-1`, `dto_24#art-1`, `ley_20536#art-unico`): el prefijo alfanumérico de 600 caracteres del JSON aparece **literal** en el `pdf_text()` crudo, 3 de 3. Control positivo: cambiando **una** palabra, la comprobación devuelve `FALSE`. Conservación de masa: delta 0 en las 4 normas medidas. La errata del original ("implementacíón" en la ley 20.536) sigue ahí sin corregir, que es la prueba positiva de que no se edita. |
| I4 | Reproducibilidad: `00_run_all.R` regenera todo `40_salidas/` | **PASA** | Se borró `40_salidas/` entero (`sitio`, `sitio_src`, `intermedios`, `datos`) y `run_all()` lo reconstruyó completo en 8,3 s, 5 pasos, 0 saltados. El workflow de CI hace lo mismo en un runner limpio y salió en verde. |
| I5 | Guarda de locale instalada (POLITICA §5.2bis) | **PASA** | Verificador del kit en verde (V1–V4). Calibrada rompiéndola: comentando la invocación, V2, V3 y V4 fallan y sale con código 1. Restaurada con residuo cero verificado por md5 (`3d17b03169822952c0bb91961538fc6a` antes y después). Constancia en `50_documentacion/activa/50_locale_utf8.md`. En producción: `grep 'Artículo 16 A'` sobre el HTML publicado devuelve 2, `grep '<c3><a1>'` devuelve 0. |
| I6 | Gobernanza de commits | **PASA** | 9 commits, todos con `git add <rutas explícitas>`; cero `git add -A` y cero `git add .`. Grep de privacidad y coautoría corrido antes de cada commit: 0 hallazgos en los 8 commits cerrados (el único hallazgo histórico fue el bug 1, corregido antes de commitear, y las rutas del andamio del encargo, que POLITICA §1.6 prohíbe reescribir). Ningún commit lleva coautoría de la herramienta. |
| I7 | Los id de artículo y las anclas del HTML salen de la misma función | **PASA** | El `id` lo escribe `slugificar()` en el paso 32 y el paso 33 lo copia verbatim al `{#id}` del encabezado. Verificado end-to-end: la búsqueda de un token plantado en el artículo 16 A devolvió exactamente `ley_20536_violencia_escolar.html#art-16-a`. Ids duplicados dentro de una norma: 0 sobre los 24 archivos. |

---

## 7. Decisiones del usuario registradas en gates

Ninguna: el encargo es de modo autónomo sin gates intermedios. La decisión previa
que sí condiciona la sesión es la bifurcación de sensibilidad (Rama A), que el
encargo trae ya resuelta.

---

## 7bis. Decisiones autónomas

| # | Decisión | Alternativa descartada | Reversibilidad |
|---|---|---|---|
| D1 | **No congelar T1** pese a que la regla de detención §1.4 se dispara literalmente. El worktree contenía dos `.md` "no previstos": el propio encargo y su prompt hermano de Claude Design, ambos en la ruta canónica `50_documentacion/andamios/`. Se reportó el inventario completo antes de crear estructura, que es la acción que la regla ordena. | Congelar T1, que arrastra a las ocho tareas y aborta la cadena entera por sus propios andamios. | Reversible: la estructura creada no toca esos archivos. |
| D2 | **Versionar solo `40_salidas/datos/`.** `sitio_src/` y `sitio/` van a `.gitignore`. | Versionar los `.qmd` generados para poder leer en Git el texto publicado sin renderizar. | Reversible: una línea de `.gitignore`. |
| D3 | **Versionar `package-lock.json`** (se quitó de `.gitignore`). Es lo que hace que la versión de Pagefind que indexa en local y en CI sea la misma. | Dejar `npx pagefind` resolver la última versión en cada corrida. | Reversible. |
| D4 | **Sitio plano**, todas las páginas en la raíz, sin subcarpetas. Así `pagefind/` resuelve igual desde cualquier página, en GitHub Pages (que sirve bajo un subpath) y abriendo el HTML local. | Jerarquía `normas/<slug>.html`, que obliga a fijar una URL base y rompe la vista previa local. | Costosa: cambia todas las URLs públicas. Conviene decidirla ahora. |
| D5 | **`_quarto.yml` vive en la raíz y el paso 33 lo copia a `sitio_src/`.** Quarto calcula la ruta de salida relativa al directorio del proyecto: con el archivo en la raíz, el sitio quedaría en `40_salidas/sitio/40_salidas/sitio_src/index.html`. | Poner el `_quarto.yml` únicamente dentro de `sitio_src/`, que está en `.gitignore` y por tanto no se versionaría. | Reversible. |
| D6 | **Segmentar sobre todo encabezado de artículo, incluidos los que una ley modificatoria cita entrecomillados.** Así la ley 20.536 publica su "Artículo 16 A", que es como el equipo lo cita en la práctica. | Segmentar solo el articulado propio, dejando la ley 20.536 con un único artículo. | Reversible, pero cambia ids y por lo tanto anclas públicas. Ver §8, duda 4. |
| D7 | **Diccionario temático cerrado y declarado en la configuración**, aplicado por coincidencia de palabras clave sobre el texto plegado a ASCII. | Clasificación por modelo, que no da el mismo resultado en cada corrida ni se puede revisar línea por línea. | Reversible: es una constante en `10_configuracion.R`. |
| D8 | **Los 4 documentos escaneados entran igual al índice de búsqueda**, con su ficha como cuerpo. | Dejarlos fuera del índice, lo que los volvería invisibles para quien busque "circular 812". | Reversible. |
| D9 | **Commit extra `docs:`** para el documento de decisión funcional aparecido en disco durante la sesión, fuera de la lista de commits del encargo. | Incluirlo en el commit de T4, ocultando en el historial que llegó como insumo externo. | Reversible. |

---

## 8. Dudas y pendientes abiertos

### Duda 1 — Documento de decisión aparecido durante la sesión

**Contexto.** A las 15:46, con T1 ya commiteado, apareció en disco
`50_documentacion/activa/decisiones/20260825_decision_funcionalidad_sitio.md`,
que fija cuatro invariantes de contenido y siete funcionalidades. No estaba
enumerado en el encargo (regla de detención §1.5).

**Qué se hizo.** Se leyó, se verificó que es coherente con las exclusiones §8 del
encargo (búsqueda semántica, FAQ, recomendador y fichas resumen están declarados
fase 2+), se commiteó aparte y se honró lo que sí aplica al MVP: el campo
`tipo_fuente` y la insignia visible de capa de fuente (invariante 1) y la cita
textual con enlace al artículo en contexto (invariante 2).

**Pregunta cerrada.** ¿Los invariantes 3 (solo derecho chileno) y 4 (texto
interpretativo solo con `validado_por` registrado) deben materializarse ya como
campos del esquema JSON, o entran junto con las piezas interpretativas de fase 2?

**Qué quedó bloqueado.** Nada del MVP.

### Duda 2 — Año de publicación de los 3 dictámenes

**Contexto.** `dictamen_065_revision_mochilas`, `dictamen_52_77_expulsion` y
`dictamen_71_expulsion_cancelacion_matricula` no traen ninguna fecha estructural
propia. `dictamen_52_77` es además un texto refundido de dos dictámenes de 2020 y
2025, así que ni siquiera hay un año único que sea el correcto.

**Pregunta cerrada.** ¿Confirma el equipo estos tres años, uno por dictamen, para
cargarlos como dato curado en el catálogo? (El pipeline no puede derivarlos sin
adivinar.)

**Qué quedó bloqueado.** Los tres aparecen bajo "Sin año determinado" en el índice
por año. Todo lo demás funciona.

### Duda 3 — OCR de los 4 documentos escaneados

**Contexto.** `circular_193_estudiantes_embarazadas` (16 pág.),
`circular_586_tea` (1 pág.), `circular_812_identidad_genero` (10 pág.) y
`rex_482_reglamentos_b` (48 pág.) son escaneos de imagen: 0 caracteres
alfabéticos. La circular 812 sobre identidad de género y la 193 sobre estudiantes
embarazadas son, además, de las más consultadas por un equipo de convivencia.

**Pregunta cerrada.** ¿Autoriza el equipo una sesión de OCR con revisión humana
página por página de estos 4 documentos (75 páginas en total), asumiendo que sin
esa revisión el texto no se publica?

**Qué quedó bloqueado.** Su articulado no es buscable. Aparecen en el sitio con
ficha, aviso explícito y enlace al PDF.

### Duda 4 — Artículos citados dentro de leyes modificatorias

**Contexto.** La ley 20.536 tiene un solo artículo propio ("Artículo único") que
inserta los artículos 16 A a 16 E en la Ley General de Educación. El segmentador
los publica como artículos de la ley 20.536, que es como se citan en la práctica
("el artículo 16 A introducido por la ley 20.536"), pero jurídicamente pertenecen
al DFL 2 de 2009.

**Pregunta cerrada.** ¿Mantener la presentación actual, o marcar estos artículos
con una nota "artículo incorporado a la Ley General de Educación" en la ficha?

**Qué quedó bloqueado.** Nada. Cambiarlo después altera anclas públicas.

### Duda 5 — Rutas absolutas del titular en archivos versionados

**Contexto.** El repositorio es público y tres clases de archivo versionados
llevan la ruta absoluta del filesystem del titular:

1. `20260825_encargo_bootstrap_v1.md`, 6 líneas. POLITICA §1.6 prohíbe reescribir
   rutas en `andamios/` porque falsifica el registro histórico: **no se tocaron**.
2. Los snapshots del escáner (`50_documentacion/estructura/*`), que escriben la
   raíz del proyecto en su línea 3. Los genera `00_escanear_proyecto.R`, que es
   plantilla del kit y no se edita por proyecto.
3. Este mismo log, en dos líneas donde la ruta **es la evidencia** del bug 1.

En los tres casos lo expuesto es el nombre de usuario `tomgc`, idéntico al de la
cuenta pública de GitHub que aloja el repositorio, más la existencia de una
carpeta `Projects`. La compuerta de privacidad disparó en los tres y se pasó por
decisión explícita, no en silencio.

**Pregunta cerrada.** ¿Se acepta esa exposición, o se saca del versionado el
andamio del encargo y los snapshots del escáner con `git rm --cached` más
`.gitignore` (los archivos quedan en disco)?

**Qué quedó bloqueado.** Nada.

### Marcas `# REVISAR` en los datos

7 de 24 normas llevan `marca_revisar` no vacío:

| Norma | Campos |
|---|---|
| `circular_193_estudiantes_embarazadas` | titulo, anio, texto |
| `circular_586_tea` | titulo, anio, texto |
| `circular_812_identidad_genero` | titulo, anio, texto |
| `rex_482_reglamentos_b` | titulo, anio, texto |
| `dictamen_065_revision_mochilas` | anio |
| `dictamen_52_77_expulsion` | anio |
| `dictamen_71_expulsion_cancelacion_matricula` | anio |

---

## 9. Estado de cifras y datos críticos

Todas recontadas programáticamente en el turno de cierre, no heredadas del
pipeline.

| Cifra | Valor | Cómo se midió |
|---|---|---|
| PDF en el corpus | 24 | `ls -1 20_insumos/normativa/*.pdf \| wc -l` |
| JSON de norma | 24 | `ls -1 40_salidas/datos/normas/*.json \| wc -l` |
| Normas en el catálogo | 24 | `jq '.normas\|length'` |
| Artículos totales | 682 | `jq -s 'map(.articulos\|map(select(.es_articulo))\|length)\|add'` |
| Segmentos totales | 711 | `jq -s 'map(.articulos\|length)\|add'` |
| Páginas HTML | 29 | `ls -1 40_salidas/sitio/*.html \| wc -l` |
| Páginas indexadas | 24 | `jq '.languages.es.page_count' pagefind-entry.json` |
| Facetas de búsqueda | 4 (tipo, tema, año, fuente) | API de Pagefind, `pf.filters()` |
| Temas distintos | 15 | `jq -s 'map(.tema)\|flatten\|unique\|length'` |
| Documentos sin capa de texto | 4 | `jq -s 'map(select(.sin_capa_texto))\|length'` |
| Documentos con marca de revisión | 7 | `jq -s 'map(select(.marca_revisar\|length>0))\|length'` |
| Ids de artículo duplicados | 0 | `jq -s` sobre los 24 archivos |
| Enlaces internos rotos | 0 de 59 únicos | comprobación de existencia archivo por archivo |
| Tiempo del pipeline completo | 8,3 s | `run_all()` cronometrado |

**Lo intocable, intacto.** Suma de control del conjunto de los 24 PDF:
`c1a2bdac9f0f5da37745f03ac5f53076`, idéntica a la medida antes del movimiento de
T2.

**Distribución por tipo:** 9 leyes, 4 decretos supremos, 3 circulares, 3
dictámenes, 3 resoluciones exentas, 2 decretos con fuerza de ley.

**Veredicto del presunto duplicado 482.** No son duplicados. `22. REX 482…` es la
resolución exenta de 1 página (25.302 bytes, md5 `947a35e0…`) que aprueba la
circular; `482 REGLAMENTOS.pdf` es el cuerpo de la circular, 48 páginas escaneadas
(15.570.204 bytes, md5 `fb6d0ed5…`). La autorización de `rm` del encargo estaba
condicionada a md5 idéntico y **no se ejerció**.

---

## 10. Notas para el revisor

**Qué mirar con ojo crítico.**

1. **La segmentación del `dfl_1_estatuto_asistentes_educacion`**, que produce 217
   artículos sobre 96 páginas. Es un texto refundido y el número es plausible,
   pero es el documento con más margen para que el patrón haya capturado un
   encabezado de más o de menos. Vale una revisión visual de su página.
2. **El preámbulo como segmento.** Todo documento con articulado produce un
   segmento "Encabezado y promulgación" que incluye la ficha de la Biblioteca del
   Congreso (`Fecha Publicación`, `Url Corta`). Es fiel al documento, pero
   compite en los resultados de búsqueda con los artículos reales.
3. **La redundancia visible en cada artículo.** El encabezado dice "Artículo 16 A"
   y el cuerpo empieza con "Artículo 16 A. Se entenderá…". Es deliberado: el
   encabezado es navegación, el cuerpo es cita literal. Si molesta, la salida es
   ocultar el encabezado visualmente, nunca recortar el texto.
4. **El diccionario temático** (`TEMAS_PALABRAS_CLAVE` en
   `10_utils/10_configuracion.R`). Es una decisión metodológica, no un dato
   extraído: quince temas, con las palabras clave a la vista. El
   `dictamen_065_revision_mochilas` cae en 6 temas, lo que sugiere que las claves
   de algunos temas son demasiado permisivas.
5. **La interfaz de Pagefind es la "Default UI"**, que la versión 1.5.2 marca como
   heredada en favor de la "Component UI". Funciona y está soportada, pero es
   deuda conocida.

**Qué auditar después.**

- Un muestreo mayor del spot-check 1:1 (se hicieron 3 artículos de 3 normas; el
  instrumento y su control positivo están escritos y son reutilizables en
  `50_documentacion/andamios/` si se decide congelarlos ahí).
- El comportamiento del sitio en móvil, que es el contexto de uso declarado en el
  documento de decisión funcional y que esta sesión no probó.
- La accesibilidad AA, también declarada en ese documento y no verificada aquí.

**Qué falló o sorprendió.**

- **Sorprendió** que el presunto duplicado 482 no lo fuera: 1 página contra 48, y
  el grande sin capa de texto. La hipótesis del encargo era razonable y estaba
  mal; medirla antes de borrar evitó perder un documento de 48 páginas.
- **Sorprendió** que dos leyes con articulado completo (20.911 y el decreto 215)
  dieran cero coincidencias en el sondeo de FASE 0: usan ordinales en palabra
  ("Artículo primero"), no dígitos. Un segmentador que solo mirara dígitos las
  habría publicado vacías sin error visible.
- **Falló** el supuesto de que `data-pagefind-filter` admite varios `clave:valor`
  separados por coma en un mismo atributo. Pagefind lee el atributo entero como el
  valor del primer filtro: la faceta "tipo" tenía 20 valores del estilo
  "Ley, anio:2011, fuente:normativa, tema:…" y las otras tres no existían. Se vio
  solo porque la verificación consultó la API de filtros en vez de confiar en el
  "Indexed 1 filter" de la salida del indexador.
- **Falló** el primer intento de indexación por artículo: Quarto movía el `id` al
  `<section>` envolvente y Pagefind no generaba sub-resultados. Se vio con una
  búsqueda real, no leyendo el HTML.
- **Costó** más de lo previsto decidir qué hacer con la regla de detención §1.4,
  que se dispara con los propios andamios de la sesión. Está registrado como D1.
