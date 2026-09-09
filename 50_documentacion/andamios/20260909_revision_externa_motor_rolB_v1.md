# Informe de revisión externa, Rol B: utilidad y modos de falla en uso real

> **Destino:** `50_documentacion/andamios/20260909_revision_externa_motor_rolB_v1.md`
> **Encargo:** `50_documentacion/andamios/20260908_encargo_revision_externa_motor_v1.md`, Rol B, formato de §4.
> **Insumo principal:** `20260908_especificacion_motor_busqueda_v1.md`, leída completa.
> **Insumo complementario, declarado:** para no redescubrir los hallazgos H-1 a H-20 del panel interno (encargo §6), se consultó además `20260904_alcance_motor_busqueda_sintesis_v1.md`, §1 a §5. Donde una cifra viene de ahí se indica "(síntesis §x)".
> **Ámbito:** esta revisión no tuvo acceso al repositorio ni al sitio. Toda afirmación sobre comportamiento en uso es una hipótesis con su prueba declarada.

---

## 1. Hallazgos

```
ID: B-01
SECCION: §2, invariante 1 (y §9, "ley general de educación consolidada a 2010")
TIPO: defecto
SEVERIDAD: bloqueante
AFIRMACION: El invariante 1 garantiza trazabilidad a un ancla, no vigencia del texto; hoy el motor puede devolver un artículo de la LGE con su ancla correcta y sin ninguna marca de que el texto es de 2010 y fue reescrito después.
FUNDAMENTO: §9 declara el texto consolidado a 2010 y §5.3 que la vigencia por fecha no es respondible; ninguna regla del diseño hace viajar esa carencia hasta el resultado. Un texto rastreable y desactualizado, citado en un oficio a un apoderado, es el caso más puro de "resultado equivocado con aire de certeza", y un motor mejor solo lo hace más alcanzable.
CAMBIO: Incorporar al invariante 1 la fecha de versión del texto, materializada como un campo curado por norma (`texto_consolidado_al`, 25 valores, escritura humana con fuente) que se imprime en texto plano en todo resultado de esa norma, y bloquear la etiqueta "vigente" para toda norma sin ese campo.
PRUEBA: Buscar cualquier artículo de la LGE reescrito por las dos leyes posteriores que §9 menciona; si el resultado no contiene, dentro del texto copiable, una fecha de versión o una advertencia, el hallazgo se confirma.
CONFIANZA: alta
```

```
ID: B-02
SECCION: §9, "el lenguaje real de las consultas del equipo", y §4.4
TIPO: omision
SEVERIDAD: mayor
AFIRMACION: El diseño no contiene ningún instrumento para capturar consultas reales, de modo que la tabla de alias del paso 2 se va a curar desde la imaginación y su utilidad no podrá medirse.
FUNDAMENTO: Los tres conjuntos de prueba son construidos y el diseño lo declara; la brecha de 42 % (§4.4) es la brecha entre el corpus y un lenguaje que también fue construido. La capa que más rendimiento promete (alias curados) depende por completo de conocer qué escribe el equipo, y esa cifra sigue sin dueño.
CAMBIO: Antes de curar un alias, abrir un canal de captura sin servidor (un enlace "¿No encontraste lo que buscabas? Cuéntanos qué buscabas" hacia un formulario, más una lista compartida donde el equipo anote qué buscó cada vez que abre el sitio) durante cuatro semanas, y hacer de esa lista la fuente obligatoria de cada alias.
PRUEBA: Tras cuatro semanas, comparar los 30 términos más frecuentes de las consultas reales contra las 38 consultas construidas (síntesis §1.1); si menos de la mitad coincide, los conjuntos de prueba no eran el lenguaje del equipo.
CONFIANZA: alta
```

```
ID: B-03
SECCION: §5.2 (fusión por rango recíproco, 30 candidatos por vía)
TIPO: defecto
SEVERIDAD: mayor
AFIRMACION: La fusión por rango siempre produce una lista ordenada, de modo que el motor no puede decir "no está en el corpus" y responderá la consulta cuya respuesta correcta es esa ausencia con hasta 30 resultados de apariencia pertinente.
FUNDAMENTO: RRF combina posiciones, no evidencia; no existe en el diseño un umbral de "sin resultado" ni un estado de interfaz para ello. El conjunto de evaluación incorporó la consulta "esa norma no está en el corpus" (síntesis §4.2, H-5), pero el diseño no dice cómo se responde en pantalla.
CAMBIO: Definir un estado "sin resultado firme" (ninguna coincidencia léxica sobre ningún token de contenido) que reemplace la lista por un mensaje y por la lista curada de normas citadas por el corpus pero no incluidas en él.
PRUEBA: Pasar por la fusión la consulta de H-5 y una consulta ajena al dominio ("licencia de conducir"); si ambas devuelven una lista completa sin advertencia, el hallazgo se confirma.
CONFIANZA: alta
```

```
ID: B-04
SECCION: §9, "el procedimiento de expulsión no está en el corpus"
TIPO: omision
SEVERIDAD: mayor
AFIRMACION: La situación más frecuente de un equipo de convivencia (expulsión o cancelación de matrícula) tiene 39 menciones y ningún texto que la regule en el corpus, y el motor entregará las menciones como si fueran la respuesta.
FUNDAMENTO: §9 lo declara como problema del corpus que ninguna capa repara; desde el usuario es el modo de falla más predecible y más costoso, porque la persona citará el artículo que menciona el procedimiento y no el que lo regula. Un vacío conocido y frecuente admite una respuesta curada aunque el texto no esté.
CAMBIO: Crear en la capa 1 un tipo de entrada curada "no está en esta biblioteca: está en <norma>, <artículo>" para los temas ausentes más frecuentes, escrita a mano con fuente, que aparezca antes que cualquier resultado de mención.
PRUEBA: Escribir "expulsión" en el sitio actual y clasificar cada resultado como "regula" o "menciona"; luego pedir a dos integrantes del equipo que elijan cuál citarían en un oficio. Si eligen una mención, el hallazgo se confirma.
CONFIANZA: alta sobre la falla; media sobre la frecuencia, que no está medida
```

```
ID: B-05
SECCION: §5.4, "ninguna unidad no citable precede a una firmada", y D4 (síntesis §1.6)
TIPO: riesgo
SEVERIDAD: mayor
AFIRMACION: En "revisión de pertenencias" el usuario leerá primero un dictamen sustituido y al final el vigente rotulado como no citable, y la regla de orden lo conducirá a la conclusión operativa equivocada.
FUNDAMENTO: La regla ordena por citabilidad, que es lo que el proyecto puede garantizar, pero el usuario ordena por vigencia, que es lo que necesita; la síntesis mide que 0 de las 4 unidades del tema son a la vez firmadas y vigentes. La nota de sustitución derivada del dato está prevista, pero no se dice dónde ni con qué visibilidad aparece.
CAMBIO: Mostrar la nota "existe un pronunciamiento posterior, aún sin revisar" como encabezado de la lista y no como nota marginal, y programar la revisión humana de las 9 páginas del dictamen 078 como prerrequisito de lanzamiento, no como mejora futura.
PRUEBA: Entregar la lista de resultados de ese tema a dos integrantes del equipo y preguntar qué documento citarían; si cualquiera cita el sustituido, el hallazgo se confirma.
CONFIANZA: alta
```

```
ID: B-06
SECCION: §4.3, coincidencia por prefijo con AND sobre cada token
TIPO: defecto
SEVERIDAD: mayor
AFIRMACION: El contrato AND sobre todos los tokens devuelve cero sugerencias para cualquier consulta escrita como oración, y el estado vacío no está diseñado, de modo que la experiencia por defecto de la capa 1 es el silencio.
FUNDAMENTO: H-12 midió 9 de 10 consultas con cero sugerencias contra el resolutor real (síntesis §4.1); un equipo pregunta con oraciones ("qué hago si un apoderado agrede a un docente") y cada palabra de relleno es un AND que nadie satisface. Una herramienta que responde tres veces con nada deja de usarse antes de la cuarta.
CAMBIO: Excluir palabras vacías del AND, aplicar AND solo a tokens de contenido con OR de respaldo, y diseñar el estado vacío ("sin sugerencia; buscar igual" más la lista de temas navegable).
PRUEBA: Correr las 38 consultas construidas contra el resolutor con y sin exclusión de palabras vacías y contar los casos con cero sugerencias en cada variante.
CONFIANZA: alta sobre el mecanismo; media sobre la magnitud de la ganancia
```

```
ID: B-07
SECCION: §4.1 (objetivo de la capa 1)
TIPO: omision
SEVERIDAD: mayor
AFIRMACION: La persona que no sabe cómo se llama lo que busca no puede empezar a escribir, y la capa 1 solo ayuda a quien ya tiene una palabra.
FUNDAMENTO: El autocompletado supone un prefijo correcto; el 42 % de consultas sin ninguna palabra compartida (§4.4) describe usuarios que no tienen ese prefijo. Los 17 temas existen, pero el diseño no dice cómo se llega a ellos sin escribir, y sus nombres probablemente están en lenguaje legal.
CAMBIO: Escribir a mano un índice de situaciones en lenguaje corriente (entre 40 y 60 entradas del tipo "un estudiante trae un objeto peligroso", cada una apuntando a un tema y a sus anclas), publicarlo como página navegable y usarlo como primera fuente de alias.
PRUEBA: Describir cinco situaciones en lenguaje corriente a cinco integrantes del equipo, sin el sitio delante, y pedirles que digan qué escribirían; contar cuántas primeras palabras coinciden con alguna clave de la capa 1.
CONFIANZA: alta
```

```
ID: B-08
SECCION: §6.3, marca en texto plano dentro del bloque
TIPO: omision
SEVERIDAD: mayor
AFIRMACION: El rótulo que sobrevive al copiado dice quién lo dijo (nivel) pero no si sigue vigente ni qué tipo de acto es, de modo que "Fuente primaria" pegado en un oficio funciona como aval de un artículo sustituido.
FUNDAMENTO: El diseño hace viajar el nivel y el estado OCR dentro del texto (H-1), pero la sustitución solo aparece como penalización de orden en la capa 1 y como advertencia en la capa 3 en vivo; en la capa 2, que es la que se construirá primero, nada indica que la marca de vigencia vaya dentro del bloque copiable.
CAMBIO: Componer el rótulo en texto plano con nivel, tipo y estado ("Fuente primaria · Ley · sustituida por X" o "· vigente"), derivado de los metadatos existentes, en las tres capas.
PRUEBA: Copiar un resultado de una norma sustituida a un editor de texto plano; si el texto pegado no contiene la palabra "sustituida", el hallazgo se confirma.
CONFIANZA: alta
```

```
ID: B-09
SECCION: §6.3, debilidad conocida (niveles 1 y 2 no distinguidos)
TIPO: alternativa
SEVERIDAD: menor
AFIRMACION: La regla que distingue los niveles 1 y 2 ya es derivable del tipo de norma existente y no requiere un metadato nuevo.
FUNDAMENTO: La síntesis (§4.1, H-14) muestra seis tipos en el catálogo: ley, dfl, dto, dictamen, circular, rex. Los tres primeros son fuente primaria; los tres últimos son actos o pronunciamientos de autoridad. La objeción de H-15 (circular y rex) se resuelve imprimiendo el tipo en el rótulo en vez de un número de nivel.
CAMBIO: Derivar el nivel de `tipo` (ley, dfl, dto → 1; dictamen, circular, rex → 2) e imprimir el tipo en el rótulo, no "nivel 2".
PRUEBA: Aplicar la regla a las 25 normas, listar el resultado y pedir al equipo que marque desacuerdos; si hay cero, la regla basta.
CONFIANZA: media
```

```
ID: B-10
SECCION: §6.1, piezas firmadas con nombre y fecha de quien validó
TIPO: riesgo
SEVERIDAD: mayor
AFIRMACION: Las 0 de 22 piezas validadas se explican mejor por la unidad de firma (un funcionario con nombre propio avalando orientación jurídica en un sitio público) que por la falta de tiempo, y ningún cambio de motor lo mueve.
FUNDAMENTO: Firmar con nombre una interpretación normativa publicada es exposición profesional para un funcionario público, y la práctica institucional chilena firma por cargo y acta. Además la pieza mínima firmable es una ruta completa: cuanto más grande la unidad, más cara la firma.
CAMBIO: Admitir la firma por cargo más acta de sesión del equipo (sigue siendo humana, nominal y fechada), y reducir la unidad mínima firmable a una consideración de dos o tres líneas antes de pedir rutas completas.
PRUEBA: Ofrecer al equipo, la misma semana, una consideración de tres líneas y una ruta completa para firma, y preguntar en forma directa si el nombre propio es el obstáculo; contar cuál se firma.
CONFIANZA: media
```

```
ID: B-11
SECCION: §6.1 y §8 ("sumar una norma nueva es rutina")
TIPO: omision
SEVERIDAD: mayor
AFIRMACION: Una pieza firmada tiene fecha pero no condición de caducidad: si cambia el texto de una norma que la pieza ancla, la pieza sigue publicada y firmada.
FUNDAMENTO: §8 dice que "si toca un tema con ruta ya escrita, alguien la revisa", pero no dice quién avisa ni cómo; la firma vieja sobre un ancla que cambió es contenido no validado con aspecto de validado. El manifiesto por hash existe y permite detectarlo sin escribir en la capa de curaduría.
CAMBIO: Derivar en tiempo de construcción "anclas modificadas desde la fecha de firma" y degradar la pieza a "requiere revalidación" (estado derivado, mostrado y no publicado), sin escribir en `20_insumos/`.
PRUEBA: En una rama de prueba, modificar un segmento anclado por la ruta de ejemplo y reconstruir; si la ruta se publica sin advertencia, el hallazgo se confirma.
CONFIANZA: alta
```

```
ID: B-12
SECCION: §4.3, "los términos de glosario van rotulados como no validados"
TIPO: riesgo
SEVERIDAD: menor
AFIRMACION: Un término de glosario no validado dentro de un desplegable de sugerencias se lee como validado, y 20 de 39 encabezados están truncados con la definición pegada.
FUNDAMENTO: Nadie lee un rótulo de estado en un desplegable; el contexto de "sugerencia del sitio" es un aval implícito. Es la vía más discreta por la que lo no validado empieza a tratarse como validado.
CAMBIO: Hasta que el glosario tenga firma, sus entradas en la capa 1 solo navegan (sin definición visible) o quedan fuera del desplegable.
PRUEBA: Mostrar el desplegable con un término de glosario a tres personas ajenas al proyecto y preguntar si la definición es "oficial"; si dos dicen que sí, el hallazgo se confirma.
CONFIANZA: media
```

```
ID: B-13
SECCION: §1 ("no maneja datos personales") y §6.2 / §7 (capa 3 en vivo)
TIPO: riesgo
SEVERIDAD: mayor
AFIRMACION: La afirmación "no maneja datos personales" es cierta del corpus y falsa de las consultas: una consulta con nombre o RUT de un estudiante viajaría por el Worker hasta una API de terceros, y el diseño prevé un caso adversarial pero ningún bloqueo previo al envío.
FUNDAMENTO: El caso de uso natural de la capa 3 en vivo es pegar la situación real ("Juan Pérez, <RUT de ejemplo, redactado por gobernanza>, agredió a..."); la retención de registros de 24 horas y el tratamiento del proveedor quedan fuera del control del equipo. La normativa chilena de protección de datos trata con especial cuidado los datos de menores.
CAMBIO: Bloquear del lado del cliente, antes de enviar, toda consulta con patrón de RUT o secuencias de nombres propios, con un mensaje que explique qué quitar, y publicar en la página una línea sobre qué se envía y adónde.
PRUEBA: Enviar al arnés especificado una consulta con un RUT ficticio válido; si llega a la API, el hallazgo se confirma.
CONFIANZA: alta
```

```
ID: B-14
SECCION: §1 y §3 (propósito y arquitectura)
TIPO: omision
SEVERIDAD: mayor
AFIRMACION: El diseño nunca dice qué ofrece que la Biblioteca del Congreso (LeyChile) no ofrezca, y para leyes, DFL y decretos ese sitio ya entrega texto actualizado, anclas por artículo y versiones por fecha, que es justo lo que este corpus no tiene.
FUNDAMENTO: El equipo va a llegar por Google a LeyChile antes que a este sitio, y ahí el texto de la LGE está al día. Lo que este proyecto tiene y LeyChile no son las circulares y dictámenes de la Superintendencia, las relaciones derivadas y la orientación firmada; la inversión en recuperación compite donde el Estado gana y descuida donde el proyecto es único.
CAMBIO: Enlazar cada resultado de ley, DFL o decreto a su versión vigente en LeyChile ("ver texto vigente") y declarar en la primera pantalla del sitio qué tiene esta biblioteca que no está en otra parte.
PRUEBA: Resolver las 10 consultas de evaluación en LeyChile y en el sitio de la Superintendencia sin usar el sitio propio; si 5 o más se resuelven ahí con el texto vigente, la inversión en recuperación de leyes está mal ubicada.
CONFIANZA: alta sobre el enlace; media sobre el juicio estratégico
```

```
ID: B-15
SECCION: §5.5 y §6.3 (resultado y copiado)
TIPO: omision
SEVERIDAD: mayor
AFIRMACION: El producto del equipo es un oficio o un acta, y el motor no tiene ningún camino de salida en ese formato, de modo que hacer lo correcto (citar nivel 1 con ancla y estado) es más difícil que hacer lo incorrecto (pegar cualquier cosa).
FUNDAMENTO: La separación de niveles se defiende con rótulos que sobreviven al copiado, pero la forma más robusta de proteger la cita es que el camino sancionado sea el más cómodo. Un botón que copia solo lo citable convierte el invariante 1 en un hábito.
CAMBIO: Agregar por segmento un botón "Copiar cita" que copie exactamente norma, artículo, texto literal, URL del ancla, estado de vigencia y fecha de consulta, y nada más.
PRUEBA: Cronometrar a dos integrantes del equipo produciendo una cita para un oficio con y sin el botón, y contar errores de referencia en cada caso.
CONFIANZA: alta
```

```
ID: B-16
SECCION: §4.2 (892 entradas, 806 segmentos con ancla)
TIPO: sobreingenieria
SEVERIDAD: menor
AFIRMACION: Los 806 encabezados de segmento son cerca del 88 % del peso de la capa 1 y solo sirven a consultas que traen un número de artículo, que el equipo casi nunca conoce.
FUNDAMENTO: La regla de §4.3 ya limita su uso a consultas con número; la variante sin ellos pesa 52 036 B contra 435 763 B (síntesis §1.1). Quien sabe el número de artículo no necesita sugerencia; quien no lo sabe no la puede usar.
CAMBIO: Publicar la variante sin encabezados de segmento y reincorporarlos solo si las consultas reales muestran 10 % o más con número de artículo.
PRUEBA: Contar, en las primeras 100 consultas reales capturadas, cuántas contienen un patrón numérico de artículo.
CONFIANZA: alta sobre el peso; media sobre la utilidad
```

```
ID: B-17
SECCION: §5.2 (reordenamiento en tres niveles) y §9 (descomposición de preguntas)
TIPO: sobreingenieria
SEVERIDAD: menor
AFIRMACION: Sobre 806 segmentos y diez consultas, los niveles 2 y 3 del reordenamiento y la descomposición de preguntas (×2,30 de contexto) no tienen ganancia medida y sí costo medido.
FUNDAMENTO: El propio diseño lo declara en §9. Un reordenador que puede no estar disponible y cuyo aporte no se conoce es un componente que se mantiene sin saber para qué.
CAMBIO: Construir solo el nivel determinístico R0, medir acierto en las diez consultas, y agregar un nivel únicamente si mejora el acierto en al menos dos consultas.
PRUEBA: Acierto en los cinco primeros sobre el conjunto de evaluación con R0 solo y con el reordenador completo.
CONFIANZA: media
```

```
ID: B-18
SECCION: §5.5 (respuesta correcta identificada por ancla; 19 anclas para 10 consultas)
TIPO: omision
SEVERIDAD: mayor
AFIRMACION: La respuesta a una situación real es un conjunto de artículos de varias normas (ley, reglamento, dictamen), y el diseño evalúa y muestra una lista plana donde el acierto es un ancla.
FUNDAMENTO: 19 anclas para 10 consultas dice que casi todas las respuestas son conjuntos. Una lista plana obliga al usuario a reconstruir el conjunto y a adivinar cuál es la norma de rango superior; además nada le dice por qué aparece cada resultado.
CAMBIO: Agrupar los resultados por norma con su tipo visible, mostrar los términos que provocaron cada coincidencia, y medir la evaluación como cobertura del conjunto de anclas por consulta.
PRUEBA: Contar cuántas de las 10 consultas tienen dos o más anclas en dos o más normas; si son 5 o más, el acierto por ancla única es la métrica equivocada.
CONFIANZA: media
```

```
ID: B-19
SECCION: §1 (usuarios) y §9 (latencia real en el navegador no medida)
TIPO: riesgo
SEVERIDAD: menor
AFIRMACION: El diseño no menciona el teléfono, y el equipo consultará la norma en el celular durante reuniones y visitas a establecimientos, con conexiones de colegio.
FUNDAMENTO: Toda la medición de peso está en bytes y en segundos a 3 Mbps de escritorio; nada de la interfaz de resultados, del desplegable ni de la eventual capa 2 semántica se prueba en pantalla angosta.
CAMBIO: Incluir como criterio de aceptación de cada capa una prueba en un Android de gama media sobre la red de un establecimiento, con tiempo hasta la primera sugerencia y hasta el primer resultado.
PRUEBA: Medir esos dos tiempos en ese dispositivo; si superan 3 s, el hallazgo se confirma.
CONFIANZA: media
```

```
ID: B-20
SECCION: §8 ("lo que sí cuesta trabajo humano") y §4.4
TIPO: omision
SEVERIDAD: mayor
AFIRMACION: Ninguna parte del diseño nombra quién, dentro del equipo, cura los alias y lee las consultas fallidas; sin ese dueño la compuerta humana de la capa 1 no se abre nunca.
FUNDAMENTO: El diseño transfiere el trabajo decisivo (alias, revisión OCR, firma) a "personas" en genérico; 0 de 22 piezas validadas muestra qué pasa con el trabajo humano sin dueño. Un equipo pequeño adopta lo que uno de sus integrantes mantiene, no lo que "el equipo" debería mantener.
CAMBIO: Nombrar a una persona del equipo como dueña de alias y de consultas fallidas, con un bloque fijo de veinte minutos semanales alimentado por el formulario de B-02.
PRUEBA: A las ocho semanas, contar entradas de alias con `fuente`; si sigue en cero, el hallazgo se confirma.
CONFIANZA: media
```

---

## 2. Tabla resumen

| ID | SECCION | TIPO | SEVERIDAD | AFIRMACION (recortada) | CONFIANZA |
|---|---|---|---|---|---|
| B-01 | §2 inv. 1, §9 | defecto | bloqueante | Trazabilidad no es vigencia: la LGE de 2010 sale con ancla correcta y sin marca | alta |
| B-02 | §9, §4.4 | omision | mayor | No hay instrumento de captura de consultas reales; los alias se curarán a ciegas | alta |
| B-03 | §5.2 | defecto | mayor | La fusión por rango nunca dice "no está en el corpus" | alta |
| B-04 | §9 | omision | mayor | Expulsión: 39 menciones, ningún texto regulador, ninguna respuesta curada | alta / media |
| B-05 | §5.4, D4 | riesgo | mayor | El usuario leerá primero el dictamen sustituido y citará el equivocado | alta |
| B-06 | §4.3 | defecto | mayor | AND sobre todos los tokens deja la capa 1 en silencio ante oraciones | alta / media |
| B-07 | §4.1 | omision | mayor | Quien no conoce el término no puede empezar a escribir | alta |
| B-08 | §6.3 | omision | mayor | El rótulo copiable no lleva vigencia ni tipo de acto | alta |
| B-09 | §6.3 | alternativa | menor | Los niveles 1 y 2 ya se derivan del campo `tipo` | media |
| B-10 | §6.1 | riesgo | mayor | 0 de 22 firmas: la unidad de firma con nombre propio es el obstáculo | media |
| B-11 | §6.1, §8 | omision | mayor | La firma no caduca cuando cambia un ancla | alta |
| B-12 | §4.3 | riesgo | menor | Glosario no validado en desplegable se lee como validado | media |
| B-13 | §1, §6.2, §7 | riesgo | mayor | Datos de estudiantes en consultas viajan a una API sin bloqueo previo | alta |
| B-14 | §1, §3 | omision | mayor | No se declara qué ofrece frente a LeyChile; falta enlace al texto vigente | alta / media |
| B-15 | §5.5, §6.3 | omision | mayor | No hay salida en formato de oficio; lo correcto es más difícil que lo incorrecto | alta |
| B-16 | §4.2 | sobreingenieria | menor | 806 encabezados de segmento son 88 % del peso y sirven a consultas con número | alta / media |
| B-17 | §5.2, §9 | sobreingenieria | menor | Reordenamiento en tres niveles y descomposición sin ganancia medida | media |
| B-18 | §5.5 | omision | mayor | La respuesta es un conjunto de artículos; el diseño evalúa y muestra un ancla | media |
| B-19 | §1, §9 | riesgo | menor | Nada se prueba en teléfono | media |
| B-20 | §8, §4.4 | omision | mayor | Ningún dueño nombrado para alias y consultas fallidas | media |

---

## 3. Respuestas a las seis preguntas abiertas (§10 del documento)

**1. ¿La vía semántica se justifica en 806 segmentos?**
No, no ahora. La brecha medida es de vocabulario (42 % de consultas sin una palabra compartida) y un modelo de embeddings pequeño y multilingüe no garantiza mapear "mochila" a "revisión de pertenencias" mejor que un alias escrito por quien sabe que son lo mismo. El residuo que solo la vía semántica rescata es 1 de 10 y 1 de 38 sobre conjuntos construidos. Umbral de reapertura: cuando existan al menos 100 consultas reales capturadas y, con los alias en su lugar, 15 % o más sigan sin ninguna coincidencia léxica sobre tokens de contenido. Hasta entonces el esfuerzo rinde más en alias, índice de situaciones y estado vacío.

**2. ¿Es correcto excluir el texto sin firma del contexto del modelo?**
Sí, y en la entrada, que es donde el diseño la pone. Pero la pregunta se formula como si el costo fuera permanente y son 9 páginas de un dictamen. La decisión correcta no es "excluir o incluir": es excluir y programar la revisión humana de esas 9 páginas como prerrequisito de lanzamiento, con una cola de revisión OCR ordenada por cuántas consultas desbloquea cada página y no por orden de documento. En la capa 2, de cara al humano, el texto OCR marcado y en bloque aparte se queda como está.

**3. ¿Es defendible la unidad de recuperación, o convendría indexar por inciso?**
El artículo es la unidad de cita: es lo que va en un oficio, y cambiarla no ayuda a nadie que redacte uno. La recuperación por ventana sobre los 227 largos es un detalle interno correcto siempre que el resultado mostrado sea el artículo completo con el pasaje coincidente resaltado. Indexar por inciso solo si, con consultas reales, 20 % o más de los aciertos caen en artículos de más de 3 000 caracteres y las personas reportan no encontrar el pasaje dentro del artículo.

**4. ¿El orden de construcción maximiza valor por esfuerzo?**
No. El orden actual pone en el paso 2 un trabajo con compuerta humana (alias curados) y encadena detrás de él la única ganancia visible de costo cero (la corrección de interfaz de §5.5). Orden propuesto: (1) corrección de interfaz de §5.5, sin compuerta, días; (2) enlace "¿No encontraste?", botón "Copiar cita" y enlace a LeyChile, todo estático; (3) índice de situaciones y alias, curados desde las consultas reales de (2), con dueño nombrado; (4) capa 1 en su variante liviana; (5) andamio de capa 3 precalculada con unidad firmable pequeña; (6) vía semántica solo por disparador; capa 3 en vivo solo con arnés de suficiencia.

**5. ¿Qué le falta para que un equipo no técnico lo use de verdad?**
Que la salida sea el formato de trabajo del equipo (botón "Copiar cita"), que la entrada acepte la forma en que el equipo pregunta (índice de situaciones, estado vacío diseñado), que la confianza se pueda verificar en un clic ("ver texto vigente" en LeyChile, fecha de versión visible por norma), que exista un canal de queja de una línea ("¿No encontraste?"), que funcione en el teléfono, que una persona con nombre sea dueña del mantenimiento, y que los rótulos digan qué es la cosa ("Dictamen, sustituido") y no un número de nivel. Y una sesión de 30 minutos con los casos del propio equipo, no una guía.

**6. ¿Qué parte es sobreingeniería?**
Con nombre: (a) los 806 encabezados de segmento en la capa 1; (b) los niveles 2 y 3 del reordenamiento y la descomposición de preguntas, sin ganancia medida; (c) el prompt de 5 022 caracteres, 12 reglas y cinco modos de salida para una capa que no se construye; (d) Cloudflare Access más contabilidad de cuota en un Durable Object para un equipo que cabe en una mano, donde bastarían un secreto compartido y un contador diario en el Worker; (e) la ampliación de la ontología de relaciones, que reetiqueta 22 pares y no descubre ninguno, vale como rótulo y no como capa. No es sobreingeniería: el índice estático, la fusión por rango, la compuerta de entrada, las anclas por segmento ni la firma humana.

---

## 4. Qué no cambiaría

1. **Capas 1 y 2 estáticas, sin servidor, sin secretos.** La degradación es nula y el costo mensual es cero; para un equipo pequeño es la única arquitectura que sobrevive a que nadie la mantenga durante un año.
2. **Compuerta en la entrada y no en la salida.** 0 de 27 745 contra 10,96 % de falso positivo es una decisión medida, no una preferencia.
3. **Segmento con ancla estable como unidad, ventana solo sobre los largos.** El artículo es lo que se cita; la ventana es un detalle interno que no toca la cita.
4. **Rótulos en texto plano dentro del bloque.** Es la única marca que sobrevive al copiado; solo falta que lleve más información (B-08).
5. **Relaciones derivadas y nunca inferidas, y rechazo de la clasificación automática.** El error de un modelo en una relación jurídica es indistinguible de un acierto para quien lo lee.
6. **No construir la capa 3 en vivo mientras el arnés verifique procedencia y no suficiencia.** Publicar orientación generada con un arnés que no lee la frase es publicar contenido no validado con firma técnica.
7. **Filtro temporal con marca visible y sin ocultamiento.** Ocultar resultados por año, con cuatro años nulos y una sola sustitución registrada, borraría lo que no se sabe.
8. **La sección 9 tal como está escrita.** Declarar debilidades y residuos hace auditable el diseño y es la razón por la que este informe pudo concentrarse en supuestos y no en erratas.

---

## 5. Lo que no se pudo evaluar

- **Las 10 consultas de evaluación y las 38 construidas, con su redacción y quién las escribió.** Sin ellas no se puede juzgar si "lenguaje del equipo" describe algo o lo aspira, ni calibrar B-02, B-06 y B-07.
- **La pantalla de resultados actual (una captura o el HTML).** Sin ella no se puede juzgar el aire de certeza (si hay puntajes, cuántos resultados aparecen, cómo se ve el bloque OCR) ni cómo se copia de verdad (B-08, B-15).
- **Los nombres de los 17 temas.** Sin ellos no se puede juzgar si navegar por tema sirve a quien no conoce el término (B-07).
- **La lista de las 25 normas por tipo.** Sin ella no se puede juzgar la cobertura de situaciones típicas (Aula Segura, inclusión, discriminación, protocolos de la Superintendencia) ni la magnitud de B-04 y B-14.
- **La ruta de abordaje de ejemplo y las tres entradas de capa experta.** Sin ellas no se puede juzgar si la unidad es firmable ni cuánto tiempo exige firmarla (B-10).
- **El texto literal de los rótulos previstos.** Sin él no se puede juzgar si un lector no técnico entiende "nivel 4" o "no citable" (B-08, B-09).
- **Tamaño y composición del equipo, y quién tiene atribución para firmar.** Sin eso B-10 y B-20 quedan en hipótesis.
- **Qué hace hoy el constructor con una pieza validada cuyas anclas cambiaron.** B-11 supone que nada; un solo comando sobre el constructor lo zanjaría.

---

*Constancia de edicion por gobernanza:* en la linea 163 de este informe se sustituyo un patron de RUT (ejemplo ilustrativo del revisor) por el marcador `<RUT de ejemplo, redactado por gobernanza>`. Edicion del 2026-09-09, hecha por el cierre de la sesion 3 en aplicacion de `CLAUDE.md` §10.2 (repositorio publico), no por el revisor. Ninguna otra palabra del informe fue modificada.
