# =============================================================================
# 30_manifiesto_corpus.R
# -----------------------------------------------------------------------------
# Proposito: clasificar cada documento del corpus en sin_cambio / nuevo /
#            modificado comparando su huella contra la corrida anterior, y
#            escribir 40_salidas/datos/manifiesto_corpus.json.
#            Es el primer paso del pipeline: lo que decide aqui gobierna que
#            vuelve a extraer el paso 31.
#
# Incorporar una norma nueva es, gracias a esto, dejar el PDF con nombre canonico
# en 20_insumos/normativa/ y correr 00_run_all.R. Nada mas manual.
#
# LA HUELLA NO ES SOLO EL PDF. Para los documentos escaneados incluye tambien la
# transcripcion: si alguien corrige una pagina de OCR, el documento tiene que
# volver a procesarse aunque el PDF no se haya movido un byte. Un manifiesto que
# solo mirara el PDF dejaria las correcciones humanas fuera del sitio publicado,
# que es exactamente el trabajo que la compuerta de 00_ocr_documentos.R existe
# para proteger.
#
# LA FECHA DE MODIFICACION NO CUENTA, manda el hash: copiar el corpus, restaurar
# un respaldo o clonar el repositorio cambia mtime en todos los archivos sin
# cambiar un solo byte, y eso no es motivo para reprocesar nada.
#
# El manifiesto vive en 40_salidas/ porque es derivado y regenerable: borrarlo
# equivale a declarar todo el corpus como nuevo, que es justo lo que se quiere
# tras un `rm -rf 40_salidas/`.
# =============================================================================

source(here::here("10_utils", "10_utils.R"))
instalar_si_falta(c("jsonlite", "fs", "here", "tools"))
source(here::here("10_utils", "10_configuracion.R"))

ORIGEN <- "30_manifiesto"

# ---- Huella de un documento --------------------------------------------------
# Dos componentes: el PDF y, si existe, su transcripcion. Se combinan en una sola
# cadena para que cualquier cambio en cualquiera de las dos mueva la huella.
huella_documento <- function(slug) {
  pdf   <- ruta_normativa(paste0(slug, ".pdf"))
  h_pdf <- unname(tools::md5sum(pdf))

  # tools::md5sum() resume ARCHIVOS, no cadenas. Para resumir el conjunto de
  # paginas transcritas se escriben sus hashes a un temporal y se resume ese
  # archivo: es lo unico que la base de R ofrece sin sumar una dependencia solo
  # para esto.
  dir_ocr <- ruta_insumos("ocr", slug)
  h_ocr <- NA_character_
  if (fs::dir_exists(dir_ocr)) {
    paginas <- sort(fs::dir_ls(dir_ocr, glob = "*.txt"))
    if (length(paginas) > 0L) {
      tmp <- tempfile()
      on.exit(unlink(tmp), add = TRUE)
      writeLines(paste(basename(paginas), unname(tools::md5sum(paginas))), tmp)
      h_ocr <- unname(tools::md5sum(tmp))
    }
  }

  list(slug = slug, md5_pdf = h_pdf, md5_ocr = h_ocr,
       huella = paste(h_pdf, if (is.na(h_ocr)) "-" else h_ocr, sep = ":"))
}

# ---- Clasificacion -----------------------------------------------------------
# Funcion pura sobre (lista de slugs, manifiesto previo). Se aisla asi para poder
# calibrarla contra un corpus de prueba sin tocar el real.
clasificar_corpus <- function(slugs, previo) {
  huellas_previas <- setNames(
    vapply(previo, function(d) d$huella, character(1)),
    vapply(previo, function(d) d$slug, character(1))
  )
  lapply(slugs, function(s) {
    h <- huella_documento(s)
    estado <- if (!s %in% names(huellas_previas)) "nuevo"
              else if (!identical(unname(huellas_previas[[s]]), h$huella)) "modificado"
              else "sin_cambio"
    c(h, list(estado = estado))
  })
}

# ---- Corrida -----------------------------------------------------------------
RUTA_MANIFIESTO_CORPUS <- ruta_datos("manifiesto_corpus.json")

previo <- if (fs::file_exists(RUTA_MANIFIESTO_CORPUS)) {
  jsonlite::fromJSON(RUTA_MANIFIESTO_CORPUS, simplifyDataFrame = FALSE)$documentos
} else list()

slugs <- sort(sub("\\.pdf$", "", basename(fs::dir_ls(ruta_normativa(), glob = "*.pdf"))))
if (length(slugs) == 0L) stop("No hay PDF en ", ruta_normativa())

clasificacion <- clasificar_corpus(slugs, previo)
estados <- table(factor(vapply(clasificacion, function(d) d$estado, character(1)),
                        levels = c("sin_cambio", "nuevo", "modificado")))

log_msg(sprintf("Corpus: %d documentos — %d sin cambio, %d nuevos, %d modificados.",
                length(slugs), estados[["sin_cambio"]], estados[["nuevo"]],
                estados[["modificado"]]),
        origen = ORIGEN)

for (d in clasificacion) {
  if (d$estado != "sin_cambio") {
    log_msg(sprintf("  %-14s %s", toupper(d$estado), d$slug), origen = ORIGEN)
  }
}

fs::dir_create(ruta_datos())
escribir_atomico(
  # Sin marca de tiempo a proposito: la fecha la da el historial de Git, y un
  # timestamp aqui haria que el archivo cambiara en cada corrida aunque el corpus
  # fuera identico, ensuciando cada diff sin aportar nada.
  list(
    generado_por = "30_procesamiento/30_manifiesto_corpus.R",
    n_documentos = length(clasificacion),
    documentos = unname(clasificacion)
  ),
  RUTA_MANIFIESTO_CORPUS,
  function(o, p) jsonlite::write_json(o, p, auto_unbox = TRUE, pretty = TRUE)
)
