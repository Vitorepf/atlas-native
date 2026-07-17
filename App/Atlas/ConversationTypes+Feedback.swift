import Foundation
import AtlasCore

/// Feedback editorial do operador — peel de ConversationTypes.
enum FeedbackKind: String, CaseIterable, Identifiable {
    case util, contexto, longo, fraco
    var id: String { rawValue }
    var label: String {
        switch self {
        case .util: return "útil"; case .contexto: return "contexto"
        case .longo: return "longo"; case .fraco: return "fraco"
        }
    }
    var payload: FeedbackAiInteractionInput {
        switch self {
        case .util: return .init(feedbackScore: 5, feedbackAction: "useful")
        case .contexto: return .init(feedbackScore: 1, feedbackAction: "wrong_context")
        case .longo: return .init(feedbackScore: 2, feedbackComment: "[too_long]")
        case .fraco: return .init(feedbackScore: 1, feedbackComment: "[weak]")
        }
    }
    var activeAction: String {
        switch self {
        case .util: return "useful"; case .contexto: return "wrong_context"
        case .longo: return "too_long"; case .fraco: return "weak"
        }
    }
}
