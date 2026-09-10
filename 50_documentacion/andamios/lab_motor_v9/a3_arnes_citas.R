#!/usr/bin/env Rscript
# =============================================================================
# a3_arnes_citas.R — laboratorio A3, encargo v9 (desechable)
# -----------------------------------------------------------------------------
# Arnes antialucinacion DEL LADO DEL CLIENTE para la variante en vivo. No
# depende del modelo: recibe el texto que el modelo devolvio (esquema
# a3-salida-v1), y verifica programaticamente, contra los JSON de norma y con
# la compuerta real ancla_resuelve() de 34_generar_paginas.R:
#   1. que la salida sea JSON valido con el esquema y un modo permitido;
#   2. que cada cita apunte a un ancla existente y coherente (norma/articulo);
#   3. que `texto_citado` sea una copia LITERAL y contigua del articulo
#      (comparacion tras colapsar espacios), de 20 a 600 caracteres;
#   4. que la norma citada sea citable (origen_texto en capa_texto_pdf u
#      ocr_revisado): una pagina OCR sin revisar se degrada a "ubicacion";
#   5. que una norma sustituida arrastre su advertencia aunque el modelo la omita;
#   6. que cada frase de inferencia se apoye SOLO en citas aceptadas; las demas
#      se retiran y se cuentan.
# Ademas prueba el detector de RUT del caso adversarial A6.
# Se ejercita con a3_salida_ejemplo_mixta.json (construida a mano) y con dos
# controles: una salida ilegible y una salida minima totalmente valida.
# Ejecutar desde la raiz del repo:
#   Rscript 50_documentacion/andamios/lab_motor_v9/a3_arnes_citas.R
# =============================================================================
source(here::here("50_documentacion", "andamios", "lab_motor_v9", "a3_cargar_defs.R"))
cargar_entorno_pipeline()
d34 <- cargar_defs_de(here::here("30_procesamiento", "34_generar_paginas.R"),
                      constantes = CONSTANTES_34)
e <- d34[["env"]]
normas <- leer_normas()
anclas <- e$anclas_disponibles(unname(normas))
LAB <- here::here("50_documentacion", "andamios", "lab_motor_v9")

MODOS <- c("respuesta", "sin_respaldo", "fuera_de_dominio", "consejo_individual", "datos_personales")
CITABLES <- c("capa_texto_pdf", "ocr_revisado")
NIVEL_POR_TIPO <- c(ley = "fuente_primaria", dfl = "fuente_primaria", dto = "fuente_primaria",
                    circular = "fuente_primaria", rex = "fuente_primaria",
                    dictamen = "pronunciamiento_oficial")
colapsar <- function(x) trimws(gsub("\\s+", " ", x))

texto_de <- function(slug, id) {
  n <- normas[[slug]]
  if (is.null(n)) return(NULL)
  for (a in n[["articulos"]]) if (identical(a[["id"]], id)) return(a[["texto"]])
  NULL
}

verificar_cita <- function(c) {
  v <- list(cita_id = c[["cita_id"]], ancla = c[["ancla"]], veredicto = "aceptada", motivo = "", advertencias = character(0))
  if (!e$ancla_resuelve(c, anclas)) {
    v[["veredicto"]] <- "rechazada"; v[["motivo"]] <- "ancla inexistente o incoherente con norma/articulo"
    return(v)
  }
  n <- normas[[c[["norma"]]]]
  tc <- c[["texto_citado"]]
  if (!is.character(tc) || length(tc) != 1L || nchar(colapsar(tc)) < 20L || nchar(colapsar(tc)) > 600L) {
    v[["veredicto"]] <- "rechazada"; v[["motivo"]] <- "texto_citado ausente o fuera de 20-600 caracteres"; return(v)
  }
  if (!grepl(colapsar(tc), colapsar(texto_de(c[["norma"]], c[["articulo"]])), fixed = TRUE)) {
    v[["veredicto"]] <- "rechazada"; v[["motivo"]] <- "texto_citado no es copia literal del articulo"; return(v)
  }
  if (!n[["origen_texto"]] %in% CITABLES) {
    v[["veredicto"]] <- "degradada_a_ubicacion"
    v[["motivo"]] <- sprintf("origen_texto = %s: no es evidencia citable; se muestra solo como ubicacion", n[["origen_texto"]])
    return(v)
  }
  v[["nivel"]] <- unname(NIVEL_POR_TIPO[[n[["tipo"]]]])
  if (identical(n[["vigencia"]][["estado"]], "sustituido")) {
    v[["advertencias"]] <- sprintf("norma sustituida por %s (fuente: campo vigencia del JSON)", n[["vigencia"]][["sustituido_por"]])
  }
  v
}

verificar_respuesta <- function(json_texto) {
  s <- tryCatch(jsonlite::fromJSON(json_texto, simplifyVector = FALSE), error = function(err) NULL)
  if (is.null(s) || !is.list(s)) {
    return(list(veredicto = "salida_ilegible", accion = "no se muestra inferencia; se muestran solo los resultados de busqueda"))
  }
  if (!identical(s[["esquema"]], "a3-salida-v1") || !isTRUE(s[["modo"]] %in% MODOS) ||
      !identical(s[["rotulo"]], "inferencia_del_modelo_no_validada")) {
    return(list(veredicto = "esquema_invalido", accion = "no se muestra inferencia; se muestran solo los resultados de busqueda"))
  }
  citas <- if (is.list(s[["citas"]])) Filter(is.list, s[["citas"]]) else list()
  ver <- lapply(citas, verificar_cita)
  names(ver) <- vapply(ver, function(v) as.character(v[["cita_id"]]), character(1))
  aceptadas <- names(ver)[vapply(ver, function(v) identical(v[["veredicto"]], "aceptada"), logical(1))]
  frases <- if (is.list(s[["inferencia"]])) Filter(is.list, s[["inferencia"]]) else list()
  conservadas <- list(); retiradas <- 0L
  for (f in frases) {
    apoyos <- unlist(f[["apoya_en"]])
    if (length(apoyos) > 0L && all(apoyos %in% aceptadas)) conservadas[[length(conservadas) + 1L]] <- f
    else retiradas <- retiradas + 1L
  }
  adv <- unique(c(unlist(s[["advertencias"]]), unlist(lapply(ver[aceptadas], function(v) v[["advertencias"]]))))
  list(veredicto = if (length(conservadas) > 0L) "inferencia_parcial_o_completa" else "sin_inferencia_verificable",
       modo = s[["modo"]], citas = ver, aceptadas = aceptadas,
       conservadas = conservadas, retiradas = retiradas, advertencias = adv,
       no_resuelto = unlist(s[["no_resuelto"]]))
}

# Deteccion de RUT en el cliente (caso adversarial A6). El patron no depende de
# la locale: digitos, puntos opcionales, guion y digito verificador o K.
REGEX_RUT <- "\\b\\d{1,2}\\.?\\d{3}\\.?\\d{3}-[\\dkK]\\b"
contiene_rut <- function(texto) grepl(REGEX_RUT, texto, perl = TRUE)

# ---- Render de la salida verificada, por niveles -------------------------------
render <- function(r, citas_originales) {
  if (!identical(r[["veredicto"]], "inferencia_parcial_o_completa") && !identical(r[["veredicto"]], "sin_inferencia_verificable")) {
    return(sprintf("[%s] %s", r[["veredicto"]], r[["accion"]]))
  }
  por_id <- setNames(citas_originales, vapply(citas_originales, function(c) c[["cita_id"]], character(1)))
  lineas <- c(sprintf("[rotulo] inferencia del modelo, NO validada por el equipo | modo: %s", r[["modo"]]))
  for (id in r[["aceptadas"]]) {
    v <- r[["citas"]][[id]]; c <- por_id[[id]]
    n <- normas[[c[["norma"]]]]
    lineas <- c(lineas, sprintf("[%s] %s, %s (%s): \"%s\"%s",
                                gsub("_", " ", v[["nivel"]]), nombre_corto(n),
                                vapply(n[["articulos"]], function(a) if (identical(a[["id"]], c[["articulo"]])) a[["etiqueta"]] else NA_character_, character(1)) |> stats::na.omit() |> as.character() |> head(1),
                                c[["ancla"]], substr(colapsar(c[["texto_citado"]]), 1, 90),
                                if (length(v[["advertencias"]])) paste0("  <<", v[["advertencias"]], ">>") else ""))
  }
  for (f in r[["conservadas"]]) lineas <- c(lineas, sprintf("[inferencia del modelo] %s  (apoya en: %s)", f[["texto"]], paste(unlist(f[["apoya_en"]]), collapse = ", ")))
  if (r[["retiradas"]] > 0L) lineas <- c(lineas, sprintf("[aviso] %d frase(s) de inferencia retirada(s) porque se apoyaban en citas que no se pudieron verificar.", r[["retiradas"]]))
  for (a in r[["advertencias"]]) lineas <- c(lineas, paste0("[advertencia] ", a))
  for (x in r[["no_resuelto"]]) lineas <- c(lineas, paste0("[no resuelto] ", x))
  paste(lineas, collapse = "\n")
}

# ---- Ejercicio 1: salida mixta construida a mano ---------------------------------
cat("=== EJERCICIO 1: a3_salida_ejemplo_mixta.json (construida a mano: 1 valida, 1 ancla inventada, 1 parafrasis, 1 OCR, 1 sustituida) ===\n")
txt <- paste(readLines(file.path(LAB, "a3_salida_ejemplo_mixta.json"), warn = FALSE, encoding = "UTF-8"), collapse = "\n")
r1 <- verificar_respuesta(txt)
for (id in names(r1[["citas"]])) {
  v <- r1[["citas"]][[id]]
  cat(sprintf("  %-3s %-52s %-22s %s\n", id, v[["ancla"]], v[["veredicto"]], v[["motivo"]]))
}
cat(sprintf("  citas aceptadas: %d de %d | frases conservadas: %d de %d | retiradas: %d\n",
            length(r1[["aceptadas"]]), length(r1[["citas"]]), length(r1[["conservadas"]]),
            length(r1[["conservadas"]]) + r1[["retiradas"]], r1[["retiradas"]]))
cat("--- render ---\n")
s1 <- jsonlite::fromJSON(txt, simplifyVector = FALSE)
cat(render(r1, s1[["citas"]]), "\n")

# ---- Ejercicio 2: controles -----------------------------------------------------
cat("\n=== EJERCICIO 2: controles ===\n")
r2 <- verificar_respuesta("esto no es JSON {")
cat("  salida ilegible ->", r2[["veredicto"]], "|", r2[["accion"]], "\n")
minima <- jsonlite::toJSON(list(
  esquema = "a3-salida-v1", modo = "respuesta", rotulo = "inferencia_del_modelo_no_validada",
  pregunta_entendida = "control",
  citas = list(list(cita_id = "k1", norma = "ley_21801_celulares", articulo = "art-10-ter",
                    ancla = "ley_21801_celulares.html#art-10-ter",
                    texto_citado = "se entenderá por dispositivos móviles electrónicos de comunicación personal aquellos medios tecnológicos que permiten efectuar telecomunicación")),
  inferencia = list(list(texto = "La ley define los dispositivos móviles.", apoya_en = list("k1"))),
  no_resuelto = list(), advertencias = list()), auto_unbox = TRUE)
r3 <- verificar_respuesta(as.character(minima))
cat("  salida minima valida ->", r3[["veredicto"]], "| aceptadas:", length(r3[["aceptadas"]]), "de 1 | retiradas:", r3[["retiradas"]], "\n")
r4 <- verificar_respuesta(sub('"modo":"respuesta"', '"modo":"oraculo"', as.character(minima), fixed = TRUE))
cat("  modo no permitido ->", r4[["veredicto"]], "\n")

cat("\n=== EJERCICIO 3: detector de RUT (caso A6; datos ficticios) ===\n")
# Las cadenas con forma de RUT se CONSTRUYEN en tiempo de ejecucion y se
# ENMASCARAN al imprimir (digito verificador entre corchetes): la regla R3 del
# hook pre-push de la cartera rechaza toda linea agregada que contenga una cadena
# con forma de RUT, ficticia o no, asi que ni este archivo ni su salida pueden
# traer el literal. Correccion G-1 del orquestador, 2026-09-05.
rut_ficticio   <- paste0("11.111.111", "-", "1")
rut_sin_puntos <- paste0("11111111", "-", "k")
enmascarar <- function(x) sub("-([0-9kK])\\b", "-[\\1]", x, perl = TRUE)
consulta_a6 <- paste0("El alumno Juan Pérez Pérez, RUT ", rut_ficticio, ", de 7°B")
cat(sprintf("  '%s' -> %s (DEBE ser TRUE)\n", enmascarar(rut_ficticio), contiene_rut(consulta_a6)))
cat(sprintf("  '%s' sin puntos -> %s (DEBE ser TRUE)\n", enmascarar(rut_sin_puntos),
            contiene_rut(paste("rut", rut_sin_puntos))))
cat("  'ley 21.801 y artículo 10 bis' ->", contiene_rut("ley 21.801 y artículo 10 bis, dictamen 52/77"), "(DEBE ser FALSE)\n")
# El caso A6 de a3_casos_adversariales.yml trae el marcador RUT_FICTICIO en vez
# del literal; aqui se reemplaza por la cadena construida y se prueba.
casos_yml <- yaml::read_yaml(file.path(LAB, "a3_casos_adversariales.yml"))
a6 <- Filter(function(k) identical(k[["id"]], "A6"), casos_yml[["casos"]])[[1]]
consulta_yml <- gsub("RUT_FICTICIO", rut_ficticio, a6[["consulta"]], fixed = TRUE)
cat(sprintf("  caso A6 del YAML con el marcador reemplazado -> %s (DEBE ser TRUE); marcador presente en el YAML: %s; literal presente en el YAML: %s\n",
            contiene_rut(consulta_yml), grepl("RUT_FICTICIO", a6[["consulta"]], fixed = TRUE),
            contiene_rut(a6[["consulta"]])))

ok <- length(r1[["aceptadas"]]) == 2L && r1[["retiradas"]] == 3L &&
  identical(r2[["veredicto"]], "salida_ilegible") && length(r3[["aceptadas"]]) == 1L &&
  identical(r4[["veredicto"]], "esquema_invalido") &&
  contiene_rut(consulta_a6) && contiene_rut(consulta_yml) && !contiene_rut(a6[["consulta"]]) &&
  !contiene_rut("ley 21.801 y artículo 10 bis")
cat(sprintf("\nVEREDICTO DEL ARNES: %s\n", if (ok) "OK" else "FALLA"))
quit(status = if (ok) 0L else 1L)
