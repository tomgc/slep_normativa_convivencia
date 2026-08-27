# =============================================================================
# 10_autoprueba_coincidencia_parcial.R
# -----------------------------------------------------------------------------
# NO es un paso del pipeline y no toca ningun dato. Es el control POSITIVO de la
# compuerta que instala 00_run_all.R: provoca a proposito una coincidencia
# parcial de nombres y EXIGE que la corrida falle por ella.
#
# Uso (el exito de esta autoprueba es el FALLO del juguete):
#   Rscript 10_utils/10_autoprueba_coincidencia_parcial.R
#   -> exit 0 si la compuerta disparo; exit != 0 si no disparo.
#
# Por que existe. Hasta el encargo v6 la demostracion positiva solo se habia
# hecho en la maquina del titular: en el runner constaba que la compuerta estaba
# ARMADA (si no, 00_run_all.R aborta al derivar el aviso) pero nunca que
# DISPARARA, porque el pipeline no produce ninguna coincidencia parcial. Una
# compuerta apagada y una compuerta que nunca tuvo nada que cazar dejan
# exactamente el mismo log verde, y esa ambiguedad es la que este archivo cierra.
#
# Vive en 10_utils/ y no en 30_procesamiento/ a proposito: lo que prueba es un
# invariante de la capa de utilidades (la opcion que fija 10_configuracion.R), y
# un archivo suelto en el directorio del pipeline se lee como una etapa mas.
# =============================================================================

ROOT <- rprojroot::find_root(rprojroot::is_git_root)
setwd(ROOT)

# source(), no Rscript del orquestador: hace falta la MISMA configuracion que usa
# el pipeline (las options de 10_configuracion.R, los prefijos derivados y
# ejecutar_paso()), no una reconstruccion parecida. Bajo source() la guardia
# `sys.nframe() == 0L` no dispara, asi que esto define sin ejecutar el pipeline.
source(file.path(ROOT, "00_run_all.R"))

cat("Prefijos de aviso derivados en este entorno:\n")
for (p in PREFIJOS_PARCIAL) cat("  <", p, ">\n", sep = "")

escribir_paso <- function(nombre, lineas) {
  ruta <- file.path(tempdir(), nombre)
  writeLines(lineas, ruta)
  ruta
}

# ---- 1. Control POSITIVO: el juguete tiene que hacer fallar la corrida -------
# Reproduce el defecto real del DFL 1 (encargo v3): la curaduria declaraba solo
# `anios_alternativos`, el codigo pedia `anio` con `$`, y el anio de la norma
# quedo en 1996 sin una sola linea roja.
juguete <- escribir_paso("paso_con_coincidencia_parcial.R", c(
  "curado <- list(anios_alternativos = 1996L, titulo = 'Estatuto de los asistentes')",
  "anio <- curado$anio",
  "cat('el juguete leyo anio =', anio, '\\n')"))

fallo <- tryCatch({ ejecutar_paso(juguete); NULL }, error = function(e) conditionMessage(e))

if (is.null(fallo)) {
  stop("AUTOPRUEBA FALLIDA: el juguete provoco una coincidencia parcial de nombres y la ",
       "corrida NO fallo.\n  La compuerta de 00_run_all.R no esta cazando lo que dice cazar. ",
       "Revisa que\n  10_utils/10_configuracion.R fije options(warnPartialMatchDollar = TRUE) y ",
       "que el bucle\n  de run_all() ejecute los pasos con ejecutar_paso().",
       call. = FALSE)
}
if (!grepl("coincidencia parcial", fallo, fixed = TRUE)) {
  stop("AUTOPRUEBA FALLIDA: la corrida fallo, pero no por coincidencia parcial.\n  Mensaje: ",
       fallo, call. = FALSE)
}
if (!grepl("curado$anio", fallo, fixed = TRUE)) {
  stop("AUTOPRUEBA FALLIDA: el mensaje no nombra el acceso culpable.\n  Mensaje: ", fallo,
       call. = FALSE)
}
cat("\n[1/2] Control positivo OK: la compuerta disparo y nombro el acceso.\n")
cat(paste0("      ", strsplit(fallo, "\n")[[1]], collapse = "\n"), "\n")

# ---- 2. Control NEGATIVO: las advertencias ajenas NO deben tumbar nada -------
# Sin esto, una compuerta que promoviera CUALQUIER warning tambien pasaria el
# control positivo, y apagaria el pipeline por un as.integer("x") inofensivo.
ajeno <- escribir_paso("paso_con_advertencias_ajenas.R", c(
  "x <- as.integer('no es un numero')",
  "y <- log(-1)",
  "warning('una advertencia normal del pipeline')",
  "cat('el paso ajeno termino bien\\n')"))

ajeno_fallo <- tryCatch({ suppressWarnings(ejecutar_paso(ajeno)); NULL },
                        error = function(e) conditionMessage(e))
if (!is.null(ajeno_fallo)) {
  stop("AUTOPRUEBA FALLIDA: un paso con advertencias AJENAS a la coincidencia parcial ",
       "hizo fallar la corrida.\n  La compuerta esta promoviendo de mas.\n  Mensaje: ",
       ajeno_fallo, call. = FALSE)
}
cat("[2/2] Control negativo OK: las advertencias ajenas no tumban la corrida.\n")
cat("\nAutoprueba de la compuerta de coincidencia parcial: SUPERADA.\n")
