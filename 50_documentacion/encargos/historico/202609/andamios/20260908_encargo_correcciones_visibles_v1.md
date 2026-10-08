# Encargo v10 — Correcciones visibles: buscador, legibilidad y limpieza de texto

> **Destino:** `50_documentacion/andamios/20260908_encargo_correcciones_visibles_v1.md`
> **Tipo:** vía B (autónomo, sin firma humana para lo que produce).
> **Naturaleza:** a diferencia del v9, este encargo **sí cambia el producto**. Regenera el sitio y despliega. Cada bloque debe demostrar su efecto contra una medición previa.
> **Emitido:** 2026-09-08, sesión 3.

---

## 0. Por qué existe este encargo

El encargo v9 midió que el buscador actual **devuelve el artículo correcto en 0 de 10 consultas** de un conjunto de evaluación construido para eso. La causa no es el índice, que sí las encuentra: la interfaz muestra a lo más tres sub-resultados por norma y en orden de documento, de modo que el artículo que responde queda tapado por otros del mismo cuerpo legal. Es la mejora de mayor valor por unidad de esfuerzo del proyecto y quedó fuera de las autorizaciones del v9.

Junto con eso, hay dos deudas acumuladas: la hoja de estilos del sitio no tiene una sola regla responsiva, y el texto extraído de 17 a 19 normas arrastra la cabecera del sitio de origen dentro del preámbulo, contaminando cualquier índice que se construya sobre él.

---

## 1. Techo de esfuerzo (leer antes que las tareas)

El v9 costó cuatro jornadas y produjo 91 hallazgos, de los cuales 84 eran menores o mejorables. Esa proporción es el defecto que este encargo corrige de entrada.

- **Máximo dos agentes simultáneos.** Nunca cinco.
- **Commit por bloque terminado**, pusheado antes de empezar el siguiente. Una caída cuesta un bloque, no el encargo.
- **Una sola pasada de auditoría**, limitada a bloqueantes y mayores. Los hallazgos menores se **anotan y no se reparan**.
- **Sin segunda ronda de corrección**, salvo que quede un bloqueante abierto.
- **Regla de reparación quirúrgica desde el primer minuto:** se corrige lo que el hallazgo nombra y nada más. Mejorar de paso es lo que en el v9 introdujo 29 defectos nuevos.
- **Regla de detención por esfuerzo:** si un bloque no converge tras dos intentos, se revierte ese bloque, se declara abierto y se pasa al siguiente. No se insiste.

---

## 2. Precondiciones bloqueantes

| # | Precondición | Comando |
|---|---|---|
| P1 | Árbol limpio y sincronizado | `git fetch --quiet && git status --porcelain && git rev-parse HEAD origin/main` |
| P2 | Sesión abierta por esta máquina | `grep -E '^(sesion_abierta\|maquina):' 50_documentacion/activa/ESTADO.md` |
| P3 | Hooks del repositorio leídos | `git config core.hooksPath` y lectura del hook, **antes** de cualquier commit (lección O-3 del v9) |
| P4 | **El conjunto de evaluación de diez consultas existe** | `ls 50_documentacion/andamios/lab_motor_v9/a2_*` |

**P4 es la crítica.** El laboratorio del v9 quedó sin versionar, así que el conjunto de evaluación puede existir solo en disco local. Si no está, **reconstruirlo** desde la sección correspondiente de `50_documentacion/andamios/20260904_alcance_capa2_semantica_v1.md`, que sí está versionado, y dejar constancia de que se reconstruyó. Sin conjunto de evaluación este encargo no tiene cómo demostrar nada y se detiene.

---

## 3. Autorizaciones (exhaustivas)

**Lectura:** cualquier archivo del repositorio.

**Escritura, solo estos:**

| Ruta | Bloque |
|---|---|
| `30_procesamiento/34_plantillas_sitio/busqueda.html` | B1 |
| `30_procesamiento/34_plantillas_sitio/estilo.css` | B2 |
| `_quarto.yml` | B2 |
| El script de extracción o segmentación que produce el preámbulo, en `30_procesamiento/` | B3 |
| `50_documentacion/andamios/20260908_medicion_correcciones_v1.md` | medición y auditoría |
| `50_documentacion/andamios/20260908_pendientes_firma_humana_v1.md` | B4 |
| `50_documentacion/andamios/logs/20260908_correcciones_visibles_v10_log.md` | log |

**Regeneración del sitio:** autorizada. `40_salidas/` se regenera por pipeline, **nunca a mano**.

**Commits y push:** hasta seis, uno por bloque más el log. Verificación de CI posterior a cada push, autorizada y exigida.

---

## 4. Prohibiciones

- **Escribir en `20_insumos/`.** No hay delegación. Esto incluye el glosario, las piezas en borrador y los metadatos curados, aunque el bloque 4 encuentre defectos en ellos.
- Editar a mano cualquier archivo bajo `40_salidas/`.
- Publicar, validar o tocar el estado de ninguna pieza interpretativa.
- Correr `00_ocr_documentos.R` con cualquier bandera.
- Python: el proyecto es R-only (`CLAUDE.md` §7). La prohibición se lee sin borde y **no se ejecuta ni un sondeo de disponibilidad**. Reproducir literalmente en el prompt de cada subagente.
- Acceso `$` sobre estructuras leídas de disco. `[[ ]]` siempre.
- Reescribir historia publicada.

---

## 5. Medición previa obligatoria (antes de tocar código)

Nada se corrige antes de medirse. Escribir en `20260908_medicion_correcciones_v1.md`:

1. **Línea base del buscador:** correr las diez consultas contra el sitio actual, servido en modo lectura, y reportar en cuántas el ancla correcta aparece entre los resultados visibles. El valor esperado es 0 de 10; **si no da 0, el instrumento o la línea base heredada están mal y hay que decirlo antes de seguir**.
2. **Inventario de anclas:** número de `id` en el HTML publicado y cuántos resuelven. Valores de referencia del v9: 806 segmentos, 887 de 887 destinos verificados. Esta es la prueba de regresión de todo el encargo.
3. **Peso y densidad por página:** bytes y número de encabezados con `id` por archivo, con las diez mayores destacadas.
4. **Largo del índice lateral** en las cinco páginas más pesadas.
5. **Alcance del buscador:** en cuántas páginas aparece el bloque de búsqueda.
6. **Contaminación del preámbulo:** en cuántas normas aparece la cabecera del sitio de origen dentro del texto, con el comando exhaustivo. El v9 reportó "17 a 19": este encargo entrega el número exacto.

**Control positivo obligatorio** de los puntos 1, 2 y 6: plantar un caso que el instrumento deba detectar y mostrar que lo detecta. Un cero sin su control no se reporta.

---

## 6. Bloques de trabajo

### B1 — Sub-resultados del buscador

**Qué:** que el artículo que responde a la consulta sea visible, en vez de quedar tapado por otros del mismo cuerpo legal.

- Ordenar los sub-resultados por relevancia y no por orden de documento.
- Subir el tope de sub-resultados mostrados por norma, con un valor justificado por la medición y no por convención.
- Que cada sub-resultado muestre su identificador de artículo, para que se vea qué se está abriendo.

**Criterio de éxito, medido:** las diez consultas vuelven a correrse contra el sitio reconstruido y el resultado se publica como **N de 10 frente a la línea base de 0 de 10**, consulta por consulta. Una mejora que no se pueda expresar así no se declara.

**Regla de detención:** si el cambio exige tocar algo fuera de `busqueda.html`, se detiene y se reporta en vez de ampliar el alcance.

### B2 — Legibilidad

Seis defectos identificados en la fuente. Se corrigen los que la medición de §5 confirme; los que no se confirmen se declaran y no se tocan.

1. **Cero reglas responsivas** en las 163 líneas de la hoja: el teléfono hereda íntegro el diseño de escritorio.
2. **Enlaces que no parecen enlaces:** títulos de norma en gris y sin subrayado en los listados.
3. **Contraste bajo** en texto pequeño de ficha, procedencia y etiquetas de relación.
4. **Versalitas diminutas** en las insignias, varias por ficha.
5. **Buscador en todas las páginas**, empujando el articulado hacia abajo también donde no corresponde.
6. **Índice lateral desproporcionado** en las normas de cientos de artículos.

**Restricción sobre el bloque de OCR:** el texto reconocido conserva los saltos del reconocedor a propósito, porque lo que se muestra debe ser exactamente lo que el equipo va a corregir. Se puede mejorar su legibilidad en pantalla angosta, **no reflowear el texto**.

**Restricción de identidad:** este bloque corrige legibilidad, no rediseña. No se introducen tipografías nuevas, ni paleta nueva, ni componentes nuevos.

**Criterio de éxito:** antes y después medidos para los puntos 3, 5 y 6, y para los demás la declaración de qué regla se agregó y en qué punto de corte.

### B3 — Limpieza del preámbulo

**Qué:** eliminar la cabecera del sitio de origen del texto del preámbulo, en el punto del pipeline donde se produce.

- La regla de limpieza se **deriva del texto real**, no se escribe de memoria: se localiza el patrón exacto en los archivos y se muestra.
- Se aplica solo al preámbulo, nunca al articulado.

**Prueba de regresión, bloqueante:** tras regenerar, el número de segmentos con ancla debe seguir siendo **806** y los 887 destinos deben seguir resolviendo. Si cambia cualquiera de los dos, **se revierte el bloque completo** y se declara. Una limpieza de texto que altere la segmentación rompe todas las citas publicadas.

**Criterio de éxito:** contaminación de N normas a 0, con el mismo comando exhaustivo de §5.6 antes y después, y la prueba de regresión en verde.

### B4 — Diagnóstico de lo que solo puede arreglar una persona

**No se corrige nada aquí.** Se produce `20260908_pendientes_firma_humana_v1.md`, una lista accionable para el equipo:

- Los 20 de 39 encabezados de glosario truncados a 60 caracteres con la definición pegada, uno por uno, con su texto actual y el corte propuesto.
- Las dos anclas rotas de las piezas en borrador, con el ancla que apuntan y la que deberían apuntar.
- El campo de aviso de vigencia nulo en las 25 normas: qué lo llena y quién debe hacerlo.
- Los errores de nombre detectados en el corpus, con su corrección propuesta.

Cada punto con: qué está mal, dónde vive el archivo, qué habría que escribir, y por qué la máquina no puede hacerlo.

---

## 7. Auditoría (una sola pasada, acotada)

Un agente que no participó en los bloques verifica, y **no corrige lo que audita**:

1. Que la línea base y el resultado final del buscador se midieron con el mismo instrumento y son comparables.
2. Que la prueba de regresión de anclas se corrió después de cada regeneración, no una sola vez al final.
3. Que ningún archivo fuera de la tabla de §3 fue escrito: `git diff --name-only` contra esa tabla.
4. Que `20_insumos/` no tiene un solo cambio, con control positivo del mismo comando sobre otra ruta.
5. Que cada cifra publicada tiene su comando del mismo turno.
6. Que ningún cero se reportó sin control positivo.

Los hallazgos bloqueantes y mayores se corrigen. Los menores **se anotan y se dejan**.

---

## 8. Reglas de detención

Detenerse y reportar si: falla una precondición; un cambio exige escribir fuera de la tabla de §3; la prueba de regresión de anclas falla y la reversión no restaura el estado; el despliegue queda en rojo; o un bloque no converge tras dos intentos.

**Un aborto es información, no fracaso.** El v9 congeló una tarea por contradicción interna y esa fue la decisión correcta.

---

## 9. Log

`50_documentacion/andamios/logs/20260908_correcciones_visibles_v10_log.md`, escrito durante la ejecución:

1. Precondiciones, salida literal.
2. Mediciones previas, con sus controles positivos.
3. Por bloque: qué se cambió, con qué evidencia antes y después, y el hash de su commit.
4. Prueba de regresión de anclas tras cada regeneración.
5. Hallazgos de auditoría, con los menores anotados y marcados como no reparados.
6. Invariantes al cierre: `20_insumos/` sin cambios, ningún archivo fuera de la tabla, ninguna pieza publicada.
7. Errores del propio ejecutor.
8. Residuos declarados.
9. Commits y estado de CI verificado por `head_sha`.

---

## 10. Reporte final

1. **N de 10 frente a 0 de 10**, consulta por consulta. Es la cifra que justifica el encargo.
2. Una línea por defecto de legibilidad corregido, con su antes y después.
3. Contaminación del preámbulo, antes y después, con la prueba de regresión.
4. Cuántos puntos quedaron en la lista de firma humana.
5. Hashes y estado de CI.
6. Lo que se decidió no hacer y por qué.

Nada más. El detalle vive en el log.
