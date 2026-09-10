# =============================================================================
# a4_medir_corpus.R - recuento propio del corpus para el alcance Cloudflare (A4, v9)
# -----------------------------------------------------------------------------
# Solo LEE 40_salidas/datos/ y 40_salidas/sitio/. No escribe nada fuera de stdout.
# Toda cifra del documento 20260904_alcance_arquitectura_cloudflare_v1.md que
# describa el corpus sale de esta salida, no de la memoria ni del traspaso.
# Acceso a estructuras leidas de disco: siempre [[ ]], nunca $.
# =============================================================================
suppressPackageStartupMessages({
  library(jsonlite); library(dplyr); library(purrr); library(fs); library(here)
})
options(width = 120)  # CIF-A4-03: ancho fijo, para que el bloque pegado en el .md sea reproducible
cat("R:", R.version.string, " fecha:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n")
cat("raiz here():", here::here(), "\n\n")

# ---- 1. Normas y articulos ---------------------------------------------------
archivos_normas <- dir_ls(here::here("40_salidas/datos/normas"), glob = "*.json")
catalogo <- fromJSON(here::here("40_salidas/datos/catalogo.json"), simplifyVector = FALSE)
cat("== Normas ==\n")
cat("archivos normas/*.json      :", length(archivos_normas), "\n")
cat("catalogo[['n_normas']]      :", catalogo[["n_normas"]], "\n")
cat("catalogo[['n_articulos']]   :", catalogo[["n_articulos"]], "\n")
cat("length(catalogo[['normas']]):", length(catalogo[["normas"]]), "\n")

normas <- map(archivos_normas, \(f) fromJSON(f, simplifyVector = FALSE))
tabla_art <- map_dfr(normas, \(n) {
  arts <- n[["articulos"]]
  tibble(
    slug         = n[["slug"]],
    origen_texto = n[["origen_texto"]],
    id           = map_chr(arts, \(a) a[["id"]]),
    es_articulo  = map_lgl(arts, \(a) isTRUE(a[["es_articulo"]])),
    n_char       = map_int(arts, \(a) nchar(a[["texto"]], type = "chars")),
    n_bytes      = map_int(arts, \(a) nchar(a[["texto"]], type = "bytes"))
  )
})
cat("\n== Segmentos (unidades en articulos[]) ==\n")
cat("segmentos totales           :", nrow(tabla_art), "\n")
cat("con es_articulo == TRUE     :", sum(tabla_art[["es_articulo"]]), "\n")
cat("con es_articulo == FALSE    :", sum(!tabla_art[["es_articulo"]]), "\n")
cat("suma n_articulos por norma  :", sum(map_int(normas, \(n) as.integer(n[["n_articulos"]]))), "\n")
cat("suma n_segmentos por norma  :", sum(map_int(normas, \(n) as.integer(n[["n_segmentos"]]))), "\n")

# CON-A4-04: la unidad que el Worker puede poner en el contexto es el segmento
# FIRMADO (origen_texto en {capa_texto_pdf, ocr_revisado}), no el segmento con
# es_articulo == TRUE. Se cuentan las dos, y lo que cada filtro descarta.
ORIGENES_FIRMADOS <- c("capa_texto_pdf", "ocr_revisado")
firmada <- tabla_art[["origen_texto"]] %in% ORIGENES_FIRMADOS
cat("\n== Filtro del contexto: firmado (origen_texto) contra es_articulo ==\n")
cat("segmentos firmados          :", sum(firmada), "\n")
cat("descartados por el filtro   :", sum(!firmada), " (todos OCR sin revisar)\n")
cat("firmados que es_articulo descartaria:", sum(!tabla_art[["es_articulo"]] & firmada), "\n")
cat("firmados que el filtro nuevo descarta:", sum(!firmada & tabla_art[["origen_texto"]] == "capa_texto_pdf"), " (esperado 0)\n")
cat("CONTROL POSITIVO origen_texto inexistente:", sum(tabla_art[["origen_texto"]] %in% "zzz"), "(esperado 0)\n")

cat("\n== origen_texto por norma ==\n")
print(tabla_art |> distinct(slug, origen_texto) |> count(origen_texto, name = "normas"))
cat("\n== segmentos por origen_texto ==\n")
print(tabla_art |> summarise(segmentos = n(), articulos = sum(es_articulo), caracteres = sum(n_char), .by = origen_texto))

cat("\n== Largo de los segmentos con es_articulo == TRUE (caracteres) ==\n")
arts_true <- tabla_art |> filter(es_articulo)
# CIF-A4-06: `as.integer()` TRUNCA (888.5 -> 888) y el documento publicaba el valor
# truncado junto a "articulo mediano ~ 223 tokens", que es ceiling(888.5/4): las dos
# cifras publicadas eran inconsistentes en 1 token. Se redondea a una decimal.
q <- quantile(arts_true[["n_char"]], c(0, .5, .9, .95, 1))
cat(sprintf("min %.2f | mediana %.2f | p90 %.2f | p95 %.2f | max %.2f | media %.1f | total %d\n",
            q[[1]], q[[2]], q[[3]], q[[4]], q[[5]], mean(arts_true[["n_char"]]), sum(arts_true[["n_char"]])))
cat(sprintf("  CONTROL: valores truncados con as.integer(), que es lo que el documento publicaba: %d / %d / %d / %d / %d\n",
            as.integer(q[[1]]), as.integer(q[[2]]), as.integer(q[[3]]), as.integer(q[[4]]), as.integer(q[[5]])))
cat(sprintf("  CONTROL: tokens del articulo mediano con la regla de 4 car./token = ceiling(%.1f/4) = %d\n", q[[2]], ceiling(q[[2]] / 4)))
cat("\n== Largo de TODOS los segmentos (caracteres) ==\n")
q2 <- quantile(tabla_art[["n_char"]], c(0, .5, .9, 1))
cat(sprintf("min %.1f | mediana %.1f | p90 %.1f | max %.1f | media %.1f | total %d | total bytes %d\n",
            q2[[1]], q2[[2]], q2[[3]], q2[[4]],
            mean(tabla_art[["n_char"]]), sum(tabla_art[["n_char"]]), sum(tabla_art[["n_bytes"]])))

# ---- 2. Relaciones -----------------------------------------------------------
rel <- fromJSON(here::here("40_salidas/datos/relaciones.json"), simplifyVector = FALSE)
cat("\n== Relaciones ==\n")
cat("rel[['n_relaciones']]        :", rel[["n_relaciones"]], "\n")
cat("length(rel[['relaciones']])  :", length(rel[["relaciones"]]), "\n")
cat("por_tipo:", paste(names(rel[["por_tipo"]]), unlist(rel[["por_tipo"]]), sep = "=", collapse = ", "), "\n")

# ---- 3. Pesos en disco -------------------------------------------------------
peso <- function(p) as.numeric(file_size(p))
gz <- function(p) length(memCompress(readBin(p, "raw", file_size(p)), type = "gzip"))
cat("\n== Pesos (bytes; gzip = memCompress en R, no el gzip del servidor) ==\n")
cat(sprintf("catalogo.json      : %8d  gzip %7d\n", peso(here::here("40_salidas/datos/catalogo.json")), gz(here::here("40_salidas/datos/catalogo.json"))))
cat(sprintf("relaciones.json    : %8d  gzip %7d\n", peso(here::here("40_salidas/datos/relaciones.json")), gz(here::here("40_salidas/datos/relaciones.json"))))
cat(sprintf("normas/*.json (25) : %8d  gzip %7d\n", sum(map_dbl(archivos_normas, peso)), sum(map_int(archivos_normas, gz))))
cat(sprintf("manifiesto_corpus  : %8d\n", peso(here::here("40_salidas/datos/manifiesto_corpus.json"))))
todo_json <- c(here::here("40_salidas/datos/catalogo.json"), here::here("40_salidas/datos/relaciones.json"), archivos_normas)
cat(sprintf("TOTAL datos canon. : %8d  gzip %7d\n", sum(map_dbl(todo_json, peso)), sum(map_int(todo_json, gz))))

sitio <- here::here("40_salidas/sitio")
info_sitio <- dir_info(sitio, recurse = TRUE, type = "file")
cat("\n== Sitio generado (40_salidas/sitio, no versionado) ==\n")
cat("archivos                   :", nrow(info_sitio), "\n")
cat("bytes totales              :", sum(as.numeric(info_sitio[["size"]])), "\n")
cat("html en raiz               :", length(dir_ls(sitio, glob = "*.html")), "\n")
info_pf <- dir_info(path(sitio, "pagefind"), recurse = TRUE, type = "file")
cat("pagefind/ archivos         :", nrow(info_pf), "\n")
cat("pagefind/ bytes            :", sum(as.numeric(info_pf[["size"]])), "\n")
pdf_info <- dir_info(path(sitio, "pdf"), recurse = TRUE, type = "file", fail = FALSE)
cat("pdf/ archivos              :", nrow(pdf_info), " bytes:", sum(as.numeric(pdf_info[["size"]])), "\n")
pdfs_insumo <- dir_info(here::here("20_insumos/normativa"), glob = "*.pdf", type = "file")
cat("20_insumos/normativa/*.pdf :", nrow(pdfs_insumo), " bytes:", sum(as.numeric(pdfs_insumo[["size"]])), "\n")
entry <- fromJSON(path(sitio, "pagefind/pagefind-entry.json"), simplifyVector = FALSE)
cat("pagefind-entry version     :", entry[["version"]], "\n")
