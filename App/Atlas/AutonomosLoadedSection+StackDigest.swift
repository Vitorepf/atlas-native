import SwiftUI
import AtlasCore

// Digest section in stack — peel de AutonomosLoadedSection+StackHead.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackDigest: some View {
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
