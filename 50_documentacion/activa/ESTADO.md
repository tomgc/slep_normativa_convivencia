---
slug: slep_normativa_convivencia
nombre_real: Biblioteca de normativa de convivencia educativa, SLEP Costa Central
categoria: activo
semaforo: activo
sesion_actual: v04
ultima_actividad: 2026-09-10
maneja_sensibles: false
tipo_pendiente: bug
sesion_abierta: false
maquina: MacBook-Pro-de-Tomas.local
commit_cierre: 413add0
traspaso_vigente: traspaso_cierre_v04.md
cierre_incompleto: no
insumos_verificados: 2026-09-10
ventana_insumos: ./20_insumos
---
## En que vamos
Sitio publicado y estable (25 normas, 806 segmentos con ancla) con el índice lateral poblado y un buscador que expande la consulta y ya lleva un instrumento versionado. El buscador encuentra el ancla correcta en 8 de 10 consultas pero la pone primera en 0 de 10, y ese es el criterio del titular. Vía A sin avance desde la sesión 1; cuatro decisiones (D-A a D-D) y once dudas del log en manos del titular.
## Proximo paso
Encargo v12: capa de precedencia determinística sobre Pagefind (norma nombrada, norma principal del tema, fuente primaria antes que dictamen antes que OCR, coincidencia literal al final) con posición 1 como cifra principal, tras resolver D-03, D-09 y D-11 y materializar la decisión en `decisiones/`.
## Bloqueantes
- P1: el buscador no lleva al mejor resultado primero (0 de 10 por posición 1).
- P3: decisiones D-A a D-D sin tomar.
- P6: saneamiento del corpus (LGE 2010; DFL 2/1998 y Ley 21.128 ausentes), exige delegación de escritura en `20_insumos/`.
- P7: vía A sin avance; 22 piezas en borrador, 0 publicadas.
