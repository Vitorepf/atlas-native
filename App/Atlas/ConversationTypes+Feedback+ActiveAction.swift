import Foundation
import AtlasCore

// ActiveAction — peel de ConversationTypes+Feedback.

extension FeedbackKind {
    var activeAction: String {
        switch self {
        case .util: return "useful"
        case .contexto: return "wrong_context"
        case .longo: return "too_long"
        case .fraco: return "weak"
        }
    }
}
