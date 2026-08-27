# Diff propuesto para `20_insumos/curaduria/piezas/README.md` (tarea manual del titular)

> Producto de T5 del encargo `20260827_encargo_ensayo_general_v6.md`.
> **Este archivo no se edita desde aquí**: vive bajo `20_insumos/`, que en el repo
> real es de solo lectura sin excepción en este encargo (autorizaciones, §1). Lo
> que sigue es el cambio propuesto, para que lo aplique una persona.

## Por qué

La compuerta de ronda 2 (`fix(sitio): compuerta ronda 2`) endureció cuatro cosas que
el README todavía describe con la regla vieja. Un README que promete algo que el
pipeline rechaza es peor que un README desactualizado: manda al equipo a hacer algo
que va a fallar.

| Regla nueva | Lo que dice hoy el README | Estado |
|---|---|---|
| `validado_por` exige **nombre y apellido** (dos palabras alfabéticas de 2+ letras) y rechaza `pendiente`, `s/i`, `x`, `null` entrecomillado | «`validado_por: "Nombre y rol de quien firma"` » | el ejemplo **sí pasa** (dos palabras), pero la regla no está declarada |
| `fecha_validacion` es **obligatoria** si `estado: validada`, y con formato `AAAA-MM-DD` | aparece en el ejemplo, sin decir que es obligatoria ni con qué formato | falta |
| `fuentes` es **obligatoria** si `estado: validada`, y cada entrada necesita `norma`, `articulo` y `ancla` **no vacíos** | «`fuentes` no es decorativo» (lo dice bien en prosa) | falta la exigencia formal |
| **Toda ancla debe existir**: `<norma>.html#<id>`, con `norma` y `articulo` coincidiendo con el ancla. Si no, el pipeline **aborta** | no se menciona | falta |
| Dos piezas con el mismo nombre de archivo **abortan** el pipeline | «Una pieza validada puede quedarse donde está o moverse» — invita justo al caso que ahora aborta si se **copia** en vez de mover | **contradice** |

## Cambio propuesto

En la sección «Front matter obligatorio», después del bloque de ejemplo, añadir:

```markdown
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
```

Y en la sección «Estructura», cambiar la frase que invita a mover piezas:

```diff
-Una pieza validada puede quedarse donde está o moverse; lo que decide es el front matter.
+Una pieza validada puede quedarse donde está o **moverse** (no copiarse): el nombre
+del archivo es lo que da nombre a su página, así que dos piezas con el mismo nombre
+de archivo en carpetas distintas detienen el pipeline. Lo que decide si se publica
+es el front matter.
```

## Nota aparte, no es del README

Dos de las 22 piezas sembradas (`faq_revision_de_mochilas.md`,
`faq_seguridad_y_deteccion.md`) **abortarán el pipeline el día que se validen tal
cual**: apuntan a `dictamen_078_detectores_revision_mochilas.html#materia` y
`#concordancias`, que ya no existen porque ese documento pasó a transcripción por
páginas (`ocr-pagina-001`…`009`). `00_generar_borradores.R` no puede repararlas
porque nunca sobreescribe un archivo existente: hay que editarlas a mano. El
pipeline ya lo avisa en cada corrida con un `WARN` que las nombra.
