# =============================================================================
# 35_indexar_pagefind.R
# -----------------------------------------------------------------------------
# Proposito: construir el indice de busqueda de Pagefind sobre el sitio ya
#            renderizado. Deja 40_salidas/sitio/pagefind/ con el indice, el WASM
#            y los archivos de la interfaz que carga busqueda.html.
#
# Pagefind es una herramienta de linea de comandos (Rust), no un paquete de R:
# se invoca con system2(). Se usa la copia LOCAL del proyecto (npm install la
# fija en package.json y package-lock.json) y no una descarga al vuelo, para que
# la version que indexa en la maquina del equipo y la que indexa en GitHub
# Actions sean la misma.
#
# La indexacion es a nivel de ARTICULO: cada pagina de norma marca su cuerpo con
# data-pagefind-body y cada articulo es un encabezado con id, de modo que
# Pagefind devuelve un sub-resultado por articulo con su ancla. Esa correspondencia
# vive en 33_generar_paginas.R; aqui solo se dispara el indexador.
# =============================================================================

source(here::here("10_utils", "10_utils.R"))
instalar_si_falta(c("fs", "here"))
source(here::here("10_utils", "10_configuracion.R"))

ORIGEN <- "35_indexar_pagefind"

if (!fs::dir_exists(ruta_sitio())) {
  stop("No existe ", ruta_sitio(), ". Correr antes el paso 34 (run_all(only = 34)).")
}
if (!nzchar(Sys.which("npx"))) {
  stop("No se encontro 'npx' en el PATH. Pagefind se instala con Node: ",
       "instalar Node y correr `npm install` en la raiz del proyecto.")
}

n_html <- length(fs::dir_ls(ruta_sitio(), glob = "*.html"))
log_msg(sprintf("Indexando %d páginas HTML con Pagefind.", n_html), origen = ORIGEN)

# --no-install: falla si Pagefind no esta instalado en node_modules/, en vez de
# descargar en silencio una version distinta de la fijada en package-lock.json.
codigo <- system2("npx", c("--no-install", "pagefind", "--site", ruta_sitio()),
                  stdout = TRUE, stderr = TRUE)
estado <- attr(codigo, "status")
cat(paste(codigo, collapse = "\n"), "\n")
if (!is.null(estado) && estado != 0L) {
  stop("Pagefind salio con codigo ", estado, ". Revisar la salida de arriba.")
}

# El criterio de exito no es el codigo de salida: es que el indice exista y tenga
# el numero de paginas que se le dieron. Pagefind sale con 0 aunque no indexe
# nada si ninguna pagina lleva data-pagefind-body.
entrada <- ruta_sitio("pagefind", "pagefind-entry.json")
if (!fs::file_exists(entrada)) stop("Pagefind no dejo indice en ", dirname(entrada))

meta <- jsonlite::fromJSON(entrada)
indexadas <- sum(vapply(meta$languages, function(l) l$page_count, integer(1)))
if (indexadas == 0L) stop("El indice quedo vacio: ninguna pagina llevaba data-pagefind-body.")

log_msg(sprintf("Índice construido: %d páginas indexadas en %s.",
                indexadas, ruta_sitio("pagefind")),
        origen = ORIGEN)
