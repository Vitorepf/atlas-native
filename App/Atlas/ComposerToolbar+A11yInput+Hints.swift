import SwiftUI
import AtlasCore

// Hints spoken — peel de ComposerToolbar+A11yInput.

extension ComposerToolbar {
    func spokenEffortHint() -> String {
        "abre opções de esforço computacional para o próximo envio"
    }

    func spokenOptionsHint() -> String {
        "modo, esforço e workspace; \(spokenSendHint(canSubmit: false).lowercased())"
    }
}
