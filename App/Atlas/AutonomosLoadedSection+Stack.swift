import SwiftUI
import AtlasCore

// LazyVStack do corpo Autônomos — peel de AutonomosLoadedSection (régua ≤100).

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStack: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            AutonomosNightlyProposalBlock(nightly: nightly) { nightlyStartProposal = $0 }
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
            runReceiptLines
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
                    .transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: 6)))
            }
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 10).padding(.bottom, 32)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: receiptPhaseID)
    }
}
