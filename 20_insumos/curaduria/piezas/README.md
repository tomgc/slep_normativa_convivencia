# Piezas interpretativas — cómo se validan

Aquí viven las **fichas resumen por norma**, las **preguntas frecuentes** y el
**glosario**. A diferencia del resto del sitio, esto **no es texto normativo**:
es una lectura del equipo de convivencia.

Por eso rige un invariante duro del proyecto:

> **Ninguna pieza se publica sin firma.** El generador del sitio muestra una
> pieza solo si declara `estado: validada` **y** trae `validado_por` con un
> nombre. Las dos condiciones, no una.

Y la compuerta **aborta el pipeline**, no filtra en silencio: una pieza marcada
como validada sin firma detiene la corrida con el nombre del archivo. Un error de
curaduría tiene que verse; saltárselo calladamente es cómo un borrador acaba
publicado.

---

## Estructura

```
20_insumos/curaduria/piezas/
├── README.md          este archivo
└── borradores/        piezas generadas por 00_generar_borradores.R
    ├── ficha_<slug>.md
    ├── faq_<caso>.md
    └── glosario.md
```

La carpeta no impone nada: el generador del sitio lee **todos** los `.md` bajo
`piezas/`, en cualquier subcarpeta. `borradores/` es una convención para saber de
un vistazo qué no se ha tocado todavía. Una pieza validada puede quedarse donde
está o **moverse** (no copiarse): el nombre del archivo es lo que da nombre a su
página, así que dos piezas con el mismo nombre de archivo en carpetas distintas
detienen el pipeline. Lo que decide si se publica es el front matter.

---

## Front matter obligatorio

```yaml
---
tipo: faq                  # ficha | faq | glosario
titulo: "¿Se puede revisar la mochila de un estudiante?"
estado: borrador           # borrador | validada
validado_por: null
fecha_validacion: null
fuentes:
  - {norma: ley_20536_violencia_escolar, articulo: art-16-d, ancla: "ley_20536_violencia_escolar.html#art-16-d"}
generado_por: 00_generar_borradores.R
generado_el: 2026-08-25
---
```

`fuentes` no es decorativo: es la lista de artículos que respaldan la pieza, y el
sitio la publica al pie. **Cada afirmación de una pieza debe poder anclarse a un
artículo.** Si una afirmación no tiene artículo que la respalde, no es una lectura
de la normativa: es una opinión, y no va aquí.

### Lo que el pipeline exige, y rechaza si falta

Al poner `estado: validada`, el pipeline comprueba cuatro cosas y **se detiene**
nombrando el archivo y el campo si alguna falla:

- **`validado_por` tiene que ser un nombre y un apellido.** Una sola palabra no
  vale, y `pendiente`, `s/i`, `x`, `N/A` o `null` entrecomillado tampoco. Mientras
  la pieza sea un borrador, déjalo en `null`.
- **`fecha_validacion` es obligatoria**, con formato `AAAA-MM-DD` entre comillas.
- **`fuentes` es obligatoria** y cada entrada necesita `norma`, `articulo` y
  `ancla`, los tres con contenido.
- **Cada `ancla` tiene que existir de verdad.** Se escribe
  `<norma>.html#<id del artículo>`, y `norma` y `articulo` de esa misma entrada
  tienen que decir lo mismo que el ancla. Si el artículo no existe, el pipeline se
  detiene y te dice qué pieza, qué ancla y en qué documento.

En un borrador nada de esto se exige: solo `tipo`, `estado` y `titulo`. Las anclas
que no resuelvan salen como aviso en el log, para que se corrijan antes de validar.

---

## Cómo validar una pieza

1. Abrir el `.md` en `borradores/`.
2. Completar los bloques marcados
   `<!-- PENDIENTE DE REDACCIÓN POR EL EQUIPO DE CONVIVENCIA -->`. Lo que ya está
   relleno son datos verificables y extractos literales: **no se reescriben**, se
   usan como respaldo.
3. Agregar a `fuentes` el artículo de toda afirmación nueva que se incorpore.
4. Cambiar el front matter:

   ```yaml
   estado: validada
   validado_por: "Nombre y rol de quien firma"
   fecha_validacion: "2026-09-01"
   ```

5. Correr `Rscript -e 'source("00_run_all.R"); run_all()'` y revisar la página.
6. Commitear.

Al validar la primera pieza, el sitio gana automáticamente la sección **Fichas y
FAQ** en la barra de navegación. Mientras no haya ninguna, esa entrada no existe:
un enlace a una sección vacía le promete al usuario contenido que no está.

## Cómo devolver una pieza a borrador

Poner `estado: borrador` y volver a correr el pipeline. La página desaparece del
sitio en la misma corrida: el paso de render vacía el directorio de salida antes
de escribir, así que no quedan páginas huérfanas publicadas.

---

## Qué NO hacer

- **No definir de memoria.** El glosario solo define lo que el corpus define, con
  cita al artículo. Los términos sin respaldo normativo están listados aparte,
  como "pendientes de fuente", y ahí deben quedarse hasta que se incorpore la
  norma que los define.
- **No parafrasear el extracto.** El texto citado es literal. Si hace falta
  explicarlo, se explica **al lado**, no encima.
- **No firmar una pieza que no se leyó completa.** `validado_por` es una
  responsabilidad institucional, no un campo de formulario.

---

## Regenerar los borradores

```bash
Rscript 00_generar_borradores.R
```

**Nunca sobreescribe un archivo existente.** Solo escribe los que faltan. Para
volver a generar uno desde cero hay que borrarlo a mano, y eso descarta el
trabajo de redacción que tuviera.
