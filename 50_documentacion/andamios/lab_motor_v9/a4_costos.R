# =============================================================================
# a4_costos.R - aritmetica de costo de la capa 3 en vivo (A4, encargo v9)
# -----------------------------------------------------------------------------
# NO consume ninguna API. Calcula, no prueba gastando.
# PRECIOS PROVISIONALES (USD por millon de tokens, entrada / salida):
#   fuente: skill `claude-api` de Claude Code leido por el orquestador en esta
#   sesion, tabla de modelos cacheada con fecha 2026-06-24; NO verificada contra
#   docs.claude.com, que redirige a un host no autorizado; verificar con
#   `curl -sIL https://docs.claude.com/en/docs/about-claude/pricing` una vez
#   autorizado el dominio destino. Toda cifra de costo de este script es
#   "calculada sobre precio provisional".
# Largo de articulo: MEDIDO desde 40_salidas/datos/normas/*.json en este mismo
# script (mediana y media de los segmentos con es_articulo == TRUE).
# Regla de tokens: SUPUESTO declarado, 1 token ~ 4 caracteres (no medido con
# un tokenizador). Se muestra sensibilidad a 3 caracteres/token.
# Acceso a estructuras leidas de disco: siempre [[ ]], nunca $.
# =============================================================================
suppressPackageStartupMessages({library(jsonlite); library(dplyr); library(purrr); library(fs); library(here)})
options(width = 120)  # CIF-A4-03: ancho fijo, para que el bloque pegado en el .md sea reproducible
cat("R:", R.version.string, " fecha:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n\n")

precios <- tibble::tribble(
  ~modelo,            ~entrada_musd, ~salida_musd,
  "claude-opus-5",     5.00,          25.00,
  "claude-sonnet-5",   2.00,          10.00,
  "claude-haiku-4-5",  1.00,           5.00
)

# ---- control positivo de la aritmetica: 1M tokens de entrada a 2.00 = 2.00 USD
costo_usd <- function(tok_in, tok_out, p_in, p_out) tok_in / 1e6 * p_in + tok_out / 1e6 * p_out
stopifnot(isTRUE(all.equal(costo_usd(1e6, 0, 2.00, 10.00), 2.00)))
stopifnot(isTRUE(all.equal(costo_usd(0, 1e6, 2.00, 10.00), 10.00)))
cat("control positivo aritmetica: 1M tokens entrada a 2.00 =", costo_usd(1e6, 0, 2, 10), "USD; 1M salida a 10.00 =", costo_usd(0, 1e6, 2, 10), "USD  [OK]\n\n")

# ---- largo medido de los articulos ------------------------------------------
archivos <- dir_ls(here::here("40_salidas/datos/normas"), glob = "*.json")
arts <- map_dfr(archivos, \(f) {
  n <- fromJSON(f, simplifyVector = FALSE)
  tibble(slug = n[["slug"]],
         es_articulo = map_lgl(n[["articulos"]], \(a) isTRUE(a[["es_articulo"]])),
         n_char = map_int(n[["articulos"]], \(a) nchar(a[["texto"]], type = "chars")))
}) |> filter(es_articulo)
mediana_char <- median(arts[["n_char"]]); media_char <- mean(arts[["n_char"]])
cat(sprintf("articulos medidos (es_articulo==TRUE): %d | mediana %.1f car. | media %.1f car.  (CIF-A4-06: sin truncar)\n",
            nrow(arts), mediana_char, media_char))

CHARS_POR_TOKEN <- 4  # supuesto declarado
# CON-A4-08: el supuesto "consulta = 80 tokens" se contrasta con el dato. Las diez
# consultas de evaluacion de A2 se miden aqui mismo (artefacto de laboratorio, no
# el documento de A2), y el maximo medido se publica junto al supuesto.
ruta_q <- here::here("50_documentacion/andamios/lab_motor_v9/a2_consultas_evaluacion.csv")
q_eval <- unique(read.csv(ruta_q, stringsAsFactors = FALSE)[["consulta"]])
TOK_CONSULTA_SUP <- 80L
tok <- function(chars, cpt = CHARS_POR_TOKEN) ceiling(chars / cpt)
cat(sprintf("regla de tokens: 1 token ~ %d caracteres (SUPUESTO) -> articulo mediano ~ %d tokens, medio ~ %d tokens\n",
            CHARS_POR_TOKEN, tok(mediana_char), tok(media_char)))
cat(sprintf("consulta: SUPUESTO %d tokens | MEDIDO sobre las %d consultas de evaluacion de A2: min %d, media %.1f, max %d car. = %d tokens c4 en el peor caso (%.1f veces menos que el supuesto)\n",
            TOK_CONSULTA_SUP, length(q_eval), min(nchar(q_eval)), mean(nchar(q_eval)), max(nchar(q_eval)),
            max(tok(nchar(q_eval))), TOK_CONSULTA_SUP / max(tok(nchar(q_eval)))))
cat(sprintf("  control positivo: la consulta mas larga del conjunto es \"%s\"\n\n", q_eval[[which.max(nchar(q_eval))]]))

# ---- tres tamanos de contexto (supuestos explicitos, la sintesis los cruza con A3)
# prompt del sistema: SUPUESTO (contrato de A3 no leido): 1500 tokens.
# consulta del usuario: SUPUESTO 80 tokens. Envoltorio JSON por articulo (id, etiqueta, norma): SUPUESTO 40 tokens.
# articulos recuperados: se usa la MEDIA medida (la mediana subestima el contexto porque los articulos largos pesan mas).
tamanos <- tibble::tribble(
  ~tamano,   ~n_articulos, ~tok_sistema, ~tok_consulta, ~tok_salida,
  "pequeno",  5,            1500,          80,            500,
  "medio",   10,            1500,          80,            900,
  "grande",  20,            2500,          80,           1500
) |> mutate(
  tok_articulos = n_articulos * (tok(media_char) + 40),
  tok_entrada   = tok_sistema + tok_consulta + tok_articulos
)
cat("== Tamanos de contexto (tokens, regla 4 car./token) ==\n")
print(as.data.frame(tamanos), row.names = FALSE)

# ---- costo por consulta, por modelo y tamano ---------------------------------
por_consulta <- tidyr::crossing(tamanos, precios) |>
  mutate(usd_consulta = costo_usd(tok_entrada, tok_salida, entrada_musd, salida_musd)) |>
  select(tamano, modelo, tok_entrada, tok_salida, usd_consulta) |>
  arrange(factor(tamano, levels = c("pequeno", "medio", "grande")), desc(usd_consulta))
cat("\n== Costo por consulta (USD, calculado sobre precio provisional) ==\n")
print(as.data.frame(por_consulta |> mutate(usd_consulta = round(usd_consulta, 5))), row.names = FALSE)

# ---- escenarios de uso (consultas por mes; supuestos declarados) ------------
# bajo 100: equipo pequeno que consulta esporadicamente (~5/dia habil).
# medio 1000: ~50/dia habil; uso diario real de un equipo de convivencia de ~20 personas.
# alto 5000: ~250/dia habil; techo de planificacion, no proyeccion.
escenarios <- tibble::tribble(~escenario, ~consultas_mes, "bajo", 100L, "medio", 1000L, "alto", 5000L)
mensual <- tidyr::crossing(por_consulta, escenarios) |>
  mutate(usd_mes = usd_consulta * consultas_mes) |>
  select(escenario, consultas_mes, tamano, modelo, usd_mes) |>
  arrange(factor(escenario, levels = c("bajo", "medio", "alto")),
          factor(tamano, levels = c("pequeno", "medio", "grande")), desc(usd_mes))
cat("\n== Costo mensual (USD, calculado sobre precio provisional) ==\n")
print(as.data.frame(mensual |> mutate(usd_mes = round(usd_mes, 3))), row.names = FALSE)

cat("\n== Resumen: tamano 'medio' (10 articulos), los tres modelos, los tres escenarios ==\n")
print(as.data.frame(mensual |> filter(tamano == "medio") |> tidyr::pivot_wider(names_from = modelo, values_from = usd_mes) |> select(-tamano) |> mutate(across(where(is.numeric) & !consultas_mes, \(x) round(x, 2)))), row.names = FALSE)

# ---- sensibilidad: 3 caracteres por token (texto legal en espanol tokeniza peor)
tam3 <- tamanos |> mutate(tok_articulos = n_articulos * (tok(media_char, 3) + 40),
                          tok_entrada = tok_sistema + tok_consulta + tok_articulos)
sens <- tidyr::crossing(tam3, precios) |>
  mutate(usd_consulta = costo_usd(tok_entrada, tok_salida, entrada_musd, salida_musd)) |>
  filter(tamano == "medio") |> select(modelo, tok_entrada, usd_consulta) |>
  mutate(usd_mes_1000 = usd_consulta * 1000)
cat("\n== Sensibilidad: regla 3 car./token, tamano medio, 1000 consultas/mes ==\n")
print(as.data.frame(sens |> mutate(across(c(usd_consulta, usd_mes_1000), \(x) round(x, 4)))), row.names = FALSE)
# CIF-A4-02: el porcentaje de alza se imprime aqui en vez de calcularse a mano al redactar.
base4 <- por_consulta |> filter(tamano == "medio") |> select(modelo, usd_c4 = usd_consulta)
alza <- sens |> select(modelo, usd_c3 = usd_consulta) |> inner_join(base4, by = "modelo") |>
  mutate(alza_pct = 100 * (usd_c3 / usd_c4 - 1))
cat(sprintf("alza de 4 a 3 car./token, tamano medio: %s\n",
            paste(sprintf("%s %+.3f%%", alza[["modelo"]], alza[["alza_pct"]]), collapse = " | ")))
cat(sprintf("  (el alza es la misma para los tres modelos porque es un cociente de tokens: %+.3f%%; redondeada a una decimal, %+.1f%%)\n",
            unique(round(alza[["alza_pct"]], 3)), unique(round(alza[["alza_pct"]], 1))))

# ---- descomposicion en subpreguntas (opcion de A3 punto 9): +1 llamada corta por consulta
# SUPUESTO: la llamada de descomposicion usa sistema 600 + consulta 80 tokens de entrada y 120 de salida, sin articulos.
desc <- precios |> mutate(usd_extra = costo_usd(680, 120, entrada_musd, salida_musd)) |>
  select(modelo, usd_extra_por_consulta = usd_extra) |> mutate(usd_extra_mes_1000 = usd_extra_por_consulta * 1000)
cat("\n== Costo adicional de una llamada de descomposicion por consulta (SUPUESTO 680 in / 120 out) ==\n")
print(as.data.frame(desc |> mutate(across(where(is.numeric), \(x) round(x, 4)))), row.names = FALSE)

# ---- tokens mensuales, para cruzar con cualquier limite de tasa -------------
cat("\n== Tokens de entrada por mes, tamano medio ==\n")
print(as.data.frame(escenarios |> mutate(tok_entrada_mes = consultas_mes * tamanos[["tok_entrada"]][[2]],
                                         tok_salida_mes = consultas_mes * tamanos[["tok_salida"]][[2]])), row.names = FALSE)

# ---- CON-A4-08: costo del tamano de contexto que el diseno de A3 implica --------
# El encargo (§5, tarea 4) pide el costo "segun el tamano de contexto que el diseno
# de A3 implica". A4 no recalcula el contexto de A3: LEE los tokens que A3 publica
# en su propio artefacto de laboratorio y los convierte a USD. Asi el paquete tiene
# una sola aritmetica de contexto por autor y dos columnas de costo, no dos contextos
# en pugna sin decir cual es cual.
ruta_a3 <- here::here("50_documentacion/andamios/lab_motor_v9/a3_presupuesto_tokens_salida.txt")
lin_a3 <- readLines(ruta_a3, warn = FALSE)
# filas de la tabla de A3: "<escenario> <llamadas> <tokens_entrada> <tokens_salida>"
pat_a3 <- "^\\s*(.*\\S)\\s+(\\d+)\\s+(\\d+)\\s+(\\d+)\\s*$"
filas_a3 <- lin_a3[grepl(pat_a3, lin_a3) & !grepl("tokens_entrada", lin_a3)]
esc_a3 <- tibble::tibble(
  escenario_a3 = trimws(sub(pat_a3, "\\1", filas_a3)),
  llamadas     = as.integer(sub(pat_a3, "\\2", filas_a3)),
  tok_entrada  = as.integer(sub(pat_a3, "\\3", filas_a3)),
  tok_salida   = as.integer(sub(pat_a3, "\\4", filas_a3))
)
stopifnot(nrow(esc_a3) == 4)  # control: la tabla de A3 tiene 4 escenarios
cat("\n== Costo del contexto que A3 publica (tokens leidos de a3_presupuesto_tokens_salida.txt, NO recalculados aqui) ==\n")
costo_a3 <- tidyr::crossing(esc_a3, precios) |>
  mutate(usd_consulta = costo_usd(tok_entrada, tok_salida, entrada_musd, salida_musd),
         usd_mes_1000 = usd_consulta * 1000) |>
  select(escenario_a3, tok_entrada, tok_salida, modelo, usd_consulta, usd_mes_1000) |>
  arrange(tok_entrada, desc(usd_consulta))
print(as.data.frame(costo_a3 |> mutate(usd_consulta = round(usd_consulta, 5), usd_mes_1000 = round(usd_mes_1000, 2))), row.names = FALSE)
cat(sprintf("contraste de contextos: A4 tamano medio %d tokens de entrada | A3 sin descomposicion, largo mediano %d | diferencia %+.1f%%\n",
            tamanos[["tok_entrada"]][[2]], esc_a3[["tok_entrada"]][[1]],
            100 * (tamanos[["tok_entrada"]][[2]] / esc_a3[["tok_entrada"]][[1]] - 1)))
cat("CONTROL POSITIVO de la lectura: los cuatro escenarios de A3 leidos son", paste(esc_a3[["tok_entrada"]], collapse = ", "), "tokens de entrada\n")

