# Ensayo general de la vía A, en clon (v1)

> Producto de T3 del encargo `20260827_encargo_ensayo_general_v6.md`, sesión 2.
> Todo lo que sigue ocurrió en un clon bajo `/tmp/slep_v6_clon`, con el remote
> eliminado antes de tocar nada y borrado al terminar. **Ninguna pieza real se
> publicó y ningún estado real se cerró**: el repositorio quedó con
> `git status --porcelain` vacío.
>
> Responde la primera de las tres dudas residuales del encargo: *el camino de
> publicación de piezas jamás se había ejercitado de punta a punta*. Ahora sí, y
> encontró una cosa que ningún arnés podía encontrar.

## 0. El clon, y por qué el ensayo vive ahí

| Paso | Evidencia |
|---|---|
| Clon | `git clone` del repo real a `/tmp/slep_v6_clon`, `HEAD = 5e8fb78` |
| Condición 3 | `git remote remove origin` **inmediatamente después del clon**; `git remote -v` vacío, verificado antes de ejecutar nada más |
| Dependencias de R | El proyecto **no usa renv ni packrat** (medido en FASE 0.7): cada script hace `instalar_si_falta()` contra la biblioteca ambiente. No hay nada que restaurar, y el clon usa la misma biblioteca que el repo real |
| Dependencias de Node | `node_modules/` no se versiona. Se **copió** desde el repo real en vez de `npm ci`, porque este encargo no autoriza red más allá de `gh` y la URL pública. Efecto declarado: T3a prueba que el pipeline de R corre de cero, **no** que `npm ci` resuelva; eso lo prueba el CI en cada push |
| Borrado | `rm -rf /tmp/slep_v6_clon`; verificado inexistente al cerrar |

## 1. T3a — ¿el pipeline corre de cero?

Se borró `40_salidas/` **entera** en el clon (los 28 archivos versionados incluidos)
y se regeneró con `Rscript 00_run_all.R`. Salida 0, 7 pasos, 18,2 s, 47 `.qmd`,
47 HTML y el índice de Pagefind construido.

**Resultado: 27 de los 28 archivos versionados salen byte a byte idénticos.** El
28.º es `40_salidas/datos/manifiesto_corpus.json`, y la diferencia se enumeró
antes de juzgarla:

| Medición | Valor |
|---|---|
| Líneas distintas en el diff (`jq -S`) | **50** |
| De ellas, líneas del campo `estado` | **50** (25 documentos × 2) |
| `estado` en el repo real / en el clon | `sin_cambio` ×25 / `nuevo` ×25 |
| Huellas (`huella`, `md5_pdf`, `md5_ocr`, `origen_declarado`) | **idénticas** |
| El manifiesto sin el campo `estado` | **idéntico** (`diff` vacío) |
| Los otros 27 archivos, uno a uno | **27 de 27 idénticos** |

**El pipeline es reproducible desde cero.** La única diferencia no es de contenido:
`estado` registra **cómo esta corrida clasificó cada documento respecto del
manifiesto anterior**, y por construcción no puede coincidir cuando no hay
manifiesto anterior. Es un campo de bitácora de corrida dentro de un archivo
versionado, y por eso un build desde cero jamás producirá un manifiesto byte a byte
igual (duda E-a).

Detalle secundario, medido: la corrida desde cero emite un `WARN` que la
incremental no emite («`dictamen_078`: tiene capa de texto pero la curaduría la
declara `ocr_pendiente_revision`»). No cambia ninguna salida; aparece solo porque
la extracción se ejecuta de verdad en vez de saltarse por huella.

## 2. T3b paso 1 — publicación limpia

Se hizo exactamente lo que hará el equipo: abrir el `.md`, cambiar **tres líneas**
del front matter, correr el pipeline. Pieza elegida por medición en FASE 0.6:
`faq_expulsion.md`, 4 fuentes, las 4 anclas resuelven.

```yaml
estado: validada
validado_por: "Ensayo General"
fecha_validacion: "2026-08-27"
```

Log del pipeline: `Piezas interpretativas: 22 en total, 1 validadas y publicables.`
· `Generadas 49 páginas .qmd (25 normas + 17 temas + 1 piezas + home + acerca + 3
índices)` · `Sitio renderizado: 49 páginas HTML` · salida 0.

| # | Verificación pedida | Resultado | Evidencia |
|---|---|:-:|---|
| 1 | La página de la pieza existe y renderiza | **OK** | `pieza-faq-expulsion.html`, 30 761 bytes; `<title>¿Qué exige la normativa para expulsar a un estudiante? – Normativa de convivencia educativa</title>` |
| 2 | El índice la lista con su título | **OK** | `<li><a href="./pieza-faq-expulsion.html">¿Qué exige la normativa para expulsar a un estudiante?</a> — validada por Ensayo General`, bajo la sección «Preguntas frecuentes» |
| 3 | Todas sus anclas de `fuentes` resuelven en el HTML | **OK** | las 4 enlazadas 2 veces cada una en la pieza, y el `id` correspondiente presente en la página de cada norma (4 de 4) |
| 4 | El buscador la indexa | **FALLA** | ver §3 |
| 5 | El candado de conteo cuadra | **OK** | sin aborto; 49 esperadas, 49 escritas |
| 6 | El resto del sitio, byte a byte salvo lo esperable | **OK, con matiz** | ver abajo |

**Qué cambia en el sitio al publicar una pieza.** Dos archivos nuevos
(`pieza-faq-expulsion.html`, `piezas.html`) y **las 49 páginas preexistentes
modificadas**, todas por lo mismo: el navbar gana la entrada «Fichas y FAQ», que
solo existe cuando hay algo que enlazar (1 mención de `piezas.html` por página, 0
menciones de `pieza-faq` fuera de la propia pieza y del índice). No es un cambio de
contenido: es una entrada de menú en la plantilla común.

**La reversión es limpia, y eso importa más que la publicación.** Se devolvió la
pieza a `estado: borrador` y se regeneró: desaparecen las dos páginas nuevas,
desaparece la entrada del navbar, y **48 de las 49 páginas vuelven byte a byte a su
estado previo**. La única que no vuelve es `pagefind/pagefind-entry.json`, y no por
la pieza: **cambia entre dos corridas idénticas sin tocar nada** (medido: dos
`sha256` distintos en corridas consecutivas), porque incrusta un hash por build
(`"hash": "es_83f29fd27a"`). No está versionado, así que no afecta la
reproducibilidad del repositorio, pero sí significa que el sitio desplegado nunca
es byte a byte idéntico entre dos builds (duda E-b).

## 3. El hallazgo del ensayo: la pieza publicada NO entra al buscador

Es lo que ningún arnés podía encontrar, porque solo aparece al renderizar e indexar
de verdad.

| Medición | Valor |
|---|---|
| Páginas HTML del sitio con la pieza publicada | 49 |
| Páginas con `data-pagefind-body` | **25** (las 25 normas) |
| `data-pagefind-body` en `pieza-faq-expulsion.html` | **0** |
| `data-pagefind-body` en `piezas.html` | **0** |
| Fragmentos en el índice de Pagefind | 25 |
| URLs indexadas que contienen `pieza-` | **0** |
| `page_count` que declara `pagefind-entry.json` | 25 |

Causa exacta: `data-pagefind-body` lo emite **solo** `pagina_norma()`
(`34_generar_paginas.R:263`); `pagina_pieza()` no lo emite. El paso 36 declara su
alcance en su propia cabecera («la indexación es a nivel de ARTÍCULO: cada página de
norma marca su cuerpo con `data-pagefind-body`»).

**No se corrigió, y la razón es la condición 5 del encargo** («si la publicación
falla en el clon, NO lo arregles»). Además hay una lectura legítima en la que esto
es deliberado: el mismo archivo excluye a propósito el bloque de relacionados del
índice, con el argumento de que buscar «expulsión» no debe devolver páginas cuyo
único vínculo con la palabra es una frase generada. Una pieza interpretativa es
justamente texto no normativo, así que su exclusión puede ser la misma decisión.

Lo que no admite dos lecturas es que **nadie lo había medido**, y que el equipo va a
validar una FAQ sobre expulsión esperando encontrarla al buscar «expulsión». Va como
duda E-c, con la pregunta cerrada.

## 4. T3b paso 2 — la compuerta de anclas, control positivo sobre datos reales

Se marcó como validada `faq_revision_de_mochilas.md`, que tiene un ancla rota
conocida desde el log v5 (D-e). La regeneración **aborta**, con salida 1:

```
Paso 34 (Generar las páginas .qmd del sitio) fallo: Hay piezas validadas cuyas `fuentes` no apuntan a un artículo que exista:
  20_insumos/curaduria/piezas/borradores/faq_revision_de_mochilas.md
    - `dictamen_078_detectores_revision_mochilas.html#materia`
  El ancla se escribe `<norma>.html#<id del artículo>`, y `norma` y `articulo` de esa misma
  entrada tienen que decir lo mismo que el ancla. Ábrela en la página de la norma para
  comprobar el id, o quita la fuente.
```

Nombra **pieza, ancla y documento**, y lo hace sobre datos reales, no sintéticos. Es
el control positivo que D-e pedía.

**Consecuencia práctica para la vía A, y es incómoda:** de las 22 piezas sembradas,
**2 abortan el pipeline el día que se validen tal cual**. No es un defecto de la
compuerta —las anclas están muertas de verdad, porque el dictamen 078 pasó a
`ocr_pendiente_revision` después de sembrarse los borradores y sus únicos `id` son
`ocr-pagina-001`…`009`— sino una tarea pendiente de curaduría. Y
`00_generar_borradores.R` **no puede repararlas**: nunca sobreescribe un archivo
existente. Hay que editarlas a mano (duda E-d).

## 5. T3b paso 3 — qué se ve cuando un OCR pasa a revisado

Se cerró `origen_texto: ocr_revisado` para `circular_586_tea` (1 página) en la
curaduría del clon, con una firma sintética declarada como tal. El propósito era
**conocer el efecto antes de pedirle al equipo la primera firma real**, no validar
contenido.

**Lo que cambia (18 líneas de HTML):**

| Antes (`ocr_pendiente_revision`) | Después (`ocr_revisado`) |
|---|---|
| Chip `<span class="badge-fuente badge-ocr">OCR sin revisar</span>` | *(desaparece)* |
| Junto al enlace al PDF: `Texto obtenido por OCR, en revisión; el PDF oficial es la fuente` | *(desaparece)* |
| Aviso largo: «**No es una cita textual** y todavía no ha sido revisada… para citar, use el PDF» | Aviso corto: «Transcripción obtenida por reconocimiento óptico y **revisada por el equipo de convivencia**. La fuente oficial sigue siendo el PDF.» |
| Filtro del buscador `texto:OCR sin revisar` | `texto:verificado` |

**Lo que NO cambia, y hay que decírselo al equipo antes de que firme:**

- Las anclas **siguen siendo `#ocr-pagina-001`**, no `#art-1`. Revisar la
  transcripción no la convierte en articulado: `CLAUDE.md` §10.5 lo fija así a
  propósito. Una pieza solo podrá citar páginas de ese documento, nunca artículos.
- El índice lateral sigue diciendo «Páginas», no «Articulado».
- `marca_revisar` sigue trayendo `titulo, anio`: revisar el OCR no rellena los
  metadatos, que son curaduría aparte.
- El PDF sigue siendo la fuente oficial en las dos redacciones del aviso.

## 6. Lo que el equipo verá

*(Sección en lenguaje llano, pensada como anexo de la pauta.)*

**Cuando validas una pieza.** Cambias tres líneas del archivo (`estado`,
`validado_por`, `fecha_validacion`), corres el pipeline y aparecen dos cosas: la
página de tu pieza y, en el menú de arriba, una entrada nueva llamada **Fichas y
FAQ**. Esa entrada no existía antes: aparece con la primera pieza validada. Tu
pieza sale ahí listada con su título y con la frase «validada por [tu nombre]». En
su página, arriba, dice **interpretación institucional** y «validada por [tu
nombre] el [fecha]». Al pie, la lista de artículos que la respaldan, cada uno
enlazado.

**Si te equivocas, no rompes nada.** Poner `estado: borrador` otra vez y correr el
pipeline deja el sitio exactamente como estaba: la página desaparece, la entrada del
menú desaparece, y las demás páginas vuelven a ser idénticas. Comprobado.

**Lo que el pipeline te va a rechazar.** Si el ancla de una fuente no existe, el
pipeline se detiene y te dice qué pieza, qué ancla y en qué documento. No publica a
medias. Dos de las 22 piezas sembradas están en ese caso hoy y hay que arreglarlas
antes de validarlas: `faq_revision_de_mochilas.md` y `faq_seguridad_y_deteccion.md`,
las dos por apuntar a `dictamen_078_...html#materia` y `#concordancias`, que ya no
existen porque ese documento pasó a ser una transcripción por páginas.

**La firma tiene que ser un nombre y un apellido.** `pendiente`, `s/i`, `x` o una
sola palabra no valen: el pipeline se detiene y te lo dice. Escribe
`validado_por: "María Pérez"`. Mientras la pieza sea un borrador, déjalo en `null`.

**Ojo con una cosa: tu pieza no aparecerá en el buscador.** El buscador indexa el
texto de las normas, no las piezas interpretativas. Tu pieza se encuentra por el
menú **Fichas y FAQ**, no escribiendo su tema en la caja de búsqueda. Está
registrado como pregunta pendiente para el titular.

**Cuando cierras una revisión de OCR.** Desaparece el aviso de «no es una cita
textual» y el chip rojo de «OCR sin revisar», y en su lugar queda una nota que dice
que la transcripción está revisada por el equipo. **Lo que no cambia**: el documento
se sigue navegando por páginas, no por artículos, y el PDF sigue siendo la fuente
oficial. Si una ficha necesita citar ese documento, citará una página.
