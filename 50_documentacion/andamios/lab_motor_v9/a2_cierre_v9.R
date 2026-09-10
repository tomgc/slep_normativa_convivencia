# =============================================================================
# a2_cierre_v9.R
# Encargo v9, RONDA DE CIERRE de la fase 3. Agente A2.
#
# Re-deriva, en un solo turno y con su control al lado, las cifras que los
# defectos nuevos del verificador de A2 y los abiertos de AUD2 obligan a tocar
# en 20260904_alcance_capa2_semantica_v1.md. Ninguna cifra se hereda de un
# documento anterior ni del reporte del propio A2: todas se recuentan aqui.
#
# Ejecutar desde la raiz del repo:
#   Rscript 50_documentacion/andamios/lab_motor_v9/a2_cierre_v9.R
#
# Contrato de escritura: NO escribe nada. Solo lee. R exclusivamente,
# `[[ ]]` sobre todo lo leido de disco. Sin red, sin cuota, sin pipeline.
# =============================================================================

paquetes <- c("jsonlite", "dplyr", "purrr", "tibble", "readr", "stringr",
              "here", "fs")
faltan <- paquetes[!vapply(paquetes, requireNamespace, TRUE, quietly = TRUE)]
if (length(faltan) > 0L) stop("Faltan paquetes: ", paste(faltan, collapse = ", "))
library(dplyr, warn.conflicts = FALSE)

source(here::here("10_utils", "10_configuracion.R"))   # guarda de locale UTF-8
LAB <- here::here("50_documentacion", "andamios", "lab_motor_v9")
DOC <- here::here("50_documentacion", "andamios",
                  "20260904_alcance_capa2_semantica_v1.md")
SCR <- here::here("50_documentacion", "andamios",
                  "20260904_medicion_corpus_semantica.R")

linea <- function(...) cat(paste0(..., collapse = ""), "\n", sep = "")
seccion <- function(t) cat("\n==== ", t, " ====\n", sep = "")

linea("documento: ", DOC)
linea("lineas del documento: ", length(readLines(DOC, warn = FALSE)))

# ---------------------------------------------------------------------------
# D2. Fila "Linea base del Pagefind actual" de la seccion 0: que consulta
#     explica realmente la caida al exigir unidad citable.
# ---------------------------------------------------------------------------
seccion("D2: el desdoble por citabilidad, consulta por consulta (variante canonico)")

ev  <- readr::read_csv(fs::path(LAB, "a2_consultas_evaluacion.csv"),
                       show_col_types = FALSE)
lb  <- readr::read_csv(fs::path(LAB, "a2_linea_base_pagefind.csv"),
                       show_col_types = FALSE)
res <- jsonlite::fromJSON(fs::path(LAB, "a2_resultados_pagefind.json"),
                          simplifyVector = FALSE)

rutas_json <- fs::dir_ls(here::here("40_salidas", "datos", "normas"), glob = "*.json")
ids <- purrr::map_dfr(rutas_json, function(p) {
  n <- jsonlite::fromJSON(p, simplifyVector = FALSE)
  tibble::tibble(slug = n[["slug"]], origen = n[["origen_texto"]],
                 id = vapply(n[["articulos"]], function(a) a[["id"]], character(1)))
})
origen_por_pagina <- ids |>
  distinct(.data[["slug"]], .data[["origen"]]) |>
  mutate(pagina = paste0(.data[["slug"]], ".html"))
es_ocr_ancla <- function(a) {
  a <- stringr::str_trim(a)
  pag <- sub("#.*$", "", a)
  o <- origen_por_pagina[["origen"]][match(pag, origen_por_pagina[["pagina"]])]
  !is.na(o) & o == "ocr_pendiente_revision"
}
acep_por_consulta <- strsplit(ev[["anclas_aceptadas"]], ";")
aceptadas_de <- function(cid) {
  a <- stringr::str_trim(acep_por_consulta[[which(ev[["id"]] == cid)]])
  a[nzchar(a)]
}

# Sub-resultados con ancla, ordenados por puntaje (lectura C), y paginas (lectura A).
tabla_variante <- function(variante) {
  q <- res[["consultas"]]
  ids_q <- vapply(q, function(x) x[["id"]], character(1))
  purrr::map_dfr(ev[["id"]], function(cid) {
    k <- which(ids_q == paste0(cid, "|", variante))
    vacia <- tibble::tibble(id = cid, rango_a = NA_integer_, rango_a_cit = NA_integer_,
                            rango_c = NA_integer_, rango_c_cit = NA_integer_,
                            primer_sub = NA_character_, primer_sub_ocr = NA)
    if (length(k) == 0L) return(vacia)
    r <- q[[k[1]]][["resultados"]]
    if (length(r) == 0L) return(vacia)
    acep <- aceptadas_de(cid)
    cit  <- acep[!es_ocr_ancla(acep)]
    pags <- vapply(r, function(x) fs::path_file(x[["url"]]), character(1))
    ra  <- which(pags %in% unique(sub("#.*$", "", acep)))
    rac <- which(pags %in% unique(sub("#.*$", "", cit)))
    sub <- purrr::map_dfr(seq_along(r), function(m) {
      if (length(r[[m]][["sub_results"]]) == 0L) return(tibble::tibble())
      purrr::map_dfr(r[[m]][["sub_results"]], function(sr) tibble::tibble(
        pagina = fs::path_file(r[[m]][["url"]]),
        ancla = if (is.null(sr[["anchor_id"]])) NA_character_ else sr[["anchor_id"]],
        sb = sr[["suma_balanced"]], score = r[[m]][["score"]]))
    })
    if (nrow(sub) == 0L) return(vacia)
    sub <- sub |> filter(!is.na(.data[["ancla"]])) |>
      arrange(desc(.data[["sb"]]), desc(.data[["score"]])) |>
      mutate(completa = paste0(.data[["pagina"]], "#", .data[["ancla"]]),
             rango = dplyr::row_number())
    hc  <- sub[["rango"]][sub[["completa"]] %in% acep]
    hcc <- sub[["rango"]][sub[["completa"]] %in% cit]
    tibble::tibble(
      id = cid,
      rango_a  = if (length(ra))  min(ra)  else NA_integer_,
      rango_a_cit = if (length(rac)) min(rac) else NA_integer_,
      rango_c  = if (length(hc))  min(hc)  else NA_integer_,
      rango_c_cit = if (length(hcc)) min(hcc) else NA_integer_,
      primer_sub = sub[["completa"]][1],
      primer_sub_ocr = es_ocr_ancla(sub[["completa"]][1]))
  })
}
tv <- tabla_variante("canonico")
print(as.data.frame(tv))

en_top3 <- function(x) !is.na(x) & x <= 3
linea("lectura A (pagina): top 3 con cualquier ancla aceptada = ",
      sum(en_top3(tv[["rango_a"]])), " de 10 | exigiendo unidad citable = ",
      sum(en_top3(tv[["rango_a_cit"]])), " de 10")
linea("lectura C (sub-resultado por puntaje): top 3 con cualquier ancla aceptada = ",
      sum(en_top3(tv[["rango_c"]])), " de 10 | exigiendo unidad citable = ",
      sum(en_top3(tv[["rango_c_cit"]])), " de 10")
linea("lectura A, consultas EN el top 3: ",
      paste(tv[["id"]][en_top3(tv[["rango_a"]])], collapse = ", "))
linea("lectura C, consultas EN el top 3: ",
      paste(tv[["id"]][en_top3(tv[["rango_c"]])], collapse = ", "))
cae_a <- tv[["id"]][en_top3(tv[["rango_a"]]) & !en_top3(tv[["rango_a_cit"]])]
cae_c <- tv[["id"]][en_top3(tv[["rango_c"]]) & !en_top3(tv[["rango_c_cit"]])]
linea("CONSULTAS QUE CAEN al exigir citabilidad -> lectura A: ",
      paste(cae_a, collapse = ", "), " (n = ", length(cae_a), ")",
      " | lectura C: ", paste(cae_c, collapse = ", "), " (n = ", length(cae_c), ")")
linea("CONTRAPRUEBA de la explicacion vieja (C04, C05, C08): rango_c aceptado / citable -> ",
      paste(sprintf("%s %s/%s", c("C04", "C05", "C08"),
                    tv[["rango_c"]][match(c("C04","C05","C08"), tv[["id"]])],
                    tv[["rango_c_cit"]][match(c("C04","C05","C08"), tv[["id"]])]),
            collapse = " ; "),
      "  -> ninguna de las tres cae del top 3 por citabilidad")
linea("CONTROL POSITIVO (el hecho de C04/C05/C08 SI existe, pero es otro): ",
      "primer sub-resultado por puntaje que es pagina OCR -> ",
      sum(tv[["primer_sub_ocr"]], na.rm = TRUE), " de 10 (",
      paste(tv[["id"]][which(tv[["primer_sub_ocr"]])], collapse = ", "),
      ") ; los otros ", sum(!tv[["primer_sub_ocr"]], na.rm = TRUE), " son firmados")
linea("CONTROL NEGATIVO del detector: es_ocr_ancla('zzqq.html#x') -> ",
      es_ocr_ancla("zzqq.html#x"),
      " ; CONTROL POSITIVO: es_ocr_ancla('circular_812_identidad_genero.html#ocr-pagina-008') -> ",
      es_ocr_ancla("circular_812_identidad_genero.html#ocr-pagina-008"))
lb_can <- lb |> filter(.data[["variante"]] == "canonico") |>
  select(.data[["id"]], .data[["lectura"]], .data[["rango_aceptada"]]) |>
  arrange(.data[["lectura"]], .data[["id"]])
linea("CONTROL de fidelidad contra la columna publicada (a2_linea_base_pagefind.csv): ",
      "lectura A coincide en ",
      sum(identical_na <- (is.na(tv[["rango_a"]]) &
          is.na(lb_can[["rango_aceptada"]][lb_can[["lectura"]] == "A_pagina"])) |
          (tv[["rango_a"]] == lb_can[["rango_aceptada"]][lb_can[["lectura"]] == "A_pagina"]),
          na.rm = TRUE), " de 10 celdas")

# ---------------------------------------------------------------------------
# D3. La afirmacion de uso retirada de la seccion 0 no puede sobrevivir en otra parte.
# ---------------------------------------------------------------------------
seccion("D3: rastreo de la afirmacion de uso en TODO el documento")
txt <- readLines(DOC, warn = FALSE)
buscar <- function(patron, fijo = TRUE) {
  h <- grep(patron, txt, fixed = fijo)
  linea("  patron ", sQuote(patron), " -> ", length(h), " linea(s)",
        if (length(h)) paste0(": ", paste(h, collapse = ", ")) else "")
  h
}
buscar("mas consultadas")
buscar("más consultadas")
buscar("las fuentes más consultadas")
buscar("más consulta")
buscar("lo que más consulta el equipo")
linea("CONTROL POSITIVO del buscador (una cadena que si esta): ")
buscar("0 artículos")
linea("CONTROL NEGATIVO del buscador: ")
buscar("zzqqxw-inexistente")

# Lo que reemplaza a la afirmacion de uso en la fila H5: el mismo recuento
# verificable que ya publica la seccion 0, re-derivado aqui.
seccion("D3bis: el recuento que sustituye a la afirmacion de uso (fila H5 de la seccion 8)")
cat_json <- jsonlite::fromJSON(here::here("40_salidas", "datos", "catalogo.json"),
                               simplifyVector = FALSE)
normas_cat <- purrr::map_dfr(cat_json[["normas"]], function(n) tibble::tibble(
  slug = n[["slug"]], seg = n[["n_segmentos"]], art = n[["n_articulos"]],
  origen = n[["origen_texto"]]))
sel <- grepl("^dictamen|^rex", normas_cat[["slug"]])
linea("documentos dictamen/REX: ", sum(sel),
      " | segmentos ", sum(normas_cat[["seg"]][sel]),
      " | articulos ", sum(normas_cat[["art"]][sel]))
linea("CONTROL POSITIVO (el instrumento si ve articulos): ley_20845 -> ",
      normas_cat[["art"]][normas_cat[["slug"]] == "ley_20845_inclusion_escolar"])
linea("CONTROL NEGATIVO: slugs '^zzqq' -> ", sum(grepl("^zzqq", normas_cat[["slug"]])))
doc_esp <- sub("\\.html#.*$", "", ev[["ancla_esperada"]])
esperadas_dr <- ev[["id"]][grepl("^dictamen|^rex", doc_esp)]
tiene_dr <- vapply(ev[["id"]], function(cid) {
  a <- aceptadas_de(cid)
  any(grepl("^dictamen|^rex", sub("\\.html#.*$", "", a)))
}, logical(1))
linea("consultas cuya ancla ESPERADA vive en un dictamen o una REX: ",
      length(esperadas_dr), " de ", nrow(ev), " -> ", paste(esperadas_dr, collapse = ", "))
linea("consultas con ALGUNA ancla aceptada en un dictamen o una REX: ",
      sum(tiene_dr), " de ", nrow(ev), " -> ",
      paste(ev[["id"]][tiene_dr], collapse = ", "))
linea("CONTROL POSITIVO del mismo clasificador: anclas esperadas en una ley o un decreto -> ",
      sum(grepl("^ley|^dto|^dfl|^circular", doc_esp)))

# ---------------------------------------------------------------------------
# D1. Recuento de las marcas de fase 3, con un patron que NO se cuenta a si mismo.
# ---------------------------------------------------------------------------
seccion("D1: recuento de las marcas de correccion de fase 3")
# Las marcas reales llevan un id que empieza por mayuscula (CIF-, ANC-, CER-,
# CON-, UNI-, H-). Las dos menciones de plantilla escriben "<id>" en minuscula,
# de modo que este patron las excluye por construccion, incluida la oracion que
# publica la cifra.
P_MARCA <- "corregido en fase 3: [A-Z]"
ocurr <- unlist(stringr::str_extract_all(txt, P_MARCA))
lin_marca <- grep(P_MARCA, txt)
linea("patron ", sQuote(P_MARCA), " -> ocurrencias ", length(ocurr),
      " en ", length(lin_marca), " lineas: ", paste(lin_marca, collapse = ", "))
P_LLANO <- "corregido en fase 3:"
linea("patron llano ", sQuote(P_LLANO), " (el que se cuenta a si mismo) -> lineas ",
      length(grep(P_LLANO, txt, fixed = TRUE)), " | ocurrencias ",
      length(unlist(stringr::str_extract_all(txt, stringr::fixed(P_LLANO)))))
linea("lineas que el patron llano ve y el patron con id NO ve (las plantillas): ",
      paste(setdiff(grep(P_LLANO, txt, fixed = TRUE), lin_marca), collapse = ", "))
linea("CONTROL POSITIVO del contador (una marca conocida): ",
      "lineas con 'corregido en fase 3: CIF-A2-01' -> ",
      length(grep("corregido en fase 3: CIF-A2-01", txt, fixed = TRUE)))
linea("CONTROL NEGATIVO del contador: patron 'corregido en fase 9: [A-Z]' -> ",
      length(grep("corregido en fase 9: [A-Z]", txt)))
linea("agregados (no correcciones), para que no se confundan: ",
      "'agregad[oa] en fase 3:' -> ",
      length(unlist(stringr::str_extract_all(txt, "agregad[oa] en fase 3:"))))
P_CIERRE <- "corregido en la ronda de cierre: [A-Z]"
linea("marcas de la RONDA DE CIERRE, patron ", sQuote(P_CIERRE), " -> ocurrencias ",
      length(unlist(stringr::str_extract_all(txt, P_CIERRE))), " en lineas ",
      paste(grep(P_CIERRE, txt), collapse = ", "))
linea("CONTROL NEGATIVO: 'corregido en la ronda de cierre: [a-z]' (la forma que ",
      "usaria una plantilla) -> ", length(grep("corregido en la ronda de cierre: [a-z]", txt)))

# ---------------------------------------------------------------------------
# Cierre: gobernanza, tipografia y referencias de linea que el documento cita.
# ---------------------------------------------------------------------------
seccion("CIERRE: gobernanza, rayas largas y referencias de linea")
RAYA <- "—"
n_raya <- length(unlist(stringr::str_extract_all(txt, stringr::fixed(RAYA))))
control_raya <- length(unlist(stringr::str_extract_all(
  paste0("cadena de control construida en este turno ", RAYA, " con raya larga"),
  stringr::fixed(RAYA))))
linea("rayas largas en el documento: ", n_raya,
      " | CONTROL POSITIVO del detector sobre una cadena construida aqui: ", control_raya)
RE_RUT <- "[0-9]{1,2}\\.?[0-9]{3}\\.?[0-9]{3}-[0-9kK]"
n_rut <- length(grep(RE_RUT, txt))
ctrl_rut_pos <- grepl(RE_RUT, paste0("1", "2.345.678-", "9"))
ctrl_rut_neg <- grepl(RE_RUT, paste0("1", "2.345.678-[", "9]"))
linea("lineas con forma de RUT: ", n_rut,
      " | CONTROL POSITIVO sobre cadena construida en este turno: ", ctrl_rut_pos,
      " | CONTROL NEGATIVO sobre la forma enmascarada: ", ctrl_rut_neg)
scr <- readLines(SCR, warn = FALSE)
linea("referencias de linea que el documento cita del script de medicion:")
linea("  lineas 512-518 (control positivo antes del pskill):")
cat(paste0("    ", 512:518, ": ", scr[512:518]), sep = "\n")
linea("  lineas 553-563 (cierre con el par completo):")
cat(paste0("    ", 553:563, ": ", scr[553:563]), sep = "\n")
linea("  CONTROL: el script tiene ", length(scr), " lineas ; ",
      "'port = ' (patron con espacios, el roto) -> ",
      length(grep("port = ", scr, fixed = TRUE)), " lineas ; ",
      "'servr::httd' -> ", length(grep("servr::httd", scr, fixed = TRUE)), " lineas")

seccion("FIN")
