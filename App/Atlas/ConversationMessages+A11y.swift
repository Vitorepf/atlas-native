import Foundation
import AtlasCore

/// Spoken labels do feed de turnos — peel de ConversationMessages (CICLO C residual honesty).

enum ConversationMessagesA11y {
    static let scrollFABLabel = "ir para o fim da conversa"
    static let scrollFABHint = "volta às mensagens mais recentes"

    static func spokenMessages(turnCount: Int) -> String {
        let noun = turnCount == 1 ? "turno" : "turnos"
        return "conversa, \(turnCount) \(noun)"
    }

    static func spokenChangeReview(patchCount: Int) -> String {
        if patchCount > 0 {
            let noun = patchCount == 1 ? "patch" : "patches"
            return "revisar mudanças, \(patchCount) \(noun)"
        }
        return "revisar mudanças desta execução"
    }

    static let changeReviewHint = "abre arquivos, diff e provas desta execução"
}
