# =============================================================================
# 00_generar_borradores.R
# -----------------------------------------------------------------------------
# Proposito: sembrar los BORRADORES de las piezas interpretativas (fichas por
#            ley, preguntas frecuentes y glosario) en
#            20_insumos/curaduria/piezas/borradores/.
#
# NO ES UN PASO DEL PIPELINE, por la misma razon que 00_ocr_documentos.R: lo que
# escribe lo va a editar y validar una persona, y una corrida que sobreescriba
# esa edicion la destruye. NUNCA sobreescribe un archivo existente; si un
# borrador ya esta ahi, lo deja intacto y lo dice.
#
# QUE PONE Y QUE NO. Rellena solo lo que se puede DERIVAR del corpus:
#   - datos verificables de la norma (titulo, anio, articulado, temas),
#   - extractos LITERALES con su ancla,
#   - definiciones que el propio texto declara ("Se entendera por X ...").
# Deja EN BLANCO, con marca visible, todo lo que exige interpretacion (que
# regula, a quien aplica, obligaciones clave). Rellenar esos campos es el
# trabajo del equipo de convivencia y es justo lo que el invariante de validacion
# protege: el sitio no publica una pieza hasta que una persona la firma.
#
# Uso: Rscript 00_generar_borradores.R
# =============================================================================

source(here::here("10_utils", "10_utils.R"))
instalar_si_falta(c("jsonlite", "fs", "here", "stringi"))
source(here::here("10_utils", "10_configuracion.R"))

ORIGEN <- "00_generar_borradores"
DIR_BORRADORES <- ruta_insumos("curaduria", "piezas", "borradores")
fs::dir_create(DIR_BORRADORES, recurse = TRUE)

cat_json <- jsonlite::fromJSON(ruta_datos("catalogo.json"), simplifyDataFrame = FALSE)
normas <- lapply(cat_json$normas, function(x)
  jsonlite::fromJSON(ruta_normas(paste0(x$slug, ".json")), simplifyDataFrame = FALSE))
names(normas) <- vapply(normas, function(n) n$slug, character(1))

ORDEN_CAPA <- c(ley = 1L, dfl = 2L, dto = 2L, circular = 3L, rex = 3L, dictamen = 4L)
# nombre_corto() viene de 10_utils/10_utils.R, compartida con 34_generar_paginas.R.

escribir_pieza <- function(nombre, front, cuerpo) {
  ruta <- fs::path(DIR_BORRADORES, paste0(nombre, ".md"))
  if (fs::file_exists(ruta)) {
    log_msg(sprintf("%s: ya existe, se deja intacto.", nombre), origen = ORIGEN)
    return(FALSE)
  }
  writeLines(c("---", front, "---", "", cuerpo), ruta)
  TRUE
}

# El front matter es identico en las tres clases de pieza: el generador del sitio
# lo lee siempre igual y no tiene que saber de que tipo es para decidir si
# publica. `validado_por` y `fecha_validacion` nacen nulos a proposito.
front_matter <- function(tipo, titulo, fuentes, extra = character(0)) {
  c(sprintf("tipo: %s", tipo),
    sprintf("titulo: %s", as.character(jsonlite::toJSON(titulo, auto_unbox = TRUE))),
    "estado: borrador",
    "validado_por: null",
    "fecha_validacion: null",
    extra,
    "fuentes:",
    if (length(fuentes) == 0L) "  []" else
      vapply(fuentes, function(f)
        sprintf("  - {norma: %s, articulo: %s, ancla: \"%s.html#%s\"}",
                f$norma, f$articulo, f$norma, f$articulo), character(1)),
    sprintf("generado_por: %s", "00_generar_borradores.R"),
    sprintf("generado_el: %s", format(Sys.Date())))
}

# ---- Fichas por ley ----------------------------------------------------------
PENDIENTE <- "<!-- PENDIENTE DE REDACCIÓN POR EL EQUIPO DE CONVIVENCIA -->"

leyes <- Filter(function(n) identical(n$tipo, "ley"), normas)
n_fichas <- 0L
for (n in leyes) {
  arts <- Filter(function(a) isTRUE(a$es_articulo), n$articulos)
  primero <- if (length(arts) > 0L) arts[[1]] else NULL
  fuentes <- if (is.null(primero)) list() else list(list(norma = n$slug, articulo = primero$id))

  cuerpo <- c(
    sprintf("> **Borrador generado automáticamente el %s.** Los datos verificables ya",
            format(Sys.Date())),
    "> están rellenos; los campos de interpretación están en blanco a propósito.",
    "> Esta pieza NO se publica hasta que alguien del equipo la complete, ponga",
    "> `estado: validada` y firme en `validado_por`.",
    "",
    "## Datos de la norma",
    "",
    sprintf("- **Norma:** [%s](%s.html)", nombre_corto(n), n$slug),
    sprintf("- **Título oficial:** %s",
            if (is.null(n$titulo)) "*no consta en el documento*" else n$titulo),
    sprintf("- **Año de publicación:** %s",
            if (is.null(n$anio)) "*no consta*" else as.character(n$anio)),
    sprintf("- **Artículos:** %d", n$n_articulos),
    sprintf("- **Temas:** %s",
            if (length(n$tema) == 0L) "*sin asignar*" else paste(n$tema, collapse = ", ")),
    sprintf("- **Vigencia:** %s", n$vigencia$estado),
    "",
    if (!is.null(primero)) c(
      "## Primer artículo, textual",
      "",
      sprintf("> %s", gsub("\n\n", "\n>\n> ", trimws(primero$texto))),
      "",
      sprintf("[Leer en contexto: %s](%s.html#%s)", primero$etiqueta, n$slug, primero$id),
      "") else NULL,
    "## Qué regula",
    "", PENDIENTE, "",
    "## A quién aplica",
    "", PENDIENTE, "",
    "## Obligaciones clave para el establecimiento",
    "",
    "<!-- Una obligación por viñeta. CADA UNA debe citar el artículo que la impone,",
    "     con el formato: - Obligación. ([Artículo N](slug.html#art-N)) -->",
    PENDIENTE, "",
    "## Relación con otras normas",
    "",
    "<!-- El sitio ya deriva relaciones por vigencia, remisión textual y tema.",
    "     Aquí va solo lo que esas tres no capturan. -->",
    PENDIENTE, "")

  if (escribir_pieza(paste0("ficha_", n$slug),
                     front_matter("ficha", paste("Ficha:", nombre_corto(n)), fuentes,
                                  extra = sprintf("norma: %s", n$slug)),
                     cuerpo)) n_fichas <- n_fichas + 1L
}
log_msg(sprintf("Fichas de ley: %d escritas de %d leyes.", n_fichas, length(leyes)),
        origen = ORIGEN)

# ---- Preguntas frecuentes ----------------------------------------------------
# Casos reales del equipo de convivencia. La PREGUNTA es una semilla curatorial;
# la RESPUESTA no se redacta: se arma con extractos literales de las normas del
# tema, ordenados por jerarquia normativa. Ordenar no es interpretar.
CASOS <- list(
  list(id = "revision_de_mochilas",   pregunta = "¿Se puede revisar la mochila de un estudiante?",            tema = "revisión de pertenencias"),
  list(id = "expulsion",              pregunta = "¿Qué exige la normativa para expulsar a un estudiante?",     tema = "medidas disciplinarias"),
  list(id = "celulares",              pregunta = "¿Se puede restringir el uso de celulares en el establecimiento?", tema = "uso de dispositivos móviles"),
  list(id = "acoso_escolar",          pregunta = "¿Qué es acoso escolar y qué obliga a hacer?",                tema = "violencia y acoso escolar"),
  list(id = "estudiante_embarazada",  pregunta = "¿Qué derechos tiene una estudiante embarazada o madre?",     tema = "embarazo y maternidad"),
  list(id = "identidad_de_genero",    pregunta = "¿Cómo debe tratarse el nombre social de un estudiante trans?", tema = "identidad de género"),
  list(id = "estudiante_tea",         pregunta = "¿Qué obligaciones hay frente a un estudiante con TEA?",      tema = "trastorno del espectro autista"),
  list(id = "consejo_escolar",        pregunta = "¿Quiénes integran el consejo escolar y qué puede hacer?",    tema = "participación de la comunidad"),
  list(id = "convivencia_escolar",    pregunta = "¿Qué es la buena convivencia escolar según la normativa?",   tema = "convivencia escolar"),
  list(id = "uniforme",               pregunta = "¿Puede el establecimiento exigir un uniforme determinado?",  tema = "uniforme y presentación personal"),
  list(id = "seguridad_y_deteccion",  pregunta = "¿Se pueden instalar detectores de metales en el acceso?",    tema = "seguridad escolar"),
  list(id = "inclusion",              pregunta = "¿Qué exige la normativa sobre inclusión y no discriminación?", tema = "inclusión y no discriminación")
)

extracto_de <- function(n, claves) {
  plano <- function(x) tolower(stringi::stri_trans_general(x, "Latin-ASCII"))
  patron <- paste0("\\b(?:", paste(claves, collapse = "|"), ")")
  segs <- c(Filter(function(a) isTRUE(a$es_articulo), n$articulos),
            Filter(function(a) !isTRUE(a$es_articulo), n$articulos))
  for (seg in segs) {
    for (b in strsplit(seg$texto, "\n\n", fixed = TRUE)[[1]]) {
      if (nzchar(trimws(b)) && grepl(patron, plano(b), perl = TRUE)) {
        return(list(seg = seg, texto = trimws(b)))
      }
    }
  }
  NULL
}

n_faq <- 0L
for (caso in CASOS) {
  del_tema <- Filter(function(n) caso$tema %in% n$tema, normas)
  del_tema <- del_tema[order(ORDEN_CAPA[vapply(del_tema, function(n) n$tipo, character(1))])]
  del_tema <- utils::head(del_tema, 4L)
  claves <- TEMAS_PALABRAS_CLAVE[[caso$tema]]
  if (is.null(claves)) claves <- caso$tema

  fuentes <- list(); cuerpo_ext <- character(0)
  for (n in del_tema) {
    ex <- extracto_de(n, claves)
    if (is.null(ex)) next
    fuentes[[length(fuentes) + 1L]] <- list(norma = n$slug, articulo = ex$seg$id)
    cuerpo_ext <- c(cuerpo_ext,
      sprintf("### %s%s", nombre_corto(n),
              if (identical(n$vigencia$estado, "sustituido")) " (sustituida)" else ""),
      "",
      sprintf("> %s", gsub("\n\n", "\n>\n> ", ex$texto)),
      "",
      sprintf("[Leer en contexto: %s](%s.html#%s)", ex$seg$etiqueta, n$slug, ex$seg$id),
      "")
  }

  cuerpo <- c(
    sprintf("> **Borrador generado automáticamente el %s.** Los extractos son texto",
            format(Sys.Date())),
    "> literal de las normas del tema, ordenados por jerarquía normativa. No hay",
    "> respuesta redactada: escribirla es el trabajo del equipo, y hasta que",
    "> alguien la firme esta pieza no se publica.",
    "",
    sprintf("## %s", caso$pregunta),
    "",
    "### Respuesta breve",
    "",
    "<!-- 2 a 4 líneas. Cada afirmación debe apoyarse en uno de los extractos de",
    "     abajo, citando su enlace. -->",
    PENDIENTE,
    "",
    "## Qué dicen las normas",
    "",
    if (length(cuerpo_ext) == 0L)
      c("*Ninguna norma del corpus produjo un extracto para este tema.*", "") else cuerpo_ext,
    "## Advertencias para el caso concreto",
    "", PENDIENTE, "")

  if (escribir_pieza(paste0("faq_", caso$id),
                     front_matter("faq", caso$pregunta, fuentes,
                                  extra = sprintf("tema: %s",
                                                  as.character(jsonlite::toJSON(caso$tema, auto_unbox = TRUE)))),
                     cuerpo)) n_faq <- n_faq + 1L
}
log_msg(sprintf("Preguntas frecuentes: %d escritas de %d casos.", n_faq, length(CASOS)),
        origen = ORIGEN)

# ---- Glosario ----------------------------------------------------------------
# Solo se define lo que el corpus define. El patron busca la formula con que el
# derecho chileno introduce una definicion legal ("Se entendera por X ..."), y la
# definicion que se publica es el texto del articulo, literal, con su ancla.
# Un termino sin definicion en el corpus NO se define de memoria: se lista como
# pendiente de fuente, que es informacion util y verdadera, a diferencia de una
# definicion de diccionario en un sitio normativo.
PATRON_DEFINICION <- "(?i)se\\s+entender[aá]\\s+por\\s+[\"“]?([^,.;:\"”]{4,60})|(?i)se\\s+entiende\\s+por\\s+[\"“]?([^,.;:\"”]{4,60})"

definiciones <- list()
for (n in normas) {
  for (seg in n$articulos) {
    m <- regmatches(seg$texto, gregexpr(PATRON_DEFINICION, seg$texto, perl = TRUE))[[1]]
    for (x in unique(m)) {
      termino <- trimws(sub("(?i)^se\\s+entender[aá]\\s+por\\s+|^se\\s+entiende\\s+por\\s+", "", x, perl = TRUE))
      termino <- trimws(gsub("[\"“”]", "", termino))
      # Se descartan los fragmentos que arrastran las notas marginales de la
      # Biblioteca del Congreso ("... Art", "... EDUCACION") y los demasiado
      # cortos para ser un termino.
      if (nchar(termino) < 4L) next
      if (grepl("(?i)\\bArt$|\\bEDUCACI", termino, perl = TRUE)) next
      if (identical(tolower(termino), "tal")) next
      definiciones[[length(definiciones) + 1L]] <- list(
        termino = termino, norma = n$slug, articulo = seg$id,
        etiqueta = seg$etiqueta, corto = nombre_corto(n),
        ocr = identical(n$origen_texto, "ocr_pendiente_revision"))
    }
  }
}
orden <- order(tolower(stringi::stri_trans_general(
  vapply(definiciones, function(d) d$termino, character(1)), "Latin-ASCII")))
definiciones <- definiciones[orden]

fuentes_glosario <- lapply(definiciones, function(d)
  list(norma = d$norma, articulo = d$articulo))

cuerpo_glosario <- c(
  sprintf("> **Borrador generado automáticamente el %s.** Cada término de abajo lo",
          format(Sys.Date())),
  "> **define el propio corpus**: la entrada apunta al artículo que contiene la",
  "> definición legal. Falta redactar la explicación en lenguaje llano y decidir",
  "> qué entradas conservar. Esta pieza no se publica hasta que alguien la firme.",
  "",
  sprintf("Definiciones legales detectadas en el corpus: **%d**.", length(definiciones)),
  "",
  "## Términos definidos por el corpus",
  "",
  unlist(lapply(definiciones, function(d) c(
    sprintf("### %s", d$termino),
    "",
    sprintf("- **Definido en:** [%s, %s](%s.html#%s)%s",
            d$corto, d$etiqueta, d$norma, d$articulo,
            if (d$ocr) " · *transcripción OCR en revisión*" else ""),
    "- **Explicación en lenguaje llano:** " ,
    PENDIENTE,
    ""))),
  "## Pendientes de fuente",
  "",
  "Términos que el equipo usa a diario y que **el corpus no define**. No se",
  "definen aquí de memoria: hacerlo pondría una definición sin respaldo normativo",
  "en un sitio institucional. Cada uno necesita que se identifique la norma que lo",
  "define y se incorpore al corpus, o que se declare explícitamente que es un uso",
  "del equipo y no una definición legal.",
  "",
  "- cancelación de matrícula",
  "- medida formativa",
  "- debido proceso escolar",
  "- protocolo de actuación",
  "- dupla psicosocial",
  "")

n_glo <- escribir_pieza("glosario",
                        front_matter("glosario", "Glosario legal", fuentes_glosario),
                        cuerpo_glosario)
log_msg(sprintf("Glosario: %s (%d definiciones detectadas, %d términos pendientes de fuente).",
                if (n_glo) "escrito" else "ya existia", length(definiciones), 5L),
        origen = ORIGEN)

log_msg(sprintf("Borradores en %s: %d archivos.",
                fs::path_rel(DIR_BORRADORES, here::here()),
                length(fs::dir_ls(DIR_BORRADORES, glob = "*.md"))),
        origen = ORIGEN)
