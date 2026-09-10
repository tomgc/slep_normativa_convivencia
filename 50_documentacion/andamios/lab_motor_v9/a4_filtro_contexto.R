# =============================================================================
# a4_filtro_contexto.R - FASE 3 (correccion), agente A4, hallazgo CON-A4-04.
# -----------------------------------------------------------------------------
# Simula sobre los JSON reales los dos predicados de admision al contexto del
# Worker (§5.2 del documento y linea del esqueleto a4_worker_esqueleto.js):
#   viejo: art.es_articulo === true
#   nuevo: norma.origen_texto en {capa_texto_pdf, ocr_revisado}
# y cuenta que descarta cada uno. Solo LEE 40_salidas/datos/.
# Acceso a estructuras leidas de disco: siempre [[ ]], nunca $.
# =============================================================================
suppressPackageStartupMessages({library(jsonlite); library(dplyr); library(purrr); library(fs); library(here)})
options(width = 120)
cat("R:", R.version.string, " fecha:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n\n")

ORIGENES_FIRMADOS <- c("capa_texto_pdf", "ocr_revisado")
arch <- dir_ls(here::here("40_salidas/datos/normas"), glob = "*.json")
u <- map_dfr(arch, \(f) { n <- fromJSON(f, simplifyVector = FALSE)
  tibble(slug = n[["slug"]], tipo = n[["tipo"]], origen = n[["origen_texto"]],
         id = map_chr(n[["articulos"]], \(a) a[["id"]]),
         ea = map_lgl(n[["articulos"]], \(a) isTRUE(a[["es_articulo"]]))) })
u <- u |> mutate(firmada = origen %in% ORIGENES_FIRMADOS)

cat("== Universo ==\n")
cat("normas:", length(arch), "| segmentos:", nrow(u), "| es_articulo TRUE:", sum(u[["ea"]]), "\n\n")

cat("== Predicado VIEJO: art.es_articulo === true ==\n")
cat("sobreviven:", sum(u[["ea"]]), "| descarta:", sum(!u[["ea"]]), "\n")
cat("  descartados CON texto firmado (el defecto):", sum(!u[["ea"]] & u[["firmada"]]), "\n")
cat("  descartados por ser OCR sin revisar       :", sum(!u[["ea"]] & !u[["firmada"]]), "\n\n")

cat("== Predicado NUEVO: norma.origen_texto en {", paste(ORIGENES_FIRMADOS, collapse = ", "), "} ==\n")
cat("sobreviven:", sum(u[["firmada"]]), "| descarta:", sum(!u[["firmada"]]), "\n")
cat("  firmados perdidos (debe ser 0):", sum(!u[["firmada"]] & u[["origen"]] == "capa_texto_pdf"), "\n")
cat("  segmentos de dictamen que sobreviven:", sum(u[["firmada"]] & u[["tipo"]] == "dictamen"),
    "de", sum(u[["tipo"]] == "dictamen"),
    "(los", sum(!u[["firmada"]] & u[["tipo"]] == "dictamen"), "restantes son del dictamen 078, que es OCR sin revisar)\n\n")

cat("== Por tipo de norma ==\n")
print(as.data.frame(u |> summarise(segmentos = n(), viejo_sobrevive = sum(ea), viejo_descarta = sum(!ea),
                                   nuevo_sobrevive = sum(firmada), nuevo_descarta = sum(!firmada), .by = tipo)),
      row.names = FALSE)

cat("\n== Normas que el predicado nuevo descarta enteras ==\n")
print(as.data.frame(u |> filter(!firmada) |> summarise(segmentos = n(), .by = c(slug, tipo, origen))), row.names = FALSE)

cat("\n== Controles ==\n")
cat("CONTROL POSITIVO  predicado imposible {zzz_inexistente} -> sobreviven:",
    sum(u[["origen"]] %in% "zzz_inexistente"), "(esperado 0)\n")
cat("CONTROL NEGATIVO  predicado que no descarta nada (origen no vacio) -> sobreviven:",
    sum(nzchar(u[["origen"]])), "(esperado", nrow(u), ")\n")
cat("CONTROL de calibracion: segmentos con origen_texto == 'ocr_revisado' hoy:",
    sum(u[["origen"]] == "ocr_revisado"),
    "(esperado 0: ninguna transcripcion ha sido revisada aun; el valor esta en el predicado para que\n",
    "  el dia que el equipo revise una, entre sola sin tocar el Worker)\n")
