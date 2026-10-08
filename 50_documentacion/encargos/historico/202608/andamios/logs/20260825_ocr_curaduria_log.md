# Log — OCR de escaneos y capa de curaduría

> Andamio congelado. Sesión del 2026-08-25, posterior al bootstrap
> (`20260825_bootstrap_log.md`). Cuatro encargos del equipo en un turno.

---

## 1. Qué entró y qué salió

| Encargo | Estado |
|---|---|
| OCR de los 4 escaneos, con la condición de que el texto no se publica como cita textual hasta revisión humana | Hecho |
| Años curados de los 3 dictámenes; retirar las marcas `# REVISAR` resueltas | Hecho |
| Duda 4: nota en la ficha de `ley_20536` sobre los artículos 16 A–16 E | Hecho |
| Duda 5: se acepta la exposición del username en rutas | Cerrada sin cambios |
| Aviso de vigencia en `dictamen_065` | Hecho |

**75 páginas** reconocidas en los 4 documentos, 0 vacías. El corpus sigue
intacto: md5 del conjunto `c1a2bdac9f0f5da37745f03ac5f53076`, idéntico al del
bootstrap.

---

## 2. Commits

| Hash | Título |
|---|---|
| `c72ee97` | feat: reconocimiento optico de los cuatro documentos escaneados |
| `8d3bb6d` | feat: curaduria de metadatos y estado de revision del texto |
| `dff56b9` | feat: el sitio declara el origen del texto y las notas curadas |
| `3a758a7` | docs: documentacion al dia con OCR y curaduria |
| — | docs: log de OCR y curaduría (este archivo) |

---

## 3. La interpretación que gobernó el diseño

La condición decía dos cosas que hay que sostener juntas: el texto OCR **no se
publica como cita textual**, y el sitio **muestra un aviso junto al enlace al
PDF** diciendo que el PDF es la fuente. Se leyó como una negación de la *manera*
de publicar, no de la publicación: el texto se muestra e indexa, pero rebajado de
cita textual a transcripción automática señalizada. El aviso pedido ("el PDF
oficial es la fuente") presupone que hay texto a la vista, y el estado intermedio
`ocr_pendiente_revision` no tendría función si el texto quedara oculto.

Materialización de esa rebaja, en cuatro lugares:

1. **Segmentación por página, nunca por artículo.** El texto reconocido se corta
   en `ocr-pagina-001`, `ocr-pagina-002`… y jamás en `art-5`. Un ancla `art-5`
   sobre texto sin revisar sería indistinguible de una cita verificada, y además
   la página es la unidad con la que se revisa contra el PDF.
2. **Tipografía distinta.** Monoespaciada, fondo marcado, borde discontinuo,
   frente a la serif del texto legal verificado. Si se viera igual, la propia
   página desmentiría el aviso.
3. **Sin reflujo.** Se conservan los saltos de línea del reconocedor
   (`white-space: pre-wrap`). A un texto que nadie revisó no se le adivina además
   la estructura de párrafos, y revisarlo es mucho más fácil si lo que se ve en el
   sitio es exactamente lo que hay en el archivo que se corrige.
4. **Aviso en dos sitios**, no uno: junto al enlace al PDF en la ficha (donde lo
   pidió el equipo) y en una banda sobre el texto (donde se lee).

Además, faceta nueva en el buscador: `texto` con valores "verificado" y "OCR sin
revisar", para poder acotar una búsqueda a lo que ya está validado.

---

## 4. Decisiones autónomas

| # | Decisión | Alternativa descartada | Reversibilidad |
|---|---|---|---|
| E1 | **El texto OCR vive en `20_insumos/ocr/`, no en `40_salidas/`,** y su generador NO es un paso de `00_run_all.R`. | Hacer el OCR un paso más del pipeline. | Reversible, pero sería un error: ese texto lo va a **corregir a mano** el equipo, y una corrección que la siguiente corrida sobreescribe no es una corrección, es una pérdida. Como insumo versionado, el invariante de reproducibilidad se mantiene intacto: `run_all()` sigue regenerando todo `40_salidas/` desde `20_insumos/`. |
| E2 | **Motor: Apple Vision**, no Tesseract. | Tesseract, que es multiplataforma. | Reversible. Comparados sobre la misma página (circular 812, pág. 2, 300 dpi), Tesseract leyó "de **tos** establecimientos" donde dice "los" y "Ley N**\*** 20.529" donde dice "N°"; Vision acertó ambos. Cada error del motor es trabajo humano de revisión. La contrapartida (solo corre en macOS) no afecta a nadie más: la salida está versionada y CI la lee ya escrita. |
| E3 | **Una página por archivo** (`pagina_NNN.txt`), no un archivo por documento. | Un `.txt` por documento con separadores en banda. | Reversible. Así es como se revisa: página N del PDF junto a `pagina_00N.txt`, sin marcadores que el revisor pueda romper. |
| E4 | **Capa de curaduría en un archivo que ningún script escribe** (`20_insumos/curaduria/metadatos_curados.json`), con un campo `fuente_*` obligatorio por dato. | Guardar el estado de revisión en el manifiesto técnico que genera la herramienta. | Reversible. Si la herramienta escribiera el estado, borraría la validación del equipo cada vez que alguien la volviera a correr. |
| E5 | **Los temas de los documentos OCR se asignan sobre texto sin revisar.** | Dejarlos sin tema hasta la revisión. | Reversible por curaduría. El tema es una clasificación derivada, no una cita; dejarlos sin tema los sacaría del índice temático, que es una de las dos maneras de llegar a ellos. |
| E6 | **El título de los 4 documentos OCR sigue en `null`.** | Extraerlo del texto reconocido. | Reversible. Sacar el título de un texto sin revisar es exactamente la clase de dato plausible-pero-no-verificado que el proyecto no admite. |

---

## 5. Bugs

### Bug 5 — Segfault de poppler al rasterizar el escaneo de 48 páginas

- **Síntoma.** `*** caught segfault *** cause 'invalid permissions'` en
  `poppler_convert`, con R abortando, al procesar `rex_482_reglamentos_b`
  (48 páginas, 14,8 MB).
- **Diagnóstico.** No era memoria: rasterizar página a página en el mismo proceso
  también caía, y las mismas páginas en procesos de R separados salían bien.
  `pdftools::pdf_convert()` acumula estado de poppler y lo corrompe con este
  archivo.
- **Fix.** Rasterizar con el binario `pdftoppm`, un proceso por página. Un proceso
  externo no puede tumbar a R y además aísla una página defectuosa.
- **Verificación.** 48 de 48 páginas reconocidas, 0 vacías.

### Bug 6 — Manifiesto que contradecía al disco

- **Síntoma.** Tras la corrida que cayó, el manifiesto listaba 1 documento y en
  disco había 4.
- **Causa raíz.** Se escribía al final, a partir de lo que *esa* corrida procesó.
- **Fix.** Se reconstruye siempre desde disco, más una compuerta que compara
  páginas transcritas contra páginas del PDF y aborta si no coinciden.
- **Nota.** El mismo defecto tenía una segunda cara: la herramienta omitía un
  documento por la mera existencia de su carpeta, así que una transcripción
  parcial se veía igual de completa que una entera. Ahora compara el conteo.

### Bug 7 — Los documentos OCR salían con cero segmentos

- **Síntoma.** Los 4 documentos con transcripción llegaban al JSON con
  `segmentos=0` y el archivo de texto lleno al lado.
- **Causa raíz.** `construir_norma()` descartaba el texto con
  `if (sin_capa_texto) ""`, condición escrita cuando "sin capa de texto" y "sin
  texto" eran lo mismo. Desde que hay OCR, dejaron de serlo.
- **Fix.** Leer siempre el intermedio si existe.

---

## 6. Verificación

| Qué | Resultado |
|---|---|
| Corpus intacto | md5 del conjunto `c1a2bdac9f0f5da37745f03ac5f53076`, n=24, idéntico al del bootstrap |
| Transcripción completa | 16+1+10+48 = 75 páginas, igual al conteo de páginas de cada PDF; compuerta en la herramienta y en el paso 31 |
| Reproducibilidad | `40_salidas/` borrado entero y reconstruido por `run_all()` en 8,9 s, 5 pasos, 0 saltados |
| `origen_texto` | 20 `capa_texto_pdf`, 4 `ocr_pendiente_revision`, 0 fuera del dominio declarado (el paso 32 aborta si aparece uno) |
| Años curados | 3 dictámenes con año; normas sin año: de 7 a **4** (los 4 escaneados) |
| Búsqueda | "identidad de género" devuelve `circular_812` **en primer lugar**, con 10 sub-resultados por página; antes del OCR ese documento no aparecía en ninguna búsqueda. "reglamento interno" devuelve `rex_482_reglamentos_b` primero, con 48 sub-resultados |
| Faceta nueva | `texto`: "verificado" / "OCR sin revisar" |
| Avisos | Banda de vigencia en `dictamen_065`, aviso OCR junto al enlace al PDF y sobre el texto en los 4, notas de ficha en `ley_20536` y `dictamen_52_77`, todo comprobado sobre el HTML renderizado |

---

## 7. Procedencia de los datos curados

**Distinción que importa.** Los años de `dictamen_065` (2022) y `dictamen_71`
(2024) **no los verificó este asistente en esta sesión**: los aportó el equipo
declarando como fuente "verificación web del asistente, 2026-08-25". Están
registrados con esa procedencia literal en el archivo de curaduría y visibles en
la ficha de cada norma.

El año de `dictamen_52_77` **sí se verificó aquí**, en el texto del propio
documento: "Dictamen N° 52, de 17 de febrero de 2020" y "Dictamen N° 77, de 19 de
diciembre de 2025". Coincide con el par esperado. Se adoptó 2025 para el índice
por año y el par completo quedó en la nota de ficha.

---

## 8. Pendientes

1. **Revisión de las 75 páginas transcritas.** Es el trabajo que queda y no lo
   puede hacer una máquina. Procedimiento en el README de la raíz. Hasta que
   ocurra, los 4 documentos siguen en `ocr_pendiente_revision` y con el aviso a la
   vista.
2. **Títulos de los 4 documentos OCR.** Siguen en `null`. Salen de la transcripción
   en cuanto alguien la valide, o se pueden curar antes en el archivo de curaduría.
3. **Calidad del OCR en membretes y logos.** El cuerpo del texto sale bien; las
   cabeceras institucionales no ("Superintendencla", "Gobierna de Chile", "Pa de
   chile"). Es lo esperable y no afecta al articulado, pero conviene que quien
   revise empiece por ahí.
4. **`dictamen_065` está sustituido** por el Dictamen N°78/2026. La banda lo
   declara. Queda pendiente incorporar el 78/2026 al corpus.

---

## 9. Notas para el revisor

- **Mirar primero** una página cualquiera de `rex_482_reglamentos_b` en el sitio:
  es el caso extremo (48 páginas de escaneo) y donde mejor se ve si la rebaja de
  "cita textual" a "transcripción" se lee claramente o no.
- **La faceta `texto`** permite acotar cualquier búsqueda a lo verificado. Si el
  equipo prefiere que ese sea el comportamiento por defecto y que lo OCR haya que
  pedirlo explícitamente, es un cambio de una línea en la plantilla del buscador.
- **`00_ocr_documentos.R --rehacer` descarta correcciones humanas.** Está avisado
  en el README, pero no hay compuerta que lo impida. Si el equipo va a revisar en
  serio, vale la pena que la haya.
