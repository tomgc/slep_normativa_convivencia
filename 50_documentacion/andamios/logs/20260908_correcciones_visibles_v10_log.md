# Log de ejecución — encargo v10 (correcciones visibles)

> **Encargo:** `50_documentacion/andamios/20260908_encargo_correcciones_visibles_v1.md`
> **Medición:** `50_documentacion/andamios/20260908_medicion_correcciones_v1.md`
> **Escrito durante la ejecución**, no después. Estructura fijada por §9 del encargo.
> **Sesión:** 2026-09-08, sesión 3. Máquina: MacBook-Pro-de-Tomas.

---

## 1. Precondiciones, salida literal (§2)

```
$ git fetch --quiet && git status --porcelain && git rev-parse HEAD origin/main
?? 50_documentacion/andamios/20260908_encargo_correcciones_visibles_v1.md
?? 50_documentacion/andamios/20260908_encargo_revision_externa_motor_v1.md
?? 50_documentacion/andamios/20260908_especificacion_motor_busqueda_v1.md
?? 50_documentacion/andamios/20260908_juicio_encargo_v9_v1.md
?? 50_documentacion/andamios/lab_motor_v9/
bf9bd90687bfacdc2adf6c3308eebf1d84800b4c
bf9bd90687bfacdc2adf6c3308eebf1d84800b4c

$ grep -E '^(sesion_abierta|maquina):' 50_documentacion/activa/ESTADO.md
sesion_abierta: true
maquina: MacBook-Pro-de-Tomas

$ git config core.hooksPath
/Users/tomgc/Projects/herramientas_dev/githooks

$ ls 50_documentacion/andamios/lab_motor_v9/a2_*
(22 archivos; entre ellos a2_consultas_evaluacion.csv, 10 filas C01-C10)
```

**P1** cumple: HEAD y `origin/main` coinciden y no hay archivos versionados modificados. Las
cinco entradas `??` son residuo del v9 y de la emisión de este encargo; no se adoptan porque
no están en la tabla de §3.
**P2** cumple. **P3** cumple: el hook es `pre-push`, único del directorio, solo lectura,
reglas R1 (extensiones de datos), R2 (credenciales), R3 (RUT), R4 (kit desde Windows). Leído
íntegro antes del primer commit. Consecuencia anotada: **R1 alcanza a
`40_salidas/datos/normas/*.json`**, que se modifican en B3.
**P4 cumple, y era la bloqueante: el conjunto de evaluación existe.** No hubo que
reconstruirlo desde `20260904_alcance_capa2_semantica_v1.md`.

---

## 2. Mediciones previas, con sus controles positivos (§5)

Todas en `20260908_medicion_correcciones_v1.md`, con instrumentos transcritos en su anexo A.
Resumen y controles:

| § | Medición | Valor | Control positivo |
|---|---|---|---|
| 5.1 | Línea base del buscador | **1 de 10** (ancla esperada) / **2 de 10** (aceptadas) | comparador: 7 de 7 detecta; negativo: 0 de 10 sin falsos positivos |
| 5.2 | Anclas | 806 segmentos, 806 en el HTML, 0 faltan; 273 enlaces internos, 205 destinos distintos, 0 rotos | ancla rota plantada en copia en memoria: detectada, 1 de 1 |
| 5.3 | Peso | 3 048 234 B en 47 páginas; mayor `dfl_1` con 305 372 B y 220 encabezados con `id` | — |
| 5.4 | Índice lateral | **1 entrada** en las 5 mayores; máx 16 en el sitio | — |
| 5.5 | Alcance del buscador | **47 de 47** | — |
| 5.6 | Contaminación | **17 normas de 25**, exactas: 15 en `preambulo`, 2 en `documento`; **0 en el articulado** | cabecera plantada detectada, texto limpio no detectado |

### 2.1 Desviación de la línea base heredada, declarada antes de tocar código (§5.1)

§5.1 obliga a decirlo si la línea base no da 0, y no da 0.

- **La cifra es 1 de 10, no 0 de 10.** La lectura `B_ui_documento` del v9 modeló la interfaz
  como «los primeros en orden de documento». El bundle real
  (`40_salidas/sitio/pagefind/pagefind-ui.js` v1.5.2) **selecciona los 3 sub-resultados con
  más `locations` y solo después los presenta en orden de documento**. Con esa selección,
  C06 alcanza a mostrarse (2 de 10 si se aceptan las anclas alternativas: C06 y C10).
- **La premisa de §0 del encargo no se sostiene.** «La causa no es el índice, que sí las
  encuentra» es falso para 7 de las 10: el índice no devuelve la página correcta, y en 3
  (C02, C08, C09) no devuelve ninguna página. Pagefind exige todos los términos y las
  consultas están en el lenguaje del equipo, no en el de la norma («celular» frente a
  «dispositivos móviles»; «bullying» frente a «acoso escolar»).
- **Techo de B1: 3 de 10.** Solo 3 consultas tienen su ancla dentro del material que la
  interfaz recibe. Corregir la presentación no puede pasar de ahí, y la recuperación léxica
  queda fuera del alcance de B1 por su propia regla de detención.

Se declara y se continúa: §8 del encargo no lista esta desviación entre las causas de
detención, y las tres acciones de B1 siguen siendo correctas dentro de su techo.

### 2.2 Control de idempotencia previo (no pedido; hecho para poder comparar)

`run_all()` completo sin ninguna modificación, 7 pasos, 14,8 s: los **47 HTML idénticos byte
a byte** y los **28 JSON versionados idénticos** (`md5 -r`). Único artefacto que cambia:
`40_salidas/sitio/pagefind/pagefind-entry.json`, cuyo hash de idioma (`es_1ff273c38d` →
`es_24ccef5df1`) Pagefind rehace en cada build; no está versionado. La línea base es
comparable con lo que venga después.

---

## 3. Bloques

### 3.1 B1 — Sub-resultados del buscador

**Qué se cambió.** `30_procesamiento/34_plantillas_sitio/busqueda.html`, y nada más. Se
reemplazó `PagefindUI` por una interfaz propia sobre la API pública de Pagefind, dentro del
mismo archivo (incluidos sus estilos, en un `<style>` local, para no salir de la
autorización de B1).

**Por qué el reemplazo y no un ajuste.** Las tres cosas que B1 pide son: ordenar por
relevancia, subir el tope y mostrar el identificador de artículo. La primera y la tercera se
podían hacer con `process_result`. La segunda no: el tope de 3 está escrito en el **cuerpo**
de la función de recorte del bundle (`slice(0,3)`), no en un parámetro, de modo que ningún
ajuste desde fuera lo sube. Verificado leyendo `40_salidas/sitio/pagefind/pagefind-ui.js`
v1.5.2 y citado literal en la medición §1.1.

**Los tres cambios, uno por uno.**

1. **Orden por relevancia.** `ordenarSubResultados()` ordena por la suma de `balanced_score`
   de las apariciones, desempata por la mejor aparición y, en último término, por el orden
   de documento (para que dos artículos equivalentes salgan estables entre corridas).
   `balanced_score` corrige por el largo del fragmento: sin esa corrección, un artículo de
   tres mil caracteres que menciona el término cuatro veces le gana siempre al de doscientos
   que lo define.
2. **Tope: 5.** Justificado en la medición §1.5. Con el orden nuevo, el tope 2 ya alcanza 12
   de 13 casos y la curva es plana hasta el 8: **subir el tope no compra cobertura, el orden
   sí**. Se eligió 5 y no 2 como decisión de **margen** declarada, no como óptimo medido: 2
   es el mínimo justo sobre una muestra de 13 casos, y fijar el corte en el mínimo justo de
   una muestra pequeña es sobreajustarla.
3. **Identificador de artículo.** Cada sub-resultado muestra su ancla (`#art-3`,
   `#ocr-pagina-008`) junto al título, monoespaciada, para que se vea a dónde lleva el enlace
   antes de abrirlo.

**Cómo se midió, y por qué es comparable.** El instrumento (`consulta_ui2.mjs`, anexo de la
medición) **extrae del propio `busqueda.html` el bloque delimitado por
`// == INICIO BLOQUE DE ORDEN ==` y lo evalúa**. La cifra «después» se mide con el código que
se publica, no con una transcripción suya. Control de que el instrumento no cambió de vara:
en su modo de réplica reproduce la línea base exacta (1 de 10 estricto, 2 de 10 aceptado).

**Resultado, consulta por consulta** (ancla esperada visible en la interfaz; entre paréntesis
la posición en que aparece entre los mostrados):

| id | consulta | antes | después |
|---|---|---|---|
| C01 | pueden revisar la mochila de un alumno | no | no |
| C02 | se puede usar el celular en la sala de clases | no | no |
| C03 | es obligatorio tener un encargado de convivencia en el colegio | no | no |
| C04 | qué es el bullying | no | no |
| C05 | una alumna embarazada puede seguir yendo al colegio | no | **sí (pos. 2)** |
| C06 | cuántos días tiene el apoderado para apelar una expulsión | sí (pos. 1) | sí (pos. 2) |
| C07 | quiénes tienen que estar en el consejo escolar | no | no |
| C08 | el colegio puede obligar a los alumnos a usar uniforme | no | no |
| C09 | un alumno trans pide que lo llamen por su nombre social | no | no |
| C10 | se puede suspender al alumno mientras dura el proceso de expulsión | no | **sí (pos. 3)** |

**1 de 10 → 3 de 10** con el ancla esperada; 2 de 10 → 3 de 10 aceptando las alternativas.
**Es el techo declarado en §2.1**: las 7 restantes no tienen su ancla en el material que la
interfaz recibe, y eso es recuperación, no presentación.

Segunda batería (término canónico), donde el índice sí recupera las 10: la visibilidad se
mantiene en 9 de 10, y lo que mejora es **dónde** queda el artículo correcto: posición
mediana **2 → 1**, y aparece en primer lugar en **5 de 10** frente a 4 de 10. C03 y C04 bajan
de la posición 1 a la 2; ninguna deja de verse.

**Verificación en navegador real** (Chrome 152, headless, sitio servido en local; banco de
pruebas fuera del repositorio):

- En la raíz, `revisión de mochilas`: «2 normas con resultados», el dictamen 065 con sus
  cuatro sub-resultados y `#fuentes` —el ancla esperada de C01— **en primer lugar**; el
  dictamen 078 con **cinco** sub-resultados, que es el tope nuevo funcionando.
- Servido bajo `/slep_normativa_convivencia/`, como en Pages: el motor carga, busca y
  responde («Sin resultados para…» en la consulta que no tiene ninguno). El render completo
  bajo subdirectorio no se pudo capturar en headless por la interacción entre el reloj
  virtual de Chrome y la latencia de red; las URL se verificaron en su lugar con el
  instrumento contra ese mismo servidor: `http://127.0.0.1:8770/slep_normativa_convivencia/dto_215_uniforme_escolar.html#art-3`.
  Resuelven contra `baseUrl`, igual que antes. Queda declarado como verificación parcial.

**Prueba de regresión de anclas tras esta regeneración:** 806 segmentos declarados, **806
presentes en el HTML, 0 faltan**; 273 enlaces internos y 205 destinos distintos, **0 rotos**.
Control positivo del verificador: detecta el ancla rota plantada, 1 de 1.

