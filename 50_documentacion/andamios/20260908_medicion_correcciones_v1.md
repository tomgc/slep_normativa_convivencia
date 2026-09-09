# Medición previa y auditoría — encargo v10 (correcciones visibles)

> **Encargo:** `50_documentacion/andamios/20260908_encargo_correcciones_visibles_v1.md`
> **Regla que gobierna este archivo:** §5 del encargo. Nada se corrige antes de medirse.
> **Escrito:** 2026-09-08, sesión 3.
> **Alcance:** las seis mediciones de §5 con sus controles positivos, y (§7) la auditoría.
>
> Toda cifra de este documento lleva el comando que la produjo, ejecutado en la sesión
> que lo escribe. Los instrumentos son ocho scripts de laboratorio; como `§3` del
> encargo no autoriza crear archivos de laboratorio en el repositorio, viven fuera de él
> y se transcriben íntegros en el **anexo A**, que es lo que los hace reproducibles.

---

## 0. Precondiciones (§2)

| # | Comando | Salida |
|---|---|---|
| P1 | `git fetch --quiet && git status --porcelain && git rev-parse HEAD origin/main` | sin archivos versionados modificados; `bf9bd90687bfacdc2adf6c3308eebf1d84800b4c` en HEAD y en `origin/main` (iguales) |
| P2 | `grep -E '^(sesion_abierta\|maquina):' 50_documentacion/activa/ESTADO.md` | `sesion_abierta: true` / `maquina: MacBook-Pro-de-Tomas` |
| P3 | `git config core.hooksPath` | `/Users/tomgc/Projects/herramientas_dev/githooks`; leído antes de todo commit (§0.1) |
| P4 | `ls 50_documentacion/andamios/lab_motor_v9/a2_*` | 22 archivos. **El conjunto de evaluación existe**: `a2_consultas_evaluacion.csv`, 10 filas C01–C10. No hubo que reconstruirlo |

**Estado del árbol al abrir.** `git status --porcelain` devuelve cinco entradas, todas `??`
(sin versionar): los cuatro documentos del 2026-09-08 y el directorio `lab_motor_v9/`.
Ninguna es una modificación de archivo versionado. Se dejan sin versionar: no están en la
tabla de autorizaciones de §3 y este encargo no las adopta.

### 0.1 Hook leído antes del primer commit (P3, lección O-3 del v9)

`/Users/tomgc/Projects/herramientas_dev/githooks/pre-push`, único hook del directorio,
solo lectura, cuatro reglas: **R1** extensiones de datos (`csv|json|xlsx|parquet|rds|…`) no
cubiertas por `50_documentacion/activa/50_datos_versionados_autorizados.md`; **R2**
credenciales por nombre de archivo; **R3** patrón de RUT en líneas agregadas; **R4** push
al kit desde Windows. Consecuencia operativa para este encargo: **R1 alcanza a
`40_salidas/datos/normas/*.json`**, que sí se modifican en B3, de modo que su
autorización en ese archivo es condición del push, no un detalle.

---

## 1. Línea base del buscador (§5.1)

### 1.1 Qué se midió y con qué

- **Sitio:** el publicado, servido en lectura con `servr::httd(dir="40_salidas/sitio", port=8768)`.
- **Consultas:** las diez de `50_documentacion/andamios/lab_motor_v9/a2_consultas_evaluacion.csv`,
  columna `consulta` (la forma literal en que las escribe el equipo).
- **Instrumento:** `consulta_ui.mjs` (anexo A.2) consulta el índice Pagefind ya construido
  **y replica la lógica de recorte de sub-resultados de `pagefind-ui.js` v1.5.2**, para poder
  separar lo que el índice encuentra de lo que la interfaz muestra.
- **Evaluador:** `evaluar_buscador.R` (anexo A.3) cruza con `ancla_esperada` y `anclas_aceptadas`.

La réplica no se escribió de memoria: se transcribió del bundle publicado. Comando:
`node -e 'const s=require("fs").readFileSync("40_salidas/sitio/pagefind/pagefind-ui.js","utf8"); console.log(s.slice(s.indexOf("sub_results?.[0]?.url")-600, ...))'`.
Fragmento literal:

```js
A=(o,I)=>{if(o.length<=I)return o;
          let m=[...o].sort((f,p)=>p.locations.length-f.locations.length).slice(0,3).map(f=>f.url);
          return o.filter(f=>m.includes(f.url))},
c=async o=>{t(1,n=await o.data()),
            t(1,n=a?.(n)??n),                       // a = process_result
            ...
            Array.isArray(n.sub_results)&&(t(4,u=n.sub_results?.[0]?.url===(n.meta?.url||n.url)),
              u?t(3,C=A(n.sub_results.slice(1),3)):t(3,C=A([...n.sub_results],3)))}
```

Tres cosas se leen ahí, y las tres importan:

1. El tope es **3** y está escrito en el cuerpo de `A` (`slice(0,3)`), no solo en el argumento.
2. `A` **elige los 3 con más `locations`**, pero devuelve con `o.filter(...)`, que **preserva
   el orden del arreglo de entrada**: la selección es por frecuencia y la presentación es en
   orden de documento.
3. `process_result` (`a`) se aplica **antes** del recorte. Es el punto de entrada legítimo
   para reordenar, y no permite superar el tope de 3.

### 1.2 Resultado: la línea base heredada de 0 de 10 no se reproduce

§5.1 obliga a decirlo antes de seguir, y es el caso.

| Lectura | Cifra |
|---|---|
| Ancla **esperada** visible en la interfaz | **1 de 10** (C06) |
| Cualquier ancla **aceptada** visible en la interfaz | **2 de 10** (C06, C10) |
| Ancla aceptada presente en el índice, en cualquier posición | **3 de 10** (C05, C06, C10) |
| Consultas que devuelven **cero páginas** | **3 de 10** (C02, C08, C09) |

Detalle consulta por consulta (criterio de anclas aceptadas, `page_size = 8`, tope 3):

| id | páginas devueltas | ancla en el índice | página visible | **visible en la UI** | orden de doc. | rango por `suma_balanced` |
|---|---|---|---|---|---|---|
| C01 | 1 | no | no | **no** | — | — |
| C02 | **0** | no | no | **no** | — | — |
| C03 | 4 | no | no | **no** | — | — |
| C04 | 1 | no | no | **no** | — | — |
| C05 | 3 | sí | sí | **no** | 12 | 2 |
| C06 | 3 | sí | sí | **sí** | 5 | 2 |
| C07 | 9 | no | no | **no** | — | — |
| C08 | **0** | no | no | **no** | — | — |
| C09 | **0** | no | no | **no** | — | — |
| C10 | 5 | sí | sí | **sí** | 7 | 1 |

### 1.3 De dónde sale la discrepancia con el v9, y qué queda en pie

El v9 no midió 0 de 10 «a secas»: midió una matriz de variantes de consulta × lecturas
(`lab_motor_v9/a2_linea_base_resumen.csv`, versionado en disco pero **no en git**). La fila
`sin_filtro / B_ui_documento` da `top1=0, top3=0, top10=0, no_aparece=10`, y de ahí viene la
cifra citada en §0 del encargo. La misma tabla, fila `sin_filtro / A_pagina`, da
`no_aparece=7`, es decir **la página correcta se recupera en 3 de 10** — que es exactamente
lo que mide este encargo como «ancla en el índice».

La diferencia entre el 0 del v9 y el 1–2 de aquí está en cómo se modeló la interfaz: la
lectura `B_ui_documento` del v9 tomó **los primeros en orden de documento**, mientras que
`A` en el bundle **selecciona los 3 con más `locations`** y solo después los ordena por
documento. Con la selección por frecuencia, C06 y C10 sí alcanzan a mostrarse.

**Lo que sí queda confirmado del diagnóstico heredado:** el orden de presentación es de
documento y el tope es 3. **Lo que no queda en pie:** la frase de §0 del encargo, «la causa
no es el índice, que sí las encuentra». Para **7 de las 10** el índice **no** entrega la
página correcta, y en 3 de ellas no entrega nada. Pagefind exige que **todos** los términos
de la consulta aparezcan en la página, y las consultas están escritas en el lenguaje del
equipo, no en el de la norma: «celular» no existe en la ley 21.801, que dice «dispositivos
móviles»; «bullying» no está en la ley 21.809, que dice «acoso escolar». Eso es
recuperación léxica, no presentación, y **no cabe en el alcance de B1**, cuya regla de
detención acota el cambio a `busqueda.html`.

**Consecuencia para el criterio de éxito de B1:** el techo alcanzable tocando solo la
presentación es **3 de 10**, porque solo 3 de las 10 tienen su ancla dentro del material
que la interfaz recibe. Se declara aquí, antes de tocar código, para que el «N de 10» del
reporte final se lea contra el techo real y no contra 10.

### 1.4 Controles positivos de §5.1 (un cero sin control no se reporta)

| Control | Qué planta | Resultado |
|---|---|---|
| **Positivo (comparador)** | Declara como «ancla esperada» el primer sub-resultado que el propio instrumento marca visible, en las 7 consultas que tienen alguno | **7 de 7 detectados**. Descarta que el cero venga de la normalización de URL (`/archivo.html#ancla` frente a `archivo.html#ancla`), que es el modo natural de fallar aquí |
| **Negativo** | Declara `ley_21801_celulares.html#art-99999` como esperada en las 10 | **0 de 10**. Sin falsos positivos |

### 1.5 Segunda batería: el término canónico (justifica el tope de B1)

La batería literal deja solo 3 casos utilizables para elegir el tope, que es muy poco. Se
corrió una segunda con la columna `termino_canonico` del mismo conjunto (el término con que
la norma nombra la cosa: «dispositivos móviles», «acoso escolar»…). Ahí el índice recupera
**10 de 10** y hay 10 casos para medir.

Cobertura por criterio de orden y tope, sumando ambas baterías (máximo 3 + 10 = 13):

| criterio de orden | tope 1 | tope 2 | tope 3 | tope 4 | tope 5 | tope 6 | tope 7 | tope 8 | tope 9 |
|---|---|---|---|---|---|---|---|---|---|
| **orden de documento (el actual)** | 4 | 7 | **7** | 9 | 10 | 11 | 12 | 12 | 12 |
| `n_locations` | 8 | 11 | 11 | 11 | 11 | 11 | 11 | 11 | 12 |
| **`suma_balanced`** | 7 | **12** | 12 | 12 | 12 | 12 | 12 | 12 | 13 |
| `max_balanced` | 4 | 7 | 8 | 10 | 11 | 12 | 13 | 13 | 13 |
| `max_balanced` → `suma_balanced` | 6 | 10 | 12 | 12 | 12 | 12 | 12 | 12 | 13 |
| `suma_balanced` → `max_balanced` | 7 | **12** | 12 | 12 | 12 | 12 | 12 | 12 | 13 |
| media de `balanced` por aparición | 5 | 8 | 9 | 9 | 11 | 11 | 11 | 12 | 12 |

Lecturas que esta tabla obliga:

- **El orden pesa mucho más que el tope.** Con orden de documento hacen falta 7 posiciones
  para llegar a 12; con `suma_balanced` bastan **2**.
- **Entre 2 y 8 el tope no compra nada** con el criterio ganador: la curva es plana en 12.
  El único caso que ningún tope ≤ 8 alcanza es C07 canónica («consejo escolar» en un decreto
  que reglamenta consejos escolares: el término está en casi todos sus artículos y el que
  responde no destaca).
- Por eso el valor elegido en B1 no puede justificarse como «el mínimo que cubre», que
  sería 2 sobre 13 casos: se elige **5**, que es el mayor tope que no cuesta cobertura y deja
  margen sobre un mínimo medido con una muestra pequeña. Queda declarado como decisión de
  margen, no como óptimo medido.

`balanced_score` es el peso que Pagefind da a cada aparición corregido por el largo del
fragmento; `suma_balanced` es su suma dentro del sub-resultado.

---

## 2. Inventario de anclas (§5.2) — prueba de regresión del encargo

Instrumento: `medicion_estructura.R` (anexo A.1).

| Cifra | Valor | Referencia v9 |
|---|---|---|
| JSON de norma leídos | 25 | 25 |
| **Segmentos con ancla declarados en los JSON** | **806** | 806 ✔ |
| de ellos `es_articulo = TRUE` | 682 | 682 ✔ |
| **Presentes como `id=` en su HTML** | **806** | 806 ✔ |
| Faltan en el HTML | **0** | 0 ✔ |
| Páginas HTML del sitio | 47 | — |
| Encabezados con `id` en todo el sitio | 958 | 958 ✔ |
| Enlaces internos con fragmento | 273 | — |
| de ellos **resuelven** | **273** (0 rotos) | — |
| Destinos distintos `archivo#ancla` | 205 | — |
| de ellos **resuelven** | **205** (0 rotos) | — |

**Sobre el «887 de 887» que §5.2 cita como referencia.** Sí es reproducible, y cuadra
exacto. La primera redacción de esta sección dijo que no lo era, por haber supuesto la
descomposición en vez de buscarla; la corrección va aquí, con su fuente.

La verdad de terreno está en el laboratorio del v9, `lab_motor_v9/a1_salida_prototipo.txt`,
línea 166, que se transcribe literal:

```
destinos verificados: 887 de 887 entradas con destino (con ancla: 845; solo pagina: 42);
canonicos verificados: 887; entradas sin destino (pendientes de fuente): 5; fallos: 0
```

De ahí sale toda la aritmética, sin suponer nada:

| Relación | Cuenta |
|---|---|
| Entradas del índice del prototipo | **892** |
| … con destino | **887** = 892 − **5** sin destino (pendientes de fuente) |
| … de esas, con ancla | **845** |
| … de esas, solo página | **42** = 25 normas + 17 temas |
| Anclas de segmento del sitio | **806** |
| **Encabezados del glosario** | **39** = 845 − 806 |

Los 39 son los encabezados `###` de `20_insumos/curaduria/piezas/borradores/glosario.md`
(recuento propio: 39), que **no están publicados**: el sitio tiene 0 piezas interpretativas.
Por eso 887 no se puede verificar entero contra el sitio, y sí se puede verificar la parte
que sí existe en él:

| Clase de destino | Cantidad | Resuelven |
|---|---|---|
| Ancla de segmento (`<slug>.html#<id>`) | 806 | **806** |
| Página de norma (`<slug>.html`) | 25 | **25** |
| Página temática (`tema-*.html`) | 17 | **17** |
| **Total verificable contra el sitio publicado** | **848** | **848, 0 rotos** |

`887 − 848 = 39`, los del glosario no publicado. **La prueba de regresión de este encargo
tiene entonces tres lecturas**, y las tres se corren después de cada regeneración con el
comando del anexo A.1: 806 de 806 anclas de segmento; **848 de 848 destinos del inventario
del v9 que son verificables contra el sitio**; y 273 enlaces internos con 205 destinos
distintos, 0 rotos.

### 2.1 Control positivo de §5.2

Se planta `<a href="ley_21801_celulares.html#art-99-inexistente">` en una copia **en
memoria** de `acerca.html` (no se escribe en disco). El verificador reporta
`destinos rotos detectados: 1`, ancla `art-99-inexistente`. **Veredicto: detecta.** El 0
de destinos rotos de la tabla se reporta con su control.

---

## 3. Peso y densidad por página (§5.3)

Bytes totales del conjunto HTML: **3 048 234**. Las diez mayores:

| archivo | bytes | encabezados con `id` | `id` totales |
|---|---|---|---|
| `dfl_1_estatuto_asistentes_educacion.html` | 305 372 | 220 | 452 |
| `ley_21430_garantias_ninez.html` | 198 069 | 96 | 204 |
| `ley_20845_inclusion_escolar.html` | 194 258 | 40 | 92 |
| `rex_482_reglamentos_b.html` | 165 776 | 50 | 112 |
| `dto_453_estatuto_docente.html` | 165 040 | 67 | 146 |
| `ley_21809_convivencia_educativa.html` | 148 249 | 49 | 110 |
| `ley_20370_general_educacion.html` | 142 717 | 85 | 182 |
| `dfl_315_perdida_reconocimiento_oficial.html` | 107 531 | 41 | 94 |
| `ley_19979_jornada_escolar_completa.html` | 89 725 | 21 | 54 |
| `dictamen_52_77_expulsion.html` | 70 719 | 11 | 34 |

---

## 4. Largo del índice lateral (§5.4)

| archivo | bytes de la página | entradas `<li>` en `nav#TOC` | bytes del `nav` |
|---|---|---|---|
| `dfl_1_estatuto_asistentes_educacion.html` | 305 372 | **1** | 270 |
| `ley_21430_garantias_ninez.html` | 198 069 | **1** | 270 |
| `ley_20845_inclusion_escolar.html` | 194 258 | **1** | 270 |
| `rex_482_reglamentos_b.html` | 165 776 | **1** | 268 |
| `dto_453_estatuto_docente.html` | 165 040 | **1** | 270 |

Distribución en las 47 páginas: mín 0, mediana 1, media 2,26, **máx 16**. Páginas con más
de 50 entradas: **0**. Con más de 100: **0**.

**El defecto 6 de B2 no se confirma, y lo que hay es el contrario.** El índice lateral de
las páginas de norma se titula «Articulado» y contiene **una sola entrada**, «Normas
relacionadas». Contenido literal del `nav` de `dfl_1`, una norma de 217 artículos:

```html
<nav id="TOC" role="doc-toc" class="toc-active">
    <h2 id="toc-title">Articulado</h2>
  <ul class="collapse">
  <li><a href="#relacionadas" id="toc-relacionadas" class="nav-link active" data-scroll-target="#relacionadas">Normas relacionadas</a></li>
  </ul>
</nav>
```

Los 217 encabezados de artículo existen, con su `id`, y son `<h2>` con `toc-depth: 2`; lo
que no entran es al índice. La diferencia entre ellos y «Normas relacionadas» es que los
artículos se emiten dentro del `div` `::: {data-pagefind-body="true"}` de
`34_generar_paginas.R` y ese encabezado va fuera. **Se declara y no se toca**: la regla de
§6.B2 manda no corregir lo que la medición no confirme, y además la corrección estaría en
`34_generar_paginas.R`, fuera de la tabla de §3. Queda anotado como defecto mayor
pendiente, distinto del que el encargo suponía.

---

## 5. Alcance del buscador (§5.5)

`grep -c 'id="buscador"'` sobre las 47 páginas: **47 de 47**.

| clase de página | con buscador |
|---|---|
| norma | 25 de 25 |
| tema | 17 de 17 |
| portada e índices | 5 de 5 |

**Defecto 5 de B2 confirmado.** Espacio vertical que el bloque reserva antes del contenido,
leído de `estilo.css:75` (`#buscador { margin: 1.2rem auto 2rem auto; }`): 3,2 rem de
margen más la caja de entrada, en las 25 páginas de norma, por delante del articulado.

---

## 6. Contaminación del preámbulo (§5.6) — **17 normas exactas**

El encargo pide el número exacto donde el v9 dejó un rango. Se midió dos veces, con dos
instrumentos independientes y coincidentes: `contaminacion.R` (anexo A.4) sobre los 806
segmentos, y una verificación con `jq` sobre los mismos JSON.

**Comando exhaustivo:**

```bash
jq -r '.slug as $s | .articulos[] | select(.texto|test("bcn\\.cl")) | "\($s)\t\(.id)"' \
   40_salidas/datos/normas/*.json | sort
```

**Salida: 17 líneas.** 15 con `id = preambulo` y 2 con `id = documento`
(`rex_181_celulares`, `rex_482_instrucciones_reglamentos_internos`: normas de un solo
segmento, sin articulado, que por eso no tienen preámbulo).

| marca buscada | normas | segmentos | en `preambulo` | fuera de `preambulo` |
|---|---|---|---|---|
| `Url Corta` | 17 | 17 | 15 | 2 |
| `bcn\.cl` | 17 | 17 | 15 | 2 |
| `Publicación:` / `Promulgación:` / `Versión:` | 17 | 17 | 15 | 2 |
| `Biblioteca del Congreso Nacional` | 2 | 2 | 0 | 2 |
| `Última Versión` | 7 | 7 | 6 | 1 |

**Las 17 contaminadas:** `dfl_1_estatuto_asistentes_educacion`,
`dfl_315_perdida_reconocimiento_oficial`, `dto_215_uniforme_escolar`,
`dto_24_consejos_escolares`, `dto_453_estatuto_docente`, `dto_565_centros_padres_apoderados`,
`ley_19979_jornada_escolar_completa`, `ley_20370_general_educacion`,
`ley_20536_violencia_escolar`, `ley_20845_inclusion_escolar`, `ley_20911_formacion_ciudadana`,
`ley_21430_garantias_ninez`, `ley_21545_tea`, `ley_21801_celulares`,
`ley_21809_convivencia_educativa`, `rex_181_celulares`,
`rex_482_instrucciones_reglamentos_internos`.

**Comprobación separada, y decisiva para el alcance: no aparece en el articulado.**

```bash
$ jq -r '.slug as $s | .articulos[] | select(.es_articulo == true)
         | select(.texto|test("Url Corta|Tipo Versi|Fecha Promulgaci|Fecha Publicaci|Ultima Modificaci|bcn\\.cl|leychile"))
         | "\($s)\t\(.id)"' 40_salidas/datos/normas/*.json | wc -l
       0
```

**Cero segmentos con `es_articulo = true`.** La limpieza no puede tocar articulado porque no
hay articulado que tocar.

### 6.1 De dónde viene el «17 a 19» del v9

`grep -lI "https" 40_salidas/intermedios/texto/*.txt` da 19; los dos de más son
`dictamen_065_revision_mochilas` (una URL de la UNESCO citada en el cuerpo del dictamen) y
`rex_482_reglamentos_b` (una URL de mineduc.cl en una nota al pie). Contenido legítimo, no
cabecera. **El número exacto es 17.**

### 6.2 El patrón literal, tal como está en los datos

Invariante en las 17: la ficha ocupa bloques contiguos desde el primero y **el bloque que la
cierra termina en `Url Corta: https://bcn.cl/<token>`**, con `<token>` de 5 a 6 caracteres
alfanuméricos (`3lfmw`, `o2ZDtA`, `8gtgm9`…). Aparece **una sola vez por documento**.

```
Decreto 24 REGLAMENTA CONSEJOS ESCOLARES MINISTERIO DE EDUCACIÓN
                                        <- bloque 1: título y organismo (contenido, se conserva)
Publicación: 11-MAR-2005 | Promulgación: 27-ENE-2005 Versión: Última Versión De : 29-MAR-2016 Ultima Modificación: 29-MAR-2016 Decreto 19 Url Corta: https://bcn.cl/3lau7
                                        <- bloque 2: la ficha. Esto es lo que sobra
REGLAMENTA CONSEJOS ESCOLARES           <- bloque 3: ya es el documento oficial
```

Varía: el prefijo de la línea de fechas (`Fecha Publicación:` + `Tipo Versión:` en 11 normas;
`Publicación:` + `Versión:` en 6), los campos intermedios opcionales (`Inicio Vigencia:`,
`Fin Vigencia:`, `Ultima Modificación:`, `Tiene Texto Refundido:`), y el índice del bloque de
la ficha (2 en 15 normas, 3 en las 2 `rex`, que traen delante un encabezado corrido de
página). Largo del bloque: entre 116 y 246 caracteres.

Además, en los **2 documentos de una sola página** sobrevive el pie:

```
Biblioteca del Congreso Nacional de Chile - www.leychile.cl - documento generado el 06-Ago-2026 página 1 de 1
```

Sobrevive porque `31_extraer_texto.R:59` corta la detección de repetidos con
`if (n < 3L) return(character(0))`: con una sola página no hay repetición que detectar.

### 6.3 Control positivo de §5.6

| Caso | Detectado | Esperado |
|---|---|---|
| `"Artículo 1.- Texto cualquiera. Url Corta: https://bcn.cl/3lau7 y sigue."` | `TRUE` | `TRUE` |
| `"Artículo 1.- Texto cualquiera sin cabecera alguna."` | `FALSE` | `FALSE` |

**Veredicto: detecta y no da falso positivo.**

### 6.4 La ficha ya produjo un defecto visible, parchado en el consumidor

`34_generar_paginas.R:850-855`, comentario literal en el repositorio: *«El preambulo suele
contener el titulo de la norma y por lo tanto casi siempre menciona el tema: sin esta
preferencia, la pagina tematica de TEA mostraba como extracto la ficha bibliografica de la
ley 21.545 en vez de su articulado.»* El parche ordena artículos antes que no-artículos, y
**no cubre** a `rex_181_celulares` ni a `rex_482_instrucciones_reglamentos_internos`, cuyo
único segmento tiene `es_articulo = false`. Es evidencia de que la limpieza corresponde al
origen.

---

## 7. Control de idempotencia de la regeneración (previo, no pedido por §5)

Antes de atribuir un solo cambio a este encargo hay que saber si el sitio publicado
corresponde al código publicado. Se corrió `Rscript -e 'source("00_run_all.R"); run_all()'`
**sin ninguna modificación** (7 pasos, 14,8 s) y se compararon hashes.

| Comparación | Resultado |
|---|---|
| 47 HTML de `40_salidas/sitio` (`md5 -r`) | **idénticos, 0 diferencias** |
| 28 JSON versionados de `40_salidas/datos` (`md5 -r`) | **idénticos** |
| `git status --porcelain` tras la corrida | sin cambios en archivos versionados |
| `40_salidas/sitio/pagefind/pagefind-entry.json` | **cambia**: `es_1ff273c38d` → `es_24ccef5df1` |

Ese último es el único artefacto no reproducible: Pagefind nombra su `.pf_meta` con un hash
que cambia en cada build. No está versionado (`.gitignore:57`) y no afecta a ninguna cifra
de este documento. **La línea base es comparable con lo que venga después.**

---

## 8. Medición de los seis defectos de legibilidad (§6.B2)

§6.B2 manda corregir solo los que la medición confirme. Resultado del examen:

| # | Defecto declarado en el encargo | Veredicto | Evidencia |
|---|---|---|---|
| 1 | Cero reglas responsivas en las 163 líneas de la hoja | **confirmado** | `grep -c "@media" 30_procesamiento/34_plantillas_sitio/estilo.css` → **0**; ídem sobre la copia publicada `40_salidas/sitio/estilo.css` → **0** |
| 2 | Enlaces que no parecen enlaces: títulos de norma en gris y sin subrayado en los listados | **confirmado en otra regla** | `.lista-normas` y `.titulo-norma` (`estilo.css:79-81`) **no se usan en ninguna de las 47 páginas**: `grep -l 'lista-normas' 40_salidas/sitio/*.html \| wc -l` → **0**. Es código muerto. La regla que sí aplica es `.tema-norma a { text-decoration: none; }` (`estilo.css:149`), presente en las 17 páginas temáticas (14 ocurrencias de `class="tema-norma"` solo en `tema-convivencia-escolar.html`) |
| 3 | Contraste bajo en texto pequeño de ficha, procedencia y etiquetas de relación | **parcial** | 2 de 11 pares bajo AA. Tabla abajo |
| 4 | Versalitas diminutas en las insignias, varias por ficha | **confirmado** | `.badge-fuente` a `0.78rem` = **13,3 px** medidos con `getComputedStyle` (el `rem` base del tema es 17 px, no 16); `.ficha-norma dt` a `0.82rem` = **13,9 px**, también versalita. Insignias por página: mediana **15**, máximo **48** (`tema-medidas-disciplinarias.html`), total **781** en 42 de 47 páginas |
| 5 | Buscador en todas las páginas | **confirmado** | 47 de 47 (§5 arriba) |
| 6 | Índice lateral desproporcionado | **NO confirmado** | 1 entrada en las 5 páginas mayores, máximo 16 en el sitio (§4 arriba). Se declara y no se toca |

### 8.1 Contraste WCAG 2.1 (defecto 3)

Texto pequeño: AA exige 4,5:1. Todas las medidas son de texto pequeño (< 18,66 px). Los px
salen de `getComputedStyle` en Chrome 152 sobre el sitio servido, no de un cálculo: el tema
cosmo fija el `rem` base en **17 px**, no en los 16 px del defecto de Bootstrap.

| selector | color | fondo | tamaño | contraste | AA |
|---|---|---|---|---|---|
| `.ficha-norma dt` | `#6c757d` | `#f8f9fa` | 13,9 px versalita | **4,45** | **no** |
| `.procedencia` dentro de la ficha | `#6c757d` | `#f8f9fa` | 13,9 px | **4,45** | **no** |
| `.procedencia` sobre la página | `#6c757d` | `#ffffff` | 13,9 px | 4,69 | sí |
| `.lista-relaciones .rel-por` | `#6c757d` | `#ffffff` | 15,0 px | 4,69 | sí |
| `.badge-tema` | `#495057` | `#f1f3f5` | 13,3 px | 7,35 | sí |
| `.badge-tipo` | `#212529` | `#e9ecef` | 13,3 px versalita | 13,01 | sí |
| `.marca-ocr` | `#6b5200` | `#fffbe9` | 13,6 px | 7,14 | sí |
| `.transcripcion-ocr pre` | `#3d3d3d` | `#fffdf5` | 14,8 px | 10,67 | sí |
| `.lista-normas .titulo-norma` (muerta) | `#495057` | `#ffffff` | 17 px | 8,18 | sí |

**Confirmado solo para la ficha**, y por poco: 4,45 contra un umbral de 4,5. Las etiquetas
de relación que el encargo nombra **sí cumplen** (4,69 y 7,35) y por tanto no se tocan.

**Control positivo del cálculo:** reproduce los valores canónicos de la norma —
`#000000/#ffffff` → **21,00**; `#ffffff/#ffffff` → **1,00**; `#767676/#ffffff` → **4,54**
(el límite AA que la propia WCAG cita); `#777777/#ffffff` → **4,48** (justo por debajo).

**Color de reemplazo, elegido por medición y sin paleta nueva:** `#495057`, que ya está en
la hoja (`estilo.css:49` y `:81`). Contraste **7,76** sobre `#f8f9fa` y **8,18** sobre
blanco: cumple AAA. Los intermedios `#5c636a` (5,78) y `#565e64` (6,26) también cumplirían,
pero introducirían un gris que la hoja no tiene, contra la restricción de identidad de §6.B2.

## Anexo A — Instrumentos

Los ocho scripts se ejecutaron desde la raíz del repositorio, con `LANG=es_ES.UTF-8`.
Viven fuera del repositorio porque §3 no autoriza archivos de laboratorio dentro; se
transcriben aquí para que las cifras de arriba sean reproducibles. Residuo declarado: no
quedan versionados, que es la misma deuda que el v9 dejó con `lab_motor_v9/`.

### A.1 — `medicion_estructura.R` (§5.2, §5.3, §5.4, §5.5)

```r
# =============================================================================
# medicion_estructura.R -- mediciones §5 puntos 2, 3, 4 y 5 del encargo v10.
# -----------------------------------------------------------------------------
# SOLO LECTURA sobre el repositorio. Escribe unicamente en el directorio de
# laboratorio que reciba por argumento, que vive FUERA del repo.
# Acceso a estructuras leidas de disco siempre con [[ ]], nunca con $.
# Uso: Rscript medicion_estructura.R <dir_salida> [etiqueta]
# =============================================================================
suppressPackageStartupMessages({
  library(stringr); library(dplyr); library(tibble)
})

args <- commandArgs(trailingOnly = TRUE)
DIR_SALIDA <- if (length(args) >= 1L) args[[1L]] else stop("falta <dir_salida>")
ETIQUETA   <- if (length(args) >= 2L) args[[2L]] else "medicion"
dir.create(DIR_SALIDA, showWarnings = FALSE, recursive = TRUE)

RAIZ  <- "/Users/tomgc/Projects/slep_normativa_convivencia"
SITIO <- file.path(RAIZ, "40_salidas", "sitio")
DATOS <- file.path(RAIZ, "40_salidas", "datos", "normas")

leer <- function(p) paste(readLines(p, warn = FALSE, encoding = "UTF-8"), collapse = "\n")

htmls  <- sort(list.files(SITIO, pattern = "[.]html$", full.names = TRUE))
nombres <- basename(htmls)
cont   <- lapply(htmls, leer)
names(cont) <- nombres

cat("=============================================================\n")
cat("MEDICION ESTRUCTURAL --", ETIQUETA, "\n")
cat("=============================================================\n")
cat("Paginas HTML en 40_salidas/sitio:", length(htmls), "\n\n")

# --- Extractores reutilizables ----------------------------------------------
# ids de cualquier elemento
ids_de <- function(txt) str_match_all(txt, 'id="([^"]+)"')[[1L]][, 2L]
# ids que cuelgan de un encabezado h1..h6 (los que Pagefind usa como sub-resultado)
ids_encabezado_de <- function(txt) {
  m <- str_match_all(txt, '<h[1-6][^>]*\\sid="([^"]+)"')[[1L]]
  if (nrow(m) == 0L) character(0) else m[, 2L]
}
# enlaces internos con fragmento
enlaces_de <- function(txt) {
  h <- str_match_all(txt, 'href="([^"]+)"')[[1L]]
  if (nrow(h) == 0L) return(character(0))
  h <- h[, 2L]
  h[str_detect(h, "#") & !str_detect(h, "^(https?:|mailto:|//)")]
}

# =============================================================================
# PUNTO 2 -- INVENTARIO DE ANCLAS
# =============================================================================
cat("-------------------------------------------------------------\n")
cat("PUNTO 2a -- Segmentos con ancla declarados en los JSON de norma\n")
cat("-------------------------------------------------------------\n")
jsons <- sort(list.files(DATOS, pattern = "[.]json$", full.names = TRUE))
seg <- lapply(jsons, function(p) {
  j <- jsonlite::fromJSON(p, simplifyVector = FALSE)
  arts <- j[["articulos"]]
  tibble(
    slug = j[["slug"]],
    id   = vapply(arts, function(a) as.character(a[["id"]]), character(1)),
    es_articulo = vapply(arts, function(a) isTRUE(a[["es_articulo"]]), logical(1))
  )
})
seg <- bind_rows(seg)
seg[["html"]] <- paste0(seg[["slug"]], ".html")
seg[["presente_en_html"]] <- mapply(function(h, i) {
  if (!(h %in% names(cont))) return(NA)
  str_detect(cont[[h]], fixed(paste0('id="', i, '"')))
}, seg[["html"]], seg[["id"]])

cat("JSON de norma leidos:                 ", length(jsons), "\n")
cat("Segmentos con ancla en los JSON:      ", nrow(seg), "\n")
cat("  de ellos es_articulo = TRUE:        ", sum(seg[["es_articulo"]]), "\n")
cat("Presentes como id= en su HTML:        ", sum(seg[["presente_en_html"]], na.rm = TRUE), "\n")
cat("FALTAN en el HTML:                    ", sum(!seg[["presente_en_html"]], na.rm = TRUE), "\n")
if (any(!seg[["presente_en_html"]], na.rm = TRUE)) {
  print(as.data.frame(seg[!seg[["presente_en_html"]], c("slug", "id")]))
}

cat("\n-------------------------------------------------------------\n")
cat("PUNTO 2b -- Destinos de enlace interno con fragmento\n")
cat("-------------------------------------------------------------\n")
dest <- bind_rows(lapply(nombres, function(n) {
  e <- enlaces_de(cont[[n]])
  if (length(e) == 0L) return(tibble(origen = character(0), href = character(0)))
  tibble(origen = n, href = e)
}))
dest[["archivo"]] <- ifelse(str_starts(dest[["href"]], "#"),
                            dest[["origen"]],
                            str_replace(dest[["href"]], "#.*$", ""))
dest[["ancla"]]   <- str_replace(dest[["href"]], "^[^#]*#", "")
dest <- dest[nzchar(dest[["ancla"]]), ]
dest[["archivo_existe"]] <- dest[["archivo"]] %in% names(cont)
dest[["resuelve"]] <- mapply(function(a, k) {
  if (!(a %in% names(cont))) return(FALSE)
  str_detect(cont[[a]], fixed(paste0('id="', k, '"')))
}, dest[["archivo"]], dest[["ancla"]])

cat("Enlaces internos con fragmento (total):", nrow(dest), "\n")
cat("  resuelven:                           ", sum(dest[["resuelve"]]), "\n")
cat("  NO resuelven:                        ", sum(!dest[["resuelve"]]), "\n")
u <- distinct(dest[, c("archivo", "ancla", "resuelve")])
cat("Destinos distintos (archivo#ancla):    ", nrow(u), "\n")
cat("  resuelven:                           ", sum(u[["resuelve"]]), "\n")
cat("  NO resuelven:                        ", sum(!u[["resuelve"]]), "\n")
if (any(!u[["resuelve"]])) {
  cat("\nDestinos rotos:\n"); print(as.data.frame(u[!u[["resuelve"]], ]))
}

# --- CONTROL POSITIVO del punto 2 -------------------------------------------
cat("\n--- CONTROL POSITIVO punto 2 (el instrumento debe DETECTAR lo plantado) ---\n")
sonda_html <- cont[[nombres[[1L]]]]
plantado_roto <- '<a href="ley_21801_celulares.html#art-99-inexistente">sonda</a>'
sonda <- str_replace(sonda_html, "</body>", paste0(plantado_roto, "</body>"))
e_sonda <- enlaces_de(sonda)
arch_s <- ifelse(str_starts(e_sonda, "#"), nombres[[1L]], str_replace(e_sonda, "#.*$", ""))
anc_s  <- str_replace(e_sonda, "^[^#]*#", "")
ok_s <- mapply(function(a, k) {
  if (!(a %in% names(cont))) return(FALSE)
  str_detect(cont[[a]], fixed(paste0('id="', k, '"')))
}, arch_s, anc_s)
det <- sum(!ok_s)
cat("Ancla rota plantada en una COPIA en memoria de", nombres[[1L]], "\n")
cat("  destinos rotos detectados en la copia:", det, "(esperado: 1)\n")
cat("  ancla detectada:", paste(unique(anc_s[!ok_s]), collapse = ", "), "\n")
cat("  VEREDICTO CONTROL 2:", if (det == 1L && "art-99-inexistente" %in% anc_s[!ok_s]) "DETECTA" else "NO DETECTA -- instrumento invalido", "\n")

# =============================================================================
# PUNTO 3 -- PESO Y DENSIDAD POR PAGINA
# =============================================================================
cat("\n-------------------------------------------------------------\n")
cat("PUNTO 3 -- Peso y densidad (bytes y encabezados con id por archivo)\n")
cat("-------------------------------------------------------------\n")
peso <- tibble(
  archivo = nombres,
  bytes   = file.size(htmls),
  n_encabezados_id = vapply(nombres, function(n) length(ids_encabezado_de(cont[[n]])), integer(1)),
  n_ids_total      = vapply(nombres, function(n) length(ids_de(cont[[n]])), integer(1))
) |> arrange(desc(bytes))
cat("Bytes totales del conjunto HTML:", sum(peso[["bytes"]]), "\n")
cat("Encabezados con id en todo el sitio:", sum(peso[["n_encabezados_id"]]), "\n\n")
cat("Diez paginas mayores:\n")
print(as.data.frame(head(peso, 10)), row.names = FALSE)

# =============================================================================
# PUNTO 4 -- LARGO DEL INDICE LATERAL EN LAS CINCO MAYORES
# =============================================================================
cat("\n-------------------------------------------------------------\n")
cat("PUNTO 4 -- Largo del indice lateral (TOC) en las cinco paginas mayores\n")
cat("-------------------------------------------------------------\n")
largo_toc <- function(txt) {
  m <- str_match(txt, '(?s)<nav id="TOC".*?</nav>')
  if (is.na(m[[1L]])) return(c(entradas = 0L, bytes = 0L))
  bloque <- m[[1L]]
  c(entradas = str_count(bloque, "<li"), bytes = nchar(bloque, type = "bytes"))
}
top5 <- head(peso[["archivo"]], 5)
toc <- bind_rows(lapply(top5, function(n) {
  v <- largo_toc(cont[[n]])
  tibble(archivo = n, bytes_pagina = peso[["bytes"]][peso[["archivo"]] == n],
         entradas_toc = as.integer(v[["entradas"]]), bytes_toc = as.integer(v[["bytes"]]))
}))
print(as.data.frame(toc), row.names = FALSE)
tt <- bind_rows(lapply(nombres, function(n) {
  v <- largo_toc(cont[[n]]); tibble(archivo = n, entradas_toc = as.integer(v[["entradas"]]))
}))
cat("\nDistribucion de entradas de TOC en todo el sitio:\n")
print(summary(tt[["entradas_toc"]]))
cat("Paginas con TOC de mas de 50 entradas:", sum(tt[["entradas_toc"]] > 50), "\n")
cat("Paginas con TOC de mas de 100 entradas:", sum(tt[["entradas_toc"]] > 100), "\n")

# =============================================================================
# PUNTO 5 -- ALCANCE DEL BUSCADOR
# =============================================================================
cat("\n-------------------------------------------------------------\n")
cat("PUNTO 5 -- En cuantas paginas aparece el bloque de busqueda\n")
cat("-------------------------------------------------------------\n")
tiene_buscador <- vapply(nombres, function(n) str_detect(cont[[n]], fixed('id="buscador"')), logical(1))
cat("Paginas con <div id=\"buscador\">:", sum(tiene_buscador), "de", length(nombres), "\n")
cat("Paginas SIN el bloque:", paste(nombres[!tiene_buscador], collapse = ", "), "\n")
clase <- function(n) {
  if (str_starts(n, "tema-")) "tema"
  else if (n %in% c("index.html", "acerca.html", "indice-tipo.html", "indice-tema.html", "indice-anio.html")) "portada/indice"
  else "norma"
}
cl <- vapply(nombres, clase, character(1))
print(table(clase = cl, con_buscador = tiene_buscador))

# --- Volcados para el documento ---------------------------------------------
write.csv(as.data.frame(peso), file.path(DIR_SALIDA, paste0(ETIQUETA, "_peso_paginas.csv")), row.names = FALSE)
write.csv(as.data.frame(tt),   file.path(DIR_SALIDA, paste0(ETIQUETA, "_toc.csv")), row.names = FALSE)
write.csv(as.data.frame(u),    file.path(DIR_SALIDA, paste0(ETIQUETA, "_destinos.csv")), row.names = FALSE)
write.csv(as.data.frame(seg),  file.path(DIR_SALIDA, paste0(ETIQUETA, "_segmentos.csv")), row.names = FALSE)
cat("\nVolcados en", DIR_SALIDA, "\n")
```

### A.2 — `consulta_ui.mjs` (§5.1: consulta el índice y replica el recorte de la interfaz)

```js
// consulta_ui.mjs -- instrumento de medicion del buscador, en modo LECTURA.
// Consulta el indice Pagefind ya construido y ademas REPLICA la logica de
// recorte de sub-resultados de pagefind-ui.js v1.5.2, para poder distinguir
// "lo que el indice encuentra" de "lo que la interfaz muestra".
//
// La replica se transcribe del bundle minificado 40_salidas/sitio/pagefind/pagefind-ui.js:
//   t(4,u=n.sub_results?.[0]?.url===(n.meta?.url||n.url)),
//   u ? t(3,C=A(n.sub_results.slice(1),3)) : t(3,C=A([...n.sub_results],3))
// con
//   A=(o,I)=>{ if(o.length<=I) return o;
//              let m=[...o].sort((f,p)=>p.locations.length-f.locations.length).slice(0,3).map(f=>f.url);
//              return o.filter(f=>m.includes(f.url)) }
// Es decir: elige los 3 con MAS locations, pero los devuelve en ORDEN DE DOCUMENTO.
//
// Uso: node consulta_ui.mjs <entrada.json> <salida.json> <basePath> <rutaPagefindJs> [pageSize] [tope]
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";

const [, , entrada, salida, base, rutaJs, pageSizeArg, topeArg] = process.argv;
if (!entrada || !salida || !base || !rutaJs) {
  console.error("uso: node consulta_ui.mjs <entrada.json> <salida.json> <basePath> <rutaPagefindJs> [pageSize] [tope]");
  process.exit(2);
}
const PAGE_SIZE = pageSizeArg ? Number(pageSizeArg) : 8;
const TOPE = topeArg ? Number(topeArg) : 3;

const consultas = JSON.parse(readFileSync(entrada, "utf8"));
const p = await import(pathToFileURL(resolve(rutaJs)).href);
await p.options({ basePath: base });
await p.init();

// --- Replica literal del recorte de la UI (tope parametrizado para el experimento)
const recorte = (o, I) => {
  if (o.length <= I) return o;
  const m = [...o].sort((f, q) => q.locations.length - f.locations.length).slice(0, I).map((f) => f.url);
  return o.filter((f) => m.includes(f.url));
};
const visiblesUI = (d, tope) => {
  const sr = d.sub_results || [];
  const primeroEsPagina = sr?.[0]?.url === (d.meta?.url || d.url);
  const o = primeroEsPagina ? sr.slice(1) : [...sr];
  return recorte(o, tope);
};

const suma = (xs, f) => xs.reduce((a, x) => a + f(x), 0);
const out = { base, page_size: PAGE_SIZE, tope_sub_resultados: TOPE, consultas: [] };

for (const c of consultas) {
  const s = await p.search(c.consulta, c.filtros ? { filters: c.filtros } : undefined);
  const paginas = [];
  for (const [i, r] of s.results.entries()) {
    const d = await r.data();
    const vis = visiblesUI(d, TOPE).map((x) => x.url);
    const sub = (d.sub_results || []).map((sr, j) => ({
      orden_documento: j + 1,
      title: sr.title,
      url: sr.url,
      anchor_id: sr.anchor ? sr.anchor.id : null,
      n_locations: sr.locations ? sr.locations.length : null,
      n_weighted: sr.weighted_locations ? sr.weighted_locations.length : null,
      suma_balanced: sr.weighted_locations ? suma(sr.weighted_locations, (l) => l.balanced_score) : null,
      max_balanced: sr.weighted_locations && sr.weighted_locations.length ? Math.max(...sr.weighted_locations.map((l) => l.balanced_score)) : 0,
      suma_peso: sr.weighted_locations ? suma(sr.weighted_locations, (l) => l.weight) : null,
      visible_en_ui: vis.includes(sr.url)
    }));
    paginas.push({
      rango_pagina: i + 1,
      url: d.url,
      meta_url: d.meta ? d.meta.url ?? null : null,
      score: r.score,
      pagina_visible: i < PAGE_SIZE,
      n_sub_results: sub.length,
      n_visibles_ui: sub.filter((x) => x.visible_en_ui).length,
      sub_results: sub
    });
  }
  out.consultas.push({ id: c.id, consulta: c.consulta, filtros: c.filtros ?? null, n_paginas: s.results.length, paginas });
}
writeFileSync(salida, JSON.stringify(out, null, 1));
console.log(`consultas: ${out.consultas.length} | pageSize: ${PAGE_SIZE} | tope: ${TOPE} | escrito: ${salida}`);
process.exit(0);
```

### A.3 — `evaluar_buscador.R` (§5.1: cruce con el conjunto de evaluación y controles)

```r
# =============================================================================
# evaluar_buscador.R -- cruza la salida de consulta_ui.mjs con el conjunto de
# evaluacion de diez consultas y responde: en cuantas el ancla correcta esta
# VISIBLE en la interfaz. Distingue tres niveles:
#   (a) el indice la encuentra en algun sub-resultado de alguna pagina
#   (b) la pagina que la contiene esta entre las visibles (primeras page_size)
#   (c) el sub-resultado con esa ancla sobrevive al recorte de la UI  <-- la cifra
# Acceso a estructuras de disco siempre con [[ ]].
# Uso: Rscript evaluar_buscador.R <salida_ui.json> <etiqueta> [dir_salida]
# =============================================================================
suppressPackageStartupMessages({library(dplyr); library(tibble); library(stringr)})
args <- commandArgs(trailingOnly = TRUE)
RUTA <- args[[1L]]; ETIQ <- if (length(args) >= 2L) args[[2L]] else "medicion"
DIRS <- if (length(args) >= 3L) args[[3L]] else dirname(RUTA)

EV <- read.csv("50_documentacion/andamios/lab_motor_v9/a2_consultas_evaluacion.csv",
               stringsAsFactors = FALSE, encoding = "UTF-8")
res <- jsonlite::fromJSON(RUTA, simplifyVector = FALSE)

# Normalizacion de URL: Pagefind devuelve "/archivo.html#ancla"; el conjunto de
# evaluacion escribe "archivo.html#ancla". Sin esta normalizacion TODO daria 0 y
# el cero seria del comparador, no del buscador. Es el fallo que el control
# positivo de abajo existe para descartar.
norm <- function(u) {
  u <- sub("^https?://[^/]+", "", u)
  u <- sub("^/+", "", u)
  u <- sub("^.*/", "", u)   # el sitio es plano: basta el nombre de archivo
  u
}

filas <- list(); k <- 0L
for (cq in res[["consultas"]]) {
  idc <- cq[["id"]]
  for (pg in cq[["paginas"]]) {
    for (sr in pg[["sub_results"]]) {
      k <- k + 1L
      filas[[k]] <- tibble(
        id = idc, consulta = cq[["consulta"]],
        rango_pagina = pg[["rango_pagina"]], pagina_visible = isTRUE(pg[["pagina_visible"]]),
        pagina_url = norm(pg[["url"]]),
        orden_documento = sr[["orden_documento"]],
        n_sub = pg[["n_sub_results"]],
        url = norm(sr[["url"]]),
        anchor_id = if (is.null(sr[["anchor_id"]])) NA_character_ else sr[["anchor_id"]],
        title = sr[["title"]],
        n_locations = if (is.null(sr[["n_locations"]])) NA_integer_ else sr[["n_locations"]],
        suma_balanced = if (is.null(sr[["suma_balanced"]])) NA_real_ else sr[["suma_balanced"]],
        max_balanced = if (is.null(sr[["max_balanced"]])) NA_real_ else sr[["max_balanced"]],
        visible_ui = isTRUE(sr[["visible_en_ui"]])
      )
    }
  }
}
sub <- bind_rows(filas)

# Rango del sub-resultado dentro de su pagina bajo distintos ordenes
sub <- sub |>
  group_by(id, rango_pagina) |>
  mutate(
    rango_por_locations = rank(-n_locations, ties.method = "first"),
    rango_por_balanced  = rank(-suma_balanced, ties.method = "first"),
    rango_por_maxbal    = rank(-max_balanced, ties.method = "first")
  ) |> ungroup()

evaluar <- function(sub, esperadas_por_id, etiqueta) {
  out <- lapply(names(esperadas_por_id), function(idc) {
    acep <- esperadas_por_id[[idc]]
    s <- sub[sub[["id"]] == idc, ]
    hit <- s[s[["url"]] %in% acep, ]
    tibble(
      id = idc,
      n_paginas = length(unique(s[["rango_pagina"]])),
      en_indice = nrow(hit) > 0L,
      pagina_visible = any(hit[["pagina_visible"]]),
      VISIBLE_UI = any(hit[["visible_ui"]] & hit[["pagina_visible"]]),
      rango_pagina_min = if (nrow(hit)) min(hit[["rango_pagina"]]) else NA_integer_,
      n_sub_en_esa_pagina = if (nrow(hit)) hit[["n_sub"]][[which.min(hit[["rango_pagina"]])]] else NA_integer_,
      orden_doc = if (nrow(hit)) min(hit[["orden_documento"]]) else NA_integer_,
      rango_locations = if (nrow(hit)) min(hit[["rango_por_locations"]]) else NA_integer_,
      rango_balanced = if (nrow(hit)) min(hit[["rango_por_balanced"]]) else NA_integer_,
      rango_maxbal = if (nrow(hit)) min(hit[["rango_por_maxbal"]]) else NA_integer_
    )
  })
  out <- bind_rows(out)
  cat("\n### ", etiqueta, "\n", sep = "")
  print(as.data.frame(out), row.names = FALSE)
  cat(sprintf("  -> en el indice: %d de %d | pagina visible: %d de %d | VISIBLE EN LA UI: %d de %d\n",
              sum(out[["en_indice"]]), nrow(out), sum(out[["pagina_visible"]]), nrow(out),
              sum(out[["VISIBLE_UI"]]), nrow(out)))
  out
}

# --- Conjunto real -----------------------------------------------------------
esperadas <- setNames(lapply(seq_len(nrow(EV)), function(i) {
  norm(trimws(strsplit(EV[["anclas_aceptadas"]][[i]], ";", fixed = TRUE)[[1L]]))
}), EV[["id"]])
solo_esperada <- setNames(lapply(seq_len(nrow(EV)), function(i) norm(EV[["ancla_esperada"]][[i]])), EV[["id"]])

cat("=============================================================\n")
cat("EVALUACION DEL BUSCADOR --", ETIQ, "\n")
cat("page_size:", res[["page_size"]], "| tope de sub-resultados:", res[["tope_sub_resultados"]], "\n")
cat("=============================================================\n")
r_estricto <- evaluar(sub, solo_esperada, "A. Ancla ESPERADA (criterio estricto)")
r_acept    <- evaluar(sub, esperadas,     "B. Cualquier ancla ACEPTADA (criterio del conjunto)")

# --- CONTROL POSITIVO 1: el comparador reconoce un acierto cuando lo hay -----
cat("\n--- CONTROL POSITIVO 1 (comparador) ---\n")
cat("Se planta como 'ancla esperada' el PRIMER sub-resultado que el propio\n")
cat("instrumento declara visible en la UI para cada consulta. Si el comparador\n")
cat("funciona debe dar 10 de 10. Un 0 aqui probaria que el cero de arriba es\n")
cat("del comparador (normalizacion de URL) y no del buscador.\n")
plantado <- lapply(names(solo_esperada), function(idc) {
  s <- sub[sub[["id"]] == idc & sub[["visible_ui"]] & sub[["pagina_visible"]], ]
  if (nrow(s) == 0L) NA_character_ else s[["url"]][[1L]]
})
names(plantado) <- names(solo_esperada)
faltan <- vapply(plantado, function(x) all(is.na(x)), logical(1))
if (any(faltan)) cat("  (consultas sin ningun sub-resultado visible:", paste(names(plantado)[faltan], collapse=", "), ")\n")
plantado_ok <- plantado[!faltan]
c1 <- evaluar(sub, plantado_ok, "CONTROL POSITIVO 1: ancla plantada = un visible real")
cat("  VEREDICTO CONTROL 1:",
    if (all(c1[["VISIBLE_UI"]])) "DETECTA (el comparador reconoce aciertos)" else "NO DETECTA -- instrumento invalido", "\n")

# --- CONTROL NEGATIVO: un ancla inexistente no debe dar acierto --------------
cat("\n--- CONTROL NEGATIVO (ancla inexistente) ---\n")
inex <- setNames(lapply(names(solo_esperada), function(i) "ley_21801_celulares.html#art-99999"), names(solo_esperada))
c2 <- evaluar(sub, inex, "CONTROL NEGATIVO: ancla inexistente")
cat("  VEREDICTO CONTROL NEGATIVO:",
    if (sum(c2[["VISIBLE_UI"]]) == 0L) "0 de 10, como debe ser" else "FALSO POSITIVO -- instrumento invalido", "\n")

# --- Diagnostico: donde queda el ancla correcta ------------------------------
cat("\n--- DIAGNOSTICO: posicion del ancla correcta dentro de su pagina ---\n")
d <- r_acept[, c("id","en_indice","pagina_visible","VISIBLE_UI","rango_pagina_min",
                 "n_sub_en_esa_pagina","orden_doc","rango_locations","rango_balanced","rango_maxbal")]
print(as.data.frame(d), row.names = FALSE)
cat("\nTope necesario para cubrir las 10, por criterio de orden (max del rango):\n")
cat("  por n_locations :", max(d[["rango_locations"]], na.rm = TRUE), "\n")
cat("  por suma_balanced:", max(d[["rango_balanced"]], na.rm = TRUE), "\n")
cat("  por max_balanced :", max(d[["rango_maxbal"]], na.rm = TRUE), "\n")
cat("  por orden de documento (el actual):", max(d[["orden_doc"]], na.rm = TRUE), "\n")
cat("\nCobertura acumulada segun el tope, por criterio (sobre las que caen en pagina visible):\n")
dv <- d[d[["pagina_visible"]], ]
for (tope in 1:10) {
  cat(sprintf("  tope %2d: locations %2d/10 | suma_balanced %2d/10 | max_balanced %2d/10 | orden_doc %2d/10\n", tope,
              sum(dv[["rango_locations"]] <= tope, na.rm = TRUE),
              sum(dv[["rango_balanced"]] <= tope, na.rm = TRUE),
              sum(dv[["rango_maxbal"]] <= tope, na.rm = TRUE),
              sum(dv[["orden_doc"]] <= tope, na.rm = TRUE)))
}
write.csv(as.data.frame(r_acept), file.path(DIRS, paste0(ETIQ, "_evaluacion.csv")), row.names = FALSE)
write.csv(as.data.frame(sub), file.path(DIRS, paste0(ETIQ, "_subresultados.csv")), row.names = FALSE)
cat("\nVolcado:", file.path(DIRS, paste0(ETIQ, "_evaluacion.csv")), "\n")
```

### A.4 — `barrido_tope.R` (§5.1.5: criterio de orden × tope)

```r
# barrido_tope.R -- justifica (criterio de orden, tope) con las dos baterias.
# Reglas: [[ ]] sobre datos de disco; ninguna escritura en el repositorio.
suppressPackageStartupMessages({library(dplyr); library(tibble)})
EV <- read.csv("50_documentacion/andamios/lab_motor_v9/a2_consultas_evaluacion.csv",
               stringsAsFactors = FALSE, encoding = "UTF-8")
norm <- function(u) sub("^.*/", "", sub("^/+", "", sub("^https?://[^/]+", "", u)))
acep <- setNames(lapply(seq_len(nrow(EV)), function(i)
  norm(trimws(strsplit(EV[["anclas_aceptadas"]][[i]], ";", fixed = TRUE)[[1L]]))), EV[["id"]])

CRITERIOS <- list(
  orden_documento   = function(d) order(d[["orden_documento"]]),
  n_locations       = function(d) order(-d[["n_locations"]], d[["orden_documento"]]),
  suma_balanced     = function(d) order(-d[["suma_balanced"]], d[["orden_documento"]]),
  max_balanced      = function(d) order(-d[["max_balanced"]], d[["orden_documento"]]),
  max_luego_suma    = function(d) order(-d[["max_balanced"]], -d[["suma_balanced"]], d[["orden_documento"]]),
  suma_luego_max    = function(d) order(-d[["suma_balanced"]], -d[["max_balanced"]], d[["orden_documento"]]),
  # densidad: peso por aparicion, penaliza el segmento largo que solo repite el termino
  media_balanced    = function(d) order(-(d[["suma_balanced"]] / pmax(d[["n_locations"]], 1)), d[["orden_documento"]])
)

evaluar_barrido <- function(csv_sub, etiqueta) {
  sub <- read.csv(csv_sub, stringsAsFactors = FALSE, encoding = "UTF-8")
  out <- list(); k <- 0L
  for (nm in names(CRITERIOS)) {
    f <- CRITERIOS[[nm]]
    for (tope in 1:9) {
      aciertos <- 0L
      for (idc in EV[["id"]]) {
        s <- sub[sub[["id"]] == idc & sub[["pagina_visible"]], ]
        if (nrow(s) == 0L) next
        vis <- character(0)
        for (rp in unique(s[["rango_pagina"]])) {
          d <- s[s[["rango_pagina"]] == rp, ]
          d <- d[f(d), ]
          vis <- c(vis, head(d[["url"]], tope))
        }
        if (any(acep[[idc]] %in% vis)) aciertos <- aciertos + 1L
      }
      k <- k + 1L
      out[[k]] <- tibble(bateria = etiqueta, criterio = nm, tope = tope, aciertos_de_10 = aciertos)
    }
  }
  bind_rows(out)
}

sp <- commandArgs(trailingOnly = TRUE)[[1L]]
a <- evaluar_barrido(file.path(sp, "antes_subresultados.csv"), "literal")
b <- evaluar_barrido(file.path(sp, "antes_canonico_subresultados.csv"), "canonica")
todo <- bind_rows(a, b)

cat("=== Aciertos de 10 por criterio y tope ===\n\n")
for (bat in c("literal", "canonica")) {
  cat("--- bateria:", bat, "---\n")
  m <- todo[todo[["bateria"]] == bat, ]
  w <- reshape(as.data.frame(m[, c("criterio","tope","aciertos_de_10")]),
               idvar = "criterio", timevar = "tope", direction = "wide")
  names(w) <- sub("aciertos_de_10.", "tope_", names(w))
  print(w, row.names = FALSE)
  cat("\n")
}
cat("--- suma de las dos baterias (maximo posible: 3 literal + 10 canonica = 13) ---\n")
s <- todo |> group_by(criterio, tope) |> summarise(total = sum(aciertos_de_10), .groups="drop") |>
  arrange(desc(total), tope)
w <- reshape(as.data.frame(s), idvar = "criterio", timevar = "tope", direction = "wide")
names(w) <- sub("total.", "tope_", names(w))
print(w, row.names = FALSE)
cat("\n--- mejores pares (total, luego tope mas bajo) ---\n")
print(as.data.frame(head(s, 12)), row.names = FALSE)
```

### A.5 — `contaminacion.R` (§5.6)

```r
# contaminacion.R -- §5.6: en cuantas normas aparece la cabecera del sitio de
# origen (BCN) DENTRO del texto, y donde exactamente. Solo lectura.
suppressPackageStartupMessages({library(stringr); library(dplyr); library(tibble)})
DATOS <- "40_salidas/datos/normas"
js <- sort(list.files(DATOS, pattern = "[.]json$", full.names = TRUE))

# Marcadores candidatos, buscados sobre TODO el texto de TODOS los segmentos.
# Se listan por separado para no confundir "la cabecera" con una de sus lineas.
MARCAS <- c(
  url_corta      = "Url Corta",
  bcn_dominio    = "bcn\\.cl",
  bcn_nombre     = "Biblioteca del Congreso Nacional",
  ultima_version = "Última Versión",
  ultima_modif   = "Ultima Modificación|Última Modificación",
  publicacion    = "Publicación:",
  promulgacion   = "Promulgación:",
  version_de     = "Versión:"
)

filas <- list(); k <- 0L
for (p in js) {
  j <- jsonlite::fromJSON(p, simplifyVector = FALSE)
  slug <- j[["slug"]]
  for (a in j[["articulos"]]) {
    k <- k + 1L
    tx <- a[["texto"]]
    fila <- tibble(slug = slug, id = a[["id"]], es_articulo = isTRUE(a[["es_articulo"]]),
                   es_preambulo = identical(a[["id"]], "preambulo"), n_car = nchar(tx))
    for (nm in names(MARCAS)) fila[[nm]] <- str_detect(tx, MARCAS[[nm]])
    filas[[k]] <- fila
  }
}
d <- bind_rows(filas)
cat("Segmentos examinados:", nrow(d), "en", length(js), "normas\n")
cat("Segmentos con id 'preambulo':", sum(d[["es_preambulo"]]), "\n\n")

cat("=== Presencia de cada marca, por ubicacion ===\n")
res <- lapply(names(MARCAS), function(nm) {
  tibble(marca = nm, patron = MARCAS[[nm]],
         normas_afectadas = n_distinct(d[["slug"]][d[[nm]]]),
         segmentos = sum(d[[nm]]),
         en_preambulo = sum(d[[nm]] & d[["es_preambulo"]]),
         fuera_del_preambulo = sum(d[[nm]] & !d[["es_preambulo"]]))
}) |> bind_rows()
print(as.data.frame(res), row.names = FALSE)

cat("\n=== CIFRA DE §5.6: normas con la cabecera BCN dentro del texto ===\n")
# La cabecera se identifica por su marca menos ambigua y siempre presente:
# 'Url Corta' junto al dominio bcn.cl. Ambas juntas, para no contar una fecha suelta.
d[["cabecera"]] <- d[["url_corta"]] & d[["bcn_dominio"]]
cont <- d[d[["cabecera"]], ]
cat("Normas contaminadas:", n_distinct(cont[["slug"]]), "de", length(js), "\n")
cat("Segmentos contaminados:", nrow(cont), "\n")
cat("  en el preambulo:", sum(cont[["es_preambulo"]]), "\n")
cat("  FUERA del preambulo:", sum(!cont[["es_preambulo"]]), "\n")
if (any(!cont[["es_preambulo"]])) {
  cat("\n  Segmentos contaminados que NO son el preambulo (cambian el alcance):\n")
  print(as.data.frame(cont[!cont[["es_preambulo"]], c("slug","id","es_articulo","n_car")]), row.names = FALSE)
}
cat("\nSlugs contaminados:\n")
for (s in sort(unique(cont[["slug"]]))) cat("  ", s, "\n")
cat("\nNormas SIN contaminacion:\n")
for (s in setdiff(sort(unique(d[["slug"]])), unique(cont[["slug"]]))) cat("  ", s, "\n")

# --- CONTROL POSITIVO --------------------------------------------------------
cat("\n--- CONTROL POSITIVO §5.6 ---\n")
cat("Se planta la cabecera en un texto limpio y se comprueba que el detector la marca,\n")
cat("y se comprueba que un texto sin ella no se marca.\n")
plantado <- "Artículo 1.- Texto cualquiera. Url Corta: https://bcn.cl/3lau7 y sigue."
limpio   <- "Artículo 1.- Texto cualquiera sin cabecera alguna."
det_p <- str_detect(plantado, MARCAS[["url_corta"]]) & str_detect(plantado, MARCAS[["bcn_dominio"]])
det_l <- str_detect(limpio,   MARCAS[["url_corta"]]) & str_detect(limpio,   MARCAS[["bcn_dominio"]])
cat("  texto con cabecera plantada -> detectado:", det_p, "(esperado TRUE)\n")
cat("  texto limpio                -> detectado:", det_l, "(esperado FALSE)\n")
cat("  VEREDICTO CONTROL 6:", if (det_p && !det_l) "DETECTA y no da falso positivo" else "INSTRUMENTO INVALIDO", "\n")

# --- El bloque literal, en cuatro normas -------------------------------------
cat("\n=== Bloque literal de cabecera, tal como esta en los datos ===\n")
muestra <- head(sort(unique(cont[["slug"]])), 4)
for (s in muestra) {
  p <- file.path(DATOS, paste0(s, ".json"))
  j <- jsonlite::fromJSON(p, simplifyVector = FALSE)
  for (a in j[["articulos"]]) {
    tx <- a[["texto"]]
    if (str_detect(tx, "Url Corta") && str_detect(tx, "bcn\\.cl")) {
      loc <- str_locate(tx, "Url Corta")[1,1]
      cat("\n--- ", s, " / segmento ", a[["id"]], " (posicion de 'Url Corta': ", loc, " de ", nchar(tx), ") ---\n", sep = "")
      cat("[", substr(tx, 1, min(nchar(tx), loc + 60)), "]\n", sep = "")
      break
    }
  }
}
write.csv(as.data.frame(d), file.path(commandArgs(trailingOnly=TRUE)[[1L]], "contaminacion_segmentos.csv"), row.names = FALSE)
```

### A.6 — `contraste.R` (§6.B2.3: razón de contraste WCAG 2.1)

```r
# contraste.R -- razon de contraste WCAG 2.1 de los pares color/fondo de estilo.css
# Formula: (L1+0.05)/(L2+0.05) con L = luminancia relativa (WCAG 2.x).
rel_lum <- function(hex) {
  h <- gsub("^#", "", hex)
  if (nchar(h) == 3L) h <- paste0(rep(strsplit(h, "")[[1L]], each = 2L), collapse = "")
  v <- strtoi(substring(h, c(1,3,5), c(2,4,6)), 16L) / 255
  f <- ifelse(v <= 0.03928, v / 12.92, ((v + 0.055) / 1.055)^2.4)
  0.2126*f[[1L]] + 0.7152*f[[2L]] + 0.0722*f[[3L]]
}
razon <- function(a, b) { l <- sort(c(rel_lum(a), rel_lum(b)), decreasing = TRUE); (l[[1L]]+0.05)/(l[[2L]]+0.05) }

# rem base del tema. NO son los 16 px del defecto de Bootstrap: el tema cosmo de
# este sitio declara --bs-root-font-size: 17px, verificado en
# 40_salidas/sitio/site_libs/bootstrap/bootstrap-*.min.css y confirmado con
# getComputedStyle en el navegador. Con 16 este anexo produce cifras 6% mas bajas
# que las publicadas en la seccion 8.1, que son las medidas.
REM_BASE <- 17
px <- function(rem) rem * REM_BASE

casos <- data.frame(
  selector = c(".ficha-norma dt", ".procedencia (sobre pagina)", ".procedencia (sobre ficha)",
               ".lista-relaciones .rel-por", ".lista-normas .titulo-norma",
               ".badge-tema", ".badge-tipo", ".marca-ocr", ".transcripcion-ocr pre",
               ".leer-contexto (hereda cuerpo)", "cuerpo Bootstrap (referencia)"),
  color = c("#6c757d", "#6c757d", "#6c757d", "#6c757d", "#495057",
            "#495057", "#212529", "#6b5200", "#3d3d3d", "#212529", "#212529"),
  fondo = c("#f8f9fa", "#ffffff", "#f8f9fa", "#ffffff", "#ffffff",
            "#f1f3f5", "#e9ecef", "#fffbe9", "#fffdf5", "#ffffff", "#ffffff"),
  rem   = c(0.82, 0.82, 0.82, 0.88, 1.00, 0.78, 0.78, 0.80, 0.87, 0.90, 1.00),
  versalita = c(TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE),
  stringsAsFactors = FALSE
)
casos[["px"]] <- round(px(casos[["rem"]]), 1)
casos[["contraste"]] <- round(mapply(razon, casos[["color"]], casos[["fondo"]]), 2)
# texto pequeno = < 18.66px normal (o < 24px negrita). Todo esto es texto pequeno.
casos[["exige_AA"]] <- 4.5
casos[["cumple_AA"]] <- casos[["contraste"]] >= 4.5
casos[["cumple_AAA"]] <- casos[["contraste"]] >= 7
cat("=== Contraste WCAG 2.1 de los pares de estilo.css (texto pequeno: AA exige 4.5:1) ===\n")
print(casos[, c("selector","color","fondo","rem","px","versalita","contraste","cumple_AA","cumple_AAA")], row.names = FALSE)
cat("\nPares que NO cumplen AA:", sum(!casos[["cumple_AA"]]), "de", nrow(casos), "\n")
if (any(!casos[["cumple_AA"]])) print(casos[!casos[["cumple_AA"]], c("selector","color","fondo","contraste")], row.names = FALSE)

cat("\n--- CONTROL POSITIVO del calculo de contraste (valores conocidos de la norma) ---\n")
ctrl <- data.frame(
  par = c("#000000 sobre #ffffff", "#ffffff sobre #ffffff", "#767676 sobre #ffffff", "#777777 sobre #ffffff"),
  esperado = c("21", "1", "4.54 (limite AA citado por WCAG)", "4.48 (justo bajo AA)"),
  obtenido = c(round(razon("#000000","#ffffff"),2), round(razon("#ffffff","#ffffff"),2),
               round(razon("#767676","#ffffff"),2), round(razon("#777777","#ffffff"),2)),
  stringsAsFactors = FALSE)
print(ctrl, row.names = FALSE)
cat("VEREDICTO CONTROL: ", if (abs(razon("#000000","#ffffff") - 21) < 0.01 && abs(razon("#ffffff","#ffffff") - 1) < 0.001) "el calculo reproduce los valores canonicos (21:1 y 1:1)" else "CALCULO INVALIDO", "\n")

cat("\n--- Colores propuestos, con su contraste (para elegir por medicion, no por gusto) ---\n")
cand <- data.frame(
  color = c("#6c757d","#5c636a","#565e64","#495057","#41464b","#343a40"),
  sobre_blanco = round(sapply(c("#6c757d","#5c636a","#565e64","#495057","#41464b","#343a40"), razon, "#ffffff"), 2),
  sobre_f8f9fa = round(sapply(c("#6c757d","#5c636a","#565e64","#495057","#41464b","#343a40"), razon, "#f8f9fa"), 2),
  sobre_f1f3f5 = round(sapply(c("#6c757d","#5c636a","#565e64","#495057","#41464b","#343a40"), razon, "#f1f3f5"), 2),
  stringsAsFactors = FALSE)
print(cand, row.names = FALSE)
```

### A.7 — `consulta_ui2.mjs` (el instrumento que produce la cifra de B1)

Es el que mide el «después». Se distingue de A.2 en una sola cosa, que es la que hace
comparable la cifra: **extrae del propio `busqueda.html` el bloque delimitado por
`// == INICIO BLOQUE DE ORDEN ==` y lo evalúa**, de modo que mide el código que se publica
y no una transcripción suya. Sin la ruta de ese archivo reproduce la lógica de
`pagefind-ui.js` v1.5.2, que es la línea base.

```js
// consulta_ui2.mjs -- instrumento de medicion del buscador, en modo LECTURA.
// Igual que consulta_ui.mjs, con una diferencia que es la que lo hace comparable:
// cuando se le pasa la ruta de busqueda.html, EXTRAE de ese archivo el bloque
// delimitado por "== INICIO BLOQUE DE ORDEN ==" / "== FIN BLOQUE DE ORDEN ==" y
// lo evalua. Asi el "despues" se mide con el codigo que se publica y no con una
// transcripcion suya, que es como una medicion deja de medir lo que dice medir.
//
// Sin esa ruta reproduce la logica de pagefind-ui.js v1.5.2 (la linea base),
// transcrita del bundle y citada en 20260908_medicion_correcciones_v1.md 1.1.
//
// Uso: node consulta_ui2.mjs <entrada.json> <salida.json> <basePath> <pagefind.js> <pageSize> [busqueda.html]
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";

const [, , entrada, salida, base, rutaJs, pageSizeArg, rutaHtml] = process.argv;
if (!entrada || !salida || !base || !rutaJs) { console.error("faltan argumentos"); process.exit(2); }
const PAGE_SIZE = pageSizeArg ? Number(pageSizeArg) : 8;

let ordenar, TOPE, modo;
if (rutaHtml) {
  const html = readFileSync(resolve(rutaHtml), "utf8");
  const m = html.match(/\/\/ == INICIO BLOQUE DE ORDEN ==[\s\S]*?\/\/ == FIN BLOQUE DE ORDEN ==/);
  if (!m) { console.error("no se encontro el bloque de orden en " + rutaHtml); process.exit(3); }
  const bloque = m[0];
  const f = new Function(bloque + "\nreturn { ordenarSubResultados, TOPE_SUB_RESULTADOS };");
  const api = f();
  ordenar = api.ordenarSubResultados;
  TOPE = api.TOPE_SUB_RESULTADOS;
  modo = "ui_del_repositorio(" + rutaHtml + ")";
} else {
  // Replica literal de pagefind-ui.js v1.5.2: elige los 3 con mas locations y los
  // devuelve en ORDEN DE DOCUMENTO (o.filter preserva el orden de entrada).
  TOPE = 3;
  ordenar = (subs) => {
    if (subs.length <= 3) return subs;
    const m = [...subs].sort((f, q) => q.locations.length - f.locations.length).slice(0, 3).map((f) => f.url);
    return subs.filter((f) => m.includes(f.url));
  };
  modo = "replica_pagefind_ui_1.5.2";
}

const visibles = (d) => {
  const sr = d.sub_results || [];
  const primeroEsPagina = sr?.[0]?.url === (d.meta?.url || d.url);
  const o = primeroEsPagina ? sr.slice(1) : [...sr];
  return ordenar(o).slice(0, TOPE).map((x) => x.url);
};

const consultas = JSON.parse(readFileSync(entrada, "utf8"));
const p = await import(pathToFileURL(resolve(rutaJs)).href);
await p.options({ basePath: base });
await p.init();

const suma = (xs, f) => xs.reduce((a, x) => a + f(x), 0);
const out = { base, page_size: PAGE_SIZE, tope_sub_resultados: TOPE, modo, consultas: [] };
for (const c of consultas) {
  const s = await p.search(c.consulta, c.filtros ? { filters: c.filtros } : undefined);
  const paginas = [];
  for (const [i, r] of s.results.entries()) {
    const d = await r.data();
    const vis = visibles(d);
    const sub = (d.sub_results || []).map((sr, j) => ({
      orden_documento: j + 1, title: sr.title, url: sr.url,
      anchor_id: sr.anchor ? sr.anchor.id : null,
      n_locations: sr.locations ? sr.locations.length : null,
      suma_balanced: sr.weighted_locations ? suma(sr.weighted_locations, (l) => l.balanced_score) : null,
      max_balanced: sr.weighted_locations && sr.weighted_locations.length ? Math.max(...sr.weighted_locations.map((l) => l.balanced_score)) : 0,
      visible_en_ui: vis.includes(sr.url)
    }));
    paginas.push({ rango_pagina: i + 1, url: d.url, score: r.score, pagina_visible: i < PAGE_SIZE,
                   n_sub_results: sub.length, n_visibles_ui: sub.filter((x) => x.visible_en_ui).length, sub_results: sub });
  }
  out.consultas.push({ id: c.id, consulta: c.consulta, n_paginas: s.results.length, paginas });
}
writeFileSync(salida, JSON.stringify(out, null, 1));
console.log(`modo: ${modo} | tope: ${TOPE} | pageSize: ${PAGE_SIZE} | consultas: ${out.consultas.length}`);
process.exit(0);
```

### A.8 — `comparar_b1.R` (§6.B1: antes y después consulta por consulta)

```r
# comparar_b1.R -- antes/despues consulta por consulta, con la POSICION en que el
# articulo correcto queda entre los mostrados (no solo si esta o no).
suppressPackageStartupMessages({library(dplyr); library(tibble)})
sp <- commandArgs(trailingOnly = TRUE)[[1L]]
EV <- read.csv("50_documentacion/andamios/lab_motor_v9/a2_consultas_evaluacion.csv",
               stringsAsFactors = FALSE, encoding = "UTF-8")
norm <- function(u) sub("^.*/", "", sub("^/+", "", sub("^https?://[^/]+", "", u)))

leer <- function(ruta) {
  r <- jsonlite::fromJSON(ruta, simplifyVector = FALSE)
  filas <- list(); k <- 0L
  for (cq in r[["consultas"]]) for (pg in cq[["paginas"]]) {
    vis <- Filter(function(s) isTRUE(s[["visible_en_ui"]]), pg[["sub_results"]])
    for (i in seq_along(vis)) {
      k <- k + 1L
      filas[[k]] <- tibble(id = cq[["id"]], rango_pagina = pg[["rango_pagina"]],
                           pagina_visible = isTRUE(pg[["pagina_visible"]]),
                           pos_mostrado = i, url = norm(vis[[i]][["url"]]),
                           anchor = if (is.null(vis[[i]][["anchor_id"]])) NA_character_ else vis[[i]][["anchor_id"]])
    }
  }
  if (k == 0L) return(tibble(id=character(0), rango_pagina=integer(0), pagina_visible=logical(0),
                             pos_mostrado=integer(0), url=character(0), anchor=character(0)))
  bind_rows(filas)
}
# OJO: pos_mostrado sale del ORDEN EN QUE EL INSTRUMENTO RECIBE los sub-resultados,
# que es el de documento. Para el "despues" hay que reordenar con la misma funcion
# que usa la pagina; se recalcula abajo desde el JSON completo.
leer_ordenado <- function(ruta, ordenar_por) {
  r <- jsonlite::fromJSON(ruta, simplifyVector = FALSE)
  filas <- list(); k <- 0L
  for (cq in r[["consultas"]]) for (pg in cq[["paginas"]]) {
    vis <- Filter(function(s) isTRUE(s[["visible_en_ui"]]), pg[["sub_results"]])
    if (!length(vis)) next
    if (ordenar_por == "relevancia") {
      pesos <- vapply(vis, function(s) as.numeric(s[["suma_balanced"]]), numeric(1))
      maxs  <- vapply(vis, function(s) as.numeric(s[["max_balanced"]]), numeric(1))
      vis <- vis[order(-pesos, -maxs, seq_along(vis))]
    }
    for (i in seq_along(vis)) {
      k <- k + 1L
      filas[[k]] <- tibble(id = cq[["id"]], rango_pagina = pg[["rango_pagina"]],
                           pagina_visible = isTRUE(pg[["pagina_visible"]]),
                           pos_mostrado = i, url = norm(vis[[i]][["url"]]))
    }
  }
  bind_rows(filas)
}

acep <- setNames(lapply(seq_len(nrow(EV)), function(i)
  norm(trimws(strsplit(EV[["anclas_aceptadas"]][[i]], ";", fixed=TRUE)[[1L]]))), EV[["id"]])
esp  <- setNames(lapply(seq_len(nrow(EV)), function(i) norm(EV[["ancla_esperada"]][[i]])), EV[["id"]])

resumir <- function(d, conj) {
  vapply(EV[["id"]], function(idc) {
    s <- d[d[["id"]] == idc & d[["pagina_visible"]], ]
    h <- s[s[["url"]] %in% conj[[idc]], ]
    if (nrow(h) == 0L) NA_integer_ else as.integer(min(h[["pos_mostrado"]]))
  }, integer(1))
}

a <- leer_ordenado(file.path(sp, "antes_ui.json"), "documento")
b <- leer_ordenado(file.path(sp, "despues_ui.json"), "relevancia")
tab <- tibble(
  id = EV[["id"]], consulta = EV[["consulta"]],
  ancla_esperada = vapply(EV[["id"]], function(i) esp[[i]], character(1)),
  antes_pos = resumir(a, esp), despues_pos = resumir(b, esp),
  antes_acep = resumir(a, acep), despues_acep = resumir(b, acep)
)
tab[["antes"]]   <- ifelse(is.na(tab[["antes_pos"]]),   "no", paste0("si (pos ", tab[["antes_pos"]], ")"))
tab[["despues"]] <- ifelse(is.na(tab[["despues_pos"]]), "no", paste0("si (pos ", tab[["despues_pos"]], ")"))
cat("=== B1: ancla ESPERADA visible en la interfaz, consulta por consulta ===\n")
print(as.data.frame(tab[, c("id","consulta","ancla_esperada","antes","despues")]), row.names = FALSE)
cat("\nANTES:  ", sum(!is.na(tab[["antes_pos"]])), "de 10\n")
cat("DESPUES:", sum(!is.na(tab[["despues_pos"]])), "de 10\n")
cat("\n(con anclas aceptadas: antes", sum(!is.na(tab[["antes_acep"]])), "de 10, despues",
    sum(!is.na(tab[["despues_acep"]])), "de 10)\n")
write.csv(as.data.frame(tab), file.path(sp, "b1_comparacion.csv"), row.names = FALSE)

# --- La bateria canonica, misma comparacion -----------------------------------
ac <- leer_ordenado(file.path(sp, "antes_canonico.json"), "documento")
bc <- leer_ordenado(file.path(sp, "despues_canonico.json"), "relevancia")
tc <- tibble(id = EV[["id"]], termino = EV[["termino_canonico"]],
             antes = resumir(ac, esp), despues = resumir(bc, esp))
cat("\n=== Bateria canonica: posicion del articulo correcto entre los mostrados ===\n")
print(as.data.frame(tc), row.names = FALSE)
cat("\nvisible antes:  ", sum(!is.na(tc[["antes"]])), "de 10 | posicion mediana:", median(tc[["antes"]], na.rm=TRUE), "\n")
cat("visible despues:", sum(!is.na(tc[["despues"]])), "de 10 | posicion mediana:", median(tc[["despues"]], na.rm=TRUE), "\n")
cat("aparece en PRIMER lugar: antes", sum(tc[["antes"]] == 1, na.rm=TRUE), "de 10 | despues",
    sum(tc[["despues"]] == 1, na.rm=TRUE), "de 10\n")
```
