import SwiftUI
import AtlasCore

// Input spoken — peel de ComposerToolbar+A11yInput.

extension ComposerToolbar {
    func spokenInputLabel() -> String {
        model.bubbles.isEmpty ? "mensagem para o Atlas" : "continuar conversa com o Atlas"
    }

    func spokenInputHint() -> String {
        if canSubmit {
            return isExecuting ? "texto para a fila do próximo turno" : "texto do próximo envio"
        }
        return "escreva aqui para habilitar o envio"
    }
}
