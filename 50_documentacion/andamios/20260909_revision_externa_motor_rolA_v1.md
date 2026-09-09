# Revisión externa, Rol A: arquitectura y recuperación

> **Destino:** `50_documentacion/andamios/20260909_revision_externa_motor_rolA_v1.md`
> **Insumo:** `20260908_especificacion_motor_busqueda_v1.md` (v1, 2026-09-08). Las secciones citadas (§) son de ese documento. Donde se usa una cifra de la síntesis del alcance (`20260904_alcance_motor_busqueda_sintesis_v1.md`) se dice.
> **Rol ejecutado:** A. No se cubre el Rol B.
> **Marcadores:** toda cifra tomada del insumo lleva su sección. Toda cifra que el revisor estima y no leyó va como (hipótesis).

---

## 4.1 Hallazgos

```
ID: A-01
SECCION: §5.2
TIPO: omision
SEVERIDAD: bloqueante
AFIRMACION: La especificación fija "384 dimensiones" sin nombrar el modelo de embeddings, y el único modelo con precio en el paquete de origen (bge-m3, síntesis §6.6) produce 1 024 dimensiones, no 384.
FUNDAMENTO: Corpus y consulta deben vectorizarse con el mismo modelo o el índice es inservible. Con 1 024 dims el índice int8 pesa 2,67 veces lo calculado (1 160 × 1 024 = 1,19 MB de vectores). Todo peso, umbral (~96 normas) y presupuesto de §5.2 y §7 hereda una dimensión que no se sabe de qué modelo sale.
CAMBIO: Fijar en la especificación nombre, versión, dimensión, largo máximo de secuencia y licencia del modelo, y recalcular §5.2 y §7 con esa dimensión antes de cualquier otra decisión de la vía semántica.
PRUEBA: Vectorizar 10 fragmentos con el modelo elegido, leer `length(vector)`, y recuperar cada fragmento con su propia consulta literal: top-1 = 10 de 10 confirma que corpus y consulta comparten espacio.
CONFIANZA: alta
```

```
ID: A-02
SECCION: §5.2, §9
TIPO: defecto
SEVERIDAD: bloqueante
AFIRMACION: El presupuesto de peso "440 KiB transferidos" omite el término dominante: un modelo multilingüe de 384 dims cuantizado a int8 pesa entre 25 y 120 MB en el navegador (hipótesis, verificar con: descargar el ONNX y medir bytes), es decir 60 a 270 veces el índice.
FUNDAMENTO: Los modelos multilingües de 384 dims arrastran una matriz de vocabulario de ~250 000 entradas que domina su tamaño; ninguna cuantización del índice compensa eso. §9 lo declara "no medido", pero §3 y §7 afirman que la capa 2 "es estática y funciona completa sin Worker", lo que solo es cierto si ese modelo se descarga a cada visitante.
CAMBIO: Decidir explícitamente entre (a) vectorizar la consulta en el Worker vía Workers AI, aceptando que la vía semántica deja de ser estática, o (b) modelo en navegador con caché persistente y un tope de bytes de carga fría; medir antes de elegir.
PRUEBA: Carga fría del modelo elegido en Chrome sobre un portátil institucional y la red institucional: bytes descargados y segundos hasta la primera consulta. Si supera 10 s o 50 MB, la opción (b) no es viable para el equipo.
CONFIANZA: alta
```

```
ID: A-03
SECCION: §5.1, §1
TIPO: defecto
SEVERIDAD: mayor
AFIRMACION: Los 227 segmentos "sobre 512 tokens" y los 1 160 fragmentos están contados con la convención de 4 caracteres por token (síntesis §6.4), no con el tokenizador del modelo; con 3,5 caracteres por token el mismo paquete da 261 y 1 264.
FUNDAMENTO: El español jurídico con tokenizadores multilingües rinde menos de 4 caracteres por token en texto con siglas, números y latinismos. La frontera "se parte o no se parte" cambia de 227 a 261 unidades (15 % más) solo por la convención. Toda cifra derivada (fragmentos, bytes, neuronas) hereda ese error.
CAMBIO: Tokenizar los 806 segmentos con el tokenizador real del modelo fijado en A-01 y reemplazar la tabla de §1 y §5.1 por conteos medidos.
PRUEBA: Distribución de tokens reales versus `nchar/4`: reportar mediana de la razón caracteres/token y el nuevo conteo de segmentos sobre 512. Si la razón queda bajo 3,6, el 227 es falso.
CONFIANZA: alta
```

```
ID: A-04
SECCION: §5.1
TIPO: defecto
SEVERIDAD: mayor
AFIRMACION: La regla usa dos umbrales incompatibles: se fragmenta solo lo que supera 512 tokens, pero la ventana es de 400, de modo que todo segmento entre 401 y 512 tokens queda entero y excede la ventana.
FUNDAMENTO: §5.1 declara "400 tokens con solape de 50, aplicada solo a los 227 segmentos largos", y §1 define largo como "sobre 512". Si el modelo trunca a su largo máximo, la cola de esos segmentos no se vectoriza y no se recupera por significado; si el 400 se eligió para dejar espacio a un prefijo de instrucción, el 512 no lo respeta.
CAMBIO: Un único umbral: fragmentar todo segmento que supere la ventana (400) o subir la ventana al largo máximo real del modelo, y declarar por qué.
PRUEBA: Contar segmentos con tokens reales en el intervalo (400, 512]. Si es mayor que cero, la regla actual deja texto sin vectorizar.
CONFIANZA: alta
```

```
ID: A-05
SECCION: §5.1
TIPO: riesgo
SEVERIDAD: mayor
AFIRMACION: La ventana deslizante de 400/50 corta sin mirar párrafos ni incisos, así que una fracción medible de los 1 160 fragmentos termina en mitad de una oración o separa un inciso de su excepción.
FUNDAMENTO: La síntesis (§6.4) muestra que el párrafo solo no basta (87 párrafos sobre 512 tokens), pero de ahí no se sigue que la ventana ciega sea la alternativa. Un corte que respete límites de párrafo y solo deslice dentro de los párrafos que exceden la ventana produce fragmentos con sentido jurídico cerrado, que es lo que un reordenador y un lector necesitan.
CAMBIO: Fragmentar primero por párrafo acumulando hasta la ventana; aplicar ventana deslizante solo dentro de los párrafos que la exceden.
PRUEBA: Contar fragmentos cuyo último carácter no es punto, punto y coma ni dos puntos, con ambas estrategias, sobre los 227 segmentos largos. Diferencia mayor a 10 % zanja.
CONFIANZA: alta
```

```
ID: A-06
SECCION: §5.1, §5.2
TIPO: omision
SEVERIDAD: mayor
AFIRMACION: El fragmento no tiene ancla propia ni desplazamiento dentro del segmento, así que un acierto en el fragmento 18 del artículo de 27 167 caracteres envía al usuario al inicio del artículo sin decirle dónde está lo que buscó, y ese mismo artículo puede ocupar hasta 20 de los 30 candidatos de la vía semántica.
FUNDAMENTO: §5.1 declara 1 160 fragmentos y §2.1 exige ancla por segmento; nada dice cómo se colapsan varios fragmentos de un mismo segmento antes de la fusión ni cómo se resalta el fragmento acertado. Sin colapso, un segmento largo con muchos fragmentos afines coloniza la lista y expulsa a segmentos cortos que responden mejor.
CAMBIO: Guardar por fragmento el desplazamiento (inicio, fin) en caracteres del segmento, y colapsar a segmento por máximo antes de la fusión, conservando el desplazamiento del fragmento ganador para resaltado.
PRUEBA: Consulta "inclusión escolar" sobre el índice semántico: contar cuántos de los 30 candidatos pertenecen al mismo segmento. Más de 3 confirma la colonización.
CONFIANZA: alta
```

```
ID: A-07
SECCION: §5.2, §5.5
TIPO: defecto
SEVERIDAD: mayor
AFIRMACION: K = 30 candidatos por vía deja fuera de la fusión, por construcción, la consulta cuya ancla correcta aparece en el rango 65 de la vía léxica, que es la décima del propio conjunto de evaluación.
FUNDAMENTO: §5.5 reporta que 9 de 10 quedan cubiertas con 28 candidatos o menos, lo que implica que la décima necesita más; la síntesis (§6.4) da el rango exacto: 65. Un candidato que no entra a la lista no puede ser rescatado por RRF ni por reordenamiento, cualquiera sea su calidad. La vía léxica es local y gratuita: no hay razón de costo para recortarla en 30.
CAMBIO: K léxico igual o mayor que 65 (o el máximo observado más un margen), K semántico separado y justificado por su propio recall@K; ambos declarados como parámetros distintos, no uno.
PRUEBA: Recall@K de la vía léxica sobre las 10 consultas para K en {30, 65, 100}: la curva debe alcanzar 10 de 10 en el K que se adopte.
CONFIANZA: alta
```

```
ID: A-08
SECCION: §5.2
TIPO: riesgo
SEVERIDAD: mayor
AFIRMACION: Con RRF de constante 60 y listas de 30, un resultado en rango 1 de una sola vía (1/61 = 0,0164) queda por debajo de uno en rango 15 en ambas (2/75 = 0,0267), de modo que la fusión degrada precisamente las consultas por número de ley o artículo donde §5.2 declara a la vía léxica "imbatible".
FUNDAMENTO: RRF premia consenso mediocre sobre certeza unilateral; con dos listas cortas y k = 60 los pesos son casi planos. Una consulta "ley 20.845 artículo 6" tiene un único resultado correcto que la vía semántica no distingue de sus vecinos; el consenso la entierra.
CAMBIO: Regla determinística en R0 previa a la fusión: si la consulta contiene número de norma o de artículo y la vía léxica tiene coincidencia exacta en ese campo, ese resultado encabeza; RRF solo ordena el resto. Evaluar además k = 10 frente a 60.
PRUEBA: 10 consultas con número más las 10 de evaluación, fusión frente a léxica sola: contar regresiones de top-1. Cualquier regresión en las consultas con número zanja.
CONFIANZA: media
```

```
ID: A-09
SECCION: §5.2, §7
TIPO: omision
SEVERIDAD: mayor
AFIRMACION: El "reordenamiento en tres niveles" no especifica qué son los niveles 1 y 2 ni dónde corren, y §7 no enumera qué devuelve el motor cuando falla cada componente por separado (índice semántico que no carga, modelo que no carga, reordenador caído, Pagefind caído).
FUNDAMENTO: Si un nivel es un reordenador cruzado servido por Workers AI, la capa 2 deja de ser estática y §7 ("capas 1 y 2 siguen funcionando completas") solo vale para el piso R0. "Degrada a algo predecible" no es una especificación: sin tabla de modos de falla no hay prueba de aceptación posible y la ganancia de cada nivel, ya declarada no medida en §9, tampoco se puede aislar.
CAMBIO: Tabla de degradación con una fila por componente (falla, qué se omite, qué ve el usuario, rótulo visible) y definición de cada nivel de reordenamiento con su entrada, salida y lugar de ejecución.
PRUEBA: Bloquear cada archivo o servicio uno a uno en el navegador y comparar la lista devuelta con la esperada en la tabla, sobre las 10 consultas.
CONFIANZA: alta
```

```
ID: A-10
SECCION: §5.2
TIPO: sobreingenieria
SEVERIDAD: menor
AFIRMACION: Cuantizar a int8 ahorra alrededor de 1,3 MB frente a float32 (1 160 × 384 × 4 B = 1,78 MB sin comprimir) a cambio de un paso de calibración no especificado y un riesgo de recall no medido, mientras el término que decide "cabe en el navegador" es el modelo (A-02).
FUNDAMENTO: A esta escala el producto punto sobre 1 160 vectores float32 en JavaScript tarda milisegundos; la cuantización no resuelve latencia. §5.2 no dice si la calibración es por dimensión o global, ni si la consulta se cuantiza, que es donde int8 pierde calidad.
CAMBIO: Construir primero el índice en float32 (o float16), medir recall@10 contra int8 en el mismo conjunto, y adoptar int8 solo si el presupuesto de transferencia lo exige y la pérdida es menor a 1 punto.
PRUEBA: Recall@10 y MRR de float32 frente a int8 sobre las 10 consultas más las 38 sintéticas; reportar además bytes reales de ambos índices comprimidos.
CONFIANZA: media
```

```
ID: A-11
SECCION: §8
TIPO: riesgo
SEVERIDAD: mayor
AFIRMACION: "Vectorización incremental por hash" con hash del documento como única clave produce índices incoherentes cuando cambia cualquier parámetro que no sea el texto: versión del modelo, ventana, solape o escala de cuantización.
FUNDAMENTO: §8 exige no reembeber el corpus completo, pero un vector generado con la versión N del modelo no es comparable con uno de la versión N+1; y una calibración int8 por dimensión calculada sobre 1 160 fragmentos cambia al entrar el 1 161. El costo escondido es una reindexación completa que el manifiesto por hash no dispara.
CAMBIO: Clave de caché por fragmento = hash(texto del fragmento) + identificador y versión del modelo + ventana + solape + parámetros de cuantización; cualquier cambio en los cuatro últimos invalida el índice entero y el pipeline lo reporta.
PRUEBA: Cambiar la ventana de 400 a 350 sin tocar el corpus: el pipeline debe reembeber el 100 %. Correr dos veces sin cambios: 0 reembebidos. Los dos controles en el mismo turno.
CONFIANZA: alta
```

```
ID: A-12
SECCION: §7, §8
TIPO: omision
SEVERIDAD: mayor
AFIRMACION: La especificación no dice dónde se generan los vectores ni dónde viven: la CI de GitHub Pages no tiene la clave de ningún modelo ("sin secretos", §7) y el índice binario no tiene lugar declarado en el repositorio.
FUNDAMENTO: Las opciones son excluyentes y ninguna está elegida: (a) la CI guarda un secreto y vectoriza en cada build, lo que contradice la ausencia de secretos y expone cuota; (b) una máquina del equipo vectoriza y versiona un blob binario, que colisiona con la política de datos versionados que la síntesis (D5) describe; (c) el Worker vectoriza bajo demanda y la capa 2 deja de ser estática.
CAMBIO: Declarar la opción, la ruta del índice en el repositorio o en el artefacto de build, y quién tiene la clave; si es (b), registrar la excepción de versionado por ruta explícita.
PRUEBA: Ejecutar el pipeline completo en la CI sin ningún secreto configurado: o produce el índice semántico o declara que no lo intenta. Ambos resultados son aceptables; el fallo silencioso no.
CONFIANZA: alta
```

```
ID: A-13
SECCION: §6.2, §7
TIPO: riesgo
SEVERIDAD: mayor
AFIRMACION: El arnés "del lado del cliente" es la única compuerta sobre la salida del modelo, y cualquier persona autorizada por Access puede llamar al Worker directamente y recibir esa salida sin arnés.
FUNDAMENTO: §7 limita el Worker a custodiar la clave y contar cuota; §6.2 pone la verificación en JavaScript. Además, la "función real de resolución de anclas" vive en R en el pipeline y el cliente la reimplementa en JavaScript: dos implementaciones del mismo invariante divergen con el tiempo. El invariante 2 (§2) queda protegido por la interfaz, no por el sistema.
CAMBIO: Exportar desde R el conjunto de anclas válidas y citables como JSON (dato, no lógica) y hacer que tanto el cliente como el Worker lo consuman; el Worker rechaza en menos de 10 ms de CPU toda respuesta cuyas anclas no estén en ese conjunto antes de devolverla.
PRUEBA: Llamar al Worker con `curl` y un token válido de Access, con una consulta que induzca una cita inexistente: si la respuesta llega con la cita, el arnés es evitable.
CONFIANZA: alta
```

```
ID: A-14
SECCION: §5.4, §6.2
TIPO: defecto
SEVERIDAD: mayor
AFIRMACION: "0 de 27 745 casos" mide que el texto OCR no entra al contexto, no que el modelo no lo produzca; un modelo que conoce el dictamen derogado por su entrenamiento puede reproducirlo apoyado en una cita firmada verificable, y el arnés lo deja pasar porque verifica procedencia, no suficiencia.
FUNDAMENTO: §6.2 dice que se "retira toda frase cuya cita no se verifique"; verificar es ancla existente más texto literal. Una frase puede llevar cita literal verdadera y afirmación falsa. §9 no lista esto entre las debilidades del diseño, aunque la síntesis (§3.3) lo declara con dos caminos de fuga abiertos.
CAMBIO: Hasta que exista un arnés de suficiencia, restringir el modo en vivo a salida extractiva (cita literal más ubicación, sin paráfrasis ni conclusión), y mover los dos caminos de fuga abiertos a §9 de la especificación.
PRUEBA: Plantar las dos salidas de fuga (facultad que el artículo no contiene; cita que corta antes de la excepción) contra el arnés: la tasa de retiro debe ser 2 de 2 antes de habilitar cualquier modo no extractivo.
CONFIANZA: alta
```

```
ID: A-15
SECCION: §5.5
TIPO: omision
SEVERIDAD: mayor
AFIRMACION: Diez consultas no distinguen un motor de otro: pasar de 3 a 5 aciertos sobre 10 no es estadísticamente distinguible del azar, y el conjunto no incluye ninguna consulta cuya respuesta correcta sea "no está en el corpus".
FUNDAMENTO: Con n = 10 la diferencia entre 3/10 y 5/10 tiene un valor p cercano a 0,65 en una prueba exacta (hipótesis, verificar con: `fisher.test(matrix(c(3, 7, 5, 5), 2))`). El corpus tiene omisiones conocidas (§9: procedimiento de expulsión) y un motor que devuelve algo con confianza ante ellas viola el espíritu del invariante 1. Faltan además métricas por vía (recall@K léxico y semántico por separado) y MRR.
CAMBIO: Ampliar a 50 consultas estratificadas (número de norma, nombre de figura, lenguaje de sala, sin respuesta), con 10 de la última clase, y reportar recall@10 por vía, MRR y tasa de abstención correcta; conservar las 10 actuales como subconjunto histórico.
PRUEBA: Intervalo de confianza bootstrap del recall@10 con n = 10 y n = 50: el primero debe ser demasiado ancho para decidir; el segundo, no.
CONFIANZA: alta
```

```
ID: A-16
SECCION: §2, §5.3, §8
TIPO: defecto
SEVERIDAD: bloqueante
AFIRMACION: El invariante 1 asume que "ancla estable" implica "texto estable", y no es así: al incorporar la ley general de educación consolidada (§9), el ancla del artículo modificado conserva su identificador con otro texto, y toda pieza de capa 3 que la cita sigue verificando mientras cita un contenido que ya no existe.
FUNDAMENTO: §8 describe la incorporación como rutina por hash de documento; §5.3 reconoce que no hay campo de versión. El arnés (§6.2) y el constructor de piezas (§6.1) verifican existencia del ancla, no identidad del texto. Es el supuesto que la sección 6 del encargo pide buscar: el invariante mismo está incompleto.
CAMBIO: Cada cita en una pieza firmada guarda el hash del texto del segmento citado al momento de la firma; el constructor marca como "reparo" toda pieza cuyo hash citado difiera del actual, y el ancla pública agrega un sufijo de versión cuando el texto cambia.
PRUEBA: Modificar el texto de un artículo en un JSON canónico, reconstruir, y contar piezas marcadas: debe ser exactamente el número de piezas que lo citan (control positivo) y 0 para un artículo que nadie cita (control negativo).
CONFIANZA: alta
```

```
ID: A-17
SECCION: §5.5, §9
TIPO: omision
SEVERIDAD: menor
AFIRMACION: "0,70 a 27,48 ms" mide CPU fuera del navegador y no es la latencia que verá el equipo: en el navegador la primera consulta paga la descarga de los trozos de índice de Pagefind y, si hay vía semántica, la carga del modelo y del índice; el presupuesto debe ser un par (fría, caliente), no un número.
FUNDAMENTO: Pagefind carga su índice por trozos bajo demanda; la latencia dominante de la primera consulta es de red, no de cómputo. Un modelo en navegador tarda segundos en inicializar su sesión antes de vectorizar nada. Ningún umbral de aceptación de latencia aparece en la especificación.
CAMBIO: Declarar dos umbrales (primera consulta de la sesión; consultas siguientes) medidos en Chrome sobre un equipo institucional y la red institucional, y aceptar la vía semántica solo si ambos se cumplen.
PRUEBA: 30 sesiones frías y 30 consultas calientes en el equipo de referencia; reportar mediana y p90 de cada una.
CONFIANZA: media
```

```
ID: A-18
SECCION: §4.3
TIPO: omision
SEVERIDAD: menor
AFIRMACION: Las reglas de sugerencia no declaran normalización de tildes ni de mayúsculas, así que "inclusion" escrito sin tilde no coincide por prefijo con "inclusión".
FUNDAMENTO: El equipo escribe rápido y sin tildes; el corpus las trae completas. Es la clase de discrepancia que convierte un vocabulario correcto en uno que "no encuentra nada".
CAMBIO: Normalizar claves y consulta a minúsculas sin diacríticos (NFD, retirar marcas combinantes) antes de la coincidencia por prefijo; conservar la forma original para mostrar.
PRUEBA: Las 892 entradas con y sin tildes en la consulta: el conjunto sugerido debe ser idéntico.
CONFIANZA: alta
```

```
ID: A-19
SECCION: §5.2
TIPO: riesgo
SEVERIDAD: menor
AFIRMACION: "Imbatible con números de ley" depende de cómo tokeniza Pagefind el punto de millar: "20.845", "20845" y "20 845" son tres consultas distintas y al menos una de ellas devuelve resultados peores.
FUNDAMENTO: Los tokenizadores por defecto separan en puntuación, con lo que "20.845" se parte en "20" y "845", ambos frecuentes en cualquier corpus legal. La especificación no declara una normalización de números ni en el índice ni en la consulta.
CAMBIO: Emitir en cada página el número de norma en sus tres formas (con punto, sin punto, con espacio) como metadato indexable y normalizar la consulta a la forma sin punto antes de enviarla a Pagefind.
PRUEBA: Las 25 normas consultadas en las tres formas: contar cuántas quedan en top-1 por forma. Cualquier diferencia entre formas zanja.
CONFIANZA: media
```

```
ID: A-20
SECCION: §6.3
TIPO: omision
SEVERIDAD: menor
AFIRMACION: Los niveles 1 y 2 se derivan hoy sin campo nuevo: el tipo de norma que ya existe en el catálogo (ley, dfl, dto, rex frente a dictamen, circular) los separa en las 25 normas.
FUNDAMENTO: §6.3 declara la debilidad y propone "escribir la regla"; la regla es una tabla de seis filas sobre un campo existente, no un dato por curar. La síntesis (§4.1) muestra los seis tipos con sus recuentos.
CAMBIO: Tabla explícita tipo de norma → nivel en el constructor, con lista cerrada de tipos y error si aparece uno no contemplado.
PRUEBA: 25 de 25 normas reciben nivel; 0 sin asignar; un tipo inventado en el control negativo detiene la construcción.
CONFIANZA: alta
```

---

## 4.2 Tabla resumen

| ID | SECCION | TIPO | SEVERIDAD | AFIRMACION (recortada) | CONFIANZA |
|---|---|---|---|---|---|
| A-01 | §5.2 | omision | bloqueante | Modelo no nombrado; 384 dims no corresponde al único modelo con precio (1 024) | alta |
| A-02 | §5.2, §9 | defecto | bloqueante | El modelo en navegador pesa 60 a 270 veces el índice; "capa 2 estática" depende de eso | alta |
| A-03 | §5.1, §1 | defecto | mayor | 227 y 1 160 salen de `nchar/4`, no de tokenizador; con 3,5 dan 261 y 1 264 | alta |
| A-04 | §5.1 | defecto | mayor | Umbral de corte 512 y ventana 400 son incompatibles: segmentos de 401 a 512 quedan sin fragmentar | alta |
| A-05 | §5.1 | riesgo | mayor | La ventana ciega corta oraciones e incisos; corte por párrafo primero | alta |
| A-06 | §5.1, §5.2 | omision | mayor | Fragmentos sin desplazamiento ni colapso a segmento antes de fusión | alta |
| A-07 | §5.2, §5.5 | defecto | mayor | K = 30 excluye por construcción la consulta con ancla en rango 65 | alta |
| A-08 | §5.2 | riesgo | mayor | RRF k = 60 entierra el top-1 léxico de consultas con número | media |
| A-09 | §5.2, §7 | omision | mayor | Niveles de reordenamiento y modos de falla sin especificar | alta |
| A-10 | §5.2 | sobreingenieria | menor | int8 ahorra ~1,3 MB donde el término dominante es el modelo | media |
| A-11 | §8 | riesgo | mayor | Hash de documento no invalida por modelo, ventana ni cuantización | alta |
| A-12 | §7, §8 | omision | mayor | No se dice dónde se generan ni dónde viven los vectores | alta |
| A-13 | §6.2, §7 | riesgo | mayor | Arnés solo en cliente: evitable con `curl`; resolución de anclas duplicada en R y JS | alta |
| A-14 | §5.4, §6.2 | defecto | mayor | Compuerta de entrada no impide reproducir OCR desde el entrenamiento; arnés no mide suficiencia | alta |
| A-15 | §5.5 | omision | mayor | n = 10 no distingue motores; faltan consultas sin respuesta y métricas por vía | alta |
| A-16 | §2, §5.3, §8 | defecto | bloqueante | Ancla estable no implica texto estable; piezas firmadas citan texto que cambia sin aviso | alta |
| A-17 | §5.5, §9 | omision | menor | Latencia medida fuera del navegador; falta presupuesto (fría, caliente) | media |
| A-18 | §4.3 | omision | menor | Sin normalización de tildes en la sugerencia | alta |
| A-19 | §5.2 | riesgo | menor | Punto de millar en números de ley rompe la coincidencia léxica | media |
| A-20 | §6.3 | omision | menor | Niveles 1 y 2 se derivan del tipo de norma existente | alta |

---

## 4.3 Respuestas a las seis preguntas abiertas

**1. ¿Se justifica la vía semántica en 806 segmentos?** No ahora. El residuo medido que solo ella rescata es 1 de 10, y su costo real no es el índice de 440 KiB sino el modelo que vectoriza la consulta (A-02), que no está medido ni nombrado (A-01). Umbral de reapertura: cuando, con la tabla de alias curados ya construida y un conjunto de 50 consultas (A-15), el residuo léxico supere 20 %, o cuando exista un registro de consultas reales donde más de un tercio sean oraciones y no términos.

**2. ¿Es correcto excluir el texto sin firma del contexto del modelo?** Sí, y no es negociable mientras el arnés verifique procedencia y no suficiencia (A-14). Que eso deje un tema sin doctrina vigente citable no es un problema del motor: se repara firmando las páginas OCR del dictamen afectado, que son horas de curaduría, no una decisión de diseño. Lo que sí debe hacer el motor es mostrar ese dictamen como "ubicación, no evidencia" en todo modo, incluido el precalculado.

**3. ¿Es defendible el segmento como unidad?** Sí. Es la única unidad con ancla pública y el inciso no la tiene; además hay 87 párrafos que superan por sí solos la ventana, así que el inciso no evita fragmentar. Lo que no es defendible es fragmentar a ciegas dentro del segmento: la fragmentación debe respetar párrafos (A-05) y cada fragmento debe conservar su desplazamiento para resaltar y colapsar (A-06).

**4. ¿El orden de construcción es el mejor?** Casi. Dos cosas van antes de la capa 1: la corrección de la interfaz que mueve la línea base de 0 a 3 de 10 sin ningún motor nuevo (§5.5, costo cero, verificable hoy), y el versionado del texto por ancla (A-16), porque es la única partida cuyo aplazamiento empeora con cada norma que entra. Después: capa 1 derivada, alias curados, vía léxica con expansión, orientación precalculada, y la vía semántica solo si se dispara la condición de la pregunta 1.

**5. ¿Qué le falta para que un equipo no técnico lo use?** Desde el Rol A, tres instrumentos: un registro de consultas anónimo y sin datos personales (es el único dato que hoy no existe y del que depende toda decisión posterior, §9), una respuesta explícita "no está en el corpus" con la lista de lo que sí cubre (A-15), y un formato de cita copiable que lleve ancla, norma y rótulo de nivel en texto plano, para que lo pegado fuera del sitio siga siendo verificable.

**6. ¿Qué es sobreingeniería?** La cuantización int8 (A-10), el reordenamiento en tres niveles sin ganancia medida ni niveles definidos (A-09), y la infraestructura completa de la variante en vivo (Worker, Access, cuota, esquema de cinco modos) mientras existan 0 piezas validadas y dos caminos de fuga abiertos. Todo lo demás (segmento, Pagefind, JSON estático, fusión con piso determinístico) está a escala.

---

## 4.4 Qué NO se cambiaría

- **El segmento como unidad de recuperación (§5.1).** Es la única unidad con ancla pública verificada; cualquier otra rompe el invariante 1.
- **El piso determinístico R0 por metadatos (§5.2).** Garantiza que el orden citable > no citable no dependa de ningún modelo.
- **Alojamiento estático sin base de datos ni almacén (§7).** Los umbrales calculados (~96 normas para int8) están lejos y la decisión es reversible.
- **La compuerta en la entrada y no en la salida (§5.4).** El dato (10,96 % de falso positivo del detector de salida) la sostiene; el problema restante (A-14) es de suficiencia, no de compuerta.
- **Verificar 887 de 887 destinos contra el HTML publicado (§4.2).** Es el hábito que hace auditable todo lo demás y debe extenderse a los fragmentos.
- **Declarar calculado frente a medido (§0, §9).** Sin esa distinción, A-01 a A-04 no habrían sido detectables desde fuera.
- **Rechazar con nombre los tipos de relación que exigen juicio jurídico (§6.4).** Es la aplicación correcta del invariante 5 y evita que un modelo entre por la puerta de atrás.

---

## 4.5 Lo que no se pudo evaluar

- **Nombre, versión, dimensión y largo máximo de secuencia del modelo de embeddings.** Sin eso, A-02, A-03 y A-04 son rangos y no cifras; se necesitaba una línea con esos cuatro datos.
- **La distribución de tokens reales por tipo de segmento (artículo, sección de dictamen, página OCR).** Sin tokenizador real no se puede opinar sobre 400/50 más allá de la convención `nchar/4`.
- **La configuración de Pagefind** (tokenizador, tratamiento de puntuación, cómo puntúa sub-resultados, pesos por elemento). A-19 y la corrección de §5.5 dependen de ella.
- **Las diez consultas de evaluación y sus 19 anclas.** Sin verlas no se puede decir si cubren números, figuras, lenguaje de sala y casos sin respuesta (A-15).
- **La definición de los tres niveles de reordenamiento.** La especificación solo nombra el piso.
- **El esquema de campos del JSON canónico y del manifiesto por hash.** A-11 y A-16 proponen claves y sufijos que podrían ya existir con otro nombre.
- **El código del arnés cliente y su función de resolución de anclas.** Se juzgó su descripción, no su implementación; A-13 asume duplicación R/JS porque la especificación no dice lo contrario.
- **Los límites de Cloudflare se aceptan como verificados por el paquete**; no se reverificaron en esta revisión.
