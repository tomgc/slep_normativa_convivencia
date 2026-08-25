# Decisión: especificación funcional del sitio (entrevista 2026-08-25)

> Origen: entrevista de funcionalidad al equipo, sesión NEW PROJECT
> 2026-08-25. Este documento fija el alcance funcional y los invariantes
> de contenido. Complementa (no reemplaza) la ruta técnica aprobada:
> Quarto + Pagefind en GitHub Pages, pipeline R.

---

## 1. Invariantes de contenido (🔒, regla canónica del equipo)

1. 🔒 **Trazabilidad de fuente en toda respuesta.** Cada resultado,
   ficha, FAQ o recomendación declara visiblemente de qué tipo de fuente
   proviene: `ley` / `decreto` / `circular` / `dictamen` / `resolución`
   (fuentes normativas), `orientación ministerial` (guías Mineduc/
   Superintendencia sin rango normativo), `evidencia científica` (papers,
   informes). La distinción se materializa como badge visual + campo
   `tipo_fuente` en los datos. Nunca se mezclan fuentes sin etiqueta.
2. 🔒 **Citación textual de lo normativo.** El texto legal se muestra
   SIEMPRE literal, extraído del documento oficial, sin paráfrasis ni
   resumen en la capa de respuesta. Todo extracto ofrece "leer en
   contexto": enlace al artículo completo dentro de la norma completa,
   con ancla. Ninguna funcionalidad (búsqueda, FAQ, recomendador,
   síntesis) puede alterar, recortar con elipsis engañosa o reordenar el
   sentido del texto legal.
3. 🔒 **Solo derecho chileno.** Normativa y orientaciones: exclusivamente
   chilenas. La evidencia científica admite nacional e internacional,
   siempre bajo su badge propio y nunca presentada como fundamento
   normativo.
4. 🔒 **Texto interpretativo solo validado.** Fichas resumen, FAQ,
   páginas temáticas y glosario son interpretación institucional: se
   publican únicamente con validación del equipo de convivencia
   registrada (campo `validado_por` + fecha en el front matter de cada
   pieza). Sin validación, la pieza queda en borrador fuera del sitio
   publicado.

**Razón de los cuatro:** un error de cita o de fuente en este dominio
puede derivar en multas, sumarios o destitución de quien lo use. El sitio
optimiza rigurosidad primero, agilidad después.

## 2. Taxonomía de fuentes

| Capa | Contenido | Rango | Tratamiento |
|---|---|---|---|
| Normativa | Leyes, DFL, decretos, circulares, dictámenes, REX | Vinculante (con jerarquías internas) | Cita textual, artículo como unidad |
| Orientaciones | Guías y orientaciones ministeriales | No vinculante | Cita textual o referencia por sección; badge propio |
| Evidencia | Papers e informes nacionales e internacionales | Referencial | Ficha bibliográfica + enlace; badge propio; fase futura |

## 3. Funcionalidades aprobadas

### 3.1 Búsqueda en dos capas
- **Fase 1 (MVP): léxica con facetas.** Pagefind a nivel de artículo;
  filtros por tipo de fuente, tema y año.
- **Fase 2: semántica.** Embeddings por artículo precalculados en el
  pipeline R; similitud calculada en el navegador. Presentación del
  resultado: primero los extractos textuales que responden (invariante
  2), luego los relacionados.

### 3.2 Recomendador de artículos relacionados
Al ver un artículo o un resultado: bloque "Artículos relacionados",
DESPUÉS de la respuesta principal, con explicación breve del porqué de la
relación. Las explicaciones se generan desde metadatos curados (tema
compartido, norma que remite a otra, misma materia regulada), no desde
texto generativo libre: cada relación es un dato del pipeline
(`relaciones.json`), auditable y corregible.

### 3.3 Fichas resumen por norma
Qué regula, a quién aplica, obligaciones clave, vigencia, relación con
otras normas. Texto interpretativo → invariante 4 (validación del equipo
de convivencia obligatoria). La ficha enlaza cada afirmación al artículo
textual que la respalda.

### 3.4 FAQ de casos reales
Sección "Preguntas frecuentes" con casos de uso ("¿se puede revisar una
mochila?"), cada uno respondido con: extracto textual del o los artículos
aplicables + enlace en contexto + badge de fuente. Curaduría manual,
validación del equipo de convivencia (invariante 4).

### 3.5 Páginas temáticas (navegación por categorías)
Sección hermana de la búsqueda: categorías temáticas navegables
(ej. TEA, expulsiones, celulares, identidad de género, violencia escolar,
participación). Cada página temática cruza todo lo que las distintas
fuentes dicen del tema (ej. TEA: ley 21545 + circular 586), organizado
por capa de fuente y con extractos textuales anclados.

### 3.6 Glosario legal
Términos definidos con rigor jurídico chileno (expulsión vs cancelación
de matrícula, debido proceso, medida disciplinaria vs formativa). Cada
definición ancla a la fuente normativa que la sustenta. Validación:
invariante 4.

### 3.7 Incorporación de nuevas normas (automatizada)
Flujo: dejar el PDF (nombre canónico snake_case) en
`20_insumos/normativa/` (u `20_insumos/orientaciones/` según capa) y
correr `00_run_all.R`. El pipeline detecta documentos nuevos o
modificados (hash por archivo contra un manifiesto), procesa solo lo
nuevo, reporta qué incorporó y qué metadatos quedaron pendientes de
curación (tema, relaciones, ficha). El push publica. Nada más manual.

## 4. Fases

| Fase | Contenido | Estado |
|---|---|---|
| 1 (MVP) | Estructura, corpus, búsqueda léxica facetada, páginas por norma, índices | En ejecución (encargo bootstrap) |
| 2 | Páginas temáticas, FAQ inicial, glosario, fichas resumen, recomendador por metadatos, flujo de incorporación con manifiesto | Siguiente |
| 3 | Búsqueda semántica en navegador | Tras validar fase 2 |
| 4 | Capa de evidencia científica (sesión de research aparte para el barrido inicial) | Proyección; NO se aborda aún |

## 5. Audiencia

Fase actual: equipo de convivencia del SLEP (tono técnico-profesional).
Posible ampliación futura a equipos de convivencia de las comunidades
educativas del SLEP: decisión pendiente, afectaría tono de fichas y FAQ.

## 6. Pendientes que esta decisión deja abiertos

- Lista inicial de categorías temáticas (propuesta saldrá del corpus
  procesado; valida el equipo de convivencia).
- Formato del registro de validación (quién firma por el equipo de
  convivencia y dónde queda el registro).
- Sesión de research para la capa de evidencia (fase 4).
