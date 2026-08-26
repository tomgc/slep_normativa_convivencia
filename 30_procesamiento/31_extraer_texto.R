# =============================================================================
# 31_extraer_texto.R
# -----------------------------------------------------------------------------
# Proposito: PDF -> texto plano limpio, un archivo por norma en
#            40_salidas/intermedios/texto/<slug>.txt, mas un manifiesto
#            40_salidas/intermedios/extraccion.json con lo medido por documento.
#
# INVARIANTE DE FIDELIDAD: el texto no se corrige, no se resume y no se
# parafrasea. La unica limpieza permitida es la que quita ARTEFACTOS DE
# MAQUETACION del PDF, que no son parte de la norma:
#   1. encabezados y pies de pagina repetidos (detectados programaticamente),
#   2. cortes de palabra por guion al final de linea,
#   3. saltos de linea internos de un parrafo (son ancho de columna, no texto).
# Todo lo demas se conserva byte a byte, incluidas comillas, mayusculas,
# numeracion romana y erratas del original.
# =============================================================================

source(here::here("10_utils", "10_utils.R"))
instalar_si_falta(c("pdftools", "jsonlite", "fs", "here"))
source(here::here("10_utils", "10_configuracion.R"))

ORIGEN <- "31_extraer_texto"

# ---- Deteccion de encabezados y pies repetidos ------------------------------
# Se comparan las lineas NORMALIZADAS (espacios colapsados y digitos sustituidos
# por #) porque el pie de la Biblioteca del Congreso trae el numero de pagina y
# la fecha de generacion: sin normalizar, "pagina 1 de 3" y "pagina 2 de 3" son
# lineas distintas y ninguna se repite nunca.
# Solo se miran las 3 primeras y las 3 ultimas lineas no vacias de cada pagina:
# una frase legal que por casualidad se repita en el cuerpo no es un pie y no se
# puede borrar.
normalizar_linea <- function(x) {
  x |>
    trimws() |>
    gsub(pattern = "[0-9]+", replacement = "#") |>
    gsub(pattern = "\\s+",   replacement = " ")
}

detectar_repetidos <- function(paginas) {
  n <- length(paginas)
  if (n < 3L) return(character(0))
  zona <- unlist(lapply(paginas, function(p) {
    l <- strsplit(p, "\n", fixed = TRUE)[[1]]
    l <- l[nzchar(trimws(l))]
    if (length(l) == 0L) return(character(0))
    unique(normalizar_linea(c(utils::head(l, 3L), utils::tail(l, 3L))))
  }))
  frec  <- table(zona)
  umbral <- max(2L, ceiling(0.6 * n))
  nombres <- names(frec)[frec >= umbral]
  nombres[nzchar(nombres)]
}

quitar_repetidos <- function(pagina, repetidos) {
  if (length(repetidos) == 0L) return(pagina)
  l <- strsplit(pagina, "\n", fixed = TRUE)[[1]]
  no_vacias <- which(nzchar(trimws(l)))
  if (length(no_vacias) == 0L) return(pagina)
  # Solo se borra en la zona de encabezado/pie, nunca en medio del cuerpo.
  zona <- c(utils::head(no_vacias, 3L), utils::tail(no_vacias, 3L))
  borrar <- zona[normalizar_linea(l[zona]) %in% repetidos]
  if (length(borrar) > 0L) l <- l[-borrar]
  paste(l, collapse = "\n")
}

# ---- Reflujo de parrafos ----------------------------------------------------
# Un parrafo del PDF llega partido en lineas de ~85 caracteres: eso es el ancho
# de la caja de texto, no el texto. Se reunen las lineas de cada bloque (bloques
# separados por linea en blanco) en un solo parrafo. Las palabras cortadas por
# guion al final de linea se reunen sin el guion, y SOLO cuando lo que hay a cada
# lado es minuscula: "politico-\nsocial" es un guion legitimo del original y no
# se toca, "estable-\ncimientos" es un corte de maquetacion y si.
reflujo_bloque <- function(lineas) {
  txt <- paste(trimws(lineas), collapse = "\n")
  txt <- gsub("([a-záéíóúüñ])[-­]\n([a-záéíóúüñ])", "\\1\\2", txt, perl = TRUE)
  txt <- gsub("\n", " ", txt, fixed = TRUE)
  gsub("[ \t]+", " ", txt) |> trimws()
}

reflujo_pagina <- function(pagina) {
  l <- strsplit(pagina, "\n", fixed = TRUE)[[1]]
  vacia <- !nzchar(trimws(l))
  grupo <- cumsum(vacia)
  bloques <- split(l[!vacia], grupo[!vacia])
  bloques <- vapply(bloques, reflujo_bloque, character(1))
  bloques[nzchar(bloques)]
}

# ---- Union de bloques a traves del salto de pagina --------------------------
# Un articulo partido entre dos paginas llega como dos bloques. Se unen solo si
# el ultimo bloque de la pagina anterior NO termina en puntuacion de cierre y el
# primero de la siguiente empieza en minuscula: la conjuncion de ambas
# condiciones es lo que distingue una frase cortada de dos parrafos vecinos.
unir_a_traves_de_paginas <- function(bloques_por_pagina) {
  todos <- character(0)
  for (bl in bloques_por_pagina) {
    if (length(bl) == 0L) next
    if (length(todos) > 0L) {
      ultimo <- todos[length(todos)]
      corte <- !grepl("[.:;!?\"”)]\\s*$", ultimo) &&
               grepl("^[a-záéíóúüñ(]", bl[1])
      if (corte) {
        todos[length(todos)] <- paste(ultimo, bl[1])
        bl <- bl[-1]
      }
    }
    todos <- c(todos, bl)
  }
  todos
}

# ---- Extraccion de un documento ---------------------------------------------
extraer_documento <- function(ruta_pdf) {
  slug <- sub("\\.pdf$", "", basename(ruta_pdf))
  info <- pdftools::pdf_info(ruta_pdf)
  paginas <- pdftools::pdf_text(ruta_pdf)

  # Validez de lectura (POLITICA 5.3.8): el numero de paginas leidas tiene que
  # coincidir con el que declara el propio PDF. Si no coincide, pdf_text() leyo
  # otra cosa y todo lo que siga esta mal.
  stopifnot(length(paginas) == info$pages)

  bruto <- paste(paginas, collapse = "\n")
  alfabeticos <- nchar(gsub("[^[:alpha:]]", "", bruto))
  sin_capa <- alfabeticos < MIN_CHARS_ALFABETICOS

  # Cabecera BRUTA de la primera pagina, en lineas y sin reflujo. La necesita el
  # paso 32 para extraer titulo y anio: en la version reflujada la ficha de la
  # Biblioteca del Congreso ("Ley 20536" / titulo en mayusculas / "MINISTERIO DE
  # ..." / "Fecha Publicacion: ...") queda fundida en un solo parrafo, y ahi los
  # campos ya no se distinguen unos de otros. Es el mismo texto, en la forma en
  # que todavia se puede leer por posicion.
  cabecera <- {
    l <- strsplit(paginas[1], "\n", fixed = TRUE)[[1]]
    l <- trimws(l[nzchar(trimws(l))])
    utils::head(l, 25L)
  }

  if (sin_capa) {
    # Sin capa de texto: es un escaneo de imagen. Se busca la transcripcion que
    # dejo 00_ocr_documentos.R en 20_insumos/ocr/. Si existe se usa; si no, el
    # documento queda sin texto y el sitio lo declara.
    dir_ocr <- ruta_insumos("ocr", slug)
    if (!fs::dir_exists(dir_ocr)) {
      log_msg(sprintf("%s: SIN capa de texto (%d caracteres en %d páginas) y SIN reconocimiento. Correr Rscript 00_ocr_documentos.R.",
                      slug, alfabeticos, info$pages),
              nivel = "WARN", origen = ORIGEN)
      return(list(slug = slug, paginas = info$pages, chars_alfabeticos = alfabeticos,
                  sin_capa_texto = TRUE, origen_texto = "sin_texto", chars_limpio = 0L,
                  lineas_maquetacion = 0L, cabecera = character(0), texto = ""))
    }

    paginas_ocr <- sort(fs::dir_ls(dir_ocr, glob = "*.txt"))
    # Compuerta: la transcripcion tiene que cubrir el documento entero. Una a la
    # que le falta una pagina se ve, desde aguas abajo, igual que una completa.
    if (length(paginas_ocr) != info$pages) {
      stop(sprintf("%s: el reconocimiento tiene %d páginas y el PDF %d. Rehacer con Rscript 00_ocr_documentos.R --rehacer.",
                   slug, length(paginas_ocr), info$pages))
    }

    # EL TEXTO RECONOCIDO NO SE REFLUYE NI SE LIMPIA. Se conservan los saltos de
    # linea tal como salieron del reconocedor. Dos razones: a un texto que nadie
    # ha revisado todavia no se le adivina ademas la estructura de parrafos, y la
    # revision es mucho mas facil si lo que se lee en el sitio es exactamente lo
    # que hay en el archivo que se corrige.
    # El separador de pagina permite que 32 segmente por pagina, que es la unica
    # unidad honesta aqui: una transcripcion automatica no tiene articulos, tiene
    # paginas.
    texto <- paste(vapply(paginas_ocr, function(f)
      paste(readLines(f, warn = FALSE), collapse = "\n"), character(1)),
      collapse = SEPARADOR_PAGINA_OCR)

    log_msg(sprintf("%s: sin capa de texto; se usa el reconocimiento de %d páginas (%d caracteres).",
                    slug, length(paginas_ocr), nchar(texto)),
            origen = ORIGEN)

    return(list(slug = slug, paginas = info$pages, chars_alfabeticos = alfabeticos,
                sin_capa_texto = TRUE, origen_texto = "ocr_pendiente_revision",
                chars_limpio = nchar(texto), lineas_maquetacion = 0L,
                cabecera = character(0), texto = texto))
  }

  repetidos <- detectar_repetidos(paginas)
  limpias   <- vapply(paginas, quitar_repetidos, character(1), repetidos = repetidos,
                      USE.NAMES = FALSE)
  bloques   <- unir_a_traves_de_paginas(lapply(limpias, reflujo_pagina))
  texto     <- paste(bloques, collapse = "\n\n")

  stopifnot(nchar(texto) > 0)

  log_msg(sprintf("%s: %d paginas, %d bloques, %d caracteres, %d lineas de maquetacion removidas.",
                  slug, info$pages, length(bloques), nchar(texto), length(repetidos)),
          origen = ORIGEN)

  list(slug = slug, paginas = info$pages, chars_alfabeticos = alfabeticos,
       sin_capa_texto = FALSE, origen_texto = "capa_texto_pdf",
       chars_limpio = nchar(texto),
       lineas_maquetacion = length(repetidos), cabecera = cabecera, texto = texto)
}

# ---- Corrida ----------------------------------------------------------------
dir_texto <- ruta_salidas("intermedios", "texto")
fs::dir_create(dir_texto)

pdfs <- sort(fs::dir_ls(ruta_normativa(), glob = "*.pdf"))
if (length(pdfs) == 0L) stop("No hay PDF en ", ruta_normativa())

# ---- Reutilizacion de lo que no cambio --------------------------------------
# El paso 30 clasifico cada documento por huella (PDF + transcripcion OCR). Aqui
# se reextrae SOLO lo nuevo y lo modificado; del resto se arrastra la entrada del
# manifiesto anterior tal cual.
#
# La reutilizacion exige DOS condiciones, no una: que el paso 30 lo declare sin
# cambio Y que su texto intermedio siga en disco con su entrada en el manifiesto.
# Sin la segunda, un borrado parcial de 40_salidas/intermedios/ dejaria documentos
# marcados como vigentes y sin texto, y el fallo apareceria recien en el paso 32,
# lejos de su causa.
RUTA_MANIFIESTO_CORPUS <- ruta_datos("manifiesto_corpus.json")
estado_corpus <- if (fs::file_exists(RUTA_MANIFIESTO_CORPUS)) {
  m <- jsonlite::fromJSON(RUTA_MANIFIESTO_CORPUS, simplifyDataFrame = FALSE)$documentos
  setNames(vapply(m, function(d) d$estado, character(1)),
           vapply(m, function(d) d$slug, character(1)))
} else character(0)

RUTA_EXTRACCION <- ruta_salidas("intermedios", "extraccion.json")
previo <- if (fs::file_exists(RUTA_EXTRACCION)) {
  m <- jsonlite::fromJSON(RUTA_EXTRACCION, simplifyDataFrame = FALSE)
  setNames(m, vapply(m, function(d) d$slug, character(1)))
} else list()

reutilizable <- function(slug) {
  identical(unname(estado_corpus[slug]), "sin_cambio") &&
    !is.null(previo[[slug]]) &&
    fs::file_exists(ruta_salidas("intermedios", "texto", paste0(slug, ".txt")))
}

n_reutilizados <- 0L

log_msg(sprintf("Extrayendo texto de %d PDF.", length(pdfs)), origen = ORIGEN)

# unname() NO es cosmetico: fs::dir_ls() devuelve un vector CON NOMBRES (la ruta
# absoluta de cada archivo) y lapply() los arrastra hasta la lista. Al serializar,
# jsonlite convierte una lista con nombres en un OBJETO cuyas claves son esas
# rutas, de modo que el catalogo publicado en un repositorio publico llevaba
# incrustada la ruta del filesystem de quien corrio el pipeline, y ademas dejaba
# de ser un arreglo. Lo detecto el grep de privacidad previo al commit.
resultados <- unname(lapply(unname(pdfs), function(ruta_pdf) {
  slug <- sub("[.]pdf$", "", basename(ruta_pdf))
  if (reutilizable(slug)) {
    n_reutilizados <<- n_reutilizados + 1L
    return(previo[[slug]])
  }
  extraer_documento(ruta_pdf)
}))

# Solo se reescribe el texto de lo que se extrajo en esta corrida: las entradas
# reutilizadas no traen el campo `texto` (el manifiesto no lo guarda) y su archivo
# ya esta en disco intacto.
for (r in resultados) {
  if (!is.null(r$texto)) {
    escribir_atomico(r$texto, file.path(dir_texto, paste0(r$slug, ".txt")),
                     function(o, p) writeLines(o, p, useBytes = FALSE))
  }
}

manifiesto <- unname(lapply(resultados, function(r) r[setdiff(names(r), "texto")]))
escribir_atomico(
  manifiesto,
  ruta_salidas("intermedios", "extraccion.json"),
  function(o, p) jsonlite::write_json(o, p, auto_unbox = TRUE, pretty = TRUE)
)

origenes <- table(vapply(resultados, function(r) r$origen_texto, character(1)))
log_msg(sprintf("Extraccion terminada: %d documentos (%s)%s.",
                length(resultados),
                paste(sprintf("%s: %d", names(origenes), as.integer(origenes)),
                      collapse = "; "),
                sprintf("; %d reutilizados sin cambio", n_reutilizados)),
        origen = ORIGEN)
