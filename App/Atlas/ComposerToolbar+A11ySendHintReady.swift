import SwiftUI
import AtlasCore

// Send hint when ready — peel de ComposerToolbar+A11yHint.

extension ComposerToolbar {
    func spokenSendHintReady() -> String {
        isExecuting
            ? "envia esta mensagem na fila do próximo turno"
            : "envia mensagem e anexos ao Atlas"
    }
}
