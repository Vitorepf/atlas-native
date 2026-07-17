import SwiftUI
import AtlasCore

// Work order fields — peel de AutonomosDetailWorkRows.

enum AutonomosDetailWorkOrderFields {
    @ViewBuilder
    static func fields(_ item: AtlasAutonomosWorkOrder) -> some View {
        AutonomosDetailChrome.field("id", item.workOrderId)
        AutonomosDetailChrome.field("finding", item.findingHash)
        AutonomosDetailChrome.field("route", item.route)
        AutonomosDetailChrome.field("owner service", item.routesToOwnerService)
        AutonomosDetailChrome.field("risk", item.riskLevel)
        AutonomosDetailChrome.field("priority", "\(item.priorityScore)")
        AutonomosDetailChrome.field("status", item.status)
        if let createdAt = item.createdAt {
            AutonomosDetailChrome.field("criado", createdAt)
            if let date = AtlasTime.date(createdAt) {
                AutonomosDetailChrome.field("idade", AutonomosChrome.relativeAge(from: date))
            }
        }
        AutonomosDetailChrome.field("branch isolation", item.requiresBranchIsolation ? "sim" : "não")
        AutonomosDetailChrome.field("decisão do operador", item.operatorDecisionRequired ? "sim" : "não")
        AutonomosDetailChrome.field("evidência exigida", item.evidenceRequired ? "sim" : "não")
        AutonomosDetailChrome.field("execução feita", item.executionExecuted ? "sim" : "não")
    }
}
