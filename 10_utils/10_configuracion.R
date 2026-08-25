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
  "identidad de género"        = c("identidad de genero", "nombre social", "trans"),
  "embarazo y maternidad"      = c("embarazada", "embarazo", "maternidad", "paternidad", "lactancia"),
  "trastorno del espectro autista" = c("espectro autista", "autismo", "neurodivergen"),
  "uso de dispositivos móviles" = c("dispositivos moviles", "telefono movil", "celular"),
  "uniforme y presentación personal" = c("uniforme escolar", "presentacion personal"),
  "formación ciudadana"        = c("formacion ciudadana", "educacion civica"),
  "jornada escolar"            = c("jornada escolar completa", "jornada escolar"),
  "estatuto del personal"      = c("estatuto docente", "asistentes de la educacion", "profesionales de la educacion"),
  "reconocimiento oficial"     = c("reconocimiento oficial", "perdida del reconocimiento")
)

# ---- Metadatos que NO se inventan -------------------------------------------
# Marca que se escribe en el JSON cuando un metadato (titulo, anio) no se pudo
# extraer del texto. Se prefiere una marca visible a un valor plausible: en una
# biblioteca normativa institucional, un anio inventado es peor que un hueco.
MARCA_REVISAR <- "# REVISAR"
