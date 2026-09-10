#!/usr/bin/env Rscript
# =============================================================================
# a3_ontologia_relaciones.R — laboratorio A3, encargo v9 (desechable)
# -----------------------------------------------------------------------------
# Tarea 8: recuenta las relaciones por tipo y evalua, UNA POR UNA, que tipos del
# diseno externo (modifica, deroga, complementa, reglamenta, interpreta,
# desarrolla, contradice) son derivables programaticamente de los metadatos y
# el texto disponibles. Para los derivables corre la regla sobre los datos
# reales y cuenta; para cada cero, planta un control positivo sintetico que la
# misma regla DEBE encontrar.
# Reutiliza patron_cita() y anio_de_la_cita() de 33_relaciones.R cargados por
# definiciones (no se sourcea 33: escribe relaciones.json).
# Ejecutar desde la raiz del repo:
#   Rscript 50_documentacion/andamios/lab_motor_v9/a3_ontologia_relaciones.R
# =============================================================================
source(here::here("50_documentacion", "andamios", "lab_motor_v9", "a3_cargar_defs.R"))
cargar_entorno_pipeline()
d33 <- cargar_defs_de(here::here("30_procesamiento", "33_relaciones.R"), constantes = CONSTANTES_33)
e33 <- d33[["env"]]
cat(sprintf("33_relaciones.R: %d expresiones; evaluadas %d; omitidas %d (entre ellas la carga, los bucles y escribir_atomico).\n",
            d33[["n_total"]], length(d33[["evaluadas"]]), length(d33[["omitidas"]])))
normas <- leer_normas()

# ---- (0) Recuento de lo que hay hoy --------------------------------------------
rel <- jsonlite::fromJSON(here::here("40_salidas", "datos", "relaciones.json"), simplifyVector = FALSE)
tipos <- vapply(rel[["relaciones"]], function(r) r[["tipo"]], character(1))
cat("\n(0) relaciones.json: n_relaciones declarado =", rel[["n_relaciones"]],
    "| recontadas =", length(tipos), "| descartadas por anio =", length(rel[["descartadas"]]),
    "| suprimidas intra-grupo =", length(rel[["suprimidas_intra_grupo"]]), "\n")
print(table(tipos))

tipo_de  <- vapply(normas, function(n) n[["tipo"]], character(1))
grupo_de <- vapply(normas, function(n) if (is.null(n[["grupo_acto"]])) NA_character_ else n[["grupo_acto"]][["id"]], character(1))
resol_de <- vapply(normas, function(n) if (is.null(n[["grupo_acto"]])) NA_character_ else n[["grupo_acto"]][["resolucion"]], character(1))
sondeable <- function(s) is.na(grupo_de[[s]]) || identical(s, resol_de[[s]])
# Guardado contra slugs que no estan en el corpus (los controles sinteticos).
mismo_grupo <- function(x, y) x %in% names(grupo_de) && y %in% names(grupo_de) &&
  !is.na(grupo_de[[x]]) && identical(grupo_de[[x]], grupo_de[[y]])
patrones <- Filter(Negate(is.null), setNames(lapply(names(normas), function(s)
  if (sondeable(s)) e33$patron_cita(normas[[s]][["tipo"]], normas[[s]][["numero"]]) else NULL), names(normas)))
anios_de <- function(s) {
  n <- normas[[s]]
  a <- c(n[["anio"]], unlist(n[["anios_alternativos"]]))
  unlist(a[!vapply(a, is.null, logical(1))])
}

# Regla generica: verbo + cita de B dentro de una ventana posterior, con el mismo
# filtro de anio discordante que usa 33 (anio_de_la_cita).
buscar_verbo_cita <- function(lista, regex_verbo, ventana, segmentos_de = function(n) n[["articulos"]]) {
  out <- list()
  for (a in lista) {
    for (seg in segmentos_de(a)) {
      txt <- seg[["texto"]]
      if (!is.character(txt) || !nzchar(txt)) next
      pos <- gregexpr(regex_verbo, txt, perl = TRUE)[[1]]
      if (pos[1] == -1L) next
      for (p in as.integer(pos)) {
        vent <- substr(txt, p, p + ventana)
        for (b in names(patrones)) {
          if (identical(b, a[["slug"]]) || mismo_grupo(a[["slug"]], b)) next
          m <- regexpr(patrones[[b]], vent, perl = TRUE)
          if (m == -1L) next
          cita <- regmatches(vent, m)
          lectura <- e33$anio_de_la_cita(txt, p + as.integer(m) - 1L + attr(m, "match.length"))
          ab <- anios_de(b)
          if (!is.na(lectura[["anio"]]) && length(ab) > 0L && !(lectura[["anio"]] %in% ab)) next
          cabeza <- substr(txt, p, p + 80)
          out[[length(out) + 1L]] <- list(desde = a[["slug"]], hacia = b, articulo = seg[["id"]],
                                          verbo = regmatches(cabeza, regexpr(regex_verbo, cabeza, perl = TRUE)),
                                          cita = cita)
        }
      }
    }
  }
  out
}
resumir <- function(out, nombre) {
  if (length(out) == 0L) { cat(sprintf("  %s: 0 pares.\n", nombre)); return(invisible(0L)) }
  pares <- unique(vapply(out, function(r) paste(r[["desde"]], "->", r[["hacia"]]), character(1)))
  cat(sprintf("  %s: %d coincidencia(s) en %d par(es) unico(s):\n", nombre, length(out), length(pares)))
  for (p in pares) {
    ej <- Filter(function(r) identical(paste(r[["desde"]], "->", r[["hacia"]]), p), out)[[1]]
    cat(sprintf("    %-62s en %-12s verbo «%s» cita «%s»\n", p, ej[["articulo"]], ej[["verbo"]], ej[["cita"]]))
  }
  invisible(length(pares))
}

# ---- (1) modifica --------------------------------------------------------------
REGEX_MODIFICA <- "(?i)introd[uú]cen?se\\s+las\\s+siguientes\\s+modificaciones|\\bmodif[ií]ca(?:n)?se\\b|\\bmodif[ií]quese\\b|\\bmodif[ií]quense\\b"
cat("\n(1) modifica: verbo de modificacion + cita de la norma modificada en los 400 caracteres siguientes (misma regla de anio que 33).\n")
mod <- buscar_verbo_cita(unname(normas), REGEX_MODIFICA, 400L)
n_mod <- resumir(mod, "modifica")
# Consolidacion: el texto modificado NO esta consolidado en el corpus (medido).
busca <- function(slug, id, frase) {
  n <- normas[[slug]]; for (a in n[["articulos"]]) if (identical(a[["id"]], id)) return(grepl(frase, a[["texto"]], fixed = TRUE)); NA
}
cat(sprintf("  consolidacion: frase insertada por ley 21.801 («desincentivar el uso excesivo») en ley_20370 art-10 = %s | en ley_21801 art-unico = %s (control)\n",
            busca("ley_20370_general_educacion", "art-10", "desincentivar el uso excesivo"),
            busca("ley_21801_celulares", "art-unico", "desincentivar el uso excesivo")))
cat(sprintf("  consolidacion: frase insertada por ley 21.809 («Es deber del Estado promover la buena convivencia») en ley_20370 art-4 = %s | en ley_21809 art-1 = %s (control)\n",
            busca("ley_20370_general_educacion", "art-4", "Es deber del Estado promover la buena convivencia"),
            busca("ley_21809_convivencia_educativa", "art-1", "Es deber del Estado promover la buena convivencia")))

# ---- (2) deroga ------------------------------------------------------------------
# Primera version de la regla (un solo verbo «derog*» + cita en 300 caracteres)
# dio 4 pares, y los 4 eran falsos: dos por la formula de cita de la LGE («con las
# normas no derogadas del DFL 1, de 2005») y dos por notas marginales de la BCN
# («Artículo 23: DEROGADO ... LEY 19979 ... D.O. 06.11.2004»), donde la norma
# citada es la que DEROGA y no la derogada. Sondeo previo sobre el corpus:
# 71 ocurrencias de «derog», 19 en la forma «no derogad», 52 restantes.
# Por eso la regla se parte en dos formas con direccion distinta:
#   D1 prosa dispositiva: «derógase/deróganse/deroga(n)» + cita de B en los 300
#      caracteres siguientes -> A deroga B. Los participios («derogado/as») no
#      entran: son la nota marginal, no una disposicion.
#   D2 nota marginal BCN: el segmento empieza con «Artículo N ... DEROGADO/
#      Derogado» y la nota termina en la fecha D.O.; la norma citada DENTRO de la
#      nota es la que deroga -> B deroga (ese articulo de) A. Direccion invertida.
REGEX_DEROGA_D1 <- "(?i)(?<!\\bno\\s)\\bder[oó]g(?:ase|anse|uese|uense|a|an)\\b"
REGEX_DEROGA_D2 <- "^\\s*Art[íi]culo[^\\n]{0,30}?(?:DEROGAD[OA]S?|Derogad[oa]s?)\\b"
REGEX_FECHA_DO  <- "(?i)D\\.?\\s?O\\.?\\s*[0-9]{1,2}[.\\-/][0-9]{1,2}[.\\-/](?:19|20)[0-9]{2}"
cat("\n(2) deroga, forma D1 (prosa dispositiva, «derógase» + cita en 300 caracteres; excluye «no derogadas» y los participios):\n")
der1 <- buscar_verbo_cita(unname(normas), REGEX_DEROGA_D1, 300L)
n_der1 <- resumir(der1, "deroga D1")
for (r in der1) {
  n <- normas[[r[["desde"]]]]
  for (s in n[["articulos"]]) if (identical(s[["id"]], r[["articulo"]])) {
    q <- regexpr(REGEX_DEROGA_D1, s[["texto"]], perl = TRUE)
    cat("      contexto:", gsub("\\s+", " ", substr(s[["texto"]], max(1, q - 60), q + 200)), "\n")
  }
}
sintetica <- list(list(slug = "sintetica_control", tipo = "ley", numero = "0", anio = 2026L,
                       articulos = list(list(id = "art-1", texto = "Artículo 1.- Derógase la ley N° 20.370, sin perjuicio de lo dispuesto en el artículo siguiente."))))
ctrl <- buscar_verbo_cita(sintetica, REGEX_DEROGA_D1, 300L)
cat(sprintf("  control positivo D1 (segmento sintetico «Derógase la ley N° 20.370»): %d coincidencia(s) -> %s (DEBE encontrar ley_20370)\n",
            length(ctrl), if (length(ctrl)) ctrl[[1]][["hacia"]] else "nada"))
ctrl_no <- buscar_verbo_cita(list(list(slug = "sintetica_control", tipo = "ley", numero = "0", anio = 2026L,
  articulos = list(list(id = "art-1", texto = "con las normas no derogadas del decreto con fuerza de ley N° 1, de 2005, y la ley N° 20.370")))), REGEX_DEROGA_D1, 300L)
cat(sprintf("  control negativo D1 («normas no derogadas ... ley N° 20.370»): %d coincidencia(s) (DEBE ser 0)\n", length(ctrl_no)))

cat("\n(2) deroga, forma D2 (nota marginal BCN «Artículo N: DEROGADO <norma> ... D.O. fecha»; la norma citada deroga el articulo):\n")
der2 <- list(); n_segs_d2 <- 0L
for (a in unname(normas)) for (s in a[["articulos"]]) {
  txt <- s[["texto"]]
  if (!grepl(REGEX_DEROGA_D2, txt, perl = TRUE)) next
  n_segs_d2 <- n_segs_d2 + 1L
  corte <- regexpr(REGEX_FECHA_DO, txt, perl = TRUE)
  nota <- if (corte > 0L) substr(txt, 1L, as.integer(corte) + attr(corte, "match.length") - 1L) else substr(txt, 1L, 250L)
  for (b in names(patrones)) {
    if (identical(b, a[["slug"]]) || mismo_grupo(a[["slug"]], b)) next
    m <- regexpr(patrones[[b]], nota, perl = TRUE)
    if (m == -1L) next
    lectura <- e33$anio_de_la_cita(nota, as.integer(m) + attr(m, "match.length"))
    ab <- anios_de(b)
    if (!is.na(lectura[["anio"]]) && length(ab) > 0L && !(lectura[["anio"]] %in% ab)) next
    der2[[length(der2) + 1L]] <- list(deroga = b, articulo_derogado = paste0(a[["slug"]], "#", s[["id"]]),
                                      cita = regmatches(nota, m), nota = gsub("\\s+", " ", nota))
  }
}
cat(sprintf("  segmentos que empiezan con nota «DEROGADO»: %d; de ellos, con una norma del corpus citada dentro de la nota (antes de la fecha D.O.): %d\n",
            n_segs_d2, length(der2)))
for (r in der2) cat(sprintf("    %s deroga %s   nota: «%s»\n", r[["deroga"]], r[["articulo_derogado"]], substr(r[["nota"]], 1, 110)))
ctrl2 <- {
  txt <- "Artículo 99: DEROGADO LEY 20370 Art. 3 D.O. 12.09.2009 PARRAFO II De la ley N° 19.979 y sus efectos"
  corte <- regexpr(REGEX_FECHA_DO, txt, perl = TRUE); nota <- substr(txt, 1L, as.integer(corte) + attr(corte, "match.length") - 1L)
  hits <- Filter(function(b) regexpr(patrones[[b]], nota, perl = TRUE) != -1L, names(patrones))
  hits_sin_corte <- Filter(function(b) regexpr(patrones[[b]], txt, perl = TRUE) != -1L, names(patrones))
  list(hits = hits, sin_corte = hits_sin_corte)
}
cat(sprintf("  control D2 (nota sintetica «DEROGADO LEY 20370 ... D.O. 12.09.2009 PARRAFO II De la ley N° 19.979»): con corte en D.O. encuentra %s (DEBE ser solo ley_20370); sin corte encontraria %s\n",
            paste(ctrl2[["hits"]], collapse = ","), paste(ctrl2[["sin_corte"]], collapse = ",")))
n_der <- n_der1 + length(der2)

# ---- (3) reglamenta ---------------------------------------------------------------
REGEX_REGLAMENTA <- "(?i)\\breglament(?:a|o|ar|e|an|aria|ario)\\b"
cat("\n(3) reglamenta: desde un decreto o DFL, la palabra «reglamento/reglamenta» + cita de la ley reglamentada en los 250 caracteres siguientes, buscada en el TITULO y en el preambulo.\n")
solo_dto <- Filter(function(n) n[["tipo"]] %in% c("dto", "dfl"), unname(normas))
segs_cabecera <- function(n) c(
  if (is.character(n[["titulo"]])) list(list(id = "titulo", texto = n[["titulo"]])) else list(),
  Filter(function(a) identical(a[["id"]], "preambulo"), n[["articulos"]]))
reg <- buscar_verbo_cita(solo_dto, REGEX_REGLAMENTA, 250L, segmentos_de = segs_cabecera)
n_reg <- resumir(reg, "reglamenta")
sint2 <- list(list(slug = "sintetica_control", tipo = "dto", numero = "0", anio = 2026L, titulo = "APRUEBA REGLAMENTO DE LA LEY N° 20.370",
                   articulos = list()))
ctrl2 <- buscar_verbo_cita(sint2, REGEX_REGLAMENTA, 250L, segmentos_de = segs_cabecera)
cat(sprintf("  control positivo (titulo sintetico «APRUEBA REGLAMENTO DE LA LEY N° 20.370»): %d -> %s (DEBE encontrar ley_20370)\n",
            length(ctrl2), if (length(ctrl2)) ctrl2[[1]][["hacia"]] else "nada"))
cat("  nota: dto_453 dice «APRUEBA REGLAMENTO DE LA LEY N° 19.070»; el corpus tiene el texto refundido de esa ley como dfl_1 (numero 1), de modo que\n",
    "        el vinculo dto_453 -> dfl_1 exige saber que el DFL 1/1997 refunde la ley 19.070: es curaduria, no derivacion; se declara.\n")

# ---- (4) interpreta ---------------------------------------------------------------
cat("\n(4) interpreta: subconjunto de las remisiones existentes cuyo origen es un dictamen (nivel pronunciamiento oficial). No es inferencia: es rotular por tipo del origen.\n")
rem <- Filter(function(r) identical(r[["tipo"]], "remision"), rel[["relaciones"]])
interp <- Filter(function(r) identical(tipo_de[[r[["desde"]]]], "dictamen"), rem)
cat(sprintf("  remisiones totales: %d | con origen dictamen (interpreta): %d | con origen circular/rex (instruye sobre): %d\n",
            length(rem), length(interp),
            length(Filter(function(r) tipo_de[[r[["desde"]]]] %in% c("circular", "rex"), rem))))
for (r in interp) cat(sprintf("    %-45s -> %-45s cita «%s»\n", r[["desde"]], r[["hacia"]], r[["cita_literal"]]))

# ---- (5) complementa, desarrolla, contradice ----------------------------------------
cat("\n(5) complementa / desarrolla / contradice: no existe marcador textual ni metadato que los produzca; exigen juicio juridico. Se rechazan (ver documento, tarea 8).\n")
cat("  prueba de contradice: la unica huella textual de un cambio de criterio en el corpus es la que describe el dictamen 52/77 num-1 («sustituyendo la expresión “y, además”, por la voz “o”»);\n",
    "  esa huella la produce una ley MODIFICATORIA (ley 21.128, fuera del corpus) y se clasifica como `modifica`, no como contradiccion. Sin regla deterministica, no entra.\n")

cat(sprintf("\nRESUMEN: hoy %d relaciones (%s). Derivables: modifica %d par(es), deroga %d, reglamenta %d, interpreta %d (relabel). Rechazados: complementa, desarrolla, contradice.\n",
            length(tipos), paste(names(table(tipos)), as.integer(table(tipos)), sep = "=", collapse = ", "),
            n_mod, n_der, n_reg, length(interp)))

# ---- (6) los pares derivables CONTRA el grafo que ya existe -------------------------
# Hallazgo CIF-A3-02 de la auditoria: los 8 + 1 + 2 pares derivables no son "nuevas
# aristas". Este bloque cruza cada par propuesto con `relaciones.json` y reporta con
# que tipos ya esta unido ese par de normas hoy.
cat("\n(6) los pares derivables contra el grafo que YA existe en relaciones.json\n")
slug_de <- function(x) sub("#.*$", "", x)
pares_hoy <- split(vapply(rel[["relaciones"]], function(r) r[["tipo"]], character(1)),
                   paste(vapply(rel[["relaciones"]], function(r) slug_de(r[["desde"]]), character(1)), "->",
                         vapply(rel[["relaciones"]], function(r) slug_de(r[["hacia"]]), character(1))))
propuestos <- c(
  lapply(mod,  function(r) list(tipo = "modifica",   par = paste(slug_de(r[["desde"]]), "->", slug_de(r[["hacia"]])))),
  lapply(der2, function(r) list(tipo = "deroga D2",  par = paste(slug_de(r[["deroga"]]), "->", slug_de(r[["articulo_derogado"]])))),
  lapply(reg,  function(r) list(tipo = "reglamenta", par = paste(slug_de(r[["desde"]]), "->", slug_de(r[["hacia"]])))))
ya <- 0L
for (p in propuestos) {
  t_hoy <- pares_hoy[[p[["par"]]]]
  if (!is.null(t_hoy)) ya <- ya + 1L
  cat(sprintf("    %-11s %-72s %s\n", p[["tipo"]], p[["par"]],
              if (is.null(t_hoy)) "PAR NUEVO (hoy sin ninguna relacion)" else paste("ya existe como:", paste(sort(unique(t_hoy)), collapse = ","))))
}
cat(sprintf("  relaciones tipadas nuevas: %d | pares de normas distintos que tocan: %d | pares NUEVOS (hoy desconectados): %d de %d\n",
            length(propuestos), length(unique(vapply(propuestos, function(p) p[["par"]], character(1)))),
            length(propuestos) - ya, length(propuestos)))
cat(sprintf("  grafo actual: %d pares dirigidos distintos, de %d posibles con %d normas\n",
            length(pares_hoy), length(normas) * (length(normas) - 1L), length(normas)))
cat(sprintf("  CONTROL POSITIVO del cruce (par sintetico que NO puede existir): %s -> %s ya existe? %s (DEBE ser FALSE)\n",
            "ley_21801_celulares", "circular_586_tea",
            !is.null(pares_hoy[["ley_21801_celulares -> circular_586_tea"]])))
cat(sprintf("  CONTROL NEGATIVO del cruce (par que SI existe por remision): %s ya existe? %s (DEBE ser TRUE)\n",
            "ley_21801_celulares -> ley_20370_general_educacion",
            !is.null(pares_hoy[["ley_21801_celulares -> ley_20370_general_educacion"]])))
