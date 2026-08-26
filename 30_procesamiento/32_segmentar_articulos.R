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

# ---- Metadatos curados por el equipo ----------------------------------------
# Lo que el pipeline no puede derivar del documento sin adivinar lo aporta una
# persona en 20_insumos/curaduria/metadatos_curados.json. Ese archivo NO lo
# escribe ningun script: es la unica manera de que una validacion humana
# sobreviva a la siguiente corrida.
cargar_curaduria <- function() {
  ruta <- ruta_insumos("curaduria", "metadatos_curados.json")
  if (!fs::file_exists(ruta)) {
    log_msg("No hay archivo de curaduria; se usan solo metadatos derivados.",
            nivel = "WARN", origen = ORIGEN)
    return(list())
  }
  jsonlite::fromJSON(ruta, simplifyDataFrame = FALSE)$normas
}
CURADURIA <- cargar_curaduria()

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
    # fin se busca sobre resto[-1], asi que su indice i corresponde a resto[i+1]:
    # el encabezado de la seccion siguiente. El titulo son las lineas resto[1..i],
    # sin incluirlo. La version anterior sumaba uno y se llevaba el encabezado
    # dentro del titulo ("... Sustituye Dictamen N° 65. ANTECEDENTES:").
    fin <- which(grepl(REGEX_ENCABEZADO_SECCION, resto[-1], perl = TRUE))
    hasta <- if (length(fin) > 0L) fin[1] else length(resto)
    cand <- resto[seq_len(hasta)]
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
  # Frontera de palabra al INICIO de cada clave, no coincidencia por subcadena.
  # Con subcadena, "trans" etiquetaba como identidad de genero los 16 documentos
  # que contienen "transitorio" o "transparencia". La frontera va solo al inicio
  # y no al final a proposito: asi "expulsion" sigue encontrando "expulsiones" y
  # "neurodivergen" sigue encontrando "neurodivergente", que es justo para lo que
  # esas claves se escribieron.
  coincide <- function(clave) {
    grepl(paste0("\\b", gsub("([.|()\\^{}+$*?\\[\\]])", "\\\\\\1", clave)),
          plano, perl = TRUE)
  }
  hits <- vapply(TEMAS_PALABRAS_CLAVE,
                 function(claves) any(vapply(claves, coincide, logical(1))),
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

  # Dos clases de encabezado conviven en un dictamen: la etiqueta en versalitas
  # con dos puntos (MATERIA:, ANTECEDENTES:) que abre la carátula, y el numeral en
  # versalitas (1. SOBRE LAS CAUSALES...) que estructura el cuerpo. Se detectan
  # juntas: con solo la primera, el cuerpo entero quedaba en un unico segmento.
  es_seccion <- grepl(REGEX_ENCABEZADO_SECCION, bloques, perl = TRUE) |
                grepl(REGEX_ENCABEZADO_NUMERAL, bloques, perl = TRUE)
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
    # La etiqueta y el id se derivan de la clase de encabezado que corresponda.
    # El numeral usa "num-N" y no el titulo slugificado: los titulos de seccion de
    # un dictamen tienen setenta caracteres y producirian anclas ilegibles e
    # inestables ante la menor correccion de redaccion.
    m_num <- regmatches(bloques[i], regexec(REGEX_ENCABEZADO_NUMERAL, bloques[i], perl = TRUE))[[1]]
    if (length(m_num) > 0L) {
      etiqueta <- trimws(sub("[ ,.]+$", "", m_num[1]))
      id <- paste0("num-", m_num[2])
    } else {
      etiqueta <- trimws(sub("^[ \t]*([^:]{4,44}):.*$", "\\1", bloques[i]))
      id <- slugificar(etiqueta)
    }
    if (id %in% vistos) id <- paste0(id, "-", sum(vistos == id) + 1L)
    vistos <- c(vistos, id)
    segs[[length(segs) + 1L]] <- list(
      id = id, etiqueta = etiqueta, es_articulo = FALSE,
      texto = paste(bloques[i:fin], collapse = "\n\n")
    )
  }
  segs
}

# ---- Segmentacion de una transcripcion automatica ---------------------------
# El texto reconocido se segmenta por PAGINA, no por articulo, y de forma
# deliberada. Un texto que nadie ha revisado no puede presentarse con anclas
# "art-5" que lo hagan indistinguible de una cita textual verificada; la pagina,
# en cambio, es una unidad que la transcripcion si tiene y que ademas es la que
# usa quien la revisa contra el PDF.
segmentar_ocr <- function(texto) {
  paginas <- strsplit(texto, SEPARADOR_PAGINA_OCR, fixed = TRUE)[[1]]
  lapply(seq_along(paginas), function(i) {
    list(id = sprintf("ocr-pagina-%03d", i),
         etiqueta = sprintf("Página %d", i),
         es_articulo = FALSE,
         texto = paginas[i])
  })
}

# ---- Vigencia ----------------------------------------------------------------
# Dominio cerrado de dos estados. `sustituido` exige las dos cosas: a que norma
# se sustituyo y de donde consta. Una sustitucion sin procedencia es una
# afirmacion juridica sin respaldo, y este sitio la publicaria en una banda roja
# sobre el articulado.
ESTADOS_VIGENCIA <- c("vigente", "sustituido")

vigencia_de <- function(slug, curado) {
  v <- curado$vigencia
  if (is.null(v)) return(list(estado = "vigente"))
  if (!v$estado %in% ESTADOS_VIGENCIA) {
    stop(sprintf("Slug '%s': vigencia.estado '%s' fuera del dominio (%s).",
                 slug, v$estado, paste(ESTADOS_VIGENCIA, collapse = ", ")))
  }
  if (identical(v$estado, "sustituido")) {
    if (is.null(v$sustituido_por) || !nzchar(v$sustituido_por)) {
      stop(sprintf("Slug '%s': vigencia 'sustituido' sin `sustituido_por`.", slug))
    }
    if (is.null(v$fuente) || !nzchar(v$fuente)) {
      stop(sprintf("Slug '%s': vigencia 'sustituido' sin `fuente`. La procedencia es obligatoria.", slug))
    }
  }
  v
}

# Deriva el vinculo inverso y valida que la norma sustituta exista en el corpus.
# Sin esta comprobacion, un slug mal escrito produce una banda que enlaza a una
# pagina inexistente, y el error no aparece hasta que alguien hace clic.
derivar_sustituciones <- function(normas) {
  slugs <- vapply(normas, function(n) n$slug, character(1))
  sustituye <- setNames(vector("list", length(slugs)), slugs)
  for (n in normas) {
    if (!identical(n$vigencia$estado, "sustituido")) next
    destino <- n$vigencia$sustituido_por
    if (!destino %in% slugs) {
      stop(sprintf("Slug '%s': declara `sustituido_por: %s`, que no existe en el corpus.",
                   n$slug, destino))
    }
    sustituye[[destino]] <- c(sustituye[[destino]], n$slug)
  }
  lapply(normas, function(n) {
    n$vigencia$sustituye_a <- I(if (is.null(sustituye[[n$slug]])) character(0)
                                else sustituye[[n$slug]])
    n
  })
}

# ---- Construccion de una norma ----------------------------------------------
construir_norma <- function(meta) {
  slug <- meta$slug
  d <- derivar_de_nombre(slug)

  # Se lee siempre el intermedio, sin mirar si el PDF tenia capa de texto. Desde
  # que existe el reconocimiento optico, "sin capa de texto" y "sin texto" dejaron
  # de ser lo mismo: los cuatro escaneos no tienen capa y si tienen transcripcion.
  # La condicion anterior los dejaba en cero segmentos con el archivo lleno al
  # lado.
  ruta_texto <- ruta_salidas("intermedios", "texto", paste0(slug, ".txt"))
  texto <- if (fs::file_exists(ruta_texto)) {
    paste(readLines(ruta_texto, warn = FALSE), collapse = "\n")
  } else ""

  cabecera <- if (is.null(meta$cabecera)) character(0) else as.character(meta$cabecera)
  curado <- if (!is.null(CURADURIA[[slug]])) CURADURIA[[slug]] else list()

  titulo <- extraer_titulo(cabecera)
  anio   <- extraer_anio(cabecera)
  temas  <- if (nzchar(texto)) asignar_temas(texto) else character(0)

  # El estado del texto lo declara el equipo cuando hay curaduria y el pipeline
  # cuando no. Asi 'ocr_revisado' solo puede llegar de una persona.
  origen_texto <- if (!is.null(curado$origen_texto)) curado$origen_texto else meta$origen_texto
  if (!origen_texto %in% ORIGENES_TEXTO) {
    stop(sprintf("Slug '%s': origen_texto '%s' fuera del dominio declarado (%s).",
                 slug, origen_texto, paste(ORIGENES_TEXTO, collapse = ", ")))
  }
  es_ocr <- origen_texto %in% c("ocr_pendiente_revision", "ocr_revisado")

  arts <- if (!nzchar(texto)) list() else if (es_ocr) segmentar_ocr(texto) else segmentar(texto)

  # La curaduria se SUPERPONE al dato derivado y, al hacerlo, retira la marca de
  # revision del campo que resuelve. El campo `fuente_*` viaja al JSON: un
  # metadato curado sin procedencia visible es indistinguible de uno inventado.
  if (!is.null(curado$anio))   anio   <- curado$anio
  if (!is.null(curado$titulo)) titulo <- curado$titulo

  revisar <- character(0)
  if (is.null(titulo)) revisar <- c(revisar, "titulo")
  if (is.null(anio))   revisar <- c(revisar, "anio")
  if (origen_texto == "sin_texto") revisar <- c(revisar, "texto")
  if (origen_texto == "ocr_pendiente_revision") revisar <- c(revisar, "texto_ocr")
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
    # I() marca estos dos como arreglos JSON pase lo que pase. Sin el,
    # auto_unbox = TRUE convierte un vector de largo 1 en un escalar, de modo que
    # `tema` era una lista en unas normas y un string suelto en otras, y cualquier
    # consumidor que iterara sobre el campo fallaba justo en las normas de un solo
    # tema. Lo detecto el recuento con jq del cierre.
    tema = I(temas),
    fuente_anio = if (!is.null(curado$fuente_anio)) curado$fuente_anio else NULL,
    # Anios adicionales legitimos de la norma, para los textos refundidos: el
    # catalogo la ubica en uno solo, pero una cita a cualquiera de ellos apunta a
    # este mismo documento.
    anios_alternativos = I(if (!is.null(curado$anios_alternativos))
      unlist(curado$anios_alternativos) else integer(0)),
    # Vigencia. Por defecto `vigente`; la sustitucion la declara la curaduria en
    # la norma SUSTITUIDA y una sola vez. El vinculo inverso ("sustituye a") lo
    # deriva el pipeline mas abajo, para que las dos direcciones no puedan
    # divergir: si cada norma declarara su mitad, bastaria con que alguien
    # editara una para que el sitio afirmara dos cosas incompatibles.
    vigencia = vigencia_de(slug, curado),
    paginas = meta$paginas,
    pdf = paste0(slug, ".pdf"),
    sin_capa_texto = isTRUE(meta$sin_capa_texto),
    # Estado del texto publicado. Gobierna como lo presenta el sitio: solo
    # capa_texto_pdf y ocr_revisado se muestran como cita textual.
    origen_texto = origen_texto,
    fuente_origen_texto = if (!is.null(curado$fuente_origen_texto)) curado$fuente_origen_texto else NULL,
    notas_ficha = I(if (!is.null(curado$notas_ficha)) unlist(curado$notas_ficha) else character(0)),
    aviso_vigencia = if (!is.null(curado$aviso_vigencia)) curado$aviso_vigencia else NULL,
    marca_revisar = I(revisar),
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
normas <- derivar_sustituciones(unname(lapply(manifiesto, construir_norma)))

for (n in normas) {
  escribir_atomico(n, ruta_normas(paste0(n$slug, ".json")),
                   function(o, p) jsonlite::write_json(o, p, auto_unbox = TRUE,
                                                       pretty = TRUE, null = "null"))
  log_msg(sprintf("%-46s %-9s %-22s %s  articulos=%-4d segmentos=%-4d temas=%d %s",
                  n$slug, n$tipo, n$origen_texto,
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

# ---- Reporte de curacion pendiente -------------------------------------------
# Solo sobre lo que ENTRO o CAMBIO en esta corrida. Repetir en cada corrida las
# marcas de los 25 documentos convierte el reporte en ruido que nadie lee; lo que
# el equipo necesita saber al incorporar una norma es que le falta A ESA.
estado_corpus <- {
  ruta <- ruta_datos("manifiesto_corpus.json")
  if (fs::file_exists(ruta)) {
    m <- jsonlite::fromJSON(ruta, simplifyDataFrame = FALSE)$documentos
    setNames(vapply(m, function(d) d$estado, character(1)),
             vapply(m, function(d) d$slug, character(1)))
  } else character(0)
}
entraron <- Filter(function(n)
  identical(unname(estado_corpus[n$slug]), "nuevo") ||
  identical(unname(estado_corpus[n$slug]), "modificado"), normas)

if (length(entraron) > 0L) {
  cat("\n", strrep("-", 76), "\n", sep = "")
  cat(sprintf("CURACION PENDIENTE — %d documento(s) entraron o cambiaron\n", length(entraron)))
  cat(strrep("-", 76), "\n", sep = "")
  for (n in entraron) {
    pendientes <- character(0)
    if (length(n$marca_revisar) > 0L) {
      pendientes <- c(pendientes, sprintf("metadatos: %s", paste(n$marca_revisar, collapse = ", ")))
    }
    if (length(n$tema) == 0L) pendientes <- c(pendientes, "tema: sin asignar")
    if (is.null(n$aviso_vigencia) && identical(n$vigencia$estado, "sustituido"))
      pendientes <- c(pendientes, "vigencia: sustituido sin aviso")
    cat(sprintf("  %-46s %s\n", n$slug,
                if (length(pendientes) == 0L) "sin pendientes"
                else paste(pendientes, collapse = " | ")))
  }
  cat(sprintf("  Se curan en %s\n",
              fs::path_rel(ruta_insumos("curaduria", "metadatos_curados.json"), here::here())))
  cat(strrep("-", 76), "\n\n", sep = "")
}

n_sustituidas <- sum(vapply(normas, function(n)
  identical(n$vigencia$estado, "sustituido"), logical(1)))
log_msg(sprintf("Vigencia: %d vigentes, %d sustituidas.",
                length(normas) - n_sustituidas, n_sustituidas), origen = ORIGEN)

log_msg(sprintf("Segmentacion terminada: %d normas, %d articulos, %d documentos con marca de revision.",
                length(normas),
                sum(vapply(normas, function(n) n$n_articulos, integer(1))),
                sum(vapply(normas, function(n) length(n$marca_revisar) > 0L, logical(1)))),
        origen = ORIGEN)
