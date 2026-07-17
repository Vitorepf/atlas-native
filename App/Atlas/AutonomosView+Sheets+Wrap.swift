import SwiftUI
import AtlasCore

// Modifier wrap — peel de AutonomosView+Sheets.

extension View {
    func autonomosSheetsModifierWrap(
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
        modifier(AutonomosSheetsModifier(
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
        ))
    }
}
