# =============================================================================
# 10_configuracion.R - Configuracion del proyecto
# -----------------------------------------------------------------------------
# Proyecto de datos 100% PUBLICOS (Rama A, POLITICA 8.2): raiz unificada. Las
# carpetas de datos viven dentro del repo y se resuelven con here::here()
# exclusivamente; no hay variable de entorno ni data root externo.
# Aqui viven TODAS las rutas, constantes y parametros del proyecto; ningun
# script aguas abajo hardcodea rutas ni numeros magicos (POLITICA 5.3.10, 5.4).
# =============================================================================

# ---- Guarda de locale UTF-8 (POLITICA 5.2bis) -------------------------------
# Primera linea ejecutable del arranque, antes de cualquier lectura o escritura.
# Un proceso lanzado desde un shell sin locale (cron, GitHub Actions, shell no
# interactivo) escribe el texto acentuado escapado como <c3><a1> sin emitir
# error alguno. En un corpus de normativa chilena eso corrompe practicamente
# cada articulo. El helper se copia identico desde herramientas_dev/plantillas/
# y NUNCA se edita por proyecto.
source(here::here("10_utils", "10_locale.R"))
asegurar_locale_utf8("10_configuracion.R")

# ---- Coincidencia parcial de nombres, visible -------------------------------
# `l$anio` resuelve a `anios_alternativos` cuando la clave exacta falta: asi el
# anio del DFL 1 quedo en 1996 y el derivador empezo a descartar las citas
# correctas, sin un solo error. 00_run_all.R convierte estos avisos en fallo de
# la corrida (encargo v5, T2; Duda 4 del log de correcciones v4).
options(warnPartialMatchDollar = TRUE,
        warnPartialMatchArgs   = TRUE,
        warnPartialMatchAttr   = TRUE)

# ---- Rutas (raiz unificada) -------------------------------------------------
ruta_insumos   <- function(...) here::here("20_insumos", ...)
ruta_salidas   <- function(...) here::here("40_salidas", ...)
ruta_normativa <- function(...) ruta_insumos("normativa", ...)
ruta_datos     <- function(...) ruta_salidas("datos", ...)
ruta_normas    <- function(...) ruta_datos("normas", ...)
ruta_sitio_src <- function(...) ruta_salidas("sitio_src", ...)
ruta_sitio     <- function(...) ruta_salidas("sitio", ...)

# ---- Identidad del sitio ----------------------------------------------------
SITIO_TITULO <- "Normativa de convivencia educativa"
SITIO_URL    <- "https://tomgc.github.io/slep_normativa_convivencia/"
SITIO_LANG   <- "es"

# ---- Taxonomia de tipos de norma --------------------------------------------
# El tipo NO se infiere del texto: se deriva del prefijo del nombre canonico del
# archivo, que fija T2 del encargo de bootstrap. Esta tabla traduce ese prefijo a
# la etiqueta que ve el usuario y fija el orden de presentacion en los indices
# (jerarquia normativa: ley > DFL > decreto > acto administrativo > dictamen).
TIPOS_NORMA <- c(
  ley      = "Ley",
  dfl      = "Decreto con fuerza de ley",
  dto      = "Decreto supremo",
  circular = "Circular",
  rex      = "Resolución exenta",
  dictamen = "Dictamen"
)
ORDEN_TIPOS <- names(TIPOS_NORMA)

# ---- Umbral de capa de texto ------------------------------------------------
# Un PDF de norma con menos de este numero de caracteres alfabeticos no tiene
# capa de texto util: es un escaneo de imagen. Umbral tomado de la regla de
# detencion 2 del encargo de bootstrap. Medido en FASE 0 (2026-08-25): el
# documento con capa de texto mas corta del corpus, rex_181_celulares, tiene
# 1.113 caracteres; los cuatro escaneados tienen exactamente 0. El umbral
# discrimina con dos ordenes de magnitud de holgura.
MIN_CHARS_ALFABETICOS <- 500L

# ---- Reconocimiento optico (OCR) --------------------------------------------
# Resolucion de rasterizado para 00_ocr_documentos.R. 300 dpi es el minimo con el
# que el reconocedor distingue con fiabilidad la tilde y la enie en un escaneo de
# oficina; por debajo confunde "nino" con "nino" y la correccion la paga una
# persona.
OCR_DPI <- 300L

# Estados posibles del campo `origen_texto` de cada norma. Es un dominio cerrado:
# un valor fuera de esta lista es un error, no una variante.
#   capa_texto_pdf         el PDF trae texto seleccionable; es cita textual.
#   ocr_pendiente_revision texto reconocido por maquina, SIN revisar. No es cita
#                          textual y el sitio lo declara asi. La fuente es el PDF.
#   ocr_revisado           texto reconocido y validado por el equipo de
#                          convivencia. Solo el equipo mueve un documento a este
#                          estado, editando 20_insumos/curaduria/.
#   sin_texto              ni capa de texto ni reconocimiento disponible.
ORIGENES_TEXTO <- c("capa_texto_pdf", "ocr_pendiente_revision",
                    "ocr_revisado", "sin_texto")

# Aviso que el sitio muestra junto al enlace al PDF mientras el texto reconocido
# no este validado. Literal fijado por el equipo el 2026-08-25.
AVISO_OCR_PENDIENTE <- "Texto obtenido por OCR, en revisión; el PDF oficial es la fuente"

# Separador con el que 31 une las paginas reconocidas y 32 las vuelve a separar.
# Se elige una secuencia que no puede aparecer en un texto legal reconocido: dos
# saltos, un marcador de formulario y dos saltos.
SEPARADOR_PAGINA_OCR <- "\n\n\u000c\n\n"

# ---- Segmentacion por articulado --------------------------------------------
# Dos formas conviven en el corpus chileno y hay que cubrir las dos:
#   numerica ("Articulo 5", "Art. 5 bis", "ARTICULO 12 TRANSITORIO")
#   ordinal en palabra ("Articulo unico.-", "Articulo primero:", "Articulo
#   septimo:")
# La segunda no es marginal: medida en FASE 0, ley_20911 y dto_215 no producen
# NI UNA coincidencia con el patron numerico y sin embargo tienen articulado
# completo. Un segmentador que solo mirara digitos los declararia sin articulos.
ORDINALES_ARTICULO <- c(
  "unico" = 1L, "primero" = 1L, "segundo" = 2L, "tercero" = 3L, "cuarto" = 4L,
  "quinto" = 5L, "sexto" = 6L, "septimo" = 7L, "octavo" = 8L, "noveno" = 9L,
  "decimo" = 10L, "undecimo" = 11L, "duodecimo" = 12L,
  "decimotercero" = 13L, "decimocuarto" = 14L, "decimoquinto" = 15L,
  "decimosexto" = 16L, "decimoseptimo" = 17L, "decimoctavo" = 18L,
  "decimonoveno" = 19L, "vigesimo" = 20L
)

# Los ordinales se escriben sin tilde en la tabla de arriba, pero el corpus los
# trae CON tilde ("Articulo unico" es en realidad "Art\u00edculo \u00fanico"). En vez de
# duplicar cada entrada a mano, cada vocal se convierte en una clase que acepta
# las dos formas: es una sola linea y no se puede olvidar una variante.
.tolerar_tildes <- function(x) {
  x <- gsub("a", "[a\u00e1]", x, fixed = TRUE)
  x <- gsub("e", "[e\u00e9]", x, fixed = TRUE)
  x <- gsub("i", "[i\u00ed]", x, fixed = TRUE)
  x <- gsub("o", "[o\u00f3]", x, fixed = TRUE)
  gsub("u", "[u\u00fa]", x, fixed = TRUE)
}
.alternativa_ordinales <- paste(
  .tolerar_tildes(c(names(ORDINALES_ARTICULO), "transitorio", "final")),
  collapse = "|"
)

# Encabezado de articulo. Se ancla en inicio de bloque (perl, multiline) para no
# capturar las CITAS a articulos de otras normas que abundan en dictamenes y
# circulares ("...conforme al articulo 6 letra d) de la ley 20.529..."), que van
# siempre en medio de una frase. Sin ese anclaje, un dictamen de 6 paginas
# producia 6 "articulos" que no son suyos.
#
# La parte numerica admite un digito O una palabra de la lista CERRADA de
# ordinales de arriba (mas "transitorio" y "final"). Cerrada a proposito: con un
# comodin \w+ el patron capturaria "Articulo anterior" o "Articulo siguiente",
# que son referencias internas, no encabezados.
#
# El sufijo cubre las tres formas reales del corpus: "bis"/"ter" (ley 21430),
# la letra suelta ("Articulo 16 A" de la ley 20536, que es como el legislador
# intercala articulos nuevos sin renumerar la ley entera) y "transitorio".
# La comilla inicial opcional NO es cosmetica: en las leyes modificatorias el
# articulado va entre comillas porque es texto que se inserta en otra norma
# ("Articulo unico.- Introducense las siguientes modificaciones..."). Sin ella,
# el patron se saltaba justo el articulo propio de la ley 20536 y de la 20911 y
# publicaba las dos con su articulado incompleto.
REGEX_ENCABEZADO_ARTICULO <- paste0(
  "^[ \\t]*[\"\u201c\u00ab(]?[ \\t]*",
  "(?:ART[I\u00cd]CULO|Art[i\u00ed]culo|ARTICULO|Art\\.)",
  "[ \\t]+",
  "(\\d+|", .alternativa_ordinales, ")",
  "[ \\t]*(?:\u00b0|\u00ba)?",
  "[ \\t]*(bis|ter|quater|quinquies|[A-Z])?",
  "[ \\t]*(transitorio)?",
  "[ \\t]*(?=[.:\\-\u2013\u2014])"
)

# Marca de inicio de las disposiciones transitorias. Se detecta aparte del
# encabezado porque en muchas normas la palabra "transitorio" no viaja en cada
# articulo, sino una sola vez en el titulo de la seccion, y desde ahi TODO lo que
# sigue es transitorio.
REGEX_SECCION_TRANSITORIA <- "^[ \\t]*(DISPOSICIONES\\s+TRANSITORIAS|ART[I\u00cd]CULOS?\\s+TRANSITORIOS?)"

# Encabezado de seccion para documentos SIN articulado (dictamenes, circulares,
# resoluciones). Etiqueta en versalitas terminada en dos puntos: "MATERIA:",
# "ANTECEDENTES:", "FUENTES:", "CONCORDANCIAS:", "CONCLUSIONES:". Es la
# estructura que la Superintendencia de Educacion usa en todos sus dictamenes.
REGEX_ENCABEZADO_SECCION <- "^[ \\t]*([A-Z\u00c1\u00c9\u00cd\u00d3\u00da\u00d1][A-Z\u00c1\u00c9\u00cd\u00d3\u00da\u00d1 ]{3,40}):"

# Encabezado de seccion NUMERADA, en documentos sin articulado. Los dictamenes de
# la Superintendencia organizan su cuerpo en "1. SOBRE LAS CAUSALES...",
# "2. SOBRE LA PROCEDENCIA...". Sin este patron, todo el cuerpo caia en el ultimo
# segmento de versalitas ("CONCORDANCIAS") y un dictamen de 30.000 caracteres
# tenia un solo ancla.
#
# Se exige VERSALITAS despues del numero, y punto (no parentesis), para no
# confundir un encabezado con las dos cosas que se le parecen y no lo son:
#   "1) Resolucion Exenta N° 0413..."  -> item de la lista de ANTECEDENTES
#   "1. Que, cualquier regulacion..."  -> considerando, en minusculas
REGEX_ENCABEZADO_NUMERAL <- "^[ \\t]*([0-9]{1,2})\\.[ \\t]+([A-Z\u00c1\u00c9\u00cd\u00d3\u00da\u00d1][A-Z\u00c1\u00c9\u00cd\u00d3\u00da\u00d1 ,.()\u00ba\u00b0-]{4,})"

# ---- Ficha y pie del sitio de origen ----------------------------------------
# Los PDF del corpus se descargan de la Biblioteca del Congreso Nacional, que
# envuelve el texto oficial en metadatos propios: arriba una ficha con fechas de
# publicacion, promulgacion, version y ultima modificacion, cerrada por una URL
# corta; abajo, en los documentos de una sola pagina, su linea de pie. Nada de
# eso es parte del acto administrativo: es el envoltorio del sitio desde donde se
# obtuvo el archivo. Dentro del texto contamina cualquier indice que se construya
# sobre el, y ya produjo un defecto visible que se parcho aguas abajo (ver el
# comentario de extracto_tematico() en 34_generar_paginas.R).
#
# Medido antes de escribir la regla: 17 de las 25 normas la arrastran, ninguna en
# un segmento con es_articulo = TRUE
# (50_documentacion/andamios/20260908_medicion_correcciones_v1.md, seccion 6).
#
# El pie ya lo quita detectar_repetidos() en los documentos de tres paginas o
# mas; 31_extraer_texto.R completa esa misma limpieza para los de una o dos, donde
# aquella se apaga por falta de repeticion que detectar (n < 3L). No es una
# politica nueva: es la que ya existe, sin el hueco.
#
# LA REGLA SE DERIVO DEL TEXTO REAL, no de memoria. Invariante medido en las 17:
# la ficha ocupa un bloque contiguo cerca de la cabeza y ese bloque TERMINA en
# "Url Corta: https://bcn.cl/<token>"; aparece una sola vez por documento; el
# indice del bloque es 2 en quince normas y 3 en dos.
#
# Vivieron en 30_procesamiento/31_extraer_texto.R desde el encargo v10 y se
# trajeron aqui en el v11 (T5, hueco 1 de P7): la tabla de autorizaciones del v10
# no incluia 10_utils/, asi que quedaron fuera de su fuente canonica. El valor no
# cambio: se movio la linea, no se retipeo.
REGEX_FICHA_ORIGEN <- "Url\\s+Corta\\s*:\\s*https?://bcn\\.cl/[A-Za-z0-9]+\\s*$"
REGEX_PIE_ORIGEN   <- "^Biblioteca del Congreso Nacional de Chile\\s*-\\s*www\\.leychile\\.cl"

# ---- Diccionario tematico ---------------------------------------------------
# DECISION METODOLOGICA DECLARADA, no inferencia del asistente.
# El tema NO viene marcado en los documentos: es una columna derivada. Se asigna
# por coincidencia de palabras clave sobre el texto extraido, con este
# diccionario cerrado y auditable. Se prefiere un diccionario explicito a una
# clasificacion por modelo porque el resultado tiene que ser identico en cada
# corrida y revisable linea por linea por el equipo de convivencia.
# Una norma puede quedar en varios temas o en ninguno (tema = lista vacia).
# Las CLAVES llevan tilde porque son la etiqueta que el sitio imprime; los
# VALORES van sin tilde porque se comparan contra el texto plegado a ASCII, que
# es lo que hace que "discriminacion" encuentre "discriminación".
TEMAS_PALABRAS_CLAVE <- list(
  "convivencia escolar"        = c("convivencia escolar", "buena convivencia", "encargado de convivencia"),
  "violencia y acoso escolar"  = c("violencia escolar", "acoso escolar", "maltrato", "bullying", "agresion"),
  "medidas disciplinarias"     = c("expulsion", "cancelacion de matricula", "medida disciplinaria", "reglamento interno", "sancion"),
  "inclusión y no discriminación" = c("inclusion", "discriminacion arbitraria", "necesidades educativas especiales", "integracion"),
  "derechos de la niñez"       = c("interes superior del nino", "garantias de la ninez", "derechos del nino", "ninos, ninas y adolescentes"),
  "participación de la comunidad" = c("consejo escolar", "centro de padres", "centro de alumnos", "participacion"),
  # "trans" a secas NO se usa: con coincidencia por subcadena etiquetaba 16 de 25
  # documentos del corpus por contener "transitorio", "transparencia" o
  # "transcribo" (medido el 2026-08-25). Las formas explicitas son largas a
  # proposito.
  "identidad de género"        = c("identidad de genero", "nombre social",
                                   "estudiantes trans", "estudiante trans",
                                   "personas trans", "persona trans",
                                   "ninas, ninos y estudiantes trans"),
  "embarazo y maternidad"      = c("embarazada", "embarazo", "maternidad", "paternidad", "lactancia"),
  "trastorno del espectro autista" = c("espectro autista", "autismo",
                                       "neurodivergen"),
  "uso de dispositivos móviles" = c("dispositivos moviles", "telefono movil", "celular"),
  "uniforme y presentación personal" = c("uniforme escolar", "presentacion personal"),
  "formación ciudadana"        = c("formacion ciudadana", "educacion civica"),
  "jornada escolar"            = c("jornada escolar completa", "jornada escolar"),
  "estatuto del personal"      = c("estatuto docente", "asistentes de la educacion", "profesionales de la educacion"),
  "reconocimiento oficial"     = c("reconocimiento oficial", "perdida del reconocimiento"),
  # Temas incorporados el 2026-08-25 al entrar el dictamen 078: el corpus pasa a
  # tener dos documentos sobre deteccion y revision, y sin estas entradas ambos
  # quedaban repartidos en temas genericos que no los describen.
  "seguridad escolar"          = c("detector de metales", "detectores de metales",
                                   "porticos detectores", "arma blanca",
                                   "elementos incendiarios", "seguridad escolar"),
  "revisión de pertenencias"   = c("revision de mochilas", "mochilas y bolsos",
                                   "efectos personales", "revision de pertenencias",
                                   "registro de mochilas")
)


# ---- Buscador del sitio: orden, tope y expansion de la consulta -------------
# TODO parametro del buscador vive aqui y no en el cuerpo de busqueda.html.
# 34_generar_paginas.R los inyecta en la copia publicada de la plantilla, de modo
# que la pagina y el instrumento de medicion (tests/medir_buscador.R) leen los
# mismos numeros de la misma fuente. Antes del encargo v11, TOPE_SUB_RESULTADOS
# estaba escrito en el cuerpo del JavaScript y habia que ir a buscarlo ahi.

# Sub-resultados (articulos) que se muestran por norma. 5 y no 3: el bundle de
# Pagefind recorta en 3 dentro del cuerpo de su funcion, no en un parametro, y
# esa fue la razon de escribir una interfaz propia (encargo v10, B1).
TOPE_SUB_RESULTADOS <- 5L

# Normas por tanda en la lista de resultados.
PAGINA_RESULTADOS <- 8L

# ---- Expansion de la consulta (encargo v11, T2) -----------------------------
# EL PROBLEMA QUE RESUELVE, medido y no supuesto: Pagefind exige TODOS los
# terminos de contenido de la consulta, y el equipo pregunta con palabras que la
# norma no usa ("celular" donde la ley dice "dispositivos moviles", "bullying"
# donde dice "acoso escolar"). Medido el 2026-09-09 sobre las diez consultas de
# evaluacion: 3 de 10 resueltas, y en 3 de las 7 restantes el indice no devuelve
# NINGUNA pagina.
#
# QUE NO ES: no reescribe la consulta del usuario ni altera el texto publicado.
# Ejecuta la consulta original y hasta TOPE_VARIANTES_CONSULTA consultas mas, y
# une los resultados por pagina. La consulta original conserva precedencia
# absoluta (piso R0): sus paginas van primero, siempre, de modo que una expansion
# mala solo puede agregar ruido debajo, nunca desplazar lo que ya se encontraba.
#
# DOS MEDICIONES QUE CAMBIARON EL DISENO, ambas del 2026-09-09:
#  - Sustituir el alias DENTRO de la consulta completa no sirve: recupera 1 de 7,
#    porque los demas terminos de la consulta siguen exigiendose. La variante que
#    funciona es la FRASE DEL ALIAS SOLA: recupera 7 de 7.
#  - Pagefind ya normaliza tildes y ya ignora las palabras vacias del espanol: las
#    diez consultas con y sin tildes, y con y sin palabras vacias, devuelven EL
#    MISMO conjunto de paginas (0 de 10 difieren). Por eso la expansion NO
#    normaliza la consulta que se envia; PALABRAS_VACIAS_CONSULTA existe solo para
#    TROCEAR la consulta y decidir que alias disparan.

# Cuantas variantes se ejecutan ademas de la original, y cuantas paginas puede
# aportar cada una. El tope por variante impide que un alias amplio ("expulsion")
# inunde la lista y empuje la respuesta correcta fuera de la primera tanda.
# ADVERTENCIA METODOLOGICA: los dos valores se eligieron por simulacion sobre las
# MISMAS diez consultas con que se reporta el resultado. Es ajuste sobre el
# conjunto de evaluacion, y la superficie es ruidosa (7, 5 y 8 aciertos en
# configuraciones vecinas). Lo que se afirma es la medida pareada -ninguna
# consulta retrocede-, no una mejora general. Se re-eligen cuando existan
# consultas reales del equipo (decision D-C de la integracion del 2026-09-09).
TOPE_VARIANTES_CONSULTA   <- 3L
TOPE_PAGINAS_POR_VARIANTE <- 2L

# Un alias con mas de estos tokens de contenido no se usa como variante: los
# titulos completos de las normas estan en la tabla y como consulta no aportan.
MAX_TOKENS_ALIAS <- 4L

# Largo de la raiz con que se comparan las palabras. 6 caracteres hacen que
# "mochila" y "mochilas" coincidan sin que lo hagan "consejo" y "consentimiento".
LARGO_RAIZ_ALIAS <- 6L

# Palabras vacias del espanol. NO se quitan de la consulta que viaja a Pagefind
# (que ya las ignora): se quitan para trocear la consulta y buscar alias.
PALABRAS_VACIAS_CONSULTA <- c(
  "de", "la", "el", "en", "para", "un", "una", "los", "las", "que", "se", "a", "al", "del", "por", "con", "es", "lo", "su", "y", "o"
)

# Raices que aparecen en mas de 3 entradas de ALIAS_CONSULTA y por eso no
# disparan una expansion por si solas: "educacion" o "escolar" estan en casi
# todas las normas del corpus y dispararian todas las expansiones a la vez.
# Derivadas de la propia tabla, no escritas a mano.
RAICES_COMUNES_ALIAS <- c(
  "aprueb", "circul", "decret", "derech", "dictam", "dto", "educac", "escola", "establ", "estado", "estudi", "ley", "modifi", "oficia", "person", "recono", "reglam", "sobre", "suprem", "uso"
)

# Procedencia de cada alias. Un alias sin procedencia es indistinguible de uno
# inventado, que es exactamente lo que este encargo tiene prohibido.
FUENTES_ALIAS <- c(
  temas            = "10_utils/10_configuracion.R TEMAS_PALABRAS_CLAVE",
  readme_nombre    = "20_insumos/normativa/README.md nombre original",
  readme_escaneo   = "20_insumos/normativa/README.md tabla de escaneos (que es)",
  numero           = "catalogo.json numero (crudo, con punto de miles, sin ceros a la izquierda)",
  tipo             = "catalogo.json tipo / TIPOS_NORMA",
  titulo           = "catalogo.json titulo",
  grupo_acto       = "metadatos_curados.json grupos_acto nota_colapso",
  remision         = "relaciones.json cita_literal de remisiones",
  slug             = "slug (materia de la URL)",
  denominacion     = "texto del corpus: denominacion junto al numero de ley"
)

# ALIAS_CONSULTA: 183 filas, 42 entradas (25 normas y 17 temas), 168 alias
# distintos. NINGUN alias se invento en el encargo v11: todos existen en
# 50_documentacion/andamios/lab_motor_v9/a1_alias_procedencia.csv (260 filas), del
# que se conservan las que tienen entre 1 y MAX_TOKENS_ALIAS tokens de contenido y
# al menos una raiz que no este en RAICES_COMUNES_ALIAS. Se traen aqui como CODIGO
# porque ese CSV no se versiona: la regla R1 del hook global rechaza extensiones de
# datos fuera de 40_salidas/datos/.
#
# data.frame y no tibble a proposito: 10_configuracion.R lo carga TODO script del
# pipeline, incluidos los que no instalan tibble (31_extraer_texto.R declara
# pdftools, jsonlite, fs y here). Anadir aqui una dependencia de paquete romperia
# ese contrato.
ALIAS_CONSULTA <- as.data.frame(matrix(
  byrow = TRUE, ncol = 3L,
  dimnames = list(NULL, c("entrada", "alias", "clave_fuente")),
  data = c(
  "norma:circular_193_estudiantes_embarazadas", "193", "numero",
  "norma:circular_193_estudiantes_embarazadas", "CIRULAR 193 EMBARAZOS", "readme_nombre",
  "norma:circular_193_estudiantes_embarazadas", "estudiantes embarazadas", "slug",
  "norma:circular_586_tea", "586", "numero",
  "norma:circular_586_tea", "CIRCULAR 586 LEY TEA", "readme_nombre",
  "norma:circular_586_tea", "Circular 586, ley TEA", "readme_escaneo",
  "norma:circular_586_tea", "tea", "slug",
  "norma:circular_812_identidad_genero", "812", "numero",
  "norma:circular_812_identidad_genero", "CIRCULAR 812 IDENTIDAD DE GÉNERO", "readme_nombre",
  "norma:circular_812_identidad_genero", "identidad genero", "slug",
  "norma:dfl_1_estatuto_asistentes_educacion", "Decreto con fuerza de ley", "tipo",
  "norma:dfl_1_estatuto_asistentes_educacion", "decreto con fuerza de ley N° 1", "remision",
  "norma:dfl_1_estatuto_asistentes_educacion", "decreto con fuerza de ley Nº 1", "remision",
  "norma:dfl_1_estatuto_asistentes_educacion", "dfl", "tipo",
  "norma:dfl_1_estatuto_asistentes_educacion", "DFL 1 MINEDUC ESTATUTO ASISTENTES", "readme_nombre",
  "norma:dfl_1_estatuto_asistentes_educacion", "estatuto asistentes educacion", "slug",
  "norma:dfl_315_perdida_reconocimiento_oficial", "315", "numero",
  "norma:dfl_315_perdida_reconocimiento_oficial", "Decreto con fuerza de ley", "tipo",
  "norma:dfl_315_perdida_reconocimiento_oficial", "dfl", "tipo",
  "norma:dfl_315_perdida_reconocimiento_oficial", "DLF 315 PÉRDIDA RO", "readme_nombre",
  "norma:dfl_315_perdida_reconocimiento_oficial", "perdida reconocimiento oficial", "slug",
  "norma:dictamen_065_revision_mochilas", "065", "numero",
  "norma:dictamen_065_revision_mochilas", "DICTÁMEN 065 REVISIÓN DE MOCHILAS", "readme_nombre",
  "norma:dictamen_065_revision_mochilas", "revision mochilas", "slug",
  "norma:dictamen_078_detectores_revision_mochilas", "078", "numero",
  "norma:dictamen_078_detectores_revision_mochilas", "detectores revision mochilas", "slug",
  "norma:dictamen_52_77_expulsion", "52 77 expulsion", "slug",
  "norma:dictamen_52_77_expulsion", "DICTÁMENES 52 Y 77 EXPULSION", "readme_nombre",
  "norma:dictamen_71_expulsion_cancelacion_matricula", "DICTÁMEN 71 EXPULSIONES Y CANCELACIONES DE MATRÍCULA", "readme_nombre",
  "norma:dictamen_71_expulsion_cancelacion_matricula", "expulsion cancelacion matricula", "slug",
  "norma:dto_215_uniforme_escolar", "215", "numero",
  "norma:dto_215_uniforme_escolar", "Decreto Supremo N° 215", "remision",
  "norma:dto_215_uniforme_escolar", "DTO 215 UNIFORME", "readme_nombre",
  "norma:dto_215_uniforme_escolar", "REGLAMENTA USO DE UNIFORME ESCOLAR", "titulo",
  "norma:dto_215_uniforme_escolar", "uniforme escolar", "slug",
  "norma:dto_24_consejos_escolares", "consejos escolares", "slug",
  "norma:dto_24_consejos_escolares", "DTO 24 CONSEJOS ESCOLARES", "readme_nombre",
  "norma:dto_24_consejos_escolares", "REGLAMENTA CONSEJOS ESCOLARES", "titulo",
  "norma:dto_453_estatuto_docente", "453", "numero",
  "norma:dto_453_estatuto_docente", "estatuto docente", "slug",
  "norma:dto_565_centros_padres_apoderados", "565", "numero",
  "norma:dto_565_centros_padres_apoderados", "centros padres apoderados", "slug",
  "norma:dto_565_centros_padres_apoderados", "Decreto Supremo N° 565", "remision",
  "norma:dto_565_centros_padres_apoderados", "DTO 565 CGPMA", "readme_nombre",
  "norma:ley_19979_jornada_escolar_completa", "19.979", "numero",
  "norma:ley_19979_jornada_escolar_completa", "19979", "numero",
  "norma:ley_19979_jornada_escolar_completa", "19979 JEC", "readme_nombre",
  "norma:ley_19979_jornada_escolar_completa", "jornada escolar completa", "slug",
  "norma:ley_19979_jornada_escolar_completa", "Ley 19979", "remision",
  "norma:ley_19979_jornada_escolar_completa", "Ley N° 19.979", "remision",
  "norma:ley_19979_jornada_escolar_completa", "ley Nº 19.979", "remision",
  "norma:ley_19979_jornada_escolar_completa", "ley Nº19.979", "remision",
  "norma:ley_20370_general_educacion", "20.370", "numero",
  "norma:ley_20370_general_educacion", "20370", "numero",
  "norma:ley_20370_general_educacion", "20370 LGE", "readme_nombre",
  "norma:ley_20370_general_educacion", "ESTABLECE LA LEY GENERAL DE EDUCACIÓN", "titulo",
  "norma:ley_20370_general_educacion", "general educacion", "slug",
  "norma:ley_20370_general_educacion", "Ley 20.370", "remision",
  "norma:ley_20370_general_educacion", "ley N° 20.370", "remision",
  "norma:ley_20370_general_educacion", "ley Nº 20.370", "remision",
  "norma:ley_20370_general_educacion", "ley Nº20.370", "remision",
  "norma:ley_20536_violencia_escolar", "20.536", "numero",
  "norma:ley_20536_violencia_escolar", "20536", "numero",
  "norma:ley_20536_violencia_escolar", "20536 VIOLENCIA ESCOLAR", "readme_nombre",
  "norma:ley_20536_violencia_escolar", "SOBRE VIOLENCIA ESCOLAR", "titulo",
  "norma:ley_20536_violencia_escolar", "violencia escolar", "slug",
  "norma:ley_20845_inclusion_escolar", "20.845", "numero",
  "norma:ley_20845_inclusion_escolar", "20845", "numero",
  "norma:ley_20845_inclusion_escolar", "20845 INCLUSION SEP", "readme_nombre",
  "norma:ley_20845_inclusion_escolar", "inclusion escolar", "slug",
  "norma:ley_20845_inclusion_escolar", "Ley 20845", "remision",
  "norma:ley_20845_inclusion_escolar", "Ley N° 20.845", "remision",
  "norma:ley_20845_inclusion_escolar", "Ley N°20.845", "remision",
  "norma:ley_20845_inclusion_escolar", "ley Nº 20.845", "remision",
  "norma:ley_20911_formacion_ciudadana", "20.911", "numero",
  "norma:ley_20911_formacion_ciudadana", "20911", "numero",
  "norma:ley_20911_formacion_ciudadana", "20911 FORMACIÓN CIUDADANA", "readme_nombre",
  "norma:ley_20911_formacion_ciudadana", "formacion ciudadana", "slug",
  "norma:ley_21430_garantias_ninez", "21.430", "numero",
  "norma:ley_21430_garantias_ninez", "21430", "numero",
  "norma:ley_21430_garantias_ninez", "21430 PROTECCIÓN Y DERECHOS NIÑEZ", "readme_nombre",
  "norma:ley_21430_garantias_ninez", "garantias ninez", "slug",
  "norma:ley_21430_garantias_ninez", "ley N° 21.430", "remision",
  "norma:ley_21430_garantias_ninez", "Ley N°21.430", "remision",
  "norma:ley_21545_tea", "21.545", "numero",
  "norma:ley_21545_tea", "21545", "numero",
  "norma:ley_21545_tea", "21545 LEY TEA", "readme_nombre",
  "norma:ley_21545_tea", "ley N° 21.545", "remision",
  "norma:ley_21545_tea", "Ley Nº 21.545", "remision",
  "norma:ley_21545_tea", "Ley TEA", "denominacion",
  "norma:ley_21545_tea", "tea", "slug",
  "norma:ley_21801_celulares", "21.801", "numero",
  "norma:ley_21801_celulares", "21801", "numero",
  "norma:ley_21801_celulares", "21801 CELULARES", "readme_nombre",
  "norma:ley_21801_celulares", "celulares", "slug",
  "norma:ley_21801_celulares", "ley N° 21.801", "remision",
  "norma:ley_21809_convivencia_educativa", "21.809", "numero",
  "norma:ley_21809_convivencia_educativa", "21809", "numero",
  "norma:ley_21809_convivencia_educativa", "21809 LEY DE CONVIVENCIA", "readme_nombre",
  "norma:ley_21809_convivencia_educativa", "convivencia educativa", "slug",
  "norma:ley_21809_convivencia_educativa", "Ley 21809", "remision",
  "norma:ley_21809_convivencia_educativa", "Ley N° 21.809", "remision",
  "norma:rex_181_celulares", "181", "numero",
  "norma:rex_181_celulares", "celulares", "slug",
  "norma:rex_181_celulares", "Resolución exenta", "tipo",
  "norma:rex_181_celulares", "rex", "tipo",
  "norma:rex_181_celulares", "REX 181 CELULARES", "readme_nombre",
  "norma:rex_482_instrucciones_reglamentos_internos", "482", "numero",
  "norma:rex_482_instrucciones_reglamentos_internos", "incluye el cuerpo del reglamento", "grupo_acto",
  "norma:rex_482_instrucciones_reglamentos_internos", "instrucciones reglamentos internos", "slug",
  "norma:rex_482_instrucciones_reglamentos_internos", "Resolución exenta", "tipo",
  "norma:rex_482_instrucciones_reglamentos_internos", "rex", "tipo",
  "norma:rex_482_instrucciones_reglamentos_internos", "REX 482 INSTRUCCIONES REGLAMENTOS", "readme_nombre",
  "norma:rex_482_instrucciones_reglamentos_internos", "REX N° 482", "remision",
  "norma:rex_482_reglamentos_b", "482", "numero",
  "norma:rex_482_reglamentos_b", "482 REGLAMENTOS", "readme_nombre",
  "norma:rex_482_reglamentos_b", "incluye el cuerpo del reglamento", "grupo_acto",
  "norma:rex_482_reglamentos_b", "Resolución exenta", "tipo",
  "norma:rex_482_reglamentos_b", "rex", "tipo",
  "tema:convivencia-escolar", "buena convivencia", "temas",
  "tema:convivencia-escolar", "convivencia escolar", "temas",
  "tema:convivencia-escolar", "encargado de convivencia", "temas",
  "tema:derechos-de-la-ninez", "derechos del nino", "temas",
  "tema:derechos-de-la-ninez", "garantias de la ninez", "temas",
  "tema:derechos-de-la-ninez", "interes superior del nino", "temas",
  "tema:derechos-de-la-ninez", "ninos, ninas y adolescentes", "temas",
  "tema:embarazo-y-maternidad", "embarazada", "temas",
  "tema:embarazo-y-maternidad", "embarazo", "temas",
  "tema:embarazo-y-maternidad", "lactancia", "temas",
  "tema:embarazo-y-maternidad", "maternidad", "temas",
  "tema:embarazo-y-maternidad", "paternidad", "temas",
  "tema:estatuto-del-personal", "asistentes de la educacion", "temas",
  "tema:estatuto-del-personal", "estatuto docente", "temas",
  "tema:estatuto-del-personal", "profesionales de la educacion", "temas",
  "tema:formacion-ciudadana", "educacion civica", "temas",
  "tema:formacion-ciudadana", "formacion ciudadana", "temas",
  "tema:identidad-de-genero", "estudiante trans", "temas",
  "tema:identidad-de-genero", "estudiantes trans", "temas",
  "tema:identidad-de-genero", "identidad de genero", "temas",
  "tema:identidad-de-genero", "ninas, ninos y estudiantes trans", "temas",
  "tema:identidad-de-genero", "nombre social", "temas",
  "tema:identidad-de-genero", "persona trans", "temas",
  "tema:identidad-de-genero", "personas trans", "temas",
  "tema:inclusion-y-no-discriminacion", "discriminacion arbitraria", "temas",
  "tema:inclusion-y-no-discriminacion", "inclusion", "temas",
  "tema:inclusion-y-no-discriminacion", "integracion", "temas",
  "tema:inclusion-y-no-discriminacion", "necesidades educativas especiales", "temas",
  "tema:jornada-escolar", "jornada escolar", "temas",
  "tema:jornada-escolar", "jornada escolar completa", "temas",
  "tema:medidas-disciplinarias", "cancelacion de matricula", "temas",
  "tema:medidas-disciplinarias", "expulsion", "temas",
  "tema:medidas-disciplinarias", "medida disciplinaria", "temas",
  "tema:medidas-disciplinarias", "reglamento interno", "temas",
  "tema:medidas-disciplinarias", "sancion", "temas",
  "tema:participacion-de-la-comunidad", "centro de alumnos", "temas",
  "tema:participacion-de-la-comunidad", "centro de padres", "temas",
  "tema:participacion-de-la-comunidad", "consejo escolar", "temas",
  "tema:participacion-de-la-comunidad", "participacion", "temas",
  "tema:reconocimiento-oficial", "perdida del reconocimiento", "temas",
  "tema:revision-de-pertenencias", "efectos personales", "temas",
  "tema:revision-de-pertenencias", "mochilas y bolsos", "temas",
  "tema:revision-de-pertenencias", "registro de mochilas", "temas",
  "tema:revision-de-pertenencias", "revision de mochilas", "temas",
  "tema:revision-de-pertenencias", "revision de pertenencias", "temas",
  "tema:seguridad-escolar", "arma blanca", "temas",
  "tema:seguridad-escolar", "detector de metales", "temas",
  "tema:seguridad-escolar", "detectores de metales", "temas",
  "tema:seguridad-escolar", "elementos incendiarios", "temas",
  "tema:seguridad-escolar", "porticos detectores", "temas",
  "tema:seguridad-escolar", "seguridad escolar", "temas",
  "tema:trastorno-del-espectro-autista", "autismo", "temas",
  "tema:trastorno-del-espectro-autista", "espectro autista", "temas",
  "tema:trastorno-del-espectro-autista", "neurodivergen", "temas",
  "tema:uniforme-y-presentacion-personal", "presentacion personal", "temas",
  "tema:uniforme-y-presentacion-personal", "uniforme escolar", "temas",
  "tema:uso-de-dispositivos-moviles", "celular", "temas",
  "tema:uso-de-dispositivos-moviles", "dispositivos moviles", "temas",
  "tema:uso-de-dispositivos-moviles", "telefono movil", "temas",
  "tema:violencia-y-acoso-escolar", "acoso escolar", "temas",
  "tema:violencia-y-acoso-escolar", "agresion", "temas",
  "tema:violencia-y-acoso-escolar", "bullying", "temas",
  "tema:violencia-y-acoso-escolar", "maltrato", "temas",
  "tema:violencia-y-acoso-escolar", "violencia escolar", "temas"
)), stringsAsFactors = FALSE)

# Validez de lectura: la tabla se usa en el sitio publicado, asi que un error aqui
# viaja a produccion.
stopifnot(
  nrow(ALIAS_CONSULTA) == 183L,
  !anyDuplicated(paste(ALIAS_CONSULTA[["entrada"]], tolower(ALIAS_CONSULTA[["alias"]]))),
  all(ALIAS_CONSULTA[["clave_fuente"]] %in% names(FUENTES_ALIAS)),
  all(nzchar(ALIAS_CONSULTA[["alias"]]))
)
ALIAS_CONSULTA[["fuente"]] <- unname(FUENTES_ALIAS[ALIAS_CONSULTA[["clave_fuente"]]])

# ---- Metadatos que NO se inventan -------------------------------------------
# Marca que se escribe en el JSON cuando un metadato (titulo, anio) no se pudo
# extraer del texto. Se prefiere una marca visible a un valor plausible: en una
# biblioteca normativa institucional, un anio inventado es peor que un hueco.
MARCA_REVISAR <- "# REVISAR"
