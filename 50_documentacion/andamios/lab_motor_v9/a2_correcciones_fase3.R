# =============================================================================
# a2_correcciones_fase3.R
# Encargo v9, FASE 3 (correccion). Agente A2.
#
# Re-deriva, en un solo turno y con su control al lado, TODAS las cifras que la
# auditoria refuto en 20260904_alcance_capa2_semantica_v1.md, mas las que el
# panel adversarial (H-16) obliga a desdoblar. Ninguna cifra de este script se
# hereda de un documento: todas se recuentan aqui.
#
# Ejecutar desde la raiz del repo:
#   Rscript 50_documentacion/andamios/lab_motor_v9/a2_correcciones_fase3.R
#
# Contrato de escritura: SOLO escribe en 50_documentacion/andamios/lab_motor_v9/
# con prefijo "a2_". Lee 40_salidas/ en modo lectura y no la toca (invariante
# verificado al cierre). No reindexa: sirve el sitio ya construido por HTTP local
# y consulta el indice Pagefind existente con la API JavaScript.
# R exclusivamente. `[[ ]]` sobre todo lo leido de disco.
# =============================================================================

paquetes <- c("jsonlite", "dplyr", "purrr", "tibble", "readr", "stringr",
              "stringi", "here", "fs", "servr")
faltan <- paquetes[!vapply(paquetes, requireNamespace, TRUE, quietly = TRUE)]
if (length(faltan) > 0L) stop("Faltan paquetes: ", paste(faltan, collapse = ", "))
library(dplyr, warn.conflicts = FALSE)

source(here::here("10_utils", "10_configuracion.R"))   # guarda de locale UTF-8 + rutas
LAB <- here::here("50_documentacion", "andamios", "lab_motor_v9")

linea <- function(...) cat(paste0(..., collapse = ""), "\n", sep = "")
seccion <- function(t) cat("\n==== ", t, " ====\n", sep = "")

foto_salidas <- function() {
  inf <- fs::dir_info(here::here("40_salidas"), recurse = TRUE, type = "file", all = TRUE)
  list(n = nrow(inf), mtime_max = max(inf[["modification_time"]]))
}
foto_antes <- foto_salidas()
linea("40_salidas/ antes: ", foto_antes[["n"]], " archivos, mtime max ",
      format(foto_antes[["mtime_max"]]))

BM <- 57.7916   # bytes de metadatos minimos por unidad (medido en TAREA 3)

# ---------------------------------------------------------------------------
seccion("CIF-A2-01: aporte de los 4 dictamenes y las 3 REX")
cat_json <- jsonlite::fromJSON(here::here("40_salidas", "datos", "catalogo.json"),
                               simplifyVector = FALSE)
normas_cat <- purrr::map_dfr(cat_json[["normas"]], function(n) tibble::tibble(
  slug = n[["slug"]], seg = n[["n_segmentos"]], art = n[["n_articulos"]],
  origen = n[["origen_texto"]]))
sel <- grepl("^dictamen|^rex", normas_cat[["slug"]])
print(as.data.frame(normas_cat[sel, ]))
linea("documentos seleccionados: ", sum(sel),
      " | suma segmentos: ", sum(normas_cat[["seg"]][sel]),
      " | suma articulos: ", sum(normas_cat[["art"]][sel]))
linea("de ellos, firmados (capa_texto_pdf): ",
      sum(normas_cat[["seg"]][sel & normas_cat[["origen"]] == "capa_texto_pdf"]),
      " | OCR sin revisar: ",
      sum(normas_cat[["seg"]][sel & normas_cat[["origen"]] == "ocr_pendiente_revision"]))
linea("CONTROL POSITIVO (el instrumento si ve articulos): ley_20845 aporta ",
      normas_cat[["art"]][normas_cat[["slug"]] == "ley_20845_inclusion_escolar"], " articulos")
linea("CONTROL NEGATIVO (patron que no debe existir): slugs '^zzqq' -> ",
      sum(grepl("^zzqq", normas_cat[["slug"]])))

# ---------------------------------------------------------------------------
seccion("CIF-A2-02 y CIF-A2-07 y CIF-A2-12: pesos de indice")
peso <- function(N, dim, bpd) N * dim * bpd + N * BM
kb <- function(b) round(b / 1024, 1)
seg <- function(b) round(b * 8 / 3e6, 2)
linea("1 344 x 1 024 binario (1/8 byte/dim): ", round(peso(1344, 1024, 1/8), 1),
      " bytes = ", kb(peso(1344, 1024, 1/8)), " KB (", seg(peso(1344, 1024, 1/8)), " s)")
linea("CONTROL de la misma formula, fila vecina 806 x 1 024 binario: ",
      kb(peso(806, 1024, 1/8)), " KB (", seg(peso(806, 1024, 1/8)), " s)  <- este es el 146,2")
pind <- readr::read_csv(fs::path(LAB, "a2_peso_indice.csv"), show_col_types = FALSE)
f <- pind[pind[["conjunto"]] == "fragmentos_todos_ventana" & pind[["dim"]] == 1024 &
            pind[["formato"]] == "binario", ]
print(as.data.frame(f))
b722 <- peso(722, 384, 1); b1160 <- peso(1160, 384, 1)
pagina_max <- as.numeric(fs::file_size(here::here("40_salidas", "sitio",
                                                  "dfl_1_estatuto_asistentes_educacion.html")))
linea("indice int8x384: 722 unidades = ", round(b722), " B (", kb(b722), " KB); ",
      "1 160 fragmentos = ", round(b1160), " B (", kb(b1160), " KB)")
linea("HTML mas pesado del sitio = ", pagina_max, " B (", kb(pagina_max), " KB)")
linea("razon indice/pagina: ", round(b722 / pagina_max, 2), " x  y  ",
      round(b1160 / pagina_max, 2), " x  -> ambos SUPERAN la pagina mas pesada: ",
      b722 > pagina_max, " / ", b1160 > pagina_max)
linea("CONTROL POSITIVO de la comparacion (algo que si es menor): indice 682x384 binario = ",
      kb(peso(682, 384, 1/8)), " KB < ", kb(pagina_max), " KB -> ",
      peso(682, 384, 1/8) < pagina_max)
html_todos <- sum(as.numeric(fs::dir_info(here::here("40_salidas", "sitio"),
                                          glob = "*.html", type = "file")[["size"]]))
linea("HTML del sitio completo: ", html_todos, " B (", kb(html_todos), " KB)")
linea("CIF-A2-12: umbral de fragmentos por norma = pagina_max / (384 + ", BM, ") = ",
      round(pagina_max / (384 + BM), 1))

# ---------------------------------------------------------------------------
seccion("CIF-A2-03: que fraccion del articulo mas largo cabe en 512 tokens")
j845 <- jsonlite::fromJSON(here::here("40_salidas", "datos", "normas",
                                      "ley_20845_inclusion_escolar.json"), simplifyVector = FALSE)
art3 <- Filter(function(a) a[["id"]] == "art-3", j845[["articulos"]])[[1]][["texto"]]
n3 <- nchar(art3)
linea("nchar(ley_20845#art-3) = ", n3, " | tok_c4 = ", ceiling(n3 / 4))
linea("512 tokens c4 = ", 512 * 4, " caracteres = ", round(100 * 512 * 4 / n3, 2), " % del articulo")
pos <- stringr::str_locate(art3, "quince d")[1, 1]
linea("posicion de 'quince d': caracter ", pos, " de ", n3,
      " -> queda fuera de la ventana de 2 048: ", pos > 512 * 4)
linea("CONTROL NEGATIVO del localizador: 'zzqq inexistente' -> ",
      ifelse(is.na(stringr::str_locate(art3, "zzqq inexistente")[1, 1]), "NA (no esta)", "ENCONTRADO"))

# ---------------------------------------------------------------------------
seccion("CIF-A2-04 y CIF-A2-10: cobertura por K")
lb <- readr::read_csv(fs::path(LAB, "a2_linea_base_pagefind.csv"), show_col_types = FALSE)
can_c <- lb |>
  filter(.data[["variante"]] == "canonico", .data[["lectura"]] == "C_sub_puntaje") |>
  arrange(.data[["id"]])
rangos <- setNames(can_c[["rango_aceptada"]], can_c[["id"]])
print(rangos)
for (K in c(0L, 3L, 4L, 10L, 27L, 28L, 30L, 65L, 1000L)) {
  linea("K = ", K, " cubre ", sum(!is.na(rangos) & rangos <= K), " de ", length(rangos))
}
linea("estrictamente ANTES del rango 28: ", sum(!is.na(rangos) & rangos < 28),
      " | HASTA el rango 28 (<=): ", sum(!is.na(rangos) & rangos <= 28))

# ---------------------------------------------------------------------------
seccion("CIF-A2-05 / H-20: terminos de contenido de la consulta en su unidad objetivo")
ev <- readr::read_csv(fs::path(LAB, "a2_consultas_evaluacion.csv"), show_col_types = FALSE)
print(as.data.frame(ev[, c("id", "n_terminos", "n_terminos_en_objetivo", "terminos_en_objetivo")]))
cero <- ev[["id"]][ev[["n_terminos_en_objetivo"]] == 0]
linea("consultas con CERO terminos de contenido en su unidad objetivo: ",
      length(cero), " -> ", paste(cero, collapse = ", "))
todos <- ev[["id"]][ev[["n_terminos_en_objetivo"]] == ev[["n_terminos"]]]
linea("CONTROL POSITIVO (la columna no es toda cero): con todos los terminos -> ",
      paste(todos, collapse = ", "))

# ---------------------------------------------------------------------------
seccion("CIF-A2-06: rango de s_L (suma de balanced_score por sub-resultado)")
res <- jsonlite::fromJSON(fs::path(LAB, "a2_resultados_pagefind.json"), simplifyVector = FALSE)
plano <- purrr::map_dfr(res[["consultas"]], function(q) {
  if (length(q[["resultados"]]) == 0L) return(tibble::tibble())
  purrr::map_dfr(q[["resultados"]], function(r) {
    if (length(r[["sub_results"]]) == 0L) return(tibble::tibble())
    purrr::map_dfr(r[["sub_results"]], function(sr) tibble::tibble(
      id = q[["id"]], pagina = fs::path_file(r[["url"]]),
      ancla = if (is.null(sr[["anchor_id"]])) NA_character_ else sr[["anchor_id"]],
      suma_balanced = sr[["suma_balanced"]]))
  })
})
c06 <- plano |> filter(.data[["id"]] == "C06|sin_filtro", !is.na(.data[["ancla"]]))
linea("C06 sin filtro: ", nrow(c06), " sub-resultados con ancla | min ",
      round(min(c06[["suma_balanced"]]), 2), " | max ", round(max(c06[["suma_balanced"]]), 2))
print(as.data.frame(c06 |> arrange(desc(.data[["suma_balanced"]])) |> head(4)))
todo <- plano |> filter(!is.na(.data[["ancla"]]))
linea("sobre las ", dplyr::n_distinct(todo[["id"]]), " consultas medidas: min ",
      round(min(todo[["suma_balanced"]]), 1), " | max ", round(max(todo[["suma_balanced"]]), 1))
linea("CONTROL POSITIVO del aplanador (encuentra el valor que el documento cita): ",
      "hay algun sub-resultado con suma_balanced entre 99 782 y 99 783 en C06 sin filtro: ",
      any(c06[["suma_balanced"]] > 99782 & c06[["suma_balanced"]] < 99783))

# ---------------------------------------------------------------------------
seccion("CIF-A2-08: que rescata terminos_clave frente a sin_filtro")
lect <- c(A = "A_pagina", B = "B_ui_documento", C = "C_sub_puntaje")
comparar <- function(v1, v2) {
  purrr::map_dfr(names(lect), function(L) {
    a <- lb |> filter(.data[["variante"]] == v1, .data[["lectura"]] == lect[[L]]) |> arrange(.data[["id"]])
    b <- lb |> filter(.data[["variante"]] == v2, .data[["lectura"]] == lect[[L]]) |> arrange(.data[["id"]])
    stopifnot(identical(a[["id"]], b[["id"]]))
    tibble::tibble(id = a[["id"]], lectura = L,
                   v1 = a[["rango_aceptada"]], v2 = b[["rango_aceptada"]])
  })
}
d1 <- comparar("sin_filtro", "terminos_clave") |>
  filter(is.na(.data[["v1"]]), !is.na(.data[["v2"]]))
linea("terminos_clave aparece donde sin_filtro NO aparece:")
print(as.data.frame(d1))
linea("CONTROL POSITIVO del comparador (celdas comparadas): ",
      nrow(comparar("sin_filtro", "terminos_clave")),
      " | pares donde ambas aparecen: ",
      sum(!is.na(comparar("sin_filtro", "terminos_clave")[["v1"]]) &
          !is.na(comparar("sin_filtro", "terminos_clave")[["v2"]])))

seccion("CIF-A2-09: canonico frente a canonico_verificado")
d2 <- comparar("canonico", "canonico_verificado") |>
  filter(xor(is.na(.data[["v1"]]), is.na(.data[["v2"]])) |
           (!is.na(.data[["v1"]]) & !is.na(.data[["v2"]]) & .data[["v1"]] != .data[["v2"]]))
linea("filas en que difieren: ", nrow(d2))
print(as.data.frame(d2 |> arrange(.data[["id"]], .data[["lectura"]])))
linea("CONTROL POSITIVO: celdas comparadas = ", nrow(comparar("canonico", "canonico_verificado")),
      " ; celdas IGUALES = ", nrow(comparar("canonico", "canonico_verificado")) - nrow(d2))

# ---------------------------------------------------------------------------
seccion("CIF-A2-11: de que documentos salen las respuestas del conjunto")
esp <- ev[["ancla_esperada"]]
doc_esp <- sub("\\.html#.*$", "", esp)
linea("anclas ESPERADAS que viven en un dictamen o una REX: ",
      paste(ev[["id"]][grepl("^dictamen|^rex", doc_esp)], collapse = ", "),
      "  (n = ", sum(grepl("^dictamen|^rex", doc_esp)), " de ", nrow(ev), ")")
acep_por_consulta <- strsplit(ev[["anclas_aceptadas"]], ";")
tiene_dr <- vapply(seq_along(acep_por_consulta), function(i) {
  a <- stringr::str_trim(acep_por_consulta[[i]]); a <- a[nzchar(a)]
  any(grepl("^dictamen|^rex", sub("\\.html#.*$", "", a)))
}, logical(1))
linea("consultas con ALGUNA ancla aceptada en un dictamen o una REX: ",
      paste(ev[["id"]][tiene_dr], collapse = ", "), "  (n = ", sum(tiene_dr), " de ", nrow(ev), ")")
linea("CONTROL POSITIVO del clasificador de documento: anclas en una ley -> ",
      sum(grepl("^ley|^dto|^dfl", doc_esp)), " ; CONTROL NEGATIVO '^zzqq' -> ",
      sum(grepl("^zzqq", doc_esp)))

# ---------------------------------------------------------------------------
seccion("ANC-A2-01: pares (consulta, ancla) frente a anclas distintas")
acep <- unique(stringr::str_trim(unlist(acep_por_consulta)))
acep <- acep[nzchar(acep)]
pares <- unlist(acep_por_consulta); pares <- stringr::str_trim(pares); pares <- pares[nzchar(pares)]
linea("pares (consulta, ancla): ", length(pares),
      " | anclas DISTINTAS: ", length(acep),
      " | esperadas distintas: ", dplyr::n_distinct(esp),
      " | alternativas que no son ninguna esperada: ", length(setdiff(acep, esp)))
dup <- acep_tab <- table(pares)
linea("ancla que aparece en dos consultas: ",
      paste(names(acep_tab)[acep_tab > 1], collapse = ", "))
va <- readr::read_csv(fs::path(LAB, "a2_verificacion_anclas.csv"), show_col_types = FALSE)
linea("a2_verificacion_anclas.csv: ", nrow(va), " filas | ",
      dplyr::n_distinct(va[["ancla_completa"]]), " anclas distintas | ",
      "filas con exactamente 1 coincidencia en el HTML: ", sum(va[["n_id_en_html"]] == 1),
      " | anclas distintas que existen: ",
      dplyr::n_distinct(va[["ancla_completa"]][va[["existe"]]]),
      " | anclas distintas que NO existen: ",
      dplyr::n_distinct(va[["ancla_completa"]][!va[["existe"]]]))
linea("CONTROL NEGATIVO (ancla inventada en un archivo real): id=\"art-9999\" en ley_21801 -> ",
      sum(stringr::str_count(readLines(here::here("40_salidas", "sitio", "ley_21801_celulares.html"),
                                       warn = FALSE), stringr::fixed("id=\"art-9999\""))))

# ---------------------------------------------------------------------------
seccion("UNI-A2-02: recorrido exhaustivo de los id de las unidades OCR")
rutas_json <- fs::dir_ls(here::here("40_salidas", "datos", "normas"), glob = "*.json")
ids <- purrr::map_dfr(rutas_json, function(p) {
  n <- jsonlite::fromJSON(p, simplifyVector = FALSE)
  tibble::tibble(slug = n[["slug"]], origen = n[["origen_texto"]],
                 id = vapply(n[["articulos"]], function(a) a[["id"]], character(1)))
})
ocr <- ids |> filter(.data[["origen"]] == "ocr_pendiente_revision")
linea("unidades OCR sin revisar: ", nrow(ocr),
      " | con id de la forma 'ocr-pagina-N': ", sum(grepl("^ocr-pagina-[0-9]+$", ocr[["id"]])),
      " | con id que empieza por 'art-': ", sum(startsWith(ocr[["id"]], "art-")))
linea("CONTROL POSITIVO (el mismo recorrido si ve ids de articulo): unidades firmadas con 'art-': ",
      sum(ids[["origen"]] == "capa_texto_pdf" & startsWith(ids[["id"]], "art-")))
linea("normas con OCR: ", dplyr::n_distinct(ocr[["slug"]]),
      " -> ", paste(sort(unique(ocr[["slug"]])), collapse = ", "))

# ---------------------------------------------------------------------------
seccion("H-16: la linea base, desdoblada en citable y no citable")
origen_por_pagina <- ids |>
  distinct(.data[["slug"]], .data[["origen"]]) |>
  mutate(pagina = paste0(.data[["slug"]], ".html"))
es_ocr_ancla <- function(a) {
  a <- stringr::str_trim(a)
  pag <- sub("#.*$", "", a)
  o <- origen_por_pagina[["origen"]][match(pag, origen_por_pagina[["pagina"]])]
  !is.na(o) & o == "ocr_pendiente_revision"
}
desdoble <- purrr::map_dfr(seq_len(nrow(ev)), function(i) {
  a <- stringr::str_trim(acep_por_consulta[[i]]); a <- a[nzchar(a)]
  tibble::tibble(id = ev[["id"]][i],
                 n_anclas = length(a),
                 n_ocr = sum(es_ocr_ancla(a)),
                 solo_ocr = all(es_ocr_ancla(a)))
})
print(as.data.frame(desdoble))
linea("consultas cuya UNICA respuesta aceptada es texto OCR sin revisar: ",
      sum(desdoble[["solo_ocr"]]), " -> ",
      paste(desdoble[["id"]][desdoble[["solo_ocr"]]], collapse = ", "))
linea("CONTROL POSITIVO del detector de OCR: anclas totales ", sum(desdoble[["n_anclas"]]),
      ", de ellas OCR ", sum(desdoble[["n_ocr"]]),
      " ; CONTROL NEGATIVO: es_ocr_ancla('zzqq.html#x') -> ", es_ocr_ancla("zzqq.html#x"))

# Rango de la primera ancla aceptada CITABLE (no OCR), lectura C, por variante.
primera_citable <- function(variante) {
  q <- res[["consultas"]]
  ids_q <- vapply(q, function(x) x[["id"]], character(1))
  purrr::map_dfr(ev[["id"]], function(cid) {
    k <- which(ids_q == paste0(cid, "|", variante))
    if (length(k) == 0L) return(tibble::tibble(id = cid, rango_c_citable = NA_integer_))
    r <- q[[k[1]]][["resultados"]]
    sub <- purrr::map_dfr(seq_along(r), function(m) {
      if (length(r[[m]][["sub_results"]]) == 0L) return(tibble::tibble())
      purrr::map_dfr(r[[m]][["sub_results"]], function(sr) tibble::tibble(
        pagina = fs::path_file(r[[m]][["url"]]),
        ancla = if (is.null(sr[["anchor_id"]])) NA_character_ else sr[["anchor_id"]],
        sb = sr[["suma_balanced"]], score = r[[m]][["score"]]))
    })
    if (nrow(sub) == 0L) return(tibble::tibble(id = cid, rango_c_citable = NA_integer_))
    sub <- sub |> filter(!is.na(.data[["ancla"]])) |>
      arrange(desc(.data[["sb"]]), desc(.data[["score"]])) |>
      mutate(completa = paste0(.data[["pagina"]], "#", .data[["ancla"]]),
             rango = dplyr::row_number())
    aceptadas <- stringr::str_trim(acep_por_consulta[[which(ev[["id"]] == cid)]])
    aceptadas <- aceptadas[nzchar(aceptadas)]
    citables <- aceptadas[!es_ocr_ancla(aceptadas)]
    hit <- sub[["rango"]][sub[["completa"]] %in% citables]
    tibble::tibble(id = cid, rango_c_citable = if (length(hit)) min(hit) else NA_integer_)
  })
}
pc <- primera_citable("canonico")
print(as.data.frame(pc))
linea("variante canonico, lectura C: con ancla aceptada CITABLE en el top 3: ",
      sum(!is.na(pc[["rango_c_citable"]]) & pc[["rango_c_citable"]] <= 3),
      " de 10 | en algun rango: ", sum(!is.na(pc[["rango_c_citable"]])), " de 10")
lb_can <- lb |> filter(.data[["variante"]] == "canonico",
                       .data[["lectura"]] == "C_sub_puntaje") |> arrange(.data[["id"]])
linea("CONTROL: la misma lectura C SIN distinguir citabilidad (columna publicada): top 3 = ",
      sum(!is.na(lb_can[["rango_aceptada"]]) & lb_can[["rango_aceptada"]] <= 3),
      " de 10 | en algun rango: ", sum(!is.na(lb_can[["rango_aceptada"]])), " de 10")
lb_can_pag <- lb |> filter(.data[["variante"]] == "canonico",
                           .data[["lectura"]] == "A_pagina") |> arrange(.data[["id"]])
linea("CONTROL: lectura A (pagina) publicada: top 3 = ",
      sum(!is.na(lb_can_pag[["rango_aceptada"]]) & lb_can_pag[["rango_aceptada"]] <= 3), " de 10")
pca <- purrr::map_dfr(seq_len(nrow(ev)), function(i) {
  a <- stringr::str_trim(acep_por_consulta[[i]]); a <- a[nzchar(a)]
  tibble::tibble(id = ev[["id"]][i], tiene_citable = any(!es_ocr_ancla(a)))
})
linea("consultas del conjunto que tienen al menos una respuesta aceptada citable: ",
      sum(pca[["tiene_citable"]]), " de ", nrow(pca))

# Lectura A (pagina) desdoblada: rango de la primera pagina que corresponde a un
# ancla aceptada CITABLE (documento con origen_texto = capa_texto_pdf).
primera_pagina_citable <- function(variante) {
  q <- res[["consultas"]]
  ids_q <- vapply(q, function(x) x[["id"]], character(1))
  purrr::map_dfr(ev[["id"]], function(cid) {
    k <- which(ids_q == paste0(cid, "|", variante))
    if (length(k) == 0L) return(tibble::tibble(id = cid, rango_a = NA_integer_,
                                               rango_a_citable = NA_integer_))
    r <- q[[k[1]]][["resultados"]]
    if (length(r) == 0L) return(tibble::tibble(id = cid, rango_a = NA_integer_,
                                               rango_a_citable = NA_integer_))
    pags <- vapply(r, function(x) fs::path_file(x[["url"]]), character(1))
    aceptadas <- stringr::str_trim(acep_por_consulta[[which(ev[["id"]] == cid)]])
    aceptadas <- aceptadas[nzchar(aceptadas)]
    pag_acep <- unique(sub("#.*$", "", aceptadas))
    pag_cit  <- unique(sub("#.*$", "", aceptadas[!es_ocr_ancla(aceptadas)]))
    ra  <- which(pags %in% pag_acep); rc <- which(pags %in% pag_cit)
    tibble::tibble(id = cid,
                   rango_a = if (length(ra)) min(ra) else NA_integer_,
                   rango_a_citable = if (length(rc)) min(rc) else NA_integer_)
  })
}
pa <- primera_pagina_citable("canonico")
print(as.data.frame(pa))
linea("variante canonico, lectura A: top 3 con cualquier ancla aceptada = ",
      sum(!is.na(pa[["rango_a"]]) & pa[["rango_a"]] <= 3),
      " de 10 | top 3 con ancla aceptada CITABLE = ",
      sum(!is.na(pa[["rango_a_citable"]]) & pa[["rango_a_citable"]] <= 3), " de 10")
linea("CONTROL de fidelidad de esta reimplementacion contra la columna publicada (lectura A): ",
      "coinciden ", sum(pa[["rango_a"]] == lb_can_pag[["rango_aceptada"]] |
                          (is.na(pa[["rango_a"]]) & is.na(lb_can_pag[["rango_aceptada"]]))),
      " de 10 celdas")
linea("CONTROL de fidelidad (lectura C): coinciden ",
      sum(pc[["rango_c_citable"]] == lb_can[["rango_aceptada"]] |
            (is.na(pc[["rango_c_citable"]]) & is.na(lb_can[["rango_aceptada"]])), na.rm = TRUE),
      " de 10 celdas con la columna publicada (difiere solo donde el ancla es OCR: C09)")

# Cuantas veces el PRIMER sub-resultado por puntaje es una pagina OCR sin revisar.
primer_sub_ocr <- function(variante) {
  q <- res[["consultas"]]
  ids_q <- vapply(q, function(x) x[["id"]], character(1))
  purrr::map_dfr(ev[["id"]], function(cid) {
    k <- which(ids_q == paste0(cid, "|", variante))
    r <- q[[k[1]]][["resultados"]]
    sub <- purrr::map_dfr(seq_along(r), function(m) {
      if (length(r[[m]][["sub_results"]]) == 0L) return(tibble::tibble())
      purrr::map_dfr(r[[m]][["sub_results"]], function(sr) tibble::tibble(
        pagina = fs::path_file(r[[m]][["url"]]),
        ancla = if (is.null(sr[["anchor_id"]])) NA_character_ else sr[["anchor_id"]],
        sb = sr[["suma_balanced"]], score = r[[m]][["score"]]))
    })
    if (nrow(sub) == 0L) return(tibble::tibble(id = cid, primero = NA_character_, es_ocr = NA))
    sub <- sub |> filter(!is.na(.data[["ancla"]])) |>
      arrange(desc(.data[["sb"]]), desc(.data[["score"]]))
    comp <- paste0(sub[["pagina"]][1], "#", sub[["ancla"]][1])
    tibble::tibble(id = cid, primero = comp, es_ocr = es_ocr_ancla(comp))
  })
}
ps <- primer_sub_ocr("canonico")
print(as.data.frame(ps))
linea("variante canonico: primer sub-resultado por puntaje que es una pagina OCR sin revisar: ",
      sum(ps[["es_ocr"]], na.rm = TRUE), " de ", nrow(ps),
      " -> ", paste(ps[["id"]][ps[["es_ocr"]]], collapse = ", "))
linea("CONTROL POSITIVO (el detector tambien marca los firmados): no OCR = ",
      sum(!ps[["es_ocr"]], na.rm = TRUE))

# ---------------------------------------------------------------------------
seccion("UNI-A2-01 y UNI-A2-03: experimentos propios sobre el indice Pagefind")
PUERTO <- 8791L
BASE <- sprintf("http://127.0.0.1:%d/", PUERTO)
mjs <- fs::path(LAB, "a2_consulta_pagefind.mjs")
node <- Sys.which("node")
curl_ok <- function(url) {
  cod <- tryCatch(suppressWarnings(system2("curl", c("-s", "-o", "/dev/null", "-w", "%{http_code}", url),
                                           stdout = TRUE, stderr = FALSE)), error = function(e) "")
  identical(cod, "200")
}
# CER-A2-01. El patron de la fase 1, "port = <PUERTO>", NO PUEDE coincidir nunca:
# R reemplaza los espacios de la expresion de -e por "~+~" en la linea de
# comandos del proceso (verificado con ps en este turno:
#   ...exec/R --no-echo --no-restore -e servr::httd("...",~+~port~+~=~+~8791,...)
# ), asi que un pgrep con espacios devuelve 0 con el servidor VIVO. Los patrones
# que si discriminan no llevan espacios y se calibran los tres abajo.
contar <- function(patron) {
  length(suppressWarnings(system2("pgrep", c("-f", shQuote(patron)), stdout = TRUE)))
}
patrones_servidor <- function() c(
  `pgrep -f servr::httd`               = contar("servr::httd"),
  `pgrep -f <puerto>`                  = contar(as.character(PUERTO)),
  `pgrep -f "port = <puerto>" (fase 1)` = contar(sprintf("port = %d", PUERTO)))
vivo_pid <- function(pid) system2("ps", c("-p", pid), stdout = FALSE, stderr = FALSE) == 0L
if (!nzchar(node) || !fs::file_exists(mjs) || curl_ok(paste0(BASE, "index.html"))) {
  linea("NO MEDIDO: falta node, falta el arnes, o el puerto ", PUERTO, " ya responde.")
} else {
  cmd_r <- sprintf("servr::httd(%s, port = %d, daemon = FALSE, browser = FALSE, verbose = FALSE)",
                   deparse(ruta_sitio()), PUERTO)
  interno <- paste0("Rscript -e ", shQuote(cmd_r), " >/dev/null 2>&1 & echo $!")
  pid <- as.integer(system2("sh", c("-c", shQuote(interno)), stdout = TRUE))
  intentos <- 0L
  while (!curl_ok(paste0(BASE, "index.html")) && intentos < 120L) {
    Sys.sleep(0.5); intentos <- intentos + 1L
  }
  linea("servidor local (PID ", pid, ") listo tras ", intentos, " esperas de 0,5 s")
  linea("CER-A2-01, CONTROL POSITIVO (los tres patrones CON el servidor vivo, PID ", pid, "):")
  print(patrones_servidor())
  linea("  ps -p ", pid, " (el proceso concreto vive): ", vivo_pid(pid))
  linea("  linea de comandos real del proceso: ",
        system2("ps", c("-o", "command=", "-p", pid), stdout = TRUE))

  entrada <- list(
    list(id = "E0_control_positivo",       consulta = "mochila"),
    list(id = "E1_una_palabra_inexistente", consulta = "xyzzy"),
    list(id = "E2_existente_mas_inexistente", consulta = "mochila zzqqxw"),
    list(id = "E3_inexistente_mas_existente", consulta = "zzqqxw mochila"),
    list(id = "E4_dos_existentes_lejanas",  consulta = "mochila uniforme"),
    list(id = "K1_cobertura_maxima_a",      consulta = "educacion"),
    list(id = "K2_cobertura_maxima_b",      consulta = "escolar"),
    list(id = "K3_cobertura_maxima_c",      consulta = "articulo"),
    list(id = "K4_cobertura_maxima_d",      consulta = "de"),
    list(id = "H5_norma_ausente",           consulta = "aula segura"),
    list(id = "H5_norma_ausente_numero",    consulta = "ley 21.128")
  )
  re <- fs::path(LAB, "a2_experimentos_fase3_entrada.json")
  rs <- fs::path(LAB, "a2_experimentos_fase3_salida.json")
  jsonlite::write_json(entrada, re, auto_unbox = TRUE, pretty = TRUE)
  if (fs::file_exists(rs)) fs::file_delete(rs)
  cod <- system2(node, c("--no-warnings", shQuote(mjs), shQuote(re), shQuote(rs),
                         shQuote(paste0(BASE, "pagefind/"))), stdout = TRUE, stderr = TRUE)
  linea("node: ", paste(cod, collapse = " | "))

  if (fs::file_exists(rs)) {
    ex <- jsonlite::fromJSON(rs, simplifyVector = FALSE)
    pe <- jsonlite::fromJSON(here::here("40_salidas", "sitio", "pagefind", "pagefind-entry.json"),
                             simplifyVector = FALSE)
    n_indexadas <- pe[["languages"]][["es"]][["page_count"]]
    linea("paginas indexadas por Pagefind (pagefind-entry.json): ", n_indexadas)
    tabla <- purrr::map_dfr(ex[["consultas"]], function(q) tibble::tibble(
      id = q[["id"]], consulta = q[["consulta"]], paginas = q[["n_resultados"]],
      anclas = sum(vapply(q[["resultados"]], function(r)
        sum(vapply(r[["sub_results"]], function(s) !is.null(s[["anchor_id"]]), logical(1))),
        integer(1)))))
    print(as.data.frame(tabla))
    linea("UNI-A2-03: maximo de paginas devueltas por una sola consulta = ",
          max(tabla[["paginas"]]), " de ", n_indexadas, " indexadas -> ",
          if (max(tabla[["paginas"]]) >= n_indexadas) "Pagefind devuelve TODAS las paginas con coincidencia (sin corte)"
          else "no se alcanzo la cobertura total; el enunciado queda como hipotesis")
    readr::write_csv(tabla, fs::path(LAB, "a2_experimentos_fase3.csv"))
    linea("  -> a2_experimentos_fase3.csv (", nrow(tabla), " filas)")

    linea("UNI-A2-01, conjuncion: paginas devueltas por cada experimento y sus normas")
    for (q in ex[["consultas"]]) {
      if (q[["n_resultados"]] > 5) next
      linea("  [", q[["id"]], "] '", q[["consulta"]], "' -> ",
            q[["n_resultados"]], " paginas: ",
            paste(vapply(q[["resultados"]], function(r)
              paste0(sub("[.]html$", "", fs::path_file(r[["url"]])), " (",
                     r[["n_palabras_coincidentes"]], " palabras)"), character(1)),
              collapse = "; "))
    }

    seccion("H-5: una norma que el corpus CITA pero no CONTIENE (ley 21.128, Aula Segura)")
    slugs <- sub("[.]json$", "", list.files(here::here("40_salidas", "datos", "normas"),
                                            pattern = "[.]json$"))
    linea("normas del corpus: ", length(slugs),
          " | alguna cuyo slug contenga '21128' o '21_128': ",
          sum(grepl("21128|21_128", slugs)))
    numeros <- vapply(cat_json[["normas"]], function(n)
      if (is.null(n[["numero"]])) "" else as.character(n[["numero"]]), character(1))
    linea("alguna norma del catalogo con numero 21128 o 21.128: ",
          sum(grepl("21128|21\\.128", numeros)),
          " | CONTROL POSITIVO (numero que si esta): 21801 -> ",
          sum(grepl("21801|21\\.801", numeros)))
    textos <- purrr::map_dfr(fs::dir_ls(here::here("40_salidas", "datos", "normas"), glob = "*.json"),
      function(p) {
        n <- jsonlite::fromJSON(p, simplifyVector = FALSE)
        tibble::tibble(slug = n[["slug"]],
                       id = vapply(n[["articulos"]], function(a) a[["id"]], character(1)),
                       txt = vapply(n[["articulos"]], function(a) a[["texto"]], character(1)))
      })
    plano_txt <- stringi::stri_trans_general(tolower(textos[["txt"]]), "Latin-ASCII")
    cita_as <- grepl("aula segura", plano_txt, fixed = TRUE)
    cita_num <- grepl("21.128", plano_txt, fixed = TRUE) | grepl("21128", plano_txt, fixed = TRUE)
    linea("segmentos que MENCIONAN 'aula segura': ", sum(cita_as), " -> ",
          paste(paste0(textos[["slug"]][cita_as], "#", textos[["id"]][cita_as]), collapse = ", "))
    linea("segmentos que MENCIONAN el numero 21.128 / 21128: ", sum(cita_num), " -> ",
          paste(paste0(textos[["slug"]][cita_num], "#", textos[["id"]][cita_num]), collapse = ", "))
    linea("CONTROL POSITIVO del mismo detector (una norma que SI esta en el corpus): ",
          "segmentos que mencionan 'inclusion escolar': ",
          sum(grepl("inclusion escolar", plano_txt, fixed = TRUE)))
    linea("CONTROL NEGATIVO: segmentos que mencionan 'zzqqxw': ",
          sum(grepl("zzqqxw", plano_txt, fixed = TRUE)))
  } else {
    linea("NO MEDIDO: el arnes no escribio resultados.")
  }

  tools::pskill(pid)
  Sys.sleep(1)
  linea("CER-A2-01, EL CERO (los mismos tres patrones TRAS pskill):")
  print(patrones_servidor())
  linea("  ps -p ", pid, " (el proceso concreto vive): ", vivo_pid(pid))
  linea("  el puerto ya no responde: ", !curl_ok(paste0(BASE, "index.html")))
}

# ---------------------------------------------------------------------------
seccion("CER-GEN-01: invariante de no escritura, con su control positivo")
g1 <- suppressWarnings(system2("git", c("status", "--porcelain", "--",
                                        "40_salidas", "20_insumos", "30_procesamiento"),
                               stdout = TRUE))
g2 <- suppressWarnings(system2("git", c("status", "--porcelain", "--", "50_documentacion"),
                               stdout = TRUE))
linea("git status --porcelain -- 40_salidas 20_insumos 30_procesamiento -> ", length(g1), " lineas")
linea("CONTROL POSITIVO del mismo comando: -- 50_documentacion -> ", length(g2), " lineas")
if (length(g2)) print(g2)

seccion("CIERRE")
foto_despues <- foto_salidas()
linea("40_salidas/: archivos antes=", foto_antes[["n"]], " despues=", foto_despues[["n"]],
      " | mtime max antes=", format(foto_antes[["mtime_max"]]),
      " despues=", format(foto_despues[["mtime_max"]]),
      " -> ", if (identical(foto_antes, foto_despues)) "SIN CAMBIOS" else "CAMBIO DETECTADO")
