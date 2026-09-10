# =============================================================================
# a5_contraste3.R  (laboratorio del encargo v9, agente A5: fase 2, contraste)
# -----------------------------------------------------------------------------
# Tercera tanda: (1) la cota superior de A2 (variante `canonico`) contra el
# vocabulario REAL de A1, que es quien tendria que producir esa expansion;
# (2) medicion corregida del rotulo dentro del cuerpo (H-1), con su control;
# (3) rotulos en el JSON de A1. Solo lee; escribe solo archivos a5_*.
# [[ ]] exacto sobre datos de disco.
# =============================================================================
suppressPackageStartupMessages({
  library(jsonlite); library(dplyr); library(purrr); library(stringr)
  library(stringi); library(tibble); library(readr); library(here); library(fs)
})
options(warnPartialMatchDollar = TRUE)
LAB <- here::here("50_documentacion", "andamios", "lab_motor_v9")
cab <- function(x) cat("\n==== ", x, " ====\n", sep = "")
pl  <- function(x) tolower(stringi::stri_trans_general(x, "Latin-ASCII"))

source(file.path(LAB, "a3_cargar_defs.R"))
cargar_entorno_pipeline()
normas <- leer_normas()

seg <- map_dfr(normas, function(n) tibble(
  slug = n[["slug"]], numero = if (is.null(n[["numero"]])) NA_character_ else as.character(n[["numero"]]),
  id = vapply(n[["articulos"]], function(a) a[["id"]], character(1)),
  es_articulo = vapply(n[["articulos"]], function(a) isTRUE(a[["es_articulo"]]), logical(1)),
  texto = vapply(n[["articulos"]], function(a) a[["texto"]], character(1))))
seg <- seg |> mutate(clase = case_when(str_starts(id, "ocr-pagina-") ~ "pagina_ocr",
                                       es_articulo ~ "articulo", TRUE ~ "seccion_firmada"))

# ---- Resolutor real de A1 (mismo montaje verificado en a5_contraste2.R) -----
d1 <- cargar_defs_de(here::here("50_documentacion", "andamios", "20260904_prototipo_vocabulario.R"),
                     constantes = c("STOP_CONSULTA", "REGLA_PREFIJO", "PESOS"))
a1 <- d1[["env"]]
voc <- jsonlite::fromJSON(file.path(LAB, "vocabulario.json"), simplifyDataFrame = FALSE)
ent <- voc[["entradas"]]; names(ent) <- vapply(ent, function(x) x[["id"]], character(1))
assign("entradas", ent, envir = a1)
local({
  tokenizar <- a1[["tokenizar"]]
  cp <- lapply(ent, function(x) unique(unlist(lapply(c(x[["termino"]], x[["alias"]]), tokenizar))))
  cl <- cp
  for (id in names(ent)) { x <- ent[[id]]
    if (identical(x[["tipo"]], "articulo")) cl[[id]] <- unique(c(cl[[id]], cp[[paste0("norma:", x[["norma"]])]])) }
  assign("claves_propias", cp, envir = a1); assign("claves", cl, envir = a1)
  assign("primer_token", vapply(ent, function(x) { t <- tokenizar(x[["termino"]]); if (length(t)) t[1] else "" }, character(1)), envir = a1)
  assign("tipo_de", vapply(ent, function(x) x[["tipo"]], character(1)), envir = a1)
  assign("peso_de", vapply(ent, function(x) x[["peso"]], numeric(1)), envir = a1)
  assign("citable_de", vapply(ent, function(x) isTRUE(x[["citable"]]), logical(1)), envir = a1)
  assign("sustituida_de", vapply(ent, function(x) identical(x[["vigencia"]][["estado"]], "sustituido"), logical(1)), envir = a1)
  assign("largo_de", vapply(ent, function(x) nchar(x[["termino"]]), integer(1)), envir = a1)
})
sugerir <- a1[["sugerir"]]
stopifnot(nrow(sugerir("celu")) == 3L, nrow(sugerir("xyzzy")) == 0L)   # control de fidelidad

cab("C1. La cota superior de A2 (variante `canonico`) contra el vocabulario REAL de A1")
cat("A2 §6.3 declara: la variante `canonico` es 'el termino con que la NORMA nombra el asunto\n",
    "(mapeo manual de A2; no se leyo el vocabulario de A1)'. Aqui se prueba si el vocabulario\n",
    "de A1, que es quien tendria que producir esa expansion en produccion, lleva de la consulta\n",
    "del equipo a la pagina de la norma esperada.\n", sep = "")
ev <- read_csv(file.path(LAB, "a2_consultas_evaluacion.csv"), show_col_types = FALSE)
pagina_de <- function(a) str_match(a, "^([^#]+)#")[, 2]
paginas_aceptadas <- function(i) {
  aa <- c(ev[["ancla_esperada"]][i], unlist(str_split(ev[["anclas_aceptadas"]][i], ";")))
  aa <- str_trim(aa[nzchar(str_trim(aa))])
  unique(pagina_de(aa))
}
evalua <- function(i, modo) {
  r <- sugerir(ev[["consulta"]][i], modo = modo)
  if (nrow(r) == 0) return(list(n = 0L, acierta = FALSE, top1 = "", rango = NA_integer_))
  dest <- ifelse(is.na(r[["destino_canonico"]]), "", r[["destino_canonico"]])
  pag <- str_replace(dest, "#.*$", "")
  ok <- pag %in% paginas_aceptadas(i)
  list(n = nrow(r), acierta = any(ok), top1 = paste0(r[["tipo"]][1], ": ", r[["termino"]][1]),
       rango = if (any(ok)) which(ok)[1] else NA_integer_)
}
tab <- map_dfr(seq_len(nrow(ev)), function(i) {
  a <- evalua(i, "todos"); o <- evalua(i, "alguno")
  tibble(id = ev[["id"]][i], consulta = ev[["consulta"]][i],
         pagina_esperada = paste(paginas_aceptadas(i), collapse = " | "),
         and_n = a[["n"]], and_acierta = a[["acierta"]],
         or_n = o[["n"]], or_acierta = o[["acierta"]], or_rango = o[["rango"]], or_top1 = o[["top1"]])
})
print(tab |> select(id, consulta, and_n, and_acierta, or_n, or_acierta, or_rango) |> as.data.frame(), row.names = FALSE)
cat("\ntop1 en modo OR por consulta:\n")
for (i in seq_len(nrow(tab))) cat(sprintf("  %s  %-45s -> %s\n", tab[["id"]][i], str_trunc(tab[["consulta"]][i], 45), tab[["or_top1"]][i]))
cat(sprintf("\nCon el CONTRATO de A1 (AND): %d de 10 consultas de A2 llegan a una pagina aceptada; %d devuelven 0 sugerencias.\n",
            sum(tab[["and_acierta"]]), sum(tab[["and_n"]] == 0)))
cat(sprintf("Con OR (que A1 mide y NO recomienda): %d de 10 llegan a una pagina aceptada.\n", sum(tab[["or_acierta"]])))
cat("Referencia: A2 §6.5 reporta con `canonico` 9 de 10 paginas en el top 3 (mapeo manual de A2).\n")
cat("CONTROL POSITIVO del evaluador: consulta plantada 'mochila' -> paginas sugeridas: ",
    paste(str_replace(ifelse(is.na(sugerir("mochila")[["destino_canonico"]]), "", sugerir("mochila")[["destino_canonico"]]), "#.*$", ""), collapse = ", "),
    "; ¿incluye la pagina esperada de C01 (", paginas_aceptadas(1)[1], ")? ",
    any(str_replace(ifelse(is.na(sugerir("mochila")[["destino_canonico"]]), "", sugerir("mochila")[["destino_canonico"]]), "#.*$", "") %in% paginas_aceptadas(1)), "\n", sep = "")
cat("CONTROL NEGATIVO del evaluador: consulta 'xyzzy' -> acierta alguna pagina de C01: ",
    { r <- sugerir("xyzzy"); nrow(r) > 0 }, "\n", sep = "")
write_csv(tab, file.path(LAB, "a5_contraste_a2_consultas_vs_vocabulario_a1.csv"))

cab("C2. H-1 corregido: la identidad de la norma dentro del cuerpo del segmento")
# La medicion de la fase 1 ('0 de 722 cuerpos nombran su norma') se rehace con un
# detector calibrado: el numero de la norma tal como el corpus lo escribe.
con_numero <- normas[map_lgl(normas, function(n) !is.null(n[["numero"]]) && nchar(as.character(n[["numero"]])) >= 4)]
cat("normas cuyo `numero` tiene 4 o mas caracteres (unico universo donde el detector no es ambiguo):",
    length(con_numero), "->", paste(names(con_numero), collapse = ", "), "\n")
# El catalogo guarda el numero sin punto de miles ("21801") y el corpus lo escribe
# con punto ("21.801"): el patron se deriva del dato, no se escribe a mano.
pat_num <- function(num) paste0(substr(num, 1, nchar(num) - 3), "\\.?", substr(num, nchar(num) - 2, nchar(num)))
firmados <- seg |> filter(clase != "pagina_ocr", slug %in% names(con_numero))
tiene_num <- map2_lgl(firmados[["texto"]], firmados[["numero"]], function(t, num) str_detect(t, pat_num(num)))
cat("segmentos firmados de esas normas:", nrow(firmados),
    "| cuyo texto contiene el numero de su PROPIA norma:", sum(tiene_num),
    sprintf("(%.1f%%)", 100 * mean(tiene_num)), "\n")
cat("CONTROL POSITIVO del detector (el numero SI aparece en el corpus, en otras normas):\n")
for (s in c("ley_21801_celulares", "ley_20370_general_educacion", "ley_20536_violencia_escolar")) {
  num <- as.character(normas[[s]][["numero"]]); p <- pat_num(num)
  cat(sprintf("   numero %s (patron %s, norma %s): en segmentos de la propia norma %d | en segmentos de OTRAS normas %d\n", num, p, s,
              sum(str_detect(seg[["texto"]][seg[["slug"]] == s], p)),
              sum(str_detect(seg[["texto"]][seg[["slug"]] != s], p))))
}
cat("CONTROL NEGATIVO: numero inventado (patron", pat_num("99999"), ") en todo el corpus:",
    sum(str_detect(seg[["texto"]], pat_num("99999"))), "segmentos\n")
cat("Lectura: el cuerpo del segmento no lleva la identidad de su norma salvo cuando el propio\n",
    "texto se autocita; el resto de las veces la identidad vive en el encabezado de la pagina.\n", sep = "")

cab("C3. Que rotulo lleva el JSON de A1 (H-1 en la capa 1)")
rot <- map_chr(ent, function(x) if (is.null(x[["rotulo"]])) "" else x[["rotulo"]])
tipo <- map_chr(ent, function(x) x[["tipo"]])
cat("entradas con rotulo no vacio:", sum(nzchar(rot)), "de", length(ent), "\n")
print(tibble(tipo = tipo, con_rotulo = nzchar(rot)) |> count(tipo, con_rotulo) |> as.data.frame(), row.names = FALSE)
cat("ejemplos de rotulo (2):\n"); for (r in head(unique(rot[nzchar(rot)]), 2)) cat("   ", str_trunc(r, 130), "\n")
cat("entradas de tipo articulo (806) con rotulo:", sum(nzchar(rot) & tipo == "articulo"), "\n")
cat("CONTROL: entradas con citable = FALSE:", sum(!map_lgl(ent, function(x) isTRUE(x[["citable"]]))), "\n")

cat("\n==== FIN ====\n")
