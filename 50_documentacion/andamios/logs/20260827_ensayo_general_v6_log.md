# Log — ensayo general y cierre de calidad (v6), sesión 2

Encargo: `50_documentacion/andamios/20260827_encargo_ensayo_general_v6.md`.
Ejecutado el 2026-08-27, modo autónomo, secuencial, en un turno.
Orden pedido y cumplido: FASE 0 → T1 (con panel) → T2 → T3a → T3b → T5.
**La sesión NO se cierra: `ESTADO.md` no se tocó** (`git diff 7bbb452..HEAD --
50_documentacion/activa/ESTADO.md` vacío).

## 1. Resumen de la sesión

Las cinco tareas se ejecutaron completas. **Ninguna quedó congelada.** Ninguna de
las ocho condiciones de detención se disparó. El panel encontró **once defectos en
las reglas que esta misma cadena acababa de escribir**, y los once se corrigieron
antes del commit.

- **T1** cerró la ronda 2 de la compuerta (D-a, D-b, D-c, D-d, D-e, D-h): 53
  conductas medidas, **26 cambian de veredicto**, las 22 piezas reales sin cambio.
- **T2** fijó R 4.5.2 y Quarto 1.9.38 en el workflow y añadió una **autoprueba** que
  provoca una coincidencia parcial y exige que la corrida falle. Verificado que la
  autoprueba **detecta las dos formas de romper la compuerta**.
- **T3a** respondió por primera vez con evidencia si el pipeline corre de cero:
  **27 de 28 archivos byte a byte**, y el 28.º difiere solo en un campo de bitácora.
- **T3b** ejercitó el camino de publicación de punta a punta y encontró lo que
  ningún arnés podía encontrar: **la pieza publicada no entra al buscador**.
- **T5** alineó la pauta con la regla real de firma y dejó el diff del README de
  piezas como tarea manual, porque vive bajo `20_insumos/`.

## 2. Inventario de commits

| Commit | Mensaje | Numstat |
|---|---|---|
| `d55670a` | `docs(andamios): encargo v6` | 123 / 0 |
| `d3e8b69` | `fix(sitio): compuerta ronda 2 (D-a b c d e h del log v5)` | 301 / 43 en `34_generar_paginas.R` |
| `5e8fb78` | `feat(ci): versiones fijadas y autoprueba de la compuerta de coincidencia parcial` | 20 / 1 en `publicar.yml`; 88 / 0 en `10_utils/10_autoprueba_coincidencia_parcial.R` |
| `668e672` | `docs(andamios): ensayo general de la via A en clon` | 215 / 0 |
| `1862030` | `docs(andamios): pauta alineada con la compuerta final` | 4 / 4 en la pauta; 66 / 0 en el diff propuesto del README |

Árbol limpio. `20_insumos/` sin un solo cambio en toda la cadena. Los 28 archivos
versionados de `40_salidas/` byte a byte idénticos a la línea base de FASE 0.

## 3. FASE 0 — medición

| # | Qué | Medido |
|---|---|---|
| 1 | Porcelain y sincronía | única entrada `??` era este encargo → commiteado; `HEAD` == `origin/main` == `7bbb452`; `git log 7bbb452..HEAD` vacío |
| 2 | `ESTADO.md` | `sesion_abierta: true`, `commit_cierre: 358e150` |
| 3 | Arnés de partida | **53 casos** reproducidos sobre el código actual, cubriendo toda la lista pendiente de §2 (ver §4.1) |
| 4 | README de piezas | `20_insumos/curaduria/piezas/README.md`, **bajo `20_insumos/`** → no editable; **8** campos bajo «Front matter obligatorio» |
| 5 | Versiones del workflow | `r-version: 'release'` y `quarto-actions/setup@v2` **sin `version`**; node sí fijado en 22 |
| 6 | Anclas y candidata | **92** anclas, **2** rotas (las dos conocidas); candidata limpia elegida por medición: `faq_expulsion.md`, 4 fuentes, 4 resuelven |
| 7 | Dependencias | **no hay renv ni packrat**: `instalar_si_falta()` contra la biblioteca ambiente; Node por `package-lock.json`, `node_modules/` no versionado |
| 8 | Línea base | 28 archivos, sha256 del conjunto `25eec8681b8dd12eb693d82cfc14a8b646efb1f7b45e065fe87ca3cd7c7c2c71` |

## 4. Cambios sustantivos

### 4.1 T1 — Ronda 2 de la compuerta

**Reglas implementadas**, todas sobre `revisar_pieza()` / `cargar_piezas()`:

- `titulo` obligatorio, texto escalar no vacío.
- `fecha_validacion` obligatoria si `estado: validada`, formato `AAAA-MM-DD` que
  además exista como fecha (`2026-02-30` no pasa).
- `fuentes` obligatoria si validada: lista no vacía, cada entrada con `norma`,
  `articulo` y `ancla` de tipo texto **y no vacíos**.
- `validado_por`: dos palabras alfabéticas de 2+ letras tras normalizar espacios
  invisibles, más lista negra `NO_SON_FIRMA`.
- `tipo` se normaliza como `estado` (`tolower` + espacios invisibles).
- **Colisión de slug** entre dos piezas cualesquiera → aborta nombrando ambas.
- **Compuerta de anclas**: sobre lo publicable aborta; sobre borradores avisa.
- Lectura robusta: no-UTF-8 (Latin-1 **y UTF-16**) aborta nombrando el archivo;
  `README.md`/`LEEME.md` se excluyen sin distinguir mayúsculas.
- Candado de conteo que enumera qué falta, qué sobra y qué nombre está repetido.

**Tabla completa antes / después**, 53 casos, mismo arnés sobre los dos árboles.
**26 cambian de veredicto, 27 se mantienen.** Distribución: antes 24 ABORTA / 19
PUBLICA / 3 REVIENTA-INDICE / 2 REVIENTA-PAGINA / 2 SLUG-COLISION / 1
PUBLICA-ANCLA-MUERTA / 2 OMITE; después **42 ABORTA / 9 PUBLICA / 2 OMITE**, sin
ningún reventón aguas abajo.

| Grupo | Caso | Antes (v5) | Después (ronda 2) | |
|---|---|---|---|:-:|
| v5 | legitimo completo | PUBLICA | **PUBLICA** | = |
| v5 | validada sin validado_por | ABORTA | **ABORTA** | = |
| v5 | validado_por solo espacios | ABORTA | **ABORTA** | = |
| v5 | validado_por ~ | ABORTA | **ABORTA** | = |
| v5 | clave prefijada (O5) | ABORTA | **ABORTA** | = |
| v5 | borrador con firma | OMITE | **OMITE** | = |
| v5 | sin clave estado | ABORTA | **ABORTA** | = |
| v5 | estado: Validada | PUBLICA | **PUBLICA** | = |
| v5 | estado: ' validada ' | PUBLICA | **PUBLICA** | = |
| v5 | tipo desconocido (minuta) | ABORTA | **ABORTA** | = |
| v5 | sin clave tipo | ABORTA | **ABORTA** | = |
| v5 | validado_por: no | ABORTA | **ABORTA** | = |
| v5 | validado_por: true | ABORTA | **ABORTA** | = |
| v5 | validado_por: 12345 | ABORTA | **ABORTA** | = |
| v5 | validado_por: .nan | ABORTA | **ABORTA** | = |
| v5 | validado_por: 2026-08-26 | ABORTA | **ABORTA** | = |
| v5 | validado_por: [] | ABORTA | **ABORTA** | = |
| v5 | fm declara cuerpo | ABORTA | **ABORTA** | = |
| v5 | fm declara archivo | ABORTA | **ABORTA** | = |
| v5 | clave YAML duplicada | ABORTA | **ABORTA** | = |
| v5 | sin front matter | ABORTA | **ABORTA** | = |
| v5 | fm no es un mapa | ABORTA | **ABORTA** | = |
| D-a | sin titulo | REVIENTA-INDICE | **ABORTA** | **→** |
| D-a | titulo: ~ | REVIENTA-INDICE | **ABORTA** | **→** |
| D-a | titulo: no (booleano) | PUBLICA | **ABORTA** | **→** |
| D-a | titulo: [a, b] | REVIENTA-INDICE | **ABORTA** | **→** |
| D-a | titulo vacio | PUBLICA | **ABORTA** | **→** |
| D-a | sin fecha_validacion | PUBLICA | **ABORTA** | **→** |
| D-a | fecha_validacion: no | PUBLICA | **ABORTA** | **→** |
| D-a | fecha_validacion: lista | PUBLICA | **ABORTA** | **→** |
| D-a | fecha_validacion: prosa | PUBLICA | **ABORTA** | **→** |
| D-a | sin fuentes | PUBLICA | **ABORTA** | **→** |
| D-a | fuentes: cadena | REVIENTA-PAGINA | **ABORTA** | **→** |
| D-a | fuentes sin articulo/ancla | REVIENTA-PAGINA | **ABORTA** | **→** |
| D-a | fuentes: [] vacia | PUBLICA | **ABORTA** | **→** |
| D-e | ancla inexistente, VALIDADA | PUBLICA-ANCLA-MUERTA | **ABORTA** | **→** |
| D-e | ancla inexistente, BORRADOR | OMITE | **OMITE** | = |
| D-b | validado_por: pendiente | PUBLICA | **ABORTA** | **→** |
| D-b | validado_por: s/i | PUBLICA | **ABORTA** | **→** |
| D-b | validado_por: x | PUBLICA | **ABORTA** | **→** |
| D-b | validado_por: "null" | PUBLICA | **ABORTA** | **→** |
| D-b | validado_por: "N/A" | PUBLICA | **ABORTA** | **→** |
| D-b | validado_por una palabra | PUBLICA | **ABORTA** | **→** |
| D-b | firma con NBSP en medio | PUBLICA | **PUBLICA** | = |
| D-b | firma con rol (3 palabras) | PUBLICA | **PUBLICA** | = |
| D-h | estado validada + NBSP | ABORTA | **PUBLICA** | **→** |
| D-h | estado con a cirilica | ABORTA | **ABORTA** | = |
| D-h | tipo: Ficha | ABORTA | **PUBLICA** | **→** |
| D-h | tipo: ' ficha ' | ABORTA | **PUBLICA** | **→** |
| D-h | Readme.md como pieza | ABORTA | **PUBLICA** | **→** |
| D-h | archivo en Latin-1 | ABORTA | **ABORTA** | = |
| D-d | dos piezas, mismo basename | SLUG-COLISION | **ABORTA** | **→** |
| D-d | dos piezas slug vacio | SLUG-COLISION | **ABORTA** | **→** |

**Condición 7 (las 22 piezas reales):** «22 en total, 0 validadas y publicables»
antes y después, sin aborto. La ronda 2 añade un `WARN` nuevo que nombra las 2
anclas rotas de borrador. Regeneración por `Rscript 00_run_all.R`: **28 de 28**
archivos versionados byte a byte idénticos.

### 4.2 T2 — CI reproducible y con autoprueba

**Versiones fijadas.** `r-version: '4.5.2'` y `version: '1.9.38'`. Antes de fijarlas
se comprobó que existen: `gh api repos/quarto-dev/quarto-cli/releases/tags/v1.9.38`
devuelve `prerelease=false`, publicado 2026-05-25. La condición 6 no se disparó: no
hubo que elegir versiones cercanas.

**Autoprueba** (`10_utils/10_autoprueba_coincidencia_parcial.R`, paso de CI antes del
pipeline). Vive en `10_utils/` y no en `30_procesamiento/` porque lo que prueba es un
invariante de la capa de utilidades, y un archivo suelto en el directorio del
pipeline se lee como una etapa más. Hace dos cosas:

1. **Control positivo**: escribe un paso de juguete que reproduce el defecto del
   DFL 1 (`curado$anio` sobre una lista que solo declara `anios_alternativos`), lo
   ejecuta con el `ejecutar_paso()` real, y exige que falle **y que el mensaje
   nombre el acceso culpable**.
2. **Control negativo**: un paso con `as.integer("x")`, `log(-1)` y un `warning()`
   propio **no** debe tumbar la corrida.

**Y se verificó que la autoprueba detecta una compuerta rota**, que es lo que
convierte su `exit 0` en información. En un clon desechable:

| Escenario | Resultado |
|---|---|
| Compuerta sana | `exit 0` |
| `options(warnPartialMatch* = FALSE)` | `exit 1` — «No se pudo derivar el aviso de coincidencia parcial…» |
| Opciones puestas pero manejador neutralizado | `exit 1` — «AUTOPRUEBA FALLIDA: el juguete provocó una coincidencia parcial y la corrida NO falló» |

### 4.3 T3a y T3b

Producto completo: **`50_documentacion/andamios/20260827_ensayo_general_v1.md`**
(215 líneas), con el guion ejecutado, la evidencia de cada verificación, los
fragmentos de HTML y la sección «lo que el equipo verá» en lenguaje llano.
Resumen aquí; el detalle está allí.

- **T3a**: `40_salidas/` borrada entera en el clon y regenerada. **27 de 28 byte a
  byte.** El 28.º (`manifiesto_corpus.json`) difiere en 50 líneas, **las 50 del
  campo `estado`** (`sin_cambio` ×25 vs `nuevo` ×25); las huellas son idénticas y el
  manifiesto sin ese campo es idéntico.
- **T3b paso 1**: publicación limpia de `faq_expulsion.md`. 5 de las 6
  verificaciones OK; la 4.ª (el buscador la indexa) **FALLA** (§5.3). La reversión a
  borrador restaura **48 de 49** páginas byte a byte.
- **T3b paso 2**: control positivo de la compuerta de anclas sobre datos reales. La
  regeneración **aborta** con salida 1 nombrando pieza, ancla y documento.
- **T3b paso 3**: `ocr_revisado` en la circular 586. Cambian 18 líneas de HTML
  (desaparecen el chip «OCR sin revisar», el aviso junto al PDF y el bloque «no es
  una cita textual»; el filtro pasa de `texto:OCR sin revisar` a `texto:verificado`).
  **No cambian** las anclas (`#ocr-pagina-001`, no `#art-1`), el rótulo «Páginas»
  del índice lateral, ni `marca_revisar`.

Los clones se borraron y se verificó el borrado (`/tmp/slep_v6_clon` y
`/tmp/slep_v6_metaprueba` inexistentes).

### 4.4 T5 — Coherencia documental

- **Pauta**: 4 sustituciones, todas sobre la instrucción de firma («nombre y fecha»
  → «**nombre y apellido** y fecha»), más una frase en las preguntas frecuentes que
  declara que el sistema rechaza una sola palabra o un «pendiente». Las otras dos
  menciones de «nombre y fecha» del documento **no se tocaron**: son la firma de una
  tabla y el registro de una decisión, no el campo `validado_por`.
- **README de piezas**: vive bajo `20_insumos/` → **no se editó**. El diff propuesto
  queda en `50_documentacion/andamios/20260827_diff_propuesto_readme_piezas.md`,
  con la tabla de qué regla nueva contradice qué frase actual. La más grave: el
  README invita a «mover» una pieza validada, y **copiar** en vez de mover ahora
  aborta el pipeline por colisión de slug.

## 5. El panel adversarial

Dos revisores, solo lectura, R/jq con Python prohibido declarado, escritura confinada
a `/tmp/slep_v6_panel{1,2}/`. **Los dos primeros cayeron por límite de sesión** —
fallo de infraestructura, que §1 excluye del tope— y se relanzaron; el panel siguió
siendo de dos.

### 5.1 Once defectos en las reglas recién escritas, corregidos antes del commit

Todos verificados por esta cadena, no aceptados del informe.

| # | Defecto | Corrección |
|---|---|---|
| 1 | **Falso negativo de la compuerta de anclas.** `sub("[.]html","")` aceptaba `norma#art-1` (sin extensión), `norma.html#a#b` y `norma#art-1.html`, y las tres se publican tal cual: 404. **La compuerta validaba una cadena distinta de la que publica** | forma exacta `^<norma>.html#<id>$` con un solo `#` |
| 2 | **Falso positivo por espacio invisible en el ancla.** Un espacio final abortaba el pipeline entero, y el mensaje mostraba un ancla visualmente idéntica a la correcta. Era el único campo de la ronda 2 sin normalizar | `normalizar_espacios()` en `ancla_resuelve`, **y también en `normalizar_pieza`**, para que lo validado sea exactamente lo publicado |
| 3 | **Un borrador con `fuentes` mal formado reventaba** con `subíndice fuera de los límites`, sin nombrar archivo. El estado de trabajo diario del equipo paraba el pipeline | `fuentes_en_forma()` filtra lo que no es lista antes de leerlo |
| 4 | **UTF-16 reventaba antes de la comprobación UTF-8**, volcando bytes crudos a la consola | `tryCatch` alrededor de `rawToChar` |
| 5 | **Reparo contradictorio**: `validado_por: "J. Pérez"` decía a la vez «no es el nombre de una persona» y «no trae un `validado_por`» | el segundo reparo solo si el campo está ausente |
| 6 | `norma` y `articulo` vacíos publicaban `- [, ](…)` | se exige `nzchar` en los tres |
| 7 | **La etiqueta podía mentir**: `{norma: dto_215, articulo: art-1, ancla: "ley_20536.html#art-16-d"}` publicaba una cita que nombra una norma y lleva a otra | cruce `norma`/`articulo` contra el ancla (ver §7bis D3) |
| 8 | El mensaje de `validado_por` perdió, respecto de v5, «una lista de nombres tampoco vale» y «déjalo vacío»: **regresión medible** que empujaba a falsificar una firma en un borrador | ambas restauradas |
| 9 | `fuentes` como cadena decía «no trae `fuentes`» a quien está mirando su línea `fuentes:` | mensaje propio para «no es una lista de entradas» |
| 10 | El reparo de entrada mal formada nombraba los tres campos genéricamente | nombra **el** campo que falta |
| 11 | **El candado de conteo mentía**: usaba `setdiff`, que pierde la multiplicidad, y ante dos temas con el mismo slug decía «Faltan: ninguna, Sobran: ninguna» | se añadió la lista de nombres repetidos |

Y uno de forma: el empalme del bloque había **duplicado literalmente** el comentario
de `escalar_texto`. Corregido.

### 5.2 La afirmación 🔒: NO REFUTADA

Revisor 1 midió por su cuenta las dos versiones sobre el corpus real: 22 archivos,
0 publicables, sin aborto en ninguna. Verificó además que el `WARN` nuevo **dice la
verdad**: 92 anclas, exactamente 2 no resuelven, y son las que nombra; confirmado con
`jq` que el dictamen 078 solo tiene `ocr-pagina-001`…`009`.

Revisor 2 llegó por otro camino y añadió la prueba que más importa: **sembrador y
compuerta siguen alineados**. Ejecutó `00_generar_borradores.R` completo redirigido a
`/tmp`, rellenó las tres líneas de firma en las 22 piezas sembradas y corrió la
compuerta: **22 de 22 publicables**, sin reventones.

### 5.3 Lo que el panel encontró y esta cadena NO corrigió

Va a §8 como duda. La regla es la misma que en v5: son reglas nuevas, no las que el
encargo aprobó.

- La lista negra de firmas **es de una sola familia**: `sin asignar`, `no aplica`,
  `por confirmar`, `equipo convivencia`, `aaa bbb` y `AA BB` siguen publicando. El
  propio revisor lo formuló bien: *ninguna lista negra por enumeración va a
  distinguir una firma de un relleno*.
- **Falsos positivos de la regla de dos palabras**: `J. Pérez`, `Ñ. Muñoz` (inicial y
  apellido) y `李 娜` abortan. La regla es la que el encargo especificó al detalle.
- **El cuerpo de la pieza no lo valida nadie**: revisor 2 renderizó con Quarto 1.9.38
  y comprobó que un `<script>` y un `<iframe>` en el cuerpo **llegan intactos al HTML
  publicado**, y que `{{< include ../afuera.md >}}` inyecta un archivo de fuera del
  sitio.
- El JSON de normas puede estar rancio cuando corre la compuerta de anclas
  (`run_all(only = 34)` es legal), y entonces culpa a la pieza de un ancla correcta.

## 6. Las tres dudas residuales, antes y después

Es la sección que el encargo pide como criterio de éxito: para cada duda, qué
evidencia había, cuál hay ahora, y qué queda honestamente sin probar.

### 6.1 El camino de publicación de piezas

| | |
|---|---|
| **Antes** | Toda la evidencia era de **arnés**: funciones extraídas del árbol de parseo, ejecutadas contra piezas sintéticas en `/tmp`. Ninguna pieza había recorrido nunca borrador → validada → página → índice → buscador. El sitio nunca había tenido una sola pieza publicada. |
| **Ahora** | Recorrido completo en clon, con evidencia por paso: la página existe y renderiza con su título y su línea de firma; el índice la lista; las 4 anclas resuelven contra el `id` real de cada norma; el navbar gana la entrada «Fichas y FAQ»; el candado de conteo cuadra (49 = 47 + 2); y **la reversión a borrador restaura 48 de 49 páginas byte a byte**. Se ejercitó además el camino de fallo con datos reales: una pieza con ancla muerta **aborta** nombrando pieza, ancla y documento. |
| **Sin probar** | El recorrido se hizo con **una** pieza; no se probó el índice con varias piezas validadas a la vez ni con los tres tipos (`ficha`, `faq`, `glosario`) simultáneos. Y nada de esto se ha hecho nunca con una persona real escribiendo el front matter: el ensayo simula la edición, no al editor. |
| **Lo que encontró** | **La pieza publicada no entra al buscador** (§5.3 del informe). 25 de 49 páginas llevan `data-pagefind-body`, y son las 25 normas. Es la clase de hallazgo que solo aparece renderizando e indexando de verdad. |

### 6.2 La reproducibilidad

| | |
|---|---|
| **Antes** | No estaba probada **ni desde cero ni entre cadenas**. El runner corría R 4.6.1 / Quarto 1.10.18 contra 4.5.2 / 1.9.38 declarados (D-j de la adenda v5), y el HTML publicado difería del local en 15 líneas de andamiaje. Nadie había borrado nunca `40_salidas/` para ver si volvía igual. |
| **Ahora** | **Desde cero: 27 de 28 archivos byte a byte**, y el 28.º difiere solo en un campo de bitácora de corrida, enumerado línea por línea. **Entre cadenas: las versiones quedan fijadas** en el workflow (4.5.2 y 1.9.38, ambas verificadas como existentes antes de fijarlas). |
| **Sin probar** | Que el runner **efectivamente** instale esas versiones y que el HTML desplegado pase a ser byte a byte idéntico al local: eso llega con el push de este cierre y se registra en la adenda. Y `npm ci` no se ejercitó en el clon (se copió `node_modules/`), porque este encargo no autoriza red. |
| **Lo que encontró** | Dos fuentes de no-determinismo, ninguna conocida antes: el campo `estado` del manifiesto versionado, que **por construcción** no puede coincidir en un build desde cero; y `pagefind-entry.json`, que **cambia entre dos corridas idénticas** porque incrusta un hash por build. |

### 6.3 El control positivo de la compuerta en el runner

| | |
|---|---|
| **Antes** | La adenda v5 lo declaró como hueco explícito: en el runner constaba que la compuerta estaba **armada** (si no, `00_run_all.R` aborta al derivar el aviso), pero nunca que **disparara**, porque el pipeline no produce ninguna coincidencia parcial. Una compuerta apagada y una que nunca tuvo nada que cazar dejan el mismo log verde. |
| **Ahora** | Existe un paso de CI que **provoca** una coincidencia parcial y exige el fallo, con control negativo incluido. Y se verificó que ese paso **detecta las dos formas de romper la compuerta**, así que su `exit 0` significa algo. |
| **Sin probar** | Que el paso pase en Linux: llega con el push de este cierre. Hasta que ese run esté en verde, el control positivo sigue siendo de macOS. |

## 7. Verificación de invariantes 🔒

| Invariante | Comprobación | Resultado |
|---|---|---|
| Nada cierra estados ni publica piezas **en el repo real** | log del paso 34 y `ls` del sitio | **cumplido**: 22 piezas, 0 publicables, 0 `pieza-*.html` |
| `20_insumos/` solo se lee **en el repo real** | `git diff 7bbb452..HEAD -- 20_insumos/` | **vacío** |
| `40_salidas/` solo por regeneración | todas las corridas por `Rscript 00_run_all.R` | **cumplido**; 28 de 28 byte a byte |
| El endurecimiento no cambia el veredicto de ninguna pieza real | arnés sobre las 22 con las dos versiones, y log del paso 34 | **cumplido**: 22 / 0 las cuatro veces |
| Toda regla nueva aborta nombrando archivo y clave | se provocó cada aborto y se leyó el texto | **cumplido**, y el panel forzó 11 correcciones para que lo fuera de verdad |
| **Los clones no empujan y se borran** | `git remote -v` vacío verificado tras cada clon; `rm -rf` y comprobación de inexistencia | **cumplido** en los dos clones |
| **Ninguna pieza real se publica: la única que llega a HTML vive y muere en el clon** | el clon se borró; el repo real nunca tuvo una pieza publicable | **cumplido** |
| Subagentes solo lectura, R/jq, Python prohibido | declarado en los cuatro prompts; `git status` vacío | **cumplido**; tope de 2 respetado |
| `ESTADO.md` no se toca | `git diff 7bbb452..HEAD` sobre esa ruta | **vacío** |

## 7bis. Decisiones autónomas

| # | Decisión | Alternativa descartada | Reversibilidad |
|---|---|---|---|
| D1 | **La autoprueba vive en `10_utils/`**, no en `30_procesamiento/`. | Ponerla donde el encargo la sugería primero. | Reversible: un `git mv`. Las autorizaciones no incluyen `30_procesamiento/` como directorio, solo un archivo; y lo que prueba es un invariante de la capa de utilidades. |
| D2 | **La autoprueba comprueba también el control negativo** y que el mensaje nombre el acceso culpable. | Comprobar solo que falla. | Reversible: dos bloques. Una compuerta que promoviera CUALQUIER advertencia también pasaría el control positivo. |
| D3 | **La compuerta de anclas cruza `norma` y `articulo` contra el ancla**, que el encargo no pedía. | Validar solo la existencia del ancla. | Reversible: dos comparaciones. Se hizo **con medición previa**: las 92 entradas del corpus real ya cumplen las tres condiciones, así que no rompe nada; y sin el cruce se publica una cita que nombra una norma y lleva a otra, que es lo contrario de la fidelidad que el sitio promete. Lo señalaron los dos revisores por separado. |
| D4 | **`node_modules/` se copió al clon** en vez de `npm ci`. | `npm ci`. | N/A. El encargo no autoriza red más allá de `gh` y la URL del sitio. Efecto declarado en el informe: T3a prueba el pipeline de R, no la resolución de npm. |
| D5 | **El arnés se detiene si le falta un nombre** en vez de reportar tabla. | Dejarlo como estaba. | Reversible: cuatro líneas. Se instaló **porque falló así**: al añadir las funciones nuevas, el arnés reportó 53 ABORTA que eran su propio fallo (§10). |
| D6 | **`force(anclas)` al entrar a `cargar_piezas()`.** | Confiar en que el argumento obligatorio basta. | Reversible: una línea. Lo midió revisor 2: el argumento es perezoso y solo se evalúa si alguna pieza llega validada, así que un llamador que lo olvidara no fallaría hoy y fallaría el día de la primera firma. El comentario que decía lo contrario habría sido falso. |

## 8. Dudas y pendientes abiertos

Ninguna tarea quedó congelada. Todo lo que sigue son preguntas cerradas para el
titular, verificadas por esta cadena.

### E-a — El manifiesto versionado lleva un campo de bitácora de corrida

`estado` (`nuevo` / `modificado` / `sin_cambio`) registra cómo **esta** corrida
clasificó cada documento respecto del manifiesto anterior. Está dentro de un archivo
versionado, así que **un build desde cero nunca producirá un
`manifiesto_corpus.json` byte a byte igual**: 27 de 28 idénticos y el 28.º
difiriendo en las 50 líneas de ese campo. Todo lo demás (las huellas) coincide.

**Pregunta cerrada.** ¿Se saca `estado` del archivo versionado (queda como línea de
log, que es lo que es), o se acepta y se declara que ese archivo no es
byte-reproducible?

### E-b — El sitio publicado nunca es byte a byte idéntico entre dos builds

`pagefind/pagefind-entry.json` cambia entre **dos corridas idénticas sin tocar
nada** (dos `sha256` distintos, medidos), porque incrusta un hash por build
(`"hash": "es_83f29fd27a"`). No está versionado, así que no afecta al repositorio,
pero sí acota lo que puede comprobar cualquier verificación de despliegue.

**Pregunta cerrada.** ¿La verificación de despliegue excluye ese archivo por
declaración, o se investiga si Pagefind admite un índice determinista?

### E-c — La pieza publicada no entra al buscador

Medido en el ensayo: 49 páginas, **25 con `data-pagefind-body`** (las 25 normas), 0
en `pieza-*.html` y `piezas.html`, 0 URLs de pieza en el índice. Causa exacta:
`data-pagefind-body` lo emite solo `pagina_norma()` (`34_generar_paginas.R:263`).

Hay dos lecturas y ninguna es obviamente la buena. **A favor de que sea deliberado**:
el mismo archivo excluye a propósito el bloque de relacionados del índice, con el
argumento de que buscar «expulsión» no debe devolver páginas cuyo único vínculo con
la palabra es una frase generada; una pieza es texto no normativo, igual que esas
explicaciones. **En contra**: el proyecto se describe como «biblioteca pública y
buscable», y el equipo va a validar una FAQ sobre expulsión esperando encontrarla al
buscar «expulsión». No estaba medido ni declarado en ninguna parte.

**Pregunta cerrada.** ¿Se indexan las piezas (con un `data-pagefind-meta` que las
distinga de las normas en los resultados), se excluyen **declarándolo** en la pauta y
en el «Acerca de», o se indexa solo su título?

### E-d — Dos de las 22 piezas abortarán el pipeline el día que se validen

`faq_revision_de_mochilas.md` y `faq_seguridad_y_deteccion.md` apuntan a
`dictamen_078_detectores_revision_mochilas.html#materia` y `#concordancias`, que ya
no existen: ese documento pasó a `ocr_pendiente_revision` **después** de sembrarse
los borradores, y sus únicos `id` son `ocr-pagina-001`…`009`. La compuerta tiene
razón; los borradores están rancios. Y `00_generar_borradores.R` **no puede
repararlos**: nunca sobreescribe un archivo existente.

Corregirlos exige escribir en `20_insumos/curaduria/piezas/`, fuera de las
autorizaciones de este encargo.

**Pregunta cerrada.** ¿Se corrigen a mano las dos anclas (apuntándolas a la página
del dictamen sin fragmento, o a la página OCR correspondiente), o se añade a
`00_generar_borradores.R` un modo que reescriba solo el bloque `fuentes` de un
borrador no validado?

### E-e — La lista negra de firmas no cierra su familia

Siguen publicando como firma: `sin asignar`, `no aplica`, `por confirmar`,
`en revisión`, `equipo convivencia`, `Dpto. Jurídico`, `aaa bbb`, `AA BB`. La lista
que el encargo especificó cubre `por definir` y no sus hermanos. Ninguna lista por
enumeración lo va a cerrar.

**Pregunta cerrada.** ¿Se acepta que la lista negra es un colador de lo más
frecuente y el resto lo cubre la pauta, o se cambia de enfoque (por ejemplo, exigir
que la firma no esté en un vocabulario de relleno **y** que el mismo nombre aparezca
en un registro de personas autorizadas)?

### E-f — Falsos positivos de la regla de dos palabras

`J. Pérez`, `Ñ. Muñoz` (inicial y apellido, forma habitual en documentos
institucionales) y `李 娜` **abortan el pipeline**. La regla es la que el encargo
especificó al detalle («al menos dos palabras alfabéticas de 2+ letras cada una»), y
se implementó tal cual.

**Pregunta cerrada.** ¿Se acepta una inicial como palabra válida (`^[[:alpha:]]\.$`)
o se deja la regla como está y la pauta lo advierte?

### E-g — Nadie valida el cuerpo de la pieza

Revisor 2 lo midió renderizando con Quarto 1.9.38: un `<script>` y un `<iframe>` en
el cuerpo **llegan intactos al HTML publicado**, y `{{< include ../afuera.md >}}`
inyecta un archivo de fuera del directorio del sitio. Es HTML arbitrario en un sitio
institucional público, escrito por una persona de confianza pero sin ninguna guarda.

**Pregunta cerrada.** ¿Se sanea el cuerpo (lista blanca de HTML, prohibición de
shortcodes), o se declara que el cuerpo es responsabilidad de quien firma?

### E-h — La compuerta de anclas confía en un JSON que puede estar rancio

`34_generar_paginas.R` no tiene guarda de frescura y `run_all(only = 34)` es legal.
Con `40_salidas/datos/normas/` desactualizado, `anclas_disponibles()` devuelve
`character(0)` sin quejarse y la compuerta **culpa a la pieza** de un ancla correcta.

**Pregunta cerrada.** ¿El paso 34 comprueba que el manifiesto que produjo esos JSON
coincide con el corpus actual antes de juzgar anclas?

### Heredadas y no tocadas

D-f, D-g, D-i del log v5, la Duda 3 de v4 (vocabulario de `relaciones.json`), el slug
del DFL 1 y el módulo de reglamentos siguen en el traspaso v02 y en gates humanos.
D-j (versiones sin fijar) queda **cerrada** por T2, a falta de la confirmación en el
runner.

## 9. Estado de cifras y datos críticos

Todas recontadas programáticamente en el turno.

| Cifra | Valor | Comando |
|---|---:|---|
| Casos de conducta medidos | **53** | arnés propio sobre el árbol de parseo |
| Casos que cambian de veredicto | **26**; 27 se mantienen | arnés sobre los dos árboles |
| Veredictos después | 42 ABORTA / 9 PUBLICA / 2 OMITE | ídem |
| Reventones aguas abajo, antes → después | 5 → **0** | ídem |
| Piezas / publicables en el repo real | 22 / **0** | log del paso 34 |
| Anclas del corpus / rotas | 92 / **2** | recuento propio contra los `id` de los 25 JSON |
| Entradas de `fuentes` con `norma`+`articulo` coherentes con el ancla | **92 / 92** | medido antes de exigirlo (D3) |
| Archivos versionados de `40_salidas/` | **28** | `git ls-files` |
| Idénticos byte a byte tras las regeneraciones | **28 de 28** | `shasum -a 256 -c` |
| T3a: clon desde cero, idénticos | **27 de 28** | `shasum -c` contra la línea base |
| T3a: líneas distintas del manifiesto / de ellas, del campo `estado` | 50 / **50** | `diff` sobre `jq -S` |
| T3b: páginas del sitio con la pieza publicada | 49 (47 + 2) | `ls` del clon |
| T3b: páginas con `data-pagefind-body` | **25 de 49** | `grep -l` |
| T3b: URLs de pieza en el índice de Pagefind | **0** | fragmentos descomprimidos con `gzfile()` en R |
| T3b: páginas restauradas al revertir a borrador | **48 de 49** | `shasum -c` |
| Defectos del panel corregidos antes del commit | **11** (+1 de forma) | §5.1 |
| Pasos del workflow | 13 | `yaml::yaml.load_file` |

## 10. Notas para el revisor

**Lo que falló o sorprendió.** Cuatro cosas, y dos son sobre el instrumento, no sobre
el código.

1. **El arnés reportó 53 ABORTA que eran su propio fallo.** Al añadir las funciones
   nuevas, la lista de nombres que el arnés extrae del archivo se quedó corta, y
   `cargar_piezas()` murió con «no se pudo encontrar la función». El arnés lo
   presentó como veredicto del código medido, con 53 filas de aspecto impecable. Es
   la falla más peligrosa posible en una cadena que mide: un instrumento que confunde
   su propio fallo con el resultado. Ahora se detiene con una prueba de humo antes de
   reportar tabla, y la lista de nombres vive en un solo sitio. Volvió a pasar dos
   veces más (en `cond7.R` y en el verificador de hallazgos) hasta que se centralizó.

2. **El shell se comió los backslashes dos veces**, en `Rscript -e` con expresiones
   regulares dentro de comillas simples. La primera vez dejó una meta-prueba que
   informaba `exit=0` **sin haber roto nada**: parecía verde y no medía. Desde
   entonces, todo script con regex va a disco por heredoc con delimitador entre
   comillas.

3. **El panel encontró once defectos en reglas escritas hacía diez minutos**, y el
   peor era exactamente el que la regla venía a cerrar: la compuerta de anclas
   validaba una cadena distinta de la que publica, así que `norma#art-1` sin
   extensión pasaba y se publicaba como enlace muerto. La regla existía para impedir
   enlaces muertos.

4. **El ensayo encontró lo único que ningún arnés podía encontrar.** Que la pieza
   publicada no entre al buscador no se ve en la compuerta, ni en el `.qmd`, ni en el
   HTML: solo aparece al indexar. Es el argumento entero a favor de hacer ensayos
   generales antes de convocar al equipo, y no después.

**Lo que este encargo deja listo.** Las tres dudas residuales tienen respuesta con
evidencia (§6), el camino de la vía A está ejercitado de punta a punta con su informe
en lenguaje llano, y la pauta dice la verdad sobre lo que el pipeline exige. Lo que
falta antes de entregar: decidir E-c (si las piezas se buscan) y E-d (las dos anclas
rancias), que son lo único que el equipo va a tropezar el primer día.

---

# Adenda — verificación en el runner (segundo push, solo documentación)

## A. Run

`git push origin main` → `7bbb452..66a99d5`.

| | |
|---|---|
| Run | **33092847417** |
| Estado | **completed / success**, 2 m 11 s, push a `main` el 2026-08-27T16:22:07Z |
| Jobs | `construir` (98589996796) ✓ 1 m 52 s · `desplegar` (98590564322) ✓ 11 s |
| Pasos fallidos | **0** en ambos |
| Versiones que instaló el runner | **R 4.5.2** (`/opt/R/4.5.2`) y **Quarto 1.9.38** — las fijadas, sin caer a una cercana |

## B. La autoprueba de la compuerta, en verde y visible

Paso «Autoprueba de la compuerta de coincidencia parcial»: **`success`**. Log literal
del runner:

```
Prefijos de aviso derivados en este entorno:
  <encuentros parciales de >
  <argumentos parcialmente correctos de >

[1/2] Control positivo OK: la compuerta disparo y nombro el acceso.
      coincidencia parcial de nombres.
        Aviso de R: encuentros parciales de 'anio' to 'anios_alternativos'
        Llamada:    curado$anio
        La clave exacta no estaba y R devolvió otra que la tiene por comienzo.
        Cambia ese acceso a [[ ]], que no adivina.
el paso ajeno termino bien
[2/2] Control negativo OK: las advertencias ajenas no tumban la corrida.

Autoprueba de la compuerta de coincidencia parcial: SUPERADA.
```

**La tercera duda residual queda cerrada.** El control positivo ya no vive solo en
macOS: corre en cada despliegue, en Linux, y se ve disparar.

Detalle que confirma la decisión D7 del encargo v5: en este runner, con R **4.5.2**,
el aviso salió en **español** (`encuentros parciales de`). En el runner anterior, con
R 4.6.1, el catálogo de traducciones estaba incompleto y R mezclaba los dos idiomas.
El prefijo derivado en tiempo de ejecución acertó en los dos; un patrón escrito a
mano habría tenido que acertar el idioma **y** la versión de R.

## C. Las páginas desplegadas vs el HTML local: de 15 líneas a 2, no a 0

**Resultado: la comprobación NO pasa del todo, y se reporta sin arreglar nada**, como
manda la instrucción.

| Página | HTTP | Bytes local / desplegado | `generator` | Diff antes → ahora |
|---|:-:|---|---|---|
| `index.html` | **200** | 25 315 / 25 315 | `quarto-1.9.38` en ambos | 15 → **2** |
| `ley_20536_violencia_escolar.html` | **200** | 36 452 / 36 452 | `quarto-1.9.38` en ambos | 15 → **2** |

Fijar las versiones cerró **13 de las 15 líneas**: desaparecen la diferencia de
`<meta name="generator">`, las reglas `@media screen` que cambiaron entre 1.9 y 1.10,
y el hash del CSS de resaltado de sintaxis. Las 2 que quedan son **una sola línea**,
la misma en las dos páginas:

```
< <link href="site_libs/bootstrap/bootstrap-8c38fd85d21bfe44b50360969156fb14.min.css" ...>   (local)
> <link href="site_libs/bootstrap/bootstrap-b1376423af881990cfd602ae2f353e6b.min.css" ...>   (desplegado)
```

**Y no es solo el nombre: el contenido del CSS difiere de verdad.** Medido
descargando el bundle desplegado y comparándolo con el local:

| | Local | Desplegado |
|---|---|---|
| Tamaño | 498 675 bytes | **498 675 bytes** |
| sha256 | `e75e401cd6c091a4…` | `75bbe0d81f9f1b25…` |
| Líneas distintas (plegado a 120 col) | — | **684** |

Mismo tamaño exacto y contenido distinto. Es el bundle de Bootstrap/bslib que Quarto
compila desde SASS para el tema `cosmo`, y con la **misma** versión de Quarto sale
distinto en Linux y en macOS. El nombre del archivo es un hash de su contenido, así
que la única línea que difiere en el HTML es consecuencia de eso, no una causa
aparte.

**Conclusión honesta sobre la segunda duda residual.** Fijar las versiones hizo lo
que se le pidió: el HTML **generado por el pipeline** es ya idéntico entre las dos
cadenas. Lo que no es reproducible entre plataformas es el **tema compilado**, que no
lo produce este proyecto. La reproducibilidad del sitio quedó acotada, y ahora con
número: **1 línea de 25 315 bytes**, y esa línea es un nombre de archivo derivado.

*Hipótesis no verificada, con su comando:* existe una caché local de Quarto en
`40_salidas/sitio_src/.quarto` que podría estar sirviendo un tema compilado antiguo.
Se comprueba con `rm -rf 40_salidas/sitio_src/.quarto && Rscript 00_run_all.R` y
volviendo a comparar el hash del bundle. No se hizo: la instrucción era reportar sin
tocar nada. Queda como duda **E-i**.

## D. Estado al cierre de la adenda

`origin/main` = `66a99d5` más el commit de esta adenda. Sitio en 200. `ESTADO.md`
sigue intacto (`sesion_abierta: true`, `commit_cierre: 358e150`). La sesión sigue
abierta.
