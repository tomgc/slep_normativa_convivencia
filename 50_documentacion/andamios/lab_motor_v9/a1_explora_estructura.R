suppressPackageStartupMessages({library(jsonlite); library(purrr)})
cat <- base::cat
c0 <- fromJSON(here::here("40_salidas", "datos", "catalogo.json"), simplifyVector = FALSE)
ns <- c0[["normas"]]
cat("tipo_fuente:\n"); print(table(map_chr(ns, function(n) n[["tipo_fuente"]])))
cat("grupo_acto no nulo:\n")
for (n in ns) if (!is.null(n[["grupo_acto"]])) { cat(n[["slug"]], ":\n"); str(n[["grupo_acto"]]) }
cat("etiquetas de segmentos no art-:\n")
dir <- here::here("40_salidas", "datos", "normas")
for (f in list.files(dir, full.names = TRUE)) {
  d <- fromJSON(f, simplifyVector = FALSE)
  for (a in d[["articulos"]]) if (!grepl("^art-", a[["id"]]) && !grepl("^ocr-pagina-0(0[2-9]|[1-9][0-9])", a[["id"]]))
    cat(sprintf("  %-45s %-16s %s\n", d[["slug"]], a[["id"]], a[["etiqueta"]]))
}
cat("muestra de etiquetas art-:\n")
d <- fromJSON(file.path(dir, "ley_21430_garantias_ninez.json"), simplifyVector = FALSE)
for (a in d[["articulos"]][c(2, 3, 50, 94)]) cat(sprintf("  %-16s %s | es_articulo=%s\n", a[["id"]], a[["etiqueta"]], a[["es_articulo"]]))
cat("campos catalogo norma:\n"); print(names(ns[[1]]))
cat("aviso_vigencia no nulo:\n"); for (n in ns) if (!is.null(n[["aviso_vigencia"]])) cat(n[["slug"]], "\n")
cat("vigencia por norma:\n"); for (n in ns) cat(sprintf("  %-45s %s | sust_por=%s | sust_a=%s\n", n[["slug"]], n[["vigencia"]][["estado"]],
  if (is.null(n[["vigencia"]][["sustituido_por"]])) "-" else n[["vigencia"]][["sustituido_por"]],
  paste(unlist(n[["vigencia"]][["sustituye_a"]]), collapse = ",")))
