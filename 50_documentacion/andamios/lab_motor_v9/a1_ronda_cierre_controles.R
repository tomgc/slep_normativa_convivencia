setwd("/Users/tomgc/Projects/slep_normativa_convivencia")
D <- "50_documentacion/andamios/20260904_alcance_capa1_vocabulario_v1.md"
x <- readLines(D, warn = FALSE, encoding = "UTF-8")

# --- (a) rayas largas. El caracter se deriva de su punto de codigo, no se escribe a mano.
raya  <- intToUtf8(0x2014)   # em dash
raya2 <- intToUtf8(0x2013)   # en dash
menos <- intToUtf8(0x2212)   # signo menos matematico (NO es raya larga)
cat("=== (a) rayas largas ===\n")
cat("em dash U+2014 en el documento:", sum(vapply(gregexpr(raya, x, fixed = TRUE), function(g) sum(g > 0), numeric(1))), "\n")
cat("en dash U+2013 en el documento:", sum(vapply(gregexpr(raya2, x, fixed = TRUE), function(g) sum(g > 0), numeric(1))), "\n")
cat("signo menos U+2212 (legitimo, aritmetica):", sum(vapply(gregexpr(menos, x, fixed = TRUE), function(g) sum(g > 0), numeric(1))), "\n")
ctrl <- paste0("una cadena de control con raya larga ", raya, " aqui")
cat("CONTROL POSITIVO del instrumento sobre una cadena construida en este turno:",
    sum(gregexpr(raya, ctrl, fixed = TRUE)[[1]] > 0), "(debe ser 1)\n")
cat("CONTROL NEGATIVO sobre una cadena sin raya:",
    sum(gregexpr(raya, "sin raya aqui", fixed = TRUE)[[1]] > 0), "(debe ser 0)\n")

# --- (b) cadenas con forma de RUT
cat("\n=== (b) forma de RUT ===\n")
rx <- "[0-9]{1,2}\\.?[0-9]{3}\\.?[0-9]{3}-[0-9kK]"
cat("coincidencias en el documento:", sum(grepl(rx, x)), "\n")
pos <- paste0("caso de control construido en este turno: ", "12", ".", "345", ".", "678", "-", "9")
cat("CONTROL POSITIVO sobre cadena construida en este turno:", as.integer(grepl(rx, pos)), "(debe ser 1)\n")
cat("CONTROL NEGATIVO sobre la forma enmascarada:", as.integer(grepl(rx, "12.345.678-[k]")), "(debe ser 0)\n")

# --- (d) referencias de linea que el documento cita, revalidadas tras mis ediciones
cat("\n=== (d) referencias de linea, revalidadas ===\n")
P <- readLines("50_documentacion/andamios/20260904_prototipo_vocabulario.R", warn = FALSE)
cat("prototipo L512:", trimws(P[512]), "\n")
cat("  contiene la expresion corregida:", grepl("(!citable_de[[id]])", P[512], fixed = TRUE), "\n")
S <- readLines("50_documentacion/andamios/lab_motor_v9/a1_salida_prototipo.txt", warn = FALSE)
for (ln in c(45, 138, 199, 372, 465, 565)) cat(sprintf("  salida L%-4d %s\n", ln, substr(S[ln], 1, 72)))
cat("  filas entre 100 y 130:", length(100:130), "lineas, la 99 es el encabezado:", substr(S[99], 1, 50), "\n")
cat("  CONTROL NEGATIVO, linea fuera de rango (9999):", is.na(S[9999]), "\n")

# --- autorreferencia: recuento de lineas
cat("\n=== autorreferencia ===\n")
cat("wc -l documento:", length(x), "| lo que la tabla de §9 declara:",
    regmatches(x[grep("Líneas del prototipo", x)], regexpr("756 / [0-9]+", x[grep("Líneas del prototipo", x)])), "\n")
