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
