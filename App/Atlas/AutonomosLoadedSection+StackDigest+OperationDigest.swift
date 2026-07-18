import SwiftUI
import AtlasCore

// Operation digest — peel de AutonomosLoadedSection+StackDigest.

extension AutonomosLoadedSection {
    @ViewBuilder
    var loadedStackOperationDigest: some View {
        let incidentPresent = model.taskHealth?.incidents.present == true
        AutonomosDigestToggleLine(
            title: "operação",
            detail: "\(model.delivered?.deliveredTotal ?? 0) entregues · \(model.backlog?.workOrders.count ?? 0) na fila",
            expanded: $operationDigestExpanded,
            a11yID: A11yID.autonomosOperationToggle
        )
        // Por exceção: incidente na fila fura o colapso — exceção grita sempre.
        if operationDigestExpanded || incidentPresent {
            AutonomosOperationDigestSection(
                deliveredTotal: model.delivered?.deliveredTotal ?? 0,
                pendingCount: model.backlog?.workOrders.count ?? 0,
                inboxCount: model.backlog?.inboxItems.count ?? 0,
                incidentPresent: incidentPresent,
                oldestBacklogCreatedAt: oldestBacklogCreatedAt,
                findingsByRisk: model.backlog?.findings.byRisk ?? [:]
            )
        }
    }
}
