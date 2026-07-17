import SwiftUI
import AtlasCore

// Autônomos lifecycle chrome — peel de AutonomosView.
// Rhythm → AutonomosView+LifecycleRhythm.swift

extension AutonomosView {
    func autonomosLifecycleChrome<Content: View>(_ content: Content) -> some View {
        autonomosRhythmTask(
            content
                .navigationBarHidden(true)
                .accessibilityIdentifier(A11yID.autonomosScreen)
                .accessibilityLabel(spokenScreenLabel())
                .accessibilityHint(Self.screenHint)
                .task { if case .idle = model.phase { await model.load() } }
                .autonomosSheets(
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
        )
    }
}
