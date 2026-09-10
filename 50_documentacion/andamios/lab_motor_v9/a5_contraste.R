# =============================================================================
# a5_contraste.R  (laboratorio del encargo v9, agente A5: fase 2, contraste)
# -----------------------------------------------------------------------------
# Recuenta, contra los artefactos, cada cifra ajena (A1 a A4) que A5 usa en un
# veredicto de la fase 2, y corrige dos cifras propias de la fase 1. Solo lee.
# Salida por consola; se guarda con tee en a5_contraste_salida.txt.
# Acceso a estructuras leídas de disco: [[ ]] exacto, nunca $.
# =============================================================================
suppressPackageStartupMessages({
  library(jsonlite); library(dplyr); library(purrr); library(stringr)
  library(stringi); library(tibble); library(readr); library(here)
})
options(warnPartialMatchDollar = TRUE)
lab   <- here::here("50_documentacion", "andamios", "lab_motor_v9")
sitio <- here::here("40_salidas", "sitio")
datos <- here::here("40_salidas", "datos")
cab <- function(x) cat("\n==== ", x, " ====\n", sep = "")

cat_json <- jsonlite::fromJSON(file.path(datos, "catalogo.json"), simplifyDataFrame = FALSE)
slugs <- vapply(cat_json[["normas"]], function(x) x[["slug"]], character(1))
normas <- set_names(lapply(slugs, function(s)
  jsonlite::fromJSON(file.path(datos, "normas", paste0(s, ".json")), simplifyDataFrame = FALSE)), slugs)
seg <- map_dfr(normas, function(n) tibble(
  slug = n[["slug"]], origen = n[["origen_texto"]],
  id = vapply(n[["articulos"]], function(a) a[["id"]], character(1)),
  es_articulo = vapply(n[["articulos"]], function(a) isTRUE(a[["es_articulo"]]), logical(1)),
  texto = vapply(n[["articulos"]], function(a) a[["texto"]], character(1))))
seg <- seg |> mutate(clase = case_when(str_starts(id, "ocr-pagina-") ~ "pagina_ocr",
                                       es_articulo ~ "articulo", TRUE ~ "seccion_firmada"))
htmls <- fs::dir_ls(sitio, glob = "*.html")
paginas <- set_names(map(htmls, function(f) paste(readLines(f, warn = FALSE), collapse = "\n")), basename(htmls))

# ---- E1: corrección propia: 835 -> 806 -------------------------------------
cab("E1. Encabezados <h2 id> por página: reconciliación 958 (A1) / 913 (A5) / 806 (A1, A3)")
h2_todos <- map_int(paginas, function(h) str_count(h, '<h2 id="[^"]+"'))
h2_anch  <- map_int(paginas, function(h) str_count(h, '<h2 id="[^"]+" class="anchored">'))
cat("h2 con id (cualquier clase), 47 HTML:", sum(h2_todos), "| con class=anchored:", sum(h2_anch),
    "| diferencia (toc-title):", sum(h2_todos) - sum(h2_anch), "\n")
es_norma <- names(paginas) %in% paste0(slugs, ".html")
cat("h2 anchored en las 25 páginas de norma:", sum(h2_anch[es_norma]),
    "| de ellos 'relacionadas':", sum(map_int(paginas[es_norma], function(h) str_count(h, '<h2 id="relacionadas"'))),
    "| restantes (= anclas de segmento):", sum(h2_anch[es_norma]) - sum(map_int(paginas[es_norma], function(h) str_count(h, '<h2 id="relacionadas"'))), "\n")
cat("h2 anchored en páginas que NO son de norma (tema-*, indice-*, acerca, index):", sum(h2_anch[!es_norma]), "\n")
cat("segmentos con ancla en los JSON:", nrow(seg), "= articulo", sum(seg[["clase"]] == "articulo"),
    "+ pagina_ocr", sum(seg[["clase"]] == "pagina_ocr"), "+ seccion_firmada", sum(seg[["clase"]] == "seccion_firmada"), "\n")
cat("CORRECCIÓN A5: los sub-resultados indexables de Pagefind son 806, no 835; los 29 de diferencia son h2 de indice-*/acerca que A5 clasificó como 'seccion_sin_articulado'.\n")

# ---- E2: corrección propia: caracteres --------------------------------------
cab("E2. Caracteres del texto: suma directa vs suma con separadores")
cat("suma de nchar(texto) sobre 806 segmentos:", sum(nchar(seg[["texto"]])), "(A4 §8.1 reporta 1.429.841)\n")
cat("nchar del texto unido con '\\n' (lo que A5 reportó):", nchar(paste(seg[["texto"]], collapse = "\n")), "= suma + 805 separadores\n")

# ---- A2: 'celular' y 'nombre social' en el TEXTO por origen -----------------
cab("A2 §5: términos en el texto de las unidades, firmadas vs OCR (no en el nombre de archivo)")
pl <- function(x) tolower(stri_trans_general(x, "Latin-ASCII"))
tx <- pl(seg[["texto"]])
for (t in c("celular", "nombre social", "dispositivos moviles")) {
  hit <- str_detect(tx, fixed(t))
  cat(sprintf("  '%s': unidades firmadas %d | unidades OCR %d | normas: %s\n", t,
              sum(hit & seg[["origen"]] == "capa_texto_pdf"), sum(hit & seg[["origen"]] == "ocr_pendiente_revision"),
              paste(unique(seg[["slug"]][hit]), collapse = ", ")))
}

# ---- A3: anclas de las 4 piezas de laboratorio, verificadas y clasificadas --
cab("A3 §2.2: anclas de a3_ruta_* y a3_tema_*: existencia en HTML y clase de segmento")
a3_md <- fs::dir_ls(lab, regexp = "a3_(ruta|tema)_.*[.]md$")
anclas_a3 <- unlist(map(a3_md, function(f) str_match_all(paste(readLines(f, warn = FALSE), collapse = "\n"), 'ancla: "([^"]+)"')[[1]][, 2]))
cat("archivos:", length(a3_md), "| anclas (con repetición):", length(anclas_a3), "| distintas:", n_distinct(anclas_a3), "\n")
verifica <- function(a) { m <- str_match(a, "^([^#]+)#(.+)$"); h <- paginas[[m[2]]]
  !is.null(h) && str_count(h, fixed(sprintf('id="%s"', m[3]))) >= 1 }
existen <- vapply(anclas_a3, verifica, logical(1))
cat("anclas que existen en el HTML (A5 recuenta):", sum(existen), "de", length(anclas_a3), "\n")
cat("CONTROL: ancla plantada 'ley_21801_celulares.html#art-99' existe?", verifica("ley_21801_celulares.html#art-99"),
    "| 'ley_21801_celulares.html#art-10-bis'?", verifica("ley_21801_celulares.html#art-10-bis"), "\n")
clase_de <- function(a) { m <- str_match(a, "^([^#]+)[.]html#(.+)$"); s <- seg |> filter(slug == m[2], id == m[3]); if (nrow(s) == 0) "inexistente" else s[["clase"]][1] }
cl <- vapply(anclas_a3, clase_de, character(1))
cat("clase de las 36 anclas:"); print(table(cl))
cat("anclas que el filtro es_articulo === true del Worker de A4 (a4_worker_esqueleto.js:186) DESCARTARÍA:",
    sum(cl != "articulo"), "de", length(cl), "| distintas:", n_distinct(anclas_a3[cl != "articulo"]), "\n")

# ---- A2: las 19 anclas aceptadas ---------------------------------------------
cab("A2 §5: las anclas aceptadas del conjunto de evaluación, recontadas por A5")
a2v <- read_csv(file.path(lab, "a2_verificacion_anclas.csv"), show_col_types = FALSE)
ex2 <- vapply(a2v[["ancla_completa"]], verifica, logical(1))
cat("filas:", nrow(a2v), "| existen en HTML:", sum(ex2), "| clase:"); print(table(vapply(a2v[["ancla_completa"]], clase_de, character(1))))
cat("anclas de A2 que el filtro es_articulo del Worker de A4 descartaría:", sum(vapply(a2v[["ancla_completa"]], clase_de, character(1)) != "articulo"), "de", nrow(a2v), "\n")

# ---- A2: línea base y temporalidad, recontadas desde los CSV ----------------
cab("A2 §6.5: línea base (top 3) desde a2_linea_base_resumen.csv")
lb <- read_csv(file.path(lab, "a2_linea_base_resumen.csv"), show_col_types = FALSE)
print(lb |> filter(variante %in% c("sin_filtro", "canonico")) |> select(variante, lectura, top1, top3, no_aparece) |> as.data.frame(), row.names = FALSE)
cab("A2 §4ter: temporalidad desde a2_temporalidad.csv")
tp <- read_csv(file.path(lab, "a2_temporalidad.csv"), show_col_types = FALSE)
cat("normas:", nrow(tp), "| anio NA:", sum(is.na(tp[["anio"]])), "| sustituido:", sum(tp[["estado"]] == "sustituido"),
    "| regia_en_2021 TRUE:", sum(tp[["regia_en_2021"]] %in% TRUE), "| FALSE:", sum(tp[["regia_en_2021"]] %in% FALSE),
    "| NA:", sum(is.na(tp[["regia_en_2021"]])), "| tiene_campo_fecha TRUE:", sum(tp[["tiene_campo_fecha"]] %in% TRUE), "\n")
cat("¿ley_20370 figura como 'regía en 2021'?", tp[["regia_en_2021"]][tp[["slug"]] == "ley_20370_general_educacion"],
    "| marcas BCN del preámbulo de la LGE:",
    str_extract(normas[["ley_20370_general_educacion"]][["articulos"]][[1]][["texto"]], "Fecha Publicaci[^|]{0,22}"), "/",
    str_extract(normas[["ley_20370_general_educacion"]][["articulos"]][[1]][["texto"]], "ltima Modificaci[^ ]{0,4} [0-9A-Z-]+"), "\n")

# ---- A1: consultas proxy y alias, recontados desde los CSV ------------------
cab("A1 §2.2 y §1.4: desde a1_consultas_proxy.csv y a1_alias_prueba.csv")
px <- read_csv(file.path(lab, "a1_consultas_proxy.csv"), show_col_types = FALSE)
cat("consultas proxy:", nrow(px), "| con sugerencia AND (n_todos > 0):", sum(px[["n_todos"]] > 0),
    "| títulos FAQ:", sum(px[["origen"]] == "titulo FAQ borrador"), "| títulos FAQ con AND = 0:", sum(px[["origen"]] == "titulo FAQ borrador" & px[["n_todos"]] == 0), "\n")
cat("títulos FAQ cuyo top1 en modo OR es 'identidad de género':", sum(px[["origen"]] == "titulo FAQ borrador" & str_detect(px[["top1_alguno"]], "identidad de género")), "\n")
al <- read_csv(file.path(lab, "a1_alias_prueba.csv"), show_col_types = FALSE)
cat("alias probados:", nrow(al), "| con 0 sugerencias:", sum(al[["n"]] == 0), "\n")
for (q in c("SEP", "DFL 2", "estatuto asistentes", "ley de subvenciones", "dictamen 65"))
  cat(sprintf("  '%s' -> n=%s, top1=%s\n", q, al[["n"]][al[["consulta"]] == q], al[["top1"]][al[["consulta"]] == q]))

# ---- A1: verificación propia de los destinos de vocabulario.json ------------
cab("A1 §3: destinos de vocabulario.json verificados por A5 contra el HTML")
voc <- jsonlite::fromJSON(file.path(lab, "vocabulario.json"), simplifyDataFrame = FALSE)
ent <- voc[["entradas"]]
cat("n_entradas declarado:", voc[["n_entradas"]], "| entradas leídas:", length(ent), "\n")
dest <- vapply(ent, function(e) if (is.null(e[["destino"]])) NA_character_ else e[["destino"]], character(1))
cat("con destino:", sum(!is.na(dest)), "| sin destino:", sum(is.na(dest)), "\n")
ok_dest <- vapply(dest[!is.na(dest)], function(d) {
  if (str_detect(d, "#")) verifica(d) else !is.null(paginas[[d]]) }, logical(1))
cat("destinos que resuelven (página existe y, si hay ancla, el id existe):", sum(ok_dest), "de", length(ok_dest), "\n")
cat("CONTROL: destino plantado 'tema-no-existe.html' resuelve?", !is.null(paginas[["tema-no-existe.html"]]), "\n")
tipos <- vapply(ent, function(e) e[["tipo"]], character(1)); print(table(tipos))
cit <- vapply(ent, function(e) isTRUE(e[["citable"]]), logical(1))
cat("entradas tipo articulo con citable = FALSE (páginas OCR, regla 6 de A1):", sum(tipos == "articulo" & !cit), "\n")

# ---- H-2 contra el artefacto real: las 38 consultas de A5 por el resolutor mínimo ----
cab("H-2: las 38 consultas de A5 contra vocabulario.json con las reglas 1, 4 y 6 de A1 (reimplementación mínima, NO el resolutor de A1)")
norm_a1 <- function(x) { x <- pl(x); x <- gsub("(?<=\\d)[.](?=\\d)", "", x, perl = TRUE); str_extract_all(x, "[a-z0-9]+")[[1]] }
STOP_A1 <- c("n","no","num","numero","de","del","la","el","los","las","y","o","a","en","sobre","que","un","una","al","por","para","con","se","su","sus","lo","es","e","u")
tok_ent <- map(ent, function(e) unique(unlist(map(c(e[["termino"]], unlist(e[["alias"]])), norm_a1))))
sugerir_min <- function(q, modo = "AND") {
  qt <- setdiff(norm_a1(q), STOP_A1); if (length(qt) == 0) return(0L)
  con_num <- any(str_detect(qt, "^[0-9]"))
  hits <- map_lgl(seq_along(ent), function(i) {
    e <- ent[[i]]
    if (identical(e[["tipo"]], "articulo") && !con_num) return(FALSE)            # regla 4
    if (identical(e[["tipo"]], "articulo") && !isTRUE(e[["citable"]])) return(FALSE) # regla 6
    m <- vapply(qt, function(t) any(startsWith(tok_ent[[i]], t)), logical(1))
    if (modo == "AND") all(m) else any(m) })
  sum(hits) }
cs <- read_csv(file.path(lab, "a5_consultas_equipo.csv"), show_col_types = FALSE)
res <- cs |> mutate(n_AND = map_int(consulta, sugerir_min, modo = "AND"), n_OR = map_int(consulta, sugerir_min, modo = "OR"))
print(res |> select(id, consulta, n_AND, n_OR) |> as.data.frame(), row.names = FALSE)
cat(sprintf("consultas con >= 1 sugerencia con AND (contrato de A1 §4.3): %d de %d | con OR (solo diagnóstico): %d de %d\n",
            sum(res[["n_AND"]] > 0), nrow(res), sum(res[["n_OR"]] > 0), nrow(res)))
cat("CONTROLES (casos plantados de A1 por el mismo resolutor mínimo): 'celu' =", sugerir_min("celu"), "| 'mochila' =", sugerir_min("mochila"),
    "| 'circular 482' =", sugerir_min("circular 482"), "| 'xyzzy' =", sugerir_min("xyzzy"), "| 'convivencia' =", sugerir_min("convivencia"), "\n")
stopifnot(sugerir_min("celu") >= 1, sugerir_min("mochila") >= 1, sugerir_min("xyzzy") == 0)
write_csv(res, file.path(lab, "a5_contraste_consultas_vs_a1.csv"))

# ---- A3: estado de las piezas del laboratorio y archivos con 'validada' -----
cab("A3 §1.4 y §6.3: estado de las 4 piezas de laboratorio y dónde aparece 'estado: validada' en a3_*")
a3_all <- fs::dir_ls(lab, regexp = "a3_")
con_val <- a3_all[map_lgl(a3_all, function(f) any(str_detect(readLines(f, warn = FALSE), "estado: validada")))]
con_bor <- a3_all[map_lgl(a3_all, function(f) any(str_detect(readLines(f, warn = FALSE), "estado: borrador")))]
cat("archivos a3_* con 'estado: validada':", length(con_val), "->", paste(basename(con_val), collapse = ", "), "\n")
cat("archivos a3_* con 'estado: borrador' (control):", length(con_bor), "\n")
cat("piezas .md de A3 con estado: borrador y validado_por: null:",
    sum(map_lgl(a3_md, function(f) { l <- readLines(f, warn = FALSE); any(l == "estado: borrador") && any(l == "validado_por: null") })), "de", length(a3_md), "\n")
cat("generado_por de las piezas de A3:", paste(unique(unlist(map(a3_md, function(f) grep("^generado_por:", readLines(f, warn = FALSE), value = TRUE)))), collapse = " | "), "\n")
cat("a3_tema_revision_de_pertenencias.md: fuentes con prioridad 1:",
    paste(str_match_all(paste(readLines(file.path(lab, "a3_tema_revision_de_pertenencias.md"), warn = FALSE), collapse = "\n"),
                        'ancla: "([^"]+)", nivel: [a-z_]+, prioridad: 1')[[1]][, 2], collapse = "; "), "\n")

# ---- A4: el filtro es_articulo del Worker, en el código ---------------------
cab("A4 §5.2: filtro del Worker sobre es_articulo (a4_worker_esqueleto.js)")
js <- readLines(file.path(lab, "a4_worker_esqueleto.js"), warn = FALSE)
cat("líneas con 'es_articulo':", paste(grep("es_articulo", js), collapse = ", "), "\n")
cat("  ", trimws(js[grep("es_articulo", js)]), sep = "\n")
cat("segmentos firmados que ese filtro descarta (es_articulo FALSE y origen capa_texto_pdf):", sum(!seg[["es_articulo"]] & seg[["origen"]] == "capa_texto_pdf"),
    "| páginas OCR que también descarta:", sum(seg[["clase"]] == "pagina_ocr"), "\n")
