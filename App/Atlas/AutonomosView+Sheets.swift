import SwiftUI
import AtlasCore

// Folhas do AutonomosView — peel de régua ~160; callbacks idênticos.
// Forward → AutonomosView+Sheets+Forward.swift

extension View {
    func autonomosSheets(
        model: AutonomosModel,
        nightly: NightlyProposalController,
        control: Binding<AtlasAutonomosRunAction?>,
        startRunMode: Binding<AtlasAutonomosStartRunMode?>,
        nightlyStartProposal: Binding<NightlyProposalController.ProposalPayload?>,
        showTransferSheet: Binding<Bool>,
        detailSheet: Binding<AutonomosDetailSheet?>,
        selfConstructionReceipt: Binding<SelfConstructionReceipt?>,
        canRevert: @escaping (SelfConstructionReceipt) -> Bool,
        revertReceipt: @escaping (SelfConstructionReceipt) -> AtlasAutonomosCycleRevertResponse?
    ) -> some View {
        autonomosSheetsForward(
            model: model,
            nightly: nightly,
            control: control,
            startRunMode: startRunMode,
            nightlyStartProposal: nightlyStartProposal,
            showTransferSheet: showTransferSheet,
            detailSheet: detailSheet,
            selfConstructionReceipt: selfConstructionReceipt,
            canRevert: canRevert,
            revertReceipt: revertReceipt
        )
    }
}
