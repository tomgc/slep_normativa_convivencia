# Rastreo de fuentes de los 5 términos pendientes del glosario — v1

Proyecto `slep_normativa_convivencia`, sesión 2, 2026-08-26. Producto de la tarea T5 del
encargo `50_documentacion/andamios/20260826_encargo_avance_maquina_v1.md`.

> **Qué es y qué no es.** Es una **propuesta** de fuente normativa para cada uno de los
> cinco términos que el glosario declara "pendiente de fuente". No incorpora ningún PDF
> al corpus, no escribe en `20_insumos/curaduria/` y no publica nada: la incorporación de
> una norma nueva es compuerta del titular. Donde no encontré definición legal, la fila
> dice **no hallada** y muestra qué se buscó: un glosario institucional prefiere un hueco
> declarado a una definición de diccionario.

## 1. Qué se buscó y dónde

Los cinco términos salen de la sección `## Pendientes de fuente` del borrador
`20_insumos/curaduria/piezas/borradores/glosario.md`. El marcador literal que el encargo
esperaba (`pendiente de fuente`, minúscula) **no existe** en el archivo: la marca real es
esa sección con su tabla de cinco filas, y el conteo coincide con la premisa.

Dos frentes de búsqueda:

1. **Dentro del corpus**, incluido el texto OCR sin revisar: se buscó la fórmula con que
   el derecho chileno introduce una definición legal (`se entenderá por X`,
   `se entiende por X`) aplicada a cada término. **Resultado: una sola coincidencia en
   las 25 normas**, la de `procedimiento justo y racional` en la circular 482.
2. **Fuera del corpus**, en fuentes oficiales, restringido a los dominios autorizados por
   el encargo (`bcn.cl`, `leychile.cl`, `supereduc.cl`,
   `diariooficial.interior.gob.cl`, `comunidadescolar.cl`). Nada se tomó de memoria: cada
   norma propuesta se abrió y se leyó su ficha en Ley Chile.

## 2. Tabla de propuestas

| Término | Norma propuesta | Artículo | Fuente oficial | ¿Ya en el corpus? | PDF propuesto |
|---|---|---|---|---|---|
| cancelación de matrícula | **DFL 2, de 1998, MINEDUC** (texto refundido de la Ley de Subvenciones) | art. 6 letra d) | [Ley Chile, idNorma 127911](https://www.bcn.cl/leychile/navegar?idNorma=127911) | **No** | **Sí** |
| debido proceso escolar | **Circular 482** (en el corpus) define `procedimiento justo y racional`; su base legal es el **DFL 2, de 1998**, art. 6 letra d) | `rex_482_reglamentos_b`, pág. 12 · DFL 2 art. 6 d) | [Ley Chile, idNorma 127911](https://www.bcn.cl/leychile/navegar?idNorma=127911) | Parcialmente: la circular sí, el DFL 2 no | **Sí**, el DFL 2 |
| dupla psicosocial | **Ley 21.109, de 2018** (Estatuto de los Asistentes de la Educación Pública): no define el término, pero define la función profesional que lo sustenta | art. 5 (categorías) y art. 6 (funciones de carácter psicosocial o psicopedagógico) | [Ley Chile, idNorma 1123513](https://www.bcn.cl/leychile/navegar?idNorma=1123513) | **No** | **Sí** |
| medida formativa | **no hallada** como definición legal | usada sin definir en Ley 21.809 art. 16 B y en la circular 482 (págs. 35, 37, 39 y 44) | — | La regulación sí, la definición no existe | No |
| protocolo de actuación | **no hallada** como definición legal | usado sin definir en la circular 482 (**12** segmentos, ver nota de criterio en §3) y en el artículo 46 letra f) de la Ley General de Educación, que la Ley 21.809 modifica | — | La regulación sí, la definición no existe | No |

## 3. Evidencia por término

### cancelación de matrícula — resuelto

El DFL 2 de 1998 del Ministerio de Educación (D.O. 28-11-1998), que fija el texto
refundido de la Ley de Subvenciones, regula la medida en su artículo 6 letra d). Texto
leído en la fuente oficial:

> "Las medidas de expulsión o cancelación de matrícula sólo podrán adoptarse mediante un
> procedimiento previo, racional y justo que deberá estar contemplado en el reglamento
> interno"

Es además la norma a la que remite el `dictamen_52_77_expulsion` del propio corpus
("el procedimiento de expulsión y cancelación de matrícula regulado en el literal d) del
artículo 6 de la Ley de Subvenciones"). **El corpus cita esa norma y no la contiene.**

### debido proceso escolar — resuelto, y ya está adentro

La única fórmula de definición que existe en las 25 normas del corpus para cualquiera de
estos cinco términos:

> `rex_482_reglamentos_b`, página 12: "Se entenderá por procedimiento justo y racional,
> aquel establecido en forma previa a la aplicación de una medida, que considere al
> menos, la comunicación al estudiante de la falta establecida en el Reglamento Interno
> por la cual se le pretende sancionar; respete la [...]"

Dos consecuencias, y las dos importan:

1. La sospecha que el equipo dejó anotada en el glosario (**"la circular 482 define
   varios de ellos"**) se confirma para este término y **solo** para este término.
2. **La definición no es citable todavía**: la circular 482 está en
   `ocr_pendiente_revision`. Revisar la página 12 de ese documento desbloquea esta
   entrada del glosario sin necesidad de incorporar ninguna norma nueva. Es el trabajo de
   menor costo y mayor rendimiento de esta lista.

### dupla psicosocial — resuelto como anclaje, no como definición

El glosario anticipaba que "probablemente no tiene definición normativa y hay que
declararlo como uso del equipo". **Es correcto que ninguna norma define el término**,
pero sí existe la norma que define la función: la Ley 21.109, de 2018, que establece el
Estatuto de los Asistentes de la Educación Pública, clasifica en su artículo 6 entre las
funciones profesionales las "de carácter psicosocial o psicopedagógico, desarrolladas por
profesionales de la salud y de las ciencias sociales".

La redacción honesta de la ficha sería, entonces: término de uso del equipo, sin
definición legal, cuyo sustento normativo es la función profesional del artículo 6 de la
Ley 21.109.

### medida formativa — no hallada

Se buscó `se entenderá por medida(s) formativa(s)` y `se entiende por` en las 25 normas,
incluido el texto OCR: cero coincidencias. La expresión se usa como categoría conocida y
nunca se define. Aparece en la Ley 21.809 artículo 16 B ("medidas formativas o
disciplinarias proporcionales con la falta") y en cuatro pasajes de la circular 482
("las medidas formativas, pedagógicas y/o de apoyo psicosocial aplicables a los
estudiantes que estén involucrados en los hechos que originan la activación del
protocolo"). Ninguno es una definición: son enumeraciones de aplicación.

### protocolo de actuación — no hallada

Mismo resultado. **Doce** segmentos de la circular 482 lo mencionan y regulan (qué debe
contener un protocolo, cuándo se activa), sin que ninguna norma diga qué es un protocolo de
actuación. Es un término definido por su contenido obligatorio, no por una fórmula.

> **Criterio del conteo (corregido el 2026-08-26).** La v1 de este documento decía «once
> segmentos». El criterio ahora es explícito: **segmentos del documento que contienen la
> expresión «protocolo de actuación» o «protocolos de actuación»**, y con ese criterio son
> **12**: páginas 2, 3, 4, 21, 22, 23, 24, 30, 35, 38, 39 y 44 (20 apariciones en total).
> Dos de esos segmentos no regulan nada —las páginas 2 y 3 son el índice y la 38 es una
> referencia bibliográfica a un documento externo de convivenciaescolar.cl—, pero excluir
> solo una de las tres habría sido arbitrario, así que se declara el criterio amplio y se
> nombran las excepciones. Recontado en este turno sobre
> `40_salidas/datos/normas/rex_482_reglamentos_b.json`.

> **Referencia corregida el 2026-08-26.** La v1 decía «la Ley 21.809 los menciona en el
> artículo 46 letra f)». **La Ley 21.809 no tiene un artículo 46**: sus 47 segmentos no
> incluyen `art-46` y el sitio no tiene esa ancla. El artículo 46 letra f) es de la **Ley
> General de Educación** (ley N° 20.370, cuyo texto refundido fijó el DFL N° 2, de 2009, del
> Ministerio de Educación), y es el que exige «contar con un reglamento interno que regule
> las relaciones entre el establecimiento y los distintos actores de la comunidad escolar».
> La Ley 21.809 lo **modifica**, en el numeral 16 de su artículo 1: «Reemplázase en el
> literal f) del inciso primero del artículo 46 el texto "políticas de prevención, medidas
> pedagógicas, protocolos de actuación y diversas conductas que constituyan falta a la buena
> convivencia escolar"». En el sitio ese texto vive en el segmento `art-44-bis` de la Ley
> 21.809, que es donde el segmentador cortó el articulado modificatorio.

## 4. Calibración del instrumento

El encargo pide tratar el método como sospechoso si los cinco términos salieran
"no hallada". No es el caso: **tres de cinco quedaron resueltos** (dos con norma
propuesta e identificada con año y artículo, uno con la definición ya dentro del corpus),
y los dos "no hallada" traen la búsqueda documentada y la razón por la que no hay
definición. El caso bueno esperable existe y se cumplió.

## 5. Hallazgo lateral, que excede a T5

Al rastrear la dupla psicosocial apareció algo que el equipo debe decidir: **la norma que
en el corpus tiene el slug `dfl_1_estatuto_asistentes_educacion` no es el Estatuto de los
Asistentes de la Educación.** Su propio título dice que fija el texto refundido de la
**ley N° 19.070, Estatuto de los Profesionales de la Educación**, es decir el estatuto
**docente**. El Estatuto de los Asistentes es la **Ley 21.109, de 2018**, y no está en el
corpus.

Esto se detalla, con su evidencia y su pregunta cerrada, en
`50_documentacion/andamios/20260826_preclasificacion_descartes_v1.md` §4, porque es la
misma pieza que explica 21 de los 88 descartes de remisión.

## 6. Compuerta

Ninguno de los tres PDF propuestos (DFL 2 de 1998; Ley 21.109 de 2018) se descargó, se
incorporó ni se procesó. Incorporar una norma es decisión del titular e implica nombre
canónico snake_case, `run_all()` y, si fuera multiarchivo, declaración de `grupos_acto`.
Este documento propone; no ejecuta.
