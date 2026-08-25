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
  rex      = "Resolucion exenta",
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

# Encabezado de articulo. Ancla en inicio de linea (perl, multiline) para no
# capturar las CITAS a articulos de otras normas que abundan en dictamenes y
# circulares ("...conforme al articulo 6 letra d) de la ley 20.529..."), que van
# siempre en medio de una frase. Sin este anclaje, un dictamen de 6 paginas
# producia 6 "articulos" que no son suyos.
REGEX_ENCABEZADO_ARTICULO <- paste0(
  "^[ \\t]*",
  "(?:ART[IÍ]CULO|Art[ií]culo|ARTICULO|Art\\.)",
  "[ \\t]+",
  "(\\d+|[A-Za-zÁÉÍÓÚáéíóú]+)",
  "[ \\t]*(?:°|º)?",
  "[ \\t]*(bis|ter|quater|quinquies)?",
  "[ \\t]*(transitorio)?",
  "[ \\t]*(?=[.:\\-])"
)

# Marca de inicio de las disposiciones transitorias. Se detecta aparte del
# encabezado porque en muchas normas la palabra "transitorio" no viaja en cada
# articulo, sino una sola vez en el titulo de la seccion, y desde ahi TODO lo
# que sigue es transitorio.
REGEX_SECCION_TRANSITORIA <- "^[ \\t]*(DISPOSICIONES\\s+TRANSITORIAS|ART[IÍ]CULOS?\\s+TRANSITORIOS?)"

# ---- Diccionario tematico ---------------------------------------------------
# DECISION METODOLOGICA DECLARADA, no inferencia del asistente.
# El tema NO viene marcado en los documentos: es una columna derivada. Se asigna
# por coincidencia de palabras clave sobre el texto extraido, con este
# diccionario cerrado y auditable. Se prefiere un diccionario explicito a una
# clasificacion por modelo porque el resultado tiene que ser identico en cada
# corrida y revisable linea por linea por el equipo de convivencia.
# Una norma puede quedar en varios temas o en ninguno (tema = lista vacia).
TEMAS_PALABRAS_CLAVE <- list(
  "convivencia escolar"        = c("convivencia escolar", "buena convivencia", "encargado de convivencia"),
  "violencia y acoso escolar"  = c("violencia escolar", "acoso escolar", "maltrato", "bullying", "agresion"),
  "medidas disciplinarias"     = c("expulsion", "cancelacion de matricula", "medida disciplinaria", "reglamento interno", "sancion"),
  "inclusion y no discriminacion" = c("inclusion", "discriminacion arbitraria", "necesidades educativas especiales", "integracion"),
  "derechos de la ninez"       = c("interes superior del nino", "garantias de la ninez", "derechos del nino", "ninos, ninas y adolescentes"),
  "participacion de la comunidad" = c("consejo escolar", "centro de padres", "centro de alumnos", "participacion"),
  "identidad de genero"        = c("identidad de genero", "nombre social", "trans"),
  "embarazo y maternidad"      = c("embarazada", "embarazo", "maternidad", "paternidad", "lactancia"),
  "trastorno del espectro autista" = c("espectro autista", "autismo", "neurodivergen"),
  "uso de dispositivos moviles" = c("dispositivos moviles", "telefono movil", "celular"),
  "uniforme y presentacion personal" = c("uniforme escolar", "presentacion personal"),
  "formacion ciudadana"        = c("formacion ciudadana", "educacion civica"),
  "jornada escolar"            = c("jornada escolar completa", "jornada escolar"),
  "estatuto del personal"      = c("estatuto docente", "asistentes de la educacion", "profesionales de la educacion"),
  "reconocimiento oficial"     = c("reconocimiento oficial", "perdida del reconocimiento")
)

# ---- Metadatos que NO se inventan -------------------------------------------
# Marca que se escribe en el JSON cuando un metadato (titulo, anio) no se pudo
# extraer del texto. Se prefiere una marca visible a un valor plausible: en una
# biblioteca normativa institucional, un anio inventado es peor que un hueco.
MARCA_REVISAR <- "# REVISAR"
