import SwiftUI
import AtlasCore

/// Modifier das folhas Autônomos — peel de `AutonomosView+Sheets`.
/// Detail/transfer → AutonomosSheetsModifier+Detail.swift
/// Nightly → AutonomosSheetsModifier+Nightly.swift
/// Control → AutonomosSheetsModifier+Control.swift
/// BodyChain → AutonomosSheetsModifier+BodyChain.swift
struct AutonomosSheetsModifier: ViewModifier {
    @Bindable var model: AutonomosModel
    let nightly: NightlyProposalController
    @Binding var control: AtlasAutonomosRunAction?
    @Binding var startRunMode: AtlasAutonomosStartRunMode?
    @Binding var nightlyStartProposal: NightlyProposalController.ProposalPayload?
    @Binding var showTransferSheet: Bool
    @Binding var detailSheet: AutonomosDetailSheet?
    @Binding var selfConstructionReceipt: SelfConstructionReceipt?
    let canRevert: (SelfConstructionReceipt) -> Bool
    let revertReceipt: (SelfConstructionReceipt) -> AtlasAutonomosCycleRevertResponse?

    func body(content: Content) -> some View {
        autonomosSheetsBody(on: content)
    }
}
