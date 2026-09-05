# Panel adversarial del motor de búsqueda asistida (encargo v9)

**Fecha:** 2026-09-05 (encargo emitido el 2026-09-04, sesión 3; ejecución iniciada el 2026-09-05 a las 02:30 y reanudada a las 08:08 tras un corte de sesión de la API).
**Autor:** A5, encargo v9 (`50_documentacion/andamios/20260904_encargo_alcance_motor_busqueda_v1.md`, sección "A5" (Panel adversarial)).
**Papel:** atacar el diseño de las tres capas y las adopciones de §0bis. A5 no propone; donde una tarea pide una respuesta (tarea 4), la da como argumento y la rotula como tal.
**Restricción de método cumplida:** no se leyó ningún documento ni artefacto de A1 a A4 (`20260904_alcance_*`, `20260904_prototipo_vocabulario.R`, `20260904_medicion_corpus_semantica.R`, `vocabulario.json`, `a1_*` a `a4_*`). Los ataques se construyen desde §0, §0bis, las tareas de A1 a A4 y el repositorio.

## Instrumentos y convención de cita

Todo lo medido sale de cinco scripts R de laboratorio, todos con prefijo `a5_` en `50_documentacion/andamios/lab_motor_v9/`, corridos en esta ejecución con `Rscript <ruta>` y salida guardada con `tee` en el archivo `*_salida.txt` homónimo:

| Instrumento | Qué mide | Salida |
|---|---|---|
| `a5_dimensiones.R` | unidades, bytes, largos, vocabulario léxico, relaciones, campos de vigencia, versiones múltiples de artículos, `tipo_fuente`, piezas, cálculo del índice vectorial | `a5_dimensiones_salida.txt` |
| `a5_rotulos.R` | qué marca de procedencia viaja dentro del texto y cuál se queda en CSS o atributos; insignias declaradas vs usadas; posición del rótulo de pieza respecto del cuerpo indexado; qué verifica la compuerta de firma | `a5_rotulos_salida.txt` |
| `a5_verificacion_extra.R` | explica las 2 coincidencias del detector de rótulos y muestra qué texto expone un sub-resultado de Pagefind de una página OCR | `a5_verificacion_extra_salida.txt` |
| `a5_cobertura.R` sobre `a5_consultas_equipo.csv` | fracción de los términos de 38 consultas en lenguaje llano que aparece literalmente en el vocabulario de la capa 1 y en el corpus, con tres controles | `a5_cobertura_salida.txt`, `a5_cobertura_resultado.csv` |

Convención: cada cifra lleva al lado el instrumento y la sección de su salida, o el comando de shell literal. "Medido" es recuento programático de esta ejecución; "calculado" es aritmética explícita sobre cifras medidas; "hipótesis" es lo que no se midió y lleva su comando de verificación. Un cero sin control positivo en el mismo bloque no vale y no se escribe.

## 0. Cifras base recontadas en esta ejecución

| Cifra | Valor | Fuente |
|---|---|---|
| Normas | 25 | `a5_dimensiones.R` §1 |
| Segmentos con ancla (unidades de recuperación reales) | **806** = 682 artículos (`es_articulo == TRUE`) + 40 secciones de documentos con capa de texto + 84 páginas OCR | `a5_dimensiones.R` §1 |
| Páginas OCR sin revisar | 84, en 5 normas | `a5_dimensiones.R` §1; `grep -oh 'id="ocr-pagina-[0-9]*"' 40_salidas/sitio/*.html \| wc -l` → 84; por norma 16/1/10/48/9 |
| Texto | 1.430.646 caracteres; 1.461.161 bytes UTF-8; 370.858 bytes gzip | `a5_dimensiones.R` §2 |
| Texto OCR sin revisar | 224.276 caracteres, 15,7 % del texto | `a5_dimensiones.R` §2 |
| JSON de normas / catálogo / relaciones | 1.592.790 / 31.570 / 257.530 bytes | `a5_dimensiones.R` §2 |
| Relaciones | 552 = 2 sustitución + 2 grupo_acto + 46 remisión + 502 tema; 67 descartadas | `a5_dimensiones.R` §5 |
| Piezas interpretativas | 22, las 22 con `estado: borrador` y `validado_por: null` | `a5_dimensiones.R` §9 |
| Páginas HTML del sitio local / temáticas | 47 / 17 | `ls 40_salidas/sitio/*.html \| wc -l`; `ls 40_salidas/sitio/tema-*.html \| wc -l` |
| Páginas indexadas por Pagefind | 25 (versión 1.5.2) | `cat 40_salidas/sitio/pagefind/pagefind-entry.json` |
| Bundle Pagefind (index + fragment + filter) | 457.993 + 416.553 + 1.029 = 875.575 bytes (calculado sobre medidos) | `a5_dimensiones.R` §10 |
| Asignaciones de tema frágiles | 34 | `grep -c '^\| [A-Z][^\|]* \| \[' 50_documentacion/andamios/20260826_tabla_temas_fragiles_v1.md` |

Las cifras heredadas del encargo (25, 682, 552, 84 en 5, 22 y 0) se confirman. La que cambia de significado es 682: son los artículos, no las unidades con ancla, que son 806 (ver §7, P2).

---

## 1. Tarea 1: modos de falla del producto

### 1.1 El motor sugiere el artículo equivocado con confianza

**Evidencia medida de que ya ocurre, sin motor nuevo:**

- **Una norma rotulada como otra.** El slug `dfl_1_estatuto_asistentes_educacion` tiene por título real "FIJA TEXTO REFUNDIDO ... DE LA LEY Nº 19.070 QUE APROBO EL ESTATUTO DE LOS PROFESIONALES DE LA EDUCACION" (`grep -o '<title>[^<]*</title>' 40_salidas/sitio/dfl_1_estatuto_asistentes_educacion.html`). El sitio lo enlaza 35 veces desde 24 páginas (`grep -oh 'href="dfl_1_estatuto_asistentes_educacion\.html[^"]*"' 40_salidas/sitio/*.html | wc -l` → 35; `grep -l ... | wc -l` → 24). Cualquier capa que use el slug o el nombre canónico como señal (capa 1 lo hace por construcción) dirige "asistentes de la educación" a un documento que trata de docentes. La decisión está pendiente del equipo (pauta, Bloque 4), pero el motor se diseña sobre el dato que hay hoy.
- **Dos artículos con el mismo id y texto distinto, ambos "vigente".** `art-16-b` existe en `ley_20536_violencia_escolar` (2011, "Se entenderá por acoso escolar toda acción u omisión...") y en `ley_21809_convivencia_educativa` (2026, "Los establecimientos educacionales velarán por la prevención...") y las dos normas tienen `vigencia.estado == "vigente"` (`a5_dimensiones.R` §7). Hay 90 ids de artículo presentes en 2 o más leyes (`a5_dimensiones.R` §7). Una consulta "definición de acoso escolar" recibe dos respuestas con la misma insignia y ningún dato que las ordene en el tiempo.
- **La norma que regula la materia no está, pero el corpus la nombra.** "aula segura" aparece 22 veces y "21.128" 17 veces, todas en `dictamen_52_77_expulsion.json` (`cd 40_salidas/datos/normas && grep -io "aula segura" *.json | wc -l` → 22; `grep -il` → solo ese archivo). La Ley 21.128 no está en el corpus. Un motor léxico o semántico devuelve el dictamen con puntaje alto y el usuario lee "la norma sobre aula segura" donde solo hay un dictamen que la cita.
- **502 de las 552 relaciones (91 %) son "tema compartido"** derivadas de un diccionario de palabras clave, y 34 asignaciones de tema descansan en una sola aparición de una sola palabra (§0). Una capa que use `relaciones.json` como grafo de vecinos hereda ese ruido con la misma confianza que las 46 remisiones textuales.

**Veredicto:** obliga a cambiar el diseño en A3 (tarea 5: falta el caso adversarial "norma citada por el corpus pero ausente de él", que no es "fuera de dominio" ni "norma sustituida") y obliga a acotar en A2 (el conjunto de evaluación debe incluir al menos una consulta cuya respuesta correcta sea "no está en el corpus" y una con dos versiones del mismo artículo). Ver H-5 y H-3.

### 1.2 La normativa cambia y el índice no

**Evidencia medida de que ya ocurrió antes de construir nada:**

- La copia de la Ley General de Educación del corpus lleva la marca de la BCN "Última Modificación: 02-JUL-2010" (`grep -oi 'ltima modificaci[^"]\{0,60\}' 40_salidas/datos/normas/ley_20370_general_educacion.json`). Es anterior a la Ley 20.536 (2011), que insertó los artículos 16 A a 16 E, y a la Ley 21.809 (2026), que los reescribe. En el JSON de la LGE solo existe `art-16` (`grep -o '"id": "art-16[^"]*"' ...ley_20370_general_educacion.json` → `art-16`); "acoso escolar" aparece 1 vez en la LGE frente a 3 en la 20.536 (`grep -o 'acoso escolar' <json> | wc -l`); la LGE no contiene "convivencia educativa" y la 21.809 sí (`a5_dimensiones.R` §7); la 21.809 menciona los artículos 16 A (1), 16 B (1), 16 C (4), 16 D (5) y 16 E (3) (`grep -o 'art[ií]culo 16 [A-E]' ...ley_21809_convivencia_educativa.json | sort | uniq -c`).
- El mecanismo de incorporación detecta cambios de **archivo**, no de **derecho**: la huella del manifiesto es `md5_pdf:md5_ocr:origen_declarado` (`head -c 1500 40_salidas/datos/manifiesto_corpus.json`). Un PDF que no cambia deja "sin_cambio" aunque la ley haya sido modificada tres veces.
- No existe ningún campo de fecha de versión, entrada en vigor o derogación: las claves del objeto `vigencia` son `estado, sustituye_a, sustituido_por, fuente`, y ninguna clave de norma contiene `fecha`, `vigor` ni `derog` (`a5_dimensiones.R` §6; control positivo del mismo grep: sí existen `anio` y `vigencia`).

**Consecuencia para el motor:** cualquier índice (léxico, vectorial o de vocabulario) que se construya hoy indexa una LGE de 2010 como si fuera la vigente y la marca "vigente". El invariante 1 ("rastreable a un artículo con ancla estable") se cumple; el artículo al que se llega es el de hace 16 años.

**Veredicto:** obliga a cambiar el diseño en A2 (4ter) y es un problema de premisa que se reporta al orquestador: el corpus contiene versiones incompatibles del mismo articulado y ningún metadato lo declara (ver §7, P5, y H-3). No es tarea de este encargo corregir el corpus (prohibido escribir en `20_insumos/`), pero sí es tarea de A2 decir que la dimensión temporal no puede construirse sobre `anio` de publicación.

### 1.3 La consulta correcta se hace con las palabras equivocadas

Medido en la tarea 3 (§3): de 38 consultas en lenguaje llano, 16 (42 %) no comparten ningún término con el vocabulario de la capa 1 y solo 1 (3 %) está completamente cubierta por él; 14 términos del equipo no existen en el corpus ni como prefijo ("quitarle, echar, agrede, dura, autismo, grabar, castigo, pelea, cortarse, pelo, ciberbullying, whatsapp, dupla, arma"); "mochila" en singular no aparece nunca (0 exacto, 1 por prefijo) y "mochilas" sí (`a5_cobertura.R`, bloque de controles). El modo de falla no es "sin resultados": es "resultados por palabra suelta" (las 7 consultas cuyo objeto está fuera del corpus tienen al menos un término en el corpus: 7 de 7).

**Veredicto:** obliga a cambiar el diseño en A1 (ver §3 y H-2).

### 1.4 El equipo confía en la salida no validada como si estuviera validada

Cadena medida de por qué es el modo de falla más probable y no el más raro:

1. Hoy no hay ninguna pieza validada (22 de 22 en borrador, `a5_dimensiones.R` §9) y ninguna publicada (0 archivos del sitio con `badge-interpretacion`, 0 con la cadena "borrador": `grep -l badge-interpretacion 40_salidas/sitio/*.html | wc -l` → 0; `grep -il borrador ... | wc -l` → 0; control positivo: `badge-normativa` aparece en 192 lugares, `a5_rotulos.R` §4). La primera "orientación" que el equipo vea será, si la capa 3 en vivo se construye, salida de un modelo.
2. La marca de estado vive fuera del texto: 0 de 722 cuerpos de artículo nombran su propia norma (`a5_rotulos.R` §3; control positivo: 688 de 722 contienen la palabra "Artículo"); 0 de 84 bloques OCR llevan rótulo alguno dentro del `<pre>` (`a5_rotulos.R` §2 reporta 2 coincidencias, y `a5_verificacion_extra.R` §1 muestra que son la subcadena `ocr` dentro de "democrática"; control positivo: los 5 avisos `aviso-ocr` sí se detectan). Lo que se copia a un correo no dice de dónde salió ni en qué estado está.
3. La pauta le dice al equipo "nada de lo que ustedes no hayan revisado se da por bueno" (pauta, "Qué es esto"), pero el instrumento que van a usar a diario, el buscador, presenta el texto OCR y el verificado con la misma tipografía en la tarjeta de resultado: el sub-resultado de una página OCR muestra "Página 5" y 240 caracteres de texto corrido sin ninguna marca (`a5_verificacion_extra.R` §2). El filtro `texto:OCR sin revisar` existe (25 spans de filtro en `data-pagefind-filter`, 5 con ese valor: `grep -oh 'data-pagefind-filter="[^"]*"' 40_salidas/sitio/*.html | sort | uniq -c`), pero es un filtro, no una etiqueta del resultado (hipótesis sobre la UI de Pagefind 1.5.2: las tarjetas muestran título, sub-título y extracto, no los filtros; verificar con: abrir `40_salidas/sitio/index.html` servido localmente y buscar "identidad de género").

**Veredicto:** obliga a cambiar el diseño en A3 (H-1) y a acotar en A2 (H-7).

---

## 2. Tarea 2: ataque al invariante de firma

**Pregunta:** ¿existe un camino por el que contenido no validado termine indistinguible del validado a los ojos de quien lee? Se recorren cuatro, sobre el código y el sitio reales.

### 2.1 Camino 1: la página publicada de una pieza

Cómo se ve hoy una pieza publicada frente a un borrador, leído en `30_procesamiento/34_generar_paginas.R`:

- Un borrador **no existe** en el sitio: `cargar_piezas()` devuelve solo `publicables` (línea 726: `identical(p[["estado"]], "validada") && firmada(p)`), y `pagina_pieza()` solo se llama sobre ellas (línea 1213-1216). Confirmado en el HTML: 0 archivos con `badge-interpretacion` y 0 con "borrador" (comandos en §1.4).
- Una pieza publicada lleva la insignia `interpretación institucional` y la línea "Pieza validada por X el AAAA-MM-DD" en un `<div class="ficha-norma">` emitido en la línea 796, **antes** de abrir el contenedor `data-pagefind-body` de la línea 803 (`a5_rotulos.R` §5: badge en 796, cuerpo en 803, "badge fuera del cuerpo: TRUE"); entre la apertura y el cierre `:::` hay 0 líneas que inserten rótulo alguno (`a5_rotulos.R` §5 imprime el bloque literal, líneas 803 a 812).

Consecuencia: en la página, la firma es visible. En cualquier cosa que se derive del **cuerpo** (índice, extracto, copia), no.

### 2.2 Camino 2: el buscador

Pagefind indexa el cuerpo de la pieza (decisión E-c, comentario de líneas 770-784) y el cuerpo de cada norma, y genera un sub-resultado por cada `<h2 id>`. Hoy hay 913 encabezados con id en el sitio: 682 artículos, 84 páginas OCR, 69 secciones de documentos sin articulado y 78 de navegación (`a5_rotulos.R` §1); los 835 de las tres primeras clases están dentro del cuerpo indexado (calculado: 682 + 84 + 69; que los tres tipos se emiten dentro del `:::` con `data-pagefind-body` se lee en las líneas 310-323 y 331-342 del generador). Un sub-resultado de página OCR expone el texto reconocido sin marca (`a5_verificacion_extra.R` §2), distinguible del verificado solo porque su encabezado dice "Página N" en vez de "Artículo N". El día que se publique la primera FAQ, su sub-resultado dirá "Respuesta breve" y un extracto, con la palabra "validada" fuera del índice por diseño (línea 792-793: "La cabecera de firma queda FUERA del cuerpo indexado").

### 2.3 Camino 3: un JSON estático con el texto

`40_salidas/sitio/search.json` (índice de búsqueda de Quarto, 1.684.615 bytes) se genera aunque `_quarto.yml` declare `search: false` (línea 30) y viaja al despliegue porque el artefacto de Pages es `40_salidas/sitio` entero (`.github/workflows/publicar.yml` línea 131). Contiene 47 entradas, una por página, con el texto completo (`Rscript -e` sobre `search.json`: entradas 47; con `#ocr-pagina-` 0; con `#art-` 0; las 5 entradas de normas OCR sí contienen la marca "OCR" en su cabecera, control positivo 5). Aquí la marca está, pero una vez por página, al principio de 10 a 48 páginas de texto. Los JSON de `40_salidas/datos/normas/` sí llevan `origen_texto` por norma, no por segmento. Cualquier consumidor programático (un prototipo de capa 2, un cuaderno, una hoja de cálculo) que tome `articulos[].texto` obtiene 84 páginas de OCR con el mismo formato que los 682 artículos, y solo las distingue si mira el campo de la norma padre.

### 2.4 Camino 4: la salida en vivo copiada a un correo

Sobre el diseño propuesto (§0, capa 3 en vivo: salida "rotulada como no validada"): el rótulo, si es una insignia CSS o un encabezado de interfaz, no viaja con el texto seleccionado. La evidencia de que este proyecto ya construye así los rótulos está en 2.1 y 2.2: ninguna marca vive dentro del cuerpo. Un párrafo generado por el modelo, pegado en un correo institucional, es indistinguible de una FAQ firmada pegada en el mismo correo, y las dos son indistinguibles de un artículo de ley pegado desde la página de la norma (0 de 722 cuerpos de artículo nombran su norma). El invariante 2 dice "rotulando la salida"; el rótulo tiene que ser parte de la salida, no de la página.

### 2.5 Camino 5: la compuerta valida la forma de la firma, no la firma

`es_nombre_de_persona()` exige un escalar de texto con al menos dos palabras alfabéticas de dos o más letras, fuera de una lista negra (`a5_rotulos.R` §6 imprime la función). En todo el generador hay 0 líneas que mencionen `autoriz`, `blame`, `gpg`, `firma digital` o `hash` (control positivo del mismo grep: 15 líneas mencionan `validado_por`). Es decir: `validado_por: "María Pérez"` escrito por un script, por un agente o por cualquiera con acceso al repositorio publica la pieza. Es coherente con el contrato (el front matter "lo escribe A MANO el equipo", líneas 357-358) y la garantía real la da el proceso (quién commitea), no el código. Para este encargo importa porque A3 va a escribir "tres entradas completas y verificadas" y "una ruta de abordaje completa de ejemplo": si esos ejemplos llevan `estado: validada` y una firma con forma de nombre, la compuerta los publicaría en la primera corrida del pipeline.

### 2.6 Veredicto de la tarea 2

- Caminos 2, 3 y 4: **obliga a cambiar el diseño** (H-1): el rótulo de nivel y de estado debe ser texto plano dentro de cada bloque de salida y dentro de cada unidad indexada, y el arnés antialucinación de A3 (tarea 4) debe verificar la presencia del rótulo en el texto, no en el DOM.
- Camino 5: **obliga a acotar** (H-6): los ejemplos de A3 nacen `estado: borrador`, y la fase 2 (AUD, tarea 6) debe cruzar que ningún artefacto de A3 lleve `estado: validada`.
- Camino 1: **no derriba**: la página de pieza hoy es correcta.

---

## 3. Tarea 3: ataque a la premisa de la capa 1

### 3.1 Método declarado

No hay registro de consultas. A5 **construyó** 38 consultas en lenguaje llano (`a5_consultas_equipo.csv`, columnas `id, consulta, objetivo_declarado, origen`) a partir de la pauta de validación, las 12 FAQ en borrador y la tabla de temas frágiles, más 7 cuyo objeto está fuera del corpus a propósito. Son plausibles, no dato de uso, y llevan sesgo de autor (un agente redactando "como el equipo").

El vocabulario de la capa 1 se tomó **tal como lo define la tarea 1 de A1**: 17 títulos de páginas temáticas, 393 etiquetas de artículo distintas, 39 entradas del glosario y los nombres, números y títulos de las 25 normas (`a5_cobertura.R`, bloque "Vocabulario capa 1"). Ese vocabulario tiene 335 tipos alfabéticos distintos frente a 8.716 del corpus.

Cada consulta se reduce a sus términos de contenido (120 en total, tras quitar una lista corta de palabras funcionales declarada en el script), plegados a ASCII y minúsculas, y cada término se busca con borde de palabra en tres textos: **V** (vocabulario A1), **C** (corpus completo, cota superior aunque A1 metiera todas las palabras del corpus) y **P** (corpus, aceptando prefijo de 5 o más letras para tolerar flexión).

### 3.2 Resultado

```
consultas con TODOS sus términos en el vocabulario A1 (exacto):         1 de 38 (3%)
consultas con AL MENOS UN término en el vocabulario A1 (exacto):       22 de 38 (58%)
consultas con NINGÚN término en el vocabulario A1 (exacto):            16 de 38 (42%)
consultas con TODOS sus términos en el corpus (exacto o prefijo):      27 de 38 (71%)
consultas con NINGÚN término en el corpus (exacto o prefijo):           1 de 38 (3%)
términos totales 120: en vocab A1 25 (21%), en corpus exacto 103 (86%), en corpus prefijo 106 (88%)
consultas con objetivo declarado 'fuera del corpus': 7; con al menos un término en el corpus: 7 de 7
términos que faltan en el corpus: quitarle, echar, agrede, dura, autismo, grabar, castigo,
  pelea, cortarse, pelo, ciberbullying, whatsapp, dupla, arma
```
(fuente: `a5_cobertura_salida.txt`, bloque "Resumen"; detalle por consulta en `a5_cobertura_resultado.csv`, 38 filas).

### 3.3 Controles, en el mismo bloque

```
ctrl_pos_legal            (art. 16 B en lenguaje legal)  8 términos: V 6, C 8, P 8
ctrl_neg_inexistente      ("xyzzy plugh zorblat")        3 términos: V 0, C 0, P 0
ctrl_pos_termino_conocido ("mochilas")                   1 término:  V 1, C 1, P 1
ctrl_singular_vs_plural   ("mochila")                    1 término:  V 0, C 0, P 1
```
El instrumento encuentra lo que debe (8 de 8 en lenguaje legal, "mochilas") y no encuentra lo que no existe (0 de 3). El cuarto control es un hallazgo: el corpus dice "mochilas" y nunca "mochila".

Control de frase (la palabra está, la frase no): "dupla psicosocial" FALSE; "aula segura", "21.128", "hoja de vida", "carabineros", "drogas" TRUE; controles positivos "revisión de mochilas" TRUE e "interés superior del niño" TRUE. "PIE" (sigla del Programa de Integración Escolar) no aparece como palabra ni como "programa de integración"; "integración escolar" sí.

### 3.4 Lectura

- La premisa "vocabulario derivado del corpus" cubre **21 % de los términos** y **3 % de las consultas completas** del equipo. El 42 % de las consultas no toca el vocabulario ni por una palabra. El corpus entero, como cota superior, cubre el 86 % de los términos: la brecha entre 21 % y 86 % es lo que un vocabulario derivado **puede** ganar ampliándose; la brecha entre 86 % y 100 % (14 términos) es la que ninguna derivación del corpus cierra, porque las palabras no están ("echar", "castigo", "pelea", "pelo", "grabar", "ciberbullying", "whatsapp", "dupla").
- Tres de esos 14 son flexión ("arma" frente a "armas", hipótesis, verificar con: `grep -o '\barmas\b' 40_salidas/datos/normas/*.json | wc -l`; "mochila" frente a "mochilas", medido; "autismo" frente a "autista", medido: "espectro autista" existe). Un vocabulario por coincidencia exacta de prefijos de 1 a 3 caracteres (tarea 4 de A1) no resuelve flexión: "mochi" sí, "mochila " con espacio no.
- El criterio de éxito de A1 ("celu", "circular 482", "mochila", "xyzzy") está, por construcción, dentro del vocabulario en 3 de 4 casos; ninguna de las cuatro es una consulta como las 38.
- Los 7 casos fuera del corpus tienen todos al menos una palabra dentro: la capa 1 va a **sugerir algo** para "aula segura", "carabineros" o "drogas", y lo que sugiera será un dictamen o una ley que menciona la palabra de paso.

**Veredicto:** obliga a cambiar el diseño en A1 (H-2): el vocabulario no puede ser solo derivado; necesita una tabla de alias en lenguaje llano con procedencia por entrada (mismo estatuto que `TEMAS_PALABRAS_CLAVE`: declarada, auditable, sin firma pero con fuente), tolerancia a flexión, y un criterio de éxito con consultas llanas. La cifra que A1 debe reportar no es "cuántas entradas tiene el JSON" sino "qué fracción de estas 38 (u otras construidas con el mismo método declarado) resuelve al destino correcto".

---

## 4. Tarea 4: orden de construcción

**Pregunta:** si solo se pudiera construir una capa, ¿cuál entrega más valor por unidad de esfuerzo? Respuesta por argumento, con las cifras de este panel. Se rotula como argumento de A5, no como decisión (decide SINT).

| Capa | Brecha medida que ataca | Costo medido o calculado | Qué invariante compromete si se construye sola |
|---|---|---|---|
| 1 (vocabulario) tal como está definida | 21 % de los términos del equipo (§3) | un JSON estático; hoy 335 tipos | ninguno |
| 1 ampliada con alias curados y flexión | la brecha 21 % → 86 % es alcanzable con alias hacia palabras que sí están en el corpus; la de 86 % → 100 % con alias hacia temas | mismo JSON más una tabla curada con `fuente` por entrada | ninguno, si la tabla se declara como el diccionario de temas |
| 2 (semántica) | el residuo que ninguna vía léxica alcanza: 4 de 38 consultas sin ruta léxica ni por prefijo (q03 "echar", q17 "castigo pelea", q23 "cortarse pelo", q28 "ciberbullying whatsapp"; `a5_cobertura_resultado.csv`) = 11 % | índice de 806 × 384 int8 = 0,31 MB (calculado), más un modelo de embeddings en el navegador o un servicio; comparable al bundle Pagefind de 0,88 MB | invariante 4 si no excluye OCR; invariante 1 solo si cada resultado conserva ancla |
| 3 precalculada (rutas firmadas) | la que el equipo pidió ("cómo abordar") | requiere firmas: hoy 0 de 22 | ninguno, pero rinde 0 hasta la primera firma |
| 3 en vivo | la misma | Worker, clave, costo por consulta, arnés | invariantes 1, 2 y 4 hasta que H-1 esté resuelto (§2) |

**Argumento:** la capa 1 ampliada es la única que ataca la brecha más grande medida (42 % de consultas sin ninguna palabra en común con el vocabulario) con el costo más bajo, sin backend, sin modelo, sin firma, y con salida determinista y auditable. La capa 2 ataca un residuo medido del 11 % a un costo mayor y con dos invariantes en juego. La capa 3 precalculada rinde exactamente 0 mientras haya 0 piezas validadas (`a5_dimensiones.R` §9), y la capa 3 en vivo es la que más valor **percibido** tiene y la que hoy rompe el invariante de firma en cuanto alguien copia la respuesta (§2.4). Construir primero la capa 3 es construir primero el modo de falla 1.4.

Un corolario que no es capa: antes de cualquier índice, el corpus tiene que declarar la versión de cada texto (§1.2). Un motor mejor sobre una LGE de 2010 es un motor mejor para llegar a un artículo derogado.

**Veredicto:** obliga a acotar el orden en SINT (H-11): capa 1 ampliada primero; capa 2 solo si la línea base de A2 muestra que el residuo importa; capa 3 precalculada cuando exista la primera firma; capa 3 en vivo no en este ejercicio mientras H-1 no esté especificado.

---

## 5. Tarea 5: sobreingeniería, con nombre y apellido

### 5.1 El stack de cinco servicios de Cloudflare (D1, R2, Vectorize, AI Search, Workers AI)

Dimensiones medidas del problema que resolverían: 25 normas; 806 unidades; 1,59 MB de JSON; 1,43 millones de caracteres que comprimen a 0,37 MB; 552 aristas en 0,26 MB; un índice vectorial completo de 0,31 MB (384 dims, int8) a 3,30 MB (1024 dims, float32), calculado (`a5_dimensiones.R` §2, §5, §10). El bundle estático que ya sirve GitHub Pages para la búsqueda léxica pesa 0,88 MB. Con esas cifras: D1 (base de datos relacional) no tiene qué relacionar que no quepa en `catalogo.json` de 31 KB; R2 (almacenamiento de objetos) guardaría 25 PDF que GitHub Pages ya sirve (`34_generar_paginas.R` línea 1112-1113 los copia al sitio); Vectorize guardaría 806 vectores que pesan menos que la hoja de estilos de Pagefind; AI Search y Workers AI son servicios administrados para corpus que no caben en el navegador. Ninguno pasa la prueba de la tarea 8 de A4 ("qué problema resuelve que no se resuelva con un archivo estático"). §0bis ya lo rechazó; este panel lo confirma con cifras y añade: **el Worker mismo solo se justifica si la capa 3 en vivo se construye**, y §4 argumenta que no debe construirse primero. A4 debe presentar "no construir la capa 3 en vivo en este ejercicio" como opción con costo cero, no como omisión.

**Veredicto:** ya rechazado en §0bis; A5 no lo derriba porque no está en pie. Obliga a acotar en A4 (H-9): justificar incluso el Worker.

### 5.2 La descomposición de preguntas en subpreguntas

Universo sobre el que operaría: 17 temas, 25 normas, 806 unidades. Una "pregunta compleja" del equipo (q05 "apoderado agrede a un profesor", q35 "expulsión inmediata por portar un arma") toca dos o tres temas de 17, y las páginas temáticas ya cruzan las normas por tema. La descomposición multiplica las llamadas al modelo por el número de subpreguntas (costo lineal, lo mide A4) y no tiene hoy ninguna consulta de evaluación sobre la que demostrar ganancia (A2 construye las 10 recién en este encargo). §0bis la adopta "solo como opción con costo medido": eso ya es la forma acotada. Lo que A5 añade: sobre 806 unidades, la alternativa a descomponer es **recuperar más candidatos** (30 en vez de 10 cuesta 0 llamadas adicionales), y esa alternativa debe estar en la comparación de A3 (tarea 9) o la ganancia de descomponer está mal medida.

**Veredicto:** sobreingeniería mientras no haya medición; obliga a acotar en A3 tarea 9 (H-8): comparar contra "más candidatos sin descomponer".

### 5.3 El reranking

Un reranker reordena un pool de candidatos porque el pool es mucho mayor que lo que el usuario puede leer. Aquí el pool **total** es 806. La tarea 4bis de A2 pide medir "cuántos candidatos hay que recuperar antes de reordenar para que la respuesta correcta esté entre ellos"; si ese número resulta ser 10 o 20 sobre 806, la ganancia del reranker es la diferencia entre la posición en el top-3 con y sin él, y eso no está medido. Adoptar reranking "conservando los puntajes de cada motor" antes de la línea base es adoptar el costo (una llamada más por consulta, o un modelo más en el navegador) sin conocer el beneficio. Además, con las cifras de §3, el reordenamiento que más rinde es **determinista**: preferir texto verificado a OCR (84 unidades a demover), preferir vigente a sustituido (1 norma), preferir la unidad con la cita numérica exacta (408 de 806 segmentos, 50,6 %, contienen al menos una cita "ley N° x.xxx": `a5_dimensiones.R` §4). Eso es un orden por reglas sobre metadatos, no un reranker.

**Veredicto:** sobreingeniería hasta que A2 mida la ganancia; obliga a acotar (H-8).

---

## 6. Tarea 6: ataque a las adopciones de §0bis

Se impugnan cinco de las siete adopciones (mínimo exigido: tres).

### 6.1 Búsqueda híbrida (léxica + vectorial) con fusión de rangos

**A favor de la adopción, medido:** la mitad de las unidades (408 de 806) contienen citas numéricas de ley, hay 176 formas distintas de escribir "ley N° x.xxx" en el corpus (`a5_dimensiones.R` §4) y un embedding no distingue 21.801 de 21.809. La vía léxica tiene que existir y ganar ahí.

**En contra de la complejidad:** el residuo que la vía vectorial resolvería es 4 de 38 consultas (11 %) en las que ni la palabra ni su prefijo están en el corpus (§3.4). Antes de la vía vectorial, dos cosas más baratas cierran la mayor parte de la brecha: alias curados (que el vocabulario de la capa 1 ya necesita por H-2) y tolerancia a flexión (Pagefind 1.5.2 indexa con `languages: es` según `pagefind-entry.json`; que aplique stemming en español y por tanto ya resuelva "mochila" → "mochilas" es hipótesis, verificar con: buscar "mochila" en `40_salidas/sitio/index.html` servido localmente y contar resultados). La fusión de rangos (RRF o equivalente) añade un parámetro que nadie va a calibrar sobre 10 consultas.

**Veredicto:** no derriba la adopción (la vía léxica es obligatoria y la semántica tiene un residuo real), pero **obliga a acotar** (H-10): la primera construcción es léxica + alias + flexión, y la vía vectorial entra solo si la línea base de A2, corrida **después** de los alias, deja consultas sin resolver.

### 6.2 La capa experta como estructura de datos, con 0 piezas validadas hoy

La adopción es correcta como diseño (precalculable, firmable) y vacía como funcionalidad: 22 piezas, 22 borradores, 22 firmas `null` (`a5_dimensiones.R` §9). Tres consecuencias que el diseño debe absorber y que §0bis no nombra:

1. **Comportamiento con 0 entradas.** La consulta "informada por la capa experta antes de recuperar nada" (tarea 6 de A3) no tiene con qué informarse. A3 debe especificar la degradación: sin entradas validadas, la búsqueda es la de las capas 1 y 2 y la salida lo declara.
2. **Los ejemplos son borradores.** Las "tres entradas completas y verificadas" y la "ruta de abordaje de ejemplo" las escribe un agente. La compuerta valida la forma de la firma y nada más (§2.5). Nacen con `estado: borrador` o la primera corrida del pipeline las publica.
3. **La firma se dibuja como acto, no como campo.** "Verificar que el esquema pasa la compuerta" (A3, tareas 1 y 6) prueba que un YAML con forma de firma publica; no prueba que alguien haya validado. El esquema debe declarar de dónde sale la firma (el proceso: quién commitea en `20_insumos/`) y el documento de A3 debe decirlo en vez de dar la compuerta por garantía.

**Veredicto:** obliga a acotar (H-6).

### 6.3 Separación en cuatro niveles con insignias visuales

Dos ataques, uno a la premisa y otro al mecanismo.

**A la premisa** ("el sitio ya tiene cuatro insignias de fuente en `estilo.css`"): las clases declaradas son `badge-normativa`, `badge-orientacion`, `badge-evidencia` y `badge-tipo`, más `badge-interpretacion`, `badge-ocr`, `badge-sustituida` y cuatro `badge-rel-*` (`a5_rotulos.R` §4 las enumera desde el CSS). En el HTML, `badge-orientacion` aparece 0 veces, `badge-evidencia` 0, `badge-interpretacion` 0 (control positivo: `badge-normativa` 192, `badge-ocr` 51). En los datos, `tipo_fuente` tiene **un solo valor** en las 25 normas: `normativa` (`a5_dimensiones.R` §8). Los 4 dictámenes, las 3 circulares y las 3 resoluciones exentas llevan la misma insignia que las 9 leyes. El nivel 2 ("pronunciamiento oficial") **no existe hoy en los datos ni en el sitio**; existe en el CSS una clase con otro nombre y sin uso. Para que exista hace falta una regla de derivación (por `tipo`: dictamen → pronunciamiento; circular y rex → acto administrativo, que es una tercera cosa entre ley e interpretación y el diseño de cuatro niveles tiene que decidir dónde va), y esa regla es programática (invariante 5 satisfecho), pero A3 tiene que escribirla, no asumirla.

**Al mecanismo** (copiar y pegar): ninguna insignia viaja con el texto. Medido: 0 de 722 cuerpos de artículo nombran su norma; 0 de 84 bloques OCR llevan rótulo en el texto; el rótulo de pieza está fuera del cuerpo indexado (§2). Cuatro niveles separados por CSS son un nivel en el portapapeles. La separación se sostiene solo si cada bloque de salida empieza con su nivel y su estado en texto plano (por ejemplo `[Fuente primaria · Ley 20.536, art. 16 B · <URL>]`, `[Inferencia del modelo · no validada · 2026-09-05]`) y si la cita lleva nombre de norma, artículo y URL en la misma línea. Y el arnés de A3 (tarea 4) debe fallar si un bloque de salida no empieza con su marca.

**Veredicto:** obliga a cambiar el diseño (H-1 y H-4).

### 6.4 Vigencia y temporalidad como dimensión de consulta de primera clase

La adopción dice: "el corpus ya tiene `vigencia` y `sustituido_por` desde la sesión 1". Medido, lo que tiene: `anio` de publicación (nulo en 4 de 25 normas, las cuatro escaneadas: `a5_dimensiones.R` §6), un objeto `vigencia` con `estado, sustituye_a, sustituido_por, fuente`, **1** norma sustituida y 24 vigentes, y ningún campo de entrada en vigor, derogación ni versión consolidada. Con eso:

- "Qué rige hoy" devuelve 24 normas "vigentes", entre ellas una LGE consolidada al 02-JUL-2010 sin los artículos 16 A a 16 E (§1.2) y dos `art-16-b` con texto distinto (§1.1). Es decir, "qué rige hoy" **ya está mal respondido** por los datos, antes de cualquier filtro.
- "Qué regía en 2021" no es calculable: exige saber qué versión de cada norma estaba vigente ese año, y el corpus guarda una sola versión por norma sin fecha de versión. Un filtro `anio <= 2021` devuelve "publicado hasta 2021", que es otra pregunta, y la devuelve con la LGE de 2010 como si fuera la de 2021 (que, por la 20.536 de 2011, ya tenía los 16 A a 16 E).
- La sustitución que sí está declarada (dictamen 065 → 078) es una de 25 normas: la dimensión "de primera clase" tiene exactamente un caso de uso real hoy.

**Veredicto:** obliga a acotar (H-3): A2 (4ter) debe especificar la dimensión temporal como "publicado hasta el año X" más la marca de sustitución, declarar "vigente en el año X" como **no respondible** con los datos actuales, y reportar al orquestador que el corpus contiene versiones incompatibles del mismo articulado (LGE 2010, 20.536 de 2011, 21.809 de 2026) sin metadato que lo declare. La adopción sobrevive como dirección; muere como funcionalidad de este ciclo.

### 6.5 Reranking conservando puntajes, y descomposición como opción

Impugnados en §5.2 y §5.3. **Veredicto:** obliga a acotar (H-8).

### 6.6 Lo que no se impugna

"Estructurar el análisis de un caso en vez de entregar una conclusión" no se derriba: un análisis estructurado sin firma sigue siendo inferencia del modelo y cae bajo H-1 (rótulo en el texto), pero la estructura en sí es la forma que hace verificable la cita. Se deja en pie con esa condición.

---

## 7. Problemas detectados en premisas del encargo (se reportan, no se corrigen)

| # | Premisa | Qué se midió | Consecuencia |
|---|---|---|---|
| P1 | "el sitio ya tiene cuatro insignias de fuente en `estilo.css`" (§0bis) | 4 clases `badge-{normativa,orientacion,evidencia,tipo}` en el CSS; 2 de ellas con 0 usos en el HTML; `tipo_fuente` con un único valor en los 25 JSON | los cuatro niveles no existen en datos; hay que derivarlos (H-4) |
| P2 | "682 unidades" / "682 artículos" como tamaño del corpus | 806 segmentos con ancla; 682 son `es_articulo == TRUE`; 84 páginas OCR y 40 secciones también son unidades de recuperación y sub-resultados | todo dimensionamiento (peso del índice, k de candidatos) debe hacerse sobre 806 |
| P3 | "el corpus ya tiene `vigencia` y `sustituido_por`" (§0bis) | cierto, con 1 sustitución, 4 años nulos y ningún campo de versión ni derogación | la dimensión temporal no se sostiene (H-3) |
| P4 | el criterio de éxito de A1 ("celu", "circular 482", "mochila", "xyzzy") | 3 de 4 dentro del vocabulario por construcción; ninguna en lenguaje llano; "mochila" no existe en el corpus en singular | no mide la premisa que la tarea 3 de A5 refuta |
| P5 | (implícita) el corpus es la normativa vigente | la LGE es la versión BCN "Última Modificación: 02-JUL-2010", sin los artículos 16 A a 16 E que la Ley 20.536 insertó en 2011 y la 21.809 reescribió en 2026 | fuera del alcance del encargo (prohibido escribir en `20_insumos/`); se reporta como bloqueante de contenido para toda capa |
| P6 | "84 páginas en 5 documentos", "552 relaciones en 4 tipos", "22 piezas, 0 publicadas" | recontadas: 84 en 5; 552 en 4 tipos; 22 y 0 | confirmadas |
| P7 | "`20_insumos/curaduria/piezas/borradores/` (22 piezas ...; el glosario es `glosario.md`)" | 22 archivos `.md`, uno de ellos `glosario.md` | confirmada |

---

## 8. Hallazgos que obligan a cambiar el diseño

Numerados para la fase 2. Cada uno con veredicto, agente afectado y cambio concreto exigido.

**H-1 · obliga a cambiar el diseño · A3 (tareas 3, 4 y 7), con efecto en A1 y A2.** El rótulo de nivel (fuente primaria / pronunciamiento oficial / orientación experta / inferencia del modelo) y de estado (validada por X el día D / no validada / OCR sin revisar) debe ser **texto plano al inicio de cada bloque de salida** y viajar con toda copia, y cada cita debe llevar en la misma línea nombre de norma, artículo y URL con ancla. El arnés antialucinación (tarea 4) verifica la marca en el texto, no en el DOM. Evidencia: 0 de 722 artículos nombran su norma en el cuerpo; 0 de 84 bloques OCR llevan rótulo en el texto (control: 5 avisos detectados); el badge de pieza se emite en la línea 796, fuera del cuerpo indexado abierto en la 803 (`a5_rotulos.R` §2, §3, §5; `a5_verificacion_extra.R`).

**H-2 · obliga a cambiar el diseño · A1 (tareas 2, 4 y criterio de éxito).** El vocabulario no puede ser solo derivado del corpus: cubre el 21 % de los términos y el 3 % de las consultas del equipo, y el 42 % de las consultas no toca ninguna entrada. Cambio: (a) una tabla de alias en lenguaje llano hacia destinos del corpus, con `fuente` por entrada, declarada en un archivo auditable con el mismo estatuto que `TEMAS_PALABRAS_CLAVE` (sin firma, con procedencia); (b) tolerancia a flexión (singular/plural, verbo/sustantivo) en la coincidencia; (c) criterio de éxito reportado como fracción de consultas llanas resueltas al destino correcto, sobre `a5_consultas_equipo.csv` u otro conjunto construido con método declarado. Evidencia: `a5_cobertura_salida.txt` y `a5_cobertura_resultado.csv`.

**H-3 · obliga a acotar · A2 (tarea 4ter), y reporte al orquestador.** La dimensión temporal se especifica como "publicado hasta el año X" más marca de sustitución; "vigente en el año X" se declara **no respondible** con los datos (1 sustitución, 4 años nulos, 0 campos de versión, `art-16-b` duplicado con textos distintos ambos "vigente", LGE consolidada a 2010). El orquestador recibe como problema de premisa que el corpus contiene versiones incompatibles del mismo articulado sin metadato que lo declare (P5). Evidencia: `a5_dimensiones.R` §6 y §7; greps de §1.2.

**H-4 · obliga a cambiar el diseño · A3 (tarea 7).** Los niveles 1 y 2 no existen en los datos: `tipo_fuente` vale `normativa` en las 25 normas, y las insignias `badge-orientacion` y `badge-evidencia` tienen 0 usos. A3 debe escribir la regla de derivación del nivel por `tipo` (y decidir dónde caen circulares y resoluciones exentas, que son actos administrativos y no dictámenes) en vez de asumir que las insignias existentes ya separan los niveles. Evidencia: `a5_dimensiones.R` §8; `a5_rotulos.R` §4.

**H-5 · obliga a cambiar el diseño · A3 (tarea 5) y A2 (tarea 5).** Falta el caso adversarial "norma citada por el corpus pero ausente de él": "aula segura" / Ley 21.128 aparece 22 y 17 veces en el dictamen 52/77 y la ley no está. El motor debe responder "la norma que regula X no está en el corpus; el corpus la cita en Y", no devolver el dictamen como si fuera la norma. A2 debe incluir en las 10 consultas al menos una cuya respuesta correcta sea esa. Evidencia: greps de §1.1.

**H-6 · obliga a acotar · A3 (tareas 1, 2 y 6) y AUD (fase 2, tarea 6).** Las tres entradas y la ruta de ejemplo nacen con `estado: borrador` y `validado_por: null`, porque la compuerta valida solo la forma del nombre (0 líneas de autorización, `blame`, `gpg` o `hash` en el generador; control: 15 líneas con `validado_por`). A3 especifica además la degradación con 0 entradas validadas (hoy: 22 de 22 en borrador). AUD cruza que ningún artefacto de A3 lleve `estado: validada`. Evidencia: `a5_rotulos.R` §6; `a5_dimensiones.R` §9.

**H-7 · obliga a acotar · A2 (tarea 4quater) y A3 (tarea 3).** De las tres opciones para el OCR sin revisar (excluir, devolver marcado, devolver solo sin alternativa), en la capa 3 en vivo la única compatible con H-1 y con el invariante 4 es **excluir del contexto del modelo**: un texto OCR en el contexto sale citado como "cita textual" con la misma forma que un artículo verificado. En la capa 2, "devolver marcado" solo vale si la marca va en el texto del resultado (H-1). Evidencia: 84 de 806 unidades (10,4 %, calculado) y 15,7 % del texto son OCR; el sub-resultado de Pagefind de una página OCR no lleva marca (`a5_verificacion_extra.R` §2).

**H-8 · obliga a acotar · A2 (tarea 4bis) y A3 (tarea 9).** Reranking y descomposición no se adoptan sin ganancia medida sobre las 10 consultas de A2, y la comparación incluye la alternativa "recuperar más candidatos sin reordenar ni descomponer" (pool total: 806) y el orden determinista por metadatos (verificado antes que OCR, vigente antes que sustituido, cita numérica exacta primero: 408 de 806 segmentos contienen una cita de ley). Evidencia: `a5_dimensiones.R` §1 y §4.

**H-9 · obliga a acotar · A4 (tarea 8).** Con 1,59 MB de JSON, 0,37 MB de texto gzip, 552 aristas en 0,26 MB, un índice vectorial de 0,31 a 3,30 MB (calculado) y un bundle Pagefind de 0,88 MB ya servido estáticamente, ningún componente del stack pasa la prueba de la tarea 8; el Worker con Access solo se justifica si la capa 3 en vivo se construye, y A4 debe presentar "no construirla en este ejercicio" como opción con costo cero. Evidencia: `a5_dimensiones.R` §2, §5, §10.

**H-10 · obliga a acotar · A2 (tarea 4).** La búsqueda híbrida se construye en dos tiempos: primero léxica + alias (H-2) + flexión, y solo si la línea base corrida **después** de los alias deja consultas sin resolver, entra la vía vectorial. El residuo medido que la vía vectorial atacaría es 4 de 38 consultas (11 %); la vía léxica debe ganar en el 50,6 % de unidades con cita numérica. Evidencia: `a5_cobertura_resultado.csv`; `a5_dimensiones.R` §4.

**H-11 · obliga a acotar · SINT (orden de construcción).** Orden argumentado en §4: capa 1 ampliada (H-2) primero; capa 2 condicionada a H-10; capa 3 precalculada cuando exista la primera firma; capa 3 en vivo fuera de este ejercicio mientras H-1 no esté especificado y verificado. Antes de cualquier índice, resolver la versión del corpus (H-3, P5).

Declaración exigida por el criterio de éxito: hay hallazgos que obligan a cambiar el diseño (H-1, H-2, H-4, H-5). El panel corrió.

---

## 9. Residuos, estimaciones y errores propios

**No medido:** el comportamiento real de la UI de Pagefind (si muestra filtros en la tarjeta; si aplica stemming en español), declarado como hipótesis con su verificación en §1.4 y §6.1; la línea base de Pagefind sobre las 38 consultas (es tarea de A2 sobre sus 10; A5 no la duplica); "armas" en plural (hipótesis con comando en §3.4).

**Estimado o calculado:** el peso del índice vectorial (§0 y §5.1, aritmética explícita sobre 806 unidades); 835 sub-resultados indexables (suma de conteos medidos); 10,4 % de unidades OCR (84/806).

**Decidido no hacer:** consultar el índice Pagefind existente por programa (exige el runtime del navegador o Node; fuera del alcance de A5 y con riesgo de reindexar, que está prohibido); ampliar las 38 consultas con más autores (no hay otro autor disponible; se declara el sesgo).

**Errores propios durante la ejecución:** (1) el control positivo de `a5_cobertura.R` usó "mochila" en singular, que no existe en el corpus; el `stopifnot` abortó y el script se corrigió recalibrando el control con "mochilas" y conservando el singular como medición declarada (regla: ningún cero sin control calibrado; el control mismo estaba mal calibrado). (2) Siete objetivos de `a5_consultas_equipo.csv` se declararon "fuera del corpus" sin medir antes si la frase aparecía: cuatro aparecen de paso ("aula segura", "hoja de vida", "carabineros", "drogas"); se corrigieron las etiquetas con la medición y se dejó constancia (regla 4 del encargo: premisa de hecho sin comando). (3) El detector de rótulos de `a5_rotulos.R` contó 2 falsos positivos por la subcadena `ocr` en "democrática"; se verificó con `a5_verificacion_extra.R` y el cero real (0 de 84) se reporta con ese respaldo. (4) Un comando de shell encadenado con `&&` incluyó un `grep -c` y un `ls` sobre un archivo inexistente que devolvieron código 1 y cortaron el resto del bloque; se repitieron los comandos restantes por separado. (5) La ejecución se interrumpió por corte de sesión de la API y se reanudó a las 08:08 del 2026-09-05 verificando con `ls -la` y `wc -l` que los ocho artefactos `a5_*` estaban en disco (mtimes 02:40 a 02:43) y releyendo las tres salidas antes de continuar.
