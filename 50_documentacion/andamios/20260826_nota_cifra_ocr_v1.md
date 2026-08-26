# Nota de reconciliación — la cifra de páginas OCR

Proyecto `slep_normativa_convivencia`, sesión 2, 2026-08-26. Producto de la tarea TD del
encargo `50_documentacion/andamios/20260826_encargo_avance_maquina_v2.md`.

> **Conclusión primero: las dos cifras son correctas y miden cosas distintas.** El
> traspaso v01 dice "84 páginas / 5 documentos"; el manifiesto y el disco dicen
> "75 páginas / 4 carpetas". No hay error en ninguno de los dos: 75 es lo que la
> herramienta de OCR transcribió, 84 es la carga de revisión humana pendiente. La
> diferencia son las 9 páginas del dictamen 078, que nunca pasó por la herramienta.
>
> **84 = 75 + 9.**

## 1. Qué declara el manifiesto y qué hay en disco

`20_insumos/ocr/manifiesto_ocr.json` declara **4 documentos y 75 páginas**:

| Documento | Páginas declaradas | Páginas del PDF | Caracteres | Vacías |
|---|---:|---:|---:|---:|
| `circular_193_estudiantes_embarazadas` | 16 | 16 | 27.683 | 0 |
| `circular_586_tea` | 1 | 1 | 2.649 | 0 |
| `circular_812_identidad_genero` | 10 | 10 | 36.367 | 0 |
| `rex_482_reglamentos_b` | 48 | 48 | 122.868 | 0 |
| **total** | **75** | | | |

En disco hay exactamente lo mismo:

```
jq '[.documentos[].paginas] | add' 20_insumos/ocr/manifiesto_ocr.json   → 75
find 20_insumos/ocr -name 'pagina_*.txt' | wc -l                        → 75
ls -d 20_insumos/ocr/*/ | wc -l                                         → 4
```

## 2. Por dónde entró el dictamen 078, que no está en esa cuenta

El dictamen 078 **sí tiene capa de texto en su PDF**: `sin_capa_texto = false`. Nunca lo
tocó `00_ocr_documentos.R`, no tiene carpeta en `20_insumos/ocr/` y por eso no figura en
el manifiesto. Su estado `ocr_pendiente_revision` **lo declaró la curaduría**, no el
pipeline, y por una razón que consta con su procedencia en
`20_insumos/curaduria/metadatos_curados.json`:

> "la capa de texto del PDF la produjo un reconocedor en el origen y arrastra sus errores
> ('á Ley' por 'la Ley', 'artículos incendiados' por 'incendiarios', 'Resolución Exenta
> Ir 413' por 'N° 413'). Decisión del equipo, 2026-08-25: no se publica como cita textual
> hasta revisión humana."

La puerta por la que entra está escrita en `30_procesamiento/31_extraer_texto.R`: la
función `origen_curado()` (línea 36) lee la declaración del equipo, y la rama de la línea
206 la aplica antes de la extracción normal:

```r
declarado <- origen_curado(slug)
if (!is.na(declarado) && declarado %in% c("ocr_pendiente_revision", "ocr_revisado")) {
  # Tiene capa de texto, pero la curaduria la declara transcripcion automatica.
  texto <- paste(trimws(limpias), collapse = SEPARADOR_PAGINA_OCR)
  ...
  return(list(..., sin_capa_texto = FALSE, origen_texto = declarado, ...))
}
```

Es decir: el documento se segmenta por página y se presenta como transcripción, igual que
un escaneo, **sin haber sido escaneado**. `32_segmentar_articulos.R` línea 416 remata la
regla — `origen_texto <- if (!is.null(curado$origen_texto)) curado$origen_texto else
meta$origen_texto` — con el comentario que la explica: *"El estado del texto lo declara el
equipo cuando hay curaduría y el pipeline cuando no. Así `ocr_revisado` solo puede llegar
de una persona."*

## 3. De dónde sale exactamente el "84 / 5" del traspaso

Reproduce la suma de las páginas de **todas las normas en estado
`ocr_pendiente_revision`**, cualquiera sea la vía por la que llegaron a ese estado:

| Documento | Páginas | ¿Sin capa de texto? | ¿Lo transcribió la herramienta? |
|---|---:|---|---|
| `circular_193_estudiantes_embarazadas` | 16 | sí | sí |
| `circular_586_tea` | 1 | sí | sí |
| `circular_812_identidad_genero` | 10 | sí | sí |
| `rex_482_reglamentos_b` | 48 | sí | sí |
| `dictamen_078_detectores_revision_mochilas` | 9 | **no** | **no**, lo declaró la curaduría |
| **total** | **84** | | |

Comando que la produce:

```
jq -s '[.[] | select(.origen_texto=="ocr_pendiente_revision")]
       | {documentos: length, paginas: (map(.paginas) | add)}' 40_salidas/datos/normas/*.json
→ { "documentos": 5, "paginas": 84 }
```

La cifra del traspaso **es reproducible y es correcta**. Lo que faltaba era decir qué
mide.

## 4. Qué cifra usar en el traspaso v02

Las dos, nombradas por lo que miden. Escribir solo una obliga a la siguiente sesión a
repetir esta indagación.

| Cifra | Valor | Qué mide | Comando |
|---|---:|---|---|
| Transcripción producida | **75 páginas en 4 documentos** | lo que generó `00_ocr_documentos.R` y vive en `20_insumos/ocr/`; es lo que protege la compuerta de `--rehacer` | `jq '[.documentos[].paginas] \| add' 20_insumos/ocr/manifiesto_ocr.json` |
| Revisión humana pendiente | **84 páginas en 5 documentos** | todo lo que el sitio presenta como transcripción y no como cita; es la carga de trabajo del equipo | `jq -s '[.[] \| select(.origen_texto=="ocr_pendiente_revision")] \| {documentos: length, paginas: (map(.paginas) \| add)}' 40_salidas/datos/normas/*.json` |

Redacción sugerida para el traspaso: *"84 páginas en 5 documentos pendientes de revisión
humana, de las cuales 75 en 4 documentos son transcripción generada por la herramienta de
OCR; las 9 restantes son el dictamen 078, cuya capa de texto viene reconocida desde el
origen."*

## 5. Calibración del contador

El encargo pide que el contador reproduzca el caso bueno conocido y dispare sobre uno
malo. Ambos se ejecutaron; el caso malo se plantó en una **copia temporal fuera de
`20_insumos/`** y el árbol real no se tocó.

| Caso | Raíz inspeccionada | Manifiesto | Disco | Resultado |
|---|---|---:|---:|---|
| bueno (árbol real) | `20_insumos/ocr` | 75 | 75 | **OK**, coinciden |
| malo (copia con una página plantada) | copia temporal | 75 | 76 | **FALLA**, discrepan en 1 página |

`git status --porcelain -- 20_insumos/` quedó vacío después de ambas corridas.

## 6. Lo que esta nota no hace

- No corrige ninguna línea de OCR (escritura humana exclusiva, incluida la `у` cirílica
  detectada en `50_documentacion/andamios/20260826_prerevision_ocr_v1.md`).
- No cambia el estado de ningún documento: mover algo a `ocr_revisado` es firma humana.
- No modifica el manifiesto: declara 75 porque 75 es lo que la herramienta produjo, y esa
  es la cifra correcta para lo que el manifiesto sirve.
