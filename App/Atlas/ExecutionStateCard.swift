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

extension ExecutionStateCard {
    func choiceActionButton(_ action: AtlasExecutionPresentationState.Action, choiceJobId: JobID) -> some View {
        Button { onChoose(choiceJobId, action.id) } label: {
            Text(action.title)
                .font(.system(.caption, weight: .semibold))
                .lineLimit(1)
                .padding(.horizontal, 11).padding(.vertical, 8)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(ExecutionStateActionStyle(
            style: action.style,
            reduceMotion: reduceMotion
        ))
        .accessibilityIdentifier(A11yID.executionActionChoice(action.id))
        .accessibilityLabel(action.title)
        .accessibilityHint("ação declarada pelo servidor")
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var choiceActionButtons: some View {
        if effectiveChoiceJobId != nil, !state.actions.isEmpty {
            choiceButtonsStack
        } else {
            retryFallbackButton
        }
    }
}


extension ExecutionStateCard {
    var publishedExternalDeadline: String? {
        guard state.kind == .awaitingExternal else { return nil }
        return state.deadline
    }

    var effectiveChoiceJobId: JobID? {
        if let jobId { return jobId }
        if state.kind == .failed { return retryableJobId }
        return nil
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var detailLine: some View {
        if let detail = state.detail {
            Text(detail)
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    static func shouldDisplay(state: AtlasExecutionPresentationState) -> Bool {
        if state.kind == .completed,
           state.actions.isEmpty,
           state.detail == nil,
           state.checkpoint == nil,
           state.deadline == nil {
            return false
        }
        return true
    }
}

extension ExecutionStateCard {
    /// WAVE-052: chrome maps owned by Judgment.
    var iconWait: String? {
        switch state.kind {
        case .attentionRequired, .awaitingExternal:
            return ExecutionStateCardJudgment.iconName(for: state.kind)
        default: return nil
        }
    }

    var iconAttention: String? {
        if let wait = iconWait { return wait }
        switch state.kind {
        case .recovering, .replanning:
            return ExecutionStateCardJudgment.iconName(for: state.kind)
        default: return nil
        }
    }

    var iconTerminal: String {
        ExecutionStateCardJudgment.iconName(for: state.kind)
    }

    var kindBadgeWait: String? {
        switch state.kind {
        case .attentionRequired, .awaitingExternal:
            return ExecutionStateCardJudgment.badge(for: state.kind)
        default: return nil
        }
    }

    var kindBadgeAttention: String? {
        if let wait = kindBadgeWait { return wait }
        switch state.kind {
        case .recovering, .replanning:
            return ExecutionStateCardJudgment.badge(for: state.kind)
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder var metaKickerLines: some View {
        if let kicker = leaveScreenKicker {
            Text(kicker)
                .font(.system(.caption, weight: .semibold))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
        if let checkpoint = state.checkpoint {
            Text("checkpoint · \(checkpoint)")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder var metaLines: some View {
        metaKickerLines
        timerMetaLines
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var deadlineMetaLine: some View {
        if let deadline = publishedExternalDeadline {
            Text("Próxima mudança: \(deadline)")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var frozenTimerLine: some View {
        if let frozen = frozenTimerText {
            Text(frozen)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var recoveringTimerLine: some View {
        if frozenTimerText == nil, let active = recoveringTimerText {
            Text(active)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var timerMetaLines: some View {
        frozenTimerLine
        recoveringTimerLine
        deadlineMetaLine
    }
}

