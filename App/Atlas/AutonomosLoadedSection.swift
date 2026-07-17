import SwiftUI
import AtlasCore

/// Corpo carregado da área Autônomos — scroll com frota, digest, área e histórico.
struct AutonomosLoadedSection: View {
    let model: AutonomosModel
    let auditModeEnabled: Bool
    let nightly: NightlyProposalController
    let rhythmSampleDays: Int?
    let oldestBacklogCreatedAt: Date?
    @Binding var nightlyStartProposal: NightlyProposalController.ProposalPayload?
    @Binding var control: AtlasAutonomosRunAction?
    @Binding var startRunMode: AtlasAutonomosStartRunMode?
    @Binding var showTransferSheet: Bool
    @Binding var detailSheet: AutonomosDetailSheet?
    @Binding var selfConstructionReceipt: SelfConstructionReceipt?
    let onRefreshRhythm: () async -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                AutonomosNightlyProposalBlock(nightly: nightly) { nightlyStartProposal = $0 }
                    .animation(
                        reduceMotion ? nil : AtlasMotion.editorial,
                        value: nightly.pendingProposal?.id
                    )
                AutonomosRhythmLearningLine(sampleDays: rhythmSampleDays)
                if let fleet = model.fleet {
                    AutonomosFleetSummary(
                        fleet: fleet,
                        incidentPresent: model.taskHealth?.incidents.present == true
                    )
                }
                if let digest = model.digest {
                    AutonomosNextDigestSection(digest: digest)
                }
                AutonomosOperationDigestSection(
                    deliveredTotal: model.delivered?.deliveredTotal ?? 0,
                    pendingCount: model.backlog?.workOrders.count ?? 0,
                    inboxCount: model.backlog?.inboxItems.count ?? 0,
                    incidentPresent: model.taskHealth?.incidents.present == true,
                    oldestBacklogCreatedAt: oldestBacklogCreatedAt,
                    findingsByRisk: model.backlog?.findings.byRisk ?? [:]
                )
                AutonomosAwaitingYouSection(backlog: model.backlog) { detailSheet = $0 }
                    .animation(
                        reduceMotion ? nil : AtlasMotion.editorial,
                        value: AutonomosAwaitingYouSection.decisionCount(in: model.backlog)
                    )
                AutonomosAreaPicker(
                    areas: model.areas,
                    selectedAreaID: model.selectedAreaID
                ) { id in
                    Task { await model.selectArea(id) }
                }
                if let area = model.selectedArea {
                    AutonomosAreaDetailSection(
                        area: area,
                        model: model,
                        control: $control,
                        startRunMode: $startRunMode,
                        showTransferSheet: $showTransferSheet,
                        onOpenDetail: { detailSheet = $0 },
                        onSelfConstructionReceipt: { selfConstructionReceipt = $0 }
                    )
                }
                if let receipt = model.lastStartRunReceipt, receipt.isEnqueued {
                    AutonomosInfoLine("Novo ciclo NA FILA — ainda não iniciado. A execução só é real quando o lease aparecer no vivo.")
                }
                if let transfer = model.lastTransferReceipt {
                    AutonomosTransferStatus(transfer: transfer) {
                        Task { await model.refreshTransferStatus() }
                    }
                }
                if let receipt = model.lastControlReceipt {
                    AutonomosControlReceiptLine(receipt: receipt)
                }
                if let fleet = model.fleet {
                    AutonomosFleetSection(
                        fleet: fleet,
                        incidentPresent: model.taskHealth?.incidents.present == true,
                        auditModeEnabled: auditModeEnabled
                    )
                }
                if let health = model.taskHealth {
                    AutonomosTaskHealthSection(health: health)
                }
                if let history = model.fleetHistory {
                    AutonomosFleetHistorySection(history: history)
                }
                if let error = model.controlError {
                    AutonomosErrorCard(message: error)
                }
            }
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 10).padding(.bottom, 32)
        }
        .refreshable {
            await model.load()
            await onRefreshRhythm()
        }
        .scrollIndicators(.hidden)
    }
}
