# Log — indexación de piezas y cierre documental (v7), sesión 2

Encargo: `50_documentacion/andamios/20260827_encargo_cierre_calidad_v7.md`.
Ejecutado el 2026-08-27, autónomo, secuencial, en un turno. Sin subagentes.
Orden pedido y cumplido: FASE 0 → T1 → T3 → T2 → cierre.
**`ESTADO.md` no se tocó**; ninguna pieza real se publicó.

## 1. Resumen

Las tres tareas se ejecutaron. **Una mitad congelada**: la comprobación (d) de T1,
por la condición 4. Todo lo demás pasó.

- **T1**: `origin/main` ya estaba sincronizado, así que se verificó el run existente.
  Run en verde, autoprueba en verde, versiones fijadas confirmadas en el runner. **El
  diff de andamiaje NO cae a 0**: cae de 15 líneas a 2, que son una sola línea. Esa
  mitad queda **congelada** y se reporta con el diff, sin arreglar nada.
- **T3**: diff del README aplicado por delegación explícita del titular. Dos hunks,
  ni uno más. **Y destapó un problema que el diff no cubría**: el ejemplo canónico del
  propio README usa una de las dos anclas muertas de E-d.
- **T2**: las piezas publicadas entran al buscador. Control en las dos direcciones
  sobre el clon: **25 URLs indexadas antes, 26 después** (25 normas + 1 pieza).

## 2. Inventario de commits

| Commit | Mensaje |
|---|---|
| `ff57532` | `docs(andamios): encargo v7` |
| `62d1bab` | `docs(curaduria): readme de piezas al dia con la compuerta ronda 2 (delegacion del titular)` |
| `84baef8` | `fix(sitio): piezas publicadas indexadas en el buscador (E-c del ensayo)` |

## 3. FASE 0

| # | Qué | Medido |
|---|---|---|
| 1 | Porcelain y sincronía | única entrada `??` era este encargo → commiteado; `HEAD` == `origin/main` == `a38489a` |
| 2 | `ESTADO.md` | `sesion_abierta: true`, `commit_cierre: 358e150` |
| 3 | `data-pagefind` | 3 apariciones: filtro (143), cuerpo en `pagina_norma()` (263), comentario (328). **Ninguna en `pagina_pieza()`** |
| 4 | Aplicabilidad del diff | La frase base **sí está**, ajustada en dos líneas (33-34) donde el diff la escribió en una. Comparada plegada a una línea: 1 coincidencia exacta. **La condición 5 no se dispara** |
| 5 | Línea base | 28 archivos, conjunto `25eec8681b8dd12eb693d82cfc14a8b646efb1f7b45e065fe87ca3cd7c7c2c71` |

## 4. Cambios sustantivos

### 4.1 T1 — Push y verificación en runner

`origin/main` ya estaba en `a38489a`, así que no hubo push nuevo: se verificó el run
que ese push había disparado.

| | Evidencia |
|---|---|
| **(a) run** | **33093208170**, `completed / success`, 2 m 0 s. `construir` y `desplegar` con **0 pasos fallidos** |
| **(b) autoprueba** | paso «Autoprueba de la compuerta de coincidencia parcial»: **`success`** |
| **(c) versiones** | `/opt/R/4.5.2` y `Quarto 1.9.38` en el log del runner — **las fijadas**, sin caer a una cercana |
| **(d) andamiaje** | **NO cae a 0. CONGELADA** (condición 4) |

**(d), con el diff.** Las dos páginas responden **200** y pesan exactamente lo mismo
que las locales (25 315 y 36 452 bytes), y las dos declaran `quarto-1.9.38`. El diff
bajó de **15 líneas a 2**, y las 2 son una sola línea, la misma en ambas:

```
< <link href="site_libs/bootstrap/bootstrap-8c38fd85d21bfe44b50360969156fb14.min.css" ...>   (local)
> <link href="site_libs/bootstrap/bootstrap-b1376423af881990cfd602ae2f353e6b.min.css" ...>   (desplegado)
```

Medido en la adenda de v6: **no es solo el nombre**. Los dos bundles pesan
exactamente 498 675 bytes y difieren en 684 líneas plegadas. Es el tema `cosmo` que
Quarto compila desde SASS, y con la **misma** versión sale distinto en Linux y en
macOS. El nombre del archivo es un hash de su contenido, así que la línea que difiere
en el HTML es consecuencia, no causa.

Fijar las versiones hizo lo que se le pidió: el HTML **que produce este pipeline** ya
es idéntico entre las dos cadenas. Lo irreproducible es un tema compilado que este
proyecto no genera. No se arregló nada.

### 4.2 T3 — README de piezas, por delegación

Aplicado exactamente el diff de `20260827_diff_propuesto_readme_piezas.md`: **2 hunks**,
verificado con `git diff | grep -c '^@@'`. Ninguna otra ruta de `20_insumos/` en el
porcelain. El archivo re-abre limpio y el front matter de su ejemplo sigue parseando.

**Un juicio al aplicar, declarado.** El diff decía «después del bloque de ejemplo,
añadir». El bloque nuevo se colocó al **final** de la sección, después de la prosa que
explica `fuentes`, y no entre el ejemplo y esa prosa: meterse en medio habría separado
una explicación de su objeto. Queda dentro de la sección y después del ejemplo, que es
lo que el diff pide.

### 4.3 T2 — E-c: las piezas entran al buscador

`pagina_pieza()` ahora emite `data-pagefind-body`, con el mismo mecanismo que
`pagina_norma()`, y **respeta sus exclusiones**: la cabecera de firma queda fuera del
cuerpo indexado (es procedencia, no contenido) y la lista de `## Fuentes` también, por
el mismo motivo por el que el bloque de relacionados de la página de norma está fuera
—son slugs y números de artículo, y buscar `ley_20536` empezaría a devolver piezas
cuyo único vínculo con el término es su pie de fuentes—. `piezas.qmd`, que es un
índice, **no** se indexa.

**Frente 1, repo real.** Regeneración: «22 en total, **0** validadas y publicables»,
**28 de 28** archivos byte a byte idénticos, 0 páginas de pieza. La condición 6 no se
disparó.

**Frente 2, clon** (`/tmp/slep_v7_clon`, remote eliminado y verificado, borrado al
cerrar). Se repitió el paso 1 del guion del ensayo v6 y se midió en las dos
direcciones con el mismo instrumento:

| | URLs indexadas | de norma | de pieza |
|---|---:|---:|---:|
| **Antes** (código de `62d1bab`) | 25 | 25 | **0** |
| **Después** (con el cambio) | **26** | 25 | **1** (`/pieza-faq-expulsion.html`) |

El instrumento pasó su **prueba de humo** antes de reportar cada conteo (lección v6):
si no encuentra la URL de una norma conocida en el índice, se detiene en vez de
informar un número.

Comprobaciones adicionales, todas sobre el HTML e índice reales del clon:

- Páginas con `data-pagefind-body`: **26** (25 + 1); `piezas.html`: **0**.
- `page_count` que declara `pagefind-entry.json`: **26**.
- Filtros que emite la pieza:
  `tipo:Preguntas frecuentes`, `fuente:interpretación institucional`,
  `tema:medidas disciplinarias`, registrados en el fragmento como
  `"filters":{"fuente":[…],"tema":[…],"tipo":[…]}`.
- **Qué quedó dentro y qué fuera**, leyendo el fragmento descomprimido: contiene
  `expulsar` (cuerpo) → **sí**; contiene `ley_20536_violencia_escolar` (slug de
  Fuentes) → **no**; contiene `art-16-d` → **no**; contiene `Ensayo General` (firma)
  → **no**.

**Los filtros no son decorativos, y por eso van.** Pagefind excluye de una faceta las
páginas que no declaran su valor: una pieza indexada **sin** filtros aparecería en la
búsqueda libre y desaparecería en cuanto alguien usara cualquier filtro. La faceta
`fuente` tenía un único valor en todo el sitio (`normativa`, 25 páginas); la pieza
aporta el segundo, que es justo la distinción que le importa al lector: texto legal
frente a lectura del equipo.

## 5. Verificación de invariantes 🔒

| Invariante | Comprobación | Resultado |
|---|---|---|
| Ninguna pieza real se publica | log del paso 34 y `ls` del sitio real | **cumplido**: 22 / 0, 0 `pieza-*.html` |
| `40_salidas/` solo por regeneración | única vía `Rscript 00_run_all.R` | **cumplido**; 28 de 28 byte a byte |
| `20_insumos/` solo se toca donde delega el titular | `git status --porcelain -- 20_insumos/` | **una sola ruta**: `piezas/README.md`, la delegada |
| La delegación cubre UN archivo y UN cambio | `git diff \| grep -c '^@@'` = **2** hunks, los dos del diff propuesto | **cumplido** |
| Los clones no empujan y se borran | `git remote -v` vacío tras el clon; `rm -rf` y comprobación | **cumplido** |
| `ESTADO.md` no se toca | `git diff` sobre esa ruta | **vacío** |
| Sin subagentes | ninguno invocado | **cumplido** |

## 6. Estado de cifras

| Cifra | Valor | Comando |
|---|---:|---|
| Hunks del diff del README | **2** | `git diff \| grep -c '^@@'` |
| Líneas del README, antes → después | 113 → **134** | `readLines` |
| Páginas con `data-pagefind-body` en el clon | **26** (25 + 1) | `grep -l` sobre el HTML |
| URLs indexadas, antes → después | 25 → **26** | fragmentos descomprimidos con `gzfile()` |
| `page_count` de `pagefind-entry.json` | **26** | `jq` |
| Archivos versionados byte a byte | **28 de 28** | `shasum -a 256 -c` |
| Diff andamiaje desplegado vs local | 15 → **2** líneas (una sola línea real) | `diff` sobre el HTML segmentado |
| Bundle de Bootstrap: tamaño / sha256 | 498 675 = 498 675 bytes, sha distintos | `shasum` sobre el CSS descargado |

## 7. Decisiones del usuario registradas en gates

**Delegación de T3.** El titular autorizó explícitamente, en el chat de esta sesión,
escribir en `20_insumos/curaduria/piezas/README.md` **únicamente** para aplicar el
diff propuesto de `20260827_diff_propuesto_readme_piezas.md`. Es la segunda vez en la
cartera que se escribe en `20_insumos/` bajo delegación (la primera fue la entrada de
curaduría de la Duda 2). Alcance ejercido: un archivo, dos hunks, ningún otro cambio.

**Decisión aprobada de E-c**: el material de apoyo publicado debe ser encontrable. Ejecutada en T2.

**Segunda delegación de la sesión, para V-a.** Tras leer el reporte de v7, el titular
autorizó explícitamente un cambio más en `20_insumos/curaduria/piezas/README.md`:
sustituir en el bloque de ejemplo la entrada de `fuentes` que apuntaba a
`dictamen_078_...#materia` por una fuente verificada, previa comprobación en el mismo
turno de que su ancla resuelve. Alcance ejercido: **un hunk**, ningún otro cambio.
Con esto son tres las escrituras en `20_insumos/` bajo delegación en la cartera.

## 7bis. Decisiones autónomas

| # | Decisión | Alternativa descartada | Reversibilidad |
|---|---|---|---|
| D1 | **La pieza emite también filtros** (`tipo`, `fuente`, `tema`), no solo `data-pagefind-body`. | Emitir solo el cuerpo indexado. | Reversible: tres líneas. Se hizo **con medición**: la faceta `fuente` tenía un único valor en las 25 páginas del sitio, y Pagefind excluye de una faceta las páginas que no declaran su valor, así que sin filtros la pieza aparecería en la búsqueda libre y desaparecería al primer filtro. `pagina_norma()` emite cuerpo y filtros en el mismo bloque: es el mismo mecanismo, completo. |
| D2 | **`## Fuentes` y la cabecera de firma quedan FUERA del cuerpo indexado.** | Indexar la página entera. | Reversible: mover dos líneas. Es la exclusión que el propio archivo ya aplica al bloque de relacionados, con su razón escrita. Verificado leyendo el fragmento: no contiene ni el slug ni el id de artículo ni la firma. |
| D3 | **El bloque nuevo del README va al final de la sección**, no entre el ejemplo y su prosa. | Insertarlo justo tras el bloque de ejemplo, literal. | Reversible: es documentación. Insertarlo en medio separaba una explicación de su objeto. |

## 8. Dudas y pendientes abiertos

### V-a — El ejemplo del README apunta a un ancla que no existe (destapado por T3)

El bloque de ejemplo del README (`## Front matter obligatorio`) usa:

```yaml
fuentes:
  - {norma: dictamen_078_detectores_revision_mochilas, articulo: materia, ancla: "dictamen_078_detectores_revision_mochilas.html#materia"}
```

Medido en este turno: los únicos `id` de esa norma son `ocr-pagina-001`…`ocr-pagina-009`;
`materia` **no resuelve**. Es la misma ancla muerta de E-d, en el documento que el
equipo va a copiar.

**Y ahora el README se contradice**: el bloque que T3 acaba de insertar dice «Cada
`ancla` tiene que existir de verdad», justo debajo de un ejemplo cuya ancla no existe.
Esa contradicción la introdujo esta cadena al aplicar la delegación **a la letra**: el
diff delegado cubría dos cambios y este habría sido un tercero, fuera de una
autorización que dice «UN archivo y UN cambio».

**Pregunta cerrada.** ¿Se sustituye el ejemplo del README por una fuente que resuelva
(por ejemplo `ley_20536_violencia_escolar` / `art-16-d`, verificada en este turno), en
la misma delegación o en una nueva?

### V-b — La mitad congelada de T1

El diff de andamiaje no cae a 0 (§4.1). Traspaso v02 junto con el resto del
no-determinismo del sitio.

*Hipótesis no verificada, con su comando* (heredada de la adenda v6, sin cambio):
puede haber una caché en `40_salidas/sitio_src/.quarto` sirviendo un tema compilado
antiguo. Se comprueba con
`rm -rf 40_salidas/sitio_src/.quarto && Rscript 00_run_all.R` y volviendo a comparar
el hash del bundle.

### Heredadas y no tocadas

E-d (anclas rancias de las 2 FAQ) sigue como pendiente operativo de la vía A: el
pipeline avisa en cada corrida y abortaría su publicación. El no-determinismo de
`estado` del manifiesto y de `pagefind-entry.json` viaja al traspaso v02. Las demás
dudas del log v6 (E-e a E-i) siguen abiertas donde estaban.

## 9. Notas para el revisor

**Lo que falló o sorprendió.** Dos cosas.

1. **La única comprobación que falló es la que ya se sabía que podía fallar**, y falló
   por una causa que no estaba prevista: no es la versión de Quarto (esa quedó fijada y
   coincide), sino que el **tema compilado** sale distinto en Linux y en macOS con la
   misma versión, y con el mismo tamaño de archivo al byte. Un bundle de 498 675 bytes
   idéntico en tamaño y distinto en 684 líneas no es lo que uno espera encontrar
   detrás de un hash que no cuadra.

2. **Aplicar una delegación a la letra puede empeorar la coherencia del documento.**
   El diff del README era correcto y se aplicó exactamente; el resultado es un README
   que exige que las anclas existan encima de un ejemplo cuya ancla no existe. La
   alternativa —arreglar el ejemplo de paso— habría sido un tercer cambio en un
   directorio de solo lectura, bajo una autorización que dice «UN archivo y UN cambio».
   Se aplicó lo delegado y se reporta la contradicción como V-a, que es lo que la
   autorización permite.

**Lo que este encargo deja listo.** E-c cerrada y verificada en las dos direcciones;
el README dice lo que el pipeline exige; el runner corre las versiones fijadas y ve
dispararse la compuerta en cada despliegue. Antes de entregar la pauta queda una
decisión de una línea: V-a.

---

# Adenda — cierre de v7: V-a, V-b y evidencia de CI

## A. V-a — el ejemplo del README ya apunta a un ancla que resuelve

Delegación registrada en §7. **Verificado ANTES de escribir**, en este turno, con la
compuerta real (`ancla_resuelve()` extraída del árbol de parseo del generador y
alimentada con `anclas_disponibles()` sobre los 25 JSON):

| Entrada | `ancla_resuelve` |
|---|:-:|
| `{ley_20536_violencia_escolar, art-16-d, "ley_20536_violencia_escolar.html#art-16-d"}` | **TRUE** |
| `{dictamen_078_detectores_revision_mochilas, materia, "…#materia"}` (la que había) | **FALSE** |

Comprobaciones de respaldo: `ley_20536_violencia_escolar` tiene 8 artículos, uno de
ellos `art-16-d` (etiqueta «Artículo 16 D»), y su `origen_texto` es `capa_texto_pdf`,
así que **es citable**; el `id` aparece además en el HTML publicado. El dictamen 078
solo tiene `ocr-pagina-001`…`009`.

Cambio aplicado: **1 hunk**, una línea, ninguna otra ruta de `20_insumos/` tocada. El
front matter del ejemplo sigue parseando con sus 8 campos y su ancla ahora resuelve.
Commit `9df5d64`.

**Un residuo que conviene decir.** El ejemplo tiene por `titulo` «¿Se puede revisar la
mochila de un estudiante?» y su fuente pasa a ser un artículo sobre violencia ejercida
por quien detenta autoridad: el ejemplo ya no es semánticamente coherente consigo
mismo, aunque sí formalmente correcto (que es lo que un ejemplo de front matter
ilustra). Existe una alternativa que habría mantenido las dos cosas y que se midió en
este turno: **`dictamen_065_revision_mochilas` / `materia`**, que es `capa_texto_pdf`,
tiene `materia` entre sus 4 `id` reales y trata justamente de revisión de mochilas. No
se usó porque la delegación nombraba la otra fuente. Queda como cambio de una línea si
el titular lo prefiere.

## B. V-b — la hipótesis de la caché: REFUTADA

Procedimiento pedido: `rm -rf 40_salidas/sitio_src/.quarto && Rscript 00_run_all.R`, y
comparar.

| Medición | Antes | Después |
|---|---|---|
| `40_salidas/sitio_src/.quarto` | existe, 4,3 MB | borrado, y **regenerado por el render** |
| Bundle de Bootstrap (nombre) | `bootstrap-8c38fd85d21bfe44b50360969156fb14.min.css` | **el mismo** |
| Bundle, `sha256` | `e75e401cd6c091a4136db2d85022373b864ceda318f726e7d316e013883f6447` | **idéntico** |
| Los 28 archivos versionados | línea base | **28 de 28 byte a byte** |
| `git status --porcelain` | vacío | **vacío** |

**Ningún archivo versionado cambió**, así que no hubo que restaurar ni congelar nada.
Y el bundle no cambió de hash: **la hipótesis queda refutada**.

Hay además un argumento estructural que la refuta por construcción y que apareció al
mirar el código para montar la prueba: `34_generar_paginas.R:1107` hace
`if (fs::dir_exists(destino)) fs::dir_delete(destino)` sobre `40_salidas/sitio_src/`,
de modo que **esa caché se destruye en cada corrida de todos modos**. Nunca pudo estar
sirviendo un tema antiguo.

**Conclusión sobre V-b.** La diferencia de una línea entre el HTML local y el
desplegado no viene de una caché local: el tema `cosmo` que Quarto compila desde SASS
sale distinto en Linux y en macOS con la **misma** versión de Quarto (498 675 bytes en
ambos, 684 líneas plegadas distintas). No es reproducible entre plataformas y no lo
produce este proyecto. La mitad congelada de T1 se cierra con esa explicación, no con
un arreglo.

## C. Evidencia de CI del push de cierre

`git push origin main` → `a38489a..9df5d64`.

| | |
|---|---|
| Run | **33094362295**, `head_sha` = `9df5d64` (comprobado, no supuesto) |
| Estado | **completed / success**, 2 m 31 s |
| Jobs | `construir` ✓ · `desplegar` ✓, **0 pasos fallidos** en ambos |
| Autoprueba de la compuerta | **`success`**, con su línea de cierre en el log: `Autoprueba de la compuerta de coincidencia parcial: SUPERADA.` |
| Versiones del runner | `/opt/R/4.5.2` y `quarto-1.9.38` |
| Piezas en el runner | `Piezas interpretativas: 22 en total, 0 validadas y publicables.` |

**El sitio no cambió, que es lo correcto**: con 0 piezas validadas, el cambio de T2 no
toca ninguna salida. Las dos páginas muestreadas responden **200** y siguen a **2
líneas** del HTML local (la línea del bundle de §B, sin cambio). `piezas.html` devuelve
**404**, como debe: no hay ninguna pieza publicada.

*Nota de método:* el primer intento de leer el run tomó el id **antes** de que el push
registrara el suyo, y leyó el run anterior. Se detectó comparando el `head_sha` del run
con el commit pusheado; la evidencia de esta sección es la del run correcto.

## D. Estado al cierre

`origin/main` = `9df5d64` más el commit de esta adenda. `ESTADO.md` intacto
(`sesion_abierta: true`, `commit_cierre: 358e150`). Ninguna pieza publicada. La sesión
sigue abierta.
