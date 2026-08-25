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

> **Este sitio no es asesoría jurídica ni una fuente oficial.** Ante cualquier
> discrepancia, manda el texto publicado en el Diario Oficial.

---

## Estructura

```
slep_normativa_convivencia/
├── 00_run_all.R                 orquestador (punto de entrada único)
├── 00_escanear_proyecto.R       escáner de estructura
├── _quarto.yml                  configuración del sitio
├── 10_utils/                    utilidades y configuración
│   ├── 10_utils.R               bootstrapping (instalar_si_falta, log_msg)
│   ├── 10_configuracion.R       rutas, constantes, taxonomías
│   └── 10_locale.R              guarda de locale UTF-8 (copia del kit)
├── 20_insumos/normativa/        los 24 PDF, read-only
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

## Documentos sin capa de texto

Cuatro de los 24 PDF son escaneos de imagen y no tienen texto extraíble
(medido el 2026-08-25). Aparecen en el sitio con su ficha y un enlace al PDF,
pero sin articulado transcrito y sin entrar al índice de búsqueda por artículo.
El detalle está en `20_insumos/normativa/README.md`.

---

## Licencia

El **código** de este repositorio es MIT. La licencia **no alcanza** a los
documentos normativos de `20_insumos/normativa/`: son normas jurídicas chilenas
de acceso público, cuyo régimen lo fija la ley, no este repositorio.
