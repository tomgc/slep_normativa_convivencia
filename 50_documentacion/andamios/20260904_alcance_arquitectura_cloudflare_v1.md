# Alcance de la arquitectura Cloudflare para el motor de búsqueda asistida (A4)

> **Encargo:** v9, `50_documentacion/andamios/20260904_encargo_alcance_motor_busqueda_v1.md`, sección A4.
> **Autor:** A4, encargo v9. **Fecha:** 2026-09-05 (verificaciones de red entre las 06:36 y las 12:16 UTC del mismo día).
> **Naturaleza:** documento de ALCANCE. Nada de lo que describe está desplegado ni probado en vivo: se verifica contra la documentación oficial y se calcula.
> **Artefactos de laboratorio (todos con prefijo `a4_`, en `50_documentacion/andamios/lab_motor_v9/`):** `a4_medir_corpus.R` (recuento propio del corpus), `a4_costos.R` (aritmética de costos), `a4_stack_minimo.R` (aritmética del stack), `a4_citas_verificadas.R` → `a4_citas_verificadas.csv` (cada cita con su URL, código HTTP medido, fecha y frase literal), `a4_worker_esqueleto.js` (esqueleto del Worker, no desplegado ni ejecutado).

**Convenciones de este documento.** Cada afirmación lleva uno de tres rótulos: **verificado** (URL de `developers.cloudflare.com` o `www.cloudflare.com` leída en esta sesión, con la frase literal; los identificadores `Cnn` remiten a la fila del CSV), **calculado** (aritmética en R sobre insumos medidos o declarados, con el script y su salida literal), o **NO MEDIDO / hipótesis** (con el comando que lo zanjaría). Las citas literales se transcriben en inglés tal como aparecen; las rayas largas dentro de ellas son del original. Ningún número proviene de un blog de terceros. Regla de red aplicada: solo `developers.cloudflare.com`, `www.cloudflare.com`, `docs.claude.com` y `www.anthropic.com`; toda redirección a otro host se registró y no se siguió (§4 y §10).

**Lo que este documento NO leyó, a propósito:** los archivos de A1, A2, A3 y A5. Los números del corpus que la tarea 8 pide "medidos por A2" se recontaron aquí de forma independiente (§8.1) y la síntesis los cruzará.

---

## 0. Resumen de decisiones

| Pregunta | Respuesta | Rótulo |
|---|---|---|
| ¿Cabe la capa 3 en vivo en el plan gratuito de Workers? | Sí en solicitudes (100.000/día frente a 500/día en el escenario alto) y en CPU siempre que el cuerpo del modelo pase sin transformarse en JS; la CPU real del paso a través de un streaming queda por medir con el instrumento que la propia documentación nombra | verificado + calculado + NO MEDIDO (§1, §3) |
| ¿Access puede proteger un `workers.dev`? | **Sí, está documentado explícitamente**, y el requisito es Zero Trust habilitado en la cuenta, no una zona propia (§2) | verificado |
| ¿Cuánto cuesta operar la capa 3 en vivo? | Es costo de la API del modelo, no de Cloudflare: con 10 artículos de contexto, entre 1,04 y 5,22 USD/mes (100 consultas) y entre 52 y 261 USD/mes (5.000 consultas), según el modelo; **sobre precio provisional** (§4) | calculado sobre precio NO MEDIDO |
| ¿Qué es AI Search hoy? | Búsqueda híbrida (vector + BM25) con fusión `rrf` o `max`, reranking opcional con `bge-reranker-base`, filtros por metadatos con 8 operadores, gratis en beta abierta con 20.000 consultas/mes en Free; el tokenizador de palabras clave es Porter (inglés) o trigramas, sin opción de idioma (§7) | verificado |
| ¿Qué componentes del stack externo sobreviven? | Ninguno de los cinco (D1, R2, Vectorize, AI Search, Workers AI) resuelve algo que un archivo estático en GitHub Pages no resuelva para 25 normas y 682 artículos. El stack mínimo es GitHub Pages + **un** Worker Free con Access, un secreto y un Durable Object SQLite para la cuota. Workers AI queda como *binding* opcional del mismo Worker (embedding de la consulta y reranking), no como servicio aparte (§8) | calculado |

---

## 1. Límites del plan gratuito, verificados (tarea 1)

Fecha de consulta: 2026-09-05. Comando de verificación de existencia previo a cada lectura: `curl -sI --max-time 20 "<url>"` (salida en §10). Las frases son literales.

### 1.1 Workers Free

Fuente: `https://developers.cloudflare.com/workers/platform/limits/` (la página declara "Last updated Sep 5, 2026") y `https://developers.cloudflare.com/workers/platform/pricing/`.

| Límite | Valor Free | Cita literal | Id |
|---|---|---|---|
| Solicitudes por día | 100.000 | "Requests 100,000/day No limit" (columnas Free / Paid); "Accounts on the Workers Free plan have a daily request limit of 100,000 requests, resetting at midnight UTC. [...] When a Worker exceeds this limit, Cloudflare returns Error 1027." | C01, C02 |
| CPU por invocación | 10 ms | "CPU time 10 ms 5 min" | C01 |
| Subrequests por solicitud | 50 | "Subrequests 50/request 10,000/request" | C01 |
| Tamaño del Worker | 64 MiB sin comprimir | "Worker size (uncompressed) 64 MiB 64 MiB There is no compressed size limit. Only the uncompressed bundle size counts." | C03 |
| Memoria | 128 MB | "Memory 128 MB 128 MB" | C01 |
| Conexiones salientes simultáneas | 6 | "Simultaneous outgoing connections/request 6 6" | C01 |
| Variables de entorno (secretos + texto) | 64 por Worker | "Environment variables 64/Worker 128/Worker" | C01 |
| Número de Workers | 100 | "Number of Workers 100 500" | C01 |
| Duración | sin cargo ni límite duro | "Free 100,000 per day No charge for duration 10 milliseconds of CPU time per invocation" | C08 |

Plan de pago, por si el proxy no cupiera en 10 ms de CPU (§3.3): "Standard 10 million included per month +$0.30 per additional million No charge or limit for duration 30 million CPU milliseconds included per month +$0.02 per additional million CPU milliseconds" (C08) por un mínimo de "$5 USD per month for an account" (misma página, verificado en el volcado).

Servicios auxiliares en Free que el diseño usa o descarta (§5, §8):

| Servicio | Valor Free | Cita literal | Id |
|---|---|---|---|
| Durable Objects | disponibles, solo SQLite; 100.000 solicitudes/día; 100.000 filas escritas/día | "Durable Objects are available both on Workers Free and Workers Paid plans. Workers Free plan: Only Durable Objects with SQLite storage backend are available." / "Requests 100,000 / day" / "Rows written 100,000 / day" | C45 |
| KV | 100.000 lecturas/día, 1.000 escrituras/día, 1 GB | "Keys read 100,000 / day [...] Keys written 1,000 / day [...] Stored data 1 GB" | C46 |
| Workers Logs | 200.000 eventos/día, retención 3 días | "Workers Free 200,000 per day 3 Days" | C47 |
| Rate Limiting (binding) | período 10 o 60 s; contador por ubicación; eventualmente consistente | "Period: the duration of the period, in seconds. Must be either 10 or 60" / "permissive, eventually consistent, and intentionally designed to not be used as an accurate accounting system" | C44 |

**NO MEDIDO:** la página del binding de Rate Limiting no dice en qué planes está disponible (patrón `Free` sin coincidencias en el volcado `cf_ratelimit.txt`; control positivo en el mismo archivo: `Must be either 10 or 60`, 2 coincidencias). Se asume disponible en Free como hipótesis; si no lo estuviera, la cuota diaria del Durable Object (§5.4) cubre sola el límite de tasa, con peor granularidad (día en vez de minuto). Verificar con: `curl -s https://developers.cloudflare.com/workers/runtime-apis/bindings/rate-limit/ | grep -i -c "free"`.

### 1.2 Zero Trust y Access, plan Free

| Dato | Valor | Cita literal y URL | Id |
|---|---|---|---|
| El plan Free existe | sí, sin cargo | "If you chose the Zero Trust Free plan, this step is still needed but you will not be charged." (`/cloudflare-one/setup/`) | C23 |
| **Número máximo de usuarios en Free** | **NO MEDIDO** | La página de planes `https://www.cloudflare.com/plans/zero-trust-services/` responde `HTTP/2 200` pero su contenido lo renderiza JavaScript: el HTML crudo (412.901 bytes, `curl -s`) contiene la palabra "users" solo en la meta descripción y ninguna coincidencia de "seats", "50 users" ni "Up to N users" (script `buscar_usuarios.R` del scratchpad, patrones `\busers\b`, `\bseats?\b`, `\b50\b`). Tampoco lo dicen `seat-management/`, `account-limits/` ni las FAQ de `developers.cloudflare.com`. Lo único verificado sobre asientos: "Cloudflare One subscriptions consist of seats that active users in your account consume. Active users are added to Cloudflare One through any authentication event." (C21). Verificar abriendo la página de planes en un navegador con JavaScript, o cuando se autorice el host desde el que esa página carga sus datos | C22, C21 |
| Retención de logs de Access | **24 horas** en Free (30 días en Standard, 180 en Enterprise) | "Access logs 24 hours 30 days 30 days 24 hours 180 days" (columnas Free / Standard / Access / Gateway / Enterprise), `https://developers.cloudflare.com/cloudflare-one/insights/logs/` | C19 |
| Qué registra un log de autenticación | correo, IP, país, aplicación, permitido o denegado, proveedor de identidad, timestamp, ray id | "User email Email address of the authenticating user. [...] IP address IP address of the authenticating user." y "Authentication logs do not capture the user's actions during a self-hosted or SaaS application session." | C20 |
| Métodos de identidad | proveedor de identidad de Cloudflare (por defecto), PIN por correo, cualquier SAML/OIDC | "Cloudflare automatically adds the Cloudflare identity provider as your default login method" (C23); "Cloudflare supports all SAML and OIDC providers and can integrate with the majority of OAuth providers. [...] You can also send a one-time PIN (OTP) to approved email addresses. No configuration needed — simply add a user's email address to an Access policy" (C24); "OTP is no longer added automatically, but you can set it up at any time [...] This secure PIN expires 10 minutes after the initial request." (C25) | C23, C24, C25 |
| Límites de cuenta de Access (por defecto, sin distinción Free/pago en la página) | 500 aplicaciones, 50 proveedores de identidad, 50 tokens de servicio | "Access Feature Limit Applications 500 [...] Service tokens 50 Identity providers 50 Reusable policies 500 Rules per application 1,000", `https://developers.cloudflare.com/cloudflare-one/account-limits/` | C26 |

**NO MEDIDO:** si algún método de identidad está restringido por plan. Ninguna de las tres páginas leídas (`identity-providers/`, `one-time-pin/`, `setup/`) menciona una restricción (patrón `plan` en `cf_idp.txt` y `cf_otp.txt` sin coincidencias que hablen de restricción; control positivo en `cf_otp.txt`: `expires 10 minutes`, 1 coincidencia). Hipótesis de diseño: PIN por correo sobre una lista de correos permitidos, que es lo que la documentación describe sin configuración.

### 1.3 Vectorize, plan Free

Fuente: `https://developers.cloudflare.com/vectorize/platform/pricing/` y `.../vectorize/platform/limits/`.

| Límite | Valor | Cita literal | Id |
|---|---|---|---|
| Dimensiones consultadas por mes | 30 millones | "Total queried vector dimensions 30 million queried vector dimensions / month" | C27 |
| Dimensiones almacenadas | 5 millones | "Total stored vector dimensions 5 million stored vector dimensions" | C27 |
| Índices por cuenta | 100 en Free | "Indexes per account 50,000 (Workers Paid) / 100 (Free)" | C28 |
| Dimensiones máximas por vector | 1.536, float32 | "Maximum dimensions per vector 1536 dimensions, 32 bits precision" | C28 |
| topK con valores o metadatos | 50 | "Maximum returned results (topK) with values or metadata 50" | C28 |
| Vectores por índice; namespaces | 20.000.000; 1.000 en Free | "Maximum vectors per index 20,000,000 Maximum namespaces per index 50,000 (Workers Paid) / 1000 (Free)" | C28 |

### 1.4 Workers AI, plan Free

Fuente: `https://developers.cloudflare.com/workers-ai/platform/pricing/` y `.../workers-ai/platform/limits/`.

| Límite | Valor | Cita literal | Id |
|---|---|---|---|
| Cupo gratuito | 10.000 neuronas/día; al excederlo, error | "Our free allocation allows anyone to use a total of 10,000 Neurons per day at no charge. [...] If you exceed any one of the above limits, further operations will fail with an error." | C29 |
| Precio en pago | 0,011 USD / 1.000 neuronas | "$0.011 / 1,000 Neurons" | C29 |
| Embedding `bge-m3` | 1.075 neuronas por millón de tokens | "@cf/baai/bge-m3 $0.012 per M input tokens 1075 neurons per M input tokens" | C30 |
| Reranker `bge-reranker-base` | 283 neuronas por millón de tokens | "@cf/baai/bge-reranker-base $0.003 per M input tokens 283 neurons per M input tokens" | C30 |
| Tasa | embeddings 3.000/min; generación 300/min | "Text Embeddings 3000 requests per minute [...] Text Generation 300 requests per minute" | C31 |

---

## 2. ¿Puede Access proteger un subdominio `workers.dev`? (tarea 2)

**Veredicto: sí, y la documentación lo dice de forma explícita en dos páginas distintas.** No exige un dominio propio en una zona de Cloudflare; exige Zero Trust habilitado en la cuenta.

1. Página de `workers.dev`, sección "Manage access to workers.dev" (`https://developers.cloudflare.com/workers/configuration/routing/workers-dev/`): "To require visitors to sign in before they can access a workers.dev URL, use Cloudflare Access. Access can protect one Worker's production workers.dev URL, preview URLs, or both. You can also protect all Workers or all Worker previews in an account. To use details about the signed-in user in your Worker, use ctx.access." (C09)
2. Página de Access para Workers (`https://developers.cloudflare.com/workers/configuration/cloudflare-access/`, "Last updated Aug 18, 2026"), que es a la que enlaza la anterior:
   - requisitos: "Before you start To use Access with Workers, you need: Zero Trust enabled on your account. If Zero Trust is not turned on, complete Zero Trust setup first, then return to the Workers dashboard. Permission to manage Workers and Access applications." (C11). La palabra "zone" no aparece en esa página (patrón `zone`: 0 coincidencias en `cf_workers_access.txt`; control positivo en el mismo archivo: `ctx.access`, 20 coincidencias).
   - alcance: "Protect one Worker Require sign-in on a single Worker. This automatically protects every domain associated with the Worker, including its routes, Custom Domains, workers.dev hostname, and previews." (C12) y, en la tabla de destinos, "A specific hostname — can be workers.dev, a Custom Domain, or a path" (C13).
   - operación: "Dashboard path: Workers & Pages > select your Worker > Access." y "ctx.access is undefined if Access did not authenticate the request." (C14).

**El origen de la duda del diseño externo** es la página genérica de aplicaciones autohospedadas (`.../cloudflare-one/access-controls/applications/http-apps/self-hosted-public-app/`), cuyos requisitos son "An active domain on Cloudflare" y "Domains must belong to an active zone in your Cloudflare account." (C15). Esa es la vía *por hostname de zona*; la vía *por Worker* de la página de Workers no la exige. Ambas coexisten en la documentación y no se contradicen: protegen cosas distintas.

**Lo que la documentación no dice, y por tanto queda NO MEDIDO:** que la vía por Worker funcione con el plan **Zero Trust Free** (la página de Access para Workers no menciona planes: patrón `Free`, 0 coincidencias en `cf_workers_access.txt`, mismo control positivo). La página de setup confirma que el plan Free existe y que se elige en el mismo onboarding (C23), así que la hipótesis es que sí.

**Experimento que lo zanja (no ejecutado: este encargo prohíbe desplegar):**
1. Cuenta de Cloudflare sin ninguna zona. Activar Zero Trust con el plan Free (`/cloudflare-one/setup/`).
2. Desplegar un Worker "hola" en `https://<worker>.<subdominio>.workers.dev/`.
3. En Workers & Pages > el Worker > Access, "Protect this Worker behind Access", "All traffic", política con un solo correo permitido y PIN por correo.
4. `curl -sI https://<worker>.<subdominio>.workers.dev/` debe responder `302` con `location:` hacia `https://<team>.cloudflareaccess.com/...`. Si responde `200` con el cuerpo del Worker, Access no protege el hostname.
5. Iniciar sesión con el PIN en un navegador y comprobar que el Worker devuelve el correo de `ctx.access.getIdentity()`.
6. Control positivo del experimento: repetir el paso 4 tras desactivar Access y exigir `200`.

---

## 3. ¿Cabe el consumo de CPU del proxy en 10 ms? (tarea 3)

### 3.1 Lo que está verificado

- La espera de red no cuenta como CPU: "CPU time measures how long the CPU spends executing your Worker code. Waiting on network requests (such as fetch() calls, KV reads, or database queries) does not count toward CPU time." (`.../workers/platform/limits/`, C04).
- La duración no se cobra ni se limita en HTTP: "No charge for duration" en Free (C08) y "There is no hard limit on duration for HTTP-triggered Workers. As long as the client remains connected, the Worker can continue processing, making subrequests, and streaming a response body." (C05).
- Un Worker que hace streaming sigue vivo: "A Worker that is still streaming a response body remains active." (C06).
- El patrón de paso a través sin búfer es el ejemplo oficial de la API de Streams: "const response = await fetch(request); return new Response(response.body, response);" y "Use the Streams API to avoid buffering large requests or responses in memory." (`.../workers/runtime-apis/streams/`, C43).

Consecuencia de diseño: el Worker de §5 hace exactamente eso con la respuesta del modelo. Su código JS ejecuta antes de la llamada (validar JWT, consultar cuota, armar el cuerpo) y no vuelve a ejecutar por cada fragmento del stream, porque el cuerpo se entrega al runtime como `ReadableStream` y no pasa por un `TransformStream` en JavaScript. Toda validación del contenido (arnés antialucinación de A3) es del lado del cliente, en el navegador, así que no consume CPU del Worker.

### 3.2 Lo que NO está medido

- **La CPU real que consume el paso a través de un streaming.** La documentación afirma que la espera no cuenta y que el Worker sigue activo, pero no cuantifica el costo de CPU de mover los bytes de un `ReadableStream` al cliente. Tampoco cuantifica el costo de la validación del JWT con `jose` (`createRemoteJWKSet` + `jwtVerify`) ni del `JSON.stringify` de un contexto de hasta 60.000 caracteres. Rótulo: NO MEDIDO.
- **Instrumento, nombrado por la propia documentación:** "Workers Logs — CPU time and wall time appear in the invocation log. Tail Workers / Logpush — CPU time and wall time appear at the top level of the Workers Trace Events object." (C07).
- **Experimento (no ejecutado):** desplegar el esqueleto con `observability.enabled = true`, hacer 30 consultas de tamaño "grande" (§4.2) con respuesta en streaming de 1.500 tokens de salida, y leer el `cpuTime` de cada invocación en Workers Logs. Umbral de aceptación: p95 < 8 ms (margen del 20% sobre el límite de 10 ms). Control positivo: una versión del Worker que parsea cada evento SSE en un `TransformStream` debe mostrar CPU claramente mayor; si ambas versiones miden igual, el instrumento no está leyendo lo que creemos.

### 3.3 Degradación si no cabe

Si el p95 superara 10 ms, la salida es el plan Standard: 5 USD/mes con "30 million CPU milliseconds included per month" (C08). A 5.000 consultas/mes (escenario alto), 30 millones de ms de CPU dan 6.000 ms por consulta, tres órdenes de magnitud por encima de lo que un proxy puede necesitar. El riesgo de CPU es, por tanto, de 5 USD/mes, no de viabilidad.

---

## 4. Costo de operación de la capa 3 en vivo (tarea 4)

### 4.1 El precio de la API queda NO MEDIDO (decisión D4 del orquestador, confirmada aquí)

Salida literal de `curl -sI --max-time 20` (2026-09-05, 06:36 y 06:38 UTC), sin seguir redirecciones:

```
### https://docs.claude.com/en/docs/about-claude/pricing
HTTP/2 302
location: https://platform.claude.com/docs/en/about-claude/pricing
### https://docs.claude.com/en/api/pricing
HTTP/2 301
location: https://platform.claude.com/docs/en/api/pricing
### https://www.anthropic.com/pricing
HTTP/2 301
location: https://claude.com/pricing
### https://www.anthropic.com/api
HTTP/2 301
location: https://claude.com/platform/api
### https://docs.claude.com/
HTTP/2 301
location: https://platform.claude.com/docs
### https://docs.claude.com/en/docs/about-claude/models/overview
HTTP/2 302
location: https://platform.claude.com/docs/en/about-claude/models/overview
```

Ninguna de las seis variantes responde `200` en un host autorizado; todas redirigen a `platform.claude.com` o `claude.com`, que no lo están. No se siguió ninguna. **Tabla provisional usada**, con su procedencia declarada textualmente: *fuente: skill `claude-api` de Claude Code leído por el orquestador en esta sesión, tabla de modelos cacheada con fecha 2026-06-24; NO verificada contra `docs.claude.com`, que redirige a un host no autorizado; verificar con `curl -sIL https://docs.claude.com/en/docs/about-claude/pricing` una vez autorizado el dominio destino.* Precios por millón de tokens (entrada / salida, USD): `claude-opus-5` 5,00 / 25,00; `claude-sonnet-5` 2,00 / 10,00; `claude-haiku-4-5` 1,00 / 5,00. **Toda cifra de costo de esta sección es "calculada sobre precio provisional".** No se aplica caché de prompt ni descuento por lote porque no hay precio verificado para ellos.

### 4.2 Supuestos de tamaño de contexto (declarados aquí; A3 no fue leído)

- Largo de artículo **medido** en `a4_costos.R` desde `40_salidas/datos/normas/*.json`, sobre los 682 segmentos con `es_articulo == TRUE`: mediana 888 caracteres, media 1.577,7 caracteres (fuente: salida de `Rscript 50_documentacion/andamios/lab_motor_v9/a4_costos.R`). Se usa la media, porque los artículos largos pesan más en un contexto que la mediana.
- Regla de tokens: **supuesto** 1 token ≈ 4 caracteres (sin tokenizador; sensibilidad a 3 caracteres/token en §4.4). Artículo medio ≈ 395 tokens.
- Prompt del sistema: supuesto 1.500 tokens (2.500 en el tamaño grande, por si incluye la capa experta estructurada de A3). Consulta: 80 tokens. Envoltorio por artículo (id, etiqueta, ancla): 40 tokens.
- Tres tamaños: pequeño (5 artículos, 500 tokens de salida), medio (10, 900), grande (20, 1.500).
- Tres escenarios de uso, en consultas por mes: **bajo 100** (uso esporádico, unas 5 por día hábil), **medio 1.000** (unas 50 por día hábil: uso diario real de un equipo de convivencia de ~20 personas, cifra de tamaño del equipo que es supuesto, no dato), **alto 5.000** (unas 250 por día hábil: techo de planificación, no proyección).

### 4.3 Salida literal de `a4_costos.R` (`Rscript 50_documentacion/andamios/lab_motor_v9/a4_costos.R`, 2026-09-05)

```
control positivo aritmetica: 1M tokens entrada a 2.00 = 2 USD; 1M salida a 10.00 = 10 USD  [OK]

articulos medidos (es_articulo==TRUE): 682 | mediana 888 car. | media 1577.7 car.
regla de tokens: 1 token ~ 4 caracteres (SUPUESTO) -> articulo mediano ~ 223 tokens, medio ~ 395 tokens

== Tamanos de contexto (tokens, regla 4 car./token) ==
  tamano n_articulos tok_sistema tok_consulta tok_salida tok_articulos tok_entrada
 pequeno           5        1500           80        500          2175        3755
   medio          10        1500           80        900          4350        5930
  grande          20        2500           80       1500          8700       11280

== Costo por consulta (USD, calculado sobre precio provisional) ==
  tamano           modelo tok_entrada tok_salida usd_consulta
 pequeno    claude-opus-5        3755        500      0.03127
 pequeno  claude-sonnet-5        3755        500      0.01251
 pequeno claude-haiku-4-5        3755        500      0.00626
   medio    claude-opus-5        5930        900      0.05215
   medio  claude-sonnet-5        5930        900      0.02086
   medio claude-haiku-4-5        5930        900      0.01043
  grande    claude-opus-5       11280       1500      0.09390
  grande  claude-sonnet-5       11280       1500      0.03756
  grande claude-haiku-4-5       11280       1500      0.01878

== Resumen: tamano 'medio' (10 articulos), los tres modelos, los tres escenarios ==
 escenario consultas_mes claude-opus-5 claude-sonnet-5 claude-haiku-4-5
      bajo           100          5.22            2.09             1.04
     medio          1000         52.15           20.86            10.43
      alto          5000        260.75          104.30            52.15

== Sensibilidad: regla 3 car./token, tamano medio, 1000 consultas/mes ==
           modelo tok_entrada usd_consulta usd_mes_1000
 claude-haiku-4-5        7240       0.0117        11.74
    claude-opus-5        7240       0.0587        58.70
  claude-sonnet-5        7240       0.0235        23.48

== Costo adicional de una llamada de descomposicion por consulta (SUPUESTO 680 in / 120 out) ==
           modelo usd_extra_por_consulta usd_extra_mes_1000
    claude-opus-5                 0.0064               6.40
  claude-sonnet-5                 0.0026               2.56
 claude-haiku-4-5                 0.0013               1.28

== Tokens de entrada por mes, tamano medio ==
 escenario consultas_mes tok_entrada_mes tok_salida_mes
      bajo           100          593000          90000
     medio          1000         5930000         900000
      alto          5000        29650000        4500000
```

La tabla completa de los 27 cruces (3 tamaños × 3 modelos × 3 escenarios) está en la salida del script; el rango extremo va de 0,63 USD/mes (pequeño, Haiku, 100 consultas) a 469,50 USD/mes (grande, Opus, 5.000 consultas).

### 4.4 Lectura

- El costo es lineal en consultas y en artículos de contexto; el prompt del sistema pesa poco (1.500 de 5.930 tokens en el tamaño medio).
- Con 3 caracteres por token en vez de 4 (texto legal en español tokeniza peor), el costo sube 12,5% en el tamaño medio (20,86 → 23,48 USD/mes con Sonnet a 1.000 consultas).
- La descomposición en subpreguntas (opción de A3, punto 9) agrega una llamada corta: entre 1,28 y 6,40 USD/mes a 1.000 consultas. Es barata; lo que decide si entra es la ganancia medida sobre las diez consultas de A2, no el costo.
- Nada de esto lo cobra Cloudflare: en Free, el Worker, el Durable Object, los logs y Access cuestan 0 dentro de los cupos de §1 (verificado) y los escenarios no se acercan a ellos (§8.2, calculado).

---

## 5. Especificación del Worker (tarea 5)

Esqueleto en `lab_motor_v9/a4_worker_esqueleto.js` (rotulado: no desplegado, no probado, no ejecutado). Lo que sigue es su contrato.

### 5.1 Diagrama de despliegue, en texto

```
[GitHub Pages]  https://tomgc.github.io/slep_normativa_convivencia/
  |  sitio Quarto (47 HTML), PDF (25), indice Pagefind 1.5.2, estilo.css
  |  capa 1: vocabulario.json (estatico, A1)      -> nunca llama al Worker
  |  capa 2: indice de recuperacion (estatico, A2) -> nunca llama al Worker (*)
  |  capa 3 precalculada: rutas de abordaje firmadas (estatico, A3)
  |  enlace "Orientacion en vivo (no validada)" -> abre el Worker en otra pestana
  v
[Cloudflare, plan Free, sin zona propia]
  Access (Zero Trust Free) ---- protege https://<worker>.<sub>.workers.dev/
     |  politica: lista de correos del equipo, PIN por correo
     |  cada solicitud llega con Cf-Access-Jwt-Assertion; sin sesion -> 302 al login
     v
  Worker "orientacion"
     GET  /              UI minima (mismo origen que la API)
     GET  /api/yo        correo del usuario (ctx.access)
     GET  /api/estado    cuota usada hoy (usuario y global)
     POST /api/orientar  consulta + ids de articulos -> modelo -> streaming al navegador
     |  secreto ANTHROPIC_API_KEY (wrangler secret put; nunca sale del Worker)
     |  binding RAFAGA (Rate Limiting, 10/60 s por correo)
     |  Durable Object CUOTA (SQLite): 30/usuario/dia, 200 global/dia
     |  subrequests: 1 por norma citada (<= 20; limite Free 50) + 1 al modelo
     v
[API del modelo]  fuera de Cloudflare; el unico costo variable (§4)

(*) si A2 decide embeber la consulta con Workers AI, ese unico llamado pasa
    por el mismo Worker (binding AI), detras del mismo Access: §8.3.
```

Por dónde viaja cada solicitud: la navegación normal del sitio nunca toca Cloudflare. Solo el usuario que abre la orientación en vivo entra a Access, se autentica, y desde la UI servida por el Worker hace `POST /api/orientar` al **mismo origen**. El Worker lee los artículos citados desde GitHub Pages (subrequest) o, en la variante alternativa, del cuerpo de la solicitud, llama al modelo y devuelve el stream.

### 5.2 Rutas y contrato de entrada

| Ruta | Método | Entrada | Salida | Errores |
|---|---|---|---|---|
| `/` | GET | ninguna | HTML de la UI (la especifica A3) | 403 si `ctx.access` está indefinido |
| `/api/yo` | GET | ninguna | `{email}` | 403 |
| `/api/estado` | GET | ninguna | `{fecha, usadas_usuario, usadas_global}` | 403 |
| `/api/orientar` | POST | `{consulta: string ≤ 2000, articulos: ["<slug>#<id>", ...] ≤ 20}` | `text/event-stream` del modelo, con encabezado `x-orientacion-validada: no` | 400 entrada inválida; 403 sin identidad; 429 ráfaga o cuota; 502 modelo no disponible |

**Dos variantes para el texto de los artículos, con una condición medida:**
- *Variante "ids" (recomendada):* el cliente manda solo las anclas; el Worker lee `datos/normas/<slug>.json` desde el sitio, toma únicamente segmentos con `es_articulo === true` y arma el contexto. Ventaja: el modelo solo ve texto que existe en el sitio con su ancla, nunca texto OCR (`es_articulo` es `FALSE` en los 84 segmentos de las 5 normas `ocr_pendiente_revision`: recuento en §8.1). **Condición:** hoy el sitio NO publica los JSON de datos: `find 40_salidas/sitio -name '*.json' -not -path '*/pagefind/*'` devuelve solo `40_salidas/sitio/search.json` (comando ejecutado el 2026-09-05; control positivo: `ls 40_salidas/datos/normas/*.json | wc -l` → 25). Publicarlos es un cambio del pipeline (fuera de la autorización de A4) que la síntesis debe decidir; hasta entonces la variante es una hipótesis con una precondición explícita.
- *Variante "textos":* el cliente manda `{ancla, texto}` leídos de los JSON estáticos que publique el sitio. Sin subrequests, pero el Worker no puede garantizar que el texto sea el del sitio. Tope: 60.000 caracteres por solicitud.

### 5.3 Secreto

- Se carga con `npx wrangler secret put ANTHROPIC_API_KEY` y se lee como `env.ANTHROPIC_API_KEY`. "Secrets are environment variables. The difference is secret values are not visible within Wrangler or Cloudflare dashboard after you define them." (C42).
- Nunca aparece en `wrangler.jsonc`, en el repositorio ni en el navegador; en desarrollo local vive en `.dev.vars`, que la misma página manda a `.gitignore`. Este repositorio es público: el archivo `.dev.vars` no debe crearse dentro de él.
- Defensa en profundidad además de Access: el Worker valida el JWT que Access agrega, siguiendo el ejemplo oficial con `jose`: "We recommend validating the Cf-Access-Jwt-Assertion header instead of the CF_Authorization cookie, since the cookie is not guaranteed to be passed." y claves en `https://<team>.cloudflareaccess.com/cdn-cgi/access/certs` (C16). Si el JWT falta o no valida, 403 antes de tocar el secreto.

### 5.4 Límite de tasa por usuario

Dos capas, porque la documentación dice que el binding de Rate Limiting no es un contador exacto (C44):
1. **Ráfaga**, binding `RAFAGA` con `{limit: 10, period: 60}` y clave = correo de `ctx.access`. Corta abuso por minuto; es local a cada ubicación de Cloudflare y eventualmente consistente, lo que aquí basta.
2. **Cuota diaria**, Durable Object `CUOTA` con SQLite (disponible en Free, C45): tabla `(fecha, email, n)`, tope 30 por usuario y 200 global por día (declarados a partir del escenario alto: 5.000/mes ≈ 167/día; el tope global de 200 deja margen y acota el gasto máximo diario a 200 × 0,05 USD ≈ 10 USD con Opus en tamaño medio, calculado sobre precio provisional). Consumo: 1 fila escrita por consulta; a 5.000/mes son 167 filas/día, el 0,167% del cupo Free de 100.000 filas escritas/día (`a4_stack_minimo.R`). KV habría servido (1.000 escrituras/día, 16,7% en el escenario alto) pero es eventualmente consistente y no ofrece la transacción "leer y sumar" que el contador necesita.

### 5.5 CORS contra el origen de GitHub Pages

**Recomendación: no hay CORS, porque la UI de la capa 3 se sirve desde el propio Worker** (mismo origen que `/api/*`). El sitio estático solo enlaza al Worker. Razones verificadas:
- Access bloquea el *preflight*: "If you make a preflighted cross-origin request to an Access-protected domain, the OPTIONS request will return a 403 error. This error occurs regardless of whether you have logged in to the domain. This is because the browser never includes cookies with OPTIONS requests, by design." (C17) y "For a CORS request to reach a site protected by Access, the request must include a valid CF-Authorization cookie." (C18).
- Un `fetch()` desde `https://tomgc.github.io` a un Worker protegido, sin sesión, recibe la redirección al login dentro del `fetch`, no una navegación: el usuario no ve la pantalla de acceso. Con la UI en el Worker, la primera visita es una navegación y Access la maneja.

Si la síntesis prefiriera de todos modos llamar desde el sitio estático, la política sería: `Access-Control-Allow-Origin: https://tomgc.github.io` exacto (nunca `*`), `Access-Control-Allow-Credentials: true`, `Access-Control-Allow-Methods: POST`, `Access-Control-Allow-Headers: Content-Type`, configurados en la aplicación de Access ("Configure Cloudflare to respond to the OPTIONS request", opción 2 de la página de CORS) y `fetch(..., {credentials: "include"})` en el cliente. **NO MEDIDO:** si la cookie `CF_Authorization` viaja entre sitios (atributo `SameSite`); la página de CORS no lo dice. Experimento: tras iniciar sesión en el Worker, ejecutar desde la consola del navegador en `tomgc.github.io` un `fetch` con `credentials: "include"` y observar si llega `200` o `302`.

### 5.6 Qué se registra y qué no

| Se registra (Workers Logs, `console.log` de una línea JSON) | No se registra nunca |
|---|---|
| timestamp, correo del usuario, número de artículos, modelo, estado HTTP, resultado de cuota | el texto de la consulta, los textos de los artículos, la salida del modelo, la clave de la API, el cuerpo de error del proveedor |

Retención en Free: 3 días, 200.000 eventos/día (C47). Los logs de invocación automáticos incluyen "the Request, Response, and related metadata" (C47): la URL y el método, no el cuerpo; por eso la consulta va en el cuerpo del `POST` y nunca en la URL. Access registra por su lado correo, IP y país de cada autenticación con 24 horas de retención en Free (C19, C20). Un `Tail Worker` o `Logpush` no entra: no hay razón de negocio para retener más.

---

## 6. Plan de degradación (tarea 6)

La capa 1 (vocabulario estático) y la capa 2 (índice estático) viven en GitHub Pages y **nunca llaman al Worker** (§5.1): en los tres casos siguen funcionando sin cambio. La capa 3 precalculada (rutas de abordaje firmadas, estática) es el contenido de respaldo que la UI muestra cuando la variante en vivo no responde.

| Caso | Qué pasa técnicamente | Qué ve el usuario | Cita |
|---|---|---|---|
| El Worker no responde (caído, sin red, Access sin sesión válida) | `fetch` falla, expira (timeout del cliente 20 s) o devuelve `302`/`403` | Aviso "La orientación en vivo no está disponible; abajo está la ruta de abordaje validada para este tema" y el enlace a la ruta precalculada. Si es `302`/`403`: botón "Volver a iniciar sesión" que hace una navegación a `/` | C14 (403 sin `ctx.access`) |
| Se agota la cuota diaria (usuario o global) | el Durable Object responde `429` con `{error: "cuota_diaria_usuario"|"cuota_diaria_global", usadas, max}` | "Se alcanzó el cupo diario (N de M). Vuelve mañana; la ruta de abordaje validada sigue disponible". `/api/estado` permite mostrar el contador antes de enviar | §5.4 |
| Se agota el cupo de 100.000 solicitudes/día del plan Free (improbable: 500/día en el escenario alto) | Cloudflare devuelve Error 1027 sin ejecutar el Worker | Mismo aviso del primer caso: para el cliente es un Worker que no responde | C02 |
| La API del modelo devuelve error o expira | el Worker responde `502` con `{error: "modelo_no_disponible", estado_proveedor}` sin reenviar el cuerpo del proveedor | "El modelo no respondió (código N). Puedes reintentar en un minuto" con el botón de reintento sujeto al límite de ráfaga; la ruta precalculada queda visible | §5.2 |
| El stream se corta a mitad | el navegador recibe un `event-stream` incompleto | El arnés del cliente (A3) rechaza una salida sin cierre válido y muestra "Respuesta incompleta; no se muestra" en vez de un fragmento que parezca completo | C05, C06 |

Regla de rotulado que sobrevive a todos los casos: cualquier texto que provenga del Worker lleva el encabezado `x-orientacion-validada: no` y la UI lo pinta con la insignia de "inferencia del modelo" (nivel 4 de A3); ninguna degradación puede hacer que un fragmento del modelo se muestre con la insignia de contenido validado, porque las insignias las decide el origen del dato, no el estado del servicio.

---

## 7. Cloudflare AI Search: qué es y qué soporta hoy (tarea 7)

Fecha de consulta 2026-09-05. La página de inicio declara "Last updated Jul 6, 2026". `https://developers.cloudflare.com/autorag/` redirige (`301`) a `/ai-search/`: AI Search es el nombre actual de AutoRAG.

| Pregunta del encargo | Respuesta verificada | Cita literal | Id |
|---|---|---|---|
| ¿Qué es? | Búsqueda administrada (indexación, embedding, vector + BM25, fusión, reranking, generación opcional) sobre archivos subidos o una fuente conectada | "AI Search lets you add search to any application or agent without having to build an entire retrieval infrastructure." (`/ai-search/`, verificado en el volcado) | C32 |
| ¿Híbrida administrada? | Sí | "When hybrid search is enabled, a BM25 keyword search runs in parallel with vector search." | C33 |
| ¿Con qué método de fusión? | `rrf` (Reciprocal Rank Fusion, por defecto) o `max` | "rrf Yes Reciprocal Rank Fusion. Scores results based on rank position across both search methods. Recommended for most use cases. max No Takes the higher of the normalized vector and keyword scores." | C34 |
| ¿Conserva los puntajes de cada motor? | Sí, en `scoring_details` | "vector_score number Vector similarity score (0 to 1). keyword_score number Raw BM25 keyword score. vector_rank number [...] keyword_rank number [...] fusion_method string [...] reranking_score number Score from the reranking model, if enabled." | C35 |
| ¿Incluye reranking? | Sí, opcional, apagado por defecto, con `@cf/baai/bge-reranker-base` (cross-encoder, 512 tokens de entrada) | "By default, reranking is disabled for all AI Search instances." / "A cross-encoder model re-scores results by evaluating the query and document together." / "@cf/baai/bge-reranker-base 512" | C36, C33, C41 |
| ¿Qué filtros por metadatos? | `$eq $ne $in $nin $lt $lte $gt $gte`, AND implícito entre claves; **máximo 5 campos de metadatos personalizados por instancia** | "$eq Equals $ne Not equals $in [...] $gte Greater than or equal to [...] Multiple conditions (implicit AND)" / "Max custom metadata fields 5 per AI Search instance" | C37, C39 |
| ¿Qué hay en el plan gratuito? | Todo lo anterior; AI Search es gratis en beta abierta, Workers AI se cobra aparte (dentro de su propio cupo Free de 10.000 neuronas/día) | "During the open beta, AI Search is free within these limits. Workers AI and AI Gateway usage is billed separately. Pricing details will be communicated at least 30 days before any billing begins." / Free: "AI Search instances per account 100 [...] Files per instance 100,000 [...] Max file size 4 MB [...] Queries per month 20,000 [...] Maximum pages crawled per day 500" | C38, C39 |
| Tokenizador de palabras clave | `porter` (stemming de Porter, por defecto) o `trigram`; **no hay opción de idioma** | "porter Yes Applies Porter stemming. \"running\" matches \"run.\" Best for natural language. trigram No Overlapping 3-character windows." | C40 |
| Modelo de embedding | `@cf/baai/bge-m3`, 1.024 dimensiones, 512 tokens de entrada por fragmento | "Workers AI @cf/baai/bge-m3 1,024 512 cosine" | C41 |

**Lo que la verificación cambia respecto del diseño externo:**
1. Las afirmaciones del diseño externo sobre híbrida, fusión y reranking **sí tienen respaldo hoy** en la documentación oficial; dejan de ser hipótesis.
2. Aparecen tres restricciones que el diseño externo no vio: (a) el stemmer es Porter, que es un algoritmo para inglés; para "sostenedor / sostenedores" o "expulsión / expulsiones" el comportamiento en español está **NO MEDIDO** (la página no lista idiomas: patrón `language` en `cf_ais_keyword.txt` solo aparece en "Best for natural language"; control positivo: `porter`, 2 coincidencias); (b) el corte en fragmentos es de AI Search ("The extracted text is chunked into smaller pieces", `how-ai-search-works`, verificado en el volcado) y el embedding admite 512 tokens: un artículo de 27.167 caracteres (máximo medido, §8.1) se parte en varios fragmentos y **la unidad de cita deja de ser el artículo**, que es el invariante 1 del encargo; (c) 5 campos de metadatos personalizados: `slug`, `tipo`, `anio`, `vigencia` y `origen_texto` los agotan sin dejar sitio a `tema`.
3. La exclusión del OCR sin revisar sería posible con un filtro `origen_texto: {$ne: "ocr_pendiente_revision"}`, a costa de uno de los 5 campos.

Veredicto para el diseño: **verificado como servicio, descartado como base** (§8.4), y utilizable solo como experimento medible contra las diez consultas de A2 si la síntesis lo pide.

---

## 8. Stack mínimo, no máximo (tarea 8)

### 8.1 Números del corpus, recuento propio (`Rscript 50_documentacion/andamios/lab_motor_v9/a4_medir_corpus.R`, 2026-09-05)

| Cifra | Valor | Cómo se contó |
|---|---|---|
| Normas | 25 | `length(dir_ls("40_salidas/datos/normas", glob="*.json"))`; coincide con `catalogo[["n_normas"]]` = 25 |
| Artículos (`es_articulo == TRUE`) | 682 | suma sobre los 25 JSON; coincide con `catalogo[["n_articulos"]]` = 682 y con la suma de `n_articulos` por norma |
| Segmentos totales en `articulos[]` | 806 (682 artículos + 124 no artículo) | mismo script |
| Normas con texto OCR sin revisar | 5 (`origen_texto == "ocr_pendiente_revision"`), 84 segmentos, 0 artículos, 224.276 caracteres | `count(origen_texto)` y `summarise(.by = origen_texto)`. La cifra heredada "84 páginas en 5 documentos" del encargo §0 **se confirma** |
| Relaciones | 552 (tema 502, remisión 46, sustitución 2, grupo_acto 2) | `length(rel[["relaciones"]])` = `rel[["n_relaciones"]]` = 552 |
| Caracteres | 1.429.841 en los 806 segmentos (1.460.356 bytes); 1.075.967 en los 682 artículos | `nchar(texto, type = "chars")` |
| Largo de artículo | mín 59, mediana 888, p90 3.117, p95 4.610, máx 27.167, media 1.577,7 caracteres | `quantile()` sobre los 682 |
| Peso de los datos canónicos | 1.881.890 bytes en disco; 431.668 bytes gzip (catálogo 31.570 → 4.899; relaciones 257.530 → 8.967; 25 normas 1.592.790 → 417.802) | `file_size()` y `memCompress(type = "gzip")` |
| Sitio generado | 148 archivos, 41.737.491 bytes; 47 HTML; PDF 25 archivos, 34.337.933 bytes (idénticos en bytes a `20_insumos/normativa/`); Pagefind 55 archivos, 1.521.719 bytes, versión 1.5.2 | `dir_info(recurse = TRUE)` y `pagefind-entry.json` |

Todos los enunciados universales de esta sección ("los 25", "los 682", "los 806") se sostienen en el recorrido exhaustivo de ese script sobre `40_salidas/datos/normas/*.json`.

### 8.2 Aritmética del stack (`Rscript 50_documentacion/andamios/lab_motor_v9/a4_stack_minimo.R`, salida literal, 2026-09-05)

```
corpus medido: 25 normas | 682 articulos | 806 segmentos | 552 relaciones | 1429841 caracteres (todo) | 1075967 caracteres (articulos)

== Vectorize: dimensiones (Free: 5,000,000 almacenadas; 30,000,000 consultadas/mes) ==
dims  384: almacenadas    261888 (5.2% del cupo) | consultadas/mes a 100/1000/5000 consultas: 38400 / 384000 / 1920000
dims  768: almacenadas    523776 (10.5% del cupo) | consultadas/mes a 100/1000/5000 consultas: 76800 / 768000 / 3840000
dims 1024: almacenadas    698368 (14.0% del cupo) | consultadas/mes a 100/1000/5000 consultas: 102400 / 1024000 / 5120000
vectores que agotan el cupo Free de almacenamiento a 1024 dims: 4882 (= 179.0 normas de 27.3 articulos)

== Indice de embeddings estatico (bytes; sin comprimir) ==
dims  384: float32   1047552 | int8   261888
dims  768: float32   2095104 | int8   523776
dims 1024: float32   2793472 | int8   698368
articulos con los que un indice int8 de 1024 dims supera 5 MiB: 5120 (= 188 normas de este tamano)
articulos con los que un indice float32 de 1024 dims supera 5 MiB: 1280 (= 47 normas)

== Workers AI (neuronas; cupo Free 10,000/dia) ==
embeber todo el corpus una vez con bge-m3: 357461 tokens -> 384.3 neuronas (3.84% del cupo diario)
embeber una consulta (80 tokens): 0.0860 neuronas -> 5000/mes = 430.0 neuronas/mes
reordenar 20 candidatos de 1578 car. medios (+ consulta): 9500 tokens -> 2.69 neuronas/consulta -> 5000/mes = 13442 neuronas/mes = 448/dia

== Workers Free: 100,000 solicitudes/dia ==
  100 consultas/mes -> 3.3/dia (x3 solicitudes por consulta: 10.0/dia = 0.0100% del cupo)
 1000 consultas/mes -> 33.3/dia (x3 solicitudes por consulta: 100.0/dia = 0.1000% del cupo)
 5000 consultas/mes -> 166.7/dia (x3 solicitudes por consulta: 500.0/dia = 0.5000% del cupo)

== KV Free (1,000 escrituras/dia) y DO Free (100,000 filas escritas/dia) frente al contador de cuota ==
  100 consultas/mes -> 3.3 escrituras/dia: KV 0.3% | DO 0.003%
 1000 consultas/mes -> 33.3 escrituras/dia: KV 3.3% | DO 0.033%
 5000 consultas/mes -> 166.7 escrituras/dia: KV 16.7% | DO 0.167%

== Peso estatico de lo que D1 guardaria ==
catalogo.json       31570 bytes | gzip   4899 | por norma gzip 196
relaciones.json    257530 bytes | gzip   8967 | por norma gzip 359
normas/*.json     1592790 bytes | gzip 417802 | por norma gzip 16712
extrapolacion LINEAL (hipotesis) a 100 normas: normas gzip ~ 1632 KB, relaciones gzip ~ 35 KB
```

Regla de tokens en este script: supuesto 1 token ≈ 4 caracteres, igual que en §4.

### 8.3 Veredicto por componente

Prueba que cada componente debe pasar: (a) qué problema resuelve que un archivo estático servido desde GitHub Pages no resuelva; (b) a partir de qué tamaño de corpus empieza a pagarse; (c) qué mantenimiento agrega. **Un componente que no pasa (a) se descarta.**

| Componente | (a) Problema que resolvería | Lo que el estático ya hace, con número | (b) Umbral en que empezaría a pagarse | (c) Mantenimiento que agrega | Veredicto |
|---|---|---|---|---|---|
| **D1** (SQL) | consultas relacionales sobre normas, artículos y relaciones | `relaciones.json` pesa 8.967 bytes gzip y `catalogo.json` 4.899 bytes gzip: el grafo completo de 552 aristas viaja en menos de 14 KB y se filtra en el navegador en O(552). Extrapolación lineal a 100 normas: ~35 KB gzip (hipótesis) | cuando haya escrituras por usuario (anotaciones, historial) o el grafo deje de caber en una descarga razonable (órdenes de magnitud por encima de 100 normas) | esquema, migraciones, sincronización con los JSON que el pipeline ya genera (dos fuentes de verdad) | **Descartado** |
| **R2** (objetos) | servir PDF y JSON | GitHub Pages ya sirve los 25 PDF (34.337.933 bytes) y 47 HTML; los JSON canónicos suman 431.668 bytes gzip | cuando el sitio supere los límites de GitHub Pages (**NO MEDIDO**: `github.com` no está autorizado para leer su documentación; verificar con `curl -sI https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits` cuando se autorice) o cuando haga falta subir archivos desde el navegador | un bucket, credenciales y un segundo despliegue | **Descartado** |
| **Vectorize** (índice vectorial) | búsqueda por similitud sin descargar el índice | un índice int8 de 1.024 dimensiones para 682 artículos pesa 698.368 bytes (float32: 2.793.472). Cabe en una descarga estática; en Vectorize Free ocuparía el 14,0% del cupo de almacenamiento y el 3,4% del de consulta a 5.000 consultas/mes | a partir de ~5.120 artículos (188 normas de este tamaño) el índice int8 supera 5 MiB; a partir de 4.882 vectores de 1.024 dims también se agota el Free de Vectorize, así que a esa escala Vectorize es de pago | índice fuera del repositorio; reindexar en cada corrida del pipeline con `wrangler`; llaves y dimensiones acopladas al modelo | **Descartado para 25 normas**; reevaluar por encima de ~150 normas. Lo que Vectorize no evita de todos modos es el embedding de la consulta en runtime, que necesita un modelo: §8.4 |
| **AI Search** (RAG administrado) | híbrida + RRF + reranking + filtros sin escribir código | Pagefind 1.5.2 (1.521.719 bytes) ya da la vía léxica a nivel de artículo con anclas estables; la vía vectorial cabe estática (fila anterior). AI Search rompe la unidad de artículo (fragmentos de 512 tokens), su stemmer es Porter (inglés) y admite 5 campos de metadatos (§7) | cuando el corpus deje de caber estático **y** el equipo acepte citas por fragmento en vez de por artículo | una instancia, subir 25 archivos en cada corrida, mapear fragmentos a anclas, vigilar el fin de la beta (precio no anunciado, C38) | **Descartado como base**; admisible solo como experimento con las diez consultas de A2 |
| **Workers AI** (inferencia) | embeber la consulta y reordenar candidatos | no hay equivalente estático: embeber la consulta en el navegador exige descargar un modelo (decenas de MB, NO MEDIDO). Costo en Cloudflare: 0,086 neuronas por consulta; reordenar 20 candidatos, 2,69 neuronas; 448 neuronas/día en el escenario alto, el 4,5% del cupo Free; embeber el corpus entero una vez, 384 neuronas | desde el primer día si A2 elige la vía vectorial; nunca si A2 elige Pagefind + sinónimos de A1 | ninguno adicional al Worker: es un *binding* del mismo Worker, detrás del mismo Access | **Se conserva como binding opcional del Worker existente**, no como servicio aparte; la decisión de usarlo es de A2 |

### 8.4 Conclusión

La hipótesis por defecto del encargo ("casi todo cabe estático y el Worker existe solo para custodiar la clave") **se intentó refutar con datos y sobrevive**: ningún cupo Free se acerca al 20% en el escenario alto (solicitudes 0,5%, filas del Durable Object 0,167%, neuronas 4,5%, y Vectorize ni siquiera se usa), y ningún artefacto estático supera 3 MB salvo los PDF que GitHub Pages ya sirve. El único argumento a favor de un servicio adicional es el embedding de la consulta en runtime, y ese servicio (Workers AI) se resuelve como *binding* del Worker que de todos modos hay que desplegar para la clave.

**Stack mínimo resultante:** GitHub Pages (sitio, PDF, Pagefind, `vocabulario.json`, índice vectorial estático si A2 lo adopta, rutas de abordaje firmadas, y los JSON de datos si se decide publicarlos) + un Worker Free en `workers.dev` protegido por Access (Zero Trust Free) con un secreto, un binding de Rate Limiting, un Durable Object SQLite y, opcionalmente, un binding de Workers AI. Sin zona propia, sin D1, sin R2, sin Vectorize, sin AI Search.

**Riesgo declarado del stack mínimo:** "Your workers.dev subdomain is treated as a Free website and is intended for personal or hobby projects that aren't business-critical." (C10). Para un ejercicio académico-técnico (§0 del encargo) eso es coherente; si el servicio pasara a ser institucional, el primer cambio sería un dominio propio, y con él la vía por hostname de zona de Access (C15).

---

## 9. Citas y cifras

Tabla completa, con código HTTP medido programáticamente el 2026-09-05 por `a4_citas_verificadas.R` (HEAD sin seguir redirecciones, guarda de hosts autorizados antes de tocar la red), en `lab_motor_v9/a4_citas_verificadas.csv` (56 filas: 47 con estado `verificado`, de las cuales 46 responden `200` y 1 es la redirección `301` dentro del mismo host; 7 `no_medido`; 2 controles). Códigos HTTP medidos en el CSV: 48 × `200`, 5 × `301`, 2 × `302`, 1 × `404`. Resumen por dato:

| Dato | URL o comando | Estado |
|---|---|---|
| Workers Free: 100.000 solicitudes/día, 10 ms CPU, 50 subrequests, 64 MiB, 128 MB, 6 conexiones | `https://developers.cloudflare.com/workers/platform/limits/` (C01, C02, C03) | verificado |
| CPU: la espera de red no cuenta; sin límite de duración HTTP; streaming mantiene activo el Worker | misma URL (C04, C05, C06, C07) | verificado |
| Workers Free "No charge for duration"; Standard 5 USD, 30 M ms de CPU | `https://developers.cloudflare.com/workers/platform/pricing/` (C08) | verificado |
| Access protege `workers.dev`; requisito Zero Trust, no zona; `ctx.access` | `.../workers/configuration/routing/workers-dev/` (C09, C10); `.../workers/configuration/cloudflare-access/` (C11 a C14) | verificado |
| App autohospedada genérica exige zona activa | `.../cloudflare-one/access-controls/applications/http-apps/self-hosted-public-app/` (C15) | verificado |
| Validación del JWT; CORS 403 en OPTIONS | `.../authorization-cookie/validating-json/` (C16); `.../authorization-cookie/cors/` (C17, C18) | verificado |
| Retención de logs de Access 24 h en Free; campos del log | `.../cloudflare-one/insights/logs/` (C19); `.../access-authentication-logs/` (C20) | verificado |
| Asientos por autenticación; plan Free existe; métodos de identidad; límites de Access | C21, C23, C24, C25, C26 | verificado |
| **Usuarios máximos en Zero Trust Free** | `https://www.cloudflare.com/plans/zero-trust-services/` (C22) | **NO MEDIDO** (contenido renderizado por JavaScript) |
| Vectorize Free: 30 M dims consultadas/mes, 5 M almacenadas; 100 índices; 1.536 dims; topK 50 | `.../vectorize/platform/pricing/` (C27); `.../vectorize/platform/limits/` (C28) | verificado |
| Workers AI Free: 10.000 neuronas/día; bge-m3 1.075 y reranker 283 neuronas/M tokens; tasas | `.../workers-ai/platform/pricing/` (C29, C30); `.../workers-ai/platform/limits/` (C31) | verificado |
| AI Search: híbrida, BM25, `rrf`/`max`, `scoring_details`, reranking opcional, 8 operadores de filtro, gratis en beta, 20.000 consultas/mes, 5 campos de metadatos, Porter/trigram, bge-m3 1.024/512 | `.../ai-search/` y subpáginas (C32 a C41) | verificado |
| Secretos, Streams, Rate Limiting, Durable Objects, KV, Workers Logs | C42 a C47 | verificado |
| Precio de la API del modelo | `docs.claude.com` y `www.anthropic.com` (C48 a C53): 6 redirecciones a hosts no autorizados, salida literal en §4.1 | **NO MEDIDO**; aritmética sobre tabla provisional |
| Control positivo: URL existente → 200; control negativo: URL inventada → 404 | C54: `https://developers.cloudflare.com/workers/platform/limits/` → `HTTP/2 200`; C55: `https://developers.cloudflare.com/esta-url-no-existe-a4-control-negativo-v9/` → `HTTP/2 404` (curl -sI 06:36 UTC y HEAD desde R 12:16 UTC, misma salida) | control |
| 25 normas, 682 artículos, 806 segmentos, 5 normas OCR con 84 segmentos, 552 relaciones, caracteres, largos, pesos, sitio | `Rscript 50_documentacion/andamios/lab_motor_v9/a4_medir_corpus.R` (§8.1) | calculado (recuento propio) |
| Costos por consulta y por mes; sensibilidad; descomposición | `Rscript 50_documentacion/andamios/lab_motor_v9/a4_costos.R` (§4.3) | calculado sobre precio provisional |
| Dimensiones en Vectorize, peso del índice estático, neuronas, porcentaje de cupos, umbrales | `Rscript 50_documentacion/andamios/lab_motor_v9/a4_stack_minimo.R` (§8.2) | calculado |
| El sitio no publica los JSON de datos | `find 40_salidas/sitio -name '*.json' -not -path '*/pagefind/*'` → solo `search.json` | verificado (repositorio) |
| Sitio publicado y origen: `https://tomgc.github.io/slep_normativa_convivencia/` | `README.md` y `_quarto.yml` (`site-url`), leídos en esta sesión; `.github/workflows/publicar.yml` despliega a Pages en cada push a `main` con `actions/deploy-pages@v5` | verificado (repositorio) |

---

## 10. Redirecciones, hosts contactados y residuos

**Redirecciones a hosts NO autorizados (registradas, no seguidas):** las seis de §4.1 (`docs.claude.com` → `platform.claude.com` ×4; `www.anthropic.com` → `claude.com` ×2).

**Redirecciones dentro de hosts autorizados (destino leído):** `/cloudflare-one/applications/` → `/cloudflare-one/access-controls/applications/http-apps/` (301); `/cloudflare-one/identity/idp-integration/` → `/cloudflare-one/integrations/identity-providers/` (301); `/cloudflare-one/identity/one-time-pin/` → `/cloudflare-one/integrations/identity-providers/one-time-pin/` (301); `/ai-search/configuration/retrieval-configuration/` → `/ai-search/configuration/retrieval/result-controls/` (301); `/autorag/` → `/ai-search/` (301); `https://www.cloudflare.com/zero-trust/products/access/` → `https://www.cloudflare.com/sase/products/access/` (301, mismo host, no leído por innecesario).

**Hosts contactados:** `developers.cloudflare.com`, `www.cloudflare.com`, `docs.claude.com`, `www.anthropic.com`. Ningún otro.

**Residuos (qué no se midió, qué se estimó, qué no se hizo):**
1. Precio de la API del modelo: NO MEDIDO (D4); aritmética sobre tabla provisional rotulada.
2. Usuarios máximos del plan Zero Trust Free: NO MEDIDO (página renderizada por JavaScript en el único host autorizado que la sirve).
3. CPU real del paso a través en streaming y de la validación del JWT: NO MEDIDO; experimento e instrumento en §3.2.
4. Comportamiento de la cookie de Access entre sitios: NO MEDIDO; irrelevante con la UI en el mismo origen (§5.5).
5. Disponibilidad del binding de Rate Limiting en Free: hipótesis (§1.1); la cuota diaria cubre el caso si falla.
6. Regla de tokens (4 caracteres por token): supuesto, con sensibilidad a 3 (§4.4).
7. Tamaño del equipo (~20 personas) y escenarios de uso: supuestos declarados, no datos.
8. Límites de GitHub Pages: NO MEDIDO (`github.com` no autorizado para documentación en este agente).
9. Stemming en español del tokenizador Porter de AI Search y peso de un modelo de embedding en el navegador: NO MEDIDO.
10. No se desplegó, no se creó cuenta, no se usó `wrangler`, no se consumió ninguna API: prohibido por el encargo. El esqueleto JS no se ejecutó.
11. Extrapolación a 100 normas: lineal, declarada como hipótesis.
