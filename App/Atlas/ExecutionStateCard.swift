import SwiftUI
import AtlasCore

/// Cena operacional do Fable 5: o estado chega pronto do ledger e só então a
/// conversa oferece uma ação. Não há botão, prazo ou risco criado pela casca.
/// Header → +Header · Meta → +Meta · Detail → +Detail · ações → +ActionButtons.
/// Display → +Display.swift
/// Chrome → ExecutionStateCard+Chrome.swift
struct ExecutionStateCard: View {
    let state: AtlasExecutionPresentationState
    let jobId: JobID?
    let onChoose: (JobID, String) -> Void
    var retryableJobId: JobID? = nil
    var onRetry: (JobID) -> Void = { _ in }
    var onSteer: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        stateCardChrome {
            VStack(alignment: .leading, spacing: 10) {
                stateHeader
                detailLine
                metaLines
                actionButtons
            }
        }
    }
}
