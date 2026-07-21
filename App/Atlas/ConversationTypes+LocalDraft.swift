import Foundation
import AtlasCore

/// Anexo local (pré-envio) — peel de ConversationTypes.
/// O ÚNICO contrato de UI de anexos: a strip do composer renderiza isto e nada
/// mais. O AttachmentInput correspondente vive no model, fora da View.

struct LocalDraft: Identifiable, Equatable {
    enum State: Equatable { case pronto, subindo, falhou(String) }
    let id: String
    let fileName: String
    let mimeType: String
    let kind: AtlasAttachmentKind
    let bytes: Int
    let preview: Data?     // pequena o bastante pra UIImage(data:) direto
    var state: State = .pronto
}
