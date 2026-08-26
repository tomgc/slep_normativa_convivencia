# Pre-revisión asistida del OCR — v1

Proyecto `slep_normativa_convivencia`, sesión 2, 2026-08-26. Producto de la tarea T4 del encargo `50_documentacion/andamios/20260826_encargo_avance_maquina_v1.md`.

> **Qué es esto y qué no es.** Es una lista priorizada de líneas del texto OCR donde
> un detector léxico encontró señal de error de reconocimiento, para que la revisión
> humana empiece por donde más rinde. **No corrige nada, no reescribe nada y no mueve
> ningún documento a `ocr_revisado`.** Ningún archivo de `20_insumos/ocr/` fue
> modificado: el análisis es de solo lectura y los controles se plantaron en una copia
> temporal fuera del repositorio. Una línea que este documento no marca **no queda
> certificada**: el detector es léxico, no semántico, y no ve una palabra bien escrita
> puesta donde no va.

## 1. Método y calibración

El léxico de referencia no es un diccionario externo: son las 8144 palabras distintas de las 20 normas del corpus **con capa de texto de PDF**. "Fuera del léxico" significa, entonces, "no aparece en ninguna norma legible del corpus", que es una señal más limpia que un diccionario general de español y no introduce vocabulario ajeno al derecho chileno.

Dos calibraciones sucesivas recortaron el detector, y las dos quedan registradas porque
explican por qué la lista es corta:

1. **"Fuera del léxico" a secas no sirve como prioridad.** Marcaba 623 líneas, casi
   todas español legítimo ausente del corpus (`parámetro`, `gozan`, `tomaren`).
2. **Distancia de edición 1 tampoco basta.** La morfología del español produce vecinos
   a un carácter por conjugación y género (`comprendan`/`comprenden`,
   `accesorios`/`accesorias`). Solo cuenta como señal fuerte si el carácter que cambia
   forma un par que el reconocedor confunde **por forma** (i/l, j/i, f/t, n/ñ).

De ahí los dos tramos. **El tramo fuerte es la lista de trabajo**; el débil se declara
en el §6 con su ruido medido, no se esconde ni se presenta como hallazgo.

| Motivo | Tramo | Peso | Qué detecta |
|---|---|---|---|
| símbolo ajeno | fuerte | 3 | `®`, `™`, `©`, `§`: llamadas a nota al pie mal reconocidas |
| letra fuera del alfabeto | fuerte | 3 | `Ń`, `ł` y demás letras que el español no usa |
| confusión típica | fuerte | 3 | palabra a un carácter de una del corpus, por un par confundible |
| dígito pegado a palabra | fuerte | 2 | `educacionales3`: el número de nota se soldó a la palabra |
| mayúscula intercalada | fuerte | 2 | `DIGnIDAD` |
| tilde o eñe perdida | fuerte | 1 | `ensenanza`, `basica`: solo formas que el corpus nunca escribe sin marca |
| a un carácter del corpus | débil | 1 | distancia 1 sin par confundible: casi siempre morfología |
| vocabulario no visto | débil | 1 | palabra ausente del corpus sin vecino cercano |
| línea corta sin cierre | débil | 1 | posible corte del reconocedor a mitad de párrafo |


### Precisión medida por inspección manual

El control positivo prueba que el instrumento dispara y que calla, no cuánto se equivoca.
Para eso se leyeron filas reales, una por una, y el resultado se declara aquí en vez de
presentar la lista como si fuera limpia:

| Motivo | Filas | Inspeccionadas | Correctas | Precisión |
|---|---:|---:|---:|---|
| símbolo ajeno | 10 | 10 | 10 | sin falso positivo: `®` y `™` son siempre llamadas a nota mal leídas |
| letra fuera del alfabeto | 7 | 7 | 7 | sin falso positivo |
| mayúscula intercalada | 1 | 1 | 1 | sin falso positivo |
| tilde o eñe perdida | 29 | 17 (formas distintas) | 17 | sin falso positivo |
| dígito pegado | 38 | 10 | 10 | sin falso positivo en la muestra |
| confusión típica | 51 | 14 | 11 | **~79%**: falla en pares r/n y a/e de final de palabra (`dotar`→`dotan`, `hombre`→`nombre`, `agravar`→`agravan`) |

**Léase así:** cinco de los seis motivos del tramo fuerte no produjeron ningún falso
positivo en lo inspeccionado; el sexto, la confusión típica, acierta unas cuatro de cada
cinco veces y su error tiene una forma reconocible (cambio de letra al final de la
palabra, que en español suele ser conjugación y no error de lectura). Ninguna cifra de
esta tabla es una estimación: son filas leídas.

### El hallazgo que un ojo humano no encuentra

En 5 líneas el reconocedor escribió la conjunción **`у` (letra cirílica U+0443)** en lugar de la **`y` latina**. Las dos se ven idénticas en pantalla y en papel: nadie que lea el texto lo va a notar, y sin embargo cualquier búsqueda por `y`, cualquier comparación con el PDF y cualquier índice de Pagefind las tratan como caracteres distintos. Es el tipo exacto de error que justifica una pre-revisión de máquina: no acelera lo que un humano haría más lento, encuentra lo que un humano no puede encontrar.

### Control positivo (obligatorio, ejecutado antes de reportar)

Cuatro errores típicos plantados en una **copia temporal fuera de `20_insumos/`**, y
tres líneas limpias tomadas del propio texto OCR:

| Caso | Línea | Resultado |
|---|---|---|
| malo 1 | `Superintendencla de Educación...` | detectado (confusión típica i/l → `superintendencia`) |
| malo 2 | `...educacionales3 deberan...` | detectado (dígito pegado + tilde perdida) |
| malo 3 | `...discriminación arbitraria® toda...` | detectado (símbolo ajeno) |
| malo 4 | `...ENSENANZA BASICA Y MEDIA...` | detectado (eñe y tilde perdidas) |
| bueno 1 | `La protección del referido principio incumbe...` | tramo fuerte **calla** (el débil la marca) |
| bueno 2 | `deben cumplir las normas establecidas...` | callan ambos tramos |
| bueno 3 | `medidas disciplinarias de carácter formativo...` | tramo fuerte **calla** (el débil la marca) |

**Veredicto del control: el tramo fuerte detecta 4 de 4 plantados por su motivo y no
marca ninguna de las 3 líneas limpias. El tramo débil marca 2 de las 3 líneas limpias**,
y esa medición es la razón por la que no encabeza la lista.

**Doble pasada de motores: no disponible.** No hay un segundo motor OCR instalado en la
máquina (`tesseract` y `ocrmypdf` ausentes) y el encargo prohíbe instalar. Se declara y
se sigue: no era condición de éxito.

## 2. Estadística por documento

| Documento | Páginas | Líneas | Marcadas | % | Tramo fuerte | % | Líneas de membrete |
|---|---:|---:|---:|---:|---:|---:|---:|
| `circular_193_estudiantes_embarazadas` | 16 | 557 | 146 | 26.2% | **7** | 1.3% | 44 |
| `circular_586_tea` | 1 | 69 | 10 | 14.5% | **1** | 1.4% | 3 |
| `circular_812_identidad_genero` | 10 | 499 | 125 | 25.1% | **15** | 3.0% | 10 |
| `rex_482_reglamentos_b` | 48 | 2387 | 423 | 17.7% | **85** | 3.6% | 303 |
| **total** | **75** | **3512** | **704** | **20.0%** | **108** | **3.1%** | **360** |

## 3. Patrones de error sistemáticos, por documento

### `circular_193_estudiantes_embarazadas` — 16 páginas, 7 líneas del tramo fuerte

- **Confusiones típicas:** `dialogo -> diálogo` (1), `dotar -> dotan` (1), `gobiernc -> gobierno` (1), `nacer -> hacer` (1), `retencion -> retención` (1)
- **Tilde o eñe perdida:** `dialogo -> diálogo` (1), `retencion -> retención` (1)
- **Símbolos ajenos:** —
- **Letras fuera del alfabeto:** `'у'` (2)
- **Dígitos pegados (llamadas a nota):** —
- **Membrete:** 44 líneas de las 557 del documento (8%) son encabezado o pie repetido.

### `circular_586_tea` — 1 páginas, 1 líneas del tramo fuerte

- **Confusiones típicas:** —
- **Tilde o eñe perdida:** —
- **Símbolos ajenos:** —
- **Letras fuera del alfabeto:** `'у'` (1)
- **Dígitos pegados (llamadas a nota):** —
- **Membrete:** 3 líneas de las 69 del documento (4%) son encabezado o pie repetido.

### `circular_812_identidad_genero` — 10 páginas, 15 líneas del tramo fuerte

- **Confusiones típicas:** `complementar -> complementan` (1), `cuándo -> cuando` (1), `emanar -> emanan` (1), `hombre -> nombre` (1), `informan -> informar` (1), `parvularja -> parvularia` (1), `superintendencla -> superintendencia` (1)
- **Tilde o eñe perdida:** —
- **Símbolos ajenos:** `'®'` (2)
- **Letras fuera del alfabeto:** `'Ń'` (1), `'у'` (1)
- **Dígitos pegados (llamadas a nota):** `9nero` (1), `generalidad3` (1), `inclusivos13` (1)
- **Membrete:** 10 líneas de las 499 del documento (2%) son encabezado o pie repetido.

### `rex_482_reglamentos_b` — 48 páginas, 85 líneas del tramo fuerte

- **Confusiones típicas:** `ensenanza -> enseñanza` (13), `basica -> básica` (6), `minimo -> mínimo` (3), `racionales -> nacionales` (2), `actuacion -> actuación` (1), `agravar -> agravan` (1), `aprobacion -> aprobación` (1), `chite -> chile` (1)
- **Tilde o eñe perdida:** `ensenanza -> enseñanza` (13), `basica -> básica` (6), `minimo -> mínimo` (3), `actuacion -> actuación` (1), `aprobacion -> aprobación` (1), `deteccion -> detección` (1), `estandares -> estándares` (1), `fiscalizacion -> fiscalización` (1)
- **Símbolos ajenos:** `'®'` (7), `'™'` (1)
- **Letras fuera del alfabeto:** `'İ'` (1), `'у'` (1)
- **Dígitos pegados (llamadas a nota):** `adecuada4` (1), `Apoderados64` (1), `aravosas16` (1), `caso4` (1), `conflicto56` (1), `días68` (1), `Educación34` (1), `educativa43` (1)
- **Membrete:** 303 líneas de las 2387 del documento (13%) son encabezado o pie repetido.

## 4. Lista priorizada (tramo fuerte, completa)

Las 108 líneas del tramo fuerte, **sin recorte**, ordenadas por peso descendente y luego por página. La ruta es relativa a `20_insumos/ocr/`.

### `circular_193_estudiantes_embarazadas` (7 líneas)

| Ruta | Peso | Línea | Motivo |
|---|---:|---|---|
| `circular_193_estudiantes_embarazadas/pagina_014.txt:34` | 5 | http://portales.mineduc.c//usuarios/convivencia_escolar/doc/201512311219590. Protocolo_Retencio | confusion tipica del reconocedor: retencion -> retención · vocabulario no visto en el corpus: portales, mineduc, adolesc · tilde o enie perdida: retencion -> retención |
| `circular_193_estudiantes_embarazadas/pagina_016.txt:19` | 4 | constituyan un espacio de dialogo para los estudiantes en estas materias, en que la | confusion tipica del reconocedor: dialogo -> diálogo · tilde o enie perdida: dialogo -> diálogo |
| `circular_193_estudiantes_embarazadas/pagina_002.txt:28` | 3 | 6.1.1. Regulación de medidas académicas у administrativas que debe adoptar el | letra fuera del alfabeto espanol: 'у' |
| `circular_193_estudiantes_embarazadas/pagina_006.txt:31` | 3 | de cualquier nivel, debiendo estos últimos otorgar las facilidades académicas у | letra fuera del alfabeto espanol: 'у' |
| `circular_193_estudiantes_embarazadas/pagina_009.txt:64` | 3 | estudiantes, existe la necesidad de dotar de contenido la obligación dispuesta en el artículo | confusion tipica del reconocedor: dotar -> dotan |
| `circular_193_estudiantes_embarazadas/pagina_012.txt:10` | 3 | madre o del que está por nacer. | confusion tipica del reconocedor: nacer -> hacer |
| `circular_193_estudiantes_embarazadas/pagina_015.txt:1` | 3 | Gobiernc | confusion tipica del reconocedor: gobiernc -> gobierno |

### `circular_586_tea` (1 líneas)

| Ruta | Peso | Línea | Motivo |
|---|---:|---|---|
| `circular_586_tea/pagina_001.txt:65` | 3 | inclusión, la atención integral, у la protección de los | letra fuera del alfabeto espanol: 'у' |

### `circular_812_identidad_genero` (15 líneas)

| Ruta | Peso | Línea | Motivo |
|---|---:|---|---|
| `circular_812_identidad_genero/pagina_002.txt:34` | 5 | mismo, ha incorporado y explicitado elementos que vienen a complementar el ámbito de | confusion tipica del reconocedor: complementar -> complementan · a un caracter de una palabra del corpus: vienen -> tienen · vocabulario no visto en el corpus: explicitado |
| `circular_812_identidad_genero/pagina_001.txt:15` | 4 | SUPERTINTEŃDENCIA DE EDUCACIÓN Y | letra fuera del alfabeto espanol: 'Ń' · vocabulario no visto en el corpus: supertinteńdencia |
| `circular_812_identidad_genero/pagina_002.txt:33` | 4 | términos específicos algunos aspectos que sólo tenían raigambre administrativa у, así | letra fuera del alfabeto espanol: 'у' · a un caracter de una palabra del corpus: tenían -> tengan |
| `circular_812_identidad_genero/pagina_003.txt:4` | 4 | b) IDENTIDAD DE GÉNERO: Convicción personal e interna de ser hombre o mujer, tal como la | confusion tipica del reconocedor: hombre -> nombre · vocabulario no visto en el corpus: convicción |
| `circular_812_identidad_genero/pagina_004.txt:30` | 4 | entrega un parámetro general de lo que se entiende por discriminación arbitraria®, sino que | simbolo ajeno al documento legal: '®' · vocabulario no visto en el corpus: parámetro |
| `circular_812_identidad_genero/pagina_008.txt:20` | 4 | niña, niño o estudiante quien decida cuándo y a quién comparte su identidad de género. | confusion tipica del reconocedor: cuándo -> cuando · a un caracter de una palabra del corpus: comparte -> comparten |
| `circular_812_identidad_genero/pagina_009.txt:40` | 4 | considerar baños inclusivos13 u otras alternativas consensuadas por las partes | digito pegado a palabra (llamada a nota): inclusivos13 · a un caracter de una palabra del corpus: baños -> años · vocabulario no visto en el corpus: consensuadas |
| `circular_812_identidad_genero/pagina_001.txt:1` | 3 | Superintendencla | confusion tipica del reconocedor: superintendencla -> superintendencia |
| `circular_812_identidad_genero/pagina_001.txt:34` | 3 | Aseguramiento de la Calidad de la Educación Parvularja, Básica y Media y su Fiscalización; en l | confusion tipica del reconocedor: parvularja -> parvularia |
| `circular_812_identidad_genero/pagina_003.txt:38` | 3 | su ineludible e integral generalidad3. | digito pegado a palabra (llamada a nota): generalidad3 · vocabulario no visto en el corpus: ineludible, generalidad |
| `circular_812_identidad_genero/pagina_003.txt:54` | 3 | content/uploads/2018/10/Orientaciones-diversidad-sexual-y-de-g%C3%A9nero-LGTBl.-Mineduc-2017.pd | digito pegado a palabra (llamada a nota): 9nero · vocabulario no visto en el corpus: content, uploads, lgtbl, mineduc |
| `circular_812_identidad_genero/pagina_005.txt:11` | 3 | civil, penal o administrativa que pudiera emanar de esta contravención. | confusion tipica del reconocedor: emanar -> emanan |
| `circular_812_identidad_genero/pagina_005.txt:4` | 3 | de género, incorpora, dentro de los principios que informan el derecho a la identidad de | confusion tipica del reconocedor: informan -> informar |
| `circular_812_identidad_genero/pagina_005.txt:49` | 3 | ® Artículo 25 de la Ley N° 21.120. | simbolo ajeno al documento legal: '®' |
| `circular_812_identidad_genero/pagina_003.txt:32` | 2 | a) DIGnIDAD DEL SER HUMANO. De conformidad a lo establecido en el literal n) de la Ley | mayuscula intercalada: DIGnIDAD |

### `rex_482_reglamentos_b` (85 líneas)

| Ruta | Peso | Línea | Motivo |
|---|---:|---|---|
| `rex_482_reglamentos_b/pagina_002.txt:17` | 5 | IV. MODELO DE FISCALIZACION CON ENFOQUE EN DERECHOS | confusion tipica del reconocedor: fiscalizacion -> fiscalización · vocabulario no visto en el corpus: modelo · tilde o enie perdida: fiscalizacion -> fiscalización |
| `rex_482_reglamentos_b/pagina_002.txt:13` | 4 | INDICE | confusion tipica del reconocedor: indice -> índice · tilde o enie perdida: indice -> índice |
| `rex_482_reglamentos_b/pagina_002.txt:53` | 4 | 4. DERECHOS Y BIENES JURÍDICOS INVOLUCRADOS EN LA OBLIGACION DE | confusion tipica del reconocedor: obligacion -> obligación · tilde o enie perdida: obligacion -> obligación |
| `rex_482_reglamentos_b/pagina_002.txt:56` | 4 | 5. CONTENIDO MINIMO DE LOS REGLAMENTOS INTERNOS. | confusion tipica del reconocedor: minimo -> mínimo · tilde o enie perdida: minimo -> mínimo |
| `rex_482_reglamentos_b/pagina_003.txt:10` | 4 | ENSENANZA BÁSICA Y MEDIA CON | confusion tipica del reconocedor: ensenanza -> enseñanza · tilde o enie perdida: ensenanza -> enseñanza |
| `rex_482_reglamentos_b/pagina_003.txt:60` | 4 | 1. APROBACION, ACTUALIZACIONES Y MODIFICACIONES | confusion tipica del reconocedor: aprobacion -> aprobación · tilde o enie perdida: aprobacion -> aprobación |
| `rex_482_reglamentos_b/pagina_003.txt:69` | 4 | DETECCION | confusion tipica del reconocedor: deteccion -> detección · tilde o enie perdida: deteccion -> detección |
| `rex_482_reglamentos_b/pagina_003.txt:72` | 4 | VULNERACION | confusion tipica del reconocedor: vulneracion -> vulneración · tilde o enie perdida: vulneracion -> vulneración |
| `rex_482_reglamentos_b/pagina_004.txt:29` | 4 | LOS REGLAMENTOS INTERNOS, POR SER CONTRARIAS A LA LEGISLACION VIGENTE. | confusion tipica del reconocedor: legislacion -> legislación · tilde o enie perdida: legislacion -> legislación |
| `rex_482_reglamentos_b/pagina_009.txt:11` | 4 | ENSENANZA BÁSICA Y MEDIA CON | confusion tipica del reconocedor: ensenanza -> enseñanza · tilde o enie perdida: ensenanza -> enseñanza |
| `rex_482_reglamentos_b/pagina_010.txt:11` | 4 | ENSENANZA BASICA Y MEDIA CON | confusion tipica del reconocedor: ensenanza -> enseñanza, basica -> básica · tilde o enie perdida: ensenanza -> enseñanza, basica -> básica |
| `rex_482_reglamentos_b/pagina_012.txt:25` | 4 | elementos que podrían atenuar o agravar la sanción aplicable, considerando la etapa de | confusion tipica del reconocedor: agravar -> agravan · a un caracter de una palabra del corpus: atenuar -> atentar |
| `rex_482_reglamentos_b/pagina_013.txt:18` | 4 | reviamente aquellas de menor intensidad antes de utilizar las más aravosas16 | digito pegado a palabra (llamada a nota): aravosas16 · a un caracter de una palabra del corpus: reviamente -> previamente, aravosas -> gravosas · vocabulario no visto en el corpus: intensidad |
| `rex_482_reglamentos_b/pagina_014.txt:15` | 4 | establecimiento, y a expresar su opinión'®; los padres, madres y apoderados gozan del | simbolo ajeno al documento legal: '®' · a un caracter de una palabra del corpus: gozan -> goza |
| `rex_482_reglamentos_b/pagina_017.txt:45` | 4 | con sujecion a los procedimientos racionales | confusion tipica del reconocedor: sujecion -> sujeción, racionales -> nacionales · tilde o enie perdida: sujecion -> sujeción |
| `rex_482_reglamentos_b/pagina_018.txt:63` | 4 | generales y estandares de aprendizaje que | confusion tipica del reconocedor: estandares -> estándares · tilde o enie perdida: estandares -> estándares |
| `rex_482_reglamentos_b/pagina_020.txt:11` | 4 | ENSENANZA BASICA Y MEDIA CON | confusion tipica del reconocedor: ensenanza -> enseñanza, basica -> básica · tilde o enie perdida: ensenanza -> enseñanza, basica -> básica |
| `rex_482_reglamentos_b/pagina_022.txt:11` | 4 | ENSENANZA BASICA Y MEDIA CON | confusion tipica del reconocedor: ensenanza -> enseñanza, basica -> básica · tilde o enie perdida: ensenanza -> enseñanza, basica -> básica |
| `rex_482_reglamentos_b/pagina_022.txt:43` | 4 | trata de conductas que resultan agresivas o que demuestren un conocimiento que los niños y niña | confusion tipica del reconocedor: resultan -> resultar · vocabulario no visto en el corpus: agresivas, naturalmente |
| `rex_482_reglamentos_b/pagina_026.txt:12` | 4 | ENSENANZA BÁSICA Y MEDIA CON | confusion tipica del reconocedor: ensenanza -> enseñanza · tilde o enie perdida: ensenanza -> enseñanza |
| `rex_482_reglamentos_b/pagina_026.txt:15` | 4 | Los viajes5° o giras de estudio y las salidas pedagógicas, constituyen una actividad organizada | digito pegado a palabra (llamada a nota): viajes5 · a un caracter de una palabra del corpus: salidas -> salinas · vocabulario no visto en el corpus: viajes |
| `rex_482_reglamentos_b/pagina_026.txt:36` | 4 | . En virtud del mismo principio, no se podra | confusion tipica del reconocedor: podra -> podrá · tilde o enie perdida: podra -> podrá |
| `rex_482_reglamentos_b/pagina_027.txt:43` | 4 | Los Reglamentos Internos deben, asimismo, detallar las conductas que merecen | confusion tipica del reconocedor: detallar -> detallan · vocabulario no visto en el corpus: merecen |
| `rex_482_reglamentos_b/pagina_028.txt:12` | 4 | ENSENANZA BASICA Y MEDIA CON | confusion tipica del reconocedor: ensenanza -> enseñanza, basica -> básica · tilde o enie perdida: ensenanza -> enseñanza, basica -> básica |
| `rex_482_reglamentos_b/pagina_030.txt:11` | 4 | ENSENANZA BÁSICA Y MEDIA CON | confusion tipica del reconocedor: ensenanza -> enseñanza · tilde o enie perdida: ensenanza -> enseñanza |
| `rex_482_reglamentos_b/pagina_031.txt:10` | 4 | ENSENANZA BASICA Y MEDIA CON | confusion tipica del reconocedor: ensenanza -> enseñanza, basica -> básica · tilde o enie perdida: ensenanza -> enseñanza, basica -> básica |
| `rex_482_reglamentos_b/pagina_034.txt:11` | 4 | ENSENANZA BÁSICA Y MEDIA CON | confusion tipica del reconocedor: ensenanza -> enseñanza · tilde o enie perdida: ensenanza -> enseñanza |
| `rex_482_reglamentos_b/pagina_036.txt:11` | 4 | ENSENANZA BÁSICA Y MEDIA CON | confusion tipica del reconocedor: ensenanza -> enseñanza · tilde o enie perdida: ensenanza -> enseñanza |
| `rex_482_reglamentos_b/pagina_037.txt:13` | 4 | ANEXO 2: CONTENIDO MINIMO DEL PROTOCOLO FRENTE A AGRESIONES | confusion tipica del reconocedor: minimo -> mínimo · tilde o enie perdida: minimo -> mínimo |
| `rex_482_reglamentos_b/pagina_038.txt:12` | 4 | ENSENANZA BASICA Y MEDIA CON | confusion tipica del reconocedor: ensenanza -> enseñanza, basica -> básica · tilde o enie perdida: ensenanza -> enseñanza, basica -> básica |
| `rex_482_reglamentos_b/pagina_039.txt:50` | 4 | de manera inoportuna sobre los hechos, evitando vulnerar sus derechos. | confusion tipica del reconocedor: vulnerar -> vulneran · vocabulario no visto en el corpus: inoportuna |
| `rex_482_reglamentos_b/pagina_040.txt:14` | 4 | siguientes al momento en que tomaren conocimiento del hecho™ | simbolo ajeno al documento legal: '™' · a un caracter de una palabra del corpus: tomaren -> tomarán |
| `rex_482_reglamentos_b/pagina_041.txt:10` | 4 | ENSENANZA BÁSICA Y MEDIA CON | confusion tipica del reconocedor: ensenanza -> enseñanza · tilde o enie perdida: ensenanza -> enseñanza |
| `rex_482_reglamentos_b/pagina_044.txt:15` | 4 | ANEXO 6: CONTENIDO MINIMO DEL PROTOCOLO DE ACTUACION FRENTE A | confusion tipica del reconocedor: minimo -> mínimo, actuacion -> actuación · tilde o enie perdida: minimo -> mínimo, actuacion -> actuación |
| `rex_482_reglamentos_b/pagina_048.txt:32` | 4 | REPONENE DE CHIL SEBASTIÁN IZQUIERDO RAMİREZ | letra fuera del alfabeto espanol: 'İ' · vocabulario no visto en el corpus: reponene, izquierdo, rami̇rez |
| `rex_482_reglamentos_b/pagina_007.txt:40` | 3 | Entoque en Derechos y deja sin efecto parcialmente el Oficio N° 0182, de 8 de abril de | confusion tipica del reconocedor: entoque -> enfoque |
| `rex_482_reglamentos_b/pagina_008.txt:2` | 3 | de Chite | confusion tipica del reconocedor: chite -> chile |
| `rex_482_reglamentos_b/pagina_009.txt:40` | 3 | concepto que se aplica en todos los ámbitos y respecto de todos quiénes se relacionan y | confusion tipica del reconocedor: quiénes -> quienes |
| `rex_482_reglamentos_b/pagina_011.txt:21` | 3 | de integración e inclusión', que propenden a eliminar todas las formas de discriminación | confusion tipica del reconocedor: propenden -> propender |
| `rex_482_reglamentos_b/pagina_011.txt:23` | 3 | diversidad®, que exige el respeto de las distintas realidades culturales, religiosas y sociales | simbolo ajeno al documento legal: '®' |
| `rex_482_reglamentos_b/pagina_011.txt:24` | 3 | las familias que integran la comunidad educativa; del principio de interculturalidad®, que exig | simbolo ajeno al documento legal: '®' |
| `rex_482_reglamentos_b/pagina_014.txt:20` | 3 | comunidad escolar21 | digito pegado a palabra (llamada a nota): escolar21 · linea corta sin cierre entre dos lineas largas (posible corte) |
| `rex_482_reglamentos_b/pagina_014.txt:43` | 3 | comunidad contribuir a su desarrollo y perfeccionamiento24, de lo cual se deriva que, todos los | digito pegado a palabra (llamada a nota): perfeccionamiento24 · a un caracter de una palabra del corpus: deriva -> derive |
| `rex_482_reglamentos_b/pagina_015.txt:14` | 3 | protesionales y asistentes de la educación, entre otros, brindar un trato digno, respetuoso y | confusion tipica del reconocedor: protesionales -> profesionales |
| `rex_482_reglamentos_b/pagina_016.txt:24` | 3 | con sujeción a los procedimientos racionales | confusion tipica del reconocedor: racionales -> nacionales |
| `rex_482_reglamentos_b/pagina_020.txt:44` | 3 | educativas31 | digito pegado a palabra (llamada a nota): educativas31 · linea corta sin cierre entre dos lineas largas (posible corte) |
| `rex_482_reglamentos_b/pagina_021.txt:14` | 3 | con lo dispuesto respecto a las alumnas embarazadas, madres y padres estudiantes32, y los | digito pegado a palabra (llamada a nota): estudiantes32 · vocabulario no visto en el corpus: embarazadas |
| `rex_482_reglamentos_b/pagina_024.txt:32` | 3 | esta Superintendencia47 | digito pegado a palabra (llamada a nota): Superintendencia47 · linea corta sin cierre entre dos lineas largas (posible corte) |
| `rex_482_reglamentos_b/pagina_025.txt:27` | 3 | educativas especiales48 | digito pegado a palabra (llamada a nota): especiales48 · linea corta sin cierre entre dos lineas largas (posible corte) |
| `rex_482_reglamentos_b/pagina_028.txt:30` | 3 | proyecto educativo, las que se deben enmarcar en la normativa vigente, teniendo como | confusion tipica del reconocedor: enmarcar -> enmarcan |
| `rex_482_reglamentos_b/pagina_029.txt:15` | 3 | definitivas, salvo que el sostenedor le otorgue al Consejo carácter resolutivo58 en dichas | digito pegado a palabra (llamada a nota): resolutivo58 · vocabulario no visto en el corpus: definitivas |
| `rex_482_reglamentos_b/pagina_029.txt:40` | 3 | El Plan de Gestión es el instrumento en el cual constan las iniciativas del Consejo Escolar o | confusion tipica del reconocedor: constan -> constar |
| `rex_482_reglamentos_b/pagina_030.txt:44` | 3 | establecimientos deberán conservar los documentos que acrediten su realización®1. | simbolo ajeno al documento legal: '®' |
| `rex_482_reglamentos_b/pagina_031.txt:17` | 3 | la comunidad educativa62 | digito pegado a palabra (llamada a nota): educativa62 · linea corta sin cierre entre dos lineas largas (posible corte) |
| `rex_482_reglamentos_b/pagina_031.txt:40` | 3 | promover la creación de estamentos tales como Centros de Alumnos®3, Centros de Padres y | simbolo ajeno al documento legal: '®' |
| `rex_482_reglamentos_b/pagina_031.txt:41` | 3 | Apoderados64, | digito pegado a palabra (llamada a nota): Apoderados64 · linea corta sin cierre entre dos lineas largas (posible corte) |
| `rex_482_reglamentos_b/pagina_031.txt:42` | 3 | Consejos de Profesores, Consejos Escolares65, Comités de Buena | digito pegado a palabra (llamada a nota): Escolares65 · vocabulario no visto en el corpus: comités |
| `rex_482_reglamentos_b/pagina_033.txt:23` | 3 | anexos, en su sitio web o mantenerlo disponible en el recinto69, de modo que se asegure su | digito pegado a palabra (llamada a nota): recinto69 · vocabulario no visto en el corpus: mantenerlo |
| `rex_482_reglamentos_b/pagina_043.txt:2` | 3 | de cielo | confusion tipica del reconocedor: cielo -> ciclo |
| `rex_482_reglamentos_b/pagina_044.txt:38` | 3 | Las medidas formativas®°, pedagógicas y/o de apoyo psicosocial aplicables a | simbolo ajeno al documento legal: '®' |
| `rex_482_reglamentos_b/pagina_047.txt:22` | 3 | rendimiento académico de los estudiantes sin respetar los requisitos legales®3, o por falta | simbolo ajeno al documento legal: '®' |
| `rex_482_reglamentos_b/pagina_048.txt:40` | 3 | - División de Comunicaciones у Denuncias | letra fuera del alfabeto espanol: 'у' |
| `rex_482_reglamentos_b/pagina_010.txt:22` | 2 | existencia de una supervisión adecuada4. | digito pegado a palabra (llamada a nota): adecuada4 |
| `rex_482_reglamentos_b/pagina_011.txt:38` | 2 | a resguardar el principio de no discriminación arbitraria en el proyecto educativo13. | digito pegado a palabra (llamada a nota): educativo13 |
| `rex_482_reglamentos_b/pagina_012.txt:21` | 2 | medida o sanción asignada a ese hecho14 | digito pegado a palabra (llamada a nota): hecho14 |
| `rex_482_reglamentos_b/pagina_014.txt:17` | 2 | proyecto educativo19; los profesionales y técnicos de la educación, tienen derecho a proponer | digito pegado a palabra (llamada a nota): educativo19 |
| `rex_482_reglamentos_b/pagina_014.txt:18` | 2 | las iniciativas que estimaren útiles para el progreso del establecimiento2o; mientras que los | digito pegado a palabra (llamada a nota): establecimiento2 |
| `rex_482_reglamentos_b/pagina_014.txt:41` | 2 | 2.10. Responsabilidad23 | digito pegado a palabra (llamada a nota): Responsabilidad23 |
| `rex_482_reglamentos_b/pagina_021.txt:16` | 2 | de Educación34 referidas al uso de uniforme escolar de estudiantes migrantes 35 | digito pegado a palabra (llamada a nota): Educación34 |
| `rex_482_reglamentos_b/pagina_021.txt:21` | 2 | 5.6.1. Plan Integral de Seguridad Escolar36 | digito pegado a palabra (llamada a nota): Escolar36 |
| `rex_482_reglamentos_b/pagina_021.txt:29` | 2 | por medio de una metodología de trabajo, los aspectos preventivos y de respuesta38 que | digito pegado a palabra (llamada a nota): respuesta38 |
| `rex_482_reglamentos_b/pagina_022.txt:30` | 2 | sexual41 y agresiones sexuales dentro del contexto educativo42 que atenten contra la | digito pegado a palabra (llamada a nota): sexual41, educativo42 |
| `rex_482_reglamentos_b/pagina_022.txt:34` | 2 | comunidad educativa de acuerdo a las particularidades del nivel y modalidad educativa43. | digito pegado a palabra (llamada a nota): educativa43 |
| `rex_482_reglamentos_b/pagina_023.txt:43` | 2 | o más adultos de la comunidad educativa como responsables44. | digito pegado a palabra (llamada a nota): responsables44 |
| `rex_482_reglamentos_b/pagina_023.txt:47` | 2 | de toda la comunidad educativa45. | digito pegado a palabra (llamada a nota): educativa45 |
| `rex_482_reglamentos_b/pagina_026.txt:35` | 2 | considerados faltas y cuál será su gravedad51. | digito pegado a palabra (llamada a nota): gravedad51 |
| `rex_482_reglamentos_b/pagina_026.txt:37` | 2 | incluir ninguna de las medidas disciplinarias prohibidas por ley52. | digito pegado a palabra (llamada a nota): ley52 |
| `rex_482_reglamentos_b/pagina_027.txt:52` | 2 | desarrollo integral de los estudiantes54 | digito pegado a palabra (llamada a nota): estudiantes54 |
| `rex_482_reglamentos_b/pagina_028.txt:21` | 2 | de conflicto56. | digito pegado a palabra (llamada a nota): conflicto56 |
| `rex_482_reglamentos_b/pagina_029.txt:47` | 2 | establecimiento, así como todos los documentos que acrediten su implementación59 | digito pegado a palabra (llamada a nota): implementación59 |
| `rex_482_reglamentos_b/pagina_031.txt:45` | 2 | obstáculo al mismo66. | digito pegado a palabra (llamada a nota): mismo66 |
| `rex_482_reglamentos_b/pagina_032.txt:22` | 2 | a lo establecido en la Constitución y la leyo7; e incorporar las disposiciones que permitan el | digito pegado a palabra (llamada a nota): leyo7 |
| `rex_482_reglamentos_b/pagina_032.txt:41` | 2 | establecimiento, en un plazo de 30 días68 | digito pegado a palabra (llamada a nota): días68 |
| `rex_482_reglamentos_b/pagina_035.txt:48` | 2 | deberán ser aplicadas conforme la gravedad del caso4. Entre estas medidas se | digito pegado a palabra (llamada a nota): caso4 |
| `rex_482_reglamentos_b/pagina_010.txt:28` | 1 | en el goce de sus derechos. En este sentido, el Comité de los Derechos del Nino de las | tilde o enie perdida: nino -> niño |

## 5. Membretes: por dónde empezar

El traspaso v01 dejó la regla aprendida: *cuerpo confiable, membretes no; la revisión
humana empieza por encabezados*. Esta corrida la confirma en cifras: el membrete
concentra 360 de las 3512 líneas del texto reconocido (10%), y en `rex_482_reglamentos_b` son 303 líneas
repetidas casi idénticas, que ningún artículo cita.

Sugerencia de orden de trabajo, de mayor a menor rendimiento por minuto:


1. **`rex_482_reglamentos_b`** — 85 líneas del tramo fuerte en 48 páginas, 303 líneas de membrete.
2. **`circular_812_identidad_genero`** — 15 líneas del tramo fuerte en 10 páginas, 10 líneas de membrete.
3. **`circular_193_estudiantes_embarazadas`** — 7 líneas del tramo fuerte en 16 páginas, 44 líneas de membrete.
4. **`circular_586_tea`** — 1 líneas del tramo fuerte en 1 páginas, 3 líneas de membrete.

El membrete se ataca primero dentro de cada documento: es un patrón repetido, así que
una sola decisión de forma resuelve todas sus páginas. La circular 812 es además la que
el traspaso v01 propone para estrenar el flujo, por corta y de consulta frecuente.

## 6. Tramo débil: qué es y por qué no encabeza la lista

596 líneas más quedaron marcadas solo por motivos débiles (`vocabulario no visto`, `a un carácter del corpus`, `línea corta sin cierre`). No se listan una por una porque el control positivo midió que marcan 2 de cada 3 líneas limpias: como lista de trabajo desperdiciarían más tiempo del que ahorran.

Sirven para otra cosa: **barrido**, cuando alguien quiera leer un documento entero con
un mapa de calor en vez de una lista. El detector vive en
`50_documentacion/andamios/20260826_prerevision_ocr_detector.R` (solo lectura, sin efectos)

## 7. Lo que este documento no cubre

- **`dictamen_078_detectores_revision_mochilas`.** Es el quinto documento en
  `ocr_pendiente_revision`, pero su estado lo declaró la curaduría (tiene capa de texto
  de PDF) y no existe carpeta suya en `20_insumos/ocr/`. Queda fuera del alcance
  declarado de T4, que es de solo lectura sobre esa carpeta.
- **Errores semánticos.** Una palabra bien escrita en el lugar equivocado, un número de
  norma correcto pero cambiado, un párrafo entero omitido por el reconocedor: nada de
  eso deja huella léxica y este detector no lo ve.
- **Segunda opinión de otro motor.** No disponible en la máquina (§1).
- **Ningún cambio de estado.** Mover un documento a `ocr_revisado` es firma humana; este
  documento no la sustituye ni la anticipa.
