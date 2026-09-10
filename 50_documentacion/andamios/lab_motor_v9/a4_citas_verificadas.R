# =============================================================================
# a4_citas_verificadas.R - genera a4_citas_verificadas.csv (A4, encargo v9)
# -----------------------------------------------------------------------------
# Cada fila: un dato citado en 20260904_alcance_arquitectura_cloudflare_v1.md,
# su URL, la frase literal leida (curl -s + extraccion en R, 2026-09-05) y el
# codigo HTTP que la URL devuelve HOY, medido aqui mismo con HEAD y SIN seguir
# redirecciones. Guarda programatica: solo se contacta a los hosts autorizados
# por el encargo; cualquier otra URL aborta el script antes de tocar la red.
# Incluye el control positivo (URL existente -> 200) y el negativo (URL
# inventada -> 404) para mostrar que el instrumento distingue.
# =============================================================================
suppressPackageStartupMessages({library(tibble); library(dplyr); library(purrr); library(readr); library(curl); library(here)})
HOSTS_AUTORIZADOS <- c("developers.cloudflare.com", "www.cloudflare.com", "docs.claude.com", "www.anthropic.com")
host_de <- function(u) sub("^https?://([^/]+).*$", "\\1", u)

citas <- tribble(
  ~id, ~dato, ~url, ~cita_literal, ~estado,
  "C01", "Workers Free: tabla de limites de cuenta", "https://developers.cloudflare.com/workers/platform/limits/",
    "Account plan limits Feature Workers Free Workers Paid Requests 100,000/day No limit CPU time 10 ms 5 min Memory 128 MB 128 MB Subrequests 50/request 10,000/request Simultaneous outgoing connections/request 6 6 Environment variables 64/Worker 128/Worker Environment variable size 5 KB 5 KB Worker size 64 MiB 64 MiB Worker startup time 1 second 1 second Number of Workers 100 500", "verificado",
  "C02", "Workers Free: cupo diario y Error 1027", "https://developers.cloudflare.com/workers/platform/limits/",
    "Accounts on the Workers Free plan have a daily request limit of 100,000 requests, resetting at midnight UTC. [...] When a Worker exceeds this limit, Cloudflare returns Error 1027.", "verificado",
  "C03", "Workers: tamano del Worker sin comprimir", "https://developers.cloudflare.com/workers/platform/limits/",
    "Worker size (uncompressed) 64 MiB 64 MiB There is no compressed size limit. Only the uncompressed bundle size counts.", "verificado",
  "C04", "CPU: la espera de red no cuenta", "https://developers.cloudflare.com/workers/platform/limits/",
    "CPU time measures how long the CPU spends executing your Worker code. Waiting on network requests (such as fetch() calls, KV reads, or database queries) does not count toward CPU time.", "verificado",
  "C05", "Duracion: sin limite duro mientras el cliente siga conectado; streaming", "https://developers.cloudflare.com/workers/platform/limits/",
    "There is no hard limit on duration for HTTP-triggered Workers. As long as the client remains connected, the Worker can continue processing, making subrequests, and streaming a response body.", "verificado",
  "C06", "Streaming: el Worker sigue activo", "https://developers.cloudflare.com/workers/platform/limits/",
    "A Worker that is still streaming a response body remains active.", "verificado",
  "C07", "Instrumento para medir CPU del proxy", "https://developers.cloudflare.com/workers/platform/limits/",
    "Workers Logs — CPU time and wall time appear in the invocation log. Tail Workers / Logpush — CPU time and wall time appear at the top level of the Workers Trace Events object.", "verificado",
  "C08", "Workers pricing: Free y Standard", "https://developers.cloudflare.com/workers/platform/pricing/",
    "Free 100,000 per day No charge for duration 10 milliseconds of CPU time per invocation Standard 10 million included per month +$0.30 per additional million No charge or limit for duration 30 million CPU milliseconds included per month +$0.02 per additional million CPU milliseconds", "verificado",
  "C09", "Access puede proteger workers.dev (pagina workers.dev)", "https://developers.cloudflare.com/workers/configuration/routing/workers-dev/",
    "To require visitors to sign in before they can access a workers.dev URL, use Cloudflare Access. Access can protect one Worker's production workers.dev URL, preview URLs, or both. You can also protect all Workers or all Worker previews in an account. To use details about the signed-in user in your Worker, use ctx.access.", "verificado",
  "C10", "workers.dev es un sitio Free para proyectos no criticos", "https://developers.cloudflare.com/workers/configuration/routing/workers-dev/",
    "Your workers.dev subdomain is treated as a Free website and is intended for personal or hobby projects that aren't business-critical.", "verificado",
  "C11", "Access para Workers: requisitos (Zero Trust, no una zona)", "https://developers.cloudflare.com/workers/configuration/cloudflare-access/",
    "Before you start To use Access with Workers, you need: Zero Trust enabled on your account. If Zero Trust is not turned on, complete Zero Trust setup first, then return to the Workers dashboard. Permission to manage Workers and Access applications.", "verificado",
  "C12", "Access para Workers: proteger un Worker cubre su hostname workers.dev", "https://developers.cloudflare.com/workers/configuration/cloudflare-access/",
    "Protect one Worker Require sign-in on a single Worker. This automatically protects every domain associated with the Worker, including its routes, Custom Domains, workers.dev hostname, and previews.", "verificado",
  "C13", "Access para Workers: hostname puede ser workers.dev", "https://developers.cloudflare.com/workers/configuration/cloudflare-access/",
    "A specific hostname — can be workers.dev, a Custom Domain, or a path", "verificado",
  "C14", "ctx.access y ruta del panel", "https://developers.cloudflare.com/workers/configuration/cloudflare-access/",
    "ctx.access is undefined if Access did not authenticate the request. [...] Dashboard path: Workers & Pages > select your Worker > Access.", "verificado",
  "C15", "App autohospedada generica: exige dominio/zona activa", "https://developers.cloudflare.com/cloudflare-one/access-controls/applications/http-apps/self-hosted-public-app/",
    "Prerequisites An active domain on Cloudflare Domain uses either a full setup or a partial (CNAME) setup [...] Domains must belong to an active zone in your Cloudflare account.", "verificado",
  "C16", "Validar el JWT de Access en el Worker", "https://developers.cloudflare.com/cloudflare-one/access-controls/applications/http-apps/authorization-cookie/validating-json/",
    "You should validate the token with your public key to ensure that the request came from Access and not a malicious third party. We recommend validating the Cf-Access-Jwt-Assertion header instead of the CF_Authorization cookie, since the cookie is not guaranteed to be passed. [...] The public key for the signing key pair is located at https://<your-team-name>.cloudflareaccess.com/cdn-cgi/access/certs", "verificado",
  "C17", "CORS contra Access: OPTIONS devuelve 403", "https://developers.cloudflare.com/cloudflare-one/access-controls/applications/http-apps/authorization-cookie/cors/",
    "If you make a preflighted cross-origin request to an Access-protected domain, the OPTIONS request will return a 403 error. This error occurs regardless of whether you have logged in to the domain. This is because the browser never includes cookies with OPTIONS requests, by design.", "verificado",
  "C18", "CORS contra Access: exige cookie CF-Authorization", "https://developers.cloudflare.com/cloudflare-one/access-controls/applications/http-apps/authorization-cookie/cors/",
    "For a CORS request to reach a site protected by Access, the request must include a valid CF-Authorization cookie.", "verificado",
  "C19", "Retencion de logs de Access por plan (Free 24 horas)", "https://developers.cloudflare.com/cloudflare-one/insights/logs/",
    "Free Standard Access Gateway Enterprise Admin logs 18 months 18 months 18 months 18 months 18 months Access logs 24 hours 30 days 30 days 24 hours 180 days", "verificado",
  "C20", "Campos de los logs de autenticacion de Access", "https://developers.cloudflare.com/cloudflare-one/insights/logs/dashboard-logs/access-authentication-logs/",
    "User email Email address of the authenticating user. [...] IP address IP address of the authenticating user. [...] Authentication logs do not capture the user's actions during a self-hosted or SaaS application session.", "verificado",
  "C21", "Asientos de Zero Trust: se consumen por autenticacion", "https://developers.cloudflare.com/cloudflare-one/team-and-resources/users/seat-management/",
    "Cloudflare One subscriptions consist of seats that active users in your account consume. Active users are added to Cloudflare One through any authentication event. The amount of seats available in your Cloudflare One account depends on the amount of users you purchase.", "verificado",
  "C22", "Zero Trust Free: numero maximo de usuarios", "https://www.cloudflare.com/plans/zero-trust-services/",
    "NO MEDIDO: la pagina responde 200 pero su contenido se renderiza por JavaScript; el HTML crudo (412,901 bytes) contiene 'users' solo en la meta descripcion y ninguna coincidencia de 'seats', '50 users' ni 'Up to N users'. Verificar en navegador o con un host autorizado que sirva el JSON de planes.", "no_medido",
  "C23", "Zero Trust Free existe; proveedor de identidad de Cloudflare por defecto", "https://developers.cloudflare.com/cloudflare-one/setup/",
    "If you chose the Zero Trust Free plan, this step is still needed but you will not be charged. When you create your organization, Cloudflare automatically adds the Cloudflare identity provider as your default login method", "verificado",
  "C24", "Metodos de identidad: SAML/OIDC y PIN por correo", "https://developers.cloudflare.com/cloudflare-one/integrations/identity-providers/",
    "Cloudflare supports all SAML and OIDC providers and can integrate with the majority of OAuth providers. [...] You can also send a one-time PIN (OTP) to approved email addresses. No configuration needed — simply add a user's email address to an Access policy", "verificado",
  "C25", "PIN por correo: ya no se agrega solo; expira en 10 minutos", "https://developers.cloudflare.com/cloudflare-one/integrations/identity-providers/one-time-pin/",
    "New Zero Trust organizations use the Cloudflare identity provider as their default login method. OTP is no longer added automatically, but you can set it up at any time [...] This secure PIN expires 10 minutes after the initial request.", "verificado",
  "C26", "Limites de cuenta de Access (tabla Feature/Limit, columna unica)", "https://developers.cloudflare.com/cloudflare-one/account-limits/",
    "Applications 500 [...] Identity providers 50 [...] Service tokens 50", "verificado",
  "C27", "Vectorize Free: dimensiones consultadas y almacenadas", "https://developers.cloudflare.com/vectorize/platform/pricing/",
    "Total queried vector dimensions 30 million queried vector dimensions / month [...] Total stored vector dimensions 5 million stored vector dimensions", "verificado",
  "C28", "Vectorize: limites por indice", "https://developers.cloudflare.com/vectorize/platform/limits/",
    "Indexes per account 50,000 (Workers Paid) / 100 (Free) Maximum dimensions per vector 1536 dimensions, 32 bits precision [...] Maximum returned results (topK) with values or metadata 50 [...] Maximum vectors per index 20,000,000 Maximum namespaces per index 50,000 (Workers Paid) / 1000 (Free)", "verificado",
  "C29", "Workers AI Free: 10,000 neuronas/dia", "https://developers.cloudflare.com/workers-ai/platform/pricing/",
    "Our free allocation allows anyone to use a total of 10,000 Neurons per day at no charge. [...] If you exceed any one of the above limits, further operations will fail with an error. [...] $0.011 / 1,000 Neurons", "verificado",
  "C30", "Workers AI: precio de bge-m3 y bge-reranker-base", "https://developers.cloudflare.com/workers-ai/platform/pricing/",
    "@cf/baai/bge-m3 $0.012 per M input tokens 1075 neurons per M input tokens [...] @cf/baai/bge-reranker-base $0.003 per M input tokens 283 neurons per M input tokens", "verificado",
  "C31", "Workers AI: tasa por tipo de tarea", "https://developers.cloudflare.com/workers-ai/platform/limits/",
    "Text Embeddings 3000 requests per minute [...] Text Generation 300 requests per minute", "verificado",
  "C32", "AI Search: en todos los planes; hibrida", "https://developers.cloudflare.com/ai-search/",
    "Available on all plans [...] Hybrid search Combine semantic and keyword matching in the same query for more accurate results.", "verificado",
  "C33", "AI Search: BM25, fusion, reranking cross-encoder", "https://developers.cloudflare.com/ai-search/concepts/how-ai-search-works/",
    "When hybrid search is enabled, a BM25 keyword search runs in parallel with vector search. Fusion (optional): When using hybrid search, vector and keyword results are combined using the configured fusion method. Reranking (optional): A cross-encoder model re-scores results by evaluating the query and document together.", "verificado",
  "C34", "AI Search: metodos de fusion rrf (defecto) y max", "https://developers.cloudflare.com/ai-search/configuration/indexing/hybrid-search/",
    "rrf Yes Reciprocal Rank Fusion. Scores results based on rank position across both search methods. Recommended for most use cases. max No Takes the higher of the normalized vector and keyword scores. Use when one search method is consistently more relevant.", "verificado",
  "C35", "AI Search: puntajes conservados por resultado", "https://developers.cloudflare.com/ai-search/configuration/indexing/hybrid-search/",
    "vector_score number Vector similarity score (0 to 1). keyword_score number Raw BM25 keyword score. vector_rank number Rank position in the vector result set. keyword_rank number Rank position in the keyword result set. fusion_method string Fusion method used (rrf or max). reranking_score number Score from the reranking model, if enabled.", "verificado",
  "C36", "AI Search: reranking apagado por defecto; modelo", "https://developers.cloudflare.com/ai-search/configuration/retrieval/reranking/",
    "By default, reranking is disabled for all AI Search instances. You can enable it during creation or later from the settings page. [...] model: \"@cf/baai/bge-reranker-base\" [...] there may be an increase in the latency of the request.", "verificado",
  "C37", "AI Search: operadores de filtro por metadatos", "https://developers.cloudflare.com/ai-search/configuration/retrieval/filtering/",
    "$eq Equals $ne Not equals $in Matches a stored scalar against any candidate scalar value $nin Excludes a stored scalar matching any candidate scalar value $lt Less than $lte Less than or equal to $gt Greater than $gte Greater than or equal to [...] Multiple conditions (implicit AND)", "verificado",
  "C38", "AI Search: gratis en beta abierta; Workers AI aparte", "https://developers.cloudflare.com/ai-search/platform/limits-pricing/",
    "During the open beta, AI Search is free within these limits. Workers AI and AI Gateway usage is billed separately. Pricing details will be communicated at least 30 days before any billing begins.", "verificado",
  "C39", "AI Search: tabla de limites Free/Paid", "https://developers.cloudflare.com/ai-search/platform/limits-pricing/",
    "AI Search instances per account 100 5,000 Namespaces per account 100 100 Files per instance 100,000 1M or 500K for hybrid search [...] Max file size 4 MB 4 MB Queries per month 20,000 Unlimited [...] Maximum pages crawled per day 500 Unlimited Max custom metadata fields 5 per AI Search instance 5 per AI Search instance", "verificado",
  "C40", "AI Search: tokenizador de palabras clave (Porter o trigramas)", "https://developers.cloudflare.com/ai-search/configuration/indexing/keyword-search/",
    "porter Yes Applies Porter stemming. \"running\" matches \"run.\" Best for natural language. trigram No Overlapping 3-character windows. \"config\" matches \"configuration.\" Best for code. [...] and Yes All query terms must appear. Higher precision, fewer results. or No Any query term can match.", "verificado",
  "C41", "AI Search: modelos de embedding y reranking", "https://developers.cloudflare.com/ai-search/configuration/models/supported-models/",
    "Workers AI @cf/baai/bge-m3 1,024 512 cosine [...] Reranking Provider Alias Input tokens Workers AI @cf/baai/bge-reranker-base 512", "verificado",
  "C42", "Secretos: no visibles tras definirlos; wrangler secret put", "https://developers.cloudflare.com/workers/configuration/secrets/",
    "Secrets are environment variables. The difference is secret values are not visible within Wrangler or Cloudflare dashboard after you define them. [...] npx wrangler secret put <KEY>", "verificado",
  "C43", "Streams: paso a traves sin bufer", "https://developers.cloudflare.com/workers/runtime-apis/streams/",
    "Use the Streams API to avoid buffering large requests or responses in memory. This enables you to parse extremely large request or response bodies within a Worker's 128 MB memory limit. [...] const response = await fetch(request); [...] return new Response(response.body, response);", "verificado",
  "C44", "Rate Limiting binding: periodo, consistencia, localidad", "https://developers.cloudflare.com/workers/runtime-apis/bindings/rate-limit/",
    "Period: the duration of the period, in seconds. Must be either 10 or 60 [...] the Rate Limiting API is permissive, eventually consistent, and intentionally designed to not be used as an accurate accounting system. [...] For each unique key you pass to your rate limiting binding, there is a unique limit per Cloudflare location.", "verificado",
  "C45", "Durable Objects en Free (SQLite) y sus cupos", "https://developers.cloudflare.com/durable-objects/platform/pricing/",
    "Durable Objects are available both on Workers Free and Workers Paid plans. Workers Free plan: Only Durable Objects with SQLite storage backend are available. [...] Requests 100,000 / day [...] Rows written 100,000 / day", "verificado",
  "C46", "KV Free: cupos diarios", "https://developers.cloudflare.com/kv/platform/pricing/",
    "Keys read 100,000 / day [...] Keys written 1,000 / day [...] Stored data 1 GB", "verificado",
  "C47", "Workers Logs Free: volumen, retencion, contenido del log de invocacion", "https://developers.cloudflare.com/workers/observability/logs/workers-logs/",
    "Workers Free 200,000 per day 3 Days [...] Each Workers invocation returns a single invocation log that contains details such as the Request, Response, and related metadata.", "verificado",
  "C48", "Precio API Claude (docs.claude.com pricing)", "https://docs.claude.com/en/docs/about-claude/pricing",
    "NO MEDIDO: HTTP/2 302 location: https://platform.claude.com/docs/en/about-claude/pricing (host no autorizado; no se sigue).", "no_medido",
  "C49", "Precio API Claude (docs.claude.com api/pricing)", "https://docs.claude.com/en/api/pricing",
    "NO MEDIDO: HTTP/2 301 location: https://platform.claude.com/docs/en/api/pricing (host no autorizado; no se sigue).", "no_medido",
  "C50", "Precio API Claude (anthropic.com/pricing)", "https://www.anthropic.com/pricing",
    "NO MEDIDO: HTTP/2 301 location: https://claude.com/pricing (host no autorizado; no se sigue).", "no_medido",
  "C51", "Precio API Claude (anthropic.com/api)", "https://www.anthropic.com/api",
    "NO MEDIDO: HTTP/2 301 location: https://claude.com/platform/api (host no autorizado; no se sigue).", "no_medido",
  "C52", "docs.claude.com raiz", "https://docs.claude.com/",
    "NO MEDIDO: HTTP/2 301 location: https://platform.claude.com/docs (host no autorizado; no se sigue).", "no_medido",
  "C53", "docs.claude.com modelos", "https://docs.claude.com/en/docs/about-claude/models/overview",
    "NO MEDIDO: HTTP/2 302 location: https://platform.claude.com/docs/en/about-claude/models/overview (host no autorizado; no se sigue).", "no_medido",
  "C54", "CONTROL POSITIVO: URL existente responde 200", "https://developers.cloudflare.com/workers/platform/limits/",
    "control", "control_positivo",
  "C55", "CONTROL NEGATIVO: URL inventada responde 404", "https://developers.cloudflare.com/esta-url-no-existe-a4-control-negativo-v9/",
    "control", "control_negativo",
  "C56", "Redireccion dentro del mismo host (se siguio a mano)", "https://developers.cloudflare.com/cloudflare-one/applications/",
    "HTTP/2 301 location: /cloudflare-one/access-controls/applications/http-apps/ (mismo host; destino leido)", "verificado"
)

# ---- notas del AUTOR (CIT-A4-05) --------------------------------------------
# La columna `cita_literal` contiene SOLO texto transcrito de la fuente. Toda
# evaluacion, alcance o advertencia de A4 vive en `nota`, que no se lee como cita.
notas <- tribble(
  ~id, ~nota,
  "C26", "Alcance: la TABLA DE ACCESS de esta pagina no distingue Free de pago (columna unica `Limit`). La pagina si distingue planes mas abajo, en la tabla de Digital Experience Monitoring, que este diseno no usa.",
  "C43", "Las dos sentencias existen textualmente pero NO son contiguas: entre ellas la pagina intercala la linea de comentario `// ... and deliver our Response while that's running.`. El marcador [...] senala esa elision.",
  "C22", "El universal de ausencia se re-deriva con `a4_volcados_cf.R`, que conserva el volcado en `a4_cf_zt_planes.txt` con su fecha.",
  "C44", "La pagina no declara en que planes esta disponible el binding. Conteo con metodo declarado en `a4_volcados_cf.R`: 3 ocurrencias de \\bfree\\b en el texto sin etiquetas, ninguna sobre planes de Cloudflare."
)

# ---- guarda programatica de hosts, ANTES de cualquier solicitud -------------
hosts <- unique(host_de(citas[["url"]]))
no_autorizados <- setdiff(hosts, HOSTS_AUTORIZADOS)
if (length(no_autorizados) > 0) stop("Host no autorizado en la lista de citas: ", paste(no_autorizados, collapse = ", "))
cat("hosts contactados (todos autorizados):", paste(hosts, collapse = ", "), "\n")

# ---- HEAD sin seguir redirecciones -------------------------------------------
sondear <- function(u) {
  h <- new_handle(nobody = TRUE, followlocation = FALSE, timeout = 20)
  r <- tryCatch(curl_fetch_memory(u, handle = h), error = \(e) NULL)
  if (is.null(r)) return(tibble(http = NA_integer_, location = "ERROR_RED"))
  loc <- parse_headers_list(r[["headers"]])[["location"]]
  tibble(http = as.integer(r[["status_code"]]), location = if (is.null(loc)) "" else loc)
}
fecha <- format(Sys.time(), "%Y-%m-%d %H:%M %Z")
urls_unicas <- unique(citas[["url"]])
sondeo <- map_dfr(urls_unicas, \(u) bind_cols(tibble(url = u), sondear(u)))
salida <- citas |> left_join(sondeo, by = "url") |> left_join(notas, by = "id") |>
  mutate(fecha_consulta = fecha, nota = tidyr::replace_na(nota, "")) |>
  select(id, dato, url, http, location, fecha_consulta, estado, cita_literal, nota)
# CIT-A4-05: control de que ninguna cita literal trae glosa del autor. Los parentesis
# en ingles del original son legitimos; lo que no puede haber es texto en espanol.
# El lexico excluye palabras que tambien son inglesas ("no", "de", "el"): con ellas el
# detector marcaba 9 citas legitimas ("No limit", "Number of Workers") y era inservible.
pat_es <- "(?i)\\b(pagina|p\u00e1gina|tabla|distingue|defecto|dise\u00f1o|diseno|segun|seg\u00fan|para|que|los|las|una|del|por|con)\\b"
con_espanol <- grepl(pat_es, salida[["cita_literal"]], perl = TRUE) & salida[["estado"]] == "verificado"
cat("citas verificadas con texto en espanol dentro de cita_literal:", sum(con_espanol), "(esperado 0)\n")
if (any(con_espanol)) print(as.data.frame(salida[con_espanol, c("id", "cita_literal")]), row.names = FALSE)
cat("CONTROL POSITIVO del detector: sobre la columna `nota` (que si esta en espanol) detecta",
    sum(grepl(pat_es, salida[["nota"]], perl = TRUE)), "de", sum(nzchar(salida[["nota"]])), "filas con nota\n")

destino <- here::here("50_documentacion/andamios/lab_motor_v9/a4_citas_verificadas.csv")
write_csv(salida, destino)
cat("filas escritas:", nrow(salida), " ->", destino, "\n\n")
print(as.data.frame(salida |> select(id, http, location, estado) |> mutate(location = substr(location, 1, 70))), row.names = FALSE)

# ---- comprobaciones: controles y redirecciones --------------------------------
stopifnot(salida[["http"]][salida[["id"]] == "C54"] == 200L)
stopifnot(salida[["http"]][salida[["id"]] == "C55"] == 404L)
cat("\ncontrol positivo C54 -> 200 [OK] | control negativo C55 -> 404 [OK]\n")
fuera <- salida |> filter(location != "", !grepl("^/", location)) |>
  mutate(host_destino = host_de(location)) |> filter(!(host_destino %in% HOSTS_AUTORIZADOS))
cat("redirecciones a hosts NO autorizados (no seguidas):", nrow(fuera), "\n")
print(as.data.frame(fuera |> select(id, url, location)), row.names = FALSE)
cat("verificadas con 200:", sum(salida[["http"]] == 200L & salida[["estado"]] == "verificado", na.rm = TRUE), "de",
    sum(salida[["estado"]] == "verificado"), "filas 'verificado'\n")
