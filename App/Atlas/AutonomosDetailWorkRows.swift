import SwiftUI
import AtlasCore

// Work orders + inbox cards — peel de AutonomosDetailContent (régua ≤100).

enum AutonomosDetailWorkRows {
    @ViewBuilder
    static func workOrders(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        ForEach(backlog.workOrders) { item in
            AutonomosDetailChrome.card(item.title) {
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
    }

    @ViewBuilder
    static func inbox(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        ForEach(backlog.inboxItems) { item in
            AutonomosDetailChrome.card(item.title) {
                AutonomosDetailChrome.field("finding", item.findingHash)
                AutonomosDetailChrome.field("route", item.route)
                AutonomosDetailChrome.field("risk", item.riskLevel)
                AutonomosDetailChrome.field("priority", "\(item.priorityScore)")
                if let createdAt = item.createdAt {
                    AutonomosDetailChrome.field("criado", createdAt)
                    if let date = AtlasTime.date(createdAt) {
                        AutonomosDetailChrome.field("idade", AutonomosChrome.relativeAge(from: date))
                    }
                }
                AutonomosDetailChrome.field("decisão exigida", item.decisionRequired ? "sim" : "não")
                AutonomosDetailChrome.field("opções", item.decisionOptions.joined(separator: " · "))
            }
        }
    }
}
