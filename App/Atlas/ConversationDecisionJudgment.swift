import Foundation
import AtlasCore

// MARK: - Conversation mid-run decision (WAVE-031)

/// Pure judgment: when the strip must elevate **Escolher** over live-run dialect.
enum ConversationDecisionJudgment {

    /// Published choice path exists (actions + job id).
    static func isDecisionRequired(_ bubble: ChatBubble) -> Bool {
        guard let state = bubble.executionPresentationState else { return false }
        guard bubble.executionChoiceJobId != nil else { return false }
        return !state.actions.isEmpty
            && (state.kind == .attentionRequired
                || ConversationExecutionPhase.attention(for: state) == .decision)
    }

    static func isDecisionRequired(state: AtlasExecutionPresentationState, jobId: JobID?) -> Bool {
        guard jobId != nil else { return false }
        return !state.actions.isEmpty
            && (state.kind == .attentionRequired
                || ConversationExecutionPhase.attention(for: state) == .decision)
    }

    /// Product lead when decision is required.
    static var productWord: String { "decision" }

    static var spokenLead: String {
        ConversationExecutionPhase.spokenAttention(.decision)
    }

    static func choiceActions(for bubble: ChatBubble) -> [AtlasExecutionPresentationState.Action] {
        guard isDecisionRequired(bubble) else { return [] }
        return bubble.executionPresentationState?.actions ?? []
    }

    /// Compact strip label when many actions: "Escolher" or first title.
    static func stripChooseLabel(actionCount: Int, firstTitle: String?) -> String {
        if actionCount == 1, let firstTitle, !firstTitle.isEmpty {
            return firstTitle
        }
        return "Escolher"
    }

    // MARK: Pack (WAVE-095)

    static func packFacts(from bubble: ChatBubble?) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        guard let bubble, isDecisionRequired(bubble) else {
            absences.append("sem decisão Escolher publicada neste recorte")
            return (facts, absences)
        }
        let actions = choiceActions(for: bubble)
        facts.append("decision_face: \(productWord)")
        facts.append("decision_action_count: \(actions.count)")
        for action in actions.prefix(8) {
            facts.append("decision_action: \(action.title)")
        }
        if let jobId = bubble.executionChoiceJobId {
            facts.append("decision_job: \(jobId.rawValue)")
        }
        return (facts, absences)
    }

    static func packFacts(
        decisionRequired: Bool,
        actionTitles: [String]
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        guard decisionRequired, !actionTitles.isEmpty else {
            absences.append("sem decisão Escolher publicada neste recorte")
            return (facts, absences)
        }
        facts.append("decision_face: \(productWord)")
        facts.append("decision_action_count: \(actionTitles.count)")
        for title in actionTitles.prefix(8) {
            facts.append("decision_action: \(title)")
        }
        return (facts, absences)
    }
}
