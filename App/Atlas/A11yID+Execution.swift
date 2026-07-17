import Foundation

// Execution + plan A11yIDs — peel de A11yID.swift.

extension A11yID {
    static let executionReconnectBanner = "execution-reconnect-banner"
    static let executionSilenceWatchdog = "execution-silence-watchdog"
    static let executionReplayScrubber = "execution-replay-scrubber"
    static let executionProof = "execution-proof"
    static let editorialTurnSignature = "editorial-turn-signature"
    static let editorialTurnFeedbackPrefix = "editorial-turn-feedback-"
    static let markdownCodeBlockPrefix = "markdown-code-block-"
    static let markdownCodeCopyPrefix = "markdown-code-copy-"
    static func markdownCodeBlock(_ index: Int) -> String { markdownCodeBlockPrefix + String(index) }
    static func markdownCodeCopy(_ index: Int) -> String { markdownCodeCopyPrefix + String(index) }
    static func editorialTurnFeedback(_ kind: String) -> String { editorialTurnFeedbackPrefix + kind }
    static let executionStateCard = "execution-state-card"
    static let planCard = "plan-card"
    static let planSteps = "plan-steps"
    static let planProgress = "plan-progress"
    static let planStepPrefix = "plan-step-"
    static func planStep(_ index: Int) -> String { planStepPrefix + String(index) }
}
