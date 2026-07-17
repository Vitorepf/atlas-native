import SwiftUI
import AtlasCore

/// Cena operacional do Fable 5: o estado chega pronto do ledger e só então a
/// conversa oferece uma ação. Não há botão, prazo ou risco criado pela casca.
/// Header → +Header · Meta → +Meta · Detail → +Detail · ações → +ActionButtons.
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
            stateHeader
            detailLine
            metaLines
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
