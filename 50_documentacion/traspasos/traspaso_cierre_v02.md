# Traspaso de cierre v02 — slep_normativa_convivencia

Sesión 2, cerrada el 2026-08-27. `main` previo al cierre: `d301186` (fuente: reporte de Claude Code del último push, verificado en esta sesión con `git rev-parse` y run de CI por `head_sha`). Redactado contra `POLITICA_PROYECTO.md` (encabezado transcrito: "> **Versión 5.8 — vigente.**") y `SETTINGS_Y_PROMPTS_OPERACIONALES.md` (encabezado transcrito: "> **Versión 34.**"), ambos leídos de la knowledge base en esta sesión.

## 1. Entorno

Sin cambios respecto del traspaso v01 en la máquina local: macOS, R 4.5.2, Quarto 1.9.38, Positron, cuenta GitHub `tomgc`, sitio en GitHub Pages. Cambio nuevo en el runner: el workflow ahora FIJA R 4.5.2 y Quarto 1.9.38 (antes derivaba; llegó a correr R 4.6.1 / Quarto 1.10.18 sin que nada lo declarara) (fuente: log v6 y adenda, `50_documentacion/andamios/logs/20260827_ensayo_general_v6_log.md`).

## 2. El proyecto y su estado al cierre

Biblioteca pública de normativa de convivencia escolar: 25 normas, 682 artículos, sitio Quarto + Pagefind publicado y estable, HTTP 200 verificado en esta sesión. Cifras vivas al cierre, todas recontadas programáticamente en la sesión (fuente: logs v3 a v7 en `50_documentacion/andamios/logs/`): 552 relaciones (2 sustitución, 2 grupo_acto, 46 remisión, 502 tema), 67 descartes registrados, 795 enlaces internos con 0 rotos, manifiesto de incorporación 25/0/0, 22 piezas interpretativas todas en borrador y 0 publicadas, 34 asignaciones de tema frágiles, 84 páginas pendientes de revisión humana (75 OCR en 4 carpetas + 9 del dictamen 078 con capa de texto), 28 archivos versionados en `40_salidas/`.

La sesión 2 fue íntegramente de máquina (vía B) porque el equipo de convivencia no respondió: siete encargos autónomos (v1 a v7) que agotaron lo ejecutable sin firma humana, más una auditoría contra producto de toda la sesión y un ensayo general de la vía A en clon. El riesgo residual dominante sigue siendo el declarado desde la sesión 1: la capa más útil del sitio opera sin respaldo humano, y ahora todo el material de validación está listo para entregarse.

## 3. Verificación del cierre

Repositorio sincronizado (`HEAD` == `origin/main` == `d301186`), porcelain vacío, CI en verde con autoprueba de la compuerta de coincidencia parcial visible y en `success` en cada despliegue, sitio desplegado byte a byte igual al HTML local salvo una línea (el bundle del tema, ver pendiente 12) (fuente: reportes de Claude Code de los cierres v6 y v7, con runs verificados por `head_sha`). Las tres delegaciones de escritura en `20_insumos/` están registradas en §7 de los logs v2 y v7 con su alcance ejercido.

## 4. Trabajo de la sesión, por bloques

1. **Apertura y candado.** ESTADO.md adoptado (commit `70dc7da`) con traducciones al enum del estándar declaradas; hipótesis de apertura resueltas (backlog existe, guarda de locale instalada, OCR 75 páginas/4 carpetas contra 84/5 del traspaso, reconciliado después en bloque 4.4).
2. **Encargo v1 (avance de máquina).** Preclasificación de los 88 descartes (67 correctos, 21 homologables), rótulos distintivos del grupo REX 482, pre-revisión asistida del OCR (108 líneas sospechosas de 3.512, con controles positivos), rastreo de fuentes del glosario (3 de 5 resueltos contra Ley Chile). T3 congelada por contradicción interna del encargo (dominios autorizados vs verificación en github.com).
3. **Restitución del DFL 1.** Hallazgo: el filtro de año partía un mismo destino porque el DFL 1 MINEDUC se cita legítimamente "de 1996" (promulgación) y "de 1997" (publicación). Entrada `anios_alternativos: [1996]` escrita por delegación del titular (commit `90d58cf`), regeneración verificada con contador calibrado 21→0: 552 relaciones, 46 remisiones, 67 descartes.
4. **Defecto sistémico de coincidencia parcial.** `$` sobre listas de curaduría resolvía por prefijo (`anio`→`anios_alternativos` y tres pares más). La primera regeneración de la restitución fue atrapada por el chequeo calibrado (70 ≠ 67 esperados) y el arreglo `[[ ]]` se extendió a todo el pipeline en tres tandas (commits `48d176a`, `851f021`, `01fd28d`, `81179e3`). La nota `20260826_nota_cifra_ocr_v1.md` reconcilió además la cifra 84 = 75 OCR + 9 del dictamen 078 (ambas correctas: transcrito vs carga de revisión).
5. **Auditoría contra producto (encargo v3).** Toda cifra, hash y estado reportado en la sesión se re-derivó desde los artefactos: 7 de 8 puntos confirmados; el refutado fue un enunciado universal del propio auditor. Hallazgo mayor O5: la compuerta de firma decidía con `$` sobre YAML crudo.
6. **Compuerta de firma endurecida (encargos v5 y v6).** Ronda 1: cinco medidas, 17 de 25 veredictos de conducta cambiados, ninguna pieza real afectada. Ronda 2: `titulo`/`fecha_validacion`/`fuentes` obligatorios al validar, firma con nombre y apellido más lista negra, colisión de slug aborta, compuerta de anclas (aborta en publicable, avisa en borrador), robustez a NBSP/encoding. Todo con arnés antes/después sobre el árbol de parseo real y panel adversarial.
7. **Coincidencia parcial promovida a error del pipeline (v5) con autoprueba en CI (v6).** El patrón del aviso se deriva en runtime porque el mensaje de R está traducido y el runner mezcla idiomas (medido en producción); el paso de autoprueba provoca la coincidencia y exige el fallo en cada despliegue.
8. **Reclasificación de la clase B por univocidad (v5).** 91 accesos (v3 contaba líneas, no accesos): 0 muerden hoy, lista de vigilancia real de 9 contingentes; documento `20260826_reclasificacion_clase_b_v1.md` reemplaza a la clasificación v3.
9. **Ensayo general de la vía A en clon (v6).** Primera vez que una pieza recorre borrador→validada→página→índice; la compuerta de anclas abortó sobre la FAQ con ancla rancia real; el flujo `ocr_revisado` se simuló con la circular 586. Hallazgo E-c (pieza publicada fuera del buscador), corregido en v7: piezas indexadas con cuerpo y facetas (25+1 verificado en clon), Fuentes y firma fuera del índice. Build desde clon limpio: 27/28 byte a byte más 1 explicado (campo `estado` del manifiesto, por construcción).
10. **Material de validación listo.** Pauta en lenguaje llano (`20260826_pauta_validacion_convivencia_v1.md`, con URL y cifras verificadas), tabla de 34 temas frágiles con enlaces y columnas de firma, listado de 5 borradores con rótulo antiguo, pre-revisión OCR, guion "lo que el equipo verá" del ensayo, formato de cruce referencia↔instrumentos y su CSV prellenado con las 25 normas. README de piezas actualizado por tres delegaciones registradas.

## 5. Backlog

Vive en `50_documentacion/activa/backlog_acumulativo.md`; este cierre anexa el tramo 18→32 (sesión 2). El backlog es la única fuente de verdad del conteo histórico.

## 6. Bugs de la sesión y reglas aprendidas

**Bugs encontrados y cerrados en la sesión** (todos con causa raíz, archivo y commit en los logs): coincidencia parcial de `$` en cuatro pares (pipeline completo convertido a `[[ ]]`); compuerta de firma derrotable por tipos YAML no-carácter, secuestro de `archivo`/`cuerpo`, colisión de slug y anclas inexistentes (dos rondas de endurecimiento); `Rscript 00_run_all.R` inerte (definía sin invocar; guardia `sys.nframe() == 0L && !interactive()` más guarda de `commandArgs`); pieza publicada invisible al buscador (E-c); democión accidental del `stop()` de firma detrás de reparos nuevos (atrapada por el panel contra el propio comentario del código). **Bugs abiertos: ninguno.**

**Reglas aprendidas (se suman a las 5 de v01, que siguen vigentes):**
1. Acceso `[[ ]]` exacto para TODA estructura leída de disco; `$` está prohibido sobre ellas (cuatro pares de prefijos medidos; la opción global más la autoprueba de CI lo vigilan en runtime).
2. Un enunciado universal ("0 accesos", "toda lectura") solo se emite con el comando exhaustivo que lo sostiene; si no, se acota. Tres paneles consecutivos derribaron universales y confirmaron toda la aritmética.
3. Ningún cero se reporta sin control positivo calibrado en el mismo turno: los 7 defectos de instrumento de la sesión los cazó un caso plantado y ninguno la lectura del código.
4. "Salió con código 0" no es "se ejecutó": la evidencia es el cambio observable y contado (mtimes, líneas de log, conteos).
5. La forma mínima de una entrada destapa defectos que el caso rico oculta (el `anios_alternativos` sin `anio` exacto destapó la coincidencia parcial).
6. Ningún patrón dependiente de locale se escribe a mano: se deriva en runtime provocando el caso (el runner demostró hablar dos idiomas a la vez).
7. Autorizaciones y verificaciones de un encargo se cruzan par a par antes de emitirlo (dos congelamientos por contradicción interna del encargo, ambos evitables).
8. La auditoría no corrige lo que audita: hallazgo y corrección viven en tareas distintas.
9. El ensayo general en clon sin remote encuentra lo que ningún arnés puede (E-c apareció solo al ejecutar el flujo completo).

## 7. Decisiones del titular registradas en gates

Tres delegaciones de escritura en `20_insumos/` (entrada de curaduría del DFL 1; README de piezas dos veces), todas con alcance de un archivo y un cambio, registradas en §7 de los logs correspondientes. Decisión de diseño E-c (el material de apoyo publicado debe ser encontrable). Directiva permanente nueva: las tareas manuales delegables no se piden al titular; se ejecutan por delegación registrada.

## 8. Estructura del repositorio

Rama A canónica, sin desviaciones. Novedades de la sesión bajo `50_documentacion/andamios/` (encargos v1-v7, auditoría, reclasificación, ensayo, pauta, formato de cruce, CSV, tabla de temas frágiles, listados, nota OCR) y `50_documentacion/andamios/logs/` (logs v1-v7 con adendas). Escáner regenerado en este cierre y referenciado por el paquete.

## 9. Documentación técnica

No aplica en esta sesión: no se emitió `documentacion_tecnica_vN.md` nuevo; la documentación de lo hecho vive en los logs de encargo, que son la memoria institucional de la sesión.

## 10. Estado de las vías

Vía A: lista para arrancar y ahora es el único camino con trabajo pendiente; el ensayo general la recorrió completa en clon y la compuerta de ronda 2 es la que el equipo enfrentará. Vía B: agotada; no existe encargo autónomo viable con el gate humano cerrado.

## 11. Inventario de pendientes y ruta propuesta

**Inmediatos del titular:**
1. **Entregar la pauta al equipo de convivencia** con sus anexos (tabla de 34 temas frágiles, listado de borradores con rótulo antiguo, pre-revisión OCR, guion del ensayo). Criterio de éxito: acuse de recibo y fecha comprometida de primera tanda. Prioridad: alta; es el riesgo residual declarado desde la sesión 1.
2. **Entregar el CSV del cruce referencia↔instrumentos** para llenado del equipo. Criterio: CSV devuelto con filas de prioridad alta completas. Prioridad: alta; funda el módulo de reglamentos.

**Gates del equipo de convivencia (vía A):**
3. Revisión OCR de 84 páginas en 5 documentos (Bloque 1). Criterio: primer documento con "Revisado completo" firmado y `ocr_revisado` cerrado por el Área.
4. Validación de 34 temas frágiles (Bloque 2). Criterio: tabla firmada.
5. Validación de 3-5 piezas (Bloque 3). Criterio: primera pieza publicada con CI verde. Operativo E-d: al validar las 2 FAQ con anclas rancias, el Área corrige el destino técnico del ancla al registrar (la compuerta impide publicarlas antes).
6. Decisión del slug del DFL 1, opciones A/B/C (Bloque 4; 19 enlaces enrutan hoy a esa URL). Criterio: opción firmada; si implica renombrar, planificar redirecciones aparte (anclas públicas 🔒).
7. Al validar: corregir rótulos antiguos del REX 482 en los 5 borradores listados y unificar la denominación "circular 482" del glosario.
8. Glosario: 2 términos sin fuente normativa hallada (búsqueda documentada en `20260826_fuentes_glosario_v1.md`).

**Compuerta de dudas (5 registradas, filtro de tres campos):**
9. `supuesto:` el manejador de coincidencia parcial promueve a error también en Linux ante una coincidencia REAL dentro de un paso (la autoprueba corre en paso separado). `predicado:` un acceso `$` parcial plantado dentro de `ejecutar_paso()` deja el job del runner en rojo. `medicion:` rama de prueba desechable con el acceso plantado en un paso, push, `gh run view` esperando failure, y borrado de la rama.
10. `supuesto:` el build desde clon limpio reproduce también en una máquina sin la biblioteca R local (el clon de T3a resolvió dependencias con el mecanismo local). `predicado:` `renv::restore()` (o el mecanismo declarado) más pipeline en un entorno limpio da 27/28 + 1 explicado. `medicion:` clon y corrida en la otra estación de la cartera al abrirla.
11. `supuesto:` los 9 accesos de la lista de vigilancia clase B siguen protegidos mientras el esquema no gane hermanas nuevas. `predicado:` ninguna clave nueva del esquema derivado extiende por prefijo a ninguna de las 9. `medicion:` re-correr el clasificador de univocidad (`20260826_reclasificacion_clase_b_v1.md` documenta el método) tras cualquier cambio de esquema.
12. `supuesto:` el no-determinismo del bundle del tema (Bootstrap compilado distinto entre plataformas con la misma versión, mismo tamaño, sha distinto) y de `pagefind-entry.json` es inocuo para el lector. `predicado:` dos corridas consecutivas difieren solo en esos artefactos y el buscador y los estilos funcionan igual en el sitio desplegado. `medicion:` doble corrida más diff acotado más inspección de las 2 páginas muestreadas del despliegue.
13. `supuesto:` el campo `estado` del manifiesto OCR versionado puede seguir versionado sin romper el criterio de reproducibilidad desde cero. `predicado:` existe una decisión declarada (excluirlo del versionado, o aceptarlo con nota) y el build desde clon la respeta. `medicion:` decisión en sesión propia más re-corrida del build limpio con 28/28 o con la exclusión declarada.

**Registrables sin acción inmediata:** vocabulario `tema`/`temas` y `cita`/`cita_literal` en `relaciones.json` (zona frágil, cubierta en runtime por la compuerta); 3 `suppressWarnings` sobre `as.integer` ciegos al manejador y prefijos con 2+ hermanas que devuelven `NULL` silencioso (mapa en la reclasificación); 4 líneas de la clase B de v3 no reconstruibles (registradas sin racionalizar); deuda v01 que sigue: dictamen_065 con 4 segmentos, gatillo de ordenación §4.7 declarado y nunca priorizado.

**Fases futuras:** módulo de análisis de reglamentos de establecimientos (sesión propia de alcance; prerrequisitos: vía A avanzada, en particular el OCR del grupo REX 482, y cruce completado; todo informe del módulo nace interpretativo con gate `validado_por`); fases 3 (búsqueda semántica) y 4 (evidencia científica), diferidas; entregable de Claude Design, aún sin llegar.

**Auditoría de cierre (política 5.6, preguntas de cierre):** datos crudos aislados e inmutables: sí, `20_insumos/` sin un solo cambio fuera de las tres delegaciones registradas (fuente: invariantes de los logs v5-v7). Pipeline corre de cero: sí, probado por primera vez desde clon limpio (27/28 + 1 explicado). Declaraciones al inicio: sí, `10_configuracion.R` incorpora además las opciones de coincidencia parcial junto a la guarda de locale. Estructura conforme: sí, Rama A. Nombres canónicos: sí. Guarda `asegurar_locale_utf8()`: instalada y verificada en 2 archivos, vista operar en cada corrida (fuente: FASE 0 de los encargos). La sesión no deja deuda sin documentar: los pendientes de arriba son el inventario completo.

## 12. Instrucciones específicas para la próxima sesión

- ⚠️ NO publicar ninguna pieza sin `validado_por` (nombre y apellido) y fecha; la compuerta ahora ABORTA ante todo front matter inválido y ante anclas inexistentes: un aborto del pipeline en la vía A es información, no emergencia.
- ⚠️ NO escribir en `20_insumos/` desde ningún encargo salvo delegación explícita del titular registrada en §7 del log, con alcance de archivo y cambio enumerados.
- ⚠️ NO editar a mano `40_salidas/` (se regenera) y NO correr `00_ocr_documentos.R --rehacer` sin leer el aborto de la compuerta.
- ✅ ANTES de emitir un encargo: cruzar autorizaciones contra verificaciones par a par, declarar R-only en prompts de subagentes, y usar la invocación `Rscript 00_run_all.R` (ya ejecuta gracias a la guardia; `--from N` también).
- ✅ ANTES de reportar cualquier cifra o cero: recuento programático del turno y control positivo calibrado.
- ✅ Si la vía A arranca: el guion del ensayo (`20260827_ensayo_general_v1.md`) es el mapa de lo que va a pasar, incluido qué ve el equipo.
- 🔒 Cita textual, trazabilidad por badge (ahora incluye la procedencia de `anios_alternativos` en la ficha), solo derecho chileno, anclas públicas estables, reproducibilidad de `40_salidas/`, firma humana como invariante.

## 13. Errores del asistente de la sesión (tabla 2.2.15)

| # | Error | Regla o principio | Corrección aplicada |
|---|---|---|---|
| 1 | Encargo v1: lista de dominios autorizados contradecía la verificación exigida por T3 (tarea congelada) | Coherencia interna del encargo | Regla aprendida 7; v2+ autorizó el dominio |
| 2 | Encargo v1: prompts de subagentes sin declarar R-only; un subagente usó python3 | CLAUDE.md §7 | Declaración obligatoria desde v2 |
| 3 | Encargo v2: "push único" vs verificación de CI posterior al push (hubo dos push) | Coherencia interna del encargo | v3+ autoriza de antemano el segundo push documental |
| 4 | Encargo v5: "los seis valores no-carácter" cuando uno era carácter entrecomillado | Precisión de enumeración | Residuo declarado por el ejecutor; lista negra en ronda 2 |
| 5 | Encargo v5: taxonomía cerrada de 3 categorías sobre un universo no medido (faltó la (0), 75 de 91 casos) | No enumerar sin medir el universo | Categoría declarada por el ejecutor; registrada aquí |
| 6 | Encargos v2-v5: prescribieron `Rscript 00_run_all.R` sin verificar su efecto (fórmula inerte) | "Exit 0 no es ejecución" (regla 4) | Guardia commiteada; fórmula ahora correcta |
| 7 | Encargo v6: idioma sugerido `if (!interactive())` habría duplicado cada despliegue del CI | Medir antes de prescribir | El ejecutor midió antes de escribir y lo evitó; se registra el default dañino |
| 8 | Pauta v1: llamó "escaneados" a 5 documentos siendo 4 (O1) | Precisión ante el destinatario | Corregida en T4 de v4 |

friccion: tareas manuales delegables pedidas al titular → directiva permanente: se ejecutan por delegación registrada en gate.

## 14. Bloque de reapertura

Mensaje para abrir la sesión 3 (el eco del cierre añade debajo los hashes y el estado del push):

▎ Sesión CONTINUATION de slep_normativa_convivencia. El protocolo (POLITICA_PROYECTO.md y SETTINGS_Y_PROMPTS_OPERACIONALES.md) vive en la knowledge base. Adjunto: traspaso_cierre_v02.md y salida del escáner.
▎ Estado: sitio publicado y estable; 25 normas, 682 artículos, 552 relaciones, 67 descartes; 22 piezas en borrador, 0 publicadas; compuerta de firma endurecida en dos rondas y ensayada de punta a punta en clon; CI con versiones fijadas (R 4.5.2 / Quarto 1.9.38) y autoprueba de la compuerta de coincidencia parcial en cada despliegue; cero pendientes de máquina.
▎ La sesión 2 fue íntegramente vía B (7 encargos autónomos, auditoría contra producto de toda la sesión, ensayo general de la vía A en clon) y dejó listo todo el material de validación: pauta en lenguaje llano con 4 bloques (OCR, 34 temas frágiles, piezas, decisión del slug del DFL 1), tabla de temas frágiles, listados y el CSV del cruce referencia↔instrumentos para el módulo de reglamentos.
▎ Foco propuesto: (1) si la pauta ya se entregó, estado de la recepción y primera tanda de la vía A (procesar hallazgos del equipo: cerrar el primer ocr_revisado, publicar las primeras piezas, resolver la Duda del slug); (2) si no, la entrega es lo primero; (3) sesión de alcance del módulo de reglamentos cuando el cruce vuelva completo. La compuerta de dudas del traspaso trae 5 verificaciones medibles pendientes (pendientes 9-13), ninguna bloqueante.
▎ En ninguna vía se cierran estados ocr_revisado, se aprueban temas ni se publican piezas sin firma humana; toda escritura en 20_insumos/ exige delegación registrada.
