# a5_fase3_verificacion.R — encargo v9, FASE 3 (corrección), agente A5.
# Re-deriva, en un solo turno y con control positivo y negativo, todas las cifras que
# la auditoría 20260904_auditoria_alcance_motor_v1.md refutó en
# 20260904_panel_adversarial_motor_v1.md. Solo lectura: no escribe nada fuera de stdout.
# Uso: Rscript 50_documentacion/andamios/lab_motor_v9/a5_fase3_verificacion.R
suppressPackageStartupMessages({library(jsonlite); library(readr); library(here)})
cab <- function(x) cat("\n==== ", x, " ====\n", sep = "")
lab   <- here::here("50_documentacion", "andamios", "lab_motor_v9")
andam <- here::here("50_documentacion", "andamios")
datos <- here::here("40_salidas", "datos")
sitio <- here::here("40_salidas", "sitio")

# ---- CIF-A5-01: residuo de consultas sin ruta lexica ni por prefijo ----------
cab("CIF-A5-01  residuo sin ruta lexica ni por prefijo")
r <- read_csv(file.path(lab, "a5_cobertura_resultado.csv"), show_col_types = FALSE)
sin_ruta <- r[["id"]][r[["C_prefijo"]] == 0]
cat("filas del artefacto:", nrow(r), "\n")
cat("C_prefijo == 0 ->", paste(sin_ruta, collapse = ", "), "| n =", length(sin_ruta),
    "de", nrow(r), sprintf("(%.1f %%)", 100 * length(sin_ruta) / nrow(r)), "\n")
cat("CONTROL POSITIVO (complemento, mismo detector): C_prefijo >= 1 ->",
    sum(r[["C_prefijo"]] >= 1), "de", nrow(r), "\n")
cat("CONTROL NEGATIVO (umbral imposible): C_prefijo < 0 ->", sum(r[["C_prefijo"]] < 0), "\n")
cat("perfil de las cuatro que la fase 1 nombro:\n")
print(as.data.frame(r[r[["id"]] %in% c("q03","q17","q23","q28"),
                      c("id","n_terminos","C_exacto","C_prefijo","faltan_en_corpus")]))
cat("criterio alternativo 'algun termino ausente del corpus':",
    sum(!is.na(r[["faltan_en_corpus"]]) & nzchar(r[["faltan_en_corpus"]])), "de", nrow(r), "\n")

# ---- CIF-A5-02: primera sugerencia de q21 "aula segura" ---------------------
cab("CIF-A5-02  primera sugerencia de q21")
c38 <- read_csv(file.path(lab, "a5_contraste_38_vs_resolutor_a1.csv"), show_col_types = FALSE)
print(as.data.frame(c38[c38[["id"]] %in% c("q11","q21"), c("id","consulta","n_and","n_or","top1_or")]))
cat("filas cuyo top1_or contiene 'MEDIDA CAUTELAR':",
    paste(c38[["id"]][grepl("MEDIDA CAUTELAR", c38[["top1_or"]])], collapse = ", "), "\n")
cat("CONTROL POSITIVO: top1_or con 'Dictamen' ->", sum(grepl("Dictamen", c38[["top1_or"]])), "filas\n")
cat("CONTROL NEGATIVO: top1_or con 'ZORBLAT' ->", sum(grepl("ZORBLAT", c38[["top1_or"]])), "filas\n")

# ---- CIF-A5-03: "Aula Segura" en las consultas de A2, sin y con mayusculas ---
cab("CIF-A5-03  Aula Segura en a2_consultas_evaluacion.csv")
a2 <- read_csv(file.path(lab, "a2_consultas_evaluacion.csv"), show_col_types = FALSE)
for (col in c("consulta","por_que","ancla_esperada","cita_objetivo")) {
  s <- grepl("aula segura", a2[[col]], ignore.case = TRUE)
  n <- grepl("aula segura", a2[[col]], ignore.case = FALSE)
  cat(sprintf("  %-15s  con -i: %d (%s) | sin -i: %d\n", col, sum(s),
              paste(a2[["id"]][s], collapse = ", "), sum(n)))
}
cat("CONTROL POSITIVO (termino que si abunda): 'ley' en por_que ->",
    sum(grepl("ley", a2[["por_que"]], ignore.case = TRUE)), "de", nrow(a2), "\n")
cat("CONTROL NEGATIVO: 'zorblat' en por_que ->",
    sum(grepl("zorblat", a2[["por_que"]], ignore.case = TRUE)), "\n")
cat("consultas SIN ancla esperada (respuesta 'no esta en el corpus'):",
    sum(is.na(a2[["ancla_esperada"]]) | !nzchar(a2[["ancla_esperada"]])), "de", nrow(a2), "\n")
cat("CONTROL POSITIVO: consultas CON ancla esperada:",
    sum(!is.na(a2[["ancla_esperada"]]) & nzchar(a2[["ancla_esperada"]])), "de", nrow(a2), "\n")

# ---- CIF-A5-04: lineas de los documentos leidos en fase 2 -------------------
cab("CIF-A5-04  lineas de los documentos leidos en fase 2")
docs <- c("20260904_alcance_capa1_vocabulario_v1.md","20260904_alcance_capa2_semantica_v1.md",
          "20260904_alcance_capa3_orientacion_v1.md","20260904_alcance_arquitectura_cloudflare_v1.md",
          "20260904_prototipo_vocabulario.R","20260904_medicion_corpus_semantica.R")
sello_arbol <- format(Sys.time(), "%Y-%m-%d %H:%M")
cat("Los cinco documentos que A5 leyo en fase 2 los editan OTROS agentes en la fase 3,\n",
    "de modo que el conteo del arbol de trabajo caduca: se fija por commit.\n")
cat("La columna 'arbol' es perecible y por eso va fechada:", sello_arbol,
    "(corr. cierre fase 3, N-12: la version anterior la publicaba sin fecha).\n")
for (d in docs) cat(sprintf("  %-52s e71f1e0 %4d | 80d291e %4d | arbol %4d\n", d,
  length(system(paste0("git show e71f1e0:50_documentacion/andamios/", d), intern = TRUE)),
  length(system(paste0("git show 80d291e:50_documentacion/andamios/", d), intern = TRUE)),
  length(readLines(file.path(andam, d), warn = FALSE))))
cat("HEAD:", system("git rev-parse --short HEAD", intern = TRUE), "\n")
cat("capa3 en HEAD:", length(system(
  "git show HEAD:50_documentacion/andamios/20260904_alcance_capa3_orientacion_v1.md", intern = TRUE)), "lineas\n")
cat("capa3 en e71f1e0 (commit de fase 1):", length(system(
  "git show e71f1e0:50_documentacion/andamios/20260904_alcance_capa3_orientacion_v1.md", intern = TRUE)), "lineas\n")

# ---- CIF-A5-05: caracteres, bytes UTF-8 y gzip del texto --------------------
cab("CIF-A5-05  caracteres, bytes UTF-8 y gzip del texto")
catj  <- fromJSON(file.path(datos, "catalogo.json"), simplifyVector = FALSE)
slugs <- vapply(catj[["normas"]], function(n) n[["slug"]], character(1))
normas <- lapply(slugs, function(s)
  fromJSON(file.path(datos, "normas", paste0(s, ".json")), simplifyVector = FALSE))
names(normas) <- slugs
textos <- unlist(lapply(normas, function(n)
  vapply(n[["articulos"]], function(a) a[["texto"]], character(1))))
pegado <- paste(textos, collapse = "\n")
cat("segmentos:", length(textos), "| separadores del pegado:", length(textos) - 1, "\n")
cat("caracteres  sum(nchar):", sum(nchar(textos)), "| pegado:", nchar(pegado),
    "| diferencia:", nchar(pegado) - sum(nchar(textos)), "\n")
cat("bytes UTF-8 sum(nchar,'bytes'):", sum(nchar(textos, type = "bytes")),
    "| pegado:", nchar(pegado, type = "bytes"),
    "| diferencia:", nchar(pegado, type = "bytes") - sum(nchar(textos, type = "bytes")), "\n")
tmp_gz <- tempfile(fileext = ".gz")
con <- gzfile(tmp_gz, "wb"); writeLines(pegado, con); close(con)
cat("gzip gzfile+writeLines (metodo de a5_dimensiones.R):", file.size(tmp_gz), "bytes\n")
cat("gzip memCompress(type='gzip'):", length(memCompress(charToRaw(pegado), type = "gzip")), "bytes\n")
cat("CONTROL POSITIVO ASCII  nchar('abcde') =", nchar("abcde"),
    "| bytes =", nchar("abcde", type = "bytes"), "\n")
cat("CONTROL POSITIVO acentos nchar('ñáé') =", nchar("ñáé"),
    "| bytes =", nchar("ñáé", type = "bytes"), "(bytes > caracteres: el detector distingue)\n")
cat("CONTROL NEGATIVO cadena vacia:", nchar(""), "|", nchar("", type = "bytes"), "\n")

# ---- CIF-A5-06: search.json y rango de paginas OCR --------------------------
cab("CIF-A5-06  search.json: control calibrado de los dos ceros")
sj <- fromJSON(file.path(sitio, "search.json"), simplifyVector = FALSE)
href <- vapply(sj, function(e) e[["href"]], character(1))
cat("bytes:", file.size(file.path(sitio, "search.json")), "| entradas:", length(sj), "\n")
cat("href con '#ocr-pagina-':", sum(grepl("#ocr-pagina-", href, fixed = TRUE)),
    "| href con '#art-':", sum(grepl("#art-", href, fixed = TRUE)), "\n")
cat("CONTROL CALIBRADO (mismo campo, mismo detector): href con '#':",
    sum(grepl("#", href, fixed = TRUE)), "| href con '.html':",
    sum(grepl(".html", href, fixed = TRUE)), "de", length(href), "\n")
cat("CONTROL NEGATIVO: href con '#zorblat-':", sum(grepl("#zorblat-", href, fixed = TRUE)), "\n")
ocr <- vapply(normas, function(n)
  sum(startsWith(vapply(n[["articulos"]], function(a) a[["id"]], character(1)), "ocr-pagina-")), integer(1))
ocr <- ocr[ocr > 0]
cat("paginas OCR por norma:", paste(ocr, collapse = " / "), "| total", sum(ocr),
    "en", length(ocr), "normas | rango", min(ocr), "a", max(ocr), "\n")

# ---- CIF-A5-07: de donde sale el 240 ----------------------------------------
cab("CIF-A5-07  el 240 es el truncamiento fijo del propio script")
l <- readLines(file.path(lab, "a5_verificacion_extra.R"), warn = FALSE)
idx <- grep("240", l)
for (i in idx) cat("  L", i, ": ", trimws(l[i]), "\n", sep = "")
cat("lineas del script que contienen '240':", length(idx), "\n")
cat("CONTROL NEGATIVO: lineas con 'pagefind' (el script nunca consulta el indice):",
    length(grep("pagefind", l, ignore.case = TRUE)), "\n")

# ---- CIF-A5-08: cifra de E-4 ------------------------------------------------
cab("CIF-A5-08  E-4: segmentos que nombran su propia norma")
firm <- sum(vapply(normas, function(n)
  sum(!startsWith(vapply(n[["articulos"]], function(a) a[["id"]], character(1)), "ocr-pagina-")), integer(1)))
cat("segmentos firmados en todo el corpus (no OCR):", firm, "\n")
sel <- vapply(normas, function(n) {
  num <- n[["numero"]]
  !is.null(num) && identical(n[["tipo"]], "ley") && nchar(gsub("[^0-9]", "", num)) >= 4
}, logical(1))
tot <- 0L; con_n <- 0L
for (s in names(normas)[sel]) {
  n <- normas[[s]]; d <- gsub("[^0-9]", "", n[["numero"]])
  pat <- paste0(substr(d, 1, 2), "\\.?", substr(d, 3, 5))
  ids <- vapply(n[["articulos"]], function(a) a[["id"]], character(1))
  txt <- vapply(n[["articulos"]], function(a) a[["texto"]], character(1))
  keep <- !startsWith(ids, "ocr-pagina-")
  tot <- tot + sum(keep); con_n <- con_n + sum(grepl(pat, txt[keep]))
}
cat("normas 'ley' con numero de 4+ digitos:", sum(sel), "| sus segmentos firmados:", tot,
    "| con el numero de su PROPIA norma:", con_n, sprintf("(%.1f %%)", 100 * con_n / tot), "\n")
cat("complemento (los que NO nombran su propia norma):", tot - con_n, "de", tot,
    sprintf("(%.1f %%)", 100 * (tot - con_n) / tot),
    "-- denominador explicito, corr. cierre fase 3\n")
# El control corre sobre la MISMA poblacion que la cifra que calibra: segmentos
# firmados, excluyendo las paginas OCR (corr. cierre fase 3, control descalibrado).
propia <- 0L; ajenas <- 0L; propia_con_ocr <- 0L; ajenas_con_ocr <- 0L
for (s in names(normas)) {
  n <- normas[[s]]
  ids <- vapply(n[["articulos"]], function(a) a[["id"]], character(1))
  txt <- vapply(n[["articulos"]], function(a) a[["texto"]], character(1))
  keep <- !startsWith(ids, "ocr-pagina-")
  h  <- sum(grepl("20\\.?370", txt[keep]))
  ht <- sum(grepl("20\\.?370", txt))
  num <- if (is.null(n[["numero"]])) "" else gsub("[^0-9]", "", n[["numero"]])
  if (identical(num, "20370")) {
    propia <- propia + h; propia_con_ocr <- propia_con_ocr + ht
  } else {
    ajenas <- ajenas + h; ajenas_con_ocr <- ajenas_con_ocr + ht
  }
}
cat("CONTROL POSITIVO patron 20\\.?370 sobre SEGMENTOS FIRMADOS (misma poblacion que la cifra):",
    "propia norma", propia, "| otras normas", ajenas, "\n")
cat("  (con paginas OCR incluidas, poblacion distinta y por eso no es el control:",
    "propia", propia_con_ocr, "| otras", ajenas_con_ocr, ")\n")
cat("CONTROL NEGATIVO patron 99\\.?999 en todo el corpus:", sum(vapply(normas, function(n)
  sum(grepl("99\\.?999", vapply(n[["articulos"]], function(a) a[["texto"]], character(1)))), integer(1))), "\n")

# ---- CIF-A5-09 y UNI-A5-01 --------------------------------------------------
cab("CIF-A5-09  spans de data-pagefind-filter, por faceta")
htmls <- list.files(sitio, pattern = "[.]html$", full.names = TRUE)
todo <- unlist(lapply(htmls, function(f) {
  h <- paste(readLines(f, warn = FALSE), collapse = "\n")
  regmatches(h, gregexpr('data-pagefind-filter="[^"]*"', h))[[1]]
}))
cat("spans totales del atributo:", length(todo), "\n")
print(table(sub('data-pagefind-filter="([^:]*):.*', "\\1", todo)))
cat("faceta texto, por valor:\n"); print(table(grep('"texto:', todo, value = TRUE)))
cat("CONTROL NEGATIVO: faceta 'zorblat:':", sum(grepl('"zorblat:', todo)), "\n")

cab("UNI-A5-01  cuantos scripts a5_*.R")
todos <- list.files(lab, pattern = "^a5_.*[.]R$")
inst <- setdiff(todos, "a5_fase3_verificacion.R")
cat("instrumentos a5_*.R de fase 1 y 2 en disco:", length(inst), "->", paste(inst, collapse = ", "), "
")
cat("mas el verificador de fase 3 (este script):", length(todos) - length(inst),
    "| total de archivos a5_*.R en disco:", length(todos), "
")
pan <- readLines(file.path(andam, "20260904_panel_adversarial_motor_v1.md"), warn = FALSE)
cit <- sort(unique(unlist(regmatches(pan, gregexpr("a5_[a-z0-9_]+[.]R", pan)))))
cat("citados en el panel:", length(cit), "->", paste(cit, collapse = ", "), "\n")
cat("CONTROL POSITIVO (otro prefijo, mismo patron): a4_*.R citados en el documento de A4:",
    length(sort(unique(unlist(regmatches(
      x <- readLines(file.path(andam, "20260904_alcance_arquitectura_cloudflare_v1.md"), warn = FALSE),
      gregexpr("a4_[a-z0-9_]+[.]R", x)))))), "\n")
cat("CONTROL NEGATIVO (prefijo inexistente): a9_*.R citados:",
    length(unlist(regmatches(pan, gregexpr("a9_[a-z0-9_]+[.]R", pan)))), "\n")

# ---- UNI-A5-02: barrido exhaustivo sobre el orden de construccion -----------
cab("UNI-A5-02  barrido exhaustivo sobre el orden de construccion (A1 a A4)")
d4 <- c(A1 = docs[1], A2 = docs[2], A3 = docs[3], A4 = docs[4])
pats <- c('"orden de construcci"' = "orden de construcci",
          '"primer[ao] en construirse"' = "primer[ao] en construirse",
          '"construir(se)? primero|primero se construye"' = "construir(se)? primero|primero se construye",
          '"capa 3 en vivo"' = "capa 3 en vivo")
# Se leen desde el commit 80d291e y no del arbol de trabajo: los otros agentes
# editan esos archivos en paralelo durante la fase 3 y el conteo caducaria.
ln <- lapply(d4, function(f) system(paste0("git show 80d291e:50_documentacion/andamios/", f), intern = TRUE))
for (p in names(pats)) {
  hits <- vapply(ln, function(l) length(grep(pats[[p]], l, ignore.case = TRUE, perl = TRUE)), integer(1))
  cat(sprintf("  %-48s A1 %d  A2 %d  A3 %d  A4 %d\n", p, hits[1], hits[2], hits[3], hits[4]))
  for (a in names(ln)) {
    idx <- grep(pats[[p]], ln[[a]], ignore.case = TRUE, perl = TRUE)
    if (length(idx)) cat("        ", a, "lineas:", paste(idx, collapse = ", "), "\n")
  }
}
mix <- vapply(ln, function(l) {
  i <- grep("capa", l, ignore.case = TRUE)
  length(i[grepl("primer|antes|orden", l[i], ignore.case = TRUE)])
}, integer(1))
cat(sprintf("  %-48s A1 %d  A2 %d  A3 %d  A4 %d\n",
            'linea con "capa" y ("primer"|"antes"|"orden")', mix[1], mix[2], mix[3], mix[4]))
cp <- vapply(ln, function(l) length(grep("capa", l, ignore.case = TRUE)), integer(1))
cn <- vapply(ln, function(l) length(grep("zorblat", l, ignore.case = TRUE)), integer(1))
cat(sprintf("  %-48s A1 %d  A2 %d  A3 %d  A4 %d\n", 'CONTROL POSITIVO patron "capa"', cp[1], cp[2], cp[3], cp[4]))
cat(sprintf("  %-48s A1 %d  A2 %d  A3 %d  A4 %d\n", 'CONTROL NEGATIVO patron "zorblat"', cn[1], cn[2], cn[3], cn[4]))
cat("\nfin.\n")
