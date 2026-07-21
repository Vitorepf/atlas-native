import SwiftUI
import AtlasCore

// WAVE-156 density peel — AgentRow + ExecutingStrip host

struct AgentRow: View {
    let agent: ExecAgent
    var compactLane = false
    var body: some View {
        agentRowChrome(agentRowContent)
    }
}

// MARK: - Conversation live instrument (WAVE-006)
// Uma árvore visual: live · progress · reconnect · stop · steer.
// Reconnect banner (cockpit) e silence watchdog continuam secondary surfaces.

struct ExecutingStrip: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var onSteer: (() -> Void)? = nil
    /// WAVE-031: same path as StateCard — resolveExecutionChoice(jobId, optionId).
    var onChoose: ((JobID, String) -> Void)? = nil

    /// WAVE-023: strip branches on exclusive face (not bool soup alone).
    var face: ConversationExecutionFace {
        ConversationExecutionPhase.face(for: bubble)
    }

    var decisionRequired: Bool {
        ConversationDecisionJudgment.isDecisionRequired(bubble)
    }

    var choiceActions: [AtlasExecutionPresentationState.Action] {
        ConversationDecisionJudgment.choiceActions(for: bubble)
    }

    var body: some View {
        HStack(spacing: 8) {
            stripStatus
            Spacer(minLength: 0)
            if ConversationExecutionPhase.stripShowsLiveChrome(bubble) || decisionRequired {
                stripActionButtons
            }
        }
        .padding(.horizontal, 6)
        .lineLimit(1)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.executionLiveStrip)
    }
}
