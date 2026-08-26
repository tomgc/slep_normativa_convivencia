# Formato — cruce entre documentos de referencia e instrumentos de gestión

**Propósito:** insumo fundante del futuro módulo de análisis de reglamentos de establecimientos. Antes de que la máquina pueda comparar un reglamento contra la normativa, una persona debe declarar QUÉ documento de referencia orienta QUÉ instrumento de gestión y con qué fuerza. Este archivo define ese formato; el equipo lo completa.

## Definiciones

- **Documento de referencia:** cualquiera de las 25 normas del corpus (leyes, decretos, circulares, resoluciones, dictámenes) y las que se incorporen después.
- **Instrumento de gestión:** documento propio de un establecimiento que la normativa regula u orienta. Vocabulario controlado inicial (ampliable por el equipo, avisando para mantener la consistencia):
  - `reglamento_interno`
  - `protocolo` (especificar cuál en la columna `materia`, p. ej. protocolo de vulneración de derechos, de maltrato escolar, de identidad de género)
  - `plan_gestion_convivencia`
  - `pei` (Proyecto Educativo Institucional)
  - `otro` (especificar en `materia`)
  - `ninguno` (el documento no orienta ningún instrumento; también es información)

## El archivo a completar

`cruce_referencia_instrumentos.csv` — separado por punto y coma (`;`), codificación UTF-8, se abre directo en Excel. La máquina lo entregará **prellenado con una fila por cada una de las 25 normas** (columnas 1 y 2 ya escritas); el equipo completa el resto.

| Columna | Quién la llena | Contenido |
|---|---|---|
| `slug` | máquina | Identificador técnico de la norma. **No tocar.** |
| `documento_referencia` | máquina | Nombre legible de la norma. No tocar. |
| `instrumento_objetivo` | equipo | Uno del vocabulario controlado. |
| `tipo_relacion` | equipo | `exige_contenido` (el instrumento DEBE incluir algo por mandato de esta norma) / `orienta` (recomienda o da criterios) / `fiscaliza` (es la vara con que se revisa o sanciona) / `define_conceptos` (aporta definiciones que el instrumento usa). |
| `materia` | equipo | En pocas palabras, qué parte o contenido del instrumento toca (p. ej. "medidas disciplinarias", "protocolo de embarazo adolescente"). |
| `prioridad` | equipo | `alta` / `media` / `baja` para el análisis del módulo: `alta` = lo primero que el módulo debe revisar. |
| `observaciones` | equipo | Libre. Matices, dudas, referencias cruzadas. |

## Reglas de llenado

1. **Una fila = una relación.** Si una norma orienta a más de un instrumento (lo normal en las circulares), **duplicar la fila** y llenar cada una por separado. No importa cuántas filas resulten.
2. Si no saben dónde calza una norma, llenar `instrumento_objetivo` con `ninguno` y anotar la duda en `observaciones`: una duda declarada vale más que una celda en blanco.
3. No usar tildes ni mayúsculas en las columnas de vocabulario controlado (`instrumento_objetivo`, `tipo_relacion`, `prioridad`); el resto de las columnas admite redacción libre.
4. Guardar como CSV manteniendo el punto y coma (Excel en español lo hace por defecto con "Guardar como CSV").

## Circuito

1. La máquina genera el CSV prellenado y el Área de Monitoreo se lo entrega al equipo.
2. El equipo lo completa (puede ser por partes: las filas con `prioridad: alta` primero).
3. El archivo completo vuelve al Área de Monitoreo, que lo incorpora como insumo curado (capa de escritura humana, con registro de quién lo llenó y cuándo).
4. Recién entonces se diseña el módulo de análisis: la pauta de comparación del módulo sale de este cruce, no de supuestos de la máquina.
