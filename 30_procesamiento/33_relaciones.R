# =============================================================================
# 33_relaciones.R
# -----------------------------------------------------------------------------
# Proposito: derivar 40_salidas/datos/relaciones.json, el insumo del bloque
#            "Normas y articulos relacionados" de cada pagina.
#
# LAS RELACIONES SON DATOS, NO TEXTO GENERADO (invariante del proyecto). Cada
# relacion tiene un tipo declarado y su explicacion se compone por PLANTILLA
# desde ese tipo, con los campos que la propia relacion trae. En ningun punto se
# redacta prosa libre sobre el contenido de las normas: una frase inventada sobre
# que dice una ley, en un sitio institucional, es exactamente el riesgo que este
# proyecto existe para no correr.
#
# Tres tipos, cada uno medible y auditable:
#
#   (La explicacion describe el rol del DESTINO de la relacion, porque el destino
#    es lo que rotula el enlace en la pagina. Redactada desde el sujeto se leia al
#    reves: "Dictamen 078 - Sustituida por esta norma".)
#
#   sustitucion  Se lee del campo `vigencia`, que a su vez sale de la curaduria
#                humana con procedencia obligatoria. Es la relacion mas fuerte:
#                cambia que norma hay que aplicar.
#   remision     La norma A cita el numero de la norma B en el texto de uno de
#                sus articulos. Se mide con un patron por norma que exige la
#                PALABRA del tipo junto al numero ("ley 20.370", "dictamen N° 65"),
#                nunca el numero suelto. Si la cita trae ANIO y no coincide con el
#                de la norma de destino, se descarta: es otra norma homonima. Las
#                citas sin anio se conservan, con su texto literal a la vista.
#   tema         Comparten temas del diccionario. Es la mas debil y la que mas
#                ruido produce, asi que se exige un minimo de temas en comun.
# =============================================================================

source(here::here("10_utils", "10_utils.R"))
instalar_si_falta(c("jsonlite", "fs", "here"))
source(here::here("10_utils", "10_configuracion.R"))

ORIGEN <- "33_relaciones"

# ---- Patron de cita de una norma --------------------------------------------
# El numero SOLO no sirve: "24" aparece en cualquier texto legal como cifra. El
# patron exige la palabra del tipo delante, admite la abreviatura y el simbolo de
# numero, y tolera el punto de millar ("20.370" o "20370").
#
# Los DOS lookaheads finales impiden que una norma de numero bajo se de por citada
# dentro de un numero mayor. Hacen falta los dos y son distintos:
#   (?!\\d)   corta "18.962" (tras casar el "1" viene "8")
#   (?!\\.\\d)  corta "1.111" (tras casar el "1" viene ".1")
# Con un solo lookahead combinado (?![\\d.]\\d) el primero se escapaba, y el patron
# de la ley 1 daba por citada esa norma dentro de "ley N° 18.962".
PALABRAS_TIPO <- c(
  ley      = "ley(?:es)?",
  dfl      = "d\\.?\\s?f\\.?\\s?l\\.?|decreto con fuerza de ley",
  dto      = "decreto(?:s)?(?:\\s+supremo)?|dto\\.?",
  circular = "circular(?:es)?",
  rex      = "resoluci[oó]n(?:\\s+exenta)?|rex\\.?",
  dictamen = "dict[aá]men(?:es)?"
)

patron_cita <- function(tipo, numero) {
  n <- suppressWarnings(as.integer(numero))
  if (is.na(n)) return(NULL)
  # 20370 -> "20\.?370"; 24 -> "24". Se admite el punto de millar opcional.
  digitos <- as.character(n)
  con_punto <- if (nchar(digitos) > 3L) {
    paste0(substr(digitos, 1, nchar(digitos) - 3L), "\\.?",
           substr(digitos, nchar(digitos) - 2L, nchar(digitos)))
  } else digitos
  paste0("(?i)\\b(?:", PALABRAS_TIPO[[tipo]], ")\\s*",
         "(?:n\\s*[°ºo]?\\s*|n[°º]\\s*|num\\.?\\s*)?",
         "0*", con_punto, "(?!\\d)(?!\\.\\d)")
}

# ---- Carga -------------------------------------------------------------------
cat_json <- jsonlite::fromJSON(ruta_datos("catalogo.json"), simplifyDataFrame = FALSE)
normas <- lapply(cat_json$normas, function(x)
  jsonlite::fromJSON(ruta_normas(paste0(x$slug, ".json")), simplifyDataFrame = FALSE))
names(normas) <- vapply(normas, function(n) n$slug, character(1))

log_msg(sprintf("Derivando relaciones sobre %d normas.", length(normas)), origen = ORIGEN)

# ---- (1) Sustitucion ---------------------------------------------------------
rel_sustitucion <- unlist(lapply(normas, function(n) {
  if (!identical(n$vigencia$estado, "sustituido")) return(NULL)
  list(list(desde = n$slug, hacia = n$vigencia$sustituido_por, tipo = "sustitucion",
            explicacion = "Es la norma que sustituye a esta.",
            fuente = n$vigencia$fuente))
}), recursive = FALSE)

rel_sustituye <- unlist(lapply(normas, function(n) {
  if (length(n$vigencia$sustituye_a) == 0L) return(NULL)
  lapply(n$vigencia$sustituye_a, function(s)
    list(desde = n$slug, hacia = s, tipo = "sustitucion",
         explicacion = "Es la norma sustituida por esta; se mantiene como referencia histórica.",
         fuente = normas[[s]]$vigencia$fuente))
}), recursive = FALSE)

# ---- (2bis) Mismo acto administrativo ---------------------------------------
# La curaduria puede declarar que dos archivos del corpus son el MISMO acto: la
# Resolucion Exenta 482 de 2018 es un PDF de una pagina que aprueba una circular,
# y esa circular es otro PDF de 48 paginas escaneadas. Sin la declaracion, este
# derivador los trataba como dos normas con el mismo numero y hacia dos cosas
# falsas: emitia una remision de la resolucion a su propio cuerpo (el control
# `desde == hacia` no la ve, porque los slugs difieren) y duplicaba toda cita de
# terceros al acto, una vez por archivo.
GRUPO_DE <- vapply(normas, function(n)
  if (is.null(n$grupo_acto)) NA_character_ else n$grupo_acto$id, character(1))
RESOLUCION_DE <- vapply(normas, function(n)
  if (is.null(n$grupo_acto)) NA_character_ else n$grupo_acto$resolucion, character(1))
NOTA_GRUPO <- vapply(normas, function(n)
  if (is.null(n$grupo_acto)) NA_character_ else n$grupo_acto$nota_colapso, character(1))

# Compuerta: la resolucion de cada grupo tiene que estar en el corpus. Si no,
# el enlace colapsado apuntaria a una pagina que no existe.
sin_resolucion <- setdiff(unique(RESOLUCION_DE[!is.na(RESOLUCION_DE)]), names(normas))
if (length(sin_resolucion) > 0L) {
  stop("Grupo(s) de acto cuya `resolucion` no esta en el corpus: ",
       paste(sin_resolucion, collapse = ", "))
}

mismo_grupo <- function(x, y) !is.na(GRUPO_DE[[x]]) && identical(GRUPO_DE[[x]], GRUPO_DE[[y]])

# Las fichas de los miembros se enlazan entre si declarando la relacion, con la
# explicacion compuesta por plantilla desde el ROL del destino y la procedencia
# del grupo a la vista. Sin este vinculo, colapsar las remisiones dejaria al
# cuerpo escaneado sin ninguna via de llegada desde el resto del sitio.
rel_grupo <- unlist(lapply(normas, function(n) {
  if (is.null(n$grupo_acto)) return(NULL)
  lapply(unlist(n$grupo_acto$otros_miembros), function(otro) {
    list(desde = n$slug, hacia = otro, tipo = "grupo_acto",
         explicacion = switch(normas[[otro]]$grupo_acto$rol,
           resolucion = "Es la resolución del mismo acto administrativo.",
           cuerpo     = "Es el cuerpo del mismo acto administrativo."),
         fuente = n$grupo_acto$fuente)
  })
}), recursive = FALSE)

# ---- (2) Remision textual ----------------------------------------------------
# Se recorre articulo por articulo para poder decir EN CUAL se cita, que es la
# mitad util de la explicacion: "remite en su articulo 5" lleva a alguna parte,
# "remite" no.
# Un grupo de acto se sondea UNA sola vez, por su resolucion. Sondear cada
# miembro por separado no solo duplicaria el resultado: el filtro de anio veria
# anios distintos para el MISMO acto (la resolucion 482 es de 2018 y su cuerpo
# escaneado no tiene anio derivable), de modo que el veredicto sobre una misma
# cita dependeria de a cual de los dos archivos se la comparara.
es_sondeable <- function(slug)
  is.na(GRUPO_DE[[slug]]) || identical(slug, RESOLUCION_DE[[slug]])

patrones <- Filter(Negate(is.null), setNames(
  lapply(normas, function(n)
    if (es_sondeable(n$slug)) patron_cita(n$tipo, n$numero) else NULL),
  names(normas)))

# ---- Anio que acompana a una cita -------------------------------------------
# El numero chileno NO identifica una norma por si solo (hay un "DFL N° 1" por
# ministerio y por anio), asi que cuando la cita trae anio y NO coincide con el
# de la norma de destino, la cita es de OTRA norma homonima y la relacion se
# descarta. Las citas sin anio se conservan: no hay evidencia de que apunten a
# otra cosa, y la cita literal queda a la vista para que el lector juzgue.
#
# El anio viene en DOS formas y hay que leer las dos:
#
#   de_aaaa  Prosa: "..., de 2005, del Ministerio de Educacion".
#   d_o      Nota marginal de modificacion de la BCN, en los textos refundidos:
#            "Decreto 215, EDUCACION Art. UNICO N° 1 D.O. 05.01.2012". No es
#            prosa: es el aparato de modificaciones del documento, y la fecha
#            del Diario Oficial es la de la norma nombrada al inicio de la nota.
#
# Las dos formas necesitan ventana y corte DISTINTOS, y por eso no se unifican:
#
# (a) Ventana. Al aplanar las dos columnas del PDF, la nota marginal se
#     INTERCALA linea a linea con el cuerpo, de modo que su fecha queda lejos de
#     su cabecera. Medido el 2026-08-26 sobre los 42 candidatos de dto_453:
#     distancia mediana 132 caracteres, maxima 230. Con la ventana de prosa (60)
#     solo 15 de los 42 traian fecha; con 300 la traen los 42, y subir a 360 no
#     agrega ninguno.
# (b) Corte. El corte de prosa se detiene en CUALQUIER palabra de tipo, porque
#     en "Ley N° 21.430; D.F.L. N° 2, de 2009" el "de 2009" es del segundo. Ese
#     corte es inservible a 300 caracteres: el cuerpo intercalado nombra leyes y
#     decretos todo el tiempo y cortaria mucho antes de la fecha. Para la forma
#     D.O. se corta en la CABEZA DE OTRA NOTA (palabra de tipo + numero + coma
#     inmediata), que es lo unico que puede reclamar esa fecha para si.
#     Control medido sobre el corpus completo: con este corte, la unica remision
#     que cambia de veredicto es dto_453 -> dto_215. SIN el, se descartaba
#     ademas dictamen_71 -> ley_20370, cuya cola dice "...del decreto con fuerza
#     de ley Nº 1, de 2005. D.O. 02.07.2010" y esa fecha es del DFL, no de la ley.
VENTANA_ANIO_CITA <- 60L
VENTANA_ANIO_DO   <- 300L

REGEX_CORTE_PROSA <- paste0(";|(?i)\\b(?:", paste(PALABRAS_TIPO, collapse = "|"), ")\\b")
REGEX_CABEZA_NOTA <- paste0("(?i)\\b(?:", paste(PALABRAS_TIPO, collapse = "|"),
                            ")\\s*(?:n\\s*[°ºo]?\\s*|n[°º]\\s*|num\\.?\\s*)?",
                            "[0-9][0-9.\\-]*\\s*,")
REGEX_ANIO_PROSA  <- "\\bde\\s+((?:19|20)[0-9]{2})\\b"
REGEX_ANIO_DO     <- "(?i)D\\.?\\s?O\\.?\\s*[0-9]{1,2}[.\\-/][0-9]{1,2}[.\\-/]((?:19|20)[0-9]{2})"

# Se extrae el anio del texto que caso, NO la primera corrida de digitos: en
# "D.O. 05.01.2012" la primera corrida es el dia.
.anio_de <- function(m) if (length(m) == 0L) NA_integer_ else
  as.integer(regmatches(m[1], regexpr("(?:19|20)[0-9]{2}", m[1])))

# Devuelve el anio Y la forma en que se leyo. La forma viaja al registro de
# descartadas: un filtro que no dice por que vio un anio no se puede auditar.
anio_de_la_cita <- function(texto, desde) {
  cortar <- function(x, re) {
    p <- regexpr(re, x, perl = TRUE)
    if (p > 0L) substr(x, 1, p - 1L) else x
  }
  prosa <- cortar(substr(texto, desde, desde + VENTANA_ANIO_CITA), REGEX_CORTE_PROSA)
  a <- .anio_de(regmatches(prosa, regexpr(REGEX_ANIO_PROSA, prosa, perl = TRUE)))
  if (!is.na(a)) return(list(anio = a, forma = "de_aaaa"))
  nota <- cortar(substr(texto, desde, desde + VENTANA_ANIO_DO), REGEX_CABEZA_NOTA)
  a <- .anio_de(regmatches(nota, regexpr(REGEX_ANIO_DO, nota, perl = TRUE)))
  if (!is.na(a)) return(list(anio = a, forma = "d_o"))
  list(anio = NA_integer_, forma = NA_character_)
}

rel_remision <- list()
descartadas <- list()
for (a in normas) {
  for (slug_b in names(patrones)) {
    # Control negativo estructural: una norma nunca se relaciona consigo misma.
    # Lo intra-grupo NO se filtra aqui: se filtra una sola vez sobre el total,
    # mas abajo, para que la regla no dependa de que cada bucle la repita.
    if (identical(slug_b, a$slug)) next
    encontrado <- NULL
    literal <- NA_character_
    n_citas <- 0L
    for (seg in a$articulos) {
      pos <- regexpr(patrones[[slug_b]], seg$texto, perl = TRUE)
      if (pos == -1L) next
      cita <- trimws(regmatches(seg$texto, pos)[[1]])
      # Anio de la cita. La regla, sus dos formas y la medicion que fija cada
      # ventana viven en anio_de_la_cita(); aqui solo se aplica su veredicto.
      lectura <- anio_de_la_cita(seg$texto, pos + attr(pos, "match.length"))
      anio_cita <- lectura$anio
      # Anios validos de la norma de destino: el suyo mas los que declare la
      # curaduria. Un texto refundido tiene mas de una fecha legitima: el
      # dictamen 52/77 refunde uno de 2020 y otro de 2025, y una cita al "Dictamen
      # N° 52, de 2020" apunta a ese mismo documento aunque el catalogo lo ubique
      # en 2025.
      anios_destino <- c(normas[[slug_b]][["anio"]], normas[[slug_b]][["anios_alternativos"]])
      anios_destino <- anios_destino[!vapply(anios_destino, is.null, logical(1))]

      if (!is.na(anio_cita) && length(anios_destino) > 0L &&
          !(anio_cita %in% unlist(anios_destino))) {
        descartadas[[length(descartadas) + 1L]] <- list(
          desde = a$slug, hacia = slug_b, cita = cita,
          anio_cita = anio_cita, forma_anio = lectura$forma,
          anios_norma = I(unlist(anios_destino)),
          articulo = seg$id)
        next
      }

      n_citas <- n_citas + 1L
      if (is.null(encontrado)) { encontrado <- seg; literal <- cita }
    }
    if (is.null(encontrado)) next
    # La explicacion transcribe la CITA LITERAL que disparo la relacion, no solo
    # afirma que existe. El numero por si solo no identifica una norma chilena
    # (hay un "DFL N° 1" por cada ministerio y por cada anio), asi que mostrar el
    # texto exacto es lo que permite a quien lee descartar de un vistazo una
    # coincidencia que apunta a otra norma homonima.
    # Cuando el destino es la resolucion de un grupo, el enlace representa al
    # acto COMPLETO y tiene que decirlo: sin la nota se lee como si apuntara solo
    # al PDF de una pagina, y el cuerpo de 48 quedaria invisible para quien busca
    # lo que el tercero esta citando.
    rel <- list(
      desde = a$slug, hacia = slug_b, tipo = "remision",
      articulo = encontrado$id, etiqueta_articulo = encontrado$etiqueta,
      cita_literal = literal, n_citas = n_citas,
      explicacion = sprintf("Cita «%s» en %s%s.",
                            literal, encontrado$etiqueta,
                            if (n_citas > 1L) sprintf(" y en otros %d fragmentos", n_citas - 1L) else "")
    )
    # El campo se AGREGA, no se asigna NULL: asignarlo lo escribe como {} en
    # todas las demas remisiones, y un objeto vacio en los datos es una promesa
    # de campo que ningun consumidor puede distinguir de un campo perdido.
    if (!is.na(NOTA_GRUPO[[slug_b]])) rel$nota <- NOTA_GRUPO[[slug_b]]
    rel_remision[[length(rel_remision) + 1L]] <- rel
  }
}

# ---- (3) Tema compartido -----------------------------------------------------
# Umbral de 2 temas en comun, no 1. Con uno solo, "convivencia escolar" relaciona
# practicamente todo el corpus con todo el corpus y el bloque de relacionados deja
# de informar: 25 normas relacionadas es lo mismo que ninguna.
MIN_TEMAS_COMPARTIDOS <- 2L

rel_tema <- list()
for (a in normas) {
  for (b in normas) {
    if (identical(a$slug, b$slug)) next
    comunes <- intersect(a$tema, b$tema)
    if (length(comunes) < MIN_TEMAS_COMPARTIDOS) next
    rel_tema[[length(rel_tema) + 1L]] <- list(
      desde = a$slug, hacia = b$slug, tipo = "tema",
      temas = I(comunes), n_temas = length(comunes),
      explicacion = sprintf("Comparten %d temas: %s.",
                            length(comunes), paste(comunes, collapse = ", "))
    )
  }
}

todas <- c(rel_sustitucion, rel_sustituye, rel_grupo, rel_remision, rel_tema)

# ---- Supresion intra-grupo ---------------------------------------------------
# Entre miembros de un mismo acto administrativo el UNICO vinculo legitimo es el
# tipo `grupo_acto`. Cualquier otro seria la norma relacionandose consigo misma
# por otra via: la resolucion "citando" su propio cuerpo, o los dos archivos
# "compartiendo temas" con ellos mismos, que es literalmente lo que decia el
# sitio ("Comparten 2 temas: medidas disciplinarias, reconocimiento oficial").
#
# El filtro se aplica sobre el TOTAL, no dentro de cada derivador, a proposito:
# asi cubre los tipos que se agreguen despues sin que nadie tenga que acordarse
# de repetir el control en un bucle nuevo. Es el mismo criterio por el que la
# compuerta `auto` de aqui abajo mira el total y no cada derivador por separado.
#
# Nota: el vinculo intra-grupo se suprime del bloque de relacionados, NO de las
# paginas tematicas. Esas se arman desde el campo `tema` de cada norma y no desde
# este archivo, asi que los dos miembros siguen apareciendo cada uno con su
# extracto: el cuerpo escaneado es donde esta el texto, y esconderlo del tema
# seria esconder el contenido del acto.
intra_grupo <- Filter(function(r)
  !identical(r$tipo, "grupo_acto") && mismo_grupo(r$desde, r$hacia), todas)
todas <- Filter(function(r)
  identical(r$tipo, "grupo_acto") || !mismo_grupo(r$desde, r$hacia), todas)

if (length(intra_grupo) > 0L) {
  por_tipo_intra <- table(vapply(intra_grupo, function(r) r$tipo, character(1)))
  log_msg(sprintf("Relaciones suprimidas por unir dos archivos del mismo acto: %d (%s).",
                  length(intra_grupo),
                  paste(names(por_tipo_intra), por_tipo_intra, sep = "=", collapse = ", ")),
          origen = ORIGEN)
  for (r in intra_grupo) {
    log_msg(sprintf("  %s -> %s [%s]: %s", r$desde, r$hacia, r$tipo, r$explicacion),
            origen = ORIGEN)
  }
}

# ---- Compuertas --------------------------------------------------------------
auto <- Filter(function(r) identical(r$desde, r$hacia), todas)
if (length(auto) > 0L) {
  stop(sprintf("%d relacion(es) de una norma consigo misma. Es un defecto del derivador.",
               length(auto)))
}
huerfanas <- Filter(function(r) !(r$hacia %in% names(normas)), todas)
if (length(huerfanas) > 0L) {
  stop("Relaciones que apuntan fuera del corpus: ",
       paste(vapply(huerfanas, function(r) paste0(r$desde, " -> ", r$hacia), character(1)),
             collapse = ", "))
}

if (length(descartadas) > 0L) {
  por_forma <- table(vapply(descartadas, function(d) d$forma_anio, character(1)))
  log_msg(sprintf("Remisiones descartadas por anio discordante: %d (%s).",
                  length(descartadas),
                  paste(names(por_forma), por_forma, sep = "=", collapse = ", ")),
          nivel = "WARN", origen = ORIGEN)
  for (d in descartadas) {
    log_msg(sprintf("  %s -> %s: cita «%s» con año %d leído como %s; la norma del corpus es de %s.",
                    d$desde, d$hacia, d$cita, d$anio_cita, d$forma_anio,
                    paste(d$anios_norma, collapse = "/")),
            origen = ORIGEN)
  }
}

por_tipo <- table(factor(vapply(todas, function(r) r$tipo, character(1)),
                         levels = c("sustitucion", "grupo_acto", "remision", "tema")))
log_msg(sprintf("Relaciones: %d en total — %d sustitucion, %d mismo acto, %d remision, %d tema.",
                length(todas), por_tipo[["sustitucion"]], por_tipo[["grupo_acto"]],
                por_tipo[["remision"]], por_tipo[["tema"]]),
        origen = ORIGEN)

escribir_atomico(
  list(
    generado_por = "30_procesamiento/33_relaciones.R",
    min_temas_compartidos = MIN_TEMAS_COMPARTIDOS,
    # Se registran las remisiones descartadas, no se borran en silencio: un filtro
    # que reduce resultados sin dejar rastro es indistinguible de un derivador que
    # no los encontro nunca.
    remisiones_descartadas_por_anio = length(descartadas),
    descartadas = unname(descartadas),
    # Mismo criterio para lo suprimido por intra-grupo: si el lector no ve que
    # esos vinculos existian y se quitaron a proposito, no puede distinguir la
    # supresion de un derivador que nunca los encontro.
    relaciones_suprimidas_intra_grupo = length(intra_grupo),
    suprimidas_intra_grupo = unname(intra_grupo),
    n_relaciones = length(todas),
    por_tipo = as.list(setNames(as.integer(por_tipo), names(por_tipo))),
    relaciones = unname(todas)
  ),
  ruta_datos("relaciones.json"),
  function(o, p) jsonlite::write_json(o, p, auto_unbox = TRUE, pretty = TRUE)
)
