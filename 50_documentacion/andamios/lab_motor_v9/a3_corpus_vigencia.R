# a3_corpus_vigencia.R
# Reparto del corpus por `origen_texto` y por `vigencia.estado`, con sus controles.
# Sostiene la fila "Corpus por origen_texto / por vigencia.estado" de §12 y el
# control positivo de §2.1. Solo lee; no escribe nada.
# Uso: Rscript 50_documentacion/andamios/lab_motor_v9/a3_corpus_vigencia.R
suppressWarnings(suppressMessages({ library(jsonlite); library(here) }))

f <- list.files(here::here("40_salidas/datos/normas"), pattern = "[.]json$", full.names = TRUE)
cat(sprintf("normas leidas: %d\n\n", length(f)))
n <- lapply(f, function(p) jsonlite::fromJSON(p, simplifyVector = FALSE))

orig <- vapply(n, function(x) x[["origen_texto"]], character(1))
vig  <- vapply(n, function(x) x[["vigencia"]][["estado"]], character(1))
slug <- vapply(n, function(x) x[["slug"]], character(1))

cat("origen_texto:\n"); print(table(orig))
cat("\nvigencia.estado:\n"); print(table(vig))
no_vig <- slug[vig != "vigente"]
cat(sprintf("\nno vigente(s): %s\n", paste(no_vig, collapse = ", ")))
cat(sprintf("sustituida por: %s\n",
            paste(unlist(lapply(n[vig != "vigente"],
                                function(x) x[["vigencia"]][["sustituido_por"]])), collapse = ", ")))

cat("\n=== CONTROLES ===\n")
cat(sprintf("  CONTROL POSITIVO: categorias distintas de origen_texto %d y de vigencia.estado %d (DEBE >1 en ambos;\n    una sola categoria delataria un filtro roto que devuelve una clase)\n",
            length(unique(orig)), length(unique(vig))))
cat(sprintf("  CONTROL NEGATIVO: estado inventado 'zzz' -> %d (DEBE 0)\n", sum(vig == "zzz")))
cat(sprintf("  CONTROL de suma: origen %d + vigencia %d = %d y %d, ambos = n normas %s\n",
            sum(table(orig)), sum(table(vig)), sum(table(orig)), sum(table(vig)),
            sum(table(orig)) == length(f) && sum(table(vig)) == length(f)))
