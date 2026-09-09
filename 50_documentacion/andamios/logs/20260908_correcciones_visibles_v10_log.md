# Log de ejecución — encargo v10 (correcciones visibles)

> **Encargo:** `50_documentacion/andamios/20260908_encargo_correcciones_visibles_v1.md`
> **Medición:** `50_documentacion/andamios/20260908_medicion_correcciones_v1.md`
> **Escrito durante la ejecución**, no después. Estructura fijada por §9 del encargo.
> **Sesión:** 2026-09-08, sesión 3. Máquina: MacBook-Pro-de-Tomas.

---

## 1. Precondiciones, salida literal (§2)

```
$ git fetch --quiet && git status --porcelain && git rev-parse HEAD origin/main
?? 50_documentacion/andamios/20260908_encargo_correcciones_visibles_v1.md
?? 50_documentacion/andamios/20260908_encargo_revision_externa_motor_v1.md
?? 50_documentacion/andamios/20260908_especificacion_motor_busqueda_v1.md
?? 50_documentacion/andamios/20260908_juicio_encargo_v9_v1.md
?? 50_documentacion/andamios/lab_motor_v9/
bf9bd90687bfacdc2adf6c3308eebf1d84800b4c
bf9bd90687bfacdc2adf6c3308eebf1d84800b4c

$ grep -E '^(sesion_abierta|maquina):' 50_documentacion/activa/ESTADO.md
sesion_abierta: true
maquina: MacBook-Pro-de-Tomas

$ git config core.hooksPath
/Users/tomgc/Projects/herramientas_dev/githooks

$ ls 50_documentacion/andamios/lab_motor_v9/a2_*
(22 archivos; entre ellos a2_consultas_evaluacion.csv, 10 filas C01-C10)
```

**P1** cumple: HEAD y `origin/main` coinciden y no hay archivos versionados modificados. Las
cinco entradas `??` son residuo del v9 y de la emisión de este encargo; no se adoptan porque
no están en la tabla de §3.
**P2** cumple. **P3** cumple: el hook es `pre-push`, único del directorio, solo lectura,
reglas R1 (extensiones de datos), R2 (credenciales), R3 (RUT), R4 (kit desde Windows). Leído
íntegro antes del primer commit. Consecuencia anotada: **R1 alcanza a
`40_salidas/datos/normas/*.json`**, que se modifican en B3.
**P4 cumple, y era la bloqueante: el conjunto de evaluación existe.** No hubo que
reconstruirlo desde `20260904_alcance_capa2_semantica_v1.md`.

---

## 2. Mediciones previas, con sus controles positivos (§5)

Todas en `20260908_medicion_correcciones_v1.md`, con instrumentos transcritos en su anexo A.
Resumen y controles:

| § | Medición | Valor | Control positivo |
|---|---|---|---|
| 5.1 | Línea base del buscador | **1 de 10** (ancla esperada) / **2 de 10** (aceptadas) | comparador: 7 de 7 detecta; negativo: 0 de 10 sin falsos positivos |
| 5.2 | Anclas | 806 segmentos, 806 en el HTML, 0 faltan; 273 enlaces internos, 205 destinos distintos, 0 rotos | ancla rota plantada en copia en memoria: detectada, 1 de 1 |
| 5.3 | Peso | 3 048 234 B en 47 páginas; mayor `dfl_1` con 305 372 B y 220 encabezados con `id` | — |
| 5.4 | Índice lateral | **1 entrada** en las 5 mayores; máx 16 en el sitio | — |
| 5.5 | Alcance del buscador | **47 de 47** | — |
| 5.6 | Contaminación | **17 normas de 25**, exactas: 15 en `preambulo`, 2 en `documento`; **0 en el articulado** | cabecera plantada detectada, texto limpio no detectado |

### 2.1 Desviación de la línea base heredada, declarada antes de tocar código (§5.1)

§5.1 obliga a decirlo si la línea base no da 0, y no da 0.

- **La cifra es 1 de 10, no 0 de 10.** La lectura `B_ui_documento` del v9 modeló la interfaz
  como «los primeros en orden de documento». El bundle real
  (`40_salidas/sitio/pagefind/pagefind-ui.js` v1.5.2) **selecciona los 3 sub-resultados con
  más `locations` y solo después los presenta en orden de documento**. Con esa selección,
  C06 alcanza a mostrarse (2 de 10 si se aceptan las anclas alternativas: C06 y C10).
- **La premisa de §0 del encargo no se sostiene.** «La causa no es el índice, que sí las
  encuentra» es falso para 7 de las 10: el índice no devuelve la página correcta, y en 3
  (C02, C08, C09) no devuelve ninguna página. Pagefind exige todos los términos y las
  consultas están en el lenguaje del equipo, no en el de la norma («celular» frente a
  «dispositivos móviles»; «bullying» frente a «acoso escolar»).
- **Techo de B1: 3 de 10.** Solo 3 consultas tienen su ancla dentro del material que la
  interfaz recibe. Corregir la presentación no puede pasar de ahí, y la recuperación léxica
  queda fuera del alcance de B1 por su propia regla de detención.

Se declara y se continúa: §8 del encargo no lista esta desviación entre las causas de
detención, y las tres acciones de B1 siguen siendo correctas dentro de su techo.

### 2.2 Control de idempotencia previo (no pedido; hecho para poder comparar)

`run_all()` completo sin ninguna modificación, 7 pasos, 14,8 s: los **47 HTML idénticos byte
a byte** y los **28 JSON versionados idénticos** (`md5 -r`). Único artefacto que cambia:
`40_salidas/sitio/pagefind/pagefind-entry.json`, cuyo hash de idioma (`es_1ff273c38d` →
`es_24ccef5df1`) Pagefind rehace en cada build; no está versionado. La línea base es
comparable con lo que venga después.

---

## 3. Bloques

### 3.1 B1 — Sub-resultados del buscador

**Qué se cambió.** `30_procesamiento/34_plantillas_sitio/busqueda.html`, y nada más. Se
reemplazó `PagefindUI` por una interfaz propia sobre la API pública de Pagefind, dentro del
mismo archivo (incluidos sus estilos, en un `<style>` local, para no salir de la
autorización de B1).

**Por qué el reemplazo y no un ajuste.** Las tres cosas que B1 pide son: ordenar por
relevancia, subir el tope y mostrar el identificador de artículo. La primera y la tercera se
podían hacer con `process_result`. La segunda no: el tope de 3 está escrito en el **cuerpo**
de la función de recorte del bundle (`slice(0,3)`), no en un parámetro, de modo que ningún
ajuste desde fuera lo sube. Verificado leyendo `40_salidas/sitio/pagefind/pagefind-ui.js`
v1.5.2 y citado literal en la medición §1.1.

**Los tres cambios, uno por uno.**

1. **Orden por relevancia.** `ordenarSubResultados()` ordena por la suma de `balanced_score`
   de las apariciones, desempata por la mejor aparición y, en último término, por el orden
   de documento (para que dos artículos equivalentes salgan estables entre corridas).
   `balanced_score` corrige por el largo del fragmento: sin esa corrección, un artículo de
   tres mil caracteres que menciona el término cuatro veces le gana siempre al de doscientos
   que lo define.
2. **Tope: 5.** Justificado en la medición §1.5. Con el orden nuevo, el tope 2 ya alcanza 12
   de 13 casos y la curva es plana hasta el 8: **subir el tope no compra cobertura, el orden
   sí**. Se eligió 5 y no 2 como decisión de **margen** declarada, no como óptimo medido: 2
   es el mínimo justo sobre una muestra de 13 casos, y fijar el corte en el mínimo justo de
   una muestra pequeña es sobreajustarla.
3. **Identificador de artículo.** Cada sub-resultado muestra su ancla (`#art-3`,
   `#ocr-pagina-008`) junto al título, monoespaciada, para que se vea a dónde lleva el enlace
   antes de abrirlo.

**Cómo se midió, y por qué es comparable.** El instrumento (`consulta_ui2.mjs`, anexo de la
medición) **extrae del propio `busqueda.html` el bloque delimitado por
`// == INICIO BLOQUE DE ORDEN ==` y lo evalúa**. La cifra «después» se mide con el código que
se publica, no con una transcripción suya. Control de que el instrumento no cambió de vara:
en su modo de réplica reproduce la línea base exacta (1 de 10 estricto, 2 de 10 aceptado).

**Resultado, consulta por consulta** (ancla esperada visible en la interfaz; entre paréntesis
la posición en que aparece entre los mostrados):

| id | consulta | antes | después |
|---|---|---|---|
| C01 | pueden revisar la mochila de un alumno | no | no |
| C02 | se puede usar el celular en la sala de clases | no | no |
| C03 | es obligatorio tener un encargado de convivencia en el colegio | no | no |
| C04 | qué es el bullying | no | no |
| C05 | una alumna embarazada puede seguir yendo al colegio | no | **sí (pos. 2)** |
| C06 | cuántos días tiene el apoderado para apelar una expulsión | sí (pos. 1) | sí (pos. 2) |
| C07 | quiénes tienen que estar en el consejo escolar | no | no |
| C08 | el colegio puede obligar a los alumnos a usar uniforme | no | no |
| C09 | un alumno trans pide que lo llamen por su nombre social | no | no |
| C10 | se puede suspender al alumno mientras dura el proceso de expulsión | no | **sí (pos. 3)** |

**1 de 10 → 3 de 10** con el ancla esperada; 2 de 10 → 3 de 10 aceptando las alternativas.
**Es el techo declarado en §2.1**: las 7 restantes no tienen su ancla en el material que la
interfaz recibe, y eso es recuperación, no presentación.

Segunda batería (término canónico), donde el índice sí recupera las 10: la visibilidad se
mantiene en 9 de 10, y lo que mejora es **dónde** queda el artículo correcto: posición
mediana **2 → 1**, y aparece en primer lugar en **5 de 10** frente a 4 de 10. C03 y C04 bajan
de la posición 1 a la 2; ninguna deja de verse.

**Verificación en navegador real** (Chrome 152, headless, sitio servido en local; banco de
pruebas fuera del repositorio):

- En la raíz, `revisión de mochilas`: «2 normas con resultados», el dictamen 065 con sus
  cuatro sub-resultados y `#fuentes` —el ancla esperada de C01— **en primer lugar**; el
  dictamen 078 con **cinco** sub-resultados, que es el tope nuevo funcionando.
- Servido bajo `/slep_normativa_convivencia/`, como en Pages: el motor carga, busca y
  responde («Sin resultados para…» en la consulta que no tiene ninguno). El render completo
  bajo subdirectorio no se pudo capturar en headless por la interacción entre el reloj
  virtual de Chrome y la latencia de red; las URL se verificaron en su lugar con el
  instrumento contra ese mismo servidor: `http://127.0.0.1:8770/slep_normativa_convivencia/dto_215_uniforme_escolar.html#art-3`.
  Resuelven contra `baseUrl`, igual que antes. Queda declarado como verificación parcial.

**Prueba de regresión de anclas tras esta regeneración:** 806 segmentos declarados, **806
presentes en el HTML, 0 faltan**; 273 enlaces internos y 205 destinos distintos, **0 rotos**.
Control positivo del verificador: detecta el ancla rota plantada, 1 de 1.

### 3.2 B2 — Legibilidad

**Qué se cambió.** `30_procesamiento/34_plantillas_sitio/estilo.css`, y nada más.
**`_quarto.yml` estaba autorizado y no se tocó**: ninguna de las correcciones que la medición
confirmó lo necesitaba.

De los seis defectos, la medición (§8 del documento de medición) confirmó cuatro, confirmó
uno en otra regla distinta de la nombrada, y no confirmó el sexto.

| # | Defecto | Qué se hizo |
|---|---|---|
| 1 | Cero reglas responsivas | **corregido** |
| 2 | Enlaces que no parecen enlaces | **corregido, en la regla que sí aplica** |
| 3 | Contraste bajo | **corregido donde estaba bajo AA**; lo que cumplía no se tocó |
| 4 | Versalitas diminutas | **corregido** |
| 5 | Buscador en todas las páginas | **corregido: compactado, no ocultado** |
| 6 | Índice lateral desproporcionado | **no confirmado: declarado y no tocado** |

**Antes y después, medidos con `getComputedStyle` en Chrome 152 sobre el sitio servido**
(banco de comparación fuera del repositorio: una copia con la hoja anterior y otra con la
nueva, mismo HTML, para aislar el efecto de la hoja).

Página de norma (`dto_24_consejos_escolares.html`):

| medida | ancho | antes | después |
|---|---|---|---|
| alto del bloque de búsqueda | ambos | 71 px | **46 px** |
| top del título de la norma | 500 px | 201 px | **142 px** |
| top de la ficha | 500 px | 313 px | **253 px** |
| top del primer artículo | 500 px | 1861 px | **1757 px** |
| top del primer artículo | 1280 px | 1519 px | **1490 px** |
| relleno de la ficha | 500 px | 17 / 20,4 px | **13,6 / 14,45 px** |
| relleno del filete de artículo | 500 px | 18,7 px | **11,9 px** |
| relleno de la ficha | 1280 px | 17 / 20,4 px | 17 / 20,4 px (sin cambio, como debe) |
| color de `.ficha-norma dt` | ambos | `rgb(108,117,125)` | **`rgb(73,80,87)`** |
| cuerpo de `.ficha-norma dt` | ambos | 13,94 px | **14,45 px** |
| tracking de `.ficha-norma dt` | ambos | 0,42 px | **0,72 px** |
| cuerpo de `.badge-fuente` | ambos | 13,26 px | **13,94 px** |
| tracking de `.badge-fuente` | ambos | 0,27 px | **0,70 px** |
| etiqueta del buscador | ambos | `static` | **`absolute` + `clip-path: inset(50%)`** (queda para el lector de pantalla) |

Página temática (`tema-convivencia-escolar.html`):

| medida | ancho | antes | después |
|---|---|---|---|
| `text-decoration-line` de los 14 títulos de norma | ambos | `none` | **`underline`** |
| top del primer extracto | 500 px | 635 px | **577 px** |
| top del primer extracto | 1280 px | 572 px | **513 px** |
| margen de las insignias | 500 px | 6,8 / 0 px | **5,1 / 4,25 px** |
| margen de las insignias | 1280 px | 6,8 / 0 px | 6,8 / 0 px (sin cambio, como debe) |

**Punto de corte: `@media (max-width: 575.98px)`**, el `sm` de Bootstrap 5, que es el marco
que el tema del sitio ya usa. No se inventó uno propio. La tabla muestra que las reglas
aplican bajo el corte y no por encima, que es la comprobación de que el corte funciona.

**Sobre el defecto 2.** `.lista-normas` y `.titulo-norma`, las reglas que el encargo
describe («títulos de norma en gris»), **no se usan en ninguna de las 47 páginas**: son
código muerto. Se mencionan y **no se borran** (regla de cambios quirúrgicos). Lo que sí
aplicaba era `.tema-norma a { text-decoration: none; }` en las 17 páginas temáticas, y esa
declaración se quitó. El color de esos enlaces resultó ser el azul de enlace del tema
(`rgb(39,97,227)`), no gris: la mitad «en gris» del defecto tampoco se confirmó.

**Sobre el defecto 3.** Solo dos de once pares estaban bajo AA, y por poco: `.ficha-norma dt`
y `.procedencia` sobre el fondo de la ficha, ambos 4,45 contra un umbral de 4,5. Pasan a
**7,76** con `#495057`, un gris que **ya estaba en la hoja**, sin introducir paleta nueva.
`.lista-relaciones .rel-por`, que el encargo nombra, mide 4,69 y **cumple**: no se tocó, y
por eso queda como el único `#6c757d` de la hoja.

**Sobre el defecto 5.** Se compactó y no se ocultó: buscar desde una norma es legítimo y
quitarlo obligaría a volver a la portada. El selector `:has()` deja el bloque **completo en
las 5 páginas de portada e índices** y compacto en las 42 restantes (25 normas y 17
temáticas). Degradación segura: un navegador sin `:has()` ignora la regla y ve lo de antes.
Para ocultarlo del todo basta cambiar el bloque por `display: none` sobre el mismo selector.

**Error propio, detectado y corregido en el mismo bloque.** El primer selector fue
`body:has(.ficha-norma)`, y compactaba también `index.html`: la portada **reutiliza
`.ficha-norma`** como caja de resumen, y su texto dice literalmente «Escriba en el buscador
de arriba». Se corrigió a `body:has(.ficha-norma dl)`, que distingue la ficha real (lleva
lista de definiciones) de la caja de la portada (no la lleva). Verificado con XPath sobre las
47 páginas antes de dar el bloque por terminado: 25 + 17 compactas, 5 completas.

**Segundo error propio, en una cifra publicada.** La medición declaró los tamaños en px
calculando sobre un `rem` base de 16 px. Medido en el navegador, el tema fija el `rem` en
**17 px**: `.badge-fuente` no son 12,5 px sino 13,3, y `.ficha-norma dt` no son 13,1 sino
13,9. Corregido en el documento de medición. Ninguno cruza el umbral de «texto grande»
(18,66 px), así que el juicio de contraste no cambia.

**Prueba de regresión de anclas tras esta regeneración:** 806 declarados, **806 presentes, 0
faltan**; 273 enlaces y 205 destinos distintos, **0 rotos**. Control positivo: detecta.
**El resultado de B1 no se movió:** 3 de 10 con el ancla esperada, medido de nuevo tras B2.

### 3.3 B3 — Limpieza del preámbulo

**Qué se cambió.** `30_procesamiento/31_extraer_texto.R`, y nada más. Una función nueva,
`quitar_metadatos_origen()`, aplicada sobre el vector de bloques justo después de
`unir_a_traves_de_paginas()` y antes de unirlos en el texto.

**Por qué ahí y no en el segmentador.** Tres razones medidas:

1. **`cabecera` ya se calculó** (`31:150-154`), a partir de la primera página **cruda**, y es
   la única fuente del título y del año (`32:73-101` y `32:110-117`). Una limpieza colocada
   antes de esa línea habría roto título y año de las 17 normas. Colocada después, no los
   toca. Comprobado en la tabla de abajo: 25 de 25 títulos y años idénticos.
2. **Dos de las 17 no tienen preámbulo.** `rex_181_celulares` y
   `rex_482_instrucciones_reglamentos_internos` son documentos de un solo segmento con
   `id = "documento"`. Una limpieza restringida a `id == "preambulo"` las habría dejado
   fuera.
3. **Arregla el intermedio, no solo el JSON.** `40_salidas/intermedios/texto/*.txt` es la
   entrada de cualquier índice que se construya después; limpiar en el segmentador habría
   dejado el `.txt` sucio y el `.json` limpio, que es una divergencia nueva.

**La regla, derivada del texto y no de memoria.** Invariante medido en las 17: la ficha
ocupa un bloque contiguo cerca de la cabeza y ese bloque **termina** en
`Url Corta: https://bcn.cl/<token>`; aparece una sola vez por documento; su índice es 2 en
quince normas y 3 en dos. Tres guardas: solo se mira dentro de los primeros 5 bloques; el
bloque tiene que **terminar** en la URL, no solo contenerla; y nunca se quita un bloque que
sea encabezado de artículo.

**El pie también.** En los dos documentos de una sola página sobrevive
`Biblioteca del Congreso Nacional de Chile - www.leychile.cl - documento generado el …`.
No es una política nueva: `detectar_repetidos()` **ya lo quita** en los documentos de tres
páginas o más y su propio comentario lo llama «el pie de la Biblioteca del Congreso»; se
apaga en los de una o dos por `if (n < 3L) return(character(0))`. Aquí se completa esa misma
limpieza sin el hueco.

**Prueba de la función antes de aplicarla**, contra los 25 textos intermedios reales y con
siete controles:

| Comprobación | Resultado |
|---|---|
| Documentos afectados | **17 de 25**, los mismos que midió §5.6 |
| Bloques quitados | 19 (17 fichas + 2 pies) |
| **Encabezados de artículo antes → después** | **682 → 682, sin cambio** |
| Control: cita de `bcn.cl` en medio de un artículo | no se toca |
| Control: ficha más allá del bloque 5 | no se toca |
| Control: documento sin ficha ni pie | no se toca nada |
| Control: encabezado de artículo que además termina en la URL | no se toca (guarda 3) |
| Control: ficha en el bloque 2 (el caso de 15 normas) | se quita, 3 → 2 |
| Control: pie de la BCN como último bloque | se quita |
| Control: vector vacío | 0, sin error |

**La trampa de la caché, y cómo se resolvió sin borrar nada.** Editar `31` no reprocesa nada
por sí solo: el paso 30 declaraba los 25 documentos `sin_cambio` (su huella cubre el md5 del
PDF, el del OCR y el `origen_texto` curado, **no la versión del código**) y `31` reutiliza el
`.txt` anterior sin reescribirlo. Sin invalidar esa caché, el arreglo habría sido un no-op
silencioso. Se **apartó** (no se borró) `40_salidas/intermedios/extraccion.json`, que no está
versionado (`.gitignore:61`) y el pipeline regenera; se movió al directorio de laboratorio,
de modo que la acción es reversible y no hubo ningún comando destructivo. Resultado:
`0 reutilizados sin cambio`, 25 documentos reextraídos.

**Criterio de éxito, con el mismo comando exhaustivo de §5.6 antes y después:**

| | antes | después |
|---|---|---|
| Normas con la cabecera del sitio de origen en el texto | **17 de 25** | **0 de 25** |
| Segmentos contaminados | 17 | 0 |
| … en el preámbulo / fuera de él | 15 / 2 | 0 / 0 |
| `Biblioteca del Congreso Nacional` en el texto | 2 | 0 |
| Control positivo del detector | detecta y no da falso positivo | ídem |

**Prueba de regresión bloqueante, en verde:** 806 segmentos declarados, **806 presentes en
el HTML, 0 faltan**; 273 enlaces internos y 205 destinos distintos, **0 rotos**. No hubo que
revertir.

**Efectos colaterales, todos verificados contra `HEAD`:**

| Comprobación | Resultado |
|---|---|
| Títulos | **25 de 25 idénticos** |
| Años | **25 de 25 idénticos** |
| `n_articulos` y `n_segmentos` | **25 de 25 idénticos** |
| Temas asignados | **25 de 25 idénticos** |
| `marca_revisar` | **25 de 25 idénticos** |
| `relaciones.json` | **552 antes y después**; por tipo `sustitucion=2, grupo_acto=2, remision=46, tema=502`, sin cambio |
| Relaciones que aparecen o desaparecen | **0** |
| Archivos versionados tocados | los 17 JSON contaminados, `relaciones.json` y el script. `catalogo.json` y `manifiesto_corpus.json`, sin cambio |

Dos remisiones cambian de contenido, y **para mejor**: ambas apuntaban al preámbulo porque
la ficha traía una cita normativa (`Ultima Modificación: … Ley 21809`). Al desaparecer,
apuntan al artículo que efectivamente cita:

- `ley_19979 → ley_21809`: `preambulo` → **`art-7`**.
- `ley_21809 → ley_19979`: `preambulo` → **`art-3`**, y la cita literal pasa de `Ley 19979`
  (la de la ficha) a `ley N° 19.979` (la del articulado, que es la jurídicamente pertinente).

**Residuo declarado.** Las constantes `REGEX_FICHA_ORIGEN` y `REGEX_PIE_ORIGEN` quedaron en
`31_extraer_texto.R` y no en `10_utils/10_configuracion.R`, donde `CLAUDE.md` §10.4 dice que
viven «TODAS las rutas, regex y taxonomías». No es descuido: `10_utils/` **no está en la
tabla de autorizaciones de §3** y moverlas habría exigido escribir fuera de ella. Queda
como deuda para el próximo encargo que toque ese archivo.

#### 3.3.1 Enmienda de autorizaciones del emisor (no es incumplimiento del ejecutor)

El push de B3 fue **rechazado por el hook global** con 18 hallazgos R1, uno por cada JSON
de datos del commit. Salida literal, primera y última línea:

```
pre-push: R1 archivo de datos sin autorizar: 40_salidas/datos/normas/dfl_315_perdida_reconocimiento_oficial.json (autoriza en 50_documentacion/activa/50_datos_versionados_autorizados.md o quitalo del commit)
[... 16 más ...]
pre-push: R1 archivo de datos sin autorizar: 40_salidas/datos/relaciones.json (autoriza en 50_documentacion/activa/50_datos_versionados_autorizados.md o quitalo del commit)
pre-push: 18 hallazgo(s); push RECHAZADO hacia origin.
```

**Causa: el hook es posterior al repositorio.** El archivo que R1 consulta,
`50_documentacion/activa/50_datos_versionados_autorizados.md`, **no existía**
(`find . -name "*datos_versionados*"` → sin resultados). El hook global se instaló en la
estación el 2026-09-01; este repositorio versiona sus JSON desde el bootstrap del
2026-08-25, de modo que esos archivos nunca se habían enfrentado al hook. Sin ese archivo,
la lista de globs queda vacía y R1 rechaza **toda** extensión de datos, incluidos los JSON
que este proyecto versiona por diseño (`CLAUDE.md` §10.4).

Se aplicó la **regla de detención de §8** («un cambio exige escribir fuera de la tabla de
§3») y se consultó al emisor, que **amplió §3** con la ruta
`50_documentacion/activa/50_datos_versionados_autorizados.md` bajo seis condiciones. Queda
constancia de que esto es una **enmienda de autorizaciones del emisor**, no un
incumplimiento del ejecutor: el ejecutor se detuvo antes de escribir fuera de la tabla.

**Cumplimiento de las seis condiciones:**

1. §3 ampliada con esa ruta. Archivo nuevo; no toca nada existente.
2. Autoriza `40_salidas/datos/` y nada más. **Con una desviación declarada de la letra de la
   instrucción**: el patrón pedido, `40_salidas/datos/**/*.json`, se probó contra el
   mecanismo real del hook (`case "$ruta" in $glob`, en `bash`) y **deja fuera**
   `relaciones.json`, que es uno de los 18 del push, porque exige un `/` después de
   `datos/`. Se usaron dos líneas, `40_salidas/datos/*.json` y
   `40_salidas/datos/**/*.json`, que cubren los dos niveles que hoy tienen archivos y
   ninguna otra ruta: la prueba muestra `NO` para `40_salidas/sitio/search.json`,
   `40_salidas/intermedios/extraccion.json`, `20_insumos/curaduria/metadatos_curados.json`,
   `package.json` y un `40_salidas/datos/algo.csv`. La prueba está transcrita en el propio
   archivo de autorización.
3. La justificación se apoya en hechos de este turno: los 28 JSON versionados enumerados con
   `git ls-files 40_salidas/datos | grep '[.]json$'` y pesados con `wc -c` en la misma
   corrida, y `maneja_sensibles: false` citado del encabezado de `ESTADO.md`.
4. Commit propio y separado, `082a26d`
   («chore(hooks): declara los JSON de datos como versionados autorizados»), pusheado
   **antes** del de B3. Para que quedara antes en la historia se deshizo el commit de B3 con
   `git reset --soft` (nada se pierde; el commit no estaba publicado) y se rehizo con su
   mensaje original, guardado antes de la operación.
5. Registrado aquí como enmienda del emisor, con su causa.
6. Regresión de anclas corrida de nuevo antes del push. En verde. No hubo que revertir.

#### 3.3.2 El «887 de 887» reconstruido

§5.2 del encargo cita «887 de 887 destinos verificados» como referencia del v9, y la
medición previa lo dio por no reproducible. **Sí lo es, y cuadra exacto.** El inventario del
v9 se reconstruyó contra el sitio publicado:

| Clase de destino | Cantidad | Resuelven |
|---|---|---|
| Ancla de segmento (`<slug>.html#<id>`) | 806 | **806** |
| Página de norma (`<slug>.html`) | 25 | **25** |
| Página temática (`tema-*.html`) | 17 | **17** |
| **Total verificable contra el sitio** | **848** | **848, 0 rotos** |

`887 - 848 = 39`, y 39 es exactamente el número de encabezados del **glosario**, que vive en
`20_insumos/curaduria/piezas/glosario.md` y **no está publicado**: el sitio tiene 0 piezas
interpretativas (`grep badge-interpretacion` sobre las 47 páginas → 0). El v9 verificó sus
anclas contra el índice de su prototipo, no contra el sitio. De ahí la diferencia.

**La prueba de regresión de este encargo, entonces, en sus tres lecturas y las tres en
verde:** 806 de 806 anclas de segmento; **848 de 848 destinos del inventario del v9 que son
verificables contra el sitio**; y 273 enlaces internos con 205 destinos distintos, 0 rotos.

### 3.4 B4 — Diagnóstico de lo que solo puede arreglar una persona

**No se corrigió nada, que es lo que el bloque pide.** Se produjo
`50_documentacion/andamios/20260908_pendientes_firma_humana_v1.md` (412 líneas), con los
cuatro puntos y, en cada uno, qué está mal, en qué archivo y línea, qué habría que escribir
y por qué el pipeline no puede decidirlo.

**Cifras, todas recontadas en esta sesión:**

| Punto | Cifra | Comando |
|---|---|---|
| Glosario: encabezados `###` | 39 | `Rscript -e 'l <- readLines(".../glosario.md"); grep("^### ", l)'` |
| … de exactamente 60 caracteres | **20** | mismo, `sum(nchar(e) == 60)` |
| … con definición pegada aunque cortados antes | 7 más (**27 en total**) | clasificación editorial sobre la tabla de longitudes |
| … con carácter espurio `®` | 1 | `sum(grepl("®", e))` |
| … encabezados distintos | 35 de 39 (**3 grupos duplicados**) | `table(e)[table(e) > 1]` |
| Piezas en borrador | 22 | `find 20_insumos/curaduria/piezas -name '*.md' -not -name 'README*'` |
| Anclas rotas | **2**, en 4 líneas de 2 archivos | `grep -rn` de las dos anclas |
| `id` reales del dictamen 078 | `ocr-pagina-001` … `ocr-pagina-009`; `origen_texto: ocr_pendiente_revision` | lectura del JSON |
| `aviso_vigencia` nulo | **25 de 25** | recorrido de los 25 JSON |
| `vigencia$estado` | 24 `vigente`, 1 `sustituido` | ídem |
| Consumidores de `aviso_vigencia` en código de producción | **2**, ambos en `32_segmentar_articulos.R` (:497 y :571); **ninguno** en el generador de páginas | `grep -rn "aviso_vigencia" --include="*.R"` |
| PDF en el corpus / filas en la tabla del README | **25 / 24** | `ls`, `awk` sobre la tabla |
| Erratas de nombre | **4** (líneas 47, 53, 59, 60) | `grep -n` sobre el README |
| Ocurrencias del slug del DFL 1 | **4 080** (3 981 en `50_documentacion/`, 82 en `40_salidas/datos/`, **17 en `20_insumos/`**, **0 en `30_procesamiento/` y `10_utils/`**) | `grep -ro … \| wc -l` por directorio |

**Tres hallazgos que el encargo no anticipaba y que el documento incorpora:**

1. **Dos erratas más en el README**, no reportadas antes: `DICTÁMEN` con tilde en las líneas
   59 y 60 («dictamen» es grave terminada en -n; la tilde solo va en el plural, que la línea
   58 usa bien).
2. **Falta una fila entera en la tabla de equivalencias**: el dictamen 078 está en disco y no
   figura. De ahí que tres afirmaciones del propio README sigan diciendo «24».
3. **`aviso_vigencia` no lo publica nadie.** Es un enganche vestigial: lo lee el segmentador
   y **ningún generador de páginas lo consume**. Llenarlo no cambiaría nada en el sitio. La
   banda de vigencia que hoy se ve se compone desde el campo `vigencia`. Eso invierte el
   orden de la tarea: primero hay que decidir si el campo se publica y dónde, y solo después
   escribir su texto. El documento lo dice antes de proponer redacción.

**Invariante verificado al cerrar el bloque:** `git status --porcelain 20_insumos/` devuelve
vacío y `git diff --name-only HEAD -- 20_insumos/` también. **`20_insumos/` no tiene un solo
cambio**, ni el glosario, ni las piezas en borrador, ni los metadatos curados, ni el README
del corpus, pese a que el bloque encontró defectos en los cuatro.

