# =============================================================================
# 35_renderizar_sitio.R
# -----------------------------------------------------------------------------
# Proposito: renderizar 40_salidas/sitio_src/ (Quarto) a 40_salidas/sitio/.
#            Es el unico paso del pipeline que invoca una herramienta externa a R.
#
# El render se dispara sobre la CARPETA, no sobre cada .qmd: Quarto necesita
# tratarla como proyecto para resolver la barra de navegacion, el tema y las
# rutas relativas entre paginas. El _quarto.yml que hay ahi lo deposito el paso
# 34 por copia desde la raiz del repositorio, que es donde se versiona.
# =============================================================================

source(here::here("10_utils", "10_utils.R"))
instalar_si_falta(c("quarto", "fs", "here"))
source(here::here("10_utils", "10_configuracion.R"))

ORIGEN <- "35_renderizar_sitio"

if (!nzchar(Sys.which("quarto"))) {
  stop("No se encontro el ejecutable 'quarto' en el PATH. ",
       "Instalarlo desde https://quarto.org antes de correr este paso.")
}

if (!fs::dir_exists(ruta_sitio_src())) {
  stop("No existe ", ruta_sitio_src(), ". Correr antes el paso 34 (run_all(only = 34)).")
}

# El directorio de salida se vacia ANTES de renderizar. Quarto no borra lo que
# dejo de tener fuente: si una pagina desaparece del generador, su HTML se queda
# publicado indefinidamente. Con las piezas interpretativas eso deja de ser un
# detalle de higiene y pasa a romper el invariante del proyecto: una ficha que el
# equipo devuelve a borrador seguiria en linea, firmada, para siempre. Medido el
# 2026-08-25 con pieza-faq-revision-de-mochilas.html.
if (fs::dir_exists(ruta_sitio())) fs::dir_delete(ruta_sitio())

n_qmd <- length(fs::dir_ls(ruta_sitio_src(), glob = "*.qmd"))
log_msg(sprintf("Renderizando %d páginas .qmd con Quarto %s.",
                n_qmd, as.character(quarto::quarto_version())),
        origen = ORIGEN)

quarto::quarto_render(input = ruta_sitio_src(), as_job = FALSE)

# Verificacion del conteo declarada ANTES del render (criterio de exito de T4):
# si un .qmd no produjo HTML, el render puede haber salido con codigo 0 igual.
n_html <- length(fs::dir_ls(ruta_sitio(), glob = "*.html"))
if (n_html != n_qmd) {
  stop(sprintf("Render incompleto: %d .qmd de entrada, %d .html de salida.", n_qmd, n_html))
}

log_msg(sprintf("Sitio renderizado: %d páginas HTML en %s.", n_html, ruta_sitio()),
        origen = ORIGEN)
