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
| Refinamientos menores no atribuibles | — | 0 | — | — |
| **Total** | 1 | 17 | | |

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

## Delta del backlog

| Versión | Entradas nuevas | Taxonomía | Lectura |
|---|---|---|---|
| v01 | 17 (tramo 1→17) | taxonomía inicial de 8 categorías propuesta en esta sesión | sesión fundacional cargada hacia infraestructura y derivador; el trabajo migra ahora del pipeline a la validación humana (OCR, temas, borradores), que es el cuello declarado de la fase siguiente. |
