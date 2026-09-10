#!/usr/bin/env Rscript
# =============================================================================
# a3_probar_compuerta.R — laboratorio A3, encargo v9 (desechable)
# -----------------------------------------------------------------------------
# Prueba que el esquema de front matter propuesto para rutas de abordaje y
# entradas de capa experta PASA la compuerta de firma vigente, usando el codigo
# real de 34_generar_paginas.R (leer_pieza, revisar_pieza, normalizar_pieza,
# firmada, ancla_resuelve, fuentes_en_forma, rotulo_ancla), cargado por
# definiciones (a3_cargar_defs.R), nunca por source() del script entero.
#
# `compuerta_lab()` reproduce el ORDEN y las CONDICIONES de cargar_piezas()
# (34_generar_paginas.R, lineas 675-763 leidas el 2026-09-05) con dos
# diferencias declaradas: la raiz es una lista de rutas y no
# ruta_insumos("curaduria","piezas"), y los stop() se devuelven como texto
# para poder encadenar varios casos en una corrida. Las funciones que deciden
# son las reales. Como control de que el codigo real corre en este entorno, al
# final se llama a cargar_piezas() de verdad sobre la carpeta real de piezas
# (solo lectura: dir_ls + leer_pieza + log; hoy 0 validadas).
# Ejecutar desde la raiz del repo:
#   Rscript 50_documentacion/andamios/lab_motor_v9/a3_probar_compuerta.R
# =============================================================================
source(here::here("50_documentacion", "andamios", "lab_motor_v9", "a3_cargar_defs.R"))
cargar_entorno_pipeline()
d34 <- cargar_defs_de(here::here("30_procesamiento", "34_generar_paginas.R"),
                      constantes = CONSTANTES_34)
e <- d34[["env"]]
normas <- leer_normas()
anclas <- e$anclas_disponibles(unname(normas))
LAB <- here::here("50_documentacion", "andamios", "lab_motor_v9")

compuerta_lab <- function(rutas, anclas) {
  piezas <- lapply(rutas, e$leer_pieza)
  rel <- function(p) fs::path_rel(p[["archivo"]], here::here())
  reparos <- unlist(lapply(piezas, function(p) {
    r <- e$revisar_pieza(p)
    if (length(r) == 0L) return(NULL)
    paste0("  ", rel(p), "\n", paste0("    - ", r, collapse = "\n"))
  }))
  if (length(reparos) > 0L) {
    return(list(veredicto = "ABORTA (revisar_pieza)",
                detalle = paste0(sprintf("Hay %d pieza(s) interpretativa(s) que el pipeline no puede aceptar:\n", length(reparos)),
                                 paste(reparos, collapse = "\n"))))
  }
  piezas <- lapply(piezas, e$normalizar_pieza)
  publicables <- Filter(function(p) identical(p[["estado"]], "validada") && e$firmada(p), piezas)
  malas_de <- function(p) Filter(function(f) !e$ancla_resuelve(f, anclas), e$fuentes_en_forma(p))
  rotas_pub <- unlist(lapply(publicables, function(p) {
    malas <- malas_de(p)
    if (length(malas) == 0L) return(NULL)
    paste0("  ", rel(p), "\n", paste0("    - `", vapply(malas, e$rotulo_ancla, character(1)), "`", collapse = "\n"))
  }))
  if (length(rotas_pub) > 0L) {
    return(list(veredicto = "ABORTA (compuerta de anclas)",
                detalle = paste0("Hay piezas validadas cuyas `fuentes` no apuntan a un artículo que exista:\n",
                                 paste(rotas_pub, collapse = "\n"))))
  }
  borradores <- Filter(function(p) !identical(p[["estado"]], "validada"), piezas)
  rotas_bor <- unlist(lapply(borradores, function(p) {
    malas <- malas_de(p)
    if (length(malas) == 0L) return(NULL)
    sprintf("%s -> %s", rel(p), paste(vapply(malas, e$rotulo_ancla, character(1)), collapse = ", "))
  }))
  list(veredicto = sprintf("PASA: %d publicable(s), %d borrador(es)%s",
                           length(publicables), length(borradores),
                           if (length(rotas_bor)) " [WARN anclas rotas en borrador]" else ""),
       detalle = if (length(rotas_bor)) paste(rotas_bor, collapse = "; ") else
         if (length(publicables)) paste("publicable:", paste(vapply(publicables, function(p) basename(p[["archivo"]]), character(1)), collapse = ", ")) else "sin reparos")
}

# ---- Casos plantados a partir de la ruta de ejemplo ---------------------------
base <- readLines(file.path(LAB, "a3_ruta_uso_dispositivos_moviles.md"), warn = FALSE)
variante <- function(nombre, ...) {
  cambios <- list(...)
  x <- base
  for (k in names(cambios)) {
    i <- grep(paste0("^", k, ":"), x)[1]
    stopifnot(!is.na(i))
    x[i] <- if (is.null(cambios[[k]])) NA_character_ else paste0(k, ": ", cambios[[k]])
  }
  x <- x[!is.na(x)]
  ruta <- file.path(LAB, paste0("a3_tmp_caso_", nombre, ".md"))
  writeLines(x, ruta)
  ruta
}
rota <- function(nombre) {
  # Un ancla que apunta a un articulo inexistente, con norma/articulo coherentes
  # con ella (asi la falla es la del articulo, no la del cruce de etiqueta).
  x <- readLines(variante(nombre, estado = "validada", validado_por = '"Ejemplo Ficticio"',
                          fecha_validacion = '"2026-09-05"'), warn = FALSE)
  x <- sub('articulo: art-10-ter, ancla: "ley_21801_celulares.html#art-10-ter"',
           'articulo: art-10-nonies, ancla: "ley_21801_celulares.html#art-10-nonies"', x, fixed = TRUE)
  ruta <- file.path(LAB, paste0("a3_tmp_caso_", nombre, ".md")); writeLines(x, ruta); ruta
}

casos <- list(
  list(id = "A  DEBE PASAR: estado validada + firma ficticia 'Ejemplo Ficticio' (declarada ficticia) + fecha",
       ruta = variante("A_pasa", estado = "validada", validado_por = '"Ejemplo Ficticio"', fecha_validacion = '"2026-09-05"')),
  list(id = "B1 DEBE ABORTAR: estado validada sin validado_por ni fecha",
       ruta = variante("B1_sin_firma", estado = "validada")),
  list(id = "B2 DEBE ABORTAR: validado_por: no (booleano YAML, firma no textual)",
       ruta = variante("B2_firma_booleana", estado = "validada", validado_por = "no", fecha_validacion = '"2026-09-05"')),
  list(id = "B3 DEBE ABORTAR: validado_por: \"pendiente\" (texto que no es nombre)",
       ruta = variante("B3_pendiente", estado = "validada", validado_por = '"pendiente"', fecha_validacion = '"2026-09-05"')),
  list(id = "C  DEBE ABORTAR: tipo: ruta_abordaje (fuera del dominio cerrado TIPOS_PIEZA)",
       ruta = variante("C_tipo_nuevo", tipo = "ruta_abordaje")),
  list(id = "D  DEBE ABORTAR: validada y firmada, con un ancla a un articulo inexistente",
       ruta = rota("D_ancla_rota"))
)
for (k in casos) {
  cat("\n=== CASO", k[["id"]], "===\n")
  r <- compuerta_lab(k[["ruta"]], anclas)
  cat("VEREDICTO:", r[["veredicto"]], "\n", r[["detalle"]], "\n")
}

# ---- E: los archivos reales del laboratorio, tal como estan (borrador) --------
cat("\n=== CASO E  DEBE PASAR sin publicar: los 4 archivos a3_ruta_*/a3_tema_* en borrador ===\n")
reales <- fs::dir_ls(LAB, regexp = "a3_(ruta|tema)_.*[.]md$")
r <- compuerta_lab(reales, anclas)
cat("VEREDICTO:", r[["veredicto"]], "\n", r[["detalle"]], "\n")
for (f in reales) {
  p <- e$leer_pieza(f)
  cat(sprintf("  %-45s revisar_pieza: %d reparos | firmada: %s | estado: %s | subtipo: %s\n",
              basename(f), length(e$revisar_pieza(p)), e$firmada(p), p[["estado"]], p[["subtipo"]]))
}

# ---- F: la funcion REAL cargar_piezas() sobre la carpeta real (solo lectura) ---
cat("\n=== CASO F  control del codigo real: cargar_piezas(anclas) sobre 20_insumos/curaduria/piezas (lectura) ===\n")
pub <- e$cargar_piezas(anclas)
cat(sprintf("cargar_piezas() devolvio %d pieza(s) publicable(s).\n", length(pub)))

# ---- Limpieza de los archivos temporales de este script ------------------------
tmp <- fs::dir_ls(LAB, regexp = "a3_tmp_caso_.*[.]md$")
fs::file_delete(tmp)
cat(sprintf("\nArchivos temporales borrados: %d. Quedan a3_tmp_*: %d\n", length(tmp),
            length(fs::dir_ls(LAB, regexp = "a3_tmp_"))))
