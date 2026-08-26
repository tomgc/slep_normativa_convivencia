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
# Uso: Rscript 00_ocr_documentos.R            (solo los que faltan)
#      Rscript 00_ocr_documentos.R --rehacer  (rehace todos)
# =============================================================================

source(here::here("10_utils", "10_utils.R"))
instalar_si_falta(c("pdftools", "jsonlite", "fs", "here"))
source(here::here("10_utils", "10_configuracion.R"))

ORIGEN <- "00_ocr_documentos"
REHACER <- "--rehacer" %in% commandArgs(trailingOnly = TRUE)

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

# ---- Compilar el auxiliar Swift ---------------------------------------------
# Se compila a un temporal en cada corrida en vez de versionar un binario: un
# ejecutable en el repositorio no es codigo fuente y nadie puede revisarlo.
binario <- file.path(tempdir(), "ocr_vision")
fuente  <- here::here("00_ocr_vision.swift")
log_msg("Compilando el auxiliar de reconocimiento.", origen = ORIGEN)
estado <- system2("swiftc", c("-O", "-o", shQuote(binario), shQuote(fuente)))
if (estado != 0L || !file.exists(binario)) {
  stop("No se pudo compilar 00_ocr_vision.swift. ¿Están las Command Line Tools ",
       "instaladas? (xcode-select --install)")
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

# ---- Reconocimiento de un documento -----------------------------------------
ocr_documento <- function(ruta_pdf) {
  slug <- sub("\\.pdf$", "", basename(ruta_pdf))
  destino <- ruta_insumos("ocr", slug)

  info <- pdftools::pdf_info(ruta_pdf)

  # Se omite solo si el reconocimiento esta COMPLETO. Comparar contra la
  # existencia de la carpeta no basta: una corrida interrumpida deja una carpeta
  # con menos paginas que el PDF, y esa transcripcion parcial se ve igual de
  # completa que una entera. Paso el 2026-08-25 con rex_482_reglamentos_b, que
  # tumbo a poppler a mitad de camino.
  if (fs::dir_exists(destino) && !REHACER) {
    presentes <- length(fs::dir_ls(destino, glob = "*.txt"))
    if (presentes == info$pages) {
      log_msg(sprintf("%s: ya tiene reconocimiento completo (%d páginas), se omite.",
                      slug, presentes),
              origen = ORIGEN)
      return(NULL)
    }
    log_msg(sprintf("%s: reconocimiento INCOMPLETO (%d de %d páginas). Se rehace.",
                    slug, presentes, info$pages),
            nivel = "WARN", origen = ORIGEN)
    fs::dir_delete(destino)
  }
  fs::dir_create(destino)
  tmp <- fs::path(tempdir(), paste0("raster_", slug))
  fs::dir_create(tmp)
  on.exit(fs::dir_delete(tmp), add = TRUE)

  log_msg(sprintf("%s: rasterizando y reconociendo %d páginas a %d dpi.",
                  slug, info$pages, OCR_DPI),
          origen = ORIGEN)

  caracteres <- integer(info$pages)
  for (i in seq_len(info$pages)) {
    # Una pagina por invocacion de pdftoppm, en un PROCESO APARTE. Dentro de un
    # mismo proceso de R, pdftools::pdf_convert() acumula estado de poppler y
    # termina cayendo con segfault "invalid permissions" en este escaneo de 48
    # paginas y 14,8 MB (medido el 2026-08-25; las mismas paginas sueltas, en
    # procesos separados, salen bien). Un binario externo no puede tumbar a R, y
    # ademas aisla una pagina defectuosa en vez de perder el documento entero.
    # Cada imagen se borra en cuanto se reconoce: el escaneo completo a 300 dpi
    # no cabe comodo en disco temporal.
    prefijo <- fs::path(tmp, sprintf("p_%03d", i))
    imagen  <- paste0(prefijo, ".png")
    estado_raster <- system2("pdftoppm",
      c("-png", "-r", OCR_DPI, "-f", i, "-l", i, "-singlefile",
        shQuote(ruta_pdf), shQuote(prefijo)))
    if (estado_raster != 0L || !file.exists(imagen)) {
      stop(sprintf("pdftoppm fallo al rasterizar %s pagina %d.", slug, i))
    }
    lineas <- system2(binario, shQuote(imagen), stdout = TRUE, stderr = FALSE)
    fs::file_delete(imagen)
    if (!is.null(attr(lineas, "status")) && attr(lineas, "status") != 0L) {
      stop(sprintf("El reconocedor fallo en %s pagina %d.", slug, i))
    }
    texto <- paste(lineas, collapse = "\n")
    caracteres[i] <- nchar(texto)
    escribir_atomico(texto, fs::path(destino, sprintf("pagina_%03d.txt", i)),
                     function(o, p) writeLines(o, p, useBytes = FALSE))
  }

  log_msg(sprintf("%s: %d páginas reconocidas, %d caracteres, %d páginas vacías.",
                  slug, info$pages, sum(caracteres), sum(caracteres == 0L)),
          origen = ORIGEN)

  list(slug = slug, paginas = info$pages, caracteres = sum(caracteres),
       paginas_vacias = sum(caracteres == 0L),
       md5_pdf = unname(tools::md5sum(ruta_pdf)))
}

resultados <- Filter(Negate(is.null), lapply(sin_capa, ocr_documento))

# ---- Manifiesto tecnico -----------------------------------------------------
# Se reconstruye SIEMPRE desde lo que hay en disco, no desde lo que proceso esta
# corrida. Con la version anterior, la corrida que cayo a mitad de camino dejo
# tres documentos reconocidos y un manifiesto que solo mencionaba el cuarto: el
# registro contradecia al disco y no habia forma de notarlo salvo contando a
# mano. Derivarlo del disco lo vuelve ademas idempotente.
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
  list(
    slug = slug,
    paginas = length(paginas),
    paginas_pdf = pdftools::pdf_info(pdf)$pages,
    caracteres = sum(caracteres),
    paginas_vacias = sum(caracteres == 0L),
    md5_pdf = unname(tools::md5sum(pdf))
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
    documentos = unname(documentos)
  ),
  ruta_insumos("ocr", "manifiesto_ocr.json"),
  function(o, p) jsonlite::write_json(o, p, auto_unbox = TRUE, pretty = TRUE)
)

# Compuerta: cada documento reconocido tiene que tener tantas paginas de texto
# como paginas el PDF. Una transcripcion a la que le falta una pagina se ve igual
# de completa que una entera.
incompletos <- Filter(function(d) d$paginas != d$paginas_pdf, documentos)
if (length(incompletos) > 0L) {
  stop("Reconocimiento incompleto en: ",
       paste(vapply(incompletos, function(d)
         sprintf("%s (%d de %d páginas)", d$slug, d$paginas, d$paginas_pdf),
         character(1)), collapse = ", "))
}

log_msg(sprintf("Reconocimiento terminado: %d documentos procesados.", length(resultados)),
        origen = ORIGEN)
