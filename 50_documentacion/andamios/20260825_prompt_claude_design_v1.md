# Prompt para Claude Design — Biblioteca de Normativa de Convivencia Educativa

Diseña la interfaz de un sitio web público llamado "Biblioteca de Normativa
de Convivencia Educativa", un buscador de leyes, decretos, circulares y
dictámenes chilenos sobre convivencia escolar, mantenido por un Servicio
Local de Educación Pública. Es un sitio estático (Quarto + Pagefind en
GitHub Pages), sin backend ni cuentas de usuario.

## Usuarios y contexto de uso

Profesionales de equipos de convivencia escolar (encargados de convivencia,
duplas psicosociales, directivos) que necesitan resolver rápido preguntas
del tipo "¿puedo revisar la mochila de un estudiante?", "¿qué exige la ley
ante una expulsión?". Consultan muchas veces desde el celular, en medio de
situaciones con tiempo acotado. No son abogados: necesitan llegar al
artículo exacto sin leer la ley completa.

## Principios de diseño

1. Minimalista y sobrio: es un sitio institucional público, no un producto
   comercial. Cero adornos que compitan con el texto legal.
2. La búsqueda es la protagonista: un campo de búsqueda grande y central en
   la home, estilo página de inicio de un buscador, con ejemplos de
   consultas reales debajo ("revisión de mochilas", "cancelación de
   matrícula", "uso de celulares").
3. Tipografía optimizada para lectura larga de texto legal: serif o
   humanista legible, interlineado generoso, ancho de columna acotado
   (65-75 caracteres), jerarquía clara entre título de norma, número de
   artículo y cuerpo.
4. Navegación por facetas siempre visible: por tipo de norma (ley, decreto,
   circular, dictamen, resolución), por tema (violencia escolar, inclusión,
   expulsiones, celulares, identidad de género, etc.) y por año.
5. La unidad de contenido es el ARTÍCULO: cada resultado de búsqueda y cada
   ancla apunta a un artículo específico dentro de una norma. La página de
   norma muestra los artículos como bloques claramente separados, con su
   número destacado y enlace copiable.
6. Accesibilidad AA como mínimo: contraste alto, tamaños táctiles, soporte
   completo mobile-first, funciona sin JavaScript para la navegación básica
   (la búsqueda sí requiere JS).
7. Paleta contenida: un color institucional primario (azul profundo o
   verde petróleo, a tu criterio), neutros cálidos para fondo, un solo
   color de acento para resultados y estados activos. Modo claro por
   defecto.
8. Componentes a diseñar: home con buscador; página de resultados con
   extracto del artículo y ruta (norma → artículo); página de norma con
   ficha de metadatos (tipo, número, año, temas, enlace a fuente oficial) y
   articulado; índices por faceta; header y footer institucionales
   discretos; estado vacío de búsqueda con sugerencias.

## Restricciones técnicas

HTML + CSS que pueda integrarse a un tema de Quarto (SCSS variables
bienvenidas). Sin frameworks pesados; CSS puro o utilidades ligeras. La UI
de resultados debe convivir con el widget de Pagefind (personalizable vía
CSS custom properties). Idioma del sitio: español de Chile.

## Entregable esperado

Mockup de la home, de una página de resultados y de una página de norma
(desktop y mobile), más la definición de tokens (colores, tipografía,
espaciado) lista para traducir a SCSS.
