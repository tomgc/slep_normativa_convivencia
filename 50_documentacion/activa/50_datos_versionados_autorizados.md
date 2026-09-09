# Datos versionados autorizados

> **Qué es este archivo.** La lista que lee la regla **R1** del hook global
> `pre-push` de la cartera (`herramientas_dev/githooks/pre-push`) para decidir qué
> archivos con extensión de datos pueden viajar en un push. R1 rechaza por defecto
> `xlsx xls xlsm xlsb csv tsv parquet rds rdata sav dta db sqlite sqlite3 json geojson`;
> lo que aparezca en el bloque de abajo queda exceptuado.
>
> **Formato, impuesto por el hook.** El hook toma **el primer bloque cercado del
> archivo** y lee una ruta por línea, descartando lo que siga a un `#`. Cualquier
> otro bloque de código debe ir después de ese primero.
>
> **Creado:** 2026-09-08, encargo v10, por enmienda de autorizaciones del emisor.
> El hook global se instaló en la estación el 2026-09-01, después de que este
> repositorio empezara a versionar sus JSON (bootstrap del 2026-08-25), así que
> nunca llegó a escribirse su lista. El primer push que tocó esos archivos —el del
> bloque B3 de este encargo— fue rechazado por 18 hallazgos R1. Este archivo cierra
> ese hueco.

```
40_salidas/datos/*.json        # catalogo, manifiesto y relaciones
40_salidas/datos/**/*.json     # una norma por archivo, en normas/
```

## Por qué dos líneas y no una

La instrucción del emisor pedía `40_salidas/datos/**/*.json` y nada más. Medido
contra el mecanismo real del hook (`case "$ruta" in $glob`, en `bash`, que es el
intérprete del hook), ese patrón por sí solo **deja fuera** los JSON que cuelgan
directamente de `40_salidas/datos/`, porque exige un `/` después de `datos/`:

```
### solo '40_salidas/datos/**/*.json'
  CASA   40_salidas/datos/normas/ley_21801_celulares.json
  NO     40_salidas/datos/relaciones.json
  NO     40_salidas/datos/catalogo.json
  NO     40_salidas/datos/manifiesto_corpus.json

### los dos niveles de 40_salidas/datos/
  CASA   40_salidas/datos/normas/ley_21801_celulares.json
  CASA   40_salidas/datos/relaciones.json
  CASA   40_salidas/datos/catalogo.json
  CASA   40_salidas/datos/manifiesto_corpus.json
  NO     20_insumos/curaduria/metadatos_curados.json
  NO     40_salidas/sitio/search.json
  NO     40_salidas/intermedios/extraccion.json
  NO     package.json
  NO     datos.csv
  NO     40_salidas/datos/algo.csv
```

`relaciones.json` es uno de los 18 archivos del push rechazado, de modo que con el
patrón literal el push habría seguido rechazado. Las dos líneas cubren
exactamente los dos niveles de `40_salidas/datos/` que hoy tienen archivos y **no
alcanzan ninguna otra ruta**: ni `40_salidas/sitio/`, ni `40_salidas/intermedios/`,
ni `20_insumos/`, ni un `.csv` dentro del propio `40_salidas/datos/`. El hueco se
cierra a la medida de lo que existe.

## Qué autoriza, exactamente

Los 28 archivos versionados bajo `40_salidas/datos/`, enumerados con
`git ls-files 40_salidas/datos | grep '[.]json$'` y medidos con `wc -c` en la misma
corrida:

| Ruta | Peso |
|---|---|
| `40_salidas/datos/catalogo.json` | 31570 B |
| `40_salidas/datos/manifiesto_corpus.json` | 6847 B |
| `40_salidas/datos/normas/circular_193_estudiantes_embarazadas.json` | 32152 B |
| `40_salidas/datos/normas/circular_586_tea.json` | 3799 B |
| `40_salidas/datos/normas/circular_812_identidad_genero.json` | 40374 B |
| `40_salidas/datos/normas/dfl_1_estatuto_asistentes_educacion.json` | 274378 B |
| `40_salidas/datos/normas/dfl_315_perdida_reconocimiento_oficial.json` | 77998 B |
| `40_salidas/datos/normas/dictamen_065_revision_mochilas.json` | 24196 B |
| `40_salidas/datos/normas/dictamen_078_detectores_revision_mochilas.json` | 35498 B |
| `40_salidas/datos/normas/dictamen_52_77_expulsion.json` | 41221 B |
| `40_salidas/datos/normas/dictamen_71_expulsion_cancelacion_matricula.json` | 39011 B |
| `40_salidas/datos/normas/dto_215_uniforme_escolar.json` | 10907 B |
| `40_salidas/datos/normas/dto_24_consejos_escolares.json` | 16970 B |
| `40_salidas/datos/normas/dto_453_estatuto_docente.json` | 136415 B |
| `40_salidas/datos/normas/dto_565_centros_padres_apoderados.json` | 20993 B |
| `40_salidas/datos/normas/ley_19979_jornada_escolar_completa.json` | 61043 B |
| `40_salidas/datos/normas/ley_20370_general_educacion.json` | 113189 B |
| `40_salidas/datos/normas/ley_20536_violencia_escolar.json` | 8982 B |
| `40_salidas/datos/normas/ley_20845_inclusion_escolar.json` | 164771 B |
| `40_salidas/datos/normas/ley_20911_formacion_ciudadana.json` | 8714 B |
| `40_salidas/datos/normas/ley_21430_garantias_ninez.json` | 169679 B |
| `40_salidas/datos/normas/ley_21545_tea.json` | 33803 B |
| `40_salidas/datos/normas/ley_21801_celulares.json` | 14775 B |
| `40_salidas/datos/normas/ley_21809_convivencia_educativa.json` | 117993 B |
| `40_salidas/datos/normas/rex_181_celulares.json` | 2287 B |
| `40_salidas/datos/normas/rex_482_instrucciones_reglamentos_internos.json` | 3223 B |
| `40_salidas/datos/normas/rex_482_reglamentos_b.json` | 137220 B |
| `40_salidas/datos/relaciones.json` | 257428 B |

De ellos, **18 viajaban en el push rechazado**: los 17 JSON de norma que el bloque
B3 modificó al quitar la ficha del sitio de origen, más `relaciones.json`.
`catalogo.json` y `manifiesto_corpus.json` no cambiaron en ese commit y se
autorizan igual, porque son el mismo tipo de artefacto y el próximo cambio del
corpus los tocará.

## Por qué es seguro autorizarlos

1. **El proyecto no maneja datos sensibles.** `50_documentacion/activa/ESTADO.md`
   declara `maneja_sensibles: false` en su encabezado. Es un proyecto de **Rama A**
   (`CLAUDE.md` §10.2): leyes, decretos, circulares y dictámenes **ya publicados**
   por el Estado. No hay RUT, ni nombres de estudiantes, ni matrícula, ni
   asistencia, ni resultados individuales. El repositorio es público a propósito.
2. **Son el entregable canónico del pipeline, no un volcado de datos.**
   `CLAUDE.md` §10.4 los lista como versionados por diseño:
   `40_salidas/datos/catalogo.json` («catálogo maestro (versionado)») y
   `40_salidas/datos/normas/<slug>.json` («una norma por archivo (versionado)»).
   `.gitignore` confirma el criterio en sus líneas 50 a 57: `40_salidas/datos/` se
   versiona; `40_salidas/sitio_src/` y `40_salidas/sitio/` no.
3. **Son reproducibles.** Los regenera `00_run_all.R` desde los PDF versionados, y
   el workflow de CI los reconstruye en un runner limpio en cada push.
4. **La excepción es de R1 y de nadie más.** Las reglas R2 (credenciales), R3
   (patrón de RUT en líneas agregadas) y R4 siguen aplicándose sin cambio a estos
   archivos y a todos los demás.

## Lo que este archivo NO autoriza

Cualquier otra ruta del repositorio, incluidas las demás de `40_salidas/`. En
particular, un archivo de datos que apareciera en `20_insumos/` seguirá siendo
rechazado por R1, que es lo correcto: esa carpeta es la fuente legal de verdad y
su contenido es intocable para el pipeline.
