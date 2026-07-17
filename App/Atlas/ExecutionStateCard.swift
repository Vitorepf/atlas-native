import SwiftUI
import AtlasCore

/// Cena operacional do Fable 5: o estado chega pronto do ledger e só então a
/// conversa oferece uma ação. Não há botão, prazo ou risco criado pela casca.
/// Ações → ExecutionStateCard+ActionButtons; prova → ExecutionProof.swift.
struct ExecutionStateCard: View {
    let state: AtlasExecutionPresentationState
    let jobId: JobID?
    let onChoose: (JobID, String) -> Void
    var retryableJobId: JobID? = nil
    var onRetry: (JobID) -> Void = { _ in }
    var onSteer: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) var reduceMotion

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

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(tint)
                    .accessibilityHidden(true)
                Text(state.title)
                    .font(.system(.footnote, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                Spacer(minLength: 0)
                if let badge = kindBadge {
                    Text(badge)
                        .font(AtlasFont.mono(10)).tracking(0.8)
                        .foregroundStyle(tint)
                        .accessibilityHidden(true)
                }
            }
            if let detail = state.detail {
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityHidden(true)
            }
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
            if let frozen = frozenTimerText {
                Text(frozen)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .accessibilityHidden(true)
            } else if let active = recoveringTimerText {
                Text(active)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .accessibilityHidden(true)
            }
            if let deadline = publishedExternalDeadline {
                Text("Próxima mudança: \(deadline)")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
            actionButtons
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AtlasTheme.surface.opacity(0.68))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(tint.opacity(0.42), lineWidth: 1))
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(spokenSummary)
        .accessibilityIdentifier(A11yID.executionStateCard)
    }
}
