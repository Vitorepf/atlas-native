import AtlasCore
import SwiftUI

// IDLE-COMPRESS fused

extension ExecutionStateCard {
    @ViewBuilder
    var choiceButtonsStack: some View {
        if let choiceJobId = effectiveChoiceJobId, !state.actions.isEmpty {
            HStack(spacing: 8) {
                ForEach(state.actions) { action in
                    choiceActionButton(action, choiceJobId: choiceJobId)
                }
            }
        }
    }
}

extension ExecutionStateCard {
    func spokenTimerPart(into parts: inout [String]) {
        if let fragment = spokenTimerFragment { parts.append(fragment) }
    }
}

extension ExecutionStateCard {
    func stateCardChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.card)
                    .fill(AtlasTheme.surface.opacity(0.68))
                    .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).stroke(tint.opacity(0.42), lineWidth: 1))
            )
            .accessibilityElement(children: .contain)
            .accessibilityLabel(spokenSummary)
            .accessibilityIdentifier(A11yID.executionStateCard)
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var stateHeaderBadge: some View {
        if let badge = kindBadge {
            Text(badge)
                .font(AtlasFont.mono(10)).tracking(0.8)
                .foregroundStyle(tint)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    var stateHeader: some View {
        // WAVE-027: primary = face spoken; server title = detail only.
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: icon)
                .atlasSans(13, .semibold)
                .foregroundStyle(tint)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(ConversationExecutionPhase.primarySpoken(for: state))
                    .font(AtlasFont.mono(11, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                if !state.title.isEmpty {
                    Text(state.title)
                        .font(AtlasFont.serifItalic(12))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(2)
                        .accessibilityHidden(true)
                }
            }
            Spacer(minLength: 0)
            Text(
                (presenceAttention == .decision
                    ? ConversationDecisionJudgment.productWord
                    : ConversationExecutionPhase.primaryProduct(presenceFace)
                ).uppercased()
            )
            .font(AtlasFont.mono(9))
            .tracking(0.6)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
            stateHeaderBadge
        }
    }
}

extension ExecutionStateCard {
    var icon: String {
        iconAttention ?? iconTerminal
    }

    static func clock(_ ms: Int) -> String {
        AtlasTime.formatActiveDuration(milliseconds: ms)
    }
}

extension ExecutionStateCard {
    /// WAVE-052: completed stays badge-silent (parity); others from Judgment.
    var kindBadge: String? {
        switch state.kind {
        case .completed: return nil
        default: return ExecutionStateCardJudgment.badge(for: state.kind)
        }
    }
}

extension ExecutionStateCard {
    var tint: Color {
        ExecutionStateCardJudgment.tint(for: state.kind)
    }
}

extension ExecutionStateCard {
    var stateCardStack: some View {
        VStack(alignment: .leading, spacing: 10) {
            stateHeader
            detailLine
            metaLines
            actionButtons
        }
    }
}

struct ExecutionStateCard: View {
    let state: AtlasExecutionPresentationState
    let jobId: JobID?
    let onChoose: (JobID, String) -> Void
    var retryableJobId: JobID? = nil
    var onRetry: (JobID) -> Void = { _ in }
    var onSteer: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    /// WAVE-023: exclusive face + attention overlay (not parallel dialects).
    var presenceFace: ConversationExecutionFace {
        ConversationExecutionPhase.face(for: state)
    }

    var presenceAttention: ConversationExecutionAttention? {
        ConversationExecutionPhase.attention(for: state)
    }

    var body: some View {
        stateCardChrome { stateCardStack }
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var actionButtons: some View {
        choiceActionButtons
        steerButton
    }
}

