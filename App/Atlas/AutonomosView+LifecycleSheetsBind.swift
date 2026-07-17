import SwiftUI
import AtlasCore

// Sheets bind — peel de AutonomosView+Lifecycle.

extension AutonomosView {
    func autonomosLifecycleSheets<V: View>(_ content: V) -> some View {
        content.autonomosSheets(
            model: model,
            nightly: nightly,
            control: $control,
            startRunMode: $startRunMode,
            nightlyStartProposal: $nightlyStartProposal,
            showTransferSheet: $showTransferSheet,
            detailSheet: $detailSheet,
            selfConstructionReceipt: $selfConstructionReceipt,
            canRevert: canRevertSelfConstruction,
            revertReceipt: revertReceipt
        )
    }
}
