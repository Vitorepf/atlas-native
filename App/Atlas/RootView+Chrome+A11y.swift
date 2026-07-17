import SwiftUI

/// Spoken labels do chrome da home — peel de RootView+Chrome (CICLO C residual honesty).

extension RootView {
    func mastheadSpokenLabel(auditModeEnabled: Bool) -> String {
        auditModeEnabled ? "Atlas, modo auditoria" : "Atlas"
    }

    func mastheadSpokenHint() -> String {
        "pressione e segure para alternar modo auditoria"
    }

    func searchSpokenLabel() -> String {
        "buscar conversas"
    }

    func newConversationSpokenLabel() -> String {
        "nova conversa"
    }

    func newConversationSpokenHint() -> String {
        "abre conversa em branco"
    }

    func inputPillSpokenLabel() -> String {
        "Escreva ao Atlas, nova conversa"
    }

    func homeScreenSpokenLabel() -> String {
        "Atlas, início"
    }

    func homeScreenSpokenHint() -> String {
        "workspaces, conversas e Autônomos; Live Now aparece quando há sessão viva"
    }
}
