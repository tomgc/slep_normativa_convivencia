# Análisis de la ejecución del encargo v3 — auditoría contra producto

Autor: asistente de análisis (chat), sesión 2. Objeto: `20260826_auditoria_y_cierre_v3_log.md`, su reporte al chat y, por referencia, `20260826_auditoria_contra_producto_v1.md`. Método: lectura completa del log y contraste con el encargo redactado, los dos logs anteriores y el traspaso v01. Este análisis no re-ejecuta comandos: evalúa coherencia interna, calibración de la evidencia y consecuencias; los bytes ya fueron auditados contra producto por TA y su panel, que era el propósito del encargo.

## 1. Veredicto global

La ejecución es conforme y el resultado central es el que se buscaba: **ninguna cifra, hash ni estado reportado durante la sesión resultó falso al re-derivarlo desde los artefactos**. Las seis tareas cerraron, los cinco chequeos de TC pasaron con calibración previa, el deployment quedó verificado en producción (HTTP 200, procedencia visible en la ficha del DFL 1, control negativo en una norma sin alternativos) y los invariantes 🔒 pasan con evidencia por comando en toda la cadena.

La única refutación de la sesión cayó sobre un enunciado del propio auditor ("0 accesos `$` residuales"), no sobre los productos auditados. Eso es exactamente lo que un sistema sano debe producir: la auditoría sobrevivió a su panel en lo aritmético y fue corregida en lo universal.

## 2. Análisis por tarea

**TA.** El punto metodológicamente más fuerte del encargo: la cifra 795, que venía de un verificador no versionado, se volvió reproducible probando ocho definiciones hasta aislar la que la genera, y la definición quedó escrita. Lo mismo con `relaciones.json` no publicado: en lugar de declarar el punto no verificable, se verificó por huella (blob del deployment == working tree) y por efecto (las remisiones legibles en el HTML publicado). Son dos ejemplos de auditoría que persigue el artefacto hasta donde el artefacto existe. La condición 3 (no corregir lo auditado) se respetó incluso cuando O5 estaba a tres líneas del código que TC editaba; el propio log reconoce que sin la condición escrita la tentación habría ganado. Esa condición debe volverse cláusula estándar de todo encargo con componente de auditoría.

**TB.** Correcta y mínima. El arnés no solo reprodujo el par `anio`↔`anios_alternativos`: encontró que la versión con `$` podía inventar un `ocr_revisado` desde claves prefijadas plantadas — es decir, el defecto en ese archivo podía **bloquear `--rehacer` creyendo revisado lo no revisado**. El caso plantado convierte un fix cosmético en la clausura de un riesgo real sobre la compuerta de OCR.

**TD.** 5 piezas / 7 líneas, instrumento calibrado en ambos sentidos aunque el resultado no fuera 0 (el control solo era obligatorio para el 0). Hallazgo lateral valioso: `glosario.md` usa una tercera forma de nombrar el documento ("circular 482"); la unificación pertenece a la validación humana y debe viajar como nota junto al listado.

**TE.** La decisión D2 (el tema es del documento; la columna localiza la aparición única que lo disparó, y la tabla lo declara) es la interpretación correcta y está honestamente rotulada. Sin la declaración, el revisor habría creído que validaba una asignación por artículo. La doble derivación (tabla ⚠ de la indagación vs re-derivación de `asignar_temas()`, conjuntos idénticos en ambas direcciones) deja la tabla en el mejor estado de evidencia posible para un insumo de validación.

**TF.** El BOM UTF-8 (D3) es la decisión práctica correcta para un circuito que termina en Excel en español, y se verificó que no ensucia la relectura en R. La pauta quedó tocada en una sola línea, como estaba autorizado.

**TC.** El chequeo (a) corrió antes de regenerar y falló, "que es la única forma de saber que después mide algo": esa frase del log es la síntesis de la disciplina de calibración de toda la sesión. Diff +50/−0 acotado al campo nuevo, `relaciones.json` byte a byte, y el efecto lateral sobre el dictamen 52/77 (que gana la misma procedencia visible) es coherente, no accidental: la plantilla se escribió por condición, no por caso.

**D1 (conversión parcial dentro de TC)** merece mención: convertir solo los 4 accesos del bloque que TC misma editaba, dejando los otros 82 sin tocar por ser materia de O5, es el trazado fino correcto de la frontera entre "no repetir un defecto a sabiendas en código que introduzco" y "no corregir lo que la auditoría registró". La alternativa (convertir todo de paso) habría contaminado la auditoría; la otra (no convertir nada) habría sembrado el defecto conocido en código nuevo.

## 3. El hallazgo mayor: O5, la compuerta de firma

`firmada()` decide con `p$validado_por` sobre front matter YAML crudo. Una pieza `estado: validada`, sin `validado_por`, con cualquier clave que lo tenga por prefijo, **se publica como firmada**. Tres cosas lo agravan y una lo contiene:

1. Es la compuerta que `CLAUDE.md` §10.5 declara invariante duro: el punto único donde el proyecto promete que nada interpretativo sale sin firma humana.
2. El front matter lo escriben personas (es capa de curaduría): el escenario "clave parecida pero no exacta" es precisamente el error humano esperable, no un caso rebuscado. La sesión ya vio nacer un par así de forma natural (`validado_por` / `validado_por_equipo` es análogo a `anio` / `anios_alternativos`).
3. **Su probabilidad de activarse pasa de teórica a real en el momento exacto en que empiece la vía A**: hoy 0 de 22 piezas la exponen porque nadie ha validado nada; la primera tanda de validaciones del equipo de convivencia es cuando aparecerán los primeros `estado: validada` escritos a mano.
4. Lo contiene: no está viva, y el descubrimiento llegó antes que la primera validación.

**Consecuencia de secuencia, que es la conclusión operativa de este análisis: los 17 accesos de clase A de `34_generar_paginas.R` deben convertirse ANTES de entregar la pauta al equipo de convivencia**, porque la pauta es el disparador de las primeras piezas validadas. La verificación debe incluir el arnés adversarial obvio: pieza plantada con `estado: validada` y clave prefijada → la compuerta debe rechazarla o abortar, según lo que §10.5 mande.

Los 86 accesos de clase B (curaduría derivada, con esquema que normaliza) son de riesgo distinto y menor; pueden viajar como pendiente del traspaso v02 con su clasificación ya hecha.

## 4. Patrones de tercera iteración (material para reglas aprendidas del cierre)

1. **Las cifras aguantan; los enunciados universales caen.** Tres encargos seguidos con el mismo patrón: el panel confirma todo lo aritmético y derriba afirmaciones de alcance ("toda lectura", "0 accesos", "0 residuales"). Regla candidata: todo enunciado universal en un log debe llegar acompañado del comando exhaustivo que lo sostiene, o degradarse a enunciado acotado ("0 en los archivos X, Y; Z no barrido").
2. **El control positivo es la única red que ha funcionado.** Siete defectos de instrumento en la sesión (cinco en v1, dos en v3) y ninguno se detectó leyendo código: todos los detectó un caso plantado. El costo de plantar casos es minutos; el costo de no plantarlos habría sido un hallazgo falso contra el sitio publicado y un veredicto de auditoría erróneo.
3. **La coincidencia parcial por prefijo es el defecto sistémico del proyecto**, con cuatro apariciones ya (`anio`/`anios_alternativos`, `fuente_anio`/`fuente_anios_alternativos`, `validado_por`/`validado_por_equipo` como vector de O5, `paginas`/`paginas_pdf`/`paginas_vacias` en el manifiesto). No es un bug puntual: es una propiedad del binomio "R con `$` + esquemas que crecen por sufijación". La erradicación completa de `$` sobre estructuras leídas de disco es la única política estable.
4. **La forma mínima destapa lo que el caso rico oculta** (v2) y **"salió con código 0" no es "se ejecutó"** (v3, `Rscript 00_run_all.R` que solo define la función). Ambas son variantes de la misma lección: la ausencia de error no es evidencia de ejecución; la evidencia es el cambio observable y contado.

## 5. Riesgos residuales, ordenados

1. **O5 / clase A** — alto y con fecha de activación (la vía A). Corregir antes de entregar la pauta.
2. **`Rscript 00_run_all.R` inerte** — medio: cualquier operador futuro (humano o encargo) puede creer que regeneró sin haberlo hecho. Arreglo de una línea (`if (!interactive()) run_all()`) más corrección de la fórmula en encargos.
3. **Clase B (86 accesos) y lecturas del manifiesto en `00_ocr_documentos.R` (O3)** — bajo hoy, misma clase de defecto; programable.
4. **Imprecisiones documentales** — bajas pero públicas ante el equipo: la pauta llama "escaneados" a los 5 documentos y uno no lo es (O1); el rastreo del glosario cita un "art. 46 letra f)" inexistente y un conteo 11 sin criterio (O4). Se corrigen antes de que esos documentos se usen como insumo de validación.
5. **Slug del DFL 1 (Duda 5)** — decisión humana pendiente, con peso creciente medido: 19 enlaces enrutan hoy a una URL que contradice el contenido, y la propia curaduría lo describe correctamente en su texto. El dato nuevo del panel (el error vive solo en slug/URL/PDF/clave, no en texto visible) acota el costo de la corrección: renombrar rompe URLs y nada más, lo que hace viable evaluar redirecciones como mitigación cuando el equipo decida. Sigue en el Bloque 4 de la pauta.

## 6. Decisiones que este análisis deja planteadas

1. Convertir los 17 accesos de clase A (incluida `firmada()`) en tarea propia inmediata, previa a la entrega de la pauta. Recomendación: sí, es la condición de seguridad de la vía A.
2. Guardia de ejecución en `00_run_all.R` y fórmula corregida en encargos futuros. Recomendación: sí, en la misma tarea.
3. O3 (manifiesto) y O4 + O1 (correcciones documentales). Recomendación: sí, en el mismo micro-encargo; son minutos y cierran el inventario de defectos conocidos en cero.
4. Clase B (86 accesos): Recomendación: pendiente del traspaso v02, con la clasificación del panel como insumo.
5. Después de ese micro-encargo: cierre de sesión con protocolo. La sesión ya produjo tres encargos, una auditoría y cinco documentos de andamiaje; el riesgo de degradación de contexto crece y todo lo restante es o humano (vía A, Duda 5, cruce) o de sesión nueva (módulo de reglamentos).
