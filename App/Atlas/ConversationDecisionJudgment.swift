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
}
