# =============================================================================
# 34_generar_paginas.R
# -----------------------------------------------------------------------------
# Proposito: JSON -> .qmd en 40_salidas/sitio_src/. Genera una pagina por norma
#            (ficha + articulos anclados), la home con el buscador, tres indices
#            (tipo, tema, anio) y la pagina institucional. Copia ademas
#            _quarto.yml y las plantillas de 34_plantillas_sitio/.
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
instalar_si_falta(c("jsonlite", "fs", "here", "stringi", "yaml"))
source(here::here("10_utils", "10_configuracion.R"))

ORIGEN <- "34_generar_paginas"

# ---- Utilidades de presentacion ---------------------------------------------
# nombre_corto(), formatear_numero() y ROL_GRUPO viven en 10_utils/10_utils.R:
# los comparte con 00_generar_borradores.R, que rotula las mismas normas.

# Diccionario slug -> nombre corto, para poder rotular un enlace a otra norma sin
# tener que cargar su JSON entero cada vez. Se rellena en la corrida.
NOMBRES <- new.env(parent = emptyenv())
nombre_de <- function(slug) {
  if (!is.null(NOMBRES[[slug]])) NOMBRES[[slug]] else slug
}
enlace_norma <- function(slug) {
  sprintf('<a href="%s.html">%s</a>', slug, escapar_html(nombre_de(slug)))
}

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

# ---- Bloque de relacionados --------------------------------------------------
# Va DESPUES del articulado y FUERA del contenedor indexado por Pagefind. Fuera a
# proposito: si las explicaciones entraran al indice, buscar "expulsion" empezaria
# a devolver paginas cuyo unico vinculo con la palabra es la frase "Comparten
# temas: medidas disciplinarias", y el buscador dejaria de responder sobre texto
# legal para responder sobre sus propios metadatos.
#
# Orden: sustitucion > mismo acto > remision > tema. Es orden de fuerza juridica,
# no de similitud: que una norma haya sido sustituida cambia cual hay que
# aplicar; que otro archivo sea el mismo acto cambia que hay que leer para tener
# el acto completo; que comparta temas solo sugiere donde seguir leyendo.
TOPE_RELACIONES_TEMA <- 5L

RELACIONES <- NULL

bloque_relacionados <- function(n) {
  propias <- Filter(function(r) identical(r$desde, n$slug), RELACIONES)
  if (length(propias) == 0L) return(character(0))

  por <- function(t) Filter(function(r) identical(r$tipo, t), propias)
  sus <- por("sustitucion")
  gru <- por("grupo_acto")
  rem <- por("remision")
  tem <- por("tema")
  tem <- tem[order(-vapply(tem, function(r) r$n_temas, integer(1)),
                   vapply(tem, function(r) r$hacia, character(1)))]
  omitidas <- max(0L, length(tem) - TOPE_RELACIONES_TEMA)
  tem <- utils::head(tem, TOPE_RELACIONES_TEMA)

  # La nota solo la traen las remisiones colapsadas hacia un grupo de acto: el
  # enlace apunta a la resolucion pero representa al acto entero, y sin decirlo
  # se lee como si el cuerpo aprobado no estuviera incluido.
  item <- function(r, clase) sprintf(
    '<li class="rel rel-%s"><span class="badge-fuente badge-rel-%s">%s</span> %s <span class="rel-por">%s</span></li>',
    clase, clase,
    switch(clase, sustitucion = "vigencia", grupo_acto = "mismo acto",
           remision = "remisión", tema = "tema"),
    enlace_norma(r$hacia),
    escapar_html(paste0(r$explicacion,
                        if (!is.null(r$nota)) paste0(" El enlace ", r$nota, ".") else "")))

  c("",
    "## Normas relacionadas {#relacionadas}",
    "",
    "```{=html}",
    '<ul class="lista-relaciones">',
    vapply(sus, item, character(1), clase = "sustitucion"),
    vapply(gru, item, character(1), clase = "grupo_acto"),
    vapply(rem, item, character(1), clase = "remision"),
    vapply(tem, item, character(1), clase = "tema"),
    "</ul>",
    # Los topes se declaran, no se aplican en silencio: si el lector no sabe que
    # la lista esta recortada, la lee como si fuera completa.
    if (omitidas > 0L)
      sprintf('<p class="procedencia">Se muestran los %d vínculos temáticos más fuertes; hay %d más con menos temas en común.</p>',
              TOPE_RELACIONES_TEMA, omitidas) else NULL,
    '<p class="procedencia">Los vínculos se derivan de datos del pipeline (campo de vigencia, declaración de acto administrativo común, cita del número de la norma en el texto, temas compartidos), no de una lectura interpretativa.</p>',
    "```",
    "")
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
    paste0("texto:", if (ocr_sin_revisar) "OCR sin revisar" else "verificado"),
    paste0("vigencia:", if (identical(n$vigencia$estado, "sustituido")) "sustituida" else "vigente")
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
  # El texto lo compone el mecanismo desde el campo `vigencia`, no una nota
  # escrita a mano por norma: asi enlaza siempre a la sustituta y no puede quedar
  # desincronizado del dato.
  banda <- if (identical(n$vigencia$estado, "sustituido")) c(
    "```{=html}",
    '<div class="aviso aviso-fuerte" role="alert">',
    sprintf("<p><strong>Documento sustituido.</strong> Esta norma fue sustituida por %s. Se mantiene publicada como referencia histórica.</p>",
            enlace_norma(n$vigencia$sustituido_por)),
    sprintf('<p class="procedencia">Consta en: %s</p>', escapar_html(n$vigencia$fuente)),
    "</div>",
    "```",
    ""
  ) else if (length(n$vigencia$sustituye_a) > 0L) c(
    "```{=html}",
    '<div class="aviso" role="note">',
    sprintf("<p><strong>Sustituye a %s.</strong> Aquella norma se mantiene publicada como referencia histórica.</p>",
            paste(vapply(n$vigencia$sustituye_a, enlace_norma, character(1)),
                  collapse = " y ")),
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
  #
  # Acceso con [[ ]] y no con $: desde que la norma publica
  # `fuente_anios_alternativos`, `fuente_anio` es prefijo de otra clave del mismo
  # objeto, y `anio` lo es de `anios_alternativos`. Hoy el escritor emite las dos
  # claves siempre, asi que $ acertaria; el acceso exacto no depende de eso.
  linea_anio <- if (is.null(n[["anio"]])) {
    "<dt>Año de publicación</dt><dd><em>No consta en el documento. Pendiente de revisión del equipo.</em></dd>"
  } else if (!is.null(n[["fuente_anio"]])) {
    sprintf("<dt>Año de publicación</dt><dd>%d <span class=\"procedencia\">(dato curado — %s)</span></dd>",
            n[["anio"]], escapar_html(n[["fuente_anio"]]))
  } else {
    sprintf("<dt>Año de publicación</dt><dd>%d</dd>", n[["anio"]])
  }

  # Anios de cita reconocidos. Solo aparece cuando la curaduria declaro alguno:
  # es el dato que explica por que una cita "de 1996" a un documento que el
  # catalogo ubica en 1997 se acepta como remision y no se descarta.
  linea_anios_cita <- if (length(n[["anios_alternativos"]]) == 0L) NULL else {
    todos <- unique(c(n[["anio"]], unlist(n[["anios_alternativos"]])))
    lista <- paste(todos[!is.na(todos)], collapse = ", ")
    if (!is.null(n[["fuente_anios_alternativos"]])) {
      sprintf("<dt>Años de cita reconocidos</dt><dd>%s <span class=\"procedencia\">(dato curado — %s)</span></dd>",
              lista, escapar_html(n[["fuente_anios_alternativos"]]))
    } else {
      sprintf("<dt>Años de cita reconocidos</dt><dd>%s</dd>", lista)
    }
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
            paste0(
              if (ocr_sin_revisar) '<span class="badge-fuente badge-ocr">OCR sin revisar</span>' else "",
              if (identical(n$vigencia$estado, "sustituido"))
                '<span class="badge-fuente badge-sustituida">sustituida</span>' else "")),
    "<dl>",
    sprintf("<dt>Título oficial</dt><dd>%s</dd>",
            if (is.null(n$titulo)) "<em>No fue posible extraerlo del documento. Pendiente de revisión del equipo.</em>"
            else escapar_html(n$titulo)),
    linea_anio,
    linea_anios_cita,
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
    return(paste(c(cab, banda, ficha, abre, "", spans_filtro, cuerpo, ":::",
                   bloque_relacionados(n), ""),
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
                   secciones, ":::", bloque_relacionados(n), ""),
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

  paste(c(cab, banda, ficha, abre, "", spans_filtro, secciones, ":::",
          bloque_relacionados(n), ""),
        collapse = "\n")
}

# ---- Piezas interpretativas --------------------------------------------------
# Fichas, preguntas frecuentes y glosario son INTERPRETACION institucional, no
# cita textual. El invariante del proyecto es que no se publican sin firma: el
# sitio muestra una pieza solo si declara `estado: validada` Y trae
# `validado_por` con un nombre. Las dos condiciones, no una.
#
# Y la compuerta ABORTA, no filtra en silencio: una pieza marcada como validada
# sin firma es un error de curaduria que alguien tiene que ver, no un archivo que
# convenga saltarse calladamente.
#
# El front matter lo escribe A MANO el equipo de convivencia, asi que la compuerta
# se defiende de lo que una PERSONA escribe, no de lo que un script emite. Tres
# familias medidas en el encargo v4 y cerradas aqui (v5):
#   - `as.character()` convierte en texto el booleano de YAML: quien escribiera
#     `validado_por: no` (que en YAML 1.1 es el booleano falso) firmaba la pieza
#     como «FALSE» y el sitio lo imprimia. Igual con `true`, `0`, `.nan` y una
#     fecha suelta. Por eso ahora se valida el TIPO del valor y no solo que no
#     este vacio.
#   - `validado_por: []` hacia que la comprobacion valiera NA, y `Filter` descarta
#     los NA de los DOS lados: la pieza ni abortaba ni se publicaba. Desaparecia,
#     que es exactamente lo que 10.5 prohibe.
#   - un front matter que declarara `archivo:` o `cuerpo:` dejaba el objeto con
#     nombres duplicados, y `[[ ]]` devuelve el primero, que es el del YAML: el
#     texto publicado dejaba de ser el cuerpo revisado. No pasa por `$`, asi que
#     el acceso exacto no lo cerraba.
# Todo aborto nombra el archivo y el campo: quien lee el error es una persona del
# equipo de convivencia, no un programador.

# Un escalar de texto, y nada mas. Es la comprobacion que faltaba: `as.character()`
# sobre un booleano, un numero o una fecha de YAML tambien produce texto, y ahi es
# por donde se colaban las firmas que no eran nombres.
escalar_texto <- function(x) is.character(x) && length(x) == 1L && !is.na(x)

# Espacios que una persona pega sin verlos: el duro (U+00A0) que insertan Word y
# el navegador, los de ancho fijo, el de ancho cero y la marca de orden de bytes.
# `trimws()` no toca ninguno, y por eso `estado: "validada<U+00A0>"` abortaba con
# un mensaje que decia que `validada` no vale y que `validada` si.
# Se construyen por PUNTO DE CODIGO y no como literales: un espacio duro escrito
# dentro de este mismo archivo fuente seria exactamente igual de invisible aqui
# que en el front matter que intenta cazar, y nadie podria revisar esta linea.
ESPACIOS_INVISIBLES <- paste0("[", intToUtf8(c(0x00a0, 0x1680, 0x2000:0x200b,
                                               0x202f, 0x205f, 0x3000, 0xfeff)), "]")
normalizar_espacios <- function(x)
  trimws(gsub("\\s+", " ", gsub(ESPACIOS_INVISIBLES, " ", x)))
# Para los campos de dominio cerrado (`tipo`, `estado`): aceptar lo bien
# intencionado, abortar lo desconocido.
normalizar_clave <- function(x) tolower(normalizar_espacios(x))

# Campos que pone el generador y que el front matter no puede declarar.
CLAVES_RESERVADAS <- c("archivo", "cuerpo")
ESTADOS_PIEZA <- c("borrador", "validada")

# Lo que una persona escribe cuando todavia no ha validado nada. Ninguno es un
# nombre, y todos pasarian la regla de "dos palabras" o la de "tiene una letra".
# Una lista por enumeracion NO cierra la familia (`sin asignar`, `no aplica` y
# `por confirmar` siguen pasando): es un colador de lo mas frecuente, no una
# garantia, y asi esta declarado en el log.
NO_SON_FIRMA <- c("null", "na", "n/a", "s/i", "si", "no", "pendiente",
                  "por definir", "x", "xx", "tbd")

leer_pieza <- function(ruta) {
  rel <- fs::path_rel(ruta, here::here())
  aviso_codificacion <- function() {
    stop(sprintf(paste0("La pieza %s no está guardada en UTF-8.\n",
                        "  Vuelve a guardarla con codificación UTF-8 desde tu editor. ",
                        "Suele pasar al escribir\n  un nombre con tilde en un editor de Windows, ",
                        "o al elegir «Unicode» en vez de «UTF-8»."), rel), call. = FALSE)
  }
  # La validez UTF-8 se comprueba ANTES de tocar el texto: un archivo en Latin-1
  # hacia reventar `trimws()` con `input string N is invalid UTF-8` sin decir de
  # que archivo hablaba. El tryCatch cubre ademas UTF-16, donde `rawToChar()`
  # revienta antes por los bytes nulos y vuelca la cadena cruda a la consola.
  ok_utf8 <- tryCatch(validUTF8(rawToChar(readBin(ruta, "raw", file.size(ruta)))),
                      error = function(e) FALSE, warning = function(w) FALSE)
  if (!isTRUE(ok_utf8)) aviso_codificacion()

  lineas <- readLines(ruta, warn = FALSE)
  cortes <- which(trimws(lineas) == "---")
  if (length(cortes) < 2L) {
    stop(sprintf(paste0("La pieza %s no tiene front matter delimitado por '---'.\n",
                        "  El archivo tiene que empezar con una línea '---', los campos ",
                        "(`tipo`, `estado`, `titulo`...)\n  y otra línea '---'."), rel),
         call. = FALSE)
  }
  # El lector de YAML avisa en ingles y sin decir de que archivo habla. El error
  # mas probable al editar a mano es dejar un campo escrito dos veces
  # («Duplicate map key»), y sin el nombre del archivo hay 22 donde buscar.
  fm <- tryCatch(
    yaml::yaml.load(paste(lineas[(cortes[1] + 1L):(cortes[2] - 1L)], collapse = "\n")),
    error = function(e) {
      stop(sprintf(paste0("No se pudo leer el front matter de %s.\n",
                          "  El lector de YAML dice: %s\n",
                          "  Suele ser un campo escrito dos veces, una comilla sin cerrar o una ",
                          "tabulación.\n  Si el lector da un número de línea, cuenta desde el ",
                          "primer '---', no desde el\n  principio del archivo."),
                  rel, conditionMessage(e)), call. = FALSE)
    })
  if (!is.list(fm) || is.null(names(fm)) || any(!nzchar(names(fm)))) {
    stop(sprintf(paste0("El front matter de %s no es una lista de `campo: valor`.\n",
                        "  Cada línea entre los '---' del principio tiene que tener la ",
                        "forma `campo: valor`."), rel), call. = FALSE)
  }
  invadidas <- intersect(names(fm), CLAVES_RESERVADAS)
  if (length(invadidas) > 0L) {
    stop(sprintf(paste0("El front matter de %s declara %s.\n",
                        "  Esos campos los pone el generador. Declararlos en el front matter ",
                        "reemplaza el texto\n  revisado de la pieza por el del YAML, sin aviso. ",
                        "Borra esa línea del front matter."),
                 rel, paste0("`", invadidas, "`", collapse = " y ")), call. = FALSE)
  }
  cuerpo <- if (cortes[2] < length(lineas)) lineas[(cortes[2] + 1L):length(lineas)] else character(0)
  c(fm, list(archivo = ruta, cuerpo = cuerpo))
}

TIPOS_PIEZA <- c(ficha = "Fichas por norma", faq = "Preguntas frecuentes",
                 glosario = "Glosario")

# ---- Reglas de campo ---------------------------------------------------------
# El destinatario de todo lo que sigue es una persona del equipo de convivencia.
# Cada regla devuelve el reparo en su idioma, con un ejemplo VALIDO cuando hace
# falta: un mensaje que ilustra con un valor que publicaria mal es un mensaje que
# ensena a romper la compuerta.

# Un nombre de persona: al menos dos palabras alfabeticas de dos letras o mas.
# Una sola palabra no distingue "Perez" de "pendiente". Limite conocido y
# declarado: rechaza `J. Perez` (inicial y apellido) y los nombres cuyos tokens
# tienen una sola letra, como muchos nombres chinos.
es_nombre_de_persona <- function(x) {
  if (!escalar_texto(x)) return(FALSE)
  v <- normalizar_espacios(x)
  if (!nzchar(v) || normalizar_clave(v) %in% NO_SON_FIRMA) return(FALSE)
  palabras <- strsplit(v, "[^[:alpha:]]+")[[1]]
  sum(nchar(palabras) >= 2L) >= 2L
}

# Fecha ISO real, no una cadena con forma de fecha: `2026-13-45` tiene el formato
# y no existe.
es_fecha_plausible <- function(x) {
  if (!escalar_texto(x)) return(FALSE)
  v <- normalizar_espacios(x)
  grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", v) &&
    !is.na(suppressWarnings(as.Date(v, format = "%Y-%m-%d")))
}

# Las anclas que el sitio puede resolver de verdad: los `id` que 32 escribio en
# los JSON de norma. Se construye desde los datos, nunca desde una lista aparte
# que haya que acordarse de mantener.
anclas_disponibles <- function(normas) {
  z <- lapply(normas, function(n) vapply(n[["articulos"]], function(a) a[["id"]], character(1)))
  names(z) <- vapply(normas, function(n) n[["slug"]], character(1))
  z
}

# El ancla se valida con la forma EXACTA que se publica, no con una aproximacion.
# `sub("[.]html", "", ancla)` aceptaba `norma#art-1` (sin extension),
# `norma.html#a#b` (fragmento partido) y `norma#art-1.html`: las tres se emiten
# TAL CUAL al HTML, donde son 404. Una compuerta que valida una cadena distinta de
# la que publica no valida nada.
#
# Se cruza ademas contra `norma` y `articulo`, que son el TEXTO del enlace: sin
# ese cruce, `{norma: dto_215, articulo: art-1, ancla: "ley_20536.html#art-16-d"}`
# publica una cita que NOMBRA una norma y LLEVA a otra, que es lo contrario de la
# fidelidad que el sitio promete. Medido antes de exigirlo: las 92 entradas de
# `fuentes` del corpus real ya cumplen las tres condiciones.
ancla_resuelve <- function(fuente, disponibles) {
  if (!is.list(fuente)) return(FALSE)
  a <- fuente[["ancla"]]
  if (!escalar_texto(a)) return(FALSE)
  a <- normalizar_espacios(a)
  m <- regmatches(a, regexec("^([^#/]+)[.]html#([^#]+)$", a))[[1]]
  if (length(m) != 3L) return(FALSE)
  ids <- disponibles[[m[2]]]
  if (is.null(ids) || !m[3] %in% ids) return(FALSE)
  identical(m[2], normalizar_espacios(fuente[["norma"]])) &&
    identical(m[3], normalizar_espacios(fuente[["articulo"]]))
}

# Entradas de `fuentes` en forma segura. Sobre un BORRADOR no se exige la forma de
# `fuentes` (a medio llenar es su estado normal), asi que no se puede dar por
# hecho que cada entrada sea una lista: `f[["ancla"]]` sobre un vector atomico
# revienta con `subindice fuera de los limites`, y era el estado de trabajo diario
# del equipo el que paraba el pipeline con un error de R sin nombre de archivo.
fuentes_en_forma <- function(p) {
  fu <- p[["fuentes"]]
  if (!is.list(fu)) return(list())
  Filter(is.list, fu)
}
# Un ancla ilegible se rotula, no se imprime vacia: `- ``` no le dice nada a nadie.
rotulo_ancla <- function(f) {
  a <- f[["ancla"]]
  if (!escalar_texto(a)) return("(el campo `ancla` no es texto)")
  if (!nzchar(trimws(a))) return("(el campo `ancla` está vacío)")
  a
}

# Revisa UNA pieza y DEVUELVE los reparos en vez de abortar, para poder juntarlos
# todos: una sola corrida tiene que decir todo lo que hay que arreglar, no el
# primer problema y a empezar de nuevo.
revisar_pieza <- function(p) {
  r <- character(0)

  tipo <- p[["tipo"]]
  if (is.null(tipo)) {
    r <- c(r, "falta el campo `tipo`. Tiene que ser uno de: ficha, faq, glosario.")
  } else if (!escalar_texto(tipo)) {
    r <- c(r, "el campo `tipo` no es una palabra suelta. Escríbelo así: `tipo: ficha`.")
  } else if (!normalizar_clave(tipo) %in% names(TIPOS_PIEZA)) {
    r <- c(r, sprintf("el campo `tipo` dice `%s`, que no existe. Usa ficha, faq o glosario.",
                      normalizar_espacios(tipo)))
  }

  estado <- p[["estado"]]
  validada <- FALSE
  if (is.null(estado)) {
    r <- c(r, "falta el campo `estado`. Tiene que decir `borrador` o `validada`.")
  } else if (!escalar_texto(estado)) {
    r <- c(r, "el campo `estado` no es una palabra suelta. Escríbelo así: `estado: borrador`.")
  } else if (!normalizar_clave(estado) %in% ESTADOS_PIEZA) {
    r <- c(r, sprintf("el campo `estado` dice `%s`. Solo valen `borrador` y `validada`.",
                      normalizar_espacios(estado)))
  } else {
    validada <- identical(normalizar_clave(estado), "validada")
  }

  # `titulo` lo lee el índice de piezas, no solo la página: sin él el pipeline
  # moría lejos del archivo que lo causaba, con un error de longitud de R.
  titulo <- p[["titulo"]]
  if (is.null(titulo)) {
    r <- c(r, "falta el campo `titulo`. Es el nombre con que la pieza aparece en el índice.")
  } else if (!escalar_texto(titulo)) {
    r <- c(r, paste0("el campo `titulo` no es texto. Si escribiste `no` o `si` sin comillas, ",
                     "YAML los lee como verdadero/falso. Ponlo entre comillas: ",
                     "`titulo: \"¿Qué exige la ley para expulsar?\"`."))
  } else if (!nzchar(normalizar_espacios(titulo))) {
    r <- c(r, "el campo `titulo` está vacío. Escribe el nombre con que la pieza aparecerá en el índice.")
  }

  v <- p[["validado_por"]]
  if (!is.null(v)) {
    if (!escalar_texto(v)) {
      r <- c(r, paste0("el campo `validado_por` no trae UN nombre escrito como texto. Una lista ",
                       "de nombres no vale, y si\n      pusiste `no`, `off`, `N` o `false`, YAML ",
                       "los lee como el valor falso. Déjalo en `null` mientras\n      la pieza sea ",
                       "un borrador, o escribe una sola firma: `validado_por: \"María Pérez\"`."))
    } else if (!es_nombre_de_persona(v)) {
      r <- c(r, sprintf(paste0("el campo `validado_por` dice `%s`, que no es el nombre de una ",
                               "persona. Tiene que traer\n      nombre y apellido. Déjalo en `null` ",
                               "mientras la pieza sea un borrador, o firma así:\n      ",
                               "`validado_por: \"María Pérez\"`."), normalizar_espacios(v)))
    }
  }

  # Lo que sigue solo se le exige a una pieza que dice estar validada: un borrador
  # a medio llenar es lo normal, y abortar por eso pararia el pipeline cada dia.
  if (validada) {
    # Solo si el campo NO esta: si esta y es invalido, el reparo de arriba ya lo
    # dijo, y anadir "no trae validado_por" sobre un campo que si esta escrito es
    # mandar a la persona a buscar algo que tiene delante.
    if (is.null(v)) {
      r <- c(r, paste0("dice `estado: validada` pero no trae `validado_por`. Una pieza ",
                       "interpretativa sin firma no se\n      publica: completa `validado_por` y ",
                       "`fecha_validacion`, o vuelve a `estado: borrador`."))
    }
    f <- p[["fecha_validacion"]]
    if (is.null(f)) {
      r <- c(r, "dice `estado: validada` pero no trae `fecha_validacion`. Escríbela así: `fecha_validacion: \"2026-09-01\"`.")
    } else if (!es_fecha_plausible(f)) {
      r <- c(r, sprintf(paste0("el campo `fecha_validacion` dice `%s`, que no es una fecha. ",
                               "Escríbela como año-mes-día\n      entre comillas: ",
                               "`fecha_validacion: \"2026-09-01\"`."),
                        paste(as.character(f), collapse = ", ")))
    }
    fu <- p[["fuentes"]]
    if (is.null(fu)) {
      r <- c(r, paste0("dice `estado: validada` pero no trae `fuentes`. Cada afirmación de una ",
                       "pieza tiene que\n      poder anclarse a un artículo; una pieza sin ",
                       "fuentes es una opinión, no una lectura de la normativa."))
    } else if (!is.list(fu) || length(fu) == 0L) {
      r <- c(r, paste0("el campo `fuentes` no es una lista de entradas. Se escribe una por línea, ",
                       "empezando por `-`:\n      `fuentes:`\n      `  - {norma: ",
                       "ley_20536_violencia_escolar, articulo: art-16-d, ancla: ",
                       "\"ley_20536_violencia_escolar.html#art-16-d\"}`."))
    } else {
      for (i in seq_along(fu)) {
        e <- fu[[i]]
        if (!is.list(e)) {
          r <- c(r, sprintf(paste0("en `fuentes`, la entrada %d no es un `{norma: ..., articulo: ",
                                   "..., ancla: \"...\"}`."), i))
          next
        }
        faltan <- Filter(function(k) !escalar_texto(e[[k]]) || !nzchar(normalizar_espacios(e[[k]])),
                         c("norma", "articulo", "ancla"))
        if (length(faltan) > 0L) {
          r <- c(r, sprintf("en `fuentes`, a la entrada %d le falta %s (o está en blanco).",
                            i, paste0("`", unlist(faltan), "`", collapse = " y ")))
        }
      }
    }
  }
  r
}

# `tipo` y `estado` se normalizan DESPUES de revisarlos, y el valor normalizado es
# el que usa todo lo de abajo. Las anclas se normalizan aqui tambien, y no solo al
# validarlas: se copian y pegan del navegador y llegan con espacios que nadie ve,
# y si se normalizaran solo en la comprobacion, un ancla con un espacio final
# pasaria la compuerta y se publicaria rota. Lo que se valida tiene que ser
# exactamente lo que se publica.
normalizar_pieza <- function(p) {
  p[["estado"]] <- normalizar_clave(p[["estado"]])
  p[["tipo"]]   <- normalizar_clave(p[["tipo"]])
  if (is.list(p[["fuentes"]])) {
    p[["fuentes"]] <- lapply(p[["fuentes"]], function(f) {
      if (!is.list(f)) return(f)
      for (k in c("norma", "articulo", "ancla"))
        if (escalar_texto(f[[k]])) f[[k]] <- normalizar_espacios(f[[k]])
      f
    })
  }
  p
}

# isTRUE() ademas de la comprobacion de tipo: sin el, un `validado_por: []` hacia
# que esto valiera NA y la pieza se caia de las dos listas a la vez.
firmada <- function(p) isTRUE(es_nombre_de_persona(p[["validado_por"]]))

slug_pieza <- function(p) paste0("pieza-", slugificar(tools::file_path_sans_ext(basename(p[["archivo"]]))))

cargar_piezas <- function(anclas) {
  # force() explicito: sin el, `anclas` es perezoso y solo se evalua dentro de
  # ancla_resuelve(), que solo se alcanza si alguna pieza llega validada y bien
  # formada. Un llamador que olvidara el argumento no fallaria hoy (0 piezas
  # validadas) y fallaria el dia de la primera firma, que es justo cuando nadie
  # quiere descubrirlo. El argumento obligatorio solo garantiza algo si se fuerza.
  force(anclas)
  raiz <- ruta_insumos("curaduria", "piezas")
  if (!fs::dir_exists(raiz)) return(list())
  archivos <- fs::dir_ls(raiz, glob = "*.md", recurse = TRUE)
  # Insensible a mayusculas: en Linux `Readme.md` y `LEEME.md` no son el mismo
  # archivo que `README.md`, y se parseaban como si fueran una pieza.
  archivos <- archivos[!tolower(basename(archivos)) %in% c("readme.md", "leeme.md")]
  if (length(archivos) == 0L) return(list())

  piezas <- lapply(archivos, leer_pieza)
  rel <- function(p) fs::path_rel(p[["archivo"]], here::here())

  reparos <- unlist(lapply(piezas, function(p) {
    r <- revisar_pieza(p)
    if (length(r) == 0L) return(NULL)
    paste0("  ", rel(p), "\n", paste0("    - ", r, collapse = "\n"))
  }))
  if (length(reparos) > 0L) {
    stop(sprintf("Hay %d pieza(s) interpretativa(s) que el pipeline no puede aceptar:\n",
                 length(reparos)),
         paste(reparos, collapse = "\n"),
         "\n  Todo esto se corrige en el front matter, que es lo que va entre los '---' del ",
         "principio del archivo.", call. = FALSE)
  }

  piezas <- lapply(piezas, normalizar_pieza)

  # Dos piezas con el mismo nombre de archivo en carpetas distintas producen el
  # mismo slug: la segunda pagina sobreescribe a la primera y una pieza firmada
  # desaparece del sitio sin que nadie lo note. El README dice que una pieza
  # validada "puede quedarse donde esta o moverse", asi que copiar en vez de mover
  # produce exactamente este par.
  slugs <- vapply(piezas, slug_pieza, character(1))
  if (anyDuplicated(slugs) > 0L) {
    choques <- unique(slugs[duplicated(slugs)])
    detalle <- vapply(choques, function(s) paste0(
      "  todas estas piezas se llamarían `", s, "`:\n",
      paste0("    - ", vapply(piezas[slugs == s], rel, character(1)), collapse = "\n")),
      character(1))
    stop("Hay piezas distintas que producirían la misma página:\n",
         paste(detalle, collapse = "\n"),
         "\n  La página se nombra por el nombre del archivo, sin la carpeta. Renombra una de ",
         "ellas.", call. = FALSE)
  }

  publicables <- Filter(function(p) identical(p[["estado"]], "validada") && firmada(p), piezas)

  # Compuerta de anclas. Solo sobre lo PUBLICABLE: abortar el pipeline entero por
  # un borrador que nadie ha firmado pararia el trabajo diario del equipo. Sobre
  # los borradores se avisa, que es lo que convierte el aviso en tarea.
  malas_de <- function(p) Filter(function(f) !ancla_resuelve(f, anclas), fuentes_en_forma(p))
  rotas_pub <- unlist(lapply(publicables, function(p) {
    malas <- malas_de(p)
    if (length(malas) == 0L) return(NULL)
    paste0("  ", rel(p), "\n",
           paste0("    - `", vapply(malas, rotulo_ancla, character(1)), "`", collapse = "\n"))
  }))
  if (length(rotas_pub) > 0L) {
    stop("Hay piezas validadas cuyas `fuentes` no apuntan a un artículo que exista:\n",
         paste(rotas_pub, collapse = "\n"),
         "\n  El ancla se escribe `<norma>.html#<id del artículo>`, y `norma` y `articulo` de ",
         "esa misma\n  entrada tienen que decir lo mismo que el ancla. Ábrela en la página de la ",
         "norma para\n  comprobar el id, o quita la fuente.", call. = FALSE)
  }
  borradores <- Filter(function(p) !identical(p[["estado"]], "validada"), piezas)
  rotas_bor <- unlist(lapply(borradores, function(p) {
    malas <- malas_de(p)
    if (length(malas) == 0L) return(NULL)
    sprintf("%s -> %s", rel(p),
            paste(vapply(malas, rotulo_ancla, character(1)), collapse = ", "))
  }))
  if (length(rotas_bor) > 0L) {
    n_anclas <- sum(vapply(borradores, function(p) length(malas_de(p)), integer(1)))
    log_msg(sprintf(paste0("Anclas que no resuelven en %d borrador(es), %d ancla(s) en total: %s. ",
                           "Hay que corregirlas ANTES de validarlos."),
                    length(rotas_bor), n_anclas, paste(rotas_bor, collapse = "; ")),
            nivel = "WARN", origen = ORIGEN)
  }

  log_msg(sprintf("Piezas interpretativas: %d en total, %d validadas y publicables.",
                  length(piezas), length(publicables)), origen = ORIGEN)
  publicables
}

pagina_pieza <- function(p) {
  fuentes <- if (is.null(p[["fuentes"]]) || length(p[["fuentes"]]) == 0L) character(0) else
    vapply(p[["fuentes"]], function(f)
      sprintf("- [%s, %s](%s)", f[["norma"]], f[["articulo"]], f[["ancla"]]), character(1))

  # El cuerpo de la pieza SI se indexa (E-c del ensayo v6). Hasta v6 solo
  # pagina_norma() emitia data-pagefind-body, asi que una pieza validada se
  # publicaba y no se podia encontrar buscando: medido en el ensayo, 25 de 49
  # paginas indexadas y 0 URLs de pieza en el indice. El equipo va a validar una
  # FAQ sobre expulsion esperando encontrarla al buscar "expulsion".
  #
  # Los filtros van con el cuerpo y no son decorativos: Pagefind excluye de una
  # faceta las paginas que no declaran su valor, asi que una pieza indexada SIN
  # filtros aparece en la busqueda libre y DESAPARECE en cuanto alguien usa
  # cualquier filtro. La faceta `fuente` tenia un unico valor (`normativa`); la
  # pieza aporta el segundo, que es justo la distincion que importa al lector:
  # texto legal frente a lectura del equipo.
  filtros <- c(paste0("tipo:", unname(TIPOS_PIEZA[[p[["tipo"]]]])),
               "fuente:interpretación institucional")
  if (escalar_texto(p[["tema"]])) filtros <- c(filtros, paste0("tema:", p[["tema"]]))

  c("---",
    paste("title:", escalar_yaml(p[["titulo"]])),
    paste("subtitle:", escalar_yaml(unname(TIPOS_PIEZA[[p[["tipo"]]]]))),
    "toc: true",
    "---",
    "",
    # La cabecera de firma queda FUERA del cuerpo indexado, igual que la ficha de
    # la pagina de norma: es procedencia, no contenido.
    "```{=html}",
    '<div class="ficha-norma">',
    sprintf('<p><span class="badge-fuente badge-interpretacion">interpretación institucional</span></p>'),
    sprintf("<p>Pieza <strong>validada por %s</strong>%s. No es texto normativo: es una lectura del equipo de convivencia, y cada afirmación enlaza al artículo que la respalda.</p>",
            escapar_html(as.character(p[["validado_por"]])),
            if (!is.null(p[["fecha_validacion"]])) paste0(" el ", escapar_html(as.character(p[["fecha_validacion"]]))) else ""),
    "</div>",
    "```",
    "",
    sprintf('::: {data-pagefind-body="true" data-pagefind-meta="pieza:%s"}',
            gsub('"', "", as.character(p[["titulo"]]))),
    "",
    "```{=html}",
    sprintf('<span data-pagefind-filter="%s"></span>', escapar_html(filtros)),
    "```",
    "",
    p[["cuerpo"]],
    "",
    ":::",
    "",
    # La lista de fuentes queda FUERA del indice, por el mismo motivo por el que
    # el bloque de relacionados de la pagina de norma tambien lo esta: son slugs y
    # numeros de articulo, y buscar "ley_20536" empezaria a devolver piezas cuyo
    # unico vinculo con el termino es su pie de fuentes.
    if (length(fuentes) > 0L) c("## Fuentes", "", fuentes, "") else NULL) |>
    paste(collapse = "\n")
}

# ---- Paginas tematicas -------------------------------------------------------
# Una pagina por tema, que cruza lo que dicen TODAS las fuentes sobre el. Es la
# hermana navegable del buscador: sirve para la pregunta "que dice la normativa
# sobre celulares", que no se responde bien escribiendo una palabra suelta.
#
# El orden de las capas es la jerarquia normativa (ley -> reglamento -> acto
# administrativo -> interpretacion), no el alfabeto ni la relevancia: leer un
# dictamen antes que la ley que interpreta invierte el razonamiento juridico.
CAPAS_TEMA <- list(
  list(id = "leyes",      titulo = "Leyes",                          tipos = c("ley")),
  list(id = "reglamento", titulo = "Decretos y decretos con fuerza de ley", tipos = c("dfl", "dto")),
  list(id = "actos",      titulo = "Circulares y resoluciones",      tipos = c("circular", "rex")),
  list(id = "dictamenes", titulo = "Dictámenes",                     tipos = c("dictamen"))
)

TOPE_EXTRACTO <- 700L

# Extracto textual: el PRIMER bloque de la norma que menciona el tema, entero.
# No una ventana de N caracteres alrededor de la palabra: recortar por posicion
# parte frases a la mitad y produce exactamente la "elipsis enganosa" que el
# invariante de contenido prohibe. Un parrafo entero nunca miente por recorte.
# Si el parrafo es larguisimo se corta en el ultimo punto antes del tope y se
# marca el corte, con el enlace al articulo completo siempre a la vista.
extracto_tematico <- function(n, claves) {
  plano_de <- function(x) tolower(stringi::stri_trans_general(x, "Latin-ASCII"))
  patron <- paste0("\\b(?:", paste(vapply(claves, function(k)
    gsub("([.|()\\^{}+$*?\\[\\]])", "\\\\\\1", k), character(1)), collapse = "|"), ")")
  # Se buscan primero los ARTICULOS y solo despues el resto de los segmentos. El
  # preambulo suele contener el titulo de la norma y por lo tanto casi siempre
  # menciona el tema: sin esta preferencia, la pagina tematica de TEA mostraba
  # como extracto la ficha bibliografica de la ley 21.545 en vez de su articulado.
  # Es literal en ambos casos, pero uno responde la pregunta y el otro no.
  segmentos <- c(Filter(function(x) isTRUE(x$es_articulo), n$articulos),
                 Filter(function(x) !isTRUE(x$es_articulo), n$articulos))
  for (seg in segmentos) {
    for (bloque in strsplit(seg$texto, "\n\n", fixed = TRUE)[[1]]) {
      if (!nzchar(trimws(bloque))) next
      if (!grepl(patron, plano_de(bloque), perl = TRUE)) next
      texto <- trimws(bloque)
      cortado <- FALSE
      if (nchar(texto) > TOPE_EXTRACTO) {
        recorte <- substr(texto, 1, TOPE_EXTRACTO)
        ultimo <- max(c(0L, unlist(gregexpr("[.;] ", recorte))))
        texto <- if (ultimo > 200L) substr(recorte, 1, ultimo) else recorte
        cortado <- TRUE
      }
      return(list(id = seg$id, etiqueta = seg$etiqueta, texto = texto, cortado = cortado))
    }
  }
  NULL
}

ficha_tematica <- function(n, claves) {
  ex <- extracto_tematico(n, claves)
  corto <- nombre_corto(n)
  sustituida <- identical(n$vigencia$estado, "sustituido")
  ocr <- identical(n$origen_texto, "ocr_pendiente_revision")

  encabezado <- sprintf(
    '<p class="tema-norma"><span class="badge-fuente badge-%s">%s</span><span class="badge-fuente badge-tipo">%s</span>%s%s <a href="%s.html"><strong>%s</strong></a>%s</p>',
    n$tipo_fuente, n$tipo_fuente, escapar_html(n$tipo_etiqueta),
    if (sustituida) '<span class="badge-fuente badge-sustituida">sustituida</span>' else "",
    if (ocr) '<span class="badge-fuente badge-ocr">OCR sin revisar</span>' else "",
    n$slug, escapar_html(corto),
    if (is.null(n$titulo)) "" else paste0(" — ", escapar_html(n$titulo)))

  if (is.null(ex)) {
    return(c(encabezado,
             '<p class="procedencia">Trata el tema, pero no fue posible aislar un extracto: el término aparece repartido en el documento. Abrir la norma para leerlo en contexto.</p>'))
  }

  c(encabezado,
    sprintf('<blockquote class="%s"><p>%s%s</p></blockquote>',
            if (ocr) "transcripcion-ocr" else "texto-legal",
            escapar_html(ex$texto), if (ex$cortado) " […]" else ""),
    sprintf('<p class="leer-contexto"><a href="%s.html#%s">Leer en contexto: %s</a></p>',
            n$slug, ex$id, escapar_html(ex$etiqueta)))
}

pagina_tema <- function(tema, normas_tema, claves) {
  # Dentro de cada capa: primero las vigentes, y las sustituidas al final con su
  # marca. Una norma sustituida sigue siendo parte de la historia del tema, pero
  # no es lo que hay que aplicar hoy.
  cuerpo <- unlist(lapply(CAPAS_TEMA, function(capa) {
    del_capa <- Filter(function(n) n$tipo %in% capa$tipos, normas_tema)
    if (length(del_capa) == 0L) return(NULL)
    sustituida <- vapply(del_capa, function(n)
      identical(n$vigencia$estado, "sustituido"), logical(1))
    del_capa <- c(del_capa[!sustituida], del_capa[sustituida])
    c(sprintf("## %s {#%s}", capa$titulo, capa$id),
      "",
      "```{=html}",
      unlist(lapply(del_capa, ficha_tematica, claves = claves)),
      "```",
      "")
  }))

  c("---",
    paste("title:", escalar_yaml(tema)),
    paste("subtitle:", escalar_yaml(sprintf(
      "%d norma%s del corpus tratan este tema", length(normas_tema),
      if (length(normas_tema) == 1L) "" else "s"))),
    "toc: true",
    'toc-title: "Capas de fuente"',
    "---",
    "",
    "```{=html}",
    '<div class="aviso" role="note">',
    "<p>Cada extracto es <strong>texto literal</strong> de la norma y enlaza al ",
    "artículo completo. El orden de las secciones sigue la jerarquía normativa. ",
    "La pertenencia al tema se deriva de un diccionario de palabras clave ",
    "declarado en el código, no de una lectura interpretativa.</p>",
    "</div>",
    "```",
    "",
    cuerpo) |> paste(collapse = "\n")
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
  marcas <- c(
    if (identical(n$vigencia$estado, "sustituido"))
      sprintf("**sustituida por %s**", nombre_de(n$vigencia$sustituido_por)) else NULL,
    if (identical(n$origen_texto, "ocr_pendiente_revision"))
      "*transcripción OCR en revisión*" else NULL
  )
  sprintf('- [%s](%s.qmd)%s%s',
          corto, n$slug,
          if (is.null(n$titulo)) "" else paste0(" — ", n$titulo),
          if (length(marcas)) paste0(" · ", paste(marcas, collapse = " · ")) else "")
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

RELACIONES <- jsonlite::fromJSON(ruta_datos("relaciones.json"),
                                 simplifyDataFrame = FALSE)$relaciones

for (n in normas) assign(n$slug, nombre_corto(n), envir = NOMBRES)

destino <- ruta_sitio_src()
if (fs::dir_exists(destino)) fs::dir_delete(destino)
fs::dir_create(destino)

# Los PDF viajan al sitio: la ficha de cada norma enlaza el documento oficial y
# ese enlace tiene que resolver en GitHub Pages, no solo en el repositorio.
fs::dir_create(file.path(destino, "pdf"))
fs::file_copy(fs::dir_ls(ruta_normativa(), glob = "*.pdf"), file.path(destino, "pdf"))

fs::file_copy(here::here("_quarto.yml"), file.path(destino, "_quarto.yml"))
fs::file_copy(
  fs::dir_ls(here::here("30_procesamiento", "34_plantillas_sitio")),
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
# ---- Temas: una pagina por tema + el directorio que las enlaza --------------
temas <- sort(unique(unlist(lapply(normas, function(n) n$tema))))
por_tema <- setNames(
  lapply(temas, function(t) Filter(function(n) t %in% n$tema, normas)),
  temas
)
slug_tema <- function(t) paste0("tema-", slugificar(t))

for (t in temas) {
  claves <- TEMAS_PALABRAS_CLAVE[[t]]
  if (is.null(claves)) claves <- t   # tema aportado por curaduria, sin diccionario
  writeLines(pagina_tema(t, por_tema[[t]], claves),
             file.path(destino, paste0(slug_tema(t), ".qmd")))
}

# El indice de temas deja de ser una lista plana de normas y pasa a ser el
# directorio de las paginas tematicas: es la puerta hermana del buscador que pide
# el encargo, y repetir aqui el listado completo duplicaria lo que cada pagina ya
# muestra mejor.
filas_tema <- vapply(temas, function(t) {
  ns <- por_tema[[t]]
  sust <- sum(vapply(ns, function(n) identical(n$vigencia$estado, "sustituido"), logical(1)))
  sprintf("| [%s](%s.qmd) | %d | %s |", t, slug_tema(t), length(ns),
          paste(sort(unique(vapply(ns, function(n) n$tipo_etiqueta, character(1)))), collapse = ", "))
}, character(1))

sin_tema <- Filter(function(n) length(n$tema) == 0L, normas)
writeLines(
  c("---",
    'title: "Temas"',
    'subtitle: "Qué dice el corpus completo sobre cada materia, cruzando todas las fuentes."',
    "toc: false",
    "---",
    "",
    "Cada página temática reúne lo que dicen las leyes, los reglamentos, las",
    "circulares y los dictámenes sobre una misma materia, con extractos textuales",
    "y enlace al artículo completo.",
    "",
    "| Tema | Normas | Tipos de fuente |",
    "|---|---:|---|",
    filas_tema,
    "",
    if (length(sin_tema) > 0L) c(
      "## Sin tema asignado",
      "",
      vapply(sin_tema, item_norma, character(1)),
      "",
      "Un documento sin tema es casi siempre un documento sin texto disponible.",
      "") else NULL,
    "",
    "```{=html}",
    '<p class="procedencia">Los temas se asignan por coincidencia de palabras clave sobre el texto extraído, con un diccionario declarado en <code>10_utils/10_configuracion.R</code>. Una norma puede estar en varios temas.</p>',
    "```",
    ""),
  file.path(destino, "indice-tema.qmd")
)

# ---- Piezas interpretativas: solo las validadas ------------------------------
piezas <- cargar_piezas(anclas_disponibles(normas))
for (p in piezas) {
  writeLines(pagina_pieza(p), file.path(destino, paste0(slug_pieza(p), ".qmd")))
}

n_piezas <- length(piezas)
if (n_piezas > 0L) {
  por_tipo_pieza <- split(piezas, vapply(piezas, function(p) p[["tipo"]], character(1)))
  por_tipo_pieza <- por_tipo_pieza[intersect(names(TIPOS_PIEZA), names(por_tipo_pieza))]
  writeLines(
    c("---",
      'title: "Fichas, preguntas frecuentes y glosario"',
      'subtitle: "Piezas interpretativas validadas por el equipo de convivencia."',
      "toc: true",
      "---",
      "",
      "```{=html}",
      '<div class="aviso" role="note">',
      "<p>Lo que sigue <strong>no es texto normativo</strong>. Son lecturas del equipo ",
      "de convivencia, y cada una está firmada por quien la validó. El texto legal ",
      "literal está en las páginas de cada norma.</p>",
      "</div>",
      "```",
      "",
      unlist(lapply(names(por_tipo_pieza), function(t) c(
        paste("##", TIPOS_PIEZA[[t]]),
        "",
        vapply(por_tipo_pieza[[t]], function(p)
          sprintf("- [%s](%s.qmd) — validada por %s", p[["titulo"]], slug_pieza(p),
                  as.character(p[["validado_por"]])), character(1)),
        ""))),
      ""),
    file.path(destino, "piezas.qmd"))

  # El navbar gana la entrada SOLO si hay algo que enlazar. Un enlace a una
  # seccion vacia le dice al usuario que existe contenido que no existe.
  yml <- readLines(file.path(destino, "_quarto.yml"), warn = FALSE)
  i <- grep("^      - href: acerca\\.qmd", yml)
  if (length(i) == 1L) {
    yml <- append(yml, c("      - href: piezas.qmd", "        text: Fichas y FAQ"), after = i[1] - 1L)
    writeLines(yml, file.path(destino, "_quarto.yml"))
  }
}

n_qmd <- length(fs::dir_ls(destino, glob = "*.qmd"))
esperadas <- length(normas) + length(temas) + 5L + n_piezas + (n_piezas > 0L)
log_msg(sprintf("Generadas %d páginas .qmd (%d normas + %d temas + %d piezas + home + acerca + 3 índices) en %s.",
                n_qmd, length(normas), length(temas), n_piezas, destino),
        origen = ORIGEN)
if (n_qmd != esperadas) {
  # El candado decia cuantas paginas faltaban y no CUALES, que es aritmetica de
  # programador. Los nombres esperados se derivan con las MISMAS funciones que los
  # escriben (slug_tema, slug_pieza), no con una copia del patron: una copia se
  # desalinea el dia que cambie el generador y el diagnostico pasa a mentir.
  hay <- basename(fs::dir_ls(destino, glob = "*.qmd"))
  quiere <- c(paste0(vapply(normas, function(n) n[["slug"]], character(1)), ".qmd"),
              paste0(vapply(temas, slug_tema, character(1)), ".qmd"),
              "index.qmd", "acerca.qmd", "indice-tipo.qmd", "indice-tema.qmd", "indice-anio.qmd",
              if (n_piezas > 0L) c(paste0(vapply(piezas, slug_pieza, character(1)), ".qmd"), "piezas.qmd"))
  falta <- setdiff(quiere, hay); sobra <- setdiff(hay, quiere)
  # `setdiff` pierde la MULTIPLICIDAD, y es la que explica el caso mas probable:
  # dos temas curados (o dos normas) cuyo slug coincide hacen que el bucle escriba
  # el mismo archivo dos veces, `hay` queda uno por debajo de `esperadas` y los dos
  # setdiff salen vacios. Un candado que dispara diciendo "faltan: ninguna, sobran:
  # ninguna" es exactamente el diagnostico que miente que esta ronda vino a quitar.
  # (Nota de alcance: `quiere` no incluye lo que se copia de 34_plantillas_sitio/,
  # que hoy no trae ningun .qmd; el dia que traiga uno saldra como "sobra".)
  repetidos <- unique(quiere[duplicated(quiere)])
  stop(sprintf(paste0("Se esperaban %d páginas .qmd y hay %d.\n",
                      "  Faltan: %s\n  Sobran: %s\n  Nombres repetidos: %s"),
               esperadas, n_qmd,
               if (length(falta)) paste(falta, collapse = ", ") else "ninguna",
               if (length(sobra)) paste(sobra, collapse = ", ") else "ninguna",
               if (length(repetidos)) paste(repetidos, collapse = ", ") else "ninguno"))
}
