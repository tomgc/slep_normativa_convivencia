# =============================================================================
# a3_cargar_defs.R — laboratorio A3, encargo v9 (desechable)
# -----------------------------------------------------------------------------
# Carga SOLO definiciones de un script del pipeline, sin ejecutar su bloque de
# corrida. Motivo: 34_generar_paginas.R borra y reescribe 40_salidas/sitio_src/
# al ser sourced, y 33_relaciones.R escribe relaciones.json. Este encargo
# prohibe ambas cosas, pero exige probar la compuerta de firma con su CODIGO
# REAL, no con una copia.
#
# Regla de seleccion, declarada: se evalua una expresion de nivel superior si y
# solo si (a) es una asignacion `nombre <- ...` y (b) su lado derecho es una
# `function(...)` O el nombre esta en la lista blanca `constantes`. Todo lo
# demas (lecturas de JSON, bucles, writeLines, dir_delete) se omite y se cuenta.
#
# Uso:  source(here::here("50_documentacion","andamios","lab_motor_v9","a3_cargar_defs.R"))
#       d <- cargar_defs_de(here::here("30_procesamiento","34_generar_paginas.R"),
#                           constantes = CONSTANTES_34)
#       d$env$revisar_pieza(...)
# =============================================================================

cargar_defs_de <- function(archivo, constantes = character(0),
                           env = new.env(parent = globalenv())) {
  exprs <- as.list(parse(archivo, keep.source = FALSE))
  es_asignacion <- function(x) is.call(x) && length(x) == 3L &&
    (identical(x[[1]], as.name("<-")) || identical(x[[1]], as.name("=")))
  es_funcion <- function(x) is.call(x[[3]]) && identical(x[[3]][[1]], as.name("function"))
  evaluadas <- character(0); omitidas <- character(0)
  for (x in exprs) {
    if (es_asignacion(x) && is.name(x[[2]])) {
      nombre <- as.character(x[[2]])
      if (es_funcion(x) || nombre %in% constantes) {
        eval(x, envir = env)
        evaluadas <- c(evaluadas, nombre)
        next
      }
      omitidas <- c(omitidas, paste0(nombre, " <- ", deparse(x[[3]])[1]))
      next
    }
    omitidas <- c(omitidas, paste(deparse(x)[1], "..."))
  }
  list(env = env, evaluadas = evaluadas, omitidas = omitidas, n_total = length(exprs))
}

# Constantes que las funciones de la compuerta de 34 necesitan en tiempo de
# llamada (leidas del archivo el 2026-09-05; ver §1.3 del documento A3).
CONSTANTES_34 <- c("ORIGEN", "ESPACIOS_INVISIBLES", "CLAVES_RESERVADAS",
                   "ESTADOS_PIEZA", "NO_SON_FIRMA", "TIPOS_PIEZA")

# Constantes que patron_cita() y anio_de_la_cita() de 33 necesitan.
CONSTANTES_33 <- c("ORIGEN", "PALABRAS_TIPO", "VENTANA_ANIO_CITA", "VENTANA_ANIO_DO",
                   "REGEX_CORTE_PROSA", "REGEX_CABEZA_NOTA", "REGEX_ANIO_PROSA",
                   "REGEX_ANIO_DO")

# Los utilitarios se sourcean ENTEROS porque son lectura: verificado con
#   grep -n -E "writeLines|write\.|write_json|file_move|file_copy|dir_create|dir_delete|sink\(|saveRDS" \
#     10_utils/10_utils.R 10_utils/10_configuracion.R 10_utils/10_locale.R
# cuya unica coincidencia ejecutable es `fs::file_move` DENTRO de la definicion
# de escribir_atomico(), que no se llama al cargar.
cargar_entorno_pipeline <- function() {
  source(here::here("10_utils", "10_utils.R"))
  source(here::here("10_utils", "10_configuracion.R"))
  invisible(TRUE)
}

# Lectura de las 25 normas, con [[ ]] exacto (regla aprendida 1 de la sesion 2).
leer_normas <- function() {
  archivos <- fs::dir_ls(here::here("40_salidas", "datos", "normas"), glob = "*.json")
  normas <- lapply(archivos, function(f) jsonlite::fromJSON(f, simplifyVector = FALSE))
  names(normas) <- vapply(normas, function(n) n[["slug"]], character(1))
  normas
}

# ids publicados como `id="..."` en el HTML generado de una norma.
ids_html_de <- function(slug) {
  ruta <- here::here("40_salidas", "sitio", paste0(slug, ".html"))
  if (!file.exists(ruta)) return(character(0))
  html <- readLines(ruta, warn = FALSE)
  m <- unique(unlist(regmatches(html, gregexpr('id="[^"]+"', html))))
  sub('"$', "", sub('^id="', "", m))
}
