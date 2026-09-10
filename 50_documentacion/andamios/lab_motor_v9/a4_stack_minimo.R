# =============================================================================
# a4_stack_minimo.R - aritmetica del stack minimo (A4, encargo v9)
# -----------------------------------------------------------------------------
# Cruza el corpus MEDIDO (40_salidas/datos/) con los limites gratuitos VERIFICADOS
# en developers.cloudflare.com el 2026-09-05 (URL en el documento). No llama a
# ninguna API. Regla de tokens: SUPUESTO 1 token ~ 4 caracteres.
# Acceso a estructuras leidas de disco: siempre [[ ]], nunca $.
# =============================================================================
suppressPackageStartupMessages({library(jsonlite); library(dplyr); library(purrr); library(fs); library(here)})
options(width = 120)  # CIF-A4-03: ancho fijo, para que el bloque pegado en el .md sea reproducible
cat("R:", R.version.string, " fecha:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n\n")
archivos <- dir_ls(here::here("40_salidas/datos/normas"), glob = "*.json")
seg <- map_dfr(archivos, \(f) { n <- fromJSON(f, simplifyVector = FALSE)
  tibble(slug = n[["slug"]], origen_texto = n[["origen_texto"]],
         es_articulo = map_lgl(n[["articulos"]], \(a) isTRUE(a[["es_articulo"]])),
         n_char = map_int(n[["articulos"]], \(a) nchar(a[["texto"]], type = "chars"))) })
# CON-A4-04: la unidad del contexto es el SEGMENTO firmado, no el articulo. Firmado =
# origen_texto en {capa_texto_pdf, ocr_revisado}. `es_articulo` describe la forma del
# segmento (si trae numero de articulo), no si su texto esta verificado.
ORIGENES_FIRMADOS <- c("capa_texto_pdf", "ocr_revisado")
firmada <- seg[["origen_texto"]] %in% ORIGENES_FIRMADOS
n_firm <- sum(firmada)
n_normas <- length(archivos); n_art <- sum(seg[["es_articulo"]]); n_seg <- nrow(seg)
# CON-A4-07: UNA unidad para todo lo que se indexa. La que A2 decide indexar son los
# fragmentos firmados de a2_fragmentacion.csv; se lee del artefacto, no se transcribe.
ruta_frag <- here::here("50_documentacion/andamios/lab_motor_v9/a2_fragmentacion.csv")
frag <- read.csv(ruta_frag, stringsAsFactors = FALSE)
N_CAN <- frag[["frag_c4"]][frag[["nota"]] %in% "total firmadas"]
n_unid_frag <- frag[["unidades"]][frag[["nota"]] %in% "total firmadas"]
stopifnot(length(N_CAN) == 1, length(n_unid_frag) == 1)
META_B <- 57.8  # bytes de metadatos minimos por unidad; convencion de A2 (a2 §3).
                # Cota inferior medida por A4: la ancla "slug#id" pesa 38,4 B UTF-8 de
                # media sobre las 722 unidades firmadas, asi que 57,8 es conservador.
chars_total <- sum(seg[["n_char"]]); chars_art <- sum(seg[["n_char"]][seg[["es_articulo"]]])
rel <- fromJSON(here::here("40_salidas/datos/relaciones.json"), simplifyVector = FALSE)
n_rel <- length(rel[["relaciones"]])
CPT <- 4; tok <- \(c) ceiling(c / CPT)
cat(sprintf("corpus medido: %d normas | %d articulos | %d segmentos | %d relaciones | %d caracteres (todo) | %d caracteres (articulos)\n",
            n_normas, n_art, n_seg, n_rel, chars_total, chars_art))
cat(sprintf("unidad del contexto (CON-A4-04): %d segmentos FIRMADOS (origen_texto en {%s}) | %d descartados por OCR sin revisar | firmados perdidos por el filtro: %d\n",
            n_firm, paste(ORIGENES_FIRMADOS, collapse = ", "), n_seg - n_firm,
            sum(!firmada & seg[["origen_texto"]] == "capa_texto_pdf")))
cat(sprintf("  CONTRASTE con el filtro viejo (es_articulo == TRUE): sobreviven %d, descarta %d, de los cuales %d tienen texto firmado\n",
            n_art, n_seg - n_art, sum(!seg[["es_articulo"]] & firmada)))
cat(sprintf("  CONTROL POSITIVO: segmentos con origen_texto inexistente = %d (esperado 0) | CONTROL NEGATIVO: con origen_texto no vacio = %d (esperado %d)\n\n",
            sum(seg[["origen_texto"]] %in% "zzz_inexistente"), sum(nzchar(seg[["origen_texto"]])), n_seg))

# ---- Vectorize (limites Free verificados: 5M dims almacenadas, 30M dims consultadas/mes)
cat("== Vectorize: dimensiones (Free: 5,000,000 almacenadas; 30,000,000 consultadas/mes) ==\n")
cat(sprintf("unidad indexada, UNA para toda la seccion: %d fragmentos firmados (a2_fragmentacion.csv, frag_c4, fila 'total firmadas')\n", N_CAN))
cat(sprintf("  CONTROL CRUZADO: esa fila declara %d unidades firmadas; mi recuento independiente da %d -> coinciden: %s\n",
            n_unid_frag, n_firm, identical(as.integer(n_unid_frag), as.integer(n_firm))))
for (N in c(N_CAN, n_art)) {
  et <- if (identical(N, N_CAN)) "fragmentos firmados (canonica)" else "articulos (unidad vieja, contraste)"
  for (d in c(384L, 768L, 1024L)) {
    alm <- N * d
    cat(sprintf("N=%5d %-36s dims %4d: almacenadas %9d = %5.1f%% del cupo\n", N, et, d, alm, 100 * alm / 5e6))
  }
}
for (N in c(N_CAN, n_art)) {
  et <- if (identical(N, N_CAN)) "fragmentos firmados" else "articulos"
  cat(sprintf("vectores que agotan el cupo Free de almacenamiento a 1024 dims: %d (= %.0f normas, a %.1f %s por norma)\n",
              5e6 %/% 1024, (5e6 %/% 1024) / (N / n_normas), N / n_normas, et))
}
# CIF-A4-01: porcentaje del cupo de CONSULTA. Dos formulas, las dos impresas:
#  (A) convencion interna, consultas x dims;
#  (B) formula que Cloudflare factura, (consultas + vectores almacenados) x dims:
#      "If you have 10,000 vectors with 384-dimensions ... your total queried vector
#       dimensions would sum to 3.878 million ( (10000 + 100) * 384 )"
#      (developers.cloudflare.com/vectorize/platform/pricing/, leida el 2026-09-06).
cat("\ncupo de CONSULTA de Vectorize Free (30,000,000 dims/mes), 1024 dims, indice de", N_CAN, "vectores (unidad canonica):\n")
for (m in c(100L, 1000L, 5000L)) {
  a <- m * 1024; b <- (m + N_CAN) * 1024
  cat(sprintf("%5d consultas/mes -> (A) consultas x dims = %8d = %5.2f%% | (B) (consultas + almacenados) x dims = %8d = %5.2f%%\n",
              m, a, 100 * a / 3e7, b, 100 * b / 3e7))
}
cat(sprintf("  CONTROL POSITIVO de la formula (B) con el ejemplo de la pagina: (10000 + 100) * 384 = %d dims (la pagina dice 3.878 millones)\n\n",
            (10000 + 100) * 384))

# ---- indice estatico en el navegador (bytes = vectores x dims x bytes/dim + metadatos)
# El bloque suelto que imprimia el peso SIN metadatos sobre los 682 articulos se retiro:
# publicaba un segundo peso del mismo objeto, que es justo lo que CON-A4-07 senala.
# CON-A4-07: el paquete publicaba tres pesos para el mismo objeto (con y sin
# metadatos, sobre tres universos y en dos convenciones de KB). Aqui se fija UNA
# formula (bytes de vector + metadatos por unidad) y UNA unidad (N_CAN, arriba), y se
# imprimen los universos vecinos para que la sintesis pueda cruzarlos sin recalcular.
cat("== Peso del indice de embeddings: UNA formula (vector + metadatos) y UNA unidad ==\n")
cat(sprintf("formula: bytes = N x dims x bytes_por_dim + N x %.1f B de metadatos | unidad canonica N = %d\n", META_B, N_CAN))
for (N in c(N_CAN, n_firm, n_art, n_seg)) {
  et <- c("fragmentos firmados (canonica)", "segmentos firmados", "articulos", "segmentos totales")[match(N, c(N_CAN, n_firm, n_art, n_seg))]
  for (d in c(384L, 1024L)) {
    i8 <- N * d * 1 + N * META_B; f32 <- N * d * 4 + N * META_B
    cat(sprintf("  N=%5d %-32s dims %4d: int8 %9.0f B (%7.1f KiB) | float32 %9.0f B (%7.1f KiB)\n",
                N, et, d, i8, i8 / 1024, f32, f32 / 1024))
  }
}
cat(sprintf("  CONTROL: sin metadatos, la unidad canonica a 1024 dims int8 pesa %d B; la diferencia con la formula fijada es %.0f B\n\n",
            N_CAN * 1024, N_CAN * META_B))
umbral <- 5 * 1024^2
# CIF-A4-05: los umbrales se imprimen con su derivacion, para que el documento no
# escriba un "~150 normas" que ningun calculo produce.
# CON-A4-07 (segunda pasada): los dos umbrales de 5 MiB se calculaban con
# `umbral %/% 1024` y `umbral %/% (1024*4)`, es decir SIN los metadatos que la
# formula fijada arriba incluye. Aqui se usa la misma formula del bloque anterior.
b_i8 <- 1024 * 1 + META_B   # bytes por vector int8   de 1024 dims, con metadatos
b_f32 <- 1024 * 4 + META_B  # bytes por vector float32 de 1024 dims, con metadatos
cat("umbrales, con la unidad canonica (fragmentos firmados) y con la vieja (articulos):\n")
for (N in c(N_CAN, n_art)) {
  et <- if (identical(N, N_CAN)) "fragmentos" else "articulos"
  por_norma <- N / n_normas
  cat(sprintf("  %-11s por norma %5.1f -> agota Vectorize Free (almacenamiento, 1024 dims) con %d vectores = %5.0f normas | indice int8 de 1024 dims supera 5 MiB con %d = %5.0f normas | float32 con %d = %5.0f normas\n",
              et, por_norma, 5e6 %/% 1024, (5e6 %/% 1024) / por_norma,
              umbral %/% b_i8, (umbral %/% b_i8) / por_norma,
              umbral %/% b_f32, (umbral %/% b_f32) / por_norma))
}
cat(sprintf("  CONTROL (formula SIN metadatos, que es como se publicaron antes): int8 %d vectores = %.0f normas | float32 %d = %.0f normas\n",
            umbral %/% 1024, (umbral %/% 1024) / (N_CAN / n_normas),
            umbral %/% (1024 * 4), (umbral %/% (1024 * 4)) / (N_CAN / n_normas)))
cat("\n")

# ---- Workers AI (Free: 10,000 neuronas/dia; bge-m3 1075 neuronas/M tokens; bge-reranker-base 283 neuronas/M tokens)
cat("== Workers AI (neuronas; cupo Free 10,000/dia) ==\n")
tok_corpus <- tok(chars_total)
cat(sprintf("embeber todo el corpus una vez con bge-m3: %d tokens -> %.1f neuronas (%.2f%% del cupo diario)\n",
            tok_corpus, tok_corpus / 1e6 * 1075, tok_corpus / 1e6 * 1075 / 1e4 * 100))
tok_consulta <- 80L
cat(sprintf("embeber una consulta (80 tokens): %.4f neuronas -> 5000/mes = %.1f neuronas/mes\n", tok_consulta / 1e6 * 1075, 5000 * tok_consulta / 1e6 * 1075))
media_art <- mean(seg[["n_char"]][seg[["es_articulo"]]])
tok_rerank <- 20L * (tok(media_art) + tok_consulta)
neur_rerank_dia <- 5000 * tok_rerank / 1e6 * 283 / 30
neur_emb_dia    <- 5000 * tok_consulta / 1e6 * 1075 / 30
cat(sprintf("reordenar 20 candidatos de %.0f car. medios (+ consulta): %d tokens -> %.2f neuronas/consulta -> 5000/mes = %.0f neuronas/mes = %.0f/dia\n",
            media_art, tok_rerank, tok_rerank / 1e6 * 283, 5000 * tok_rerank / 1e6 * 283, neur_rerank_dia))
# CIF-A4-07: el 4,5% del cupo era SOLO el reranking. El consumo diario del escenario
# alto es reranking + embedding de la consulta, y las dos partidas se imprimen.
cat(sprintf("escenario alto (5000 consultas/mes), consumo diario de neuronas: reranking %.1f (%.2f%% del cupo) + embedding de la consulta %.2f (%.2f%%) = %.1f (%.2f%%)\n\n",
            neur_rerank_dia, 100 * neur_rerank_dia / 1e4, neur_emb_dia, 100 * neur_emb_dia / 1e4,
            neur_rerank_dia + neur_emb_dia, 100 * (neur_rerank_dia + neur_emb_dia) / 1e4))

# ---- Workers Free: solicitudes/dia frente a los escenarios
cat("== Workers Free: 100,000 solicitudes/dia ==\n")
for (m in c(100L, 1000L, 5000L)) cat(sprintf("%5d consultas/mes -> %.1f/dia (x3 solicitudes por consulta: %.1f/dia = %.4f%% del cupo)\n",
                                             m, m / 30, 3 * m / 30, 3 * m / 30 / 1e5 * 100))
cat("\n== KV Free (1,000 escrituras/dia) y DO Free (100,000 filas escritas/dia) frente al contador de cuota ==\n")
for (m in c(100L, 1000L, 5000L)) cat(sprintf("%5d consultas/mes -> %.1f escrituras/dia: KV %.1f%% | DO %.3f%%\n", m, m / 30, m / 30 / 1000 * 100, m / 30 / 1e5 * 100))

# ---- D1 / relaciones: peso estatico
gz <- \(p) length(memCompress(readBin(p, "raw", file_size(p)), type = "gzip"))
cat("\n== Peso estatico de lo que D1 guardaria ==\n")
for (f in c("catalogo.json", "relaciones.json")) { p <- here::here("40_salidas/datos", f)
  cat(sprintf("%-16s %8d bytes | gzip %6d | por norma gzip %.0f\n", f, as.integer(file_size(p)), gz(p), gz(p) / n_normas)) }
tot <- sum(map_dbl(archivos, \(f) as.numeric(file_size(f)))); totgz <- sum(map_int(archivos, gz))
cat(sprintf("%-16s %8d bytes | gzip %6d | por norma gzip %.0f\n", "normas/*.json", as.integer(tot), totgz, totgz / n_normas))
cat(sprintf("extrapolacion LINEAL (hipotesis) a 100 normas: normas gzip ~ %.0f KB, relaciones gzip ~ %.0f KB\n", 4 * totgz / 1024, 4 * gz(here::here("40_salidas/datos/relaciones.json")) / 1024))

# ---- UNI-A4-02: el universal de §8.4, con el recorrido exhaustivo que lo sostiene
cat("\n== Universal: ningun artefacto estatico no-PDF supera 3 MB (recorrido exhaustivo de 40_salidas) ==\n")
inv <- dir_info(here::here("40_salidas"), recurse = TRUE, type = "file")
es_pdf <- grepl("[.]pdf$", inv[["path"]], ignore.case = TRUE)
no_pdf <- inv[!es_pdf, ]
cat(sprintf("archivos recorridos: %d (no-PDF %d | PDF %d)\n", nrow(inv), nrow(no_pdf), sum(es_pdf)))
cat(sprintf("no-PDF que superan 3 MB (3e6 bytes): %d\n", sum(as.numeric(no_pdf[["size"]]) > 3e6)))
mayor <- no_pdf[which.max(as.numeric(no_pdf[["size"]])), ]
cat(sprintf("el mayor no-PDF: %s con %.3f MB (%.3f MiB)\n",
            sub(".*/40_salidas/", "40_salidas/", mayor[["path"]]),
            as.numeric(mayor[["size"]]) / 1e6, as.numeric(mayor[["size"]]) / 1024^2))
cat(sprintf("CONTROL POSITIVO (el instrumento SI ve archivos grandes): PDF que superan 3 MB = %d\n", sum(as.numeric(inv[["size"]][es_pdf]) > 3e6)))
cat(sprintf("CONTROL NEGATIVO (umbral imposible): archivos que superan 3 TB = %d (esperado 0)\n", sum(as.numeric(inv[["size"]]) > 3e12)))

