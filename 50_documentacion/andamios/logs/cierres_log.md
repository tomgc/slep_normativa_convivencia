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
