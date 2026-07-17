import SwiftUI

/// Conversation chrome spoken — peel de RootView+Chrome+A11y.

extension RootView {
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
