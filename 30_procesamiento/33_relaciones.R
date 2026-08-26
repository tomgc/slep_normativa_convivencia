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
#                nunca el numero suelto.
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

# ---- (2) Remision textual ----------------------------------------------------
# Se recorre articulo por articulo para poder decir EN CUAL se cita, que es la
# mitad util de la explicacion: "remite en su articulo 5" lleva a alguna parte,
# "remite" no.
patrones <- Filter(Negate(is.null), setNames(
  lapply(normas, function(n) patron_cita(n$tipo, n$numero)),
  names(normas)))

rel_remision <- list()
for (a in normas) {
  for (slug_b in names(patrones)) {
    # Control negativo estructural: una norma nunca se relaciona consigo misma.
    if (identical(slug_b, a$slug)) next
    encontrado <- NULL
    literal <- NA_character_
    n_citas <- 0L
    for (seg in a$articulos) {
      m <- regmatches(seg$texto, regexpr(patrones[[slug_b]], seg$texto, perl = TRUE))
      if (length(m) == 0L) next
      n_citas <- n_citas + 1L
      if (is.null(encontrado)) { encontrado <- seg; literal <- trimws(m[1]) }
    }
    if (is.null(encontrado)) next
    # La explicacion transcribe la CITA LITERAL que disparo la relacion, no solo
    # afirma que existe. El numero por si solo no identifica una norma chilena
    # (hay un "DFL N° 1" por cada ministerio y por cada anio), asi que mostrar el
    # texto exacto es lo que permite a quien lee descartar de un vistazo una
    # coincidencia que apunta a otra norma homonima.
    rel_remision[[length(rel_remision) + 1L]] <- list(
      desde = a$slug, hacia = slug_b, tipo = "remision",
      articulo = encontrado$id, etiqueta_articulo = encontrado$etiqueta,
      cita_literal = literal, n_citas = n_citas,
      explicacion = sprintf("Cita «%s» en %s%s.",
                            literal, encontrado$etiqueta,
                            if (n_citas > 1L) sprintf(" y en otros %d fragmentos", n_citas - 1L) else "")
    )
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

todas <- c(rel_sustitucion, rel_sustituye, rel_remision, rel_tema)

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

por_tipo <- table(factor(vapply(todas, function(r) r$tipo, character(1)),
                         levels = c("sustitucion", "remision", "tema")))
log_msg(sprintf("Relaciones: %d en total — %d sustitucion, %d remision, %d tema.",
                length(todas), por_tipo[["sustitucion"]], por_tipo[["remision"]],
                por_tipo[["tema"]]),
        origen = ORIGEN)

escribir_atomico(
  list(
    generado_por = "30_procesamiento/33_relaciones.R",
    min_temas_compartidos = MIN_TEMAS_COMPARTIDOS,
    n_relaciones = length(todas),
    por_tipo = as.list(setNames(as.integer(por_tipo), names(por_tipo))),
    relaciones = unname(todas)
  ),
  ruta_datos("relaciones.json"),
  function(o, p) jsonlite::write_json(o, p, auto_unbox = TRUE, pretty = TRUE)
)
