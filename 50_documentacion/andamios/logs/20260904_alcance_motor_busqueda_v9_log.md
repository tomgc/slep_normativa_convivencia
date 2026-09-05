# Log — alcance del motor de búsqueda asistida (v9), sesión 3

Encargo: `50_documentacion/andamios/20260904_encargo_alcance_motor_busqueda_v1.md`.
Inicio: 2026-09-04 21:16 (hora local de la máquina, `date`). Vía B, autónomo.
Orquestación: sesión principal de Claude Code como orquestador; fase 1 con cinco
subagentes en paralelo (A1 a A5), fase 2 con un auditor (AUD), fase 3 con los
autores corrigiendo su propio archivo, fase 4 con un sintetizador (SINT).
Este log se escribe DURANTE la ejecución: cada sección se completa al cerrar la
fase que la produce. Una sección marcada `(pendiente)` es una fase que aún no corre.

## 1. FASE 0 — precondiciones

Hash de partida: `a07dd1ad068f51b701cb02564277e80aaf415352` (`HEAD` == `origin/main`,
fuente: `git rev-parse HEAD origin/main` de esta fase).

| # | Precondición | Veredicto |
|---|---|---|
| P1 | v8 terminó y pusheó, o no fue lanzado | **PASA** (rama "no fue lanzado") |
| P2 | Árbol limpio y sincronizado | **PASA** con interpretación declarada abajo |
| P3 | Sesión abierta por esta máquina | **PASA** |
| P4 | Existe `50_documentacion/andamios/logs` | **PASA** |

### P1 — salida literal

```
$ git log --oneline -5
a07dd1a chore(estado): abrir sesion 3
bc3fdbe docs(cierre): log de cierre v02
4c8bdf5 docs(cierre): traspaso v02, backlog y estado de sesion (completa e85057c)
e85057c docs(cierre): traspaso v02, backlog y estado de sesion
d301186 docs(andamios): evidencia de CI del ejemplo del readme
$ git log --oneline -30 | grep -F 'docs(andamios): medicion de legibilidad del sitio v1'
NO ENCONTRADO en los ultimos 30 commits
$ ls 50_documentacion/andamios 50_documentacion/andamios/logs | grep -i legib
sin archivos *legib*
$ git worktree list
/Users/tomgc/Projects/slep_normativa_convivencia  a07dd1a [main]
```

Lectura: no hay commit de v8, no hay encargo ni log de legibilidad en el árbol,
no hay otro worktree y `origin/main` tras `git fetch` coincide con `HEAD`. Se toma
la rama "no fue lanzado" de P1. Riesgo residual declarado: un v8 corriendo en otro
clon sin haber pusheado no es detectable desde aquí; la precondición tal como está
escrita no lo distingue.

### P2 — salida literal

```
$ git fetch --quiet && git status --porcelain && git rev-parse HEAD origin/main
?? 50_documentacion/andamios/20260904_encargo_alcance_motor_busqueda_v1.md
a07dd1ad068f51b701cb02564277e80aaf415352
a07dd1ad068f51b701cb02564277e80aaf415352
```

Interpretación: la única entrada de `--porcelain` es el propio encargo, sin
trackear porque el titular lo acaba de depositar. Se lee como árbol limpio, con el
mismo criterio que la FASE 0 del log v7 ("única entrada `??` era este encargo →
commiteado"). El encargo se commitea junto con la fase 1.

### P3 y P4 — salida literal

```
$ grep -E '^(sesion_abierta|maquina):' 50_documentacion/activa/ESTADO.md
sesion_abierta: true
maquina: MacBook-Pro-de-Tomas
$ ls -d 50_documentacion/andamios/logs
50_documentacion/andamios/logs
```

### Premisas del encargo verificadas antes de lanzar

| Premisa | Comando | Resultado |
|---|---|---|
| Sitio generado existe en local con páginas temáticas | `ls 40_salidas/sitio_src/tema-*.qmd \| wc -l` | 17 |
| Índice Pagefind existente en local | `find 40_salidas -maxdepth 3 -type d -name pagefind` | `40_salidas/sitio/pagefind` |
| HTML renderizado en local | `ls 40_salidas/sitio/*.html \| wc -l` | 47 |
| Red hacia `developers.cloudflare.com` | `curl -sI https://developers.cloudflare.com/ \| head -1` | `HTTP/2 200` |
| Red hacia `docs.claude.com` | `curl -sI https://docs.claude.com/ \| head -1` | `HTTP/2 301` (ver decisión D4) |
| Herramientas | `which R Rscript node npx quarto gh curl` | todas presentes; Node `v26.5.0`; R `4.5.2` |
| Pagefind fijado | `grep -A2 '"node_modules/pagefind"' package-lock.json` | `1.5.2` |

### Decisiones del orquestador en FASE 0

- **D1. Carpeta de laboratorio.** Creada `50_documentacion/andamios/lab_motor_v9/`
  (`mkdir -p`). Es desechable: contiene artefactos derivados de datos públicos por
  los prototipos, ninguno es fuente. No hay regla en `.gitignore` para ella y
  editar `.gitignore` no está autorizado, así que se commitea con la fase que la
  produce para que el árbol quede limpio y AUD pueda re-derivar desde ella. Cada
  agente prefija sus archivos de laboratorio con `aN_` salvo `vocabulario.json`,
  que el encargo nombra.
- **D2. Consulta del índice Pagefind en modo lectura.** `pagefind.js` carga el índice
  con `fetch`, que en Node no acepta rutas de archivo. Sondeo del orquestador
  (comando literal en §3, control positivo C0): servir `40_salidas/sitio/` con
  `servr::httd()` (paquete R ya instalado) y consultar con `import()` de
  `pagefind.js` desde Node con `basePath` HTTP. La consulta devuelve resultados con
  `sub_results` y ancla. Se autoriza a A2 esa vía porque la API JavaScript es la
  única interfaz del índice; la lógica de evaluación va en R. No hay reindexación
  ni escritura en `40_salidas/`.
- **D3. Sin instalación de paquetes.** CRAN no está entre los dominios autorizados,
  así que los agentes usan solo paquetes ya instalados (lista en el prompt).
- **D4. Dominios de Anthropic redirigen fuera de la lista autorizada.**
  `curl -sI https://docs.claude.com/en/docs/about-claude/pricing` responde
  `HTTP/2 302` con `location: https://platform.claude.com/docs/en/about-claude/pricing`;
  `curl -sI https://www.anthropic.com/pricing` responde `HTTP/2 301` con
  `location: https://claude.com/pricing`. Ni `platform.claude.com` ni `claude.com`
  están autorizados. Con el precedente de la T3 del encargo v1 (regla aprendida 7:
  lista de dominios contradice la verificación exigida → se congela, no se
  improvisa), la verificación de precios de A4 (tarea 4) se declara **NO MEDIDA**:
  A4 no sigue redirecciones a hosts no autorizados, registra la salida literal de
  `curl -sI` y hace la aritmética con la tabla de precios cacheada del skill
  `claude-api` leído en esta sesión (fecha de caché 2026-06-24), rotulada como
  fuente provisional con su comando de verificación. Se reporta al titular como
  contradicción del encargo. Las verificaciones contra `developers.cloudflare.com`
  no se ven afectadas (responde `200` sin redirigir).
- **D5. Plan de commits.** Cuatro commits, uno por fase (fase 1 incluye el encargo
  y este log), con uno de los cinco autorizados en reserva. Cada uno pusheado y
  con verificación de CI por `head_sha`.
- **D6. Contraste de A5.** El encargo dice que A5 contrasta sus ataques contra los
  documentos ya escritos "en la fase 2". Se ejecuta como paso secuencial entre el
  fin de la fase 1 y el inicio de AUD, para que AUD audite la versión final de A5 y
  no un archivo en movimiento.
- **D7 (2026-09-05 20:25, revisa D1). El laboratorio NO se versiona.** El primer
  `git push` del commit de la fase 1 fue rechazado por el hook global de la cartera
  (`core.hooksPath = ~/Projects/herramientas_dev/githooks/pre-push`, decisión del
  titular del 2026-09-01) con 31 hallazgos: regla R1 (archivos con extensión de datos
  `json`/`csv` sin autorizar en `50_documentacion/activa/50_datos_versionados_autorizados.md`,
  que en este repo no existe) sobre los artefactos de `lab_motor_v9/`, y regla R3 (10
  líneas agregadas con patrón de RUT, ver O-4). Autorizar datos versionados exige
  escribir fuera de la tabla de §2, así que no se hace: `lab_motor_v9/` sale del índice
  (`git rm -r --cached`, los 66 archivos siguen en disco) y queda como carpeta local
  desechable, tal como la describe el encargo. La evidencia versionada es la que cada
  documento pega literalmente; los scripts de A1 y A2 en `andamios/` sí se versionan.
  Si el titular quiere versionar el laboratorio, es una decisión suya: crear el archivo
  de autorización y volver a agregar la carpeta. No se usa `--no-verify`.

## 2. Por agente

### 2.1 A1 — Capa 1: vocabulario controlado

Estado: **terminado** (reanudado a las 08:08 tras el segundo corte; informe recibido
~08:20). Archivos: `20260904_alcance_capa1_vocabulario_v1.md` (463 líneas) y
`20260904_prototipo_vocabulario.R` (663 líneas) (fuente: `wc -l` del orquestador
tras el informe). Laboratorio: `vocabulario.json` (435 763 B) más 11 archivos `a1_*`
(fuente: `ls -la lab_motor_v9 | grep -E 'vocabulario|a1_' | wc -l` = 12).

**Qué hizo.** Inventario del universo del vocabulario, cobertura contra un proxy del
lenguaje de consulta, prototipo ejecutable de punta a punta, contrato del JSON y
presupuesto de descarga. Sin git, sin red, sin Python (declarado en su informe).

**Cifras con comando (según su informe; tabla completa en §9 de su documento):**

| Cifra | Comando o fuente declarada |
|---|---|
| 25 normas / 682 artículos / 806 segmentos / 552 relaciones | salida §2 y §3 de `a1_salida_prototipo.txt` |
| 84 páginas OCR en 5 documentos | salida §2 del prototipo (recuento propio) |
| 958 encabezados `<h2 id>` en el sitio | `grep -ohE '<h2 id="[^"]+"' 40_salidas/sitio/*.html \| wc -l` |
| 17 páginas temáticas | `ls 40_salidas/sitio_src/tema-*.qmd \| wc -l` |
| Glosario: 39 encabezados, 35 distintos, 5 OCR, 5 pendientes | salida §3 del prototipo |
| 892 entradas, 260 alias, 555 claves | salida §4 y §6 del prototipo |
| 435 763 B (425,5 KB); gzip 22 097 B (`gzfile`), 22 113 (`gzip -c \| wc -c`), 21 398 (`gzip -9`) | prototipo + Bash |
| Construcción 0,247 s | `system.time()` en el prototipo |
| 887/887 destinos verificados contra el sitio | verificador de anclas del prototipo |
| 3 Mbps → 1,162 s sin comprimir / 0,059 s con gzip | **calculado**, no medido |

**Decisiones.** Índice de 892 entradas (17 temas, 25 normas, 806 encabezados con
ancla, 44 del glosario) derivadas solo de artefactos existentes, con procedencia por
alias. Carga completa y diferida en un archivo (21,6 KB gzip); fragmentación como
contingencia si Pages no comprime (hipótesis con `curl` de verificación). Reglas:
prefijo por token con AND; 1 carácter no sugiere, 2 solo temas y normas, 3 o más
todo; encabezados heredan claves de su norma solo si la consulta trae número; grupo de
acto resuelve al `resolucion`; norma sustituida penalizada pero visible; páginas OCR
excluidas por defecto y normas OCR rotuladas; glosario rotulado "sin validar".

**Fuera, con razón.** FAQ y fichas (0 publicadas, sin destino); tolerancia a erratas;
modo OR (yerra 4 de 12 preguntas con confianza); alias curados (exigirían escribir en
`20_insumos/`; propone archivo firmado en §2.4 de su documento).

**Errores propios declarados por A1.** (1) Dos `Rscript -e` fallaron por colapso de
`\\` en la capa de shell; movió la exploración a archivos `.R`. (2) Fragmento residual
`tidyr_pivot <- NULL` en el script escrito antes del corte; `parse()` lo detectó al
reanudar y lo eliminó. (3) Primera corrida sugería encabezados sin contenido
("MATERIA", "FUENTES") para "mochila"; corrigió la regla de herencia y volvió a correr
(JSON idéntico, md5 `d8ef55cd…`). (4) Un grep de "circular 181" contó sus propios
artefactos; lo repitió excluyendo `lab_motor_v9/` antes de afirmar el cero.

**Problemas reportados (no corregidos; van a AUD y a la síntesis).** (a)
`aviso_vigencia` es `null` en las 25 normas; la marca de sustitución sale solo de
`vigencia`. (b) Slug del DFL 1 dice "asistentes" y su título dice estatuto docente
(pendiente conocido en `ESTADO.md`). (c) 20 de 39 encabezados del glosario están
truncados a 60 caracteres con la definición pegada; uno trae `®` del OCR. (d) El nombre
original `20845 INCLUSION SEP` produce un alias ambiguo (Ley SEP = 20.248); erratas
`CIRULAR 193`, `DLF 315` en el README del corpus. (e) `relaciones.json` no tiene
`fuente` en todas las relaciones (ver §8, error O-1 del orquestador). (f)
`34_generar_paginas.R` y `10_utils.R` usan `$` sobre datos de disco (mitigado por
`warnPartialMatchDollar`). (g) Los preámbulos arrastran la cabecera de la BCN ("Url
Corta: https://bcn.cl…") en 17 a 19 normas: contamina cualquier índice.

**Residuos.** No medido: latencia real en navegador, compresión efectiva en Pages,
equivalencia ICU/JS de la normalización, lenguaje real del equipo (proxies declarados:
86/200 unigramas y 53/150 bigramas del corpus cubiertos; 23 consultas humanas del
repo, 11/23 resueltas con AND). Estimado: descarga a 3 Mbps.

### 2.5 A5 — Panel adversarial

Estado: **terminado** en fase 1 (reanudado a las 08:08; informe recibido ~08:25). El
contraste de fase 2 contra los documentos de A1 a A4 queda pendiente (decisión D6).
Archivo: `20260904_panel_adversarial_motor_v1.md` (316 líneas, fuente: `wc -l` del
orquestador). Laboratorio: 10 archivos `a5_*` (`a5_consultas_equipo.csv` con 38
consultas construidas, `a5_cobertura.R` y su resultado y salida, `a5_dimensiones.R` y
salida, `a5_rotulos.R` y salida, `a5_verificacion_extra.R` y salida), corridos con
`Rscript 50_documentacion/andamios/lab_motor_v9/<script>.R 2>&1 | tee <salida>.txt`.
Sin git de escritura, sin pipeline, sin red, sin Python (declarado en su informe).

**Cifras con comando (según su informe):** tabla de cifras base en §0 de su documento;
greps del DFL 1, "aula segura" y LGE en §1.1 y §1.2; rótulos en §2 (instrumento
`a5_rotulos.R` §1 a §6 y `a5_verificacion_extra.R`); cobertura en §3.2 y §3.3
(`a5_cobertura.R`); dimensionamiento en §5 y §6 (`a5_dimensiones.R`).

**Hallazgos (una línea cada uno; el contraste de fase 2 dirá cuáles sobreviven):**

| H | Veredicto | Afecta | Cambio exigido |
|---|---|---|---|
| H-1 | obliga a cambiar | A3 (tareas 3, 4, 7) | rótulo de nivel y estado como texto plano dentro de cada bloque de salida; el arnés verifica el texto, no el DOM |
| H-2 | obliga a cambiar | A1 | el vocabulario derivado cubre 21 % de términos y 3 % de consultas (42 % sin ninguna palabra): alias curados con procedencia, flexión, criterio de éxito con consultas llanas |
| H-3 | obliga a acotar | A2 (4ter) | temporalidad solo como "publicado hasta X" más sustitución; "vigente en X" no respondible (1 sustitución, 4 años nulos, 0 campos de versión, `art-16-b` duplicado, LGE consolidada a 2010) |
| H-4 | obliga a cambiar | A3 (tarea 7) | niveles 1 y 2 no existen en datos (`tipo_fuente` con un solo valor; dos insignias con 0 usos); escribir la regla de derivación por `tipo` |
| H-5 | obliga a cambiar | A3 (tarea 5), A2 (tarea 5) | caso adversarial "norma citada por el corpus pero ausente" (aula segura / ley 21.128: 22 y 17 menciones) |
| H-6 | obliga a acotar | A3 (tareas 1, 2, 6), AUD | los ejemplos nacen `estado: borrador`; degradación con 0 validadas; la compuerta valida forma, no autoría |
| H-7 | obliga a acotar | A2 (4quater), A3 | en capa 3 en vivo el OCR se excluye del contexto; en capa 2 "marcado" solo si la marca va en el texto |
| H-8 | obliga a acotar | A2 (4bis), A3 (tarea 9) | reranking y descomposición solo con ganancia medida, comparados contra "más candidatos" y orden determinista por metadatos |
| H-9 | obliga a acotar | A4 (tarea 8) | ningún componente del stack pasa la prueba; justificar incluso el Worker; "no construir capa 3 en vivo" como opción |
| H-10 | obliga a acotar | A2 (tarea 4) | híbrida en dos tiempos; residuo vectorial medido 4/38 |
| H-11 | obliga a acotar | SINT | orden: capa 1 ampliada → capa 2 condicionada → capa 3 precalculada con primera firma → capa 3 en vivo fuera de este ejercicio |

No derriba: "estructurar el análisis" (condicionado a H-1); la adopción híbrida en su
núcleo léxico; la página de pieza publicada.

**Errores propios declarados por A5.** (1) Control positivo de `a5_cobertura.R` mal
calibrado ("mochila" en singular no existe en el corpus): `stopifnot` abortó;
recalibrado con "mochilas" y el singular convertido en medición declarada. (2) Siete
objetivos del CSV declarados "fuera del corpus" sin medir la frase; cuatro aparecen de
paso; etiquetas corregidas tras el grep. (3) Detector de rótulos con 2 falsos positivos
(`ocr` dentro de "democrática"); verificado con `a5_verificacion_extra.R`. (4) Un
bloque `&&` cortado por `grep -c`/`ls` con código 1; comandos repetidos aparte. (5) Una
raya larga transcrita del título del encargo; reemplazada. (6) Reanudación tras el
corte: verificó los ocho artefactos en disco, releyó las tres salidas y solo rehízo la
corrida de cobertura.

**Premisas del encargo cuestionadas (van a AUD y a la síntesis).** P1 "cuatro insignias
ya existen": 2 de 4 con 0 usos y `tipo_fuente` con un solo valor. P2 "682 unidades":
las unidades con ancla son 806. P3 `vigencia`/`sustituido_por` insuficientes para
temporalidad. P4 el criterio de éxito de A1 está dentro del vocabulario por
construcción. P5 la LGE del corpus es la versión BCN del 02-JUL-2010, sin los artículos
16 A a 16 E (bloqueante de contenido para toda capa; fuera del alcance porque
`20_insumos/` es intocable). P6/P7: 25/682/552/84 en 5/22/0 y `glosario.md`
confirmados.

**Residuos.** No medido: comportamiento de la UI de Pagefind (filtros en tarjeta,
stemming español), línea base sobre sus 38 consultas (es de A2), "armas" en plural.
Calculado: peso del índice vectorial; 835 sub-resultados; 10,4 % OCR. Decidido no
hacer: consultar el índice Pagefind por programa (lo consideró prohibido por riesgo de
reindexar; el orquestador sí lo autorizó a A2 por la vía D2, en modo lectura). Las 38
consultas son construidas, no dato de uso.

### 2.2 A2 — Capa 2: búsqueda semántica

Estado: **terminado** (dos reanudaciones, 08:08 y 14:21; informe recibido ~14:23).
Archivos: `20260904_alcance_capa2_semantica_v1.md` (479 líneas),
`20260904_medicion_corpus_semantica.R` (661 líneas), `lab_motor_v9/a2_consulta_pagefind.mjs`
(55 líneas) y 15 tablas `a2_*` más (fuente: `wc -l` y `ls -la` del informe de A2;
`a2_resultados_pagefind.json` pesa 2 394 145 B). Sin git de escritura, sin Python, sin
reindexación, sin API de modelos (declarado en su informe).

**Qué hizo.** Dimensionó el corpus por unidad de recuperación, decidió la
fragmentación, calculó pesos de índice, especificó híbrida, reranking, temporalidad y
tratamiento del OCR, construyó el conjunto de evaluación de diez consultas y midió la
línea base de Pagefind en modo lectura por la vía D2 (sitio servido con `servr` en
`127.0.0.1:8767`, consulta con `a2_consulta_pagefind.mjs` invocado desde el script).

**Cifras con comando.** Todas salen de
`Rscript 50_documentacion/andamios/20260904_medicion_corpus_semantica.R` (secciones
TAREA 1, 3, 4ter, 4quater, 5, 6 y CIERRE de su salida) y están tabuladas cifra →
comando/tabla en la sección 10 de su documento. Principales: 682 artículos (coincide
con `n_articulos` del catálogo) en 806 unidades; 227 unidades > 512 tokens (regla c4);
0 artículos sobre 8 192 tokens con 302 sobre 256; índice int8 × 384 = 311,5 a 500,5 KB
frente a float32 × 1 024 = 5,3 MB (calculado); 84 unidades OCR no firmadas en 5
documentos frente a 722 firmadas en 20; 19 de 19 anclas del conjunto aceptadas y 10 de
10 esperadas presentes en `40_salidas/sitio/*.html`; latencia Pagefind en Node 0,70 a
27,48 ms; 9 de 10 consultas cubiertas con K ≤ 28 y C07 en rango 65.

**Decisiones.** Unidad = segmento (806, no 682) con ventana 400/50 solo sobre las 227
unidades largas (1 160 fragmentos firmados); índice int8 × 384 estático en el navegador;
vía léxica Pagefind con expansión y reordenamiento de sub-resultados como paso
obligatorio; fusión RRF con `k = 60` y K = 30 por vía; reranking en tres niveles con
un R0 determinístico como piso; OCR devuelto marcado en bloque aparte y no citable;
filtro temporal por año con marca, sin ocultar. Vectorize descartado a esta escala y a
100 normas (2,0 MB calculados).

**Fuera, con razón.** Vectorizar corpus o consultas (cuota prohibida); peso del modelo
en el navegador (sin red); precios (A4); reranker propio (§0bis); leer el vocabulario
de A1 (su variante `canonico` es un mapeo manual, cota superior).

**Errores propios declarados por A2.** (1) `!!s` dentro de una función anónima anidada
en `mutate()` se evaluaba al capturar el argumento externo; corregido con subsetting
base. (2) `aplanar()` devolvía un tibble sin columnas cuando Pagefind daba 0 páginas y
`distinct()` abortaba; corregido con tibble vacío tipado (apareció porque 3 consultas
devuelven 0 páginas). (3) Total de fragmentos firmados salía 1 344 (igual al general)
por un `firmada = TRUE` dentro del `summarise`; corregido filtrando antes de sumar,
verificado en la salida (1 160). (4) `K_max` daba `-Inf` sin apariciones; corregido a
`NA`. (5) Reanudaciones verificadas con `ls -la`, `wc -l`, `parse()`, `tail`,
`grep '^## '`, conteo de filas C01 a C10 y relectura de `a2_verificacion_anclas.csv`.

**Problemas reportados (no corregidos; van a AUD y a la síntesis).** H1 Pagefind no
devuelve cero para `xyzzy` (4 páginas): todo control negativo de otra capa que use
Pagefind debe contar anclas, no resultados (afecta el criterio de éxito de A1). H2 La
UI (`busqueda.html`) muestra a lo más 3 sub-resultados por norma en orden de documento:
el artículo correcto queda oculto (0 de 10 sin filtro); corrección barata vía
`process_result`, fuera de su autorización. H3 El segmentador dejó el cuerpo entero del
dictamen 065 (20 769 caracteres) bajo `#fuentes`. H4 No hay vigencia por artículo: la
ley 21.809 reescribe los arts. 15 y 16 B de la LGE y ambas redacciones conviven sin
relación. H5 "682 artículos" son 682 de 806 unidades; dictámenes y REX aportan 0
artículos. H6 El dictamen 078 (vigente) es OCR: la única doctrina citable sobre
mochilas es la norma sustituida. La cifra heredada de 84 páginas OCR en 5 documentos
quedó confirmada por recuento propio.

**Residuos.** Tokens estimados con dos reglas declaradas (c4 y c35), no medidos; peso
del modelo de embeddings en navegador no medido; calidad de la vía vectorial e int8 no
medida (cuota prohibida); precios diferidos a A4 (entrega cantidades: 301 659 tokens
c4 por build firmado, ~20 por consulta, 8 250 a 15 930 por reranking de 30
candidatos); latencia medida en Node, no en navegador; compresibilidad sobre proxy
sintético; conjunto de evaluación de A2, no del equipo; extrapolación a 100 normas
lineal.

### 2.4 A4 — Arquitectura Cloudflare

Estado: **terminado** (dos reanudaciones, 08:08 y 14:21; informe recibido ~14:25).
Archivos: `20260904_alcance_arquitectura_cloudflare_v1.md` (496 líneas) y seis de
laboratorio: `a4_citas_verificadas.R` (166), `a4_citas_verificadas.csv` (57, 56 filas
más encabezado), `a4_costos.R` (111), `a4_medir_corpus.R` (92), `a4_stack_minimo.R`
(68), `a4_worker_esqueleto.js` (241, no ejecutado) (fuente: `wc -l` del informe de
A4). Sin git de escritura, sin `wrangler` ni despliegue, sin Python (declarado).
Dominios contactados: `developers.cloudflare.com`, `www.cloudflare.com`,
`docs.claude.com`, `www.anthropic.com`; ninguna redirección a otro host fue seguida
(guarda de hosts en `a4_citas_verificadas.R` que aborta antes de la red).

**Cifras con comando.** Corpus (25 normas, 682 artículos, 806 segmentos, 5 normas OCR
con 84 segmentos y 224 276 caracteres, 552 relaciones, largos mín 59 / mediana 888 /
p90 3 117 / máx 27 167 caracteres, JSON 1 881 890 B y 431 668 gzip, sitio 41 737 491 B,
Pagefind 1 521 719 B v1.5.2): `Rscript 50_documentacion/andamios/lab_motor_v9/a4_medir_corpus.R`,
pegado en §8.1 de su documento. Costos (3 tamaños × 3 modelos × 3 escenarios,
sensibilidad a 3 caracteres/token, descomposición): `Rscript .../a4_costos.R`, salida
literal en §4.3. Stack (umbrales 4 882 vectores / 5 120 artículos / 188 normas):
`Rscript .../a4_stack_minimo.R`, salida en §8.2. Límites de Cloudflare: 47 citas
literales con URL en `a4_citas_verificadas.csv` (46 con 200, 1 con 301 dentro del mismo
host) y en las tablas de §1, §2, §3, §5 y §7; resumen dato → URL → estado en §9.

**Decisiones.** `workers.dev`: **resuelto, sí**, con dos páginas oficiales
(`.../workers/configuration/routing/workers-dev/`: "Access can protect one Worker's
production workers.dev URL, preview URLs, or both"; `.../workers/configuration/cloudflare-access/`:
"This automatically protects every domain associated with the Worker, including its
routes, Custom Domains, workers.dev hostname, and previews", requisito "Zero Trust
enabled on your account", sin mención de zona); queda NO MEDIDO que funcione con el
plan Zero Trust Free, con experimento de 6 pasos en §2. AI Search: **verificado como
servicio, descartado como base** (híbrida vector + BM25, fusión `rrf`/`max`,
`scoring_details`, reranking opcional `bge-reranker-base`, 8 operadores de filtro,
20 000 consultas/mes en Free; pero tokenizador Porter o trigramas sin opción de idioma,
fragmentación a 512 tokens que rompe la unidad de artículo y 5 campos de metadatos).
Stack mínimo: GitHub Pages más un Worker Free en `workers.dev` con Access, secreto,
binding de Rate Limiting, Durable Object SQLite para cuota y Workers AI opcional; D1,
R2, Vectorize y AI Search descartados con números (§8.3); la hipótesis del encargo se
intentó refutar y sobrevive (ningún cupo Free supera el 5 % en el escenario alto).
CORS: servir la UI de la capa 3 desde el propio Worker (mismo origen), porque Access
devuelve 403 a los `OPTIONS`.

**Fuera, con razón.** Publicar los JSON de datos en el sitio (precondición de la
variante "ids" del Worker; cambio del pipeline fuera de su autorización, declarado
para la síntesis); prompt del sistema y UI (A3); elección de vía léxica/vectorial (A2).

**Errores propios declarados por A4.** (1) Reanudaciones verificadas con `ls -la`,
`wc -l`, `tail` y reejecución de los scripts, con grep de líneas literales (1 y 1)
entre salida pegada y reejecución fresca. (2) Cuatro `WebFetch` fallaron por límite de
sesión; los reemplazó por `curl -s` más extracción en R (`stringi`), con `curl -sI`
antes de cada lectura. (3) El `grep` del sistema es `ugrep` y falló con `.{0,80}` sobre
UTF-8; movió la extracción a R; un `Rscript -e` falló por escapes y lo reescribió como
script. (4) Un `&&` con `ls` de archivos inexistentes detuvo un bloque; repitió la
reejecución aparte. (5) Un grep de consistencia con espacios literales dio 0 en script
y documento; lo repitió tolerante a espacios (1 y 1) antes de afirmar la coincidencia.
(6) Precisó el recuento de filas del CSV en §9 ("47 con estado verificado: 46 con 200,
1 con 301 del mismo host") para que coincida con `table(estado)`.

**Problemas reportados (no corregidos; van a AUD y a la síntesis).** Redirecciones
no seguidas: `docs.claude.com/en/docs/about-claude/pricing` → 302 `platform.claude.com/...`;
`docs.claude.com/en/api/pricing` → 301; `docs.claude.com/` → 301 `platform.claude.com/docs`;
`docs.claude.com/en/docs/about-claude/models/overview` → 302; `www.anthropic.com/pricing`
→ 301 `claude.com/pricing`; `www.anthropic.com/api` → 301 `claude.com/platform/api`
(confirma D4). `www.cloudflare.com/plans/zero-trust-services/` responde 200 pero se
renderiza con JavaScript: el cupo de usuarios de Zero Trust Free no es verificable con
`curl`. `developers.cloudflare.com/cloudflare-one/applications/` redirige 301 dentro
del host, y `.../cloudflare-one/tutorials/access-workers/` trata de encabezados
personalizados: la página correcta es `.../workers/configuration/cloudflare-access/`.
El sitio publicado no expone `datos/*.json` (solo `search.json`): cualquier diseño que
lea los JSON canónicos desde el Worker o el navegador exige un cambio del pipeline. La
cifra heredada de 84 páginas OCR en 5 documentos se confirma (84 segmentos, 5 normas).

**Residuos.** Precio de la API (NO MEDIDO, tabla provisional rotulada); usuarios
máximos de Zero Trust Free (NO MEDIDO); CPU real del paso a través en streaming y de la
validación JWT (NO MEDIDO, instrumento en §3.2); cookie de Access entre sitios (NO
MEDIDO); binding de Rate Limiting en Free (hipótesis); 4 caracteres por token y tamaño
del equipo (supuestos); límites de GitHub Pages (`github.com` no autorizado para eso);
stemming en español de AI Search y peso de un modelo de embedding en navegador (NO
MEDIDO); extrapolación a 100 normas lineal; nada desplegado; esqueleto JS no ejecutado.

### 2.3 A3 — Capa 3: orientación

Estado: **terminado** (dos reanudaciones, 08:08 y 14:21; informe recibido ~14:35).
Archivo: `20260904_alcance_capa3_orientacion_v1.md` (839 líneas). Laboratorio: 22
archivos `a3_*`, 2 382 líneas en total (`wc -l a3_*` del informe de A3): scripts de
carga de definiciones, verificación de anclas, prueba de compuerta, arnés de citas,
constructor de capa experta, ontología de relaciones y presupuesto de tokens, cada uno
con su `*_salida.txt`; ruta de ejemplo (`a3_ruta_uso_dispositivos_moviles.md`), tres
entradas de capa experta (`a3_tema_*.md`), `a3_capa_experta.json`, `a3_rutas.json`,
`a3_prompt_sistema.md`, `a3_salida_ejemplo_mixta.json`, `a3_casos_adversariales.yml`.
Los 6 temporales `a3_tmp_caso_*` de la prueba de compuerta se borraron al terminar
(`Quedan a3_tmp_*: 0`). Sin git de escritura, sin `source()` de 34 ni 33 completos,
sin pipeline, sin Python (declarado).

**Cifras con comando (tabla completa en §12 de su documento).** 806 ids / 682
artículos / 25 normas (`a3_verificar_anclas_salida.txt` (a)); 552 relaciones =
2/2/46/502 y 67 descartadas (`a3_ontologia_relaciones_salida.txt` (0)); 84 páginas OCR
en 5 documentos (`Rscript -e` sobre los JSON sumando ids `ocr-pagina-*`); 17 temas
(`ls 40_salidas/sitio_src/tema-*.qmd | wc -l`); 22 piezas, 0 validadas
(`grep -l "^estado: validada"`); insignias por página (`grep -l badge-* 40_salidas/sitio/*.html | wc -l`);
`tipo_fuente` 25/25 normativa; 83/36/47 expresiones de 34 y 47/13/34 de 33; formas /
términos / consideraciones por entrada 13/7/8, 14/10/8, 11/7/6 recontadas con `awk`;
prompt del sistema 5 022 caracteres; mediana/p90 de artículos 888/3 117 caracteres
(`a3_presupuesto_tokens_salida.txt`).

**Decisiones.** Ruta de abordaje y entrada de capa experta como piezas con
`tipo: faq` más `subtipo` (`ruta_abordaje` / `capa_experta`): pasan la compuerta
vigente sin tocar código; `tipo: ruta_abordaje` aborta (caso C) y ampliar `TIPOS_PIEZA`
queda como mejora opcional. Lo derivable (`nivel`, `citable`, `vigencia`, etiquetas) no
se declara a mano: lo calcula el constructor, y un `nivel` declarado distinto del
derivado es reparo. Tema de la ruta de ejemplo: uso de dispositivos móviles (rica,
vigente, con capa de texto); expulsión descartada para la ruta porque el procedimiento
vigente (DFL 2/1998 art. 6 d, ley 21.128) no está en el corpus, y va como entrada de
capa experta que declara lo que falta. Variante en vivo: prompt completo (12 reglas,
esquema `a3-salida-v1` con cinco modos) y arnés del lado del cliente que usa
`ancla_resuelve()` real, exige `texto_citado` literal, degrada OCR a ubicación, agrega
la advertencia de sustitución desde el dato y retira toda frase con cita no verificada.
Cuatro niveles derivados del dato, una línea por nivel, marca textual entre corchetes
además de la insignia; se especifica `.badge-inferencia` sin tocar `estilo.css`.
Ontología: entran `modifica` (8 pares, con advertencia de texto no consolidado),
`reglamenta` (2), `interpreta` (rótulo de 11 remisiones de dictamen), `deroga` solo
como nota marginal a nivel de artículo (1); se rechazan por escrito `complementa`,
`desarrolla` y `contradice`. Descomposición: sobrecosto calculado (+1 llamada, ×2,3 el
contexto en el caso mediano), ganancia NO EVALUADA y no recomendada.

**Errores propios declarados por A3.** (1) La primera regla de `deroga` dio 4 pares
con control positivo pasado y los 4 eran falsos ("normas no derogadas" y notas
marginales con dirección invertida): un control positivo prueba sensibilidad, no
precisión; faltaba el negativo. Corregido con reglas D1/D2, control negativo y corte en
fecha del D.O.; recuento 0 y 1. (2) Dos defectos en `a3_ontologia_relaciones.R`
detectados al releerlo antes de correr (`mismo_grupo` con el slug sintético;
`regmatches` sobre otra cadena). (3) Un `Rscript -e` con escapes falló por el quoting;
sondeo movido a archivo. (4) Las cifras de formas/términos/consideraciones se
escribieron primero de memoria y se recontaron con `awk` antes de entregar
(coincidieron; el orden correcto era recontar primero). (5) Reanudaciones verificadas
con `ls -la`, `git status --porcelain` sobre carpetas prohibidas (vacío) y lectura de
las salidas; en la segunda faltaban ontología y presupuesto, que corrió entonces.

**Problemas reportados (no corregidos; van a AUD y a la síntesis).** (1) "682
artículos" no es el número de anclas citables: 806 `id` (682 `es_articulo`, 124
preámbulos, secciones de dictamen y páginas OCR). (2) "Cuatro insignias en
`estilo.css`": cierto en el CSS, pero el HTML solo usa `badge-normativa` (42 páginas;
las otras tres 0) y `tipo_fuente` es `normativa` en 25/25: el nivel 2 no está
distinguido en el dato. (3) La LGE del corpus es el texto de 2009 sin consolidar (las
frases insertadas por 21.801 y 21.809 no están en `ley_20370`). (4) El procedimiento
de expulsión (DFL 2/1998 art. 6 d, ley 21.128) no está en el corpus. (5)
`20260827_ensayo_general_v1.md` §3 quedó desactualizado: `pagina_pieza()` hoy sí emite
`data-pagefind-body` (línea 803). (6) Siguen las 2 anclas rotas en borradores reales
(`faq_revision_de_mochilas`, `faq_seguridad_y_deteccion`), confirmadas por
`cargar_piezas()` real.

**Residuos.** No medido: obediencia real del modelo al prompt (sin cuota); ganancia de
la descomposición; costo en USD (precio como parámetro de A4); render Quarto de la ruta
(prohibido). Convenciones: 1 token ≈ 4 caracteres; k = 8, s = 3, 600 tokens de salida.
No hecho: detector de nombres propios en el cliente (no determinístico; mitigado con
advertencia permanente); render de `pasos` desde el front matter (exige cambio en 34);
`reglamenta` para dfl_315 (fuera de la ventana de 250 caracteres); `deroga` D2 halla 1
porque 36 de 37 notas citan normas fuera del corpus; `formas_de_preguntar` es
hipótesis de A3 hasta que el equipo lo corrija; la temporalidad queda en la capa 2.

### 2.6 Cierre de la fase 1

Las cinco secciones anteriores están en orden de llegada del informe (A1, A5, A2, A4,
A3), no en orden numérico: el log se escribió a medida que cada agente terminaba.
Ningún agente leyó el archivo de otro (declarado en los cinco informes; AUD lo
verifica por contradicciones e independencia de cifras). Ningún agente escribió fuera
de su lista (verificación del orquestador en §6, bloque de la fase 1).

## 3. Controles positivos

### C0 — orquestador: el índice Pagefind existente responde en modo lectura

```
$ (Rscript -e 'servr::httd(here::here("40_salidas","sitio"), port = 8765, daemon = FALSE, browser = FALSE, verbose = FALSE)' > /dev/null 2>&1 &) ; until curl -s -o /dev/null http://127.0.0.1:8765/index.html; do :; done
$ node --input-type=module -e '
const p = await import("./40_salidas/sitio/pagefind/pagefind.js");
await p.options({ basePath: "http://127.0.0.1:8765/pagefind/" });
await p.init();
const s = await p.search("mochila");
console.log("resultados:", s.results.length);
const r0 = await s.results[0].data();
console.log("url:", r0.url, "| sub_results:", r0.sub_results.length);
console.log("sub0:", JSON.stringify({url: r0.sub_results[0].url, title: r0.sub_results[0].title}));
process.exit(0);'
resultados: 3
url: http://127.0.0.1:8765/dictamen_065_revision_mochilas.html | sub_results: 2
sub0: {"url":"http://127.0.0.1:8765/dictamen_065_revision_mochilas.html#materia","title":"MATERIA"}
$ pkill -f 'servr::httd'; pgrep -f 'servr::httd' | wc -l
0
```

Sin el servidor HTTP el mismo `import()` falla con
`TypeError: Failed to parse URL from /Users/.../pagefind-entry.json?ts=...`
(salida literal recortada de la ruta). Ese fallo es el control de que la vía HTTP
es necesaria, no decorativa.


### C1 — A1: control negativo `"xyzzy"` con su contraparte positiva (salida literal en §6 de su documento y en `lab_motor_v9/a1_salida_prototipo.txt` §9)

- `"xyzzy"` → `0 sugerencia(s)`; en el mismo bloque `"convivencia"` → `5 sugerencia(s)`
  (tema convivencia escolar 140, Ley 21.809 100, dos del glosario 70, un encabezado 50).
- `"celu"` → tema `uso de dispositivos móviles` (100), `Ley 21.801` (90), `Resolución exenta 181` (90).
- `"circular 482"` y `"REX 482"` → las mismas 3 sugerencias, `destino_canonico` =
  `rex_482_instrucciones_reglamentos_internos.html` en ambas.
- `"mochila"` → tema `revisión de pertenencias` (100), `Dictamen 078` con rótulo
  "sustituye a dictamen_065…" (90), `Dictamen 065` con rótulo `sustituida por
  dictamen_078_detectores_revision_mochilas` (65).
- Verificador de anclas: `#art-999-inexistente` → FALSE; `#art-10-ter` → TRUE.
- Alias: `LIE`, `SAE`, `LSAC` → 0, con control `convivencia` = 5 al lado; grep de
  "circular 181" fuera del laboratorio → 0 archivos ajenos, control con `482` = 14 archivos.
- Los cuatro casos plantados son `stopifnot()` dentro del script; salida 0 más las
  cifras anteriores como evidencia de ejecución.

(el resto: pendiente, se completa por fase)

### C2 — A5: ceros con su control (salida literal en `lab_motor_v9/a5_*_salida.txt`)

- Cobertura (`a5_cobertura_salida.txt`): `ctrl_pos_legal 8 términos: V 6, C 8, P 8` ·
  `ctrl_neg_inexistente: V 0, C 0, P 0` · `ctrl_pos_termino_conocido "mochilas": 1/1/1` ·
  `ctrl_singular_vs_plural "mochila": 0/0/1` · frases: `'dupla psicosocial' FALSE` con
  controles `'revision de mochilas' TRUE | 'interes superior del nino' TRUE`.
- Rótulos (`a5_rotulos_salida.txt`): "bloques OCR cuyo texto <pre> contiene alguna marca:
  2 de 84" con "CONTROL POSITIVO: avisos aviso-ocr en los que el detector encuentra la
  marca: 5 (esperado: 5)"; `a5_verificacion_extra_salida.txt` muestra que las 2 son la
  subcadena `ocr` en "democrática", así que el cero real es 0 de 84. "artículos cuyo
  cuerpo contiene el nombre corto de su norma: 0 de 722" con "CONTROL POSITIVO: 688 de
  722 contienen 'Artículo'". "líneas con autoriz|blame|gpg|firma digital|hash: 0" con
  "CONTROL POSITIVO: líneas con validado_por: 15". `badge-orientacion 0,
  badge-evidencia 0, badge-interpretacion 0` con `badge-normativa 192`.
- Vigencia: 0 claves con `fecha|vigor|derog`; el mismo instrumento lista `estado,
  sustituye_a, sustituido_por, fuente`.
- `search.json`: 0 entradas con `#ocr-pagina-` y 0 con `#art-`; control: 5 entradas de
  normas OCR con la marca "OCR" en cabecera.

### C3 — A2: controles del script de medición (salida literal citada en su informe)

- `control: n_articulos del catalogo (682) COINCIDE con el recuento propio (682)`
- `normas con algun campo 'fecha' en vigencia: 0 (control positivo: normas con campo 'estado' en vigencia: 25)`
- `unidades NO firmadas: 84 en 5 documentos | unidades firmadas (control positivo): 722 en 20 documentos`
- `anclas aceptadas verificadas contra 40_salidas/sitio/*.html: 19 | existen: 19 | no existen: 0` y
  `control negativo del verificador: id inexistente 'art-9999' en ley_21801_celulares.html -> 0 coincidencias (debe ser 0)`
- Ventana 8 192 tokens: 0 artículos sobre ella; la misma tabla cuenta 302 sobre 256.
- `control positivo C0 'mochila': 3 paginas; primera = dictamen_065_revision_mochilas.html; primer sub-resultado = #materia -> PASA (reproduce la receta del orquestador)`
- `control negativo CNEG 'xyzzy': 4 paginas devueltas (...) -> Pagefind NO devuelve cero para un termino inexistente`
- `40_salidas/: archivos antes=277 despues=277 | mtime max antes=2026-08-27 12:38:58 despues=2026-08-27 12:38:58 -> SIN CAMBIOS`

### C4 — A4: instrumento de citas y aritmética (salida literal citada en su informe)

- `curl -sI --max-time 20 https://developers.cloudflare.com/workers/platform/limits/` → `HTTP/2 200`;
  `curl -sI --max-time 20 https://developers.cloudflare.com/esta-url-no-existe-a4-control-negativo-v9/` → `HTTP/2 404`.
  Repetido desde R en `a4_citas_verificadas.R`: `control positivo C54 -> 200 [OK] | control negativo C55 -> 404 [OK]`.
- `control positivo aritmetica: 1M tokens entrada a 2.00 = 2 USD; 1M salida a 10.00 = 10 USD  [OK]`.
- Ceros de extracción con control en el mismo archivo: `zone` 0 y `Free` 0 en
  `cf_workers_access.txt` frente a `ctx.access` 20; `Free` 0 en `cf_ratelimit.txt` frente
  a `Must be either 10 or 60` 2; `multilingual` 0 en `cf_ais_models.txt` frente a
  `bge-m3` 1; `users`/`seats`/`50 users` 0 en el HTML crudo de la página de planes
  frente a `Free` 3 apariciones.
- Guarda de hosts: `hosts contactados (todos autorizados): developers.cloudflare.com,
  www.cloudflare.com, docs.claude.com, www.anthropic.com`.

### C5 — A3: compuerta real, anclas y arnés (salida literal citada en su informe)

Compuerta (`a3_probar_compuerta_salida.txt`):
```
=== CASO A  DEBE PASAR: estado validada + firma ficticia 'Ejemplo Ficticio' (declarada ficticia) + fecha ===
VEREDICTO: PASA: 1 publicable(s), 0 borrador(es)
=== CASO B1 ... === VEREDICTO: ABORTA (revisar_pieza)  - dice `estado: validada` pero no trae `validado_por`. [...]
=== CASO B2 ... === VEREDICTO: ABORTA (revisar_pieza)  - el campo `validado_por` no trae UN nombre escrito como texto. [...]
=== CASO C  tipo: ruta_abordaje === VEREDICTO: ABORTA (revisar_pieza)  - el campo `tipo` dice `ruta_abordaje`, que no existe. Usa ficha, faq o glosario.
=== CASO D  ancla inexistente === VEREDICTO: ABORTA (compuerta de anclas)  - `ley_21801_celulares.html#art-10-nonies`
=== CASO F  cargar_piezas() real === [WARN] Anclas que no resuelven en 2 borrador(es) [...] [INFO] Piezas interpretativas: 22 en total, 0 validadas y publicables.
```
Anclas (`a3_verificar_anclas_salida.txt`):
```
(a) Global: 806 ids en los 25 JSON de norma; 806 presentes como id= en su HTML; faltan 0.
  TOTAL laboratorio: 36 de 36 anclas resuelven en la compuerta real Y existen en el HTML.  (9 + 11 + 7 + 9)
  ancla inexistente  ley_21801_celulares.html#art-99   ancla_resuelve=FALSE  en HTML=FALSE  (DEBE ser FALSE/FALSE)
  ancla existente    ley_21801_celulares.html#art-10-bis  ancla_resuelve=TRUE  en HTML=TRUE
VEREDICTO: OK
```
Arnés (`a3_arnes_citas_salida.txt`):
```
  c1  ley_21801_celulares.html#art-10-bis   aceptada
  c2  ley_21801_celulares.html#art-45       rechazada   ancla inexistente o incoherente con norma/articulo
  c3  ley_21801_celulares.html#art-10-ter   rechazada   texto_citado no es copia literal del articulo
  c4  rex_482_reglamentos_b.html#ocr-pagina-022   degradada_a_ubicacion   origen_texto = ocr_pendiente_revision [...]
  c5  dictamen_065_revision_mochilas.html#materia   aceptada  (+ advertencia de sustitución agregada desde el dato)
  citas aceptadas: 2 de 5 | frases conservadas: 2 de 5 | retiradas: 3
  salida ilegible -> salida_ilegible | salida minima valida -> aceptadas: 1 de 1 | modo no permitido -> esquema_invalido
  'RUT 11.111.111-[1]' -> TRUE | 'ley 21.801 y artículo 10 bis' -> FALSE   (dígito verificador entre corchetes en este log: la regla R3 del hook rechaza toda cadena con forma de RUT, ficticia o no)
VEREDICTO DEL ARNES: OK
```
Ontología: control positivo D1 sintético «Derógase la ley N° 20.370» encuentra
`ley_20370`; control negativo «normas no derogadas ... ley N° 20.370» → 0; D2 con corte
en D.O. encuentra solo `ley_20370`. Consulta informada: control negativo «receta de pan
amasado» → sin entrada; las tres consultas en lenguaje del equipo llegan a su entrada.

## 4. Hallazgos de auditoría

(pendiente: se completa al cerrar la fase 2)

## 5. Correcciones

(pendiente: se completa al cerrar la fase 3)

## 6. Invariantes verificados al cierre

(pendiente: se completa al cerrar la fase 4)

## 7. Delegaciones ejercidas

Ninguna esperada. (pendiente de confirmar al cierre)

## 8. Errores del propio ejecutor

- **O-1 (orquestador, FASE 1, regla 4 del estándar).** La orientación de rutas que di a
  los cinco agentes describía `relaciones.json` como `relaciones[{desde, hacia, tipo,
  explicacion, fuente}]`, generalizando desde la primera entrada (`str()` de
  `relaciones[[1]]`, que es una sustitución). Recuento del turno:
  `Rscript -e '...table(unlist(lapply(r, names)))...'` → `fuente` en 4 de 552,
  `cita_literal` en 46, `temas`/`n_temas` en 502, `desde/hacia/tipo/explicacion` en 552.
  Lo detectó A1. Corrección: la orientación decía "verifica cada dato antes de usarlo",
  y cada agente recuenta; no se corrige el prompt en vuelo (los agentes ya corren) y se
  deja constancia aquí para AUD.
- **O-2 (orquestador, FASE 1, regla 3 del estándar: "salió con código 0 no es se
  ejecutó").** Al insertar la sección de A1 en este log con `perl -0pi` leyendo el
  bloque desde `$ENV{SP}`, la variable de shell no estaba exportada: `open` falló en
  silencio, el bloque quedó vacío y los tres marcadores `(pendiente…)` de §2, §3 y §8
  se borraron sin insertar nada. Lo delató el recuento: `wc -l` dio 204 líneas cuando
  se esperaban unas 290, y `grep -n '^### 2.1'` no encontró la sección. Corrección:
  reinserción con rutas absolutas dentro del script de perl y verificación por `grep`
  de los tres encabezados insertados más `wc -l`.
- **O-3 (orquestador, cierre de fase 1, regla 7 de la sesión 2: cruzar autorizaciones
  y verificaciones par a par antes de actuar).** Decidí en D1 versionar
  `lab_motor_v9/` sin haber leído el hook pre-push global que rige todos los repos de
  la cartera; su regla R1 rechaza `json`/`csv` no autorizados y el archivo de
  autorización no existe aquí. Detectado por el propio hook al pushear. Corrección: D7
  (laboratorio fuera del índice) y enmienda del commit local. Lección: leer
  `core.hooksPath` en FASE 0 de todo encargo que commitee.
- **O-4 (orquestador, fase 1, regla R3 de SETTINGS 4.3).** Copié al bloque C5 de este
  log la salida literal del arnés de A3 con el RUT ficticio `11.111.111-[1]`, y el hook
  rechaza toda cadena con forma de RUT, ficticia o no (regex
  `[0-9]{1,2}\.?[0-9]{3}\.?[0-9]{3}-[0-9kK]`). Recuento del diff rechazado:
  `git diff -U0 a07dd1a..6d1412c | grep -E '^\+' | grep -Ec '<regex>'` = 10 líneas en
  5 archivos: 2 en el documento de A3, 7 en `lab_motor_v9/` (`a3_arnes_citas.R`,
  `a3_arnes_citas_salida.txt`, `a3_casos_adversariales.yml`) y 1 en este log. Además,
  la nota operativa (g) de mi prompt a A3 sugería justamente `RUT 11.111.111-[1]` como
  ejemplo ficticio: el error nace en el prompt. Corrección: línea del log enmascarada
  (`11.111.111-[1]`, recuento posterior 0 con el mismo grep); hallazgo **G-1** enrutado
  a A3 para sus dos líneas del documento y sus tres archivos de laboratorio (aunque el
  laboratorio ya no se versiona, la regla vale para todo texto que pueda viajar).

## 9. Residuos declarados

(pendiente: se completa al cierre; D4 ya es un residuo: precio de la API no medido)

## 10. Commits

(pendiente)

## Anexo A. Incidencias de ejecución (se anota en el momento)

- **2026-09-04 ~21:20 → 2026-09-05 02:30. Primer lanzamiento de la fase 1 abortado por
  límite de sesión de la API.** Los cinco subagentes (A1 a A5) terminaron con
  `HTTP 429, rate_limit: "You've hit your session limit · resets 2am
  (America/Santiago)"` en su primer o segundo turno, antes de escribir nada.
  Verificado tras el reinicio: `git status --porcelain` muestra solo el encargo y
  este log; `ls -la 50_documentacion/andamios/lab_motor_v9/` vacío;
  `pgrep -f 'servr::httd' | wc -l` = 0. Se relanzan los cinco con prompts
  idénticos a las 02:31 del 2026-09-05. No es error del ejecutor ni de los agentes;
  se registra porque el encargo exige que el log refleje lo que pasó, no lo que
  debía pasar.
- **2026-09-05 ~02:46 → 08:08. Segundo corte por límite de sesión de la API**
  (`HTTP 429, rate_limit: "You've hit your session limit · resets 7:30am
  (America/Santiago)"`), esta vez con trabajo parcial en disco. Verificado a las
  08:08 con `git status --porcelain`: sin trackear solo el encargo, este log,
  `20260904_prototipo_vocabulario.R` (A1), `20260904_medicion_corpus_semantica.R`
  (A2) y `lab_motor_v9/` con 11 archivos (`a2_consulta_pagefind.mjs`, `a4_costos.R`,
  `a4_medir_corpus.R`, siete `a5_*`); ningún `.md` de agente todavía.
  `git status --porcelain -- 20_insumos 40_salidas 30_procesamiento 10_utils | wc -l`
  = 0; `pgrep -f 'servr::httd' | wc -l` = 0. Decisión: **reanudar los cinco agentes
  con su contexto** (mensaje de continuación al mismo agente) en vez de relanzar,
  con la instrucción de verificar en disco qué ya escribieron antes de seguir.
- **2026-09-05 ~08:25 → 14:20. Tercer corte por límite de sesión de la API** (`HTTP 429,
  rate_limit: "You've hit your session limit · resets 1pm (America/Santiago)"`) sobre
  A2, A3 y A4, después de que A1 y A5 entregaran su informe. Verificado a las 14:20:
  `git status --porcelain` muestra ya los documentos de A1, A2, A4 y A5 y los dos
  scripts; A2 y A4 escribieron su documento (479 y 496 líneas, `wc -l`) pero no
  entregaron el informe; A3 tiene 20 archivos `a3_*` en el laboratorio (mtimes 08:11 a
  08:21) y ningún documento. `git status --porcelain -- 20_insumos 40_salidas
  30_procesamiento 10_utils | wc -l` = 0; `pgrep -f 'servr::httd' | wc -l` = 0. Se
  reanudan los tres con su contexto a las 14:21.
- **2026-09-05 14:37 → 20:25. Push de la fase 1 rechazado por el hook pre-push** (R1 y
  R3; salida literal en D7 y O-4). Commit local `6d1412c` (73 archivos) intacto, no
  pusheado; `git rev-parse HEAD origin/main` = `6d1412c…` / `a07dd1a…`. Corrección
  dentro de las autorizaciones: laboratorio fuera del índice, línea del log
  enmascarada, corrección de A3 enrutada a A3 (G-1), commit enmendado (sigue siendo el
  primero de los cinco: la enmienda es local). En la misma ventana, **cuarto corte por
  límite de sesión** (`resets 6:50pm`) sobre A5 al iniciar el contraste de fase 2;
  reanudado a las 20:26.
- **O-5 (orquestador, 20:30, misma regla que O-4).** Al redactar O-4 escribí dos veces
  el literal con forma de RUT que estaba describiendo, y el recuento posterior a la
  enmienda dio 2 en vez de 0. Corregido con `perl -pi` (dígito verificador entre
  corchetes) y recontado: 0 en el log, 1 en la cadena de control construida con
  `echo`. Regla operativa desde ahora: todo texto que cite ese ejemplo lo escribe
  enmascarado, incluida la descripción del error.
