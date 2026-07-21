import SwiftUI
import AtlasCore

// Send hint when blocked — peel de ComposerToolbar+A11yHint.

extension ComposerToolbar {
    func spokenSendHintBlocked() -> String {
        if isExecuting {
            return "escreva uma mensagem para adicionar à fila durante a execução"
        }
        if !model.drafts.isEmpty {
            return "adicione texto ou envie os anexos prontos"
        }
        return "escreva uma mensagem ou adicione um anexo para enviar"
    }
}
