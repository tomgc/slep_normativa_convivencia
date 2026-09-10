#!/usr/bin/env Rscript
# aud_cobertura_instrumento.R — cuanto de los 5 documentos de la fase 1 queda
# FUERA del alcance del procedimiento automatico (limitacion medida, no supuesta).
suppressPackageStartupMessages({library(stringr); library(dplyr); library(purrr); library(tibble); library(here)})
RAIZ <- here::here()
plegar <- function(x) tolower(stringi::stri_trans_general(x, "Latin-ASCII"))
docs <- c(A1 = "20260904_alcance_capa1_vocabulario_v1.md",
          A2 = "20260904_alcance_capa2_semantica_v1.md",
          A3 = "20260904_alcance_capa3_orientacion_v1.md",
          A4 = "20260904_alcance_arquitectura_cloudflare_v1.md",
          A5 = "20260904_panel_adversarial_motor_v1.md")
CATALOGO <- c("normas","norma","articulos","articulo","segmentos","unidades","segmento",
              "relaciones","relacion","aristas","paginas html","paginas del sitio","paginas",
              "paginas tematicas","temas","piezas","borradores")
res <- purrr::map_dfr(names(docs), function(k) {
  p <- file.path(RAIZ, "50_documentacion", "andamios", docs[[k]])
  txt <- readLines(p, warn = FALSE, encoding = "UTF-8")
  cerca <- stringr::str_detect(txt, "^\\s*```"); en <- (cumsum(cerca) %% 2 == 1) | cerca
  prosa <- plegar(txt[!en]); todo <- paste(plegar(txt), collapse = "\n")
  # anclas completas vs. abreviadas
  completas <- unlist(stringr::str_extract_all(todo, "[a-z0-9_.\\-]+\\.html#[a-z0-9_\\-]+"))
  abrev <- unlist(stringr::str_extract_all(todo, "(?<!html)#(art|num|ocr|preambulo|materia|documento|fuentes|concordancias)[a-z0-9_\\-]*"))
  # afirmaciones numero + sustantivo en prosa
  pares <- unlist(stringr::str_extract_all(paste(prosa, collapse = "\n"), "[0-9]+\\s+[a-zaeiou][a-z]{3,}"))
  sust <- stringr::str_squish(stringr::str_remove(pares, "^[0-9]+\\s+"))
  dentro <- sum(sust %in% CATALOGO)
  tibble::tibble(doc = k, lineas = length(txt),
                 anclas_completas = length(completas), anclas_completas_unicas = length(unique(completas)),
                 anclas_abreviadas = length(abrev),
                 pares_num_sust = length(pares), cubiertos_por_catalogo = dentro,
                 fuera_del_catalogo = length(pares) - dentro)
})
print(as.data.frame(res), right = TRUE)
cat("\nTOTALES: anclas completas =", sum(res[["anclas_completas"]]),
    "| anclas abreviadas (fuera del chequeo C2) =", sum(res[["anclas_abreviadas"]]),
    "\n         pares numero+sustantivo en prosa =", sum(res[["pares_num_sust"]]),
    "| cubiertos por el catalogo de C1 =", sum(res[["cubiertos_por_catalogo"]]),
    "| fuera =", sum(res[["fuera_del_catalogo"]]),
    sprintf(" (%.1f%%)", 100 * sum(res[["fuera_del_catalogo"]]) / sum(res[["pares_num_sust"]])), "\n")
cat("\nLECTURA: el procedimiento automatico es un cedazo, no una cobertura.",
    "\nLo que queda fuera lo tiene que re-derivar a mano otra dimension de la auditoria.\n")
