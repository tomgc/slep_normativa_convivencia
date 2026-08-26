// =============================================================================
// 00_ocr_vision.swift - reconocimiento optico de texto con el framework Vision
// -----------------------------------------------------------------------------
// Auxiliar de 00_ocr_documentos.R (POLITICA 1.2.4: el auxiliar toma el numero
// del ejecutable que lo usa). Recibe rutas de imagen y escribe a stdout el texto
// reconocido, una linea por linea reconocida, en el orden en que Vision las
// devuelve.
//
// Por que Vision y no Tesseract: comparados sobre la misma pagina del corpus
// (circular_812, pagina 2, 300 dpi) el 2026-08-25, Tesseract leyo "de tos
// establecimientos" donde dice "los" y "Ley N* 20.529" donde dice "N°". Vision
// acerto ambos. En un texto que una persona tiene que revisar linea por linea,
// cada error del motor es trabajo humano.
//
// Contrapartida declarada: esto solo corre en macOS. No importa para la
// reproducibilidad del pipeline, porque la salida se versiona en 20_insumos/ y
// 00_run_all.R nunca ejecuta esta herramienta: la lee ya escrita.
// =============================================================================

import Foundation
import Vision
import AppKit

let rutas = Array(CommandLine.arguments.dropFirst())
guard !rutas.isEmpty else {
    FileHandle.standardError.write("uso: 00_ocr_vision <imagen...>\n".data(using: .utf8)!)
    exit(2)
}

for ruta in rutas {
    guard let imagen = NSImage(contentsOfFile: ruta),
          let cg = imagen.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        FileHandle.standardError.write("no se pudo leer la imagen: \(ruta)\n".data(using: .utf8)!)
        exit(1)
    }
    let peticion = VNRecognizeTextRequest()
    // .accurate y no .fast: la diferencia de tiempo es de segundos por pagina y
    // la de exactitud la paga una persona revisando.
    peticion.recognitionLevel = .accurate
    peticion.recognitionLanguages = ["es-ES"]
    peticion.usesLanguageCorrection = true
    let handler = VNImageRequestHandler(cgImage: cg, options: [:])
    do {
        try handler.perform([peticion])
    } catch {
        FileHandle.standardError.write("Vision fallo en \(ruta): \(error)\n".data(using: .utf8)!)
        exit(1)
    }
    for observacion in peticion.results ?? [] {
        if let mejor = observacion.topCandidates(1).first {
            print(mejor.string)
        }
    }
}
