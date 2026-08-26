# Normativa de convivencia educativa

Biblioteca pública y buscable de la normativa chilena que regula la convivencia
escolar, para el equipo de convivencia del **SLEP Costa Central**.

El sitio es estático y no tiene backend: la búsqueda corre íntegramente en el
navegador. El corpus se indexa **a nivel de artículo**, no de documento, porque
la unidad de recuperación que el equipo necesita es "ley X, artículo Y".

**Sitio publicado:** <https://tomgc.github.io/slep_normativa_convivencia/>

---

## Qué contiene

24 documentos: leyes, decretos con fuerza de ley, decretos supremos, circulares,
resoluciones exentas y dictámenes de la Superintendencia de Educación.

Todos provienen de **fuentes oficiales** (Biblioteca del Congreso Nacional,
Ministerio de Educación, Superintendencia de Educación) y se conservan en el
repositorio tal como se descargaron, sin edición de ninguna clase. Los PDF de
`20_insumos/normativa/` son la fuente legal de verdad: el pipeline solo los lee.

El texto que muestra el sitio es **transcripción literal** del PDF. No hay
resúmenes, paráfrasis ni interpretaciones: la única limpieza que aplica el
pipeline es unir palabras cortadas por guion al final de línea, colapsar espacios
y quitar encabezados y pies repetidos de página.

Cuatro documentos son escaneos sin capa de texto y se publican con una
**transcripción automática (OCR) todavía sin revisar**, señalizada como tal en
todas partes. Esa transcripción no es cita textual: para citar, manda el PDF.

> **Este sitio no es asesoría jurídica ni una fuente oficial.** Ante cualquier
> discrepancia, manda el texto publicado en el Diario Oficial.

---

## Estructura

```
slep_normativa_convivencia/
├── 00_run_all.R                 orquestador (punto de entrada único)
├── 00_escanear_proyecto.R       escáner de estructura
├── 00_ocr_documentos.R          OCR de escaneos (herramienta, no paso del pipeline)
├── 00_ocr_vision.swift          auxiliar de OCR (framework Vision de macOS)
├── _quarto.yml                  configuración del sitio
├── 10_utils/                    utilidades y configuración
│   ├── 10_utils.R               bootstrapping (instalar_si_falta, log_msg)
│   ├── 10_configuracion.R       rutas, constantes, taxonomías
│   └── 10_locale.R              guarda de locale UTF-8 (copia del kit)
├── 20_insumos/
│   ├── normativa/               los 24 PDF, read-only
│   ├── ocr/                     transcripción de los escaneos (curada a mano)
│   └── curaduria/               metadatos que aporta el equipo, no un script
├── 30_procesamiento/            extracción, segmentación, generación
├── 40_salidas/
│   ├── datos/                   JSON estructurado (versionado)
│   ├── sitio_src/               .qmd generados (no versionado)
│   └── sitio/                   HTML renderizado + índice Pagefind (no versionado)
├── 50_documentacion/            política, decisiones, andamios, estructura
└── tests/
```

La convención de carpetas y su justificación viven en
`50_documentacion/activa/POLITICA_PROYECTO.md` (copia local, no versionada).

---

## Cómo regenerar todo

Requiere R (≥ 4.5), [Quarto](https://quarto.org) y Node (para Pagefind).

```bash
cd /ruta/a/slep_normativa_convivencia
Rscript -e 'source("00_run_all.R"); run_all()'
```

`run_all()` reconstruye **todo** `40_salidas/` desde `20_insumos/normativa/` sin
ningún paso manual: extrae el texto de cada PDF, lo segmenta por artículo, escribe
el JSON, genera los `.qmd`, renderiza el sitio y construye el índice de búsqueda.

Etapas sueltas, solo para depurar:

```bash
Rscript -e 'source("00_run_all.R"); run_all(only = 31)'   # solo extracción
Rscript -e 'source("00_run_all.R"); run_all(from = 33)'   # desde la generación de páginas
```

---

## Publicación

Cada push a `main` dispara `.github/workflows/publicar.yml`, que corre el
pipeline completo en un runner limpio y publica `40_salidas/sitio/` en GitHub
Pages. El sitio que se ve en línea siempre sale de una corrida reproducible, no
de una carpeta subida a mano.

---

## Documentos escaneados: OCR y su revisión

Cuatro de los 24 PDF son escaneos de imagen (medido el 2026-08-25):
`circular_193`, `circular_586`, `circular_812` y `rex_482_reglamentos_b`. De
ellos se obtuvo una transcripción automática con `00_ocr_documentos.R`, que
**no es parte del pipeline** y se corre una sola vez por documento nuevo.

Su salida vive en `20_insumos/ocr/<slug>/pagina_NNN.txt`, una página por archivo,
y **se versiona**: el equipo la va a corregir a mano, y una corrección humana que
la siguiente corrida sobreescribe no es una corrección, es una pérdida.

El estado de cada documento vive en `20_insumos/curaduria/metadatos_curados.json`,
campo `origen_texto`:

| Valor | Significado |
|---|---|
| `capa_texto_pdf` | El PDF trae texto seleccionable. Es cita textual. |
| `ocr_pendiente_revision` | Transcripción automática sin revisar. **No es cita textual.** |
| `ocr_revisado` | Transcripción revisada y validada por el equipo. |

### Cómo revisar una transcripción

1. Abrir el PDF en `20_insumos/normativa/<slug>.pdf` y el archivo
   `20_insumos/ocr/<slug>/pagina_001.txt` lado a lado.
2. Corregir el `.txt` contra la página. No se reordena ni se reformatea: solo se
   corrige lo que el reconocedor leyó mal.
3. Repetir por cada página.
4. Cambiar `origen_texto` a `ocr_revisado` en
   `20_insumos/curaduria/metadatos_curados.json` y anotar quién y cuándo en
   `fuente_origen_texto`.
5. Correr `Rscript -e 'source("00_run_all.R"); run_all()'` y commitear.

Mientras el estado sea `ocr_pendiente_revision`, el sitio muestra el aviso
"Texto obtenido por OCR, en revisión; el PDF oficial es la fuente" junto al
enlace al PDF y sobre el texto.

### Regenerar el OCR (solo macOS)

```bash
Rscript 00_ocr_documentos.R              # solo los que faltan
Rscript 00_ocr_documentos.R --rehacer    # rehace todos, DESCARTA correcciones
```

Requiere `pdftoppm` (`brew install poppler`) y las Command Line Tools de Xcode.
Nadie más necesita correrlo: la transcripción está versionada y el pipeline la
lee ya escrita.

---

## Licencia

El **código** de este repositorio es MIT. La licencia **no alcanza** a los
documentos normativos de `20_insumos/normativa/`: son normas jurídicas chilenas
de acceso público, cuyo régimen lo fija la ley, no este repositorio.
