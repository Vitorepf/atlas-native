import SwiftUI
import AtlasCore

// Send hint — peel de ComposerToolbar+A11y.

extension ComposerToolbar {
    func spokenSendHint(canSubmit: Bool) -> String {
        if canSubmit {
            return isExecuting
                ? "envia esta mensagem na fila do próximo turno"
                : "envia mensagem e anexos ao Atlas"
        }
        if isExecuting {
            return "escreva uma mensagem para adicionar à fila durante a execução"
        }
        if !model.drafts.isEmpty {
            return "adicione texto ou envie os anexos prontos"
        }
        return "escreva uma mensagem ou adicione um anexo para enviar"
    }

    func spokenProcessingLabel() -> String { "Atlas processando" }
}
