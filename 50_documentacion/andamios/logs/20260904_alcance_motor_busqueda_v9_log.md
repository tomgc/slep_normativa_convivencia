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
- **D8 (2026-09-05 20:30). Cambio de modelo y reasignación de los dos agentes muertos.**
  A3 (corrección G-1) y A5 (contraste de fase 2) terminaron con
  `HTTP 429: "You've reached your Fable limit"`, distinto de los cortes anteriores: la
  cuota del modelo se agotó, no la ventana de sesión, así que reanudarlos habría vuelto
  a fallar. El titular cambió el modelo de la sesión a Opus 5 (1M de contexto) con
  esfuerzo `ultracode`. Los roles A3 y A5 se reasignan a **instancias nuevas del mismo
  rol** sobre Opus 5, con el estado en disco como contexto (los documentos y el
  laboratorio están completos y son la fuente). Se declara porque cambia quién escribió
  qué: las secciones de fase 1 de A3 y A5 son de las instancias originales; el cierre de
  G-1 y el contraste de fase 2 son de las nuevas. Ningún archivo cambia de autor: el
  rol es el mismo y cada archivo lo sigue escribiendo su rol.
- **D9 (2026-09-05 20:31). La auditoría se ejecuta en abanico, con un solo autor.**
  El encargo pide un agente AUD secuencial que re-derive desde los artefactos. Se
  implementa como **doce verificadores independientes** (cifras de A1, A2, A3, A4 y A5;
  anclas; universales; ceros; citas externas; autorizaciones contra escrituras;
  contradicciones; y el control positivo de la auditoría misma), más una **verificación
  adversarial**: cada hallazgo clasificado bloqueante o mayor pasa por un escéptico que
  intenta refutarlo con el comando del auditor reproducido, y el refutado no entra como
  hallazgo sino a una tabla de descartados con su razón. Un único agente consolida y
  escribe `20260904_auditoria_alcance_motor_v1.md`. Por qué respeta el encargo: la
  independencia exigida sale reforzada (doce re-derivaciones separadas en vez de una), la
  regla "ningún archivo tiene dos autores" se mantiene (los verificadores no escriben
  archivos; el único que escribe en el laboratorio es el del control positivo, con
  prefijo `aud_`), y la regla "la auditoría no corrige lo que audita" se declara en el
  prompt de los trece. El costo en tokens no es criterio en esta sesión (modo
  `ultracode`); la precisión sí.
- **D10 (2026-09-06 08:05). La fusión se reparte por destinatario.** El primer intento de
  fusionar los 125 hallazgos en una lista canónica única murió con
  `API Error: Claude's response exceeded the 64000 output token maximum`. No es un
  problema de contenido sino de forma: la salida estructurada de 125 objetos no cabe en
  una respuesta. Se reparte en seis fusionadores, uno por destinatario (A1, A2, A3, A4,
  A5 y ORQ con ENCARGO), cada uno con su porción del expediente. Efecto colateral
  favorable: cada fusionador conoce a fondo un solo documento.
- **D11 (2026-09-06 08:05). El documento de auditoría se escribe por secciones.** Por el
  mismo tope de salida, el redactor recibe la instrucción explícita de crear el archivo
  con el encabezado y la tabla maestra y **anexar una sección por llamada**, verificando
  con `wc -l` después de cada anexado. Un documento de 1 193 líneas no cabe en una sola
  respuesta y el intento habría fallado en silencio a mitad de camino.
- **D12 (2026-09-06 13:35). El paquete se pasa por archivo, no por prompt.** El
  expediente de la auditoría (547 KB, 1 773 líneas) y los veredictos (96 KB) viven en el
  directorio temporal de la sesión y los agentes los leen de ahí. Ni el expediente ni los
  paquetes intermedios se versionan: lo que queda en el repositorio es el documento de
  auditoría, que cita su evidencia literal. La reconstrucción, si hiciera falta, sale del
  diario de los workflows, cuya ruta queda anotada en §10 de este log.

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

### 2.7 Fase 2a — cierre de G-1 (rol A3, instancia nueva)

Estado: **terminado** (2026-09-05 20:36, agente del workflow sobre Opus 5). La instancia
anterior había dejado el documento y dos archivos del laboratorio sin cadenas con forma
de RUT, pero no había regenerado la salida del arnés, así que el documento citaba una
salida que aún no existía. La instancia nueva reejecutó
`Rscript 50_documentacion/andamios/lab_motor_v9/a3_arnes_citas.R`, con evidencia de
ejecución real y no de código 0: mtime 08:21 → 20:36, 2 576 → 2 719 bytes, 28 → 29
líneas. Veredicto del arnés: `OK`. Encontró **una discrepancia** entre el documento y la
salida real (el documento citaba una etiqueta que la salida no imprime) y corrigió el
documento, nunca el instrumento. Control del par cero/positivo en el mismo bloque: el
patrón da 0 en los cuatro archivos de A3 y 1 sobre una cadena construida en el momento
con `printf`, y 2 sobre la salida vieja respaldada, que es exactamente lo que el
orquestador había medido antes.

### 2.8 Fase 2b — contraste adversarial de A5 (instancia nueva)

Estado: **terminado** (699 líneas, `wc -l`). Con los cuatro documentos de A1 a A4 ya
escritos y legibles, A5 contrastó sus once hallazgos a ciegas: **5 sostenidos, 2
atenuados, 4 retirados**, y **9 nuevos** (H-12 a H-20) que solo se podían formular
leyendo los documentos. De los nuevos, tres obligan a cambiar el diseño (H-12: la
variante `canonico` de A2 es una cota no alcanzable hoy sin la tabla de alias de A1;
H-13: el arnés de A3 verifica procedencia y no suficiencia, y no puede presentarse como
garantía antialucinación; H-14: el filtro del Worker de A4 debe pasar de `es_articulo`
a `origen_texto`, porque si no el nivel 2 de A3 no existe y dos de las diez consultas de
A2 quedan sin respuesta), cinco obligan a acotar y uno corrige una atribución. A5 declaró
además **seis afirmaciones propias de fase 1 que resultaron falsas**, con su corrección.
El criterio de éxito del encargo ("al menos un hallazgo que obligue a cambiar el diseño,
o la declaración argumentada de que no lo hay") queda cumplido con margen.

### 2.9 Fase 2c — auditoría independiente (AUD)

Estado: **terminado** (`20260904_auditoria_alcance_motor_v1.md`, 1 193 líneas, 13
secciones, las 13 que exige el encargo). Método declarado en D9: doce verificadores
independientes, verificación adversarial de los graves, fusión por destinatario y
consolidación por un solo autor. Resultado: **125 hallazgos crudos → 91 defectos
canónicos** (2 bloqueantes, 5 mayores, 58 menores, 26 mejorables) y **7 descartados**
por los escépticos, cinco de los cuales dejaron un defecto real más angosto que sí entra.

Veredicto de AUD, literal: los cinco documentos **son utilizables tal como están**; los
dos bloqueantes no son contra A1 a A5 sino contra el instrumento de la propia auditoría
(la versión 1 de su procedimiento, ya corregida y re-verificada), y su valor vivo es
invalidar esa pasada como evidencia. La reserva es nominal y acotada: la síntesis no
puede tomar sin corregir el residuo "4 de 38" de A5, el filtro `es_articulo === true`
de A4, el "3,4 %" de Vectorize de A4 y la regla de puntaje de §4.3 de A1.

Reparto de la fase 3, recuento programático de AUD sobre su propia tabla maestra: A1 19,
A2 19, A3 10, A4 17, A5 12, ORQ 11, más 3 filas de agente compuesto. ENCARGO 0 (su único
candidato fue descartado).

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

### C6 — AUD: control positivo de la auditoría sobre sí misma

AUD plantó en el laboratorio tres archivos con defectos conocidos
(`aud_control_cifra_falsa.md`, `aud_control_ancla_falsa.md`,
`aud_control_cero_sin_control.md`), escribió su procedimiento de auditoría en
`aud_procedimiento.R` y lo corrió sobre ellos, con control negativo sobre fragmentos
reales y correctos de los documentos de fase 1 (`aud_fragmento_negativo_a1.md`,
`aud_fragmento_negativo_a2.md`). La primera versión del procedimiento **falló** en tres
de los defectos plantados, y ese fallo es el origen de los dos únicos hallazgos
bloqueantes del paquete: no apuntan a ningún autor, apuntan al instrumento de la propia
auditoría. La versión 2 los detecta. Salida literal en §9 del documento de auditoría.
Consecuencia de método, ya asumida: `aud_procedimiento_salida_v1.txt` queda **invalidado
como evidencia** y no se cita en ningún documento del paquete.

### C7 — AUD: la contrabarra que se come el intérprete (regla 5 del estándar)

AUD descubrió, con su propio control positivo, que en esta sesión un patrón con `\b`
dentro de `Rscript -e '...'` llega a R con la contrabarra colapsada, de modo que `\b`
deja de ser frontera de palabra, el patrón no coincide y **devuelve 0 en silencio**. Lo
delató que el control positivo `LGE` diera 0 cuando debía dar 15. Zanjado moviendo el
comando a un archivo (`Rscript archivo.R`), donde el patrón llega intacto: `SEP` 7,
`LGE` 15, `ZQX` 0. Es la regla 5 del estándar en estado puro (ningún patrón dependiente
del entorno se escribe a mano: se deriva provocando el caso) y obliga a una regla
operativa para todo el paquete: **todo comando con `\b` se ejecuta desde archivo, no con
`-e`, y lleva su prueba de instrumento al lado.**

## 4. Hallazgos de auditoría

El documento completo es `50_documentacion/andamios/20260904_auditoria_alcance_motor_v1.md`
(1 193 líneas, 13 secciones más la adenda de la segunda pasada). Aquí va el recuento y el
enrutamiento; el detalle, con el comando de cada cifra, vive allá y no se duplica.

| Clasificación | n | Qué significa (rúbrica del encargo, línea 266) |
|---|---|---|
| bloqueante | 2 | impide usar el documento |
| mayor | 5 | cambia una conclusión |
| menor | 58 | precisión |
| mejorable | 26 | calidad sin error |
| **total canónico** | **91** | de 125 hallazgos crudos, tras deduplicar las dos pasadas |
| descartados | 7 | refutados por los escépticos; 5 dejaron un defecto más angosto que sí entra |

Reparto por agente que corrige (recuento de AUD sobre su propia tabla): **A1 19, A2 19,
A3 10, A4 17, A5 12, ORQ 11**, más 3 filas de agente compuesto. ENCARGO 0: su único
candidato fue descartado.

**Los dos bloqueantes no son contra ningún autor.** Apuntan al instrumento de la propia
auditoría: su primera versión no detectó tres de los defectos que ella misma había
plantado. El código quedó corregido en la versión 2 y las reglas de método que la falla
enseñó están en §12. Veredicto de AUD sobre los cinco documentos: **son utilizables tal
como están**, con la reserva nominal de cuatro cifras que la síntesis no puede tomar sin
corregir.

El estado de cada hallazgo tras la fase 3 está en la sección 14 del documento de
auditoría (segunda pasada, acotada a bloqueantes y mayores) y resumido en §5 de este log.

## 5. Correcciones

La fase 3 corrió en dos rondas, porque la primera introdujo defectos nuevos y el encargo
exige que la corrección se verifique, no que se declare.

**Ronda 1 (2026-09-06, cinco autores en paralelo más cinco verificadores independientes).**
Cada autor corrigió su propio archivo contra las filas de la tabla maestra dirigidas a él;
ningún autor tocó el archivo de otro (verificado por los verificadores con
`git status --porcelain` y `git diff --name-only`).

| Autor | Corregidos | No corregidos (declarados) | Líneas | Veredicto del verificador | Defectos nuevos |
|---|---|---|---|---|---|
| A1 | 20 | 1 | 463 → 495 | introdujo defecto | 3 |
| A2 | 27 | 0 | 479 → 611 | quedan abiertas | 5 |
| A3 | 14 | 1 | 848 → 1 035 | introdujo defecto | 7 |
| A4 | 18 | 1 | 496 → 542 | introdujo defecto | 9 |
| A5 | 12 | 0 | 699 → 731 | introdujo defecto | 5 |

**Segunda pasada de AUD (acotada a bloqueantes y mayores, como manda el encargo).** De los
7 graves: **4 cerrados** (`CTRL-AUD-02`, `AUT-A-01`, `CON-A4-04`, `CIF-A5-01`) y **3
cerrados con reserva** (`CTRL-AUD-01`, `CTRL-AUD-03`, `PRO-A1-01`). Ninguno abierto en su
sustancia. Las cuatro cifras que la síntesis tenía prohibido tomar sin corregir quedaron
corregidas y re-derivadas por AUD. La pasada dejó **15 puntos abiertos**, entre reservas,
defectos nuevos y tres decisiones que ningún autor puede tomar solo.

**Ronda 2, de cierre.** Los 29 defectos nuevos y los 15 puntos abiertos se enrutaron de
vuelta a su autor con una regla explícita: **reparación quirúrgica**, sin reescribir ni
mejorar nada que el defecto no nombre, porque la ronda 1 demostró que corregir de más es
lo que introduce defectos. Con verificación independiente por documento y tercera pasada
de AUD. Su resultado y el estado final de cada hallazgo están en las secciones 14 y 15 del
documento de auditoría.


**Resultado de la ronda 2 y tercera pasada de AUD.** Los defectos nuevos cayeron de 29 a
9, y AUD volvió a re-verificar con comando propio, sin apoyarse en ningún reporte.

| Autor | Reparados | No reparados | Líneas | Veredicto del verificador | Defectos nuevos |
|---|---|---|---|---|---|
| A1 | 5 | 2 | 495 → 496 | convergió | 0 |
| A2 | 3 | 4 | 611 → 615 | convergió | 4 (dos del reporte, no del documento) |
| A3 | 6 | 2 | 1 035 → 1 078 | introdujo defecto | 2 (menores) |
| A4 | 9 | 2 | 647 → 670 | introdujo defecto | 3 (menores) |
| A5 | 8 | 2 | 731 → 772 | introdujo defecto | 2 (menores) |

**Veredicto de la tercera pasada:** los cinco documentos **convergieron**. Los 7
bloqueantes y mayores quedan **cerrados sin reserva** (las tres reservas de la segunda
pasada se levantaron por hecho verificado). De los 29 defectos nuevos de la ronda 1: 23
cerrados, 3 cerrados con reserva y 3 que no correspondían al archivo (suma verificada
programáticamente: 29 = 23 + 3 + 3). AUD anexó la sección 15 a su documento y actualizó
21 celdas de estado de su tabla maestra.

**Por qué la corrección se detiene aquí y no en una tercera ronda.** Los residuos que
quedan son de una especie particular: **cuentas que el propio documento altera al
mencionarse**. Un ejemplo medido por AUD: la fila de trazabilidad de A4 publica
`grep -c 'UNI-A4-02'` → 2, y hoy son 3 porque la fila se cuenta a sí misma. Otro: un
artefacto de A3 guarda 750 como número de línea y hoy es 751 porque el documento se editó
después. Corregirlos vuelve a moverlos. El encargo prevé exactamente este caso ("si un
hallazgo sigue abierto después de la corrección, se declara abierto en la síntesis; no se
cierra por cansancio") y esa es la vía tomada: los siete residuos y las cinco decisiones
de paquete se declaran en la fase 4, y la síntesis recibe la instrucción de citar por
sección y nunca por número de línea, que es lo que los volvería a romper.

**Lo que la fase 3 mandó a la síntesis y no a un autor.** Tres decisiones cruzan documentos
y por eso no se corrigen: (a) si el texto OCR sin revisar entra o no al contexto del
modelo, que toca a A2, A3 y al filtro del Worker de A4 a la vez; (b) una sola fórmula y una
sola unidad para el peso del índice, hoy publicado con tres cifras porque hay dos fórmulas
(con y sin metadatos) y tres universos (682 artículos, 722 unidades firmadas, 1 160
fragmentos firmados); (c) un solo nombre para las 806 unidades con ancla, que hoy se llaman
"artículo" en el JSON y significan otra cosa en cinco documentos.

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

| # | Hash | Mensaje | Estado |
|---|---|---|---|
| 1 | `e71f1e0` | `docs(andamios): encargo v9, fase 1 del alcance del motor de busqueda (A1 a A5)` | pusheado dentro del rango del commit 2 |
| 2 | `80d291e` | `docs(andamios): fase 2 del encargo v9, auditoria independiente y contraste adversarial` | pusheado 2026-09-06 13:35 |

El commit 1 se enmendó dos veces **en local** antes de pushear (para sacar el laboratorio
del índice por la regla R1 del hook y para enmascarar una línea del log por la R3), y su
mensaje conserva una afirmación falsa que ya no es corregible (`AUT-A-05`, ver §11.3).

```
$ git push origin main
   a07dd1a..80d291e  main -> main
$ git rev-parse HEAD origin/main
80d291e93ad3b80f20ca616839c8ee69717ceecc
80d291e93ad3b80f20ca616839c8ee69717ceecc
```

**Guarda de estacionamiento aplicada (`AUT-A-04`).** En los dos commits se estacionó por
ruta explícita, nunca con `git add -A` ni `git add .`, y antes de cada uno se verificó
que `git diff --cached --name-only` no trajera nada fuera de `50_documentacion/andamios/`
ni ningún archivo con extensión vetada por R1 (0 en ambos casos). El laboratorio queda
**sin trackear pero no ignorado**: 87 archivos en disco, 33 con extensión vetada, y
`.gitignore` sin regla que lo cubra (`git check-ignore` → no). Cualquier `git add -A`
futuro lo volvería a meter y el push volvería a ser rechazado.

**CI del último push, verificado por `head_sha`:**

```
$ gh run view 34045955413 --json headSha,conclusion,status,displayTitle
{"conclusion":"success","displayTitle":"docs(andamios): fase 2 del encargo v9…",
 "headSha":"80d291e93ad3b80f20ca616839c8ee69717ceecc","status":"completed"}
```

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
- **2026-09-05 20:26 → 20:30. Quinto corte, esta vez por agotamiento de la cuota del
  modelo** (`HTTP 429: "You've reached your Fable limit. Run /usage-credits to continue
  or switch models"`), sobre A3 (a mitad de la corrección G-1) y A5 (al iniciar el
  contraste). Estado medido a las 20:30: A3 alcanzó a dejar su documento en 0 cadenas
  con forma de RUT (`grep -cE` del patrón, control positivo 1 sobre cadena construida) y
  a corregir `a3_arnes_citas.R` y `a3_casos_adversariales.yml` (0 cada uno, mtime
  20:27), pero **no regeneró `a3_arnes_citas_salida.txt`** (mtime 08:21, 2 líneas con el
  literal viejo): el documento quedó citando una salida que todavía no se producía, que
  es la regla 3 del estándar al revés. A5 no escribió nada de fase 2 (su documento sigue
  en 316 líneas, sin sección de contraste). Ambos roles se reasignan por D8.
- **2026-09-05 20:35 → 2026-09-06 13:33. Tres cortes más y un desbordamiento, todos
  absorbidos por la reanudación desde caché.** El workflow de la fase 2 corrió en tres
  invocaciones: la primera completó 9 de 19 agentes (corte a las 02:20), la segunda 22 de
  30 (corte a las 08:00), y las dos últimas cerraron la fusión y la escritura. La
  reanudación desde caché replica los agentes ya completados y solo reejecuta los que
  fallaron. **Efecto no buscado y valioso:** como la reanudación rehace todo lo que sigue
  al primer fallo, siete de las doce dimensiones se re-derivaron **dos veces por agentes
  distintos**, lo que convirtió la interrupción en una segunda pasada independiente. Dos
  pasadas que encuentran el mismo defecto son evidencia más fuerte, y las discrepancias
  entre pasadas tienen su propia sección (§11) en el documento de auditoría. El
  desbordamiento de salida de la fusión está en D10.
- **O-5 (orquestador, 20:30, misma regla que O-4).** Al redactar O-4 escribí dos veces
  el literal con forma de RUT que estaba describiendo, y el recuento posterior a la
  enmienda dio 2 en vez de 0. Corregido con `perl -pi` (dígito verificador entre
  corchetes) y recontado: 0 en el log, 1 en la cadena de control construida con
  `echo`. Regla operativa desde ahora: todo texto que cite ese ejemplo lo escribe
  enmascarado, incluida la descripción del error.
- **2026-09-06 14:00 → 18:04. Sexto y séptimo corte, y un desbordamiento de salida.** La
  fase 3 corrió entera en la ventana de la tarde; la ronda de cierre cayó completa al
  lanzarse (los seis agentes con `HTTP 429: "You've hit your session limit · resets 6pm"`,
  sin escribir nada, verificado por `git status --porcelain`, que solo mostraba las
  ediciones de la ronda 1) y se relanzó a las 18:04. Antes, el intento de fusionar los 125
  hallazgos en una sola lista había muerto por el tope de 64 000 tokens de salida (D10).
  **Ninguna de las tres interrupciones costó trabajo**: la reanudación desde caché replica
  lo completado, y lo que se pierde es tiempo de reloj, no evidencia. El costo real de los
  siete cortes de esta sesión fue de unas veinte horas de reloj repartidas en dos días.

- **O-6 (orquestador, 2026-09-06 13:35, regla 7 de la sesión 2).** Pusheé la fase 2 sin
  leer antes los hallazgos que la auditoría dirigía al orquestador, y uno de ellos
  (`AUT-A-05`) exigía enmendar el mensaje del commit de la fase 1 **antes** de que fuera
  inmutable. Al pushear cerré esa ventana. Consecuencia registrada en §11.3: el hallazgo
  queda abierto, con su afirmación falsa fija en el historial y esta constancia como
  única reparación. La regla que violé es la que la sesión 2 ya había aprendido en otra
  forma: leer lo que el instrumento devuelve antes de ejecutar la acción irreversible que
  ese instrumento evalúa. El resto del push era correcto y necesario (`AUT-A-01` pedía
  justamente commitear encima), así que el error es de orden, no de acción.
- **O-7 (orquestador, fase 3, prohibición literal del encargo §3).** Tres subagentes de
  la fase 3 ejecutaron `python3 --version 2>/dev/null` como sondeo, encadenado delante de
  un comando real. Lo detectó el verificador independiente de A3 y lo confirmé contra las
  transcripciones: `grep -o '"command":"python3 --version[^"]*"'` sobre los once
  transcritos de la fase 3 devuelve 3 ocurrencias, en los agentes que trabajaron sobre los
  documentos de A2, A3 y A4 (control positivo del instrumento: el mismo grep de
  `"command":"` sobre los mismos archivos devuelve 702). **Ningún análisis se hizo en
  Python, ningún archivo `.py` se creó ni se ejecutó, y ninguna cifra del paquete depende
  de Python**: los tres comandos son sondeos de versión cuya salida se descartó a
  `/dev/null`. Aun así es una violación literal de la prohibición, que el encargo manda
  reproducir en el prompt de cada subagente y que sí estaba reproducida, palabra por
  palabra, en los once prompts. La responsabilidad es mía por omisión de un detalle: el
  texto prohíbe usar Python como herramienta y los agentes lo respetaron en eso, pero no
  prohibía explícitamente el sondeo de disponibilidad. **Corrección aplicada a la ronda de
  cierre:** el prompt agrega "ni siquiera `python3 --version` ni ningún sondeo de
  disponibilidad, encadenado o no", y la regla queda en §12 como M-8 para el kit.
## 11. Correcciones del orquestador (fase 3)

La auditoría dirigió **once hallazgos al orquestador** (2 bloqueantes, 2 mayores, 4
menores, 3 mejorables). El orquestador corrige su propio archivo, que es este log, con
la misma regla que los demás autores. Los dos bloqueantes y dos de los mayores
(`CTRL-AUD-01` a `CTRL-AUD-04`) no piden cambiar contenido sino **fijar reglas de
método**, y están en §12.

| Hallazgo | Qué exigía | Qué se hizo |
|---|---|---|
| `AUT-A-01` (mayor) | Commitear encima el arreglo de A3 en vez de enmendar, correr el contador de R3 hasta 0 y corregir D7, O-4 y el Anexo A, que daban por cerrada una incidencia que seguía viva | Hecho y verificado abajo. D7, O-4 y el Anexo A quedan corregidos con la nota de que el cero se había medido sobre el árbol y no sobre el commit |
| `AUT-A-03` (menor) | Anotar quién escribió el encargo a las 02:37:47 del 2026-09-05 y si los agentes relanzados leyeron el texto anterior o el posterior | Hecho abajo, con lo verificable y con lo que no es recuperable dicho como tal |
| `AUT-A-04` (menor) | Dejar constancia de que el laboratorio queda sin trackear pero **no ignorado**, con el riesgo medido y la guarda de procedimiento | Hecho: anotado en D7 y aplicado en los dos commits siguientes |
| `AUT-A-05` (menor) | Enmendar el mensaje de `e71f1e0`, que afirma traer el laboratorio cuando no trae ningún archivo suyo | **No corregible: la ventana se cerró.** Ver el error O-6 |
| `AUT-A-06` (mejorable) | Declarar cuál es el artefacto canónico de la fase 2 y anotar que G-1 corrió en su ventana | Hecho abajo |
| `CTRL-AUD-05` (mejorable) | Acotar los enunciados universales de las tareas 1 y 2 de la auditoría | Hecho en §12, regla M-5 |
| `CTRL-AUD-06` (mejorable) | Exigir caso plantado por dimensión; la dimensión de contradicciones quedó sin él | Hecho en §12, regla M-6, con el residuo declarado |

### 11.1 `AUT-A-01`, con su verificación

El arreglo de A3 se commiteó **encima**, no por enmienda, en el commit de la fase 2.
Salida literal de este turno:

```
$ git log --oneline -3
80d291e docs(andamios): fase 2 del encargo v9, auditoria independiente y contraste adversarial
e71f1e0 docs(andamios): encargo v9, fase 1 del alcance del motor de busqueda (A1 a A5)
a07dd1a chore(estado): abrir sesion 3

$ git diff -U0 a07dd1a HEAD | grep -E '^\+' | grep -v '^+++' | grep -cE '<patron R3>'
0
$ printf '%s-%s\n' "$(printf '11.111.%s' '111')" '1' | grep -cE '<patron R3>'   # CONTROL POSITIVO
1
$ git push origin main
   a07dd1a..80d291e  main -> main
$ git rev-parse HEAD origin/main
80d291e93ad3b80f20ca616839c8ee69717ceecc
80d291e93ad3b80f20ca616839c8ee69717ceecc
```

El push pasó el hook, que es la prueba real: el escéptico que confirmó `AUT-A-01` lo
había ejecutado a mano contra el rango anterior y obtenía rechazo. **Corrección
explícita de D7, O-4 y el Anexo A:** donde esos bloques dicen que la incidencia del
push quedó corregida, hay que leer que el árbol de trabajo quedó limpio (medición
correcta) pero el **commit** `e71f1e0` seguía trayendo dos líneas con forma de RUT, de
modo que la incidencia siguió viva hasta este commit. La medición de 0 fue sobre el
árbol, no sobre el commit, y la diferencia importaba.

### 11.2 `AUT-A-03`, el encargo cambió de inodo a mitad de ejecución

Medido en este turno: `stat` sobre el encargo devuelve `mtime = 2026-09-05 02:37:47` y
`birth = 2026-09-05 02:37:47` iguales, es decir, **el archivo que hoy está en disco se
creó a las 02:37:47**, seis minutos después del relanzamiento de los cinco agentes
(02:31) y cinco horas después de que el orquestador leyera el encargo en la FASE 0
(2026-09-04 21:16). Lo verificable: el orquestador no lo escribió (no tiene
autorización sobre ese archivo y no hay ninguna escritura suya registrada); su primera
versión **no es recuperable**, porque el archivo no estaba versionado hasta el commit
`e71f1e0` de la fase 1; y los cinco agentes relanzados leyeron el archivo en su primer
turno, todos después de las 02:38, así que trabajaron sobre el texto actual. Lo que no
se puede afirmar: qué decía la versión anterior ni quién la reemplazó. Contra la duda
de si lo ejecutado sigue estando en el encargo, se verificó en este turno que el texto
en disco sostiene lo que se ejecutó (341 líneas; la tabla de §2 nombra los diez
archivos autorizados; "hasta cinco commits" aparece una vez; la prohibición de Python
aparece una vez; las 84 páginas OCR, dos).

### 11.3 `AUT-A-05`, la ventana que se cerró

El mensaje de `e71f1e0` dice que el commit trae "la carpeta desechable `lab_motor_v9`
con los artefactos medidos", y no trae ningún archivo suyo (`git diff --name-only
a07dd1a e71f1e0 | grep -c lab_motor_v9` → 0). La corrección exigida era enmendar el
mensaje **antes de pushear**. No se hizo, porque el orquestador pusheó antes de leer los
hallazgos dirigidos a sí mismo (error O-6). Enmendar ahora exigiría reescribir historia
ya publicada, que este encargo no autoriza y que la política del proyecto trata como
acción destructiva. **El hallazgo queda abierto y su afirmación falsa queda inmutable en
el historial**, con esta constancia al lado como única reparación disponible. La
síntesis lo declara como hallazgo abierto.

### 11.4 `AUT-A-06`, artefacto canónico y ventana de G-1

Se declara: **el artefacto canónico de la fase 2 es el árbol de trabajo**, que es lo que
los autores editan y lo que los verificadores miden; ninguna cifra de auditoría se midió
sobre un commit salvo las de la dimensión de autorizaciones, que por su objeto miden
commits y lo dicen. La corrección G-1 de A3 se ejecutó **dentro de la ventana de la fase
2** y no en la fase 3, porque era un hallazgo de gobernanza (una regla del hook que
bloqueaba el push), no un hallazgo de auditoría; eso significa que el documento de A3 que
la auditoría leyó ya incluía esa corrección, y que las dos pasadas de la dimensión de
cifras de A3 lo leyeron en el mismo estado. Para la segunda pasada, el hash de
referencia queda fijado aquí: `80d291e93ad3b80f20ca616839c8ee69717ceecc`.

## 12. Reglas de método fijadas por la auditoría

Los dos hallazgos bloqueantes del paquete no apuntan a ningún autor: apuntan al
**instrumento de la propia auditoría**, cuya primera versión no detectó tres de los
defectos que ella misma había plantado. El código ya está corregido en
`aud_procedimiento.R` (versión 2, que sí los detecta). Lo que queda es fijar por escrito
lo que esa falla enseñó, que es exactamente lo que un log de encargo debe dejar para la
sesión siguiente.

- **M-1 (`CTRL-AUD-01`).** `lab_motor_v9/aud_procedimiento_salida_v1.txt` queda
  **invalidado como evidencia** y no se cita en ningún documento del paquete. Ningún
  chequeo puede aceptar como prueba de control un token presente en el texto auditado sin
  discriminar su rol: "control" escrito por el autor no es un control.
- **M-2 (`CTRL-AUD-02`).** Toda ancla que no resuelve se reporta como hallazgo aunque el
  autor la declare caso de control; la autodeclaración viaja como nota, nunca degrada el
  estado. Ninguna exclusión automática puede depender de palabras presentes en el texto
  auditado.
- **M-3 (`CTRL-AUD-03`).** Todo hallazgo de cifra cita la línea completa del autor y
  nombra la magnitud exacta re-derivada con su comando, para que se vea de inmediato si el
  auditor confundió dos magnitudes de nombre parecido (la v1 refutó una afirmación
  verdadera sobre 17 páginas temáticas re-derivando 47, que son las páginas totales).
- **M-4 (`CTRL-AUD-04`).** Todo instrumento de auditoría se prueba con **control negativo
  sobre texto real y correcto**, no solo con control positivo sobre texto plantado: la v1
  marcaba dos falsos defectos sobre un fragmento real de A2.
- **M-5 (`CTRL-AUD-05`).** Los enunciados universales de la propia auditoría se acotan:
  no se escribe "toda cifra fue re-derivada", sino cuántas se re-derivaron
  programáticamente y cuántas a mano, con el alcance del cedazo declarado.
- **M-6 (`CTRL-AUD-06`).** Cada dimensión exhibe su propio caso plantado antes de aceptar
  un cero suyo. **Residuo declarado:** en esta pasada la dimensión de contradicciones
  quedó sin caso plantado, y ninguna dimensión reportó cero hallazgos, de modo que el
  riesgo no se materializó; queda como deuda de método para la sesión siguiente.
- **M-7 (de C7, no de un hallazgo).** Todo comando con `\b` se ejecuta desde archivo
  (`Rscript archivo.R`), nunca con `-e`, y lleva su prueba de instrumento al lado.
- **M-8 (de O-7).** La prohibicion de Python del kit se lee literal y sin borde: no se
  ejecuta `python`, `python3`, `pip`, un archivo `.py` **ni un sondeo de disponibilidad**
  del tipo `python3 --version`, encadenado o no, con salida descartada o no. Tres
  subagentes de la fase 3 lo hicieron sin usar Python para nada, lo que muestra que la
  prohibicion tal como estaba escrita dejaba ese borde abierto.
- **M-9 (de CTRL-AUD-01, tercio (c), que la segunda pasada declaro abierto).** Todo caso
  plantado en un control es **adversarial contra el instrumento**, nunca benevolo: se
  planta el caso que el instrumento tenderia a dejar pasar, no el que obviamente detecta.
  Un control positivo que el instrumento aprueba por la razon equivocada (por un token
  presente en el texto, por una coincidencia parcial, por un archivo distinto del que se
  cree) es indistinguible de un instrumento roto, y esa es exactamente la falla que la
  version 1 del procedimiento de auditoria exhibio en tres de sus cuatro chequeos.

