import Foundation
import AtlasCore

// Label — peel de ConversationTypes+Feedback.

extension FeedbackKind {
    var label: String {
        switch self {
        case .util: return "útil"
        case .contexto: return "contexto"
        case .longo: return "longo"
        case .fraco: return "fraco"
        }
    }
}
