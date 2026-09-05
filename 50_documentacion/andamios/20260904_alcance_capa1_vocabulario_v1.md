# Alcance de la capa 1: vocabulario controlado para sugerir conceptos mientras se escribe (v1)

Proyecto `slep_normativa_convivencia`. Fecha: 2026-09-05. Autor: A1, encargo v9
(`50_documentacion/andamios/20260904_encargo_alcance_motor_busqueda_v1.md`, sección A1).

| Entregable | Ruta |
|---|---|
| Este documento | `50_documentacion/andamios/20260904_alcance_capa1_vocabulario_v1.md` |
| Prototipo (R, ejecutable de punta a punta) | `50_documentacion/andamios/20260904_prototipo_vocabulario.R` (663 líneas, `wc -l`) |
| Índice construido | `50_documentacion/andamios/lab_motor_v9/vocabulario.json` |
| Artefactos de medición (todos con prefijo `a1_`) | `lab_motor_v9/a1_salida_prototipo.txt` (salida literal completa de la corrida), `a1_medidas.json`, `a1_alias_procedencia.csv`, `a1_alias_prueba.csv`, `a1_prefijos.csv`, `a1_cobertura_unigramas.csv`, `a1_cobertura_bigramas.csv`, `a1_consultas_proxy.csv`, `a1_vocabulario.json.gz`, `a1_vocabulario_sin_articulos.json` (+ `.gz`) |

Invocación, desde la raíz: `Rscript 50_documentacion/andamios/20260904_prototipo_vocabulario.R`.
La corrida que sustenta este documento terminó con código 0 el 2026-09-05 08:11 (segunda corrida; la primera, 08:09, difería solo en la regla de desambiguación de artículos de §4.3, y el JSON es idéntico: `md5 -q vocabulario.json` = `d8ef55cd51bb90fed890ca3b935a1c8e`, 435.763 bytes en ambas).

Convenciones: **medido** = recontado en la corrida citada; **calculado** = aritmética sobre un valor medido; **hipótesis** = no verificado, con su comando. Las secciones numeradas `§N` de `a1_salida_prototipo.txt` se citan como `salida §N`. El prototipo es de laboratorio: no toca el pipeline, no escribe en `20_insumos/` ni en `40_salidas/`, y su carpeta es desechable.

---

## 0. Decisiones, en corto

1. El vocabulario tiene **892 entradas** de cuatro tipos (17 temas, 25 normas, 806 encabezados con ancla, 44 del glosario), todas derivadas de artefactos existentes y cada alias con procedencia (medido, salida §4).
2. Pesa **425,5 KB sin comprimir y 21,6 KB con gzip**; a 3 Mbps son **0,059 s** comprimido (calculado, §5). Se carga **completo, en un solo archivo**, diferido al primer foco en el buscador; la fragmentación queda como contingencia si el servidor no comprime.
3. Sin LLM y sin backend: la resolución es un prefijado por tokens con reglas declaradas (§4.3). Cuatro casos plantados pasan dentro del propio script (§6).
4. El texto OCR sin revisar y el glosario sin firma **no se ocultan: se rotulan**. Los encabezados de página OCR quedan fuera de las sugerencias por defecto; las normas OCR aparecen con su aviso.
5. La cobertura del lenguaje del equipo es la debilidad real de la capa: 11 de 23 consultas proxy resuelven con la semántica AND, y las 12 preguntas en forma de oración no resuelven ninguna (§2). Lo que falta no es más código sino una **lista de alias curada y firmada** (§2.4).

---

## 1. Tarea 1: inventario del universo del vocabulario

### 1.1 Páginas temáticas

**17** páginas (`ls 40_salidas/sitio_src/tema-*.qmd | wc -l` = 17). El nombre canónico es la clave de `TEMAS_PALABRAS_CLAVE` en `10_utils/10_configuracion.R`; el archivo es `tema-<slugificar(clave)>.qmd`. Verificado programáticamente (salida §3): el conjunto de las 17 claves slugificadas es igual al conjunto de archivos, y el `title:` del front matter coincide con la clave en 17/17.

| Tema (nombre canónico) | Destino | Normas | Palabras clave |
|---|---|---:|---:|
| convivencia escolar | `tema-convivencia-escolar.html` | 14 | 3 |
| violencia y acoso escolar | `tema-violencia-y-acoso-escolar.html` | 11 | 5 |
| medidas disciplinarias | `tema-medidas-disciplinarias.html` | 22 | 5 |
| inclusión y no discriminación | `tema-inclusion-y-no-discriminacion.html` | 19 | 4 |
| derechos de la niñez | `tema-derechos-de-la-ninez.html` | 11 | 4 |
| participación de la comunidad | `tema-participacion-de-la-comunidad.html` | 20 | 4 |
| identidad de género | `tema-identidad-de-genero.html` | 6 | 7 |
| embarazo y maternidad | `tema-embarazo-y-maternidad.html` | 9 | 5 |
| trastorno del espectro autista | `tema-trastorno-del-espectro-autista.html` | 3 | 3 |
| uso de dispositivos móviles | `tema-uso-de-dispositivos-moviles.html` | 3 | 3 |
| uniforme y presentación personal | `tema-uniforme-y-presentacion-personal.html` | 4 | 2 |
| formación ciudadana | `tema-formacion-ciudadana.html` | 4 | 2 |
| jornada escolar | `tema-jornada-escolar.html` | 7 | 2 |
| estatuto del personal | `tema-estatuto-del-personal.html` | 13 | 3 |
| reconocimiento oficial | `tema-reconocimiento-oficial.html` | 15 | 2 |
| seguridad escolar | `tema-seguridad-escolar.html` | 4 | 6 |
| revisión de pertenencias | `tema-revision-de-pertenencias.html` | 2 | 5 |

"Normas" es el recuento de entradas del catálogo cuyo campo `tema` contiene la clave (salida §3); "Palabras clave" es `length(TEMAS_PALABRAS_CLAVE[[tema]])`, 65 en total (salida §4, tabla de procedencia). Esas 65 palabras son los alias de tema del vocabulario: es lo que hace que "celu" llegue a "uso de dispositivos móviles" (alias `celular`) y "mochila" a "revisión de pertenencias" (alias `revision de mochilas`).

### 1.2 Términos del glosario

Fuente: `20_insumos/curaduria/piezas/borradores/glosario.md` (321 líneas, `wc -l`), leído sin modificar. Front matter: `estado: borrador`, `validado_por: null` (salida §3).

| Cifra | Valor | Cómo |
|---|---:|---|
| Encabezados `### ` con enlace "Definido en" | **39** | salida §3; coincide con la línea "Definiciones legales detectadas en el corpus: **39**" del propio archivo |
| Términos distintos (hay repetidos con anclas distintas) | **35** | `n_distinct(termino)`, salida §3 |
| Anclados en transcripción OCR en revisión (no citables) | **5** | marca literal `*transcripción OCR en revisión*` en la línea "Definido en": 3 en `rex_482_reglamentos_b`, 2 en `circular_812_identidad_genero` |
| Con fuente normativa citable | **34** | 39 menos 5 |
| Pendientes de fuente (tabla "## Pendientes de fuente") | **5** | cancelación de matrícula, medida formativa, debido proceso escolar, protocolo de actuación, dupla psicosocial |

Distribución de los 39 por norma de la ancla (salida §3): dto_453 8, dfl_1 5, ley_21430 5, dfl_315 4, ley_21809 4, rex_482_reglamentos_b 3 (OCR), circular_812 2 (OCR), ley_20536 2, ley_20845 2, ley_21545 2, ley_20370 1, ley_21801 1.

Dos observaciones sobre la forma de los términos, que el vocabulario hereda tal cual (no se corrigen aquí porque el archivo es de escritura humana): (a) el generador de borradores recortó el encabezado a 60 caracteres incluyendo el inicio de la definición, de modo que 20 de los 39 rezan como "acoso escolar toda acción u omisión constitutiva de agresión"; el límite del término no es derivable y queda para la validación; (b) hay una entrada "discriminación arbitraria®" (con signo de marca registrada, artefacto del OCR de la circular 812).

### 1.3 Encabezados de artículo con `id` en el sitio generado

Fuente: `40_salidas/sitio/*.html` (47 archivos, `ls 40_salidas/sitio/*.html | wc -l`; mtime 2026-08-27 12:38, misma corrida que `catalogo.json`, `stat -f '%Sm %N'`). Quarto va con `section-divs: false`, así que el `id` vive en el `<h2>`.

| Cifra | Valor | Cómo |
|---|---:|---|
| `<h2 id="…">` en los 47 HTML | **958** | `grep -ohE '<h2 id="[^"]+"' 40_salidas/sitio/*.html \| wc -l` = 958; salida §3 |
| En las 25 páginas de norma, descontando `toc-title` y `relacionadas` | **806** | salida §3 |
| Segmentos con `id` en los 25 JSON | **806** | salida §3 |
| Con `es_articulo = TRUE` (artículos propiamente tales) | **682** | salida §3; `catalogo.json` declara 682 |
| Páginas OCR sin revisar (`id` `ocr-pagina-NNN`) | **84 en 5 documentos** | salida §3: circular_193 (16), circular_586 (1), circular_812 (10), dictamen_078 (9), rex_482_reglamentos_b (48) |
| Otros segmentos no numerados | **40** | 806 menos 682 menos 84: 15 `preambulo`, 2 `documento`, 23 secciones de dictamen (`materia`, `antecedentes`, `fuentes`, `concordancias`, `num-N`) |

**Enunciado universal, con su comando:** en las 25 normas, el conjunto de `id` del JSON es igual al conjunto de `id` de los `<h2>` de su página (`setequal` por norma, salida §3: "conjunto de ids JSON == conjunto de ids h2 en 25/25 normas"). Es la garantía de que un destino `<slug>.html#<id>` construido desde el JSON existe en el sitio.

Distribución por norma (salida §3, `segmentos`/`artículos`): dfl_1 218/217, ley_21430 94/93, ley_20370 83/82, dto_453 65/64, rex_482_reglamentos_b 48/0 (OCR), ley_21809 47/46, dfl_315 39/38, ley_20845 38/37, ley_21545 31/30, dto_565 21/20, ley_19979 19/18, circular_193 16/0 (OCR), dto_24 15/14, circular_812 10/0 (OCR), dictamen_71 10/0, dictamen_078 9/0 (OCR), dictamen_52_77 9/0, dto_215 9/8, ley_20536 8/7, ley_21801 6/5, dictamen_065 4/0, ley_20911 4/3, circular_586 1/0 (OCR), rex_181 1/0, rex_482_instrucciones 1/0. Un solo documento (el DFL 1) concentra 217 de los 682 artículos (32 %, calculado).

### 1.4 Nombres, rótulos y alias históricos de las normas

**Rótulo corto.** Se reproduce la regla del sitio (`formatear_numero()` y `ROL_GRUPO` de `10_utils/10_utils.R`): "Ley 21.801", "Decreto supremo 215", "Dictamen 065", y para el acto en dos archivos "Resolución exenta 482 (resolución)" y "Resolución exenta 482 (cuerpo)". La función se reimplementó en el prototipo con `[[ ]]` (`nombre_corto_a1`) para no llamar código que accede con `$` a estructuras leídas de disco.

**Alias derivados, con procedencia.** 260 alias sobre 25 normas y 17 temas (`a1_alias_procedencia.csv`, 261 líneas con cabecera; salida §4):

| Fuente del alias | Alias | Ejemplo |
|---|---:|---|
| `TEMAS_PALABRAS_CLAVE` (temas) | 65 | `celular`, `revision de mochilas` |
| `catalogo.json` tipo y `TIPOS_NORMA` | 50 | `rex`, `Resolución exenta` |
| `catalogo.json` número (crudo, con punto de miles, sin ceros) | 36 | `21801`, `21.801`; `065`, `65` |
| `relaciones.json`, `cita_literal` de las 46 remisiones (cómo el corpus nombra a la norma) | 32 | `REX N° 482`, `Dictamen N° 65`, `LEY 19979` |
| slug (materia de la URL) | 25 | `celulares`, `revision mochilas` |
| `20_insumos/normativa/README.md`, nombre original del archivo | 24 | `20370 LGE`, `19979 JEC`, `DTO 565 CGPMA`, `21545 LEY TEA` |
| `catalogo.json` título | 21 | los 4 escaneos no tienen título |
| README, tabla de escaneos ("qué es") | 4 | `Cuerpo de la Circular 482 sobre reglamentos internos` |
| `metadatos_curados.json`, `grupos_acto.nota_colapso` | 2 | `incluye el cuerpo del reglamento` |
| Texto del corpus: denominación pegada a un número de ley del corpus | 1 | `Ley TEA` (ley_21545) |

Los nombres originales del README son los **alias históricos del propio equipo** (así llegaron los archivos): LGE, JEC, SEP, TEA, RO, CGPMA. Es la única fuente de "LGE" y "JEC" del vocabulario; sin ella, `LGE` daría 0 (verificado en `a1_alias_prueba.csv`: `LGE` → Ley 20.370, 1 sugerencia).

**El caso "circular 482" contra "REX 482".** Evidencia recogida en esta sesión:

- Fuera del corpus: `grep -rniE 'circular\s*(n[°º]?\s*)?482' --include='*.md' --include='*.R' --include='*.json' --include='*.qmd' --include='*.txt' --include='*.yml' .` (excluyendo `.git` y el laboratorio) encuentra el rótulo en `glosario.md` (líneas 301, 309 a 312, 315), en `20_insumos/normativa/README.md` (tabla de escaneos), en `traspaso_cierre_v02.md` y en 8 documentos de andamios, entre ellos `20260826_borradores_rotulo_rex482_v1.md`, que ya lo documenta.
- Dentro del corpus: el dictamen 52/77 lo cita como **"Circular N° 482, de la Superintendencia de Educación"** (1 aparición, patrón `(?i)circular n° 482`, salida de `a1_explora_contextos.R`), y `relaciones.json` registra la remisión con `cita_literal` = **"REX N° 482"**. Es decir, el corpus mismo usa las dos formas.
- Resolución en el vocabulario: el título de `rex_482_instrucciones` ("…QUE APRUEBA CIRCULAR QUE IMPARTE INSTRUCCIONES…") y el "qué es" del README para `rex_482_reglamentos_b` ("Cuerpo de la Circular 482…") aportan el token `circular`; `grupos_acto` declara el destino canónico. `"circular 482"` y `"REX 482"` devuelven las mismas tres sugerencias y el mismo `destino_canonico` (§6).

**Búsqueda exhaustiva de otros alias**, con los comandos usados:

1. Denominaciones que el corpus pega a una norma, cinco patrones declarados en el script (`PATRONES_DENOMINACION`: "conocida como X", "en adelante X", "(X o SIGLA)", "denominada X,", "X (SIGLA)"), corridos sobre el texto de las 25 normas (salida §3, tabla "Denominaciones y siglas"). Resultado: 31 filas distintas. Las que nombran una norma **del corpus**: `Ley TEA` (ley 21.545, incorporada por traer el número al lado), `Ley General de Educación o LGE` (3 apariciones), `Ley de Inclusión Escolar o LIE` y `Ley de Inclusión o LIE` (1 y 1), `Ley de Convivencia Educativa` (en adelante, dictamen 078), `Ley de Garantías de la Niñez` (dictamen 71). Las que nombran algo que **no** está en el corpus: `Aula Segura` (ley 21.128), `Ley de Subvenciones o LS`, `LSAC` (ley 20.529), `SAE` (Sistema de Admisión Escolar), `CPR`, `OPD`, `PME`, `RBD`, `SIE`, `USE`, `IPC`, `FIDE`, `ENSI`, `DUDH`, `DIDH`, `CDN`.
2. Siglas en mayúsculas de 2 a 6 letras en el corpus, por frecuencia (`a1_explora_alias.R`, `str_extract_all("\\b[A-ZÑ]{2,6}\\b")`): tras descartar conectores y meses, las siglas con sentido de norma o institución son LGE 15, CPR 18, DTO 17, DFL 10, LSAC 7, SEP 7, SAE 6, RO 5. `SEP` aparece 7 veces, todas como abreviatura de septiembre en cabeceras de la BCN ("12-SEP-2009"), ninguna como Ley SEP.
3. El patrón "circular N contra resolución exenta N" en la otra resolución del corpus: `grep -rliE 'circular (n[°º] ?)?181'` sobre `20_insumos/curaduria`, `50_documentacion`, `40_salidas/datos` y los dos README, excluyendo `lab_motor_v9/`, da **1 archivo, que es el propio prototipo** (la consulta de prueba); es decir, **0 usos ajenos a A1**. Control positivo del mismo comando con `482`: **14 archivos**. La resolución 181 se llama "circular" en su propio título ("…APRUEBA CIRCULAR QUE IMPARTE INSTRUCCIONES SOBRE EL USO DE…"), así que `"circular 181"` resuelve igual a `rex_181_celulares.html` (2 sugerencias, `a1_alias_prueba.csv`) sin alias adicional.

**Prueba alias por alias** (`a1_alias_prueba.csv`, 22 consultas; control positivo `convivencia` = 5 sugerencias en el mismo bloque):

| Consulta | Sugerencias | Primera | Lectura |
|---|---:|---|---|
| `LIE` | **0** | (ninguna) | alias real no cubierto: la sigla no aparece en título, slug, README ni citas |
| `ley de inclusión` | 2 | Ley 20.845 | cubierto por título y slug |
| `ley de garantías` | 1 | Ley 21.430 | cubierto por slug |
| `ley de convivencia` | 1 | Ley 21.809 | cubierto por slug |
| `ley de subvenciones` | 1 | encabezado "4. …LEY DE SUBVENCIONES" del dictamen 52/77 | correcto: la norma no está en el corpus; solo existe ese encabezado |
| `JEC` | 1 | Ley 19.979 | cubierto solo por el nombre original del README |
| `SEP` | 4 | Ley 20.845 | cubierto por el nombre original `20845 INCLUSION SEP`; **ambiguo**: la Ley SEP es la 20.248, que no está en el corpus |
| `RO` | 1 | DFL 315 | nombre original `DLF 315 PÉRDIDA RO` |
| `SAE`, `LSAC` | **0**, **0** | | correcto: no son normas del corpus |
| `DFL 2` | 4 | Artículo 2º del DFL 1 | **no cubierto**: "DFL 2 de 2009" es la LGE (ley 20.370) y no hay alias; el número 2 cae en el artículo 2 del DFL 1 |
| `DFL 1` | 5 | DFL 1 | |
| `circular 181` | 2 | Resolución exenta 181 | |
| `dictamen 65` | 6 | **Dictamen 078**, con rótulo "sustituye a dictamen_065…"; el 065 va segundo con "sustituida por…" | el penalizador de vigencia ordena primero lo que rige hoy (§4.3, regla 7) |
| `dictamen 78` | 1 | Dictamen 078 | |
| `estatuto asistentes`, `asistentes de la educación` | 2, 2 | tema "estatuto del personal" | ver hallazgo 2 de §7: el slug del DFL 1 dice "asistentes" y su título dice "profesionales de la educación" |
| `reglamento interno` | 4 | tema "medidas disciplinarias" | |
| `protocolo` | 2 | glosario "protocolo de actuación" (pendiente, sin destino) | |
| `trans`, `nombre social`, `embarazada` | 6, 1, 2 | temas identidad de género / embarazo | |

---

## 2. Tarea 2: cobertura contra el lenguaje real de las consultas

**Aproximación declarada, no dato de uso.** No existe registro de consultas del sitio (Pagefind no lo guarda y no hay analítica). Se usan dos proxies, y se dice cuánto vale cada uno.

### 2.1 Proxy A: términos frecuentes del corpus que el vocabulario no sugiere

Método (salida §8): se tokenizan los textos de las 25 normas con la misma normalización del resolutor; se descartan tokens de menos de 4 caracteres, numéricos y una lista de 200 palabras vacías declarada en el script (`STOP_CORPUS`: conectores más fórmulas legales como "artículo", "inciso", "dispuesto"); quedan **93.583 tokens, 8.529 distintos**. Se toman los 200 unigramas y 150 bigramas presentes en más normas, y "cubierto" significa que **esa cadena, escrita como consulta, devuelve al menos una sugerencia** (definición operacional; no es coincidencia de cadenas).

| | Cubiertos | No cubiertos |
|---|---:|---:|
| Top-200 unigramas | **86** | **114** |
| Top-150 bigramas | **53** | **97** |

Control del instrumento (los cubiertos existen y son razonables): `educacion` (25 normas, 6 sugerencias), `establecimientos` (25, 5), `escolar` (23, 8), `reglamento interno` (17 normas, 4), `reconocimiento oficial` (15, 4), `convivencia escolar` (14, 4).

Los 40 unigramas no cubiertos con mayor dispersión (`a1_cobertura_unigramas.csv`) son, con dos excepciones, lenguaje de redacción legal y ruido de cabecera: `normas`, `republica`, `acuerdo`, `traves`, `constitucion`, `politica`, `chile`, `cumplimiento`, `dentro`, `perjuicio`, `manera`, `caracter`, `educativos`, `santiago`, `dispuesto`, `conformidad`, `procedimientos`, `publicacion`, `ello`, `promover`, `https`, `director`, `menos`, `ejercicio`, `acciones`, `informacion`, `condiciones`, `relacion`, `objetivos`, `disposiciones`, `especialmente`, `conocimiento`, `obligacion`, `puedan`, `informar`, `mantener`, `relaciones`, `cuanto`, `nivel`, `calidad`. **Juicio de A1, declarado como tal:** solo `director` y `procedimientos` son consultas plausibles de un equipo de convivencia; el resto no lo es. Entre los 40 bigramas no cubiertos, plausibles a juicio de A1: `integridad fisica`, `derechos fundamentales`, `desarrollo integral`, `docentes directivos`, `normativa educacional` (5 de 40); los demás son fórmulas ("constitucion politica", "presidente republica", "tratados internacionales") o cabecera de la BCN ("url corta", "https bcn", "tipo version"), que el preámbulo de cada norma arrastra y que contamina cualquier índice léxico (hallazgo 7 de §7).

Conclusión del proxy A: el corpus habla en lenguaje legal y el vocabulario cubre lo que del corpus es nombre de cosa (norma, tema, figura); lo que no cubre es, en su gran mayoría, lo que nadie consultaría. Este proxy **no mide** el lenguaje del equipo; mide el del legislador.

### 2.2 Proxy B: consultas escritas por personas dentro del repositorio

23 consultas (salida §8, `a1_consultas_proxy.csv`): los 6 ejemplos de la portada (`index.qmd`, "Escriba en el buscador… por ejemplo"), los títulos de las 12 FAQ en borrador (escritos como pregunta) y los 5 pendientes del glosario.

| Origen | n | Con sugerencia (AND, contrato del §4.3) | Con sugerencia (OR, solo diagnóstico) |
|---|---:|---:|---:|
| Portada | 6 | **6** | 6 |
| Títulos FAQ (preguntas completas) | 12 | **0** | 12 |
| Pendientes del glosario | 5 | **5** | 5 |
| Total | 23 | **11** | 23 |

Las 6 de la portada resuelven al destino esperable ("revisión de mochilas" → tema revisión de pertenencias; "uso de celulares" → Ley 21.801; "encargado de convivencia" → tema convivencia escolar). Las 12 preguntas completas dan 0 con AND porque traen verbos ("obliga", "hacer", "restringir") que ningún término contiene: **una pregunta en forma de oración está fuera del contrato de la capa 1**, que sugiere mientras se escribe, no responde. El modo OR sirve solo para ver qué haría un relajamiento: acierta 8 de 12 a juicio de A1 y yerra 4 (lleva "estudiante embarazada" a derechos de la niñez y "estudiante con TEA", "expulsar a un estudiante" y "mochila de un estudiante" a identidad de género, porque `estudiante` es prefijo de `estudiantes trans`, alias de ese tema). Un OR ingenuo produce sugerencias equivocadas con confianza, que es el modo de falla que el encargo teme; **no se recomienda**.

### 2.3 Qué mide y qué no

Medido: cobertura del vocabulario sobre el vocabulario del corpus (proxy A) y sobre 23 consultas humanas disponibles en el repositorio (proxy B). No medido: el lenguaje real del equipo de convivencia. La única forma de medirlo es un registro de consultas del sitio (con el buscador actual, sin datos personales: la consulta y la hora) o el conjunto de consultas realistas que el encargo pide a A2 y a A5, que A1 no leyó por regla.

### 2.4 Lo que sí se puede hacer sin adivinar

Los alias que faltan (`LIE`, `DFL 2` para la LGE, `Ley de Subvenciones` como remisión externa, y lo que el equipo diga con sus palabras: "dupla", "protocolo", "carta de compromiso") no se derivan del corpus. Propuesta: un archivo de alias **curado y firmado**, con el mismo contrato que `metadatos_curados.json` (cada alias con `fuente`, `validado_por`, `fecha`), leído por el constructor como una fuente más. Es una estructura de datos, pasa la compuerta de firma, y es exactamente lo que la sección 0bis del encargo llama "capa experta como estructura de datos". A1 no lo crea: sería escribir en `20_insumos/`.

---

## 3. Tarea 3: prototipo y medidas

Todas las cifras son de la corrida del 2026-09-05 08:11 (salida §4, §5, §6 y `a1_medidas.json`).

| Medida | Valor | Método |
|---|---:|---|
| Entradas | **892** | `length(entradas)`; por tipo: articulo 806, glosario 44 (39 con ancla + 5 pendientes), norma 25, tema 17 |
| Alias con procedencia | 260 | `nrow(a1_alias_procedencia.csv)` |
| Claves distintas (tokens normalizados) | 555 | salida §6; todas dentro de `[a-z0-9]` (verificado) |
| Peso de `vocabulario.json` | **435.763 bytes = 425,5 KB** | `file.size()`; `wc -c` = 435763 |
| Peso comprimido | **22.097 bytes = 21,6 KB** (5 % del original) | `gzfile()` de R, nivel por defecto; contraste en Bash: `gzip -c vocabulario.json \| wc -c` = 22.113; `gzip -9 -c … \| wc -c` = 21.398 |
| Variante sin los 806 encabezados (86 entradas) | 52.036 bytes = 50,8 KB; gzip 7.391 bytes = 7,2 KB | `a1_vocabulario_sin_articulos.json`; `gzip -c` en Bash = 7.425 |
| Tiempo de construcción | **0,247 s** (elapsed; user 0,244, system 0,002) | `system.time()` alrededor de la construcción y la escritura del JSON, sin contar la lectura de artefactos |
| Duración total del script | 17,95 s (segunda corrida; 24,42 s la primera) | incluye lectura de 47 HTML, verificación de anclas, 454 prefijos y 373 consultas de cobertura |
| Latencia del resolutor en R | 14,4 ms por consulta | 100 repeticiones de `"celu"`; medido en R, **no** en el navegador |
| Destinos verificados contra `40_salidas/sitio/` | **887 de 887** (845 con ancla, 42 solo página); 887 canónicos | salida §5; 5 entradas sin destino (pendientes de fuente) |

**Control positivo del verificador de anclas** (salida §5): `verificar_destino("ley_21801_celulares.html#art-999-inexistente")` → `FALSE`; `verificar_destino("ley_21801_celulares.html#art-10-ter")` → `TRUE`. El 887/887 vale porque el instrumento demuestra que sabe fallar.

Los 806 encabezados pesan 383.727 bytes, el **88 % del archivo** (calculado: 435.763 menos 52.036), y contribuyen a las sugerencias solo cuando la consulta trae un número (§4.3, regla 4) o cuando su propia etiqueta contiene el término (los `num-N` de los dictámenes, que son títulos de sección con contenido: "3. EXPULSIÓN Y CANCELACIÓN DE MATRÍCULA…").

---

## 4. Tarea 4: contrato del JSON

### 4.1 Esquema

Cabecera: `generado_por`, `generado_el`, `version_esquema` (1), `contrato` (4 frases), `n_entradas`, `por_tipo`, `entradas[]`.

| Campo de entrada | Tipo | Significado |
|---|---|---|
| `id` | string | `tema:<slug>`, `norma:<slug>`, `art:<slug>#<id>`, `glos:NN`, `glos-pend:NN` |
| `tipo` | `tema` \| `norma` \| `articulo` \| `glosario` | |
| `termino` | string | rótulo visible; lo que se muestra en la lista |
| `contexto` | string | segunda línea: "3 normas", título de la norma, "Ley 21.801", "Ley 20.536, Artículo 16 B" |
| `alias` | string[] | cadenas adicionales que identifican la entrada; siempre arreglo (vacío en artículos y glosario) |
| `destino` | string \| null | URL relativa del sitio: `tema-<slug>.html`, `<slug>.html`, `<slug>.html#<id>`; null solo en pendientes de fuente |
| `destino_canonico` | string \| null | adonde se navega; difiere de `destino` solo dentro de un grupo de acto (`rex_482_reglamentos_b` → `rex_482_instrucciones_reglamentos_internos.html`) |
| `norma` | string \| null | slug de la norma asociada |
| `peso` | número | base del puntaje: tema 100, norma 90, glosario 60 (pendiente 50), artículo 40 |
| `nivel` | `navegacion` \| `fuente_primaria` \| `pronunciamiento_oficial` \| `orientacion_experta` | mapa **provisional** a los cuatro niveles del encargo: ley/DFL/DTO/circular/REX → fuente primaria, dictamen → pronunciamiento oficial, glosario → orientación experta; el cuarto nivel (inferencia del modelo) no existe en esta capa |
| `citable` | booleano | `origen_texto` ∈ {`capa_texto_pdf`, `ocr_revisado`}; para el glosario, además que la ancla no sea OCR |
| `origen_texto` | string \| null | copia del catálogo |
| `anio` | entero \| null | solo normas |
| `vigencia` | objeto \| null | `{estado, sustituido_por?, sustituye_a?}`, copia del catálogo |
| `grupo_acto` | string \| null | id del grupo (`rex_482_2018`) |
| `es_articulo` | booleano | solo tipo articulo |
| `accion` | string | solo pendientes: `buscar_texto` (la interfaz manda el término al buscador de texto completo) |
| `rotulo` | string \| null | texto que **siempre** se muestra junto al término: "sustituida por …", "sustituye a …", el aviso OCR literal de `AVISO_OCR_PENDIENTE`, "mismo acto que …", "glosario en borrador, sin validar (…)" |

Tres entradas reales, tal como están en el archivo:

```json
{"id":"tema:uso-de-dispositivos-moviles","tipo":"tema","termino":"uso de dispositivos móviles","contexto":"3 normas",
 "alias":["dispositivos moviles","telefono movil","celular"],"destino":"tema-uso-de-dispositivos-moviles.html",
 "destino_canonico":"tema-uso-de-dispositivos-moviles.html","norma":null,"peso":100,"nivel":"navegacion","citable":true,
 "origen_texto":null,"vigencia":null,"grupo_acto":null,"rotulo":null}

{"id":"norma:dictamen_065_revision_mochilas","tipo":"norma","termino":"Dictamen 065",
 "contexto":"Sobre la procedencia de implementar protocolos preventivos de revisión de mochilas y bolsos a estudiantes, …",
 "alias":["065","65","dictamen","Dictamen","Sobre la procedencia … educacionales.","revision mochilas",
          "DICTÁMEN 065 REVISIÓN DE MOCHILAS","Dictamen N° 65"],
 "destino":"dictamen_065_revision_mochilas.html","destino_canonico":"dictamen_065_revision_mochilas.html",
 "norma":"dictamen_065_revision_mochilas","peso":90,"nivel":"pronunciamiento_oficial","citable":true,
 "origen_texto":"capa_texto_pdf","anio":2022,
 "vigencia":{"estado":"sustituido","sustituido_por":"dictamen_078_detectores_revision_mochilas"},
 "grupo_acto":null,"rotulo":"sustituida por dictamen_078_detectores_revision_mochilas"}

{"id":"glos-pend:01","tipo":"glosario","termino":"cancelación de matrícula",
 "contexto":"pendiente de fuente; donde buscar: circular 482 (OCR pendiente); dictamen 71; dictamen 52/77",
 "alias":[],"destino":null,"destino_canonico":null,"norma":null,"peso":50,"nivel":"orientacion_experta","citable":false,
 "origen_texto":null,"vigencia":null,"grupo_acto":null,"accion":"buscar_texto",
 "rotulo":"sin definicion normativa en el corpus (pendiente de fuente); se ofrece busqueda de texto completo"}
```

El archivo **no** embarca los tokens: el navegador los deriva de `termino` + `alias` con la misma normalización que el resolutor (§4.2). Embarcarlos duplicaría el peso sin ganar nada, y una sola función de normalización en dos lugares es más fácil de mantener igual que dos listas de tokens.

### 4.2 Normalización (derivada en runtime, regla 5 del encargo)

`normalizar(x)`: transliteración Latin-ASCII de ICU (`stringi::stri_trans_general`), minúsculas, eliminación del punto de miles entre dígitos (`21.801` → `21801`), todo lo que no sea `[a-z0-9]` pasa a separador. Ninguna clase de caracteres acentuados se escribe a mano. Autoprueba en el script (salida §1), con el caso provocado y su salida literal:

```
entrada : ARTÍCULO único Nº 10 ter: Ñuñoa, Ley N° 21.801 (LGE) «celú» — año
salida  : articulo unico n 10 ter nunoa ley n 21801 lge celu ano
```

y, sobre datos reales, la verificación de que las 555 claves del índice quedan dentro de `[a-z0-9]` (salida §6). Tokens de consulta que se descartan por no discriminar (`STOP_CONSULTA`, 30 formas): `n`, `no`, `num`, `numero`, `de`, `del`, `la`, `el`, `los`, `las`, `y`, `o`, `a`, `en`, `sobre`, `que`, `un`, `una`, `al`, `por`, `para`, `con`, `se`, `su`, `sus`, `lo`, `es`, `e`, `u`.

### 4.3 Reglas de desambiguación (implementadas en `sugerir()`, salida §6 y §9)

1. **Coincidencia por prefijo de token, con AND.** Cada token de la consulta debe ser prefijo de alguna clave de la entrada. `"ley 21.801"` → tokens `ley`, `21801`; `"celu"` es prefijo de `celular` y de `celulares`.
2. **Puntaje** = `peso` + 30 si el primer token de la consulta es prefijo del primer token del término + 10 por cada token con coincidencia exacta − 25 si la norma está sustituida − 10 si no es citable − 0,05 por carácter del término (desempate a favor del más corto). Con eso `"convivencia"` pone el tema (140) sobre la Ley 21.809 (100) y sobre las dos entradas del glosario (70).
3. **Diversidad:** a lo más 4 entradas por tipo, y 8 en total. Sin el tope, `"ley 21.801"` devolvería sus 6 encabezados y nada más.
4. **Los encabezados heredan las claves de su norma solo si la consulta trae un número.** `"21801 art 10"` devuelve los tres artículos 10 de la Ley 21.801 (bis, ter, quater); `"mochila"` no devuelve "MATERIA", "FUENTES" ni "Encabezado" del dictamen 065, que fue lo que la primera corrida mostró y motivó la regla. Sin número, un encabezado solo coincide por su propia etiqueta (`"aula segura"` → "3. SOBRE LA MEDIDA CAUTELAR… LEY AULA SEGURA…" del dictamen 52/77).
5. **Grupo de acto:** cada miembro conserva su página en `destino`, pero `destino_canonico` es la página del miembro `resolucion` declarado en `grupos_acto`, y el rótulo dice "mismo acto que … (incluye el cuerpo del reglamento)". Es la misma regla con que `33_relaciones.R` dirige las remisiones de terceros.
6. **Texto OCR sin revisar:** las normas OCR se sugieren con el rótulo literal `AVISO_OCR_PENDIENTE` ("Texto obtenido por OCR, en revisión; el PDF oficial es la fuente"); sus **encabezados de página** (`ocr-pagina-NNN`, 84) **no se sugieren por defecto** (`incluir_no_citable_articulos = FALSE`): una página sin revisar no puede parecerse a un artículo verificado, que es el invariante 4 del encargo. Están en el JSON con `citable: false` para que la interfaz pueda ofrecerlos marcados si se decide.
7. **Vigencia:** una norma sustituida nunca se oculta; baja 25 puntos y lleva "sustituida por <slug>"; la sucesora lleva "sustituye a <slug>". Efecto medido: `"dictamen 65"` pone primero el 078 (vigente) y segundo el 065. Alternativa no adoptada: no penalizar cuando la consulta trae el número exacto; se deja a decisión del equipo con este dato a la vista.
8. **Glosario:** cada entrada lleva "glosario en borrador, sin validar (estado: borrador, validado_por: null)", leído del front matter en cada corrida; el día que se firme, el rótulo desaparece solo. Los 5 pendientes no tienen destino y declaran `accion: buscar_texto`.
9. **Empates** se resuelven por término alfabético; por eso `"circular 482"` lista "(cuerpo)" antes que "(resolución)", ambos a 110 y con el mismo destino canónico.

### 4.4 Prefijos de 1, 2 y 3 caracteres (medido, salida §7 y `a1_prefijos.csv`)

Para todos los prefijos posibles de cada largo tomados de las 555 claves, se cuenta cuántas entradas dispararían sin regla (cualquier clave que empiece así) y cuántas devuelve el resolutor con la regla adoptada:

| Largo | Prefijos distintos | Mediana sin regla | Máximo sin regla | Mediana con regla | Máximo con regla | Prefijos que dan 0 con regla |
|---:|---:|---:|---:|---:|---:|---:|
| 1 | 36 | 213,5 | 847 | 0 | 0 | 36 |
| 2 | 185 | 13 | 837 | 1 | 19 | 92 |
| 3 | 233 | 12 | 692 | 2 | 683 | 10 |

Regla adoptada y su justificación en la tabla: **1 carácter no sugiere nada** (la mediana sin regla es 213 entradas; `l` dispararía 795). **2 caracteres sugieren solo temas y normas** (42 entradas en juego; máximo 19 para `re`; `ce` da 5: dos temas y tres normas). **3 o más caracteres sugieren todo**, con dos matices medidos: `art` sigue disparando 683 encabezados (es el primer token de 682 etiquetas), que el tope de diversidad reduce a 4 visibles, y los 10 prefijos que dan 0 con regla son conectores de `STOP_CONSULTA` (`con`, `del`, `por`, `que`, `los`, `las`, `sus`, `una`, `num`) más `pag`, que solo existe en las etiquetas "Página N" de OCR, excluidas por la regla 6. Ejemplos literales: `c` → 0; `ce` → 5; `cel` → 3; `48` → 2; `482` → 3; `ley` → 6 (con tope; 17 sin tope).

---

## 5. Tarea 5: presupuesto de latencia en el navegador (calculado, no medido)

Fórmula: segundos = bytes × 8 / 3.000.000. No incluye establecimiento de conexión, TLS ni tiempo hasta el primer byte, que no se midieron.

| Archivo | Bytes (medido) | Segundos a 3 Mbps (calculado) |
|---|---:|---:|
| `vocabulario.json` sin comprimir | 435.763 | **1,162** |
| `vocabulario.json` con gzip | 22.097 | **0,059** |
| sin encabezados, sin comprimir | 52.036 | 0,139 |
| sin encabezados, con gzip | 7.391 | 0,020 |

**Decisión: se carga completo, en un solo archivo, diferido.** Con compresión, 0,06 s de transferencia está por debajo de lo que una persona nota al empezar a escribir, y la carga se dispara al primer foco en el buscador (o tras `DOMContentLoaded` en reposo), nunca bloqueando la página. La construcción del índice en memoria (tokenizar 892 términos y 260 alias) es del orden de lo que R hace en 0,25 s, y en JavaScript sería menor; no se midió.

**Hipótesis de la que depende la decisión:** que GitHub Pages sirva el JSON comprimido (gzip o brotli) cuando el navegador lo acepta. Comando de verificación, una vez publicado: `curl -sI -H 'Accept-Encoding: gzip, br' https://tomgc.github.io/slep_normativa_convivencia/vocabulario.json | grep -i content-encoding`. Si la respuesta no trae `content-encoding`, el costo es el de la fila sin comprimir (1,16 s) y entra la **contingencia**: dos fragmentos, `vocabulario_base.json` (temas, normas, glosario: 50,8 KB, 0,14 s) al primer foco, y `vocabulario_articulos.json` (383 KB) solo cuando la consulta trae un número, que es el único caso en que los encabezados heredados participan (regla 4). La contingencia no se prototipó porque la hipótesis se resuelve con un `curl` en el despliegue.

---

## 6. Criterio de éxito: los cuatro casos plantados

Se ejecutan dentro del script (salida §9) y **el script aborta con `stop()` si alguno falla**; la corrida citada terminó con código 0. Salida literal (columnas `contexto` y `rotulo` truncadas por el propio script a 60 y 70 caracteres):

```
> consulta "celu": 3 sugerencia(s)
 termino                     tipo  contexto                                                     destino                               destino_canonico                      rotulo puntaje
 uso de dispositivos móviles tema  3 normas                                                     tema-uso-de-dispositivos-moviles.html tema-uso-de-dispositivos-moviles.html        100
 Ley 21.801                  norma MODIFICA LA LEY Nº 20.370, GENERAL DE EDUCACIÓN, CON EL O... ley_21801_celulares.html              ley_21801_celulares.html                      90
 Resolución exenta 181       norma RESOLUCIÓN N° 181 EXENTA, DE FECHA 26.02.2026 QUE “APRUEB... rex_181_celulares.html                rex_181_celulares.html                        90
OK celu: aparecen el tema de dispositivos moviles y la Ley 21.801

> consulta "circular 482": 3 sugerencia(s)
 termino                            tipo     contexto                                                     destino
 Resolución exenta 482 (cuerpo)     norma    Cuerpo de la Circular 482 sobre reglamentos internos         rex_482_reglamentos_b.html
 Resolución exenta 482 (resolución) norma    RESOLUCIÓN N° 482 EXENTA, DE 22 DE JUNIO DE 2018, QUE APR... rex_482_instrucciones_reglamentos_internos.html
 Documento completo                 articulo Resolución exenta 482 (resolución)                           rex_482_instrucciones_reglamentos_internos.html#documento
 destino_canonico                                          rotulo                                                                 puntaje
 rex_482_instrucciones_reglamentos_internos.html           Texto obtenido por OCR, en revisión; el PDF oficial es la fuente; m... 110
 rex_482_instrucciones_reglamentos_internos.html           mismo acto que rex_482_reglamentos_b (incluye el cuerpo del reglame... 110
 rex_482_instrucciones_reglamentos_internos.html#documento                                                                         60

> consulta "REX 482": 3 sugerencia(s)
 termino                            tipo     contexto                                                     destino
 Resolución exenta 482 (cuerpo)     norma    Cuerpo de la Circular 482 sobre reglamentos internos         rex_482_reglamentos_b.html
 Resolución exenta 482 (resolución) norma    RESOLUCIÓN N° 482 EXENTA, DE 22 DE JUNIO DE 2018, QUE APR... rex_482_instrucciones_reglamentos_internos.html
 Documento completo                 articulo Resolución exenta 482 (resolución)                           rex_482_instrucciones_reglamentos_internos.html#documento
 destino_canonico                                          rotulo                                                                 puntaje
 rex_482_instrucciones_reglamentos_internos.html           Texto obtenido por OCR, en revisión; el PDF oficial es la fuente; m... 110
 rex_482_instrucciones_reglamentos_internos.html           mismo acto que rex_482_reglamentos_b (incluye el cuerpo del reglame... 110
 rex_482_instrucciones_reglamentos_internos.html#documento                                                                         60
OK circular 482 == REX 482: ambas resuelven a rex_482_instrucciones_reglamentos_internos.html

> consulta "mochila": 3 sugerencia(s)
 termino                  tipo  contexto                                                     destino                                        destino_canonico
 revisión de pertenencias tema  2 normas                                                     tema-revision-de-pertenencias.html             tema-revision-de-pertenencias.html
 Dictamen 078             norma Sobre el uso de medios tecnológicos para la detección de ... dictamen_078_detectores_revision_mochilas.html dictamen_078_detectores_revision_mochilas.html
 Dictamen 065             norma Sobre la procedencia de implementar protocolos preventivo... dictamen_065_revision_mochilas.html            dictamen_065_revision_mochilas.html
 rotulo                                                                 puntaje
                                                                        100
 sustituye a dictamen_065_revision_mochilas; Texto obtenido por OCR,...  90
 sustituida por dictamen_078_detectores_revision_mochilas                65
OK mochila: tema de revision de pertenencias, dictamen 065 con marca 'sustituida por dictamen_078...' y dictamen 078

> consulta "xyzzy": 0 sugerencia(s)

> consulta "convivencia": 5 sugerencia(s)
 termino                                                                                                 tipo     contexto
 convivencia escolar                                                                                     tema     14 normas
 Ley 21.809                                                                                              norma    SOBRE CONVIVENCIA, BUEN TRATO Y BIENESTAR DE LAS COMUNIDA...
 buena convivencia educativa la coexistencia armónica de los                                             glosario Ley 21.809, Artículo 16 A
 buena convivencia escolar la coexistencia armónica de los mi                                            glosario Ley 20.536, Artículo 16 A
 3. EXPULSIÓN Y CANCELACIÓN DE MATRÍCULA COMO MEDIDAS DISCIPLINARIAS POR FALTAS A LA CONVIVENCIA ESCOLAR articulo Dictamen 71
 destino                                                destino_canonico                                       rotulo                                                                 puntaje
 tema-convivencia-escolar.html                          tema-convivencia-escolar.html                                                                                                 140
 ley_21809_convivencia_educativa.html                   ley_21809_convivencia_educativa.html                                                                                          100
 ley_21809_convivencia_educativa.html#art-16-a          ley_21809_convivencia_educativa.html#art-16-a          glosario en borrador, sin validar (estado: borrador, validado_por: ...  70
 ley_20536_violencia_escolar.html#art-16-a              ley_20536_violencia_escolar.html#art-16-a              glosario en borrador, sin validar (estado: borrador, validado_por: ...  70
 dictamen_71_expulsion_cancelacion_matricula.html#num-3 dictamen_71_expulsion_cancelacion_matricula.html#num-3                                                                         50
OK control negativo/positivo en el mismo bloque: 'xyzzy' -> 0 resultados; 'convivencia' -> 5 resultados
```

Lectura contra el criterio del encargo: `"celu"` sugiere el tema y la Ley 21.801 (y además la REX 181, que es la circular sobre celulares); `"circular 482"` y `"REX 482"` devuelven el mismo `destino_canonico`; `"mochila"` llega al tema, al dictamen 065 con "sustituida por dictamen_078…" visible y al dictamen 078 (con "sustituye a dictamen_065…" y su aviso OCR, porque su capa de texto viene de un reconocedor); `"xyzzy"` da 0 y `"convivencia"` da 5 en el mismo bloque. La marca de sustitución sale del campo `vigencia` del catálogo (`estado`, `sustituido_por`, `sustituye_a`); `aviso_vigencia` es `null` en las 25 normas (hallazgo 1 de §7).

---

## 7. Hallazgos sobre premisas del encargo y trabajo ajeno (se reportan, no se corrigen)

1. **`aviso_vigencia` es `null` en las 25 entradas del catálogo** (`a1_explora_estructura.R`: "aviso_vigencia no nulo:" no imprime ninguna). La nota operativa del orquestador decía que la marca de sustitución sale de `vigencia`/`aviso_vigencia`; sale solo de `vigencia`. `CLAUDE.md` §10.6 habla de un "aviso de vigencia en dictamen 065" del 2026-08-25 que hoy vive en `vigencia.fuente`, no en `aviso_vigencia`.
2. **El slug `dfl_1_estatuto_asistentes_educacion` no describe su contenido**: el título del documento es "FIJA TEXTO REFUNDIDO… DE LA LEY Nº 19.070 QUE APROBÓ EL ESTATUTO DE LOS PROFESIONALES DE LA EDUCACIÓN" (estatuto docente). Ya está registrado (`20260826_fuentes_glosario_v1.md` §5 y `ESTADO.md`, "decisión del slug del DFL 1"). Para esta capa tiene un efecto concreto: la materia del slug entra como alias, así que `asistentes` apunta al estatuto docente. Mientras el equipo no decida, el vocabulario reproduce el defecto en vez de esconderlo.
3. **Los encabezados del glosario en borrador vienen truncados a 60 caracteres con el arranque de la definición pegado** (20 de 39), y uno trae un `®` del OCR. No es un defecto del glosario como pieza (es un borrador que espera redacción) pero sí del uso de sus encabezados como términos: el límite del término no es derivable.
4. **Nombre original `03. 20845 INCLUSION SEP.pdf`**: "SEP" como alias de la Ley 20.845 es ambiguo (la Ley SEP es la 20.248, de subvención escolar preferencial, que no está en el corpus). También hay dos erratas en nombres originales (`CIRULAR 193`, `DLF 315`) que producen tokens inertes (`cirular`, `dlf`). Ninguna se corrige: el README es trazabilidad.
5. **`relaciones.json` no tiene el campo `fuente` por relación** que la orientación de rutas del orquestador enumeraba (`relaciones[{desde, hacia, tipo, explicacion, fuente}]`). Los campos reales de una remisión son `desde, hacia, tipo, articulo, etiqueta_articulo, cita_literal, n_citas, explicacion` (`a1_explora_alias.R`); `cita` existe solo en `descartadas`. La procedencia global vive en `generado_por`.
6. **El código vigente del pipeline accede con `$` a estructuras leídas de disco** (`34_generar_paginas.R`: `n$vigencia$estado`, `a$id`; `10_utils.R`: `n$tipo_etiqueta`, `n$grupo_acto$rol`), mitigado por `options(warnPartialMatchDollar = TRUE)` en `10_configuracion.R` y por la autoprueba de CI. La regla del encargo se cumple en el prototipo (cero `$` sobre datos de disco); se anota porque cualquier reutilización de `nombre_corto()` desde el motor la incumpliría.
7. **Los preámbulos arrastran la cabecera de la BCN** ("Url Corta: https://bcn.cl/…", "Tipo Versión: Última Versión", "Fecha Publicación: 12-SEP-2009"): en el proxy A, `https` aparece en 19 normas y "url corta" en 17. Es texto literal del PDF (no se puede limpiar sin tocar el invariante de fidelidad) pero cualquier índice léxico o vectorial sobre `preambulo` lo va a ver; conviene que quien diseñe la capa 2 lo sepa. A1 no leyó el trabajo de A2.
8. **Cifras heredadas del encargo, recontadas y confirmadas:** 25 normas, 682 artículos, 552 relaciones, 84 páginas OCR en 5 documentos (salida §2 y §3); 22 piezas en borrador y 0 con firma (`grep -hE '^(estado|validado_por):' 20_insumos/curaduria/piezas/borradores/*.md | sort | uniq -c` → `22 estado: borrador`, `22 validado_por: null`).

---

## 8. Residuos: lo que no se midió, lo que se estimó, lo que se decidió no hacer

| Ítem | Estado | Razón |
|---|---|---|
| Latencia real en el navegador (descarga, parseo, primer resultado) | **no medido** | no se escribió el JavaScript; el encargo pide especificar y demostrar con prototipo en R, y la descarga a 3 Mbps se pide como cálculo |
| Compresión efectiva en GitHub Pages | **hipótesis** | sin red por regla; comando de verificación en §5 |
| Equivalencia exacta de la normalización entre R (ICU Latin-ASCII) y JavaScript (`String.prototype.normalize('NFD')` más eliminación de diacríticos) | **no verificado** | especificación en §4.2; la autoprueba de §1 del script es la que debe reproducirse en JS con el mismo caso |
| Lenguaje real del equipo de convivencia | **no medido** | no hay registro de consultas; §2.3 |
| Alias curados (`LIE`, `DFL 2` → LGE, denominaciones del equipo) | **no hecho** | exigiría escribir en `20_insumos/`; propuesta en §2.4 |
| FAQ y fichas como entradas del vocabulario | **decidido no hacer** | 0 piezas publicadas: no existe página destino y la compuerta de firma manda; el glosario sí entra porque su destino es la ancla del artículo, que existe |
| Coincidencia tolerante a erratas (`celuar`) y por sinónimos no declarados | **decidido no hacer** | sin datos de uso que la justifiquen; agregaría falsos positivos con confianza |
| Fragmentación del índice | **decidido no prototipar** | la decisión depende de la hipótesis de compresión, que un `curl` resuelve en el despliegue |
| Integración con Pagefind (sinónimos, expansión de consulta) | **fuera de alcance de A1** | corresponde a la comparación de arquitecturas de A2 |
| Corrección del rótulo "circular 482" en el glosario y de los alias del DFL 1 | **no se toca** | piezas y curaduría son de escritura humana |

---

## 9. Comandos y cifras

| Cifra | Valor | Comando o sección |
|---|---:|---|
| Normas (JSON) | 25 | `ls 40_salidas/datos/normas/*.json \| wc -l`; salida §2 |
| Páginas temáticas | 17 | `ls 40_salidas/sitio_src/tema-*.qmd \| wc -l`; salida §3 |
| HTML en el sitio | 47 | `ls 40_salidas/sitio/*.html \| wc -l` |
| `<h2 id>` en el sitio | 958 | `grep -ohE '<h2 id="[^"]+"' 40_salidas/sitio/*.html \| wc -l` |
| `<h2 id>` en páginas de norma | 806 | salida §3 |
| Segmentos con id en JSON | 806 | salida §3 |
| Artículos (`es_articulo`) | 682 | salida §3 |
| Páginas OCR sin revisar / documentos | 84 / 5 | salida §3 |
| Equivalencia id JSON = id h2 | 25/25 | salida §3 (`setequal` por norma) |
| Relaciones | 552 | salida §2 |
| Glosario: encabezados / distintos / OCR / pendientes | 39 / 35 / 5 / 5 | salida §3 |
| Piezas en borrador / firmadas | 22 / 0 | `grep -hE '^(estado\|validado_por):' 20_insumos/curaduria/piezas/borradores/*.md \| sort \| uniq -c` |
| Entradas del vocabulario (por tipo) | 892 (806/44/25/17) | salida §4 |
| Alias con procedencia | 260 | salida §4; `wc -l a1_alias_procedencia.csv` = 261 con cabecera |
| Claves distintas | 555 | salida §6 |
| Bytes / KB del JSON | 435.763 / 425,5 | `wc -c vocabulario.json`; salida §4 |
| gzip (R `gzfile`) / (Bash `gzip -c`) / (`gzip -9`) | 22.097 / 22.113 / 21.398 | salida §4; `gzip -c … \| wc -c` |
| Sin encabezados: bytes / gzip | 52.036 / 7.391 | salida §4 |
| Tiempo de construcción | 0,247 s | `system.time()`, salida §4 |
| Duración total del script | 17,95 s | salida §11 |
| Latencia del resolutor (R) | 14,4 ms | salida §6 |
| Destinos verificados | 887/887 (+5 sin destino) | salida §5 |
| Control del verificador de anclas | FALSE / TRUE | salida §5 |
| Prefijos: 1 / 2 / 3 caracteres | 36 / 185 / 233 | salida §7; `a1_prefijos.csv` |
| Cobertura unigramas / bigramas | 86 de 200 / 53 de 150 | salida §8 |
| Tokens del corpus tras filtros / distintos | 93.583 / 8.529 | salida §8 |
| Consultas proxy: AND / OR | 11 de 23 / 23 de 23 | salida §8; `a1_consultas_proxy.csv` |
| Alias probados / con 0 | 22 / 3 (`LIE`, `SAE`, `LSAC`) | `a1_alias_prueba.csv`; control `convivencia` = 5 |
| "circular 181" fuera del laboratorio | 1 archivo (el prototipo) = 0 ajenos | `grep -rliE 'circular (n[°º] ?)?181' 20_insumos/curaduria 50_documentacion 40_salidas/datos README.md 20_insumos/normativa/README.md \| grep -v lab_motor_v9`; control con `482` = 14 |
| "Circular N° 482" en el corpus | 1 (dictamen 52/77) | `a1_explora_contextos.R`, patrón `(?i)circular n° 482` |
| Segundos a 3 Mbps (json / gzip) | 1,162 / 0,059 | calculado, salida §10 |
| md5 de `vocabulario.json` | `d8ef55cd51bb90fed890ca3b935a1c8e` | `md5 -q`, idéntico en las dos corridas |
| Líneas del prototipo / del documento | 663 / 463 | `wc -l` sobre ambos archivos |

---

## 10. Registro de ejecución

- 2026-09-05 02:46: el prototipo quedó escrito en disco; la sesión se cortó por límite de la API antes de correrlo.
- 08:08: reanudación. Verificado con `ls -la` y `wc -l` que el script existía (45.987 bytes, 653 líneas) y que no existían ni este documento ni `vocabulario.json`. `parse()` detectó un fragmento residual (`tidyr_pivot <- NULL`, línea 275) que se eliminó.
- 08:09: primera corrida completa, código 0. La salida mostró encabezados de dictamen ("MATERIA", "FUENTES") entre las sugerencias de `"mochila"`; se adoptó la regla 4 de §4.3.
- 08:11: segunda corrida, código 0; JSON idéntico (md5); es la corrida citada en todo el documento.
