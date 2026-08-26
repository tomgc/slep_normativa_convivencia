# Pre-clasificación de los 88 descartes de remisión — v1

Proyecto `slep_normativa_convivencia`, sesión 2, 2026-08-26. Producto de la tarea T1 del encargo `50_documentacion/andamios/20260826_encargo_avance_maquina_v1.md`.

> **Qué es y qué no es.** Los 88 descartes son citas que el derivador de relaciones
> encontró y el filtro de año descartó. Este documento los clasifica y **propone** qué
> hacer con ellos. Las homologaciones son propuestas: escribir `anios_alternativos` en
> `20_insumos/curaduria/metadatos_curados.json` es acto humano y ningún script lo toca.

## 1. Resultado

| Clase | Descartes | Qué significa |
|---|---:|---|
| descarte correcto | **67** | la cita apunta a una norma distinta, fuera del corpus: el filtro acertó |
| homologable | **21** | la cita apunta a la MISMA norma del corpus, bajo otro año: el filtro se pasó de largo |
| ambiguo | **0** | requiere decisión humana |
| **total** | **88** | |

**No hay filas ambiguas, y eso no es suerte: es que los 88 descartes colapsan en seis
grupos.** Cada grupo es una única norma citada con un único año, así que la decisión se
toma seis veces y se aplica ochenta y ocho, con la evidencia a la vista en cada fila.

## 2. Los seis grupos

| Grupo | Citas | Clase | Qué norma es en realidad | Evidencia |
|---|---:|---|---|---|
| `dto_215_uniforme_escolar`, año 2012 | 42 | descarte correcto | Decreto 215 de 2011, MINEDUC (D.O. 05-01-2012), que modifica el propio DTO 453 | nota marginal del aparato de modificaciones de la BCN, no cita del texto legal |
| `dfl_1_estatuto_asistentes_educacion`, año 1996 | 21 | **homologable** | DFL N° 1, de 1996, MINEDUC: es la MISMA norma del corpus (promulgada 10-09-1996, publicada 22-01-1997) | el contexto nombra al Ministerio de Educación y al Estatuto de los Profesionales de la Educación / ley 19.070 |
| `dfl_1_estatuto_asistentes_educacion`, año 2005 | 18 | descarte correcto | DFL N° 1, de 2005, MINEDUC: texto refundido de la ley 18.962 (LOCE) | el contexto dice literalmente que refunde la ley N° 18.962, Orgánica Constitucional de Enseñanza |
| `dfl_1_estatuto_asistentes_educacion`, año 2006 | 4 | descarte correcto | DFL N° 1, de 2006: tres del Ministerio del Interior (ley 18.695, Municipalidades) y uno del Ministerio de Salud (DL 2.763) | el contexto nombra el ministerio y la ley refundida en cada caso |
| `dfl_1_estatuto_asistentes_educacion`, año 2000 | 2 | descarte correcto | DFL N° 1/19.653, de 2000, Min. Secretaría General de la Presidencia: texto refundido de la ley 18.575 | el contexto nombra SEGPRES y la ley N° 18.575, Bases Generales de la Administración del Estado |
| `dfl_1_estatuto_asistentes_educacion`, año 1980 | 1 | descarte correcto | DFL N° 1-3.063, de 1980, del Ministerio del Interior (traspaso de servicios a las municipalidades) | el contexto escribe el número compuesto 1-3063 y lo atribuye a Interior |

## 3. Acción propuesta por grupo

- **`dto_215_uniforme_escolar`, año 2012** (42 citas) — ninguna; el filtro de año hizo exactamente lo que debía
- **`dfl_1_estatuto_asistentes_educacion`, año 1996** (21 citas) — proponer anios_alternativos: [1996] en la curaduría de dfl_1_estatuto_asistentes_educacion
- **`dfl_1_estatuto_asistentes_educacion`, año 2005** (18 citas) — ninguna; norma distinta con el mismo número, fuera del corpus
- **`dfl_1_estatuto_asistentes_educacion`, año 2006** (4 citas) — ninguna; dos normas distintas, ninguna en el corpus
- **`dfl_1_estatuto_asistentes_educacion`, año 2000** (2 citas) — ninguna; norma distinta, fuera del corpus
- **`dfl_1_estatuto_asistentes_educacion`, año 1980** (1 citas) — ninguna; norma distinta, fuera del corpus

## 4. El hallazgo que cambia el veredicto: 21 falsos negativos con costo visible

El grupo de 1996 no es una curiosidad de catálogo. **El propio corpus cita esa misma
norma con los dos años, y el filtro está partiendo el destino en dos según cómo la cite
cada legislador.** Las dos citas, una al lado de la otra:

| Norma citante | Año que usa | Texto | Resultado |
|---|---|---|---|
| `ley_21545_tea` art-19 | **1997** | "el artículo 12 ter del decreto con fuerza de ley N° 1, de 1997, del Ministerio de Educación, que fija el texto refundido […] de la ley N° 19.070, que aprobó el Estatuto de los Profesionales de la Educación" | remisión **aceptada** |
| `ley_21809_convivencia_educativa` art-5 | **1996** | "Estatuto de los Profesionales de la Educación, cuyo texto refundido […] fue fijado por el decreto con fuerza de ley N° 1, de 1996, del Ministerio de Educación" | remisión **descartada** |

Mismo objeto, misma ley refundida, mismo ministerio. Lo único distinto es el año que
eligió el redactor: 1996, el de la promulgación (10-09-1996), o 1997, el de la
publicación (22-01-1997). Ambos son citas correctas en derecho chileno.

**Lo que el sitio pierde hoy por esto**, medido sobre `relaciones.json`:

- Hacia esa norma sobreviven **3** remisiones (`ley_19979` art-5, `ley_21545_tea` art-19,
  `dto_453` art-88): las tres, las que citan "de 1997".
- **`dfl_315_perdida_reconocimiento_oficial → dfl_1` no existe.** Esa norma solo cita el
  DFL con año 1996, así que el enlace desapareció entero.
- **`ley_21809_convivencia_educativa → dfl_1` no existe**, por lo mismo. Es la ley de
  convivencia educativa, la norma central del sitio.
- `dto_453 → dfl_1` sobrevive declarando `n_citas: 1`, cuando hay 18 segmentos citantes.

No es un error del filtro de año: el filtro hace bien su trabajo y esa es justamente la
lección de la sesión 1. Es que a esta norma le falta el dato que el pipeline ya sabe
consumir.

## 5. Remedio propuesto (acto humano, una línea)

El mecanismo existe y está probado. `30_procesamiento/33_relaciones.R` construye los años
válidos del destino así:

```r
anios_destino <- c(normas[[slug_b]]$anio, normas[[slug_b]]$anios_alternativos)
```

y el campo ya se usa para el caso idéntico del dictamen 52/77
(`anios_alternativos: 2020` en `20_insumos/curaduria/metadatos_curados.json`). La
propuesta es una entrada análoga:

```json
"dfl_1_estatuto_asistentes_educacion": {
  "anios_alternativos": [1996],
  "fuente_anios_alternativos": "el propio documento declara Promulgación: 10-SEP-1996 y Publicación: 22-ENE-1997; verificado en Ley Chile (BCN, idNorma 60439) el 2026-08-26"
}
```

**Esa línea no la escribió esta sesión y no debe escribirla ningún script.** Con ella,
`run_all()` recupera las remisiones de `dfl_315` y `ley_21809`, y `dto_453` pasa de
`n_citas: 1` a reflejar sus 18 segmentos.

## 6. Otro hallazgo, en la misma pieza: la norma no es la que su nombre dice

`dfl_1_estatuto_asistentes_educacion` **no es el Estatuto de los Asistentes de la
Educación.** Su título declara que fija el texto refundido de la **ley N° 19.070, que
aprobó el Estatuto de los Profesionales de la Educación**, es decir el estatuto
**docente**. El contenido lo confirma sin margen: en sus 217 disposiciones hay **0**
apariciones de "asistentes de la educación" y **154** de "profesionales de la educación".

El origen del nombre está registrado: el PDF llegó así rotulado desde el equipo
(`20_insumos/normativa/README.md`, línea 48: `10. DFL 1 MINEDUC ESTATUTO ASISTENTES.pdf`).
Hay además una confusión de fondo que lo explica y que no es trivial: el DFL se dictó
"en uso de las facultades que me confiere el artículo vigésimo de la **Ley Nº 19.464**"
—la ley del personal no docente— pero lo que refunde es la 19.070.

Consecuencias que ya están en producción: el rótulo erróneo viajó al catálogo, al
manifiesto, a cinco anclas del borrador de glosario y al PDF publicado; y **el corpus no
contiene ninguna norma sobre asistentes de la educación** (el Estatuto de los Asistentes
es la Ley 21.109, de 2018, ver
`50_documentacion/andamios/20260826_fuentes_glosario_v1.md` §3).

**Pregunta cerrada para el titular:** ¿el PDF es el que se quería (el Estatuto Docente,
mal rotulado, y hay que renombrar el slug) o se quería la Ley 21.109 y hay que
incorporarla además? Renombrar un slug mueve anclas públicas, así que la decisión no es
de máquina.

## 7. Panel adversarial

Dos revisores independientes de solo lectura, con instrucción explícita de **refutar**:

| Revisor | Encargo | Resultado |
|---|---|---|
| 1 | re-derivar con código propio el conteo de 88, los 550 vínculos por tipo, los seis grupos y las 12 normas citantes | **coincide en todo**: 88 descartes (0 duplicados), 550 relaciones (502 tema, 44 remisión, 2 grupo_acto, 2 sustitución), los seis grupos con la misma distribución, 12 normas en `desde` |
| 2 | intentar refutar las cinco afirmaciones de clasificación leyendo el texto real | **las cinco CONFIRMADAS**, con dos matices y una pieza de evidencia que esta sesión no tenía |

Lo que el segundo revisor aportó y aquí se incorporó:

- La cita gemela de `ley_21545_tea` art-19 con año 1997 (§4), que es la evidencia
  decisiva del falso negativo. **Verificada de nuevo en este turno**, no tomada por buena.
- El costo medido en relaciones ausentes (§4), también reverificado.
- **Matiz sobre el grupo de 2005:** solo las citas de `ley_20370` nombran la ley 18.962
  en el texto; las otras 15 la identifican por co-texto (la fórmula estándar
  "DFL N° 2, de 2009 […] con las normas no derogadas del DFL N° 1, de 2005"). La
  identificación es inequívoca pero indirecta, y corresponde decirlo.
- **Matiz sobre el grupo de 2012:** una de las apariciones no es nota marginal sino nota
  explicativa de la BCN en el preámbulo ("El numeral 4 del Artículo Único del Decreto
  215, Educación, publicado el 05.01.2012, modifica el artículo 9 de la presente
  norma"). Sigue siendo aparato editorial y no texto legal: el veredicto no cambia.

Ninguno de los dos revisores consultó fuentes externas; la verificación en Ley Chile
(BCN) la hizo esta sesión por separado.

## 8. Calibración del clasificador

El encargo pide dos controles, y los dos se ejecutaron:

- **Caso malo conocido.** Las falsas remisiones `dto_453 → dto_215` por notas marginales
  de la BCN, que la sesión 1 descubrió y corrigió, están entre los 88 y el clasificador
  las devuelve como **descarte correcto**, las 42. El instrumento reproduce el caso
  conocido.
- **Caso bueno.** Una remisión vigente de las 44 aceptadas
  (`ley_19979_jornada_escolar_completa → ley_20845_inclusion_escolar`, cita "Ley 20845" en
  el artículo 7º bis) pasa por el mismo examen y sale **coherente**: la cita no lleva año
  que contradiga al del corpus, así que se conserva. El instrumento no marca lo sano.

## 9. Verificación de completitud

Filas de la tabla = descartes leídos del archivo = **88**, comprobado en el mismo turno
que las produjo. Ninguna fila se agrupó, se resumió ni se omitió.

## 10. Tabla completa: las 88 filas

Las 88, sin recorte. `art.` es el id del segmento donde está la cita; el contexto es el texto real que la rodea, recortado a 210 caracteres.

| # | Norma que cita | art. | Cita detectada | Año cita | Año corpus | Clase | Contexto |
|---:|---|---|---|---:|---:|---|---|
| 1 | `ley_20370_general_educacion` | `art-70` | decreto con fuerza de ley Nº 1 | 2005 | 1997 | correcto | Artículo 70.- Sin perjuicio de lo señalado en el artículo siguiente, derógase el decreto con fuerza de ley Nº 1, de 2005, del Ministerio de Educación, que fija el texto refundido, coordinado y sistematizado de  |
| 2 | `ley_20370_general_educacion` | `art-71` | decreto con fuerza de ley Nº 1 | 2005 | 1997 | correcto | n fuerza de ley, refunda, coordine y sistematice esta ley con las normas no derogadas del decreto con fuerza de ley Nº 1, de 2005, a que se refiere el artículo anterior, dentro de un plazo de 90 días contado de |
| 3 | `ley_20370_general_educacion` | `art-7-5` | decreto con fuerza de ley Nº 1 | 2005 | 1997 | correcto | r legal del Consejo Superior de Educación establecido en el párrafo 2º del Título III del decreto con fuerza de ley Nº 1, de 2005, del Ministerio de Educación, que fija el texto refundido, coordinado y sistemat |
| 4 | `ley_20845_inclusion_escolar` | `art-1` | decreto con fuerza de ley Nº1 | 2005 | 1997 | correcto |  refundido, coordinado y sistematizado de la ley Nº20.370 con las normas no derogadas del decreto con fuerza de ley Nº1, de 2005: 1) Modifícase el artículo 3º en el siguiente sentido: a) Agrégase la siguiente l |
| 5 | `ley_20845_inclusion_escolar` | `art-20-transitorio` | decreto con fuerza de ley Nº1 | 2005 | 1997 | correcto | to refundido, coordinado y sistematizado de la ley 20.370 con las normas no derogadas del decreto con fuerza de ley Nº1, de 2005, en conformidad a lo dispuesto en el artículo 1º transitorio del mismo cuerpo leg |
| 6 | `ley_21430_garantias_ninez` | `art-65` | decreto con fuerza de ley N° 1 | 2006 | 1997 | correcto | al de Municipalidades, cuyo texto refundido, coordinado y sistematizado fue fijado por el decreto con fuerza de ley N° 1, de 2006, del Ministerio del Interior, se cumplirá a través de los convenios celebrados c |
| 7 | `ley_21430_garantias_ninez` | `art-84` | decreto con fuerza de ley N° 1 | 2006 | 1997 | correcto | al de Municipalidades, cuyo texto refundido, coordinado y sistematizado fue fijado por el decreto con fuerza de ley N° 1, de 2006, del Ministerio del Interior: "m) La promoción de los derechos de los niños, niñ |
| 8 | `ley_21545_tea` | `art-17` | decreto con fuerza de ley N° 1 | 2006 | 1997 | correcto | s derechos que otorga y reconoce el presente Título conforme lo dispone el artículo 4 del decreto con fuerza de ley N° 1, de 2006, del Ministerio de Salud, que fija el texto refundido, coordinado y sistematizad |
| 9 | `ley_21545_tea` | `art-18` | decreto con fuerza de ley N° 1 | 2005 | 1997 | correcto | refundido, coordinado y sistematizado de la ley N° 20.370 con las normas no derogadas del decreto con fuerza de ley N° 1, de 2005. Las instituciones de educación no formal promoverán medidas para la participaci |
| 10 | `ley_21801_celulares` | `art-unico` | decreto con fuerza de ley Nº 1 | 2005 | 1997 | correcto | efundido, coordinado y sistematizado de la ley Nº 20.370, con las normas no derogadas del decreto con fuerza de ley Nº 1, de 2005: 1. Agrégase en el artículo 3 el siguiente literal o): "o) Educación digital. El |
| 11 | `ley_21809_convivencia_educativa` | `art-1` | decreto con fuerza de ley Nº 1 | 2005 | 1997 | correcto | efundido, coordinado y sistematizado de la ley Nº 20.370, con las normas no derogadas del decreto con fuerza de ley Nº 1, de 2005: 1. Agrégase en el artículo 4° el siguiente inciso final, nuevo: "Es deber del E |
| 12 | `ley_21809_convivencia_educativa` | `art-16-e` | decreto con fuerza de ley N° 1 | 1996 | 1997 | **homologable** | ales de la Educación, cuyo texto refundido, coordinado y sistematizado, fue fijado por el decreto con fuerza de ley N° 1, de 1996, del Ministerio de Educación. El equipo de convivencia definirá medidas pedagógi |
| 13 | `ley_21809_convivencia_educativa` | `art-2` | decreto con fuerza de ley N° 1 | 2005 | 1997 | correcto | refundido, coordinado y sistematizado de la ley N° 20.370 con las normas no derogadas del decreto con fuerza de ley N° 1, de 2005". 2. Incorpórase el siguiente párrafo segundo, nuevo, readecuándose el orden cor |
| 14 | `ley_21809_convivencia_educativa` | `art-11-bis` | decreto con fuerza de ley N° 1 | 2005 | 1997 | correcto | refundido, coordinado y sistematizado de la ley N° 20.370 con las normas no derogadas del decreto con fuerza de ley N° 1, de 2005. d) Elaborar un informe bienal del estudio, análisis, hallazgos y recomendacione |
| 15 | `ley_21809_convivencia_educativa` | `art-5` | decreto con fuerza de ley N° 1 | 1996 | 1997 | **homologable** | ales de la Educación, cuyo texto refundido, coordinado y sistematizado, fue fijado por el decreto con fuerza de ley N° 1, de 1996, del Ministerio de Educación: 1. En el artículo 8° bis: a) Sustitúyese en el inc |
| 16 | `ley_21809_convivencia_educativa` | `art-9` | decreto con fuerza de ley N° 1 | 2006 | 1997 | correcto | al de Municipalidades, cuyo texto refundido, coordinado y sistematizado fue fijado por el decreto con fuerza de ley N° 1, de 2006, del Ministerio del Interior, por la siguiente: "b) Medidas de prevención y resg |
| 17 | `ley_21809_convivencia_educativa` | `art-12` | decreto con fuerza de ley N° 1 | 2005 | 1997 | correcto | refundido, coordinado y sistematizado de la ley N° 20.370 con las normas no derogadas del decreto con fuerza de ley N° 1, de 2005. 5. Coordinar la implementación del Programa con la División de Educación Genera |
| 18 | `ley_21809_convivencia_educativa` | `art-9-2` | decreto con fuerza de ley Nº 1 | 2005 | 1997 | correcto | efundido, coordinado y sistematizado de la ley Nº 20.370, con las normas no derogadas del decreto con fuerza de ley Nº 1, de 2005. |
| 19 | `ley_21809_convivencia_educativa` | `art-12-2` | decreto con fuerza de ley N° 1 | 2005 | 1997 | correcto | refundido, coordinado y sistematizado de la ley N° 20.370 con las normas no derogadas del decreto con fuerza de ley N° 1, de 2005, y de conformidad a los plazos señalados en el artículo quinto transitorio. La p |
| 20 | `dfl_315_perdida_reconocimiento_oficial` | `preambulo` | decreto con fuerza de ley Nº 1 | 2005 | 1997 | correcto | refundido, coordinado y sistematizado de la ley Nº 20.370 con las normas no derogadas del decreto con fuerza de ley Nº 1, de 2005, del Ministerio de Educación; Que el mismo artículo 46 previamente citado, señal |
| 21 | `dfl_315_perdida_reconocimiento_oficial` | `art-1` | decreto con fuerza de ley Nº 1 | 2005 | 1997 | correcto | refundido, coordinado y sistematizado de la ley Nº 20.370 con las normas no derogadas del decreto con fuerza de ley Nº 1, de 2005, del Ministerio de Educación, para otorgar el reconocimiento oficial del Estado  |
| 22 | `dfl_315_perdida_reconocimiento_oficial` | `art-11` | decreto con fuerza de ley Nº 1 | 1996 | 1997 | **homologable** | o en las conductas descritas en el artículo 3 de la ley Nº 19.464, y en el artículo 4 del decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación. NOTA El numeral 4 del artículo único del Decreto 2 |
| 23 | `dfl_315_perdida_reconocimiento_oficial` | `art-24-ter` | decreto con fuerza de ley Nº 1 | 1996 | 1997 | **homologable** | ados directamente por las municipalidades, se estará a lo dispuesto en el artículo 22 del decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Respecto al capital mínimo, se estará a lo dispues |
| 24 | `dto_453_estatuto_docente` | `preambulo` | decreto con fuerza de ley Nº 1 | 1996 | 1997 | **homologable** | siderados de educación básica. Artículo 2° Asimismo, en los términos del artículo 1° del decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación, este reglamento será aplicable a los profesionales  |
| 25 | `dto_453_estatuto_docente` | `art-18-bis` | decreto con fuerza de ley Nº 1 | 1996 | 1997 | **homologable** | , siempre que hubieren resultado mal evaluados según lo establecido en el artículo 70 del decreto con fuerza de ley Nº 1 de 1996, del Ministerio de Educación; proponer al sostenedor el personal a contrata y de  |
| 26 | `dto_453_estatuto_docente` | `art-42` | DFL Nº 1 | 1996 | 1997 | **homologable** |  10.10.2019 PARRAFO VII Del procedimiento para aplicar las sanciones del artículo 12 bis DFL Nº 1, de 1996 de Educación. - Derogado DTO 213, EDUCACION Art. único N) D.O. 04.10.2001 |
| 27 | `dto_453_estatuto_docente` | `art-42-a` | decreto con fuerza de ley Nº 1 | 1996 | 1997 | **homologable** | administración del sector en los términos señalados en la parte final del artículo 1° del decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Decreto 215, EDUCACIÓN Art. ÚNICO N° 1 D.O. 05.01. |
| 28 | `dto_453_estatuto_docente` | `art-65` | decreto con fuerza de ley Nº 1 | 1996 | 1997 | **homologable** | autorizado para ejercer la función docente de acuerdo a lo señalado en el artículo 2º del decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación; y 5.- No estar inhabilitado para el ejercicio de f |
| 29 | `dto_453_estatuto_docente` | `art-80` | decreto con fuerza de ley Nº 1 | 1996 | 1997 | **homologable** | en presentar los postulantes al cargo concursable, de conformidad a lo establecido por el decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación y el presente reglamento. Para estos efectos, exist |
| 30 | `dto_453_estatuto_docente` | `art-80-bis` | decreto con fuerza de ley Nº 1 | 2000 | 1997 | correcto | ración del Estado, cuyo texto refundido, coordinado y sistematizado ha sido fijado por el decreto con fuerza de ley Nº 1/19.653, de 2000, del Ministerio Secretaría General de la Presidencia. b. Normas para prov |
| 31 | `dto_453_estatuto_docente` | `art-81-bis` | decreto con fuerza de ley Nº 1 | 1996 | 1997 | **homologable** | ontratar a un profesional de la educación de acuerdo a lo dispuesto en el artículo 25 del decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Las postulaciones deberán presentarse dentro del p |
| 32 | `dto_453_estatuto_docente` | `art-86` | decreto con fuerza de ley Nº 1 | 1996 | 1997 | **homologable** | do al mecanismo de selección directiva establecido en el artículo 31 bis y siguientes del decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Decreto 215, EDUCACIÓN Art. ÚNICO N° 20 D.O. 05.01 |
| 33 | `dto_453_estatuto_docente` | `art-89` | decreto con fuerza de ley Nº 1 | 1996 | 1997 | **homologable** | deberá ser declarado desierto por el sostenedor, en atención a que el artículo 32 bis del decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación, exige dicho número mínimo para conformar la nómina |
| 34 | `dto_453_estatuto_docente` | `art-91` | decreto con fuerza de ley Nº 1 | 1996 | 1997 | **homologable** | ación Municipal, un convenio de desempeño de acuerdo a lo dispuesto en el artículo 33 del decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Decreto 215, Si el director designado renunciare d |
| 35 | `dto_453_estatuto_docente` | `art-91-ter` | DFL Nº 1 | 1996 | 1997 | **homologable** | nivel jerárquico, en lo que corresponda, de acuerdo a los artículos 34 D y siguientes del DFL Nº 1 de 1996, del Ministerio de Educación, sin perjuicio de lo establecido en el artículo 34 J del mismo cuerpo lega |
| 36 | `dto_453_estatuto_docente` | `art-120` | DFL Nº 1 | 1996 | 1997 | **homologable** |  de lo anterior, esta asignación podrá ser incrementada en conformidad al artículo 47 del DFL Nº 1 de 1996, del Ministerio de Educación. La asignación establecida en el inciso anterior se calculará anualmente c |
| 37 | `dto_453_estatuto_docente` | `art-121` | DFL Nº 1 | 1996 | 1997 | **homologable** | otal, sin perjuicio de la facultad de ser incrementadas en conformidad al artículo 47 del DFL Nº 1 de 1996, del Ministerio de Educación; en los establecimientos educacionales con una matrícula total de entre 40 |
| 38 | `dto_453_estatuto_docente` | `art-124` | Decreto con Fuerza de Ley N° 1 | 1980 | 1997 | correcto |  Artículo 127° Los establecimientos educacionales que, ya sea en virtud de las normas del Decreto con Fuerza de Ley N° 1-3063, de 1980, de Interior o de la Ley N° 18.602, hubieren aprobado reglamentos internos, |
| 39 | `dto_453_estatuto_docente` | `art-129` | decreto con fuerza de ley Nº 1 | 1996 | 1997 | **homologable** | podrá ponérseles término a la relación laboral, según lo dispuesto en el artículo 52° del decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Decreto 215, EDUCACIÓN Art. ÚNICO N° 1 D.O. 05.01. |
| 40 | `dto_453_estatuto_docente` | `art-144` | decreto con fuerza de ley Nº 1 | 1996 | 1997 | **homologable** |  docentes; f) Por fallecimiento; g) Por aplicación del inciso séptimo del artículo 70 del decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación; h) Por salud irrecuperable o incompatible con el d |
| 41 | `dto_453_estatuto_docente` | `art-147` | decreto con fuerza de ley Nº 1 | 1996 | 1997 | **homologable** | nedor deberá basarse obligatoriamente en la dotación fijada de acuerdo al artículo 22 del decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación, fundamentada en el Plan Anual de Desarrollo Educat |
| 42 | `dto_453_estatuto_docente` | `art-147-bis` | decreto con fuerza de ley Nº 1 | 1996 | 1997 | **homologable** | ículo 144º anterior, tendrán derecho a la indemnización contemplada en el artículo 73 del decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación, y quedarán sujetos a lo prescrito en el artículo 7 |
| 43 | `dto_453_estatuto_docente` | `preambulo` | Decreto 215 | 2012 | 2009 | correcto | onales y que se desempeñen en los departamentos de administración de educación municipal. Decreto 215, EDUCACIÓN Art. ÚNICO N° 1 D.O. 05.01.2012 Artículo 3° Este Reglamento regula: a. Los requisitos, deberes, d |
| 44 | `dto_453_estatuto_docente` | `art-18-bis` | Decreto 215 | 2012 | 2009 | correcto | so segundo del mismo artículo; y promover una adecuada convivencia en el establecimiento. Decreto 215, EDUCACIÓN b) En el ámbito financiero: asignar, administrar y Art. ÚNICO N° 6 controlar los recursos que les |
| 45 | `dto_453_estatuto_docente` | `art-42-a` | Decreto 215 | 2012 | 2009 | correcto | del artículo 1° del decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Decreto 215, EDUCACIÓN Art. ÚNICO N° 1 D.O. 05.01.2012 Artículo 61° Para estos efectos se considera "sector municipal" l |
| 46 | `dto_453_estatuto_docente` | `art-65` | Decreto 215 | 2012 | 2009 | correcto | blecido en el inciso primero del artículo 13 de la Constitución Política de la República; Decreto 215, 2.- Haber cumplido con la Ley de Reclutamiento y EDUCACIÓN Movilización, cuando fuere procedente; Art. ÚNIC |
| 47 | `dto_453_estatuto_docente` | `art-66` | Decreto 215 | 2012 | 2009 | correcto |  del Departamento de Administración de Educación Municipal o de la Corporación Municipal. Decreto 215, EDUCACIÓN Art. ÚNICO N° 9 D.O. 05.01.2012 |
| 48 | `dto_453_estatuto_docente` | `art-67` | Decreto 215 | 2012 | 2009 | correcto | que estén en posesión de un título profesional o licenciatura de al menos ocho semestres. Decreto 215, EDUCACIÓN Art. ÚNICO N° 10 D.O. 05.01.2012 |
| 49 | `dto_453_estatuto_docente` | `art-68` | Decreto 215 | 2012 | 2009 | correcto |  de no poder acreditarse del modo antes indicado, será materia de una declaración jurada. Decreto 215, EDUCACIÓN Art. ÚNICO N° 11 D.O. 05.01.2012 Artículo 69° Los profesionales de la educación pueden ingresar a |
| 50 | `dto_453_estatuto_docente` | `art-71` | Decreto 215 | 2012 | 2009 | correcto | iendo aquéllos, no hayan cumplido con los requisitos exigidos en las bases de los mismos. Decreto 215, Los docentes a contrata podrán desempeñar funciones EDUCACIÓN docentes directivas Art. ÚNICO N° 13 D.O. 05. |
| 51 | `dto_453_estatuto_docente` | `art-72` | Decreto 215 | 2012 | 2009 | correcto | as y técnico-pedagógicas en los organismos de administración educacional de dicho sector. Decreto 215, EDUCACIÓN Art. ÚNICO N° 14 D.O. 05.01.2012 |
| 52 | `dto_453_estatuto_docente` | `art-73` | Decreto 215 | 2012 | 2009 | correcto |  o por la Corporación Educacional correspondiente, de acuerdo con lo dispuesto en la ley. Decreto 215, Dicha fijación se hará conforme al número de alumnos EDUCACIÓN del establecimiento por niveles y cursos y s |
| 53 | `dto_453_estatuto_docente` | `art-76` | Decreto 215 | 2012 | 2009 | correcto | una, deberá realizar las adecuaciones que procedan por alguna de las siguientes causales: Decreto 215, 1.- Variación en el número de alumnos del sector EDUCACIÓN municipal de una comuna; Art. ÚNICO N° 17 2.- Mo |
| 54 | `dto_453_estatuto_docente` | `art-77` | Decreto 215 | 2012 | 2009 | correcto |  establecidas en el decreto con fuerza de ley Nº 2, de 1998, del Ministerio de Educación. Decreto 215, EDUCACIÓN Art. ÚNICO N° 18 D.O. 05.01.2012 Artículo 78° Derogado. Decreto 215, EDUCACIÓN Art. ÚNICO N° 19 D |
| 55 | `dto_453_estatuto_docente` | `art-80` | Decreto 215 | 2012 | 2009 | correcto | ción, en D.O. 05.01.2012 calidad de titular se hará por concurso público de antecedentes. Decreto 215, Los concursos públicos de antecedentes son aquellos EDUCACIÓN convocados de conformidad a lo dispuesto por  |
| 56 | `dto_453_estatuto_docente` | `art-80-bis` | Decreto 215 | 2012 | 2009 | correcto | siempre las normas de transparencia, imparcialidad y objetividad del presente reglamento. Decreto 215, El cómputo de los plazos establecidos para la EDUCACIÓN convocatoria y resolución de los concursos a que se |
| 57 | `dto_453_estatuto_docente` | `art-81` | Decreto 215 | 2012 | 2009 | correcto | dotación como docente en calidad de titular se hará por concurso público de antecedentes. Decreto 215, EDUCACIÓN Art. ÚNICO N° 20 D.O. 05.01.2012 |
| 58 | `dto_453_estatuto_docente` | `art-81-bis` | Decreto 215 | 2012 | 2009 | correcto | Administración de Educación Municipal respectivo o a la Corporación Municipal en su caso. Decreto 215, Los concursos deberán ser publicitados, a lo menos, en EDUCACIÓN un diario de circulación nacional y en el  |
| 59 | `dto_453_estatuto_docente` | `art-82` | Decreto 215 | 2012 | 2009 | correcto | s de Concursos para los casos de los docentes estarán integradas, cada una de ellas, por: Decreto 215, EDUCACIÓN a) El Director del Departamento de Administración de Art. ÚNICO N° 20 Educación Municipal o de la |
| 60 | `dto_453_estatuto_docente` | `art-83` | Decreto 215 | 2012 | 2009 | correcto | onal procederá a efectuar el sorteo a que se refiere el literal c) del artículo anterior. Decreto 215, En el sorteo se determinará un miembro titular y uno EDUCACIÓN reemplazante, el que asumirá la designación  |
| 61 | `dto_453_estatuto_docente` | `art-84` | Decreto 215 | 2012 | 2009 | correcto | o el plazo de recepción de postulaciones. Sus decisiones se adoptarán por simple mayoría. Decreto 215, En todo caso, deberán dejar constancia de sus EDUCACIÓN actuaciones en actas que deberán suscribir todos su |
| 62 | `dto_453_estatuto_docente` | `art-85` | Decreto 215 | 2012 | 2009 | correcto | nco seleccionados, quienes deberán ocupar los primeros lugares ponderados en el concurso. Decreto 215, El Alcalde, en un plazo máximo de cinco días contados EDUCACIÓN desde la fecha de recepción del informe de  |
| 63 | `dto_453_estatuto_docente` | `art-86` | Decreto 215 | 2012 | 2009 | correcto | is y siguientes del decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Decreto 215, EDUCACIÓN Art. ÚNICO N° 20 D.O. 05.01.2012 |
| 64 | `dto_453_estatuto_docente` | `art-86-bis` | Decreto 215 | 2012 | 2009 | correcto |  respectivo, o a la Corporación Municipal en su caso, la administración de los concursos. Decreto 215, El Jefe del Departamento de Administración Municipal o EDUCACIÓN de la Corporación Municipal, según corresp |
| 65 | `dto_453_estatuto_docente` | `art-87` | Decreto 215 | 2012 | 2009 | correcto | Artículo 87º: Las convocatorias deberán informar, a lo menos, las siguientes materias: Decreto 215, EDUCACIÓN . Plazo y forma de las postulaciones; Art. ÚNICO N° 20 . Perfil profesional del cargo; D.O. 05.01.20 |
| 66 | `dto_453_estatuto_docente` | `art-87-bis` | Decreto 215 | 2012 | 2009 | correcto | rán contener las materias señaladas en el artículo anterior, y a lo menos las siguientes: Decreto 215, EDUCACIÓN . Etapas del proceso; Art. ÚNICO N° 20 . Proposición del convenio de desempeño, y D.O. 05.01.2012 |
| 67 | `dto_453_estatuto_docente` | `art-88` | Decreto 215 | 2012 | 2009 | correcto | oras de Concursos de directores de establecimientos educacionales estarán integradas por: Decreto 215, EDUCACIÓN a) El Jefe del Departamento de Administración de Art. ÚNICO N° 20 Educación Municipal o de la Cor |
| 68 | `dto_453_estatuto_docente` | `art-88-bis` | Decreto 215 | 2012 | 2009 | correcto | nda, procederá a efectuar el sorteo a que se refiere el literal c) del artículo anterior. Decreto 215, El sorteo determinará un miembro titular y uno EDUCACIÓN reemplazante, el que asumirá la designación en cas |
| 69 | `dto_453_estatuto_docente` | `art-89` | Decreto 215 | 2012 | 2009 | correcto |  participar en un proceso de preselección que contará con el apoyo de asesorías externas. Decreto 215, En el caso de los establecimientos educacionales EDUCACIÓN rurales o en aquellos que tengan una matrícula i |
| 70 | `dto_453_estatuto_docente` | `art-89-bis` | Decreto 215 | 2012 | 2009 | correcto | se calculará anualmente considerando el promedio de la asistencia media del año anterior. Decreto 215, EDUCACIÓN Art. ÚNICO N° 20 D.O. 05.01.2012 |
| 71 | `dto_453_estatuto_docente` | `art-90` | Decreto 215 | 2012 | 2009 | correcto | sus actuaciones en actas que deberán suscribir todos sus integrantes y el ministro de fe. Decreto 215, Los postulantes preseleccionados, de acuerdo a lo EDUCACIÓN dispuesto en el artículo 89º del presente regla |
| 72 | `dto_453_estatuto_docente` | `art-90-bis` | Decreto 215 | 2012 | 2009 | correcto | undada, desierto el proceso de selección, caso en el cual se realizará un nuevo concurso. Decreto 215, El resultado de este proceso se notificará a los EDUCACIÓN integrantes de la nómina de selección de conform |
| 73 | `dto_453_estatuto_docente` | `art-91` | Decreto 215 | 2012 | 2009 | correcto |  el artículo 33 del decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Decreto 215, Si el director designado renunciare dentro de los dos EDUCACIÓN meses siguientes a su nombramiento, el sost |
| 74 | `dto_453_estatuto_docente` | `art-91-bis` | Decreto 215 | 2012 | 2009 | correcto | arse vacante el cargo, al cabo de los cuales obligatoriamente deberá llamarse a concurso. Decreto 215, EDUCACIÓN Art. ÚNICO N° 20 d. Normas para proveer el cargo de Jefe del Departamento D.O. 05.01.2012 de Admi |
| 75 | `dto_453_estatuto_docente` | `art-91-ter` | Decreto 215 | 2012 | 2009 | correcto | de Educación, sin perjuicio de lo establecido en el artículo 34 J del mismo cuerpo legal. Decreto 215, EDUCACIÓN Art. ÚNICO N° 20 D.O. 05.01.2012 PARRAFO III De los Derechos del Personal Docente del Sector Muni |
| 76 | `dto_453_estatuto_docente` | `art-120` | Decreto 215 | 2012 | 2009 | correcto | o-pedagógicas y a un 15% en el caso de otro personal de las unidades técnico-pedagógicas. Decreto 215, Para determinar el porcentaje, el Departamento de EDUCACIÓN Administración de la Educación o la Corporación |
| 77 | `dto_453_estatuto_docente` | `art-121` | Decreto 215 | 2012 | 2009 | correcto |  convenio de igualdad de oportunidades y excelencia educativa a que se refiere dicha ley. Decreto 215, EDUCACIÓN Art. ÚNICO N° 23 D.O. 05.01.2012 |
| 78 | `dto_453_estatuto_docente` | `art-122` | Decreto 215 | 2012 | 2009 | correcto | cional podrán percibir asignaciones mayores a las del director del mismo establecimiento. Decreto 215, EDUCACIÓN Art. ÚNICO N° 24 D.O. 05.01.2012 Artículo 123° El Departamento de Administración Educacional de l |
| 79 | `dto_453_estatuto_docente` | `art-124` | Decreto 215 | 2012 | 2009 | correcto | o técnico-pedagógica, solamente se mantendrán si el nuevo empleo da derecho a percibirlas Decreto 215, EDUCACIÓN Art. ÚNICO N° 25 D.O. 05.01.2012 PARRAFO V Del Reglamento Interno Artículo 125° Los establecimien |
| 80 | `dto_453_estatuto_docente` | `art-129` | Decreto 215 | 2012 | 2009 | correcto | el artículo 52° del decreto con fuerza de ley Nº 1, de 1996, del Ministerio de Educación. Decreto 215, EDUCACIÓN Art. ÚNICO N° 1 D.O. 05.01.2012 PARRAFO VIII Del Término de la Relación Laboral |
| 81 | `dto_453_estatuto_docente` | `art-144` | Decreto 215 | 2012 | 2009 | correcto | l sector municipal, dejarán de pertenecer a ella, solamente, por las siguientes causales: Decreto 215, EDUCACIÓN a) Por renuncia voluntaria; Art. ÚNICO N° 27 b) Por falta de probidad, conducta inmoral, establec |
| 82 | `dto_453_estatuto_docente` | `art-145` | Decreto 215 | 2012 | 2009 | correcto | amento de Educación Municipal o de la Corporación Municipal, designado por el sostenedor. Decreto 215, Tratándose de los casos establecidos en las letras b) EDUCACIÓN y c) del artículo anterior, se aplicará lo  |
| 83 | `dto_453_estatuto_docente` | `art-147` | Decreto 215 | 2012 | 2009 | correcto | de una misma asignatura o de igual nivel y especialidad de enseñanza, cesará en su cargo: Decreto 215, EDUCACIÓN a) En primer lugar, con quienes tengan sesenta o más Art. ÚNICO N° 1 y años si son mujeres o sese |
| 84 | `dto_453_estatuto_docente` | `art-147-bis` | Decreto 215 | 2012 | 2009 | correcto | erio de Educación, y quedarán sujetos a lo prescrito en el artículo 74 del mismo decreto. Decreto 215, Aquellos profesionales que dejen de pertenecer a la EDUCACIÓN dotación por las causales de las letras g) y  |
| 85 | `circular_193_estudiantes_embarazadas` | `ocr-pagina-004` | Decreto con Fuerza de Ley N° 1 | 2005 | 1997 | correcto | refundido, coordinado y sistematizado de la Ley N° 20.370 con las normas no derogadas del Decreto con Fuerza de Ley N° 1, de 2005 (LGE). • Ley N° 20.845, de Inclusión Escolar, que regula la admisión de los y la |
| 86 | `circular_812_identidad_genero` | `ocr-pagina-001` | Decreto con Fuerza de Ley N°1 | 2000 | 1997 | correcto |  EDUCACIONAL. RESOLUCIÓN EXENTA N• 0 812 SANTIAGO, 2 1 DIC 2021 VISTO: Lo dispuesto en el Decreto con Fuerza de Ley N°1-19.653, de 2000, del Ministerio Secretaría General de la Presidencia, que fija el texto re |
| 87 | `rex_482_reglamentos_b` | `ocr-pagina-006` | Decreto con Fuerza de Ley N° 1 | 2005 | 1997 | correcto | refundido, coordinado y sistematizado de la Ley N° 20.370 con las normas no derogadas del Decreto con Fuerza de Ley N° 1, de 2005 (Ley General de Educación). 12) Ley N° 20.845, de inclusión escolar, que regula  |
| 88 | `dictamen_71_expulsion_cancelacion_matricula` | `num-1` | decreto con fuerza de ley Nº 1 | 2005 | 1997 | correcto |  refundido, coordinado y sistematizado de la ley Nº20.370 con las normas no derogadas del decreto con fuerza de ley Nº 1, de 2005. D.O. 02.07.2010. 2 “El sistema debe promover y respetar la diversidad de proces |
