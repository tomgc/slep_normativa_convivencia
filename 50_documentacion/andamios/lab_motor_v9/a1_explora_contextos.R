# Contextos de siglas y citas (A1). Solo lectura.
suppressPackageStartupMessages({
  library(jsonlite); library(dplyr); library(stringr); library(purrr); library(tibble)
})
dir <- here::here("40_salidas", "datos", "normas")
fs  <- list.files(dir, full.names = TRUE)
tx <- map(fs, function(f) {
  d <- fromJSON(f, simplifyVector = FALSE)
  tibble(slug = d[["slug"]],
         texto = paste(map_chr(d[["articulos"]], function(a) a[["texto"]]), collapse = "\n"))
}) |> bind_rows()
ctx <- function(p, w = 70, k = 6) {
  cat("\n---", p, "---\n")
  for (i in seq_len(nrow(tx))) {
    m <- str_locate_all(tx[["texto"]][i], p)[[1]]
    if (nrow(m) == 0) next
    for (j in seq_len(min(k, nrow(m)))) {
      a <- max(1, m[j, 1] - w); b <- min(nchar(tx[["texto"]][i]), m[j, 2] + w)
      cat(sprintf("[%s] ...%s...\n", tx[["slug"]][i],
                  str_replace_all(substr(tx[["texto"]][i], a, b), "\\s+", " ")))
    }
  }
}
ctx("\\(LGE\\)", k = 2); ctx("\\bLGE\\b", k = 2); ctx("\\(SAE\\)", k = 2); ctx("\\bRO\\b", k = 3)
ctx("\\bSEP\\b", k = 3); ctx("\\bLSAC\\b", k = 2); ctx("(?i)circular n° 482", k = 3)
ctx("(?i)ley tea", k = 2); ctx("(?i)ley de convivencia", k = 2); ctx("(?i)aula segura", k = 2)
ctx("(?i)ley de garant", k = 2); ctx("(?i)ley de inclusi", k = 3)

rel <- fromJSON(here::here("40_salidas", "datos", "relaciones.json"), simplifyVector = FALSE)
rr <- rel[["relaciones"]]
tipos <- map_chr(rr, function(r) r[["tipo"]])
rem <- map(rr[tipos == "remision"], function(r) tibble(hacia = r[["hacia"]], desde = r[["desde"]],
  cita_literal = r[["cita_literal"]], n_citas = r[["n_citas"]])) |> bind_rows()
cat("\n=== cita_literal por norma destino ===\n")
print(rem |> count(hacia, cita_literal, sort = TRUE), n = 80)
cat("\n=== grupo_acto y sustitucion ===\n")
for (r in rr[tipos %in% c("grupo_acto", "sustitucion")]) cat(r[["desde"]], "->", r[["hacia"]], "|", r[["tipo"]], "|", r[["explicacion"]], "\n")
