# Indagación previa al cierre — remisiones sin año, temas y sustitución del dictamen 65

> Andamio de **solo lectura**. Ningún script del pipeline se modificó, ningún
> JSON de `40_salidas/datos/` se regeneró y el sitio no cambió. Este archivo es
> el único producto de la sesión: existe para poner delante de una persona tres
> decisiones que hoy el pipeline toma solo y que no quedan a la vista en el sitio.
>
> **Fecha de la indagación:** 2026-08-26. **Estado del corpus consultado:** el de
> `40_salidas/datos/` tras el commit `15227da`.

---

## 0. Qué se midió y cómo

Los tres recuentos salen de un script de indagación que **copia literalmente**
las funciones del pipeline en vez de reimplementarlas: `patron_cita()`, la
ventana de año (`VENTANA_ANIO_CITA = 60`) y su regla de corte, de
`30_procesamiento/33_relaciones.R`; y `asignar_temas()` de
`30_procesamiento/32_segmentar_articulos.R`. Una reimplementación que
"se parece" mide otra cosa y el hallazgo no sería trasladable.

Dos diferencias declaradas respecto del pipeline, ambas deliberadas:

1. El derivador usa `regexpr()` (**primera** coincidencia por artículo); aquí se
   usa `gregexpr()` (**todas**). Para revisión humana interesa cada ocurrencia,
   no una representante.
2. El derivador solo guarda un artículo representante por par; aquí se conserva
   el artículo de cada ocurrencia.

Universo: 25 normas del catálogo (fuente: recuento programático sobre `40_salidas/datos/catalogo.json`, esta sesión).
En `relaciones.json` vigente hay 47 relaciones de tipo `remision` y 46 remisiones descartadas por año discordante (fuente: `40_salidas/datos/relaciones.json`, leído esta sesión).

---

## 1. Remisiones vigentes SIN año en la cita, hacia normas de número genérico

**Criterio de "genérico":** número de destino de 1 a 3 dígitos. Un número corto
no identifica una norma chilena (hay un decreto 215 por ministerio y por año), así
que cuando además la cita no trae año el derivador conserva la remisión por
ausencia de evidencia en contra. Esa es exactamente la población que una persona
tiene que mirar.

**Destinos genéricos en el corpus: 16 de 25 normas.**

`dfl_1_estatuto_asistentes_educacion`, `dfl_315_perdida_reconocimiento_oficial`, `dto_24_consejos_escolares`, `dto_215_uniforme_escolar`, `dto_453_estatuto_docente`, `dto_565_centros_padres_apoderados`, `circular_193_estudiantes_embarazadas`, `circular_586_tea`, `circular_812_identidad_genero`, `rex_181_celulares`, `rex_482_instrucciones_reglamentos_internos`, `rex_482_reglamentos_b`, `dictamen_52_77_expulsion`, `dictamen_065_revision_mochilas`, `dictamen_71_expulsion_cancelacion_matricula`, `dictamen_078_detectores_revision_mochilas`.

**Ocurrencias sin año encontradas: 83, en 5 pares distintos.** Los 12 destinos genéricos restantes no reciben ninguna cita sin año.

### 1.1 Resumen por par

| Origen | Destino | Ocurrencias | Segmentos | Citas literales distintas | Veredicto propuesto |
|---|---|---:|---:|---|---|
| `dto_453_estatuto_docente` | `dto_215_uniforme_escolar` | 74 | 42 | «Decreto 215» | **Falso positivo.** Homónimo: es otro decreto 215 |
| `rex_482_instrucciones_reglamentos_internos` | `rex_482_reglamentos_b` | 5 | 1 | «Resolución 482», «resolución exenta N° 482», «RESOLUCIÓN N° 482» | **Autorreferencia.** A y B son el mismo acto |
| `dictamen_52_77_expulsion` | `rex_482_instrucciones_reglamentos_internos` | 1 | 1 | «REX N° 482» | Correcta |
| `dictamen_52_77_expulsion` | `rex_482_reglamentos_b` | 1 | 1 | «REX N° 482» | Correcta (duplica la anterior: mismo acto) |
| `dictamen_078_detectores_revision_mochilas` | `dictamen_065_revision_mochilas` | 2 | 1 | «Dictamen N 65», «Dictamen N° 65» | Correcta |

### 1.2 `dto_453` → `dto_215`: 74 de las 83 ocurrencias son un homónimo

El texto refundido del Estatuto Docente trae las **notas marginales de
modificación** de la BCN, con la forma `Decreto 215, EDUCACIÓN Art. ÚNICO N° 1
D.O. 05.01.2012`. Ese *Decreto 215 de Educación, publicado el 05.01.2012*, es la
norma que **modificó** el Estatuto Docente. El `dto_215` del corpus es el
*Decreto 215 de 2009 sobre uniforme escolar*: mismo número, misma cartera,
distinto año y distinta materia.

Las 74 ocurrencias son la MISMA nota, repetida: en las 74 la cita va seguida de
coma (`Decreto 215,`), que es la forma de la nota marginal y no la de una
remisión en prosa. La ventana de 120 caracteres alcanza a mostrar `EDUCACIÓN` en
61 de ellas y la fecha `D.O. 05.01.2012` en 34; en el resto el texto de la
columna se intercala y la nota queda cortada (recuentos programáticos de esta
sesión). A lo que se suma el argumento material: el `dto_453` es de 1992 y el
decreto de uniforme escolar de 2009; un reglamento no cita una norma que aún no
existe.

La cita trae el año, pero en la forma `D.O. 05.01.2012`, que no es la que busca
el filtro (`\bde\s+((?:19|20)[0-9]{2})\b`). Por eso ninguna de estas 74
ocurrencias figura entre las descartadas: **`descartadas` hacia `dto_215` es 0**
(fuente: recuento sobre `relaciones.json`, esta sesión).

Efecto hoy visible en el sitio: la página del Estatuto Docente ofrece el decreto
de uniforme escolar como norma relacionada, con la explicación
`Cita «Decreto 215» en Encabezado y promulgación y en otros 41 fragmentos`. Es
una remisión que no existe.

### 1.3 `rex_482_instrucciones` → `rex_482_reglamentos_b`: el mismo acto citado dos veces

Los dos slugs son el **mismo** acto administrativo (REX 482 de 2018): A es la
resolución y B su circular anexa, escaneada. Comparten `tipo` y `numero`, de modo
que `patron_cita()` produce para ambos un patrón idéntico y no puede
distinguirlos. Consecuencias medidas:

- A remite a B con citas que son en realidad su propio encabezado
  (`RESOLUCIÓN N° 482 EXENTA, DE 22 DE JUNIO DE 2018`): el control
  `desde == hacia` de `33_relaciones.R` no lo atrapa porque los slugs difieren.
- Toda remisión de terceros al REX 482 se emite **dos veces**, una por slug. Se
  ve en `dictamen_52_77`, que produce la misma cita «REX N° 482» hacia los dos.

### 1.4 Las tres remisiones correctas

`dictamen_52_77` → REX 482 y `dictamen_078` → `dictamen_065` son remisiones
reales. En las dos el año aparece en el texto, pero fuera del patrón que el
filtro reconoce (`REX N° 482- 2018` con guion, `del año 2022` en vez de
`de 2022`), así que llegaron por la vía de "sin año" y no por coincidencia
verificada. El resultado es correcto; el camino no lo acredita.

### 1.5 Listado completo para revisión humana

Contexto: 60 caracteres a cada lado de la cita, espacios colapsados. El corchete
indica el segmento (`id` del artículo o página) donde ocurre.

#### `dto_453_estatuto_docente` → `dto_215_uniforme_escolar` — 74 ocurrencia(s)

1. `[preambulo]` cita «Decreto 215»
   > los departamentos de administración de educación municipal. Decreto 215, EDUCACIÓN Art. ÚNICO N° 1 D.O. 05.01.2012 Artículo 3° Est
2. `[preambulo]` cita «Decreto 215»
   > n fuerza de ley Nº 1, de 1996, del Ministerio de Educación; Decreto 215, b. La carrera de los profesionales de la educación que se
3. `[preambulo]` cita «Decreto 215»
   > 158, VI y VII con excepción del artículo 163 del TITULO IV. Decreto 215, EDUCACIÓN Art. ÚNICO N° 2 D.O. 05.01.2012 Artículo 7° Se
4. `[preambulo]` cita «Decreto 215»
   > nte. NOTA En el caso de la enseñanza media, estarán también Decreto 215, autorizados para ejercer la función docente quienes estén
5. `[preambulo]` cita «Decreto 215»
   > n fuerza de ley Nº 2, de 2009, del Ministerio de Educación. Decreto 215, EDUCACIÓN Art. ÚNICO N° 3 D.O. 05.01.2012 NOTA El numeral
6. `[preambulo]` cita «Decreto 215»
   > 3 D.O. 05.01.2012 NOTA El numeral 4 del Artículo Único del Decreto 215, Educación, publicado el 05.01.2012, modifica el artículo 9
7. `[preambulo]` cita «Decreto 215»
   > públicos a las buenas costumbres, homicidio o infanticidio. Decreto 215, EDUCACIÓN Art. ÚNICO N° 1 D.O. 05.01.2012 Artículo 11° En
8. `[preambulo]` cita «Decreto 215»
   > menos durante tres años en un establecimiento educacional. Decreto 215, Sin perjuicio de lo establecido en el inciso EDUCACIÓN ant
9. `[art-18-bis]` cita «Decreto 215»
   > y promover una adecuada convivencia en el establecimiento. Decreto 215, EDUCACIÓN b) En el ámbito financiero: asignar, administrar
10. `[art-18-bis]` cita «Decreto 215»
   > anterior a aquél en que se inicia el año escolar siguiente. Decreto 215, EDUCACIÓN Art. ÚNICO N° 1 D.O. 05.01.2012 Artículo 23° Se
11. `[art-42-a]` cita «Decreto 215»
   > n fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Decreto 215, EDUCACIÓN Art. ÚNICO N° 1 D.O. 05.01.2012 Artículo 61° Pa
12. `[art-42-a]` cita «Decreto 215»
   > bajo y sus leyes complementarias, y las de este Reglamento. Decreto 215, EDUCACIÓN Art. ÚNICO N° 1 D.O. 05.01.2012 Artículo 63° Lo
13. `[art-65]` cita «Decreto 215»
   > el artículo 13 de la Constitución Política de la República; Decreto 215, 2.- Haber cumplido con la Ley de Reclutamiento y EDUCACIÓN
14. `[art-66]` cita «Decreto 215»
   > ación de Educación Municipal o de la Corporación Municipal. Decreto 215, EDUCACIÓN Art. ÚNICO N° 9 D.O. 05.01.2012
15. `[art-67]` cita «Decreto 215»
   > tulo profesional o licenciatura de al menos ocho semestres. Decreto 215, EDUCACIÓN Art. ÚNICO N° 10 D.O. 05.01.2012
16. `[art-68]` cita «Decreto 215»
   > odo antes indicado, será materia de una declaración jurada. Decreto 215, EDUCACIÓN Art. ÚNICO N° 11 D.O. 05.01.2012 Artículo 69° L
17. `[art-68]` cita «Decreto 215»
   > a dotación docente previo concurso público de antecedentes. Decreto 215, Los contratados son aquellos que desempeñan labores EDUCAC
18. `[art-68]` cita «Decreto 215»
   > desempeñar funciones D.O. 05.01.2012 docentes directivas. Decreto 215, EDUCACIÓN Artículo 70° Funciones transitorias son aquella
19. `[art-71]` cita «Decreto 215»
   > ido con los requisitos exigidos en las bases de los mismos. Decreto 215, Los docentes a contrata podrán desempeñar funciones EDUCAC
20. `[art-72]` cita «Decreto 215»
   > s organismos de administración educacional de dicho sector. Decreto 215, EDUCACIÓN Art. ÚNICO N° 14 D.O. 05.01.2012
21. `[art-73]` cita «Decreto 215»
   > nal correspondiente, de acuerdo con lo dispuesto en la ley. Decreto 215, Dicha fijación se hará conforme al número de alumnos EDUCA
22. `[art-73]` cita «Decreto 215»
   > cacionales de la respectiva comuna. Artículo 75° Derogado. Decreto 215, EDUCACIÓN Art. ÚNICO N° 16 D.O. 05.01.2012
23. `[art-76]` cita «Decreto 215»
   > aciones que procedan por alguna de las siguientes causales: Decreto 215, 1.- Variación en el número de alumnos del sector EDUCACIÓN
24. `[art-77]` cita «Decreto 215»
   > n fuerza de ley Nº 2, de 1998, del Ministerio de Educación. Decreto 215, EDUCACIÓN Art. ÚNICO N° 18 D.O. 05.01.2012 Artículo 78° D
25. `[art-77]` cita «Decreto 215»
   > ÓN Art. ÚNICO N° 18 D.O. 05.01.2012 Artículo 78° Derogado. Decreto 215, EDUCACIÓN Art. ÚNICO N° 19 D.O. 05.01.2012 Artículo 79° D
26. `[art-77]` cita «Decreto 215»
   > ÓN Art. ÚNICO N° 19 D.O. 05.01.2012 Artículo 79° Derogado. Decreto 215, EDUCACIÓN Art. ÚNICO N° 19 D.O. 05.01.2012 3.- De los Co
27. `[art-77]` cita «Decreto 215»
   > CIÓN Art. ÚNICO N° 19 D.O. 05.01.2012 3.- De los Concursos Decreto 215, EDUCACIÓN Art. ÚNICO N° 20 D.O. 05.01.2012 a. Normas gene
28. `[art-77]` cita «Decreto 215»
   > CIÓN Art. ÚNICO N° 20 D.O. 05.01.2012 a. Normas generales Decreto 215, EDUCACIÓN Art. ÚNICO N° 20
29. `[art-80]` cita «Decreto 215»
   > ad de titular se hará por concurso público de antecedentes. Decreto 215, Los concursos públicos de antecedentes son aquellos EDUCAC
30. `[art-80-bis]` cita «Decreto 215»
   > encia, imparcialidad y objetividad del presente reglamento. Decreto 215, El cómputo de los plazos establecidos para la EDUCACIÓN co
31. `[art-80-bis]` cita «Decreto 215»
   > esidencia. b. Normas para proveer los cargos de Docentes. Decreto 215, EDUCACIÓN Art. ÚNICO N° 20 D.O. 05.01.2012
32. `[art-81]` cita «Decreto 215»
   > ad de titular se hará por concurso público de antecedentes. Decreto 215, EDUCACIÓN Art. ÚNICO N° 20 D.O. 05.01.2012
33. `[art-81-bis]` cita «Decreto 215»
   > nicipal respectivo o a la Corporación Municipal en su caso. Decreto 215, Los concursos deberán ser publicitados, a lo menos, en EDU
34. `[art-82]` cita «Decreto 215»
   > de los docentes estarán integradas, cada una de ellas, por: Decreto 215, EDUCACIÓN a) El Director del Departamento de Administració
35. `[art-83]` cita «Decreto 215»
   > orteo a que se refiere el literal c) del artículo anterior. Decreto 215, En el sorteo se determinará un miembro titular y uno EDUCA
36. `[art-84]` cita «Decreto 215»
   > tulaciones. Sus decisiones se adoptarán por simple mayoría. Decreto 215, En todo caso, deberán dejar constancia de sus EDUCACIÓN ac
37. `[art-85]` cita «Decreto 215»
   > erán ocupar los primeros lugares ponderados en el concurso. Decreto 215, El Alcalde, en un plazo máximo de cinco días contados EDUC
38. `[art-85]` cita «Decreto 215»
   > so anterior. c. Normas para proveer el cargo de Director. Decreto 215, EDUCACIÓN Art. ÚNICO N° 20
39. `[art-86]` cita «Decreto 215»
   > n fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Decreto 215, EDUCACIÓN Art. ÚNICO N° 20 D.O. 05.01.2012
40. `[art-86-bis]` cita «Decreto 215»
   > n Municipal en su caso, la administración de los concursos. Decreto 215, El Jefe del Departamento de Administración Municipal o EDU
41. `[art-87]` cita «Decreto 215»
   > rias deberán informar, a lo menos, las siguientes materias: Decreto 215, EDUCACIÓN . Plazo y forma de las postulaciones; Art. ÚNICO
42. `[art-87-bis]` cita «Decreto 215»
   > ladas en el artículo anterior, y a lo menos las siguientes: Decreto 215, EDUCACIÓN . Etapas del proceso; Art. ÚNICO N° 20 . Proposi
43. `[art-88]` cita «Decreto 215»
   > s de establecimientos educacionales estarán integradas por: Decreto 215, EDUCACIÓN a) El Jefe del Departamento de Administración de
44. `[art-88-bis]` cita «Decreto 215»
   > orteo a que se refiere el literal c) del artículo anterior. Decreto 215, El sorteo determinará un miembro titular y uno EDUCACIÓN r
45. `[art-89]` cita «Decreto 215»
   > reselección que contará con el apoyo de asesorías externas. Decreto 215, En el caso de los establecimientos educacionales EDUCACIÓN
46. `[art-89-bis]` cita «Decreto 215»
   > erando el promedio de la asistencia media del año anterior. Decreto 215, EDUCACIÓN Art. ÚNICO N° 20 D.O. 05.01.2012
47. `[art-90]` cita «Decreto 215»
   > eberán suscribir todos sus integrantes y el ministro de fe. Decreto 215, Los postulantes preseleccionados, de acuerdo a lo EDUCACIÓ
48. `[art-90-bis]` cita «Decreto 215»
   > selección, caso en el cual se realizará un nuevo concurso. Decreto 215, El resultado de este proceso se notificará a los EDUCACIÓN
49. `[art-91]` cita «Decreto 215»
   > n fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Decreto 215, Si el director designado renunciare dentro de los dos EDUC
50. `[art-91-bis]` cita «Decreto 215»
   > de los cuales obligatoriamente deberá llamarse a concurso. Decreto 215, EDUCACIÓN Art. ÚNICO N° 20 d. Normas para proveer el carg
51. `[art-91-bis]` cita «Decreto 215»
   > o D.O. 05.01.2012 de Administración de Educación Municipal. Decreto 215, EDUCACIÓN Art. ÚNICO N° 20 D.O. 05.01.2012
52. `[art-91-ter]` cita «Decreto 215»
   > lo establecido en el artículo 34 J del mismo cuerpo legal. Decreto 215, EDUCACIÓN Art. ÚNICO N° 20 D.O. 05.01.2012 PARRAFO III De
53. `[art-91-ter]` cita «Decreto 215»
   > l Decreto con Fuerza de Ley N° 1-3063, de 1980 de Interior. Decreto 215, Para estos efectos se entiende por remuneraciones lo EDUCA
54. `[art-91-ter]` cita «Decreto 215»
   > n fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Decreto 215, EDUCACIÓN Además, las Municipalidades podrán establecer Ar
55. `[art-91-ter]` cita «Decreto 215»
   > más de los establecimientos de la respectiva Municipalidad. Decreto 215, EDUCACIÓN Art. ÚNICO N° 21 b) 2 Remuneración Básica Mínim
56. `[art-91-ter]` cita «Decreto 215»
   > ° del Decreto con Fuerza de Ley N° 2, de 1989 de Educación. Decreto 215, EDUCACIÓN Art. ÚNICO N° 1 D.O. 05.01.2012 Artículo 105° S
57. `[art-91-ter]` cita «Decreto 215»
   > n fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Decreto 215, Este complemento no será considerado para el cálculo EDUCA
58. `[art-91-ter]` cita «Decreto 215»
   > n fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Decreto 215, Sólo podrán considerarse válidos para estos efectos EDUCAC
59. `[art-120]` cita «Decreto 215»
   > caso de otro personal de las unidades técnico-pedagógicas. Decreto 215, Para determinar el porcentaje, el Departamento de EDUCACIÓ
60. `[art-121]` cita «Decreto 215»
   > unidades y excelencia educativa a que se refiere dicha ley. Decreto 215, EDUCACIÓN Art. ÚNICO N° 23 D.O. 05.01.2012
61. `[art-122]` cita «Decreto 215»
   > iones mayores a las del director del mismo establecimiento. Decreto 215, EDUCACIÓN Art. ÚNICO N° 24 D.O. 05.01.2012 Artículo 123°
62. `[art-124]` cita «Decreto 215»
   > e se mantendrán si el nuevo empleo da derecho a percibirlas Decreto 215, EDUCACIÓN Art. ÚNICO N° 25 D.O. 05.01.2012 PARRAFO V Del
63. `[art-124]` cita «Decreto 215»
   > a regir a contar del próximo año escolar. INCISO SUPRIMIDO. Decreto 215, EDUCACIÓN Art. ÚNICO N° 26 D.O. 05.01.2012 Artículo 126°
64. `[art-129]` cita «Decreto 215»
   > n fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Decreto 215, EDUCACIÓN Art. ÚNICO N° 1 D.O. 05.01.2012 PARRAFO VIII De
65. `[art-144]` cita «Decreto 215»
   > pertenecer a ella, solamente, por las siguientes causales: Decreto 215, EDUCACIÓN a) Por renuncia voluntaria; Art. ÚNICO N° 27 b)
66. `[art-145]` cita «Decreto 215»
   > o de la Corporación Municipal, designado por el sostenedor. Decreto 215, Tratándose de los casos establecidos en las letras b) EDUC
67. `[art-145]` cita «Decreto 215»
   > evisional conceda la jubilación, pensión o renta vitalicia. Decreto 215, EDUCACIÓN Art. ÚNICO N° 29 D.O. 05.01.2012
68. `[art-147]` cita «Decreto 215»
   > gual nivel y especialidad de enseñanza, cesará en su cargo: Decreto 215, EDUCACIÓN a) En primer lugar, con quienes tengan sesenta o
69. `[art-147-bis]` cita «Decreto 215»
   > sujetos a lo prescrito en el artículo 74 del mismo decreto. Decreto 215, Aquellos profesionales que dejen de pertenecer a la EDUCAC
70. `[art-147-bis]` cita «Decreto 215»
   > de 1996, del Ministerio de Educación y de este Reglamento. Decreto 215, EDUCACIÓN Art. ÚNICO N° 1 D.O. 05.01.2012 PARRAFO II Norm
71. `[art-147-bis]` cita «Decreto 215»
   > eador. Ambas circunstancias deberán señalarse expresamente. Decreto 215, d. Duración del contrato, el que podrá ser de plazo fijo,
72. `[art-147-bis]` cita «Decreto 215»
   > n fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Decreto 215, No obstante, las normas que establecen la Renta Básica EDU
73. `[art-147-bis]` cita «Decreto 215»
   > lo 10° del D.F.L. N° 2 de 1989 del Ministerio de Educación. Decreto 215, EDUCACIÓN Art. ÚNICO N° 1 D.O. 05.01.2012 Artículo transi
74. `[art-147-bis]` cita «Decreto 215»
   > n fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Decreto 215, Asimismo, en lo que concierne al artículo 74, es EDUCACIÓN

#### `rex_482_instrucciones_reglamentos_internos` → `rex_482_reglamentos_b` — 5 ocurrencia(s)

1. `[documento]` cita «Resolución 482»
   > Resolución 482 EXENTA, EDUCACIÓN (2018) Resolución 482 EXENTA RESOLUCIÓN
2. `[documento]` cita «Resolución 482»
   > Resolución 482 EXENTA, EDUCACIÓN (2018) Resolución 482 EXENTA RESOLUCIÓN N° 482 EXENTA, DE 22 DE JUNIO DE 2018, QU
3. `[documento]` cita «RESOLUCIÓN N° 482»
   > olución 482 EXENTA, EDUCACIÓN (2018) Resolución 482 EXENTA RESOLUCIÓN N° 482 EXENTA, DE 22 DE JUNIO DE 2018, QUE APRUEBA CIRCULAR QUE IM
4. `[documento]` cita «RESOLUCIÓN N° 482»
   > Versión De : 07-MAY-2026 Url Corta: https://bcn.cl/kqtJKB RESOLUCIÓN N° 482 EXENTA, DE 22 DE JUNIO DE 2018, QUE APRUEBA CIRCULAR QUE IM
5. `[documento]` cita «resolución exenta N° 482»
   > 22 de junio de 2018, la Superintendencia de Educación dicta resolución exenta N° 482, que "Aprueba circular que imparte instrucciones sobre regl

#### `dictamen_52_77_expulsion` → `rex_482_instrucciones_reglamentos_internos` — 1 ocurrencia(s)

1. `[num-1]` cita «REX N° 482»
   > os Internos publicada por la Superintendencia de Educación (REX N° 482- 2018), en tanto “La calificación de las infracciones (por

#### `dictamen_52_77_expulsion` → `rex_482_reglamentos_b` — 1 ocurrencia(s)

1. `[num-1]` cita «REX N° 482»
   > os Internos publicada por la Superintendencia de Educación (REX N° 482- 2018), en tanto “La calificación de las infracciones (por

#### `dictamen_078_detectores_revision_mochilas` → `dictamen_065_revision_mochilas` — 2 ocurrencia(s)

1. `[ocr-pagina-001]` cita «Dictamen N° 65»
   > es al interior de establecimientos educacionales. Sustituye Dictamen N° 65, de la Superintendencia de Educación. ANTECEDENTES:
2. `[ocr-pagina-001]` cita «Dictamen N 65»
   > STABLECIMIENTOS EDUCACIONALES DEL PAIS A través del Dictamen N 65, del año 2022, este Servicio se pronunció sobre la proceden

---

## 2. Documento → temas asignados, con las palabras clave que los dispararon

El tema no viene marcado en los documentos: lo asigna `asignar_temas()` por
coincidencia contra el diccionario cerrado `TEMAS_PALABRAS_CLAVE` de
`10_utils/10_configuracion.R`, sobre el texto plegado a ASCII y en minúsculas,
con frontera de palabra al inicio de la clave. La tabla siguiente abre esa caja:
por cada tema publicado, **qué clave coincidió y cuántas veces**.

**Control de reconstrucción:** los temas reconstruidos aquí coinciden con los
publicados en los 25 JSON de norma, sin una sola discrepancia (0 discrepancias, recuento de esta sesión). La tabla describe el sitio real, no una aproximación.

**Cómo leerla.** Una asignación con `n = 1` en una sola clave descansa en una
única aparición de una palabra en todo el documento: es la más frágil y la que
conviene mirar primero. Van marcadas con ⚠.

| Documento | Tema asignado | Palabras clave que lo dispararon (nº de apariciones) | Frágil |
|---|---|---|---|
| `ley_19979_jornada_escolar_completa` | medidas disciplinarias | `expulsion` (1), `reglamento interno` (5), `sancion` (11) |  |
| `ley_19979_jornada_escolar_completa` | inclusión y no discriminación | `integracion` (2) |  |
| `ley_19979_jornada_escolar_completa` | participación de la comunidad | `consejo escolar` (8), `centro de padres` (2), `centro de alumnos` (1), `participacion` (2) |  |
| `ley_19979_jornada_escolar_completa` | jornada escolar | `jornada escolar completa` (14), `jornada escolar` (14) |  |
| `ley_19979_jornada_escolar_completa` | estatuto del personal | `asistentes de la educacion` (2), `profesionales de la educacion` (3) |  |
| `ley_19979_jornada_escolar_completa` | reconocimiento oficial | `reconocimiento oficial` (1) | ⚠ |
| `ley_20370_general_educacion` | convivencia escolar | `convivencia escolar` (1) | ⚠ |
| `ley_20370_general_educacion` | violencia y acoso escolar | `maltrato` (2) |  |
| `ley_20370_general_educacion` | medidas disciplinarias | `reglamento interno` (5), `sancion` (16) |  |
| `ley_20370_general_educacion` | inclusión y no discriminación | `inclusion` (2), `discriminacion arbitraria` (2), `necesidades educativas especiales` (5), `integracion` (4) |  |
| `ley_20370_general_educacion` | participación de la comunidad | `consejo escolar` (1), `centro de padres` (1), `participacion` (8) |  |
| `ley_20370_general_educacion` | embarazo y maternidad | `embarazo` (1), `maternidad` (1) |  |
| `ley_20370_general_educacion` | jornada escolar | `jornada escolar completa` (1), `jornada escolar` (1) |  |
| `ley_20370_general_educacion` | estatuto del personal | `asistentes de la educacion` (3), `profesionales de la educacion` (8) |  |
| `ley_20370_general_educacion` | reconocimiento oficial | `reconocimiento oficial` (27), `perdida del reconocimiento` (1) |  |
| `ley_20536_violencia_escolar` | convivencia escolar | `convivencia escolar` (10), `buena convivencia` (8), `encargado de convivencia` (1) |  |
| `ley_20536_violencia_escolar` | violencia y acoso escolar | `violencia escolar` (3), `acoso escolar` (2), `maltrato` (1), `agresion` (3) |  |
| `ley_20536_violencia_escolar` | medidas disciplinarias | `reglamento interno` (3), `sancion` (2) |  |
| `ley_20536_violencia_escolar` | participación de la comunidad | `consejo escolar` (2) |  |
| `ley_20536_violencia_escolar` | estatuto del personal | `asistentes de la educacion` (3) |  |
| `ley_20845_inclusion_escolar` | convivencia escolar | `convivencia escolar` (3), `buena convivencia` (1) |  |
| `ley_20845_inclusion_escolar` | medidas disciplinarias | `expulsion` (5), `cancelacion de matricula` (5), `reglamento interno` (10), `sancion` (10) |  |
| `ley_20845_inclusion_escolar` | inclusión y no discriminación | `inclusion` (7), `discriminacion arbitraria` (8), `necesidades educativas especiales` (3), `integracion` (5) |  |
| `ley_20845_inclusion_escolar` | derechos de la niñez | `interes superior del nino` (2) |  |
| `ley_20845_inclusion_escolar` | participación de la comunidad | `consejo escolar` (4), `participacion` (4) |  |
| `ley_20845_inclusion_escolar` | identidad de género | `persona trans` (1) | ⚠ |
| `ley_20845_inclusion_escolar` | formación ciudadana | `formacion ciudadana` (1) | ⚠ |
| `ley_20845_inclusion_escolar` | jornada escolar | `jornada escolar completa` (3), `jornada escolar` (3) |  |
| `ley_20845_inclusion_escolar` | estatuto del personal | `asistentes de la educacion` (1) | ⚠ |
| `ley_20845_inclusion_escolar` | reconocimiento oficial | `reconocimiento oficial` (7) |  |
| `ley_20911_formacion_ciudadana` | convivencia escolar | `convivencia escolar` (1) | ⚠ |
| `ley_20911_formacion_ciudadana` | medidas disciplinarias | `sancion` (1) | ⚠ |
| `ley_20911_formacion_ciudadana` | inclusión y no discriminación | `integracion` (1) | ⚠ |
| `ley_20911_formacion_ciudadana` | derechos de la niñez | `derechos del nino` (1) | ⚠ |
| `ley_20911_formacion_ciudadana` | participación de la comunidad | `consejo escolar` (1), `participacion` (2) |  |
| `ley_20911_formacion_ciudadana` | formación ciudadana | `formacion ciudadana` (8), `educacion civica` (1) |  |
| `ley_21430_garantias_ninez` | violencia y acoso escolar | `maltrato` (5), `bullying` (2) |  |
| `ley_21430_garantias_ninez` | medidas disciplinarias | `sancion` (15) |  |
| `ley_21430_garantias_ninez` | inclusión y no discriminación | `inclusion` (4), `discriminacion arbitraria` (9), `necesidades educativas especiales` (4), `integracion` (8) |  |
| `ley_21430_garantias_ninez` | derechos de la niñez | `interes superior del nino` (16), `garantias de la ninez` (1), `derechos del nino` (22), `ninos, ninas y adolescentes` (209) |  |
| `ley_21430_garantias_ninez` | participación de la comunidad | `participacion` (21) |  |
| `ley_21430_garantias_ninez` | identidad de género | `identidad de genero` (2) |  |
| `ley_21430_garantias_ninez` | embarazo y maternidad | `embarazada` (1), `embarazo` (6), `maternidad` (4), `paternidad` (4), `lactancia` (1) |  |
| `ley_21545_tea` | medidas disciplinarias | `sancion` (2) |  |
| `ley_21545_tea` | inclusión y no discriminación | `inclusion` (11), `discriminacion arbitraria` (2) |  |
| `ley_21545_tea` | derechos de la niñez | `ninos, ninas y adolescentes` (3) |  |
| `ley_21545_tea` | participación de la comunidad | `participacion` (7) |  |
| `ley_21545_tea` | trastorno del espectro autista | `espectro autista` (58) |  |
| `ley_21545_tea` | estatuto del personal | `asistentes de la educacion` (1), `profesionales de la educacion` (1) |  |
| `ley_21801_celulares` | convivencia escolar | `convivencia escolar` (2) |  |
| `ley_21801_celulares` | medidas disciplinarias | `sancion` (1) | ⚠ |
| `ley_21801_celulares` | inclusión y no discriminación | `necesidades educativas especiales` (1) | ⚠ |
| `ley_21801_celulares` | uso de dispositivos móviles | `dispositivos moviles` (19) |  |
| `ley_21809_convivencia_educativa` | convivencia escolar | `convivencia escolar` (5), `buena convivencia` (14) |  |
| `ley_21809_convivencia_educativa` | violencia y acoso escolar | `acoso escolar` (8), `maltrato` (1), `agresion` (5) |  |
| `ley_21809_convivencia_educativa` | medidas disciplinarias | `expulsion` (8), `cancelacion de matricula` (7), `medida disciplinaria` (1), `reglamento interno` (10), `sancion` (22) |  |
| `ley_21809_convivencia_educativa` | inclusión y no discriminación | `inclusion` (3), `discriminacion arbitraria` (7), `necesidades educativas especiales` (1), `integracion` (2) |  |
| `ley_21809_convivencia_educativa` | derechos de la niñez | `interes superior del nino` (1), `ninos, ninas y adolescentes` (6) |  |
| `ley_21809_convivencia_educativa` | participación de la comunidad | `consejo escolar` (15), `centro de padres` (1), `participacion` (11) |  |
| `ley_21809_convivencia_educativa` | trastorno del espectro autista | `espectro autista` (2) |  |
| `ley_21809_convivencia_educativa` | formación ciudadana | `formacion ciudadana` (1) | ⚠ |
| `ley_21809_convivencia_educativa` | jornada escolar | `jornada escolar completa` (2), `jornada escolar` (2) |  |
| `ley_21809_convivencia_educativa` | estatuto del personal | `asistentes de la educacion` (10), `profesionales de la educacion` (8) |  |
| `dfl_1_estatuto_asistentes_educacion` | convivencia escolar | `convivencia escolar` (2) |  |
| `dfl_1_estatuto_asistentes_educacion` | violencia y acoso escolar | `maltrato` (1) | ⚠ |
| `dfl_1_estatuto_asistentes_educacion` | medidas disciplinarias | `reglamento interno` (2), `sancion` (3) |  |
| `dfl_1_estatuto_asistentes_educacion` | inclusión y no discriminación | `inclusion` (3), `necesidades educativas especiales` (1), `integracion` (1) |  |
| `dfl_1_estatuto_asistentes_educacion` | participación de la comunidad | `participacion` (9) |  |
| `dfl_1_estatuto_asistentes_educacion` | jornada escolar | `jornada escolar completa` (1), `jornada escolar` (1) |  |
| `dfl_1_estatuto_asistentes_educacion` | estatuto del personal | `profesionales de la educacion` (156) |  |
| `dfl_1_estatuto_asistentes_educacion` | reconocimiento oficial | `reconocimiento oficial` (1) | ⚠ |
| `dfl_315_perdida_reconocimiento_oficial` | violencia y acoso escolar | `violencia escolar` (1), `maltrato` (1) |  |
| `dfl_315_perdida_reconocimiento_oficial` | medidas disciplinarias | `reglamento interno` (4), `sancion` (18) |  |
| `dfl_315_perdida_reconocimiento_oficial` | inclusión y no discriminación | `discriminacion arbitraria` (1), `integracion` (1) |  |
| `dfl_315_perdida_reconocimiento_oficial` | participación de la comunidad | `consejo escolar` (1) | ⚠ |
| `dfl_315_perdida_reconocimiento_oficial` | embarazo y maternidad | `embarazo` (1) | ⚠ |
| `dfl_315_perdida_reconocimiento_oficial` | jornada escolar | `jornada escolar completa` (1), `jornada escolar` (1) |  |
| `dfl_315_perdida_reconocimiento_oficial` | reconocimiento oficial | `reconocimiento oficial` (44), `perdida del reconocimiento` (3) |  |
| `dto_24_consejos_escolares` | medidas disciplinarias | `reglamento interno` (3) |  |
| `dto_24_consejos_escolares` | inclusión y no discriminación | `integracion` (2) |  |
| `dto_24_consejos_escolares` | participación de la comunidad | `consejo escolar` (25), `centro de padres` (1), `centro de alumnos` (1), `participacion` (1) |  |
| `dto_24_consejos_escolares` | reconocimiento oficial | `reconocimiento oficial` (1) | ⚠ |
| `dto_215_uniforme_escolar` | medidas disciplinarias | `reglamento interno` (1), `sancion` (2) |  |
| `dto_215_uniforme_escolar` | participación de la comunidad | `centro de padres` (3), `centro de alumnos` (3) |  |
| `dto_215_uniforme_escolar` | uniforme y presentación personal | `uniforme escolar` (15) |  |
| `dto_215_uniforme_escolar` | reconocimiento oficial | `reconocimiento oficial` (1) | ⚠ |
| `dto_215_uniforme_escolar` | seguridad escolar | `seguridad escolar` (3) |  |
| `dto_453_estatuto_docente` | medidas disciplinarias | `reglamento interno` (5), `sancion` (1) |  |
| `dto_453_estatuto_docente` | participación de la comunidad | `participacion` (8) |  |
| `dto_453_estatuto_docente` | embarazo y maternidad | `maternidad` (1) | ⚠ |
| `dto_453_estatuto_docente` | estatuto del personal | `estatuto docente` (1), `profesionales de la educacion` (90) |  |
| `dto_565_centros_padres_apoderados` | medidas disciplinarias | `reglamento interno` (15) |  |
| `dto_565_centros_padres_apoderados` | participación de la comunidad | `centro de padres` (18), `participacion` (5) |  |
| `circular_193_estudiantes_embarazadas` | convivencia escolar | `convivencia escolar` (1), `buena convivencia` (1) |  |
| `circular_193_estudiantes_embarazadas` | medidas disciplinarias | `reglamento interno` (4) |  |
| `circular_193_estudiantes_embarazadas` | inclusión y no discriminación | `inclusion` (1), `discriminacion arbitraria` (1), `necesidades educativas especiales` (1), `integracion` (1) |  |
| `circular_193_estudiantes_embarazadas` | derechos de la niñez | `derechos del nino` (2) |  |
| `circular_193_estudiantes_embarazadas` | participación de la comunidad | `participacion` (3) |  |
| `circular_193_estudiantes_embarazadas` | embarazo y maternidad | `embarazada` (43), `embarazo` (15), `maternidad` (16), `paternidad` (8), `lactancia` (2) |  |
| `circular_193_estudiantes_embarazadas` | uniforme y presentación personal | `uniforme escolar` (1) | ⚠ |
| `circular_193_estudiantes_embarazadas` | reconocimiento oficial | `reconocimiento oficial` (4), `perdida del reconocimiento` (1) |  |
| `circular_586_tea` | inclusión y no discriminación | `inclusion` (3) |  |
| `circular_586_tea` | trastorno del espectro autista | `espectro autista` (3) |  |
| `circular_586_tea` | reconocimiento oficial | `reconocimiento oficial` (1) | ⚠ |
| `circular_812_identidad_genero` | convivencia escolar | `convivencia escolar` (1), `buena convivencia` (2) |  |
| `circular_812_identidad_genero` | violencia y acoso escolar | `acoso escolar` (1), `maltrato` (2) |  |
| `circular_812_identidad_genero` | medidas disciplinarias | `reglamento interno` (3), `sancion` (1) |  |
| `circular_812_identidad_genero` | inclusión y no discriminación | `inclusion` (11), `discriminacion arbitraria` (10), `necesidades educativas especiales` (1), `integracion` (6) |  |
| `circular_812_identidad_genero` | derechos de la niñez | `interes superior del nino` (3), `derechos del nino` (5), `ninos, ninas y adolescentes` (2) |  |
| `circular_812_identidad_genero` | participación de la comunidad | `participacion` (2) |  |
| `circular_812_identidad_genero` | identidad de género | `identidad de genero` (21), `nombre social` (5), `estudiantes trans` (8), `estudiante trans` (2), `persona trans` (1), `ninas, ninos y estudiantes trans` (3) |  |
| `circular_812_identidad_genero` | embarazo y maternidad | `maternidad` (1), `lactancia` (1) |  |
| `circular_812_identidad_genero` | uniforme y presentación personal | `presentacion personal` (1) | ⚠ |
| `circular_812_identidad_genero` | estatuto del personal | `asistentes de la educacion` (1), `profesionales de la educacion` (1) |  |
| `circular_812_identidad_genero` | reconocimiento oficial | `reconocimiento oficial` (1) | ⚠ |
| `rex_181_celulares` | uso de dispositivos móviles | `dispositivos moviles` (3) |  |
| `rex_482_instrucciones_reglamentos_internos` | medidas disciplinarias | `reglamento interno` (1) | ⚠ |
| `rex_482_instrucciones_reglamentos_internos` | reconocimiento oficial | `reconocimiento oficial` (3) |  |
| `rex_482_reglamentos_b` | convivencia escolar | `convivencia escolar` (22), `buena convivencia` (16), `encargado de convivencia` (3) |  |
| `rex_482_reglamentos_b` | violencia y acoso escolar | `acoso escolar` (7), `maltrato` (13), `agresion` (8) |  |
| `rex_482_reglamentos_b` | medidas disciplinarias | `expulsion` (5), `cancelacion de matricula` (9), `medida disciplinaria` (1), `reglamento interno` (71), `sancion` (18) |  |
| `rex_482_reglamentos_b` | inclusión y no discriminación | `inclusion` (3), `discriminacion arbitraria` (9), `integracion` (1) |  |
| `rex_482_reglamentos_b` | derechos de la niñez | `interes superior del nino` (9), `derechos del nino` (9), `ninos, ninas y adolescentes` (5) |  |
| `rex_482_reglamentos_b` | participación de la comunidad | `consejo escolar` (8), `participacion` (23) |  |
| `rex_482_reglamentos_b` | identidad de género | `identidad de genero` (4), `estudiantes trans` (3) |  |
| `rex_482_reglamentos_b` | embarazo y maternidad | `embarazada` (8), `embarazo` (1), `maternidad` (2), `paternidad` (2) |  |
| `rex_482_reglamentos_b` | uso de dispositivos móviles | `celular` (2) |  |
| `rex_482_reglamentos_b` | uniforme y presentación personal | `uniforme escolar` (11), `presentacion personal` (1) |  |
| `rex_482_reglamentos_b` | jornada escolar | `jornada escolar completa` (1), `jornada escolar` (4) |  |
| `rex_482_reglamentos_b` | estatuto del personal | `estatuto docente` (1), `asistentes de la educacion` (5), `profesionales de la educacion` (2) |  |
| `rex_482_reglamentos_b` | reconocimiento oficial | `reconocimiento oficial` (57) |  |
| `rex_482_reglamentos_b` | seguridad escolar | `seguridad escolar` (6) |  |
| `dictamen_52_77_expulsion` | convivencia escolar | `convivencia escolar` (16) |  |
| `dictamen_52_77_expulsion` | violencia y acoso escolar | `agresion` (6) |  |
| `dictamen_52_77_expulsion` | medidas disciplinarias | `expulsion` (32), `cancelacion de matricula` (24), `reglamento interno` (8), `sancion` (21) |  |
| `dictamen_52_77_expulsion` | inclusión y no discriminación | `inclusion` (4), `discriminacion arbitraria` (7), `necesidades educativas especiales` (1), `integracion` (1) |  |
| `dictamen_52_77_expulsion` | participación de la comunidad | `participacion` (2) |  |
| `dictamen_52_77_expulsion` | identidad de género | `identidad de genero` (1) | ⚠ |
| `dictamen_52_77_expulsion` | embarazo y maternidad | `embarazo` (1), `maternidad` (2), `lactancia` (1) |  |
| `dictamen_52_77_expulsion` | estatuto del personal | `asistentes de la educacion` (3), `profesionales de la educacion` (1) |  |
| `dictamen_52_77_expulsion` | reconocimiento oficial | `reconocimiento oficial` (4) |  |
| `dictamen_065_revision_mochilas` | convivencia escolar | `convivencia escolar` (5), `buena convivencia` (5) |  |
| `dictamen_065_revision_mochilas` | violencia y acoso escolar | `maltrato` (2) |  |
| `dictamen_065_revision_mochilas` | medidas disciplinarias | `medida disciplinaria` (1) | ⚠ |
| `dictamen_065_revision_mochilas` | inclusión y no discriminación | `discriminacion arbitraria` (1) | ⚠ |
| `dictamen_065_revision_mochilas` | derechos de la niñez | `interes superior del nino` (2), `derechos del nino` (3), `ninos, ninas y adolescentes` (3) |  |
| `dictamen_065_revision_mochilas` | estatuto del personal | `asistentes de la educacion` (2) |  |
| `dictamen_065_revision_mochilas` | seguridad escolar | `detectores de metales` (6), `porticos detectores` (5) |  |
| `dictamen_065_revision_mochilas` | revisión de pertenencias | `revision de mochilas` (7), `mochilas y bolsos` (2), `revision de pertenencias` (1) |  |
| `dictamen_71_expulsion_cancelacion_matricula` | convivencia escolar | `convivencia escolar` (8), `buena convivencia` (1) |  |
| `dictamen_71_expulsion_cancelacion_matricula` | medidas disciplinarias | `expulsion` (23), `cancelacion de matricula` (19), `medida disciplinaria` (4), `reglamento interno` (3), `sancion` (23) |  |
| `dictamen_71_expulsion_cancelacion_matricula` | inclusión y no discriminación | `inclusion` (5), `discriminacion arbitraria` (4), `necesidades educativas especiales` (1), `integracion` (2) |  |
| `dictamen_71_expulsion_cancelacion_matricula` | derechos de la niñez | `interes superior del nino` (1), `garantias de la ninez` (4), `ninos, ninas y adolescentes` (5) |  |
| `dictamen_71_expulsion_cancelacion_matricula` | participación de la comunidad | `participacion` (2) |  |
| `dictamen_71_expulsion_cancelacion_matricula` | embarazo y maternidad | `embarazo` (1) | ⚠ |
| `dictamen_71_expulsion_cancelacion_matricula` | formación ciudadana | `formacion ciudadana` (1) | ⚠ |
| `dictamen_71_expulsion_cancelacion_matricula` | reconocimiento oficial | `reconocimiento oficial` (1) | ⚠ |
| `dictamen_078_detectores_revision_mochilas` | convivencia escolar | `convivencia escolar` (1) | ⚠ |
| `dictamen_078_detectores_revision_mochilas` | violencia y acoso escolar | `acoso escolar` (1), `maltrato` (1) |  |
| `dictamen_078_detectores_revision_mochilas` | inclusión y no discriminación | `discriminacion arbitraria` (1) | ⚠ |
| `dictamen_078_detectores_revision_mochilas` | derechos de la niñez | `interes superior del nino` (3), `derechos del nino` (1), `ninos, ninas y adolescentes` (8) |  |
| `dictamen_078_detectores_revision_mochilas` | participación de la comunidad | `consejo escolar` (3), `participacion` (4) |  |
| `dictamen_078_detectores_revision_mochilas` | identidad de género | `identidad de genero` (1) | ⚠ |
| `dictamen_078_detectores_revision_mochilas` | estatuto del personal | `asistentes de la educacion` (2) |  |
| `dictamen_078_detectores_revision_mochilas` | reconocimiento oficial | `reconocimiento oficial` (1) | ⚠ |
| `dictamen_078_detectores_revision_mochilas` | seguridad escolar | `detectores de metales` (2), `porticos detectores` (2), `seguridad escolar` (1) |  |
| `dictamen_078_detectores_revision_mochilas` | revisión de pertenencias | `revision de mochilas` (3), `mochilas y bolsos` (1), `efectos personales` (2), `revision de pertenencias` (1) |  |

**Asignaciones frágiles (una sola aparición de una sola clave): 34.**

| Documento | Tema | Única clave, única aparición |
|---|---|---|
| `ley_19979_jornada_escolar_completa` | reconocimiento oficial | `reconocimiento oficial` |
| `ley_20370_general_educacion` | convivencia escolar | `convivencia escolar` |
| `ley_20845_inclusion_escolar` | identidad de género | `persona trans` |
| `ley_20845_inclusion_escolar` | formación ciudadana | `formacion ciudadana` |
| `ley_20845_inclusion_escolar` | estatuto del personal | `asistentes de la educacion` |
| `ley_20911_formacion_ciudadana` | convivencia escolar | `convivencia escolar` |
| `ley_20911_formacion_ciudadana` | medidas disciplinarias | `sancion` |
| `ley_20911_formacion_ciudadana` | inclusión y no discriminación | `integracion` |
| `ley_20911_formacion_ciudadana` | derechos de la niñez | `derechos del nino` |
| `ley_21801_celulares` | medidas disciplinarias | `sancion` |
| `ley_21801_celulares` | inclusión y no discriminación | `necesidades educativas especiales` |
| `ley_21809_convivencia_educativa` | formación ciudadana | `formacion ciudadana` |
| `dfl_1_estatuto_asistentes_educacion` | violencia y acoso escolar | `maltrato` |
| `dfl_1_estatuto_asistentes_educacion` | reconocimiento oficial | `reconocimiento oficial` |
| `dfl_315_perdida_reconocimiento_oficial` | participación de la comunidad | `consejo escolar` |
| `dfl_315_perdida_reconocimiento_oficial` | embarazo y maternidad | `embarazo` |
| `dto_24_consejos_escolares` | reconocimiento oficial | `reconocimiento oficial` |
| `dto_215_uniforme_escolar` | reconocimiento oficial | `reconocimiento oficial` |
| `dto_453_estatuto_docente` | embarazo y maternidad | `maternidad` |
| `circular_193_estudiantes_embarazadas` | uniforme y presentación personal | `uniforme escolar` |
| `circular_586_tea` | reconocimiento oficial | `reconocimiento oficial` |
| `circular_812_identidad_genero` | uniforme y presentación personal | `presentacion personal` |
| `circular_812_identidad_genero` | reconocimiento oficial | `reconocimiento oficial` |
| `rex_482_instrucciones_reglamentos_internos` | medidas disciplinarias | `reglamento interno` |
| `dictamen_52_77_expulsion` | identidad de género | `identidad de genero` |
| `dictamen_065_revision_mochilas` | medidas disciplinarias | `medida disciplinaria` |
| `dictamen_065_revision_mochilas` | inclusión y no discriminación | `discriminacion arbitraria` |
| `dictamen_71_expulsion_cancelacion_matricula` | embarazo y maternidad | `embarazo` |
| `dictamen_71_expulsion_cancelacion_matricula` | formación ciudadana | `formacion ciudadana` |
| `dictamen_71_expulsion_cancelacion_matricula` | reconocimiento oficial | `reconocimiento oficial` |
| `dictamen_078_detectores_revision_mochilas` | convivencia escolar | `convivencia escolar` |
| `dictamen_078_detectores_revision_mochilas` | inclusión y no discriminación | `discriminacion arbitraria` |
| `dictamen_078_detectores_revision_mochilas` | identidad de género | `identidad de genero` |
| `dictamen_078_detectores_revision_mochilas` | reconocimiento oficial | `reconocimiento oficial` |

---

## 3. La declaración de sustitución del dictamen 65 en el texto del 078

**Sí existe, y está en la página 1.** Aparece dos veces, con dos redacciones y
dos grafías del número:

**Página 1, `ocr-pagina-001`** — término detectado: `Dictamen N° 65`

> tir de á Ley N° 21.809, Y la potestad de revisar mochilas, bolsos u otros efectos personales al interior de establecimientos educacionales. Sustituye Dictamen N° 65, de la Superintendencia de Educación. ANTECEDENTES: Resolución Exenta Ir 413, del 9 de junio de 2017, que aprueba instrucciones que reglamentan la potestad interpretativa de la Su

**Página 1, `ocr-pagina-001`** — término detectado: `Dictamen N 65`

> ADRIAZOLA ROJAS SUPERINTENDENTA DE EDUCACIÓN (S) A: ENTIDADES SOSTENEDORAS DE ESTABLECIMIENTOS EDUCACIONALES DEL PAIS A través del Dictamen N 65, del año 2022, este Servicio se pronunció sobre la procedencia de la aplicación de protocolos de revisión de mochilas y bolsos a estudiantes, y de instalar pórticos detectores de metales al interior

La primera está **dentro de la línea `MATERIA`**, que abre la página 1 en la
posición 1 del texto (verificado en `40_salidas/datos/normas/dictamen_078_detectores_revision_mochilas.json`,
esta sesión): el propio documento declara que
sustituye al dictamen 65. La segunda, en el cuerpo dirigido a las entidades
sostenedoras, agrega el año (`del año 2022`) y confirma que el 65 sustituido es
el del corpus (`dictamen_065_revision_mochilas`, año 2022 curado).

**La procedencia NO se cambió, como pide el encargo.** Hoy
`20_insumos/curaduria/metadatos_curados.json` sostiene la sustitución en una
`fuente` que cita esa misma línea MATERIA, y el texto donde ahora se verifica
está en `ocr_pendiente_revision`: por el invariante del proyecto, un texto sin
revisar **no es cita textual**. Lo que este hallazgo aporta es que la cita
curada es localizable y literal, no que ya pueda invocarse como fuente textual.

Detalle que la revisión de OCR tendrá que resolver: la segunda mención se
transcribió como `Dictamen N 65` (sin el símbolo `°`). El patrón de cita la
reconoce igual, así que no rompe nada hoy, pero es una de las correcciones que
el equipo deberá aplicar al revisar la transcripción.

---

## 4. Qué queda para decisión humana

Ninguno de estos puntos se tocó en esta sesión. Se dejan formulados, no resueltos.

1. **`dto_453` → `dto_215` es una remisión falsa que hoy se publica.** Para
   cerrarla hace falta decidir el mecanismo: ampliar el reconocimiento de año a
   la forma `D.O. dd.mm.aaaa`, o excluir las notas marginales de modificación de
   la BCN del texto que se examina. Las dos son cambios al derivador, no a los
   datos.
2. **`rex_482_instrucciones` y `rex_482_reglamentos_b` son el mismo acto en dos
   slugs.** Mientras lo sean, toda remisión al REX 482 se duplicará y A seguirá
   "remitiendo" a B. La decisión es de modelo de datos (¿un documento con dos
   piezas, o dos documentos?), y por eso no se toma sin el equipo.
3. **34 asignaciones de tema descansan en una sola aparición de una sola
   palabra.** La tabla de §2 es el insumo para que el equipo de convivencia
   confirme o descarte cada una; el diccionario es cerrado y editable en
   `10_utils/10_configuracion.R`.
4. **La transcripción del `dictamen_078` sigue sin revisar.** Nada de lo hallado
   en §3 la mueve a `ocr_revisado`: eso solo lo hace una persona.

