#!/usr/bin/env Rscript
# =============================================================================
# a3_verificar_anclas.R — laboratorio A3, encargo v9 (desechable)
# -----------------------------------------------------------------------------
# Verifica ancla por ancla, con la compuerta REAL de 34_generar_paginas.R
# (ancla_resuelve, sobre anclas_disponibles), las `fuentes` de los archivos
# a3_ruta_*.md y a3_tema_*.md del laboratorio, y ADEMAS que cada id exista como
# `id="..."` en el HTML generado en 40_salidas/sitio/. Incluye el control
# global (todos los id del JSON contra el HTML) y dos controles plantados.
# Ejecutar desde la raiz del repo:
#   Rscript 50_documentacion/andamios/lab_motor_v9/a3_verificar_anclas.R
# =============================================================================
source(here::here("50_documentacion", "andamios", "lab_motor_v9", "a3_cargar_defs.R"))
cargar_entorno_pipeline()

d34 <- cargar_defs_de(here::here("30_procesamiento", "34_generar_paginas.R"),
                      constantes = CONSTANTES_34)
e <- d34[["env"]]
cat(sprintf("34_generar_paginas.R: %d expresiones de nivel superior; evaluadas %d (funciones + %d constantes), omitidas %d.\n",
            d34[["n_total"]], length(d34[["evaluadas"]]), length(CONSTANTES_34), length(d34[["omitidas"]])))
cat("Funciones de compuerta disponibles:",
    paste(intersect(c("leer_pieza", "revisar_pieza", "normalizar_pieza", "firmada",
                      "es_nombre_de_persona", "anclas_disponibles", "ancla_resuelve",
                      "fuentes_en_forma", "rotulo_ancla", "cargar_piezas"), d34[["evaluadas"]]),
          collapse = ", "), "\n\n")

normas <- leer_normas()
anclas <- e$anclas_disponibles(unname(normas))

# ---- (a) Control global: todo id del JSON existe como id= en su HTML ---------
tot <- 0L; ok <- 0L; faltan <- character(0)
for (s in names(normas)) {
  ids_json <- anclas[[s]]
  ids_html <- ids_html_de(s)
  hit <- ids_json %in% ids_html
  tot <- tot + length(ids_json); ok <- ok + sum(hit)
  if (any(!hit)) faltan <- c(faltan, paste0(s, "#", ids_json[!hit]))
}
cat(sprintf("(a) Global: %d ids en los %d JSON de norma; %d presentes como id= en su HTML; faltan %d.\n",
            tot, length(normas), ok, length(faltan)))
if (length(faltan)) print(faltan)
n_art <- sum(vapply(unname(normas), function(n)
  sum(vapply(n[["articulos"]], function(a) isTRUE(a[["es_articulo"]]), logical(1))), integer(1)))
cat(sprintf("    De esos %d ids, %d son articulos (es_articulo = TRUE); el resto son preambulos, secciones de dictamen y paginas OCR.\n", tot, n_art))
cat(sprintf("    Frescura: HTML mas antiguo %s | JSON mas reciente %s (el HTML debe ser posterior).\n",
            format(min(file.mtime(fs::dir_ls(here::here("40_salidas", "sitio"), glob = "*.html")))),
            format(max(file.mtime(fs::dir_ls(here::here("40_salidas", "datos", "normas"), glob = "*.json"))))))

# ---- (b) Archivos del laboratorio --------------------------------------------
LAB <- here::here("50_documentacion", "andamios", "lab_motor_v9")
archivos <- fs::dir_ls(LAB, regexp = "a3_(ruta|tema)_.*[.]md$")
cat(sprintf("\n(b) Archivos del laboratorio con fuentes: %d\n", length(archivos)))
tot_lab <- 0L; ok_lab <- 0L
for (f in archivos) {
  p <- e$leer_pieza(f)
  fu <- e$fuentes_en_forma(p)
  res  <- vapply(fu, function(x) e$ancla_resuelve(x, anclas), logical(1))
  html <- vapply(fu, function(x) x[["articulo"]] %in% ids_html_de(x[["norma"]]), logical(1))
  cat(sprintf("  %-45s %2d de %2d resuelven (ancla_resuelve real) | %2d de %2d presentes en HTML\n",
              basename(f), sum(res), length(res), sum(html), length(html)))
  for (i in which(!res | !html)) cat("      NO RESUELVE:", e$rotulo_ancla(fu[[i]]), "\n")
  tot_lab <- tot_lab + length(res); ok_lab <- ok_lab + sum(res & html)
}
cat(sprintf("  TOTAL laboratorio: %d de %d anclas resuelven en la compuerta real Y existen en el HTML.\n", ok_lab, tot_lab))

# ---- (c) Controles plantados ---------------------------------------------------
mala   <- list(norma = "ley_21801_celulares", articulo = "art-99",
               ancla = "ley_21801_celulares.html#art-99")
buena  <- list(norma = "ley_21801_celulares", articulo = "art-10-bis",
               ancla = "ley_21801_celulares.html#art-10-bis")
miente <- list(norma = "dto_215_uniforme_escolar", articulo = "art-1",
               ancla = "ley_21801_celulares.html#art-10-bis")
sin_ext <- list(norma = "ley_21801_celulares", articulo = "art-10-bis",
                ancla = "ley_21801_celulares#art-10-bis")
r_mala <- e$ancla_resuelve(mala, anclas); h_mala <- "art-99" %in% ids_html_de("ley_21801_celulares")
r_buena <- e$ancla_resuelve(buena, anclas); h_buena <- "art-10-bis" %in% ids_html_de("ley_21801_celulares")
cat("\n(c) Controles plantados:\n")
cat(sprintf("  ancla inexistente  %-40s ancla_resuelve=%s  en HTML=%s  (DEBE ser FALSE/FALSE)\n", mala[["ancla"]], r_mala, h_mala))
cat(sprintf("  ancla existente    %-40s ancla_resuelve=%s  en HTML=%s  (DEBE ser TRUE/TRUE)\n", buena[["ancla"]], r_buena, h_buena))
cat(sprintf("  etiqueta que miente (norma=dto_215, ancla=ley_21801)  ancla_resuelve=%s  (DEBE ser FALSE)\n", e$ancla_resuelve(miente, anclas)))
cat(sprintf("  ancla sin .html    %-40s ancla_resuelve=%s  (DEBE ser FALSE)\n", sin_ext[["ancla"]], e$ancla_resuelve(sin_ext, anclas)))

exito <- (ok == tot) && (ok_lab == tot_lab) && !r_mala && !h_mala && r_buena && h_buena
cat(sprintf("\nVEREDICTO: %s\n", if (exito) "OK" else "FALLA"))
quit(status = if (exito) 0L else 1L)
