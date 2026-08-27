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

# ---- Compuerta de coincidencia parcial de nombres ---------------------------
# 10_utils/10_configuracion.R enciende warnPartialMatch*: R AVISA cada vez que un
# `$`, un argumento o un atributo resuelve por PREFIJO en vez de por nombre
# exacto. Avisar no basta. El defecto del DFL 1 fue exactamente eso: `curado$anio`
# devolvio el arreglo `anios_alternativos`, el anio de la norma quedo en 1996 y el
# derivador empezo a descartar las citas correctas, todo sin una sola linea roja.
# Un WARN en medio de 700 lineas de log es lo que nadie ve. Aqui el aviso hace
# FALLAR la corrida, y por tanto el CI.
#
# Se promueven SOLO las de coincidencia parcial. Convertir en error cualquier
# advertencia apagaria el pipeline por un `as.integer("x")` inofensivo.
#
# El texto de esas advertencias lo TRADUCE R segun el idioma en que hable (medido
# en R 4.5.2: "encuentros parciales de 'a' to 'ab'" en espanol, "partial match of
# 'a' to 'ab'" en ingles). Escribir el patron a mano ataria la compuerta a una
# locale y la volveria un no-op silencioso en cuanto el runner hablara otro
# idioma, que es la clase exacta de fallo que esta compuerta existe para impedir.
# Por eso el prefijo se DERIVA: se provoca una coincidencia parcial conocida y se
# guarda lo que R responda hasta la primera comilla, que es la parte que no
# depende de los nombres.
derivar_prefijos_parciales <- function() {
  atrapar <- function(f) {
    m <- NULL
    withCallingHandlers(f(), warning = function(w) {
      m <<- conditionMessage(w); invokeRestart("muffleWarning")
    })
    m
  }
  msgs <- c(
    atrapar(function() { l <- list(zzsondalarga = 1L); l$zzsonda }),
    atrapar(function() { g <- function(zzsondalarga = 1L) zzsondalarga; g(zzsonda = 2L) }),
    atrapar(function() { x <- 1L; attr(x, "zzsondalarga") <- 1L; attr(x, "zzsonda", exact = FALSE) })
  )
  pref <- unique(sub("'.*$", "", unlist(msgs)))
  pref <- pref[nzchar(pref)]
  # Si R no avisa ante una coincidencia parcial provocada a proposito, la opcion
  # no esta puesta y esta compuerta no vigila nada. Una compuerta desarmada que
  # no lo dice es peor que no tenerla: da por revisado lo que nadie reviso.
  if (length(pref) == 0L) {
    stop("No se pudo derivar el aviso de coincidencia parcial: R no avisó ante una ",
         "provocada a propósito.\n  Revisa que 10_utils/10_configuracion.R fije ",
         "options(warnPartialMatchDollar = TRUE). Sin ese aviso esta compuerta no vigila nada.")
  }
  pref
}
PREFIJOS_PARCIAL <- derivar_prefijos_parciales()

# Ejecuta un paso con la compuerta puesta. Alcance declarado: R avisa solo cuando
# la coincidencia parcial RESUELVE; un prefijo con dos o mas hermanas devuelve
# NULL sin avisar, porque ahi no hubo coincidencia. La compuerta caza el defecto,
# no la fragilidad; el mapa de la fragilidad es
# 50_documentacion/andamios/20260826_reclasificacion_clase_b_v1.md.
ejecutar_paso <- function(ruta) {
  withCallingHandlers(
    source(ruta, echo = FALSE, chdir = TRUE),
    warning = function(w) {
      if (!any(startsWith(conditionMessage(w), PREFIJOS_PARCIAL))) return(invisible(NULL))
      stop(sprintf(paste0("coincidencia parcial de nombres.\n",
                          "  Aviso de R: %s\n",
                          "  Llamada:    %s\n",
                          "  La clave exacta no estaba y R devolvió otra que la tiene por ",
                          "comienzo.\n  Cambia ese acceso a [[ ]], que no adivina."),
                  conditionMessage(w),
                  paste(deparse(conditionCall(w)), collapse = " ")),
           call. = FALSE)
    })
}

# ---- Definicion de pasos ----------------------------------------------------
# El id refleja el numero de sub-etapa en 30_procesamiento/ (POLITICA 1.2).
PASOS <- list(
  list(id = 30L, etiqueta = "Clasificar el corpus por huella (nuevo/modificado)",
       ruta = "30_procesamiento/30_manifiesto_corpus.R"),
  list(id = 31L, etiqueta = "Extraer texto de los PDF",
       ruta = "30_procesamiento/31_extraer_texto.R"),
  list(id = 32L, etiqueta = "Segmentar por artículo y escribir JSON",
       ruta = "30_procesamiento/32_segmentar_articulos.R"),
  list(id = 33L, etiqueta = "Derivar relaciones entre normas",
       ruta = "30_procesamiento/33_relaciones.R"),
  list(id = 34L, etiqueta = "Generar las páginas .qmd del sitio",
       ruta = "30_procesamiento/34_generar_paginas.R"),
  list(id = 35L, etiqueta = "Renderizar el sitio con Quarto",
       ruta = "30_procesamiento/35_renderizar_sitio.R"),
  list(id = 36L, etiqueta = "Construir el índice de búsqueda (Pagefind)",
       ruta = "30_procesamiento/36_indexar_pagefind.R")
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
      ejecutar_paso(fs::path(ROOT, p$ruta)),
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

# ---- Ejecucion directa ------------------------------------------------------
# `Rscript 00_run_all.R` definia run_all() y terminaba ahi: exit 0, cero lineas
# de log y cero cambios en el arbol, que es exactamente la forma que tiene un
# paso de pipeline de parecer ejecutado sin haberlo estado (encargo v4, T2).
#
# La guardia es `sys.nframe() == 0L` y NO `!interactive()` a secas: bajo
# `source()` el marco de llamada es > 0 (medido: 4), asi que el uso documentado
# arriba y el del workflow de CI —ambos `source("00_run_all.R"); run_all()`—
# siguen corriendo el pipeline UNA sola vez y no dos.
# El `!interactive()` NO es redundante: pegar este archivo entero en una consola
# interactiva tambien da sys.nframe() == 0, y ahi no se quiere disparar nada.
#
# Y se rechazan los argumentos de linea de comandos en vez de ignorarlos: este archivo
# no lee commandArgs(), asi que `Rscript 00_run_all.R --from 32` correria el pipeline
# COMPLETO en silencio, que es peor que no correr nada. Varios encargos del proyecto
# instruyen la forma `Rscript 00_run_all.R`, de modo que la confusion es esperable.
if (sys.nframe() == 0L && !interactive()) {
  .args <- commandArgs(trailingOnly = TRUE)
  if (length(.args) > 0L) {
    stop("00_run_all.R no acepta argumentos de linea de comandos (recibio: ",
         paste(.args, collapse = " "), ").\n",
         "  Para el pipeline completo:  Rscript 00_run_all.R\n",
         "  Para un rango:              Rscript -e 'source(\"00_run_all.R\"); run_all(from = 32)'")
  }
  run_all()
}
