# Juicio del encargo v9 — alcance del motor de búsqueda

> **Destino:** `50_documentacion/andamios/20260908_juicio_encargo_v9_v1.md`
> **Emitido:** 2026-09-08, sesión 3, por el Área de Monitoreo.
> **Insumo:** `50_documentacion/andamios/logs/20260904_alcance_motor_busqueda_v9_log.md`, 1 211 líneas, leído íntegro en esta sesión. Las cifras de este juicio se citan del log; las que el propio log declara como calculadas o no medidas se marcan así aquí también.

---

## 1. Veredicto en una línea

El encargo cumplió lo que prometía y produjo un cimiento sólido, pero su hallazgo más valioso no es el motor de búsqueda: es que el buscador actual devuelve el artículo correcto en **0 de 10** consultas de prueba, que la ley principal del corpus está desactualizada y que falta la normativa más citada por los propios documentos.

---

## 2. Lo logrado — producto

### 2.1 Documentos y código versionados

- Cinco documentos de alcance, uno de auditoría (1 193 líneas), una síntesis y el log. Once rutas versionadas, exactamente las diez de la tabla de autorizaciones más el propio encargo (log §6).
- Dos prototipos en R ejecutables: `20260904_prototipo_vocabulario.R` (663 líneas) y `20260904_medicion_corpus_semantica.R` (661 líneas).
- Un esqueleto de Worker en JavaScript (241 líneas, no ejecutado) y 87 archivos de laboratorio con las mediciones crudas.

### 2.2 Capa 1 — vocabulario controlado

- Índice construido y verificado: **892 entradas** (17 temas, 25 normas, 806 encabezados con ancla, 44 del glosario), 260 alias, 555 claves.
- Peso: **425,5 KB en disco, 21,6 KB comprimidos**; construcción en 0,247 s.
- **887 de 887 destinos verificados** contra el sitio real: ninguna entrada apunta a un ancla que no resuelve.
- Las cuatro consultas plantadas del criterio de éxito resueltas, con su control negativo.
- Reglas de sugerencia especificadas al detalle: prefijo por token con AND, umbrales por largo de consulta, herencia de claves, grupo de acto resuelto al acto, norma sustituida penalizada pero visible, páginas OCR excluidas por defecto.

### 2.3 Capa 2 — recuperación

- Corpus dimensionado como unidad de recuperación: **806 segmentos** (no 682 artículos), 227 unidades sobre 512 tokens, 302 sobre 256.
- Fragmentación decidida con la distribución medida: ventana 400/50 solo sobre las 227 largas, resultando en 1 160 fragmentos firmados.
- Índice int8 × 384 dimensiones: **601,9 KiB en disco, 440,0 KiB transferidos** (calculado, no medido: no se generó ni un vector porque gastar cuota estaba prohibido).
- Fusión híbrida especificada con RRF, `k = 60`, K = 30 por vía; reranking en tres niveles con un piso determinístico.
- **Conjunto de evaluación de diez consultas** con sus anclas verificadas (19 de 19 aceptadas, 10 de 10 presentes en el HTML). Este es el activo más reutilizable del encargo: sin él, ninguna mejora futura de búsqueda es demostrable.
- **Línea base medida** del buscador actual, en modo lectura y sin reindexar.

### 2.4 Capa 3 — orientación

- Ruta de abordaje completa de ejemplo (uso de dispositivos móviles), con todas sus anclas verificadas contra el sitio.
- Tres entradas de capa experta construidas, no descritas.
- **Forma que pasa la compuerta de firma vigente sin tocar código**: `tipo: faq` más `subtipo`, verificado contra la compuerta real y no contra su documentación. `tipo: ruta_abordaje` aborta, y ampliar `TIPOS_PIEZA` queda como mejora opcional.
- Prompt del sistema escrito (5 022 caracteres, 12 reglas, esquema de salida con cinco modos) y arnés antialucinación que usa la función real de resolución de anclas, exige texto citado literal y retira toda frase con cita no verificada.
- Ontología de relaciones decidida tipo por tipo con recuento: entran `modifica` (8 pares), `reglamenta` (2), `interpreta` (11 remisiones de dictamen), `deroga` solo como nota marginal (1). Se rechazan por escrito `complementa`, `desarrolla` y `contradice`.

### 2.5 Arquitectura

- **47 citas oficiales con URL verificada** (46 con 200, 1 con 301 del mismo host).
- La pregunta abierta del diseño quedó **resuelta por documentación**: Access sí puede proteger un `workers.dev` sin exigir zona propia. Queda no medido que funcione en el plan gratuito, con un experimento de seis pasos escrito.
- **AI Search verificado y descartado como base** con razones técnicas, no de gusto: su tokenizador no tiene opción de idioma y su fragmentación a 512 tokens rompe la unidad de artículo, que es justamente la unidad que este proyecto existe para dar.
- Stack reducido a GitHub Pages más un Worker que solo custodia la clave. D1, R2, Vectorize y AI Search descartados con umbrales calculados (4 882 vectores, 5 120 artículos, 188 normas). La hipótesis del encargo se intentó refutar y sobrevivió.

---

## 3. Lo logrado — método (lo que de verdad es cimiento)

- **La auditoría se encontró rota a sí misma.** Los dos hallazgos bloqueantes no apuntan a ningún autor: apuntan al instrumento de auditoría, cuya primera versión no detectó tres de los defectos que ella misma había plantado. Eso es el control positivo funcionando exactamente como debe.
- **Nueve reglas de método (M-1 a M-9) fijadas por escrito**, con la M-9 como la más valiosa: todo caso plantado debe ser adversarial contra el instrumento, no benévolo. Un control que el instrumento aprueba por la razón equivocada es indistinguible de un instrumento roto.
- **La corrección se verificó en vez de declararse.** Ronda 1: los cinco autores corrigieron y cuatro de cinco introdujeron defectos nuevos (29 en total). Ronda 2 con regla de reparación quirúrgica: los defectos nuevos cayeron de 29 a 9 y los cinco documentos convergieron. Los 7 graves quedaron cerrados sin reserva.
- **La corrección se detuvo por criterio, no por cansancio.** Los residuos que quedan son cuentas que el documento altera al mencionarse (una fila publica un conteo que se cuenta a sí misma). El encargo previó ese caso y se declararon abiertos en vez de perseguirlos.
- **Las cinco decisiones de paquete se resolvieron midiendo**, no por preferencia: fórmula única del peso del índice, nombre único para las 806 unidades, si el OCR entra al contexto (no entra, y la compuerta va en la entrada porque el detector de salida tiene 10,96 % de falso positivo medido), orden de las unidades no citables, y qué hacer con el laboratorio.
- **La síntesis pasó tres vueltas adversariales** y la última tuvo sesgo explícito a suprimir: quedó más corta que antes (1 076 → 1 072 líneas), porque una cláusula borrada no puede estar mal.
- **Invariantes verificados con comando y control positivo**: `20_insumos/` sin un solo cambio, `40_salidas/` intacto (277 archivos antes y después, mismo mtime máximo), ninguna pieza publicada ni validada, ninguna delegación ejercida ni necesaria.
- **Los cuatro errores del orquestador quedaron registrados con su evidencia**, incluido el que no tiene reparación.

---

## 4. Lo pendiente — decisiones del titular

| # | Decisión | Por qué no la puede tomar la máquina |
|---|---|---|
| 1 | Alias curados del vocabulario | Exigen escribir en `20_insumos/`, que es de firma humana. A1 dejó la propuesta de archivo firmado, sin escribirlo |
| 2 | Versionar el laboratorio (87 archivos, 783,4 KiB) | Tres de sus puntos exigen escribir fuera de las autorizaciones del encargo |
| 3 | Ampliar `TIPOS_PIEZA` para que la ruta de abordaje sea tipo propio | Vive en `30_procesamiento/`; hay forma de evitarlo, así que es preferencia y no necesidad |
| 4 | Publicar los JSON de datos en el sitio | Precondición de una de las variantes del Worker; es cambio de pipeline |
| 5 | Autorizar `platform.claude.com` y `claude.com` | Sin eso, el precio de la API sigue no medido y la aritmética de costos sigue rotulada como provisional |

---

## 5. Lo pendiente — lo que el encargo destapó y no puede arreglar

Esto es lo más importante del paquete y no aparece en su recomendación principal.

- **El buscador actual falla en 0 de 10.** La interfaz muestra a lo más tres sub-resultados por norma y en orden de documento, así que el artículo correcto queda oculto. La corrección es barata (vía `process_result`) y quedó fuera de las autorizaciones de A2. Es la mejora de mayor valor por unidad de esfuerzo de todo el encargo.
- **La LGE del corpus está desactualizada.** Es el texto consolidado al 02-JUL-2010, sin los artículos 16 A a 16 E, y sin las frases insertadas por las leyes 21.801 y 21.809. La ley principal del corpus no dice hoy lo que dice la ley vigente. Ninguna capa de búsqueda repara eso.
- **Falta el procedimiento de expulsión.** El DFL 2/1998 art. 6 letra d y la ley 21.128 ("aula segura") no están en el corpus, y los propios documentos los mencionan 22 y 17 veces. El corpus cita normativa que no contiene.
- **El dictamen 078, que es el vigente, es OCR sin firma.** Resultado perverso: la única doctrina citable sobre revisión de mochilas es la norma sustituida.
- **Siguen dos anclas rotas** en piezas en borrador reales (`faq_revision_de_mochilas`, `faq_seguridad_y_deteccion`), confirmadas contra el cargador real.
- **`aviso_vigencia` es nulo en las 25 normas**: la marca de sustitución sale solo de `vigencia`.
- **Los preámbulos arrastran la cabecera de la BCN** en 17 a 19 normas, lo que contamina cualquier índice que se construya sobre el texto.
- **20 de 39 encabezados del glosario están truncados** a 60 caracteres con la definición pegada, y uno trae un carácter espurio del OCR.
- **`34_generar_paginas.R` y `10_utils.R` todavía usan `$` sobre datos leídos de disco**, mitigado por la opción de advertencia pero no erradicado.
- **El segmentador dejó el cuerpo entero del dictamen 065** (20 769 caracteres) bajo un solo encabezado de fuentes.
- **No hay vigencia por artículo**, y ya hay dos redacciones conviviendo sin relación entre ellas.

---

## 6. Lo pendiente — residuos no medidos

- Precio de la API, por la lista de dominios que yo dejé incompleta. Toda la aritmética de costos está rotulada como provisional.
- Bytes reales del índice vectorial: no existe ni un vector, porque gastar cuota estaba prohibido. Las tres cifras son aritmética sobre la dimensionalidad.
- Latencia real en el navegador: nadie escribió el JavaScript de la capa 1; el prototipo mide construcción, no carga.
- Ganancia del reranking y de la descomposición: el costo está medido, la ganancia exige un motor que todavía no existe.
- Cupo de usuarios de Zero Trust gratuito: la página se arma con JavaScript y `curl` no ve el número.
- CPU real del paso a través en streaming y de la validación del token.
- **Lenguaje real de las consultas del equipo.** A1 usó proxies del corpus, A5 construyó 38 consultas; ambas declaradas como aproximación y no como dato de uso. Este residuo es el que más pesa, y la sección siguiente explica por qué.

---

## 7. Defecto de fondo: la capa 1 no es gratis

- La recomendación del paquete es construir primero la capa 1 "porque cuesta cero". El propio panel adversarial la mide y la deja en mal pie: el vocabulario derivado del corpus cubre **21 % de los términos y 3 % de las consultas**, y **42 % de las consultas no comparten ni una palabra** con él.
- El proxy de A1 apunta a lo mismo: 11 de 23 consultas humanas resueltas.
- La razón es estructural y no se arregla programando: el corpus habla en lenguaje legal y el equipo no.
- Conclusión: la capa 1 útil depende de los **alias curados**, que son escritura humana en `20_insumos/`. Es decir, no es vía B barata: es vía A otra vez, y vuelve a depender del equipo de convivencia.

---

## 8. Errores del emisor del encargo (Área de Monitoreo)

- **Lista de dominios incompleta frente a la verificación exigida.** Dejó a A4 sin poder verificar precios por una redirección de un salto. Es el mismo error que el traspaso v02 ya había registrado de la sesión 2.
- **Paralelismo de cinco agentes contra un límite de sesión.** Siete cortes en cuatro días. La reanudación desde caché evitó perder trabajo, pero convirtió un encargo de una sesión en uno de cuatro.
- **La prohibición de Python quedó con un borde abierto.** Tres subagentes ejecutaron un sondeo de disponibilidad sin usar Python para nada. Cerrado por la regla M-8.
- **El ejemplo de RUT ficticio venía en el propio prompt** a A3, y el hook lo rechazó al pushear. El error nace en el encargo, no en el agente.
- **El mensaje del primer commit contiene una afirmación falsa e inmutable.** Dice que trae la carpeta de laboratorio y no trae ningún archivo suyo. La ventana de corrección se cerró porque se pusheó antes de leer los hallazgos dirigidos al propio orquestador. Enmendarlo exigiría reescribir historia publicada. Queda con la constancia al lado como única reparación.

---

## 9. Juicio sobre la pregunta de fondo

El criterio que fijé al empezar fue: un cimiento sólido no es un documento bien escrito, es una decisión que no hay que volver a tomar. Contra ese criterio:

- **Decisiones que no habrá que relitigar:** la unidad de recuperación son 806 segmentos y no 682 artículos; el stack es GitHub Pages más un Worker y nada más; AI Search no sirve para este corpus y se sabe por qué; el OCR sin firma no entra al contexto y la compuerta va en la entrada; la ruta de abordaje pasa la compuerta vigente sin tocar código; qué tipos de relación son derivables y cuáles no. Seis decisiones firmes con su medición al lado.
- **Activos reutilizables:** el conjunto de diez consultas con anclas verificadas, la línea base del buscador actual, las nueve reglas de método, y dos prototipos que corren.
- **Lo que no quedó firme:** el orden de construcción. La recomendación del paquete (capa 1 primero) descansa en un supuesto que su propio panel adversarial midió y debilitó.
- **Lo que el encargo demostró sin proponérselo:** los tres problemas más caros del proyecto hoy no son de búsqueda, son de corpus (LGE desactualizada, normativa faltante, doctrina vigente no citable) y de interfaz (0 de 10).

**Veredicto:** cimiento sólido, con la reserva de que la prioridad que el paquete recomienda no es la que sus propias mediciones sostienen.
