import AtlasCore
import Foundation

// Cycle 029 fuse → ConversationMessages+A11y.swift

enum ConversationMessagesA11y {
    static let scrollFABLabel = ConversationMessagesA11yFAB.scrollFABLabel
    static let scrollFABHint = ConversationMessagesA11yFAB.scrollFABHint

    static func spokenMessages(turnCount: Int) -> String {
        let noun = turnCount == 1 ? "turno" : "turnos"
        return "conversa, \(turnCount) \(noun)"
    }

    static func spokenChangeReview(patchCount: Int) -> String {
        ConversationMessagesA11yReview.spokenChangeReview(patchCount: patchCount)
    }

    static let changeReviewHint = ConversationMessagesA11yReview.changeReviewHint
}

enum ConversationMessagesA11yFAB {
    static let scrollFABLabel = "ir para o fim da conversa"
    static let scrollFABHint = "volta às mensagens mais recentes"
}

enum ConversationMessagesA11yReview {
    static func spokenChangeReview(patchCount: Int) -> String {
        if patchCount > 0 {
            let noun = patchCount == 1 ? "patch" : "patches"
            return "revisar mudanças, \(patchCount) \(noun)"
        }
        return "revisar mudanças desta execução"
    }

    static let changeReviewHint = "abre arquivos, diff e provas desta execução"
}
