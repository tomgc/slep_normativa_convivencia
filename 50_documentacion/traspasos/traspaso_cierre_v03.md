
# Traspaso de cierre v03 — slep_normativa_convivencia

## 1. Identificación

- **Proyecto:** `slep_normativa_convivencia` (biblioteca pública de normativa chilena de convivencia educativa, artículo por artículo).
- **Versión del traspaso:** v03. **Sesión:** 3. **Fecha de cierre:** 2026-09-09.
- **Foco de la sesión:** diseñar el motor de búsqueda asistida mediante un encargo de alcance de cinco agentes (v9), y después corregir lo que ese encargo destapó en el producto real (v10): buscador, legibilidad y limpieza del texto extraído.
- **Entorno:** macOS, MacBook Pro de Tomás. R 4.5.2 y Quarto 1.9.38 fijados en CI. Positron. Repositorio único (Rama A), corpus público sin datos personales.
- **Documentos normativos vigentes, con su encabezado transcrito:** `POLITICA_PROYECTO.md` → `> **Versión 5.8 — vigente.**`; `SETTINGS_Y_PROMPTS_OPERACIONALES.md` → `> **Versión 37.**`.
- **Archivos principales modificados:** `30_procesamiento/34_plantillas_sitio/busqueda.html`, `30_procesamiento/34_plantillas_sitio/estilo.css`, `30_procesamiento/31_extraer_texto.R`, `40_salidas/datos/normas/*.json` (17) y `40_salidas/datos/relaciones.json` (regenerados por pipeline), `50_documentacion/activa/50_datos_versionados_autorizados.md` (nuevo).
- **`main` previo al commit de cierre:** `b56f077` (fuente: reporte final del encargo v10 en el chat de esta sesión). Nota de discrepancia: la tabla §9 del log del v10 enumera seis commits y termina en `bff6390`; el séptimo, `b56f077`, es el commit del propio log y aparece solo en el reporte de chat.

## 2. Resumen ejecutivo

La sesión se propuso arrancar la vía A entregando la pauta de validación al equipo de convivencia, y el titular la redirigió a trabajo de máquina desde el primer turno, con dos objetos: diseñar un motor de búsqueda más inteligente que el indexador actual, y corregir la legibilidad del sitio. Lo primero se resolvió con el encargo v9, un encargo de alcance de cinco agentes especializados más auditoría independiente y síntesis, que produjo nueve documentos, dos prototipos en R y un log de 1 211 líneas, sin cambiar un byte del producto: su valor son seis decisiones medidas que no habrá que volver a tomar, un conjunto de diez consultas de evaluación con anclas verificadas, y nueve reglas de método. Su hallazgo más importante no fue de búsqueda sino de diagnóstico: el buscador publicado no devolvía el artículo correcto casi nunca, la ley principal del corpus está consolidada a 2010, falta la normativa de expulsión que los propios documentos citan, y el único dictamen vigente sobre revisión de pertenencias es OCR sin firma. Lo segundo se resolvió con el encargo v10, que sí cambió el producto: el buscador pasó de 1 a 3 de 10 con las diez consultas de evaluación, cuatro defectos de legibilidad quedaron corregidos con antes y después medidos en navegador, y la cabecera del sitio de origen desapareció del texto de 17 normas sin mover una sola ancla. El v10 además refutó la premisa que el v9 le había heredado: la línea base no era 0 de 10 sino 1 de 10, y el cuello de botella no es la presentación sino la recuperación léxica, porque Pagefind exige todos los términos y el equipo pregunta con palabras que la norma no usa. Quedan corriendo dos revisiones externas del diseño, con roles separados, cuyos informes son el insumo del próximo encargo. La vía A sigue intacta y sin avanzar: la pauta no se entregó, 22 piezas siguen en borrador y las 84 páginas de OCR siguen sin firma.

## 3. Estado al cierre

**Qué funciona** (última ejecución exitosa: encargo v10, seis commits con CI en verde, verificado por `head_sha`, y comprobación en producción sobre `https://tomgc.github.io/slep_normativa_convivencia/`):

- Sitio publicado y estable: 47 páginas HTML, 25 normas, 682 artículos, 806 segmentos con ancla, 17 páginas temáticas.
- Pipeline reproducible: `run_all()` corrido cinco veces en la sesión; control de idempotencia previo con los 47 HTML idénticos byte a byte y los 28 JSON versionados idénticos.
- Buscador con orden por relevancia, tope de cinco sub-resultados por norma e identificador de artículo visible.
- Hoja de estilos con una regla responsiva y cuatro selectores condicionales, servidos en producción.
- Texto extraído limpio de la cabecera del sitio de origen: 0 de 25 normas contaminadas.
- Compuerta de firma endurecida y autoprueba de coincidencia parcial en cada despliegue (heredadas de la sesión 2, sin cambios).

**Qué no funciona** (síntoma observable):

- El buscador resuelve 3 de 10 consultas de evaluación. En 7 el índice no entrega la página correcta, y en 3 no entrega ninguna.
- El índice lateral de las páginas de norma dice «Articulado» y contiene una sola entrada: los artículos no entran porque se emiten dentro del contenedor de indexación.
- La Ley General de Educación del corpus es el texto consolidado al 02-JUL-2010, sin los artículos 16 A a 16 E ni las frases insertadas por las leyes 21.801 y 21.809.
- El procedimiento de expulsión (DFL 2/1998 art. 6 letra d, Ley 21.128) no está en el corpus, pese a estar mencionado 22 y 17 veces por los propios documentos.
- El dictamen 078, que es el vigente, es texto OCR sin firma: la única doctrina citable sobre revisión de pertenencias es la norma sustituida.
- Dos anclas rotas en piezas en borrador; `aviso_vigencia` nulo en las 25 normas; 27 encabezados de glosario con la definición pegada al título.

**Delta respecto a v02:**

| Magnitud | v02 | v03 |
|---|---|---|
| Consultas de evaluación resueltas | no existía la medición | **3 de 10** (línea base 1 de 10) |
| Normas con la cabecera del sitio de origen en el texto | 17 de 25 (no medido entonces) | **0 de 25** |
| Reglas responsivas en la hoja de estilos | 0 | **1 punto de corte** |
| Relaciones | 552 | **552**, sin altas ni bajas; dos remisiones mejoran de destino |
| Segmentos con ancla | 806 | **806**, sin cambio |
| Piezas publicadas | 0 de 22 | **0 de 22**, sin cambio |
| Documentos de diseño del motor | 0 | **9 documentos, 2 prototipos, 1 esqueleto de Worker** |

## 4. Registro detallado de cambios

### 4.1 Encargo v9 — alcance del motor de búsqueda (cinco agentes)

- **Archivos:** nueve documentos y dos prototipos en `50_documentacion/andamios/`, log en `andamios/logs/`. Commits `e71f1e0`, `80d291e`, `a67426d`, `6a0ebd5`, `bf9bd90`.
- **Categoría:** sitio_navegacion.
- **Qué se hizo:** cinco agentes especializados (vocabulario controlado, recuperación semántica, capa de orientación, arquitectura Cloudflare, panel adversarial), más auditoría independiente con doce verificadores y síntesis. Producto: 892 entradas de vocabulario con 887 de 887 destinos verificados y 21,6 KB comprimidos; corpus dimensionado en 806 unidades y 1 160 fragmentos; 47 citas oficiales verificadas con URL; ontología de relaciones decidida tipo por tipo; stack reducido a GitHub Pages más un Worker que solo custodia la clave.
- **Por qué:** el titular pidió un motor que sugiera conceptos mientras se escribe y oriente sobre cómo abordar un tema. Antes de construir nada había que decidir la unidad de recuperación, qué entra al contexto del modelo, qué relaciones son derivables y qué componentes sobran.
- **Cómo se verificó:** auditoría independiente que produjo 91 hallazgos canónicos (2 bloqueantes, 5 mayores, 58 menores, 26 mejorables, 7 descartados por escépticos); los dos bloqueantes apuntaban al propio instrumento de auditoría, que no detectó tres de los defectos que él mismo había plantado. Tras dos rondas de corrección, los 7 graves quedaron cerrados sin reserva; 16 puntos quedaron abiertos y declarados.
- **Tensiones:** el diseño externo aportado por el titular proponía inferir relaciones y clasificar el corpus con un modelo, ambas cosas incompatibles con los invariantes del proyecto. Se resolvió con una sección de adopciones y rechazos explícitos, firme para todos los agentes salvo el panel adversarial, único autorizado a impugnarla.

### 4.2 Encargo v10 — sub-resultados del buscador

- **Archivo:** `30_procesamiento/34_plantillas_sitio/busqueda.html`. Commit `32e19c2`.
- **Categoría:** sitio_navegacion.
- **Qué se hizo:** se reemplazó el componente de interfaz de Pagefind por una interfaz propia sobre su API pública, dentro del mismo archivo. Tres cambios: orden de sub-resultados por suma de puntaje balanceado, tope de cinco por norma, e identificador de artículo visible junto al título.
- **Por qué el reemplazo y no un ajuste:** el tope de tres está escrito en el cuerpo de la función de recorte del bundle (`slice(0,3)`), no en un parámetro, de modo que ningún ajuste externo lo sube. Verificado leyendo el bundle publicado y citado literal en la medición.
- **Cómo se verificó:** el instrumento extrae del propio `busqueda.html` el bloque de orden y lo evalúa, así que la cifra «después» se mide con el código que se publica. En modo réplica reproduce la línea base exacta. Resultado 1 → 3 de 10; en la batería con términos canónicos, posición mediana del artículo correcto de 2 a 1. Verificado además contra el índice de producción, con la misma cifra.
- **Dependencias:** el tope 5 se eligió por margen y no como óptimo medido: con el orden nuevo, el tope 2 ya alcanza 12 de 13 casos y la curva es plana hasta 8. Subir el tope no compra cobertura; el orden sí.

### 4.3 Encargo v10 — legibilidad

- **Archivo:** `30_procesamiento/34_plantillas_sitio/estilo.css`. Commit `6524ffe`. `_quarto.yml` estaba autorizado y no se tocó.
- **Categoría:** diseno_visual.
- **Qué se hizo:** de seis defectos nombrados, la medición confirmó cuatro, confirmó uno en una regla distinta de la nombrada y no confirmó el sexto. Se agregó un punto de corte responsivo (`max-width: 575.98px`, el del marco que el tema ya usa), se restituyó el subrayado de los enlaces temáticos, se subió el contraste de dos pares que estaban bajo el umbral, se agrandaron las versalitas y se compactó el bloque de búsqueda en las 42 páginas que no son portada ni índice.
- **Cómo se verificó:** `getComputedStyle` en Chrome 152 a 500 y 1280 px, contra una copia del sitio con la hoja anterior. Las reglas aplican bajo el corte y no por encima, que es la comprobación de que el corte funciona.
- **Tensiones:** el bloque de texto reconocido conserva los saltos del reconocedor a propósito; se mejoró su legibilidad sin reflowear. Cero colores nuevos, cero eliminados, las mismas dos familias tipográficas: es corrección de legibilidad, no rediseño.

### 4.4 Encargo v10 — limpieza del preámbulo

- **Archivo:** `30_procesamiento/31_extraer_texto.R`. Commit `174087a`.
- **Categoría:** corpus_insumos.
- **Qué se hizo:** función `quitar_metadatos_origen()` aplicada sobre el vector de bloques después de unir páginas y antes de componer el texto, con tres guardas: solo dentro de los primeros cinco bloques, el bloque debe terminar en la URL corta y nunca se quita un encabezado de artículo. Cubre además el pie del sitio de origen en los documentos de una o dos páginas, donde la limpieza previa se apagaba por diseño.
- **Por qué en ese punto exacto:** la cabecera de la primera página cruda es la única fuente del título y del año; limpiar antes habría roto ambos en 17 normas. Además dos de las 17 no tienen preámbulo y se habrían quedado fuera de una limpieza restringida a ese segmento, y limpiar en el segmentador habría dejado sucio el texto intermedio, que es la entrada de cualquier índice posterior.
- **Cómo se verificó:** 17 de 25 → 0 de 25 con el mismo comando exhaustivo antes y después, con control positivo. Prueba de regresión bloqueante en verde: 806 segmentos presentes, 848 de 848 destinos del inventario del v9 que son verificables contra el sitio, 273 enlaces internos con 205 destinos distintos, 0 rotos. Títulos, años, conteos, temas y marcas idénticos en las 25; relaciones en 552 antes y después.
- **Efecto colateral favorable:** dos remisiones que apuntaban al preámbulo (porque la ficha traía una cita normativa) ahora apuntan al artículo que efectivamente cita.

### 4.5 Encargo v10 — inventario de pendientes de firma humana

- **Archivo:** `50_documentacion/andamios/20260908_pendientes_firma_humana_v1.md`, 412 líneas. Commit `bff6390`.
- **Categoría:** ocr_curaduria.
- **Qué se hizo:** cuatro puntos accionables para el equipo, sin corregir ninguno: 27 encabezados de glosario con la definición pegada al título (uno por uno, con su corte propuesto), dos anclas rotas en piezas en borrador, `aviso_vigencia` nulo en las 25 normas, y cuatro erratas de nombre más un slug materialmente falso.
- **Por qué no se corrigió:** todos viven en `20_insumos/`, que es de escritura humana exclusiva y no tenía delegación.
- **Cómo se verificó:** `20_insumos/` sin un solo cambio, con control positivo del mismo comando sobre otra ruta.

### 4.6 Cierre del hueco del hook global

- **Archivo:** `50_documentacion/activa/50_datos_versionados_autorizados.md` (nuevo). Commit `082a26d`.
- **Categoría:** infraestructura_pipeline.
- **Qué se hizo:** el hook de pre-push rechazó los 18 JSON de datos del commit de B3 porque el archivo de autorización que consulta no existía. El hook global se instaló el 2026-09-01 y este repositorio versiona sus JSON desde el bootstrap del 2026-08-25, así que esos archivos nunca se habían enfrentado a él.
- **Por qué así:** el ejecutor aplicó la regla de detención y consultó, en vez de usar `--no-verify`. El emisor amplió las autorizaciones bajo seis condiciones, entre ellas que el archivo autorice `40_salidas/datos/` y nada más.
- **Desviación declarada y correcta:** el patrón que el emisor pidió (`40_salidas/datos/**/*.json`) se probó contra el mecanismo real del hook y deja fuera `relaciones.json`, porque exige un `/` después de `datos/`. Se usaron dos líneas que cubren los dos niveles con archivos y ninguna otra ruta, con la prueba de señuelos transcrita en el propio archivo.

### 4.7 Especificación técnica y revisión externa en dos roles

- **Archivos:** `50_documentacion/andamios/20260908_especificacion_motor_busqueda_v1.md` y `20260908_encargo_revision_externa_motor_v1.md`.
- **Categoría:** gobernanza_docs.
- **Qué se hizo:** documento autocontenido que describe el motor para quien no tiene acceso al repositorio, con sus debilidades y residuos declarados por adelantado, y un encargo con esquema estricto de devolución (bloques de nueve campos, tabla resumen, respuestas a seis preguntas cerradas, «qué no cambiarías» y «lo que no pudiste evaluar»).
- **Por qué dos roles distintos:** dos revisores con el mismo mandato producen dos informes casi idénticos. El rol A juzga si el diseño funciona; el rol B, si le sirve a alguien y cómo falla en uso. Cuando coinciden con mandatos distintos, el hallazgo pesa mucho más.
- **Estado:** corriendo al cierre. Sus informes son el insumo del primer encargo de la sesión 4.

## 5. Backlog acumulativo

Vive en `50_documentacion/activa/backlog_acumulativo.md`. Esta sesión aporta 10 entradas nuevas, que el ejecutor renumera desde el último número en disco.

## 6. Bugs de la sesión y reglas aprendidas

**Bugs de código: uno, resuelto.**

- **Síntoma:** editar `31_extraer_texto.R` no reprocesaba nada; el pipeline declaraba los 25 documentos sin cambio y reutilizaba el texto anterior.
- **Causa raíz:** la huella de caché del paso 30 cubre el md5 del PDF, el del OCR y el origen del texto curado, **no la versión del código**.
- **Solución:** se apartó (no se borró) `40_salidas/intermedios/extraccion.json`, que no está versionado y el pipeline regenera, moviéndolo al directorio de laboratorio para que la acción fuera reversible. Resultado: 0 reutilizados, 25 documentos reextraídos.
- **Patrón general aprendido:** *una huella de caché que no incluye la versión del código convierte cualquier arreglo del extractor en un no-op silencioso que igual pasa CI.* Antes de dar por aplicado un cambio en un paso con caché, verificar que la caché se invalidó, contando documentos reprocesados.
- **Estado:** resuelto; el defecto de la huella sigue vigente y queda como pendiente.

**Reglas aprendidas de esta sesión:**

1. **Una premisa heredada de un encargo anterior es una hipótesis, no un dato.** El «0 de 10» del v9 se incorporó al §0 del v10 sin recontarlo y era falso: la línea base real es 1 de 10, y la causa que el v9 atribuyó a la presentación es de recuperación en 7 de las 10. Toda cifra que funde un encargo se recuenta en el turno que la escribe.
2. **El paralelismo máximo no es gratis.** Cinco agentes simultáneos contra un límite de sesión convierten una interrupción en pérdida total: siete cortes en cuatro días, dos de ellos sin producir nada. Dos agentes y commit por agente terminado es el techo.
3. **Una lista de autorizaciones que no cubre las verificaciones que el propio encargo exige produce residuos evitables.** Ocurrió cuatro veces en el v10 (`10_utils/`, `CLAUDE.md`, el laboratorio y el propio archivo del encargo) y una en el v9 (dominios que redirigen). Cruzar autorizaciones contra verificaciones par a par, incluyendo las redirecciones de un salto.
4. **Un defecto nombrado sobre código muerto no es un defecto.** Dos de los seis defectos de legibilidad que el emisor nombró apuntaban a reglas sin un solo uso en las 47 páginas. Antes de nombrar un defecto de estilo, verificar que la regla se aplica en algún lugar.
5. **La proporción de hallazgos menores es un indicador de sobreingeniería del encargo, no de rigor.** De los 91 hallazgos canónicos del v9, 84 eran menores o mejorables, y el paquete informa unas seis decisiones. El v10 limitó la corrección a bloqueantes y mayores desde el inicio y convergió en una jornada.
6. **La reparación quirúrgica es una regla de primer minuto, no de segunda ronda.** En el v9, cuatro de cinco autores introdujeron defectos nuevos al corregir (29 en total); con la regla activa bajaron a 9.
7. **Un caso plantado benévolo no prueba nada.** El instrumento de auditoría del v9 aprobó tres defectos plantados por la razón equivocada. Todo control positivo debe ser adversarial contra el instrumento.
8. **Un viewport de captura no es un viewport de navegador.** Una captura headless a 390 px mostró contenido cortado que no existía: el mínimo real del navegador headless es 500 px. Antes de corregir un desborde, medir `scrollWidth` contra el viewport.

## 7. Aprendizajes y restricciones descubiertas

- **Pagefind exige todos los términos de la consulta.** Con consultas en el lenguaje del equipo («celular», «bullying») y un corpus en lenguaje legal («dispositivos móviles», «acoso escolar»), el índice no devuelve ninguna página en 3 de 10 casos. Restricción: cualquier mejora de recuperación pasa por expandir la consulta con sinónimos antes de consultar el índice, no por reordenar lo que el índice devuelve.
- **El vocabulario derivado del corpus no cubre el lenguaje del usuario.** Medido: 21 % de los términos, 3 % de las consultas, y 42 % de las consultas sin una sola palabra en común. Restricción: la capa de sugerencia útil depende de alias curados por personas, es decir, de la vía A.
- **El servicio administrado de búsqueda de Cloudflare no sirve a este corpus.** Su tokenizador no ofrece opción de idioma y su fragmentación fija a 512 tokens rompe la unidad de artículo, que es la unidad que este proyecto existe para entregar.
- **El control de acceso de Cloudflare puede proteger un subdominio propio del Worker sin exigir una zona propia**, verificado contra documentación oficial. Queda no medido que funcione en el plan gratuito.
- **Las anclas del glosario no son verificables contra el sitio**, porque el glosario no está publicado: 39 de los 887 destinos del inventario del v9 son suyos. El inventario verificable contra el sitio es de 848.
- **Un invariante que pasa mientras la condición que dice proteger está ausente produce confianza falsa.** Se manifestó dos veces: en el instrumento de auditoría del v9 y en la caché del extractor.

## 8. Decisiones de diseño

1. **El motor se diseña en tres capas independientes, cada una funcional sin las otras dos.** Alternativas: un sistema integrado tipo asistente jurídico, o solo mejorar el buscador. Justificación: la capa de sugerencia no necesita servidor ni gasto, la semántica sí y la de orientación depende de firma humana; acoplarlas habría hecho que ninguna avanzara hasta que todas pudieran. Implicancia: el orden de construcción es una decisión separada del diseño.
2. **Recuperación híbrida con fusión de rangos, no elección entre motores.** Alternativa descartada: reemplazar la vía léxica por la semántica. Justificación medida: los embeddings fallan en números de ley y de artículo, que es una porción alta de las consultas de este dominio.
3. **La unidad de recuperación es el segmento (806), no el artículo (682) ni el documento.** Justificación: los otros 124 (preámbulos, secciones de dictamen, páginas de OCR) tienen ancla y son recuperables, pero no son artículos. Implicancia: toda cifra del motor se expresa en segmentos y la nomenclatura queda fijada.
4. **El texto sin firma se excluye en la entrada al contexto del modelo, no se filtra en la salida.** Justificación medida: un detector aplicado a la salida tuvo 10,96 % de falso positivo sobre frases firmadas reales; la compuerta de entrada dejó pasar 0 de 27 745 casos.
5. **La ontología de relaciones se amplía solo con tipos derivables programáticamente.** Entran modifica (8 pares), reglamenta (2), interpreta (11) y deroga como nota marginal (1). Se rechazan complementa, desarrolla y contradice: ningún metadato los sostiene y exigirían juicio jurídico.
6. **El stack se reduce a GitHub Pages más un Worker que solo custodia la clave.** Descartados con umbrales calculados: base relacional, almacén de objetos, base vectorial y servicio administrado de búsqueda. El corpus está muy por debajo de los tres umbrales (unos 4 900 vectores, 5 120 artículos, 188 normas).
7. **La ruta de abordaje usa un tipo de pieza existente más un subtipo, en vez de ampliar el catálogo de tipos.** Justificación: pasa la compuerta de firma vigente sin tocar código, verificado contra la compuerta real y no contra su documentación.
8. **El proyecto se encuadra como ejercicio académico-técnico sobre literatura pública.** Implicancia: caen la exigencia de cuenta institucional y la de gobernanza de datos sensibles; sobrevive el control de acceso como control de gasto, y sobrevive entera la compuerta de firma.

Ninguna alcanza el peso arquitectónico que exigiría replicarse como archivo en `50_documentacion/activa/decisiones/`, salvo la 3 y la 6, que quedan como pendiente de materialización.

## 9. Constantes y parámetros

| Constante | Valor anterior | Valor nuevo | Archivo | Motivo |
|---|---|---|---|---|
| `TOPE_SUB_RESULTADOS` | 3 (en el cuerpo del bundle, no configurable) | 5 | `34_plantillas_sitio/busqueda.html` | Margen sobre el mínimo justo de una muestra de 13 casos |
| `REGEX_FICHA_ORIGEN` | no existía | derivado del texto real | `30_procesamiento/31_extraer_texto.R` | Limpieza de la cabecera del sitio de origen |
| `REGEX_PIE_ORIGEN` | no existía | derivado del texto real | `30_procesamiento/31_extraer_texto.R` | Cubre el pie en documentos de una o dos páginas |
| Punto de corte responsivo | no existía | `max-width: 575.98px` | `34_plantillas_sitio/estilo.css` | Es el corte que el marco del tema ya usa; no se inventó uno propio |

Las dos constantes de expresión regular quedaron en `31_extraer_texto.R` y no en `10_utils/10_configuracion.R`, que es su fuente canónica, porque `10_utils/` no estaba en la tabla de autorizaciones. Queda como pendiente. Las vigentes del proyecto viven en `10_utils/10_configuracion.R`.

## 10. Arquitectura de archivos

El escáner se regenera en este cierre como último acto que toca el árbol. Cambios de estructura de la sesión: ninguno en las decenas ni en la convención de nombres. Se agregan archivos en `50_documentacion/andamios/` (documentos de alcance del v9, medición y pendientes del v10, especificación y encargo de revisión externa), un archivo nuevo en `50_documentacion/activa/` (`50_datos_versionados_autorizados.md`) y un directorio de laboratorio no versionado, `50_documentacion/andamios/lab_motor_v9/`, con 128 archivos.

## 11. Pendientes y ruta sugerida

### 11.1 Inventario

**P1 — Recuperación léxica: las 7 consultas que el índice no resuelve.**
Tipo: funcionalidad. Impacto: alto, es el techo actual del buscador. Dependencias: el vocabulario de 892 entradas del v9 ya existe y sirve de fuente de sinónimos; conviene esperar el informe del revisor externo con rol A, que opina justamente sobre recuperación. Complejidad: media. Principios: cita textual y trazabilidad se mantienen intactos (la expansión ocurre antes de consultar, no después de recuperar). Precauciones: la expansión no debe degradar las consultas que hoy funcionan; medir contra las diez y contra la batería canónica. Criterio de éxito sugerido: al menos 6 de 10 con el ancla esperada, sin que ninguna de las 3 actuales retroceda.

**P2 — Índice lateral vacío en las páginas de norma.**
Tipo: bug activo. Impacto: alto sobre la legibilidad, y es probablemente parte de la queja original del titular. Contexto: las páginas titulan su índice «Articulado» y contienen una sola entrada, «Normas relacionadas»; los artículos no entran porque se emiten dentro del contenedor de indexación. Dependencias: `34_generar_paginas.R`. Complejidad: media. Precauciones: mover los encabezados fuera del contenedor puede afectar lo que Pagefind indexa; la prueba de regresión de anclas y la cifra de las diez consultas son bloqueantes. Criterio de éxito sugerido: el índice lateral de `dfl_1` lista sus 220 encabezados con `id`, y las diez consultas no retroceden.

**P3 — Saneamiento del corpus: Ley General de Educación desactualizada.**
Tipo: bloqueante de contenido. Impacto: la ley principal del corpus no dice lo que dice la ley vigente. Dependencias: incorporar el texto consolidado actual es escritura en `20_insumos/`, es decir, delegación registrada del titular. Complejidad: baja técnicamente, alta en decisión (qué versión es la canónica y cómo se marca el cambio). Precauciones: cambiar el texto de una norma publicada desplaza su segmentación; la prueba de regresión de anclas es bloqueante. Criterio de éxito sugerido: los artículos 16 A a 16 E existen en el sitio con ancla estable.

**P4 — Normativa faltante: procedimiento de expulsión.**
Tipo: bloqueante de contenido. Impacto: el corpus cita 22 y 17 veces normas que no contiene. Dependencias: obtener los PDF canónicos e incorporarlos por el manifiesto de hash; escritura en `20_insumos/` con delegación. Complejidad: baja. Criterio de éxito sugerido: DFL 2/1998 y Ley 21.128 en el corpus, con las remisiones existentes resolviendo hacia ellos.

**P5 — Cuatro puntos de firma humana ya inventariados.**
Tipo: bloqueante de calidad. Contexto: `20260908_pendientes_firma_humana_v1.md`. Dependencias: el equipo de convivencia. Criterio de éxito sugerido: los 27 encabezados de glosario corregidos y las 2 anclas rotas resueltas, con firma.

**P6 — Vía A completa, sin avance desde la sesión 1.**
Tipo: bloqueante de contenido y de calidad. Contexto: la pauta de validación (4 bloques) y el CSV del cruce siguen sin entregarse; 84 páginas de OCR sin firma en 5 documentos; 34 asignaciones frágiles de tema sin validar; 22 piezas en borrador. Dependencias: disponibilidad del equipo de convivencia. Criterio de éxito sugerido: primer `ocr_revisado` cerrado con firma y primera pieza publicada.

**P7 — Deuda de instrumental heredada del v10.**
Tipo: deuda técnica. Cuatro huecos de autorización que produjeron residuos: las dos expresiones regulares fuera de `10_utils/10_configuracion.R`; `CLAUDE.md` §10.6 sin actualizar; el laboratorio del v9 y los instrumentos del v10 sin versionar; y la enmienda de §3 que consta solo en el log. Criterio de éxito sugerido: los cuatro cerrados en un encargo que los incluya explícitamente en su tabla.

**P8 — La huella de caché del paso 30 no incluye la versión del código.**
Tipo: deuda técnica. Impacto: cualquier arreglo futuro del extractor es un no-op silencioso hasta que alguien invalide la caché a mano. Criterio de éxito sugerido: un cambio en el extractor provoca reprocesamiento sin intervención.

**P9 — 16 puntos abiertos del encargo v9.**
Tipo: documentación. Cinco exigen decisión del titular o de paquete, uno es la afirmación falsa e inmutable en el mensaje del primer commit del v9, y diez son residuos de cuentas que el documento altera al mencionarse.

**P10 — Residuos no medidos del diseño del motor.**
Tipo: documentación. Precio de la API (dominios de la lista de autorizaciones), bytes reales del índice vectorial (no existe ni un vector), latencia real en el navegador, ganancia del reordenamiento, cupo de usuarios del control de acceso gratuito, y el lenguaje real de las consultas del equipo.

### 11.2 Evaluación de deuda técnica

- **Zona frágil 1:** la huella de caché del paso 30 (P8). Viola el principio de que un pipeline corre de cero sin intervención manual: hoy corre de cero, pero no reacciona a un cambio de código.
- **Zona frágil 2:** las expresiones regulares fuera de su fuente canónica (P7). Viola la centralización de constantes de la política §5.4.
- **Zona frágil 3:** los instrumentos de medición viven fuera del repositorio, transcritos en anexos. Reproducible sí, ejecutable no sin copiar y pegar.
- **Oportunidad:** el conjunto de diez consultas con anclas verificadas convierte cualquier cambio futuro del buscador en algo demostrable. Versionarlo es barato y multiplica su valor.

### 11.3 Auditoría de cierre (política 5.6, preguntas «Cierre»)

| # | Pregunta | Respuesta |
|---|---|---|
| 2 | ¿El pipeline corre de cero sin intervención manual? | **Parcialmente.** Corre de cero, pero un cambio en el extractor no invalida la caché del paso 30 y exige apartar un archivo a mano. Se agrega como pendiente P8. |
| 5 | ¿Cada transformación crítica tiene check de validación? | **Sí.** La limpieza del preámbulo se probó contra los 25 textos reales con siete controles antes de aplicarse, y la regresión de anclas corrió tras cada una de las tres regeneraciones. |
| 6 | ¿Los outputs son reproducibles e idempotentes? | **Sí.** Control de idempotencia previo con los 47 HTML idénticos byte a byte y los 28 JSON versionados idénticos; único artefacto que cambia por corrida es el índice de Pagefind, que no está versionado. |
| 7 | ¿Decisiones metodológicas como constantes nombradas? | **Parcialmente.** Las cuatro constantes nuevas están nombradas, pero dos viven fuera de su fuente canónica. Se agrega como pendiente P7. |
| 8 | ¿Nombres sin tildes, ñ ni espacios? | **Sí**, en todos los archivos creados esta sesión. |
| 9 | ¿La guarda `asegurar_locale_utf8()` sigue instalada, idéntica a la plantilla, y se la vio fallar? | **No verificado en esta sesión.** Ninguna tarea la tocó y ninguna la ejerció a propósito. Se agrega a la compuerta de dudas (D8). |

### 11.4 Salida de la compuerta de dudas

Ocho dudas registradas; ninguna cumple el criterio estrecho para cerrarse en sesión (ninguna implica una operación irreversible, una cifra publicada hacia fuera del equipo, ni un ciclo de re-trabajo mayor que la propia verificación).

| # | `supuesto` | `predicado` | `medicion` |
|---|---|---|---|
| D1 | El conjunto de diez consultas representa el lenguaje real del equipo | Al menos 6 de 10 consultas reales del equipo coinciden en formulación con las construidas | Recoger 20 consultas reales tras entregar la pauta y cruzarlas contra las diez |
| D2 | La corrección de sub-resultados no degradó consultas fuera del conjunto de diez | En una muestra de 30 consultas nuevas, ninguna empeora su posición respecto del bundle anterior | Correr el instrumento con las 30 contra ambas versiones de `busqueda.html` |
| D3 | Las correcciones de legibilidad mejoran la lectura en un teléfono real | A 390 px físicos no hay desborde horizontal ni texto cortado | Abrir el sitio en un teléfono; el navegador headless tiene mínimo 500 px y nunca se probó bajo ese ancho |
| D4 | El archivo de autorización del hook cubre solo lo que debe | Ninguna ruta de datos fuera de `40_salidas/datos/` queda autorizada | Correr el mecanismo del hook sobre una lista de diez rutas señuelo |
| D5 | La especificación enviada a los revisores externos es fiel a los cinco documentos de alcance | Ninguna cifra de la especificación difiere de la del documento fuente | Cruzar las cifras de la especificación contra los cinco documentos del v9 |
| D6 | Los defectos corregidos cubren lo que el titular llamó «página ilegible» | El titular, ante el sitio actual, no vuelve a reportar el mismo problema | Mostrarle el sitio y preguntar; la captura pedida nunca llegó |
| D7 | La expansión de sinónimos resolvería las 7 consultas perdidas | Al menos 5 de las 7 devuelven la página correcta al expandir con el vocabulario del v9 | Correr las 7 con expansión sobre el índice actual, sin publicar nada |
| D8 | La guarda de locale sigue instalada e idéntica a la plantilla | La guarda existe, coincide byte a byte con `herramientas_dev/plantillas/10_locale.R` y falla al romperla a propósito | `diff` contra la plantilla y ejercicio deliberado de la falla |

### 11.5 Auditoría de cifras

Subsección **omitida por gatillo no verificado**: `50_documentacion/andamios/logs/auditorias_log.md` no aparece en el árbol conocido y no se comprobó su existencia en esta sesión. Si existe, la subsección es obligatoria en el próximo traspaso. Verificar con: `ls 50_documentacion/andamios/logs/auditorias_log.md`.

### 11.6 Ruta sugerida para la sesión 4

1. **Prioridad 1: integrar los dos informes de revisión externa** (rol A y rol B), con decisión explícita de adoptar o rechazar por hallazgo, como se hizo con el diseño externo del v9. Criterio de éxito: cada hallazgo bloqueante y mayor con veredicto y razón.
2. **Prioridad 2: encargo v11 con P2 y P1**, en ese orden (índice lateral primero, porque es un bug de producto con corrección acotada; expansión de sinónimos después, informada por el rol A), más el cierre de los cuatro huecos de P7. Criterio de éxito: índice lateral poblado, al menos 6 de 10 en el buscador, y ningún residuo de autorización nuevo.
3. **Prioridad 3: saneamiento del corpus** (P3 y P4), que exige delegación registrada de escritura en `20_insumos/`.

**Conviene diferir:** la construcción de la capa semántica (su prerrequisito es que la vía léxica agote su margen, y hoy no lo ha hecho), la capa de orientación en vivo (depende de que exista al menos una pieza firmada), y el módulo de análisis de reglamentos (su prerrequisito declarado sigue sin cumplirse).

## 12. Instrucciones específicas para la próxima sesión

- ⚠️ NO fundar un encargo en una cifra heredada de un traspaso o de un encargo anterior sin recontarla en el turno que la escribe. Ocurrió en esta sesión y costó una premisa falsa en el encargo v10.
- ⚠️ NO lanzar más de dos agentes simultáneos. Siete cortes por límite de sesión en cuatro días, dos de ellos con pérdida total.
- ⚠️ NO escribir en `20_insumos/` sin delegación explícita del titular registrada con alcance de archivo y cambio enumerados. Esto incluye el glosario, las piezas en borrador y los metadatos curados.
- ⚠️ NO editar a mano `40_salidas/` y NO correr `00_ocr_documentos.R` con ninguna bandera.
- ✅ ANTES de emitir un encargo, cruzar la tabla de autorizaciones contra cada verificación que el encargo exige, par a par, incluidas las redirecciones de un salto y los archivos que el propio encargo manda actualizar (`CLAUDE.md`, `10_utils/`, el laboratorio, el propio encargo).
- ✅ ANTES de nombrar un defecto de estilo, verificar que la regla se aplica en alguna página. Dos de los seis del v10 apuntaban a código muerto.
- ✅ ANTES de dar por aplicado un cambio en un paso con caché, contar cuántos documentos se reprocesaron. Cero reprocesados es un no-op silencioso que igual pasa CI.
- ✅ ANTES de reportar cualquier cifra o cero, recuento programático del turno y control positivo **adversarial** contra el instrumento.
- ✅ ANTES de tocar el generador de páginas, tener a mano la prueba de regresión de anclas (806 segmentos, 848 destinos) y la cifra de las diez consultas: ambas son bloqueantes.
- 🔒 Cita textual, trazabilidad por insignia, solo derecho chileno, anclas públicas estables, reproducibilidad de `40_salidas/`, y firma humana sobre todo lo interpretativo. Las relaciones se derivan de metadatos y ningún modelo las infiere.

## 13. Fragmentos de código de referencia

Sin patrones nuevos de R que ameriten transcripción: el trabajo de la sesión fue de diseño, de interfaz y de limpieza de texto. El patrón relevante que sí conviene recordar es de método y no de código, y está en §6: antes de dar por aplicado un cambio en un paso con caché, contar los documentos reprocesados. Los patrones estables del proyecto viven en `CLAUDE.md`.

## 14. Reapertura

Sesión CONTINUATION de `slep_normativa_convivencia`. El protocolo (`POLITICA_PROYECTO.md` y `SETTINGS_Y_PROMPTS_OPERACIONALES.md`) vive en la knowledge base y se lee desde ahí. Adjunto `traspaso_cierre_v03.md` y los dos informes de revisión externa del motor de búsqueda. ▎ Estado: sitio publicado y estable con 25 normas, 682 artículos y 806 segmentos con ancla; buscador en 3 de 10 consultas de evaluación (línea base 1 de 10); texto extraído limpio de la cabecera del sitio de origen en las 25 normas; hoja de estilos con su primer punto de corte responsivo; 22 piezas en borrador y 0 publicadas; vía A sin avance desde la sesión 1. ▎ La sesión 3 fue íntegramente vía B: un encargo de alcance de cinco agentes que diseñó el motor de búsqueda en tres capas y produjo nueve documentos con seis decisiones medidas, y un encargo de correcciones que sí cambió el producto y refutó la premisa del anterior. ▎ Foco propuesto: integrar los dos informes de revisión externa con decisión explícita de adoptar o rechazar por hallazgo, y de ahí emitir el encargo v11 con el índice lateral vacío de las páginas de norma y la expansión de sinónimos en la consulta, más el cierre de los cuatro huecos de autorización que el v10 dejó. ▎ La compuerta de dudas del traspaso trae 8 verificaciones medibles pendientes, ninguna bloqueante. ▎ En ninguna vía se cierran estados `ocr_revisado`, se aprueban temas ni se publican piezas sin firma humana; toda escritura en `20_insumos/` exige delegación registrada.

**Documentos para la sesión 4:**

1. *Protocolo en knowledge base (no se adjuntan; verificar que estén al día):* `POLITICA_PROYECTO.md`, `SETTINGS_Y_PROMPTS_OPERACIONALES.md`.
2. *Opcionales según el foco:* `CLAUDE.md` (habrá encargos de Claude Code).
3. *Específicos, sí se adjuntan:* `traspaso_cierre_v03.md`; los dos informes de revisión externa del motor; `20260908_especificacion_motor_busqueda_v1.md` si los informes citan sus secciones por número.

**Nota final:** si algún archivo listado cambió entre sesiones, adjuntar la versión más actualizada al abrir y avisarlo en el mensaje de apertura.

## 15. Errores del asistente

| # | `momento` | `disparador` | `que_paso` | `regla_violada` | `causa_raiz` | `salvaguarda_presente` | `patron` | `gatillo_observable` | `intentos_previos` | `costo` |
|---|---|---|---|---|---|---|---|---|---|---|
| E1 | Apertura, encargo del candado | asistente lo señaló espontáneamente | El mensaje de commit prescrito fue `chore(estado): abrir sesion 3` en vez del canónico `chore(estado): abre sesion vNN en <maquina>` | SETTINGS §2.1bis, formato del commit del candado | Se redactó el encargo sin transcribir la línea de formato del documento, apoyándose en el sentido y no en la letra | SETTINGS | PAT-01, sobre formato canónico | `afirmar-sin-leer`: se escribió un formato de commit sin abrir la sección que lo fija | 0 | ninguno (commit ya publicado, no se reescribe) |
| E2 | Emisión del encargo v9 | usuario lo señaló sin nombrarlo error | La lista de dominios autorizados omitía los destinos de redirección, dejando a A4 sin poder verificar precios de la API | SETTINGS §1.2.6, cruzar autorizaciones contra verificaciones par a par | Se listaron los dominios de origen sin comprobar a dónde resuelven; el traspaso v02 ya registraba este mismo error de la sesión 2 | SETTINGS y traspaso v02 | PAT-07, restricción no propagada al diseño | `encargos-premisas`: la verificación exigida no tenía dominio autorizado que la sostuviera | 0 | una tabla de costos rotulada como provisional, residuo abierto |
| E3 | Emisión del encargo v9 | asistente lo señaló espontáneamente | Se autorizaron cinco agentes simultáneos contra un límite de sesión, y siete cortes en cuatro días produjeron dos pérdidas totales | Instrucción explícita del propio encargo v9 sobre commit por fase, incompatible con el paralelismo elegido | Se optimizó tiempo de reloj sin modelar el modo de falla del límite de cuota | ninguno previo (regla nueva) | PAT-13, precondición que mide un proxy y no el riesgo | `comando-entorno`: el límite de sesión era observable antes de lanzar | 0 | cuatro jornadas de reloj, dos lanzamientos completos perdidos |
| E4 | Emisión del encargo v10 | usuario lo recibió en el reporte del ejecutor | El §0 del encargo afirmó «0 de 10» y «la causa no es el índice», ambas falsas: la línea base es 1 de 10 y el índice falla en 7 de 10 | userPreferences, marcador de fuente: toda cifra comunicada exige recuento programático del mismo turno | La cifra venía del v9 y se trató como dato consolidado en vez de como hipótesis heredada | userPreferences y SETTINGS | PAT-01, sobre cifra heredada | `cifras-datos`: se publicó una cifra sin recuento del turno que la escribe | 0 | premisa falsa en un encargo publicado y dos afirmaciones erróneas al titular |
| E5 | Emisión del encargo v10 | asistente lo señaló espontáneamente | La tabla de autorizaciones omitió cuatro rutas que el propio encargo obliga a tocar (`10_utils/`, `CLAUDE.md`, el laboratorio y el archivo del encargo) | SETTINGS §1.2.6, cruzar autorizaciones contra verificaciones par a par | Se construyó la tabla desde los archivos que el trabajo cambia y no desde los que el contrato del proyecto obliga a mantener | SETTINGS y CLAUDE.md | PAT-07, restricción no propagada al diseño | `encargos-premisas`: cuatro obligaciones sin ruta autorizada que las sostenga | 1 (el mismo hueco ya había aparecido en el v9 con los dominios) | cuatro residuos declarados y una detención del ejecutor a mitad de push |
| E6 | Emisión del encargo v9, prompt de A3 | usuario lo recibió en el log | El prompt incluía un ejemplo de RUT ficticio, que el hook rechazó al pushear | POLITICA §6.1 y hook de gobernanza de datos | Se redactó un caso adversarial con el patrón literal que el hook detecta, en vez de describirlo | POLITICA | PAT-07, restricción no propagada al diseño | `restriccion-no-propagada`: el patrón prohibido se escribió dentro del propio encargo | 0 | un rechazo de push y una reescritura del prompt |
| E7 | Diagnóstico de legibilidad | asistente lo señaló espontáneamente | Dos de los seis defectos nombrados apuntaban a reglas CSS sin un solo uso en las 47 páginas | userPreferences, marcador de fuente: el contenido de un archivo no leído es hipótesis | Se leyó la hoja de estilos y no se cruzó contra el HTML publicado antes de afirmar que el defecto se manifestaba | userPreferences | PAT-01, sobre afirmar sin fuente primaria | `afirmar-sin-leer`: se afirmó un efecto visible sin verificarlo contra el sitio | 0 | dos defectos falsos en un encargo, corregidos por el ejecutor |
| E8 | Acuse de apertura | asistente lo señaló espontáneamente al cerrar | Se citó `SETTINGS v34` como versión vigente sin transcribir su línea de encabezado; la vigente es `> **Versión 37.**` | SETTINGS §2.1, cita de versión de documento normativo por transcripción y no por número suelto | Se usó el número que traía el traspaso anterior en vez de transcribir el encabezado leído en el turno | SETTINGS | PAT-01, sobre versión de documento normativo | `afirmar-sin-leer`: número de versión suelto, indistinguible de uno recordado | 0 | una afirmación falsa en el acuse de apertura, corregida en este traspaso |

### Registro de fricciones

- friccion: expectativas altas apuntadas a producto visible cuando el encargo v9 era de alcance → se explicitó la naturaleza del entregable antes de emitir el v10 y se reordenó la prioridad hacia correcciones visibles.
- friccion: la captura de pantalla se pidió dos veces y nunca llegó, y el bloque de legibilidad avanzó sin ella → se dejó de pedirla y se acotó el bloque a defectos verificables desde la fuente y desde la medición, declarando el límite.

