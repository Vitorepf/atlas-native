import SwiftUI
import AtlasCore

// Modifier init — peel de AutonomosView+Sheets+Wrap.

extension View {
    func autonomosSheetsModifierInit(
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
