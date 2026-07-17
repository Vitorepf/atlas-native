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
                Text(state.title)
                    .font(.system(.footnote, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
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
            }
            if let checkpoint = state.checkpoint {
                Text("checkpoint · \(checkpoint)")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .accessibilityLabel("checkpoint \(checkpoint)")
            }
            if let frozen = frozenTimerText, let a11y = frozenTimerA11y {
                Text(frozen)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .accessibilityLabel(a11y)
            } else if let active = recoveringTimerText {
                Text(active)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .accessibilityLabel("tempo ativo \(active.replacingOccurrences(of: "ativo ", with: ""))")
            }
            if let deadline = state.deadline {
                Text("Próxima mudança: \(deadline)")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .accessibilityLabel("próxima mudança \(deadline)")
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
