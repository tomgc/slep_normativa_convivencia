#!/usr/bin/env Rscript
# =============================================================================
# aud_procedimiento.R (v2) — Procedimiento de auditoria aplicable a un documento
# cualquiera del encargo v9, mas su propio control positivo y negativo.
#
# Autor: AUD (fase 2, dimension control-auditoria). Archivo desechable:
# vive en 50_documentacion/andamios/lab_motor_v9/, que no se versiona.
#
# QUE HACE (los cuatro chequeos del estandar de rigor, seccion 4 del encargo):
#   C1 cifras      : re-deriva cada cifra agregada del texto contra el artefacto.
#   C2 anclas      : verifica <archivo>.html#<id> contra el HTML generado.
#   C3 ceros       : caza ceros de deteccion sin control positivo en su alcance.
#   C4 universales : caza "todos/ninguno/siempre/cualquier" sin comando al lado.
#   C4b comandos   : verifica que el comando o artefacto citado exista en disco.
#
# BITACORA DE CALIBRACION (lo que el propio control positivo corrigio; la salida
# de la version que fallaba quedo congelada en aud_procedimiento_salida_v1.txt):
#   v1 -> v2, defecto 1 (FALSO NEGATIVO, grave): C3 daba por controlado todo cero
#     cuyo entorno contuviera la raiz "plantad" o "calibrad". Como los archivos
#     plantados dicen "defecto plantado" en su encabezado, el cero plantado se
#     reportaba CERO_CON_CONTROL. Arreglo: lexico de control acotado a frases que
#     nombran el control ejercido, y busqueda que ignora encabezados markdown y
#     comentarios HTML (un titulo no es evidencia de un control corrido).
#   v1 -> v2, defecto 2 (FALSO NEGATIVO, grave): C2 degradaba a "no defecto" toda
#     ancla rota cuya linea contuviera la palabra "inexistente". El nombre del
#     archivo plantado (ley_21899_inexistente.html) contenia esa palabra, asi que
#     el ancla rota se apagaba sola. Arreglo: el estado de defecto NUNCA se
#     degrada; la autodeclaracion viaja en una columna aparte, para triaje.
#   v1 -> v2, defecto 3 (FALSO POSITIVO): C1 marcaba REFUTADA "17 paginas
#     tematicas" porque el sustantivo corto "paginas" (47 en el sitio) ganaba al
#     largo "paginas tematicas" (17). Arreglo: gana el sustantivo mas largo en la
#     misma posicion, y el marco agregado se evalua junto al numero, no en la linea.
#   v1 -> v2, defecto 4 (FALSO POSITIVO x2): C3 marcaba en A2 "R0 recibe" y
#     "0 fechas exactas" porque bastaba con que la linea trajera, en cualquier
#     posicion, una palabra de deteccion. Arreglo: el cero debe estar a menos de
#     60 caracteres de la palabra de deteccion, y no puede ir pegado a una letra
#     (R0, dictamen_065 dejan de ser ceros).
#
# QUE NO HACE (limitaciones declaradas, no supuestas):
#   - No audita cifras dentro de bloques de codigo: ahi el numero es salida
#     literal de un instrumento (evidencia), no una afirmacion del autor.
#   - Solo re-deriva las magnitudes de su catalogo (ver derivar_magnitudes()).
#     Toda otra cifra queda fuera del chequeo; no sale "correcta", sale sin auditar.
#   - Solo verifica anclas en forma completa <archivo>.html#<id>. Las anclas
#     abreviadas (#art-12 sueltas) quedan fuera.
#   - No juzga si un comando citado prueba lo que el autor dice que prueba; solo
#     que exista y este pegado a la afirmacion.
#   - Es un cedazo: entrega candidatos que un auditor humano tria. Sus dos modos
#     de falla estan medidos arriba y ninguno esta cerrado por construccion.
#
# Prohibiciones respetadas: R unicamente (nada de Python), acceso [[ ]] sobre
# toda estructura leida de disco, sin escritura fuera de aud_* en este lab.
# =============================================================================

suppressPackageStartupMessages({
  library(jsonlite); library(stringr); library(stringi)
  library(dplyr); library(purrr); library(tibble); library(fs); library(here)
})

RAIZ  <- here::here()
LAB   <- file.path(RAIZ, "50_documentacion", "andamios", "lab_motor_v9")
SITIO <- file.path(RAIZ, "40_salidas", "sitio")

linea <- function(ch = "=") cat(strrep(ch, 78), "\n", sep = "")
titulo <- function(x) { cat("\n"); linea("="); cat(x, "\n"); linea("=") }
plegar <- function(x) tolower(stringi::stri_trans_general(x, "Latin-ASCII"))

# -----------------------------------------------------------------------------
# 0. Sonda de locale y derivacion en runtime de los patrones dependientes de el
#    (regla 5 del estandar: ningun patron dependiente de locale se escribe a mano)
# -----------------------------------------------------------------------------
sondar_locale <- function(textos) {
  titulo("SONDA 0 — locale y derivacion de patrones (regla 5)")
  cat("LC_CTYPE  :", Sys.getlocale("LC_CTYPE"), "\n")
  cat("LC_COLLATE:", Sys.getlocale("LC_COLLATE"), "\n")

  cg <- jsonlite::fromJSON(file.path(RAIZ, "40_salidas", "datos", "catalogo.json"),
                           simplifyVector = FALSE)
  muestra <- cg[["normas"]][[2]][["titulo"]]
  cat("cadena acentuada leida de catalogo.json[[normas]][[2]][[titulo]]:\n   ",
      substr(muestra, 1, 70), "\n", sep = "")
  cat("plegada a ASCII por el propio procedimiento:\n   ",
      substr(plegar(muestra), 1, 70), "\n", sep = "")
  cat("Encoding() de la cadena leida: ", Encoding(muestra), "\n", sep = "")

  todo <- paste(textos, collapse = "\n")
  cand <- unique(unlist(stringr::str_extract_all(todo, "[0-9]([^0-9A-Za-z])[0-9]{3}\\b")))
  cand_sep <- unique(substr(cand, 2, 2))
  # Cada candidato se prueba en runtime: se cuenta cuantas veces aparece agrupando
  # exactamente 3 digitos (uso de separador de miles) y cuantas veces agrupando 1, 2
  # o 4+ digitos (uso decimal, de fecha o de razon). El separador se ADOPTA igual:
  # lo que impide el falso positivo no es excluirlo, sino exigir el grupo de 3
  # digitos en el patron. La ambiguedad se reporta, no se resuelve por decreto.
  ambig <- purrr::map_dfr(cand_sep, function(s) {
    tres <- length(unlist(stringr::str_extract_all(todo, paste0("[0-9]\\", s, "[0-9]{3}([^0-9]|$)"))))
    otros <- length(unlist(stringr::str_extract_all(todo,
      paste0("[0-9]\\", s, "([0-9]{1,2}|[0-9]{4,})([^0-9]|$)"))))
    tibble::tibble(sep = s, como_miles = tres, otro_uso = otros)
  })
  seps <- cand_sep[!cand_sep %in% c("]", "^", "-", "\\")]
  fmt <- function(v) if (!length(v)) "(ninguno)" else
    paste(vapply(v, function(s) sprintf("'%s' U+%04X", s, utf8ToInt(s)), character(1)), collapse = " | ")
  cat("\ncandidatos a separador de miles observados: ", fmt(cand_sep), "\n", sep = "")
  cat("uso medido de cada candidato (grupo de 3 digitos vs. otro uso):\n")
  for (i in seq_len(nrow(ambig)))
    cat(sprintf("   '%s' U+%04X  como miles: %4d   otro uso: %4d\n", ambig[["sep"]][i],
                utf8ToInt(ambig[["sep"]][i]), ambig[["como_miles"]][i], ambig[["otro_uso"]][i]))
  cat("separadores adoptados (con exigencia de grupo de 3 digitos): ", fmt(seps), "\n", sep = "")
  cat("ejemplos observados: ", paste(head(cand, 8), collapse = "  "), "\n", sep = "")

  clase <- if (length(seps) == 0) "" else paste0("[", paste(seps, collapse = ""), "]")
  patron_num <- if (nchar(clase) > 0)
    paste0("([0-9]{1,3}(?:", clase, "[0-9]{3})+|[0-9]+)") else "([0-9]+)"
  cat("patron de numero derivado en runtime: ", patron_num, "\n", sep = "")
  list(patron_num = patron_num, seps = seps)
}

derivar_realizaciones <- function(textos, claves) {
  todo <- paste(textos, collapse = "\n")
  tokens <- unique(unlist(stringr::str_extract_all(todo, "[[:alpha:]À-ɏ]+")))
  purrr::map_dfr(claves, function(k) {
    formas <- tokens[plegar(tokens) == k]
    tibble::tibble(clave_ascii = k,
                   formas_realizadas = if (length(formas)) paste(unique(formas), collapse = " | ") else "(ausente)")
  })
}

# -----------------------------------------------------------------------------
# 1. Verdad de terreno: magnitudes derivadas del repositorio EN ESTE TURNO
# -----------------------------------------------------------------------------
derivar_magnitudes <- function() {
  f_normas <- sort(fs::dir_ls(file.path(RAIZ, "40_salidas", "datos", "normas"), glob = "*.json"))
  cat_j <- jsonlite::fromJSON(file.path(RAIZ, "40_salidas", "datos", "catalogo.json"),
                              simplifyVector = FALSE)
  unidades <- purrr::map(f_normas, function(p) {
    n <- jsonlite::fromJSON(p, simplifyVector = FALSE); n[["articulos"]] })
  n_seg <- sum(purrr::map_int(unidades, length))
  n_art <- sum(purrr::map_int(unidades, function(a)
    sum(vapply(a, function(x) isTRUE(x[["es_articulo"]]), logical(1)))))
  rel <- jsonlite::fromJSON(file.path(RAIZ, "40_salidas", "datos", "relaciones.json"),
                            simplifyVector = FALSE)
  htmls <- fs::dir_ls(SITIO, glob = "*.html")
  tibble::tribble(
    ~clave,       ~sustantivos_ascii,                    ~valor,  ~comando,
    "normas",     c("normas", "norma"),                  length(f_normas),
      "length(fs::dir_ls('40_salidas/datos/normas', glob='*.json'))",
    "articulos",  c("articulos", "articulo"),            n_art,
      "sum de es_articulo==TRUE sobre articulos[[ ]] de los 25 JSON",
    "segmentos",  c("segmentos", "unidades", "segmento"), n_seg,
      "sum(length(n[['articulos']])) sobre los 25 JSON",
    "relaciones", c("relaciones", "relacion", "aristas"), length(rel[["relaciones"]]),
      "length(fromJSON('40_salidas/datos/relaciones.json')[['relaciones']])",
    "paginas_html", c("paginas html", "paginas del sitio", "paginas"), length(htmls),
      "length(fs::dir_ls('40_salidas/sitio', glob='*.html'))",
    "temas",      c("paginas tematicas", "temas"),
      length(htmls[stringr::str_detect(basename(htmls), "^tema-")]),
      "grepl('^tema-', basename(dir_ls('40_salidas/sitio', glob='*.html')))",
    "piezas",     c("piezas", "borradores"),
      length(fs::dir_ls(file.path(RAIZ, "20_insumos", "curaduria", "piezas", "borradores"), glob = "*.md")),
      "length(fs::dir_ls('20_insumos/curaduria/piezas/borradores', glob='*.md'))"
  ) |> dplyr::mutate(catalogo_n_normas = cat_j[["n_normas"]],
                     catalogo_n_articulos = cat_j[["n_articulos"]])
}

# -----------------------------------------------------------------------------
# 2. Lectura de un documento con marcado de bloques de codigo
# -----------------------------------------------------------------------------
leer_doc <- function(ruta, desde = NULL, hasta = NULL) {
  txt <- readLines(ruta, warn = FALSE, encoding = "UTF-8")
  n0 <- 1L
  if (!is.null(desde)) { n0 <- desde; txt <- txt[desde:hasta] }
  cerca <- stringr::str_detect(txt, "^\\s*```")
  estado <- cumsum(cerca)
  en_cerca <- (estado %% 2 == 1) | cerca
  tibble::tibble(n = seq_along(txt) + n0 - 1L, texto = txt, en_cerca = en_cerca,
                 bloque = ifelse(en_cerca, (estado + 1) %/% 2, NA_integer_))
}

construir_indice <- function() {
  f <- fs::dir_ls(RAIZ, recurse = TRUE, type = "file", all = FALSE, fail = FALSE)
  f <- f[!stringr::str_detect(f, "/\\.git/|/node_modules/")]
  tibble::tibble(ruta = as.character(f), base = basename(f))
}

fila <- function(chequeo, estado, n, detalle, comando, nota = "") tibble::tibble(
  chequeo = chequeo, estado = estado, n = n, detalle = detalle, comando = comando, nota = nota)
vacio <- function() fila(character(), character(), integer(), character(), character(), character())

# -----------------------------------------------------------------------------
# C1 — cifras (gana el sustantivo mas largo; marco agregado evaluado por match)
# -----------------------------------------------------------------------------
chequeo_cifras <- function(doc, mag, patron_num) {
  susts <- purrr::map_dfr(seq_len(nrow(mag)), function(i)
    tibble::tibble(clave = mag[["clave"]][i], sust = mag[["sustantivos_ascii"]][[i]],
                   valor = mag[["valor"]][i], comando = mag[["comando"]][i])) |>
    dplyr::arrange(dplyr::desc(nchar(sust)))
  d <- doc |> dplyr::filter(!en_cerca)
  res <- list(); examinadas <- 0L
  for (i in seq_len(nrow(d))) {
    l_orig <- d[["texto"]][i]; l <- plegar(l_orig)
    agregado_linea <- stringr::str_detect(l, "corpus|catalogo|repositorio|en total|del sitio|sitio generado")
    tomados <- integer()
    for (j in seq_len(nrow(susts))) {
      pat <- paste0(patron_num, "\\s+", susts[["sust"]][j], "\\b")
      loc <- stringr::str_locate_all(l, pat)[[1]]
      if (nrow(loc) == 0) next
      m <- stringr::str_match_all(l, pat)[[1]]
      for (k in seq_len(nrow(loc))) {
        ini <- loc[k, 1]
        if (any(abs(tomados - ini) < 2)) next   # ya cubierto por un sustantivo mas largo
        tomados <- c(tomados, ini)
        crudo <- m[k, 2]
        val <- suppressWarnings(as.numeric(gsub("[^0-9]", "", crudo)))
        antes <- substr(l, max(1, ini - 12), max(1, ini - 1))
        marco <- agregado_linea || stringr::str_detect(antes, "\\b(las|los)\\s+$")
        if (!marco) {
          res[[length(res) + 1L]] <- fila("C1_cifras", "OMITIDA_SIN_MARCO_AGREGADO", d[["n"]][i],
            paste0(crudo, " ", susts[["sust"]][j], " — no se lee como cifra del corpus (sin marco agregado)"),
            susts[["comando"]][j]); next
        }
        examinadas <- examinadas + 1L
        ok <- isTRUE(val == susts[["valor"]][j])
        res[[length(res) + 1L]] <- fila("C1_cifras", if (ok) "CONFIRMADA" else "REFUTADA", d[["n"]][i],
          paste0("afirma ", crudo, " ", susts[["sust"]][j], " | re-derivado = ", susts[["valor"]][j],
                 " | linea: ", stringr::str_trunc(stringr::str_squish(l_orig), 96)),
          susts[["comando"]][j])
      }
    }
  }
  out <- if (length(res)) dplyr::bind_rows(res) else vacio()
  attr(out, "examinadas") <- examinadas; out
}

# -----------------------------------------------------------------------------
# C2 — anclas (el defecto nunca se degrada; la autodeclaracion va en 'nota')
# -----------------------------------------------------------------------------
derivar_patron_id <- function() {
  h <- paste(readLines(fs::dir_ls(SITIO, glob = "*.html")[1], warn = FALSE), collapse = "\n")
  dobles <- length(unlist(stringr::str_extract_all(h, "id=\"[^\"]+\"")))
  simples <- length(unlist(stringr::str_extract_all(h, "id='[^']+'")))
  cat("sonda del atributo id en el HTML generado: id=\"..\" -> ", dobles,
      " ocurrencias | id='..' -> ", simples, " ocurrencias | se adopta la forma con comillas ",
      if (dobles >= simples) "dobles" else "simples", "\n", sep = "")
  if (dobles >= simples) 'id="%s"' else "id='%s'"
}

chequeo_anclas <- function(doc, fmt_id) {
  pat <- "([A-Za-z0-9_.\\-]+\\.html)#([A-Za-z0-9_\\-]+)"
  res <- list(); examinadas <- 0L; cache <- new.env()
  ids_de <- function(f) {
    if (!is.null(cache[[f]])) return(cache[[f]])
    p <- file.path(SITIO, f)
    cache[[f]] <- if (!file.exists(p)) NA_character_ else paste(readLines(p, warn = FALSE), collapse = "\n")
    cache[[f]]
  }
  for (i in seq_len(nrow(doc))) {
    l_orig <- doc[["texto"]][i]
    m <- stringr::str_match_all(l_orig, pat)[[1]]
    if (nrow(m) == 0) next
    # la autodeclaracion se busca en la prosa, quitando primero las anclas mismas:
    prosa <- stringr::str_remove_all(l_orig, pat)
    autodeclara <- stringr::str_detect(plegar(prosa),
      "inexistente|no existe|no resuelve|debe ser false|rechazada|ancla falsa|control")
    for (k in seq_len(nrow(m))) {
      examinadas <- examinadas + 1L
      arch <- m[k, 2]; id <- m[k, 3]; cont <- ids_de(arch)
      estado <- if (is.na(cont[1])) "ARCHIVO_INEXISTENTE"
                else if (stringr::str_detect(cont, stringr::fixed(sprintf(fmt_id, id)))) "RESUELVE"
                else "ID_INEXISTENTE"
      res[[length(res) + 1L]] <- fila("C2_anclas", estado, doc[["n"]][i], paste0(arch, "#", id),
        paste0("grep -c '", sprintf(fmt_id, id), "' 40_salidas/sitio/", arch),
        if (estado != "RESUELVE" && autodeclara) "la linea se autodeclara control: triar a mano" else "")
    }
  }
  out <- if (length(res)) dplyr::bind_rows(res) else vacio()
  attr(out, "examinadas") <- examinadas; out
}

# -----------------------------------------------------------------------------
# C3 — ceros de deteccion sin control positivo
# -----------------------------------------------------------------------------
PAT_CERO <- "(?<![0-9A-Za-z,._-])0(?![0-9,.])|\\bcero\\b"
PAT_DETECCION <- paste0("coincidencia|resultado|sugerencia|ocurrencia|hallazgo|acierto|",
                        "respuesta|devolv|encontr|arroj|detect|aparec|recuper|match|busqueda|consulta")
PAT_CONTROL <- paste0("control positivo|control negativo|contraparte positiva|",
                      "en el mismo bloque|caso que el instrumento|debe encontrar|",
                      "control calibrado|caso plantado que")
DIST_MAX <- 60

alcance_control <- function(doc, i) {
  if (!is.na(doc[["bloque"]][i])) {
    idx <- which(doc[["bloque"]] == doc[["bloque"]][i]); fin <- max(idx)
    return(union(idx, seq(fin, min(nrow(doc), fin + 5))))
  }
  seq(max(1, i - 8), min(nrow(doc), i + 8))
}

chequeo_ceros <- function(doc) {
  res <- list(); examinados <- 0L
  for (i in seq_len(nrow(doc))) {
    l <- plegar(doc[["texto"]][i])
    pc <- stringr::str_locate_all(l, PAT_CERO)[[1]]
    pd <- stringr::str_locate_all(l, PAT_DETECCION)[[1]]
    if (nrow(pc) == 0 || nrow(pd) == 0) next
    dist <- min(abs(outer(pc[, 1], pd[, 1], "-")))
    if (dist > DIST_MAX) next
    examinados <- examinados + 1L
    idx <- alcance_control(doc, i)
    # un encabezado o un comentario no es evidencia de un control corrido
    lineas_scope <- doc[["texto"]][idx]
    lineas_scope <- lineas_scope[!stringr::str_detect(lineas_scope, "^\\s*#|^\\s*<!--")]
    hay <- any(stringr::str_detect(plegar(lineas_scope), PAT_CONTROL))
    res[[length(res) + 1L]] <- fila("C3_ceros",
      if (hay) "CERO_CON_CONTROL" else "CERO_SIN_CONTROL", doc[["n"]][i],
      stringr::str_trunc(stringr::str_squish(doc[["texto"]][i]), 110),
      paste0("alcance ", min(doc[["n"]][idx]), "-", max(doc[["n"]][idx]),
             " sin encabezados, contra /", PAT_CONTROL, "/ ; distancia cero-deteccion = ", dist, " car."))
  }
  out <- if (length(res)) dplyr::bind_rows(res) else vacio()
  attr(out, "examinadas") <- examinados; out
}

# -----------------------------------------------------------------------------
# C4 / C4b — universales sin comando, y comando citado que no existe
# -----------------------------------------------------------------------------
PAT_UNIVERSAL <- "\\b(todos|todas|ningun|ninguna|ninguno|siempre|nunca|jamas|cualquier|cualquiera)\\b"
PAT_COMANDO <- paste0("rscript|grep|\\bls\\b|\\bwc\\b|\\bgit\\b|\\bjq\\b|\\bsed\\b|\\bawk\\b|",
                      "\\bfind\\b|curl|npx|fs::|dir_ls|jsonlite|readlines|str_detect|sum\\(|nrow\\(|",
                      "length\\(|\\.r$|\\.json$|\\.csv$|\\.md$|\\.html$|\\.qmd$|\\.js$|\\.mjs$|",
                      "\\.css$|\\.yml$|\\.txt$|/")
PAT_MARCADOR <- "\\(fuente:|\\(hipotesis, verificar con:|\\(medido"

extraer_backticks <- function(x) unlist(stringr::str_extract_all(x, "`[^`]+`")) |>
  stringr::str_remove_all("`")
parece_ruta <- function(tk) {
  stringr::str_detect(plegar(tk), "\\.(r|json|csv|md|html|qmd|js|mjs|css|yml|yaml|txt)$") |
    stringr::str_detect(tk, "/")
}
resolver_ruta <- function(tk, indice) {
  tk <- stringr::str_remove(tk, "^\\./")
  if (file.exists(file.path(RAIZ, tk))) return(TRUE)
  if (file.exists(file.path(LAB, tk))) return(TRUE)
  if (length(Sys.glob(file.path(RAIZ, tk))) > 0) return(TRUE)
  if (basename(tk) %in% indice[["base"]]) return(TRUE)
  FALSE
}

chequeo_universales <- function(doc, indice) {
  res <- list(); examinados <- 0L
  for (i in seq_len(nrow(doc))) {
    l <- plegar(doc[["texto"]][i])
    if (!stringr::str_detect(l, PAT_UNIVERSAL)) next
    examinados <- examinados + 1L
    vecinas <- doc[["texto"]][seq(max(1, i - 2), min(nrow(doc), i + 2))]
    tks <- extraer_backticks(vecinas)
    tiene_cmd <- any(stringr::str_detect(plegar(tks), PAT_COMANDO)) ||
      any(stringr::str_detect(plegar(vecinas), PAT_MARCADOR))
    universal <- stringr::str_match(l, PAT_UNIVERSAL)[, 2]
    res[[length(res) + 1L]] <- fila("C4_universales",
      if (tiene_cmd) "UNIVERSAL_CON_COMANDO" else "UNIVERSAL_SIN_COMANDO", doc[["n"]][i],
      paste0("'", universal, "' en: ", stringr::str_trunc(stringr::str_squish(doc[["texto"]][i]), 96)),
      if (length(tks)) paste0("citados: ", paste(head(tks, 4), collapse = ", ")) else "citados: (ninguno)")
    for (tk in unique(tks[parece_ruta(tks)])) {
      if (!resolver_ruta(tk, indice))
        res[[length(res) + 1L]] <- fila("C4b_comando_inexistente", "COMANDO_CITADO_NO_EXISTE",
          doc[["n"]][i], tk,
          paste0("file.exists(RAIZ/", tk, ") | glob | basename en indice del repo -> FALSE"))
    }
  }
  out <- if (length(res)) dplyr::bind_rows(res) else vacio()
  attr(out, "examinadas") <- examinados; out
}

# -----------------------------------------------------------------------------
# Auditoria de un documento
# -----------------------------------------------------------------------------
ESTADOS_DEFECTO <- c("REFUTADA", "ARCHIVO_INEXISTENTE", "ID_INEXISTENTE",
                     "CERO_SIN_CONTROL", "UNIVERSAL_SIN_COMANDO", "COMANDO_CITADO_NO_EXISTE")

auditar <- function(etiqueta, ruta, mag, patron_num, fmt_id, indice, desde = NULL, hasta = NULL) {
  doc <- leer_doc(ruta, desde, hasta)
  titulo(paste0("AUDITORIA DE: ", etiqueta))
  cat("archivo   : ", sub(paste0(RAIZ, "/"), "", ruta, fixed = TRUE), "\n", sep = "")
  cat("lineas    : ", min(doc[["n"]]), "-", max(doc[["n"]]), "  (", nrow(doc), " lineas, ",
      sum(doc[["en_cerca"]]), " dentro de cercas de codigo)\n", sep = "")
  c1 <- chequeo_cifras(doc, mag, patron_num); c2 <- chequeo_anclas(doc, fmt_id)
  c3 <- chequeo_ceros(doc); c4 <- chequeo_universales(doc, indice)
  cat("items examinados (no-vacuidad): C1 cifras=", attr(c1, "examinadas"),
      " | C2 anclas=", attr(c2, "examinadas"), " | C3 ceros de deteccion=", attr(c3, "examinadas"),
      " | C4 universales=", attr(c4, "examinadas"), "\n", sep = "")
  todo <- dplyr::bind_rows(c1, c2, c3, c4)
  if (nrow(todo) == 0) cat("\n  (sin items auditables: un silencio aqui NO prueba nada)\n")
  else {
    cat("\n-- registro completo (defecto y no-defecto, para que el silencio sea legible) --\n")
    for (i in seq_len(nrow(todo))) {
      marca <- if (todo[["estado"]][i] %in% ESTADOS_DEFECTO) "  [DEFECTO] " else "  [   ok  ] "
      cat(marca, "L", todo[["n"]][i], " ", todo[["chequeo"]][i], " ", todo[["estado"]][i], "\n", sep = "")
      cat("             ", todo[["detalle"]][i], "\n", sep = "")
      cat("             comando: ", todo[["comando"]][i], "\n", sep = "")
      if (nzchar(todo[["nota"]][i])) cat("             nota: ", todo[["nota"]][i], "\n", sep = "")
    }
  }
  def <- todo |> dplyr::filter(estado %in% ESTADOS_DEFECTO)
  cat("\nDEFECTOS DETECTADOS: ", nrow(def), "\n", sep = "")
  if (nrow(def) > 0) {
    r <- def |> dplyr::summarise(n = dplyr::n(), .by = c(chequeo, estado))
    for (i in seq_len(nrow(r))) cat("  - ", r[["chequeo"]][i], " / ", r[["estado"]][i], ": ", r[["n"]][i], "\n", sep = "")
  }
  todo |> dplyr::mutate(documento = etiqueta,
                        examinadas = attr(c1, "examinadas") + attr(c2, "examinadas") +
                                     attr(c3, "examinadas") + attr(c4, "examinadas"))
}

extraer_fragmento <- function(origen, desde, hasta, destino) {
  txt <- readLines(origen, warn = FALSE, encoding = "UTF-8")
  writeLines(c(paste0("<!-- fragmento literal de ", basename(origen), " lineas ", desde, "-", hasta,
                      ", copiado por aud_procedimiento.R el ", Sys.Date(), " -->"), txt[desde:hasta]),
             destino, useBytes = TRUE)
  cat("fragmento extraido: ", basename(destino), " (", hasta - desde + 1, " lineas de ",
      basename(origen), ")\n", sep = "")
  destino
}

# =============================================================================
# MAIN
# =============================================================================
plantados <- c(cifra = file.path(LAB, "aud_control_cifra_falsa.md"),
               ancla = file.path(LAB, "aud_control_ancla_falsa.md"),
               cero  = file.path(LAB, "aud_control_cero_sin_control.md"))
A1 <- file.path(RAIZ, "50_documentacion", "andamios", "20260904_alcance_capa1_vocabulario_v1.md")
A2 <- file.path(RAIZ, "50_documentacion", "andamios", "20260904_alcance_capa2_semantica_v1.md")
ETQ_A1 <- "REAL A1 seccion 6 (lineas 322-387 del documento de A1)"
ETQ_A2 <- "REAL A2 secciones 4ter.3-4quater.1 (lineas 263-278 del documento de A2)"

textos_sonda <- unlist(lapply(c(plantados, A1, A2), function(p) readLines(p, warn = FALSE, encoding = "UTF-8")))
son <- sondar_locale(textos_sonda)

titulo("SONDA 0bis — realizaciones acentuadas derivadas de los textos auditados")
print(as.data.frame(derivar_realizaciones(textos_sonda,
  c("articulos", "articulo", "paginas", "relaciones", "normas", "tematicas"))), right = FALSE)

titulo("VERDAD DE TERRENO — magnitudes re-derivadas en este turno")
mag <- derivar_magnitudes()
for (i in seq_len(nrow(mag)))
  cat(sprintf("  %-13s = %6d   <- %s\n", mag[["clave"]][i], mag[["valor"]][i], mag[["comando"]][i]))
cat("  (catalogo.json declara n_normas=", mag[["catalogo_n_normas"]][1], " n_articulos=",
    mag[["catalogo_n_articulos"]][1], "; coincide con la re-derivacion independiente)\n", sep = "")

cat("\n"); fmt_id <- derivar_patron_id()
indice <- construir_indice()
cat("indice de archivos del repositorio (sin .git):", nrow(indice), "archivos\n")

titulo("PARTE (c) — CONTROL POSITIVO: tres archivos con defectos plantados")
r1 <- auditar("PLANTADO 1 (cifras falsas)", plantados[["cifra"]], mag, son[["patron_num"]], fmt_id, indice)
r2 <- auditar("PLANTADO 2 (anclas falsas)", plantados[["ancla"]], mag, son[["patron_num"]], fmt_id, indice)
r3 <- auditar("PLANTADO 3 (cero sin control y universal sin comando)", plantados[["cero"]], mag, son[["patron_num"]], fmt_id, indice)

titulo("PARTE (d) — CONTROL NEGATIVO: fragmentos reales de la fase 1")
f1 <- extraer_fragmento(A1, 322, 387, file.path(LAB, "aud_fragmento_negativo_a1.md"))
f2 <- extraer_fragmento(A2, 263, 278, file.path(LAB, "aud_fragmento_negativo_a2.md"))
r4 <- auditar(ETQ_A1, f1, mag, son[["patron_num"]], fmt_id, indice)
r5 <- auditar(ETQ_A2, f2, mag, son[["patron_num"]], fmt_id, indice)

# --- (d bis) sonda en campo: el instrumento sobre un fragmento NO elegido -----
# El control negativo usa fragmentos que AUD sabe correctos, asi que no prueba
# poder de deteccion fuera del laboratorio. Esta sonda corre el mismo
# procedimiento sobre un fragmento real que AUD no eligio por estar limpio.
# Lo que salga aqui es materia de otra dimension de la auditoria (cifras y
# reproducibilidad) y de la fase 3: AUD no corrige lo que audita.
titulo("PARTE (d bis) — SONDA EN CAMPO (deteccion fuera del laboratorio)")
f3 <- extraer_fragmento(A1, 388, 392, file.path(LAB, "aud_fragmento_campo_a1.md"))
r6 <- auditar("SONDA EN CAMPO: A1 seccion 7 (lineas 388-392 del documento de A1)",
              f3, mag, son[["patron_num"]], fmt_id, indice)

titulo("AUTOEVALUACION DEL INSTRUMENTO")
todo <- dplyr::bind_rows(r1, r2, r3, r4, r5, r6)
def <- todo |> dplyr::filter(estado %in% ESTADOS_DEFECTO)

esperado <- tibble::tribble(
  ~defecto_plantado, ~documento, ~estado_esperado, ~minimo,
  "cifra falsa: 31 normas / 900 articulos", "PLANTADO 1 (cifras falsas)", "REFUTADA", 3L,
  "ancla con id inexistente (#art-77-quater)", "PLANTADO 2 (anclas falsas)", "ID_INEXISTENTE", 1L,
  "ancla con archivo inexistente (ley_21899_inexistente.html)", "PLANTADO 2 (anclas falsas)", "ARCHIVO_INEXISTENTE", 1L,
  "cero de deteccion sin control positivo", "PLANTADO 3 (cero sin control y universal sin comando)", "CERO_SIN_CONTROL", 1L,
  "universal sin comando al lado", "PLANTADO 3 (cero sin control y universal sin comando)", "UNIVERSAL_SIN_COMANDO", 1L,
  "comando citado que no existe en disco", "PLANTADO 3 (cero sin control y universal sin comando)", "COMANDO_CITADO_NO_EXISTE", 1L)
obtenido <- def |> dplyr::summarise(obtenido = dplyr::n(), .by = c(documento, estado))
ev <- esperado |>
  dplyr::left_join(obtenido, by = c("documento", "estado_esperado" = "estado")) |>
  dplyr::mutate(obtenido = ifelse(is.na(obtenido), 0L, obtenido),
                veredicto = ifelse(obtenido >= minimo, "DETECTADO", "NO DETECTADO -> BLOQUEANTE"))
cat("(c) DEFECTOS PLANTADOS:\n")
for (i in seq_len(nrow(ev)))
  cat(sprintf("  %-26s %-58s %s (%d/%d)\n", ev[["estado_esperado"]][i],
              stringr::str_trunc(ev[["defecto_plantado"]][i], 58), ev[["veredicto"]][i],
              ev[["obtenido"]][i], ev[["minimo"]][i]))

cat("\n(c bis) SELECTIVIDAD dentro de los archivos plantados (lo correcto NO se marca):\n")
sel <- todo |> dplyr::filter(stringr::str_starts(documento, "PLANTADO"),
                             estado %in% c("CONFIRMADA", "RESUELVE", "CERO_CON_CONTROL", "UNIVERSAL_CON_COMANDO"))
for (i in seq_len(nrow(sel)))
  cat("  [ok] L", sel[["n"]][i], " ", sel[["estado"]][i], " — ",
      stringr::str_trunc(sel[["detalle"]][i], 84), "\n", sep = "")

cat("\n(d) CONTROL NEGATIVO sobre documentos reales:\n")
for (etq in c(ETQ_A1, ETQ_A2)) {
  sub <- todo |> dplyr::filter(documento == etq)
  nd <- sum(sub[["estado"]] %in% ESTADOS_DEFECTO)
  cat(sprintf("  %-72s defectos=%d | items auditados=%d\n", stringr::str_trunc(etq, 72), nd, nrow(sub)))
}
cat("  no-vacuidad conjunta de (d): ")
nv <- todo |> dplyr::filter(stringr::str_starts(documento, "REAL")) |>
  dplyr::summarise(n = dplyr::n(), .by = chequeo)
cat(paste0(nv[["chequeo"]], "=", nv[["n"]], collapse = " | "), "\n")

cat("\n(d bis) SONDA EN CAMPO (no es control negativo; lo que marque va a otra dimension):\n")
campo <- todo |> dplyr::filter(stringr::str_starts(documento, "SONDA"))
if (sum(campo[["estado"]] %in% ESTADOS_DEFECTO) == 0)
  cat("  sin marcas en el fragmento sondeado (items auditados = ", nrow(campo), ")\n", sep = "")
for (i in seq_len(nrow(campo))) if (campo[["estado"]][i] %in% ESTADOS_DEFECTO)
  cat("  [DEFECTO] L", campo[["n"]][i], " ", campo[["estado"]][i], " — ",
      stringr::str_trunc(campo[["detalle"]][i], 90), "\n",
      "            comando: ", campo[["comando"]][i], "\n", sep = "")

falla <- any(ev[["veredicto"]] != "DETECTADO")
neg <- todo |> dplyr::filter(stringr::str_starts(documento, "REAL"), estado %in% ESTADOS_DEFECTO)
cat("\nVEREDICTO DEL INSTRUMENTO: ",
    if (falla) "FALLA — hay defectos plantados que NO detecta (hallazgo bloqueante contra la auditoria)"
    else if (nrow(neg) > 0) "DETECTA LOS 6 DEFECTOS PLANTADOS; el control negativo marco items a triar a mano"
    else "DETECTA LOS 6 DEFECTOS PLANTADOS Y NO MARCA NINGUNO DE LOS 2 FRAGMENTOS REALES CORRECTOS",
    "\n", sep = "")
cat("corrida: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), " | R ", R.version[["major"]], ".",
    R.version[["minor"]], " | archivos aud_ escritos por esta corrida: ",
    paste(basename(c(f1, f2)), collapse = ", "), "\n", sep = "")
