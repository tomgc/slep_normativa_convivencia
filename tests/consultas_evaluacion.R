# =============================================================================
# consultas_evaluacion.R - conjunto de evaluacion del buscador del sitio.
# -----------------------------------------------------------------------------
# SOLO DATOS. Se hace source() desde tests/medir_buscador.R y deja disponible el
# tibble CONSULTAS_EVALUACION. No imprime nada y no toca disco.
#
# POR QUE ES CODIGO R Y NO UN CSV
# -------------------------------
# El hook de pre-push del kit rechaza extensiones de datos (csv, json, xlsx,
# parquet, rds...) que no esten autorizadas en
# 50_documentacion/activa/50_datos_versionados_autorizados.md. Un conjunto de
# evaluacion tiene que viajar con el instrumento que lo usa, en el repositorio y
# versionado; escrito como tibble::tribble() es codigo, no dato, y pasa la
# compuerta sin pedir una excepcion. La forma tabular se conserva entera.
#
# PROCEDENCIA DE LAS DIEZ HISTORICAS
# ----------------------------------
# Copiadas literalmente (generadas por lectura programatica, no transcritas a
# mano) de 50_documentacion/andamios/lab_motor_v9/a2_consultas_evaluacion.csv:
# columna `consulta` tal como la escribe el equipo, `ancla_esperada` y
# `anclas_aceptadas` (que aqui se llama `anclas_conjunto`, separada por ";").
# Ese archivo vive bajo lab_motor_v9/, que .gitignore excluye: por eso el
# conjunto se reconstruye aqui, dentro del arbol versionado.
#
# LA CLASE sin_respuesta
# ----------------------
# Consultas que el equipo puede escribir razonablemente y que el corpus NO
# responde: 25 normas de convivencia escolar no dicen nada de licencias de
# conducir, finiquitos ni pensiones de alimentos. Existen para medir el estado
# vacio: hoy el buscador no lo tiene, de modo que su valor esperado es "devuelve
# resultados igual", que es la linea base que el v12 debe corregir. No tienen
# ancla esperada porque no hay respuesta correcta que apuntar.
#
# Columnas:
#   id              identificador estable de la consulta
#   consulta        el texto tal cual se escribe en la caja de busqueda
#   ancla_esperada  "<archivo>.html#<id>" de la unidad que responde; NA si ninguna
#   anclas_conjunto conjunto aceptado, separado por ";"; incluye a la esperada
#   clase           "historica" | "sin_respuesta"
#   fuente          de donde sale la fila
# =============================================================================

source(here::here("10_utils", "10_utils.R"))
instalar_si_falta(c("tibble", "here"))
source(here::here("10_utils", "10_configuracion.R"))

CONSULTAS_EVALUACION <- tibble::tribble(
  ~id, ~consulta, ~ancla_esperada, ~anclas_conjunto, ~clase, ~fuente,

  # ---- Las diez historicas (v9) ---------------------------------------------
  "C01", "pueden revisar la mochila de un alumno",
    "dictamen_065_revision_mochilas.html#fuentes",
    "dictamen_065_revision_mochilas.html#fuentes;dictamen_065_revision_mochilas.html#materia",
    "historica", "v9_reconstruida",
  "C02", "se puede usar el celular en la sala de clases",
    "ley_21801_celulares.html#art-10-bis",
    "ley_21801_celulares.html#art-10-bis;rex_181_celulares.html#documento",
    "historica", "v9_reconstruida",
  "C03", "es obligatorio tener un encargado de convivencia en el colegio",
    "ley_20536_violencia_escolar.html#art-unico",
    "ley_20536_violencia_escolar.html#art-unico;ley_21809_convivencia_educativa.html#art-15;ley_21809_convivencia_educativa.html#art-4-3",
    "historica", "v9_reconstruida",
  "C04", "qué es el bullying",
    "ley_21809_convivencia_educativa.html#art-16-b",
    "ley_21809_convivencia_educativa.html#art-16-b;ley_20536_violencia_escolar.html#art-16-b",
    "historica", "v9_reconstruida",
  "C05", "una alumna embarazada puede seguir yendo al colegio",
    "ley_20370_general_educacion.html#art-11",
    "ley_20370_general_educacion.html#art-11",
    "historica", "v9_reconstruida",
  "C06", "cuántos días tiene el apoderado para apelar una expulsión",
    "ley_20845_inclusion_escolar.html#art-3",
    "ley_20845_inclusion_escolar.html#art-3;dictamen_52_77_expulsion.html#num-3",
    "historica", "v9_reconstruida",
  "C07", "quiénes tienen que estar en el consejo escolar",
    "dto_24_consejos_escolares.html#art-3",
    "dto_24_consejos_escolares.html#art-3",
    "historica", "v9_reconstruida",
  "C08", "el colegio puede obligar a los alumnos a usar uniforme",
    "dto_215_uniforme_escolar.html#art-1",
    "dto_215_uniforme_escolar.html#art-1;dto_215_uniforme_escolar.html#art-3",
    "historica", "v9_reconstruida",
  "C09", "un alumno trans pide que lo llamen por su nombre social",
    "circular_812_identidad_genero.html#ocr-pagina-008",
    "circular_812_identidad_genero.html#ocr-pagina-008;circular_812_identidad_genero.html#ocr-pagina-009",
    "historica", "v9_reconstruida",
  "C10", "se puede suspender al alumno mientras dura el proceso de expulsión",
    "dictamen_52_77_expulsion.html#num-3",
    "dictamen_52_77_expulsion.html#num-3;ley_21809_convivencia_educativa.html#art-16-e",
    "historica", "v9_reconstruida",

  # ---- Clase sin_respuesta: el corpus no las responde -----------------------
  "S01", "cómo se obtiene la licencia de conducir",
    NA_character_, NA_character_, "sin_respuesta", "construida_v11",
  "S02", "cómo se calcula el finiquito de un docente",
    NA_character_, NA_character_, "sin_respuesta", "construida_v11",
  "S03", "cómo se solicita la pensión de alimentos",
    NA_character_, NA_character_, "sin_respuesta", "construida_v11",
  "S04", "dónde se renueva el pasaporte",
    NA_character_, NA_character_, "sin_respuesta", "construida_v11"
)

# ---- Validez de lectura -----------------------------------------------------
# Un conjunto de evaluacion que pierde filas en silencio convierte cualquier
# "N de 10" en una cifra sin denominador. Se comprueba al hacer source().
N_HISTORICAS    <- 10L
N_SIN_RESPUESTA <- 4L
stopifnot(
  nrow(CONSULTAS_EVALUACION) == N_HISTORICAS + N_SIN_RESPUESTA,
  !anyDuplicated(CONSULTAS_EVALUACION[["id"]]),
  sum(CONSULTAS_EVALUACION[["clase"]] == "historica")    == N_HISTORICAS,
  sum(CONSULTAS_EVALUACION[["clase"]] == "sin_respuesta") == N_SIN_RESPUESTA,
  all(!is.na(CONSULTAS_EVALUACION[["ancla_esperada"]][CONSULTAS_EVALUACION[["clase"]] == "historica"])),
  all(is.na(CONSULTAS_EVALUACION[["ancla_esperada"]][CONSULTAS_EVALUACION[["clase"]] == "sin_respuesta"]))
)
