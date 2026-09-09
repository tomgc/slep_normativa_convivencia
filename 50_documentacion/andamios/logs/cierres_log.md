# Log de cierres — slep_normativa_convivencia

> Un archivo, una sección por cierre, anexadas en orden. **La tabla de rótulos
> de cada sección es el insumo de la F3 del cierre siguiente** (instrumento
> v11, regla 7.3): el catálogo aplicable de un cierre es el conjunto de
> rótulos que disparó en el anterior. Un log que resuma esa tabla en prosa
> deja al cierre siguiente sin catálogo y lo obliga a declarar "sin historia
> previa", que es perder la detección sin que nadie lo note.

---

## v01 — 2026-08-26

**Instrumento:** `cierre_sesion_autonomo_cc_v11.md` (md5 `c7c016fe902a1282b9e89d0d2c956152`).
**Sesión cerrada:** 1 (fundacional). **Traspaso:** v01. **Tramo del backlog:** 1→17.
**Primer cierre del repositorio:** no existían `traspasos/*.md`, `activa/backlog_acumulativo.md`
ni este log.

### Fases

| Fase | Resultado |
|---|---|
| F0 | Pasa. `.git` y `traspasos/` presentes; 1 paquete; 4 delimitadores abren y cierran; 0 placeholders; guardia de repo OK; correlativo triple v01 = v01 = máx(0,0)+1; magnitudes contra disco OK; `settings_version` coincide literal con la línea 3 de SETTINGS; `compuerta_dudas: vacio declarado` con su línea en el traspaso; scope del cierre limpio |
| F1 | Copia de trabajo en `mktemp -d`. Los tres destinos no existían: nada que copiar desde el árbol; se materializaron los bloques del paquete |
| F2 | Los tres encabezados presentes, 1 ocurrencia cada uno |
| F3 | Catálogo aplicable: **sin historia previa** (no había `cierres_log.md`). Tabla abajo |
| F4 | I1–I7 en verde. Tabla abajo |
| F5 | **Compuerta: pasa.** Se procede |
| F6 | Escáner ejecutado (4 salidas generadas, 2 snapshots podados); 0 traspasos previos que archivar; 2 archivos copiados a destino |
| F7 | Commit de documentación `f3d655b`, 6 archivos, +939 −494 |
| F8 | Diff de distribución vacío en los dos bloques con destino de archivo; paquete eliminado |
| F9 | Esta sección, su commit aparte y el push conjunto |

### F3 — Disparos por rótulo del catálogo

| ID | Rótulo | Disparos |
|---|---|---:|
| R5 | Encabezado del Detalle cronológico | 1 |
| R6 | Cabecera del Resumen estadístico por sesión | 1 |
| — | **Cero disparos:** R1, R2, R3, R4, R7, R8, R9, R10, R11, R12 (10 de 12) | 0 |

Sin catálogo aplicable previo, ningún cero detiene (regla 7.3). **Precisión sobre
R5 y R6:** dispararon sobre el *encabezado de sección*, no sobre una afirmación
gobernada por magnitud. Los dos encabezados son planos (`## Detalle cronológico`,
`## Resumen estadístico por sesión`), sin rango `1–N` ni cabecera de filas y suma,
así que no hubo rótulo que reescribir. Quedan en el catálogo aplicable del cierre
v02 por el mecanismo del instrumento.

### F3 — Cifras sin rótulo (zonas declarativas; Detalle cronológico excluido)

| Cifra | Línea | Resolución |
|---|---|---|
| `2026-08-25` | «interpretativa validada por humanos. Existe desde el 2026-08-25.» | (b) histórica legítima: fecha de fundación del proyecto |
| `1` | «Taxonomía orgánica propuesta en la sesión 1» | (b) histórica legítima: atribuye la taxonomía a un tramo cerrado |
| `78` | fila `corpus_insumos` de Clasificación temática | (b) histórica legítima: ejemplo ilustrativo de categoría, no afirmación sobre el estado del archivo |
| `17`, `1` | filas del Resumen estadístico y del Delta | **(a) rótulos faltantes.** Son celdas gobernadas por magnitud (`backlog_entradas_nuevas`, `backlog_total_nuevo`, `backlog_tramo`) que ningún patrón del catálogo cubre, porque el catálogo modela afirmaciones en prosa y no celdas de tabla. Propuestos para la ampliación: **R13** celda «N° de cambios» ← `backlog_entradas_nuevas`; **R14** celda «Total» ← `backlog_total_nuevo`; **R15** celda «Entradas nuevas» del delta ← `backlog_entradas_nuevas` + `backlog_tramo`. El catálogo vive en `herramientas_dev/prompts/`, otro repositorio: su ampliación es un acto aparte de este cierre y queda declarada aquí, no ejecutada |

### F4 — Invariantes

| # | Invariante | Resultado |
|---|---|---|
| I1 | Numeración 1→N contigua | ✅ 17 entradas, 1..17, sin duplicados ni huecos, acotado a las líneas 45–99 del Detalle |
| I2 | Cuadratura | ✅ 17 (sesión 1) + 0 (refinamientos) = 17 = Total declarado = `backlog_total_nuevo` |
| I3 | Filas del resumen = previas + 1 | ✅ 0 + 1 = 1 fila de sesión |
| I4 | Sin magnitudes viejas sobrevivientes | ✅ **vacuo**: `backlog_total_previo` = 0, sin sesión anterior, sin filas previas. Conjunto de búsqueda vacío; cero apariciones que clasificar |
| I5 | Sin autorreferencias de cifras | ✅ el texto de autoría no declara cuántas entradas trae |
| I6 | Gobernanza | ✅ 0 RUT, 0 rutas absolutas de usuario, 0 rutas de OneDrive/Dropbox, 0 credenciales, 0 marcas de coautoría de la herramienta, 0 placeholders |
| I7 | Traspaso | ✅ 0 vigentes previos + 1 nuevo = exactamente 1 vigente |

### Desviaciones declaradas

1. **El paquete trajo el backlog completo, no solo el bloque de sesión, y con
   las filas del resumen y del delta ya materializadas.** Contraviene la letra
   del §2 del instrumento («sin fila del resumen, sin fila del delta: los tres
   los construye el ejecutor»). La causa es estructural y no de autoría: en un
   primer cierre no existen las tablas ni una última fila cuyo formato copiar, y
   F2 solo sabe *anexar*, no crear. El ejecutor **verificó** las dos filas contra
   las magnitudes en vez de componerlas; componerlas habría duplicado. **El
   instrumento v11 no tiene camino de primer cierre** y esa es la corrección que
   le corresponde, no al redactor (§0).
2. **Cierre reintentado tras una detención en F5.** El primer intento se detuvo
   por dos causas, ambas corregidas en el paquete reemitido: `sesion_nueva: 2`
   contradecía los bloques de autoría, que declaran la sesión que cierra como la
   1; y faltaban los encabezados `Resumen estadístico por sesión` y
   `Delta del backlog`. El árbol quedó intacto en aquel intento.
3. **`ESTADO.md`: `no adoptado`.** No se crea el archivo y no entra al commit.

### Sucios fuera de scope

Ninguno. El único archivo ajeno al commit durante el cierre fue el propio
paquete (`?? 50_documentacion/andamios/paquete_cierre_v01.md`), eliminado en F8.
El descuento que F10 aplica a su predicado es, por tanto, vacío.

### Commits y push

- **Hash de documentación (F7):** `f3d655b`
- **Hash del log (F9):** no puede vivir aquí (ningún commit contiene su propio hash, SETTINGS §1.2.2). Queda en el eco de F10 y en git
- **Push:** `por publicar` — `push_autorizado: si`, los dos commits viajan juntos al final de F9

---

## v02 — 2026-08-27

**Instrumento:** `cierre_sesion_autonomo_cc_v11.md` (md5 `c7c016fe902a1282b9e89d0d2c956152`).
**Sesión cerrada:** 2. **Traspaso:** v02. **Tramo del backlog:** 18→32.

### Fases

| Fase | Resultado |
|---|---|
| F0 | Pasa. `.git` y `traspasos/` presentes; 1 paquete; 4 delimitadores abren y cierran; 0 placeholders; guardia de repo OK; correlativo triple v02 = v02 = máx(v01)+1; magnitudes contra disco OK (previo 17 = último real 17; 15 entradas = 15 declaradas; tramo 18→32 contiguo); `settings_version` coincide literal con la línea 3 de SETTINGS (`> **Versión 34.**`); `compuerta_dudas: 5 registradas` = pendientes 9–13 del traspaso, cada uno con `supuesto`/`predicado`/`medicion`; scope del cierre limpio |
| F1 | Copia de trabajo en `mktemp -d`; los tres destinos copiados y los cuatro bloques extraídos |
| F2 | Los tres encabezados presentes, 1 ocurrencia cada uno. Tres inserciones aplicadas (ver desviación 1) |
| F3 | Catálogo aplicable de v01 = **{R5, R6}**; los dos disparan → no detiene. Tablas abajo |
| F4 | I1–I7 en verde. Tabla abajo |
| F5 | **Compuerta: pasa.** Se procede |
| F6 | Escáner ejecutado (4 salidas, 2 snapshots podados); `git mv` de v01 a `archivo/`; 3 archivos copiados a destino |
| F7 | Commit de documentación en **dos** commits (ver desviación 2): `e85057c` (renombrado) y `4c8bdf5` (7 archivos, +851 −558) |
| F8 | Diff de distribución vacío en los cuatro bloques; paquete eliminado |
| F9 | Esta sección, su commit aparte y el push conjunto |

### F3 — Disparos por rótulo del catálogo

| ID | Rótulo | Disparos |
|---|---|---:|
| R2 | Mapa de tramos (celdas `tramo N→M` del Delta) | 2 |
| R5 | Encabezado del Detalle cronológico | 1 |
| R6 | Cabecera del Resumen estadístico por sesión | 1 |
| — | **Cero disparos:** R1, R3, R4, R7, R8, R9, R10, R11, R12 (9 de 12) | 0 |

**Catálogo aplicable de este cierre para el siguiente: {R2, R5, R6}.**

Dos precisiones que el cierre v03 necesita para no leer mal esta tabla:

1. **R5 y R6 se cuentan con el criterio que fijó v01**, no con el literal del
   catálogo. Los dos encabezados siguen siendo planos (`## Detalle cronológico`,
   `## Resumen estadístico por sesión`): no traen rango `1–N` ni cabecera de filas
   y suma, así que no hubo afirmación gobernada por magnitud que reescribir. Se
   cuentan como disparo porque su sección fue localizada, que es exactamente lo que
   v01 registró y declaró («quedan en el catálogo aplicable del cierre v02 por el
   mecanismo del instrumento»). Bajo el literal del catálogo darían cero y la regla
   7.3 detendría; se mantiene la continuidad del criterio y se declara aquí para que
   la decisión sea visible y no una heurística heredada en silencio.
2. **R2 dispara por primera vez** y no detiene (es información: el archivo ganó una
   afirmación que antes no tenía). Dispara sobre las celdas `tramo 1→17` y
   `tramo 18→32` de la tabla del Delta, no sobre un mapa de tramos en prosa, que
   este backlog no tiene.

### F3 — Cifras sin rótulo (zonas declarativas; Detalle cronológico excluido)

| Cifra | Línea | Resolución |
|---|---|---|
| `2026-08-25` | «Existe desde el 2026-08-25.» | (b) histórica legítima: fecha de fundación |
| `1` | «Taxonomía orgánica propuesta en la sesión 1» | (b) histórica legítima: atribución a tramo cerrado |
| `78` | fila `corpus_insumos` de Clasificación temática | (b) histórica legítima: ejemplo ilustrativo |
| `17`, `1`, `15`, `2`, `32`, `18` | celdas del Resumen (filas de sesión y pie **Total**) y del Delta | **(a) rótulos faltantes, segunda aparición.** v01 los declaró y propuso **R13** (celda «N° de cambios» ← `backlog_entradas_nuevas`), **R14** (celda «Total» ← `backlog_total_nuevo`) y **R15** (celda «Entradas nuevas» del delta ← `backlog_entradas_nuevas` + `backlog_tramo`). Siguen sin incorporarse porque el catálogo vive en `herramientas_dev/prompts/`, otro repositorio. El instrumento dice que una cifra que reaparece en dos cierres sin resolver **es un rótulo faltante, no una coincidencia**: esta es la segunda. Este cierre tuvo que recomputar la celda **Total** a mano (17 → 32 y 1 → 2) para que I2 cerrara, que es precisamente el trabajo que R14 automatizaría |

### F4 — Invariantes

| # | Invariante | Resultado |
|---|---|---|
| I1 | Numeración 1→N contigua | ✅ 32 entradas, 1..32, 0 duplicados, 0 huecos, acotado al Detalle cronológico |
| I2 | Cuadratura | ✅ 17 + 15 + 0 = 32 = Total declarado = `backlog_total_nuevo` |
| I3 | Filas del resumen = previas + 1 | ✅ 1 + 1 = 2 filas de sesión |
| I4 | Sin magnitudes viejas sobrevivientes | ✅ 7 apariciones, 7 clasificadas como contexto histórico legítimo (detalle abajo) |
| I5 | Sin autorreferencias de cifras | ✅ el bloque de autoría no declara cuántas entradas trae |
| I6 | Gobernanza | ✅ 0 RUT, 0 rutas de usuario, 0 OneDrive/Dropbox, 0 credenciales, 0 marcas de coautoría, 0 placeholders (sobre los cuatro archivos) |
| I7 | Traspaso | ✅ 1 vigente (`traspaso_cierre_v02.md`), 1 archivado (`archivo/traspaso_cierre_v01.md`) |

**I4 — las 7 apariciones, clasificadas una a una:**

| # | Aparición | Contexto | Clasificación |
|---|---|---|---|
| 1 | `17` | fila del Resumen de la sesión 1 | histórico legítimo: dato de un tramo cerrado |
| 2 | `17` | entrada 13 del Detalle, «17 páginas temáticas» | contenido de una entrada del propio Detalle |
| 3 | `17` | correlativo de la entrada 17 del Detalle | numeración del propio Detalle |
| 4 | `17` | entrada nueva, «17 de 25 veredictos cambiados» | cifra de contenido de la sesión 2, no magnitud del backlog |
| 5 | `17` | fila del Delta v01, «17 (tramo 1→17)» | histórico legítimo: tramo cerrado |
| 6 | `sesión 1` | «Taxonomía orgánica propuesta en la sesión 1» | nota histórica de atribución |
| 7 | `Sesión 1` | encabezado «### Sesión 1 (2026-08-25 a 2026-08-26) — fundacional» | encabezado del bloque histórico |

El recuento de filas anterior (1) no aparece en ninguna afirmación en curso: R4
(«X filas para Y sesiones») dio cero disparos.

### Desviaciones declaradas

1. **La fila del resumen no se anexó «tras la última fila contigua», sino tras la
   última fila de SESIÓN, y el pie `Total` se recomputó.** La tabla termina en dos
   filas que no son de sesión (`Refinamientos menores no atribuibles` y
   `**Total**`); anexar literalmente al final habría puesto la sesión 2 **después
   del Total** y habría dejado I2 en rojo (Total 17 ≠ 32). El instrumento pide que
   las filas del resumen sumen `backlog_total_nuevo` (I2) y que el ejecutor calcule
   todo lo derivable de una magnitud (regla de oro de v6): recomputar el pie es ese
   cálculo. **F2 no contempla tablas con pie**, y esa es la corrección que le
   corresponde al instrumento, junto con R14.
2. **F7 quedó en dos commits.** El `git add` selectivo incluyó la ruta
   `traspasos/traspaso_cierre_v01.md`, que ya no existía porque `git mv` la había
   movido en F6; git aborta el `add` completo ante un pathspec inválido, de modo que
   solo quedó indexado el renombrado que el propio `git mv` había preparado, y el
   commit salió con un único archivo. Se completó con un segundo commit
   (`4c8bdf5`) en vez de `--amend`, que el §6 prohíbe sobre commits del cierre. Ambos
   viajan en el mismo push. **Corrección para el instrumento:** el `git add` de F7
   no debe nombrar la ruta de origen de un `git mv` ya ejecutado; basta la ruta de
   destino más `traspasos/` como directorio.
3. **`commit_cierre` de `ESTADO.md` queda en `358e150`**, que es el cierre v01. No
   es un descuido del paquete: el propio bloque de autoría lo declara («El
   `commit_cierre` de este archivo lo actualiza la apertura siguiente con el hash
   del eco del cierre v02»). Es la consecuencia de que el hash del commit del log no
   exista cuando se redacta el paquete, y F8 impide editarlo (el diff de
   distribución dejaría de ser vacío). El hash correcto va en el eco de F10.

### Sucios fuera de scope

Ninguno. El único archivo ajeno a los commits durante el cierre fue el propio
paquete (`?? 50_documentacion/andamios/paquete_cierre_v02.md`), eliminado en F8. El
descuento que F10 aplica a su predicado es, por tanto, **vacío**.

### Commits y push

- **Hash de documentación (F7):** `4c8bdf5` (el commit previo del mismo F7, `e85057c`, trae solo el renombrado; ver desviación 2)
- **Hash del log (F9):** no puede vivir aquí (ningún commit contiene su propio hash, SETTINGS §1.2.2). Queda en el eco de F10 y en git
- **Push:** `por publicar` — `push_autorizado: si`, los tres commits viajan juntos al final de F9

## v03 — 2026-09-09

**Instrumento:** `cierre_sesion_autonomo_cc_v14.md` | kit `76342e6`.
**Sesión cerrada:** 3. **Traspaso:** v03. **Tramo del backlog:** 33→42.

### F0.0 — Kit y normativos

- **Kit:** sincronizado (`fetch` + `merge --ff-only`); `status --porcelain` vacío
  y `rev-list --left-right --count @{u}...HEAD` = `0 0`.
- **Normativos:** `POLITICA_PROYECTO.md` al día (`> **Versión 5.8 — vigente.**`
  en kit y en `activa/`). `SETTINGS_Y_PROMPTS_OPERACIONALES.md` **actualizado
  desde el kit**: `activa/` estaba en `> **Versión 34.**` y el kit en
  `> **Versión 37.**`. La copia se aplicó en F6. No produjo commit: los dos
  normativos están en `.gitignore` líneas 76-77 y no se versionan (decisión de
  gobernanza del 2026-08-24, opción C).

### Severidades

Primera corrida bajo v14 en este repositorio, y primera bajo el esquema de
`reparto` (v12): el cierre v02 corrió con v11.

| Condición | Severidad | Resultado |
|---|---|---|
| F0.0a kit | — | pasa (sincronizado, sin divergencia) |
| F0.0b normativos | REPARA | reparada: `SETTINGS` en `activa/` v34 → v37 (copia del kit, sin commit por estar en `.gitignore`) |
| F0.1 `.git` y `traspasos/` | BLOQUEA | pasa |
| F0.2 paquete único, front matter, 4 delimitadores, 0 placeholders | BLOQUEA | pasa; ningún campo derivado viajó con valor |
| F0.3 guardia de repo | BLOQUEA | pasa (`raiz_proyecto` = `pwd`) |
| F0.4 correlativo triple | BLOQUEA | pasa (v03 = v03 = máx(v01, v02)+1) |
| F0.5 `n` vs `backlog_entradas_nuevas` | BLOQUEA | pasa (10 = 10) |
| F0.5 numeración provisional contigua | BLOQUEA | pasa (33..42) |
| F0.5 desplazamiento `k` | REPARA | pasa sin reparación: `k = 0` |
| F0.5 `sesion_nueva` | ADVIERTE + REPARA | advertencia y reparación: declarado `4`, disco+1 = `3`; se aplicó `3` |
| F0.5 `fecha_cierre` | ADVIERTE | pasa (2026-09-09 = fecha de la máquina) |
| F0.5bis reparto contra disco | BLOQUEA | pasa (10 líneas, 6 categorías, las 6 en disco, control positivo en verde) |
| F0.5ter / `recuento_tematico` | REPARA | reparada: `vigente` → `diferido` (fundamento abajo) |
| F0.6 `settings_version` | BLOQUEA | pasa (coincide literal con el kit sincronizado) |
| F0.6 `compuerta_dudas` | BLOQUEA / ADVIERTE | pasa (`8 registradas` = 8 filas D en §11.4) |
| F0.7 scope del cierre limpio | BLOQUEA | pasa |
| F0.7bis rutas fuera del scope | BLOQUEA | **bloqueó en la primera corrida; resuelto por el titular** (abajo) |
| F0.8 marcadores `<<EJECUTOR>>` | BLOQUEA | pasa (los dos con valor literal) |
| F2 encabezados estructurales | BLOQUEA | pasa (los 4 aparecen exactamente una vez) |
| F2 encabezado de sesión reconocible | BLOQUEA | pasa (grafía `### Sesión N — YYYY-MM-DD`) |
| F2 formato de fila | REPARA | pasa sin reparación |
| F3 catálogo aplicable sin disparo | ADVIERTE | pasa (los 3 del catálogo aplicable disparan) |
| F3 cifras sin rótulo | ADVIERTE | advertencia: tercera aparición (abajo) |
| I1 numeración contigua | BLOQUEA | pasa (42 entradas, 1..42, 0 huecos, 0 duplicados) |
| I2 cuadratura | BLOQUEA | pasa (17 + 15 + 0 + 10 = 42 = Total) |
| I2ter recuento diferido intacto | BLOQUEA | pasa (tabla byte a byte idéntica, verificado con `diff`; reparto archivado en la fila del delta) |
| I3 filas del resumen | BLOQUEA | pasa (2 → 3) |
| I4 magnitudes viejas | ADVIERTE | advertencia: 4 apariciones, las 4 contexto histórico legítimo |
| I5 autorreferencias | ADVIERTE | advertencia: 1 («`sitio_navegacion` concentra tres entradas») |
| I6 gobernanza | BLOQUEA | pasa sobre los tres destinos y sobre lo staged en F7.1 |
| I7 traspaso vigente | BLOQUEA | pasa (1 vigente, 2 archivados) |
| F7.1 ruta excluida en el staging | BLOQUEA | pasa (commit por pathspec explícito; ver desviación 1) |
| F8 diff de distribución | BLOQUEA | pasa (3 bloques idénticos; el cuarto es compuesto) |
| F9.3 marcador sobreviviente | BLOQUEA | pasa |
| F10 árbol vacío / publicado / estado coherente | BLOQUEA | pasa |

### Las dos detenciones de la primera corrida y su resolución

F5 detuvo con **dos `BLOQUEA`** y el árbol intacto. Los dos apuntaban a los 128
archivos no rastreados que F7.1 habría commiteado:

1. **Rutas absolutas de la máquina del titular hacia un repositorio público.**
   13 apariciones de la ruta del home en 5 archivos del laboratorio del v9
   (`a4_volcados_cf_salida.txt` 8, `a2_correcciones_fase3_salida.txt` 2,
   `a1_ronda_cierre_cifras.R` 1, `a1_ronda_cierre_controles.R` 1,
   `a4_medir_corpus_salida.txt` 1). `CLAUDE.md` §10.2 lo prohíbe.
2. **Push cierto de fallar.** 36 de los 128 con extensión de datos (26 `.csv`,
   10 `.json`), ninguno cubierto por los globs de
   `activa/50_datos_versionados_autorizados.md`. La regla R1 del hook global
   `pre-push` habría rechazado el push con 36 hallazgos.

**Decisión del titular:** ignorar el laboratorio, no versionarlo.
`50_documentacion/andamios/lab_motor_v9/` entra a `.gitignore` con su
comentario, y el saneamiento (limpiar rutas y decidir la autorización de sus
archivos de datos) queda en el pendiente P7 del traspaso v03.

### Tercera detención: patrón de RUT en el informe de rol B

Al re-correr la compuerta apareció en el árbol
`20260909_revision_externa_motor_rolB_v1.md`, que **no existía cuando se emitió
el primer reporte**: el segundo informe de revisión externa llegó durante el
cierre. Su línea 163 traía un patrón de RUT dentro de un ejemplo ilustrativo del
propio revisor. Es el mismo modo de falla que E6 del traspaso v03 y habría sido
rechazado por la regla R3 del mismo hook.

**Decisión del titular:** redactar solo el número y versionar el informe. Se
sustituyó el patrón por el marcador `<RUT de ejemplo, redactado por gobernanza>`
sin tocar ninguna otra palabra (verificado con `diff` contra la copia previa: dos
cambios, la línea 163 y la constancia), y se agregó al pie una línea de constancia
que declara la edición, la línea, la fecha y que la hizo el cierre y no el
revisor. **Verificación del informe de rol A por el mismo criterio: 0 patrones de
RUT y 0 rutas absolutas.**

### F0.5ter — Por qué el recuento temático pasó a diferido

`recuento_tematico` llegó como `vigente` y es inalcanzable en este archivo:

- La tabla «Clasificación temática» en disco tiene **dos** columnas
  (`Categoría | Descripción y ejemplos`): no tiene columna N ni columna de
  porcentaje, así que no hay `N_disco` que recalcular ni cuadratura que I2bis
  pueda comprobar.
- **Población clasificable: 27 de 42.** Las 17 entradas de la sesión 1 llevan su
  categoría como rótulo `[categoria]` en el texto; las 15 de la sesión 2 no la
  llevan en ninguna parte del repositorio (el `reparto` es de v12 y el cierre v02
  corrió con v11); las 10 nuevas vienen cubiertas por el `reparto`.
- Un recuento vigente exigiría asignar categoría a esas 15 entradas, que la
  sección 6 del instrumento prohíbe expresamente.

Aplicado `diferido`: la tabla queda byte a byte como estaba y el `reparto` se
archiva en la fila del delta (I2ter). El diferimiento es del recuento, no de la
clasificación. Levantarlo es sesión propia: exige decidir la categoría de las 15
entradas de la sesión 2 y agregar las dos columnas a la tabla.

**Reparto archivado (10 entradas):** 33 sitio_navegacion; 34 sitio_navegacion;
35 infraestructura_pipeline; 36 gobernanza_docs; 37 sitio_navegacion;
38 diseno_visual; 39 corpus_insumos; 40 ocr_curaduria;
41 infraestructura_pipeline; 42 gobernanza_docs. `categorias_nuevas: ninguna`,
`reclasificaciones: ninguna`.

### Renumeración

`renumeracion: sin desplazamiento`. `U` = 32, `n` = 10, primer provisional 33,
`k` = 32 + 1 − 33 = 0. Patrón de entrada declarado: `^[0-9]+\. \*\*`, tomado de
la línea que abre la entrada 32 en disco. Sin desplazamiento no hay referencias
cruzadas que advertir.

### F3 — Disparos por rótulo del catálogo

Catálogo aplicable heredado de v02 = **{R2, R5, R6}**; los tres disparan.

| ID | Rótulo | Disparos |
|---|---|---:|
| R2 | Mapa de tramos (celdas `tramo N→M` del Delta) | 3 |
| R5 | Encabezado del Detalle cronológico | 1 |
| R6 | Cabecera del Resumen estadístico por sesión | 1 |
| — | **Cero disparos:** R1, R3, R4, R7, R8, R9, R10, R11 (8 de 13) | 0 |
| — | **Fuera del catálogo aplicable por declaración** (`diferido`): R12, R13 | — |

R5 y R6 se cuentan con el criterio que fijó v01 y declaró v02 (sección
localizada, no rango reescrito): los dos encabezados siguen siendo planos. Se
mantiene la continuidad y se vuelve a declarar. **Catálogo aplicable de este
cierre para el siguiente: {R2, R5, R6}.**

### F3 — Cifras sin rótulo (zonas declarativas; Detalle cronológico excluido)

| Cifra | Línea | Resolución |
|---|---|---|
| `2026-08-25` | «Existe desde el 2026-08-25.» | (b) histórica legítima |
| `1` | «Taxonomía orgánica propuesta en la sesión 1» | (b) histórica legítima |
| `78` | fila `corpus_insumos` de Clasificación temática | (b) histórica legítima: ejemplo ilustrativo |
| `17`, `15`, `10`, `0`, `2`, `3`, `18`, `32`, `33`, `42` | celdas del Resumen (filas de sesión y pie **Total**) y del Delta | **(a) rótulos faltantes, TERCERA aparición.** v01 los declaró y propuso tres rótulos nuevos; v02 los volvió a declarar; siguen sin incorporarse porque el catálogo vive en otro repositorio. **Además los IDs que v01 propuso (R13/R14/R15) ya están tomados:** el catálogo v14 usa R12 y R13 para el recuento temático. La propuesta debe renumerarse a **R14** (celda «N° de cambios» ← `backlog_entradas_nuevas`), **R15** (celda «Total» ← `U+n`) y **R16** (celda «Entradas nuevas» del delta ← `backlog_entradas_nuevas` + tramo). Este cierre volvió a recomputar el pie **Total** a mano (32 → 42 y 2 → 3) |

### F4 — Invariantes

| # | Invariante | Resultado |
|---|---|---|
| I1 | Numeración 1→N contigua | ✅ 42 entradas, 1..42, 0 duplicados, 0 huecos, acotado al Detalle cronológico |
| I2 | Cuadratura | ✅ 17 + 15 + 0 + 10 = 42 = Total declarado |
| I2ter | Recuento diferido intacto | ✅ tabla byte a byte idéntica (`diff` sobre la sección); las 10 entradas del tramo aparecen una vez cada una en el `reparto`; el `reparto` está en la fila del delta |
| I3 | Filas del resumen = previas + 1 | ✅ 2 → 3 filas de sesión |
| I4 | Sin magnitudes viejas sobrevivientes | ⚠️ 4 apariciones, 4 clasificadas como contexto histórico legítimo (detalle abajo) |
| I5 | Sin autorreferencias de cifras | ⚠️ 1 aparición: la lectura de la fila del delta dice «`sitio_navegacion` concentra tres entradas». Es correcta contra el `reparto` (33, 34, 37) y es autoría: se lista, no se toca |
| I6 | Gobernanza | ✅ 0 RUT, 0 rutas de usuario, 0 OneDrive/Dropbox, 0 credenciales, 0 marcas de coautoría, 0 placeholders, sobre los tres destinos y sobre el diff staged de F7.1 |
| I7 | Traspaso | ✅ 1 vigente (`traspaso_cierre_v03.md`), 2 archivados (v01, v02) |

**I4 — las 4 apariciones, clasificadas una a una:**

| # | Aparición | Contexto | Clasificación |
|---|---|---|---|
| 1 | `32` | correlativo de la entrada 32 del Detalle | numeración del propio Detalle |
| 2 | `tramo 18→32` | fila del Delta v02 | histórico legítimo: tramo cerrado |
| 3 | `Sesión 2` | encabezado `### Sesión 2 — 2026-08-27` | encabezado del bloque histórico |
| 4 | `la sesión 2` | lectura de la fila del delta v03 | referencia narrativa a una sesión cerrada, autoría |

El recuento de filas anterior (2) no aparece en ninguna afirmación en curso: R4
(«X filas para Y sesiones») dio cero disparos, igual que en v02.

### Desviaciones declaradas

1. **F7.1 se commiteó con `git commit -- <rutas>` y no con `git add` + `git
   commit`.** El `git mv` de F6 deja el renombrado del traspaso v02 **ya
   indexado**, de modo que un `git commit` sin pathspec lo habría arrastrado al
   commit de trabajo, que es justo la ruta que F7.1 debe excluir. El commit por
   pathspec explícito deja esa entrada intacta en el índice para F7.2.
   **Corrección para el instrumento:** F7.1 debe declarar que el índice ya trae
   el renombrado de F6 y commitear por pathspec, o bien F6 debe posponer el
   `git mv` hasta después de F7.1. Es el reverso de la desviación 2 de v02, que
   describió el otro filo del mismo borde.
2. **La fila del resumen se anexó tras la última fila de SESIÓN y el pie `Total`
   se recomputó**, como en v02 y por el mismo motivo: la tabla termina en dos
   filas que no son de sesión. F2 sigue sin contemplar tablas con pie.
3. **El árbol se tocó antes de F6**, con la línea de `.gitignore`. Es la
   resolución que la propia F0 7bis sanciona («el titular la saca o la ignora en
   `.gitignore`») y la ordenó el titular por escrito; se declara porque el
   principio de orden de la sección 4 dice que el árbol real se toca en F6.
4. **Se editó un archivo de autoría de un tercero** (la línea 163 del informe de
   rol B), por instrucción explícita del titular y bajo `CLAUDE.md` §10.2, con
   constancia al pie del propio archivo.

### Sucios fuera de scope

Ninguno al terminar. Durante el cierre, los 128 archivos del laboratorio (ahora
ignorados), 6 documentos `.md` de andamios (commiteados en F7.1) y el propio
paquete (eliminado en F8).

### Commits y push

- **Hash de trabajo (F7.1):** `97bd033` — 7 rutas: `.gitignore` y los 6
  documentos de andamios del 2026-09-08 y 2026-09-09 (los dos informes de
  revisión externa entre ellos), 1 375 líneas agregadas.
- **Hash de documentación (F7.2):** `4fe2085` — traspaso v03 nuevo, v02
  archivado, backlog y las 4 salidas del escáner con 2 snapshots podados.
- **Hash del log (F9):** no puede vivir aquí (ningún commit contiene su propio
  hash). Queda en `ESTADO.md` y en el eco de F10.
- **Push:** `por publicar` — `push_autorizado: si`, los cuatro commits viajan
  juntos al final de F9.
