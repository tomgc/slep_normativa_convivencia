# Decisión: precedencia determinística en el orden de resultados del buscador

> **Destino:** `50_documentacion/activa/decisiones/20260910_decision_precedencia_buscador.md`
> **Fecha:** 2026-09-10, sesión 5. **Estado:** aprobada por el titular del Área de Monitoreo en la sesión 5, punto por punto, con las recomendaciones del asistente de chat.
> **Origen:** principio fijado por el titular al cierre de la sesión 4 (`50_documentacion/traspasos/traspaso_cierre_v04.md` §8, decisión 1) y adopciones de las revisiones externas del motor (`50_documentacion/andamios/20260909_integracion_revision_externa_v1.md`, `20260909_revision_externa_motor_rolA_v1.md`, `20260909_revision_externa_motor_rolB_v1.md`).
> **Se implementa en:** `50_documentacion/andamios/20260910_encargo_v12_precedencia_v1.md`.
> **Autor:** Área de Monitoreo, con asistencia del asistente de chat.

---

## 1. Problema

El buscador del sitio encuentra el ancla correcta entre sus resultados, pero no la pone primera. Tres consultas probadas por el titular en producción al cierre de la sesión 4 lo muestran: «dfl 1» entrega el DFL 1 en tercer lugar, «bullying» pone primero una ley que contiene la palabra y no la norma del tema, y «celular» abre páginas OCR y el preámbulo de la Ley 21.801 antes que su artículo 10 bis. La causa es de diseño: el piso R0 del encargo v11 pone primero toda página que coincide literalmente con la consulta, sin mirar qué norma es ni qué tipo de fuente.

## 2. Principio

En un corpus de 25 normas el mejor resultado de cada consulta se conoce, y el orden lo dictan reglas explícitas sobre metadatos, no la frecuencia del texto. Una consulta está resuelta solo si el ancla esperada queda en posición 1.

## 3. Reglas, en orden fijo

Cada página de resultado ocupa una sola posición: la de la regla más alta que la alcanza.

### Regla 1. Norma nombrada

La consulta nombra una norma cuando contiene alguna de estas tres formas:

1. **Tipo y número** que resuelven a una sola norma, o a un solo grupo de acto, del catálogo. El número se compara sin puntos ni ceros a la izquierda («20.536», «20536» y «dictamen 78» frente a `078`). Sinónimos de tipo: `ley`; `dfl`, `decreto con fuerza de ley`; `dto`, `ds`, `decreto`, `decreto supremo`; `circular`; `rex`, `resolución exenta`, `resolución`; `dictamen`, `dictámenes`.
2. **Número de 3 o más dígitos** que aparece en una sola norma, o en un solo grupo de acto, del catálogo.
3. **Frase completa** de un alias de `ALIAS_CONSULTA` cuya fuente sea `remision`, `denominacion` o `titulo`.

No nombran una norma los alias de fuente `slug`, `tipo` ni `readme_nombre`: son materia o variantes tipográficas, y con ellos «celular» nombraría dos normas.

**Artículo nombrado (A-08).** Si además de nombrar la norma la consulta nombra un artículo («artículo 10 bis», «art. 16 B», «16 B»), el primer resultado lleva a esa ancla. Si el artículo no existe en esa norma, lleva a la página de la norma.

### Regla 2. Norma principal

1. **Por alias** (tabla del §5): una fila se activa cuando la consulta contiene todas las raíces distintivas de ese alias. Si se activan varias, gana la de más raíces; si empatan, la que aparece primero en la consulta.
2. **Por tema** (tabla del §4): si ninguna fila por alias se activó, el tema detectado por un alias de fuente `temas` define la norma principal.
3. **Qué artículo se abre (A-06).** La tabla fija la norma. Dentro de ella, el artículo lo elige la coincidencia de la consulta con los sub-resultados de esa página; el ancla de la tabla se usa solo si no hay ninguna coincidencia.
4. La norma principal ocupa su posición aunque la consulta literal no la devuelva: el resultado se compone con los datos exportados por el pipeline (título, etiqueta y ancla), nunca con valores escritos en el código del sitio.
5. Una fila marcada «sin norma principal» desactiva la regla 2 para esa consulta.

### Regla 3. Nivel de fuente, por grupos

1. **Grupo A:** páginas que devuelve la consulta completa. **Grupo B:** páginas que aportan solo las variantes de alias. El grupo A va antes que el grupo B (B-04: lo que responde la consulta completa no queda debajo de lo que solo menciona un alias).
2. Dentro de cada grupo, el nivel de fuente de la tabla del §6: nivel 1, luego nivel 2, luego nivel 3.
3. Una norma con `vigencia.estado` igual a `sustituido` nunca queda antes que la norma que la sustituye (B-05).

### Regla 4. Coincidencia literal

Dentro de cada nivel, el orden de Pagefind (puntaje de página), y dentro de cada página, los sub-resultados por relevancia como hasta hoy.

### Varias normas o temas en una consulta

Se ordenan por la posición en que aparecen en la consulta. La regla 1 precede siempre a la regla 2.

### Estado «sin resultado firme» (B-03)

Cuando la consulta completa no devuelve ninguna página y no se activa ni la regla 1 ni la regla 2, el buscador lo dice en un mensaje, muestra la lista de normas citadas por el corpus y no incluidas en él (derivada del texto, sin curaduría) y, debajo, rotulados como relacionados, los resultados que aporten los alias.

## 4. Tabla por tema

Construida leyendo el texto de cada ancla candidata, sin mirar las anclas esperadas del conjunto de evaluación. Las filas marcadas ⚑ fueron decisiones con alternativa (§9).

| # | Tema | Norma principal | Ancla de respaldo | Por qué |
|---|---|---|---|---|
| 1 | convivencia escolar | `ley_21809_convivencia_educativa` | `art-16-a` | Define «buena convivencia educativa»; sustituyó el 16 A que había introducido la Ley 20.536 |
| 2 | violencia y acoso escolar ⚑ | `ley_21809_convivencia_educativa` | `art-16-b` | Define «acoso escolar» con el texto vigente; reemplazó el 16 B de la Ley 20.536 |
| 3 | medidas disciplinarias ⚑ | `ley_21809_convivencia_educativa` | `art-16-e` | Exige regular en el reglamento interno la aplicación de medidas disciplinarias; el procedimiento de expulsión (DFL 2/1998) no está en el corpus |
| 4 | inclusión y no discriminación | `ley_20845_inclusion_escolar` | `art-1` | Fija el principio «Integración e inclusión» (LGE, art. 3, letra k) |
| 5 | derechos de la niñez | `ley_21430_garantias_ninez` | `art-1` | Objeto de la ley y Sistema de Garantías |
| 6 | participación de la comunidad | `ley_21809_convivencia_educativa` | `art-15` | Texto vigente del art. 15 de la LGE |
| 7 | identidad de género ⚑ | `circular_812_identidad_genero` | `ocr-pagina-001` | Única norma del corpus dedicada al tema; texto OCR, se muestra como ubicación |
| 8 | embarazo y maternidad | `ley_20370_general_educacion` | `art-11` | Garantiza ingreso y permanencia; la Circular 193 (OCR) queda detrás |
| 9 | trastorno del espectro autista | `ley_21545_tea` | `art-1` | Objeto de la ley y definición del trastorno |
| 10 | uso de dispositivos móviles | `ley_21801_celulares` | `art-10-bis` | Prohibición y excepciones |
| 11 | uniforme y presentación personal | `dto_215_uniforme_escolar` | `art-1` | Regula el uso obligatorio del uniforme |
| 12 | formación ciudadana | `ley_20911_formacion_ciudadana` | `art-unico` | Crea el Plan de Formación Ciudadana |
| 13 | jornada escolar | `ley_19979_jornada_escolar_completa` | `art-1` | Régimen de jornada escolar completa |
| 14 | estatuto del personal | `dfl_1_estatuto_asistentes_educacion` | `art-1` | Ámbito del Estatuto de los Profesionales de la Educación |
| 15 | reconocimiento oficial | `ley_20370_general_educacion` | `art-46` | Requisitos del reconocimiento oficial; el Decreto 315 lo reglamenta |
| 16 | seguridad escolar ⚑ | `dictamen_078_detectores_revision_mochilas` | `ocr-pagina-001` | Detección de armas; vigente, sustituye al Dictamen 065; texto OCR, ubicación |
| 17 | revisión de pertenencias ⚑ | `dictamen_078_detectores_revision_mochilas` | `ocr-pagina-001` | Revisión de mochilas; el Dictamen 065 está sustituido |

## 5. Filas por alias

Se aplican antes que la tabla por tema (regla 2.1). El alias se escribe como está en `ALIAS_CONSULTA` (sin tildes).

| Alias | Norma principal | Ancla de respaldo | Por qué |
|---|---|---|---|
| `consejo escolar` | `dto_24_consejos_escolares` | `art-3` | Fija la integración del Consejo Escolar |
| `centro de padres` | `dto_565_centros_padres_apoderados` | `art-1` | Define los Centros de Padres y Apoderados |
| `encargado de convivencia` | `ley_21809_convivencia_educativa` | `art-15` | El texto vigente del art. 15 de la LGE regula el equipo y la Coordinación de la Convivencia Educativa, figura que reemplazó al encargado de convivencia |
| `expulsion` | `dictamen_52_77_expulsion` | `num-1` | Explica las causales y el procedimiento vigentes tras la Ley 21.128, que no está en el corpus |
| `cancelacion de matricula` | `dictamen_52_77_expulsion` | `num-1` | Mismo procedimiento que la expulsión |
| `asistentes de la educacion` | sin norma principal | (ninguna) | El estatuto de los asistentes de la educación no está entre las 25 normas; el DFL 1 regula a los profesionales de la educación |

## 6. Tabla de niveles de fuente (A-20, B-09)

| Condición | Nivel |
|---|---|
| `tipo` en `ley`, `dfl`, `dto`, `circular`, `rex` y texto citable | 1 |
| `tipo` igual a `dictamen` y texto citable | 2 |
| `origen_texto` igual a `ocr_pendiente_revision`, cualquier tipo | 3 (ubicación, no cita) |

Texto citable: `origen_texto` igual a `capa_texto_pdf` u `ocr_revisado`. Lista cerrada: un `tipo` que no esté en la tabla detiene la generación del sitio.

## 7. Dónde viven y cómo se validan

- Las tablas de los §4, §5 y §6 son constantes en `10_utils/10_configuracion.R`, con esta decisión como fuente declarada. No se escriben en `20_insumos/`.
- El pipeline exporta al sitio, como dato y no como lógica, las tablas y los metadatos que el cliente necesita (tipo, número normalizado, `origen_texto`, `vigencia`, grupo de acto, anclas por norma con su etiqueta). El sitio no contiene ancla ni norma escrita a mano (A-13).
- La generación se detiene, antes de escribir cualquier archivo, si una norma o un ancla de las tablas no existe en `40_salidas/datos/`, o si un `tipo` del catálogo no está en la tabla del §6.

## 8. Conjunto de evaluación: tres respuestas esperadas actualizadas

Se actualizan antes de medir, no después, y la esperada anterior se conserva en una columna para la comparación pareada.

| Consulta | Esperada v11 | Esperada desde esta decisión | Razón |
|---|---|---|---|
| C01 «pueden revisar la mochila de un alumno» | `dictamen_065_revision_mochilas.html#fuentes` | `dictamen_078_detectores_revision_mochilas.html#ocr-pagina-001` | El 065 está sustituido por el 078 (`vigencia` del catálogo); fila 17 |
| C03 «es obligatorio tener un encargado de convivencia en el colegio» | `ley_20536_violencia_escolar.html#art-unico` | `ley_21809_convivencia_educativa.html#art-15` | La Ley 21.809 reemplazó el art. 15 de la LGE (art. 1, N° 4) |
| C06 «cuántos días tiene el apoderado para apelar una expulsión» | `ley_20845_inclusion_escolar.html#art-3` | `dictamen_52_77_expulsion.html#num-3` | El procedimiento que transcribe la Ley 20.845 es anterior a la Ley 21.128; el punto 3 del dictamen explica los plazos vigentes |

Las anclas anteriores siguen en el conjunto aceptado de cada consulta.

## 9. Alternativas descartadas

- **Piso R0 absoluto (encargo v11):** la coincidencia literal gana a la norma del tema.
- **Ancla fija por tema:** con la detección por raíz de `busqueda.html`, desplaza la respuesta en consultas específicas («consejo escolar», «nombre social»). Se refinó el mismo día con las reglas 2.1 y 2.3.
- **Nivel de fuente sobre todo el conjunto:** una ley que solo menciona el término de un alias quedaría antes que el texto que responde la consulta completa.
- **Fila 2 con la Ley 20.536:** pondría primero un texto reemplazado (C1 de ambos revisores).
- **Fila 3 con LGE art. 46, letra f, o sin norma principal:** la primera muestra texto de 2010 ya modificado; la segunda deja el tema sin respuesta.
- **Filas 7, 16 y 17 sin norma principal:** leyes que solo mencionan el tema quedarían antes que la única norma dedicada.
- **Circular y resolución exenta en un nivel propio:** complejidad sin medición que la respalde (B-17).
- **Tablas en `20_insumos/curaduria/metadatos_curados.json`:** exige delegación registrada para cualquier escritura por script.
- **Capa semántica:** diferida con umbral (decisión D-B, pendiente de materialización).

## 10. Adopciones de las revisiones externas que esta decisión incorpora

A-06, A-08, A-09 (solo el piso determinístico, sin niveles de reordenamiento), A-13, A-15 (vara pareada), A-19, A-20, B-03, B-04 (parte derivada), B-05 (orden), B-09, B-17 y C1.

## 11. Hallazgos que quedan registrados y esta decisión no resuelve

- La Ley 21.809 sustituyó los artículos 15 y 16 A a 16 E de la LGE que había introducido la Ley 20.536; el campo `vigencia` del catálogo marca ambas leyes como vigentes y no registra reemplazos por artículo. Es insumo de la decisión D-A.
- `dfl_315_perdida_reconocimiento_oficial` es el Decreto 315 según su preámbulo, y el catálogo lo tipa `dfl` porque el tipo se toma del nombre del archivo. No altera el nivel; el rótulo se corrige cuando el sitio imprima el tipo (v13).
- `dfl_1_estatuto_asistentes_educacion` es el Estatuto de los Profesionales de la Educación; el nombre del archivo no se cambia porque es parte de las anclas públicas.
- `40_salidas/datos/relaciones.json` no contiene la lista de normas citadas y no incluidas: sus remisiones descartadas apuntan a normas del corpus con año distinto. La lista del estado «sin resultado firme» se deriva en el encargo v12.
