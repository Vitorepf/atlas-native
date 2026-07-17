import Foundation

// Rich Input · L1 contract — detectors e builders do payload
// `atlas.rich_input.payload.v1`. Tipos/wire DTOs em RichInputTypes.swift.
//
// Anti-drift: golden checks comparam a saída destes builders byte-a-byte
// (estruturalmente, via JSONValue) com fixtures GERADAS PELO CANON TS
// (packages/atlas-rich-input-canon/fixtures/rich-input.json).
//
// Lição dura do servidor (AiInteractionController): uploaded_image_ids/
// uploaded_document_ids DENTRO deste payload NÃO anexam nada — são metadados
// de routing (detecção de visão no Atlas Decide). O que anexa de verdade são
// os campos uploaded_images/uploaded_documents no NÍVEL RAIZ do create.
//
// Classifier: RichInputContract+Classifier.swift · Builder: RichInputContract+Builder.swift
