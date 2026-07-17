import Foundation
import AtlasCore

/// Change review spoken — peel de ConversationMessages+A11y.

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
