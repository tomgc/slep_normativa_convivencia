<!-- fragmento literal de 20260904_alcance_capa2_semantica_v1.md lineas 263-278, copiado por aud_procedimiento.R el 2026-09-06 -->
### 4ter.3 Marca de una norma sustituida (nunca ocultarla)

Una unidad de `dictamen_065` se devuelve siempre que la recuperación la traiga, con: insignia `sustituida`, enlace a `sustituido_por` (`dictamen_078_detectores_revision_mochilas.html`), el `anio` de ambas, y la nota de que el sustituto está en OCR sin revisar (medido: `dictamen_078` tiene `origen_texto = ocr_pendiente_revision`). En R0 recibe factor 0,8 sobre `rrf` cuando no hay filtro temporal; con filtro "regía en 2022" recibe factor 1. El caso C01 de §6 es exactamente este: la única doctrina **firmada** sobre revisión de mochilas está en la norma sustituida, y la vigente no es citable todavía. Ocultar la sustituida dejaría la consulta sin ningún fundamento citable.

### 4ter.4 Suficiencia: el dato que falta no es la fecha, es el artículo

Con 21 de 25 años, 1 sustitución y 0 fechas exactas, el filtro temporal por norma es implementable y casi trivial. El vacío que la medición deja a la vista es otro: la vigencia **por artículo**. `ley_21809_convivencia_educativa` (2026) reescribe el art. 16 B de la LGE y el corpus conserva `ley_20536_violencia_escolar.html#art-16-b` (2011) como unidad vigente sin relación con `ley_21809_convivencia_educativa.html#art-16-b`; lo mismo con el "encargado de convivencia escolar" (`ley_20536#art-unico`) que la ley 21.809 convierte en "coordinador de convivencia educativa" (`#art-15`, `#art-4-3`). Ninguna de las 552 relaciones lo representa (tipos medidos en `relaciones.json`: `tema` 502, `remision` 46, `sustitucion` 2, `grupo_acto` 2). Es un hallazgo para el orquestador (H4, §8), no una propuesta de este documento: por §0bis, una relación nueva entra solo con regla determinística, y esa regla exige un metadato curado por artículo que hoy no existe.

---

## 4quater. Tratamiento del OCR no revisado en la recuperación

### 4quater.1 Recuento propio (medido; tabla `a2_ocr_unidades.csv`)

Valores válidos leídos de `10_utils/10_configuracion.R`: `ORIGENES_TEXTO = capa_texto_pdf, ocr_pendiente_revision, ocr_revisado, sin_texto`. Firmados: `capa_texto_pdf` y `ocr_revisado`. Presentes en el corpus: `capa_texto_pdf` y `ocr_pendiente_revision` (todos dentro de `ORIGENES_TEXTO`: `TRUE`).

