# =============================================================================
# 33_generar_paginas.R
# -----------------------------------------------------------------------------
# Proposito: JSON -> .qmd en 40_salidas/sitio_src/. Genera una pagina por norma
#            (ficha + articulos anclados), la home con el buscador, tres indices
#            (tipo, tema, anio) y la pagina institucional. Copia ademas
#            _quarto.yml y las plantillas de 33_plantillas_sitio/.
#
# LOS .qmd NO SE EDITAN A MANO. Este script los reescribe enteros en cada
# corrida y 40_salidas/sitio_src/ esta en .gitignore. Editar uno es trabajo que
# el siguiente run_all() borra sin avisar.
#
# El texto legal se emite como HTML CRUDO, no como Markdown. En Markdown un "*"
# de nota, un "_" o un "#" del original se interpretan como marcado y el
# renderizador se los come: el articulo publicado dejaria de ser identico al del
# PDF. Escapar las entidades que HTML exige es lo minimo que preserva el texto
# literal, y no es "corregir" el original: es impedir que el renderizador lo
# altere (invariante de fidelidad normativa).
# =============================================================================

source(here::here("10_utils", "10_utils.R"))
instalar_si_falta(c("jsonlite", "fs", "here"))
source(here::here("10_utils", "10_configuracion.R"))

ORIGEN <- "33_generar_paginas"

# ---- Utilidades de presentacion ---------------------------------------------
# Los numeros de ley chilenos se citan con separador de miles ("ley 20.536") y
# los de decreto no ("decreto 24"). El umbral de 1000 reproduce esa convencion
# sin una tabla de excepciones.
formatear_numero <- function(numero) {
  n <- suppressWarnings(as.integer(numero))
  if (is.na(n) || n < 1000L) return(numero)
  # decimal.mark explicito: sin el, formatC avisa en cada llamada de que el
  # separador de miles y el de decimales coinciden. La coma ademas es el separador
  # decimal correcto en espanol.
  formatC(n, big.mark = ".", decimal.mark = ",", format = "d")
}

nombre_corto <- function(n) paste(n$tipo_etiqueta, formatear_numero(n$numero))

# YAML acepta JSON como subconjunto, asi que serializar con toJSON produce un
# escalar siempre valido: titulos con comillas, dos puntos o corchetes no rompen
# el front matter. Escribirlos a mano con paste0('"', x, '"') si lo rompe.
escalar_yaml <- function(x) as.character(jsonlite::toJSON(x, auto_unbox = TRUE))

# Convierte el texto de un segmento en parrafos HTML, uno por bloque.
parrafos_html <- function(texto) {
  bloques <- strsplit(texto, "\n\n", fixed = TRUE)[[1]]
  bloques <- bloques[nzchar(trimws(bloques))]
  paste0("<p>", escapar_html(trimws(bloques)), "</p>", collapse = "\n")
}

# ---- Pagina de una norma ----------------------------------------------------
pagina_norma <- function(n) {
  corto <- nombre_corto(n)
  titulo_mostrado <- if (is.null(n$titulo)) corto else paste0(corto, ": ", n$titulo)
  es_ocr <- n$origen_texto %in% c("ocr_pendiente_revision", "ocr_revisado")
  ocr_sin_revisar <- identical(n$origen_texto, "ocr_pendiente_revision")

  # Filtros de Pagefind. Salen del mismo dato que alimenta los indices
  # navegables, no de una lista paralela.
  #
  # UN ELEMENTO POR FILTRO, y no todos en un atributo separados por coma: medido
  # el 2026-08-25, Pagefind lee el atributo entero como el VALOR del primer
  # nombre de filtro, asi que la faceta "tipo" acababa teniendo veinte valores
  # del tipo "Ley, anio:2011, fuente:normativa, tema:..." y las facetas anio,
  # fuente y tema no existian.
  #
  # Los span van vacios a proposito: el valor viaja en el atributo, de modo que
  # el nombre de la faceta no entra al corpus de busqueda. Con texto visible,
  # buscar "normativa" devolveria las 24 normas.
  filtros <- c(
    paste0("tipo:", n$tipo_etiqueta),
    paste0("anio:", if (is.null(n$anio)) "sin año determinado" else as.character(n$anio)),
    paste0("fuente:", n$tipo_fuente),
    paste0("texto:", if (ocr_sin_revisar) "OCR sin revisar" else "verificado")
  )
  if (length(n$tema) > 0L) filtros <- c(filtros, paste0("tema:", n$tema))
  spans_filtro <- c(
    "```{=html}",
    sprintf('<span data-pagefind-filter="%s"></span>', escapar_html(filtros)),
    "```",
    ""
  )

  cab <- c(
    "---",
    paste("title:", escalar_yaml(corto)),
    paste("subtitle:", escalar_yaml(if (is.null(n$titulo)) "Título pendiente de revisión" else n$titulo)),
    paste("pagetitle:", escalar_yaml(titulo_mostrado)),
    "toc: true",
    paste("toc-title:", escalar_yaml(if (es_ocr) "Páginas" else "Articulado")),
    "---",
    ""
  )

  # Banda de vigencia. Va ARRIBA DE TODO, antes incluso de la ficha: si un
  # documento fue sustituido, esa es la primera cosa que quien lo consulta
  # necesita saber, y saberla despues de haber leido el articulado es tarde.
  banda <- if (!is.null(n$aviso_vigencia)) c(
    "```{=html}",
    '<div class="aviso aviso-fuerte" role="alert">',
    sprintf("<p><strong>Vigencia.</strong> %s</p>", escapar_html(n$aviso_vigencia)),
    "</div>",
    "```",
    ""
  ) else character(0)

  # Aviso de texto reconocido, JUNTO AL ENLACE AL PDF, tal como lo fijo el equipo
  # el 2026-08-25. La condicion completa es que el texto reconocido no se publica
  # como cita textual hasta que una persona lo revise: de ahi que la ficha lo
  # declare aqui y el cuerpo lo repita donde se lee.
  linea_pdf <- if (ocr_sin_revisar) {
    sprintf('<dt>Documento oficial</dt><dd><a href="%s">%s</a> (PDF) <span class="marca-ocr">%s</span></dd>',
            paste0("pdf/", n$pdf), escapar_html(n$pdf), escapar_html(AVISO_OCR_PENDIENTE))
  } else {
    sprintf('<dt>Documento oficial</dt><dd><a href="%s">%s</a> (PDF)</dd>',
            paste0("pdf/", n$pdf), escapar_html(n$pdf))
  }

  # El anio curado viaja con su procedencia a la vista. Un metadato aportado por
  # una persona sin decir de donde salio es indistinguible de uno inventado.
  linea_anio <- if (is.null(n$anio)) {
    "<dt>Año de publicación</dt><dd><em>No consta en el documento. Pendiente de revisión del equipo.</em></dd>"
  } else if (!is.null(n$fuente_anio)) {
    sprintf("<dt>Año de publicación</dt><dd>%d <span class=\"procedencia\">(dato curado — %s)</span></dd>",
            n$anio, escapar_html(n$fuente_anio))
  } else {
    sprintf("<dt>Año de publicación</dt><dd>%d</dd>", n$anio)
  }

  linea_extension <- if (es_ocr) {
    sprintf("<dt>Extensión</dt><dd>%d páginas · transcripción automática</dd>", n$paginas)
  } else {
    sprintf("<dt>Extensión</dt><dd>%d páginas · %d artículos</dd>", n$paginas, n$n_articulos)
  }

  ficha <- c(
    "```{=html}",
    '<div class="ficha-norma">',
    sprintf('<p><span class="badge-fuente badge-%s">%s</span><span class="badge-fuente badge-tipo">%s</span>%s</p>',
            n$tipo_fuente, n$tipo_fuente, escapar_html(n$tipo_etiqueta),
            if (ocr_sin_revisar) '<span class="badge-fuente badge-ocr">OCR sin revisar</span>' else ""),
    "<dl>",
    sprintf("<dt>Título oficial</dt><dd>%s</dd>",
            if (is.null(n$titulo)) "<em>No fue posible extraerlo del documento. Pendiente de revisión del equipo.</em>"
            else escapar_html(n$titulo)),
    linea_anio,
    linea_extension,
    sprintf("<dt>Temas</dt><dd>%s</dd>",
            if (length(n$tema) == 0L) "<em>sin tema asignado</em>"
            else paste0('<span class="badge-fuente badge-tema">', escapar_html(n$tema), "</span>", collapse = " ")),
    linea_pdf,
    if (length(n$notas_ficha) > 0L)
      sprintf("<dt>Notas</dt><dd>%s</dd>",
              paste0(escapar_html(n$notas_ficha), collapse = "</dd><dd>")) else NULL,
    "</dl>",
    "</div>",
    "```",
    ""
  )
  ficha <- ficha[!vapply(ficha, is.null, logical(1))]

  abre <- sprintf('::: {data-pagefind-body="true" data-pagefind-meta="norma:%s"}',
                  gsub('"', "", corto))

  # --- Documento sin texto de ninguna clase ---
  if (identical(n$origen_texto, "sin_texto")) {
    cuerpo <- c(
      "```{=html}",
      '<div class="aviso aviso-fuerte">',
      "<p><strong>Este documento no tiene capa de texto ni transcripción disponible.</strong> ",
      "Está disponible completo en el enlace al PDF de la ficha.</p>",
      "</div>",
      "```",
      ""
    )
    return(paste(c(cab, banda, ficha, abre, "", spans_filtro, cuerpo, ":::", ""),
                 collapse = "\n"))
  }

  # --- Transcripcion automatica ---
  if (es_ocr) {
    encabezado_ocr <- if (ocr_sin_revisar) c(
      "```{=html}",
      '<div class="aviso aviso-ocr" role="note">',
      sprintf("<p><strong>%s.</strong></p>", escapar_html(AVISO_OCR_PENDIENTE)),
      "<p>Lo que sigue es una transcripción hecha por reconocimiento óptico de ",
      "caracteres sobre un documento escaneado. <strong>No es una cita textual</strong> ",
      "y todavía no ha sido revisada por el equipo de convivencia: puede contener ",
      "errores de lectura. Se publica para poder encontrar el documento y ubicarse ",
      "dentro de él; para citar, use el PDF.</p>",
      "</div>",
      "```",
      ""
    ) else c(
      "```{=html}",
      '<div class="aviso" role="note">',
      "<p>Transcripción obtenida por reconocimiento óptico y <strong>revisada por el ",
      "equipo de convivencia</strong>. La fuente oficial sigue siendo el PDF.</p>",
      "</div>",
      "```",
      ""
    )

    # Los saltos de linea se conservan tal cual (pre-wrap en la hoja de estilo).
    # No se refluye: a un texto sin revisar no se le adivina ademas la estructura
    # de parrafos, y revisarlo es mucho mas facil si lo que se ve en el sitio es
    # exactamente lo que hay en el archivo que se corrige.
    secciones <- unlist(lapply(n$articulos, function(a) {
      c(sprintf("## %s {#%s}", a$etiqueta, a$id),
        "",
        "```{=html}",
        sprintf('<div class="transcripcion-ocr" id="cuerpo-%s">', a$id),
        paste0("<pre>", escapar_html(a$texto), "</pre>"),
        "</div>",
        "```",
        "")
    }))

    return(paste(c(cab, banda, ficha, abre, "", spans_filtro, encabezado_ocr,
                   secciones, ":::", ""),
                 collapse = "\n"))
  }

  # --- Articulado verificado ---
  # Contenedor indexable. Pagefind toma como registro el contenido marcado con
  # data-pagefind-body y genera un sub-resultado por cada encabezado con id que
  # encuentre dentro: por eso cada articulo lleva su "## etiqueta {#id}" y por eso
  # el ancla del HTML es exactamente el id que escribio el segmentador.
  secciones <- unlist(lapply(n$articulos, function(a) {
    c(sprintf("## %s {#%s}", a$etiqueta, a$id),
      "",
      "```{=html}",
      sprintf('<div class="articulo texto-legal" id="cuerpo-%s">', a$id),
      parrafos_html(a$texto),
      "</div>",
      "```",
      "")
  }))

  paste(c(cab, banda, ficha, abre, "", spans_filtro, secciones, ":::", ""),
        collapse = "\n")
}

# ---- Home -------------------------------------------------------------------
pagina_home <- function(cat) {
  n_normas <- length(cat$normas)
  n_arts   <- cat$n_articulos
  n_ocr    <- sum(vapply(cat$normas, function(x)
    identical(x$origen_texto, "ocr_pendiente_revision"), logical(1)))

  ejemplos <- c("revisión de mochilas", "cancelación de matrícula", "uso de celulares",
                "encargado de convivencia", "expulsión", "identidad de género")

  c("---",
    'title: "Normativa de convivencia educativa"',
    'subtitle: "Busque por artículo, no por documento."',
    "toc: false",
    "---",
    "",
    "Esta es la normativa chilena que regula la convivencia escolar, reunida y",
    "buscable **artículo por artículo**. Está pensada para resolver rápido preguntas",
    "concretas de un equipo de convivencia, con el texto legal literal a la vista y",
    "un enlace al documento oficial en cada ficha.",
    "",
    "Escriba en el buscador de arriba. Por ejemplo:",
    "",
    paste0("- ", ejemplos),
    "",
    "```{=html}",
    '<div class="ficha-norma">',
    sprintf("<p><strong>%d normas · %d artículos indexados · %d documentos con transcripción automática en revisión.</strong></p>",
            n_normas, n_arts, n_ocr),
    "<p>Todo el contenido proviene de fuentes oficiales y se reproduce sin editar.</p>",
    "</div>",
    "```",
    "",
    "## Navegar el corpus",
    "",
    "- [Por tipo de norma](indice-tipo.qmd) — leyes, decretos, circulares, resoluciones y dictámenes.",
    "- [Por tema](indice-tema.qmd) — violencia escolar, expulsiones, inclusión, celulares y otros.",
    "- [Por año](indice-anio.qmd) — de la norma más reciente a la más antigua.",
    "",
    "```{=html}",
    '<div class="aviso">',
    "<p><strong>Este sitio no es asesoría jurídica ni una fuente oficial.</strong> ",
    "Reproduce el texto publicado, sin resumirlo ni interpretarlo. Ante cualquier ",
    "discrepancia manda el texto del Diario Oficial.</p>",
    "</div>",
    "```",
    "") |> paste(collapse = "\n")
}

# ---- Indices ----------------------------------------------------------------
item_norma <- function(n) {
  corto <- nombre_corto(n)
  sprintf('- [%s](%s.qmd)%s%s',
          corto, n$slug,
          if (is.null(n$titulo)) "" else paste0(" — ", n$titulo),
          if (isTRUE(n$sin_capa_texto)) " *(sin capa de texto)*" else "")
}

pagina_indice <- function(titulo, subtitulo, grupos) {
  cuerpo <- unlist(lapply(names(grupos), function(g) {
    c(paste("##", g), "", vapply(grupos[[g]], item_norma, character(1)), "")
  }))
  c("---", paste("title:", escalar_yaml(titulo)),
    paste("subtitle:", escalar_yaml(subtitulo)),
    "toc: true", "---", "", cuerpo) |> paste(collapse = "\n")
}

# ---- Pagina institucional ---------------------------------------------------
pagina_acerca <- function(cat) {
  n_ocr <- Filter(function(x)
    identical(x$origen_texto, "ocr_pendiente_revision"), cat$normas)
  c("---",
    'title: "Acerca de este sitio"',
    "toc: true",
    "---",
    "",
    "## Qué es",
    "",
    "Una biblioteca pública y buscable de la normativa chilena de convivencia escolar,",
    "mantenida por el equipo de convivencia del Servicio Local de Educación Pública",
    "Costa Central. El corpus se indexa a nivel de **artículo**, porque la unidad que",
    "un equipo de convivencia necesita recuperar es \"ley X, artículo Y\", no un PDF de",
    "cincuenta páginas.",
    "",
    "## De dónde sale el texto",
    "",
    "De los documentos oficiales publicados por la Biblioteca del Congreso Nacional, el",
    "Ministerio de Educación y la Superintendencia de Educación. Cada ficha enlaza el",
    "PDF exacto del que se extrajo el texto.",
    "",
    "## Qué se le hace al texto y qué no",
    "",
    "**No se hace:** resumir, parafrasear, interpretar, corregir erratas, actualizar",
    "redacciones ni reordenar. Lo que se lee aquí es lo que dice el documento, incluidas",
    "sus erratas de origen.",
    "",
    "**Sí se hace**, y solo esto: quitar los encabezados y pies de página que el PDF",
    "repite en cada hoja, reunir las palabras que el PDF corta con guion al final de",
    "línea, y reunir en un párrafo las líneas que el PDF partió por ancho de columna.",
    "Son artefactos de maquetación, no texto de la norma.",
    "",
    "## Documentos escaneados y transcripción automática",
    "",
    sprintf("%d de los documentos del corpus son escaneos de imagen: el PDF no contiene",
            length(n_ocr)),
    "texto seleccionable, solo la fotografía de las páginas. De ellos se obtuvo una",
    "**transcripción automática** por reconocimiento óptico de caracteres:",
    "",
    vapply(n_ocr, item_norma, character(1)),
    "",
    "Esa transcripción **no es una cita textual y no ha sido revisada**. Se publica",
    "señalizada como tal, con el aviso a la vista tanto en la ficha como sobre el texto,",
    "para que el documento se pueda encontrar y recorrer; para citar, manda el PDF.",
    "",
    "El estado de cada documento se declara en el campo `origen_texto` de sus datos:",
    "",
    "- `capa_texto_pdf` — el PDF trae texto seleccionable. Es cita textual.",
    "- `ocr_pendiente_revision` — transcripción automática sin revisar. No es cita textual.",
    "- `ocr_revisado` — transcripción revisada y validada por el equipo de convivencia.",
    "",
    "El paso de `ocr_pendiente_revision` a `ocr_revisado` no lo hace ningún programa: lo",
    "hace una persona del equipo, leyendo la transcripción página por página contra el",
    "PDF y editando el archivo de curaduría. Mientras eso no ocurra, el aviso queda.",
    "",
    "## Metadatos pendientes de revisión",
    "",
    "Cuando el título o el año de una norma no se pueden derivar del documento sin",
    "adivinar, el sitio lo declara en la ficha en vez de rellenarlo con un valor",
    "plausible. Un año inventado en una biblioteca normativa institucional es peor que",
    "un campo vacío.",
    "",
    "## Cómo se construye",
    "",
    "Un pipeline en R lee los PDF, extrae y limpia el texto, lo segmenta por artículo y",
    "escribe un JSON por norma. De ese JSON salen estas páginas y el índice de búsqueda.",
    "Cada cambio en el repositorio dispara una reconstrucción completa: lo que se ve",
    "aquí siempre proviene de una corrida reproducible, nunca de una edición manual.",
    "",
    "El código es público: <https://github.com/tomgc/slep_normativa_convivencia>.",
    "",
    "```{=html}",
    '<div class="aviso">',
    "<p><strong>Advertencia.</strong> Este sitio no constituye asesoría jurídica ni es ",
    "una fuente oficial. Ante cualquier discrepancia manda el texto publicado en el ",
    "Diario Oficial.</p>",
    "</div>",
    "```",
    "") |> paste(collapse = "\n")
}

# ---- Corrida ----------------------------------------------------------------
cat_json <- jsonlite::fromJSON(ruta_datos("catalogo.json"), simplifyDataFrame = FALSE)
normas <- lapply(cat_json$normas, function(x)
  jsonlite::fromJSON(ruta_normas(paste0(x$slug, ".json")), simplifyDataFrame = FALSE))

destino <- ruta_sitio_src()
if (fs::dir_exists(destino)) fs::dir_delete(destino)
fs::dir_create(destino)

# Los PDF viajan al sitio: la ficha de cada norma enlaza el documento oficial y
# ese enlace tiene que resolver en GitHub Pages, no solo en el repositorio.
fs::dir_create(file.path(destino, "pdf"))
fs::file_copy(fs::dir_ls(ruta_normativa(), glob = "*.pdf"), file.path(destino, "pdf"))

fs::file_copy(here::here("_quarto.yml"), file.path(destino, "_quarto.yml"))
fs::file_copy(
  fs::dir_ls(here::here("30_procesamiento", "33_plantillas_sitio")),
  destino
)

for (n in normas) {
  writeLines(pagina_norma(n), file.path(destino, paste0(n$slug, ".qmd")))
}
writeLines(pagina_home(cat_json), file.path(destino, "index.qmd"))
writeLines(pagina_acerca(cat_json), file.path(destino, "acerca.qmd"))

# Indice por tipo, en el orden de jerarquia normativa que declara ORDEN_TIPOS.
por_tipo <- split(normas, vapply(normas, function(n) n$tipo, character(1)))
por_tipo <- por_tipo[intersect(ORDEN_TIPOS, names(por_tipo))]
names(por_tipo) <- unname(TIPOS_NORMA[names(por_tipo)])
writeLines(
  pagina_indice("Por tipo de norma",
                "El orden refleja la jerarquía normativa: primero la ley, después el reglamento que la ejecuta y por último la interpretación administrativa.",
                por_tipo),
  file.path(destino, "indice-tipo.qmd")
)

# Indice por anio, del mas reciente al mas antiguo. Las normas sin anio
# determinado NO se ocultan: van en su propio grupo al final, para que el hueco
# sea visible y accionable en vez de invisible.
anios <- vapply(normas, function(n) if (is.null(n$anio)) NA_integer_ else n$anio, integer(1))
con_anio <- normas[!is.na(anios)]
orden <- order(-anios[!is.na(anios)])
por_anio <- split(con_anio[orden], as.character(anios[!is.na(anios)][orden]))
por_anio <- por_anio[order(as.integer(names(por_anio)), decreasing = TRUE)]
if (any(is.na(anios))) por_anio[["Sin año determinado"]] <- normas[is.na(anios)]
writeLines(
  pagina_indice("Por año", "Año de publicación en el Diario Oficial.", por_anio),
  file.path(destino, "indice-anio.qmd")
)

# Indice por tema. Una norma puede aparecer en varios temas: la clasificacion es
# por coincidencia de palabras clave del diccionario cerrado de la configuracion,
# no una taxonomia excluyente.
temas <- sort(unique(unlist(lapply(normas, function(n) n$tema))))
por_tema <- setNames(
  lapply(temas, function(t) Filter(function(n) t %in% n$tema, normas)),
  temas
)
sin_tema <- Filter(function(n) length(n$tema) == 0L, normas)
if (length(sin_tema) > 0L) por_tema[["Sin tema asignado"]] <- sin_tema
writeLines(
  pagina_indice("Por tema",
                "Los temas se asignan por coincidencia de palabras clave sobre el texto extraído, con un diccionario declarado en el código. Una norma puede estar en varios temas.",
                por_tema),
  file.path(destino, "indice-tema.qmd")
)

n_qmd <- length(fs::dir_ls(destino, glob = "*.qmd"))
log_msg(sprintf("Generadas %d páginas .qmd (%d normas + home + acerca + 3 índices) en %s.",
                n_qmd, length(normas), destino),
        origen = ORIGEN)
stopifnot(n_qmd == length(normas) + 5L)
