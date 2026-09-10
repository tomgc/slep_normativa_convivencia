# Integración de las revisiones externas del motor de búsqueda (rol A y rol B)

> **Destino:** `50_documentacion/andamios/20260909_integracion_revision_externa_v1.md`
> **Insumos:** `20260909_revision_externa_motor_rolA_v1.md` (20 hallazgos), `20260909_revision_externa_motor_rolB_v1.md` (20 hallazgos), `20260908_especificacion_motor_busqueda_v1.md` (§ citadas), `traspaso_cierre_v03.md`, `CLAUDE.md`.
> **Fecha:** 2026-09-09, sesión 4. **Autor:** Área de Monitoreo, con asistencia del asistente de chat.
> **Qué es:** el veredicto del proyecto sobre cada hallazgo, con su destino. Es el equivalente de la sección de adopciones y rechazos que el encargo v9 aplicó al diseño externo del titular. Ningún hallazgo queda sin fila.

---

## 0. Cómo leer los veredictos

Cuatro veredictos, sin quinto:

| Veredicto | Significa |
|---|---|
| **adoptar** | El hallazgo es correcto y el cambio propuesto entra tal cual. |
| **adoptar con ajuste** | El hallazgo es correcto; el cambio propuesto se modifica por un invariante del proyecto, por su costo o porque una parte exige escritura humana. Se dice qué parte cambia. |
| **diferir con umbral** | El hallazgo es correcto pero recae sobre un componente que el proyecto no construye ahora (vía semántica, capa 3 en vivo, capa 1). Entra a la especificación v2 como precondición, con la condición que lo reactiva. |
| **rechazar** | El hallazgo o su cambio contradice un invariante, un dato del proyecto o el estado real. Se dice cuál. |

Siete destinos: **v11** (encargo de esta sesión: índice lateral, expansión de consulta, P7, instrumento versionado); **v12** (encargo siguiente: salidas estáticas visibles); **decisión** (del titular, formulada en §4); **vía A** (contenido de escritura humana, entra a la pauta de validación o a una delegación registrada); **esp. v2** (la especificación técnica se corrige en su versión 2, sin construir nada); **P8** (pendiente ya inventariado); **ninguno**.

Las cifras que este documento toma de los informes llevan su ID; las que recalcula, su comando. Las magnitudes del proyecto (806, 682, 25, 3 de 10) vienen del traspaso v03 y se recuentan en el encargo que las use, no aquí.

---

## 1. Convergencias entre roles

Cuando los dos revisores, con mandatos distintos y sin acceso mutuo, llegan al mismo punto, el hallazgo pesa más que cualquiera de sus dos formulaciones. Siete convergencias:

| # | Rol A | Rol B | Punto común | Peso |
|---|---|---|---|---|
| C1 | A-16 (bloqueante) | B-01 (bloqueante), B-11 | Ancla estable no implica texto estable ni vigente; la LGE a 2010 y toda pieza firmada que la cite lo muestran. | Máximo: único punto bloqueante en ambos roles. Va a decisión (§4, D-A). |
| C2 | A-15 | B-03, B-04 | El motor no sabe decir «no está en el corpus», y el conjunto de evaluación no tiene consultas cuya respuesta sea esa. | Alto. Estado vacío (v12) y clase «sin respuesta» en el instrumento (v11). |
| C3 | A-20 | B-09, B-08 | Los niveles 1 y 2 se derivan del campo `tipo`; el rótulo debe decir el tipo y el estado, no un número. | Alto. v12. |
| C4 | A-09, A-10 | B-17, B-16 | Reordenamiento en niveles 2 y 3, int8, descomposición de preguntas y los 806 encabezados en la capa 1 son sobreingeniería sin ganancia medida. | Alto. Esp. v2: solo el piso R0. |
| C5 | Pregunta 1 | Pregunta 1 | La vía semántica no se justifica ahora; ambos dan un umbral de reapertura medible. | Alto. Decisión D-B. |
| C6 | Pregunta 5 | B-02, B-03, B-15 | Los tres instrumentos que A pide para un equipo no técnico son tres hallazgos de B: registro de consultas, «no está en el corpus», cita copiable. | Alto. v12 y decisión D-C. |
| C7 | A-17 | B-19, D3 de la compuerta | La latencia y la legibilidad no están medidas en un navegador ni en un teléfono. | Medio. Criterios de aceptación de v12. |

Dos convergencias con hallazgos propios del proyecto, que refuerzan reglas ya aprendidas: A-11 (clave de caché que no incluye parámetros ni versión del modelo) es el mismo defecto que el bug de la sesión 3 (huella del paso 30 sin versión del código, P8); A-03 y A-04 (cifras por convención presentadas como conteo) son el mismo patrón que la regla aprendida 1 del traspaso (una premisa heredada es una hipótesis).

---

## 2. Veredictos, rol A

| ID | Sev. | Veredicto | Destino | Razón |
|---|---|---|---|---|
| A-01 | bloq. | adoptar | esp. v2 | Cierto y no discutible: sin modelo nombrado no hay dimensión, y sin dimensión todo §5.2 y §7 es aritmética sobre un supuesto. Entra como primera precondición de la vía semántica: nombre, versión, dimensión, largo máximo y licencia, con la prueba de 10 fragmentos recuperados por su propia consulta literal. Mientras la vía esté diferida (D-B), la especificación v2 rotula esas cifras como «calculadas sobre un modelo no elegido». |
| A-02 | bloq. | adoptar | esp. v2 | Cierto: la afirmación «capa 2 estática» de §3 y §7 solo vale si el visitante descarga el modelo. La especificación v2 lo corrige: la vía semántica no es estática hasta que se mida la carga fría del modelo elegido; si supera el umbral del propio revisor (10 s o 50 MB), la vectorización de la consulta va al Worker y la capa 2 semántica pasa a depender de él. Decisión (a)/(b) diferida con la vía. |
| A-03 | mayor | adoptar | esp. v2 | Cierto: 227 y 1 160 salen de `nchar/4` y así deben rotularse. Recontar con el tokenizador real es trabajo de la vía semántica, no de ahora. La especificación v2 reemplaza «segmentos largos: 227» por «segmentos sobre 2 048 caracteres: 227 (convención 4 c/token; conteo real pendiente del modelo)». |
| A-04 | mayor | adoptar | esp. v2 | Cierto y es un defecto de redacción del diseño: un solo umbral, la ventana. Se corrige en la especificación v2 sin esperar al modelo. |
| A-05 | mayor | adoptar | esp. v2 | Cierto. La fragmentación por párrafo con deslizamiento solo dentro del párrafo que excede la ventana es la regla que entra a la especificación v2, con la prueba del revisor (fragmentos que no terminan en signo de cierre). Los 87 párrafos sobre la ventana no la invalidan: la ventana ciega queda como caso interior, no como regla. |
| A-06 | mayor | adoptar | esp. v2 | Cierto: sin desplazamiento no hay resaltado y sin colapso el artículo largo coloniza la lista. Ambos entran a la especificación v2. El colapso a segmento por máximo antes de la fusión es además lo que preserva la unidad de recuperación (decisión 3 del traspaso). |
| A-07 | mayor | adoptar con ajuste | v11 (medición), esp. v2 | Cierto para la fusión. Ajuste: hoy solo existe la vía léxica y su lista no se recorta en 30, así que el efecto no se manifiesta todavía. Lo que sí entra al v11 es la medición: recall@K de la vía léxica sobre las diez consultas para K en {30, 65, 100}, con el instrumento versionado; el K léxico que se adopte más adelante sale de esa curva, y el semántico se declara aparte. |
| A-08 | mayor | diferir con umbral | esp. v2 | Cierto sobre RRF con k = 60 y listas cortas. No aplica mientras no exista fusión. Entra a la especificación v2 como piso R0 previo a la fusión (coincidencia exacta de número de norma o artículo encabeza) y con la prueba de regresiones de top-1. Umbral: se activa el día que exista una segunda vía. |
| A-09 | mayor | adoptar con ajuste | esp. v2 | Cierto. Ajuste: en vez de definir los niveles 2 y 3, se eliminan del diseño (converge con B-17 y con la pregunta 6 de ambos roles). Queda un solo nivel, R0 determinístico por metadatos, y la tabla de degradación por componente que el revisor pide se escribe igual, porque la exigen la vía léxica y el índice de Pagefind aunque no haya reordenador. |
| A-10 | menor | adoptar | esp. v2 | Cierto: a esta escala el término dominante es el modelo. La especificación v2 fija float32 como primera forma del índice y condiciona int8 a una pérdida de recall@10 menor a 1 punto y a un presupuesto de transferencia que lo exija. |
| A-11 | mayor | adoptar | esp. v2, P8 | Cierto, y es el mismo defecto que el bug de la sesión 3. Se generaliza como regla del proyecto: toda huella de caché incluye la versión del código y los parámetros que afectan la salida; cambiar cualquiera reprocesa el 100 % y correr dos veces sin cambios reprocesa 0. La regla se aplica primero al paso 30 (P8) y hereda al índice vectorial cuando exista. |
| A-12 | mayor | diferir con umbral | esp. v2, decisión D-B | Cierto: ninguna de las tres opciones está elegida. La (b), versionar un blob binario, choca con `50_datos_versionados_autorizados.md`, que autoriza solo `40_salidas/datos/` (traspaso §4.6), y se descarta desde ya. Entre (a) y (c) se decide cuando se reabra la vía semántica, con la prueba del revisor (CI sin secretos: produce el índice o declara que no lo intenta). |
| A-13 | mayor | adoptar con ajuste | esp. v2 | Cierto sobre la evitabilidad del arnés en cliente y sobre la duplicación R/JS. Ajuste: el principio (las anclas válidas son un dato exportado por el pipeline, no lógica reimplementada) se adopta para todo verificador del lado del cliente, incluido el instrumento de las diez consultas. La verificación en el Worker se difiere con la capa 3 en vivo. |
| A-14 | mayor | adoptar | esp. v2 | Cierto: la compuerta de entrada mide procedencia, no suficiencia, y los dos caminos de fuga que la síntesis declaró no están en §9. La capa 3 en vivo queda restringida a salida extractiva hasta que exista un arnés de suficiencia con tasa de retiro 2 de 2 sobre los casos plantados. Converge con lo que B no cambiaría (punto 6). |
| A-15 | mayor | adoptar con ajuste | v11 (instrumento), decisión D-C | Cierto en lo estadístico, verificado en este turno: p = 0,6499 para 3/10 frente a 5/10 (prueba exacta de Fisher, recalculada); 0,3698 para 3/10 frente a 6/10; incluso 15/50 frente a 25/50 da 0,0656. Consecuencia para el v11: «6 de 10» es un umbral de ingeniería, no una prueba de mejora; la medida que sí decide es la pareada (ninguna de las tres consultas resueltas retrocede, y cuáles de las siete se resuelven, una por una). Ajuste al cambio: las 40 consultas adicionales no pueden ser «lenguaje del equipo» si las construye el proyecto; la ampliación a 50 se hace con consultas reales capturadas (D-C). Lo que entra al v11 ahora: las diez actuales versionadas como subconjunto histórico, una clase «sin respuesta» de 3 a 5 consultas construidas para probar el estado vacío, y MRR además del acierto. |
| A-16 | bloq. | adoptar con ajuste | decisión D-A | Cierto y es el hallazgo más importante de ambos informes (C1). Ajuste en dos partes. Se adopta: hash del texto por segmento en el JSON canónico (dato derivado en `40_salidas/`, sin escritura humana) y estado derivado «requiere revalidación» para toda pieza firmada que cite un segmento cuyo hash cambió después de la fecha de firma, con los controles positivo y negativo del revisor. Se rechaza: el sufijo de versión en el ancla pública, porque rompe el invariante 🔒 de anclas estables y toda cita ya copiada fuera del sitio. El texto cambia; el ancla no; lo que viaja con el ancla es la fecha de versión del texto (B-01). |
| A-17 | menor | adoptar | v12 (criterios de aceptación) | Cierto: la latencia útil es un par (fría, caliente) medido en el navegador. Entra como criterio de aceptación del v12 junto con B-19, sobre el equipo de referencia que el titular declare. |
| A-18 | menor | adoptar | v11 | Cierto y barato: normalización NFD sin marcas combinantes y a minúsculas, tanto en la expansión de consulta del v11 como en la capa 1 cuando exista. Prueba del revisor (892 entradas con y sin tildes, conjunto idéntico) reducida en el v11 a las diez consultas más las de la clase «sin respuesta». |
| A-19 | menor | adoptar con ajuste | v11 | Plausible, no medido. Ajuste: primero la prueba (las 25 normas consultadas en las tres formas del número, top-1 por forma), y solo si alguna forma pierde se emite el metadato indexable en las tres formas y se normaliza la consulta. El v11 lleva la prueba como bloque de medición previa, con D7. |
| A-20 | menor | adoptar | v12 | Cierto: seis tipos en el catálogo bastan (C3). Tabla cerrada tipo → nivel en el constructor, error ante tipo no contemplado, y el rótulo imprime el tipo (B-09). |

---

## 3. Veredictos, rol B

| ID | Sev. | Veredicto | Destino | Razón |
|---|---|---|---|---|
| B-01 | bloq. | adoptar con ajuste | decisión D-A, vía A, v12 | Cierto (C1). El campo curado `texto_consolidado_al` (25 valores con fuente) vive en `20_insumos/curaduria/metadatos_curados.json`, que ningún script escribe: es delegación registrada o trabajo del equipo, y entra a la pauta de la vía A junto con `aviso_vigencia` (P5, nulo en las 25). Lo que el v12 sí hace sin escritura humana: imprimir en todo resultado y en la cita copiable «versión del texto: no declarada» mientras el campo sea nulo, y bloquear la palabra «vigente» en cualquier rótulo de norma sin ese campo. La carencia viaja hasta el resultado desde el primer día; el dato llega cuando alguien lo cure. |
| B-02 | mayor | adoptar con ajuste | v12 (enlace), decisión D-C | Cierto: sin consultas reales los alias se curan a ciegas y su utilidad no se puede medir. El enlace «¿No encontraste lo que buscabas?» es estático y va al v12. Ajuste: el destino del enlace (formulario institucional, correo, planilla compartida) y quién lo lee lo decide el titular (D-C), con una condición de gobernanza que el revisor no puso: el canal no captura datos personales ni pide identificar el caso, solo la consulta escrita. La prueba de las cuatro semanas se conserva. |
| B-03 | mayor | adoptar | v12 | Cierto (C2). Estado «sin resultado firme» cuando ningún token de contenido coincide, con mensaje y con la lista de normas que el corpus cita pero no contiene. Esa lista es derivable: el derivador de relaciones ya registra las remisiones descartadas por apuntar fuera del corpus (`CLAUDE.md` §10.6, 2026-08-26), así que no exige curaduría. La prueba del revisor (H-5 y «licencia de conducir») entra al instrumento. |
| B-04 | mayor | adoptar con ajuste | vía A (P4), v12 (parte derivada) | Cierto sobre la falla; la frecuencia no está medida y así se mantiene. Ajuste: la respuesta de raíz es P4, incorporar DFL 2/1998 y Ley 21.128 por el manifiesto de hash con delegación registrada, no una entrada curada que diga dónde está. Mientras P4 no ocurra, la lista derivada de B-03 muestra «DFL 2/1998» y «Ley 21.128» como citadas y no incluidas, antes que cualquier mención, sin escribir una línea a mano. La entrada curada «no está: está en X» queda como pieza de la vía A si P4 se demora. |
| B-05 | mayor | adoptar con ajuste | v12, vía A | Cierto sobre el orden de lectura. Se adopta: la nota «existe un pronunciamiento posterior, aún sin revisar» como encabezado de la lista del tema, derivada de la relación de sustitución ya existente (v12). Se ajusta: «prerrequisito de lanzamiento» no aplica porque el sitio está publicado; lo que sí entra es el criterio de orden de la cola de revisión OCR (páginas ordenadas por cuántas consultas desbloquea cada una), que va a la pauta de la vía A con las 9 páginas del dictamen 078 en primer lugar. |
| B-06 | mayor | adoptar | v11 (expansión), esp. v2 (capa 1) | Cierto. La exclusión de palabras vacías y el AND solo sobre tokens de contenido se aplican desde ya a la expansión de consulta del v11, que es donde hoy el AND de Pagefind mata 3 de 10 consultas (traspaso §7). El estado vacío diseñado va al v12 (B-03) y el contrato de la capa 1 se corrige en la especificación v2. |
| B-07 | mayor | adoptar | vía A | Cierto: quien no tiene la palabra no puede empezar. El índice de situaciones (40 a 60 entradas en lenguaje corriente, cada una con tema y anclas) es contenido interpretativo y se escribe a mano con firma: entra a la pauta de validación como primer bloque, porque además es la primera fuente de alias. Lo que la máquina hace ahora: verificar que las 17 páginas temáticas son navegables sin escribir y listar sus nombres para que el equipo juzgue si están en lenguaje legal. |
| B-08 | mayor | adoptar | v12 | Cierto (C3): el rótulo copiable debe llevar nivel, tipo y estado, derivados de metadatos existentes, en las tres capas. Con B-01: «Fuente primaria · Ley · versión del texto: no declarada» es un rótulo válido y honesto. |
| B-09 | menor | adoptar | v12 | Cierto (C3); misma tabla que A-20, con el tipo impreso en vez del número. La prueba del revisor (el equipo marca desacuerdos sobre las 25) se corre cuando haya equipo. |
| B-10 | mayor | adoptar con ajuste | decisión D-D | Plausible y sin medir: que 0 de 22 se explique por la unidad de firma es una hipótesis del revisor, y la prueba que propone (ofrecer las dos unidades la misma semana y preguntar) es la forma de zanjarla. Ajuste: la firma por cargo más acta sigue siendo humana, nominal y fechada, así que no rompe el invariante 🔒; pero cambia el contrato de `validado_por` y es decisión del titular, no del asistente (§4, D-D). La unidad firmable pequeña (una consideración de dos o tres líneas) usa el subtipo que la decisión 7 del traspaso ya previó. |
| B-11 | mayor | adoptar | decisión D-A | Cierto (C1) y es la versión de A-16 que no exige escritura humana: estado derivado en tiempo de construcción, mostrado y no publicado. Es el mecanismo que D-A adopta. |
| B-12 | menor | adoptar | esp. v2 (capa 1) | Cierto. Hasta que el glosario tenga firma, sus entradas en la capa 1 solo navegan, sin definición visible. Los 27 encabezados con la definición pegada (P5) refuerzan la razón. |
| B-13 | mayor | adoptar | esp. v2 (precondición de capa 3 en vivo) | Cierto y es gobernanza, no diseño: `CLAUDE.md` §4 ya obliga a detener ante RUT o nombre propio. Bloqueo del lado del cliente antes del envío (patrón de RUT y secuencias de nombres propios) y la línea pública «qué se envía y adónde» son precondiciones de la capa 3 en vivo, junto con A-14. La prueba con RUT ficticio se describe, no se transcribe (E6 del traspaso). |
| B-14 | mayor | adoptar con ajuste | v12 | Cierto en lo concreto: el enlace «ver texto vigente» a la Biblioteca del Congreso es derivable, porque la URL corta de origen está en el texto extraído de cada norma (es lo que la limpieza del preámbulo retiraba, traspaso §4.4), y una línea de portada que diga qué tiene esta biblioteca y no está en otra parte (circulares y dictámenes de la Superintendencia, relaciones derivadas, orientación firmada) es texto institucional, no doctrina. Ajuste al juicio estratégico: la inversión en recuperación no se detiene, porque el equipo no busca leyes sueltas sino conjuntos que cruzan ley, reglamento y dictamen (B-18), y eso la Biblioteca del Congreso no lo entrega. La prueba del revisor (resolver las diez consultas fuera del sitio) se corre en el v12 y su resultado se registra, no se anticipa. |
| B-15 | mayor | adoptar | v12 | Cierto (C6): el camino sancionado debe ser el más cómodo. Botón «Copiar cita» por segmento que copia norma, artículo, texto literal, URL del ancla, tipo, estado y versión del texto (B-01, B-08) y fecha de consulta. Es el invariante 1 convertido en hábito. |
| B-16 | menor | adoptar | esp. v2 (capa 1) | Cierto sobre el peso (52 036 B frente a 435 763 B, síntesis §1.1 citada por el revisor). La capa 1, cuando se construya, publica la variante sin encabezados de segmento; los reincorpora si el 10 % o más de las primeras 100 consultas reales trae número de artículo. |
| B-17 | menor | adoptar | esp. v2 | Cierto (C4). Solo R0; un nivel adicional entra únicamente si mejora el acierto en al menos dos consultas del conjunto. |
| B-18 | mayor | adoptar con ajuste | v11 (métrica), v12 (presentación) | Cierto en la métrica: 19 anclas para 10 consultas dice que la respuesta es un conjunto. Ajuste: la interfaz actual ya agrupa por norma (un resultado de Pagefind es una página de norma con sus sub-resultados), así que lo que falta es el tipo visible junto al nombre de la norma y los términos que provocaron la coincidencia, que van al v12. El v11 incorpora al instrumento la cobertura del conjunto de anclas por consulta junto al acierto por ancla, y corre la prueba del revisor (cuántas consultas tienen dos o más anclas en dos o más normas). |
| B-19 | menor | adoptar | v12 (criterios de aceptación) | Cierto (C7) y coincide con D3 de la compuerta de dudas (390 px físicos nunca probados). Cada elemento del v12 se acepta con una prueba en un teléfono real sobre la red de un establecimiento, con los dos tiempos del revisor; el dispositivo de referencia lo declara el titular. |
| B-20 | mayor | adoptar | decisión D-C | Cierto: el trabajo humano sin dueño no ocurre, y 0 de 22 lo prueba. Nombrar a la persona es del titular; el bloque semanal de veinte minutos y la fuente obligatoria (B-02) se escriben en la decisión. |

---

## 4. Decisiones del titular

La ruta de la sesión 4 previó tres; B-10 agrega una cuarta. Cada una se materializa como archivo en `50_documentacion/activa/decisiones/` una vez elegida, junto con las decisiones 3 y 6 del traspaso v03 §8, que siguen pendientes de materialización.

### D-A. Versión del texto por ancla (A-16, B-01, B-11)

- **Problema:** el invariante 1 garantiza que el ancla resuelve, no que el texto sea el de hoy ni que la pieza firmada cite lo que citó.
- **Opción 1:** hash del texto por segmento en el JSON canónico (derivado) más estado derivado «requiere revalidación» en el constructor de piezas (B-11), más campo curado `texto_consolidado_al` por norma (B-01) impreso en todo resultado, con «no declarada» mientras sea nulo. El ancla no cambia.
- **Opción 2:** lo mismo más sufijo de versión en el ancla pública cuando el texto cambia (A-16 literal).
- **Opción 3:** solo el campo curado, sin hash ni estado derivado.
- **Recomendación:** Opción 1, porque la 2 rompe el invariante 🔒 de anclas estables y toda cita ya copiada, y la 3 deja sin detección el caso que ambos revisores declaran bloqueante (la pieza firmada sobre un texto que cambió). La opción 1 no escribe en `20_insumos/`: el hash y el estado son derivados; el campo curado es trabajo de la vía A y su ausencia se muestra, no se oculta.

### D-B. Vía semántica: diferida con umbral (pregunta 1 de ambos roles, A-01, A-02, A-12)

- **Opción 1:** diferir hasta que se cumpla una condición medible: 100 o más consultas reales capturadas y, con los alias en su lugar, 15 % o más sin ninguna coincidencia léxica sobre tokens de contenido (umbral de B), o más de un tercio de las consultas reales redactadas como oraciones (umbral de A). Cualquiera de los dos reabre.
- **Opción 2:** construirla ahora en float32 con modelo nombrado, para medir en vez de estimar.
- **Opción 3:** descartarla del diseño.
- **Recomendación:** Opción 1, porque el residuo que solo la vía semántica rescata es 1 de 10 sobre conjuntos construidos, su costo real (modelo en navegador o Worker) no está medido y los dos revisores coinciden en el diferimiento; la 3 borra un diseño ya pagado y la 2 gasta cuota antes de saber qué lenguaje usa el equipo.

### D-C. Captura de consultas reales y dueño (B-02, B-20, A-15, pregunta 5 de ambos roles)

- **Problema:** todo conjunto de prueba es construido; no hay dato del lenguaje real del equipo, y ningún alias puede curarse ni medirse sin él.
- **Opción 1:** enlace estático «¿No encontraste lo que buscabas?» hacia un formulario institucional que captura solo la consulta escrita (sin nombre, sin caso, sin RUT), más una persona del equipo nombrada como dueña, con veinte minutos semanales para leer las consultas y proponer alias con `fuente`. A las cuatro semanas, cruce contra las 38 construidas (prueba de B-02); a las ocho, conteo de alias con fuente (prueba de B-20).
- **Opción 2:** registro automático de consultas en el sitio (sin servidor no es posible en GitHub Pages sin un tercero; con Worker, deja de ser estático y captura lo que el usuario escriba, incluidos datos personales).
- **Opción 3:** curar alias desde el vocabulario del v9 sin consultas reales.
- **Recomendación:** Opción 1, porque la 2 introduce un servidor y el riesgo de B-13 en la capa que hoy es estática, y la 3 es exactamente lo que B-02 llama curar a ciegas. La condición de gobernanza (solo la consulta, ningún dato del caso) es del proyecto, no del revisor.

### D-D. Unidad y forma de la firma humana (B-10)

- **Problema:** 0 de 22 piezas firmadas en tres sesiones. Hipótesis del revisor: la exposición de un nombre propio y el tamaño de la unidad firmable.
- **Opción 1:** admitir `validado_por` con cargo más acta de sesión del equipo (fechada, con los asistentes en el acta), y reducir la unidad mínima firmable a una consideración de dos o tres líneas usando el subtipo que la decisión 7 del traspaso previó; probar las dos unidades la misma semana y preguntar en forma directa si el nombre es el obstáculo.
- **Opción 2:** mantener la firma nominal por persona y la pieza completa como unidad.
- **Recomendación:** Opción 1, porque no rompe el invariante 🔒 (la firma sigue siendo humana, nominal a través del acta, y fechada), es reversible, y es la única de las dos que produce un dato sobre por qué la vía A no avanza. Condición: el cambio en el contrato de `validado_por` se documenta en `CLAUDE.md` §10.5 y en la compuerta de firma antes de aceptar la primera firma por acta, y la compuerta sigue abortando ante una pieza validada sin firma.

---

## 5. Respuesta del proyecto a las seis preguntas de la especificación §10

1. **¿Se justifica la vía semántica en 806 segmentos?** No ahora. Se difiere con el umbral de D-B. Lo que se construye en su lugar: expansión léxica (v11), salidas estáticas (v12), consultas reales con dueño (D-C).
2. **¿Es correcto excluir el texto sin firma del contexto del modelo?** Sí, en la entrada, y no es negociable mientras el arnés mida procedencia y no suficiencia (A-14). El costo no es permanente: son 9 páginas del dictamen 078, y la cola de revisión OCR se ordena por consultas desbloqueadas (B-05), con esas 9 primero. En todo modo, incluido el precalculado, el texto OCR se muestra como ubicación, no como evidencia (A, pregunta 2).
3. **¿Es defendible el segmento como unidad?** Sí, y ninguno de los dos lo discute: es la única unidad con ancla pública y es lo que va en un oficio. Cuando exista vía semántica, la fragmentación interior respeta párrafos y conserva desplazamiento (A-05, A-06), y el resultado mostrado es siempre el segmento completo con el pasaje resaltado (B, pregunta 3). Indexar por inciso: solo con consultas reales que muestren 20 % o más de aciertos en artículos de más de 3 000 caracteres y personas que no encuentren el pasaje.
4. **¿El orden de construcción es el mejor?** No lo era; se reordena tomando el de B con la inserción de A: (1) v11, corrección de interfaz y expansión léxica, sin compuerta humana; (2) v12, cita copiable, enlace a texto vigente, «¿No encontraste?», estado vacío, rótulos con tipo y estado, versión del texto visible; (3) D-A, hash por segmento y estado «requiere revalidación», porque su aplazamiento empeora con cada norma que entra; (4) índice de situaciones y alias curados desde consultas reales, con dueño (vía A, D-C); (5) capa 1 en su variante liviana; (6) capa 3 precalculada con unidad firmable pequeña (D-D); (7) vía semántica solo por el disparador de D-B; capa 3 en vivo solo con arnés de suficiencia y bloqueo de datos personales.
5. **¿Qué le falta para que un equipo no técnico lo use?** Los dos roles dan la misma lista con palabras distintas: que la salida sea el formato de trabajo del equipo (cita copiable con ancla, tipo, estado y versión), que la entrada acepte la forma en que el equipo pregunta (índice de situaciones, palabras vacías excluidas, estado vacío diseñado), que la confianza se verifique en un clic (texto vigente en la Biblioteca del Congreso, versión del texto por norma), que exista un canal de una línea para lo que no se encontró, que funcione en un teléfono, que una persona con nombre sea dueña del mantenimiento, y una sesión de treinta minutos con los casos del propio equipo antes que una guía.
6. **¿Qué parte es sobreingeniería?** Con nombre y de ambos roles: reordenamiento en niveles 2 y 3 y descomposición de preguntas (sin ganancia medida); cuantización int8 (el término dominante es el modelo); los 806 encabezados de segmento en la capa 1 (88 % del peso para consultas con número); el prompt de 5 022 caracteres y cinco modos para una capa que no se construye; Cloudflare Access más cuota en un Durable Object para un equipo que cabe en una mano; la ampliación de la ontología de relaciones como capa y no como rótulo (reetiqueta 22 pares, no descubre ninguno). No es sobreingeniería y se conserva: segmento con ancla, Pagefind, JSON estático, piso determinístico R0, compuerta en la entrada, rótulos en texto plano, relaciones derivadas y nunca inferidas, y la sección 9 de la especificación tal como está escrita.

---

## 6. Reparto de adopciones por destino

| Destino | Hallazgos |
|---|---|
| **v11** | A-07 (medición recall@K), A-15 (instrumento: diez consultas versionadas, clase «sin respuesta», MRR, medida pareada), A-18 (tildes), A-19 (prueba de números de ley, luego metadato si pierde), B-06 (palabras vacías en la expansión), B-18 (cobertura del conjunto de anclas) |
| **v12** | A-17 y B-19 (criterios de aceptación: latencia fría y caliente, teléfono real), A-20 y B-09 (nivel por `tipo`, tipo en el rótulo), B-01 (parte derivada: «versión del texto: no declarada», bloqueo de «vigente»), B-02 (enlace «¿No encontraste?»), B-03 (estado «sin resultado firme» con lista derivada de normas citadas no incluidas), B-04 (parte derivada), B-05 (nota de sustitución como encabezado), B-08 (rótulo con nivel, tipo y estado), B-14 (enlace a texto vigente, línea de portada, prueba de las diez consultas fuera del sitio), B-15 (botón «Copiar cita»), B-18 (tipo visible y términos coincidentes) |
| **decisión** | D-A (A-16, B-01, B-11), D-B (pregunta 1, A-01, A-02, A-12), D-C (B-02, B-20, A-15), D-D (B-10) |
| **vía A** | B-01 (campo `texto_consolidado_al`), B-04 (P4 y entrada curada si se demora), B-05 (orden de la cola OCR, dictamen 078 primero), B-07 (índice de situaciones como primer bloque de la pauta) |
| **esp. v2** | A-01, A-02, A-03, A-04, A-05, A-06, A-08, A-09, A-10, A-11, A-12, A-13, A-14, B-06 (capa 1), B-12, B-13, B-16, B-17 |
| **P8** | A-11 (regla de huella de caché generalizada) |
| **rechazado (parcial)** | A-16 (sufijo de versión en el ancla), B-05 (prerrequisito de lanzamiento), B-14 (detener la inversión en recuperación), B-02 opción 2 de D-C (captura automática con servidor) |

Ningún hallazgo se rechaza completo: los cuatro rechazos son de una parte del cambio propuesto, con el resto adoptado.

---

## 7. Lo que este documento no resuelve

- No mide nada del producto: las diez consultas, el recall@K, el estado del índice lateral y las tres formas del número de ley se miden en el v11 con recuento programático del turno.
- No decide por el titular: D-A a D-D quedan formuladas con recomendación y se materializan solo con su elección.
- No escribe la especificación v2: la lista de correcciones de §6 (fila «esp. v2») es su índice; la redacción es un encargo aparte o una tarea de sesión posterior.
- No toca la vía A: lo que va a la pauta (B-01, B-04, B-05, B-07) se agrega a `20260826_pauta_validacion_convivencia_v1.md` en una v2 que exige delegación para su entrega.
