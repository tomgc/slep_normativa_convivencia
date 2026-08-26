# Log — Resolución de las cuatro dudas de fase 2

> Andamio congelado. Sesión del 2026-08-25, posterior a
> `20260825_fase2_log.md`. Cuatro decisiones del equipo, implementadas en un
> turno.

---

## 1. Qué se decidió y qué se hizo

| Duda | Decisión del equipo | Estado |
|---|---|---|
| 1 | `dictamen_078` pasa a `ocr_pendiente_revision` con tratamiento estándar | Hecho |
| 2 | Descartar remisiones con año discordante; conservar las sin año con cita literal; registrar cuántas | Hecho |
| 3 | Segmentar los dictámenes por numerales, con el mapa viejo→nuevo | Hecho |
| 4 | Los 5 términos quedan pendientes de fuente, con nota sobre la circular 482 | Hecho |

**Commits:** `9ed83be` · `ebf6343` · `175a834` · `1fe87b0`.

---

## 2. Decisión 1 — El 078 como transcripción

La curaduría gana `origen_texto` como **anulación** del valor que deduce el
pipeline. El paso 31 lo respeta: un documento declarado transcripción se extrae
**por página y sin reflujo** aunque su PDF traiga capa de texto, para que reciba
el mismo trato visual y las mismas anclas de página que un escaneo.

Resultado en el sitio: banda sobre el texto, aviso junto al enlace al PDF,
insignia "OCR sin revisar", faceta `texto: OCR sin revisar`, **9 anclas de página
y 0 anclas `art-N`**. Conserva su ficha, el año curado 2026 y las notas.

### Defecto que esto destapó

La huella del manifiesto **no incluía el `origen_texto` declarado**, así que
cambiar la declaración en la curaduría no reprocesaba el documento: el paso 31
reutilizaba el texto cacheado y el sitio seguía mostrando la versión anterior.

Es el mismo error que ya se había corregido una vez para la transcripción OCR, en
otra cara: la huella tiene que cubrir **todo lo que determina la salida del paso
31**, y una declaración de curaduría la determina tanto como los bytes del PDF.
La huella pasa a tener tres componentes: PDF, transcripción, origen declarado.

Efecto secundario esperado y de una sola vez: al cambiar el formato de la huella,
la primera corrida marcó los 25 documentos como modificados. La siguiente volvió
a 25/0/0.

---

## 3. Decisión 2 — Remisiones con año discordante

**46 remisiones descartadas.** Las remisiones pasan de 57 a 47; el total de
relaciones, de 563 a 553.

El descarte **no es silencioso**: `relaciones.json` guarda el campo
`remisiones_descartadas_por_anio` y la lista completa de descartes con su cita
literal, su año y el de la norma de destino. Un filtro que reduce resultados sin
dejar rastro es indistinguible de un derivador que nunca los encontró.

La inmensa mayoría de los descartes son el caso previsto: `dfl_1` de nuestro
corpus es de 1997, y el corpus cita constantemente "decreto con fuerza de ley N° 1
**de 2005**" (que es el DFL 1 del Ministerio de Salud) y "**de 1996**" y "**de
2006**". Son normas homónimas distintas.

### Dos descartes indebidos que la primera versión producía

1. **Ventana que se comía la cita siguiente.** En una enumeración como
   "Ley N° 21.430; D.F.L. N° 2, **de 2009**", la ventana de 60 caracteres tras
   "Ley N° 21.430" alcanzaba el "de 2009" del elemento siguiente y descartaba una
   remisión legítima. **Fix:** la ventana se corta en el primer `;` o en la
   primera palabra de tipo de norma, que es donde empieza otra cita.
2. **Textos refundidos.** `dictamen_52_77` refunde uno de 2020 y otro de 2025; el
   catálogo lo ubica en 2025 y una cita a "Dictamen N° 52, **de 2020**" apunta a
   ese mismo documento. **Fix:** campo `anios_alternativos` en la curaduría, con
   procedencia. No es una excepción al mecanismo: es un dato que faltaba.

Tras ambos arreglos, los tres casos indebidos identificados (`dictamen_71 →
dictamen_52_77`, `dictamen_71 → ley_21430`, `circular_812 → ley_20370`) vuelven a
existir como remisiones y los descartes bajan de 50 a 46.

---

## 4. Decisión 3 — Segmentación por numerales

Regla general, no una excepción para cuatro archivos: en documentos sin
articulado, un bloque que empieza con **numeral y versalitas** ("1. SOBRE LAS
CAUSALES…") abre sección, igual que la etiqueta en versalitas con dos puntos.

El patrón exige **punto** (no paréntesis) y **versalitas**, para no confundir el
encabezado con las dos cosas que se le parecen:

- `1) Resolución Exenta N° 0413…` — ítem de la lista de ANTECEDENTES
- `1. Que, cualquier regulación…` — considerando, en minúsculas

### Mapa viejo → nuevo

| Documento | Antes | Después | Anclas desaparecidas | Anclas nuevas |
|---|---:|---:|---|---|
| `dictamen_52_77_expulsion` | 4 | 9 | **ninguna** | `num-1` … `num-5` |
| `dictamen_71_expulsion_cancelacion_matricula` | 4 | 10 | **ninguna** | `num-1` … `num-6` |
| `dictamen_065_revision_mochilas` | 4 | 4 | **ninguna** | ninguna |
| `dictamen_078_detectores_revision_mochilas` | 9 | 9 | **ninguna** | ninguna |

### La excepción al invariante de anclas no llegó a ser necesaria

El equipo autorizó pagar el costo de romper anclas con horas de vida. **No hubo
costo que pagar:** `materia`, `antecedentes`, `fuentes` y `concordancias`
sobreviven las cuatro en los cuatro documentos. El cambio resultó puramente
aditivo. Lo que sí cambió es el **contenido** del ancla `concordancias`, que antes
absorbía el cuerpo entero del dictamen (29.741 caracteres en el 52/77) y ahora
solo su sección: el enlace sigue resolviendo, y a un lugar más preciso.

Dos observaciones de la medición:

- **`dictamen_065` no tiene secciones numeradas.** Cero, medido con el patrón. Su
  cuerpo es prosa continua sin estructura numerada. No se forzó nada: la duda 3
  no aplica a ese documento y queda dicho.
- **El `dictamen_078` quedó fuera por la decisión 1**, que es más específica sobre
  ese documento: al pasar a transcripción se segmenta por página. El problema que
  la duda 3 quería resolver —un único segmento con todo el cuerpo— queda resuelto
  igual, con 9 anclas en vez de 2.

---

## 5. Decisión 4 — Glosario

Los cinco términos quedan como **pendientes de fuente**, con una tabla que dice
dónde buscar cada uno y la nota de que la circular 482 probablemente define
varios, pero que su transcripción está en `ocr_pendiente_revision` y no se puede
citar hasta que alguien la revise.

Se agregó una precisión que la medición permite hacer: la circular 482 **sí**
contiene la fórmula de definición legal en tres casos, que ya aparecen en el
glosario marcados como transcripción en revisión. Que los cinco términos de la
tabla no aparezcan significa que la circular no los introduce con esa fórmula,
**no** que no los regule. La diferencia importa para quien vaya a buscarlos.

---

## 6. Cifras finales

Recontadas con `jq` tras la corrida completa.

| Cifra | Antes | Después |
|---|---:|---:|
| Normas | 25 | 25 |
| Artículos | 682 | 682 |
| `capa_texto_pdf` / `ocr_pendiente_revision` | 21 / 4 | **20 / 5** |
| Relaciones | 563 | **553** |
| — sustitución / remisión / tema | 2 / 57 / 504 | 2 / **47** / 504 |
| Remisiones descartadas por año | — | **46** |
| Segmentos del `dictamen_52_77` | 4 | **9** |
| Segmentos del `dictamen_71` | 4 | **10** |
| Segmentos del `dictamen_078` | 4 | **9** (páginas) |
| Enlaces internos / rotos | 1.178 / 0 | **1.169 / 0** |
| Piezas publicadas | 0 | 0 |

---

## 7. Notas para el revisor

- **Los 46 descartes están todos en `relaciones.json`**, campo `descartadas`, con
  su cita literal. Vale una lectura: si alguno resulta ser una norma que sí está
  en el corpus, el arreglo es declarar su año alternativo en la curaduría, no
  tocar el filtro.
- **`dictamen_065` sigue con cuatro segmentos.** No es un fallo del segmentador:
  el documento no tiene secciones numeradas. Si el equipo quiere granularidad ahí,
  hay que cortarlo por otro criterio y eso sí movería sus anclas.
- **El 078 perdió sus anclas de sección** (`materia`, `antecedentes`, …) al pasar
  a transcripción por página. Tenían horas de vida y ninguna estaba enlazada desde
  fuera, pero es el único punto de esta sesión donde una ancla dejó de existir.
