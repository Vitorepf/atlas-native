import SwiftUI
import AtlasCore

// Watch/observe multi-sessão — peel de TurnPresence (régua ≤100).

extension TurnPresence {
    /// Chamado pela ConversationView no onAppear — registra/atualiza o alvo.
    /// Cada conversa aberta é observada de forma independente (multi-sessão).
    /// `threadId` nil = conversa nova local (linha viva sem navegação até o
    /// servidor confirmar a thread canônica).
    func watch(_ model: ConversationModel, threadTitle: String, threadId: ThreadID? = nil) {
        let id = ObjectIdentifier(model)
        if let existing = entries[id] {
            existing.threadTitle = threadTitle
            existing.threadId = threadId ?? model.threadId
            publishLiveSessions()
            return
        }
        let entry = Entry(model: model, threadTitle: threadTitle, threadId: threadId ?? model.threadId)
        entries[id] = entry
        observe(id)
    }

    func setVisible(_ model: ConversationModel, visible: Bool) {
        entries[ObjectIdentifier(model)]?.visible = visible
    }

}
