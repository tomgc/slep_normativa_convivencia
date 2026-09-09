# Especificación técnica — Motor de búsqueda asistida de normativa de convivencia educativa

> **Destino:** `50_documentacion/andamios/20260908_especificacion_motor_busqueda_v1.md`
> **Versión:** 1, 2026-09-08.
> **Propósito:** documento autocontenido para revisión externa. Quien lo lea no tiene acceso al repositorio ni al sitio, así que aquí está todo lo necesario para juzgar el diseño.

---

## 0. Qué es este documento y cuál es su frontera

Este documento describe el diseño de un motor de búsqueda para una biblioteca de normativa chilena de convivencia educativa. El diseño surgió de un encargo de alcance que produjo cinco documentos especializados, una auditoría independiente y una síntesis, con todas sus cifras medidas contra los artefactos reales del proyecto.

**Frontera declarada, importante para quien audite:** esta especificación fue redactada a partir del log de ejecución de ese encargo (1 211 líneas), no de los cinco documentos de alcance completos. Las cifras y decisiones que aquí aparecen están tomadas del log y son fieles a él, pero el detalle canónico de cada especificación vive en los documentos fuente. Donde una cifra sea calculada y no medida, se dice. Donde algo no se midió, se dice.

**Nada de esto está construido.** No existe una línea de código del motor. Existe el sitio actual, con un buscador léxico básico, y existen dos prototipos en R que miden y construyen índices en laboratorio.

---

## 1. El proyecto y su corpus

Ejercicio académico-técnico sobre literatura pública: derecho chileno publicado. Sitio estático que indexa leyes, decretos, circulares, resoluciones y dictámenes **a nivel de artículo**, con cita textual verificable y trazabilidad de fuente. No maneja datos personales. Los usuarios son un equipo pequeño de convivencia escolar de un servicio local de educación.

| Magnitud | Valor |
|---|---|
| Normas | 25 |
| Artículos | 682 |
| Segmentos con ancla estable (unidad real de recuperación) | 806 |
| Relaciones entre normas, derivadas de metadatos | 552, con 67 descartes registrados |
| Páginas temáticas | 17 |
| Piezas interpretativas | 22 en borrador, 0 validadas |
| Texto sin firma humana (OCR) | 84 segmentos en 5 documentos |
| Texto firmado | 722 segmentos en 20 documentos |
| Largo de artículo (caracteres) | mín 59, mediana 888, p90 3 117, máx 27 167 |
| Segmentos sobre 512 tokens | 227 (302 sobre 256; ninguno sobre 8 192) |
| JSON canónico del corpus | 1 881 890 B (431 668 comprimido) |
| Sitio generado | 41 737 491 B |
| Índice léxico actual (Pagefind 1.5.2) | 1 521 719 B |

**Diferencia entre 682 y 806, que importa para todo el diseño:** 682 son los segmentos marcados como artículo. Los otros 124 son preámbulos, secciones de dictamen y páginas de OCR. Todos tienen ancla y todos son recuperables, pero no todos son "artículos". La nomenclatura fijada es: **segmento** para los 806, **artículo** para los 682, **fragmento** solo para el trozo de una ventana deslizante.

---

## 2. Invariantes no negociables

Un diseño que viole cualquiera de estos es inaplicable, por bueno que sea en abstracto.

1. **Cita textual y trazabilidad.** Todo lo que el motor devuelva es rastreable a un segmento con ancla pública estable, o va rotulado como no normativo.
2. **Firma humana sobre lo interpretativo.** Nada interpretativo se publica sin un campo de validación con nombre y fecha. El motor no puede producir contenido que quede indistinguible de contenido validado.
3. **Solo derecho chileno.** No se razona sobre normativa extranjera ni sobre literatura no oficial.
4. **El texto OCR sin firma no es evidencia citable.** Puede mostrarse marcado, nunca como fundamento.
5. **Las relaciones se derivan de metadatos, nunca se infieren.** Un tipo de relación que no se pueda derivar programáticamente no se incorpora. En particular, ningún modelo propone, completa ni genera relaciones entre normas.
6. **La curaduría es de escritura humana exclusiva.** Los metadatos curados tienen procedencia obligatoria por dato y ningún proceso automático escribe en esa capa.

---

## 3. Arquitectura general

Tres capas sobre un sitio estático. Las capas son independientes: cada una funciona si las otras dos no existen.

```
                        consulta del usuario
                                 │
              ┌──────────────────┴──────────────────┐
              │  CAPA 1 · sugerencia mientras se    │   JSON estático
              │  escribe (vocabulario controlado)   │   sin servidor
              └──────────────────┬──────────────────┘
                                 │ consulta bien formada
              ┌──────────────────┴──────────────────┐
              │  CAPA 2 · recuperación híbrida      │
              │  ┌────────────┐    ┌─────────────┐  │
              │  │ vía léxica │    │ vía         │  │
              │  │ (Pagefind) │    │ semántica   │  │
              │  └─────┬──────┘    └──────┬──────┘  │
              │        └────── fusión ────┘         │
              │              reordenamiento         │
              └──────────────────┬──────────────────┘
                                 │ segmentos con ancla
              ┌──────────────────┴──────────────────┐
              │  CAPA 3 · orientación                │
              │  precalculada y firmada (estática)   │
              │  ─────────────────────────────────   │
              │  en vivo, opcional, tras un Worker   │
              └─────────────────────────────────────┘
```

**Alojamiento:** el sitio y las capas 1 y 2 son archivos estáticos servidos desde GitHub Pages. La capa 3 en vivo, si se construye, vive tras un único Worker de Cloudflare cuyo único trabajo es custodiar la clave de la API y limitar el gasto, protegido por Cloudflare Access.

---

## 4. Capa 1 — sugerencia de conceptos mientras se escribe

### 4.1 Qué hace

Mientras el usuario escribe, el sitio propone términos que existen de verdad en el corpus, incluidos los nombres antiguos con que la gente todavía llama a las normas. El objetivo es que la consulta llegue bien formada a la capa 2.

### 4.2 Cómo está construido

- Un único archivo JSON estático, generado por el pipeline desde los artefactos existentes.
- **892 entradas**: 17 temas, 25 normas, 806 segmentos con ancla, 44 términos de glosario.
- **260 alias** y 555 claves de búsqueda, con procedencia declarada por alias.
- **425,5 KB en disco, 21,6 KB comprimidos.** Construcción en 0,247 s.
- **887 de 887 destinos verificados** contra el HTML publicado: ninguna entrada apunta a un ancla que no resuelve.

### 4.3 Reglas de sugerencia

- Coincidencia por prefijo sobre cada token, combinados con AND.
- Un carácter no sugiere nada; dos caracteres sugieren solo temas y normas; tres o más sugieren todo.
- Un segmento hereda las claves de su norma solo si la consulta trae un número.
- Cuando dos archivos son un mismo acto administrativo, la sugerencia resuelve al acto y no al archivo.
- Una norma sustituida se penaliza en el orden pero sigue visible.
- Las páginas de OCR quedan excluidas por defecto; las normas con OCR van rotuladas.
- Los términos de glosario van rotulados como no validados.

### 4.4 Debilidad conocida y medida

El vocabulario derivado del corpus **cubre 21 % de los términos y 3 % de las consultas** de un conjunto de prueba, y **42 % de las consultas no comparten ni una palabra** con él. Un proxy independiente resolvió 11 de 23 consultas humanas. La causa es estructural: el corpus habla en lenguaje legal y el equipo pregunta en lenguaje de sala de clases. La capa 1 útil depende de **alias curados por personas**, que son escritura humana y no trabajo de máquina.

---

## 5. Capa 2 — recuperación híbrida

### 5.1 Unidad de recuperación y fragmentación

- La unidad es el **segmento** (806), no el documento ni el artículo.
- Ventana deslizante de 400 tokens con solape de 50, aplicada **solo a los 227 segmentos largos**. Resultado: 1 160 fragmentos firmados.
- Esta decisión sale de la distribución medida de largos, no de una convención general.

### 5.2 Dos vías simultáneas

- **Vía léxica:** Pagefind, imbatible con números de ley, números de artículo y nombres exactos de figuras jurídicas, que es una porción alta de las consultas reales de este dominio.
- **Vía semántica:** índice de embeddings cuantizado a int8 con 384 dimensiones, servido estáticamente. Peso **calculado** (no medido, porque generar vectores exigía gastar cuota de API): 601,9 KiB en disco, 440,0 KiB transferidos.
- **Fusión por rango recíproco** con constante 60, tomando 30 candidatos por vía.
- **Reordenamiento en tres niveles**, con un nivel determinístico por metadatos como piso, de modo que el sistema degrade a algo predecible si el reordenador no está disponible.

### 5.3 Temporalidad

- Filtro por año de publicación, con marca visible, sin ocultar resultados.
- **Acotación importante:** la pregunta "qué estaba vigente en tal año" **no es respondible** con los datos actuales. Hay una sola sustitución registrada, cuatro años nulos, ningún campo de versión, y al menos un caso de dos redacciones del mismo artículo conviviendo sin relación entre ellas. Lo que sí es respondible es "publicado hasta tal año" más la marca de sustitución.

### 5.4 Tratamiento del texto sin firma

- Los 84 segmentos de OCR se devuelven **marcados y en bloque aparte**, nunca como fundamento citable.
- Para la capa 3, la compuerta va en la **entrada** y no en la salida. Razón medida: un detector aplicado a la salida tuvo 10,96 % de falso positivo sobre frases firmadas reales, mientras que la compuerta de entrada dejó pasar 0 de 27 745 casos.
- Ninguna unidad no citable precede a una firmada en ninguna lista del motor.

### 5.5 Línea base del buscador actual (el hallazgo más importante del diseño)

Se construyó un conjunto de **diez consultas de evaluación** redactadas en el lenguaje del equipo, cada una con su respuesta correcta identificada por ancla, y las 19 anclas verificadas contra el HTML publicado.

**Resultado: el buscador actual devuelve el artículo correcto en 0 de 10 consultas.** La causa no es el índice, que sí las encuentra: la interfaz muestra a lo más tres sub-resultados por norma y en orden de documento, así que el artículo que responde queda oculto bajo otros del mismo cuerpo legal. La corrección es barata y no exige ningún motor nuevo.

Latencia del índice léxico actual, medida fuera del navegador: entre 0,70 y 27,48 ms. Nueve de las diez consultas quedan cubiertas recuperando 28 candidatos o menos.

---

## 6. Capa 3 — orientación sobre cómo abordar un tema

### 6.1 Variante precalculada (la que respeta la compuerta)

- Una **ruta de abordaje** por tema: qué pregunta responde, qué artículos la fundan por ancla, qué pasos sugiere, y qué queda fuera de lo que la normativa resuelve.
- Una **entrada de capa experta** por tema: las formas en que el equipo pregunta por él, qué debe considerarse siempre, y los documentos prioritarios.
- Ambas son piezas firmadas, con nombre y fecha de quien validó, y **pasan la compuerta de publicación vigente sin modificar código** (usan un tipo existente más un subtipo).
- Los campos derivables (nivel, si es citable, vigencia, etiquetas) los calcula el constructor. Un valor declarado a mano que difiera del derivado es un reparo, no una preferencia.
- Estado: una ruta de ejemplo completa con todas sus anclas verificadas, y tres entradas de capa experta construidas.

### 6.2 Variante en vivo (opcional, fuera del alcance actual)

- Prompt de sistema escrito: 5 022 caracteres, 12 reglas, esquema de salida con cinco modos.
- **Arnés antialucinación del lado del cliente**, no del modelo: usa la función real de resolución de anclas, exige que el texto citado sea literal, degrada el OCR a mera ubicación, agrega la advertencia de sustitución desde el dato y **retira toda frase cuya cita no se verifique**.
- Seis casos adversariales especificados con su comportamiento esperado, incluida la consulta que pega datos de un estudiante real.

### 6.3 Cuatro niveles, siempre separados

1. Fuente primaria: lo que dice la norma.
2. Pronunciamiento oficial: cómo la interpreta una autoridad.
3. Orientación experta: cómo el equipo recomienda abordarlo, firmado.
4. Inferencia del modelo: la conclusión generada.

Nunca se mezclan en una misma línea. La marca es **texto plano dentro del bloque**, no solo un color o una insignia, para que el rótulo sobreviva cuando alguien copie la respuesta y la pegue fuera del sitio.

**Debilidad conocida:** los niveles 1 y 2 hoy no se distinguen en los datos. El campo de tipo de fuente tiene un solo valor en las 25 normas, y dos de las cuatro insignias existentes no se usan en ninguna página. Hay que escribir la regla que los derive.

### 6.4 Ontología de relaciones

De los tipos adicionales evaluados, entran los que se derivan programáticamente y se rechazan por escrito los que exigirían juicio jurídico:

| Tipo | Veredicto | Recuento |
|---|---|---|
| modifica | entra, con advertencia de texto no consolidado | 8 pares |
| reglamenta | entra | 2 |
| interpreta | entra como rótulo de remisiones de dictamen | 11 |
| deroga | entra solo como nota marginal a nivel de artículo | 1 |
| complementa, desarrolla, contradice | **rechazados**: ningún metadato los sostiene | — |

---

## 7. Infraestructura

- **Sitio, capa 1 y capa 2:** archivos estáticos en GitHub Pages. Sin servidor, sin base de datos, sin secretos.
- **Capa 3 en vivo:** un único Worker de Cloudflare en su subdominio propio, protegido por Access, cuyo trabajo es custodiar la clave de la API, limitar la tasa por usuario y llevar cuota. La interfaz de esa capa se sirve desde el propio Worker, porque Access responde con error a las peticiones de verificación previa entre orígenes distintos.
- **Se descartaron con números** una base de datos relacional, un almacén de objetos, una base vectorial y el servicio administrado de búsqueda. Los umbrales calculados a partir de los cuales alguno se pagaría solo: unos 4 900 vectores, 5 120 artículos o 188 normas. El corpus está muy por debajo.
- **El servicio administrado de búsqueda se verificó y se descartó** por dos razones técnicas: su tokenizador no ofrece opción de idioma, y su fragmentación fija a 512 tokens rompe la unidad de artículo, que es precisamente la unidad que este proyecto existe para entregar.
- Límites del plan gratuito relevantes: 100 000 solicitudes diarias por Worker, 10 ms de CPU por solicitud (el tiempo de espera de la llamada saliente no cuenta), 50 subsolicitudes por solicitud, 50 usuarios en el control de acceso y 24 horas de retención de registros. Ningún escenario de uso proyectado supera el 5 % de ningún cupo.
- **Degradación:** si el Worker no responde, si se agota la cuota o si la API falla, las capas 1 y 2 siguen funcionando completas, porque son estáticas.

---

## 8. Por qué el diseño costó lo que costó, y por qué mantenerlo será barato

Esta sección existe porque un auditor externo debe entender la economía del sistema, no solo su arquitectura.

- El trabajo caro fue **decidir cómo se hacen las cosas**: cuál es la unidad de recuperación, qué entra al contexto y qué no, qué relaciones son derivables, qué componentes sobran, cómo se rotula lo no validado. Esas decisiones se toman una vez y quedan medidas.
- **Sumar una norma nueva es rutina.** El corpus ya tiene un manifiesto por hash: se deja el archivo canónico en su carpeta, se corre el orquestador y se procesa solo lo nuevo o lo modificado. El vocabulario y los índices se regeneran dentro del mismo pipeline.
- **Requisito de diseño que se deriva de esto:** la vectorización debe ser incremental por hash. Reembeber el corpus completo cada vez que entra un documento es un costo recurrente que este proyecto no debe aceptar.
- **Lo que sí cuesta trabajo humano en cada incorporación:** si el documento llega escaneado, alguien firma su OCR antes de que sea citable; si toca un tema con ruta de abordaje ya escrita, alguien la revisa. Minutos u horas, no jornadas.
- **Vuelve a haber trabajo de diseño mayor solo si** el corpus salta a cientos de normas, cambia la unidad de recuperación, o entra un tipo de documento que el esquema no contempla.

---

## 9. Debilidades conocidas y residuos no medidos

Se declaran para que la revisión externa no gaste esfuerzo en descubrirlos.

**Debilidades del diseño:**

- La utilidad de la capa 1 depende de alias curados por personas, que todavía no existen.
- La temporalidad real (qué regía en una fecha) no es alcanzable con los datos actuales.
- Los niveles 1 y 2 no están distinguidos en los datos.
- El orden de construcción recomendado por el paquete (capa 1 primero) descansa en un supuesto que su propia medición debilitó.

**Problemas del corpus que ninguna capa de búsqueda repara:**

- La ley general de educación del corpus es el texto consolidado a 2010, sin los artículos incorporados después ni las frases insertadas por dos leyes posteriores.
- El procedimiento de expulsión no está en el corpus, pese a que los propios documentos lo mencionan 22 y 17 veces.
- El único dictamen vigente sobre un tema central es OCR sin firma, de modo que la única doctrina citable es la norma sustituida.
- Los preámbulos arrastran la cabecera del sitio de origen en 17 a 19 normas, lo que contamina cualquier índice construido sobre el texto.
- 20 de 39 encabezados del glosario están truncados a 60 caracteres con la definición pegada.
- Dos anclas rotas persisten en piezas en borrador.

**No medido:**

- Bytes reales del índice vectorial: no existe ni un vector. Las cifras son aritmética sobre la dimensionalidad.
- Latencia real en el navegador: nadie escribió el JavaScript de la capa 1.
- Ganancia del reordenamiento y de la descomposición de preguntas: el costo está medido, la ganancia exige un motor que no existe.
- Precio actual de la API del modelo.
- Peso del modelo que vectorizaría la consulta en el navegador.
- **El lenguaje real de las consultas del equipo.** No hay registro de consultas. Todos los conjuntos de prueba son construidos y así están declarados.

---

## 10. Preguntas abiertas sobre las que se busca opinión externa

1. ¿La vía semántica se justifica en un corpus de 806 segmentos, o el esfuerzo rinde más mejorando la vía léxica y el vocabulario?
2. ¿Es correcto excluir el texto sin firma del contexto del modelo, sabiendo que eso deja un tema central sin doctrina vigente citable?
3. ¿Es defendible la unidad de recuperación elegida, o convendría indexar por inciso?
4. ¿El orden de construcción propuesto es el que maximiza valor por esfuerzo, o hay uno mejor?
5. ¿Qué le falta a este diseño para que un equipo no técnico lo use de verdad, más allá de que funcione?
6. ¿Qué parte de este diseño es sobreingeniería para 25 normas y un equipo pequeño?
