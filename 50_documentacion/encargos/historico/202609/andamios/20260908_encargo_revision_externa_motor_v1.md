# Encargo de revisión externa — motor de búsqueda de normativa de convivencia educativa

> **Destino:** `50_documentacion/andamios/20260908_encargo_revision_externa_motor_v1.md`
> **Para:** dos asistentes externos, trabajando por separado.
> **Insumo único:** `20260908_especificacion_motor_busqueda_v1.md`, que se adjunta completo.
> **Producto esperado:** un informe de mejoras por revisor, en el formato exacto de la sección 4. El formato no es una sugerencia: informes fuera de formato no se integran.

---

## 1. Qué se te pide

Vas a revisar el diseño de un motor de búsqueda para una biblioteca de normativa chilena de convivencia educativa. El diseño está especificado pero **no construido**: estás a tiempo de cambiarlo, y ese es el punto de pedirte esto.

Se te pide encontrar lo que está mal, lo que falta y lo que sobra. No se te pide validar el diseño ni resumirlo. Un informe que solo confirma lo que ya está escrito no aporta nada y así será tratado.

---

## 2. Asignación de rol

**Ejecuta solo el rol que se te asignó.** Los dos revisores trabajan sobre el mismo documento con mandatos distintos y no deben verse entre sí.

### Rol A — Revisión técnica de arquitectura y recuperación

Tu pregunta es **si esto funciona y qué se rompe**.

- La unidad de recuperación, la fragmentación y sus umbrales.
- La estrategia de dos vías, su fusión y su reordenamiento: parámetros, orden de operaciones, qué pasa cuando una vía falla.
- El presupuesto de peso y latencia de servir índices estáticos a un navegador.
- La cuantización del índice vectorial y su efecto sobre la calidad de recuperación.
- La incorporación incremental de documentos nuevos: qué se invalida, qué se recalcula, dónde está el costo escondido.
- La arquitectura de alojamiento y el papel del componente intermedio.
- La suficiencia del arnés de verificación de citas.
- El diseño de la evaluación: ¿diez consultas bastan para decidir algo?, ¿qué métrica falta?

### Rol B — Revisión adversarial de utilidad y modos de falla

Tu pregunta es **si esto le sirve a alguien y cómo va a fallar en uso real**.

- Qué pasa cuando el motor entrega el resultado equivocado con aire de certeza.
- Qué pasa cuando la persona que consulta no sabe cómo se llama lo que busca.
- Qué pasa cuando el equipo empieza a tratar lo no validado como si estuviera validado.
- Si la separación en cuatro niveles sobrevive al uso real, incluido copiar y pegar la respuesta fuera del sitio.
- Si la capa de orientación firmada es sostenible cuando hoy hay cero piezas validadas.
- Qué parte del diseño es sobreingeniería para 25 normas y un equipo pequeño, con nombre y apellido.
- Qué le falta para que un equipo no técnico lo adopte, más allá de que funcione.
- Qué problema del usuario real este diseño no resuelve y nadie ha nombrado.

---

## 3. Restricciones que gobiernan tus propuestas

Una propuesta que viole cualquiera de estas se descarta sin discusión, por buena que sea. Están en la sección 2 del documento y se repiten aquí porque son la causa más común de devoluciones inservibles.

- **Todo resultado se rastrea a un segmento con ancla estable, o va rotulado como no normativo.**
- **Nada interpretativo se publica sin firma humana con nombre y fecha.**
- **Las relaciones entre normas se derivan de metadatos; ningún modelo las infiere, propone ni completa.**
- **El texto sin firma humana no es evidencia citable.**
- **La capa de curaduría es de escritura humana exclusiva; ningún proceso automático escribe en ella.**
- **El corpus es solo derecho chileno publicado.**

Además:

- **No propongas construir de cero lo que ya existe.** El pipeline de ingesta, el OCR, la segmentación por artículo, el grafo de relaciones y el sitio ya están hechos y probados.
- **No propongas clasificación automática del corpus por modelo.** Colisiona con la capa de curaduría humana.
- **Más grande no es mejor.** El corpus tiene 806 unidades de recuperación. Una propuesta que agregue servicios, bases de datos o entrenamiento de modelos debe justificar el umbral a partir del cual se paga sola.
- **No escribas código.** Se te pide juicio, no implementación. Un fragmento de tres líneas para ilustrar un punto es aceptable; un módulo no.
- **Distingue lo que sabes de lo que supones.** Cada hallazgo lleva su nivel de confianza y no se penaliza declarar baja.

---

## 4. Formato de devolución (obligatorio)

### 4.1 Un bloque por hallazgo

Usa exactamente estos campos, en este orden, con estos nombres. Un bloque por hallazgo, sin prosa entre bloques.

```
ID: [A o B]-01
SECCION: §5.2 (la sección del documento que atacas)
TIPO: defecto | riesgo | alternativa | omision | sobreingenieria
SEVERIDAD: bloqueante | mayor | menor
AFIRMACION: una sola frase, concreta y falsable
FUNDAMENTO: por qué lo sostienes, en tres líneas o menos
CAMBIO: qué hacer, en una frase accionable
PRUEBA: la medición o el experimento que zanjaría si tienes razón
CONFIANZA: alta | media | baja
```

Reglas de los campos:

- **AFIRMACION** debe poder ser falsa. "La fragmentación podría mejorarse" no sirve. "La ventana de 400 tokens parte 27 de los 227 segmentos largos en mitad de un inciso" sí sirve.
- **CAMBIO** debe ser una acción, no un tema. "Revisar la estrategia de fusión" no sirve. "Bajar K de 30 a 15 por vía y medir el efecto en las diez consultas" sí sirve.
- **PRUEBA** es obligatoria. Si no se te ocurre cómo se probaría tu hallazgo, la confianza es baja y dilo.
- **SEVERIDAD** significa: bloqueante impide construir la capa; mayor cambia una decisión de diseño; menor mejora sin cambiar nada de fondo.

### 4.2 Tabla resumen

Al final de todos los bloques, una tabla con una fila por hallazgo:

| ID | SECCION | TIPO | SEVERIDAD | AFIRMACION (recortada) | CONFIANZA |

### 4.3 Respuestas a las seis preguntas abiertas

Responde una por una las seis preguntas de la sección 10 del documento. Una respuesta de tres a cinco líneas cada una, con una posición explícita. "Depende" solo vale si dices de qué depende y cuál sería el umbral.

### 4.4 Qué NO cambiarías

Enumera **al menos tres decisiones del diseño que consideras correctas y que defenderías**, con su razón en una línea. Esta sección es obligatoria: un revisor que solo propone cambios es tan poco útil como uno que solo aprueba, y esta lista es la que permite distinguir entre ambos.

### 4.5 Lo que no pudiste evaluar

Enumera lo que el documento no te permitió juzgar y qué habrías necesitado. Sé específico: "no vi el código" no sirve; "sin la distribución de largos por tipo de documento no puedo opinar sobre la ventana" sí.

---

## 5. Techo de esfuerzo

- Entre 12 y 25 hallazgos. Menos de 12 sugiere lectura superficial; más de 25 sugiere que estás contando erratas.
- Prioriza profundidad sobre cantidad: tres hallazgos bloqueantes bien fundados valen más que veinte menores.
- No repitas en el informe lo que el documento ya dice. Si necesitas citarlo, cita la sección y sigue.

---

## 6. Advertencia sobre el sesgo que se busca evitar

Este diseño ya pasó por un panel adversarial interno que encontró once ataques, de los cuales tres obligaron a cambiarlo. La sección 9 del documento declara sus debilidades conocidas y sus residuos no medidos **a propósito**, para que no gastes esfuerzo redescubriéndolos.

Lo que se busca de ti es lo que un revisor interno no puede ver: los supuestos que el equipo ya no cuestiona porque los lleva meses dando por buenos. Si encuentras uno, ese es el hallazgo más valioso que puedes entregar, aunque contradiga la sección 2.

En ese caso, dilo igual: marca el TIPO como `defecto`, la SEVERIDAD como `bloqueante`, y explica en FUNDAMENTO por qué el invariante mismo es el problema. Se evaluará. Lo que no se acepta es violar un invariante sin nombrarlo.
