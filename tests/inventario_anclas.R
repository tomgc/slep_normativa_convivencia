# =============================================================================
# inventario_anclas.R - prueba de regresion de las anclas del sitio publicado.
# -----------------------------------------------------------------------------
# SOLO LECTURA sobre el repositorio. Escribe unicamente el volcado de id por
# pagina en el directorio de trabajo (no versionado) que recibe por --salida.
# NO regenera el sitio: mide 40_salidas/sitio tal como esta.
#
# QUE PROTEGE
# -----------
# El invariante 1 del encargo v11: el conjunto de id de encabezado por pagina no
# cambia. Las citas que el equipo ya copio fuera del sitio ("<pagina>.html#art-3")
# apuntan a esas anclas; una regeneracion que las renombre rompe enlaces que
# nadie va a ver romperse. El uso es: correr con --previo ANTES de tocar el
# generador, correr sin --previo despues, y comparar los dos volcados con diff.
#
# DE DONDE SALEN LAS DEFINICIONES (no se inventan aqui)
# -----------------------------------------------------
# 50_documentacion/andamios/20260908_medicion_correcciones_v1.md, seccion 2 y su
# anexo A.1 (`medicion_estructura.R`), que son la fuente de las cifras 806 y 848:
#
#   segmento con ancla  - cada entrada de `articulos[]` de un JSON de
#                         40_salidas/datos/normas/, buscada como id="<id>" en
#                         <slug>.html del sitio. Declarados 806; presentes 806.
#   destino verificable - las tres clases de destino del inventario del v9 que
#                         existen en el sitio publicado (§2, tabla final):
#                           806 anclas de segmento  <slug>.html#<id>
#                          + 25 paginas de norma    <slug>.html
#                          + 17 paginas tematicas   tema-<slug>.html
#                          = 848, que resuelven 848.
#                         Los 39 que faltan para el 887 del v9 son encabezados
#                         del glosario, que NO esta publicado (invariante 5).
#
# Uso, desde la raiz del repositorio:
#   Rscript tests/inventario_anclas.R
#   Rscript tests/inventario_anclas.R --previo
#   Rscript tests/inventario_anclas.R --sitio <ruta>   (control positivo)
#
# Argumentos:
#   --previo         escribe ids_por_pagina_previo.txt en vez de ids_por_pagina.txt
#   --sitio <ruta>   directorio del sitio. Por defecto 40_salidas/sitio. Existe
#                    para el control positivo: se mide una copia del sitio con un
#                    id borrado a mano y el instrumento debe bajar la cifra.
#   --salida <dir>   directorio de trabajo. Por defecto
#                    50_documentacion/andamios/lab_motor_v9/salida_v11
# =============================================================================

source(here::here("10_utils", "10_utils.R"))
instalar_si_falta(c("jsonlite", "dplyr", "tibble", "stringr", "here", "fs"))
source(here::here("10_utils", "10_configuracion.R"))

suppressPackageStartupMessages({
  library(dplyr); library(tibble); library(stringr)
})

# ---- Argumentos -------------------------------------------------------------
args <- commandArgs(trailingOnly = TRUE)
valor_arg <- function(nombre, defecto) {
  i <- match(nombre, args)
  if (is.na(i) || i >= length(args)) defecto else args[[i + 1L]]
}
absoluta <- function(p) if (fs::is_absolute_path(p)) p else here::here(p)

PREVIO  <- "--previo" %in% args
SITIO   <- absoluta(valor_arg("--sitio", "40_salidas/sitio"))
DIR_SAL <- absoluta(valor_arg("--salida",
                              "50_documentacion/andamios/lab_motor_v9/salida_v11"))
fs::dir_create(DIR_SAL)
stopifnot(fs::dir_exists(SITIO))

# Validez de lectura: si el sitio deja de tener las paginas que se midieron, toda
# cifra de abajo cambia de denominador sin avisar. Se prefiere fallar ruidoso.
N_PAGINAS_ESPERADAS <- 47L   # REVISAR: subir si el sitio gana paginas (T3 del v11)

# ---- Lectura del sitio ------------------------------------------------------
leer <- function(p) paste(readLines(p, warn = FALSE, encoding = "UTF-8"), collapse = "\n")

htmls   <- sort(list.files(SITIO, pattern = "[.]html$", full.names = TRUE))
nombres <- basename(htmls)
cont    <- lapply(htmls, leer)
names(cont) <- nombres
stopifnot(length(htmls) == N_PAGINAS_ESPERADAS)

tiene_id <- function(archivo, id) {
  if (!(archivo %in% names(cont))) return(FALSE)
  str_detect(cont[[archivo]], fixed(paste0('id="', id, '"')))
}
# Los id que Pagefind usa como sub-resultado y que las citas del equipo apuntan:
# los que cuelgan de un encabezado h1..h6. Regex de A.1, sin cambios.
ids_encabezado_de <- function(txt) {
  m <- str_match_all(txt, '<h[1-6][^>]*\\sid="([^"]+)"')[[1L]]
  if (nrow(m) == 0L) character(0) else m[, 2L]
}

# ---- Segmentos con ancla ----------------------------------------------------
jsons <- sort(list.files(ruta_normas(), pattern = "[.]json$", full.names = TRUE))
stopifnot(length(jsons) > 0L)
normas <- lapply(jsons, jsonlite::fromJSON, simplifyVector = FALSE)

seg <- bind_rows(lapply(normas, function(j) tibble(
  slug = as.character(j[["slug"]]),
  id   = vapply(j[["articulos"]], function(a) as.character(a[["id"]]), character(1))
)))
seg[["archivo"]]  <- paste0(seg[["slug"]], ".html")
seg[["presente"]] <- mapply(tiene_id, seg[["archivo"]], seg[["id"]])

# ---- Destinos verificables contra el sitio ----------------------------------
# Las paginas tematicas se derivan como lo hace 34_generar_paginas.R:1157-1161
# (union de los `tema` de los JSON, luego slugificar()), y no listando el propio
# sitio: un inventario que lee sus destinos del artefacto que verifica no puede
# fallar nunca.
# REVISAR: `slug_tema()` vive hoy dentro de 34_generar_paginas.R; si T2 la sube a
# 10_utils, borrar esta copia y llamarla.
temas <- sort(unique(unlist(lapply(normas, function(j) j[["tema"]]))))
slug_tema <- function(t) paste0("tema-", slugificar(t))

destinos <- bind_rows(
  tibble(clase = "ancla de segmento", archivo = seg[["archivo"]], ancla = seg[["id"]]),
  tibble(clase = "pagina de norma",
         archivo = paste0(vapply(normas, function(j) as.character(j[["slug"]]), character(1)), ".html"),
         ancla = NA_character_),
  tibble(clase = "pagina tematica",
         archivo = paste0(slug_tema(temas), ".html"), ancla = NA_character_)
)
destinos[["resuelve"]] <- mapply(function(a, k) {
  if (!(a %in% names(cont))) return(FALSE)
  if (is.na(k)) return(TRUE)
  tiene_id(a, k)
}, destinos[["archivo"]], destinos[["ancla"]])

# ---- Volcado de id por pagina (comparable byte a byte con diff) -------------
# Una linea por id, "<pagina>.html<TAB><id>", paginas ordenadas e id ordenados
# dentro de cada pagina: es un CONJUNTO, y el orden de documento no debe hacer
# que dos volcados equivalentes difieran.
lineas <- unlist(lapply(nombres, function(n) {
  ids <- sort(unique(ids_encabezado_de(cont[[n]])))
  if (length(ids) == 0L) return(character(0))
  paste0(n, "\t", ids)
}), use.names = FALSE)
ARCHIVO_IDS <- fs::path(DIR_SAL, if (PREVIO) "ids_por_pagina_previo.txt" else "ids_por_pagina.txt")
writeLines(lineas, ARCHIVO_IDS, useBytes = TRUE)

# ---- Reporte ----------------------------------------------------------------
cat("=============================================================\n")
cat("INVENTARIO DE ANCLAS", if (PREVIO) "-- volcado PREVIO" else "", "\n")
cat("=============================================================\n")
cat("sitio:            ", SITIO, "\n")
cat("paginas_html:     ", length(htmls), "\n")
cat("json_de_norma:    ", length(jsons), "\n\n")

cat("segmentos_con_ancla: ", sum(seg[["presente"]]), "\n", sep = "")
cat("  (declarados en los JSON: ", nrow(seg),
    " | ausentes del HTML: ", sum(!seg[["presente"]]), ")\n", sep = "")
if (any(!seg[["presente"]])) {
  cat("\n  Segmentos declarados que NO estan en su HTML:\n")
  print(as.data.frame(seg[!seg[["presente"]], c("archivo", "id")]), row.names = FALSE)
}

cat("\ndestinos_resueltos: ", sum(destinos[["resuelve"]]), " de ", nrow(destinos), "\n", sep = "")
print(as.data.frame(destinos |> summarise(destinos = n(), resuelven = sum(.data[["resuelve"]]),
                                          .by = "clase")), row.names = FALSE)
if (any(!destinos[["resuelve"]])) {
  cat("\n  Destinos que NO resuelven:\n")
  print(as.data.frame(destinos[!destinos[["resuelve"]], c("clase", "archivo", "ancla")]),
        row.names = FALSE)
}

cat("\nid de encabezado en todo el sitio: ", length(lineas), "\n", sep = "")
cat("volcado: ", ARCHIVO_IDS, "\n", sep = "")
