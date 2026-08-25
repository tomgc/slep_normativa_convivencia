# =============================================================================
# 32_segmentar_articulos.R
# -----------------------------------------------------------------------------
# Proposito: texto plano -> estructura por articulo.
#            Escribe 40_salidas/datos/normas/<slug>.json (una norma por archivo)
#            y 40_salidas/datos/catalogo.json (catalogo maestro).
#
# REGLA DE ORO: nada se inventa. `tipo`, `numero` y `slug` se DERIVAN del nombre
# canonico del archivo, que es la fuente que los gobierna desde T2. `titulo` y
# `anio` se extraen del propio texto cuando la estructura del documento lo
# permite sin adivinar; cuando no, quedan NULL y el slug entra a `marca_revisar`.
# Un anio plausible pero falso en una biblioteca normativa institucional es peor
# que un hueco visible.
# =============================================================================

source(here::here("10_utils", "10_utils.R"))
instalar_si_falta(c("jsonlite", "fs", "stringi", "here"))
source(here::here("10_utils", "10_configuracion.R"))

ORIGEN <- "32_segmentar"

# ---- Derivacion desde el nombre canonico ------------------------------------
# El nombre es <tipo>_<numero>_<materia>.pdf y T2 lo fijo con verificacion de
# md5. De ahi salen tres campos sin ninguna inferencia sobre el contenido.
derivar_de_nombre <- function(slug) {
  partes <- strsplit(slug, "_", fixed = TRUE)[[1]]
  tipo <- partes[1]
  if (!tipo %in% names(TIPOS_NORMA)) {
    stop(sprintf("Slug '%s': el prefijo '%s' no esta en TIPOS_NORMA. ", slug, tipo),
         "Renombrar el PDF o ampliar la taxonomia en 10_utils/10_configuracion.R.")
  }
  list(tipo = tipo, tipo_etiqueta = unname(TIPOS_NORMA[tipo]), numero = partes[2])
}

# ---- Titulo ------------------------------------------------------------------
# Dos estructuras de cabecera conviven en el corpus y cada una tiene su regla.
#
# (a) Ficha de la Biblioteca del Congreso (18 de los 24): identificador repetido,
#     titulo en versalitas en una o mas lineas, ministerio, y despues la linea
#     de publicacion, que la Biblioteca emite en DOS variantes segun el tipo de
#     norma: "Fecha Publicacion:" y "Publicacion:" a secas. El patron acepta las
#     dos; mirar solo la primera dejaba sin titulo ni anio a 6 de los 24
#     documentos, todos ellos con la ficha completa a la vista.
#     El titulo es lo que queda entre medio al descartar el
#     identificador y el ministerio.
# (b) Dictamen de la Superintendencia: empieza en "MATERIA:" y el titulo es lo
#     que va hasta la siguiente etiqueta en versalitas ("ANTECEDENTES:").
#
# Si ninguna aplica, devuelve NULL: no hay tercera via que no sea adivinar.
extraer_titulo <- function(cabecera) {
  if (length(cabecera) == 0L) return(NULL)

  idx_fecha <- grep("^(Fecha\\s+)?Publicaci[oó]n\\s*:", cabecera)
  if (length(idx_fecha) > 0L && idx_fecha[1] > 1L) {
    cand <- cabecera[seq_len(idx_fecha[1] - 1L)]
    cand <- cand[!grepl("^(Ley|Decreto|Resolución|Resolucion|DFL|D\\.F\\.L)\\b", cand)]
    cand <- cand[!grepl("^(MINISTERIO|SUPERINTENDENCIA|SUBSECRETAR)", cand)]
    cand <- cand[nzchar(cand)]
    if (length(cand) > 0L) return(paste(cand, collapse = " "))
  }

  idx_materia <- grep("^MATERIA\\s*:", cabecera)
  if (length(idx_materia) > 0L) {
    resto <- cabecera[seq(idx_materia[1], length(cabecera))]
    resto[1] <- sub("^MATERIA\\s*:\\s*", "", resto[1])
    fin <- which(grepl(REGEX_ENCABEZADO_SECCION, resto[-1], perl = TRUE))
    hasta <- if (length(fin) > 0L) fin[1] else length(resto) - 1L
    cand <- resto[seq_len(hasta + 1L)]
    cand <- cand[nzchar(trimws(cand))]
    if (length(cand) > 0L) return(paste(cand, collapse = " "))
  }

  NULL
}

# ---- Anio --------------------------------------------------------------------
# UNICA fuente aceptada: la linea estructural "Fecha Publicacion: DD-MMM-AAAA"
# de la ficha de la Biblioteca del Congreso. Deliberadamente NO se busca una
# fecha suelta en el cuerpo: los dictamenes citan media docena de fechas ajenas
# (la ley que interpretan, el memo que los origina, la resolucion que los
# habilita) y cualquier heuristica que las mire acaba publicando el anio de otro
# documento como si fuera el propio. Sin la linea estructural, NULL.
extraer_anio <- function(cabecera) {
  if (length(cabecera) == 0L) return(NULL)
  linea <- grep("^(Fecha\\s+)?Publicaci[oó]n\\s*:", cabecera, value = TRUE)
  if (length(linea) == 0L) return(NULL)
  m <- regmatches(linea[1], regexpr("[0-9]{4}", linea[1]))
  if (length(m) == 0L) return(NULL)
  as.integer(m)
}

# ---- Temas -------------------------------------------------------------------
# Coincidencia de palabras clave del diccionario cerrado de 10_configuracion.R
# sobre el texto plegado a ASCII y minusculas. Reproducible y auditable: la misma
# entrada da siempre la misma salida y cualquiera puede leer por que una norma
# quedo en un tema.
asignar_temas <- function(texto) {
  plano <- tolower(stringi::stri_trans_general(texto, "Latin-ASCII"))
  hits <- vapply(TEMAS_PALABRAS_CLAVE,
                 function(claves) any(vapply(claves, grepl, logical(1),
                                             x = plano, fixed = TRUE)),
                 logical(1))
  names(TEMAS_PALABRAS_CLAVE)[hits]
}

# ---- Identificador de articulo ----------------------------------------------
# El id sale de las capturas del encabezado, no del texto libre, y pasa por
# slugificar(): la MISMA funcion que 33_generar_paginas.R usa para el ancla del
# HTML. Si los dos lados no comparten funcion, un resultado de busqueda apunta a
# un fragmento que no existe y el error no se ve hasta que alguien hace clic.
id_de_encabezado <- function(captura, transitorio) {
  numero  <- captura[2]
  sufijo  <- captura[3]
  marca_t <- captura[4]
  clave <- tolower(stringi::stri_trans_general(numero, "Latin-ASCII"))
  if (clave %in% names(ORDINALES_ARTICULO) && clave != "unico") {
    numero <- as.character(ORDINALES_ARTICULO[[clave]])
  } else {
    numero <- clave
  }
  piezas <- c("art", numero, tolower(sufijo))
  if (nzchar(marca_t) || transitorio) piezas <- c(piezas, "transitorio")
  slugificar(paste(piezas[nzchar(piezas)], collapse = "-"))
}

# ---- Segmentacion ------------------------------------------------------------
segmentar <- function(texto) {
  bloques <- strsplit(texto, "\n\n", fixed = TRUE)[[1]]
  bloques <- bloques[nzchar(trimws(bloques))]
  if (length(bloques) == 0L) return(list())

  cap <- regmatches(bloques, regexec(REGEX_ENCABEZADO_ARTICULO, bloques, perl = TRUE))
  es_encabezado <- lengths(cap) > 0L

  if (any(es_encabezado)) return(segmentar_por_articulos(bloques, cap, es_encabezado))

  es_seccion <- grepl(REGEX_ENCABEZADO_SECCION, bloques, perl = TRUE)
  if (sum(es_seccion) >= 2L) return(segmentar_por_secciones(bloques, es_seccion))

  # Sin articulado ni secciones: documento unico. Es el caso de las resoluciones
  # exentas de una pagina, que son un acto administrativo continuo.
  list(list(id = "documento", etiqueta = "Documento completo",
            es_articulo = FALSE, texto = paste(bloques, collapse = "\n\n")))
}

segmentar_por_articulos <- function(bloques, cap, es_encabezado) {
  cortes <- which(es_encabezado)
  segs <- list()
  transitorio <- FALSE

  if (cortes[1] > 1L) {
    segs[[1]] <- list(id = "preambulo", etiqueta = "Encabezado y promulgación",
                      es_articulo = FALSE,
                      texto = paste(bloques[seq_len(cortes[1] - 1L)], collapse = "\n\n"))
  }

  vistos <- character(0)
  for (k in seq_along(cortes)) {
    i   <- cortes[k]
    fin <- if (k < length(cortes)) cortes[k + 1L] - 1L else length(bloques)

    # La marca de seccion transitoria puede venir en un bloque anterior al
    # encabezado: desde ahi todo lo que sigue es transitorio aunque los
    # encabezados individuales no repitan la palabra.
    ini_ventana <- if (k == 1L) 1L else cortes[k - 1L]
    if (any(grepl(REGEX_SECCION_TRANSITORIA, bloques[ini_ventana:i], perl = TRUE))) {
      transitorio <- TRUE
    }

    id <- id_de_encabezado(cap[[i]], transitorio)
    # Desambiguacion de colisiones: una ley modificatoria cita articulos de la
    # norma que modifica y el mismo numero puede aparecer dos veces. Dos anclas
    # iguales en un HTML hacen que la segunda sea inalcanzable.
    if (id %in% vistos) {
      n <- sum(startsWith(vistos, id)) + 1L
      id <- paste0(id, "-", n)
    }
    vistos <- c(vistos, id)

    segs[[length(segs) + 1L]] <- list(
      id = id,
      # La comilla de apertura viaja en la captura porque el patron la admite para
      # llegar al articulado entrecomillado de las leyes modificatorias. Es parte
      # del texto del articulo, que se conserva intacto, pero no de su nombre:
      # la etiqueta es lo que el sitio imprime como titulo del bloque.
      etiqueta = trimws(sub("^[\"\u201c\u00ab(]\\s*", "", trimws(cap[[i]][1]))),
      es_articulo = TRUE,
      texto = paste(bloques[i:fin], collapse = "\n\n")
    )
  }
  segs
}

segmentar_por_secciones <- function(bloques, es_seccion) {
  cortes <- which(es_seccion)
  segs <- list()
  if (cortes[1] > 1L) {
    segs[[1]] <- list(id = "preambulo", etiqueta = "Encabezado",
                      es_articulo = FALSE,
                      texto = paste(bloques[seq_len(cortes[1] - 1L)], collapse = "\n\n"))
  }
  vistos <- character(0)
  for (k in seq_along(cortes)) {
    i   <- cortes[k]
    fin <- if (k < length(cortes)) cortes[k + 1L] - 1L else length(bloques)
    etiqueta <- trimws(sub("^[ \t]*([^:]{4,44}):.*$", "\\1", bloques[i]))
    id <- slugificar(etiqueta)
    if (id %in% vistos) id <- paste0(id, "-", sum(vistos == id) + 1L)
    vistos <- c(vistos, id)
    segs[[length(segs) + 1L]] <- list(
      id = id, etiqueta = etiqueta, es_articulo = FALSE,
      texto = paste(bloques[i:fin], collapse = "\n\n")
    )
  }
  segs
}

# ---- Construccion de una norma ----------------------------------------------
construir_norma <- function(meta) {
  slug <- meta$slug
  d <- derivar_de_nombre(slug)

  texto <- if (isTRUE(meta$sin_capa_texto)) "" else
    paste(readLines(ruta_salidas("intermedios", "texto", paste0(slug, ".txt")),
                    warn = FALSE), collapse = "\n")

  cabecera <- if (is.null(meta$cabecera)) character(0) else as.character(meta$cabecera)
  titulo <- extraer_titulo(cabecera)
  anio   <- extraer_anio(cabecera)
  temas  <- if (nzchar(texto)) asignar_temas(texto) else character(0)
  arts   <- if (nzchar(texto)) segmentar(texto) else list()

  revisar <- character(0)
  if (is.null(titulo)) revisar <- c(revisar, "titulo")
  if (is.null(anio))   revisar <- c(revisar, "anio")
  if (isTRUE(meta$sin_capa_texto)) revisar <- c(revisar, "texto")
  if (length(temas) == 0L && nzchar(texto)) revisar <- c(revisar, "tema")

  list(
    slug = slug,
    tipo = d$tipo,
    tipo_etiqueta = d$tipo_etiqueta,
    # Capa de fuente segun el invariante 1 de la decision de funcionalidad del
    # 2026-08-25: todo lo que el sitio muestre declara de que clase de fuente
    # viene. Hoy el corpus es 100% normativo; el campo existe para que sumar
    # orientaciones ministeriales o evidencia cientifica no obligue a rehacer
    # el esquema ni las plantillas.
    tipo_fuente = "normativa",
    numero = d$numero,
    titulo = titulo,
    anio = anio,
    tema = temas,
    paginas = meta$paginas,
    pdf = paste0(slug, ".pdf"),
    sin_capa_texto = isTRUE(meta$sin_capa_texto),
    marca_revisar = revisar,
    n_articulos = sum(vapply(arts, function(a) isTRUE(a$es_articulo), logical(1))),
    n_segmentos = length(arts),
    articulos = arts
  )
}

# ---- Corrida ----------------------------------------------------------------
manifiesto <- jsonlite::fromJSON(ruta_salidas("intermedios", "extraccion.json"),
                                 simplifyDataFrame = FALSE)
log_msg(sprintf("Segmentando %d documentos.", length(manifiesto)), origen = ORIGEN)

fs::dir_create(ruta_normas())
normas <- unname(lapply(manifiesto, construir_norma))

for (n in normas) {
  escribir_atomico(n, ruta_normas(paste0(n$slug, ".json")),
                   function(o, p) jsonlite::write_json(o, p, auto_unbox = TRUE,
                                                       pretty = TRUE, null = "null"))
  log_msg(sprintf("%-46s %-9s %s  articulos=%-4d segmentos=%-4d temas=%d %s",
                  n$slug, n$tipo,
                  if (is.null(n$anio)) "????" else as.character(n$anio),
                  n$n_articulos, n$n_segmentos, length(n$tema),
                  if (length(n$marca_revisar)) paste0(MARCA_REVISAR, " ",
                                                      paste(n$marca_revisar, collapse = ",")) else ""),
          origen = ORIGEN)
}

# ---- Catalogo maestro -------------------------------------------------------
catalogo <- unname(lapply(normas, function(n) n[setdiff(names(n), "articulos")]))
orden <- order(match(vapply(catalogo, function(x) x$tipo, character(1)), ORDEN_TIPOS),
               suppressWarnings(as.integer(vapply(catalogo, function(x) x$numero, character(1)))))
catalogo <- catalogo[orden]

escribir_atomico(
  list(
    generado_por = "30_procesamiento/32_segmentar_articulos.R",
    n_normas = length(catalogo),
    n_articulos = sum(vapply(catalogo, function(x) x$n_articulos, integer(1))),
    normas = catalogo
  ),
  ruta_datos("catalogo.json"),
  function(o, p) jsonlite::write_json(o, p, auto_unbox = TRUE, pretty = TRUE, null = "null")
)

log_msg(sprintf("Segmentacion terminada: %d normas, %d articulos, %d documentos con marca de revision.",
                length(normas),
                sum(vapply(normas, function(n) n$n_articulos, integer(1))),
                sum(vapply(normas, function(n) length(n$marca_revisar) > 0L, logical(1)))),
        origen = ORIGEN)
