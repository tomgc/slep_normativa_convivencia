# =============================================================================
# a5_contraste2.R  (laboratorio del encargo v9, agente A5: fase 2, contraste)
# -----------------------------------------------------------------------------
# Segunda tanda del contraste. A diferencia de a5_contraste.R (que reimplementa),
# aqui se usa el CODIGO REAL de A1 (sugerir()) y de A3 (arnes antialucinacion),
# cargado por parse() con filtro de asignaciones de funcion, sin ejecutar sus
# bloques de corrida. Solo lee; escribe unicamente archivos a5_* del laboratorio.
# Acceso a estructuras leidas de disco: [[ ]] exacto, nunca $ (salvo sobre
# environments, que no son datos de disco).
# =============================================================================
suppressPackageStartupMessages({
  library(jsonlite); library(dplyr); library(purrr); library(stringr)
  library(stringi); library(tibble); library(readr); library(here); library(fs)
})
options(warnPartialMatchDollar = TRUE)
LAB   <- here::here("50_documentacion", "andamios", "lab_motor_v9")
SITIO <- here::here("40_salidas", "sitio")
DATOS <- here::here("40_salidas", "datos")
cab <- function(x) cat("\n==== ", x, " ====\n", sep = "")
pl  <- function(x) tolower(stringi::stri_trans_general(x, "Latin-ASCII"))

source(file.path(LAB, "a3_cargar_defs.R"))   # cargador de A3 (solo define funciones)
cargar_entorno_pipeline()
normas <- leer_normas()
d34 <- cargar_defs_de(here::here("30_procesamiento", "34_generar_paginas.R"), constantes = CONSTANTES_34)
e <- d34[["env"]]
anclas <- e$anclas_disponibles(unname(normas))

seg <- map_dfr(normas, function(n) tibble(
  slug = n[["slug"]], tipo = n[["tipo"]], origen = n[["origen_texto"]],
  id = vapply(n[["articulos"]], function(a) a[["id"]], character(1)),
  etiqueta = vapply(n[["articulos"]], function(a) a[["etiqueta"]], character(1)),
  es_articulo = vapply(n[["articulos"]], function(a) isTRUE(a[["es_articulo"]]), logical(1)),
  texto = vapply(n[["articulos"]], function(a) a[["texto"]], character(1))))
seg <- seg |> mutate(clase = case_when(str_starts(id, "ocr-pagina-") ~ "pagina_ocr",
                                       es_articulo ~ "articulo", TRUE ~ "seccion_firmada"))

# =============================================================================
# BLOQUE 1. El resolutor REAL de A1 sobre las 38 consultas llanas de A5
# =============================================================================
cab("B1. Resolutor real de A1 (sugerir() de 20260904_prototipo_vocabulario.R) reconstruido")
d1 <- cargar_defs_de(here::here("50_documentacion", "andamios", "20260904_prototipo_vocabulario.R"),
                     constantes = c("STOP_CONSULTA", "REGLA_PREFIJO", "PESOS"))
a1 <- d1[["env"]]
cat("expresiones del prototipo:", d1[["n_total"]], "| evaluadas:", length(d1[["evaluadas"]]),
    "| omitidas:", length(d1[["omitidas"]]), "\n")
cat("sugerir/normalizar/tokenizar disponibles:",
    all(c("sugerir", "normalizar", "tokenizar") %in% d1[["evaluadas"]]), "\n")

# El indice en memoria se reconstruye con las MISMAS lineas 467-478 del prototipo,
# desde el artefacto real vocabulario.json.
voc <- jsonlite::fromJSON(file.path(LAB, "vocabulario.json"), simplifyDataFrame = FALSE)
ent <- voc[["entradas"]]
names(ent) <- vapply(ent, function(x) x[["id"]], character(1))
assign("entradas", ent, envir = a1)
local({
  tokenizar <- a1[["tokenizar"]]
  claves_propias <- lapply(ent, function(x) unique(unlist(lapply(c(x[["termino"]], x[["alias"]]), tokenizar))))
  claves <- claves_propias
  for (id in names(ent)) {
    x <- ent[[id]]
    if (identical(x[["tipo"]], "articulo"))
      claves[[id]] <- unique(c(claves[[id]], claves_propias[[paste0("norma:", x[["norma"]])]]))
  }
  assign("claves_propias", claves_propias, envir = a1)
  assign("claves", claves, envir = a1)
  assign("primer_token", vapply(ent, function(x) { t <- tokenizar(x[["termino"]]); if (length(t)) t[1] else "" }, character(1)), envir = a1)
  assign("tipo_de",      vapply(ent, function(x) x[["tipo"]], character(1)), envir = a1)
  assign("peso_de",      vapply(ent, function(x) x[["peso"]], numeric(1)), envir = a1)
  assign("citable_de",   vapply(ent, function(x) isTRUE(x[["citable"]]), logical(1)), envir = a1)
  assign("sustituida_de",vapply(ent, function(x) identical(x[["vigencia"]][["estado"]], "sustituido"), logical(1)), envir = a1)
  assign("largo_de",     vapply(ent, function(x) nchar(x[["termino"]]), integer(1)), envir = a1)
})
sugerir <- a1[["sugerir"]]
n_sug <- function(q, ...) nrow(sugerir(q, ...))

cab("B1.1 CONTROL de fidelidad: los casos plantados de A1 §6 reproducidos con este montaje")
ctrl <- tibble(consulta = c("celu", "circular 482", "REX 482", "mochila", "xyzzy", "convivencia"),
               a1_documento = c(3L, 3L, 3L, 3L, 0L, 5L)) |>
  mutate(a5_recuento = map_int(consulta, n_sug), coincide = a1_documento == a5_recuento)
print(as.data.frame(ctrl), row.names = FALSE)
stopifnot(all(ctrl[["coincide"]]))
cat("El montaje reproduce 6 de 6 cifras de A1 §6: es el resolutor de A1, no una reimplementacion.\n")
cat("destino_canonico de 'circular 482' y 'REX 482' identicos:",
    identical(sugerir("circular 482")[["destino_canonico"]], sugerir("REX 482")[["destino_canonico"]]), "\n")

cab("B1.2 Las 38 consultas llanas de A5 (a5_consultas_equipo.csv) por el resolutor REAL de A1")
cs <- read_csv(file.path(LAB, "a5_consultas_equipo.csv"), show_col_types = FALSE)
res38 <- cs |> mutate(
  n_and = map_int(consulta, function(q) n_sug(q, modo = "todos")),
  n_or  = map_int(consulta, function(q) n_sug(q, modo = "alguno")),
  top1_or = map_chr(consulta, function(q) { r <- sugerir(q, modo = "alguno"); if (nrow(r)) paste0(r[["tipo"]][1], ": ", r[["termino"]][1]) else "" }))
print(res38 |> select(id, consulta, n_and, n_or, top1_or) |> as.data.frame(), row.names = FALSE)
cat(sprintf("\nCON EL CONTRATO DE A1 (AND, §4.3 regla 1): %d de %d consultas devuelven >= 1 sugerencia (%.0f%%).\n",
            sum(res38[["n_and"]] > 0), nrow(res38), 100 * mean(res38[["n_and"]] > 0)))
cat(sprintf("Con OR (que A1 mide como diagnostico y NO recomienda): %d de %d.\n",
            sum(res38[["n_or"]] > 0), nrow(res38)))
cat(sprintf("Comparacion con el proxy B de A1 (23 consultas): AND 11 de 23; sus 12 titulos de FAQ dan 0 de 12.\n"))
write_csv(res38, file.path(LAB, "a5_contraste_38_vs_resolutor_a1.csv"))

# =============================================================================
# BLOQUE 2. Ataque al arnes REAL de A3
# =============================================================================
cab("B2. Arnes real de A3 (a3_arnes_citas.R) cargado por definiciones")
d3 <- cargar_defs_de(file.path(LAB, "a3_arnes_citas.R"),
                     constantes = c("MODOS", "CITABLES", "NIVEL_POR_TIPO", "REGEX_RUT"))
ar <- d3[["env"]]
assign("e", e, envir = ar); assign("normas", normas, envir = ar); assign("anclas", anclas, envir = ar)
cat("expresiones del arnes:", d3[["n_total"]], "| evaluadas:", length(d3[["evaluadas"]]), "\n")
cat("funciones disponibles:", paste(intersect(d3[["evaluadas"]], c("verificar_cita","verificar_respuesta","colapsar","texto_de","contiene_rut","render")), collapse = ", "), "\n")
verificar_respuesta <- ar[["verificar_respuesta"]]

texto_seg <- function(slug, id) seg[["texto"]][seg[["slug"]] == slug & seg[["id"]] == id][1]
salida <- function(citas, frases, modo = "respuesta") {
  jsonlite::toJSON(list(esquema = "a3-salida-v1", modo = modo,
                        rotulo = "inferencia_del_modelo_no_validada",
                        pregunta_entendida = "control adversarial de A5",
                        citas = citas, inferencia = frases,
                        no_resuelto = list(), advertencias = list()), auto_unbox = TRUE) |> as.character()
}
cita <- function(id, slug, art, txt) list(cita_id = id, norma = slug, articulo = art,
                                          ancla = paste0(slug, ".html#", art), texto_citado = txt)
informe <- function(nombre, r, espera) {
  cat(sprintf("\n[%s]\n", nombre))
  for (k in names(r[["citas"]])) cat(sprintf("   %-4s %-48s %-22s %s\n", k, r[["citas"]][[k]][["ancla"]],
                                             r[["citas"]][[k]][["veredicto"]], r[["citas"]][[k]][["motivo"]]))
  cat(sprintf("   veredicto: %s | aceptadas %d | frases conservadas %d | retiradas %d | ESPERADO: %s\n",
              r[["veredicto"]], length(r[["aceptadas"]]), length(r[["conservadas"]]), r[["retiradas"]], espera))
  invisible(r)
}

cab("B2.1 CONTROL POSITIVO: el arnes carga y sigue rechazando lo que A3 documenta")
t_bis <- texto_seg("ley_21801_celulares", "art-10-bis")
lit_bis <- substr(t_bis, 1, 120)
ctrl_a <- verificar_respuesta(salida(
  list(cita("k1", "ley_21801_celulares", "art-10-bis", lit_bis),
       cita("k2", "ley_21801_celulares", "art-45", lit_bis),
       cita("k3", "ley_21801_celulares", "art-10-ter", "la ley dice que se pueden usar los celulares si el profesor lo autoriza")),
  list(list(texto = "frase apoyada en cita valida", apoya_en = list("k1")),
       list(texto = "frase apoyada en ancla inventada", apoya_en = list("k2")),
       list(texto = "frase apoyada en parafrasis", apoya_en = list("k3")))))
informe("CONTROL: 1 valida, 1 ancla inventada (art-45), 1 parafrasis", ctrl_a, "1 aceptada, 2 retiradas")
stopifnot(length(ctrl_a[["aceptadas"]]) == 1L, ctrl_a[["retiradas"]] == 2L)

cab("B2.2 ATAQUE 1: inferencia falsa apoyada en una cita literal valida (el arnes no verifica el apoyo)")
at1 <- verificar_respuesta(salida(
  list(cita("c1", "ley_21801_celulares", "art-10-bis", lit_bis)),
  list(list(texto = "El establecimiento puede retener el telefono del estudiante hasta el termino de la jornada y entregarlo solo al apoderado.",
            apoya_en = list("c1")))));
informe("ATAQUE 1: la frase afirma una facultad de retencion que el articulo citado NO contiene", at1, "el arnes la CONSERVA")
cat("   Verificacion independiente de A5: 'reten|retir|requis|confisc|decomis' en los 6 segmentos de ley_21801: ",
    sum(str_count(tolower(seg[["texto"]][seg[["slug"]] == "ley_21801_celulares"]), "reten|retir|requis|confisc|decomis")),
    " (control positivo 'prohib' en art-10-bis: ", str_count(tolower(t_bis), "prohib"), ")\n", sep = "")

cab("B2.3 ATAQUE 2: cita literal recortada que invierte el sentido (se corta antes de la excepcion)")
pos_exc <- str_locate(t_bis, "Excepcionalmente")
recorte <- str_trim(substr(t_bis, 1, pos_exc[1, "start"] - 1L))
cat("   texto_citado = los", nchar(recorte), "primeros caracteres del art-10-bis, cortados justo antes de 'Excepcionalmente'\n")
at2 <- verificar_respuesta(salida(
  list(cita("c1", "ley_21801_celulares", "art-10-bis", substr(recorte, max(1, nchar(recorte) - 400), nchar(recorte)))),
  list(list(texto = "La prohibicion de usar dispositivos moviles no admite ninguna excepcion.", apoya_en = list("c1")))));
informe("ATAQUE 2: literal, contiguo, dentro de 20-600, y omite la excepcion del propio articulo", at2, "el arnes la CONSERVA")
cat("   'Excepcionalmente' aparece en el art-10-bis: ", str_count(t_bis, "Excepcionalmente"), " vez/veces (control: en el recorte citado ",
    str_count(recorte, "Excepcionalmente"), ")\n", sep = "")

cab("B2.4 ATAQUE 3: contenido tomado de una pagina OCR no citable, publicado como inferencia con una cita ajena valida")
t_ocr <- texto_seg("circular_812_identidad_genero", "ocr-pagina-008")
frag_ocr <- str_trim(str_squish(substr(t_ocr, 1, 200)))
cat("   fragmento OCR usado (primeros 120 car.): ", substr(frag_ocr, 1, 120), "\n", sep = "")
at3 <- verificar_respuesta(salida(
  list(cita("c1", "ley_21801_celulares", "art-10-bis", lit_bis)),
  list(list(texto = paste0("Segun la normativa, ", str_trunc(frag_ocr, 150)), apoya_en = list("c1")))));
informe("ATAQUE 3: la frase transporta texto OCR sin revisar; su unica cita es un articulo firmado", at3, "el arnes la CONSERVA")

cab("B2.5 Que SI atrapa el arnes (delimitacion honesta del ataque)")
at4 <- verificar_respuesta(salida(
  list(cita("c1", "circular_812_identidad_genero", "ocr-pagina-008", substr(str_squish(t_ocr), 1, 200))),
  list(list(texto = "El estudiante trans tiene derecho al uso del nombre social.", apoya_en = list("c1")))));
informe("Cita DIRECTA a la pagina OCR", at4, "degradada_a_ubicacion y frase retirada")

# =============================================================================
# BLOQUE 3. El filtro es_articulo del Worker de A4 contra A2 y A3
# =============================================================================
cab("B3. Filtro `art.es_articulo === true` del Worker (a4_worker_esqueleto.js) contra las anclas de A2 y A3")
clase_de <- function(a) { m <- str_match(a, "^([^#]+)[.]html#(.+)$")
  s <- seg |> filter(slug == m[2], id == m[3]); if (nrow(s) == 0) "inexistente" else s[["clase"]][1] }

a2v <- read_csv(file.path(LAB, "a2_verificacion_anclas.csv"), show_col_types = FALSE)
ev  <- read_csv(file.path(LAB, "a2_consultas_evaluacion.csv"), show_col_types = FALSE)
cl_esp <- vapply(ev[["ancla_esperada"]], clase_de, character(1))
cat("A2, anclas ESPERADAS (10):"); print(table(cl_esp))
cat("   el filtro del Worker descartaria la respuesta esperada en", sum(cl_esp != "articulo"), "de 10 consultas:",
    paste(ev[["id"]][cl_esp != "articulo"], collapse = ", "), "\n")
cl_ace <- vapply(a2v[["ancla_completa"]], clase_de, character(1))
cat("A2, anclas ACEPTADAS (19):"); print(table(cl_ace))
cat("   descartadas por el filtro:", sum(cl_ace != "articulo"), "de", nrow(a2v), "\n")
cat("A2, consultas SIN ninguna ancla aceptada que sobreviva al filtro:",
    { por_c <- ev |> mutate(cl = cl_esp, alt = anclas_aceptadas)
      ids <- vapply(seq_len(nrow(ev)), function(i) {
        aa <- unlist(str_split(ev[["anclas_aceptadas"]][i], ";"))
        aa <- str_trim(aa[nzchar(str_trim(aa))])
        if (all(vapply(aa, clase_de, character(1)) != "articulo")) ev[["id"]][i] else NA_character_ }, character(1))
      paste(na.omit(ids), collapse = ", ") }, "\n")

a3_md <- fs::dir_ls(LAB, regexp = "a3_(ruta|tema)_.*[.]md$")
anc3 <- unlist(map(a3_md, function(f) str_match_all(paste(readLines(f, warn = FALSE), collapse = "\n"), 'ancla: "([^"]+)"')[[1]][, 2]))
cl3 <- vapply(anc3, clase_de, character(1))
cat("A3, anclas de las 4 piezas (36):"); print(table(cl3))
cat("   descartadas por el filtro:", sum(cl3 != "articulo"), "de", length(cl3), "| distintas:", n_distinct(anc3[cl3 != "articulo"]), "\n")
pri1 <- unlist(map(a3_md, function(f) str_match_all(paste(readLines(f, warn = FALSE), collapse = "\n"),
                                                    'ancla: "([^"]+)", nivel: [a-z_]+, prioridad: 1')[[1]][, 2]))
cat("   de las", length(pri1), "fuentes con prioridad 1 de A3, descartadas:", sum(vapply(pri1, clase_de, character(1)) != "articulo"),
    "->", paste(pri1[vapply(pri1, clase_de, character(1)) != "articulo"], collapse = "; "), "\n")
cat("CONTROL POSITIVO del clasificador: 'ley_21801_celulares.html#art-10-bis' ->", clase_de("ley_21801_celulares.html#art-10-bis"),
    "| 'dictamen_065_revision_mochilas.html#materia' ->", clase_de("dictamen_065_revision_mochilas.html#materia"),
    "| 'circular_812_identidad_genero.html#ocr-pagina-008' ->", clase_de("circular_812_identidad_genero.html#ocr-pagina-008"), "\n")

# =============================================================================
# BLOQUE 4. OCR en la linea base de A2 y en su conjunto de evaluacion
# =============================================================================
cab("B4. Cuanto de la cota superior de A2 lo sostiene texto no citable")
lb <- read_csv(file.path(LAB, "a2_linea_base_pagefind.csv"), show_col_types = FALSE)
prim <- lb |> filter(variante == "canonico", lectura == "C_sub_puntaje") |> select(id, consulta, primer_resultado)
prim <- prim |> mutate(es_ocr = str_detect(primer_resultado, "ocr-pagina-"))
print(as.data.frame(prim), row.names = FALSE)
cat("primer sub-resultado por puntaje que es una pagina OCR sin revisar (variante canonico):",
    sum(prim[["es_ocr"]]), "de", nrow(prim), "\n")
slugs_ocr <- names(normas)[map_lgl(normas, function(n) identical(n[["origen_texto"]], "ocr_pendiente_revision"))]
cat("normas OCR (recuento propio):", length(slugs_ocr), "->", paste(slugs_ocr, collapse = ", "), "\n")
prim_sf <- lb |> filter(variante == "sin_filtro", lectura == "A_pagina") |> select(id, primer_resultado) |>
  mutate(sin_resultado = is.na(primer_resultado),
         es_ocr_norma = !is.na(primer_resultado) & str_detect(primer_resultado, paste(slugs_ocr, collapse = "|")))
cat("variante sin_filtro: consultas sin ninguna pagina devuelta:", sum(prim_sf[["sin_resultado"]]),
    "-> ", paste(prim_sf[["id"]][prim_sf[["sin_resultado"]]], collapse = ", "), "\n")
cat("variante sin_filtro: primera PAGINA devuelta que es una norma OCR:", sum(prim_sf[["es_ocr_norma"]]),
    "de", sum(!prim_sf[["sin_resultado"]]), "consultas con resultado ->",
    paste(prim_sf[["id"]][prim_sf[["es_ocr_norma"]]], collapse = ", "), "\n")
cat("consultas de A2 cuya unica ancla esperada es OCR:", sum(cl_esp == "pagina_ocr"), "->",
    paste(ev[["id"]][cl_esp == "pagina_ocr"], collapse = ", "), "\n")
cat("CONTROL POSITIVO del detector de OCR en la cadena: 'dictamen_065#fuentes' contiene 'ocr-pagina-'?",
    str_detect("dictamen_065_revision_mochilas.html#fuentes", "ocr-pagina-"),
    "| 'circular_812#ocr-pagina-008'?", str_detect("circular_812_identidad_genero.html#ocr-pagina-008", "ocr-pagina-"), "\n")

# =============================================================================
# BLOQUE 5. Nivel por tipo (A3 §7.2): quien firma cada tipo
# =============================================================================
cab("B5. La regla nivel = f(tipo) de A3 §7.2 contra el organo emisor real")
tipos <- map_dfr(normas, function(n) {
  txt <- paste(vapply(n[["articulos"]], function(a) a[["texto"]], character(1)), collapse = " ")
  tibble(slug = n[["slug"]], tipo = n[["tipo"]],
         titulo = if (is.null(n[["titulo"]])) NA_character_ else n[["titulo"]],
         n_superint = str_count(pl(paste(coalesce(if (is.null(n[["titulo"]])) NA_character_ else n[["titulo"]], ""), txt)), "superintendencia"))
})
tipos <- tipos |> mutate(nivel_a3 = if_else(tipo == "dictamen", "pronunciamiento_oficial", "fuente_primaria"),
                         emisor_superint = n_superint > 0)
print(tipos |> count(tipo, nivel_a3, emisor_superint) |> as.data.frame(), row.names = FALSE)
cat("\nNormas que nombran a la Superintendencia de Educacion en su titulo o texto, con el nivel que A3 les asigna:\n")
print(tipos |> filter(emisor_superint) |> select(slug, tipo, nivel_a3, n_superint) |> arrange(nivel_a3, slug) |> as.data.frame(), row.names = FALSE)
cat("\nCONTROL POSITIVO del detector: 'superintendencia' en el corpus (segmentos):",
    sum(str_detect(pl(seg[["texto"]]), "superintendencia")), "de", nrow(seg),
    "| CONTROL NEGATIVO: 'ministerio de hacienda' en el corpus:",
    sum(str_detect(pl(seg[["texto"]]), "ministerio de hacienda")), "segmentos\n")
cat("Reparto de los 3 tipos de acto de la Superintendencia entre los dos niveles de A3:\n")
print(tipos |> filter(emisor_superint) |> count(nivel_a3, tipo) |> as.data.frame(), row.names = FALSE)

# =============================================================================
# BLOQUE 6. Cifras cruzadas A2/A4 sobre el mismo objeto: el indice vectorial
# =============================================================================
cab("B6. El mismo indice, dos pesos: la formula de A2 lleva metadatos y la de A4 no")
peso_a2 <- function(N, dim, bytes_dim) N * dim * bytes_dim + N * 57.8
peso_a4 <- function(N, dim, bytes_dim) N * dim * bytes_dim
comp <- tibble(N = c(682L, 682L, 722L, 806L, 1160L, 1344L), dim = c(384L, 1024L, 384L, 384L, 384L, 1024L)) |>
  mutate(int8_con_metadatos_A2 = peso_a2(N, dim, 1), int8_sin_metadatos_A4 = peso_a4(N, dim, 1),
         kb_A2 = round(int8_con_metadatos_A2 / 1024, 1), kb_A4 = round(int8_sin_metadatos_A4 / 1024, 1),
         dif_kb = round((int8_con_metadatos_A2 - int8_sin_metadatos_A4) / 1024, 1))
print(as.data.frame(comp), row.names = FALSE)
cat("A2 §3 declara 294,2 KB para 682x384 int8; A4 §8.2 declara 261.888 bytes (255,8 KB) para lo mismo.\n")
cat("A2 dimensiona sobre 1.160 fragmentos firmados; A4 dimensiona sobre 682 articulos. Razon:",
    round(1160 / 682, 2), "x\n")

# =============================================================================
# BLOQUE 7. Recuento de las cifras propias de fase 1 que A5 usa en veredictos
# =============================================================================
cab("B7. Cifras de la fase 1 de A5, recontadas en este turno")

PAT_CITA <- "ley\\s+n?[°º]?\\s*[0-9]{1,2}[.]?[0-9]{3}"   # patron literal de a5_dimensiones.R §4
cita_num <- str_detect(tolower(seg[["texto"]]), PAT_CITA)
cat("segmentos con al menos una cita numerica de ley:", sum(cita_num), "de", nrow(seg),
    sprintf("(%.1f%%)", 100 * mean(cita_num)), "| A5 fase 1 reporto 408 de 806\n")
cat("CONTROL POSITIVO: el patron encuentra 'LEY N° 21.801' (mayusculas) ->", str_detect(tolower("LEY N° 21.801"), PAT_CITA),
    "| CONTROL NEGATIVO: en 'ley de subvenciones' ->", str_detect("ley de subvenciones", PAT_CITA), "\n")
dupl_ley <- seg |> filter(tipo == "ley", es_articulo) |> count(id) |> filter(n >= 2)
dupl_all <- seg |> filter(es_articulo) |> count(id) |> filter(n >= 2)
cat("ids de articulo presentes en 2 o mas LEYES (universo de la fase 1):", nrow(dupl_ley), "| A5 fase 1 reporto 90\n")
cat("ids de articulo presentes en 2 o mas NORMAS (universo ampliado):", nrow(dupl_all), "\n")
cat("  art-16-b en:", paste(seg[["slug"]][seg[["id"]] == "art-16-b"], collapse = ", "), "\n")
cat("piezas: borradores", length(fs::dir_ls(here::here("20_insumos","curaduria","piezas","borradores"), glob = "*.md")),
    "| con 'estado: validada' en 20_insumos/curaduria/piezas:",
    length(system("grep -rl '^estado: validada' 20_insumos/curaduria/piezas 2>/dev/null", intern = TRUE)), "\n")
cat("normas por origen_texto:"); print(table(map_chr(normas, function(n) n[["origen_texto"]])))
cat("normas con vigencia sustituida:", sum(map_lgl(normas, function(n) identical(n[["vigencia"]][["estado"]], "sustituido"))),
    "| con anio nulo:", sum(map_lgl(normas, function(n) is.null(n[["anio"]]))), "\n")
cat("unidades OCR / total:", sum(seg[["clase"]] == "pagina_ocr"), "/", nrow(seg),
    sprintf("(%.1f%%)", 100 * mean(seg[["clase"]] == "pagina_ocr")), "\n")

cab("B7.1 Insignias en el HTML (A3 §7.1 y A5 §6.3), recontadas")
htmls <- fs::dir_ls(SITIO, glob = "*.html")
txt_html <- set_names(map_chr(htmls, function(f) paste(readLines(f, warn = FALSE), collapse = "\n")), basename(htmls))
for (b in c("badge-normativa", "badge-orientacion", "badge-evidencia", "badge-interpretacion", "badge-ocr", "badge-sustituida")) {
  cat(sprintf("  %-22s paginas %2d | ocurrencias %3d\n", b,
              sum(map_int(txt_html, function(h) str_count(h, fixed(b))) > 0),
              sum(map_int(txt_html, function(h) str_count(h, fixed(b))))))
}
cat("  CONTROL NEGATIVO: 'badge-inexistente-a5' paginas", sum(map_int(txt_html, function(h) str_count(h, fixed("badge-inexistente-a5"))) > 0), "\n")

cab("B7.2 El rotulo dentro del cuerpo indexado (H-1), recontado sobre el HTML publicado")
cuerpos <- seg |> filter(clase != "pagina_ocr")
# El rotulo corto de la norma, tal como lo produce el sitio (nombre_corto() del pipeline).
rot <- map_chr(normas, function(n) nombre_corto(n))
cat("rotulos cortos (muestra):", paste(head(unname(rot), 6), collapse = " | "), "\n")
tiene_rotulo <- map2_lgl(cuerpos[["texto"]], cuerpos[["slug"]],
                         function(t, s) str_detect(pl(t), fixed(pl(rot[[s]]))))
cat("segmentos firmados cuyo TEXTO contiene el rotulo corto de su propia norma:",
    sum(tiene_rotulo), "de", nrow(cuerpos), "\n")
cat("CONTROL POSITIVO del detector: el rotulo de ley_21801 ('", rot[["ley_21801_celulares"]],
    "') aparece en el texto de algun segmento del corpus: ",
    sum(str_detect(pl(seg[["texto"]]), fixed(pl(rot[["ley_21801_celulares"]])))), " segmentos\n", sep = "")
cat("CONTROL NEGATIVO: rotulo inventado 'Ley 99.999' en el corpus:",
    sum(str_detect(pl(seg[["texto"]]), fixed("ley 99.999"))), "segmentos\n")
cat("CONTROL POSITIVO (que el universo no esta vacio): segmentos que contienen 'Art':",
    sum(str_detect(cuerpos[["texto"]], "Art")), "de", nrow(cuerpos), "\n")

cat("\n==== FIN ====\n")
