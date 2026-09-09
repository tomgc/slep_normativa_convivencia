// =============================================================================
// consulta_pagefind.mjs - consulta el indice Pagefind ya construido y devuelve
// JSON CRUDO. Modo LECTURA: no escribe en el sitio ni reindexa nada.
// -----------------------------------------------------------------------------
// AUXILIAR DECLARADO (ambiguedad 2 del encargo v11), y por que no puede ser R:
// el indice de Pagefind es un conjunto de fragmentos binarios que solo sabe leer
// su propio runtime, distribuido como modulo JavaScript con un nucleo WASM
// (40_salidas/sitio/pagefind/pagefind.js + wasm.*.pagefind). No existe lector R
// de ese formato, y reimplementarlo seria reimplementar el motor: la unica forma
// de medir el buscador que se publica es llamar a la misma API que llama la
// pagina. JavaScript queda acotado a este archivo.
//
// ESTE ARCHIVO NO EVALUA NADA. No ordena, no recorta, no compara con anclas
// esperadas y no cuenta aciertos: emite los sub-resultados en el orden en que
// Pagefind los entrega (orden de documento) con sus weighted_locations enteras.
// Todo el orden, el tope y toda cifra los produce tests/medir_buscador.R, en R.
// Es copia de 50_documentacion/andamios/lab_motor_v9/a2_consulta_pagefind.mjs
// adaptada SOLO en rutas (el pagefind.js deja de estar cableado y llega por
// argumento) y en emitir weighted_locations crudas en vez de sus sumas.
//
// Uso, con el sitio servido por HTTP local (lo levanta tests/medir_buscador.R):
//   node tests/consulta_pagefind.mjs <entrada.json> <salida.json> <basePath> <pagefind.js>
// entrada.json: lista de {id, consulta, filtros?}
// =============================================================================
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";
import { performance } from "node:perf_hooks";

const [, , entrada, salida, base, rutaJs] = process.argv;
if (!entrada || !salida || !base || !rutaJs) {
  console.error("uso: node tests/consulta_pagefind.mjs <entrada.json> <salida.json> <basePath> <pagefind.js>");
  process.exit(2);
}

const consultas = JSON.parse(readFileSync(entrada, "utf8"));
const p = await import(pathToFileURL(resolve(rutaJs)).href);
await p.options({ basePath: base });
await p.init();

const salidaObj = { base, pagefind_js: resolve(rutaJs), consultas: [] };

for (const c of consultas) {
  const opciones = c.filtros ? { filters: c.filtros } : undefined;
  const t0 = performance.now();
  const s = await p.search(c.consulta, opciones);
  const t1 = performance.now();

  const resultados = [];
  for (const [i, r] of s.results.entries()) {
    const d = await r.data();
    resultados.push({
      rango_pagina: i + 1,
      url: d.url,
      // meta.url es la que la interfaz compara contra el primer sub-resultado
      // para descartarlo cuando repite la pagina; se emite para que R pueda
      // aplicar ese mismo descarte sin adivinar.
      meta_url: d.meta && d.meta.url ? d.meta.url : null,
      score: r.score,
      n_palabras_coincidentes: r.words.length,
      n_sub_results: d.sub_results.length,
      sub_results: d.sub_results.map((sr, j) => ({
        orden_documento: j + 1,
        title: sr.title,
        url: sr.url,
        anchor_id: sr.anchor ? sr.anchor.id : null,
        excerpt: sr.excerpt ?? null,
        weighted_locations: (sr.weighted_locations || []).map((l) => ({
          weight: l.weight,
          balanced_score: l.balanced_score,
          location: l.location
        }))
      }))
    });
  }

  salidaObj.consultas.push({
    id: c.id,
    consulta: c.consulta,
    filtros: c.filtros ?? null,
    n_resultados: s.results.length,
    ms_busqueda: Math.round((t1 - t0) * 100) / 100,
    resultados
  });
}

writeFileSync(salida, JSON.stringify(salidaObj, null, 1));
console.log(`consultas: ${salidaObj.consultas.length} | escrito: ${salida}`);
process.exit(0);
