# Guarda de locale UTF-8 — constancia de instalación

> Invariante de entorno de `POLITICA_PROYECTO.md` §5.2bis.
> Instalada el 2026-08-25 por el encargo
> `50_documentacion/andamios/20260825_encargo_bootstrap_v1.md` (T1).
> Este archivo es el que apaga el gatillo 4ter de
> `SETTINGS_Y_PROMPTS_OPERACIONALES.md` §1.2.2.

---

## 1. Qué se instaló

| Elemento | Valor |
|---|---|
| Guarda | `10_utils/10_locale.R` |
| Origen | `herramientas_dev/plantillas/10_locale.R`, copia idéntica |
| md5 de la plantilla | `dc900c1b0d2d252c9e5730875be5d632` |
| md5 de la copia en el proyecto | `dc900c1b0d2d252c9e5730875be5d632` |
| `diff` plantilla vs copia | sin salida (cero líneas editadas) |
| Punto de arranque | `10_utils/10_configuracion.R`, creado en el mismo encargo |
| Línea de carga | `10_utils/10_configuracion.R:18` — `source(here::here("10_utils", "10_locale.R"))` |
| Línea de invocación | `10_utils/10_configuracion.R:19` — `asegurar_locale_utf8("10_configuracion.R")` |
| Posición en el parseo | expresión ejecutable 2; la 1 es el `source()` que la carga |

La invocación es la primera línea ejecutable del arranque, precedida solo por el
`source()` que carga la guarda: exactamente lo que §5.2bis exige y lo que el
verificador comprueba en su V2 parseando el archivo.

**La guarda no se edita por proyecto.** Si este proyecto necesitara un
comportamiento distinto, el helper está mal diseñado y se corrige en
`herramientas_dev/plantillas/`, nunca aquí.

### Por qué importa particularmente en este proyecto

El corpus son 24 documentos de normativa chilena. Prácticamente cada artículo
contiene tildes y eñes ("Artículo", "educación", "niñas", "expulsión"). Un
proceso en locale C escribe ese texto escapado como `<c3><a1>` en el JSON y en
el HTML del sitio, sin emitir un solo error. El sitio quedaría publicado con el
articulado ilegible y nadie se enteraría hasta que alguien lo leyera.

---

## 2. Evidencia de la calibración

La guarda se da por instalada solo cuando se la vio fallar. Las tres corridas del
verificador `herramientas_dev/plantillas/90_verificar_locale.R`, en orden, el
2026-08-25:

### 2.1 Línea base (estado instalado)

```
[ OK ] V1 archivo             identico a la plantilla
[ OK ] V2 arranque            primera linea ejecutable (expresion 2)
[ OK ] V3 proceso             LANG=C corregida a es_ES.UTF-8
[ OK ] V4 hijos               el nieto hereda es_ES.UTF-8

GUARDA INSTALADA: las cuatro verificaciones pasan.
exit=0
```

### 2.2 Control positivo — qué se rompió y qué detectó el verificador

**Qué se rompió:** se comentó la línea 19, la invocación de
`asegurar_locale_utf8()`, dejando intacto el `source()` de la línea 18. Es la
rotura que la cabecera del verificador declara discriminante: deja V1 en pie y
tumba V2, V3 y V4.

**Qué dijo el verificador:**

```
[ OK ] V1 archivo             identico a la plantilla
[FALLO] V2 arranque            asegurar_locale_utf8() no se invoca
[FALLO] V3 proceso             arranco bajo LANG=C y quedo en C
[FALLO] V4 hijos               el nieto quedo en C: la guarda corrige pero no exporta

GUARDA NO INSTALADA: fallan V2, V3, V4.
exit=1
```

El instrumento no es ciego: dispara sobre el caso malo, nombra el defecto y sale
con código distinto de 0.

### 2.3 Control negativo — cómo se restauró y qué dijo al pasar

**Cómo se restauró:** se descomentó la línea 19 con la operación simétrica a la
rotura (`perl -i -pe` con el patrón inverso). No se usó `git checkout --` porque
el archivo todavía no estaba versionado en ese momento.

**Residuo cero, comprobado por md5:**

| Momento | md5 de `10_utils/10_configuracion.R` |
|---|---|
| Antes de romper | `3d17b03169822952c0bb91961538fc6a` |
| Roto | `399b8e7b579e17450f3fe62f7de61d54` |
| Tras restaurar | `3d17b03169822952c0bb91961538fc6a` |

`grep "ROTURA"` sobre el archivo restaurado devuelve 0 ocurrencias.

**Qué dijo el verificador al pasar:** salida idéntica a la de §2.1, `exit=0`.

---

## 3. Qué cubre esta guarda y qué no

Tres hechos medidos, transcritos de la cabecera de `10_locale.R`, que acotan lo
que esta instalación garantiza:

- **H1.** `writeLines()` no escapa: pasa los bytes UTF-8 del literal aunque el
  proceso corra en C. El escape a `<c3><a1>` ocurre en otras rutas de escritura
  (openxlsx, quarto). Un criterio de aceptación que busque escapes en la salida
  es ciego.
- **H2.** El efecto colateral medible es el **orden de colación**: en locale C se
  ordena por bytes; con UTF-8, alfabéticamente. Aquí eso decide el orden de los
  índices del sitio, así que un snapshot cuyo orden depende del shell que lo
  lance no es reproducible.
- **H4.** La guarda **no cubre la lectura**, y la lectura falla en silencio. En
  este proyecto la lectura la hace `pdftools::pdf_text()`, que devuelve UTF-8
  declarado por el propio PDF; la contramedida equivalente es el
  `stopifnot(nchar(texto) > 0)` y el conteo de páginas contra
  `pdftools::pdf_info()$pages` que aplica `31_extraer_texto.R`.

---

## 4. Qué hacer si esto se rompe

1. Correr el verificador:
   `Rscript ~/Projects/herramientas_dev/plantillas/90_verificar_locale.R . dc900c1b0d2d252c9e5730875be5d632`
2. Si falla **V1**, alguien editó `10_utils/10_locale.R`: recopiarla desde el kit,
   sin editar.
3. Si falla **V2**, alguien movió o comentó la invocación en
   `10_utils/10_configuracion.R`, o insertó código ejecutable antes de ella.
4. Si fallan **V3 o V4** con V1 y V2 en pie, el problema es del entorno: exportar
   `LANG=es_ES.UTF-8` en el shell y reiniciar R. En GitHub Actions eso ya viene
   fijado en `.github/workflows/publicar.yml` (POLITICA §5.2bis, corolario de CI).
