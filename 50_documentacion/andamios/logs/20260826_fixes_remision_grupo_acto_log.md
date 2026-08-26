# Log — dos fixes correctivos sobre el derivador de relaciones

> Encargo puntual del 2026-08-26, ejecutado en dos commits atómicos sobre `main`.
> Origen: los hallazgos §1.2 y §1.3 de
> `50_documentacion/andamios/20260825_indagacion_pre_cierre.md`.
> Todas las cifras de este log son recuentos **re-derivados** en la misma sesión
> (fuente: `run_all(from = 30, to = 36)` y los diff sobre `relaciones.json`
> antes/después de cada commit).

---

## Fix 1 — el año de la cita también se lee en la forma `D.O. dd.mm.aaaa`

**Commit `741c498`** · `30_procesamiento/33_relaciones.R`, `40_salidas/datos/relaciones.json`

Los textos refundidos de la BCN traen el aparato de modificaciones como nota
marginal (`Decreto 215, EDUCACIÓN Art. ÚNICO N° 1 D.O. 05.01.2012`). El extractor
solo conocía la forma en prosa `de AAAA`, así que esas notas entraban como
remisiones **sin año** y sobrevivían al filtro de homónimos.

`anio_de_la_cita()` ahora lee las dos formas y declara **cuál** usó; la forma
viaja al JSON (campo `forma_anio` de cada descartada) y al log.

**Lo que el encargo no anticipaba y la medición obligó a resolver.** No bastaba
con reconocer la forma: el blocker era la ventana, no el patrón. Al aplanar las
dos columnas del PDF la nota marginal se **intercala** línea a línea con el
cuerpo, de modo que su fecha queda lejos de su cabecera.

| Ventana | Candidatos `dto_453` con fecha detectada |
|---|---|
| 60 (la de prosa) | 15 de 42 |
| 300 | 42 de 42 |
| 360 | 42 de 42 (no agrega ninguno) |

Distancia real cita → `D.O.`: mediana 132 caracteres, máxima 230.

El corte también tuvo que separarse. El corte de prosa se detiene en cualquier
palabra de tipo, y a 300 caracteres eso es inservible: el cuerpo intercalado
nombra leyes y decretos todo el tiempo. Para la forma `D.O.` se corta en la
**cabeza de otra nota** (palabra de tipo + número + coma inmediata). Sin ese
corte se descartaba además `dictamen_71 → ley_20370`, cuya cola dice
«…del decreto con fuerza de ley Nº 1, de 2005. D.O. 02.07.2010»: esa fecha es del
DFL, no de la ley. El corte por cabeza de nota la protege.

**Diff completo, re-derivado sobre el corpus entero:**

| | Antes | Después |
|---|---:|---:|
| relaciones | 553 | 552 |
| — sustitución | 2 | 2 |
| — remisión | 47 | **46** |
| — tema | 504 | 504 |
| descartadas por año | 46 | **88** |

- Desaparece **1** relación: `dto_453 → dto_215` (`n_citas` 42).
- Aparece **0**.
- Las 42 descartadas nuevas son todas `dto_453 → dto_215`, cita «Decreto 215»,
  año 2012, forma `d_o`.
- Las 46 descartadas previas se conservan **intactas** (46 de 46), todas
  `de_aaaa`.

---

## Fix 2 — grupo de acto administrativo

**Commit `8d2e6e6`** · curaduría, `32`, `33`, `34`, `estilo.css`, `40_salidas/datos/`

La curaduría gana `grupos_acto`. Primer grupo, `rex_482_2018`:
`rex_482_instrucciones_reglamentos_internos` (la resolución, 1 página con capa de
texto) y `rex_482_reglamentos_b` (el cuerpo de la circular que aprueba, 48
páginas escaneadas).

**El grupo se declara una sola vez, no una vez por miembro.** Es el mismo motivo
por el que la sustitución se declara una sola vez: dos mitades editables por
separado pueden afirmar cosas incompatibles y el sitio no tendría cómo saber cuál
vale. El **rol** de cada miembro se deriva de qué slug está nombrado como
`resolucion`; el JSON de cada norma recibe un `grupo_acto` derivado.

`32` valida: mínimo 2 miembros, todos en el corpus, la `resolucion` entre ellos,
`fuente` y `nota_colapso` obligatorias, ningún slug en dos grupos.

`33` hace tres cosas:

1. **No emite remisiones dentro del grupo.** La resolución no *cita* a su cuerpo,
   lo aprueba. El control `desde == hacia` no lo veía porque los slugs difieren.
2. **Sondea el grupo una sola vez, por la resolución.** Sondear cada miembro no
   solo duplicaba: el filtro de año comparaba la misma cita contra 2018 o contra
   un año nulo según a qué archivo le tocara, y el veredicto dependía de eso.
3. **Emite el tipo nuevo `grupo_acto` en los dos sentidos**, con la explicación
   compuesta por plantilla desde el rol del destino y la `fuente` del grupo a la
   vista.

`34` lo renderiza con insignia «mismo acto», entre vigencia y remisión, y agrega
la nota a la remisión colapsada.

**Diff completo, sobre el estado ya corregido por el fix 1:**

| | Antes | Después |
|---|---:|---:|
| relaciones | 552 | 552 |
| — remisión | 46 | **44** |
| — `grupo_acto` | 0 | **2** |
| descartadas por año | 88 | 88 |

Desaparecen tres remisiones:

- `rex_482_instrucciones → rex_482_reglamentos_b` (era una autocita: el encabezado
  de la resolución citándose a sí misma).
- `dictamen_52_77 → rex_482_instrucciones` y `dictamen_52_77 → rex_482_reglamentos_b`
  (la misma cita «REX N° 482», emitida dos veces).

Aparecen tres relaciones:

- los dos vínculos `grupo_acto` mutuos;
- una sola remisión `dictamen_52_77 → rex_482_instrucciones`, con la nota
  «incluye el cuerpo del reglamento».

Los 25 JSON de norma cambian: 39 inserciones, 0 borrados. 23 normas suman una
línea (`"grupo_acto": null`) y los 2 miembros suman su objeto de 8 líneas.

---

## Verificación

`run_all(from = 30, to = 36)` completo, sin error. En el HTML publicado:

- la ficha de la resolución muestra «mismo acto → *Es el cuerpo del mismo acto
  administrativo*»; la del cuerpo, «mismo acto → *Es la resolución del mismo acto
  administrativo*»;
- la ficha del `dictamen_52_77` muestra una sola remisión al REX 482, con la nota;
- la ficha del `dto_453` ya no menciona `dto_215` (0 ocurrencias en el `.qmd`);
- Pagefind reindexó las 25 páginas.

## Fuera de alcance, declarado

1. **Las relaciones de TEMA no se colapsan.** Los dos miembros del grupo siguen
   apareciendo por separado en los bloques temáticos y comparten temas *entre sí*
   («Comparten 2 temas: medidas disciplinarias, reconocimiento oficial»), que es
   una norma relacionada consigo misma por otra vía. El encargo acotó el colapso
   a las remisiones; extenderlo al tema es una decisión pendiente.
2. **Los dos enlaces del grupo se rotulan igual.** `nombre_de()` devuelve
   «Resolución exenta 482» para ambos slugs, así que el enlace no distingue cuál
   es cuál; solo la explicación lo hace.
3. **Las 34 asignaciones de tema frágiles** de la indagación §2 siguen sin
   revisar. Es trabajo del equipo de convivencia, no del pipeline.
