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
| Refinamientos menores no atribuibles | — | 0 | — | — |
| **Total** | 2 | 32 | | |

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

## Delta del backlog

| Versión | Entradas nuevas | Taxonomía | Lectura |
|---|---|---|---|
| v01 | 17 (tramo 1→17) | taxonomía inicial de 8 categorías propuesta en esta sesión | sesión fundacional cargada hacia infraestructura y derivador; el trabajo migra ahora del pipeline a la validación humana (OCR, temas, borradores), que es el cuello declarado de la fase siguiente. |
| v02 | 15 (tramo 18→32) | sin cambios | El movimiento de la sesión fue de construcción a garantía: lo nuevo no es contenido sino evidencia (auditoría, controles calibrados, ensayo en clon, autoprueba en CI) y la frontera máquina/humano quedó operacionalizada con delegaciones registradas en gate. |
