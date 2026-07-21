import Foundation

// Editorial turn A11yIDs — peel de A11yID+Execution.

extension A11yID {
    static let editorialTurnSignature = "editorial-turn-signature"
    static let editorialTurnFeedbackPrefix = "editorial-turn-feedback-"
    static func editorialTurnFeedback(_ kind: String) -> String { editorialTurnFeedbackPrefix + kind }
}
