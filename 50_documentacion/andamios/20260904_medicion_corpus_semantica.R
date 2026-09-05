# =============================================================================
# 20260904_medicion_corpus_semantica.R
# Encargo v9 (alcance del motor de busqueda), agente A2: capa 2, busqueda
# semantica. Reproduce las mediciones de las tareas 1 (dimensionamiento), 3
# (peso del indice de embeddings), 4ter (temporalidad), 4quater (OCR sin
# revisar), 5 (conjunto de evaluacion, verificacion de anclas) y 6 (linea base
# del Pagefind existente).
#
# Ejecutar desde la raiz del repo:
#   Rscript 50_documentacion/andamios/20260904_medicion_corpus_semantica.R
#
# Contrato de escritura: este script SOLO escribe en
# 50_documentacion/andamios/lab_motor_v9/ con prefijo "a2_". Lee 40_salidas/ y
# 20_insumos/ y no los toca; al final verifica que el arbol de 40_salidas/ no
# cambio (recuento de archivos y mtime maximo antes y despues).
#
# La tarea 6 consulta el indice Pagefind existente en 40_salidas/sitio/pagefind/
# en modo lectura. pagefind.js carga el indice con fetch(), que en Node no acepta
# rutas de archivo, asi que el sitio se sirve por HTTP en 127.0.0.1 con servr en
# un proceso aparte (puerto 8767, distinto del 8766 de la receta del orquestador
# para no matar un servidor ajeno), y se mata por PID al terminar. No se
# reindexa nada.
#
# Reglas del encargo que este script respeta: R exclusivamente (nada de Python),
# `[[ ]]` sobre todo lo leido de disco, `here::here()` en toda ruta, ninguna
# cifra sin recuento, ningun cero sin control positivo, ninguna llamada a una API
# de modelos (los pesos se calculan con aritmetica explicita).
# =============================================================================

# ---- 0. Paquetes y configuracion --------------------------------------------
paquetes <- c("jsonlite", "dplyr", "purrr", "tibble", "tidyr", "readr",
              "stringr", "stringi", "here", "fs", "servr")
faltan <- paquetes[!vapply(paquetes, requireNamespace, TRUE, quietly = TRUE)]
if (length(faltan) > 0L) {
  stop("Faltan paquetes (no hay red hacia CRAN en este encargo): ",
       paste(faltan, collapse = ", "))
}
library(dplyr, warn.conflicts = FALSE)

# 10_configuracion.R solo define constantes y rutas (verificado con grep antes de
# usarlo: sin dir_create ni write). Aporta ORIGENES_TEXTO, ruta_*() y la guarda
# de locale UTF-8 (asegurar_locale_utf8, que falla ruidosamente si no hay UTF-8).
source(here::here("10_utils", "10_configuracion.R"))
stopifnot(exists("ORIGENES_TEXTO"), exists("ruta_sitio"), exists("ruta_normas"))

LAB <- here::here("50_documentacion", "andamios", "lab_motor_v9")
fs::dir_create(LAB)
HOY <- as.Date("2026-09-05")

escribir <- function(df, nombre) {
  ruta <- fs::path(LAB, paste0("a2_", nombre, ".csv"))
  readr::write_csv(df, ruta, na = "")
  cat(sprintf("  -> %s (%d filas, %d bytes)\n", fs::path_file(ruta), nrow(df),
              as.integer(fs::file_size(ruta))))
  invisible(ruta)
}
linea <- function(...) cat(paste0(..., collapse = ""), "\n", sep = "")
seccion <- function(t) cat("\n==== ", t, " ====\n", sep = "")

# Foto de 40_salidas/ antes de empezar (invariante: no se toca).
foto_salidas <- function() {
  i <- fs::dir_info(ruta_salidas(), recurse = TRUE, type = "file")
  list(n = nrow(i), mtime_max = max(i[["modification_time"]]))
}
foto_antes <- foto_salidas()

# ---- 1. Dimensionar el corpus como unidad de recuperacion -------------------
seccion("TAREA 1: dimensionamiento del corpus")

archivos_normas <- fs::dir_ls(ruta_normas(), glob = "*.json")
linea("archivos JSON de normas en 40_salidas/datos/normas/: ", length(archivos_normas))

catalogo <- jsonlite::fromJSON(ruta_datos("catalogo.json"), simplifyVector = FALSE)
linea("catalogo.json: n_normas=", catalogo[["n_normas"]],
      " n_articulos=", catalogo[["n_articulos"]],
      " (largo de la lista normas=", length(catalogo[["normas"]]), ")")

leer_norma <- function(f) {
  j <- jsonlite::fromJSON(f, simplifyVector = FALSE)
  purrr::map_dfr(j[["articulos"]], function(a) tibble::tibble(
    slug         = j[["slug"]],
    tipo         = j[["tipo"]],
    anio         = if (is.null(j[["anio"]])) NA_integer_ else as.integer(j[["anio"]]),
    estado       = j[["vigencia"]][["estado"]],
    origen_texto = j[["origen_texto"]],
    id           = a[["id"]],
    etiqueta     = a[["etiqueta"]],
    es_articulo  = isTRUE(a[["es_articulo"]]),
    texto        = a[["texto"]]
  ))
}
unidades <- purrr::map_dfr(archivos_normas, leer_norma)

# Regla de estimacion de tokens, DECLARADA (no medida contra ningun tokenizador:
# no hay API disponible ni cuota autorizada). Regla primaria: 1 token por cada 4
# caracteres (heuristica habitual para tokenizadores BPE, calibrada en ingles).
# En espanol la razon suele ser menor (mas tokens por caracter), por eso se
# reporta tambien la cota conservadora de 1 token por cada 3,5 caracteres.
unidades <- unidades |>
  mutate(n_car   = nchar(texto),
         n_pal   = stringr::str_count(texto, "\\S+"),
         tok_c4  = ceiling(n_car / 4),
         tok_c35 = ceiling(n_car / 3.5))

n_normas    <- n_distinct(unidades[["slug"]])
n_unidades  <- nrow(unidades)
n_articulos <- sum(unidades[["es_articulo"]])
linea("normas leidas: ", n_normas, " | unidades de recuperacion (segmentos): ", n_unidades,
      " | articulos (es_articulo=TRUE): ", n_articulos)
linea("control: n_articulos del catalogo (", catalogo[["n_articulos"]], ") ",
      if (identical(as.integer(catalogo[["n_articulos"]]), as.integer(n_articulos))) "COINCIDE" else "NO COINCIDE",
      " con el recuento propio (", n_articulos, ")")
print(count(unidades, origen_texto, es_articulo))

resumen_dist <- function(df, etiqueta) {
  q <- function(x) stats::quantile(x, c(0, .1, .25, .5, .75, .9, .95, .99, 1), names = FALSE)
  tibble::tibble(
    subconjunto = etiqueta, n = nrow(df),
    estadistico = c("min", "p10", "p25", "mediana", "p75", "p90", "p95", "p99", "max"),
    n_car   = q(df[["n_car"]]),
    n_pal   = q(df[["n_pal"]]),
    tok_c4  = q(df[["tok_c4"]]),
    tok_c35 = q(df[["tok_c35"]])
  )
}
distribucion <- bind_rows(
  resumen_dist(filter(unidades, es_articulo), "articulos"),
  resumen_dist(unidades, "todas_las_unidades"),
  resumen_dist(filter(unidades, !es_articulo, origen_texto == "capa_texto_pdf"), "segmentos_no_articulo_firmados"),
  resumen_dist(filter(unidades, origen_texto == "ocr_pendiente_revision"), "paginas_ocr")
)
print(as.data.frame(distribucion |> filter(subconjunto == "articulos") |> select(-subconjunto, -n)))
escribir(unidades |> select(-texto), "distribucion_articulos")
escribir(distribucion, "resumen_distribucion")

# Cuantas unidades exceden una ventana de fragmento. Ventanas declaradas: 256,
# 512 (referencia: largo maximo de secuencia de la clase de modelos de embedding
# pequenos/base; hipotesis de clase, no medida aqui), 1024, 2048 y 8192.
ventanas <- c(256L, 512L, 1024L, 2048L, 8192L)
excesos <- purrr::map_dfr(ventanas, function(w) {
  art <- filter(unidades, es_articulo)
  tibble::tibble(
    ventana_tokens = w,
    articulos_sobre_ventana_c4   = sum(art[["tok_c4"]]  > w),
    articulos_sobre_ventana_c35  = sum(art[["tok_c35"]] > w),
    pct_articulos_c4             = round(100 * mean(art[["tok_c4"]] > w), 1),
    unidades_sobre_ventana_c4    = sum(unidades[["tok_c4"]]  > w),
    unidades_sobre_ventana_c35   = sum(unidades[["tok_c35"]] > w)
  )
})
print(as.data.frame(excesos))
escribir(excesos, "excesos_ventana")

# Estructura interna: parrafos (incisos) por articulo, para decidir la unidad.
parrafos <- unidades |>
  filter(es_articulo) |>
  mutate(parrafos = stringr::str_split(texto, "\n\\s*\n")) |>
  select(slug, id, parrafos) |>
  tidyr::unnest_longer(parrafos, values_to = "parrafo") |>
  mutate(n_car = nchar(parrafo), tok_c4 = ceiling(n_car / 4))
np_por_art <- parrafos |> count(slug, id, name = "n_parrafos")
linea("parrafos (split por linea en blanco) en los ", n_articulos, " articulos: ", nrow(parrafos),
      " | articulos con >1 parrafo: ", sum(np_por_art[["n_parrafos"]] > 1),
      " | max parrafos en un articulo: ", max(np_por_art[["n_parrafos"]]))
linea("parrafos con tok_c4 > 512: ", sum(parrafos[["tok_c4"]] > 512),
      " | parrafo mas largo (caracteres): ", max(parrafos[["n_car"]]),
      " | mediana (caracteres): ", stats::median(parrafos[["n_car"]]))

# Fragmentacion por ventana deslizante: objetivo 400 tokens, solapamiento 50
# (paso 350), solo para unidades que exceden 512 tokens. Aritmetica declarada:
# n_frag = 1 si tok <= 512; si no, ceiling((tok - 50) / 350).
n_frag <- function(tok) ifelse(tok <= 512, 1L, as.integer(ceiling((tok - 50) / 350)))
fragmentacion <- unidades |>
  mutate(firmada = origen_texto %in% c("capa_texto_pdf", "ocr_revisado"),
         frag_c4 = n_frag(tok_c4), frag_c35 = n_frag(tok_c35)) |>
  summarise(unidades = n(), frag_c4 = sum(frag_c4), frag_c35 = sum(frag_c35),
            .by = c(es_articulo, firmada)) |>
  arrange(desc(es_articulo), desc(firmada))
total_de <- function(df, nota) {
  df |> summarise(unidades = sum(unidades), frag_c4 = sum(frag_c4), frag_c35 = sum(frag_c35)) |>
    mutate(es_articulo = NA, firmada = NA, nota = nota)
}
fragmentacion <- bind_rows(
  fragmentacion,
  total_de(filter(fragmentacion, firmada), "total firmadas"),
  total_de(fragmentacion, "total")
)
print(as.data.frame(fragmentacion))
escribir(fragmentacion, "fragmentacion")

N_ART          <- n_articulos
N_UNI          <- n_unidades
N_UNI_FIRMADAS <- sum(unidades[["origen_texto"]] %in% c("capa_texto_pdf", "ocr_revisado"))
N_FRAG_FIRM    <- fragmentacion |> filter(nota %in% "total firmadas") |> pull(frag_c4)
N_FRAG_TODAS   <- fragmentacion |> filter(nota %in% "total") |> pull(frag_c4)

# ---- 3. Peso del indice de embeddings ---------------------------------------
seccion("TAREA 3: peso del indice de embeddings (calculado)")

# Sobrecarga de metadatos por vector: se mide como el largo del JSON con
# slug+id de cada unidad (lo minimo que hace rastreable un vector a un ancla).
meta_json <- jsonlite::toJSON(unidades |> select(slug, id), dataframe = "rows")
bytes_meta_unidad <- nchar(meta_json, type = "bytes") / n_unidades
linea("metadatos (slug,id) por unidad, medidos sobre el JSON: ", round(bytes_meta_unidad, 1), " bytes")

configs_n <- tibble::tibble(
  conjunto = c("articulos", "unidades_firmadas", "todas_las_unidades",
               "fragmentos_firmados_ventana", "fragmentos_todos_ventana"),
  N = c(N_ART, N_UNI_FIRMADAS, N_UNI, N_FRAG_FIRM, N_FRAG_TODAS)
)
formatos <- tibble::tibble(formato = c("float32", "int8", "binario"), bytes_por_dim = c(4, 1, 1 / 8))
dims <- c(384L, 768L, 1024L)
peso <- tidyr::expand_grid(configs_n, dim = dims, formatos) |>
  mutate(bytes_vectores = N * dim * bytes_por_dim,
         bytes_meta     = N * bytes_meta_unidad,
         bytes_total    = bytes_vectores + bytes_meta,
         kb_total       = round(bytes_total / 1024, 1),
         mb_total       = round(bytes_total / 1024^2, 3),
         seg_a_3mbps    = round(bytes_total * 8 / 3e6, 2),
         seg_a_10mbps   = round(bytes_total * 8 / 1e7, 2))
print(as.data.frame(peso |> filter(conjunto %in% c("articulos", "todas_las_unidades")) |>
                      select(conjunto, N, dim, formato, kb_total, seg_a_3mbps)))
escribir(peso, "peso_indice")

# Referencias medidas en el sitio generado (lo que hoy descarga un visitante).
info_pf <- fs::dir_info(ruta_sitio("pagefind"), recurse = TRUE, type = "file")
tam <- function(glob) sum(info_pf[["size"]][grepl(glob, info_pf[["path"]])])
html <- fs::dir_info(ruta_sitio(), glob = "*.html", type = "file")
gz_bytes <- function(ruta) length(memCompress(readBin(ruta, "raw", fs::file_size(ruta)), "gzip"))
referencias <- tibble::tibble(
  referencia = c("pagefind/ completo", "pagefind/index/", "pagefind/fragment/", "pagefind/filter/",
                 "wasm.es.pagefind", "pagefind.js", "pagefind-ui.js", "HTML del sitio (todos)",
                 "HTML mas pesado", "wasm.es.pagefind (gzip)", "pagefind/index/ (gzip)", "pagefind/fragment/ (gzip)"),
  bytes = c(sum(info_pf[["size"]]), tam("/index/"), tam("/fragment/"), tam("/filter/"),
            fs::file_size(ruta_sitio("pagefind", "wasm.es.pagefind")),
            fs::file_size(ruta_sitio("pagefind", "pagefind.js")),
            fs::file_size(ruta_sitio("pagefind", "pagefind-ui.js")),
            sum(html[["size"]]), max(html[["size"]]),
            gz_bytes(ruta_sitio("pagefind", "wasm.es.pagefind")),
            sum(vapply(info_pf[["path"]][grepl("/index/", info_pf[["path"]])], gz_bytes, 1)),
            sum(vapply(info_pf[["path"]][grepl("/fragment/", info_pf[["path"]])], gz_bytes, 1)))
) |> mutate(bytes = as.numeric(bytes), kb = round(bytes / 1024, 1))
referencias[["detalle"]] <- c(rep("", 8), fs::path_file(html[["path"]][which.max(html[["size"]])]), rep("", 3))
linea("archivos en pagefind/: ", nrow(info_pf), " | paginas HTML: ", nrow(html))
print(as.data.frame(referencias))
escribir(referencias, "referencias_peso_sitio")

# Compresibilidad (proxy sintetico, declarado): vectores aleatorios normalizados
# en float32 y en int8 comprimidos con gzip. No son embeddings reales; sirven
# para no suponer que gzip "arregla" el peso de un indice float32.
set.seed(20260905)
d_proxy <- 384L; n_proxy <- N_UNI
m <- matrix(stats::rnorm(n_proxy * d_proxy), nrow = n_proxy)
m <- m / sqrt(rowSums(m^2))
raw_f32 <- writeBin(as.numeric(t(m)), raw(), size = 4)
raw_i8  <- as.raw(as.integer(round(pmax(-127, pmin(127, m * 127))) + 128))
compres <- tibble::tibble(
  formato = c("float32", "int8"),
  bytes = c(length(raw_f32), length(raw_i8)),
  bytes_gzip = c(length(memCompress(raw_f32, "gzip")), length(memCompress(raw_i8, "gzip")))
) |> mutate(razon_gzip = round(bytes_gzip / bytes, 3))
print(as.data.frame(compres))
escribir(compres, "compresibilidad_proxy")

# ---- 4ter. Dimension temporal -----------------------------------------------
seccion("TAREA 4ter: temporalidad y vigencia en los datos reales")

normas_cat <- purrr::map_dfr(catalogo[["normas"]], function(n) {
  v <- n[["vigencia"]]
  tibble::tibble(
    slug = n[["slug"]], tipo = n[["tipo"]],
    anio = if (is.null(n[["anio"]])) NA_integer_ else as.integer(n[["anio"]]),
    fuente_anio = if (is.null(n[["fuente_anio"]])) NA_character_ else n[["fuente_anio"]],
    n_anios_alternativos = length(n[["anios_alternativos"]]),
    estado = v[["estado"]],
    sustituido_por = if (is.null(v[["sustituido_por"]])) NA_character_ else v[["sustituido_por"]],
    n_sustituye_a = length(v[["sustituye_a"]]),
    campos_vigencia = paste(names(v), collapse = "|"),
    tiene_campo_fecha = any(grepl("fecha", names(v), ignore.case = TRUE)),
    origen_texto = n[["origen_texto"]]
  )
})
anio_de <- function(s) normas_cat[["anio"]][match(s, normas_cat[["slug"]])]
normas_cat <- normas_cat |>
  mutate(
    anio_sustituto = anio_de(sustituido_por),
    rige_hoy = estado == "vigente",
    # "que regia en 2021": publicada hasta 2021 y, si fue sustituida, sustituida despues de 2021.
    regia_en_2021 = case_when(
      is.na(anio) ~ NA,
      anio > 2021 ~ FALSE,
      estado == "vigente" ~ TRUE,
      !is.na(anio_sustituto) & anio_sustituto > 2021 ~ TRUE,
      TRUE ~ FALSE),
    filtrable_por_anio = !is.na(anio)
  )
linea("normas con anio no nulo: ", sum(!is.na(normas_cat[["anio"]])), " de ", nrow(normas_cat),
      " | sin anio: ", sum(is.na(normas_cat[["anio"]])), " (",
      paste(normas_cat[["slug"]][is.na(normas_cat[["anio"]])], collapse = ", "), ")")
linea("normas con fuente_anio curada: ", sum(!is.na(normas_cat[["fuente_anio"]])))
linea("normas con estado distinto de vigente: ", sum(normas_cat[["estado"]] != "vigente"), " (",
      paste(normas_cat[["slug"]][normas_cat[["estado"]] != "vigente"], collapse = ", "), ")")
linea("normas con sustituido_por: ", sum(!is.na(normas_cat[["sustituido_por"]])),
      " | con sustituye_a no vacio: ", sum(normas_cat[["n_sustituye_a"]] > 0))
linea("normas con algun campo 'fecha' en vigencia: ", sum(normas_cat[["tiene_campo_fecha"]]),
      " (control positivo: normas con campo 'estado' en vigencia: ",
      sum(grepl("estado", normas_cat[["campos_vigencia"]])), ")")
linea("rige hoy (", format(HOY), "): ", sum(normas_cat[["rige_hoy"]]),
      " | regia en 2021: ", sum(normas_cat[["regia_en_2021"]], na.rm = TRUE),
      " | indeterminable para 2021 (sin anio): ", sum(is.na(normas_cat[["regia_en_2021"]])))
escribir(normas_cat, "temporalidad")

# ---- 4quater. OCR sin revisar como unidad de recuperacion -------------------
seccion("TAREA 4quater: unidades provenientes de texto sin firma")

linea("ORIGENES_TEXTO (10_utils/10_configuracion.R): ", paste(ORIGENES_TEXTO, collapse = ", "))
firmados <- intersect(ORIGENES_TEXTO, c("capa_texto_pdf", "ocr_revisado"))
linea("valores considerados firmados: ", paste(firmados, collapse = ", "))
valores_corpus <- unique(unidades[["origen_texto"]])
linea("valores de origen_texto presentes en el corpus: ", paste(valores_corpus, collapse = ", "),
      " | todos en ORIGENES_TEXTO: ", all(valores_corpus %in% ORIGENES_TEXTO))
ocr <- unidades |>
  mutate(firmada = origen_texto %in% firmados) |>
  summarise(unidades = n(), caracteres = sum(n_car), tok_c4 = sum(tok_c4), .by = c(slug, origen_texto, firmada)) |>
  arrange(firmada, slug)
no_firmadas <- ocr |> filter(!firmada)
linea("unidades NO firmadas: ", sum(no_firmadas[["unidades"]]), " en ", nrow(no_firmadas), " documentos",
      " | unidades firmadas (control positivo): ", sum(ocr[["unidades"]][ocr[["firmada"]]]),
      " en ", sum(ocr[["firmada"]]), " documentos")
print(as.data.frame(no_firmadas))
escribir(ocr, "ocr_unidades")

# ---- 5. Conjunto de evaluacion ----------------------------------------------
seccion("TAREA 5: conjunto de evaluacion (10 consultas en lenguaje del equipo)")

# ancla_esperada: pagina#ancla de la unidad que contiene la respuesta.
# anclas_aceptadas: la esperada mas alternativas defendibles (separadas por ";").
# patron_cita: expresion que DEBE encontrarse en el texto de la unidad esperada;
# ata la justificacion al JSON de la norma y no a la memoria.
consultas <- tibble::tribble(
  ~id,   ~consulta, ~ancla_esperada, ~anclas_aceptadas, ~patron_cita, ~por_que,
  "C01", "pueden revisar la mochila de un alumno",
         "dictamen_065_revision_mochilas.html#fuentes",
         "dictamen_065_revision_mochilas.html#fuentes;dictamen_065_revision_mochilas.html#materia",
         "intromisión no autorizada en pertenencias particulares",
         "Unica doctrina firmada sobre revision de mochilas. El segmentador dejo el cuerpo del dictamen bajo el rotulo FUENTES. La norma esta sustituida por el dictamen 078, cuyo texto es OCR sin revisar.",
  "C02", "se puede usar el celular en la sala de clases",
         "ley_21801_celulares.html#art-10-bis",
         "ley_21801_celulares.html#art-10-bis;rex_181_celulares.html#documento",
         "Prohíbese el uso de dispositivos móviles electrónicos",
         "Es la regla de prohibicion con sus excepciones. La ley dice 'dispositivos moviles', nunca 'celular'.",
  "C03", "es obligatorio tener un encargado de convivencia en el colegio",
         "ley_20536_violencia_escolar.html#art-unico",
         "ley_20536_violencia_escolar.html#art-unico;ley_21809_convivencia_educativa.html#art-15;ley_21809_convivencia_educativa.html#art-4-3",
         "deberán contar con un encargado de convivencia escolar",
         "Frase literal que crea la obligacion (LGE art. 15 inc. 3). La ley 21.809 (2026) lo renombra 'coordinador de convivencia educativa' (art. 15) y homologa a los encargados (art. cuarto transitorio).",
  "C04", "qué es el bullying",
         "ley_21809_convivencia_educativa.html#art-16-b",
         "ley_21809_convivencia_educativa.html#art-16-b;ley_20536_violencia_escolar.html#art-16-b",
         "Se entenderá por acoso escolar toda acción u omisión",
         "Definicion legal vigente de acoso escolar (redaccion 2026 del art. 16 B de la LGE); la de 2011 sigue en el corpus como articulo de la ley 20.536. 'bullying' solo aparece en la ley 21.430 y en una pagina OCR.",
  "C05", "una alumna embarazada puede seguir yendo al colegio",
         "ley_20370_general_educacion.html#art-11",
         "ley_20370_general_educacion.html#art-11",
         "El embarazo y la maternidad en ningún caso constituirán impedimento",
         "Regla legal directa. La circular 193 la desarrolla, pero es OCR sin revisar y no es citable.",
  "C06", "cuántos días tiene el apoderado para apelar una expulsión",
         "ley_20845_inclusion_escolar.html#art-3",
         "ley_20845_inclusion_escolar.html#art-3;dictamen_52_77_expulsion.html#num-3",
         "reconsideración de la medida dentro de quince días",
         "Plazo legal general (quince dias) en el procedimiento de expulsion que la ley 20.845 inserta en el art. 6 d) de la ley de subvenciones; el dictamen 52-77 explica el plazo de 5 dias del procedimiento Aula Segura. La ley dice 'reconsideracion', el equipo dice 'apelar'.",
  "C07", "quiénes tienen que estar en el consejo escolar",
         "dto_24_consejos_escolares.html#art-3",
         "dto_24_consejos_escolares.html#art-3",
         "El Consejo Escolar es un órgano integrado, a lo menos, por",
         "Integracion minima del Consejo Escolar.",
  "C08", "el colegio puede obligar a los alumnos a usar uniforme",
         "dto_215_uniforme_escolar.html#art-1",
         "dto_215_uniforme_escolar.html#art-1;dto_215_uniforme_escolar.html#art-3",
         "establecer el uso obligatorio del uniforme escolar",
         "Facultad del director, con acuerdo del Centro de Padres y Consejo de Profesores, de establecer uniforme obligatorio.",
  "C09", "un alumno trans pide que lo llamen por su nombre social",
         "circular_812_identidad_genero.html#ocr-pagina-008",
         "circular_812_identidad_genero.html#ocr-pagina-008;circular_812_identidad_genero.html#ocr-pagina-009",
         "USO DEL NOMBRE SOCIAL",
         "La unica unidad que responde es OCR sin revisar: ninguna unidad firmada contiene 'nombre social'. Caso de prueba de la politica de la tarea 4quater.",
  "C10", "se puede suspender al alumno mientras dura el proceso de expulsión",
         "dictamen_52_77_expulsion.html#num-3",
         "dictamen_52_77_expulsion.html#num-3;ley_21809_convivencia_educativa.html#art-16-e",
         "medida cautelar de suspensión de clases",
         "Seccion del dictamen sobre la suspension cautelar y sus plazos (Aula Segura); la ley 21.809 art. 16 E fija un tope de quince dias habiles a la suspension como medida de resguardo."
)

partir_ancla <- function(a) {
  p <- stringr::str_split_fixed(a, "#", 2)
  tibble::tibble(pagina = p[, 1], ancla = p[, 2])
}
cuenta_id_html <- function(pagina, ancla) {
  ruta <- ruta_sitio(pagina)
  if (!fs::file_exists(ruta)) return(NA_integer_)
  lineas <- readLines(ruta, warn = FALSE, encoding = "UTF-8")
  sum(stringr::str_count(lineas, stringr::fixed(sprintf('id="%s"', ancla))))
}
verificacion_anclas <- consultas |>
  select(id, anclas_aceptadas) |>
  mutate(ancla_completa = stringr::str_split(anclas_aceptadas, ";")) |>
  tidyr::unnest_longer(ancla_completa) |>
  select(-anclas_aceptadas) |>
  mutate(partir_ancla(ancla_completa)) |>
  mutate(n_id_en_html = purrr::map2_int(pagina, ancla, cuenta_id_html),
         existe = !is.na(n_id_en_html) & n_id_en_html >= 1L)
linea("anclas aceptadas verificadas contra 40_salidas/sitio/*.html: ", nrow(verificacion_anclas),
      " | existen: ", sum(verificacion_anclas[["existe"]]),
      " | no existen: ", sum(!verificacion_anclas[["existe"]]))
linea("control negativo del verificador: id inexistente 'art-9999' en ley_21801_celulares.html -> ",
      cuenta_id_html("ley_21801_celulares.html", "art-9999"), " coincidencias (debe ser 0)")
print(as.data.frame(verificacion_anclas |> select(id, ancla_completa, n_id_en_html, existe)))

# Cita textual de la unidad esperada, leida del JSON (justifica el ancla).
texto_de <- function(pagina, ancla) {
  s <- stringr::str_remove(pagina, "\\.html$")
  unidades[["texto"]][unidades[["slug"]] == s & unidades[["id"]] == ancla]
}
plegar <- function(x) stringi::stri_trans_general(tolower(x), "Latin-ASCII")
funcionales <- c("que", "los", "las", "del", "por", "con", "una", "uno", "para", "como",
                 "tiene", "tienen", "puede", "pueden", "mientras", "dura", "hay", "son",
                 "ser", "estar", "pide", "llamen", "seguir", "yendo", "usar", "de", "el",
                 "la", "un", "en", "al", "lo", "se", "su", "sus", "y", "o", "a", "es")
consultas <- consultas |>
  mutate(
    primaria = partir_ancla(ancla_esperada),
    unidad_origen_texto = purrr::map2_chr(primaria[["pagina"]], primaria[["ancla"]], function(p, a) {
      s <- stringr::str_remove(p, "\\.html$"); unidades[["origen_texto"]][unidades[["slug"]] == s & unidades[["id"]] == a]
    }),
    unidad_n_car = purrr::map2_int(primaria[["pagina"]], primaria[["ancla"]], function(p, a) nchar(texto_de(p, a))),
    patron_hallado = purrr::pmap_int(list(primaria[["pagina"]], primaria[["ancla"]], patron_cita), function(p, a, rx) {
      stringr::str_count(texto_de(p, a), stringr::fixed(rx))
    }),
    cita_objetivo = purrr::pmap_chr(list(primaria[["pagina"]], primaria[["ancla"]], patron_cita), function(p, a, rx) {
      t <- texto_de(p, a); pos <- stringr::str_locate(t, stringr::fixed(rx))[1, 1]
      if (is.na(pos)) return(NA_character_)
      stringr::str_squish(stringr::str_sub(t, max(1, pos - 60), pos + nchar(rx) + 140))
    }),
    terminos_consulta = purrr::map_chr(consulta, function(q) {
      w <- stringr::str_split(plegar(q), "[^a-z0-9]+")[[1]]
      paste(w[nchar(w) >= 3 & !(w %in% funcionales)], collapse = " ")
    }),
    terminos_en_objetivo = purrr::pmap_chr(list(primaria[["pagina"]], primaria[["ancla"]], terminos_consulta), function(p, a, tt) {
      t <- plegar(texto_de(p, a)); w <- stringr::str_split(tt, " ")[[1]]
      paste(w[stringr::str_detect(t, stringr::fixed(w))], collapse = " ")
    }),
    n_terminos = stringr::str_count(terminos_consulta, "\\S+"),
    n_terminos_en_objetivo = stringr::str_count(terminos_en_objetivo, "\\S+")
  ) |>
  select(-primaria)
# Termino canonico por consulta: la forma en que la NORMA nombra lo que el equipo
# pregunta. Es un mapeo manual de A2 (no se leyo el vocabulario de A1) y sirve
# como COTA SUPERIOR de lo que una expansion lexica desde un vocabulario podria
# entregarle a Pagefind: si aun con el termino canonico el ancla no aparece, el
# problema no es de vocabulario.
canonicos <- c(C01 = "revisión de mochilas", C02 = "dispositivos móviles",
               C03 = "encargado de convivencia", C04 = "acoso escolar",
               C05 = "embarazo", C06 = "reconsideración expulsión",
               C07 = "consejo escolar", C08 = "uniforme escolar",
               C09 = "nombre social", C10 = "suspensión expulsión")
consultas <- consultas |> mutate(termino_canonico = unname(canonicos[id]))
stopifnot(!anyNA(consultas[["termino_canonico"]]))
linea("patron_cita hallado en la unidad esperada: ",
      sum(consultas[["patron_hallado"]] >= 1), " de ", nrow(consultas), " consultas")
print(as.data.frame(consultas |> select(id, unidad_origen_texto, unidad_n_car, patron_hallado,
                                        n_terminos, n_terminos_en_objetivo, terminos_en_objetivo)))
escribir(consultas, "consultas_evaluacion")
escribir(verificacion_anclas, "verificacion_anclas")

# ---- 6. Linea base contra el Pagefind existente (modo lectura) --------------
seccion("TAREA 6: linea base del Pagefind existente")

PUERTO <- 8767L
BASE   <- sprintf("http://127.0.0.1:%d/", PUERTO)
mjs    <- fs::path(LAB, "a2_consulta_pagefind.mjs")
node   <- Sys.which("node")
curl_ok <- function(url) {
  cod <- tryCatch(suppressWarnings(system2("curl", c("-s", "-o", "/dev/null", "-w", "%{http_code}", url),
                          stdout = TRUE, stderr = FALSE)), error = function(e) "")
  identical(cod, "200")
}

if (!nzchar(node)) {
  linea("NO MEDIDA: no hay 'node' en el PATH; la API JavaScript es la unica interfaz del indice.")
} else if (!fs::file_exists(mjs)) {
  linea("NO MEDIDA: falta el arnes ", mjs)
} else if (!fs::file_exists(ruta_sitio("pagefind", "pagefind.js"))) {
  linea("NO MEDIDA: no existe 40_salidas/sitio/pagefind/pagefind.js (indice no generado)")
} else if (curl_ok(paste0(BASE, "index.html"))) {
  linea("NO MEDIDA: el puerto ", PUERTO, " ya responde; no se arranca ni se mata un servidor ajeno.")
} else {
  # Servidor HTTP local en un proceso aparte; se captura su PID para matarlo.
  cmd_r <- sprintf("servr::httd(%s, port = %d, daemon = FALSE, browser = FALSE, verbose = FALSE)",
                   deparse(ruta_sitio()), PUERTO)
  interno <- paste0("Rscript -e ", shQuote(cmd_r), " >/dev/null 2>&1 & echo $!")
  pid <- as.integer(system2("sh", c("-c", shQuote(interno)), stdout = TRUE))
  intentos <- 0L
  while (!curl_ok(paste0(BASE, "index.html")) && intentos < 120L) { Sys.sleep(0.5); intentos <- intentos + 1L }
  linea("servidor local (PID ", pid, ") listo tras ", intentos, " esperas de 0,5 s")

  # Variantes: que texto se envia (la consulta tal cual, sus terminos de
  # contenido, o el termino canonico) y con que filtros de faceta del indice.
  variantes <- list(
    sin_filtro          = list(campo = "consulta",          filtros = NULL),
    texto_verificado    = list(campo = "consulta",          filtros = list(texto = "verificado")),
    vigente_verificado  = list(campo = "consulta",          filtros = list(texto = "verificado", vigencia = "vigente")),
    terminos_clave      = list(campo = "terminos_consulta", filtros = NULL),
    canonico            = list(campo = "termino_canonico",  filtros = NULL),
    canonico_verificado = list(campo = "termino_canonico",  filtros = list(texto = "verificado"))
  )
  entrada <- c(
    list(list(id = "C0", consulta = "mochila"),           # control positivo del instrumento
         list(id = "CNEG", consulta = "xyzzy")),          # control negativo (termino inexistente)
    unlist(lapply(names(variantes), function(v) {
      lapply(seq_len(nrow(consultas)), function(i) {
        x <- list(id = paste0(consultas[["id"]][i], "|", v),
                  consulta = consultas[[variantes[[v]][["campo"]]]][i])
        if (!is.null(variantes[[v]][["filtros"]])) x[["filtros"]] <- variantes[[v]][["filtros"]]
        x
      })
    }), recursive = FALSE)
  )
  ruta_entrada <- fs::path(LAB, "a2_consultas_pagefind_entrada.json")
  ruta_salida  <- fs::path(LAB, "a2_resultados_pagefind.json")
  jsonlite::write_json(entrada, ruta_entrada, auto_unbox = TRUE, pretty = TRUE)
  if (fs::file_exists(ruta_salida)) fs::file_delete(ruta_salida)
  t0 <- Sys.time()
  cod <- system2(node, c("--no-warnings", shQuote(mjs), shQuote(ruta_entrada), shQuote(ruta_salida),
                         shQuote(paste0(BASE, "pagefind/"))), stdout = TRUE, stderr = TRUE)
  linea("node: ", paste(cod, collapse = " | "), " | duracion total: ",
        round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 1), " s | archivo escrito: ",
        fs::file_exists(ruta_salida), " (", if (fs::file_exists(ruta_salida)) fs::file_size(ruta_salida) else 0, " bytes)")

  tools::pskill(pid)
  Sys.sleep(0.5)
  vivos <- suppressWarnings(system2("pgrep", c("-f", shQuote(sprintf("port = %d", PUERTO))), stdout = TRUE))
  linea("servidor detenido: procesos servr en el puerto ", PUERTO, " tras pskill: ", length(vivos))

  if (!fs::file_exists(ruta_salida)) {
    linea("NO MEDIDA: el arnes no escribio resultados.")
  } else {
    res <- jsonlite::fromJSON(ruta_salida, simplifyVector = FALSE)
    filtros_idx <- res[["filtros"]]
    linea("facetas del indice: ", paste(names(filtros_idx), collapse = ", "))
    linea("faceta texto: ", paste(names(filtros_idx[["texto"]]), unlist(filtros_idx[["texto"]]), sep = "=", collapse = ", "),
          " | faceta vigencia: ", paste(names(filtros_idx[["vigencia"]]), unlist(filtros_idx[["vigencia"]]), sep = "=", collapse = ", "),
          " | 'sin año determinado': ", filtros_idx[["anio"]][["sin año determinado"]])

    # Aplanados por consulta: una fila por sub-resultado, con rango de pagina y orden.
    vacio <- tibble::tibble(pagina = character(), rango_pagina = integer(), score_pagina = numeric(),
                            orden_documento = integer(), ancla = character(), suma_balanced = numeric(), n_loc = integer())
    aplanar <- function(q) {
      if (length(q[["resultados"]]) == 0L) return(vacio)
      purrr::map_dfr(q[["resultados"]], function(r) {
        pagina <- fs::path_file(r[["url"]])
        if (length(r[["sub_results"]]) == 0L) {
          return(tibble::tibble(pagina = pagina, rango_pagina = r[["rango_pagina"]], score_pagina = r[["score"]],
                                orden_documento = NA_integer_, ancla = NA_character_, suma_balanced = NA_real_, n_loc = NA_integer_))
        }
        purrr::map_dfr(r[["sub_results"]], function(s) tibble::tibble(
          pagina = pagina, rango_pagina = r[["rango_pagina"]], score_pagina = r[["score"]],
          orden_documento = s[["orden_documento"]],
          ancla = if (is.null(s[["anchor_id"]])) NA_character_ else s[["anchor_id"]],
          suma_balanced = s[["suma_balanced"]], n_loc = s[["n_loc"]]))
      })
    }
    # Lectura B: lo que muestra la UI (pagefind-ui.js): por pagina, en orden de
    # documento, descartando el sub-resultado sin ancla si va primero, maximo 3.
    aplanar_ui <- function(pl) {
      pl |> arrange(rango_pagina, orden_documento) |>
        mutate(sin_ancla_primero = is.na(ancla) & orden_documento == 1L) |>
        filter(!sin_ancla_primero, !is.na(ancla)) |>
        mutate(pos_en_pagina = row_number(), .by = pagina) |>
        filter(pos_en_pagina <= 3L) |>
        arrange(rango_pagina, orden_documento) |>
        mutate(rango = row_number())
    }
    # Lectura C: todos los sub-resultados con ancla ordenados por su puntaje
    # (suma de balanced_score de las coincidencias), desempate por score de pagina.
    aplanar_puntaje <- function(pl) {
      pl |> filter(!is.na(ancla)) |>
        arrange(desc(suma_balanced), desc(score_pagina), orden_documento) |>
        mutate(rango = row_number())
    }
    rango_de <- function(df, aceptadas) {
      hits <- which(paste0(df[["pagina"]], "#", df[["ancla"]]) %in% aceptadas)
      if (length(hits) == 0L) NA_integer_ else as.integer(df[["rango"]][hits[1]])
    }
    consultas_res <- purrr::keep(res[["consultas"]], function(q) grepl("\\|", q[["id"]]))
    linea_base <- purrr::map_dfr(consultas_res, function(q) {
      partes <- stringr::str_split_fixed(q[["id"]], "\\|", 2)
      cid <- partes[1]; variante <- partes[2]
      fila <- consultas |> filter(id == cid)
      aceptadas <- stringr::str_split(fila[["anclas_aceptadas"]], ";")[[1]]
      primaria  <- fila[["ancla_esperada"]]
      pag_acept <- unique(stringr::str_remove(aceptadas, "#.*$"))
      pl <- aplanar(q)
      paginas <- pl |> distinct(pagina, rango_pagina) |> arrange(rango_pagina)
      r_pag <- paginas[["rango_pagina"]][paginas[["pagina"]] %in% pag_acept]
      ui <- aplanar_ui(pl); pu <- aplanar_puntaje(pl)
      tibble::tibble(
        id = cid, variante = variante, consulta = q[["consulta"]],
        n_paginas = q[["n_resultados"]], n_subresultados = sum(!is.na(pl[["ancla"]])),
        ms_busqueda = q[["ms_busqueda"]],
        lectura = c("A_pagina", "B_ui_documento", "C_sub_puntaje"),
        rango_aceptada = c(if (length(r_pag)) min(r_pag) else NA_integer_, rango_de(ui, aceptadas), rango_de(pu, aceptadas)),
        rango_primaria = c(if (length(r_pag)) min(r_pag) else NA_integer_, rango_de(ui, primaria), rango_de(pu, primaria)),
        top1_aceptada = coalesce(c(if (length(r_pag)) min(r_pag) else NA_integer_, rango_de(ui, aceptadas), rango_de(pu, aceptadas)) <= 1L, FALSE),
        top3_aceptada = coalesce(c(if (length(r_pag)) min(r_pag) else NA_integer_, rango_de(ui, aceptadas), rango_de(pu, aceptadas)) <= 3L, FALSE),
        top3_primaria = coalesce(c(if (length(r_pag)) min(r_pag) else NA_integer_, rango_de(ui, primaria), rango_de(pu, primaria)) <= 3L, FALSE),
        primer_resultado = c(if (nrow(paginas)) paginas[["pagina"]][1] else NA_character_,
                             if (nrow(ui)) paste0(ui[["pagina"]][1], "#", ui[["ancla"]][1]) else NA_character_,
                             if (nrow(pu)) paste0(pu[["pagina"]][1], "#", pu[["ancla"]][1]) else NA_character_)
      )
    })
    resumen_lb <- linea_base |>
      summarise(consultas = n(),
                top1 = sum(top1_aceptada), top3 = sum(top3_aceptada), top3_primaria = sum(top3_primaria),
                top10 = sum(coalesce(rango_aceptada <= 10L, FALSE)),
                no_aparece = sum(is.na(rango_aceptada)),
                K_max_para_cubrir_las_halladas = if (all(is.na(rango_aceptada))) NA_integer_ else max(rango_aceptada, na.rm = TRUE),
                candidatos_promedio = round(mean(if_else(lectura == "A_pagina", n_paginas, n_subresultados)), 1),
                ms_promedio = round(mean(ms_busqueda), 2),
                .by = c(variante, lectura)) |>
      arrange(variante, lectura)
    print(as.data.frame(linea_base |> filter(variante == "sin_filtro") |>
                          select(id, lectura, rango_aceptada, rango_primaria, top3_aceptada, n_paginas, n_subresultados, primer_resultado)))
    print(as.data.frame(resumen_lb))
    escribir(linea_base, "linea_base_pagefind")
    escribir(resumen_lb, "linea_base_resumen")

    # Controles del instrumento.
    c0 <- purrr::keep(res[["consultas"]], function(q) identical(q[["id"]], "C0"))[[1]]
    pl0 <- aplanar(c0)
    linea("control positivo C0 'mochila': ", c0[["n_resultados"]], " paginas; primera = ", pl0[["pagina"]][1],
          "; primer sub-resultado = #", pl0[["ancla"]][1],
          " -> ", if (identical(pl0[["pagina"]][1], "dictamen_065_revision_mochilas.html") && identical(pl0[["ancla"]][1], "materia")) "PASA (reproduce la receta del orquestador)" else "FALLA")
    cn <- purrr::keep(res[["consultas"]], function(q) identical(q[["id"]], "CNEG"))[[1]]
    pln <- aplanar(cn)
    linea("control negativo CNEG 'xyzzy': ", cn[["n_resultados"]], " paginas devueltas (",
          paste(unique(pln[["pagina"]]), collapse = ", "), "); anclas: ",
          paste(stats::na.omit(pln[["ancla"]]), collapse = ", "),
          " -> Pagefind NO devuelve cero para un termino inexistente: 'no aparece' se mide por ancla, no por recuento de resultados")
  }
}

# ---- Cierre: invariante de no escritura en 40_salidas/ ----------------------
seccion("CIERRE")
foto_despues <- foto_salidas()
linea("40_salidas/: archivos antes=", foto_antes[["n"]], " despues=", foto_despues[["n"]],
      " | mtime max antes=", format(foto_antes[["mtime_max"]]), " despues=", format(foto_despues[["mtime_max"]]),
      " -> ", if (identical(foto_antes, foto_despues)) "SIN CAMBIOS" else "CAMBIO DETECTADO (revisar)")
salidas_a2 <- fs::dir_info(LAB, glob = "*a2_*")
linea("artefactos a2_ en lab_motor_v9/: ", nrow(salidas_a2))
print(as.data.frame(salidas_a2 |> transmute(archivo = fs::path_file(path), bytes = as.numeric(size),
                                           mtime = format(modification_time, "%Y-%m-%d %H:%M:%S"))))
