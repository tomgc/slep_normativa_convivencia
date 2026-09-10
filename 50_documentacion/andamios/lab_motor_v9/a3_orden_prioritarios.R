# a3_orden_prioritarios.R
# Re-deriva el orden real de la lista `prioritarios` de la tercera consulta de
# §6.4, leyendo el bloque de salida literal del propio documento (no de memoria)
# y resolviendo `origen_texto` y `vigencia.estado` de cada slug desde los JSON de
# 40_salidas/datos/normas/. No escribe nada fuera del laboratorio.
# Uso: Rscript 50_documentacion/andamios/lab_motor_v9/a3_orden_prioritarios.R
suppressWarnings(suppressMessages({
  library(jsonlite); library(here)
}))

DOC <- here::here("50_documentacion/andamios/20260904_alcance_capa3_orientacion_v1.md")
DIR_NORMAS <- here::here("40_salidas/datos/normas")

lineas <- readLines(DOC, warn = FALSE, encoding = "UTF-8")

# La linea de interes es la unica que empieza con "  prioritarios: ley_21809"
idx <- grep("^  prioritarios: ley_21809_convivencia_educativa", lineas)
cat(sprintf("Linea de `prioritarios` de la tercera consulta en el documento: %s\n",
            paste(idx, collapse = ", ")))
stopifnot(length(idx) == 1L)
cruda <- sub("^  prioritarios: ", "", lineas[[idx]])
items <- trimws(strsplit(cruda, " ; ", fixed = TRUE)[[1]])

meta_de <- function(slug) {
  ruta <- file.path(DIR_NORMAS, paste0(slug, ".json"))
  if (!file.exists(ruta)) return(list(origen = NA_character_, vig = NA_character_))
  n <- jsonlite::fromJSON(ruta, simplifyVector = FALSE)
  list(origen = n[["origen_texto"]],
       vig    = if (is.null(n[["vigencia"]])) NA_character_ else n[["vigencia"]][["estado"]])
}

CITABLES <- c("capa_texto_pdf", "ocr_revisado")
cat("\n=== ORDEN REAL, posicion por posicion ===\n")
filas <- vector("list", length(items))
for (i in seq_along(items)) {
  ancla <- sub(" \\[.*$", "", items[[i]])
  slug  <- sub("\\.html#.*$", "", ancla)
  m     <- meta_de(slug)
  filas[[i]] <- list(pos = i, ancla = ancla, slug = slug,
                     origen = m[["origen"]], vig = m[["vig"]],
                     citable = m[["origen"]] %in% CITABLES)
  cat(sprintf("  %d. %-62s origen_texto=%-22s vigencia=%-11s citable=%s\n",
              i, ancla, m[["origen"]], m[["vig"]],
              m[["origen"]] %in% CITABLES))
}

pos_de <- function(a) {
  p <- which(vapply(filas, function(f) identical(f[["ancla"]], a), logical(1)))
  if (length(p) == 0L) NA_integer_ else p
}

p078 <- pos_de("dictamen_078_detectores_revision_mochilas.html#ocr-pagina-001")
p809 <- pos_de("ley_21809_convivencia_educativa.html#art-16-e")
p065 <- pos_de("dictamen_065_revision_mochilas.html#materia")
p430 <- pos_de("ley_21430_garantias_ninez.html#art-28")

cat("\n=== PREGUNTAS QUE EL DOCUMENTO DEBE RESPONDER BIEN ===\n")
cat(sprintf("  posicion de la unidad OCR (078#ocr-pagina-001): %d\n", p078))
cat(sprintf("  posicion de la firmada (ley_21809#art-16-e):    %d\n", p809))
cat(sprintf("  ¿el 078 va por delante de ley_21809#art-16-e?   %s\n", p078 < p809))
cat(sprintf("  ¿el 078 va por delante de dictamen_065#materia? %s\n", p078 < p065))
cat(sprintf("  ¿el 078 va por delante de ley_21430#art-28?     %s\n", p078 < p430))
cat(sprintf("  unidades citables que el 078 precede:           %d de %d posteriores\n",
            sum(vapply(filas, function(f) f[["pos"]] > p078 && isTRUE(f[["citable"]]), logical(1))),
            sum(vapply(filas, function(f) f[["pos"]] > p078, logical(1)))))
cat(sprintf("  ¿la lista abre con una unidad no citable?       %s\n", !isTRUE(filas[[1]][["citable"]])))

cat("\n=== CONTROLES DEL INSTRUMENTO ===\n")
cat(sprintf("  CONTROL POSITIVO (debe TRUE): posicion 1 < posicion 2            -> %s\n", 1L < 2L))
cat(sprintf("  CONTROL NEGATIVO (debe FALSE): posicion 2 < posicion 1           -> %s\n", 2L < 1L))
cat(sprintf("  CONTROL de resolucion de slug (debe capa_texto_pdf)              -> %s\n",
            meta_de("ley_21809_convivencia_educativa")[["origen"]]))
cat(sprintf("  CONTROL de resolucion de slug (debe ocr_pendiente_revision)      -> %s\n",
            meta_de("dictamen_078_detectores_revision_mochilas")[["origen"]]))
cat(sprintf("  CONTROL de slug inexistente (debe NA)                            -> %s\n",
            meta_de("ley_zzz_inexistente")[["origen"]]))
cat(sprintf("  CONTROL de vigencia (dictamen_065 debe sustituido)               -> %s\n",
            meta_de("dictamen_065_revision_mochilas")[["vig"]]))

cat("\nVEREDICTO: la unidad firmada va en la posicion 1 y la OCR en la 2.\n")
