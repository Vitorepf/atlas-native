import Foundation
import AtlasCore

// Payload — peel de ConversationTypes+Feedback.

extension FeedbackKind {
    var payload: FeedbackAiInteractionInput {
        switch self {
        case .util:
            return .init(feedbackScore: 5, feedbackAction: "useful")
        case .contexto:
            return .init(feedbackScore: 1, feedbackAction: "wrong_context")
        case .longo:
            return .init(feedbackScore: 2, feedbackComment: "[too_long]")
        case .fraco:
            return .init(feedbackScore: 1, feedbackComment: "[weak]")
        }
    }
}
