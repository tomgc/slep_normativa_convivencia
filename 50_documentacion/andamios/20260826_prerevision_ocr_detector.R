# =============================================================================
# Pre-revision asistida del OCR (T4, encargo 20260826_encargo_avance_maquina_v1)
# -----------------------------------------------------------------------------
# SOLO LECTURA sobre 20_insumos/ocr/. No corrige, no reescribe y no cambia ningun
# estado. Produce una lista priorizada de lineas sospechosas para que la revision
# humana empiece por donde mas rinde. El detector es lexico, nunca semantico.
#
# El lexico de referencia no es un diccionario externo: son las palabras del propio
# corpus con capa de texto de PDF, de modo que "fuera del lexico" significa "no
# aparece en ninguna norma legible del corpus".
#
# Dos lecciones de calibracion, incorporadas:
#  (1) "fuera del lexico" a secas marca espanol legitimo ausente del corpus
#      (parametro, gozan, tomaren). Queda como senal DEBIL, para barrido.
#  (2) Distancia de edicion 1 tampoco basta: la morfologia del espanol produce
#      vecinos a un caracter por conjugacion y genero (comprendan/comprenden,
#      accesorios/accesorias). Solo cuenta como senal FUERTE si el caracter que
#      cambia forma un par que el reconocedor confunde por forma (i/l, j/i, f/t).
# =============================================================================
suppressWarnings(suppressMessages({library(jsonlite); library(stringi)}))
raiz <- "/Users/tomgc/Projects/slep_normativa_convivencia"
tokenizar <- function(x) {
  x <- unlist(stri_split_regex(x, "[^\\p{L}]+"))
  stri_trans_tolower(x[nzchar(x)])
}

# ---- Lexico de referencia ---------------------------------------------------
normas <- list.files(file.path(raiz, "40_salidas/datos/normas"), pattern = "\\.json$", full.names = TRUE)
lex <- character(0); n_norm <- 0L
for (f in normas) {
  n <- fromJSON(f, simplifyDataFrame = FALSE)
  if (!identical(n$origen_texto, "capa_texto_pdf")) next
  n_norm <- n_norm + 1L
  lex <- c(lex, tokenizar(vapply(n$articulos, function(a) a$texto, character(1))))
}
LEXICO <- unique(lex); LEX_N <- nchar(LEXICO)
con_marca <- LEXICO[stri_detect_regex(LEXICO, "[áéíóúüñ]")]
SIN_MARCA <- setNames(con_marca, stri_trans_general(con_marca, "Latin-ASCII"))
SIN_MARCA <- SIN_MARCA[!(names(SIN_MARCA) %in% LEXICO)]

# ---- Repertorio y confusiones -----------------------------------------------
# El punto medio, los puntos suspensivos y la raya SI aparecen en el original; los
# simbolos de marca registrada no: son llamadas a nota al pie mal reconocidas.
SIMBOLO_RARO      <- "[®™©¥§¤|\\\\~¬^{}<>¦†‡]"
LETRA_NO_ESPANOLA <- "[^A-Za-zÁÉÍÓÚÜÑáéíóúüñºª\\P{L}]"  # º y ª son ordinales del espanol
CONFUSIONES <- list(c("i","l"),c("i","j"),c("l","1"),c("o","0"),c("o","c"),c("c","e"),
                    c("f","t"),c("n","ñ"),c("n","r"),c("n","h"),c("s","5"),c("g","q"),
                    c("u","v"),c("b","h"),c("y","v"),c("z","2"),c("a","á"),c("e","é"),
                    c("i","í"),c("o","ó"),c("u","ú"),c("t","l"))
es_confusion <- function(a, b) {
  if (nchar(a) != nchar(b)) return(FALSE)
  ca <- strsplit(a, "")[[1]]; cb <- strsplit(b, "")[[1]]
  d <- which(ca != cb)
  if (length(d) != 1L) return(FALSE)
  any(vapply(CONFUSIONES, function(p) identical(sort(p), sort(c(ca[d], cb[d]))), logical(1)))
}
# Devuelve "F:<vecino>" si el cambio es una confusion tipica, "D:<vecino>" si es
# solo distancia 1, NA si no hay vecino. El prefijo evita dos cachés paralelas.
CACHE <- new.env(parent = emptyenv())
vecino_d1 <- function(w) {
  if (!is.null(CACHE[[w]])) return(CACHE[[w]])
  cand <- LEXICO[abs(LEX_N - nchar(w)) <= 1L]
  r <- NA_character_
  if (length(cand)) {
    cerca <- cand[as.integer(adist(w, cand)) == 1L]
    cerca <- cerca[!(cerca %in% c(paste0(w, "s"), paste0(w, "e"), sub("s$", "", w)))]
    if (length(cerca)) {
      conf <- cerca[vapply(cerca, es_confusion, logical(1), a = w)]
      r <- if (length(conf)) paste0("F:", conf[1]) else paste0("D:", cerca[1])
    }
  }
  assign(w, r, envir = CACHE); r
}

MEMBRETE <- "(?i)^\\s*(superintendenc|gobierno|gobierna|ministerio|de educaci|p[áa]gina \\d+ de \\d+|a[ñn]o: ?\\d{4}|fecha emisi|totalmente tramitado|www\\.|resoluci[óo]n exenta n)"
PESOS <- c(simbolo = 3, letra = 3, corrupta = 3, digito = 2, mayuscula = 2,
           marca = 1, corte = 1, vecina = 1, vocab = 1)
FUERTES <- c("simbolo", "letra", "corrupta", "digito", "mayuscula", "marca")

detectar <- function(linea, prev, sig) {
  m <- character(0); tipos <- character(0)
  add <- function(txt, tipo) { m <<- c(m, txt); tipos <<- c(tipos, tipo) }
  ex <- function(pat) { v <- unique(unlist(stri_extract_all_regex(linea, pat))); v[!is.na(v)] }
  s <- ex(SIMBOLO_RARO)
  if (length(s)) add(sprintf("simbolo ajeno al documento legal: %s",
                             paste(sprintf("'%s'", s), collapse = " ")), "simbolo")
  l <- ex(LETRA_NO_ESPANOLA)
  if (length(l)) add(sprintf("letra fuera del alfabeto espanol: %s",
                             paste(sprintf("'%s'", l), collapse = " ")), "letra")
  dig <- ex("\\p{L}{2,}\\p{N}+|\\p{N}+\\p{L}{2,}")
  if (length(dig)) add(sprintf("digito pegado a palabra (llamada a nota): %s",
                               paste(dig, collapse = ", ")), "digito")
  if (!stri_detect_regex(linea, "^[^\\p{Ll}]*$")) {
    may <- ex("\\p{L}*\\p{Ll}\\p{Lu}\\p{L}*")
    if (length(may)) add(sprintf("mayuscula intercalada: %s", paste(may, collapse = ", ")), "mayuscula")
  }
  pals <- tokenizar(linea)
  fuera <- unique(pals[nchar(pals) >= 5L & !(pals %in% LEXICO)])
  if (length(fuera)) {
    vec <- vapply(fuera, vecino_d1, character(1))
    fuerte <- fuera[!is.na(vec) & startsWith(vec, "F:")]
    debil  <- fuera[!is.na(vec) & startsWith(vec, "D:")]
    nuevas <- fuera[is.na(vec)]
    if (length(fuerte)) add(sprintf("confusion tipica del reconocedor: %s",
      paste(sprintf("%s -> %s", fuerte, substring(vec[fuerte], 3)), collapse = ", ")), "corrupta")
    if (length(debil)) add(sprintf("a un caracter de una palabra del corpus: %s",
      paste(sprintf("%s -> %s", debil, substring(vec[debil], 3)), collapse = ", ")), "vecina")
    if (length(nuevas)) add(sprintf("vocabulario no visto en el corpus: %s",
      paste(nuevas, collapse = ", ")), "vocab")
  }
  perdidas <- unique(pals[pals %in% names(SIN_MARCA)])
  if (length(perdidas)) add(sprintf("tilde o enie perdida: %s",
    paste(sprintf("%s -> %s", perdidas, SIN_MARCA[perdidas]), collapse = ", ")), "marca")
  txt <- trimws(linea)
  if (nchar(txt) > 0L && nchar(txt) < 25L && !stri_detect_regex(txt, "[.;:]$") &&
      nchar(trimws(prev)) >= 60L && nchar(trimws(sig)) >= 60L)
    add("linea corta sin cierre entre dos lineas largas (posible corte)", "corte")
  list(motivos = m, tipos = tipos, peso = sum(PESOS[tipos]))
}

analizar_lineas <- function(ls_, etiqueta) {
  filas <- list()
  for (i in seq_along(ls_)) {
    if (!nzchar(trimws(ls_[i]))) next
    d <- detectar(ls_[i], if (i > 1L) ls_[i - 1L] else "", if (i < length(ls_)) ls_[i + 1L] else "")
    if (!length(d$motivos)) next
    filas[[length(filas) + 1L]] <- list(ruta = sprintf("%s:%d", etiqueta, i), linea = ls_[i],
      motivos = paste(d$motivos, collapse = " · "), tipos = d$tipos, peso = d$peso,
      membrete = stri_detect_regex(ls_[i], MEMBRETE))
  }
  filas
}

analizar <- function(carpeta) {
  archivos <- sort(list.files(carpeta, pattern = "^pagina_\\d+\\.txt$", full.names = TRUE))
  filas <- list(); n_lineas <- 0L; n_memb <- 0L
  for (a in archivos) {
    ls_ <- readLines(a, warn = FALSE, encoding = "UTF-8")
    n_lineas <- n_lineas + length(ls_)
    n_memb <- n_memb + sum(stri_detect_regex(ls_, MEMBRETE))
    filas <- c(filas, analizar_lineas(ls_, sprintf("%s/%s", basename(carpeta), basename(a))))
  }
  list(carpeta = basename(carpeta), paginas = length(archivos), lineas = n_lineas,
       membretes = n_memb, filas = filas)
}
