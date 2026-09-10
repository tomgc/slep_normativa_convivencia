# =============================================================================
# a5_rotulos.R  (laboratorio del encargo v9, agente A5: panel adversarial)
# -----------------------------------------------------------------------------
# Tarea 2: ¿qué marca de procedencia viaja con el texto y cuál se queda en el
# CSS? Mide sobre el sitio generado local (40_salidas/sitio/*.html, solo lectura):
#   - encabezados con id dentro del cuerpo indexado por Pagefind, por clase
#     (artículo verificado / página OCR / sección de dictamen),
#   - si el texto de un bloque OCR lleva algún rótulo DENTRO del propio texto
#     (lo que sobrevive a copiar y pegar) o solo en atributos y CSS,
#   - qué clases badge-* existen en el CSS y cuáles se usan de verdad en el HTML.
# Control positivo: un marcador que SÍ está en el texto (la palabra "Página" del
# encabezado h2) tiene que contarse; si el instrumento no lo cuenta, el cero de
# "rótulos dentro del texto" no vale.
# =============================================================================

suppressPackageStartupMessages({ library(stringr); library(purrr); library(dplyr); library(tibble); library(here) })

sitio <- here::here("40_salidas", "sitio")
htmls <- fs::dir_ls(sitio, glob = "*.html")
cat("páginas HTML en el sitio local:", length(htmls), "\n")

leer <- function(f) paste(readLines(f, warn = FALSE), collapse = "\n")
paginas <- set_names(map(htmls, leer), basename(htmls))

# ---- 1. Encabezados con id dentro de data-pagefind-body --------------------
cat("\n==== 1. Encabezados <h2 id=...> por clase (son los sub-resultados de Pagefind) ====\n")
h2 <- map_dfr(names(paginas), function(p) {
  ids <- str_match_all(paginas[[p]], '<h2 id="([^"]+)" class="anchored">([^<]*)</h2>')[[1]]
  if (nrow(ids) == 0) return(NULL)
  tibble(pagina = p, id = ids[, 2], texto = ids[, 3])
}) |>
  mutate(clase = case_when(
    str_starts(id, "ocr-pagina-") ~ "pagina_ocr",
    str_starts(id, "art-")        ~ "articulo",
    id %in% c("relacionadas", "leyes", "reglamento", "actos", "dictamenes") ~ "navegacion",
    TRUE                          ~ "seccion_sin_articulado"))
print(h2 |> count(clase) |> as.data.frame())
cat("normas (páginas) con al menos un encabezado pagina_ocr:",
    n_distinct(h2[["pagina"]][h2[["clase"]] == "pagina_ocr"]), "\n")

# ---- 2. ¿Qué rótulo viaja DENTRO del texto de un bloque OCR? ---------------
cat("\n==== 2. Rótulo dentro del texto de los bloques OCR (lo que sobrevive a copiar y pegar) ====\n")
bloques_ocr <- map_dfr(names(paginas), function(p) {
  m <- str_match_all(paginas[[p]], '<div class="transcripcion-ocr" id="cuerpo-([^"]+)">\\s*<pre>([\\s\\S]*?)</pre>')[[1]]
  if (nrow(m) == 0) return(NULL)
  tibble(pagina = p, id = m[, 2], texto = m[, 3])
})
cat("bloques <pre> de transcripción OCR:", nrow(bloques_ocr), "\n")
marcas <- c("OCR", "transcripci", "sin revisar", "no es una cita", "en revisión")
con_marca <- vapply(bloques_ocr[["texto"]], function(t) any(str_detect(t, regex(marcas, ignore_case = TRUE))), logical(1))
cat("bloques OCR cuyo texto <pre> contiene alguna de las marcas", paste(marcas, collapse = " | "), ":",
    sum(con_marca), "de", nrow(bloques_ocr), "\n")
# Control positivo del detector: el AVISO (fuera del <pre>) sí contiene esas marcas.
avisos <- map_int(names(paginas), function(p)
  sum(str_detect(str_match_all(paginas[[p]], '<div class="aviso aviso-ocr"[^>]*>([\\s\\S]*?)</div>')[[1]][, 2],
                 regex(paste(marcas, collapse = "|"), ignore_case = TRUE))))
cat("CONTROL POSITIVO: avisos aviso-ocr (fuera del <pre>) en los que el mismo detector encuentra la marca:",
    sum(avisos), "(esperado: 5, uno por documento OCR)\n")

# ---- 3. Artículos verificados: ¿el texto lleva el nombre de la norma? -----
cat("\n==== 3. Artículos verificados: ¿el cuerpo del artículo nombra su propia ley? ====\n")
bloques_art <- map_dfr(names(paginas), function(p) {
  m <- str_match_all(paginas[[p]], '<div class="articulo texto-legal" id="cuerpo-([^"]+)">([\\s\\S]*?)</div>')[[1]]
  if (nrow(m) == 0) return(NULL)
  tibble(pagina = p, id = m[, 2], texto = m[, 3])
})
cat("bloques de artículo verificado:", nrow(bloques_art), "\n")
# El nombre corto de la norma sale del <title>; si el cuerpo no lo contiene, un
# artículo copiado no dice de qué ley es.
titulos <- map_chr(names(paginas), function(p) {
  t <- str_match(paginas[[p]], "<title>([^<]*)</title>")[, 2]
  if (is.na(t)) "" else str_replace(t, ":.*$", "")
})
names(titulos) <- names(paginas)
nombra <- map2_lgl(bloques_art[["texto"]], bloques_art[["pagina"]], function(t, p)
  nzchar(titulos[[p]]) && str_detect(t, fixed(titulos[[p]])))
cat("artículos cuyo cuerpo contiene el nombre corto de su norma (p. ej. 'Ley 20.536'):",
    sum(nombra), "de", nrow(bloques_art), sprintf("(%.1f%%)", 100 * mean(nombra)), "\n")
cat("CONTROL POSITIVO: artículos cuyo cuerpo contiene la palabra 'Artículo' (debe ser casi todos):",
    sum(str_detect(bloques_art[["texto"]], "Art[íi]culo")), "de", nrow(bloques_art), "\n")

# ---- 4. Clases badge-* en CSS vs uso real en HTML --------------------------
cat("\n==== 4. Insignias: declaradas en estilo.css vs usadas en el HTML ====\n")
css <- leer(here::here("30_procesamiento", "34_plantillas_sitio", "estilo.css"))
badges_css <- unique(str_match_all(css, "\\.(badge-[a-z_-]+)")[[1]][, 2])
uso <- map_int(badges_css, function(b) sum(map_int(paginas, function(h) str_count(h, fixed(paste0('"', b)) ) + str_count(h, fixed(paste0(' ', b, '"'))) + str_count(h, fixed(paste0(' ', b, ' '))))))
print(tibble(badge = badges_css, apariciones_html = uso) |> as.data.frame())

# ---- 5. Rótulo de pieza publicada: dónde vive respecto del cuerpo indexado --
cat("\n==== 5. Generador: posición del rótulo de pieza respecto de data-pagefind-body ====\n")
gen <- readLines(here::here("30_procesamiento", "34_generar_paginas.R"), warn = FALSE)
l_badge <- grep("badge-interpretacion", gen)
l_body  <- grep('data-pagefind-meta="pieza:', gen)
cat("línea del badge de interpretación en pagina_pieza():", l_badge, "\n")
cat("línea de apertura del cuerpo indexado de la pieza:", l_body, "\n")
cat("¿el badge se emite ANTES de abrir el cuerpo indexado (es decir, fuera de él)?", all(l_badge < l_body), "\n")
cat("¿pagina_pieza() inserta algún rótulo DENTRO del cuerpo (entre la apertura y ':::')?\n")
ini <- l_body[1]; fin <- ini + which(grepl('^\\s*":::",', gen[ini:length(gen)]))[1] - 1
cat("  bloque líneas", ini, "a", fin, ": líneas que mencionan validad/interpretaci/rótulo:",
    sum(grepl("validad|interpretaci|rotul", gen[ini:fin])), "\n")
cat("  contenido literal del bloque:\n"); cat(paste0("    ", gen[ini:fin]), sep = "\n")

# ---- 6. Compuerta: qué comprueba de la firma -------------------------------
cat("\n==== 6. Compuerta de firma: qué verifica es_nombre_de_persona() ====\n")
i <- grep("^es_nombre_de_persona <- function", gen)
cat(paste0("  ", gen[i:(i + 6)]), sep = "\n")
cat("¿la compuerta consulta alguna lista de personas autorizadas, git blame, o una firma criptográfica? grep sobre el generador:\n")
cat("  líneas con 'autoriz|blame|gpg|firma digital|hash':", sum(grepl("autoriz|blame|gpg|firma digital|hash", gen)), "\n")
cat("CONTROL POSITIVO del grep: líneas con 'validado_por':", sum(grepl("validado_por", gen)), "\n")
