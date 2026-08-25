# =============================================================================
# 10_utils.R
# -----------------------------------------------------------------------------
# Funciones genericas compartidas entre multiples scripts del proyecto.
# RESTRICCION (POLITICA 1.4): cero dependencias de paquetes cargados; se usa
# siempre pkg::fun(). Eso permite cargar este archivo ANTES de cualquier
# library() y resolver el bootstrapping (instalacion condicional, logging).
# Solo entra aqui lo que es (a) generico y (b) usado en mas de un script.
# =============================================================================

# ---- Bootstrapping: instalacion condicional de paquetes ---------------------
instalar_si_falta <- function(paquetes) {
  faltantes <- paquetes[
    !sapply(paquetes, requireNamespace, quietly = TRUE)
  ]
  if (length(faltantes) > 0) {
    message(sprintf("Instalando paquetes faltantes: %s",
                    paste(faltantes, collapse = ", ")))
    utils::install.packages(faltantes)
  }
  invisible(TRUE)
}

# ---- Logging ----------------------------------------------------------------
# Formato fijo de POLITICA 4: [YYYY-MM-DD HH:MM:SS] [origen] [NIVEL] mensaje.
log_msg <- function(msg, nivel = "INFO", origen = NA_character_) {
  ts <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  if (is.na(origen)) {
    cat(sprintf("[%s] [%s] %s\n", ts, nivel, msg))
  } else {
    cat(sprintf("[%s] [%s] [%s] %s\n", ts, origen, nivel, msg))
  }
}

# ---- Anclaje de raiz del proyecto -------------------------------------------
obtener_raiz_proyecto <- function() {
  rprojroot::find_root(
    criterion = rprojroot::has_file(".here") |
                rprojroot::is_rstudio_project |
                rprojroot::is_git_root
  )
}

# ---- Escritura atomica (patron write -> rename) -----------------------------
# POLITICA 5.2.4: ningun artefacto que alimente otro proceso puede quedar
# parcialmente escrito. Aqui importa de verdad: el generador de paginas (33) lee
# los JSON que escribe el segmentador (32); un JSON truncado por una corrida
# interrumpida produciria una pagina de ley con el articulado cortado y sin
# ningun error visible.
escribir_atomico <- function(objeto, ruta, escritor) {
  ruta_temp <- paste0(ruta, ".tmp")
  escritor(objeto, ruta_temp)
  fs::file_move(ruta_temp, ruta)
  invisible(ruta)
}

# ---- Slug para identificadores de URL y de archivo --------------------------
# Convierte "Artículo 5° bis" en "articulo-5-bis". Se usa en el segmentador (32)
# para los id de articulo y en el generador (33) para las anclas del HTML: tienen
# que salir del MISMO codigo, o el ancla del sitio no coincide con el id del JSON
# y los resultados de busqueda apuntan a un fragmento inexistente.
slugificar <- function(x) {
  x |>
    stringi::stri_trans_general("Latin-ASCII") |>
    tolower() |>
    gsub(pattern = "[^a-z0-9]+", replacement = "-") |>
    gsub(pattern = "^-+|-+$",    replacement = "")
}

# ---- Escape de texto legal para HTML ----------------------------------------
# El texto normativo se inyecta en los .qmd generados dentro de bloques HTML
# crudos, no como Markdown. Motivo: en Markdown un "*" de nota al pie, un "_" o
# un "#" del original se interpretan como marcado y el renderizador los come, de
# modo que el articulo publicado dejaria de ser identico al del PDF. Escapar las
# tres entidades que HTML exige (&, <, >) es lo minimo que preserva el texto.
# La comilla doble NO se escapa: solo hace falta dentro del valor de un atributo,
# y este texto va como contenido de un elemento. Escaparla llenaba de &quot; unos
# archivos que alguien va a abrir para comprobar que la cita legal es fiel.
# literal; no es "corregir" el original (eso esta prohibido por el invariante de
# fidelidad), es impedir que el renderizador lo altere.
escapar_html <- function(x) {
  x |>
    gsub(pattern = "&", replacement = "&amp;",  fixed = TRUE) |>
    gsub(pattern = "<", replacement = "&lt;",   fixed = TRUE) |>
    gsub(pattern = ">", replacement = "&gt;",   fixed = TRUE)
}
