import SwiftUI
import AtlasCore

/// Modifier das folhas Autônomos — peel de `AutonomosView+Sheets`.
/// Detail/transfer → AutonomosSheetsModifier+Detail.swift
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
        detailSheets(on:
            content
            .sheet(item: $control) { action in
                AutonomosControlSheet(action: action) { actor, reason in
                    Task { await model.control(action, operatorActor: actor, reason: reason) }
                }
            }
            .sheet(item: $startRunMode) { mode in
                AutonomosStartRunSheet(mode: mode) { actor, reason in
                    Task { await model.startRun(mode: mode, operatorActor: actor, operatorReason: reason) }
                }
            }
            .sheet(item: $nightlyStartProposal) { proposal in
                AutonomosReasonSheet(
                    title: "Preparar missão noturna",
                    explainer: "Ensaio (dry-run): a frota recebe a missão proposta e o recibo entra na fila; só o lease confirma execução.",
                    reasonOptional: true,
                    initialReason: proposal.prefilledReason
                ) { actor, reason in
                    Task {
                        let previous = model.lastStartRunReceipt
                        await model.startRun(mode: .dryRun, operatorActor: actor, operatorReason: reason)
                        if model.lastStartRunReceipt != previous,
                           model.lastStartRunReceipt?.isEnqueued == true {
                            await nightly.accept(proposal)
                        }
                    }
                }
            }
        )
    }
}
