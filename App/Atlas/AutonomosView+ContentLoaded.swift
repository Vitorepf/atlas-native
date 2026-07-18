import SwiftUI
import AtlasCore

// Loaded content — peel de AutonomosView+Content.

extension AutonomosView {
    var loadedContent: some View {
        AutonomosLoadedSection(
            model: model,
            auditModeEnabled: session.auditModeEnabled,
            nightly: nightly,
            oldestBacklogCreatedAt: oldestBacklogCreatedAt(),
            nightlyStartProposal: $nightlyStartProposal,
            control: $control,
            startRunMode: $startRunMode,
            showTransferSheet: $showTransferSheet,
            detailSheet: $detailSheet,
            selfConstructionReceipt: $selfConstructionReceipt
        )
    }
}
