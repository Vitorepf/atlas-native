import SwiftUI
import AtlasCore

// Conteúdo por fase — peel de AutonomosView (régua ≤100).

extension AutonomosView {
    @ViewBuilder
    var content: some View {
        switch model.phase {
        case .idle, .loading:
            AutonomosPreludeBlocks(nightly: nightly, rhythmSampleDays: rhythmSampleDays) { nightlyStartProposal = $0 }
            Spacer()
            TraceEvidenceLoading(text: "consultando a frota…", reduceMotion: reduceMotion)
            Spacer()
        case .failed(let message):
            AutonomosPreludeBlocks(nightly: nightly, rhythmSampleDays: rhythmSampleDays) { nightlyStartProposal = $0 }
            Spacer()
            AutonomosFleetFailureEmpty(message: message) { Task { await model.load() } }
            Spacer()
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
