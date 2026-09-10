#!/usr/bin/env Rscript
# =============================================================================
# a3_sondeo_deroga.R — laboratorio A3, encargo v9 (desechable)
# -----------------------------------------------------------------------------
# Sondeo que motivo partir la regla `deroga` en D1 y D2 (documento A3, tarea 8).
# Cuenta las ocurrencias de "derog" en el texto de los 806 segmentos de las 25
# normas y separa las que estan precedidas de "no" (formula "con las normas no
# derogadas del DFL 1"), que son las que hacian falsos los pares de la primera
# regla.
#
# TRAZABILIDAD DE LA CIFRA (hallazgo CIF-A3-04 de la auditoria): el conteo de
# "no derogad" usa el patron `no\s+derogad`, y `\s` casa tambien el salto de
# linea. Una de las 19 ocurrencias trae un salto de linea entre las dos
# palabras, de modo que un conteo con un espacio LITERAL (`no derogad`, o un
# `grep -c` de shell, que ademas cuenta lineas y no ocurrencias) da 18/53 y no
# 19/52. Las dos cifras se imprimen aqui, para que quien rehaga el sondeo
# encuentre su propio numero declarado.
#
# Se escribe como ARCHIVO (no `Rscript -e`) porque el patron lleva `\s` y una
# contrabarra dentro de -e llega colapsada a R.
#
# Ejecutar desde la raiz del repo:
#   Rscript 50_documentacion/andamios/lab_motor_v9/a3_sondeo_deroga.R
# No escribe nada en disco: imprime a stdout.
# =============================================================================
source(here::here("50_documentacion", "andamios", "lab_motor_v9", "a3_cargar_defs.R"))
normas <- leer_normas()

textos <- unlist(lapply(unname(normas), function(n)
  vapply(n[["articulos"]], function(a) as.character(a[["texto"]]), character(1))))
colapsar <- function(x) gsub("\\s+", " ", x)

contar <- function(v, patron) sum(vapply(gregexpr(patron, v, perl = TRUE),
                                         function(m) if (m[[1]] == -1L) 0L else length(m), integer(1)))

PAT_DEROG   <- "(?i)derog"
PAT_NO_DER  <- "(?i)no\\s+derogad"

crudo <- c(total = contar(textos, PAT_DEROG), no = contar(textos, PAT_NO_DER))
colap <- c(total = contar(colapsar(textos), PAT_DEROG), no = contar(colapsar(textos), PAT_NO_DER))

cat(sprintf("segmentos leidos: %d (de %d normas)\n", length(textos), length(normas)))
cat(sprintf("SIN normalizar espacios : total \"derog\" %d | \"no derogad\" %d | otras %d\n",
            crudo[["total"]], crudo[["no"]], crudo[["total"]] - crudo[["no"]]))
cat(sprintf("CON espacios colapsados : total \"derog\" %d | \"no derogad\" %d | otras %d   <-- cifra publicada\n",
            colap[["total"]], colap[["no"]], colap[["total"]] - colap[["no"]]))

cat("\nformas del separador entre \"no\" y \"derogad\" (sobre el texto crudo):\n")
sep <- unlist(lapply(regmatches(textos, gregexpr("(?i)no\\s+derogad", textos, perl = TRUE)), identity))
sep_norm <- gsub("(?i)^no", "no", sep, perl = TRUE)
print(table(vapply(sep, function(s) {
  m <- sub("(?i)^no", "", s, perl = TRUE); m <- sub("(?i)derogad.*$", "", m)
  paste0("no[", gsub("\n", "\\\\n", m), "]derogad")
}, character(1))))

cat(sprintf("\nconteo con un espacio LITERAL `no derogad` sobre el texto crudo: %d | otras %d   <-- lo que obtiene quien no usa `\\s`\n",
            contar(textos, "(?i)no derogad"), crudo[["total"]] - contar(textos, "(?i)no derogad")))

cat("\nPRUEBA DE INSTRUMENTO (un termino que DEBE aparecer y uno que NO):\n")
cat(sprintf("  control positivo, \"derogad\" (participio) : %d ocurrencia(s) (DEBE ser > 0)\n",
            contar(colapsar(textos), "(?i)derogad")))
cat(sprintf("  control negativo, \"zzderogzz\"             : %d ocurrencia(s) (DEBE ser 0)\n",
            contar(colapsar(textos), "(?i)zzderogzz")))
cat(sprintf("  control de sensibilidad del patron `no\\s+derogad` sobre una cadena sintetica con salto de linea: %d (DEBE ser 1)\n",
            contar("las normas no\nderogadas del DFL 1", PAT_NO_DER)))
cat(sprintf("  el mismo patron con espacio literal `no derogad` sobre esa cadena: %d (DEBE ser 0, y esa es la diferencia entre 19 y 18)\n",
            contar("las normas no\nderogadas del DFL 1", "(?i)no derogad")))
