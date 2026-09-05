# =============================================================================
# 20260904_prototipo_vocabulario.R
# -----------------------------------------------------------------------------
# Prototipo de laboratorio del encargo v9 (agente A1, capa 1): construye el
# vocabulario controlado que alimenta la sugerencia de conceptos mientras alguien
# escribe, desde los artefactos que el pipeline ya produce, y lo deja en
#   50_documentacion/andamios/lab_motor_v9/vocabulario.json
#
# Invocacion, siempre desde la raiz del repositorio:
#   Rscript 50_documentacion/andamios/20260904_prototipo_vocabulario.R
#
# Lee (solo lectura): 40_salidas/datos/catalogo.json, 40_salidas/datos/normas/*.json,
#   40_salidas/datos/relaciones.json, 20_insumos/curaduria/metadatos_curados.json,
#   20_insumos/normativa/README.md, 20_insumos/curaduria/piezas/borradores/*.md,
#   40_salidas/sitio_src/tema-*.qmd, 40_salidas/sitio_src/index.qmd,
#   40_salidas/sitio/*.html, 10_utils/10_configuracion.R, 10_utils/10_utils.R.
# Escribe SOLO en 50_documentacion/andamios/lab_motor_v9/: vocabulario.json y
#   archivos con prefijo a1_. No toca 20_insumos/, 40_salidas/ ni el pipeline.
#
# Reglas del encargo que este script cumple a proposito:
#   - R exclusivamente (Python prohibido en el proyecto).
#   - Acceso [[ ]] exacto sobre todo lo leido de disco; nunca `$`.
#   - Ninguna cifra sin recuento en esta misma corrida; cada cero con su control
#     positivo en el mismo bloque; patrones dependientes de locale derivados en
#     runtime provocando el caso (seccion 1).
#   - Nada se inventa: cada alias trae su procedencia (a1_alias_procedencia.csv).
# =============================================================================

# ---- 0. Arranque ------------------------------------------------------------
PAQUETES <- c("jsonlite", "dplyr", "stringr", "stringi", "purrr", "tibble",
              "readr", "here", "fs", "yaml")
faltan <- PAQUETES[!vapply(PAQUETES, requireNamespace, logical(1), quietly = TRUE)]
if (length(faltan) > 0L) {
  stop("Faltan paquetes y no hay red hacia CRAN (no se instala nada): ",
       paste(faltan, collapse = ", "))
}
suppressPackageStartupMessages({
  library(dplyr); library(stringr); library(purrr); library(tibble)
})
options(width = 200, warnPartialMatchDollar = TRUE)

# Configuracion del proyecto: guarda de locale UTF-8 (primera linea ejecutable de
# ese archivo), rutas, TIPOS_NORMA y TEMAS_PALABRAS_CLAVE. Es la fuente canonica de
# las taxonomias; no se duplican aqui. Verificado antes de usarlo que ninguno de
# los dos archivos escribe en disco al ser cargado (grep de write/saveRDS/sink).
source(here::here("10_utils", "10_configuracion.R"))
source(here::here("10_utils", "10_utils.R"))   # slugificar(), formatear_numero(), ROL_GRUPO
if (!isTRUE(l10n_info()[["UTF-8"]])) stop("El proceso no corre en UTF-8 tras la guarda.")

T_INICIO <- Sys.time()
LAB <- here::here("50_documentacion", "andamios", "lab_motor_v9")
fs::dir_create(LAB)
RUTA_VOC <- file.path(LAB, "vocabulario.json")
GENERADO_POR <- "50_documentacion/andamios/20260904_prototipo_vocabulario.R"

titulo <- function(x) cat("\n", strrep("=", 78), "\n", x, "\n", strrep("=", 78), "\n", sep = "")
imprimir <- function(df) print(as.data.frame(df), row.names = FALSE, right = FALSE)

# ---- 1. Normalizacion de texto y autoprueba en runtime -----------------------
# La consulta y las claves del vocabulario se comparan en una forma plegada:
# sin tildes, en minusculas, con el punto de miles eliminado ("21.801" y "21801"
# son la misma ley) y con todo lo que no sea letra o digito convertido en
# separador. La clase de caracteres NO se escribe a mano: el plegado lo hace la
# transliteracion Latin-ASCII de ICU, y la autoprueba de abajo provoca el caso.
normalizar <- function(x) {
  x <- stringi::stri_trans_general(x, "Latin-ASCII")
  x <- tolower(x)
  x <- gsub("(?<=[0-9])\\.(?=[0-9]{3}(?![0-9]))", "", x, perl = TRUE)
  x <- gsub("[^a-z0-9]+", " ", x)
  trimws(x)
}
tokenizar <- function(x) {
  t <- strsplit(normalizar(x), " ", fixed = TRUE)[[1]]
  t[nzchar(t)]
}
# Tokens que una consulta trae por costumbre y que no discriminan nada
# ("ley n° 21.801": "n" no identifica ninguna norma). Lista declarada.
STOP_CONSULTA <- c("n", "no", "num", "numero", "de", "del", "la", "el", "los",
                   "las", "y", "o", "a", "en", "sobre", "que", "un", "una", "al",
                   "por", "para", "con", "se", "su", "sus", "lo", "es", "e", "u")

titulo("1. Autoprueba de normalizacion (regla 5: el caso se provoca, no se escribe)")
CASO_LOCALE <- "ARTÍCULO único Nº 10 ter: Ñuñoa, Ley N° 21.801 (LGE) «celú» — año"
salida_caso <- normalizar(CASO_LOCALE)
cat("entrada : ", CASO_LOCALE, "\nsalida  : ", salida_caso, "\n", sep = "")
tok_caso <- tokenizar(CASO_LOCALE)
stopifnot(
  grepl("^[a-z0-9 ]*$", salida_caso),
  all(c("articulo", "unico", "nunoa", "21801", "celu", "ano", "lge") %in% tok_caso),
  !any(c("21", "801") %in% tok_caso)
)
cat("tokens  : ", paste(tok_caso, collapse = " | "), "\nOK: plegado a ASCII, minusculas y punto de miles eliminado.\n", sep = "")

# ---- 2. Lectura de artefactos (solo lectura) --------------------------------
titulo("2. Lectura de artefactos")
leer_json <- function(ruta) jsonlite::fromJSON(ruta, simplifyVector = FALSE)
if (!fs::dir_exists(ruta_sitio())) {
  stop("Premisa rota: no existe ", ruta_sitio(), " (sitio generado local). ",
       "No se regenera desde aqui; se reporta.")
}
catalogo    <- leer_json(ruta_datos("catalogo.json"))
normas_cat  <- catalogo[["normas"]]
rutas_normas <- list.files(ruta_normas(), pattern = "\\.json$", full.names = TRUE)
normas_full <- lapply(rutas_normas, leer_json)
names(normas_full) <- vapply(normas_full, function(n) n[["slug"]], character(1))
relaciones  <- leer_json(ruta_datos("relaciones.json"))
curados     <- leer_json(ruta_insumos("curaduria", "metadatos_curados.json"))
readme_lineas   <- readLines(ruta_normativa("README.md"), encoding = "UTF-8")
glosario_ruta   <- ruta_insumos("curaduria", "piezas", "borradores", "glosario.md")
glosario_lineas <- readLines(glosario_ruta, encoding = "UTF-8")
temas_qmd   <- list.files(ruta_sitio_src(), pattern = "^tema-.*\\.qmd$")
html_rutas  <- list.files(ruta_sitio(), pattern = "\\.html$", full.names = TRUE)
html_nombres <- basename(html_rutas)
faq_rutas   <- list.files(ruta_insumos("curaduria", "piezas", "borradores"),
                          pattern = "^faq_.*\\.md$", full.names = TRUE)
index_qmd   <- readLines(ruta_sitio_src("index.qmd"), encoding = "UTF-8")

stopifnot(length(normas_cat) == length(normas_full),
          identical(sort(names(normas_full)),
                    sort(vapply(normas_cat, function(n) n[["slug"]], character(1)))))
cat(sprintf("catalogo.json: n_normas=%d n_articulos=%d | archivos normas/*.json: %d | relaciones: %d | html en sitio/: %d | tema-*.qmd: %d\n",
            catalogo[["n_normas"]], catalogo[["n_articulos"]], length(normas_full),
            length(relaciones[["relaciones"]]), length(html_rutas), length(temas_qmd)))

# ---- 3. Inventario del universo del vocabulario (tarea 1) -------------------
titulo("3. Inventario (cada cifra recontada aqui)")

# 3a. Segmentos y articulos, por norma y por origen del texto.
segmentos <- map(normas_full, function(n) {
  tibble(slug = n[["slug"]], tipo = n[["tipo"]], origen_texto = n[["origen_texto"]],
         id = vapply(n[["articulos"]], function(a) a[["id"]], character(1)),
         etiqueta = vapply(n[["articulos"]], function(a) a[["etiqueta"]], character(1)),
         es_articulo = vapply(n[["articulos"]], function(a) isTRUE(a[["es_articulo"]]), logical(1)),
         n_chars = vapply(n[["articulos"]], function(a) nchar(a[["texto"]]), integer(1)))
}) |> bind_rows()
n_segmentos   <- nrow(segmentos)
n_articulos   <- sum(segmentos[["es_articulo"]])
n_ocr_paginas <- sum(str_starts(segmentos[["id"]], "ocr-pagina-"))
docs_ocr      <- segmentos |> filter(origen_texto == "ocr_pendiente_revision") |> distinct(slug) |> pull(slug)
stopifnot(n_articulos == catalogo[["n_articulos"]])
cat(sprintf("segmentos con id (JSON): %d | es_articulo=TRUE: %d (== catalogo) | paginas OCR sin revisar: %d en %d documentos (%s)\n",
            n_segmentos, n_articulos, n_ocr_paginas, length(docs_ocr), paste(docs_ocr, collapse = ", ")))
dist_por_norma <- segmentos |> summarise(segmentos = n(), articulos = sum(es_articulo), .by = c(slug, tipo, origen_texto)) |>
  arrange(desc(segmentos))
imprimir(dist_por_norma)

# 3b. Encabezados <h2 id="..."> del sitio generado, por archivo, y equivalencia
#     con los id del JSON (mismo codigo: slugificar). Quarto va con
#     section-divs: false, asi que el id vive en el <h2> y no en un <section>.
h2_ids <- map(html_rutas, function(r) {
  l <- readLines(r, encoding = "UTF-8", warn = FALSE)
  ids <- unlist(regmatches(l, gregexpr('<h2 id="[^"]+"', l)))
  tibble(archivo = basename(r), id = sub('^<h2 id="([^"]+)"$', "\\1", ids))
}) |> bind_rows()
ANCLAS_NO_ARTICULO <- c("toc-title", "relacionadas")
h2_norma <- h2_ids |> filter(!id %in% ANCLAS_NO_ARTICULO, sub("\\.html$", "", archivo) %in% names(normas_full))
n_h2_total <- nrow(h2_ids); n_h2_norma <- nrow(h2_norma)
equiv <- map_lgl(names(normas_full), function(s) {
  setequal(h2_norma |> filter(archivo == paste0(s, ".html")) |> pull(id),
           segmentos |> filter(slug == s) |> pull(id))
})
cat(sprintf("\n<h2 id> en los %d html: %d en total; %d en las %d paginas de norma (descontando %s); ",
            length(html_rutas), n_h2_total, n_h2_norma, length(normas_full),
            paste(ANCLAS_NO_ARTICULO, collapse = "/")))
cat(sprintf("conjunto de ids JSON == conjunto de ids h2 en %d/%d normas\n", sum(equiv), length(equiv)))
stopifnot(all(equiv), n_h2_norma == n_segmentos)

# 3c. Paginas tematicas: nombre canonico = clave del diccionario del pipeline;
#     archivo = tema-<slugificar(clave)>.qmd. Se verifica la igualdad de conjuntos.
temas <- tibble(tema = names(TEMAS_PALABRAS_CLAVE)) |>
  mutate(slug_tema = slugificar(tema), archivo_qmd = paste0("tema-", slug_tema, ".qmd"),
         archivo_html = paste0("tema-", slug_tema, ".html"),
         n_palabras_clave = map_int(tema, function(t) length(TEMAS_PALABRAS_CLAVE[[t]])),
         n_normas = map_int(tema, function(t)
           sum(vapply(normas_cat, function(n) t %in% unlist(n[["tema"]]), logical(1)))))
stopifnot(setequal(temas[["archivo_qmd"]], temas_qmd), all(temas[["archivo_html"]] %in% html_nombres))
# Titulo del front matter del qmd == clave del diccionario (control de nombre canonico).
titulos_qmd <- map_chr(temas[["archivo_qmd"]], function(a) {
  l <- readLines(ruta_sitio_src(a), encoding = "UTF-8", n = 3)
  sub('^title: "(.*)"$', "\\1", l[2])
})
stopifnot(identical(titulos_qmd, temas[["tema"]]))
cat(sprintf("\npaginas tematicas: %d qmd, %d claves en TEMAS_PALABRAS_CLAVE, conjuntos iguales; title del qmd == clave en %d/%d\n",
            length(temas_qmd), nrow(temas), sum(titulos_qmd == temas[["tema"]]), nrow(temas)))
imprimir(temas |> select(tema, archivo_html, n_normas, n_palabras_clave))

# 3d. Glosario: encabezados "### termino" con su ancla, y tabla de pendientes.
fm_lim <- which(glosario_lineas == "---")[1:2]
glosario_fm <- yaml::yaml.load(paste(glosario_lineas[(fm_lim[1] + 1):(fm_lim[2] - 1)], collapse = "\n"))
idx_h3 <- which(str_starts(glosario_lineas, "### "))
glosario_def <- map(idx_h3, function(i) {
  bloque <- glosario_lineas[i:min(i + 4, length(glosario_lineas))]
  def <- bloque[str_detect(bloque, fixed("**Definido en:**"))][1]
  m <- str_match(def, "\\[([^\\]]+)\\]\\(([^)]+)\\)")
  tibble(termino = sub("^### ", "", glosario_lineas[i]),
         texto_enlace = m[, 2], ancla = m[, 3],
         ocr_en_revision = str_detect(def, fixed("transcripción OCR en revisión")))
}) |> bind_rows() |>
  mutate(norma = sub("\\.html#.*$", "", ancla), id_articulo = sub("^.*#", "", ancla))
i_pend <- which(str_starts(glosario_lineas, "## Pendientes de fuente"))
filas_pend <- glosario_lineas[i_pend:length(glosario_lineas)]
filas_pend <- filas_pend[str_detect(filas_pend, "^\\| [^|]+ \\| [^|]+ \\|$") &
                         !str_detect(filas_pend, "^\\| (Término|---)")]
glosario_pend <- tibble(termino = str_match(filas_pend, "^\\| ([^|]+) \\|")[, 2] |> str_squish(),
                        donde_buscar = str_match(filas_pend, "^\\| [^|]+ \\| ([^|]+) \\|$")[, 2] |> str_squish())
n_decl <- as.integer(str_match(glosario_lineas[str_detect(glosario_lineas, "Definiciones legales detectadas")],
                               "\\*\\*(\\d+)\\*\\*")[, 2])
cat(sprintf("\nglosario: estado=%s validado_por=%s | encabezados ### con ancla: %d (el archivo declara %d) | terminos distintos: %d | anclados en OCR sin revisar: %d | pendientes de fuente: %d\n",
            glosario_fm[["estado"]], if (is.null(glosario_fm[["validado_por"]])) "null" else glosario_fm[["validado_por"]],
            nrow(glosario_def), n_decl, n_distinct(glosario_def[["termino"]]), sum(glosario_def[["ocr_en_revision"]]),
            nrow(glosario_pend)))
stopifnot(nrow(glosario_def) == n_decl, all(!is.na(glosario_def[["ancla"]])))
imprimir(glosario_def |> count(norma, ocr_en_revision, name = "n_terminos") |> arrange(desc(n_terminos)))
imprimir(glosario_pend)

# 3e. Nombres, rotulos y alias de las normas.
#     Rotulo corto con la misma regla que el sitio (formatear_numero + rol de grupo).
nombre_corto_a1 <- function(n) {
  base <- paste(n[["tipo_etiqueta"]], formatear_numero(n[["numero"]]))
  g <- n[["grupo_acto"]]
  if (is.null(g)) return(base)
  sprintf("%s (%s)", base, ROL_GRUPO[[g[["rol"]]]])
}
# README: tabla de equivalencias (nombre original -> canonico) y tabla de
# escaneos (canonico -> "que es"), que suple el titulo NULL de los 4 escaneos.
filas_readme <- readme_lineas[str_starts(readme_lineas, "| `")]
eq <- str_match(filas_readme, "^\\| `([^`]+)` \\| `([^`]+)\\.pdf` \\|")
readme_equiv <- tibble(original = eq[, 2], slug = eq[, 3]) |> filter(!is.na(slug)) |>
  mutate(original_limpio = original |> str_replace("\\.pdf$", "") |> str_replace("^[0-9]+\\.\\s+", "") |> str_squish())
sc <- str_match(filas_readme, "^\\| `([^`]+)\\.pdf` \\| *([0-9]+) *\\| ([^|]+) \\|$")
readme_que_es <- tibble(slug = sc[, 2], que_es = str_squish(sc[, 4])) |> filter(!is.na(slug))
stopifnot(all(readme_equiv[["slug"]] %in% names(normas_full)), nrow(readme_que_es) == length(docs_ocr) - 1L)
# relaciones.json: cita literal que disparo cada remision (como el corpus nombra a la norma).
rels <- relaciones[["relaciones"]]
citas_remision <- map(rels, function(r) if (identical(r[["tipo"]], "remision"))
  tibble(slug = r[["hacia"]], cita = str_squish(str_replace_all(r[["cita_literal"]], "\\s+", " "))) else NULL) |>
  bind_rows() |> distinct()
# Denominaciones que el propio corpus pega a una norma: "(conocida como Ley TEA)",
# "(Ley de Inclusión Escolar o LIE)", "(en adelante, "Ley de Convivencia Educativa")",
# "denominada Aula Segura". Se buscan con estos patrones sobre las 25 normas y se
# incorporan SOLO cuando en los 90 caracteres previos hay un numero de ley que
# corresponde a una ley del corpus; el resto se reporta como candidato.
texto_norma <- map(normas_full, function(n) paste(map_chr(n[["articulos"]], function(a) a[["texto"]]), collapse = "\n"))
PATRONES_DENOMINACION <- c(
  conocida_como = "\\((?:conocida|denominada|llamada) como ([^()]{3,50})\\)",
  en_adelante   = "\\(en adelante,? [\"\u201c]?([^\"\u201d()]{3,60})[\"\u201d]?\\)",
  nombre_o_sigla = "\\(([A-Z\u00c1\u00c9\u00cd\u00d3\u00da\u00d1][^()]{4,60}) o ([A-Z]{2,5})\\)",
  denominada    = "denominada ([A-Z][A-Za-z\u00e1\u00e9\u00ed\u00f3\u00fa\u00f1 ]{3,40}),",
  sigla_sola    = "([A-Z][^()]{8,70}) \\(([A-Z]{2,5})\\)"
)
denominaciones <- imap(texto_norma, function(tx, s) {
  imap(PATRONES_DENOMINACION, function(p, nombre_p) {
    m <- str_match_all(tx, p)[[1]]
    if (nrow(m) == 0L) return(NULL)
    pos <- str_locate_all(tx, p)[[1]]
    tibble(encontrada_en = s, patron = nombre_p,
           denominacion = str_squish(m[, 2]),
           sigla = if (ncol(m) >= 3) m[, 3] else NA_character_,
           previo = substr(tx, pmax(1, pos[, 1] - 90), pos[, 1] - 1))
  }) |> bind_rows()
}) |> bind_rows()
numeros_ley <- tibble(slug = names(normas_full),
                      tipo = map_chr(normas_full, function(n) n[["tipo"]]),
                      numero = map_chr(normas_full, function(n) n[["numero"]]))
denominaciones <- denominaciones |>
  mutate(numero_previo = str_match(previo, "(?i)ley\\s*n?[\u00b0\u00ba]?\\s*([0-9]{1,2}\\.?[0-9]{3})(?![0-9])")[, 2] |>
           str_replace_all("\\.", "")) |>
  left_join(numeros_ley |> filter(tipo == "ley") |> select(numero_previo = numero, slug_destino = slug),
            by = "numero_previo") |>
  count(patron, denominacion, sigla, numero_previo, slug_destino, name = "n_apariciones", sort = TRUE)
cat("\nDenominaciones y siglas que el corpus pega a una norma (patrones declarados; solo se incorporan las que traen numero de ley del corpus al lado):\n")
imprimir(denominaciones |> mutate(encontrada = TRUE))
denominaciones_incorporadas <- denominaciones |> filter(!is.na(slug_destino)) |>
  transmute(slug = slug_destino, alias = ifelse(is.na(sigla), denominacion, paste(denominacion, sigla)))
# Alias del grupo de acto: nota de colapso declarada en curaduria.
grupos <- curados[["grupos_acto"]]

# ---- 4. Construccion de las entradas (tarea 3) ------------------------------
titulo("4. Construccion del vocabulario (cronometrada)")
PESOS <- c(tema = 100, norma = 90, glosario = 60, articulo = 40)
NIVEL_POR_TIPO_NORMA <- c(ley = "fuente_primaria", dfl = "fuente_primaria", dto = "fuente_primaria",
                          circular = "fuente_primaria", rex = "fuente_primaria",
                          dictamen = "pronunciamiento_oficial")
alias_proc <- list()   # procedencia de cada alias (no se embarca en el JSON)
agregar_alias <- function(id, alias, fuente) {
  alias <- unique(alias[!is.na(alias) & nzchar(str_squish(alias))])
  if (length(alias) == 0L) return(invisible(NULL))
  alias_proc[[length(alias_proc) + 1L]] <<- tibble(entrada = id, alias = alias, fuente = fuente)
  invisible(NULL)
}

tiempo_construccion <- system.time({
  entradas <- list()

  # 4a. Temas (17): termino = clave del diccionario; alias = sus palabras clave.
  for (i in seq_len(nrow(temas))) {
    t <- temas[["tema"]][i]; id <- paste0("tema:", temas[["slug_tema"]][i])
    al <- TEMAS_PALABRAS_CLAVE[[t]]
    agregar_alias(id, al, "10_utils/10_configuracion.R TEMAS_PALABRAS_CLAVE")
    entradas[[id]] <- list(id = id, tipo = "tema", termino = t,
                           contexto = sprintf("%d normas", temas[["n_normas"]][i]),
                           alias = al, destino = temas[["archivo_html"]][i],
                           destino_canonico = temas[["archivo_html"]][i], norma = NULL,
                           peso = PESOS[["tema"]], nivel = "navegacion", citable = TRUE,
                           origen_texto = NULL, vigencia = NULL, grupo_acto = NULL, rotulo = NULL)
  }

  # 4b. Normas (25).
  for (n in normas_cat) {
    s <- n[["slug"]]; id <- paste0("norma:", s)
    corto <- nombre_corto_a1(n)
    al <- character(0)
    a_num <- unique(c(n[["numero"]], formatear_numero(n[["numero"]]), sub("^0+", "", n[["numero"]])))
    agregar_alias(id, a_num, "catalogo.json numero (crudo, con punto de miles, sin ceros a la izquierda)"); al <- c(al, a_num)
    a_tipo <- unique(c(n[["tipo"]], n[["tipo_etiqueta"]]))
    agregar_alias(id, a_tipo, "catalogo.json tipo / TIPOS_NORMA"); al <- c(al, a_tipo)
    if (!is.null(n[["titulo"]])) { agregar_alias(id, n[["titulo"]], "catalogo.json titulo"); al <- c(al, n[["titulo"]]) }
    materia <- s |> str_remove(paste0("^", n[["tipo"]], "_", n[["numero"]], "_")) |> str_replace_all("_", " ")
    if (s == "dictamen_52_77_expulsion") materia <- "52 77 expulsion"
    agregar_alias(id, materia, "slug (materia de la URL)"); al <- c(al, materia)
    orig <- readme_equiv |> filter(slug == s) |> pull(original_limpio)
    agregar_alias(id, orig, "20_insumos/normativa/README.md nombre original"); al <- c(al, orig)
    qe <- readme_que_es |> filter(slug == s) |> pull(que_es)
    agregar_alias(id, qe, "20_insumos/normativa/README.md tabla de escaneos (que es)"); al <- c(al, qe)
    cit <- citas_remision |> filter(slug == s) |> pull(cita)
    agregar_alias(id, cit, "relaciones.json cita_literal de remisiones"); al <- c(al, cit)
    den <- denominaciones_incorporadas |> filter(slug == s) |> pull(alias)
    agregar_alias(id, den, "texto del corpus: denominacion junto al numero de ley"); al <- c(al, den)
    g <- n[["grupo_acto"]]; dest_canon <- paste0(s, ".html"); grupo_id <- NULL
    if (!is.null(g)) {
      grupo_id <- g[["id"]]; dest_canon <- paste0(g[["resolucion"]], ".html")
      agregar_alias(id, g[["nota_colapso"]], "metadatos_curados.json grupos_acto nota_colapso"); al <- c(al, g[["nota_colapso"]])
    }
    vig <- n[["vigencia"]]
    vig_out <- list(estado = vig[["estado"]])
    if (!is.null(vig[["sustituido_por"]])) vig_out[["sustituido_por"]] <- vig[["sustituido_por"]]
    if (length(vig[["sustituye_a"]]) > 0L) vig_out[["sustituye_a"]] <- unlist(vig[["sustituye_a"]])
    citable <- n[["origen_texto"]] %in% c("capa_texto_pdf", "ocr_revisado")
    rot <- c(if (identical(vig[["estado"]], "sustituido")) sprintf("sustituida por %s", vig[["sustituido_por"]]),
             if (length(vig[["sustituye_a"]]) > 0L) sprintf("sustituye a %s", paste(unlist(vig[["sustituye_a"]]), collapse = ", ")),
             if (!citable) AVISO_OCR_PENDIENTE,
             if (!is.null(g)) sprintf("mismo acto que %s (%s)", paste(unlist(g[["otros_miembros"]]), collapse = ", "), g[["nota_colapso"]]))
    entradas[[id]] <- list(id = id, tipo = "norma", termino = corto,
                           contexto = if (is.null(n[["titulo"]])) qe else n[["titulo"]],
                           alias = unique(al), destino = paste0(s, ".html"), destino_canonico = dest_canon,
                           norma = s, peso = PESOS[["norma"]] , nivel = NIVEL_POR_TIPO_NORMA[[n[["tipo"]]]],
                           citable = citable, origen_texto = n[["origen_texto"]], anio = n[["anio"]],
                           vigencia = vig_out, grupo_acto = grupo_id,
                           rotulo = if (length(rot)) paste(rot, collapse = "; ") else NULL)
  }

  # 4c. Articulos y segmentos con ancla (todos los <h2 id> de las paginas de norma).
  #     Heredan las claves de su norma en el resolutor; el JSON solo lleva la etiqueta.
  for (i in seq_len(nrow(segmentos))) {
    s <- segmentos[["slug"]][i]; idart <- segmentos[["id"]][i]; id <- paste0("art:", s, "#", idart)
    en <- entradas[[paste0("norma:", s)]]
    entradas[[id]] <- list(id = id, tipo = "articulo", termino = segmentos[["etiqueta"]][i],
                           contexto = en[["termino"]], alias = character(0),
                           destino = paste0(s, ".html#", idart), destino_canonico = paste0(s, ".html#", idart),
                           norma = s, peso = PESOS[["articulo"]], nivel = en[["nivel"]],
                           citable = en[["citable"]], origen_texto = en[["origen_texto"]],
                           es_articulo = segmentos[["es_articulo"]][i], vigencia = en[["vigencia"]],
                           grupo_acto = en[["grupo_acto"]],
                           rotulo = if (!en[["citable"]]) "texto OCR sin revisar: no es cita" else NULL)
  }

  # 4d. Glosario (borrador sin firma): entradas rotuladas, nunca bloqueadas.
  ROTULO_GLOSARIO <- sprintf("glosario en borrador, sin validar (estado: %s, validado_por: %s)",
                             glosario_fm[["estado"]], if (is.null(glosario_fm[["validado_por"]])) "null" else glosario_fm[["validado_por"]])
  for (i in seq_len(nrow(glosario_def))) {
    s <- glosario_def[["norma"]][i]; en <- entradas[[paste0("norma:", s)]]
    id <- sprintf("glos:%02d", i)
    entradas[[id]] <- list(id = id, tipo = "glosario", termino = glosario_def[["termino"]][i],
                           contexto = glosario_def[["texto_enlace"]][i], alias = character(0),
                           destino = glosario_def[["ancla"]][i], destino_canonico = glosario_def[["ancla"]][i],
                           norma = s, peso = PESOS[["glosario"]], nivel = "orientacion_experta",
                           citable = en[["citable"]] && !glosario_def[["ocr_en_revision"]][i],
                           origen_texto = en[["origen_texto"]], vigencia = en[["vigencia"]], grupo_acto = NULL,
                           rotulo = paste(c(ROTULO_GLOSARIO, if (glosario_def[["ocr_en_revision"]][i]) "definicion en transcripcion OCR en revision"), collapse = "; "))
  }
  for (i in seq_len(nrow(glosario_pend))) {
    id <- sprintf("glos-pend:%02d", i)
    entradas[[id]] <- list(id = id, tipo = "glosario", termino = glosario_pend[["termino"]][i],
                           contexto = paste("pendiente de fuente; donde buscar:", glosario_pend[["donde_buscar"]][i]),
                           alias = character(0), destino = NULL, destino_canonico = NULL, norma = NULL,
                           peso = PESOS[["glosario"]] - 10, nivel = "orientacion_experta", citable = FALSE,
                           origen_texto = NULL, vigencia = NULL, grupo_acto = NULL,
                           accion = "buscar_texto",
                           rotulo = "sin definicion normativa en el corpus (pendiente de fuente); se ofrece busqueda de texto completo")
  }

  # 4e. Serializacion. Los alias siempre como arreglo (I()), NULL como null.
  a_json <- function(e) {
    e[["alias"]] <- I(e[["alias"]])
    if (!is.null(e[["vigencia"]]) && !is.null(e[["vigencia"]][["sustituye_a"]]))
      e[["vigencia"]][["sustituye_a"]] <- I(e[["vigencia"]][["sustituye_a"]])
    e
  }
  por_tipo <- table(vapply(entradas, function(e) e[["tipo"]], character(1)))
  voc <- list(generado_por = GENERADO_POR, generado_el = format(Sys.Date()), version_esquema = 1L,
              contrato = c("termino: rotulo visible; alias: cadenas adicionales que tambien identifican la entrada; el navegador deriva los tokens de termino+alias con la misma normalizacion que el resolutor",
                           "destino: URL relativa del sitio (con ancla si es articulo); destino_canonico: adonde se navega (difiere de destino solo dentro de un grupo de acto)",
                           "citable=false y rotulo: la entrada se muestra con su marca, nunca se oculta; nivel sigue la separacion en cuatro niveles del encargo",
                           "vigencia: copia del campo del catalogo; un estado sustituido se muestra siempre junto al termino"),
              n_entradas = length(entradas), por_tipo = as.list(por_tipo),
              entradas = unname(lapply(entradas, a_json)))
  jsonlite::write_json(voc, RUTA_VOC, auto_unbox = TRUE, null = "null", na = "null", pretty = FALSE)
})

# Variante sin articulos (para el presupuesto de fragmentacion), misma serializacion.
RUTA_SIN_ART <- file.path(LAB, "a1_vocabulario_sin_articulos.json")
voc_sin <- voc; voc_sin[["entradas"]] <- Filter(function(e) e[["tipo"]] != "articulo", voc[["entradas"]])
voc_sin[["n_entradas"]] <- length(voc_sin[["entradas"]]); voc_sin[["por_tipo"]][["articulo"]] <- NULL
jsonlite::write_json(voc_sin, RUTA_SIN_ART, auto_unbox = TRUE, null = "null", na = "null", pretty = FALSE)

# gzip con gzfile() de R (nivel por defecto, 6); el documento declara este metodo.
gzip_bytes <- function(ruta) {
  gz <- paste0(ruta, ".gz"); if (basename(gz) == "vocabulario.json.gz") gz <- file.path(dirname(ruta), "a1_vocabulario.json.gz")
  con <- gzfile(gz, "wb"); writeBin(readBin(ruta, "raw", file.size(ruta)), con); close(con)
  c(bytes = file.size(ruta), gzip = file.size(gz))
}
med_full <- gzip_bytes(RUTA_VOC); med_sin <- gzip_bytes(RUTA_SIN_ART)
alias_proc_df <- bind_rows(alias_proc)
readr::write_csv(alias_proc_df, file.path(LAB, "a1_alias_procedencia.csv"))
cat(sprintf("entradas: %d (%s)\n", length(entradas), paste(names(por_tipo), as.integer(por_tipo), sep = "=", collapse = ", ")))
cat(sprintf("vocabulario.json: %d bytes = %.1f KB; gzip: %d bytes = %.1f KB (%.0f%% del original)\n",
            med_full[["bytes"]], med_full[["bytes"]] / 1024, med_full[["gzip"]], med_full[["gzip"]] / 1024, 100 * med_full[["gzip"]] / med_full[["bytes"]]))
cat(sprintf("sin articulos (%d entradas): %d bytes = %.1f KB; gzip: %d bytes = %.1f KB\n",
            voc_sin[["n_entradas"]], med_sin[["bytes"]], med_sin[["bytes"]] / 1024, med_sin[["gzip"]], med_sin[["gzip"]] / 1024))
cat(sprintf("tiempo de construccion (system.time, elapsed): %.3f s (user %.3f, system %.3f)\n",
            tiempo_construccion[["elapsed"]], tiempo_construccion[["user.self"]], tiempo_construccion[["sys.self"]]))
cat(sprintf("alias con procedencia: %d filas; por fuente:\n", nrow(alias_proc_df)))
imprimir(alias_proc_df |> count(fuente, name = "n_alias", sort = TRUE))
cat("\nEntradas de norma con su rotulo (vigencia, OCR, grupo):\n")
imprimir(map(Filter(function(e) e[["tipo"]] == "norma" && !is.null(e[["rotulo"]]), entradas),
             function(e) tibble(termino = e[["termino"]], rotulo = e[["rotulo"]])) |> bind_rows())

# ---- 5. Verificacion de destinos contra el sitio generado -------------------
titulo("5. Verificacion de anclas: todo destino existe en 40_salidas/sitio/")
destinos <- map(entradas, function(e) if (is.null(e[["destino"]])) NULL else
  tibble(id = e[["id"]], tipo = e[["tipo"]], destino = e[["destino"]], destino_canonico = e[["destino_canonico"]])) |> bind_rows()
verificar_destino <- function(d) {
  archivo <- sub("#.*$", "", d); ancla <- if (grepl("#", d, fixed = TRUE)) sub("^.*#", "", d) else NA_character_
  if (!archivo %in% html_nombres) return(FALSE)
  if (is.na(ancla)) return(TRUE)
  ancla %in% (h2_ids |> filter(archivo == !!archivo) |> pull(id))
}
destinos <- destinos |> mutate(ok = map_lgl(destino, verificar_destino), ok_canonico = map_lgl(destino_canonico, verificar_destino))
# Control positivo del verificador: un ancla inventada debe fallar.
ctrl_falso <- verificar_destino("ley_21801_celulares.html#art-999-inexistente"); ctrl_cierto <- verificar_destino("ley_21801_celulares.html#art-10-ter")
cat(sprintf("control del verificador: ancla inexistente -> %s (esperado FALSE); ancla real -> %s (esperado TRUE)\n", ctrl_falso, ctrl_cierto))
stopifnot(!ctrl_falso, ctrl_cierto)
n_sin_destino <- sum(vapply(entradas, function(e) is.null(e[["destino"]]), logical(1)))
cat(sprintf("destinos verificados: %d de %d entradas con destino (con ancla: %d; solo pagina: %d); canonicos verificados: %d; entradas sin destino (pendientes de fuente): %d; fallos: %d\n",
            sum(destinos[["ok"]]), nrow(destinos), sum(grepl("#", destinos[["destino"]], fixed = TRUE)),
            sum(!grepl("#", destinos[["destino"]], fixed = TRUE)), sum(destinos[["ok_canonico"]]), n_sin_destino, sum(!destinos[["ok"]])))
if (any(!destinos[["ok"]]) || any(!destinos[["ok_canonico"]])) {
  imprimir(destinos |> filter(!ok | !ok_canonico)); stop("Hay destinos que no resuelven en el sitio generado.")
}

# ---- 6. Resolutor de sugerencias (lo que haria el navegador) ----------------
titulo("6. Resolutor")
# Indice en memoria: tokens propios por entrada (termino + alias); los articulos
# ademas heredan los de su norma, pero la herencia solo cuenta cuando la consulta
# trae un numero (regla de desambiguacion: "21801 art 10" si; "mochila" no debe
# devolver el encabezado de cada dictamen que trata de mochilas).
claves_propias <- lapply(entradas, function(e) unique(unlist(lapply(c(e[["termino"]], e[["alias"]]), tokenizar))))
claves <- claves_propias
for (id in names(entradas)) {
  e <- entradas[[id]]
  if (identical(e[["tipo"]], "articulo")) claves[[id]] <- unique(c(claves[[id]], claves_propias[[paste0("norma:", e[["norma"]])]]))
}
primer_token <- vapply(entradas, function(e) { t <- tokenizar(e[["termino"]]); if (length(t)) t[1] else "" }, character(1))
tipo_de <- vapply(entradas, function(e) e[["tipo"]], character(1))
peso_de <- vapply(entradas, function(e) e[["peso"]], numeric(1))
citable_de <- vapply(entradas, function(e) isTRUE(e[["citable"]]), logical(1))
sustituida_de <- vapply(entradas, function(e) identical(e[["vigencia"]][["estado"]], "sustituido"), logical(1))
largo_de <- vapply(entradas, function(e) nchar(e[["termino"]]), integer(1))
# Verificacion de que ninguna clave escapa al alfabeto plegado (regla 5, sobre datos reales).
todas_claves <- unique(unlist(claves))
stopifnot(all(grepl("^[a-z0-9]+$", todas_claves)))
cat(sprintf("claves distintas en el indice: %d; todas en [a-z0-9] (verificado)\n", length(todas_claves)))

REGLA_PREFIJO <- list(min_caracteres = 2L, tipos_con_2 = c("tema", "norma"), k = 8L, max_por_tipo = 4L)
sugerir <- function(consulta, k = REGLA_PREFIJO[["k"]], incluir_no_citable_articulos = FALSE,
                    modo = c("todos", "alguno"), max_por_tipo = REGLA_PREFIJO[["max_por_tipo"]]) {
  modo <- match.arg(modo)
  tq <- setdiff(tokenizar(consulta), STOP_CONSULTA)
  vacio <- tibble(termino = character(0), tipo = character(0), destino = character(0),
                  destino_canonico = character(0), rotulo = character(0), puntaje = numeric(0))
  if (length(tq) == 0L || sum(nchar(tq)) < REGLA_PREFIJO[["min_caracteres"]]) return(vacio)
  tipos_ok <- if (sum(nchar(tq)) < 3L) REGLA_PREFIJO[["tipos_con_2"]] else unique(tipo_de)
  tiene_numero <- any(grepl("[0-9]", tq))
  coincide <- vapply(names(entradas), function(id) {
    if (!tipo_de[[id]] %in% tipos_ok) return(FALSE)
    if (tipo_de[[id]] == "articulo" && !incluir_no_citable_articulos && !citable_de[[id]]) return(FALSE)
    cl <- if (tipo_de[[id]] == "articulo" && !tiene_numero) claves_propias[[id]] else claves[[id]]
    hits <- vapply(tq, function(t) any(startsWith(cl, t)), logical(1))
    if (modo == "todos") all(hits) else any(hits)
  }, logical(1))
  ids <- names(entradas)[coincide]
  if (length(ids) == 0L) return(vacio)
  puntaje <- vapply(ids, function(id) {
    exactos <- sum(tq %in% claves[[id]])
    peso_de[[id]] + 30 * startsWith(primer_token[[id]], tq[1]) + 10 * exactos -
      25 * sustituida_de[[id]] - 10 * !citable_de[[id]] - 0.05 * largo_de[[id]]
  }, numeric(1))
  res <- map(ids, function(id) { e <- entradas[[id]]
    tibble(termino = e[["termino"]], tipo = e[["tipo"]], contexto = e[["contexto"]],
           destino = if (is.null(e[["destino"]])) NA_character_ else e[["destino"]],
           destino_canonico = if (is.null(e[["destino_canonico"]])) NA_character_ else e[["destino_canonico"]],
           rotulo = if (is.null(e[["rotulo"]])) "" else e[["rotulo"]]) }) |> bind_rows() |>
    mutate(puntaje = round(puntaje, 2)) |> arrange(desc(puntaje), termino) |>
    mutate(orden_tipo = row_number(), .by = tipo) |> filter(orden_tipo <= max_por_tipo) |> select(-orden_tipo)
  head(res, k)
}
mostrar <- function(consulta, ...) {
  r <- sugerir(consulta, ...)
  cat(sprintf('\n> consulta "%s": %d sugerencia(s)\n', consulta, nrow(r)))
  if (nrow(r)) imprimir(r |> mutate(contexto = str_trunc(contexto, 60), rotulo = str_trunc(rotulo, 70)))
  invisible(r)
}
t_q <- system.time(for (i in 1:100) sugerir("celu"))
cat(sprintf("latencia del resolutor en R (100 consultas 'celu'): %.1f ms por consulta (medido en R, no en el navegador)\n", 1000 * t_q[["elapsed"]] / 100))

# ---- 7. Comportamiento ante prefijos de 1, 2 y 3 caracteres (tarea 4) -------
titulo("7. Prefijos de 1, 2 y 3 caracteres: cuantas entradas dispara cada uno")
prefijos <- map(1:3, function(L) {
  pf <- unique(substr(todas_claves[nchar(todas_claves) >= L], 1, L))
  tibble(largo = L, prefijo = pf,
         sin_regla = map_int(pf, function(p) sum(vapply(names(entradas), function(id) any(startsWith(claves[[id]], p)), logical(1)))),
         con_regla = map_int(pf, function(p) nrow(sugerir(p, k = 10000L, max_por_tipo = 10000L))))
}) |> bind_rows()
readr::write_csv(prefijos, file.path(LAB, "a1_prefijos.csv"))
imprimir(prefijos |> summarise(n_prefijos = n(), mediana_sin_regla = median(sin_regla), max_sin_regla = max(sin_regla),
                               mediana_con_regla = median(con_regla), max_con_regla = max(con_regla),
                               prefijos_con_0_con_regla = sum(con_regla == 0), .by = largo))
cat("ejemplos:\n"); imprimir(prefijos |> filter(prefijo %in% c("c", "ce", "cel", "m", "mo", "moc", "4", "48", "482", "l", "le", "ley")))

# ---- 8. Cobertura contra el lenguaje del corpus (tarea 2; aproximacion declarada) ----
titulo("8. Cobertura: terminos frecuentes del corpus que el vocabulario NO sugiere")
# Sin registro de consultas, se usa el corpus como proxy. Palabras vacias declaradas
# aqui (no hay paquete stopwords en el entorno).
STOP_CORPUS <- c("a","al","algo","alguna","algunas","alguno","algunos","ante","antes","aquel","aquella","aquellas","aquellos",
  "asi","aun","cada","como","con","contra","cual","cuales","cualquier","cuando","cuyo","cuya","cuyos","cuyas","de","del",
  "desde","donde","dos","durante","el","ella","ellas","ellos","en","entre","era","eran","es","esa","esas","ese","eso","esos",
  "esta","estas","este","esto","estos","fue","fueron","ha","habia","han","hasta","hay","la","las","le","les","lo","los","mas",
  "me","mediante","mi","mientras","misma","mismo","mismas","mismos","muy","nada","ni","no","nos","o","otra","otras","otro",
  "otros","para","pero","por","que","quien","quienes","se","sea","sean","segun","ser","si","sido","sin","sino","sobre","son",
  "su","sus","tal","tales","tambien","tanto","te","tiene","tienen","toda","todas","todo","todos","tras","un","una","uno","unos",
  "unas","ya","yo","asimismo","dicho","dicha","dichos","dichas","respecto","caso","casos","efecto","efectos","podra","podran",
  "debera","deberan","deben","debe","haber","tener","cuenta","parte","forma","numero","fecha","ano","anos","art","inciso",
  "letra","articulo","articulos","ley","decreto","presente","siguiente","siguientes","anterior","texto","dia","dias","tres",
  "solo","demas","ademas","conforme","establece","establecidos","establecidas","establecido","establecida","dispone","senala",
  "senalado","senalada","senalados","senaladas","mismo","cuyo","aquel","sera","seran","este","esta","vez","asi","bien","ser")
tokens_corpus <- imap(texto_norma, function(tx, s) tibble(slug = s, token = tokenizar(tx))) |> bind_rows() |>
  filter(nchar(token) >= 4, !grepl("^[0-9]+$", token), !token %in% STOP_CORPUS)
unigramas <- tokens_corpus |> summarise(frecuencia = n(), n_normas = n_distinct(slug), .by = token) |>
  arrange(desc(n_normas), desc(frecuencia)) |> head(200) |>
  mutate(n_sugerencias = map_int(token, function(t) nrow(sugerir(t))), cubierto = n_sugerencias > 0)
readr::write_csv(unigramas, file.path(LAB, "a1_cobertura_unigramas.csv"))
bigramas <- imap(texto_norma, function(tx, s) { t <- tokenizar(tx); t <- t[nchar(t) >= 3 & !grepl("^[0-9]+$", t)]
  if (length(t) < 2) return(NULL); bg <- paste(t[-length(t)], t[-1]); tibble(slug = s, bigrama = bg) }) |> bind_rows() |>
  filter(!str_detect(bigrama, paste0("^(", paste(STOP_CORPUS, collapse = "|"), ") ")),
         !str_detect(bigrama, paste0(" (", paste(STOP_CORPUS, collapse = "|"), ")$"))) |>
  summarise(frecuencia = n(), n_normas = n_distinct(slug), .by = bigrama) |>
  arrange(desc(n_normas), desc(frecuencia)) |> head(150) |>
  mutate(n_sugerencias = map_int(bigrama, function(b) nrow(sugerir(b))), cubierto = n_sugerencias > 0)
readr::write_csv(bigramas, file.path(LAB, "a1_cobertura_bigramas.csv"))
cat(sprintf("tokens del corpus tras filtros: %d (distintos: %d) | top-200 unigramas: cubiertos %d, no cubiertos %d | top-150 bigramas: cubiertos %d, no cubiertos %d\n",
            nrow(tokens_corpus), n_distinct(tokens_corpus[["token"]]), sum(unigramas[["cubierto"]]), sum(!unigramas[["cubierto"]]),
            sum(bigramas[["cubierto"]]), sum(!bigramas[["cubierto"]])))
cat("\nunigramas NO cubiertos (top 40 por numero de normas en que aparecen):\n")
imprimir(unigramas |> filter(!cubierto) |> head(40))
cat("\nbigramas NO cubiertos (top 40):\n")
imprimir(bigramas |> filter(!cubierto) |> head(40))

# Segundo proxy: consultas escritas por personas en el propio repositorio
# (ejemplos de la portada, titulos de las 12 FAQ en borrador, pendientes del glosario).
ejemplos_portada <- {
  i0 <- which(str_detect(index_qmd, "Por ejemplo:"))[1]; i1 <- which(str_starts(index_qmd, "```"))[1]
  sub("^- ", "", index_qmd[(i0 + 1):(i1 - 1)][str_starts(index_qmd[(i0 + 1):(i1 - 1)], "- ")])
}
titulos_faq <- map_chr(faq_rutas, function(r) { l <- readLines(r, encoding = "UTF-8", n = 6)
  sub('^titulo: "(.*)"$', "\\1", l[str_starts(l, "titulo:")][1]) })
proxy <- bind_rows(tibble(origen = "portada index.qmd", consulta = ejemplos_portada),
                   tibble(origen = "titulo FAQ borrador", consulta = titulos_faq),
                   tibble(origen = "glosario pendientes", consulta = glosario_pend[["termino"]])) |>
  mutate(n_todos = map_int(consulta, function(q) nrow(sugerir(q))),
         top1_todos = map_chr(consulta, function(q) { r <- sugerir(q); if (nrow(r)) paste0(r[["tipo"]][1], ": ", r[["termino"]][1]) else "" }),
         n_alguno = map_int(consulta, function(q) nrow(sugerir(q, modo = "alguno"))),
         top1_alguno = map_chr(consulta, function(q) { r <- sugerir(q, modo = "alguno"); if (nrow(r)) paste0(r[["tipo"]][1], ": ", r[["termino"]][1]) else "" }))
readr::write_csv(proxy, file.path(LAB, "a1_consultas_proxy.csv"))
cat(sprintf("\nconsultas proxy: %d (portada %d, FAQ %d, pendientes %d); con sugerencia en modo 'todos' (AND): %d; en modo 'alguno' (OR): %d\n",
            nrow(proxy), length(ejemplos_portada), length(titulos_faq), nrow(glosario_pend), sum(proxy[["n_todos"]] > 0), sum(proxy[["n_alguno"]] > 0)))
imprimir(proxy |> mutate(consulta = str_trunc(consulta, 62), top1_todos = str_trunc(top1_todos, 45), top1_alguno = str_trunc(top1_alguno, 45)))

# ---- 9. Casos plantados del encargo (criterio de exito) ---------------------
titulo("9. Casos plantados (salida literal; el script aborta si alguno falla)")
r_celu <- mostrar("celu")
stopifnot("tema-uso-de-dispositivos-moviles.html" %in% r_celu[["destino"]], "ley_21801_celulares.html" %in% r_celu[["destino"]])
cat("OK celu: aparecen el tema de dispositivos moviles y la Ley 21.801\n")

r_circ <- mostrar("circular 482"); r_rex <- mostrar("REX 482")
stopifnot(nrow(r_circ) > 0, nrow(r_rex) > 0, identical(r_circ[["destino_canonico"]][1], r_rex[["destino_canonico"]][1]))
cat(sprintf("OK circular 482 == REX 482: ambas resuelven a %s\n", r_circ[["destino_canonico"]][1]))

r_moch <- mostrar("mochila")
fila_065 <- r_moch |> filter(destino == "dictamen_065_revision_mochilas.html")
stopifnot("tema-revision-de-pertenencias.html" %in% r_moch[["destino"]],
          nrow(fila_065) == 1L, str_detect(fila_065[["rotulo"]], "sustituida por dictamen_078"),
          "dictamen_078_detectores_revision_mochilas.html" %in% r_moch[["destino"]])
cat("OK mochila: tema de revision de pertenencias, dictamen 065 con marca 'sustituida por dictamen_078...' y dictamen 078\n")

r_xyz <- mostrar("xyzzy"); r_ctrl <- mostrar("convivencia")
stopifnot(nrow(r_xyz) == 0L, nrow(r_ctrl) > 0L)
cat(sprintf("OK control negativo/positivo en el mismo bloque: 'xyzzy' -> %d resultados; 'convivencia' -> %d resultados\n", nrow(r_xyz), nrow(r_ctrl)))

cat("\nConsultas adicionales de la especificacion (desambiguacion y prefijos):\n")
for (q in c("c", "ce", "cel", "482", "ley", "ley 21.801", "21801 art 10", "acoso", "cancelación de matrícula", "ley tea", "LGE", "aula segura", "expulsion", "art 46", "estatuto docente"))
  mostrar(q)
cat("\nAlias detectados en el corpus o en el README, uno por uno (0 resultados = alias NO cubierto; el control positivo es 'convivencia' arriba):\n")
alias_prueba <- c("LIE", "ley de inclusión", "ley de garantías", "ley de convivencia", "ley de subvenciones", "JEC", "SEP", "RO", "SAE", "LSAC", "DFL 2", "DFL 1", "circular 181", "dictamen 65", "dictamen 78", "estatuto asistentes", "asistentes de la educación", "reglamento interno", "protocolo", "trans", "nombre social", "embarazada")
cobertura_alias <- tibble(consulta = alias_prueba,
  n = map_int(alias_prueba, function(q) nrow(sugerir(q))),
  top1 = map_chr(alias_prueba, function(q) { r <- sugerir(q); if (nrow(r)) paste0(r[["tipo"]][1], ": ", r[["termino"]][1], " -> ", r[["destino_canonico"]][1]) else "(sin sugerencia)" }))
imprimir(cobertura_alias)
readr::write_csv(cobertura_alias, file.path(LAB, "a1_alias_prueba.csv"))

# ---- 10. Presupuesto de latencia en el navegador (calculo, no medicion) -----
titulo("10. Presupuesto de descarga a 3 Mbps (calculo declarado)")
MBPS <- 3
presupuesto <- tibble(archivo = c("vocabulario.json", "vocabulario.json (gzip)", "sin articulos", "sin articulos (gzip)"),
                      bytes = c(med_full[["bytes"]], med_full[["gzip"]], med_sin[["bytes"]], med_sin[["gzip"]])) |>
  mutate(kb = round(bytes / 1024, 1), segundos_a_3mbps = round(bytes * 8 / (MBPS * 1e6), 3))
imprimir(presupuesto)
cat("formula: segundos = bytes * 8 / 3e6. No incluye latencia de conexion ni TTFB (no medidos).\n")

# ---- 11. Resumen de medidas ---------------------------------------------------
medidas <- list(
  generado_por = GENERADO_POR, fecha = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
  n_normas = length(normas_full), n_segmentos = n_segmentos, n_articulos_es_articulo = n_articulos,
  n_paginas_ocr_sin_revisar = n_ocr_paginas, n_docs_ocr = length(docs_ocr),
  n_h2_total_sitio = n_h2_total, n_h2_paginas_norma = n_h2_norma, n_html = length(html_rutas),
  n_temas = nrow(temas), n_glosario_definiciones = nrow(glosario_def), n_glosario_distintos = n_distinct(glosario_def[["termino"]]),
  n_glosario_ocr = sum(glosario_def[["ocr_en_revision"]]), n_glosario_pendientes = nrow(glosario_pend),
  n_entradas = length(entradas), por_tipo = as.list(por_tipo), n_alias = nrow(alias_proc_df),
  n_claves = length(todas_claves), n_destinos_verificados = sum(destinos[["ok"]]), n_sin_destino = n_sin_destino,
  bytes = med_full[["bytes"]], kb = round(med_full[["bytes"]] / 1024, 1), gzip_bytes = med_full[["gzip"]],
  bytes_sin_articulos = med_sin[["bytes"]], gzip_bytes_sin_articulos = med_sin[["gzip"]],
  tiempo_construccion_s = round(tiempo_construccion[["elapsed"]], 3),
  latencia_resolutor_ms = round(1000 * t_q[["elapsed"]] / 100, 2),
  segundos_3mbps = presupuesto[["segundos_a_3mbps"]],
  cobertura = list(unigramas_top = nrow(unigramas), unigramas_cubiertos = sum(unigramas[["cubierto"]]),
                   bigramas_top = nrow(bigramas), bigramas_cubiertos = sum(bigramas[["cubierto"]]),
                   proxy_n = nrow(proxy), proxy_todos = sum(proxy[["n_todos"]] > 0), proxy_alguno = sum(proxy[["n_alguno"]] > 0)),
  duracion_total_s = round(as.numeric(difftime(Sys.time(), T_INICIO, units = "secs")), 2)
)
jsonlite::write_json(medidas, file.path(LAB, "a1_medidas.json"), auto_unbox = TRUE, pretty = TRUE)
titulo("11. Archivos escritos en lab_motor_v9/")
imprimir(fs::dir_info(LAB) |> filter(str_starts(basename(path), "a1_") | basename(path) == "vocabulario.json") |>
           transmute(archivo = basename(path), bytes = as.integer(size), modificado = format(modification_time, "%Y-%m-%d %H:%M:%S")))
cat(sprintf("\nduracion total del script: %.2f s\n", medidas[["duracion_total_s"]]))
