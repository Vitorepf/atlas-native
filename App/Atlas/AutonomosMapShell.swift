import SwiftUI
import AtlasCore

/// Shell Autônomos v9 — host (routes/ask/catalog/actions peels). Catálogo → hub · pílula · Novo.
/// WAVE-156 density peel — host sheets + route face.
struct AutonomosMapShell: View {
    @Environment(AtlasSession.self) var session
    let model: AutonomosModel
    @Binding var destination: AutonomosDestination?
    @Binding var selectedUnitID: String?
    @Binding var showNewSheet: Bool
    @State var showingAsk = false
    @State var askThreadId: ThreadID?
    @State var confirmEnd = false
    @State var selfConstructionReceipt: SelfConstructionReceipt?
    @State var nightly = NightlyProposalController.shared
    @State var nightlyStartProposal: NightlyProposalController.ProposalPayload?
    @State var pendingRunControl: AutonomosRunControlAction?
    @State var showTransferSheet = false
    /// WAVE-065: multi-area bind chooser when N registered and unbound.
    @State var showAreaBindChooser = false

    var selectedUnit: AutonomosUnit? {
        guard let selectedUnitID else { return nil }
        return model.operatorUnit(id: selectedUnitID)
    }

    /// Mesma resolve do hub — ask e hub nunca divergem (WAVE-007).
    var organismVestment: AutonomosHubVestment {
        // WAVE-036: incidentPresent from published taskHealth (never invent).
        AutonomosHubVestment.resolve(
            backlog: model.backlog,
            live: model.live,
            incidentPresent: AutonomosTaskHealthJudgment.incidentPresent(model.taskHealth),
            unitPaused: selectedUnit?.paused ?? false
        )
    }

    var vestmentForAsk: AutonomosHubVestment { organismVestment }

    /// Só ciclos com merge real — nunca fabrica “melhorou”.
    var latestMergeProvedReceipt: SelfConstructionReceipt? {
        guard let cycles = model.delivered?.delivered else { return nil }
        guard let cycle = cycles.first(where: { $0.mergePerformed && !$0.mergeHash.isEmpty }) else {
            return nil
        }
        return SelfConstructionReceipt(cycle: cycle, finding: nil)
    }

    var body: some View {
        Group {
            if let destination {
                route(destination)
            } else {
                catalogFace
            }
        }
        .sheet(isPresented: $showNewSheet) {
            AutonomosNewSheet(
                onCreate: { name, charter in
                    let unit = model.createOperatorUnit(name: name, charter: charter)
                    showNewSheet = false
                    selectedUnitID = unit.id
                    destination = .hub
                },
                onCancel: { showNewSheet = false }
            )
        }
        .sheet(item: $selfConstructionReceipt) { receipt in
            // WAVE-033: wire veto-with-receipt when merge-proved + area controllable.
            SelfConstructionReceiptSheet(
                receipt: receipt,
                canRevert: SelfConstructionVetoJudgment.canRevert(
                    receipt: receipt,
                    canControlSelectedArea: model.canControlSelectedArea
                ),
                revertReceipt: model.lastRevertReceipt,
                controlError: model.controlError,
                onRevert: { actor, reason in
                    Task {
                        await model.revertCycle(
                            cycle: SelfConstructionVetoJudgment.cycleKey(for: receipt),
                            operatorActor: actor,
                            reason: reason
                        )
                    }
                }
            )
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
        .confirmationDialog("Encerrar este Autônomo?", isPresented: $confirmEnd, titleVisibility: .visible) {
            Button("Encerrar de vez", role: .destructive) { deleteSelected() }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Sai da sua lista. O motor no servidor ainda não liga a isto.")
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            askPillDock
        }
        .sheet(isPresented: $showingAsk) {
            askConversationSheet
        }
        .onAppear {
            #if DEBUG
            nightly.installDemoIfRequested()
            #endif
        }
        .task {
            await bindAreaIfNeeded()
        }
        .sheet(item: $pendingRunControl) { action in
            AutonomosReasonSheet(
                title: action.reasonSheetTitle,
                explainer: action.explainer,
                reasonOptional: action.reasonOptional
            ) { actor, reason in
                Task { await applyRunControl(action, actor: actor, reason: reason) }
            }
        }
        .sheet(isPresented: $showTransferSheet) {
            // WAVE-035: mission transfer handoff (server chooses target worker).
            AutonomosReasonSheet(
                title: AutonomosTransferJudgment.reasonTitle,
                explainer: AutonomosTransferJudgment.reasonExplainer,
                reasonOptional: false
            ) { actor, reason in
                Task {
                    await model.transfer(operatorActor: actor, reason: reason)
                    await model.refreshTransferStatus()
                }
            }
        }
        .sheet(isPresented: $showAreaBindChooser) {
            // WAVE-065: thin registered-area chooser (no monólito picker).
            AutonomosAreaBindChooser(
                areas: model.areas,
                onSelect: { id in
                    showAreaBindChooser = false
                    Task { await model.selectArea(id) }
                },
                onCancel: { showAreaBindChooser = false }
            )
        }
    }
}
