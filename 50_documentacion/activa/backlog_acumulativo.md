# Backlog acumulativo — slep_normativa_convivencia

## Objetivo del proyecto

Biblioteca web pública de normativa chilena de convivencia educativa para
el equipo de convivencia del SLEP Costa Central: un sitio estático (Quarto
+ Pagefind en GitHub Pages, pipeline en R) que indexa leyes, decretos,
circulares, resoluciones y dictámenes a nivel de artículo, con citación
textual verificable, trazabilidad de fuente, navegación temática y capa
interpretativa validada por humanos. Existe desde el 2026-08-25.

## Nota metodológica

Cuenta como "cambio" una solicitud distinguible del equipo (no las
acciones técnicas que la implementan). No cuentan los errores del
asistente corregidos de inmediato; sí cuentan los bugfixes reportados por
el equipo o destapados por auditoría. La clasificación es por intención
primaria. Fuentes del conteo: logs de andamios de cada sesión y los
traspasos.

## Clasificación temática

Taxonomía orgánica propuesta en la sesión 1; los conteos y porcentajes
los mantiene el cierre.

| Categoría | Descripción y ejemplos |
|---|---|
| infraestructura_pipeline | Estructura, orquestador, CI, despliegue (bootstrap, workflow de Pages) |
| corpus_insumos | Incorporación y normalización de normas (renombrado snake_case, dictamen 78) |
| ocr_curaduria | Transcripciones, estados de revisión, metadatos curados (OCR señalizado, años de dictámenes) |
| relaciones_derivador | Remisiones, filtros, grupos de acto, supresiones (filtro de año, grupo_acto) |
| sitio_navegacion | Búsqueda, facetas, páginas temáticas, vigencia (faceta texto, banda de sustitución) |
| contenido_interpretativo | Fichas, FAQ, glosario y su candado de validación |
| gobernanza_docs | Decisiones, especificación funcional, protocolos |
| diseno_visual | Apariencia y usabilidad (brief a Claude Design) |

## Resumen estadístico por sesión

| Sesión | Traspasos generados | N° de cambios | Modelo | Foco |
|---|---|---|---|---|
| 1 | traspaso_cierre_v01.md | 17 | Claude Opus 5 (Claude Code) / Fable 5 (chat) | fundación: corpus, pipeline, sitio |
| 2 | traspaso_cierre_v02.md | 15 | Claude Opus 5 (Claude Code) / Fable 5 (chat) | Sesión íntegra de máquina: siete encargos autónomos, auditoría contra producto, endurecimiento de la compuerta de firma y ensayo general de la vía A; el material de validación humana quedó completo. |
| 3 | traspaso_cierre_v03.md | 10 | Claude Opus 5 (Claude Code) / Fable 5 (chat) | Diseño completo del motor de búsqueda por encargo de alcance, y primeras correcciones que sí cambian el producto publicado. |
| 4 | traspaso_cierre_v04.md | 10 | Claude Opus 5 (Claude Code) / Fable 5 (chat) | Integrar las revisiones externas del motor, emitir y ejecutar el encargo v11 (índice lateral, expansión de consulta, P7, instrumento) y fijar el principio de precedencia que reformula el v12. |
| Refinamientos menores no atribuibles | — | 0 | — | — |
| **Total** | 4 | 52 | | |

## Detalle cronológico

### Sesión 1 (2026-08-25 a 2026-08-26) — fundacional

1. [infraestructura_pipeline] Bootstrap completo: estructura canónica
   Rama A, pipeline de extracción y segmentación por artículo, sitio
   Quarto con Pagefind, CI a GitHub Pages. Sitio publicado.
2. [corpus_insumos] Normalización del corpus inicial: 24 PDFs renombrados
   a nomenclatura canónica con verificación md5 y tabla de equivalencias;
   el presunto duplicado del REX 482 resultó ser resolución + cuerpo.
3. [gobernanza_docs] Especificación funcional desde entrevista al equipo:
   invariantes de contenido (cita textual, trazabilidad de fuente, solo
   derecho chileno, validación de lo interpretativo) y fases 1-4.
4. [diseno_visual] Brief de diseño entregado para Claude Design
   (minimalista, mobile-first, búsqueda protagonista); entregable aún no
   recibido.
5. [ocr_curaduria] OCR de los 4 documentos escaneados (75 páginas, Apple
   Vision) publicado como transcripción señalizada: anclas por página,
   banda, insignia, faceta `texto`, sin anclas de artículo.
6. [ocr_curaduria] Capa de curaduría humana: `metadatos_curados.json` de
   escritura humana exclusiva, con procedencia obligatoria por dato; años
   de los dictámenes 065 (2022), 71 (2024) y 52/77 (2020/2025) curados.
7. [sitio_navegacion] Aviso de vigencia del dictamen 065 (sustituido por
   el 78/2026), primero como banda ad hoc y luego como mecanismo genérico.
8. [ocr_curaduria] Compuerta de `--rehacer`: protege correcciones humanas
   de las transcripciones; `--forzar` por documento con respaldo en
   `_archivo/`.
9. [corpus_insumos] Manifiesto de incorporación por hash: dejar el PDF
   canónico y correr `run_all()` procesa solo lo nuevo o modificado.
10. [corpus_insumos] Dictamen 78/2026 incorporado (25 normas); su texto
    corrobora el año 2022 del 065.
11. [sitio_navegacion] Campo `vigencia` en esquema y sitio: 065
    `sustituido_por` 078 con bandas mutuas y marca en índices.
12. [relaciones_derivador] Recomendador por metadatos: relaciones tipadas
    (sustitución, remisión textual, tema) con explicación por plantilla,
    bloque "relacionados" tras el articulado.
13. [sitio_navegacion] 17 páginas temáticas que cruzan las fuentes por
    tema, agrupadas por capa normativa, con extractos anclados.
14. [contenido_interpretativo] Infraestructura de piezas interpretativas:
    22 borradores (fichas de las 9 leyes, FAQ, glosario) con candado de
    publicación por `validado_por`; 0 publicadas al cierre.
15. [relaciones_derivador] Resolución de dudas de fase 2: 078 declarado
    transcripción por curaduría, filtro de año en remisiones con descartes
    registrados, dictámenes segmentados por numerales (aditivo, 0 anclas
    rotas), glosario con 5 términos "pendiente de fuente".
16. [relaciones_derivador] Indagación pre-cierre (solo lectura) y fixes:
    forma `D.O. dd.mm.aaaa` (caen 74 remisiones falsas dto_453→dto_215),
    tipo `grupo_acto` para el REX 482 (resolución + cuerpo declarados un
    mismo acto), supresión intra-grupo centralizada para todos los tipos.
    Estado final: 550 relaciones, 88 descartes registrados.
17. [gobernanza_docs] Registro de la tabla de 34 asignaciones de tema
    frágiles para validación del equipo, y de los pendientes de validación
    humana (84 páginas OCR, 22 borradores) como bloqueantes de contenido.

### Sesión 2 — 2026-08-27

18. **Adopción de ESTADO.md y candado de sesión.** Archivo conforme a §2.1bis creado en la sesión (commit `70dc7da`), con dos traducciones al enum del estándar declaradas; el candado 0bis quedó operativo para la cartera de dos máquinas.
19. **Encargo v1 de avance de máquina.** Preclasificación programática de los 88 descartes de remisión (67 correctos, 21 homologables), rótulos distintivos del grupo REX 482, pre-revisión asistida del OCR (108 líneas sospechosas con controles positivos) y rastreo de fuentes del glosario (3 de 5); T3 congelada por contradicción interna del encargo.
20. **Restitución de las remisiones al DFL 1.** Causa: promulgación 1996 vs publicación 1997 partía un mismo destino; entrada `anios_alternativos: [1996]` por delegación del titular (`90d58cf`) y regeneración verificada con contador calibrado 21→0; corpus queda en 552 relaciones, 46 remisiones, 67 descartes.
21. **Defecto sistémico de coincidencia parcial erradicado.** `$` sobre estructuras leídas de disco resolvía por prefijo (4 pares medidos); conversión completa a `[[ ]]` en el pipeline (`48d176a`, `851f021`, `01fd28d`, `81179e3`), tras una regresión real atrapada por el chequeo calibrado del encargo.
22. **Hallazgo del slug del DFL 1.** `dfl_1_estatuto_asistentes_educacion` contiene el Estatuto Docente; el de asistentes es la Ley 21.109 (no incorporada); decisión en gate del equipo de convivencia (Bloque 4 de la pauta), con 19 enlaces enrutando hoy a esa URL.
23. **Auditoría contra producto de la sesión (encargo v3).** Re-derivación independiente de toda cifra, hash y estado desde los artefactos: 7 de 8 confirmados, el refutado fue un universal del auditor; hallazgo O5 sobre la compuerta de firma.
24. **Compuerta de firma endurecida en dos rondas.** Ronda 1 (v5): cinco medidas, 17 de 25 veredictos cambiados; ronda 2 (v6): campos obligatorios al validar, firma nombre y apellido con lista negra, colisión de slug aborta, compuerta de anclas, robustez a NBSP y encoding; ninguna de las 22 piezas reales cambió de veredicto.
25. **Coincidencia parcial promovida a error del pipeline con autoprueba en CI.** Patrón derivado en runtime (el mensaje de R está traducido y el runner mezcla idiomas, medido en producción); el paso de autoprueba provoca la coincidencia y exige el fallo en cada despliegue.
26. **Clase B reclasificada por univocidad.** 91 accesos (v3 contaba líneas): 0 muerden, lista de vigilancia de 9; el documento reemplaza a la clasificación v3 como insumo.
27. **Ensayo general de la vía A en clon.** Primera pieza en recorrer borrador→validada→página→índice; compuerta de anclas abortando sobre la FAQ rota real; flujo `ocr_revisado` simulado; el informe incluye la sección "lo que el equipo verá".
28. **E-c corregido: piezas publicadas indexadas en el buscador.** Cuerpo y facetas dentro, Fuentes y firma fuera; control 25→26 en clon con instrumento con prueba de humo; no-op byte a byte en el repo real.
29. **Reproducibilidad probada y acotada.** Build desde clon limpio 27/28 byte a byte + 1 explicado (campo `estado` del manifiesto); versiones de R y Quarto fijadas en el workflow; residuo declarado: el bundle del tema difiere entre plataformas con la misma versión (no lo produce este proyecto).
30. **Material de validación completo para la vía A.** Pauta en lenguaje llano (4 bloques, URL y cifras verificadas), tabla de 34 temas frágiles con enlaces y firma, listado de borradores con rótulo antiguo, formato de cruce referencia↔instrumentos y CSV prellenado con las 25 normas.
31. **README de piezas alineado con la compuerta real.** Tres delegaciones registradas (bloque de exigencias del pipeline, advertencia de mover-no-copiar, ejemplo con ancla que resuelve y coherente con su título).
32. **Nuevo pendiente estratégico: módulo de análisis de reglamentos.** Comparar reglamentos de establecimientos contra la normativa con recomendaciones de mejora; prerrequisitos declarados: vía A avanzada (OCR del grupo REX 482) y cruce completado; todo informe nace con gate `validado_por`.

### Sesión 3 — 2026-09-09

33. **Encargo v9 de alcance del motor de búsqueda.** Cinco agentes
    especializados (vocabulario controlado, recuperación, orientación,
    arquitectura, panel adversarial) más auditoría independiente de doce
    verificadores y síntesis: nueve documentos, dos prototipos en R, un
    esqueleto de Worker y un log de 1 211 líneas, con el sitio sin cambios.
    Seis decisiones medidas quedan firmes, entre ellas que la unidad de
    recuperación son 806 segmentos y no 682 artículos.
34. **Evaluación del diseño conceptual externo aportado por el titular.**
    Adopciones y rechazos explícitos uno por uno: entran búsqueda híbrida,
    reranking, temporalidad, cuatro niveles de fuente y capa experta como
    estructura de datos; se rechazan la ontología de doce relaciones (el
    grafo ya existe con cuatro tipos derivados), la clasificación
    automática del corpus por modelo (colisiona con la curaduría humana) y
    el stack de cinco servicios para 806 unidades.
35. **Requisito de incorporación incremental del corpus.** El motor debe
    integrar normas nuevas por el manifiesto de hash existente, con
    vectorización incremental y no reembebido completo; cada capa declara
    qué se regenera sola y qué queda desactualizado hasta que una persona
    lo escriba.
36. **Juicio del encargo v9 y reorientación de prioridades.** El paquete
    recomendaba construir primero la capa de vocabulario; su propio panel
    adversarial midió que cubre 21 % de los términos y 3 % de las consultas,
    con 42 % sin una palabra en común. La prioridad se movió a lo que el
    encargo destapó sin proponérselo: buscador, legibilidad y saneamiento
    del corpus.
37. **Buscador: sub-resultados por relevancia con ancla visible.** El tope
    de tres estaba escrito en el cuerpo del bundle y no en un parámetro, así
    que se reemplazó el componente por una interfaz propia sobre la API
    pública. De 1 de 10 a 3 de 10 con el conjunto de evaluación; en la
    batería canónica la posición mediana del artículo correcto baja de 2 a 1.
38. **Legibilidad del sitio, acotada a lo confirmado por medición.** Primer
    punto de corte responsivo, subrayado restituido en los enlaces
    temáticos, contraste de 4,45 a 7,76 en los dos pares bajo el umbral,
    versalitas agrandadas y bloque de búsqueda compactado en las 42 páginas
    que no son portada ni índice. Dos de los seis defectos nombrados
    resultaron ser código muerto y se declararon sin tocarse.
39. **Limpieza de la cabecera del sitio de origen en el texto extraído.**
    De 17 normas contaminadas de 25 a 0, corregida en el extractor y no en
    el segmentador para que el texto intermedio quede limpio también.
    Regresión bloqueante en verde y dos remisiones que pasan de apuntar al
    preámbulo a apuntar al artículo que efectivamente citan.
40. **Inventario de pendientes que solo puede resolver una persona.**
    Cuatro puntos accionables sin corregir ninguno: 27 encabezados de
    glosario con la definición pegada al título, dos anclas rotas en piezas
    en borrador, `aviso_vigencia` nulo en las 25 normas, y cuatro erratas de
    nombre más un slug materialmente falso.
41. **Cierre del hueco del hook global de gobernanza de datos.** El hook,
    instalado en la estación después del bootstrap del repositorio,
    rechazaba los JSON que el proyecto versiona por diseño porque su archivo
    de autorización nunca existió. Se declaró `40_salidas/datos/` y nada
    más, con la prueba de señuelos transcrita en el propio archivo.
42. **Especificación técnica del motor y revisión externa en dos roles.**
    Documento autocontenido con sus debilidades y residuos declarados por
    adelantado, y un encargo con esquema estricto de devolución para dos
    revisores con mandatos separados: uno juzga si el diseño funciona, el
    otro si le sirve a alguien y cómo falla en uso.

### Sesión 4 — 2026-09-10

43. Integración de las dos revisiones externas del motor de búsqueda (rol A y rol B): veredicto y razón para los 40 hallazgos, siete convergencias marcadas, respuesta a las seis preguntas de la especificación y cuatro decisiones del titular formuladas con recomendación (D-A a D-D). Archivo `50_documentacion/andamios/20260909_integracion_revision_externa_v1.md`.
44. Emisión del encargo v11 con la plantilla v1.5 (7 tareas, 3 olas, tope de 2 subagentes, 8 invariantes con comando, FASE R y FASE L transcritas). Archivo `50_documentacion/andamios/20260909_encargo_v11_indice_y_expansion_v1.md`.
45. Instrumento de evaluación del buscador y de anclas versionado en `tests/` (conjunto de diez consultas como código R más clase «sin respuesta», runner de Pagefind, medición de posición, MRR, cobertura y recall@K, inventario de anclas). Resuelve la zona frágil 3 y la oportunidad del traspaso v03 §11.2.
46. Índice lateral poblado en las 25 páginas de norma (831 entradas; `dfl_1` con 219), con los 806 ids intactos y el texto visible idéntico. Resuelve P2 del traspaso v03.
47. Expansión de la consulta del buscador con 183 alias del laboratorio del v9 (frase del alias sola, raíz de 6 caracteres, piso R0, 3 variantes y 2 páginas por variante) y diez constantes centralizadas en `10_utils/10_configuracion.R`; buscador de 3 a 8 de 10 por presencia del ancla. Avanza P1 del traspaso v03.
48. Cierre de los cuatro huecos de P7: dos regex del extractor a su fuente canónica con prueba fuerte de no cambio, laboratorio del v9 versionado en sus 43 `.R` y `.md` con lista blanca en `.gitignore`, enmienda del v10 registrada como archivo aparte, `CLAUDE.md` §10.1 y §10.6 al día.
49. Verificaciones D4 (hook con diez señuelos) y D8 (guarda de locale) cerradas por lectura, y D7 medida (1 de 7 con sustitución, 7 de 7 con frase sola); log del encargo con FASE R aprobada con siete advertencias y once dudas con pregunta cerrada.
50. Commit de los dos andamios de la sesión que el ejecutor dejó sin versionar por no estar en su lista de escritura.
51. Principio de diseño fijado por el titular tras probar tres consultas en producción: en un corpus de 25 normas el mejor resultado se conoce y el orden lo dictan reglas explícitas sobre metadatos; con el criterio de posición 1 el buscador resuelve 0 de 10. Bug activo P1 y reformulación del v12 como capa de precedencia determinística.
52. Evaluación del log del v11 con recomendación para cada una de las once dudas del ejecutor y registro de diez errores del asistente, entre ellos la tercera reincidencia del hueco de autorizaciones con reformulación propuesta como chequeo programático.

## Delta del backlog

| Versión | Entradas nuevas | Taxonomía | Lectura |
|---|---|---|---|
| v01 | 17 (tramo 1→17) | taxonomía inicial de 8 categorías propuesta en esta sesión | sesión fundacional cargada hacia infraestructura y derivador; el trabajo migra ahora del pipeline a la validación humana (OCR, temas, borradores), que es el cuello declarado de la fase siguiente. |
| v02 | 15 (tramo 18→32) | sin cambios | El movimiento de la sesión fue de construcción a garantía: lo nuevo no es contenido sino evidencia (auditoría, controles calibrados, ensayo en clon, autoprueba en CI) y la frontera máquina/humano quedó operacionalizada con delegaciones registradas en gate. |
| v03 | 10 (tramo 33→42) | sin cambios; recuento diferido, reparto archivado: 33:sitio_navegacion; 34:sitio_navegacion; 35:infraestructura_pipeline; 36:gobernanza_docs; 37:sitio_navegacion; 38:diseno_visual; 39:corpus_insumos; 40:ocr_curaduria; 41:infraestructura_pipeline; 42:gobernanza_docs | El movimiento de la sesión fue de garantía a producto: la sesión 2 acumuló evidencia sin tocar el sitio, y esta volvió a cambiarlo, con la diferencia de que ahora cada cambio se expresa contra una medición previa. La entrada de `diseno_visual` es la primera desde el brief de la sesión 1 y cierra una categoría que llevaba dos sesiones vacía. `sitio_navegacion` concentra tres entradas porque el diseño y la corrección del buscador son la misma materia vista desde dos distancias. |
| v04 | 10 (tramo 43→52) | sin cambios; recuento diferido, reparto archivado: 43:gobernanza_docs; 44:gobernanza_docs; 45:infraestructura_pipeline; 46:sitio_navegacion; 47:sitio_navegacion; 48:infraestructura_pipeline; 49:infraestructura_pipeline; 50:gobernanza_docs; 51:sitio_navegacion; 52:gobernanza_docs | La sesión reparte entre gobernanza_docs (integración, encargo, evaluación) y el par sitio_navegacion / infraestructura_pipeline que el encargo v11 movió; la entrada 51 es la única de esta sesión que abre trabajo nuevo en vez de cerrarlo. |
