# =============================================================================
# a4_volcados_cf.R - FASE 3 (correccion) del encargo v9, agente A4.
# -----------------------------------------------------------------------------
# Hallazgos que atiende: UNI-A4-01 (los volcados cf_*.txt no se conservaron),
# CIT-A4-01 (el cero de `Free` en la pagina de Rate Limiting es falso),
# CIT-A4-02 (el control positivo `ctx.access` no reproduce en 20),
# CIT-A4-03 (el negativo universal sobre account-limits es falso).
#
# Descarga las paginas de developers.cloudflare.com y www.cloudflare.com que
# sostienen enunciados de ausencia en el documento, GUARDA el volcado con
# prefijo a4_ en este mismo laboratorio, y cuenta los patrones con el METODO
# DECLARADO al lado de cada cifra. Cada conteo lleva su control positivo.
# Solo hosts autorizados por el encargo. No sigue redirecciones.
# Acceso a estructuras leidas de disco: siempre [[ ]], nunca $.
# =============================================================================
suppressPackageStartupMessages({library(curl); library(stringr); library(here)})
cat("R:", R.version.string, " fecha:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n\n")

HOSTS_AUTORIZADOS <- c("developers.cloudflare.com", "www.cloudflare.com")
host_de <- function(u) sub("^https?://([^/]+).*$", "\\1", u)

paginas <- list(
  ratelimit      = "https://developers.cloudflare.com/workers/runtime-apis/bindings/rate-limit/",
  workers_access = "https://developers.cloudflare.com/workers/configuration/cloudflare-access/",
  account_limits = "https://developers.cloudflare.com/cloudflare-one/account-limits/",
  idp            = "https://developers.cloudflare.com/cloudflare-one/integrations/identity-providers/",
  otp            = "https://developers.cloudflare.com/cloudflare-one/integrations/identity-providers/one-time-pin/",
  ais_keyword    = "https://developers.cloudflare.com/ai-search/configuration/indexing/keyword-search/",
  streams        = "https://developers.cloudflare.com/workers/runtime-apis/streams/",
  zt_planes      = "https://www.cloudflare.com/plans/zero-trust-services/"
)
malos <- setdiff(unique(vapply(paginas, host_de, "")), HOSTS_AUTORIZADOS)
if (length(malos) > 0) stop("Host no autorizado: ", paste(malos, collapse = ", "))

# ---- METODO DE CONTEO, declarado una vez y usado en todas las cifras ---------
# 1. Descarga: curl HTTP GET, sin seguir redirecciones, timeout 30 s.
# 2. "crudo"  = los bytes tal como llegan.
# 3. "texto"  = el crudo sin <script>/<style>, sin etiquetas y con los espacios
#               colapsados. Es sobre "texto" que se cuentan los patrones.
# 4. Conteo   = str_count() de una expresion regular explicita, y ademas el
#               conteo por LINEAS del volcado guardado, que es lo que devuelve
#               `grep -c`. Las dos convenciones se publican por separado porque
#               dan numeros distintos y el documento las confundia.
a_texto <- function(crudo) {
  x <- str_remove_all(crudo, regex("<script[^>]*>.*?</script>", dotall = TRUE, ignore_case = TRUE))
  x <- str_remove_all(x, regex("<style[^>]*>.*?</style>", dotall = TRUE, ignore_case = TRUE))
  x <- str_replace_all(x, "<[^>]*>", " ")
  str_squish(x)
}
bajar <- function(url) {
  h <- new_handle(followlocation = FALSE, timeout = 30)
  r <- curl_fetch_memory(url, handle = h)
  list(http = r[["status_code"]], crudo = rawToChar(r[["content"]]))
}

destino_dir <- here::here("50_documentacion/andamios/lab_motor_v9")
fecha <- format(Sys.time(), "%Y-%m-%d %H:%M %Z")
volcados <- list()
cat("== Descarga y volcado (prefijo a4_cf_, en lab_motor_v9/) ==\n")
for (nm in names(paginas)) {
  r <- bajar(paginas[[nm]])
  tx <- a_texto(r[["crudo"]])
  # el volcado se guarda con una linea por oracion para que `grep -c` sea util
  lineas <- unlist(str_split(tx, "(?<=[.!?]) (?=[A-Z(])"))
  ruta <- file.path(destino_dir, paste0("a4_cf_", nm, ".txt"))
  writeLines(c(paste0("# fuente: ", paginas[[nm]]),
               paste0("# descargado: ", fecha, "  HTTP ", r[["http"]]),
               paste0("# crudo: ", nchar(r[["crudo"]], type = "bytes"), " bytes | texto sin etiquetas: ",
                      nchar(tx, type = "bytes"), " bytes | lineas: ", length(lineas)),
               lineas), ruta, useBytes = TRUE)
  volcados[[nm]] <- list(url = paginas[[nm]], http = r[["http"]], crudo = r[["crudo"]], texto = tx, ruta = ruta)
  cat(sprintf("%-15s HTTP %s | crudo %8d B | texto %7d B | %4d lineas -> %s\n",
              nm, r[["http"]], nchar(r[["crudo"]], type = "bytes"), nchar(tx, type = "bytes"),
              length(lineas), basename(ruta)))
}

cuenta <- function(nm, patron, ignore = FALSE) {
  pat <- if (inherits(patron, "stringr_fixed")) patron else regex(patron, ignore_case = ignore)
  str_count(volcados[[nm]][["texto"]], pat)
}
cuenta_lineas <- function(nm, patron, ignore = FALSE) {
  l <- readLines(volcados[[nm]][["ruta"]], warn = FALSE)
  l <- l[!startsWith(l, "#")]
  pat <- if (inherits(patron, "stringr_fixed")) patron else regex(patron, ignore_case = ignore)
  sum(str_detect(l, pat))
}

cat("\n== CIT-A4-01  Rate Limiting: el patron `Free` NO da cero ==\n")
cat(sprintf("ocurrencias de \\bfree\\b (may/min indistinta) en texto : %d\n", cuenta("ratelimit", "\\bfree\\b", TRUE)))
cat(sprintf("ocurrencias de \\bFree\\b (sensible a mayusculas)       : %d\n", cuenta("ratelimit", "\\bFree\\b", FALSE)))
cat(sprintf("lineas del volcado que contienen free (indistinta)    : %d\n", cuenta_lineas("ratelimit", "free", TRUE)))
cat("contexto de cada coincidencia (30 car. a cada lado):\n")
for (s in str_extract_all(volcados[["ratelimit"]][["texto"]], regex(".{0,30}\\bfree\\b.{0,30}", ignore_case = TRUE))[[1]]) cat("   ...", s, "...\n")
cat(sprintf("CONTROL POSITIVO `Must be either 10 or 60`            : %d ocurrencia(s)\n",
            cuenta("ratelimit", stringr::fixed("Must be either 10 or 60"))))
cat(sprintf("CONTROL NEGATIVO `zzz-a4-control-negativo`           : %d (esperado 0)\n",
            cuenta("ratelimit", stringr::fixed("zzz-a4-control-negativo"))))
cat(sprintf("plan de disponibilidad del binding: `Workers Free`    : %d | `Workers Paid`: %d\n",
            cuenta("ratelimit", stringr::fixed("Workers Free")), cuenta("ratelimit", stringr::fixed("Workers Paid"))))

cat("\n== CIT-A4-02  Access para Workers: dos ceros y su control ==\n")
cat(sprintf("\\bzone\\b (indistinta) en texto : %d\n", cuenta("workers_access", "\\bzone\\b", TRUE)))
cat(sprintf("\\bzone\\b (indistinta) en crudo : %d\n",
            str_count(volcados[["workers_access"]][["crudo"]], regex("\\bzone\\b", ignore_case = TRUE))))
cat(sprintf("\\bfree\\b (indistinta) en texto : %d\n", cuenta("workers_access", "\\bfree\\b", TRUE)))
cat(sprintf("CONTROL POSITIVO ctx\\.access   : %d ocurrencias en texto\n", cuenta("workers_access", "ctx\\.access", FALSE)))
cat(sprintf("CONTROL NEGATIVO zzzaccess     : %d (esperado 0)\n", cuenta("workers_access", stringr::fixed("zzzaccess"))))

cat("\n== CIT-A4-03  account-limits: la pagina SI distingue planes, fuera de la tabla de Access ==\n")
cat(sprintf("\\bFree\\b (sensible) en texto : %d\n", cuenta("account_limits", "\\bFree\\b", FALSE)))
cat("contexto de cada coincidencia (60 car. a cada lado):\n")
for (s in str_extract_all(volcados[["account_limits"]][["texto"]], ".{0,60}\\bFree\\b.{0,60}")[[1]]) cat("   ...", s, "...\n")
cat(sprintf("CONTROL POSITIVO `Applications 500` : %d ocurrencia(s)\n",
            cuenta("account_limits", stringr::fixed("Applications 500"))))
cat(sprintf("CONTROL NEGATIVO `Applications 501` : %d (esperado 0)\n",
            cuenta("account_limits", stringr::fixed("Applications 501"))))

cat("\n== §1.2 idp/otp: `plan` sin mencion de restriccion ==\n")
for (nm in c("idp", "otp")) {
  cat(sprintf("%s: \\bplan(s)?\\b = %d ; contexto:\n", nm, cuenta(nm, "\\bplans?\\b", TRUE)))
  ctx <- str_extract_all(volcados[[nm]][["texto"]], regex(".{0,50}\\bplans?\\b.{0,50}", ignore_case = TRUE))[[1]]
  if (length(ctx) == 0) cat("   (sin coincidencias)\n") else for (s in ctx) cat("   ...", s, "...\n")
}
cat(sprintf("CONTROL POSITIVO otp `expires 10 minutes` : %d\n", cuenta("otp", stringr::fixed("expires 10 minutes"))))
cat(sprintf("CONTROL POSITIVO idp `identity`           : %d\n", cuenta("idp", "\\bidentity\\b", TRUE)))

cat("\n== §7 keyword-search: `language` y el control `porter` ==\n")
cat(sprintf("\\blanguage\\b = %d ; contexto:\n", cuenta("ais_keyword", "\\blanguage\\b", TRUE)))
for (s in str_extract_all(volcados[["ais_keyword"]][["texto"]], regex(".{0,45}\\blanguage\\b.{0,45}", ignore_case = TRUE))[[1]]) cat("   ...", s, "...\n")
cat(sprintf("CONTROL POSITIVO `porter` = %d | CONTROL NEGATIVO `zzz` = %d (esperado 0)\n",
            cuenta("ais_keyword", "\\bporter\\b", TRUE), cuenta("ais_keyword", stringr::fixed("zzz"))))

cat("\n== CIT-A4-04  Streams: la cita NO es contigua ==\n")
# La extraccion de texto separa los tokens que el HTML resaltaba con <span>:
# "fetch (request)". Se normaliza el espacio ANTES de un parentesis de apertura
# para comparar codigo, y se declara la normalizacion aqui.
norm_codigo <- function(s) str_squish(str_replace_all(s, " +\\(", "("))
tx  <- norm_codigo(volcados[["streams"]][["texto"]])
m1  <- "const response = await fetch(request);"
m2  <- "return new Response(response.body, response);"
contigua <- paste(m1, m2)
cat(sprintf("cita pegada tal como estaba (las dos mitades contiguas): %s  <- el defecto\n",
            str_detect(tx, stringr::fixed(contigua))))
cat(sprintf("mitad 1 `%s` : %d ocurrencia(s)\n", m1, str_count(tx, stringr::fixed(m1))))
cat(sprintf("mitad 2 `%s` : %d ocurrencia(s)\n", m2, str_count(tx, stringr::fixed(m2))))
i <- str_locate(tx, stringr::fixed(m1))
cat("bloque real, 150 caracteres desde la mitad 1 (se ve el comentario intercalado):\n")
cat("   ...", substr(tx, i[[1]], i[[1]] + 150), "...\n")
cat(sprintf("cita CORREGIDA con marcador de elision, mitad 1 + [...] + mitad 2: ambas presentes = %s\n",
            str_detect(tx, stringr::fixed(m1)) && str_detect(tx, stringr::fixed(m2))))
cat(sprintf("CONTROL NEGATIVO `return new Response(response.body, respuesta);` : %d (esperado 0)\n",
            str_count(tx, stringr::fixed("return new Response(response.body, respuesta);"))))

cat("\n== C22 zero-trust-services: el universal de ausencia (reemplaza buscar_usuarios.R) ==\n")
crudo_zt <- volcados[["zt_planes"]][["crudo"]]
cat(sprintf("HTML crudo: %d bytes (la cifra exacta cambia entre dias: identificadores de build)\n",
            nchar(crudo_zt, type = "bytes")))
for (p in c("\\busers\\b", "\\bseats?\\b", "50 users", "Up to")) {
  cat(sprintf("  patron %-14s -> %d ocurrencia(s) en crudo\n", p, str_count(crudo_zt, regex(p, ignore_case = TRUE))))
}
cat("contexto de cada `users` en crudo (40 car. a cada lado):\n")
for (s in str_extract_all(crudo_zt, regex(".{0,40}\\busers\\b.{0,40}", ignore_case = TRUE))[[1]]) cat("   ...", str_squish(s), "...\n")
cat(sprintf("CONTROL POSITIVO `cloudflare` en crudo : %d | CONTROL NEGATIVO `zzzqx` : %d (esperado 0)\n",
            str_count(crudo_zt, regex("cloudflare", ignore_case = TRUE)), str_count(crudo_zt, stringr::fixed("zzzqx"))))

cat("\n== Volcados conservados ==\n")
for (nm in names(volcados)) cat(sprintf("  %s\n", volcados[[nm]][["ruta"]]))
