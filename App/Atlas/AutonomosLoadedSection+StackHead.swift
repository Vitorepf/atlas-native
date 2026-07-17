import SwiftUI
import AtlasCore

// Cabeça do stack Autônomos (nightly→digest) — peel de AutonomosLoadedSection+Stack.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackHead: some View {
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
    }
}
