<!-- fragmento literal de 20260904_alcance_capa1_vocabulario_v1.md lineas 322-387, copiado por aud_procedimiento.R el 2026-09-06 -->
## 6. Criterio de éxito: los cuatro casos plantados

Se ejecutan dentro del script (salida §9) y **el script aborta con `stop()` si alguno falla**; la corrida citada terminó con código 0. Salida literal (columnas `contexto` y `rotulo` truncadas por el propio script a 60 y 70 caracteres):

```
> consulta "celu": 3 sugerencia(s)
 termino                     tipo  contexto                                                     destino                               destino_canonico                      rotulo puntaje
 uso de dispositivos móviles tema  3 normas                                                     tema-uso-de-dispositivos-moviles.html tema-uso-de-dispositivos-moviles.html        100
 Ley 21.801                  norma MODIFICA LA LEY Nº 20.370, GENERAL DE EDUCACIÓN, CON EL O... ley_21801_celulares.html              ley_21801_celulares.html                      90
 Resolución exenta 181       norma RESOLUCIÓN N° 181 EXENTA, DE FECHA 26.02.2026 QUE “APRUEB... rex_181_celulares.html                rex_181_celulares.html                        90
OK celu: aparecen el tema de dispositivos moviles y la Ley 21.801

> consulta "circular 482": 3 sugerencia(s)
 termino                            tipo     contexto                                                     destino
 Resolución exenta 482 (cuerpo)     norma    Cuerpo de la Circular 482 sobre reglamentos internos         rex_482_reglamentos_b.html
 Resolución exenta 482 (resolución) norma    RESOLUCIÓN N° 482 EXENTA, DE 22 DE JUNIO DE 2018, QUE APR... rex_482_instrucciones_reglamentos_internos.html
 Documento completo                 articulo Resolución exenta 482 (resolución)                           rex_482_instrucciones_reglamentos_internos.html#documento
 destino_canonico                                          rotulo                                                                 puntaje
 rex_482_instrucciones_reglamentos_internos.html           Texto obtenido por OCR, en revisión; el PDF oficial es la fuente; m... 110
 rex_482_instrucciones_reglamentos_internos.html           mismo acto que rex_482_reglamentos_b (incluye el cuerpo del reglame... 110
 rex_482_instrucciones_reglamentos_internos.html#documento                                                                         60

> consulta "REX 482": 3 sugerencia(s)
 termino                            tipo     contexto                                                     destino
 Resolución exenta 482 (cuerpo)     norma    Cuerpo de la Circular 482 sobre reglamentos internos         rex_482_reglamentos_b.html
 Resolución exenta 482 (resolución) norma    RESOLUCIÓN N° 482 EXENTA, DE 22 DE JUNIO DE 2018, QUE APR... rex_482_instrucciones_reglamentos_internos.html
 Documento completo                 articulo Resolución exenta 482 (resolución)                           rex_482_instrucciones_reglamentos_internos.html#documento
 destino_canonico                                          rotulo                                                                 puntaje
 rex_482_instrucciones_reglamentos_internos.html           Texto obtenido por OCR, en revisión; el PDF oficial es la fuente; m... 110
 rex_482_instrucciones_reglamentos_internos.html           mismo acto que rex_482_reglamentos_b (incluye el cuerpo del reglame... 110
 rex_482_instrucciones_reglamentos_internos.html#documento                                                                         60
OK circular 482 == REX 482: ambas resuelven a rex_482_instrucciones_reglamentos_internos.html

> consulta "mochila": 3 sugerencia(s)
 termino                  tipo  contexto                                                     destino                                        destino_canonico
 revisión de pertenencias tema  2 normas                                                     tema-revision-de-pertenencias.html             tema-revision-de-pertenencias.html
 Dictamen 078             norma Sobre el uso de medios tecnológicos para la detección de ... dictamen_078_detectores_revision_mochilas.html dictamen_078_detectores_revision_mochilas.html
 Dictamen 065             norma Sobre la procedencia de implementar protocolos preventivo... dictamen_065_revision_mochilas.html            dictamen_065_revision_mochilas.html
 rotulo                                                                 puntaje
                                                                        100
 sustituye a dictamen_065_revision_mochilas; Texto obtenido por OCR,...  90
 sustituida por dictamen_078_detectores_revision_mochilas                65
OK mochila: tema de revision de pertenencias, dictamen 065 con marca 'sustituida por dictamen_078...' y dictamen 078

> consulta "xyzzy": 0 sugerencia(s)

> consulta "convivencia": 5 sugerencia(s)
 termino                                                                                                 tipo     contexto
 convivencia escolar                                                                                     tema     14 normas
 Ley 21.809                                                                                              norma    SOBRE CONVIVENCIA, BUEN TRATO Y BIENESTAR DE LAS COMUNIDA...
 buena convivencia educativa la coexistencia armónica de los                                             glosario Ley 21.809, Artículo 16 A
 buena convivencia escolar la coexistencia armónica de los mi                                            glosario Ley 20.536, Artículo 16 A
 3. EXPULSIÓN Y CANCELACIÓN DE MATRÍCULA COMO MEDIDAS DISCIPLINARIAS POR FALTAS A LA CONVIVENCIA ESCOLAR articulo Dictamen 71
 destino                                                destino_canonico                                       rotulo                                                                 puntaje
 tema-convivencia-escolar.html                          tema-convivencia-escolar.html                                                                                                 140
 ley_21809_convivencia_educativa.html                   ley_21809_convivencia_educativa.html                                                                                          100
 ley_21809_convivencia_educativa.html#art-16-a          ley_21809_convivencia_educativa.html#art-16-a          glosario en borrador, sin validar (estado: borrador, validado_por: ...  70
 ley_20536_violencia_escolar.html#art-16-a              ley_20536_violencia_escolar.html#art-16-a              glosario en borrador, sin validar (estado: borrador, validado_por: ...  70
 dictamen_71_expulsion_cancelacion_matricula.html#num-3 dictamen_71_expulsion_cancelacion_matricula.html#num-3                                                                         50
OK control negativo/positivo en el mismo bloque: 'xyzzy' -> 0 resultados; 'convivencia' -> 5 resultados
```

Lectura contra el criterio del encargo: `"celu"` sugiere el tema y la Ley 21.801 (y además la REX 181, que es la circular sobre celulares); `"circular 482"` y `"REX 482"` devuelven el mismo `destino_canonico`; `"mochila"` llega al tema, al dictamen 065 con "sustituida por dictamen_078…" visible y al dictamen 078 (con "sustituye a dictamen_065…" y su aviso OCR, porque su capa de texto viene de un reconocedor); `"xyzzy"` da 0 y `"convivencia"` da 5 en el mismo bloque. La marca de sustitución sale del campo `vigencia` del catálogo (`estado`, `sustituido_por`, `sustituye_a`); `aviso_vigencia` es `null` en las 25 normas (hallazgo 1 de §7).

---

