# =============================================================================
# 00_ocr_documentos.R
# -----------------------------------------------------------------------------
# Proposito: reconocer el texto de los PDF del corpus que NO traen capa de texto
#            y depositarlo en 20_insumos/ocr/<slug>/pagina_NNN.txt.
#
# ESTA HERRAMIENTA NO ES UN PASO DEL PIPELINE y no entra a PASOS de
# 00_run_all.R. Corre una sola vez por documento escaneado nuevo. La razon es de
# arquitectura, no de comodidad: el texto que produce va a ser CORREGIDO A MANO
# por el equipo de convivencia, y una correccion humana que el pipeline
# sobreescribe en la siguiente corrida no es una correccion, es una perdida.
# Por eso la salida vive en 20_insumos/ (insumo curado, versionado) y no en
# 40_salidas/ (regenerable). El invariante de reproducibilidad se mantiene
# intacto: 00_run_all.R sigue regenerando todo 40_salidas/ desde 20_insumos/.
#
# Una pagina por archivo, y no un archivo por documento, porque asi es como se
# revisa: la pagina N del PDF al lado de pagina_00N.txt.
#
# EL TEXTO NO SE REFLUYE. Se conservan los saltos de linea tal como los devuelve
# el reconocedor. Un texto que nadie ha revisado todavia no admite que ademas se
# le adivine la estructura de parrafos, y para revisarlo conviene que lo que se
# lee en el sitio sea exactamente lo que hay en el archivo.
#
# COMPUERTA DE PROTECCION (2026-08-25). Antes de regenerar la transcripcion de un
# documento que ya la tiene, la herramienta se detiene si detecta trabajo humano:
#   (a) el documento esta declarado `ocr_revisado` en la curaduria, o
#   (b) alguna pagina difiere del hash que se registro cuando se genero.
# La unica forma de pasar es nombrar el documento con --forzar, y aun entonces se
# respalda antes de tocar nada. Sin la compuerta, un `--rehacer` distraido borra
# semanas de revision sin preguntar y sin dejar rastro.
#
# Uso:
#   Rscript 00_ocr_documentos.R                  solo los que faltan
#   Rscript 00_ocr_documentos.R --rehacer        rehace todos (sujeto a compuerta)
#   Rscript 00_ocr_documentos.R --forzar <slug>  rehace ESE, saltando la compuerta
# =============================================================================

source(here::here("10_utils", "10_utils.R"))
instalar_si_falta(c("pdftools", "jsonlite", "fs", "here"))
source(here::here("10_utils", "10_configuracion.R"))

ORIGEN <- "00_ocr_documentos"

# ---- Argumentos --------------------------------------------------------------
args    <- commandArgs(trailingOnly = TRUE)
REHACER <- "--rehacer" %in% args
FORZAR  <- if ("--forzar" %in% args) {
  # Todo lo que sigue a --forzar y no empieza por "--" es un slug.
  resto <- args[(which(args == "--forzar")[1] + 1L):length(args)]
  resto[!startsWith(resto, "--")]
} else character(0)
FORZAR <- FORZAR[nzchar(FORZAR)]

if (Sys.info()[["sysname"]] != "Darwin") {
  stop("Esta herramienta usa el framework Vision de macOS y solo corre ahi.\n",
       "  No hace falta correrla en otra maquina: su salida esta versionada en\n",
       "  20_insumos/ocr/ y el pipeline la lee ya escrita.")
}

if (!nzchar(Sys.which("pdftoppm"))) {
  stop("No se encontro 'pdftoppm' en el PATH. Se instala con `brew install poppler`.\n",
       "  Se usa el binario y no pdftools::pdf_convert() porque este ultimo\n",
       "  corrompe el estado de poppler tras varias paginas del mismo escaneo:\n",
       "  medido el 2026-08-25, rex_482_reglamentos_b tumbaba el proceso de R con\n",
       "  segfault 'invalid permissions'. Un proceso externo por pagina no puede.")
}

# ---- Estado previo: manifiesto y curaduria ----------------------------------
RUTA_MANIFIESTO <- ruta_insumos("ocr", "manifiesto_ocr.json")

manifiesto_previo <- if (fs::file_exists(RUTA_MANIFIESTO)) {
  jsonlite::fromJSON(RUTA_MANIFIESTO, simplifyDataFrame = FALSE)
} else list(documentos = list())

hashes_registrados <- function(slug) {
  d <- Filter(function(x) identical(x$slug, slug), manifiesto_previo$documentos)
  if (length(d) == 0L || is.null(d[[1]]$hashes_paginas)) return(NULL)
  unlist(d[[1]]$hashes_paginas)
}

# Lectura de la curaduria SIEMPRE con [[ ]], nunca con $: R hace coincidencia
# PARCIAL de nombres con $ sobre listas, asi que una clave ausente puede resolver
# a otra que la tenga por prefijo. Es el mismo defecto que 48d176a arreglo en
# 30_procesamiento/ (ahi `anio` resolvia a `anios_alternativos` y ponia el anio de
# la norma en 1996). Esta funcion es el clon de origen_curado() de
# 31_extraer_texto.R y gobierna la compuerta que impide que --rehacer sobreescriba
# una transcripcion corregida a mano: no conviene que sea la unica que quede con $.
estado_curado <- function(slug) {
  ruta <- ruta_insumos("curaduria", "metadatos_curados.json")
  if (!fs::file_exists(ruta)) return(NA_character_)
  cur <- jsonlite::fromJSON(ruta, simplifyDataFrame = FALSE)[["normas"]][[slug]]
  if (is.null(cur[["origen_texto"]])) NA_character_ else cur[["origen_texto"]]
}

hashear_paginas <- function(destino) {
  paginas <- sort(fs::dir_ls(destino, glob = "*.txt"))
  if (length(paginas) == 0L) return(setNames(character(0), character(0)))
  setNames(unname(tools::md5sum(paginas)), basename(paginas))
}

# ---- Que documentos necesitan reconocimiento --------------------------------
necesita_ocr <- function(ruta_pdf) {
  txt <- paste(pdftools::pdf_text(ruta_pdf), collapse = "")
  nchar(gsub("[^[:alpha:]]", "", txt)) < MIN_CHARS_ALFABETICOS
}

pdfs <- sort(fs::dir_ls(ruta_normativa(), glob = "*.pdf"))
sin_capa <- unname(pdfs[vapply(pdfs, necesita_ocr, logical(1))])
log_msg(sprintf("%d de %d documentos sin capa de texto.", length(sin_capa), length(pdfs)),
        origen = ORIGEN)

# ---- Plan: que se hace con cada documento -----------------------------------
# Se resuelve ANTES de tocar nada, para poder evaluar la compuerta sobre el plan
# completo y abortar con la lista entera en vez de a medio camino.
plan <- lapply(sin_capa, function(ruta_pdf) {
  slug     <- sub("\\.pdf$", "", basename(ruta_pdf))
  destino  <- ruta_insumos("ocr", slug)
  existe   <- fs::dir_exists(destino)
  n_pdf    <- pdftools::pdf_info(ruta_pdf)$pages
  n_txt    <- if (existe) length(fs::dir_ls(destino, glob = "*.txt")) else 0L
  forzado  <- slug %in% FORZAR

  accion <- if (!existe || n_txt == 0L) "generar"
            else if (n_txt != n_pdf)   "reparar"
            else if (REHACER || forzado) "rehacer"
            else "omitir"

  list(ruta_pdf = ruta_pdf, slug = slug, destino = destino,
       n_pdf = n_pdf, n_txt = n_txt, accion = accion, forzado = forzado)
})

# ---- Compuerta de proteccion -------------------------------------------------
# Se aplica a todo lo que vaya a SOBREESCRIBIR paginas existentes ("rehacer" y
# "reparar"), no solo a --rehacer: reparar una transcripcion incompleta tambien
# destruye las correcciones de las paginas que si estaban.
evaluar_compuerta <- function(p) {
  if (!p$accion %in% c("rehacer", "reparar")) return(NULL)
  if (p$forzado) return(NULL)

  if (identical(estado_curado(p$slug), "ocr_revisado")) {
    return(sprintf("%s: declarado `ocr_revisado` en la curaduria.", p$slug))
  }

  registrados <- hashes_registrados(p$slug)
  if (is.null(registrados)) {
    # Sin hashes de referencia no se puede distinguir una correccion humana de la
    # salida original. Se elige el lado seguro: bloquear. La corrida normal (sin
    # --rehacer) los deja registrados, asi que esto se resuelve solo una vez.
    return(sprintf("%s: el manifiesto no tiene hashes de referencia; corre la herramienta sin --rehacer una vez para registrarlos.", p$slug))
  }

  actuales <- hashear_paginas(p$destino)
  comunes  <- intersect(names(registrados), names(actuales))
  distintas <- comunes[registrados[comunes] != actuales[comunes]]
  faltantes <- setdiff(names(registrados), names(actuales))
  nuevas    <- setdiff(names(actuales), names(registrados))

  if (length(distintas) + length(faltantes) + length(nuevas) > 0L) {
    return(sprintf("%s: %d página(s) difieren del hash de generación (%s%s%s). Parece trabajo humano.",
                   p$slug, length(distintas) + length(faltantes) + length(nuevas),
                   paste(utils::head(distintas, 4), collapse = ", "),
                   if (length(faltantes)) sprintf(" faltan: %s", paste(faltantes, collapse = ", ")) else "",
                   if (length(nuevas)) sprintf(" sobran: %s", paste(nuevas, collapse = ", ")) else ""))
  }
  NULL
}

bloqueos <- Filter(Negate(is.null), lapply(plan, evaluar_compuerta))
if (length(bloqueos) > 0L) {
  stop("\n\n  COMPUERTA DE PROTECCION: no se regenera nada.\n\n",
       paste0("  - ", unlist(bloqueos), collapse = "\n"),
       "\n\n  Estas transcripciones contienen, o pueden contener, correccion humana.\n",
       "  Para regenerar una de todos modos, nombrala explicitamente:\n",
       "    Rscript 00_ocr_documentos.R --forzar <slug>\n",
       "  Antes de sobreescribir se respalda en _archivo/AAAAMMDD/ocr_<slug>/.\n",
       call. = FALSE)
}

# ---- Reconocimiento de un documento -----------------------------------------
respaldar <- function(p) {
  if (!fs::dir_exists(p$destino)) return(invisible(NULL))
  sello <- format(Sys.Date(), "%Y%m%d")
  respaldo <- here::here("_archivo", sello, paste0("ocr_", p$slug))
  fs::dir_create(respaldo, recurse = TRUE)
  fs::file_copy(fs::dir_ls(p$destino, glob = "*.txt"), respaldo, overwrite = TRUE)
  log_msg(sprintf("%s: %d páginas respaldadas en %s",
                  p$slug, length(fs::dir_ls(respaldo, glob = "*.txt")),
                  fs::path_rel(respaldo, here::here())),
          nivel = "WARN", origen = ORIGEN)
}

ocr_documento <- function(p) {
  if (p$accion == "omitir") {
    log_msg(sprintf("%s: ya tiene reconocimiento completo (%d páginas), se omite.",
                    p$slug, p$n_txt),
            origen = ORIGEN)
    return(NULL)
  }
  if (p$accion == "reparar") {
    log_msg(sprintf("%s: reconocimiento INCOMPLETO (%d de %d páginas). Se rehace.",
                    p$slug, p$n_txt, p$n_pdf), nivel = "WARN", origen = ORIGEN)
  }
  if (p$forzado) {
    log_msg(sprintf("%s: --forzar activo, se salta la compuerta.", p$slug),
            nivel = "WARN", origen = ORIGEN)
  }

  # Respaldo antes de destruir. Solo si habia algo que perder.
  if (p$n_txt > 0L) respaldar(p)
  if (fs::dir_exists(p$destino)) fs::dir_delete(p$destino)
  fs::dir_create(p$destino)

  tmp <- fs::path(tempdir(), paste0("raster_", p$slug))
  fs::dir_create(tmp)
  on.exit(fs::dir_delete(tmp), add = TRUE)

  log_msg(sprintf("%s: rasterizando y reconociendo %d páginas a %d dpi.",
                  p$slug, p$n_pdf, OCR_DPI), origen = ORIGEN)

  caracteres <- integer(p$n_pdf)
  for (i in seq_len(p$n_pdf)) {
    # Una pagina por invocacion de pdftoppm, en un PROCESO APARTE. Dentro de un
    # mismo proceso de R, pdftools::pdf_convert() acumula estado de poppler y
    # termina cayendo con segfault "invalid permissions" en el escaneo de 48
    # paginas y 14,8 MB (medido el 2026-08-25; las mismas paginas sueltas, en
    # procesos separados, salen bien). Un binario externo no puede tumbar a R, y
    # ademas aisla una pagina defectuosa en vez de perder el documento entero.
    prefijo <- fs::path(tmp, sprintf("p_%03d", i))
    imagen  <- paste0(prefijo, ".png")
    estado_raster <- system2("pdftoppm",
      c("-png", "-r", OCR_DPI, "-f", i, "-l", i, "-singlefile",
        shQuote(p$ruta_pdf), shQuote(prefijo)))
    if (estado_raster != 0L || !file.exists(imagen)) {
      stop(sprintf("pdftoppm fallo al rasterizar %s pagina %d.", p$slug, i))
    }
    lineas <- system2(binario, shQuote(imagen), stdout = TRUE, stderr = FALSE)
    fs::file_delete(imagen)
    if (!is.null(attr(lineas, "status")) && attr(lineas, "status") != 0L) {
      stop(sprintf("El reconocedor fallo en %s pagina %d.", p$slug, i))
    }
    texto <- paste(lineas, collapse = "\n")
    caracteres[i] <- nchar(texto)
    escribir_atomico(texto, fs::path(p$destino, sprintf("pagina_%03d.txt", i)),
                     function(o, q) writeLines(o, q, useBytes = FALSE))
  }

  log_msg(sprintf("%s: %d páginas reconocidas, %d caracteres, %d páginas vacías.",
                  p$slug, p$n_pdf, sum(caracteres), sum(caracteres == 0L)),
          origen = ORIGEN)
  p$slug
}

# ---- Compilar el auxiliar Swift ---------------------------------------------
# Se compila a un temporal en cada corrida en vez de versionar un binario: un
# ejecutable en el repositorio no es codigo fuente y nadie puede revisarlo.
# Va DESPUES de la compuerta: si no se va a regenerar nada, compilar es ruido.
binario <- NULL
if (any(vapply(plan, function(p) p$accion != "omitir", logical(1)))) {
  binario <- file.path(tempdir(), "ocr_vision")
  log_msg("Compilando el auxiliar de reconocimiento.", origen = ORIGEN)
  estado <- system2("swiftc", c("-O", "-o", shQuote(binario),
                                shQuote(here::here("00_ocr_vision.swift"))))
  if (estado != 0L || !file.exists(binario)) {
    stop("No se pudo compilar 00_ocr_vision.swift. ¿Están las Command Line Tools ",
         "instaladas? (xcode-select --install)")
  }
}

regenerados <- unlist(Filter(Negate(is.null), lapply(plan, ocr_documento)))

# ---- Manifiesto tecnico -----------------------------------------------------
# Se reconstruye SIEMPRE desde lo que hay en disco, no desde lo que proceso esta
# corrida. Con la version anterior, la corrida que cayo a mitad de camino dejo
# tres documentos reconocidos y un manifiesto que solo mencionaba el cuarto: el
# registro contradecia al disco y no habia forma de notarlo salvo contando a mano.
#
# Los HASHES POR PAGINA son la excepcion deliberada a "reconstruir desde disco":
# son la huella del momento de GENERACION y no se recalculan sobre paginas que
# esta corrida no toco. Si se recalcularan, la compuerta jamas detectaria una
# correccion humana, porque el hash de referencia se habria movido con ella.
# Solo se calculan (a) para lo que se acaba de generar y (b) la primera vez para
# un documento que aun no los tiene, que es el punto 3 de esta tarea.
#
# Registra procedencia de MAQUINA, no estado de revision. El estado de revision
# es un dato humano y vive en 20_insumos/curaduria/metadatos_curados.json, que
# ningun script escribe: si el manifiesto lo guardara, esta herramienta borraria
# la validacion del equipo cada vez que alguien la volviera a correr.
documentos <- lapply(sort(fs::dir_ls(ruta_insumos("ocr"), type = "directory")), function(d) {
  slug <- basename(d)
  paginas <- sort(fs::dir_ls(d, glob = "*.txt"))
  caracteres <- vapply(paginas, function(f)
    sum(nchar(readLines(f, warn = FALSE))), integer(1))
  pdf <- ruta_normativa(paste0(slug, ".pdf"))

  previos <- hashes_registrados(slug)
  hashes <- if (slug %in% regenerados || is.null(previos)) {
    hashear_paginas(d)
  } else {
    previos
  }

  list(
    slug = slug,
    paginas = length(paginas),
    paginas_pdf = pdftools::pdf_info(pdf)$pages,
    caracteres = sum(caracteres),
    paginas_vacias = sum(caracteres == 0L),
    md5_pdf = unname(tools::md5sum(pdf)),
    hashes_paginas = as.list(hashes)
  )
})

escribir_atomico(
  list(
    generado_por = "00_ocr_documentos.R",
    motor = "Apple Vision (VNRecognizeTextRequest, .accurate, es-ES)",
    rasterizador = "pdftoppm (poppler)",
    sistema = paste(Sys.info()[["sysname"]], Sys.info()[["release"]]),
    dpi = OCR_DPI,
    fecha = format(Sys.Date()),
    nota_hashes = paste("hashes_paginas es la huella de la GENERACION, no del",
                        "estado actual: la compuerta compara contra ella para",
                        "detectar correccion humana. No se recalcula sobre",
                        "paginas que la herramienta no regenero."),
    documentos = unname(documentos)
  ),
  RUTA_MANIFIESTO,
  function(o, p) jsonlite::write_json(o, p, auto_unbox = TRUE, pretty = TRUE)
)

# Compuerta de salida: cada documento reconocido tiene que tener tantas paginas
# de texto como paginas el PDF. Una transcripcion a la que le falta una pagina se
# ve igual de completa que una entera.
incompletos <- Filter(function(d) d$paginas != d$paginas_pdf, documentos)
if (length(incompletos) > 0L) {
  stop("Reconocimiento incompleto en: ",
       paste(vapply(incompletos, function(d)
         sprintf("%s (%d de %d páginas)", d$slug, d$paginas, d$paginas_pdf),
         character(1)), collapse = ", "))
}

log_msg(sprintf("Reconocimiento terminado: %d documento(s) regenerado(s).",
                length(regenerados)),
        origen = ORIGEN)
