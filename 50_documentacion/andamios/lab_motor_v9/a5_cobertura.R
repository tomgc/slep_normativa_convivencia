# =============================================================================
# a5_cobertura.R  (laboratorio del encargo v9, agente A5: panel adversarial)
# -----------------------------------------------------------------------------
# Tarea 3: ¿qué fracción de las consultas plausibles del equipo NO cubre un
# vocabulario derivado del corpus? Las consultas son CONSTRUIDAS por A5 a partir
# de la pauta de validación, las FAQ en borrador y la tabla de temas frágiles
# (a5_consultas_equipo.csv). No son dato de uso: no existe registro de consultas.
#
# Medición, por consulta y por término de contenido (sin palabras vacías):
#   V  el término aparece literalmente en el VOCABULARIO de la capa 1 tal como lo
#      define el encargo (títulos de páginas temáticas, términos del glosario,
#      etiquetas de artículo, nombres y títulos de norma);
#   C  el término aparece literalmente en el TEXTO COMPLETO del corpus (cota
#      superior: aunque A1 metiera cada palabra del corpus al vocabulario);
#   P  el término aparece como PREFIJO de palabra en el corpus (tolera flexión:
#      "revisar" ~ "revisión" no, pero "expuls" ~ "expulsión"/"expulsar" sí).
# Todo plegado a ASCII y minúsculas, con borde de palabra.
#
# Controles en el mismo bloque: una consulta en lenguaje legal (debe dar
# cobertura alta), una consulta inexistente (debe dar 0) y un término conocido
# ("mochila") que el instrumento DEBE encontrar, o el cero no vale.
# =============================================================================

suppressPackageStartupMessages({
  library(jsonlite); library(dplyr); library(purrr); library(stringr)
  library(stringi); library(tibble); library(readr); library(here)
})
options(warnPartialMatchDollar = TRUE)
lab <- here::here("50_documentacion", "andamios", "lab_motor_v9")

plano <- function(x) tolower(stri_trans_general(x, "Latin-ASCII"))

# ---- Corpus -----------------------------------------------------------------
ruta_datos <- here::here("40_salidas", "datos")
cat_json <- jsonlite::fromJSON(file.path(ruta_datos, "catalogo.json"), simplifyDataFrame = FALSE)
slugs <- vapply(cat_json[["normas"]], function(x) x[["slug"]], character(1))
normas <- lapply(slugs, function(s)
  jsonlite::fromJSON(file.path(ruta_datos, "normas", paste0(s, ".json")), simplifyDataFrame = FALSE))
texto_corpus <- plano(paste(unlist(lapply(normas, function(n)
  vapply(n[["articulos"]], function(a) a[["texto"]], character(1)))), collapse = "\n"))

# ---- Vocabulario de la capa 1, tal como lo define la tarea 1 de A1 ---------
temas     <- sort(unique(unlist(lapply(normas, function(n) n[["tema"]]))))
etiquetas <- unique(unlist(lapply(normas, function(n)
  vapply(n[["articulos"]], function(a) a[["etiqueta"]], character(1)))))
nombres   <- unlist(lapply(normas, function(n) c(n[["tipo_etiqueta"]], n[["numero"]], n[["titulo"]])))
glos <- readLines(here::here("20_insumos", "curaduria", "piezas", "borradores", "glosario.md"), warn = FALSE)
glosario  <- str_trim(sub("^### ", "", grep("^### ", glos, value = TRUE)))
pend <- grep("^\\| [a-záéíóúñ ]+ \\|", glos, value = TRUE)
pendientes <- str_trim(str_match(pend, "^\\| ([^|]+) \\|")[, 2])
pendientes <- pendientes[!is.na(pendientes) & !pendientes %in% c("Término")]
vocab_a1 <- plano(paste(c(temas, etiquetas, nombres[!is.na(nombres)], glosario), collapse = "\n"))
vocab_ext <- plano(paste(c(vocab_a1, pendientes), collapse = "\n"))   # + pendientes de fuente del glosario
cat("Vocabulario capa 1 (definición de la tarea 1 de A1):\n")
cat("  páginas temáticas:", length(temas), "\n")
cat("  etiquetas de artículo distintas:", length(etiquetas), "\n")
cat("  entradas del glosario (### ):", length(glosario), "\n")
cat("  términos 'pendientes de fuente' del glosario:", length(pendientes), "->", paste(pendientes, collapse = "; "), "\n")
cat("  tipos alfabéticos distintos en el vocabulario A1:",
    length(unique(str_extract_all(vocab_a1, "[a-z]{3,}")[[1]])), "\n")
cat("  tipos alfabéticos distintos en el corpus:",
    length(unique(str_extract_all(texto_corpus, "[a-z]{3,}")[[1]])), "\n")

# ---- Consultas --------------------------------------------------------------
consultas <- read_csv(file.path(lab, "a5_consultas_equipo.csv"), show_col_types = FALSE)
cat("\nconsultas construidas:", nrow(consultas), "\n")

# Palabras vacías: lista corta declarada a mano (son funcionales, no dependen de
# locale). Se dejan fuera del recuento porque cubrirlas no informa nada.
vacias <- c("a","al","ante","con","de","del","el","en","es","la","las","lo","los","o","para",
            "por","que","qué","se","si","sin","su","sus","un","una","uno","y","e","le","les",
            "un","como","cómo","hay","tiene","tener","ser","puede","pueden","quién","quien",
            "cuánto","cuanto","cuál","cual","hacer","debe","antes","dentro","entre","mi","ni",
            "muy","más","mas","ya","the","pie")   # "pie" (PIE) se evalúa aparte, ver abajo
terminos_de <- function(q) {
  t <- str_extract_all(plano(q), "[a-z]{2,}")[[1]]
  t[!t %in% plano(vacias)]
}
hit_exacto  <- function(term, texto) str_detect(texto, paste0("\\b", term, "\\b"))
hit_prefijo <- function(term, texto) nchar(term) >= 5 && str_detect(texto, paste0("\\b", term))

evaluar <- function(q) {
  ts <- terminos_de(q)
  tibble(
    n_terminos = length(ts),
    terminos   = paste(ts, collapse = " "),
    V_exacto   = sum(vapply(ts, hit_exacto,  logical(1), texto = vocab_a1)),
    Vx_exacto  = sum(vapply(ts, hit_exacto,  logical(1), texto = vocab_ext)),
    C_exacto   = sum(vapply(ts, hit_exacto,  logical(1), texto = texto_corpus)),
    C_prefijo  = sum(vapply(ts, function(t) hit_exacto(t, texto_corpus) || hit_prefijo(t, texto_corpus), logical(1))),
    faltan_en_corpus = paste(ts[!vapply(ts, function(t) hit_exacto(t, texto_corpus) || hit_prefijo(t, texto_corpus), logical(1))], collapse = " "),
    faltan_en_vocab  = paste(ts[!vapply(ts, hit_exacto, logical(1), texto = vocab_a1)], collapse = " ")
  )
}

res <- consultas |> mutate(ev = map(consulta, evaluar)) |> tidyr::unnest(ev) |>
  mutate(
    frac_V  = V_exacto / n_terminos,
    frac_C  = C_exacto / n_terminos,
    frac_P  = C_prefijo / n_terminos,
    cubierta_vocab_total   = V_exacto == n_terminos,
    cubierta_vocab_alguno  = V_exacto >= 1,
    cubierta_corpus_total  = C_prefijo == n_terminos,
    cubierta_corpus_alguno = C_prefijo >= 1
  )
write_csv(res, file.path(lab, "a5_cobertura_resultado.csv"))

cat("\n==== Resultado por consulta (V = vocabulario A1 exacto; C = corpus exacto; P = corpus prefijo>=5) ====\n")
print(res |> select(id, n_terminos, V_exacto, C_exacto, C_prefijo, faltan_en_corpus, faltan_en_vocab) |> as.data.frame(), row.names = FALSE)

cat("\n==== Resumen ====\n")
n <- nrow(res)
resumen <- function(etq, x) cat(sprintf("  %-70s %2d de %d (%.0f%%)\n", etq, sum(x), n, 100 * mean(x)))
resumen("consultas con TODOS sus términos en el vocabulario A1 (exacto):", res[["cubierta_vocab_total"]])
resumen("consultas con AL MENOS UN término en el vocabulario A1 (exacto):", res[["cubierta_vocab_alguno"]])
resumen("consultas con NINGÚN término en el vocabulario A1 (exacto):", !res[["cubierta_vocab_alguno"]])
resumen("consultas con TODOS sus términos en el corpus (exacto o prefijo):", res[["cubierta_corpus_total"]])
resumen("consultas con NINGÚN término en el corpus (exacto o prefijo):", !res[["cubierta_corpus_alguno"]])
cat(sprintf("  fracción media de términos cubiertos: vocab A1 %.2f | corpus exacto %.2f | corpus prefijo %.2f\n",
            mean(res[["frac_V"]]), mean(res[["frac_C"]]), mean(res[["frac_P"]])))
tot <- sum(res[["n_terminos"]])
cat(sprintf("  términos totales %d: en vocab A1 %d (%.0f%%), en corpus exacto %d (%.0f%%), en corpus prefijo %d (%.0f%%)\n",
            tot, sum(res[["V_exacto"]]), 100 * sum(res[["V_exacto"]]) / tot,
            sum(res[["C_exacto"]]), 100 * sum(res[["C_exacto"]]) / tot,
            sum(res[["C_prefijo"]]), 100 * sum(res[["C_prefijo"]]) / tot))
cat("  consultas con objetivo declarado 'fuera del corpus':", sum(str_starts(res[["objetivo_declarado"]], "fuera del corpus")), "\n")
fuera <- res |> filter(str_starts(objetivo_declarado, "fuera del corpus"))
cat(sprintf("  ...de las cuales el corpus contiene AL MENOS UN término (falso positivo léxico posible): %d de %d\n",
            sum(fuera[["cubierta_corpus_alguno"]]), nrow(fuera)))
cat("  términos que faltan en el corpus, agregados:", paste(unlist(str_split(res[["faltan_en_corpus"]][nzchar(res[["faltan_en_corpus"]])], " ")), collapse = ", "), "\n")

cat("\n==== Controles (mismo instrumento, mismo bloque) ====\n")
# Primera corrida (02:43): el control "mochila" en singular dio C_exacto = 0 y
# C_prefijo = 1, y el stopifnot abortó. No era defecto del instrumento sino del
# control: el corpus dice "mochilas" (plural) y nunca "mochila". Se recalibra con
# el plural como término conocido y se conserva el singular como medición
# declarada de la brecha singular/plural, que es un hallazgo y no un error.
ctrl <- tibble(
  id = c("ctrl_pos_legal", "ctrl_neg_inexistente", "ctrl_pos_termino_conocido", "ctrl_singular_vs_plural"),
  consulta = c("acoso escolar acción u omisión constitutiva de agresión u hostigamiento reiterado",
               "xyzzy plugh zorblat",
               "mochilas",
               "mochila")
) |> mutate(ev = map(consulta, evaluar)) |> tidyr::unnest(ev)
print(ctrl |> select(id, n_terminos, V_exacto, C_exacto, C_prefijo, faltan_en_corpus) |> as.data.frame(), row.names = FALSE)
stopifnot(ctrl[["C_exacto"]][2] == 0L, ctrl[["C_exacto"]][3] == 1L, ctrl[["C_exacto"]][1] >= 0.9 * ctrl[["n_terminos"]][1])
cat("controles OK: el positivo legal cubre >= 90%, el inexistente da 0 y 'mochilas' se encuentra.\n")
cat("brecha singular/plural: 'mochila' exacto =", ctrl[["C_exacto"]][4], "| prefijo =", ctrl[["C_prefijo"]][4], "\n")

cat("\n==== Falsos positivos por palabra suelta: la FRASE no está aunque sus palabras sí ====\n")
frase <- function(f) str_detect(texto_corpus, paste0("\\b", plano(f), "\\b"))
for (f in c("aula segura", "21.128", "hoja de vida", "dupla psicosocial", "carabineros", "drogas"))
  cat(sprintf("  '%s' como frase/palabra en el corpus: %s\n", f, frase(f)))
cat("  CONTROL POSITIVO de frase: 'revision de mochilas':", frase("revisión de mochilas"),
    "| 'interes superior del nino':", frase("interés superior del niño"), "\n")

cat("\n==== Nota sobre 'PIE' (sigla del Programa de Integración Escolar) ====\n")
cat("  ¿'pie' aparece como palabra en el corpus?", hit_exacto("pie", texto_corpus),
    "| ¿'programa de integracion' aparece?", str_detect(texto_corpus, "programa de integracion"),
    "| ¿'integracion escolar' aparece?", str_detect(texto_corpus, "integracion escolar"), "\n")
