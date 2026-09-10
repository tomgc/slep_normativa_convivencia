# A1, ronda de cierre del encargo v9 (2026-09-06).
# Barre las cifras de medicion de §3 sobre los artefactos a1_ del laboratorio, para
# separar las que un lector puede recuperar de las que no.
#
# EXCLUSION DECLARADA: el barrido excluye a los propios artefactos de esta ronda
# (prefijo "a1_ronda_cierre_"), porque este script cita literalmente las cifras que
# busca y sin la exclusion se contaria a si mismo: cada cifra apareceria "encontrada"
# en el instrumento que la busca. El universo barrido son los 17 artefactos a1_
# anteriores a esta ronda.
setwd("/Users/tomgc/Projects/slep_normativa_convivencia")
LAB <- "50_documentacion/andamios/lab_motor_v9"
todos <- list.files(LAB, pattern = "^a1_", full.names = TRUE)
propios <- grepl("^a1_ronda_cierre_", basename(todos))
arts <- todos[!propios]
cat("artefactos a1_ en el laboratorio:", length(todos),
    "| excluidos por ser de esta ronda:", sum(propios),
    "| barridos:", length(arts), "\n")
cat(paste(" ", basename(arts), collapse = "\n"), "\n\n")

leer <- function(p) {
  if (grepl("[.]gz$", p)) return(character(0))
  tryCatch(readLines(p, warn = FALSE), error = function(e) character(0))
}
conts <- lapply(arts, leer)
names(conts) <- basename(arts)

buscar <- function(cad) {
  hits <- vapply(conts, function(x) any(grepl(cad, x, fixed = TRUE)), logical(1))
  names(hits)[hits]
}

cifras <- list(
  "0.228 (construccion, publicada)"  = c("0.228", "0,228"),
  "0.223 (rango, retirada)"          = c("0.223", "0,223"),
  "0.236 (2026-09-05, retirada)"     = c("0.236", "0,236"),
  "0.247 (v1, declarada ausente)"    = c("0.247", "0,247"),
  "31.43 (total, publicada)"         = c("31.43", "31,43"),
  "16.46 (sin 9bis, retirada)"       = c("16.46", "16,46"),
  "17.95 (2026-09-05, retirada)"     = c("17.95", "17,95"),
  "24.42 (1a corrida, ya declarada)" = c("24.42", "24,42"),
  "14.2 ms (latencia, publicada)"    = c("14.2 ", "14,2 "),
  "14.0 ms (rango, retirada)"        = c("14.0 ", "14,0 "),
  "14.4 ms (rango, retirada)"        = c("14.4 ", "14,4 ")
)
publicadas <- c("0.228 (construccion, publicada)", "31.43 (total, publicada)",
                "14.2 ms (latencia, publicada)")
res <- character(0)
for (nm in names(cifras)) {
  arch <- unique(unlist(lapply(cifras[[nm]], buscar)))
  res[nm] <- if (length(arch)) paste(arch, collapse = ", ") else "NINGUN ARTEFACTO"
  cat(sprintf("%-34s -> %s\n", nm, res[nm]))
}
# el enunciado del documento, hecho asercion: las tres publicadas se recuperan, las
# seis retiradas no estan en ningun artefacto anterior a esta ronda.
stopifnot(all(res[publicadas] != "NINGUN ARTEFACTO"))
retiradas <- setdiff(names(cifras), c(publicadas, "0.247 (v1, declarada ausente)",
                                      "24.42 (1a corrida, ya declarada)"))
stopifnot(length(retiradas) == 6L, all(res[retiradas] == "NINGUN ARTEFACTO"))
cat("\nstopifnot OK: 3 publicadas recuperables,", length(retiradas), "retiradas en ningun artefacto\n")

cat("\n--- CONTROL POSITIVO del instrumento: cadena presente en un artefacto ---\n")
cat("'tiempo_construccion_s' ->", paste(buscar("tiempo_construccion_s"), collapse = ", "), "\n")
cat("--- CONTROL NEGATIVO: cadena inventada ---\n")
neg <- buscar("zzqx_no_existe_99")
cat("'zzqx_no_existe_99' ->", if (length(neg)) paste(neg, collapse = ", ") else "0 archivos", "\n")

cat("\n--- Recuento de OK en la salida del prototipo (defecto N-3) ---\n")
sal <- readLines(file.path(LAB, "a1_salida_prototipo.txt"), warn = FALSE)
ok <- grep("^OK ", sal)
cat("lineas que empiezan con 'OK ':", length(ok), "-> lineas", paste(ok, collapse = ", "), "\n")
for (i in ok) cat("   L", i, ": ", substr(sal[i], 1, 78), "\n", sep = "")
cat("CONTROL NEGATIVO '^ZZOK ':", length(grep("^ZZOK ", sal)), "\n")
stopifnot(length(ok) == 5L)
cat("stopifnot OK: 5 lineas OK (4 casos plantados + compuerta)\n")
