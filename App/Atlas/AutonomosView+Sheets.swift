import SwiftUI
import AtlasCore

// Folhas do AutonomosView — peel de régua ~160; callbacks idênticos.

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

private struct AutonomosSheetsModifier: ViewModifier {
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
            .sheet(isPresented: $showTransferSheet) {
                AutonomosTransferSheet(
                    areaName: model.selectedArea?.areaName ?? "",
                    focus: model.selectedArea?.focus ?? "",
                    placement: model.live?.runtimePlacement
                ) { actor, reason in
                    Task { await model.transfer(operatorActor: actor, reason: reason) }
                }
            }
            .sheet(item: $detailSheet) { sheet in
                AutonomosPublicDetailSheet(kind: sheet, backlog: model.backlog)
            }
            .sheet(item: $selfConstructionReceipt) { receipt in
                SelfConstructionReceiptSheet(
                    receipt: receipt,
                    canRevert: canRevert(receipt),
                    revertReceipt: revertReceipt(receipt)
                ) { actor, reason in
                    Task {
                        await model.revertCycle(
                            cycle: String(receipt.cycle.cycleIndex),
                            operatorActor: actor,
                            reason: reason
                        )
                    }
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
    }
}

/// Proposta noturna + linha de ritmo — compartilhado entre idle/loading/failed.
struct AutonomosPreludeBlocks: View {
    let nightly: NightlyProposalController
    let rhythmSampleDays: Int?
    let onAcceptProposal: (NightlyProposalController.ProposalPayload) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        AutonomosNightlyProposalBlock(nightly: nightly, onAccept: onAcceptProposal)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 10)
            .animation(
                reduceMotion ? nil : AtlasMotion.editorial,
                value: nightly.pendingProposal?.id
            )
        AutonomosRhythmLearningLine(sampleDays: rhythmSampleDays)
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 10)
    }
}
