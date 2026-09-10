# =============================================================================
# medir_buscador.R - mide el buscador que se publica, contra el conjunto de
# evaluacion de tests/consultas_evaluacion.R.
# -----------------------------------------------------------------------------
# SOLO LECTURA sobre el repositorio: levanta un servidor HTTP local sobre el
# sitio YA construido, consulta su indice Pagefind y escribe unicamente en el
# directorio de trabajo (no versionado) que recibe por --salida.
# NO regenera el sitio: no llama a 00_run_all.R ni a 30_procesamiento/.
#
# Reparto de responsabilidades: tests/consulta_pagefind.mjs habla con el indice y
# devuelve JSON crudo; TODA la evaluacion (orden, tope, posiciones, MRR, recall)
# se hace aqui, en R.
#
# Uso, desde la raiz del repositorio:
#   Rscript tests/medir_buscador.R
#   Rscript tests/medir_buscador.R --sitio 40_salidas/sitio
#   Rscript tests/medir_buscador.R --sitio 40_salidas/sitio --modo replica
#   Rscript tests/medir_buscador.R --consultas <ruta.R>   (control positivo)
#
# Argumentos:
#   --sitio <ruta>      directorio del sitio construido. Por defecto 40_salidas/sitio
#   --modo replica      reproduce PagefindUI v1.5.2 (la linea base del v9)
#   --consultas <ruta>  archivo R que define CONSULTAS_EVALUACION. Existe para el
#                       control positivo adversarial: se mide con una copia del
#                       conjunto que tiene un ancla esperada corrompida y el
#                       instrumento debe bajar la cifra. Sin un argumento asi el
#                       control no se puede correr sin editar el arbol.
#   --salida <dir>      directorio de trabajo. Por defecto
#                       50_documentacion/andamios/lab_motor_v9/salida_v11
# =============================================================================

source(here::here("10_utils", "10_utils.R"))
instalar_si_falta(c("jsonlite", "dplyr", "tibble", "stringr", "here", "fs", "servr", "stringi"))
source(here::here("10_utils", "10_configuracion.R"))

suppressPackageStartupMessages({
  library(dplyr); library(tibble); library(stringr)
})

# Sin esto print() parte la tabla consulta por consulta en bloques de columnas y
# deja de poder leerse de un vistazo, que es lo unico que esa tabla tiene que hacer.
options(width = 200)

# ---- Argumentos -------------------------------------------------------------
args <- commandArgs(trailingOnly = TRUE)
valor_arg <- function(nombre, defecto) {
  i <- match(nombre, args)
  if (is.na(i) || i >= length(args)) defecto else args[[i + 1L]]
}
absoluta <- function(p) if (fs::is_absolute_path(p)) p else here::here(p)

SITIO     <- absoluta(valor_arg("--sitio", "40_salidas/sitio"))
MODO      <- valor_arg("--modo", "actual")
CONSULTAS <- absoluta(valor_arg("--consultas", "tests/consultas_evaluacion.R"))
DIR_SAL   <- absoluta(valor_arg("--salida",
                                "50_documentacion/andamios/lab_motor_v9/salida_v11"))
stopifnot(MODO %in% c("actual", "replica"))
fs::dir_create(DIR_SAL)

# ---- Constantes de presentacion --------------------------------------------
# Desde el encargo v11 (T2) NO se duplican: vienen de 10_utils/10_configuracion.R,
# que es de donde 34_generar_paginas.R las inyecta en la copia publicada de
# busqueda.html. La pagina y este instrumento leen los mismos numeros de la misma
# fuente, que es la unica forma de que la cifra medida sea la del sitio.
# (La marca de pendiente que T4 dejo en estas lineas se retira en este encargo.)
stopifnot(exists("TOPE_SUB_RESULTADOS"), exists("PAGINA_RESULTADOS"),
          exists("TOPE_VARIANTES_CONSULTA"), exists("TOPE_PAGINAS_POR_VARIANTE"),
          exists("MAX_TOKENS_ALIAS"), exists("LARGO_RAIZ_ALIAS"),
          exists("ALIAS_CONSULTA"), exists("PALABRAS_VACIAS_CONSULTA"),
          exists("RAICES_COMUNES_ALIAS"))
PAGINA <- PAGINA_RESULTADOS
# Tope del bundle PagefindUI v1.5.2, escrito en el cuerpo de su funcion de
# recorte (`slice(0,3)`), no en un parametro. Solo aplica en --modo replica, que
# reproduce el estado ANTERIOR al v10: sin interfaz propia y sin expansion.
TOPE_REPLICA        <- 3L
# K de la lista cruda, para separar "no se recupero" de "no se mostro".
K_RECALL            <- c(30L, 65L, 100L)

# ---- Expansion de la consulta: la misma de busqueda.html, en R --------------
# Reimplementada, no copiada: si las dos implementaciones coinciden en la cifra,
# la coincidencia significa algo. Se apaga en --modo replica.

PISO_R0 <- !any(commandArgs(trailingOnly = TRUE) == "--sin-piso-r0")
EXPANDIR <- !identical(MODO, "replica") && TOPE_VARIANTES_CONSULTA > 0L
plegar_c <- function(s) tolower(stringi::stri_trans_general(s, "Latin-ASCII"))
raiz_c   <- function(w) substr(w, 1L, pmin(nchar(w), LARGO_RAIZ_ALIAS))
trocear_c <- function(s) {
  t <- strsplit(plegar_c(s), "[^a-z0-9]+")[[1]]
  t <- t[nchar(t) >= 3L]
  t[!(t %in% PALABRAS_VACIAS_CONSULTA)]
}

# ---- Precondiciones ---------------------------------------------------------
RUNNER <- here::here("tests", "consulta_pagefind.mjs")
PAGEFIND_JS <- fs::path(SITIO, "pagefind", "pagefind.js")
NODE <- Sys.which("node")
stopifnot(fs::dir_exists(SITIO), fs::file_exists(PAGEFIND_JS),
          fs::file_exists(RUNNER), nzchar(NODE))

source(CONSULTAS)
stopifnot(exists("CONSULTAS_EVALUACION"))
EV   <- CONSULTAS_EVALUACION
HIST <- EV[EV[["clase"]] == "historica", ]
SINR <- EV[EV[["clase"]] == "sin_respuesta", ]

# Variantes de expansion por consulta. Se calculan aqui, despues de cargar el
# conjunto de evaluacion, y se anexan al lote que viaja al runner.
# La tabla de alias y sus indices se arman AQUI y no arriba: tests/consultas_evaluacion.R
# vuelve a cargar 10_utils/10_configuracion.R, de modo que cualquier sustitucion
# hecha antes quedaba pisada y los indices derivados apuntaban a una tabla que ya
# no estaba. Lo destapo el caso malo plantado de T2, que no disparaba ni una
# variante.
# Dos afordancias SOLO de medicion, sin efecto sobre el sitio publicado:
#   --alias <ruta.R>  sustituye ALIAS_CONSULTA por la del archivo indicado. Sirve
#                     para el caso malo plantado sin editar el arbol.
#   --sin-piso-r0     ordena la union solo por puntaje, sin la precedencia de la
#                     consulta original. Existe para DEMOSTRAR que el piso R0 es
#                     lo que impide los retrocesos: sin el, un alias adversarial
#                     si hace retroceder una consulta, y con el no.
ALIAS_ALT <- valor_arg("--alias", NA_character_)
if (!is.na(ALIAS_ALT)) {
  source(absoluta(ALIAS_ALT))
  message("ALIAS_CONSULTA sustituida desde ", ALIAS_ALT, ": ", nrow(ALIAS_CONSULTA), " filas")
}

.tok_alias <- lapply(ALIAS_CONSULTA[["alias"]], trocear_c)
.raices_entrada <- lapply(split(.tok_alias, ALIAS_CONSULTA[["entrada"]]), function(l) {
  r <- unique(raiz_c(unlist(l))); r[!(r %in% RAICES_COMUNES_ALIAS)]
})
variantes_de <- function(consulta) {
  if (!EXPANDIR) return(character(0))
  qt <- unique(raiz_c(trocear_c(consulta)))
  pj <- vapply(.raices_entrada, function(r) length(intersect(r, qt)), integer(1))
  ent <- names(pj)[pj > 0L]
  if (!length(ent)) return(character(0))
  ent <- ent[order(-pj[ent], ent)]
  qp <- plegar_c(consulta); salida <- character(0)
  for (e in ent) {
    a <- ALIAS_CONSULTA[["alias"]][ALIAS_CONSULTA[["entrada"]] == e]
    nt <- vapply(a, function(z) length(trocear_c(z)), integer(1))
    a <- plegar_c(a[order(-nt, a)])
    for (z in a) {
      if (identical(z, qp) || z %in% salida) next
      salida <- c(salida, z)
      if (length(salida) >= TOPE_VARIANTES_CONSULTA) return(salida)
    }
  }
  salida
}

VARIANTES <- setNames(lapply(EV[["consulta"]], variantes_de), EV[["id"]])

# ---- Servidor HTTP local ----------------------------------------------------
# Pagefind resuelve su indice por HTTP: sobre file:// el modulo no carga. Patron
# tomado de lab_motor_v9/a2_correcciones_fase3.R (lineas 390-430).
codigo_http <- function(url) {
  cod <- tryCatch(suppressWarnings(
    system2("curl", c("-s", "-o", "/dev/null", "-w", "%{http_code}", url),
            stdout = TRUE, stderr = FALSE)), error = function(e) "")
  if (length(cod) == 0L) "" else cod[[1L]]
}
puerto_libre <- function(candidatos) {
  for (p in candidatos) {
    if (!identical(codigo_http(sprintf("http://127.0.0.1:%d/index.html", p)), "200")) return(p)
  }
  stop("ningun puerto candidato esta libre: ", paste(candidatos, collapse = ", "))
}
PUERTO <- puerto_libre(8811:8830)
BASE   <- sprintf("http://127.0.0.1:%d/", PUERTO)

cmd_r <- sprintf("servr::httd(%s, port = %d, daemon = FALSE, browser = FALSE, verbose = FALSE)",
                 deparse(SITIO), PUERTO)
interno <- paste0(shQuote(fs::path(R.home("bin"), "Rscript")), " -e ", shQuote(cmd_r),
                  " >/dev/null 2>&1 & echo $!")
PID <- as.integer(system2("sh", c("-c", shQuote(interno)), stdout = TRUE))

# Sin esto un fallo de la medicion deja el servidor vivo ocupando el puerto, y la
# corrida siguiente mide contra un sitio que puede no ser el que le pidieron.
# NO se usa on.exit(): en Rscript, on.exit() en el nivel superior se asocia a la
# expresion de nivel superior en curso y no al fin del script, de modo que no
# dispara nunca al terminar (verificado: dos corridas dejaron dos servidores
# vivos, 8811 y 8812). tryCatch(finally=) si dispara, y tambien con error.
detener_servidor <- function(pid) {
  if (is.na(pid)) return(invisible(NULL))
  suppressWarnings(tools::pskill(pid))
  Sys.sleep(0.3)
  vive <- system2("ps", c("-p", pid), stdout = FALSE, stderr = FALSE) == 0L
  cat("\nservidor local detenido (PID ", pid, "; sigue vivo: ", vive, ")\n", sep = "")
}

tryCatch({

esperas <- 0L
while (!identical(codigo_http(paste0(BASE, "index.html")), "200") && esperas < 120L) {
  Sys.sleep(0.5); esperas <- esperas + 1L
}
if (!identical(codigo_http(paste0(BASE, "index.html")), "200")) {
  stop("el servidor local no respondio 200 en ", BASE, " tras ", esperas, " esperas")
}

# ---- Consulta ---------------------------------------------------------------
sufijo  <- paste0(MODO, "_", basename(SITIO))
ENTRADA <- fs::path(DIR_SAL, paste0("consultas_entrada_", sufijo, ".json"))
SALIDA  <- fs::path(DIR_SAL, paste0("pagefind_crudo_", sufijo, ".json"))

jsonlite::write_json(
  c(lapply(seq_len(nrow(EV)), function(i) list(id = EV[["id"]][[i]], consulta = EV[["consulta"]][[i]])),
    unlist(lapply(names(VARIANTES), function(id) lapply(seq_along(VARIANTES[[id]]),
      function(j) list(id = sprintf("%s__v%02d", id, j), consulta = VARIANTES[[id]][[j]]))),
      recursive = FALSE, use.names = FALSE)),
  ENTRADA, auto_unbox = TRUE, pretty = TRUE)

salida_node <- system2(NODE, c("--no-warnings", shQuote(RUNNER), shQuote(ENTRADA),
                               shQuote(SALIDA), shQuote(paste0(BASE, "pagefind/")),
                               shQuote(PAGEFIND_JS)),
                       stdout = TRUE, stderr = TRUE)
if (!fs::file_exists(SALIDA)) stop("el runner no escribio ", SALIDA, ": ",
                                   paste(salida_node, collapse = " | "))
CRUDO <- jsonlite::fromJSON(SALIDA, simplifyVector = FALSE)

# ---- Orden y tope: la misma logica de busqueda.html, reimplementada en R ----
# El sitio devuelve "/archivo.html#ancla" y el conjunto de evaluacion escribe
# "archivo.html#ancla". Sin normalizar, TODO daria ausente y el cero seria del
# comparador. El sitio es plano: basta el nombre de archivo.
norm <- function(u) sub("^.*/", "", sub("^/+", "", sub("^https?://[^/]+", "", u)))

peso_sub  <- function(s) {
  v <- vapply(s[["weighted_locations"]], function(l) as.numeric(l[["balanced_score"]]), numeric(1))
  if (length(v) == 0L) 0 else sum(v)
}
mejor_sub <- function(s) {
  v <- vapply(s[["weighted_locations"]], function(l) as.numeric(l[["balanced_score"]]), numeric(1))
  if (length(v) == 0L) 0 else max(v)
}
n_wl_sub  <- function(s) length(s[["weighted_locations"]])

# busqueda.html: suma de balanced_score, desempate por el maximo, ultimo
# desempate por orden de documento.
ordenar_actual <- function(subs) {
  if (length(subs) <= 1L) return(subs)
  p <- vapply(subs, peso_sub, numeric(1))
  m <- vapply(subs, mejor_sub, numeric(1))
  subs[order(-p, -m, seq_along(subs))]
}
# PagefindUI v1.5.2: si hay mas de 3, elige los 3 con MAS weighted_locations y
# los devuelve en ORDEN DE DOCUMENTO (el filter del bundle preserva la entrada).
ordenar_replica <- function(subs) {
  if (length(subs) <= TOPE_REPLICA) return(subs)
  n <- vapply(subs, n_wl_sub, integer(1))
  u <- vapply(subs, function(s) as.character(s[["url"]]), character(1))
  elegidas <- u[order(-n, seq_along(n))][seq_len(TOPE_REPLICA)]
  subs[u %in% elegidas]
}

# Lo que la interfaz muestra de una pagina de resultado.
mostrados_de <- function(pg) {
  subs <- pg[["sub_results"]]
  url_pagina <- if (is.null(pg[["meta_url"]])) pg[["url"]] else pg[["meta_url"]]
  # El primer sub-resultado repite la pagina cuando la coincidencia cae antes del
  # primer encabezado con id; la interfaz lo descarta.
  if (length(subs) > 0L && identical(subs[[1L]][["url"]], url_pagina)) subs <- subs[-1L]
  if (length(subs) == 0L) return(character(0))
  ord <- if (MODO == "replica") ordenar_replica(subs) else ordenar_actual(subs)
  tope <- if (MODO == "replica") TOPE_REPLICA else TOPE_SUB_RESULTADOS
  vapply(head(ord, tope), function(s) norm(as.character(s[["url"]])), character(1))
}

# Lista mostrada: primeras PAGINA paginas (la primera tanda), y dentro de cada
# una los sub-resultados ordenados y recortados. Es lo que el usuario ve.
lista_mostrada <- function(cq) {
  pgs <- head(cq[["resultados"]], PAGINA)
  if (length(pgs) == 0L) return(character(0))
  unlist(lapply(pgs, mostrados_de), use.names = FALSE)
}
# Lista cruda: TODOS los sub-resultados de TODAS las paginas, sin descarte ni
# tope. Separa "no se recupero" de "no se mostro". Se reporta bajo los DOS
# ordenes defendibles, porque el rango del ancla cambia mucho entre ellos y el
# encargo no fija cual:
#   "entrega"    - el orden en que Pagefind los devuelve: rango de pagina (que si
#                  esta puntuado) y, dentro de cada pagina, orden de documento
#                  (Pagefind NO puntua los sub-resultados entre si).
#   "relevancia" - todos los sub-resultados del conjunto reordenados por suma de
#                  balanced_score y, a igualdad, por rango de pagina. Es la lista
#                  de candidatos que un reordenador de capa 2 recibiria.
lista_cruda <- function(cq, orden = c("entrega", "relevancia")) {
  orden <- match.arg(orden)
  if (length(cq[["resultados"]]) == 0L) return(character(0))
  planos <- unlist(lapply(cq[["resultados"]], function(pg)
    lapply(pg[["sub_results"]], function(s)
      list(url = norm(as.character(s[["url"]])),
           peso = peso_sub(s),
           rango_pagina = as.integer(pg[["rango_pagina"]])))),
    recursive = FALSE, use.names = FALSE)
  if (identical(orden, "relevancia")) {
    p <- vapply(planos, function(x) x[["peso"]], numeric(1))
    g <- vapply(planos, function(x) x[["rango_pagina"]], integer(1))
    planos <- planos[order(-p, g, seq_along(planos))]
  }
  vapply(planos, function(x) x[["url"]], character(1))
}

# ---- Union por pagina: el piso R0 de busqueda.html, reimplementado ----------
# Las paginas de la consulta ORIGINAL van primero, siempre (no solo ante empate):
# asi una expansion mala solo agrega ruido debajo y ninguna consulta que hoy
# funciona puede retroceder. Cada variante aporta a lo mas
# TOPE_PAGINAS_POR_VARIANTE paginas, para que un alias amplio no inunde la lista.
crudo_por_id <- setNames(CRUDO[["consultas"]],
                         vapply(CRUDO[["consultas"]], function(q) as.character(q[["id"]]), character(1)))
unir_expansion <- function(id) {
  base_q <- crudo_por_id[[id]]
  if (!EXPANDIR || !length(VARIANTES[[id]])) return(base_q)
  claves <- character(0); acc <- list(); es_orig <- logical(0); sc <- numeric(0)
  agrega <- function(r, orig) {
    k <- norm(as.character(r[["url"]])); s <- as.numeric(r[["score"]])
    i <- match(k, claves)
    if (is.na(i)) { claves <<- c(claves, k); acc[[length(acc)+1L]] <<- r
                    es_orig <<- c(es_orig, orig); sc <<- c(sc, s)
    } else if (!es_orig[[i]] && !orig && s > sc[[i]]) { acc[[i]] <<- r; sc[[i]] <<- s }
  }
  for (r in base_q[["resultados"]]) agrega(r, TRUE)
  for (j in seq_along(VARIANTES[[id]])) {
    q <- crudo_por_id[[sprintf("%s__v%02d", id, j)]]
    if (is.null(q)) next
    for (r in head(q[["resultados"]], TOPE_PAGINAS_POR_VARIANTE)) agrega(r, FALSE)
  }
  if (!length(acc)) return(base_q)
  o <- if (PISO_R0) order(-as.integer(es_orig), -sc, seq_along(acc)) else order(-sc, seq_along(acc))
  acc <- acc[o]
  for (i in seq_along(acc)) acc[[i]][["rango_pagina"]] <- i
  base_q[["resultados"]] <- acc
  base_q[["n_resultados"]] <- length(acc)
  base_q
}
por_id <- setNames(lapply(EV[["id"]], unir_expansion), EV[["id"]])
posicion <- function(lista, ancla) {
  i <- match(ancla, lista)
  if (is.na(i)) NA_integer_ else as.integer(i)
}

# ---- Evaluacion de las historicas -------------------------------------------
hist_res <- bind_rows(lapply(seq_len(nrow(HIST)), function(i) {
  idc  <- HIST[["id"]][[i]]
  cq   <- por_id[[idc]]
  esp  <- norm(HIST[["ancla_esperada"]][[i]])
  conj <- norm(trimws(strsplit(HIST[["anclas_conjunto"]][[i]], ";", fixed = TRUE)[[1L]]))
  mos  <- lista_mostrada(cq)
  cr_e <- lista_cruda(cq, "entrega")
  cr_r <- lista_cruda(cq, "relevancia")
  r <- tibble(
    id = idc,
    consulta = HIST[["consulta"]][[i]],
    ancla_esperada = esp,
    n_paginas = as.integer(cq[["n_resultados"]]),
    n_mostrados = length(mos),
    posicion = posicion(mos, esp),
    rango_entrega = posicion(cr_e, esp),
    rango_relevancia = posicion(cr_r, esp),
    n_crudos = length(cr_e),
    n_conjunto = length(conj),
    conjunto_mostradas = sum(conj %in% mos),
    ms_busqueda = as.numeric(cq[["ms_busqueda"]])
  )
  for (k in K_RECALL) {
    r[[paste0("rec_ent_", k)]] <- !is.na(r[["rango_entrega"]])    & r[["rango_entrega"]]    <= k
    r[[paste0("rec_rel_", k)]] <- !is.na(r[["rango_relevancia"]]) & r[["rango_relevancia"]] <= k
  }
  r
}))

n_resueltas <- sum(!is.na(hist_res[["posicion"]]))
mrr <- mean(ifelse(is.na(hist_res[["posicion"]]), 0, 1 / hist_res[["posicion"]]))

# ---- Evaluacion de la clase sin_respuesta -----------------------------------
sin_res <- bind_rows(lapply(seq_len(nrow(SINR)), function(i) {
  idc <- SINR[["id"]][[i]]; cq <- por_id[[idc]]
  tibble(id = idc, consulta = SINR[["consulta"]][[i]],
         n_paginas = as.integer(cq[["n_resultados"]]),
         n_mostrados = length(lista_mostrada(cq)),
         lista_vacia = as.integer(cq[["n_resultados"]]) == 0L,
         ms_busqueda = as.numeric(cq[["ms_busqueda"]]))
}))

# ---- Reporte ----------------------------------------------------------------
cat("=============================================================\n")
cat("MEDICION DEL BUSCADOR -- modo:", MODO, "\n")
cat("=============================================================\n")
cat("sitio:      ", SITIO, "\n")
cat("consultas:  ", CONSULTAS, "\n")
cat("servidor:   ", BASE, " (PID ", PID, ", listo tras ", esperas, " esperas de 0,5 s)\n", sep = "")
cat("node:       ", paste(salida_node, collapse = " | "), "\n")
cat("constantes: ",
    if (MODO == "replica") sprintf("TOPE_REPLICA = %d", TOPE_REPLICA)
    else sprintf("TOPE_SUB_RESULTADOS = %d", TOPE_SUB_RESULTADOS),
    sprintf(" | PAGINA = %d", PAGINA), "\n", sep = "")
cat("\n")

cat("resueltas: ", n_resueltas, " de ", nrow(HIST), "\n", sep = "")
cat("MRR (sobre las ", nrow(HIST), "): ", format(round(mrr, 4), nsmall = 4), "\n\n", sep = "")

tabla <- hist_res |>
  transmute(
    id,
    consulta = substr(.data[["consulta"]], 1, 46),
    ancla_esperada,
    posicion = ifelse(is.na(.data[["posicion"]]), "ausente", as.character(.data[["posicion"]])),
    paginas = .data[["n_paginas"]],
    mostrados = .data[["n_mostrados"]],
    conjunto = paste0(.data[["conjunto_mostradas"]], " de ", .data[["n_conjunto"]]),
    r_entrega = ifelse(is.na(.data[["rango_entrega"]]), "ausente", as.character(.data[["rango_entrega"]])),
    r_relev = ifelse(is.na(.data[["rango_relevancia"]]), "ausente", as.character(.data[["rango_relevancia"]])),
    crudos = .data[["n_crudos"]],
    ms = .data[["ms_busqueda"]])
cat("--- Consulta por consulta (clase historica) ---\n")
cat("  posicion  = lugar del ancla esperada en la lista MOSTRADA (paginas 1..PAGINA,\n")
cat("              sub-resultados ya ordenados y recortados), aplanada; 'ausente' si no sale.\n")
cat("  r_entrega = rango en la lista cruda tal como Pagefind la entrega.\n")
cat("  r_relev   = rango en la lista cruda reordenada por suma de balanced_score.\n")
print(as.data.frame(tabla), row.names = FALSE)

cat("\n--- recall@K de la lista cruda (ancla esperada, todas las paginas) ---\n")
for (k in K_RECALL) {
  cat(sprintf("  recall@%-3d  orden de entrega: %d de %d | orden por relevancia: %d de %d\n", k,
              sum(hist_res[[paste0("rec_ent_", k)]]), nrow(HIST),
              sum(hist_res[[paste0("rec_rel_", k)]]), nrow(HIST)))
}

cat("\n--- Cobertura del conjunto de anclas ---\n")
cat("  anclas del conjunto mostradas: ", sum(hist_res[["conjunto_mostradas"]]),
    " de ", sum(hist_res[["n_conjunto"]]), "\n", sep = "")
cat("  consultas con al menos una del conjunto mostrada: ",
    sum(hist_res[["conjunto_mostradas"]] > 0L), " de ", nrow(HIST), "\n", sep = "")

cat("\n--- Clase sin_respuesta (linea base: el estado vacio todavia no existe) ---\n")
print(as.data.frame(sin_res), row.names = FALSE)
cat("  devuelven lista vacia: ", sum(sin_res[["lista_vacia"]]), " de ", nrow(SINR), "\n", sep = "")
cat("  devuelven resultados:  ", sum(!sin_res[["lista_vacia"]]), " de ", nrow(SINR), "\n", sep = "")

cat("\n--- Latencia por consulta (ms, la que devuelve el runner) ---\n")
lat <- bind_rows(hist_res[, c("id", "ms_busqueda")], sin_res[, c("id", "ms_busqueda")])
print(as.data.frame(lat), row.names = FALSE)
cat(sprintf("  min %.2f | mediana %.2f | max %.2f\n",
            min(lat[["ms_busqueda"]]), median(lat[["ms_busqueda"]]), max(lat[["ms_busqueda"]])))

cat("\nJSON crudo:", SALIDA, "\n")

}, finally = detener_servidor(PID))
