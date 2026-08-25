# =============================================================================
# 00_run_all.R
# -----------------------------------------------------------------------------
# Proposito: orquestador unico del pipeline. Solo orquesta: cero logica de
#            negocio (POLITICA 4). Regenera todo 40_salidas/ desde
#            20_insumos/normativa/ sin ningun paso manual (invariante de
#            reproducibilidad del encargo de bootstrap).
# Uso:       source("00_run_all.R"); run_all()
#            run_all(from = 32)          # desde la segmentacion
#            run_all(only = c(31, 32))   # solo extraccion y segmentacion
#            run_all(skip = 34)          # saltar el render del sitio
# Creado:    2026-08-25 (encargo de bootstrap, T1; stub funcional sin pasos)
# =============================================================================

# ---- Cargar utilidades primero (bootstrapping) ------------------------------
source("10_utils/10_utils.R", chdir = FALSE)

# ---- Auto-instalacion de paquetes base del orquestador ----------------------
instalar_si_falta(c("rprojroot", "fs", "here"))
library(fs)

# ---- Anclaje del root -------------------------------------------------------
ROOT <- obtener_raiz_proyecto()

# ---- Configuracion (valida precondiciones al inicio, incluida la locale) ----
source(file.path(ROOT, "10_utils", "10_configuracion.R"))

# ---- Definicion de pasos ----------------------------------------------------
# El id refleja el numero de sub-etapa en 30_procesamiento/ (POLITICA 1.2).
PASOS <- list(
  list(id = 31L, etiqueta = "Extraer texto de los PDF",
       ruta = "30_procesamiento/31_extraer_texto.R"),
  list(id = 32L, etiqueta = "Segmentar por artículo y escribir JSON",
       ruta = "30_procesamiento/32_segmentar_articulos.R"),
  list(id = 33L, etiqueta = "Generar las páginas .qmd del sitio",
       ruta = "30_procesamiento/33_generar_paginas.R"),
  list(id = 34L, etiqueta = "Renderizar el sitio con Quarto",
       ruta = "30_procesamiento/34_renderizar_sitio.R"),
  list(id = 35L, etiqueta = "Construir el índice de búsqueda (Pagefind)",
       ruta = "30_procesamiento/35_indexar_pagefind.R")
)

# ---- Funcion principal ------------------------------------------------------
run_all <- function(from = NULL, to = NULL, only = NULL, skip = NULL) {

  if (length(PASOS) == 0L) {
    log_msg("PASOS esta vacio: el pipeline aun no tiene etapas registradas.",
            nivel = "WARN", origen = "00_run_all")
    return(invisible(TRUE))
  }

  ids <- vapply(PASOS, function(p) p$id, integer(1))

  # Validar que los argumentos referencian IDs existentes.
  for (nm in c("from", "to", "only", "skip")) {
    arg <- get(nm)
    if (!is.null(arg) && !all(arg %in% ids)) {
      stop(sprintf("Argumento '%s' referencia IDs inexistentes: %s", nm,
                   paste(setdiff(arg, ids), collapse = ", ")))
    }
  }

  # Validar que todas las rutas existen AL INICIO, no a mitad de pipeline.
  faltantes <- character()
  for (p in PASOS) {
    if (!fs::file_exists(fs::path(ROOT, p$ruta))) faltantes <- c(faltantes, p$ruta)
  }
  if (length(faltantes) > 0) {
    stop("Rutas no encontradas:\n  ", paste(faltantes, collapse = "\n  "))
  }

  # Resolver que pasos ejecutar.
  if (!is.null(only)) {
    pasos_a_correr <- ids[ids %in% only]
  } else {
    pasos_a_correr <- ids
    if (!is.null(from)) pasos_a_correr <- pasos_a_correr[pasos_a_correr >= from]
    if (!is.null(to))   pasos_a_correr <- pasos_a_correr[pasos_a_correr <= to]
  }
  if (!is.null(skip)) pasos_a_correr <- setdiff(pasos_a_correr, skip)

  t_inicio <- Sys.time(); ejecutados <- 0L; saltados <- 0L

  for (p in PASOS) {
    if (!(p$id %in% pasos_a_correr)) {
      log_msg(sprintf("Paso %d (%s) saltado.", p$id, p$etiqueta),
              origen = "00_run_all")
      saltados <- saltados + 1L
      next
    }
    cat("\n", strrep("=", 76), "\n", sep = "")
    cat(sprintf("PASO %d: %s\n", p$id, p$etiqueta))
    cat(sprintf("Ruta:    %s\n", p$ruta))
    cat(strrep("=", 76), "\n", sep = "")

    t0 <- Sys.time()
    tryCatch(
      source(fs::path(ROOT, p$ruta), echo = FALSE, chdir = TRUE),
      error = function(e) {
        stop(sprintf("Paso %d (%s) fallo: %s", p$id, p$etiqueta, e$message))
      }
    )
    dur <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
    log_msg(sprintf("Paso %d completado en %.1fs.", p$id, dur),
            origen = "00_run_all")
    ejecutados <- ejecutados + 1L
  }

  dur_total <- as.numeric(difftime(Sys.time(), t_inicio, units = "secs"))
  cat("\n", strrep("=", 76), "\n", sep = "")
  cat(sprintf("RESUMEN: %d pasos ejecutados, %d saltados, %.1fs en total.\n",
              ejecutados, saltados, dur_total))
  cat(strrep("=", 76), "\n", sep = "")

  invisible(TRUE)
}

# ---- Ejemplos de uso --------------------------------------------------------
# run_all()                    # pipeline completo
# run_all(from = 32)           # desde la segmentacion
# run_all(only = c(31, 32))    # solo extraccion y segmentacion
