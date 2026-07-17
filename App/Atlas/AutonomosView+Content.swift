import SwiftUI
import AtlasCore

// Conteúdo por fase — peel de AutonomosView (régua ≤100).
// Shell → AutonomosView+ContentShell.swift

extension AutonomosView {
    @ViewBuilder
    var content: some View {
        switch model.phase {
        case .idle, .loading:
            loadingContent
        case .failed(let message):
            failedContent(message: message)
        case .loaded:
            AutonomosLoadedSection(
                model: model,
                auditModeEnabled: session.auditModeEnabled,
                nightly: nightly,
                rhythmSampleDays: rhythmSampleDays,
                oldestBacklogCreatedAt: oldestBacklogCreatedAt(),
                nightlyStartProposal: $nightlyStartProposal,
                control: $control,
                startRunMode: $startRunMode,
                showTransferSheet: $showTransferSheet,
                detailSheet: $detailSheet,
                selfConstructionReceipt: $selfConstructionReceipt,
                onRefreshRhythm: { await refreshRhythmLearning() }
            )
        }
    }
}
