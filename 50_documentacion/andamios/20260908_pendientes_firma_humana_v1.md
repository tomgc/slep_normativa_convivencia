# Pendientes de firma humana

> **Para el equipo de convivencia del SLEP Costa Central.**
> **Producido por:** encargo v10 (`20260908_encargo_correcciones_visibles_v1.md`), bloque B4.
> **Fecha:** 2026-09-08.
>
> **Aquí no se corrigió nada, y no por descuido.** Los cuatro puntos de este documento
> viven en `20_insumos/`, que ninguna máquina escribe: es la fuente legal de verdad y la
> capa donde el equipo se hace responsable de lo que afirma. Cada punto trae **qué está
> mal, en qué archivo y línea, qué habría que escribir, y por qué el pipeline no puede
> decidirlo solo**. Esa última columna es la que justifica que esto llegue como tarea y no
> como un commit.
>
> Todas las cifras se recontaron en la sesión que escribe este documento. Ninguna se hereda
> de un informe anterior sin verificar.

---

## Resumen

| # | Pendiente | Tamaño | Quién puede resolverlo |
|---|---|---|---|
| 1 | Encabezados del glosario con la definición pegada al término | **27** entradas de 39 (20 cortadas exactamente en 60 caracteres, 7 antes), más 1 falso positivo y 3 grupos de encabezados duplicados | quien pueda decidir dónde termina el término y empieza la definición |
| 2 | Anclas rotas en piezas en borrador | **2**, ambas en el mismo documento | quien decida si una cita de OCR sin revisar sobrevive |
| 3 | `aviso_vigencia` vacío en las 25 normas | **1 caso urgente**, 6 a verificar, 1 hipótesis | quien pueda afirmar qué norma rige hoy |
| 4 | Errores de nombre en el corpus | **4 erratas**, 1 alias engañoso, 1 slug materialmente falso, 1 fila faltante | quien tenga la carpeta de origen y decida sobre las URL públicas |

---

## 1. Glosario: 27 encabezados con la definición pegada al término

**Archivo:** `20_insumos/curaduria/piezas/borradores/glosario.md`.
**Dónde exactamente:** cada entrada es un encabezado `### <texto>`; dos líneas más abajo,
`- **Definido en:** [...]` la enlaza a su artículo, y la entrada correspondiente de
`fuentes:` en el front matter va en el mismo orden.

**Recuento propio** (`Rscript`: `l <- readLines(...); h <- grep("^### ", l)`):
39 encabezados, **20 de exactamente 60 caracteres**, 35 distintos (3 grupos duplicados),
1 con carácter espurio.

### 1.1 Por qué pasa

`00_generar_borradores.R:224` captura el término con

```r
PATRON_DEFINICION <- "(?i)se\\s+entender[aá]\\s+por\\s+[\"“]?([^,.;:\"”]{4,60})|…"
```

es decir, **hasta 60 caracteres o hasta el primer signo de puntuación**. El castellano
jurídico chileno no pone coma entre el término y su definición («Se entenderá por acoso
escolar toda acción…»), así que ambos viajan pegados. Cuando el término va entrecomillado
en el original (`"año escolar"`, `"especialidad"`) el corte sale limpio: por eso 12 de las
39 están bien.

### 1.2 Los 20 cortados en 60 caracteres

Formato: línea · encabezado actual → **término propuesto** · dónde sigue la definición.

| Línea | Encabezado actual (literal) | Término propuesto | Norma |
|---|---|---|---|
| 60 | `acoso escolar toda acción u omisión constitutiva de agresión` | **acoso escolar** | `ley_20536_violencia_escolar#art-16-b` |
| 66 | `acoso escolar toda acción u omisión constitutiva de agresión` | **acoso escolar** ⚠ duplicado de la anterior | `ley_21809_convivencia_educativa#art-16-b` |
| 72 | `alumnos preferentes a aquellos estudiantes que no tengan cal` | **alumnos preferentes** | `ley_20845_inclusion_escolar#art-4` |
| 84 | `año laboral docente el período comprendido entre el primer d` | **año laboral docente** | `dfl_1_…#art-9` |
| 108 | `buena convivencia escolar la coexistencia armónica de los mi` | **buena convivencia escolar** | `ley_20536_violencia_escolar#art-16-a` |
| 114 | `cuidador o cuidadora a quien proporcione asistencia o cuidad` | **cuidador o cuidadora** | `ley_21545_tea#art-2` |
| 138 | `dispositivos móviles electrónicos de comunicación personal a` | **dispositivos móviles electrónicos de comunicación personal** (el término mide 57: el corte se comió solo la `a` de «aquellos») | `ley_21801_celulares#art-10-ter` |
| 144 | `docente idóneo al que cuente con el Rectificación 2056 títul` | **docente idóneo** ⚠ ver 1.3 | `dfl_315_…#art-9` |
| 150 | `docente idóneo al que cuente con el título de profesional de` | **docente idóneo (educación básica)** ⚠ el artículo trae **dos** definiciones y el detector emitió una | `ley_20370_general_educacion#art-46` |
| 156 | ídem | **docente idóneo** | `dfl_315_…#art-12` |
| 162 | ídem | **docente idóneo** (variante con licenciatura de 8 semestres) | `dfl_315_…#art-13` |
| 174 | `dotación docente el número total de profesionales de la educ` | **dotación docente** (sujeto: **Servicio Local**) | `dfl_1_…#art-20` |
| 180 | ídem | **dotación docente** (sujeto: **municipio**) | `dto_453_estatuto_docente#art-72` |
| 192 | `establecimiento rural los que cumplan con los requisitos est` | **establecimiento rural** | `dto_453_…#art-89-bis` |
| 204 | `inclusión toda acción que proporcione la disminución o elimi` | **inclusión** | `ley_21430_garantias_ninez#art-19` |
| 222 | `no concurrencia en forma reiterada la inasistencia del traba` | **no concurrencia en forma reiterada** | `dto_453_…#art-144` |
| 228 | `personas con trastorno del espectro autista a aquellas que p` | **personas con trastorno del espectro autista** | `ley_21545_tea#art-2` |
| 234 | `prácticas profesionales aquellas actividades de naturaleza f` | **prácticas profesionales** | `ley_21809_…#art-44-bis` |
| 282 | `tramo una etapa del desarrollo profesional docente en la cua` | **tramo** | `dfl_1_…#art-19-b` |
| 288 | `viaje de estudio el conjunto de actividades educativas extra` | **viaje de estudio** | `rex_482_reglamentos_b#ocr-pagina-026` ⚠ **OCR sin revisar** |

**Las líneas 174 y 180 merecen atención aparte:** definen el mismo término con sujetos
distintos, **Servicio Local** frente a **municipio**. Para un SLEP esa es precisamente la
diferencia que importa, y el encabezado truncado la borra. Hay que decidir si se fusionan o
se separan nombrándolas por su sujeto.

### 1.3 Siete más, no reportadas antes, cortadas por una coma

| Línea | Largo | Encabezado actual | Término propuesto |
|---|---|---|---|
| 96 | 55 | `beca de perfeccionamiento el beneficio de participación` | **beca de perfeccionamiento** |
| 102 | 59 | `buena convivencia educativa la coexistencia armónica de los` | **buena convivencia educativa** |
| 126 | 41 | `discriminación arbitraria toda distinción` | **discriminación arbitraria** ⚠ OCR sin revisar |
| 198 | 59 | `explotación sexual comercial infantil la utilización de los` | **explotación sexual comercial infantil** |
| 216 | 55 | `niño o niña a todo ser humano hasta los 14 años de edad` | **niño o niña** ⚠ la misma oración define **adolescente** y esa entrada falta |
| 246 | 59 | `Protección Social de la Infancia y Adolescencia el conjunto` | **Protección Social de la Infancia y Adolescencia** |
| 276 | 51 | `trabajo infantil todo trabajo que priva a los niños` | **trabajo infantil** |

### 1.4 El carácter espurio, y por qué la entrada sobra entera

- **Línea 132:** `### discriminación arbitraria®`
- **Origen:** `20_insumos/ocr/circular_812_identidad_genero/pagina_004.txt:30`. El `®` es el
  reconocedor leyendo un **llamado a nota al pie en superíndice**.
- **Propuesta: eliminar la entrada, no limpiar el carácter.** La frase de origen **no es una
  definición**: es una remisión («la Ley N° 20.609 … no sólo entrega un parámetro general de
  lo que se entiende por discriminación arbitraria, sino que además impone…»). La definición
  real de ese mismo documento ya está en la línea 126.
- Las otras 7 apariciones de `®` viven en el OCR y **no se tocan**: ese texto se corrige
  por revisión humana página contra PDF, no por búsqueda y reemplazo.

### 1.5 Defecto adicional: tres grupos de encabezados duplicados

`acoso escolar…` ×2, `docente idóneo…` ×3, `dotación docente…` ×2, es decir 35 distintos de
39. Quarto deriva el `id` del `<h3>` de su texto, así que encabezados idénticos producen
`#acoso-escolar-…`, `…-1`, `…-2`, y el índice lateral queda ilegible. Desglosarlos por norma
(«docente idóneo (Ley 20.370, educación básica)») resuelve el truncamiento y el duplicado a
la vez.

### 1.6 Por qué la máquina no puede hacerlo

1. **No hay marca sintáctica que separe término de definición.** Ninguna heurística sirve en
   el corpus real: `dispositivos móviles electrónicos de comunicación personal` tiene seis
   palabras y `tramo` una; a `docente idóneo` le sigue «al que», a `inclusión` «toda», a
   `beca de perfeccionamiento` «el». El único criterio que funciona es saber qué concepto se
   está definiendo, que es conocimiento jurídico, no morfológico.
2. **Hay falsos positivos y ambigüedades sustantivas** (1.4, y las líneas 150, 174 y 180).
   Un script no distingue «el texto contiene la fórmula» de «el texto define».
3. **Regenerar destruiría trabajo.** `00_generar_borradores.R` no sobreescribe a propósito, y
   el archivo actual ya tiene edición humana: su sección «Pendientes de fuente» trae una
   tabla y una decisión fechada del equipo que el generador no produce.
4. **Cuatro entradas citan OCR sin revisar.** Publicar una definición legal desde texto no
   verificado es una decisión de responsabilidad institucional.

---

## 2. Dos anclas rotas en piezas en borrador

**Las dos apuntan al mismo documento y ambas se arreglan con el mismo valor.**

| # | Archivo | Líneas | Ancla actual | Ancla correcta |
|---|---|---|---|---|
| 1 | `20_insumos/curaduria/piezas/borradores/faq_revision_de_mochilas.md` | **10** (front matter) y **40** (cuerpo) | `dictamen_078_detectores_revision_mochilas.html#materia` | `…#ocr-pagina-001` |
| 2 | `20_insumos/curaduria/piezas/borradores/faq_seguridad_y_deteccion.md` | **12** y **136** | `dictamen_078_detectores_revision_mochilas.html#concordancias` | `…#ocr-pagina-001` |

### 2.1 Por qué se rompieron

Los `id` del dictamen 078 **cambiaron después** de que se sembraran los borradores. Cuando
la curaduría lo declaró `ocr_pendiente_revision`, el segmentador pasó de secciones a páginas
(`CLAUDE.md` §10.5: «El texto reconocido se segmenta por PÁGINA, nunca con anclas `art-N`»).
Verificado: los `id` reales hoy son `ocr-pagina-001` … `ocr-pagina-009`, y `materia` y
`concordancias` no existen. El generador fija el ancla al sembrar y **nunca sobreescribe un
borrador**, así que quedaron congeladas apuntando a una segmentación que ya no está.

### 2.2 Qué escribir

En las cuatro líneas, `ocr-pagina-001` (el segmento que contiene ambos extractos citados,
verificado por búsqueda del texto literal dentro del JSON). **Las etiquetas visibles también
cambian**: `MATERIA` y `CONCORDANCIAS` nombran una estructura que la página ya no tiene, y
`CONCORDANCIAS` es además falsa, porque el párrafo citado es texto corrido de la página 1.
Ambas pasan a `Página 1`.

```
faq_revision_de_mochilas.md:10   articulo: ocr-pagina-001, ancla: "dictamen_078_detectores_revision_mochilas.html#ocr-pagina-001"
faq_revision_de_mochilas.md:40   [Leer en contexto: Página 1](dictamen_078_detectores_revision_mochilas.html#ocr-pagina-001)
faq_seguridad_y_deteccion.md:12  articulo: ocr-pagina-001, ancla: "dictamen_078_detectores_revision_mochilas.html#ocr-pagina-001"
faq_seguridad_y_deteccion.md:136 [Leer en contexto: Página 1](dictamen_078_detectores_revision_mochilas.html#ocr-pagina-001)
```

### 2.3 La decisión de fondo, que no es técnica

**Reparar el ancla es lo fácil. Lo que hay que decidir es si la cita sobrevive.** El dictamen
078 está en `origen_texto: ocr_pendiente_revision`, y la propia curaduría dice por qué:
*«la capa de texto del PDF la produjo un reconocedor en el origen y arrastra sus errores
("á Ley" por "la Ley", "artículos incendiados" por "incendiarios")… no se publica como cita
textual hasta revisión humana»*. Los dos extractos que las piezas transcriben **contienen
esos errores**: `faq_revision_de_mochilas.md:38` reproduce «artículos incendiados a partir de
á Ley N° 21.809».

Arreglar el enlace deja en pie una cita textual de un texto que el equipo declaró no
citable. Tres salidas legítimas, y la elección es institucional:

1. Revisar las 9 páginas del dictamen 078 y moverlo a `ocr_revisado`.
2. Marcar los dos extractos como transcripción provisional, no como cita.
3. Quitar los extractos y dejar solo la remisión.

### 2.4 Por qué la máquina no puede hacerlo

1. **Ninguna compuerta lo detiene hoy**, y es deliberado: `34_generar_paginas.R` **avisa**
   sobre borradores y **aborta** solo sobre piezas validadas. El aviso convierte esto en
   tarea humana por diseño.
2. **Los enlaces del cuerpo no los valida nadie.** El validador solo cruza `fuentes`. Si
   alguien arregla el front matter y no el cuerpo, la pieza se publica validada con dos
   enlaces muertos dentro.
3. **Mover un documento a `ocr_revisado` es el acto por el que el equipo se hace responsable
   de esa transcripción.** Ningún script puede firmarlo.

---

## 3. `aviso_vigencia` vacío en las 25 normas

**Recuento propio:** `aviso_vigencia` es `null` en **25 de 25**. `vigencia$estado`: 24
`vigente`, 1 `sustituido`.

### 3.1 Antes de escribir nada: hoy el campo no se publica

**Dónde se declara:** `20_insumos/curaduria/metadatos_curados.json`, dentro de `normas`,
como una cadena suelta bajo el slug.

**Quién lo lee:** un solo script, en dos puntos —
`30_procesamiento/32_segmentar_articulos.R:497` (lo copia al JSON) y `:571` (lo usa para el
aviso de «curación pendiente»). **Ningún generador de páginas lo consume**: `grep` sobre
`30_procesamiento/` y `10_utils/` no devuelve una sola línea en `34_generar_paginas.R`.

La banda de vigencia que hoy ve el usuario se compone **desde el campo `vigencia`**, y el
comentario del generador lo dice: *«El texto lo compone el mecanismo desde el campo
`vigencia`, no una nota escrita a mano por norma: así enlaza siempre a la sustituta y no
puede quedar desincronizado del dato.»*

**Por qué está vacío: se vació a propósito.** El campo se introdujo el 2026-08-25 y se
retiró ese mismo día al incorporar el dictamen 078, sustituido por el bloque estructurado
`vigencia: {estado, sustituido_por, fuente}`. **`aviso_vigencia` es hoy un enganche
vestigial.**

> **Consecuencia operativa:** llenar el campo **no cambia nada en el sitio**. Habilitarlo
> exige también tocar `34_generar_paginas.R` para renderizarlo, y decidir dónde: banda
> propia, o junto a `notas_ficha`, que sí se publica. **Esa decisión es previa a escribir el
> texto**, y es la primera que el equipo tiene que tomar en este punto.

### 3.2 Qué normas lo necesitan de verdad

**No lo necesita `dictamen_065_revision_mochilas`**, la única `sustituido`: ya recibe la
banda automática con enlace a la sustituta y su procedencia. Un aviso a mano aquí duplicaría
la banda y podría desincronizarse de ella, que es el defecto que el cambio de agosto corrigió.

**Sí lo necesita, y es el caso urgente: `ley_20536_violencia_escolar`.**

- Su propia curaduría ya declara que es una ley **modificatoria**: `notas_ficha` dice
  «Artículos 16 A a 16 E: incorporados a la Ley General de Educación (DFL 2/2009) por esta
  ley».
- La ley 21.809 (2026) **reemplaza uno por uno esos mismos artículos**. Verificado en su
  texto: «6. Sustitúyese el artículo 16 A por el siguiente:», y los numerales 7 a 10 hacen lo
  propio con 16 B, 16 C, 16 D y 16 E.
- **El efecto ya es visible**: el glosario tiene el mismo término `acoso escolar` con dos
  definiciones distintas (líneas 60 y 66), una de cada ley, y nada en el sitio dice cuál rige.
- Su `estado` dice `vigente` y **es formalmente correcto**: la ley sigue en el ordenamiento;
  lo reemplazado es el texto que ella insertó en la LGE. Por eso ningún derivador la marca.

**Texto propuesto**, para pegar en la entrada que ya existe en `metadatos_curados.json`:

```json
"ley_20536_violencia_escolar": {
  "notas_ficha": [
    "Artículos 16 A a 16 E: incorporados a la Ley General de Educación (DFL 2/2009) por esta ley."
  ],
  "aviso_vigencia": "Esta ley sigue vigente como acto legislativo, pero los artículos 16 A a 16 E que incorporó a la Ley General de Educación (DFL 2/2009) fueron reemplazados por la ley N° 21.809, de 2026. Para el régimen de convivencia aplicable hoy debe consultarse la ley 21.809; este documento se mantiene publicado como antecedente histórico y para citas anteriores a esa fecha.",
  "fuente_aviso_vigencia": "Texto de la propia ley 21.809 publicada en este corpus: su artículo 15 dispone «6. Sustitúyese el artículo 16 A por el siguiente:», y los numerales 7 a 10 reemplazan sucesivamente los artículos 16 B, 16 C, 16 D y 16 E del decreto con fuerza de ley N° 2, de 2009, del Ministerio de Educación. Verificado y redactado por [NOMBRE Y ROL], [AAAA-MM-DD]."
}
```

> **Nota de esquema.** `aviso_vigencia` es el único campo curado que en su forma histórica
> **no traía `fuente_*`**, contra el contrato del archivo, que exige procedencia para todo
> valor. La propuesta de arriba cierra ese hueco. Quien la escriba debe rellenar el nombre y
> la fecha: un metadato curado sin quién lo firmó es indistinguible de uno inventado.

**A verificar (no hay evidencia en el corpus, hace falta trabajo jurídico):** las
instrucciones y dictámenes de la Superintendencia anteriores a la entrada en vigor de la ley
21.809 — `rex_482_instrucciones_reglamentos_internos`, `rex_482_reglamentos_b`,
`dictamen_52_77_expulsion`, `dictamen_71_expulsion_cancelacion_matricula`,
`circular_193_estudiantes_embarazadas`, `circular_812_identidad_genero`. Todas figuran
`vigente` y ninguna de las 552 relaciones las toca por sustitución. Si alguna fue derogada,
**el corpus no lo sabe**, porque la norma que lo diría no está en él.

**Hipótesis, no verificada:** `dto_453_estatuto_docente` (1992) frente a `dfl_1` (1997)
definen `dotación docente` con sujetos distintos (municipio frente a Servicio Local). Un
aviso que declare cuál gobierna hoy en un SLEP tendría valor operativo directo.
*(verificar con: consulta a Ley Chile o a Contraloría; el corpus no contiene la norma que lo
resolvería.)*

### 3.3 Por qué la máquina no puede hacerlo

1. **La derogación tácita no está en el texto.** Que la 21.809 haya reemplazado los artículos
   que la 20.536 insertó en la LGE es una inferencia sobre una norma modificatoria y su
   anfitriona, no una relación entre dos PDF del corpus.
2. **`vigente` es verdadero y engañoso a la vez.** Ninguna regla separa «el acto sigue en el
   ordenamiento» de «su contenido fue reemplazado».
3. **El corpus es incompleto por construcción.** El DFL 2/2009 (la LGE consolidada) no está
   entre los 25 documentos; sin él nada puede comprobar qué texto rige hoy en el artículo 16 B.
4. **`CLAUDE.md` §10.5 lo prohíbe:** «Nada se inventa». Un aviso derivado por heurística
   sería exactamente un metadato sin procedencia.
5. **Es una afirmación jurídica publicada por una institución.** Decirle a un equipo de
   convivencia «esta norma ya no rige» y equivocarse produce decisiones ilegales sobre
   estudiantes.

---

## 4. Errores de nombre en el corpus

**Archivo:** `20_insumos/normativa/README.md`, tabla de equivalencias, líneas 36 a 61.

> **Lo que condiciona toda corrección.** La columna «Nombre original» **no se transcribió de
> archivos en disco**: viene del listado que envió el equipo, y los PDF originales no están
> en el repositorio. Nadie puede verificarla desde aquí. Además, la decisión previa ya
> registrada fue no corregirla («el README es trazabilidad»). Este documento la reabre, no
> la revierte: **corregir una trazabilidad para que se lea mejor es falsearla**, salvo que
> quien tiene la carpeta de origen confirme que el nombre real es el corregido.

### 4.1 Las cuatro erratas

| Línea | Texto actual | Corrección propuesta | Tipo |
|---|---|---|---|
| **53** | `15. CIRULAR 193 EMBARAZOS.pdf` | `15. CIRCULAR 193 EMBARAZOS.pdf` | falta la segunda `C` |
| **47** | `09. DLF 315 PÉRDIDA RO.pdf` | `09. DFL 315 PÉRDIDA RO.pdf` | sigla invertida |
| **59** | `20. DICTÁMEN 065 REVISIÓN DE MOCHILAS.pdf` | `20. DICTAMEN 065 …` | **no reportada antes.** «dictamen» es grave terminada en -n: sin tilde. La tilde solo va en el plural «dictámenes», que la línea 58 usa bien |
| **60** | `21. DICTÁMEN 71 EXPULSIONES Y CANCELACIONES DE MATRÍCULA.pdf` | `21. DICTAMEN 71 …` | **no reportada antes**, idéntica |

**Riesgo acotado:** los 24 md5 declarados coinciden uno a uno con los archivos en disco y la
suma de control se reproduce. La columna canónica y los md5 están bien; el defecto está
confinado a una columna de texto documental que ningún script consume.

### 4.2 El alias engañoso `20845 INCLUSION SEP` (línea 40)

«SEP» es el acrónimo de **Subvención Escolar Preferencial**, que es la **ley 20.248** —otra
ley, que **no está en el corpus**. La 20.845 es la Ley de Inclusión Escolar. El propio corpus
las distingue: `ley_21809#art-15` menciona «la Subvención Escolar Preferencial regulada en la
ley N° 20.248».

**Propuesta:** no alterar el nombre original y añadir bajo la tabla:

> *Nota sobre `03. 20845 INCLUSION SEP.pdf`: el sufijo «SEP» del nombre de origen es
> engañoso. La ley 20.845 es la Ley de Inclusión Escolar; la Ley SEP (subvención escolar
> preferencial) es la 20.248 y no forma parte de este corpus. El nombre original se conserva
> sin alterar por trazabilidad.*

**Qué se rompe:** nada. Es prosa documental.

### 4.3 El slug del DFL 1 es materialmente falso

- **El título oficial dice:** «FIJA TEXTO REFUNDIDO … DE LA LEY Nº 19.070 QUE APROBO EL
  ESTATUTO DE LOS **PROFESIONALES DE LA EDUCACION**…». Es el **Estatuto Docente**.
- **El Estatuto de los Asistentes de la Educación es la ley 21.109**, que el corpus nombra en
  `ley_21809#art-6` y que **no está entre los 25 documentos**.
- El error viene del nombre de origen (`10. DFL 1 MINEDUC ESTATUTO ASISTENTES.pdf`, línea 48).
- **Ya produjo daño visible:** el glosario atribuye a «asistentes de la educación» cinco
  definiciones que son del Estatuto Docente (`año laboral docente`, `docente principiante`,
  `dotación docente`, `remuneración básica mínima nacional`, `tramo`). Quien busque
  «asistentes de la educación» llega a normas de docentes.

**Dos opciones, no equivalentes:**

**Opción A — renombrar el slug** a `dfl_1_estatuto_profesionales_educacion` (recoge la
expresión del título oficial y no colisiona con `dto_453_estatuto_docente`, que es su
reglamento).

*Qué se rompe, medido:* el slug **es** el nombre del PDF
(`31_extraer_texto.R:185`: `slug <- sub("\\.pdf$", "", basename(ruta_pdf))`), así que
renombrar el archivo renombra el JSON, el `.qmd`, la página y **la URL pública**. Toda URL ya
repartida queda 404, sin redirección. Alcance: **4 080 ocurrencias** del slug en el
repositorio — 3 981 en `50_documentacion/` (andamios y logs históricos, que **no deben
reescribirse**: son registro), 82 en `40_salidas/datos/` (se regeneran), **17 en
`20_insumos/`, que son las únicas que hay que editar a mano**, y **0 en `30_procesamiento/`
y `10_utils/`**, porque ningún script lo tiene escrito a mano.

**Opción B — no renombrar y corregir por metadato:** dejar el slug y añadir en
`metadatos_curados.json` una `notas_ficha` que diga qué es realmente el documento, más la
nota bajo la tabla del README.

**Recomendación: Opción B**, salvo que el equipo confirme que las URL del DFL 1 aún no se han
repartido fuera del SLEP. Una biblioteca normativa que se consulta para decidir sobre
estudiantes paga un precio alto por un 404, y el daño real —la atribución equivocada en el
glosario— se corrige igual con una nota de ficha. Si algún día se agrega una capa de
redirección, la Opción A queda disponible.

### 4.4 Falta una fila entera

`dictamen_078_detectores_revision_mochilas.pdf` **está en disco y no tiene fila en la tabla**:
25 PDF, 24 filas. El paso 2 del propio README («Agregar su fila a la tabla de equivalencias,
con el md5») no se ejecutó cuando el dictamen entró. Quedaron desactualizadas tres
afirmaciones del mismo archivo:

- **línea 30:** «coincidió en los 24 archivos» → el corpus tiene 25.
- **líneas 63-64:** la suma de control sigue siendo correcta *para las 24 filas*, pero ya no
  cubre el corpus.
- **línea 69:** «Documentos sin capa de texto (4 de 24)» → el denominador es 25. El numerador
  **sigue siendo 4**, pero **las normas en `ocr_pendiente_revision` son 5**. Distinguir «sin
  capa de texto» de «capa de texto no confiable» es una decisión de redacción que hay que
  tomar una vez y aplicar también a `CLAUDE.md` §10.5, que arrastra la misma ambigüedad.

### 4.5 Por qué la máquina no puede hacerlo

1. **La columna «Nombre original» es un registro de procedencia, no un dato derivable.**
   Ningún script puede saber si `CIRULAR` era el nombre real del archivo del equipo o un
   error al listarlo: los originales no están aquí.
2. **La decisión contraria ya se tomó una vez** («el README es trazabilidad») y cambiarla es
   una decisión de gobierno documental, no una corrección ortográfica.
3. **El renombre del slug es una decisión sobre URL públicas**, con enlaces ya repartidos y
   sin capa de redirección. Un script puede ejecutarlo; no puede ponderar el costo.
4. **Nombrar bien la norma exige saber qué norma es.** El pipeline lee el nombre del archivo
   y no puede contrastarlo con el título, porque el título lo extrae **después** de fijar el
   slug a partir de ese nombre.

---

## Qué NO hay que hacer

- **No editar `20_insumos/` con un script.** Ni para «resincronizar» anclas, ni para limpiar
  el `®`, ni para corregir el README. Es la capa donde el equipo firma.
- **No borrar `glosario.md` para regenerarlo.** El archivo ya tiene edición humana que el
  generador no reproduce.
- **No corregir el OCR con búsqueda y reemplazo.** Se revisa página contra PDF, y ese acto
  es el que mueve un documento a `ocr_revisado`.
- **No llenar `aviso_vigencia` esperando verlo en el sitio.** Hoy no hay quien lo publique;
  primero se decide dónde va (§3.1).
