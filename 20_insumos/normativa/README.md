# `20_insumos/normativa/` — corpus normativo

🔒 **Read-only.** Estos PDF son la fuente legal de verdad del proyecto. El
pipeline solo los lee; nunca se editan, se regeneran ni se recomprimen.

Todos provienen de fuentes oficiales: Biblioteca del Congreso Nacional (leyes,
DFL y decretos supremos), Ministerio de Educación y Superintendencia de
Educación (circulares, resoluciones exentas y dictámenes).

---

## Excepción declarada a `POLITICA_PROYECTO.md` §1.2.4

La política dice que los datos crudos heredados de fuentes externas **conservan
su nombre original**, y manda documentar la excepción en el README. Esta es la
excepción: aquí los insumos **sí se renombran**, por decisión del equipo en la
sesión del 2026-08-25.

**Por qué.** Los nombres de origen (`22.  REX 482 INSTRUCCIONES REGLAMENTOS.pdf`)
llevan un número de orden que no significa nada fuera de la carpeta que los
recibió, espacios dobles, tildes y mayúsculas. El pipeline deriva de este nombre
tres campos del JSON y del sitio (`tipo`, `numero`, `slug`), y esos campos
terminan en la URL pública de cada norma. Un nombre canónico
`snake_case` sin tildes es lo que hace que la URL sea estable y citable, y que
agregar una norma nueva no exija tocar código.

**Qué se preserva.** La tabla de abajo es la trazabilidad completa: nombre
original, nombre canónico y md5. El md5 permite verificar en cualquier momento
que el renombre no alteró un solo byte del documento; se midió antes y después
del movimiento y coincidió en los 24 archivos.

---

## Tabla de equivalencias

| Nombre original | Nombre canónico | Págs. | Capa de texto | md5 |
|---|---|---:|:---:|---|
| `01. 20370 LGE.pdf` | `ley_20370_general_educacion.pdf` | 32 | si | `9cce250b79be4589230494092f3c0824` |
| `02. 20536 VIOLENCIA ESCOLAR.pdf` | `ley_20536_violencia_escolar.pdf` | 3 | si | `8eb272ea6937cb37f8f0ab5c152d97fb` |
| `03. 20845 INCLUSION SEP.pdf` | `ley_20845_inclusion_escolar.pdf` | 56 | si | `37db6c0f310d02eba3a0c87ca25cd071` |
| `04. 20911 FORMACIÓN CIUDADANA.pdf` | `ley_20911_formacion_ciudadana.pdf` | 3 | si | `1bd819073a4ac1622d4d33af5377620c` |
| `05. 19979 JEC.pdf` | `ley_19979_jornada_escolar_completa.pdf` | 22 | si | `52b8b63b0d27ddbab493e809ed6b5754` |
| `06. 21545 LEY TEA.pdf` | `ley_21545_tea.pdf` | 9 | si | `85b75140d4091151236117407ab51955` |
| `07. 21430 PROTECCIÓN Y DERECHOS NIÑEZ.pdf` | `ley_21430_garantias_ninez.pdf` | 41 | si | `3c9b0f591769ada5be42677531e17419` |
| `08. 21801 CELULARES.pdf` | `ley_21801_celulares.pdf` | 4 | si | `d13f800d35a4e30934d4234b5e41b48a` |
| `23. 21809 LEY DE CONVIVENCIA.pdf` | `ley_21809_convivencia_educativa.pdf` | 30 | si | `b50d8dfc1b57d4abc640710dab087078` |
| `09. DLF 315 PÉRDIDA RO.pdf` | `dfl_315_perdida_reconocimiento_oficial.pdf` | 28 | si | `c1e73c44b614fdfde4281d9936011483` |
| `10. DFL 1 MINEDUC ESTATUTO ASISTENTES.pdf` | `dfl_1_estatuto_asistentes_educacion.pdf` | 96 | si | `ef06d576613e2923cd31d2679bde9e55` |
| `11. DTO 215 UNIFORME.pdf` | `dto_215_uniforme_escolar.pdf` | 4 | si | `eef9409a2da5bcd0d3c98415509500f1` |
| `12. DTO 24 CONSEJOS ESCOLARES.pdf` | `dto_24_consejos_escolares.pdf` | 6 | si | `ab6ae7d78a26b866e1230db5fc5e03b0` |
| `13. DTO 453 ESTATUTO PROFESIONALES DE LA EDUCACION.pdf` | `dto_453_estatuto_docente.pdf` | 56 | si | `8d9ec3e5a6bcd9b52f758c27e4277041` |
| `14. DTO 565 CGPMA.pdf` | `dto_565_centros_padres_apoderados.pdf` | 7 | si | `f45241109e5126acf197fcd8367eec00` |
| `15. CIRULAR 193 EMBARAZOS.pdf` | `circular_193_estudiantes_embarazadas.pdf` | 16 | **no** | `91a0bb6ca82ba46064752c2e9a023ad8` |
| `16. CIRCULAR 586 LEY TEA.pdf` | `circular_586_tea.pdf` | 1 | **no** | `ece5c0fccfb802be65fc10cd49fc4429` |
| `17. CIRCULAR 812 IDENTIDAD DE GÉNERO.pdf` | `circular_812_identidad_genero.pdf` | 10 | **no** | `26187828e3bcad20400fa40ee86680b1` |
| `18. REX 181 CELULARES.pdf` | `rex_181_celulares.pdf` | 1 | si | `a8a536f93e9d1d32730d3b909c57b79b` |
| `22.  REX 482 INSTRUCCIONES REGLAMENTOS.pdf` | `rex_482_instrucciones_reglamentos_internos.pdf` | 1 | si | `947a35e02f386692a0d0a41aee06f364` |
| `19. DICTÁMENES 52 Y 77 EXPULSION.pdf` | `dictamen_52_77_expulsion.pdf` | 8 | si | `69d5c91d949fd664f85e1b78dbf4bf37` |
| `20. DICTÁMEN 065 REVISIÓN DE MOCHILAS.pdf` | `dictamen_065_revision_mochilas.pdf` | 6 | si | `637a11c73e0008858aba6b28411a1e9d` |
| `21. DICTÁMEN 71 EXPULSIONES Y CANCELACIONES DE MATRÍCULA.pdf` | `dictamen_71_expulsion_cancelacion_matricula.pdf` | 8 | si | `8cd1aada39ab7bc49c9e21da73335245` |
| `482 REGLAMENTOS.pdf` | `rex_482_reglamentos_b.pdf` | 48 | **no** | `fb6d0ed59ea2e9fbe374c06bffa0b381` |

**Suma de control del conjunto** (md5 de la concatenación ordenada de los 24
md5): `c1a2bdac9f0f5da37745f03ac5f53076`. Idéntica antes y después del
movimiento del 2026-08-25.

---

## Documentos sin capa de texto (4 de 24)

Cuatro PDF son escaneos de imagen: `pdftools::pdf_text()` devuelve **cero**
caracteres alfabéticos sobre ellos.

| Canónico | Págs. | Qué es |
|---|---:|---|
| `circular_193_estudiantes_embarazadas.pdf` | 16 | Circular 193, estudiantes embarazadas, madres y padres |
| `circular_586_tea.pdf` | 1 | Circular 586, ley TEA |
| `circular_812_identidad_genero.pdf` | 10 | Circular 812, derechos de niñas, niños y estudiantes trans |
| `rex_482_reglamentos_b.pdf` | 48 | Cuerpo de la Circular 482 sobre reglamentos internos |

Desde el **2026-08-25** los cuatro tienen transcripción automática, generada por
`00_ocr_documentos.R` y depositada en `20_insumos/ocr/<slug>/pagina_NNN.txt`, una
página por archivo. Esa transcripción está en estado `ocr_pendiente_revision`:
**no es cita textual** y el sitio lo declara junto al enlace al PDF y sobre el
texto. La condición la fijó el equipo al autorizar el OCR: un texto legal
reconocido por máquina y sin revisar es *plausible pero no verificado*, y este
sitio se lee para tomar decisiones que afectan a estudiantes.

El procedimiento de revisión, página por página, está en el README de la raíz.
Solo una persona del equipo mueve un documento a `ocr_revisado`, editando
`20_insumos/curaduria/metadatos_curados.json`.

---

## Veredicto sobre el presunto duplicado 482

El encargo anticipaba que `22.  REX 482 INSTRUCCIONES REGLAMENTOS.pdf` y
`482 REGLAMENTOS.pdf` fueran el mismo archivo. **No lo son**, medido el
2026-08-25:

| | `22.  REX 482 …` | `482 REGLAMENTOS.pdf` |
|---|---|---|
| md5 | `947a35e02f386692a0d0a41aee06f364` | `fb6d0ed59ea2e9fbe374c06bffa0b381` |
| Tamaño | 25.302 bytes | 15.570.204 bytes |
| Páginas | 1 | 48 |
| Capa de texto | sí (1.297 caracteres) | no (0 caracteres) |

Son documentos complementarios: el primero es la **resolución exenta N° 482 de
2018**, el acto administrativo de una página que aprueba la circular; el segundo
es el **cuerpo de la circular** aprobada, escaneado. Se conservan los dos, con
los nombres `rex_482_instrucciones_reglamentos_internos.pdf` y
`rex_482_reglamentos_b.pdf` respectivamente. La autorización de `rm` del encargo
estaba condicionada a md5 idéntico y por lo tanto **no se ejerció**.

---

## Agregar una norma nueva

1. Dejar el PDF en esta carpeta con nombre canónico
   `<tipo>_<numero>_<materia>.pdf`, donde `<tipo>` es uno de `ley`, `dfl`,
   `dto`, `circular`, `rex`, `dictamen` (los que declara `TIPOS_NORMA` en
   `10_utils/10_configuracion.R`).
2. Agregar su fila a la tabla de equivalencias de arriba, con el md5.
3. Correr `Rscript -e 'source("00_run_all.R"); run_all()'` desde la raíz.
4. Revisar las marcas `# REVISAR` que el pipeline haya dejado en el JSON: son
   metadatos que no pudo derivar del texto y que nadie debe inventar.
