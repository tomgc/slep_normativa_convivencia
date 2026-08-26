# Borradores que citan el REX 482 con el rótulo antiguo — v1

Proyecto `slep_normativa_convivencia`, sesión 2, 2026-08-26. Producto de la tarea TD del
encargo `50_documentacion/andamios/20260826_encargo_auditoria_y_cierre_v3.md`. Es el
insumo que la pauta de validación promete en su Bloque 3 («el Área de Monitoreo les
entregará la lista de cuáles borradores tienen ese problema»).

> **Solo lectura.** Este barrido no modificó ninguna pieza. Las piezas interpretativas son
> de escritura humana: la corrección la hace el equipo de convivencia al validarlas.

## 1. Qué problema es

La Resolución exenta N° 482, de 2018, de la Superintendencia de Educación, es **un solo
acto administrativo repartido en dos archivos PDF**: la resolución que aprueba, y el
cuerpo del reglamento que la resolución aprueba. El corpus los tiene como dos documentos
(`rex_482_instrucciones_reglamentos_internos` y `rex_482_reglamentos_b`) y desde
`c774ebc` el sitio los rotula distinto para que no se confundan:

| Documento | Rótulo actual |
|---|---|
| `rex_482_instrucciones_reglamentos_internos` | **Resolución exenta 482 (resolución)** |
| `rex_482_reglamentos_b` | **Resolución exenta 482 (cuerpo)** |

Los 22 borradores se sembraron **antes** de ese cambio, con `escribir_pieza()`, que no
sobreescribe piezas ya existentes. Alinear el generador (`bd7260c`) no los tocó: los que
mencionan el REX 482 lo siguen llamando `Resolución exenta 482` a secas.

## 2. Piezas afectadas

**5 de 22 piezas, 7 líneas, 7 menciones.** Las cinco citan `rex_482_reglamentos_b`, así
que en las siete el rótulo correcto es el mismo: **`Resolución exenta 482 (cuerpo)`**.
Ninguna pieza cita `rex_482_instrucciones_reglamentos_internos`.

| Pieza | Línea | Qué dice hoy | Qué debería decir |
|---|---:|---|---|
| `faq_celulares.md` | 43 | `### Resolución exenta 482` | `### Resolución exenta 482 (cuerpo)` |
| `faq_identidad_de_genero.md` | 105 | `### Resolución exenta 482` | `### Resolución exenta 482 (cuerpo)` |
| `faq_seguridad_y_deteccion.md` | 38 | `### Resolución exenta 482` | `### Resolución exenta 482 (cuerpo)` |
| `faq_uniforme.md` | 125 | `### Resolución exenta 482` | `### Resolución exenta 482 (cuerpo)` |
| `glosario.md` | 122 | `- **Definido en:** [Resolución exenta 482, Página 10](rex_482_reglamentos_b.html#ocr-pagina-010)` | `[Resolución exenta 482 (cuerpo), Página 10]`, mismo enlace |
| `glosario.md` | 242 | `- **Definido en:** [Resolución exenta 482, Página 12](rex_482_reglamentos_b.html#ocr-pagina-012)` | `[Resolución exenta 482 (cuerpo), Página 12]`, mismo enlace |
| `glosario.md` | 290 | `- **Definido en:** [Resolución exenta 482, Página 26](rex_482_reglamentos_b.html#ocr-pagina-026)` | `[Resolución exenta 482 (cuerpo), Página 26]`, mismo enlace |

Rutas completas desde la raíz: `20_insumos/curaduria/piezas/borradores/<pieza>`.

**Los enlaces no cambian.** Las siete menciones ya apuntan al archivo correcto
(`rex_482_reglamentos_b.html`) y a un ancla que existe; lo único desalineado es el texto
visible. Verificado: el barrido de enlaces internos de la auditoría de este mismo turno da
0 rotos.

## 3. Las 17 piezas restantes

No mencionan el REX 482 en ninguna forma, ni con el rótulo antiguo ni con el nuevo: no hay
nada que corregir en ellas por este motivo.

## 4. Observación adicional: `glosario.md` lo llama «circular 482»

En seis líneas más, `glosario.md` se refiere al mismo documento como **«circular 482»**
(líneas 301, 309, 310, 311, 312 y 315). No es el defecto de rótulo que esta tarea busca
—no aparece la fórmula `Resolución exenta 482`— pero es el mismo documento nombrado de una
tercera manera, y conviene unificarlo en la misma pasada de validación.

El nombre correcto es **Resolución exenta 482 (cuerpo)**: la Resolución N° 482 exenta *de*
2018 *aprueba* una circular sobre reglamentos internos; llamarla «circular 482» confunde el
acto con su contenido. Que el propio texto del documento se presente como circular explica
el desliz, y por eso se señala sin corregirlo aquí.

| Línea | Qué dice hoy |
|---:|---|
| 301 | «la sospecha razonable es que **la circular 482 define varios de ellos**» |
| 309 | fila de tabla: `cancelación de matrícula \| circular 482 (OCR pendiente); dictamen 71; dictamen 52/77` |
| 310 | fila de tabla: `medida formativa \| circular 482 (OCR pendiente)` |
| 311 | fila de tabla: `debido proceso escolar \| circular 482 (OCR pendiente); dictamen 52/77` |
| 312 | fila de tabla: `protocolo de actuación \| circular 482 (OCR pendiente)` |
| 315 | «Nota sobre el detector: la circular 482 **sí** contiene la fórmula…» |

## 5. Control del instrumento

El barrido busca `Resolución exenta 482` **no seguido** de ` (resolución)` ni de
` (cuerpo)`. Se calibró en los dos sentidos sobre tres piezas sintéticas escritas bajo
`/tmp/slep_v3_scratch/td_ctrl`, fuera del repositorio:

| Pieza de control | Contiene | ¿La marcó? | Correcto |
|---|---|---|---|
| `control_caso_malo.md` | `Resolución exenta 482` a secas | **sí** | sí |
| `control_caso_bueno_cuerpo.md` | `Resolución exenta 482 (cuerpo)` | no | sí |
| `control_caso_bueno_resolucion.md` | `Resolución exenta 482 (resolución)` | no | sí |

El instrumento dispara sobre el caso malo y calla sobre los dos buenos. El barrido real
dio 5 piezas afectadas, de modo que el control positivo que el encargo exigía solo para el
resultado 0 no era obligatorio; se hizo igual, porque un instrumento que solo se prueba
cuando falla no está probado.

Copias temporales borradas al cerrar; ningún archivo de `20_insumos/` se modificó
(`git status --porcelain -- 20_insumos/` vacío).
