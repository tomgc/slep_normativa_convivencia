# Encargo autónomo — ensayo general y cierre de calidad (v6), sesión 2

Proyecto: `slep_normativa_convivencia`. Patrón: `encargo_autonomo_claude_code_v1.md` (v1.3). Sucede al encargo v5 y su verificación en runner. Propósito declarado: cerrar las TRES dudas residuales que quedan sobre la calidad del trabajo de la sesión, que son exactamente las que ningún encargo anterior midió: (1) **el camino de publicación de piezas jamás se ha ejercitado de punta a punta** — toda la evidencia de la compuerta es de arnés, y ninguna pieza ha recorrido nunca borrador → validada → página → índice → buscador; (2) **la reproducibilidad no está probada ni desde cero ni entre cadenas** (el runner ya corre R 4.6.1 / Quarto 1.10.18 contra 4.5.2 / 1.9.38 declarados, D-j); (3) **la compuerta de coincidencia parcial no tiene control positivo en el runner** (hueco declarado en la adenda v5). Además ejecuta la ronda 2 de la compuerta ya recomendada (D-a, D-b, D-c, D-d, D-e, D-h).

## 1. Contrato

- **Modo:** autónomo, secuencial, todo en este turno. Subagentes: SOLO de solo-lectura para el panel adversarial de T1, tope duro 2; reintentos por fallo de infraestructura no cuentan contra el tope. **Todo prompt de subagente declara: R o jq exclusivamente, Python prohibido (CLAUDE.md §7), sin escritura en el repositorio real.**
- **ENTORNO:** filesystem local vía Claude Code, raíz `~/Projects/slep_normativa_convivencia`, macOS, R 4.5.2, Quarto 1.9.38 local; runner Linux con versiones sin fijar (fuente: adenda v5, leída por el redactor).
- **INSUMOS:** por ruta desde la raíz. Claves: `30_procesamiento/34_generar_paginas.R`, `10_utils/`, `00_run_all.R`, `.github/workflows/publicar.yml`, `20_insumos/curaduria/piezas/` (solo lectura EN EL REPO REAL), README de piezas (localizar en FASE 0), `50_documentacion/andamios/20260826_pauta_validacion_convivencia_v1.md`, log v5 §8 (D-a a D-i) y adenda, `CLAUDE.md` §10.5.
- **POSICIÓN:** rutas completas desde la raíz; `bash` explícito o `Rscript`; FASE 0 abre con `git fetch` y `HEAD` vs `origin/main` (esperado: ambos en `7bbb452` o posterior de la misma cadena).

### Regla de detención (lista medible)

1. Porcelain vacío o SOLO la entrada `??` de este encargo → commitéalo (`docs(andamios): encargo v6`) y sigue. Otra cosa → detén la SESIÓN.
2. `ESTADO.md` sin `sesion_abierta: true` + `commit_cierre: 358e150` → detén la SESIÓN.
3. **Los clones de trabajo jamás empujan**: inmediatamente después de cada `git clone`, `git remote remove origin` DENTRO del clon y verifica `git remote -v` vacío. Si eso falla, congela la tarea del clon sin ejecutar nada más en él.
4. Si el build desde clon limpio (T3a) no puede restaurar dependencias → congela T3a, registra la limitación exacta, y ejecuta T3b igualmente sobre el clon (T3b no depende de la restauración si el clon usa la biblioteca local; declara el mecanismo).
5. Si en T3b la publicación de la pieza limpia FALLA en el clon → NO lo arregles: es el hallazgo más valioso posible (el camino de la vía A está roto y se descubrió en ensayo, no con el equipo mirando). Congela, registra con evidencia completa, sigue con lo demás.
6. Si las versiones a fijar en el workflow no existen en las actions del runner → fija las más cercanas disponibles y registra la diferencia; si no hay forma de fijar, congela esa mitad de T2.
7. Si alguna de las 22 piezas reales cambia de veredicto con la ronda 2 → congela T1 (misma regla que v5: el endurecimiento no puede romper el corpus real sin decisión del titular).
8. Cualquier estado, conteo o resultado no enumerado → congela ESTA tarea, duda al log, sigue con la próxima independiente.

### Autorizaciones (lista cerrada)

- **Repo real**, escribir SOLO en: `30_procesamiento/34_generar_paginas.R`, `10_utils/`, `00_run_all.R`, `.github/workflows/publicar.yml`, `40_salidas/` (solo vía regeneración), `50_documentacion/andamios/` y `50_documentacion/andamios/logs/`. `20_insumos/` en el repo real: SOLO lectura, sin excepción en este encargo.
- **Clones bajo `/tmp/slep_v6_*`**: lectura y escritura SIN restricción de rutas DENTRO del clon (incluida su copia de `20_insumos/`: el ensayo existe para simular la escritura humana), con remote eliminado (condición 3), y borrado completo al cerrar. La regla de escritura humana exclusiva protege el repositorio real; el clon es un banco de pruebas y esta autorización lo dice explícitamente para que ninguna tarea se congele por leerla en su forma general.
- `gh` solo lectura; fetch de la URL pública del sitio.
- Regeneración por `Rscript 00_run_all.R` (repo real) y el mecanismo equivalente dentro de los clones.
- `git add <rutas explícitas>`, commits atómicos, push del repo real al cierre + UN segundo push solo-documentación para evidencia de CI.
- `git checkout -- <ruta>` solo para restaurar tarea congelada, lista impresa antes.
- Nada más.

### Reglas canónicas heredadas

`CLAUDE.md` §7, §10.5; traspaso v01 §12; los 🔒 de siempre sobre el repo real. **La sesión NO se cierra: `ESTADO.md` no se toca.**

## 2. Estado de partida (premisas marcadas — se re-miden en FASE 0)

- `HEAD` == `origin/main` == `7bbb452`, árbol limpio (hipótesis, FASE 0).
- Conductas pendientes de la ronda 2, según log v5 §8: `titulo`/`fecha_validacion`/`fuentes` fuera de la compuerta con reventón aguas abajo; `validado_por` publica cualquier cadena con una letra; colisión de slug hace desaparecer una pieza; 2 de 92 anclas rotas latentes (`faq_revision_de_mochilas.md` → `#materia`, `faq_seguridad_y_deteccion.md` → `#concordancias`); NBSP y confusables en `estado`; `tipo` sin normalizar; README de piezas comparado exacto; Latin-1 revienta sin nombrar archivo (hipótesis: el arnés de T1 re-mide TODA esta lista sobre el código actual antes de tocar nada).
- El README de piezas declara 8 campos obligatorios (hipótesis; localizar el archivo y verificar si vive bajo `20_insumos/` — si es así, en el repo real NO se edita: se imprime el diff propuesto para el titular).
- El workflow no fija versiones de R ni de Quarto (hipótesis, grep).
- Las 22 piezas reales pasan la compuerta actual con veredicto borrador (hipótesis; condición 7).
- Existe mecanismo de dependencias restaurable en un clon (renv u otro) (hipótesis; FASE 0 lo identifica y decide la estrategia de T3a con evidencia).

## 3. Contexto mínimo

Último encargo de máquina de la sesión 2. Después de esto: entrega de la pauta al equipo de convivencia y cierre de sesión con protocolo. El estándar de éxito no es "las tareas corrieron": es que el log deje al auditor sin ninguna duda que no esté o cerrada con evidencia o declarada con su comando de verificación futuro.

## 4. Invariantes (🔒)

Los de siempre sobre el repo real, más: el endurecimiento no cambia el veredicto de ninguna pieza real; toda regla nueva aborta nombrando archivo y clave; los clones no empujan y se borran; **ninguna pieza real se publica: la única pieza que llega a HTML en este encargo vive y muere dentro del clon**.

## 5. Cadena de tareas y grafo

Grafo: T1 → (T2, T3) → T4; T3a antes que T3b sobre el mismo clon; T5 documental al final. El ensayo (T3b) corre con la compuerta de ronda 2 ya instalada, que es la que la vía A usará de verdad.

### FASE 0 — Medición (sin modificar nada)

1. Porcelain, sincronía, `git log --oneline 7bbb452..HEAD`.
2. `ESTADO.md`.
3. Arnés de partida: reproducir la lista completa de conductas pendientes de §2 sobre el código actual (mismo método de v5: funciones reales extraídas del árbol de parseo).
4. Localizar README de piezas; contar sus campos obligatorios; determinar si vive bajo `20_insumos/`.
5. `grep -n 'setup-r\|quarto-actions\|r-version\|version' .github/workflows/publicar.yml`.
6. Verificar las 2 anclas rotas y elegir por medición una pieza real LIMPIA (todas sus anclas resuelven contra los `id` de los JSON) como candidata del ensayo.
7. Identificar el mecanismo de dependencias para el clon (renv / biblioteca local) con evidencia.
8. Línea base sha256 de `40_salidas/`.

### T1 — Ronda 2 de la compuerta (D-a, D-b, D-c, D-d, D-h)

- Extender `revisar_pieza()` a los campos que el generador lee: `titulo` (obligatorio, texto no vacío, misma regla anti-`as.character()` que la firma), `fecha_validacion` (obligatoria si `estado: validada`; formato fecha plausible), `fuentes` (lista no vacía; cada entrada con `norma`, `articulo`, `ancla` presentes y de tipo texto).
- `validado_por`: además de la regla v5, exigir AL MENOS DOS palabras alfabéticas de 2+ letras cada una (nombre y apellido), tras normalizar espacios duros (U+00A0 y familia) a espacio simple; lista negra tras `tolower(trimws())`: {`null`, `na`, `n/a`, `s/i`, `si`, `no`, `pendiente`, `por definir`, `x`, `xx`, `tbd`}. El mensaje de error da un ejemplo VÁLIDO ("María Pérez"), no uno que publique mal.
- `tipo` se normaliza igual que `estado` (`tolower(trimws())` con NBSP incluidos) antes de validar contra el conjunto conocido.
- Colisión de slug: si dos piezas producen el mismo slug, ABORTA nombrando los dos archivos (D-d).
- Compuerta de anclas (D-e): toda ancla de `fuentes` de una pieza PUBLICABLE debe existir en los `id` reales de los JSON de norma; ancla inexistente → ABORTA nombrando pieza, ancla y documento. Para piezas en borrador: solo aviso en el log (no puede abortar el pipeline entero por borradores que nadie firmó aún).
- Lectura robusta: archivo no-UTF-8 → aborto que NOMBRA el archivo antes de que `trimws()` reviente; exclusión de README insensible a mayúsculas (D-h).
- Candado de conteo y errores aguas abajo restantes: mensajes que nombran pieza y causa en lenguaje de persona (D-c).
- Verificación: arnés antes/después con la tabla completa (los casos de FASE 0.3 más los legítimos); las 22 reales sin cambio de veredicto (condición 7); regeneración no-op byte a byte. **Panel adversarial (2, solo lectura):** atacar las reglas nuevas, incluida la compuerta de anclas, con casos propios.
- Commit: `fix(sitio): compuerta ronda 2 (D-a b c d e h del log v5)`.

### T2 — CI reproducible y con autoprueba

- Fijar en el workflow las versiones de R y Quarto que produjeron las salidas commiteadas (4.5.2 / 1.9.38, o las más cercanas disponibles — condición 6 — registrando la elección).
- Añadir un paso de CI **autoprueba de la compuerta de coincidencia parcial**: ejecuta un script de juguete (vive en `30_procesamiento/` o donde el diseño mande, fuera del flujo de datos) que provoca una coincidencia parcial bajo la misma configuración del pipeline y EXIGE fallo (exit ≠ 0); el paso pasa si el juguete falla y falla si el juguete pasa. Con esto la demostración positiva deja de existir solo en macOS: corre en cada despliegue.
- Verificación local: YAML parsea; diff acotado; el juguete falla localmente como corresponde. La verificación en runner llega con el push del cierre: run en verde, autoprueba visible en el log, y las páginas desplegadas ahora byte a byte idénticas al HTML local (la diferencia de 15 líneas de andamiaje debe caer a 0 si las versiones fijadas coinciden; si se fijaron versiones cercanas y no exactas, registra el diff residual).
- Commit: `feat(ci): versiones fijadas y autoprueba de la compuerta de coincidencia parcial`.

### T3a — Build desde clon limpio (reproducibilidad desde cero)

- `git clone` del repo real a `/tmp/slep_v6_clon` (condición 3: remote fuera), restauración de dependencias según FASE 0.7, `40_salidas/` del clon regenerada desde cero con su pipeline.
- Verificación: los 28 archivos versionados del clon byte a byte idénticos a los del repo real (sha256 contra la línea base). Cualquier diferencia se enumera archivo por archivo antes de cualquier juicio.
- Este resultado responde por primera vez con evidencia la pregunta 2 de la auditoría de apertura ("¿el pipeline corre de cero?") sobre un árbol que no arrastra estado local.

### T3b — Ensayo general de la vía A (en el clon, nunca en el real)

Sobre el MISMO clon ya construido, simular exactamente lo que el equipo de convivencia hará, con la compuerta de ronda 2:

1. **Publicación limpia:** en la copia de curaduría del clon, poner la pieza candidata de FASE 0.6 en `estado: validada`, `validado_por: "Ensayo General"`, `fecha_validacion` de hoy. Regenerar el clon. Verificar: la página de la pieza existe y renderiza; el índice de piezas la lista con su título; TODAS sus anclas de `fuentes` resuelven en el HTML generado; el buscador la indexa (presencia en el índice de Pagefind); el candado de conteo cuadra; el resto del sitio del clon queda byte a byte igual salvo los archivos esperables (enumerarlos).
2. **La compuerta de anclas trabaja de verdad:** repetir el flujo con `faq_revision_de_mochilas.md` (ancla rota conocida) → la regeneración del clon debe ABORTAR nombrando pieza, ancla y documento. Es el control positivo de D-e sobre datos reales.
3. **Flujo OCR:** en la copia de curaduría del clon, cerrar `ocr_revisado` de la circular 586 (1 página) con firma sintética, regenerar, y documentar qué cambia observablemente (badge, citabilidad, texto) contra el estado anterior. El propósito es conocer el efecto ANTES de pedirle al equipo la primera firma real, no validar contenido.
- Producto: `50_documentacion/andamios/20260827_ensayo_general_v1.md` con el guion ejecutado, la evidencia de cada verificación, capturas de los fragmentos de HTML relevantes, y una sección final "lo que el equipo verá" en lenguaje llano, utilizable como anexo de la pauta.
- Al terminar: borrar los clones y verificar el borrado.
- Commit (solo el informe): `docs(andamios): ensayo general de la via A en clon`.

### T5 — Coherencia documental con la compuerta final

- Pauta: alinear las instrucciones de firma con la regla real ("nombre y apellido"); nada más.
- README de piezas: si vive bajo `20_insumos/`, NO editar: imprimir el diff propuesto en el log y dejarlo como tarea manual del titular; si vive fuera, editarlo directo.
- Verificación: diffs acotados; toda instrucción de la pauta que la ronda 2 haya vuelto obsoleta queda corregida (barrido con lista explícita de reglas nuevas vs texto de la pauta).
- Commit: `docs(andamios): pauta alineada con la compuerta final`.

## 6. Exclusiones declaradas

- Publicar cualquier pieza real, cerrar cualquier estado real: el ensayo vive en el clon.
- Duda 3 de v4 (vocabulario), D-f/D-g/D-i, slug del DFL 1, módulo de reglamentos: traspaso v02 y gates.
- Cierre de sesión: `ESTADO.md` intacto.

## 7. Auto-auditoría, log y reporte

- T1 con panel; el resto con re-derivación por comandos distintos. El informe del ensayo se re-lee contra su propio guion antes del commit (¿cada paso tiene su evidencia?).
- Log en `50_documentacion/andamios/logs/20260827_ensayo_general_v6_log.md`, plantilla fija, con una sección propia: **"Las tres dudas residuales, antes y después"** — para cada una (camino de publicación, reproducibilidad, control positivo en runner): qué evidencia existía antes de este encargo, cuál existe ahora, y qué queda honestamente sin probar.
- Push al cierre; verificación en runner (run en verde, autoprueba visible, diff de andamiaje); segundo push solo-documentación para la adenda de CI.
- Reporte al chat: veredicto por duda residual, hashes, congeladas, ruta del log e informe del ensayo, y "lo que falló o sorprendió; si nada, decirlo explícitamente". **La sesión queda abierta.**
