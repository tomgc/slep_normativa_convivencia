#!/usr/bin/env Rscript
# =============================================================================
# a3_construir_capa_experta.R — laboratorio A3, encargo v9 (desechable)
# -----------------------------------------------------------------------------
# Construye, desde los archivos a3_tema_*.md (entradas de capa experta) y
# a3_ruta_*.md (rutas de abordaje), los dos artefactos de datos que el motor
# consumiria: a3_capa_experta.json y a3_rutas.json. Aplica la compuerta real
# (revisar_pieza, firmada, ancla_resuelve de 34) y ENRIQUECE cada fuente con lo
# que el pipeline puede derivar y por eso no se declara a mano: nivel por tipo,
# citable por origen_texto, vigencia, etiqueta del articulo. Un `nivel`
# declarado que no coincida con el derivado es un reparo.
# Al final demuestra la "consulta informada": una pregunta en lenguaje del
# equipo se cruza con formas_de_preguntar y devuelve terminos normativos y
# documentos prioritarios, con un control negativo.
# Ejecutar desde la raiz del repo:
#   Rscript 50_documentacion/andamios/lab_motor_v9/a3_construir_capa_experta.R
# =============================================================================
source(here::here("50_documentacion", "andamios", "lab_motor_v9", "a3_cargar_defs.R"))
cargar_entorno_pipeline()
d34 <- cargar_defs_de(here::here("30_procesamiento", "34_generar_paginas.R"), constantes = CONSTANTES_34)
e <- d34[["env"]]
normas <- leer_normas()
anclas <- e$anclas_disponibles(unname(normas))
LAB <- here::here("50_documentacion", "andamios", "lab_motor_v9")

NIVEL_POR_TIPO <- c(ley = "fuente_primaria", dfl = "fuente_primaria", dto = "fuente_primaria",
                    circular = "fuente_primaria", rex = "fuente_primaria",
                    dictamen = "pronunciamiento_oficial")
CITABLES <- c("capa_texto_pdf", "ocr_revisado")
SUBTIPOS <- c("capa_experta", "ruta_abordaje")

etiqueta_de <- function(slug, id) {
  for (a in normas[[slug]][["articulos"]]) if (identical(a[["id"]], id)) return(a[["etiqueta"]])
  NA_character_
}

enriquecer_fuente <- function(f) {
  n <- normas[[f[["norma"]]]]
  f[["nivel_derivado"]] <- unname(NIVEL_POR_TIPO[[n[["tipo"]]]])
  f[["citable"]] <- n[["origen_texto"]] %in% CITABLES
  f[["origen_texto"]] <- n[["origen_texto"]]
  f[["vigencia"]] <- n[["vigencia"]][["estado"]]
  if (identical(n[["vigencia"]][["estado"]], "sustituido")) f[["sustituido_por"]] <- n[["vigencia"]][["sustituido_por"]]
  f[["etiqueta_norma"]] <- nombre_corto(n)
  f[["etiqueta_articulo"]] <- etiqueta_de(f[["norma"]], f[["articulo"]])
  f
}

procesar <- function(ruta) {
  p <- e$leer_pieza(ruta)
  reparos <- e$revisar_pieza(p)
  p <- e$normalizar_pieza(p)
  if (!isTRUE(p[["subtipo"]] %in% SUBTIPOS)) reparos <- c(reparos, sprintf("subtipo `%s` no es capa_experta ni ruta_abordaje", p[["subtipo"]]))
  fu <- e$fuentes_en_forma(p)
  claves <- vapply(fu, function(f) as.character(f[["clave"]]), character(1))
  if (anyDuplicated(claves)) reparos <- c(reparos, "claves de fuentes repetidas")
  rotas <- Filter(function(f) !e$ancla_resuelve(f, anclas), fu)
  if (length(rotas)) reparos <- c(reparos, paste("ancla no resuelve:", vapply(rotas, e$rotulo_ancla, character(1))))
  fu <- lapply(fu, enriquecer_fuente)
  for (f in fu) if (!identical(f[["nivel"]], f[["nivel_derivado"]]))
    reparos <- c(reparos, sprintf("nivel declarado `%s` != derivado `%s` en %s", f[["nivel"]], f[["nivel_derivado"]], f[["ancla"]]))
  # Toda referencia de `fundamento` (considerar_siempre, pasos) apunta a una clave existente.
  refs <- c(unlist(lapply(p[["considerar_siempre"]], function(x) x[["fundamento"]])),
            unlist(lapply(p[["pasos"]], function(x) x[["fundamento"]])))
  huerfanas <- setdiff(refs, claves)
  if (length(huerfanas)) reparos <- c(reparos, paste("fundamento sin fuente:", paste(huerfanas, collapse = ", ")))
  publicable <- identical(p[["estado"]], "validada") && e$firmada(p)
  list(id = tools::file_path_sans_ext(basename(ruta)), subtipo = p[["subtipo"]], titulo = p[["titulo"]],
       tema = p[["tema"]], pagina_tema = p[["pagina_tema"]], estado = p[["estado"]],
       validado_por = p[["validado_por"]], fecha_validacion = p[["fecha_validacion"]],
       publicable = publicable, reparos = reparos,
       formas_de_preguntar = p[["formas_de_preguntar"]], terminos_normativos = p[["terminos_normativos"]],
       considerar_siempre = p[["considerar_siempre"]], fuentes = fu, pasos = p[["pasos"]],
       fuera_de_alcance = p[["fuera_de_alcance"]], no_resuelve = p[["no_resuelve"]],
       rutas = p[["rutas"]], entrada_experta = p[["entrada_experta"]],
       piezas_relacionadas = p[["piezas_relacionadas"]], advertencias = p[["advertencias"]],
       n_fuentes = length(fu), n_citables = sum(vapply(fu, function(f) isTRUE(f[["citable"]]), logical(1))),
       n_refs_fundamento = length(refs))
}

temas <- lapply(fs::dir_ls(LAB, regexp = "a3_tema_.*[.]md$"), procesar)
rutas <- lapply(fs::dir_ls(LAB, regexp = "a3_ruta_.*[.]md$"), procesar)
names(temas) <- NULL; names(rutas) <- NULL

for (x in c(temas, rutas)) {
  cat(sprintf("%-42s subtipo=%-14s estado=%-8s publicable=%-5s fuentes=%2d citables=%2d refs_fundamento=%2d reparos=%d\n",
              x[["id"]], x[["subtipo"]], x[["estado"]], x[["publicable"]], x[["n_fuentes"]], x[["n_citables"]],
              x[["n_refs_fundamento"]], length(x[["reparos"]])))
  for (r in x[["reparos"]]) cat("    REPARO:", r, "\n")
}

# Control positivo del chequeo de nivel: una fuente de dictamen declarada como fuente_primaria debe producir reparo.
ctrl <- enriquecer_fuente(list(clave = "x", norma = "dictamen_71_expulsion_cancelacion_matricula", articulo = "num-6",
                               ancla = "dictamen_71_expulsion_cancelacion_matricula.html#num-6", nivel = "fuente_primaria"))
cat(sprintf("control nivel: dictamen declarado fuente_primaria -> derivado %s (distinto: %s, DEBE ser TRUE)\n",
            ctrl[["nivel_derivado"]], !identical(ctrl[["nivel"]], ctrl[["nivel_derivado"]])))
ctrl2 <- enriquecer_fuente(list(clave = "y", norma = "dictamen_078_detectores_revision_mochilas", articulo = "ocr-pagina-001",
                                ancla = "dictamen_078_detectores_revision_mochilas.html#ocr-pagina-001", nivel = "pronunciamiento_oficial"))
cat(sprintf("control citable: dictamen_078 ocr-pagina-001 -> citable %s (DEBE ser FALSE); dictamen_065 materia -> vigencia %s (DEBE ser sustituido)\n",
            ctrl2[["citable"]], enriquecer_fuente(list(norma = "dictamen_065_revision_mochilas", articulo = "materia", ancla = "dictamen_065_revision_mochilas.html#materia"))[["vigencia"]]))

salida_capa <- list(generado_por = "a3_construir_capa_experta.R (laboratorio A3, encargo v9)",
                    generado_el = "2026-09-05", esquema = "a3-capa-experta-v1",
                    n_entradas = length(temas), n_publicables = sum(vapply(temas, function(x) x[["publicable"]], logical(1))),
                    entradas = temas)
salida_rutas <- list(generado_por = "a3_construir_capa_experta.R (laboratorio A3, encargo v9)",
                     generado_el = "2026-09-05", esquema = "a3-rutas-v1",
                     n_rutas = length(rutas), n_publicables = sum(vapply(rutas, function(x) x[["publicable"]], logical(1))),
                     rutas = rutas)
jsonlite::write_json(salida_capa, file.path(LAB, "a3_capa_experta.json"), auto_unbox = TRUE, pretty = TRUE, null = "null")
jsonlite::write_json(salida_rutas, file.path(LAB, "a3_rutas.json"), auto_unbox = TRUE, pretty = TRUE, null = "null")
cat(sprintf("\nEscritos: a3_capa_experta.json (%d bytes, %d entradas, %d publicables) y a3_rutas.json (%d bytes, %d rutas, %d publicables)\n",
            file.size(file.path(LAB, "a3_capa_experta.json")), length(temas), salida_capa[["n_publicables"]],
            file.size(file.path(LAB, "a3_rutas.json")), length(rutas), salida_rutas[["n_publicables"]]))

# ---- Consulta informada: del lenguaje del equipo a la busqueda -------------------
plano <- function(x) tolower(stringi::stri_trans_general(x, "Latin-ASCII"))
tokens <- function(x) { t <- strsplit(plano(x), "[^a-z0-9]+")[[1]]; t[nchar(t) >= 4L] }
informar_consulta <- function(consulta, entradas) {
  q <- plano(consulta)
  puntajes <- vapply(entradas, function(en) {
    formas <- unlist(en[["formas_de_preguntar"]])
    sum(vapply(formas, function(fm) {
      tk <- tokens(fm)
      if (length(tk) == 0L) return(FALSE)
      all(vapply(tk, function(t) grepl(t, q, fixed = TRUE), logical(1)))
    }, logical(1)))
  }, numeric(1))
  if (max(puntajes) == 0) return(NULL)
  en <- entradas[[which.max(puntajes)]]
  prior <- en[["fuentes"]][order(vapply(en[["fuentes"]], function(f) as.numeric(f[["prioridad"]]), numeric(1)),
                                 !vapply(en[["fuentes"]], function(f) isTRUE(f[["citable"]]), logical(1)))]
  list(entrada = en[["id"]], tema = en[["tema"]], estado = en[["estado"]], formas_coincidentes = puntajes[[which.max(puntajes)]],
       expansion = unlist(en[["terminos_normativos"]]),
       prioritarios = vapply(prior, function(f) sprintf("%s%s%s", f[["ancla"]], if (!isTRUE(f[["citable"]])) " [no citable]" else "",
                                                         if (identical(f[["vigencia"]], "sustituido")) " [sustituida]" else ""), character(1)),
       considerar = vapply(en[["considerar_siempre"]], function(x) x[["texto"]], character(1)))
}
cat("\n=== Consulta informada (lenguaje del equipo -> entrada experta -> expansion + documentos prioritarios) ===\n")
consultas <- c("me pillaron a un cabro con el celular en clases, ¿se lo puedo quitar?",
               "el director quiere echar a un alumno por pelear, ¿qué plazo hay para apelar?",
               "¿podemos revisar las mochilas a la entrada con un pórtico?",
               "receta de pan amasado para el kiosco")
for (q in consultas) {
  r <- informar_consulta(q, temas)
  cat("\nCONSULTA:", q, "\n")
  if (is.null(r)) { cat("  -> sin entrada experta (control negativo: DEBE ser este el caso solo para la receta)\n"); next }
  cat(sprintf("  -> entrada %s (tema «%s», estado %s, %d formas coincidentes)\n", r[["entrada"]], r[["tema"]], r[["estado"]], r[["formas_coincidentes"]]))
  cat("  expansion:", paste(head(r[["expansion"]], 6), collapse = " | "), "\n")
  cat("  prioritarios:", paste(head(r[["prioritarios"]], 4), collapse = " ; "), "\n")
  cat("  considerar:", substr(r[["considerar"]][1], 1, 120), "...\n")
}
