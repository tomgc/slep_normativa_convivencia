# Exploracion de alias (A1, encargo v9). Solo lectura del repo; salida a consola.
suppressPackageStartupMessages({
  library(jsonlite); library(dplyr); library(stringr); library(purrr); library(tibble)
})
dir <- here::here("40_salidas", "datos", "normas")
fs  <- list.files(dir, full.names = TRUE)
tx <- map(fs, function(f) {
  d <- fromJSON(f, simplifyVector = FALSE)
  tibble(slug = d[["slug"]],
         titulo = if (is.null(d[["titulo"]])) NA_character_ else d[["titulo"]],
         texto = paste(map_chr(d[["articulos"]], function(a) a[["texto"]]), collapse = "\n"))
}) |> bind_rows()
cat("normas:", nrow(tx), " chars totales:", sum(nchar(tx[["texto"]])), "\n")
cat("\n=== titulos NA ===\n"); print(tx |> filter(is.na(titulo)) |> pull(slug))
cat("\n=== titulo rex_482_reglamentos_b / rex_181 ===\n")
print(tx |> filter(str_detect(slug, "rex_")) |> select(slug, titulo))

# 1. siglas en mayusculas 2-6 letras
sig <- str_extract_all(tx[["texto"]], "\\b[A-Z\u00d1]{2,6}\\b") |> unlist()
cat("\n=== siglas mayusculas (top 50) ===\n"); print(sort(table(sig), decreasing = TRUE)[1:50])

# 2. citas tipo + numero
pat <- paste0("(?i)\\b(ley|decreto con fuerza de ley|d\\.?f\\.?l\\.?|decreto supremo|decreto|",
              "circular|resoluci[o\u00f3]n(?: exenta)?|dictamen|dict[a\u00e1]menes|ord\\.?|oficio)",
              "\\s*(?:n[\u00b0\u00bao]?\\.?\\s*)?(\\d{1,3}(?:\\.\\d{3})*|\\d{1,6})")
cit <- str_extract_all(tx[["texto"]], pat) |> unlist() |> str_squish() |> str_to_lower() |>
  str_replace_all("\\s+", " ")
cat("\n=== citas tipo+numero (top 70) ===\n"); print(sort(table(cit), decreasing = TRUE)[1:70])

# 3. alias candidatos conocidos
alias <- c("aula segura", "ley de subvenciones", "ley sep", "ley tea", "ley de convivencia",
           "ley general de educaci", "lge", "jec", "jornada escolar completa", "estatuto docente",
           "estatuto de los asistentes", "asistentes de la educaci", "ley de inclusi",
           "21\\.128", "ley de garant", "circular 482", "circular n\u00b0 482", "resoluci[o\u00f3]n exenta n\u00b0 482",
           "circular 193", "circular 586", "circular 812", "circular 181", "circular n\u00b0 181",
           "dictamen n\u00b0 65", "dictamen n 65", "dictamen 65", "dictamen n\u00b0 78", "dictamen n\u00b0 52",
           "dictamen n\u00b0 77", "dictamen n\u00b0 71", "d\\.f\\.l\\. n\u00b0 2", "dfl n\u00b0 2",
           "decreto con fuerza de ley n\u00b0 2", "n\u00b0 2, de 2009", "19\\.070", "21\\.109", "20\\.529",
           "sistema de admisi", "\\bsae\\b", "reglamento interno", "cgpma", "centro general de padres",
           "consejo escolar", "encargado de convivencia", "dupla psicosocial", "protocolo de actuaci",
           "medida formativa", "debido proceso", "cancelaci[o\u00f3]n de matr", "ley miscel")
low <- str_to_lower(tx[["texto"]])
for (a in alias) {
  m <- str_count(low, a)
  cat(sprintf("%-38s total=%4d  en: %s\n", a, sum(m),
              substr(paste(tx[["slug"]][m > 0], collapse = ", "), 1, 150)))
}

# 4. citas en relaciones.json (remision)
rel <- fromJSON(here::here("40_salidas", "datos", "relaciones.json"), simplifyVector = FALSE)
cat("\n=== campos relaciones.json ===\n"); print(names(rel))
rr <- rel[["relaciones"]]
cat("n relaciones:", length(rr), "\n")
tipos <- map_chr(rr, function(r) r[["tipo"]]); print(table(tipos))
cat("campos de una remision:\n"); print(names(rr[[which(tipos == "remision")[1]]]))
rem <- map(rr[tipos == "remision"], function(r) tibble(hacia = r[["hacia"]], desde = r[["desde"]],
  cita = if (is.null(r[["cita"]])) NA_character_ else r[["cita"]],
  explicacion = substr(r[["explicacion"]], 1, 160))) |> bind_rows()
cat("\n=== citas literales por norma destino (remisiones) ===\n")
print(rem |> count(hacia, cita, sort = TRUE), n = 80)
cat("\n=== descartadas: citas por hacia ===\n")
des <- map(rel[["descartadas"]], function(r) tibble(hacia = r[["hacia"]], cita = r[["cita"]])) |> bind_rows()
print(des |> count(hacia, cita, sort = TRUE), n = 40)
