# Alcance de la arquitectura Cloudflare para el motor de búsqueda asistida (A4)

> **Encargo:** v9, `50_documentacion/andamios/20260904_encargo_alcance_motor_busqueda_v1.md`, sección A4.
> **Autor:** A4, encargo v9. **Fecha:** 2026-09-05 (verificaciones de red entre las 06:36 y las 12:16 UTC del mismo día). **Corregido en la fase 3 el 2026-09-06** contra los 18 hallazgos que la auditoría dirige a A4; las verificaciones de red se repitieron ese día y el registro está en §11. **Ronda de cierre del mismo día:** los siete defectos que introdujo esa corrección, encontrados por la verificación independiente y por la segunda pasada de la auditoría, se reparan y se registran en §11.1.
> **Naturaleza:** documento de ALCANCE. Nada de lo que describe está desplegado ni probado en vivo: se verifica contra la documentación oficial y se calcula.
> **Artefactos de laboratorio (todos con prefijo `a4_`, en `50_documentacion/andamios/lab_motor_v9/`):** `a4_medir_corpus.R` (recuento propio del corpus), `a4_costos.R` (aritmética de costos), `a4_stack_minimo.R` (aritmética del stack), `a4_citas_verificadas.R` → `a4_citas_verificadas.csv` (cada cita con su URL, código HTTP medido, fecha y frase literal), `a4_worker_esqueleto.js` (esqueleto del Worker, no desplegado ni ejecutado). **Agregados en la fase 3 de corrección (2026-09-06):** `a4_volcados_cf.R` → `a4_cf_*.txt` (los ocho volcados de las páginas de Cloudflare que sostienen enunciados de ausencia, con la fecha de descarga en su cabecera) y `a4_filtro_contexto.R` (arnés del predicado de admisión al contexto). Cada corrección de esta fase, con su hallazgo y su verificación, está en §11.

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

**NO MEDIDO:** la página del binding de Rate Limiting **no declara en qué planes está disponible**. La palabra sí aparece, y el conteo va con su método (`a4_volcados_cf.R`, volcado `a4_cf_ratelimit.txt`, descargado el 2026-09-06, HTTP 200): **3 ocurrencias de `\bfree\b`** en el texto sin etiquetas (1 sensible a mayúsculas), y **5 líneas** con el comando de shell que se ofrece abajo, que cuenta líneas del HTML crudo y no ocurrencias. Ninguna de las tres habla de planes de Cloudflare: son "customers or users (ex: free vs. paid)", "rate limiting configurations for free and paid tier users" y el binding de ejemplo `// Free user rate limiting`, es decir el plan **del cliente del Worker**, no el del Worker. Control positivo del volcado: `Must be either 10 or 60`, 2 ocurrencias en el texto (1 línea con `grep -c`); control negativo `zzz-a4-control-negativo`, 0. Búsqueda directa de la respuesta: `Workers Free` 0 y `Workers Paid` 0. Se asume disponible en Free como hipótesis; si no lo estuviera, la cuota diaria del Durable Object (§5.4) cubre sola el límite de tasa, con peor granularidad (día en vez de minuto). Verificar con: `curl -s https://developers.cloudflare.com/workers/runtime-apis/bindings/rate-limit/ | grep -i -c "free"` → **5 líneas** (no 0), y `… | grep -c "Must be either 10 or 60"` → 1 línea, control positivo. *(Corrige `CIT-A4-01`: el cero publicado era falso y lo refutaba el comando que el propio documento ofrecía.)*

### 1.2 Zero Trust y Access, plan Free

| Dato | Valor | Cita literal y URL | Id |
|---|---|---|---|
| El plan Free existe | sí, sin cargo | "If you chose the Zero Trust Free plan, this step is still needed but you will not be charged." (`/cloudflare-one/setup/`) | C23 |
| **Número máximo de usuarios en Free** | **NO MEDIDO** | La página de planes `https://www.cloudflare.com/plans/zero-trust-services/` responde `HTTP/2 200` pero su contenido lo renderiza JavaScript: el HTML crudo contiene la palabra "users" solo en las tres variantes de la meta descripción ("…to secure users, devices, and networks") y **ninguna** coincidencia de "seats", "50 users" ni "Up to". **Las cifras van con el objeto exacto sobre el que se contaron, que no es el mismo en los dos casos:** sobre el **HTML crudo** (el que `a4_volcados_cf.R` descarga y tiene en memoria; sus conteos quedan en `a4_volcados_cf_salida.txt`, bloque "C22 zero-trust-services", rotulados "en crudo") los patrones dan `\busers\b` → 3, `\bseats?\b` → 0, `50 users` → 0, `Up to` → 0, con control positivo `cloudflare` → 119 y negativo `zzzqx` → 0; sobre el **volcado conservado `a4_cf_zt_planes.txt`**, que guarda solo el texto sin etiquetas (6.657 bytes), los mismos patrones dan `\busers\b` → **0** y `cloudflare` → **18**, porque las tres apariciones de "users" viven en el atributo `content` de la meta descripción y el texto sin etiquetas no lo incluye. Un lector que corra los patrones sobre el archivo conservado obtiene los segundos, no los primeros; los dos se publican para que ninguno quede sin su fuente (`UNI-A4-01`, segunda pasada). El peso del HTML **no es reproducible ni entre días ni dentro del mismo día** (identificadores de build): 412.901 bytes el 2026-09-05, 412.899 y 412.900 en dos descargas del 2026-09-06; lo que se reproduce es la ausencia, no el byte. Tampoco lo dicen `seat-management/`, `account-limits/` ni las FAQ de `developers.cloudflare.com`. Lo único verificado sobre asientos: "Cloudflare One subscriptions consist of seats that active users in your account consume. Active users are added to Cloudflare One through any authentication event." (C21). Verificar abriendo la página de planes en un navegador con JavaScript, o cuando se autorice el host desde el que esa página carga sus datos | C22, C21 |
| Retención de logs de Access | **24 horas** en Free (30 días en Standard, 180 en Enterprise) | "Access logs 24 hours 30 days 30 days 24 hours 180 days" (columnas Free / Standard / Access / Gateway / Enterprise), `https://developers.cloudflare.com/cloudflare-one/insights/logs/` | C19 |
| Qué registra un log de autenticación | correo, IP, país, aplicación, permitido o denegado, proveedor de identidad, timestamp, ray id | "User email Email address of the authenticating user. [...] IP address IP address of the authenticating user." y "Authentication logs do not capture the user's actions during a self-hosted or SaaS application session." | C20 |
| Métodos de identidad | proveedor de identidad de Cloudflare (por defecto), PIN por correo, cualquier SAML/OIDC | "Cloudflare automatically adds the Cloudflare identity provider as your default login method" (C23); "Cloudflare supports all SAML and OIDC providers and can integrate with the majority of OAuth providers. [...] You can also send a one-time PIN (OTP) to approved email addresses. No configuration needed — simply add a user's email address to an Access policy" (C24); "OTP is no longer added automatically, but you can set it up at any time [...] This secure PIN expires 10 minutes after the initial request." (C25) | C23, C24, C25 |
| Límites de cuenta de Access (por defecto; **la tabla de límites de Access** no distingue Free de pago, columna única `Limit`) | 500 aplicaciones, 50 proveedores de identidad, 50 tokens de servicio | "Access Feature Limit Applications 500 [...] Service tokens 50 Identity providers 50 Reusable policies 500 Rules per application 1,000", `https://developers.cloudflare.com/cloudflare-one/account-limits/`. La **página** sí distingue planes más abajo, en la tabla de Digital Experience Monitoring ("DEX Tests per account Zero Trust Free: 10 Zero Trust Standard: 30 Zero Trust Enterprise: 50"), que este diseño no usa: `\bFree\b` da 2 ocurrencias en la página y las dos están ahí (`a4_volcados_cf.R`, volcado `a4_cf_account_limits.txt`, 2026-09-06; control positivo `Applications 500` → 1, control negativo `Applications 501` → 0) | C26 |

**NO MEDIDO:** si algún método de identidad está restringido por plan. Ninguna de las tres páginas leídas (`identity-providers/`, `one-time-pin/`, `setup/`) menciona una restricción (patrón `\bplans?\b` en los volcados conservados `a4_cf_idp.txt` y `a4_cf_otp.txt`, descargados el 2026-09-06: **1 coincidencia en cada uno, las dos en el menú de pie del sitio** ("Getting started Plans Contact sales"), ninguna en el cuerpo; controles positivos: `expires 10 minutes` 1 en el de OTP e `\bidentity\b` 32 en el de proveedores de identidad). Hipótesis de diseño: PIN por correo sobre una lista de correos permitidos, que es lo que la documentación describe sin configuración.

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
   - requisitos: "Before you start To use Access with Workers, you need: Zero Trust enabled on your account. If Zero Trust is not turned on, complete Zero Trust setup first, then return to the Workers dashboard. Permission to manage Workers and Access applications." (C11). La palabra "zone" no aparece en esa página. **Método del conteo, declarado junto a la cifra** (`a4_volcados_cf.R`, volcado `a4_cf_workers_access.txt`, 2026-09-06, HTTP 200): `str_count` de una expresión regular explícita sobre el texto **sin etiquetas** (el HTML sin `<script>`/`<style>`, sin marcas y con espacios colapsados), indistinta a mayúsculas. Con ese método, `\bzone\b` → **0** en el texto y **0** también en el HTML crudo; control positivo `ctx\.access` → **26** (no 20: la cifra de la primera versión no reproducía, y el volcado que la sostenía no se había conservado); control negativo `zzzaccess` → 0.
   - alcance: "Protect one Worker Require sign-in on a single Worker. This automatically protects every domain associated with the Worker, including its routes, Custom Domains, workers.dev hostname, and previews." (C12) y, en la tabla de destinos, "A specific hostname — can be workers.dev, a Custom Domain, or a path" (C13).
   - operación: "Dashboard path: Workers & Pages > select your Worker > Access." y "ctx.access is undefined if Access did not authenticate the request." (C14).

**El origen de la duda del diseño externo** es la página genérica de aplicaciones autohospedadas (`.../cloudflare-one/access-controls/applications/http-apps/self-hosted-public-app/`), cuyos requisitos son "An active domain on Cloudflare" y "Domains must belong to an active zone in your Cloudflare account." (C15). Esa es la vía *por hostname de zona*; la vía *por Worker* de la página de Workers no la exige. Ambas coexisten en la documentación y no se contradicen: protegen cosas distintas.

**Lo que la documentación no dice, y por tanto queda NO MEDIDO:** que la vía por Worker funcione con el plan **Zero Trust Free** (la página de Access para Workers no menciona planes: `\bfree\b` indistinta a mayúsculas → **0** en el mismo volcado y con el mismo método, con el mismo control positivo de 26). La página de setup confirma que el plan Free existe y que se elige en el mismo onboarding (C23), así que la hipótesis es que sí.

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
- El patrón de paso a través sin búfer es el ejemplo oficial de la API de Streams: "const response = await fetch(request); **[...]** return new Response(response.body, response);" y "Use the Streams API to avoid buffering large requests or responses in memory." (`.../workers/runtime-apis/streams/`, C43). El marcador `[...]` no es adorno: entre las dos sentencias la página intercala la línea de comentario `// … and deliver our Response while that's running.`, de modo que la transcripción contigua **no aparece** en la fuente (verificado en `a4_volcados_cf.R`: la cadena contigua da FALSE; cada mitad por separado, 4 y 1 ocurrencias; control negativo con `respuesta` en vez de `response`, 0).

Consecuencia de diseño: el Worker de §5 hace exactamente eso con la respuesta del modelo. Su código JS ejecuta antes de la llamada (validar JWT, consultar cuota, armar el cuerpo) y no vuelve a ejecutar por cada fragmento del stream, porque el cuerpo se entrega al runtime como `ReadableStream` y no pasa por un `TransformStream` en JavaScript. Toda validación del contenido (arnés antialucinación de A3) es del lado del cliente, en el navegador, así que no consume CPU del Worker.

### 3.2 Lo que NO está medido

- **La CPU real que consume el paso a través de un streaming.** La documentación afirma que la espera no cuenta y que el Worker sigue activo, pero no cuantifica el costo de CPU de mover los bytes de un `ReadableStream` al cliente. Tampoco cuantifica el costo de la validación del JWT con `jose` (`createRemoteJWKSet` + `jwtVerify`) ni del `JSON.stringify` de un contexto de hasta 60.000 caracteres. Rótulo: NO MEDIDO.
- **Instrumento, nombrado por la propia documentación:** "Workers Logs — CPU time and wall time appear in the invocation log. Tail Workers / Logpush — CPU time and wall time appear at the top level of the Workers Trace Events object." (C07).
- **Experimento (no ejecutado):** desplegar el esqueleto con `observability.enabled = true`, hacer 30 consultas de tamaño "grande" (§4.2) con respuesta en streaming de 1.500 tokens de salida, y leer el `cpuTime` de cada invocación en Workers Logs. Umbral de aceptación: p95 < 8 ms (margen del 20% sobre el límite de 10 ms). Control positivo: una versión del Worker que parsea cada evento SSE en un `TransformStream` debe mostrar CPU claramente mayor; si ambas versiones miden igual, el instrumento no está leyendo lo que creemos.

### 3.3 Degradación si no cabe

Si el p95 superara 10 ms, la salida es el plan Standard: 5 USD/mes con "30 million CPU milliseconds included per month" (C08). A 5.000 consultas/mes (escenario alto), 30 millones de ms de CPU dan 6.000 ms por consulta, **600 veces** el límite Free de 10 ms (2,78 órdenes de magnitud, no tres). El riesgo de CPU es, por tanto, de 5 USD/mes, no de viabilidad.

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

- Largo de artículo **medido** en `a4_costos.R` desde `40_salidas/datos/normas/*.json`, sobre los 682 segmentos con `es_articulo == TRUE`: mediana **888,5** caracteres, media 1.577,7 caracteres (fuente: salida de `Rscript 50_documentacion/andamios/lab_motor_v9/a4_costos.R`). Se usa la media, porque los artículos largos pesan más en un contexto que la mediana. *(La mediana se publicaba truncada a 888 por un `as.integer()` del script, incoherente con el "mediano ≈ 223 tokens" de §4.3, que es `ceiling(888,5/4)`: `CIF-A4-06`.)*
- Regla de tokens: **supuesto** 1 token ≈ 4 caracteres (sin tokenizador; sensibilidad a 3 caracteres/token en §4.4). Artículo medio ≈ 395 tokens.
- Prompt del sistema: supuesto 1.500 tokens (2.500 en el tamaño grande, por si incluye la capa experta estructurada de A3). Consulta: **supuesto 80 tokens, que es 4,7 veces el máximo medido**. Las diez consultas de evaluación de A2 (`a2_consultas_evaluacion.csv`, medido en `a4_costos.R`) tienen 18 caracteres como mínimo, 49,2 de media y 66 de máximo, es decir **17 tokens c4 en el peor caso**. El supuesto se conserva como sobre conservador (pesa 80 de 5.930 tokens en el tamaño medio, 1,3 %) y la medición queda declarada al lado: `CON-A4-08`. Envoltorio por artículo (id, etiqueta, ancla): 40 tokens.
- Tres tamaños: pequeño (5 artículos, 500 tokens de salida), medio (10, 900), grande (20, 1.500).
- Tres escenarios de uso, en consultas por mes: **bajo 100** (uso esporádico, unas 5 por día hábil), **medio 1.000** (unas 50 por día hábil: uso diario real de un equipo de convivencia de ~20 personas, cifra de tamaño del equipo que es supuesto, no dato), **alto 5.000** (**167 por día calendario o 250 por día hábil**: techo de planificación, no proyección). Los dos denominadores se usan en el documento y no son intercambiables; el tope global del contador de cuota (§5.4) se fija sobre el **peor caso**, el día hábil, para que el escenario alto no quede cortado: `CIF-A4-04`.

### 4.3 Salida literal **completa** de `a4_costos.R` (`Rscript 50_documentacion/andamios/lab_motor_v9/a4_costos.R`, 2026-09-06)

99 líneas, la salida entera y sin recortes (`CIF-A4-03`). **La única línea que no reproduce es la primera**, que trae la hora de la corrida; las 98 restantes son idénticas entre pegado y ejecución, verificado con una comparación línea a línea. El script fija `options(width = 120)` para que la corrida por defecto dé este mismo ancho.


```
R: R version 4.5.2 (2025-10-31)  fecha: 2026-09-06 13:46:35 -03 

control positivo aritmetica: 1M tokens entrada a 2.00 = 2 USD; 1M salida a 10.00 = 10 USD  [OK]

articulos medidos (es_articulo==TRUE): 682 | mediana 888.5 car. | media 1577.7 car.  (CIF-A4-06: sin truncar)
regla de tokens: 1 token ~ 4 caracteres (SUPUESTO) -> articulo mediano ~ 223 tokens, medio ~ 395 tokens
consulta: SUPUESTO 80 tokens | MEDIDO sobre las 10 consultas de evaluacion de A2: min 18, media 49.2, max 66 car. = 17 tokens c4 en el peor caso (4.7 veces menos que el supuesto)
  control positivo: la consulta mas larga del conjunto es "se puede suspender al alumno mientras dura el proceso de expulsión"

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

== Costo mensual (USD, calculado sobre precio provisional) ==
 escenario consultas_mes  tamano           modelo usd_mes
      bajo           100 pequeno    claude-opus-5   3.127
      bajo           100 pequeno  claude-sonnet-5   1.251
      bajo           100 pequeno claude-haiku-4-5   0.626
      bajo           100   medio    claude-opus-5   5.215
      bajo           100   medio  claude-sonnet-5   2.086
      bajo           100   medio claude-haiku-4-5   1.043
      bajo           100  grande    claude-opus-5   9.390
      bajo           100  grande  claude-sonnet-5   3.756
      bajo           100  grande claude-haiku-4-5   1.878
     medio          1000 pequeno    claude-opus-5  31.275
     medio          1000 pequeno  claude-sonnet-5  12.510
     medio          1000 pequeno claude-haiku-4-5   6.255
     medio          1000   medio    claude-opus-5  52.150
     medio          1000   medio  claude-sonnet-5  20.860
     medio          1000   medio claude-haiku-4-5  10.430
     medio          1000  grande    claude-opus-5  93.900
     medio          1000  grande  claude-sonnet-5  37.560
     medio          1000  grande claude-haiku-4-5  18.780
      alto          5000 pequeno    claude-opus-5 156.375
      alto          5000 pequeno  claude-sonnet-5  62.550
      alto          5000 pequeno claude-haiku-4-5  31.275
      alto          5000   medio    claude-opus-5 260.750
      alto          5000   medio  claude-sonnet-5 104.300
      alto          5000   medio claude-haiku-4-5  52.150
      alto          5000  grande    claude-opus-5 469.500
      alto          5000  grande  claude-sonnet-5 187.800
      alto          5000  grande claude-haiku-4-5  93.900

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
alza de 4 a 3 car./token, tamano medio: claude-haiku-4-5 +12.560% | claude-opus-5 +12.560% | claude-sonnet-5 +12.560%
  (el alza es la misma para los tres modelos porque es un cociente de tokens: +12.560%; redondeada a una decimal, +12.6%)

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

== Costo del contexto que A3 publica (tokens leidos de a3_presupuesto_tokens_salida.txt, NO recalculados aqui) ==
                                   escenario_a3 tok_entrada tok_salida           modelo usd_consulta usd_mes_1000
 sin descomposicion, articulos de largo mediano        3773        600    claude-opus-5      0.03386        33.87
 sin descomposicion, articulos de largo mediano        3773        600  claude-sonnet-5      0.01355        13.55
 sin descomposicion, articulos de largo mediano        3773        600 claude-haiku-4-5      0.00677         6.77
     sin descomposicion, articulos de largo p90        8229        600    claude-opus-5      0.05614        56.15
     sin descomposicion, articulos de largo p90        8229        600  claude-sonnet-5      0.02246        22.46
     sin descomposicion, articulos de largo p90        8229        600 claude-haiku-4-5      0.01123        11.23
        con descomposicion (s=3), largo mediano        8677        720    claude-opus-5      0.06139        61.39
        con descomposicion (s=3), largo mediano        8677        720  claude-sonnet-5      0.02455        24.55
        con descomposicion (s=3), largo mediano        8677        720 claude-haiku-4-5      0.01228        12.28
            con descomposicion (s=3), largo p90       22045        720    claude-opus-5      0.12822       128.22
            con descomposicion (s=3), largo p90       22045        720  claude-sonnet-5      0.05129        51.29
            con descomposicion (s=3), largo p90       22045        720 claude-haiku-4-5      0.02564        25.64
contraste de contextos: A4 tamano medio 5930 tokens de entrada | A3 sin descomposicion, largo mediano 3773 | diferencia +57.2%
CONTROL POSITIVO de la lectura: los cuatro escenarios de A3 leidos son 3773, 8229, 8677, 22045 tokens de entrada
```

La tabla completa de los 27 cruces (3 tamaños × 3 modelos × 3 escenarios) está **arriba, dentro del bloque**: el rango extremo va de 0,626 USD/mes (pequeño, Haiku, 100 consultas) a 469,50 USD/mes (grande, Opus, 5.000 consultas), y las dos filas se pueden leer sin salir del documento. *(El bloque anterior estaba rotulado "salida literal" y era un extracto de 46 de 82 líneas al que le faltaban justamente las 30 del bloque `== Costo mensual ==` donde viven esos dos extremos: `CIF-A4-03`. El script fija ahora `options(width = 120)` para que la corrida por defecto reproduzca el pegado.)*

### 4.4 Lectura

- El costo es lineal en consultas y en artículos de contexto; el prompt del sistema pesa poco (1.500 de 5.930 tokens en el tamaño medio).
- Con 3 caracteres por token en vez de 4 (texto legal en español tokeniza peor), el costo sube **12,6 %** (12,560 % exacto) en el tamaño medio (20,86 → 23,48 USD/mes con Sonnet a 1.000 consultas). El porcentaje **lo imprime ahora el script** (`alza de 4 a 3 car./token…` en §4.3) en vez de derivarse a mano al redactar, que es como se publicó 12,5 %: `CIF-A4-02`.
- La descomposición en subpreguntas (opción de A3, punto 9) agrega una llamada corta: entre 1,28 y 6,40 USD/mes a 1.000 consultas. Es barata; lo que decide si entra es la ganancia medida sobre las diez consultas de A2, no el costo.
- **El tamaño de contexto que el diseño de A3 implica cuesta menos que el supuesto de A4**: A3 publica 3.773 tokens de entrada y 600 de salida para su escenario sin descomposición con artículos de largo mediano (`a3_presupuesto_tokens_salida.txt`), contra los 5.930 / 900 del tamaño "medio" de A4, un **57,2 % más** de entrada. `a4_costos.R` lee esos cuatro escenarios del artefacto de A3 y los convierte a USD sin recalcular el contexto (último bloque de §4.3): 13,55 USD/mes con Sonnet a 1.000 consultas, contra 20,86 con el supuesto de A4. **Las dos columnas se publican y se dice cuál es cuál**; la síntesis elige, no A4: `CON-A4-08`.
- Nada de esto lo cobra Cloudflare: en Free, el Worker, el Durable Object, los logs y Access cuestan 0 dentro de los cupos de §1 (verificado) y los escenarios no se acercan a ellos (§8.2, calculado).

---

## 5. Especificación del Worker (tarea 5)

Esqueleto en `lab_motor_v9/a4_worker_esqueleto.js` (rotulado: no desplegado, no probado, no ejecutado). Lo que sigue es su contrato.

### 5.1 Diagrama de despliegue, en texto

```
[GitHub Pages]  https://tomgc.github.io/slep_normativa_convivencia/
  |  sitio Quarto (47 HTML), PDF (25), indice Pagefind 1.5.2, estilo.css
  |  capa 1: vocabulario.json (estatico, A1)      -> nunca llama al Worker
  |  capa 2 lexica: Pagefind estatico              -> nunca llama al Worker
  |  capa 2 semantica: indice estatico (A2)         -> la CONSULTA se vectoriza
  |                                                    en el Worker (binding AI): (*)
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
     |  Durable Object CUOTA (SQLite): 30/usuario/dia, 250 global/dia
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
- *Variante "ids" (recomendada):* el cliente manda solo las anclas; el Worker lee `datos/normas/<slug>.json` desde el sitio, **descarta la norma entera si su `origen_texto` no está en `{capa_texto_pdf, ocr_revisado}`** y arma el contexto con los segmentos pedidos de las que sí lo están. **La unidad del contexto es el segmento (806 en el corpus, 722 firmados), no el artículo (682).** Ventaja: el modelo solo ve texto firmado, con su ancla pública, y nunca texto OCR sin revisar.

  **Condición:** hoy el sitio NO publica los JSON de datos: `find 40_salidas/sitio -name '*.json' -not -path '*/pagefind/*'` devuelve solo `40_salidas/sitio/search.json` (comando ejecutado el 2026-09-05; control positivo: `ls 40_salidas/datos/normas/*.json | wc -l` → 25). Publicarlos es un cambio del pipeline (fuera de la autorización de A4) que la síntesis debe decidir; hasta entonces la variante es una hipótesis con una precondición explícita.

  *(Corrige `CON-A4-04`. El predicado publicado era `es_articulo === true`, que describe la **forma** del segmento (si trae número de artículo) y no la **procedencia** de su texto. Medido con `a4_filtro_contexto.R` sobre los 25 JSON: descartaba 124 de 806 segmentos y solo 84 eran los buscados; los otros **40 tienen texto firmado y ancla pública estable** (`num-1`…`num-5`, `fuentes`, `materia`, `documento`), y con él se caían **enteros** los 32 segmentos de los dictámenes y los 50 de las REX, porque ninguna de esas dos familias aporta un solo segmento con `es_articulo = TRUE`. El predicado nuevo descarta **84 y solo 84** (las 5 normas OCR completas) y pierde **0** segmentos firmados; de los 32 de dictamen conserva 23, y los 9 que excluye son del dictamen 078, que es OCR sin revisar. Controles en la misma corrida: predicado imposible `{zzz_inexistente}` → 0 sobrevive; predicado que no filtra nada → 806. El valor `ocr_revisado` no existe hoy en el corpus (0 segmentos, control de calibración): está en el predicado para que una transcripción revisada entre sola, sin volver a tocar el Worker. El propio §7 de este documento ya escribía la regla correcta para AI Search (`origen_texto: {$ne: "ocr_pendiente_revision"}`) y el Worker no la seguía.)*
- *Variante "textos":* el cliente manda `{ancla, texto}` leídos de los JSON estáticos que publique el sitio. Sin subrequests, pero el Worker no puede garantizar que el texto sea el del sitio. Tope: 60.000 caracteres por solicitud.

### 5.3 Secreto

- Se carga con `npx wrangler secret put ANTHROPIC_API_KEY` y se lee como `env.ANTHROPIC_API_KEY`. "Secrets are environment variables. The difference is secret values are not visible within Wrangler or Cloudflare dashboard after you define them." (C42).
- Nunca aparece en `wrangler.jsonc`, en el repositorio ni en el navegador; en desarrollo local vive en `.dev.vars`, que la misma página manda a `.gitignore`. Este repositorio es público: el archivo `.dev.vars` no debe crearse dentro de él.
- Defensa en profundidad además de Access: el Worker valida el JWT que Access agrega, siguiendo el ejemplo oficial con `jose`: "We recommend validating the Cf-Access-Jwt-Assertion header instead of the CF_Authorization cookie, since the cookie is not guaranteed to be passed." y claves en `https://<team>.cloudflareaccess.com/cdn-cgi/access/certs` (C16). Si el JWT falta o no valida, 403 antes de tocar el secreto.

### 5.4 Límite de tasa por usuario

Dos capas, porque la documentación dice que el binding de Rate Limiting no es un contador exacto (C44):
1. **Ráfaga**, binding `RAFAGA` con `{limit: 10, period: 60}` y clave = correo de `ctx.access`. Corta abuso por minuto; es local a cada ubicación de Cloudflare y eventualmente consistente, lo que aquí basta.
2. **Cuota diaria**, Durable Object `CUOTA` con SQLite (disponible en Free, C45): tabla `(fecha, email, n)`, tope 30 por usuario y **250 global por día**, declarados sobre el **peor** de los dos denominadores que este documento usa para el escenario alto: 5.000 consultas/mes son **167 por día calendario** (÷30) pero **250 por día hábil** (÷20, que es como §4.2 define el escenario). Un tope de 200 dejaba margen con el primero (6.000/mes) y **cortaba** con el segundo (200 × 20 = 4.000/mes, un 20 % por debajo de las 5.000 declaradas): `CIF-A4-04`. Con 250 el escenario alto cabe en los dos, y el gasto máximo diario queda acotado a 250 × 0,05215 = **13,04 USD** con Opus en tamaño medio (calculado sobre precio provisional; el costo por consulta sale del bloque de §4.3). Consumo: 1 fila escrita por consulta; a 5.000/mes son 167 filas/día calendario, el 0,167 % del cupo Free de 100.000 filas escritas/día, y 250 en el peor día hábil, el 0,25 % (`a4_stack_minimo.R`). KV habría servido (1.000 escrituras/día, 16,7% en el escenario alto) pero es eventualmente consistente y no ofrece la transacción "leer y sumar" que el contador necesita.

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

La capa 1 (vocabulario estático) vive en GitHub Pages y **nunca llama al Worker** (§5.1): en los cinco casos sigue funcionando sin cambio. La capa 2 hay que **desdoblarla**, y no basta el asterisco de §5.1: el plan de degradación es lo que se lee para decidir.

| Capa | Con el Worker caído | Por qué |
|---|---|---|
| Capa 1 (vocabulario) | **sobrevive sin cambio** | archivo estático en GitHub Pages |
| Capa 2 **léxica** (Pagefind, e índice de recuperación estático) | **sobrevive sin cambio** | archivos estáticos; no requiere red fuera de Pages, ni cuota, ni servicio |
| Capa 2 **semántica** | **cae a léxica** | si A2 vectoriza la consulta con Workers AI, ese llamado pasa por el mismo Worker (§8.3). La vía no desaparece: degrada, porque la fusión de A2 admite la ausencia de una vía |
| Capa 3 precalculada (rutas firmadas) | **sobrevive sin cambio** | contenido estático; es el respaldo que la UI muestra cuando la variante en vivo no responde |
| Capa 3 en vivo | **no disponible** | es el Worker |

*(Corrige `CON-A4-03`: el documento decía "la capa 2 … nunca llama al Worker … sigue funcionando sin cambio", y eso solo vale para su vía léxica.)*

| Caso | Qué pasa técnicamente | Qué ve el usuario | Cita |
|---|---|---|---|
| El Worker no responde (caído, sin red, Access sin sesión válida) | `fetch` falla, expira (timeout del cliente 20 s) o devuelve `302`/`403` | Aviso "La orientación en vivo no está disponible; abajo está la ruta de abordaje validada para este tema" y el enlace a la ruta precalculada. Si es `302`/`403`: botón "Volver a iniciar sesión" que hace una navegación a `/` | C14 (403 sin `ctx.access`) |
| Se agota la cuota diaria (usuario o global) | el Durable Object responde `429` con `{error: "cuota_diaria_usuario"\|"cuota_diaria_global", usadas, max}` | "Se alcanzó el cupo diario (N de M). Vuelve mañana; la ruta de abordaje validada sigue disponible". `/api/estado` permite mostrar el contador antes de enviar | §5.4 |
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
2. Aparecen tres restricciones que el diseño externo no vio: (a) el stemmer es Porter, que es un algoritmo para inglés; para "sostenedor / sostenedores" o "expulsión / expulsiones" el comportamiento en español está **NO MEDIDO** (la página no lista idiomas: `\blanguage\b` da **1 sola** coincidencia en el volcado conservado `a4_cf_ais_keyword.txt`, descargado el 2026-09-06, y es "Best for natural language"; control positivo `\bporter\b` 2, control negativo `zzz` 0); (b) el corte en fragmentos es de AI Search ("The extracted text is chunked into smaller pieces", `how-ai-search-works`, verificado en el volcado) y el embedding admite 512 tokens: un artículo de 27.167 caracteres (máximo medido, §8.1) se parte en varios fragmentos y **la unidad de cita deja de ser el artículo**, que es el invariante 1 del encargo; (c) 5 campos de metadatos personalizados: `slug`, `tipo`, `anio`, `vigencia` y `origen_texto` los agotan sin dejar sitio a `tema`.
3. La exclusión del OCR sin revisar sería posible con un filtro `origen_texto: {$ne: "ocr_pendiente_revision"}`, a costa de uno de los 5 campos. **Es la misma regla que rige el contexto del Worker en §5.2**, escrita ahí en positivo (`origen_texto ∈ {capa_texto_pdf, ocr_revisado}`) para que un texto revisado en el futuro entre solo: `CON-A4-04`.

Veredicto para el diseño: **verificado como servicio, descartado como base** (§8.4), y utilizable solo como experimento medible contra las diez consultas de A2 si la síntesis lo pide.

---

## 8. Stack mínimo, no máximo (tarea 8)

### 8.1 Números del corpus, recuento propio (`Rscript 50_documentacion/andamios/lab_motor_v9/a4_medir_corpus.R`, corrida del 2026-09-06; salida congelada en `a4_medir_corpus_salida.txt`)

| Cifra | Valor | Cómo se contó |
|---|---|---|
| Normas | 25 | `length(dir_ls("40_salidas/datos/normas", glob="*.json"))`; coincide con `catalogo[["n_normas"]]` = 25 |
| Artículos (`es_articulo == TRUE`) | 682 | suma sobre los 25 JSON; coincide con `catalogo[["n_articulos"]]` = 682 y con la suma de `n_articulos` por norma |
| Segmentos totales en `articulos[]` | 806 (682 artículos + 124 no artículo) | mismo script |
| **Segmentos firmados** (`origen_texto ∈ {capa_texto_pdf, ocr_revisado}`) | **722** (682 artículos + 40 no artículo con ancla pública); los 84 restantes son las 5 normas OCR | mismo script; es la unidad que admite el contexto del Worker (§5.2, `CON-A4-04`) |
| Normas con texto OCR sin revisar | 5 (`origen_texto == "ocr_pendiente_revision"`), 84 segmentos, 0 artículos, 224.276 caracteres | `count(origen_texto)` y `summarise(.by = origen_texto)`. La cifra heredada "84 páginas en 5 documentos" del encargo §0 **se confirma** |
| Relaciones | 552 (tema 502, remisión 46, sustitución 2, grupo_acto 2) | `length(rel[["relaciones"]])` = `rel[["n_relaciones"]]` = 552 |
| Caracteres | 1.429.841 en los 806 segmentos (1.460.356 bytes); 1.075.967 en los 682 artículos | `nchar(texto, type = "chars")` |
| Largo de artículo | mín 59, mediana **888,5**, p90 **3.117,9**, p95 **4.610,65**, máx 27.167, media 1.577,7 caracteres | `quantile()` sobre los 682, **sin truncar** (`CIF-A4-06`: el script los pasaba por `as.integer()`, que trunca; los truncados eran 888 / 3.117 / 4.610) |
| Peso de los datos canónicos | 1.881.890 bytes en disco; 431.668 bytes gzip (catálogo 31.570 → 4.899; relaciones 257.530 → 8.967; 25 normas 1.592.790 → 417.802) | `file_size()` y `memCompress(type = "gzip")` |
| Sitio generado | 148 archivos, 41.737.491 bytes; 47 HTML; PDF 25 archivos, 34.337.933 bytes (idénticos en bytes a `20_insumos/normativa/`); Pagefind 55 archivos, 1.521.719 bytes, versión 1.5.2 | `dir_info(recurse = TRUE)` y `pagefind-entry.json` |

Todos los enunciados universales de esta sección ("los 25", "los 682", "los 722", "los 806") se sostienen en el recorrido exhaustivo de ese script sobre `40_salidas/datos/normas/*.json`.

### 8.2 Aritmética del stack (`Rscript 50_documentacion/andamios/lab_motor_v9/a4_stack_minimo.R`, salida literal completa, 2026-09-06)

70 líneas, la salida entera. Igual que en §4.3, la única línea que no reproduce es la de la hora.


```
R: R version 4.5.2 (2025-10-31)  fecha: 2026-09-06 18:07:57 -03 

corpus medido: 25 normas | 682 articulos | 806 segmentos | 552 relaciones | 1429841 caracteres (todo) | 1075967 caracteres (articulos)
unidad del contexto (CON-A4-04): 722 segmentos FIRMADOS (origen_texto en {capa_texto_pdf, ocr_revisado}) | 84 descartados por OCR sin revisar | firmados perdidos por el filtro: 0
  CONTRASTE con el filtro viejo (es_articulo == TRUE): sobreviven 682, descarta 124, de los cuales 40 tienen texto firmado
  CONTROL POSITIVO: segmentos con origen_texto inexistente = 0 (esperado 0) | CONTROL NEGATIVO: con origen_texto no vacio = 806 (esperado 806)

== Vectorize: dimensiones (Free: 5,000,000 almacenadas; 30,000,000 consultadas/mes) ==
unidad indexada, UNA para toda la seccion: 1160 fragmentos firmados (a2_fragmentacion.csv, frag_c4, fila 'total firmadas')
  CONTROL CRUZADO: esa fila declara 722 unidades firmadas; mi recuento independiente da 722 -> coinciden: TRUE
N= 1160 fragmentos firmados (canonica)       dims  384: almacenadas    445440 =   8.9% del cupo
N= 1160 fragmentos firmados (canonica)       dims  768: almacenadas    890880 =  17.8% del cupo
N= 1160 fragmentos firmados (canonica)       dims 1024: almacenadas   1187840 =  23.8% del cupo
N=  682 articulos (unidad vieja, contraste)  dims  384: almacenadas    261888 =   5.2% del cupo
N=  682 articulos (unidad vieja, contraste)  dims  768: almacenadas    523776 =  10.5% del cupo
N=  682 articulos (unidad vieja, contraste)  dims 1024: almacenadas    698368 =  14.0% del cupo
vectores que agotan el cupo Free de almacenamiento a 1024 dims: 4882 (= 105 normas, a 46.4 fragmentos firmados por norma)
vectores que agotan el cupo Free de almacenamiento a 1024 dims: 4882 (= 179 normas, a 27.3 articulos por norma)

cupo de CONSULTA de Vectorize Free (30,000,000 dims/mes), 1024 dims, indice de 1160 vectores (unidad canonica):
  100 consultas/mes -> (A) consultas x dims =   102400 =  0.34% | (B) (consultas + almacenados) x dims =  1290240 =  4.30%
 1000 consultas/mes -> (A) consultas x dims =  1024000 =  3.41% | (B) (consultas + almacenados) x dims =  2211840 =  7.37%
 5000 consultas/mes -> (A) consultas x dims =  5120000 = 17.07% | (B) (consultas + almacenados) x dims =  6307840 = 21.03%
  CONTROL POSITIVO de la formula (B) con el ejemplo de la pagina: (10000 + 100) * 384 = 3878400 dims (la pagina dice 3.878 millones)

== Peso del indice de embeddings: UNA formula (vector + metadatos) y UNA unidad ==
formula: bytes = N x dims x bytes_por_dim + N x 57.8 B de metadatos | unidad canonica N = 1160
  N= 1160 fragmentos firmados (canonica)   dims  384: int8    512488 B (  500.5 KiB) | float32   1848808 B ( 1805.5 KiB)
  N= 1160 fragmentos firmados (canonica)   dims 1024: int8   1254888 B ( 1225.5 KiB) | float32   4818408 B ( 4705.5 KiB)
  N=  722 segmentos firmados               dims  384: int8    318980 B (  311.5 KiB) | float32   1150724 B ( 1123.8 KiB)
  N=  722 segmentos firmados               dims 1024: int8    781060 B (  762.8 KiB) | float32   2999044 B ( 2928.8 KiB)
  N=  682 articulos                        dims  384: int8    301308 B (  294.2 KiB) | float32   1086972 B ( 1061.5 KiB)
  N=  682 articulos                        dims 1024: int8    737788 B (  720.5 KiB) | float32   2832892 B ( 2766.5 KiB)
  N=  806 segmentos totales                dims  384: int8    356091 B (  347.7 KiB) | float32   1284603 B ( 1254.5 KiB)
  N=  806 segmentos totales                dims 1024: int8    871931 B (  851.5 KiB) | float32   3347963 B ( 3269.5 KiB)
  CONTROL: sin metadatos, la unidad canonica a 1024 dims int8 pesa 1187840 B; la diferencia con la formula fijada es 67048 B

umbrales, con la unidad canonica (fragmentos firmados) y con la vieja (articulos):
  fragmentos  por norma  46.4 -> agota Vectorize Free (almacenamiento, 1024 dims) con 4882 vectores =   105 normas | indice int8 de 1024 dims supera 5 MiB con 4846 =   104 normas | float32 con 1262 =    27 normas
  articulos   por norma  27.3 -> agota Vectorize Free (almacenamiento, 1024 dims) con 4882 vectores =   179 normas | indice int8 de 1024 dims supera 5 MiB con 4846 =   178 normas | float32 con 1262 =    46 normas
  CONTROL (formula SIN metadatos, que es como se publicaron antes): int8 5120 vectores = 110 normas | float32 1280 = 28 normas

== Workers AI (neuronas; cupo Free 10,000/dia) ==
embeber todo el corpus una vez con bge-m3: 357461 tokens -> 384.3 neuronas (3.84% del cupo diario)
embeber una consulta (80 tokens): 0.0860 neuronas -> 5000/mes = 430.0 neuronas/mes
reordenar 20 candidatos de 1578 car. medios (+ consulta): 9500 tokens -> 2.69 neuronas/consulta -> 5000/mes = 13442 neuronas/mes = 448/dia
escenario alto (5000 consultas/mes), consumo diario de neuronas: reranking 448.1 (4.48% del cupo) + embedding de la consulta 14.33 (0.14%) = 462.4 (4.62%)

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

== Universal: ningun artefacto estatico no-PDF supera 3 MB (recorrido exhaustivo de 40_salidas) ==
archivos recorridos: 277 (no-PDF 227 | PDF 50)
no-PDF que superan 3 MB (3e6 bytes): 0
el mayor no-PDF: 40_salidas/sitio/search.json con 1.685 MB (1.607 MiB)
CONTROL POSITIVO (el instrumento SI ve archivos grandes): PDF que superan 3 MB = 4
CONTROL NEGATIVO (umbral imposible): archivos que superan 3 TB = 0 (esperado 0)
```

Regla de tokens en este script: supuesto 1 token ≈ 4 caracteres, igual que en §4.

**Una sola fórmula y una sola unidad para el índice (`CON-A4-07`).** El paquete publicaba tres pesos del mismo objeto: A4 daba 698.368 bytes (682 artículos, **sin** metadatos), A2 daba 720,5 KiB en int8 (682 artículos, **con** 57,8 B de metadatos por unidad) y A5 daba 0,31 a 3,30 MB (806 unidades, MB decimales). Ninguna era errónea y las tres eran incomparables. Este documento fija a partir de aquí **la fórmula con metadatos** (`bytes = N × dims × bytes_por_dim + N × 57,8`, que es la que corresponde a un archivo servido) y **la unidad que A2 decide indexar**: los **1.160 fragmentos firmados** de `a2_fragmentacion.csv` (columna `frag_c4`, fila `total firmadas`), leídos del artefacto por el script y no transcritos. Control cruzado que la corrida imprime: esa misma fila declara 722 unidades firmadas y el recuento independiente de A4 da 722. Los universos vecinos (722 segmentos firmados, 682 artículos, 806 segmentos) quedan tabulados arriba para que la síntesis los cruce sin recalcular. **Las cifras de Vectorize cambian con la unidad y por eso hay que decirla**: a 1.024 dims el índice ocupa el 23,8 % del cupo Free de almacenamiento con la unidad canónica y el 14,0 % con la vieja. **La fórmula fijada rige también los dos umbrales de 5 MiB del bloque de arriba**, que en la primera corrección se seguían calculando sin metadatos: son 4.846 vectores en int8 (~104 normas) y 1.262 en float32 (~27), no los 5.120 y 1.280 (~110 y ~28) de la fórmula sin metadatos, que el script imprime ahora como línea de control para que el cambio quede a la vista.

### 8.3 Veredicto por componente

Prueba que cada componente debe pasar: (a) qué problema resuelve que un archivo estático servido desde GitHub Pages no resuelva; (b) a partir de qué tamaño de corpus empieza a pagarse; (c) qué mantenimiento agrega. **Un componente que no pasa (a) se descarta.**

| Componente | (a) Problema que resolvería | Lo que el estático ya hace, con número | (b) Umbral en que empezaría a pagarse | (c) Mantenimiento que agrega | Veredicto |
|---|---|---|---|---|---|
| **D1** (SQL) | consultas relacionales sobre normas, artículos y relaciones | `relaciones.json` pesa 8.967 bytes gzip y `catalogo.json` 4.899 bytes gzip: el grafo completo de 552 aristas viaja en menos de 14 KB y se filtra en el navegador en O(552). Extrapolación lineal a 100 normas: ~35 KB gzip (hipótesis) | cuando haya escrituras por usuario (anotaciones, historial) o el grafo deje de caber en una descarga razonable (órdenes de magnitud por encima de 100 normas) | esquema, migraciones, sincronización con los JSON que el pipeline ya genera (dos fuentes de verdad) | **Descartado** |
| **R2** (objetos) | servir PDF y JSON | GitHub Pages ya sirve los 25 PDF (34.337.933 bytes) y 47 HTML; los JSON canónicos suman 431.668 bytes gzip | cuando el sitio supere los límites de GitHub Pages (**NO MEDIDO**: `github.com` no está autorizado para leer su documentación; verificar con `curl -sI https://docs.github.com/en/pages/getting-started-with-github-pages/github-pages-limits` cuando se autorice) o cuando haga falta subir archivos desde el navegador | un bucket, credenciales y un segundo despliegue | **Descartado** |
| **Vectorize** (índice vectorial) | búsqueda por similitud sin descargar el índice | sobre la unidad canónica (1.160 fragmentos firmados) y con la fórmula que incluye metadatos, un índice int8 de 1.024 dims pesa **1.254.888 bytes (1.225,5 KiB)**; en float32, 4.818.408 (4.705,5 KiB). Cabe en una descarga estática. En Vectorize Free ocuparía el **23,8 %** del cupo de almacenamiento y, en el escenario alto (5.000 consultas/mes), el **21,0 %** del de consulta con la fórmula que Cloudflare factura, o el 17,1 % con la convención `consultas × dims` | con la unidad canónica: **~105 normas** agotan el cupo Free de almacenamiento (4.882 vectores a 1.024 dims, a 46,4 fragmentos por norma), **~104** hacen que el índice int8 supere 5 MiB y **~27** si fuera float32. Los dos umbrales de 5 MiB usan la misma fórmula con metadatos que fija §8.2 (4.846 y 1.262 vectores); sin metadatos daban 110 y 28, que es como se publicaron antes y lo que imprime hoy la línea de control del script. Con la unidad vieja (artículos) los mismos umbrales son 179, 178 y 46 | índice fuera del repositorio; reindexar en cada corrida del pipeline con `wrangler`; llaves y dimensiones acopladas al modelo | **Descartado para 25 normas**; **reevaluar por encima de ~27 normas si el índice se sirviera en float32**, que es el menor de los tres umbrales derivados (es el punto en que la descarga estática pasa de 5 MiB) y deja solo dos normas de margen sobre el corpus de hoy; con int8, que es la variante que este documento asume, el primer umbral llega a las **~104 normas** y el cupo Free de almacenamiento de Vectorize recién a las ~105. Lo que Vectorize no evita de todos modos es el embedding de la consulta en runtime, que necesita un modelo: §8.4 |
| **AI Search** (RAG administrado) | híbrida + RRF + reranking + filtros sin escribir código | Pagefind 1.5.2 (1.521.719 bytes) ya da la vía léxica a nivel de artículo con anclas estables; la vía vectorial cabe estática (fila anterior). AI Search rompe la unidad de artículo (fragmentos de 512 tokens), su stemmer es Porter (inglés) y admite 5 campos de metadatos (§7) | cuando el corpus deje de caber estático **y** el equipo acepte citas por fragmento en vez de por artículo | una instancia, subir 25 archivos en cada corrida, mapear fragmentos a anclas, vigilar el fin de la beta (precio no anunciado, C38) | **Descartado como base**; admisible solo como experimento con las diez consultas de A2 |
| **Workers AI** (inferencia) | embeber la consulta y reordenar candidatos | no hay equivalente estático: embeber la consulta en el navegador exige descargar un modelo (decenas de MB, NO MEDIDO). Costo en Cloudflare: 0,086 neuronas por consulta; reordenar 20 candidatos, 2,69 neuronas; en el escenario alto, **462 neuronas/día = 4,6 % del cupo Free** (reranking 448,1 = 4,48 % **más** embedding de la consulta 14,3 = 0,14 %); embeber el corpus entero una vez, 384 neuronas | desde el primer día si A2 elige la vía vectorial; nunca si A2 elige Pagefind + sinónimos de A1 | ninguno adicional al Worker: es un *binding* del mismo Worker, detrás del mismo Access | **Se conserva como binding opcional del Worker existente**, no como servicio aparte; la decisión de usarlo es de A2 |

### 8.4 Conclusión

La hipótesis por defecto del encargo ("casi todo cabe estático y el Worker existe solo para custodiar la clave") **se intentó refutar con datos y sobrevive**: **ningún cupo Free de los servicios que el stack sí usa** se acerca al 20 % en el escenario alto (solicitudes 0,5 %, filas del Durable Object 0,167 % por día calendario y 0,25 % en el peor día hábil, neuronas **4,6 %** = reranking 4,48 % más embedding de la consulta 0,14 %), y **ningún artefacto estático supera 3 MB** salvo los PDF que GitHub Pages ya sirve. Las dos afirmaciones llevan ahora su recorrido:

- La acotación "de los servicios que el stack sí usa" **no es retórica, y por eso está escrita**: Vectorize está descartado, pero si se usara sería el único componente que rompe el umbral, con el 23,8 % del cupo de almacenamiento y el 21,0 % del de consulta sobre la unidad canónica (§8.2 y §8.3). Un enunciado universal que solo se sostiene excluyendo un caso tiene que nombrar el caso: `CIF-A4-01`.
- El universal de los 3 MB sale del recorrido exhaustivo de `40_salidas` que imprime `a4_stack_minimo.R` (último bloque de §8.2): **277 archivos recorridos, 227 no-PDF, 0 sobre 3 MB**, y el mayor es `40_salidas/sitio/search.json` con 1,685 MB (1,607 MiB). **Control positivo** en el mismo recorrido: 4 PDF sí superan 3 MB, o sea el instrumento ve archivos grandes; **control negativo**: 0 archivos superan 3 TB. `UNI-A4-02`. El único argumento a favor de un servicio adicional es el embedding de la consulta en runtime, y ese servicio (Workers AI) se resuelve como *binding* del Worker que de todos modos hay que desplegar para la clave.

**Stack mínimo resultante:** GitHub Pages (sitio, PDF, Pagefind, `vocabulario.json`, índice vectorial estático si A2 lo adopta, rutas de abordaje firmadas, y los JSON de datos si se decide publicarlos) + un Worker Free en `workers.dev` protegido por Access (Zero Trust Free) con un secreto, un binding de Rate Limiting, un Durable Object SQLite y, opcionalmente, un binding de Workers AI. Sin zona propia, sin D1, sin R2, sin Vectorize, sin AI Search.

**Riesgo declarado del stack mínimo:** "Your workers.dev subdomain is treated as a Free website and is intended for personal or hobby projects that aren't business-critical." (C10). Para un ejercicio académico-técnico (§0 del encargo) eso es coherente; si el servicio pasara a ser institucional, el primer cambio sería un dominio propio, y con él la vía por hostname de zona de Access (C15).

---

## 9. Citas y cifras

Tabla completa, con código HTTP medido programáticamente el 2026-09-06 por `a4_citas_verificadas.R` (HEAD sin seguir redirecciones, guarda de hosts autorizados antes de tocar la red), en `lab_motor_v9/a4_citas_verificadas.csv` (56 filas: 47 con estado `verificado`, de las cuales 46 responden `200` y 1 es la redirección `301` dentro del mismo host; 7 `no_medido`; 2 controles). Códigos HTTP medidos en el CSV, en la corrida del 2026-09-06: 48 × `200`, 5 × `301`, 2 × `302`, 1 × `404`. **El CSV tiene desde la fase 3 una novena columna, `nota`** (`CIT-A4-05`): `cita_literal` contiene solo texto transcrito de la fuente, y toda evaluación, alcance o advertencia de A4 vive en `nota`. Antes, la fila C26 llevaba dentro del campo declarado como cita literal la glosa "(tabla de límites por defecto; la página no distingue Free de pago para Access)", que no proviene de Cloudflare. El propio script comprueba la separación: **0 de 47 citas verificadas contienen texto en español**, con control positivo del detector sobre la columna `nota`, que lo detecta en 4 de 4. Resumen por dato:

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
| Volcados de las páginas de Cloudflare que sostienen enunciados de ausencia (§1.1, §1.2, §2, §7) y sus conteos con método declarado | `Rscript 50_documentacion/andamios/lab_motor_v9/a4_volcados_cf.R` → `a4_cf_*.txt` (8 volcados con fecha y HTTP en su cabecera) y `a4_volcados_cf_salida.txt` | verificado (red, 2026-09-06) |
| Predicado de admisión al contexto del Worker: qué descarta el viejo y qué el nuevo | `Rscript 50_documentacion/andamios/lab_motor_v9/a4_filtro_contexto.R` (§5.2) | calculado (recuento propio) |
| Sitio publicado y origen: `https://tomgc.github.io/slep_normativa_convivencia/` | `README.md` y `_quarto.yml` (`site-url`), leídos en esta sesión; `.github/workflows/publicar.yml` despliega a Pages en cada push a `main` con `actions/deploy-pages@v5` | verificado (repositorio) |

---

## 10. Redirecciones, hosts contactados y residuos

**Redirecciones a hosts NO autorizados (registradas, no seguidas):** las seis de §4.1 (`docs.claude.com` → `platform.claude.com` ×4; `www.anthropic.com` → `claude.com` ×2).

**Redirecciones dentro de hosts autorizados (destino leído):** `/cloudflare-one/applications/` → `/cloudflare-one/access-controls/applications/http-apps/` (301); `/cloudflare-one/identity/idp-integration/` → `/cloudflare-one/integrations/identity-providers/` (301); `/cloudflare-one/identity/one-time-pin/` → `/cloudflare-one/integrations/identity-providers/one-time-pin/` (301); `/ai-search/configuration/retrieval-configuration/` → `/ai-search/configuration/retrieval/result-controls/` (301); `/autorag/` → `/ai-search/` (301); `https://www.cloudflare.com/zero-trust/products/access/` → `https://www.cloudflare.com/sase/products/access/` (301, mismo host, no leído por innecesario).

**Hosts contactados:** `developers.cloudflare.com`, `www.cloudflare.com`, `docs.claude.com`, `www.anthropic.com`. Ningún otro, ni en la redacción ni en la corrección de la fase 3.

**Volcados conservados (`UNI-A4-01`).** Los enunciados de ausencia de §1.1, §1.2, §2 y §7 se apoyaban en volcados `cf_*.txt` y en un `buscar_usuarios.R` que vivían solo en el scratchpad de la sesión: `find` sobre el repositorio no devolvía nada y un control positivo que no se puede volver a correr no es un control. Desde el 2026-09-06 los ocho volcados viven en `lab_motor_v9/` con prefijo `a4_cf_`, los genera y los cuenta `a4_volcados_cf.R`, y cada archivo lleva en su cabecera la URL, la fecha de descarga, el código HTTP y su peso en bytes. **El laboratorio no se versiona**, así que la reproducción desde un clon sigue exigiendo volver a correr ese script: es un `curl` a hosts autorizados, con su fecha al lado, y las cifras de red se declaran no reproducibles entre días (el HTML de la página de planes pesó 412.901 bytes el 05, y 412.899 y 412.900 en dos descargas del 06). **Un volcado conserva el texto sin etiquetas, no el HTML crudo:** cuando una cifra sale del crudo hay que decirlo, porque los mismos patrones sobre el archivo conservado dan otra cosa (§1.2, `\busers\b` → 3 en crudo y 0 en el volcado).

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
---

## 11. Correcciones de la fase 3 (2026-09-06)

Cada fila es un hallazgo de la auditoría dirigido a A4, el cambio que se aplicó y el comando que lo verifica. La auditoría dirige **18** hallazgos a A4: 1 mayor, 12 menores y 5 mejorables. Los cinco mejorables se corrigieron igual que los demás.

| Hallazgo | Clase | Dónde | Qué cambió | Verificación |
|---|---|---|---|---|
| `CON-A4-04` | mayor | §5.2 y `a4_worker_esqueleto.js` | El predicado de admisión al contexto pasa de `art.es_articulo === true` a `norma.origen_texto ∈ {capa_texto_pdf, ocr_revisado}`, y la unidad del contexto se declara: **segmento** (806; 722 firmados), no artículo (682) | `Rscript …/a4_filtro_contexto.R` → viejo: descarta 124, de los cuales **40 con texto firmado**; nuevo: descarta **84 y solo 84**, firmados perdidos **0**, dictámenes que sobreviven 23 de 32. Controles: predicado imposible → 0; predicado nulo → 806; `ocr_revisado` hoy → 0 |
| `CIF-A4-01` | menor | §8.3 (Vectorize), §8.4 | El "3,4 % del cupo de consulta a 5.000 consultas/mes" era el escenario de 1.000. Se publica **21,0 %** con la fórmula que Cloudflare factura, `(consultas + almacenados) × dims`, declarada como tal, y se deja al lado el 17,1 % de la convención `consultas × dims`. §8.4 nombra el caso que su universal excluye | `Rscript …/a4_stack_minimo.R` (bloque "cupo de CONSULTA") → 5.000 consultas: (A) 17,07 %, (B) 21,03 %. Control positivo de (B) con el ejemplo de la propia página: (10.000 + 100) × 384 = 3.878.400 dims, y la página dice 3,878 millones. URL revalidada: `curl -sI --max-redirs 0 https://developers.cloudflare.com/vectorize/platform/pricing/` → `HTTP/2 200` |
| `CIF-A4-02` | menor | §4.4 | "sube 12,5 %" → **12,6 %** (12,560 %), y el porcentaje lo imprime el script en vez de derivarse a mano | Bloque de §4.3: `alza de 4 a 3 car./token, tamano medio: … +12.560%` para los tres modelos |
| `CIF-A4-03` | menor | §4.3 | El bloque rotulado "salida literal" era un extracto de 46 de 82 líneas, sin las 30 del `== Costo mensual ==` donde viven los dos extremos que el texto cita. Se pega la salida **completa** (99 líneas) y el script fija `options(width = 120)` | `diff <(sed -n '189,287p' …cloudflare_v1.md) <(Rscript …/a4_costos.R)` → una sola diferencia, la línea de la hora. **El rango publicado en la primera corrección era `186,284p`, que arrastra el encabezado y la valla de apertura y corta las tres últimas líneas de la salida: devolvía 11 líneas de diferencia.** Las vallas del bloque están en 188 y 288 (`grep -n '^\`\`\`'`), así que el contenido es 189-287, 99 líneas contra las 99 de la corrida |
| `CIF-A4-04` | menor | §4.2, §5.1, §5.4 | Los dos denominadores del escenario alto (167/día calendario, 250/día hábil) se declaran, y el tope global del contador sube de 200 a **250/día**, que es el peor caso. Gasto máximo diario recalculado: 250 × 0,05215 = **13,04 USD** con Opus en tamaño medio | Con 200: 200 × 20 días hábiles = 4.000 consultas/mes, un 20 % bajo las 5.000 del escenario. Con 250: 5.000. El costo por consulta sale del bloque de §4.3 (`medio / claude-opus-5 → 0.05215`) |
| `CIT-A4-01` | menor | §1.1 | El "patrón `Free` sin coincidencias" era falso y lo refutaba el comando que el propio documento ofrecía. Se publica el conteo real con su método y la acotación que sí se sostiene | `curl -s …/bindings/rate-limit/ \| grep -i -c "free"` → **5** líneas; `a4_volcados_cf.R` → 3 ocurrencias de `\bfree\b` en texto sin etiquetas, 1 de `\bFree\b`; `Workers Free` 0 y `Workers Paid` 0; control positivo `Must be either 10 or 60` → 2; control negativo → 0 |
| `CIT-A4-02` | menor | §2 | El control positivo `ctx.access` decía 20 y no reproducía. Se corrige a **26** y, sobre todo, se declara el método de conteo junto a la cifra (patrón exacto, sensibilidad, texto sin etiquetas contra HTML crudo) | `a4_volcados_cf.R` → `ctx\.access` 26; `\bzone\b` 0 en texto y 0 en crudo; `\bfree\b` 0; control negativo `zzzaccess` 0 |
| `CIT-A4-03` | menor | §1.2 | "sin distinción Free/pago en la página" era un negativo universal falso. Se repone el alcance que el CSV ya traía: la **tabla de Access** no distingue; la página sí lo hace en la tabla de DEX, que este diseño no usa | `a4_volcados_cf.R` → `\bFree\b` 2 ocurrencias en la página, las dos en DEX, con su contexto impreso; control positivo `Applications 500` 1, control negativo `Applications 501` 0 |
| `CIT-A4-04` | menor | §3.1 y fila C43 del CSV | Las dos sentencias del ejemplo de Streams no son contiguas: entre ellas hay una línea de comentario. Se inserta el marcador `[...]` que el propio CSV usa en otras filas | `a4_volcados_cf.R` → la cadena contigua da `FALSE`; cada mitad por separado, 4 y 1; el bloque real impreso muestra el comentario intercalado; control negativo con `respuesta` → 0 |
| `CIT-A4-05` | mejorable | fila C26 del CSV | La glosa del autor salió de `cita_literal` y pasó a una columna **`nota`** nueva. `cita_literal` contiene solo texto transcrito | `Rscript …/a4_citas_verificadas.R` → `citas verificadas con texto en espanol dentro de cita_literal: 0 (esperado 0)`, con control positivo del detector sobre `nota`: 4 de 4 |
| `UNI-A4-01` | menor | §1.1, §1.2, §2, §7, §10 | Los volcados `cf_*.txt` y `buscar_usuarios.R` vivían en un scratchpad efímero. Se reemplazan por `a4_volcados_cf.R` y ocho `a4_cf_*.txt` conservados en el laboratorio, cada uno con URL, fecha, HTTP y peso en su cabecera; §10 declara además que el laboratorio no se versiona y que la reproducción exige repetir el `curl` | `ls 50_documentacion/andamios/lab_motor_v9/a4_cf_*.txt` → 8 archivos; `head -3` de cualquiera muestra la cabecera con fecha y HTTP 200 |
| `UNI-A4-02` | mejorable | §8.4 | El universal de los 3 MB no llevaba comando. Ahora el recorrido exhaustivo lo imprime `a4_stack_minimo.R` y §8.4 lo cita con sus dos controles | Último bloque de §8.2: 277 archivos, 227 no-PDF, **0** sobre 3 MB, mayor `sitio/search.json` 1,685 MB; **control positivo** 4 PDF sobre 3 MB; **control negativo** 0 sobre 3 TB |
| `CON-A4-03` | menor | §6 | La fila de la capa 2 se desdobla: la léxica sobrevive sin cambio, la **semántica cae a léxica** porque la consulta se vectoriza en el Worker. El asterisco de §5.1 no bastaba: el plan de degradación es lo que se lee para decidir | Tabla nueva de cinco filas en §6; el diagrama de §5.1 separa las dos vías. No cambia ninguna cifra |
| `CON-A4-07` | menor | §8.2, §8.3 | Se fija **una** fórmula (con metadatos, 57,8 B/unidad) y **una** unidad (1.160 fragmentos firmados, leídos de `a2_fragmentacion.csv`), y se tabulan los universos vecinos para que la síntesis los cruce | `a4_stack_minimo.R` → índice canónico int8 1.024 dims: **1.254.888 B (1.225,5 KiB)**; control cruzado: el artefacto de A2 declara 722 unidades firmadas y el recuento propio de A4 da 722 (`TRUE`). Medición propia de la cota inferior de metadatos: la ancla `slug#id` pesa 38,4 B UTF-8 de media, así que 57,8 es conservador |
| `CON-A4-08` | menor | §4.2, §4.4, §4.3 | La consulta de 80 tokens se declara supuesto conservador con el máximo **medido** al lado (17 tokens c4 sobre las diez consultas de A2), y `a4_costos.R` publica una segunda columna de costo con el contexto que A3 implica, leyendo sus tokens del artefacto de A3 en vez de recalcularlos | Bloque de §4.3: `consulta: SUPUESTO 80 tokens \| MEDIDO … max 66 car. = 17 tokens c4` y `== Costo del contexto que A3 publica ==` con los cuatro escenarios (3.773 / 8.229 / 8.677 / 22.045 tokens de entrada) y el contraste `+57.2%` |
| `CIF-A4-05` | mejorable | §8.3 (Vectorize, veredicto) | El "~150 normas" no salía de ninguna derivación. Se publica el umbral con la suya: **~105 normas** (cupo Free de almacenamiento a 1.024 dims sobre la unidad canónica), ~104 (int8 sobre 5 MiB), ~27 (float32); con la unidad vieja, 179 / 178 / 46. **Segunda pasada:** el veredicto decía que ~105 era "el menor de los tres umbrales" teniendo el de float32 al lado, y los dos umbrales de 5 MiB se calculaban sin los metadatos que §8.2 fija; se corrigen las dos cosas y el menor se nombra como lo que es | `a4_stack_minimo.R`, bloque "umbrales, con la unidad canonica … y con la vieja" → `4882 vectores = 105 normas \| … supera 5 MiB con 4846 = 104 normas \| float32 con 1262 = 27 normas`, y la línea `CONTROL (formula SIN metadatos …): int8 5120 vectores = 110 normas \| float32 1280 = 28 normas`, que son los valores publicados antes |
| `CIF-A4-06` | mejorable | §4.2, §8.1 | Los cuantiles se publicaban truncados por `as.integer()`. Se corrige el script a dos decimales y el documento a **888,5 / 3.117,9 / 4.610,65**, que es lo único coherente con el "mediano ≈ 223 tokens" de §4.3 (`ceiling(888,5/4)`) | `Rscript …/a4_medir_corpus.R` → `min 59.00 \| mediana 888.50 \| p90 3117.90 \| p95 4610.65 \| max 27167.00`, con la línea de control que imprime los valores truncados que se publicaban |
| `CIF-A4-07` | mejorable | §8.3 (Workers AI), §8.4 | El 4,5 % era solo el reranking. Se publica el total: **4,6 %** = reranking 4,48 % más embedding de la consulta 0,14 % | `a4_stack_minimo.R` → `escenario alto …: reranking 448.1 (4.48%) + embedding de la consulta 14.33 (0.14%) = 462.4 (4.62%)` |

**Corrección fuera de la tabla maestra, declarada aquí.** §3.3 decía que 6.000 ms por consulta son "tres órdenes de magnitud" sobre el límite de 10 ms; son 600 veces, es decir 2,78 órdenes. La auditoría lo anotó como nota de su primera pasada sin abrir una fila; se corrige igual, porque es aritmética y está en un documento de A4.

**Lo que esta fase NO tocó, por no ser de A4.** Las cifras del índice de embeddings que publican A2 (§3) y A5 (§5.1) siguen en sus documentos con sus fórmulas y unidades propias: `CON-A4-07` exige que las tres converjan y ese cruce es de la síntesis, no de un autor que solo puede escribir su archivo.


### 11.1 Ronda de cierre (2026-09-06): los defectos que introdujo la corrección

La verificación independiente de la fase 3 y la segunda pasada de la auditoría encontraron
siete defectos introducidos por las correcciones de arriba, más un hallazgo cerrado cuya
trazabilidad faltaba. Se reparan uno a uno, sin tocar nada que un defecto no nombre.

| Defecto (como lo nombró quien lo levantó) | Reparación | Verificación de este turno |
|---|---|---|
| `N-8` / `CIF-A4-04` a medias: `a4_worker_esqueleto.js` mantenía `CUOTA_GLOBAL_DIA = 200` mientras §5.1 y §5.4 publican 250, y el comentario de esa misma línea remite a §5.4 | La constante pasa a **250**, con el denominador en el comentario (20 días hábiles) | `grep -n 'CUOTA_GLOBAL_DIA'` → L46 valor 250; `node --check` sobre el archivo → sintaxis OK; los cinco `200` que quedan son códigos HTTP y un `slice(0, 2000)` |
| `N-7` / `CIF-A4-05` a medias: el veredicto de §8.3 decía "~105 normas, **que es el menor de los tres umbrales**" con 28 en la celda de al lado | El veredicto nombra el menor real y dice de qué variante es cada umbral; el umbral de float32 queda declarado como el que manda | `min(105, 104, 27) = 27`, con los tres umbrales impresos por `a4_stack_minimo.R` en el bloque "umbrales…" |
| `CON-A4-07` a medias: §8.2 fijaba la fórmula con metadatos y los dos umbrales de 5 MiB se seguían calculando sin ellos (`umbral %/% 1024` y `umbral %/% (1024*4)`) | El script usa la misma fórmula del bloque anterior (`1024 + 57,8` y `1024×4 + 57,8`) e imprime una línea de control con los valores sin metadatos, que son los que se publicaron antes. §8.2, §8.3 y la fila `CIF-A4-05` se actualizan | `Rscript …/a4_stack_minimo.R` → `supera 5 MiB con 4846 = 104 normas \| float32 con 1262 = 27 normas`; `CONTROL (formula SIN metadatos…): int8 5120 = 110 \| float32 1280 = 28`. El bloque pegado de §8.2 se repegó entero: `diff <(sed -n '464,533p' …) <(Rscript …)` → una sola diferencia, la hora |
| `N-9` / `UNI-A4-01` a medias: §1.2 atribuía `\busers\b` → 3 y `cloudflare` → 119 "al volcado conservado", y sobre ese archivo los patrones dan otra cosa | §1.2 publica las dos mediciones con su objeto: 3 y 119 sobre el **HTML crudo**, 0 y 18 sobre el **volcado conservado**, y explica por qué difieren (el volcado guarda el texto sin etiquetas y las tres apariciones viven en un atributo `content`). §10 suma la regla general | Los dos conteos se re-derivaron desde archivo (nunca con `Rscript -e`), con prueba de instrumento del `\b`: `\bZero\b` → 2 en el volcado y 8 en el crudo, `\bZzzzero\b` → 0 en ambos. `curl -sI --max-redirs 0` de la página → `HTTP/2 200`; descarga de hoy 412.900 bytes |
| `N-10` / `CIF-A4-03`: el comando publicado en §11 (`sed -n '186,284p'`) no reproducía | El rango pasa a **`189,287p`**, que es el contenido entre las vallas (188 y 288) | `diff <(sed -n '189,287p' …) <(Rscript …/a4_costos.R)` → una sola diferencia, la hora; con `186,284p` → 11 líneas |
| `N-11`: §9 fechaba el barrido HTTP el 2026-09-05 y el CSV regenerado trae 2026-09-06 | La fecha pasa a **2026-09-06**, que es la del CSV | `Rscript` sobre `a4_citas_verificadas.csv` → 56 filas, `fecha_consulta` 2026-09-06 en **56**; control negativo, filas con 2026-09-05 → **0** |
| `N-13`: dos incisos con raya larga en prosa propia (§5.2), contra la convención del kit | Los dos incisos pasan a paréntesis | Recuento sobre el archivo: 4 ocurrencias en 3 líneas (67, 106 y 137), **todas dentro de citas literales en inglés**; control positivo sobre una cadena con raya construida en este turno → 1, control negativo con paréntesis → 0 |
| Trazabilidad de `UNI-A4-02`: la fila existía en el documento pero faltaba en el reporte de la fase 3 | Nada que reparar en el archivo: la corrección estaba aplicada y sigue reproduciendo | `grep -c 'UNI-A4-02'` → **2** (§8.4 y la fila de §11), control negativo con un id inventado → 0; sus cifras siguen en el bloque re-corrido de §8.2 (277 archivos, 227 no-PDF, 0 sobre 3 MB, control positivo 4 PDF, control negativo 0 sobre 3 TB) |

**Lo que esta ronda tampoco pudo cerrar.** `CON-A4-07` sigue abierto en su mitad
compartida: el panel de A5 publica en su §5.1 un tercer universo para el mismo índice
(806 unidades, MB decimales) y ningún hallazgo mandó tocarlo. Fijar una sola cifra para el
paquete es decisión de la síntesis, no de un autor que solo puede escribir su archivo.
