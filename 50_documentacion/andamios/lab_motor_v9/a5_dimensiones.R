# =============================================================================
# a5_dimensiones.R  (laboratorio del encargo v9, agente A5: panel adversarial)
# -----------------------------------------------------------------------------
# Recuenta las dimensiones del corpus que fundan los ataques de las tareas 4, 5 y
# 6: unidades de recuperación, bytes, relaciones, texto OCR, distribución de
# largos, vocabulario léxico, campos de vigencia, versiones múltiples de un mismo
# artículo. Solo lee 40_salidas/datos/ y 20_insumos/curaduria/. No escribe nada
# fuera de la salida estándar (se captura con tee al archivo a5_dimensiones_salida.txt).
#
# Acceso a estructuras leídas de disco: [[ ]] exacto, nunca $ (regla aprendida 1).
# =============================================================================

suppressPackageStartupMessages({
  library(jsonlite); library(dplyr); library(purrr); library(stringr)
  library(stringi); library(tibble); library(here)
})
options(warnPartialMatchDollar = TRUE)

cab <- function(x) cat("\n==== ", x, " ====\n", sep = "")

ruta_datos <- here::here("40_salidas", "datos")
cat_json <- jsonlite::fromJSON(file.path(ruta_datos, "catalogo.json"), simplifyDataFrame = FALSE)
slugs <- vapply(cat_json[["normas"]], function(x) x[["slug"]], character(1))
normas <- lapply(slugs, function(s)
  jsonlite::fromJSON(file.path(ruta_datos, "normas", paste0(s, ".json")), simplifyDataFrame = FALSE))
names(normas) <- slugs

# ---- 1. Unidades ------------------------------------------------------------
cab("1. Normas y unidades de recuperación")
segmentos <- map_dfr(normas, function(n) {
  tibble(
    slug        = n[["slug"]],
    tipo        = n[["tipo"]],
    origen      = n[["origen_texto"]],
    anio        = if (is.null(n[["anio"]])) NA_integer_ else as.integer(n[["anio"]]),
    vigencia    = n[["vigencia"]][["estado"]],
    id          = vapply(n[["articulos"]], function(a) a[["id"]], character(1)),
    es_articulo = vapply(n[["articulos"]], function(a) isTRUE(a[["es_articulo"]]), logical(1)),
    nchar       = vapply(n[["articulos"]], function(a) nchar(a[["texto"]]), integer(1))
  )
})
cat("normas:", length(normas), "\n")
cat("catalogo n_articulos declarado:", cat_json[["n_articulos"]], "\n")
cat("segmentos totales (todo lo que lleva ancla):", nrow(segmentos), "\n")
cat("  de los cuales es_articulo == TRUE:", sum(segmentos[["es_articulo"]]), "\n")
cat("  de los cuales es_articulo == FALSE (preámbulos, secciones, páginas OCR):",
    sum(!segmentos[["es_articulo"]]), "\n")
cat("  páginas OCR (id empieza por ocr-pagina-):",
    sum(str_starts(segmentos[["id"]], "ocr-pagina-")), "\n")
cat("segmentos por origen_texto:\n")
print(segmentos |> count(origen, es_articulo) |> as.data.frame())

# ---- 2. Bytes ---------------------------------------------------------------
cab("2. Peso del corpus")
bytes_json <- sum(file.size(file.path(ruta_datos, "normas", paste0(slugs, ".json"))))
cat("bytes de los 25 JSON de norma:", bytes_json, "\n")
cat("bytes de catalogo.json:", file.size(file.path(ruta_datos, "catalogo.json")), "\n")
cat("bytes de relaciones.json:", file.size(file.path(ruta_datos, "relaciones.json")), "\n")
texto_total <- paste(unlist(lapply(normas, function(n)
  vapply(n[["articulos"]], function(a) a[["texto"]], character(1)))), collapse = "\n")
cat("caracteres de texto de todos los segmentos:", nchar(texto_total), "\n")
cat("bytes UTF-8 del texto:", nchar(texto_total, type = "bytes"), "\n")
tmp <- tempfile(fileext = ".txt"); writeLines(texto_total, tmp)
tmp_gz <- tempfile(fileext = ".gz")
con <- gzfile(tmp_gz, "wb"); writeLines(texto_total, con); close(con)
cat("bytes del texto comprimido con gzip:", file.size(tmp_gz), "\n")
ocr_chars <- sum(segmentos[["nchar"]][segmentos[["origen"]] == "ocr_pendiente_revision"])
cat("caracteres en segmentos con origen ocr_pendiente_revision:", ocr_chars,
    sprintf("(%.1f%% del texto)", 100 * ocr_chars / nchar(texto_total)), "\n")

# ---- 3. Distribución de largos ---------------------------------------------
cab("3. Largo de los segmentos (caracteres)")
q <- function(x) round(quantile(x, c(0, .5, .9, .95, 1)))
cat("todos los segmentos:\n"); print(q(segmentos[["nchar"]]))
cat("solo es_articulo == TRUE:\n"); print(q(segmentos[["nchar"]][segmentos[["es_articulo"]]]))
cat("segmentos con más de 2000 caracteres:", sum(segmentos[["nchar"]] > 2000), "\n")
cat("segmentos con más de 4000 caracteres:", sum(segmentos[["nchar"]] > 4000), "\n")
cat("segmentos con menos de 100 caracteres:", sum(segmentos[["nchar"]] < 100), "\n")

# ---- 4. Vocabulario léxico --------------------------------------------------
cab("4. Vocabulario léxico del corpus")
plano <- tolower(stri_trans_general(texto_total, "Latin-ASCII"))
tokens <- str_extract_all(plano, "[a-z]{3,}")[[1]]
cat("tokens alfabéticos de 3+ letras:", length(tokens), "\n")
cat("tipos (palabras distintas):", length(unique(tokens)), "\n")
numeros_ley <- unique(str_extract_all(plano, "ley\\s+n?[°º]?\\s*[0-9]{1,2}[.]?[0-9]{3}")[[1]])
cat("formas distintas de cita 'ley N° x.xxx' en el texto:", length(numeros_ley), "\n")
cat("segmentos cuyo texto contiene al menos una cita 'ley ... 2x.xxx':",
    sum(vapply(unlist(lapply(normas, function(n)
      vapply(n[["articulos"]], function(a) a[["texto"]], character(1)))),
      function(t) str_detect(tolower(t), "ley\\s+n?[°º]?\\s*[0-9]{1,2}[.]?[0-9]{3}"), logical(1))), "\n")

# ---- 5. Relaciones ----------------------------------------------------------
cab("5. Relaciones")
rel_json <- jsonlite::fromJSON(file.path(ruta_datos, "relaciones.json"), simplifyDataFrame = FALSE)
rel <- rel_json[["relaciones"]]
cat("relaciones totales:", length(rel), "\n")
print(table(vapply(rel, function(r) r[["tipo"]], character(1))))
cat("descartadas registradas:", length(rel_json[["descartadas"]]), "\n")

# ---- 6. Vigencia y temporalidad --------------------------------------------
cab("6. Campos que sostendrían la dimensión temporal")
por_norma <- segmentos |> distinct(slug, tipo, origen, anio, vigencia)
cat("normas con anio nulo:", sum(is.na(por_norma[["anio"]])), "->",
    paste(por_norma[["slug"]][is.na(por_norma[["anio"]])], collapse = ", "), "\n")
cat("normas por estado de vigencia:\n"); print(table(por_norma[["vigencia"]]))
cat("distribución de anio:\n"); print(table(por_norma[["anio"]], useNA = "ifany"))
campos_vig <- unique(unlist(lapply(normas, function(n) names(n[["vigencia"]]))))
cat("claves presentes en el objeto vigencia de alguna norma:", paste(campos_vig, collapse = ", "), "\n")
campos_norma <- unique(unlist(lapply(normas, names)))
cat("¿existe algún campo de fecha de entrada en vigor o derogación? claves de norma que contienen 'fecha' o 'vigor' o 'derog':",
    paste(grep("fecha|vigor|derog", campos_norma, value = TRUE), collapse = ", "), "(vacío = ninguna)\n")

# ---- 7. Un mismo artículo en varias normas ---------------------------------
cab("7. Ids de artículo que existen en más de una ley (versiones múltiples del mismo texto)")
arts_ley <- segmentos |> filter(tipo == "ley", es_articulo)
repetidos <- arts_ley |> count(id, name = "n_leyes") |> filter(n_leyes > 1) |> arrange(desc(n_leyes))
cat("ids de artículo presentes en 2+ leyes:", nrow(repetidos), "\n")
cat("ejemplo art-16-b, en qué leyes y con qué inicio de texto:\n")
for (n in normas) {
  if (!identical(n[["tipo"]], "ley")) next
  for (a in n[["articulos"]]) {
    if (identical(a[["id"]], "art-16-b")) {
      cat(sprintf("  %s (anio %s, vigencia %s): %s...\n", n[["slug"]],
                  if (is.null(n[["anio"]])) "NA" else n[["anio"]],
                  n[["vigencia"]][["estado"]],
                  substr(gsub("\\s+", " ", a[["texto"]]), 1, 140)))
    }
  }
}
cat("¿el texto de ley_20370 (LGE) contiene 'convivencia educativa' (término de la ley 21.809)?",
    any(vapply(normas[["ley_20370_general_educacion"]][["articulos"]], function(a)
      str_detect(tolower(a[["texto"]]), "convivencia educativa"), logical(1))), "\n")
cat("¿el texto de ley_21809 contiene 'convivencia educativa'?",
    any(vapply(normas[["ley_21809_convivencia_educativa"]][["articulos"]], function(a)
      str_detect(tolower(a[["texto"]]), "convivencia educativa"), logical(1))), "\n")
cat("segmentos de ley_21809 que mencionan 'ley N° 20.370' o 'Ley General de Educación':",
    sum(vapply(normas[["ley_21809_convivencia_educativa"]][["articulos"]], function(a)
      str_detect(tolower(a[["texto"]]), "20[.]370|ley general de educaci"), logical(1))), "\n")

# ---- 8. tipo_fuente: cuántos valores distintos -----------------------------
cab("8. tipo_fuente en los datos (insumo de la 'separación en cuatro niveles')")
print(table(vapply(normas, function(n) n[["tipo_fuente"]], character(1))))
print(table(vapply(normas, function(n) n[["tipo"]], character(1))))

# ---- 9. Piezas --------------------------------------------------------------
cab("9. Piezas interpretativas")
piezas <- fs::dir_ls(here::here("20_insumos", "curaduria", "piezas"), glob = "*.md", recurse = TRUE)
piezas <- piezas[!tolower(basename(piezas)) %in% c("readme.md", "leeme.md")]
estados <- vapply(piezas, function(p) {
  l <- readLines(p, warn = FALSE)
  e <- grep("^estado:", l, value = TRUE)[1]
  trimws(sub("^estado:", "", e))
}, character(1))
cat("piezas:", length(piezas), "\n"); print(table(estados))
firmas <- vapply(piezas, function(p) {
  l <- readLines(p, warn = FALSE)
  v <- grep("^validado_por:", l, value = TRUE)[1]
  trimws(sub("^validado_por:", "", v))
}, character(1))
print(table(firmas))

# ---- 10. Cálculo (no medición) del índice vectorial ------------------------
cab("10. Cálculo del peso de un índice vectorial (aritmética declarada, no medición)")
n_u <- nrow(segmentos)
for (d in c(384L, 768L, 1024L)) {
  cat(sprintf("  %d unidades x %d dims: float32 = %.2f MB; int8 = %.2f MB\n",
              n_u, d, n_u * d * 4 / 1e6, n_u * d / 1e6))
}
cat("bytes del bundle Pagefind existente (index+fragment+filter, du -sb):\n")
pf <- here::here("40_salidas", "sitio", "pagefind")
for (sub in c("index", "fragment", "filter")) {
  cat(sprintf("  %s: %d bytes\n", sub, sum(file.size(fs::dir_ls(file.path(pf, sub))))))
}
