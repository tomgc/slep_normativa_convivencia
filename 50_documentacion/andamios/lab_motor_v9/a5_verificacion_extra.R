# a5_verificacion_extra.R (A5, encargo v9): dos comprobaciones puntuales que
# complementan a5_rotulos.R. Solo lectura sobre 40_salidas/sitio/.
suppressPackageStartupMessages({ library(stringr); library(here) })
htmls <- fs::dir_ls(here::here("40_salidas", "sitio"), glob = "*.html")
patron_bloque <- '<div class="transcripcion-ocr" id="cuerpo-([^"]+)">\\s*<pre>([\\s\\S]*?)</pre>'
palabras <- "(OCR|transcripci|sin revisar|no es una cita|en revisión)"
cat("==== (1) Bloques OCR cuyo <pre> contiene una palabra del detector: cuál y en qué contexto ====\n")
n_bloques <- 0L; n_con <- 0L
for (f in htmls) {
  h <- paste(readLines(f, warn = FALSE), collapse = "\n")
  m <- str_match_all(h, patron_bloque)[[1]]
  if (nrow(m) == 0) next
  n_bloques <- n_bloques + nrow(m)
  for (i in seq_len(nrow(m))) {
    hits <- str_extract_all(m[i, 3], regex(paste0("[^\n]{0,50}", palabras, "[^\n]{0,50}"), ignore_case = TRUE))[[1]]
    if (length(hits)) { n_con <- n_con + 1L; cat("  ", basename(f), m[i, 2], "->", paste(hits, collapse = " || "), "\n") }
  }
}
cat("bloques OCR:", n_bloques, "| con palabra del detector dentro del <pre>:", n_con, "\n")
cat("\n==== (2) ¿Qué ve un resultado de Pagefind? El h2 de la página OCR y el primer texto del <pre> ====\n")
h <- paste(readLines(here::here("40_salidas", "sitio", "circular_812_identidad_genero.html"), warn = FALSE), collapse = "\n")
m <- str_match(h, '<h2 id="(ocr-pagina-005)" class="anchored">([^<]*)</h2>\\s*<div class="transcripcion-ocr" id="cuerpo-ocr-pagina-005">\\s*<pre>([\\s\\S]{0,240})')
cat("  h2 id:", m[2], "| texto del h2:", m[3], "\n  primeros 240 caracteres del <pre>:", gsub("\\s+", " ", m[4]), "\n")
