import SwiftUI
import AtlasCore

// Operation digest — peel de AutonomosLoadedSection+StackDigest.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackOperationDigest: some View {
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
