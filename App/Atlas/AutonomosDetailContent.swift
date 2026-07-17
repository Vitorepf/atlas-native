import SwiftUI
import AtlasCore

// Cards de work orders/inbox/findings/budgets — peel de AutonomosDetailSheet (régua ~120).

enum AutonomosDetailContent {
    @ViewBuilder
    static func rows(kind: AutonomosDetailSheet, backlog: AtlasAutonomosBacklogResponse) -> some View {
        switch kind {
        case .workOrders:
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
        case .inbox:
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
        case .findings:
            AutonomosDetailChrome.card("Resumo") {
                AutonomosDetailChrome.field("total", "\(backlog.findings.total)")
                AutonomosDetailChrome.field("distintos", "\(backlog.findings.distinctTotal)")
                AutonomosDetailChrome.field("retornados", "\(backlog.findings.returned)")
                AutonomosDetailChrome.field("por risco", backlog.findings.byRisk.sorted { $0.key < $1.key }.map { "\($0.key): \($0.value)" }.joined(separator: " · "))
                AutonomosDetailChrome.field("por rota", backlog.findings.byRoute.sorted { $0.key < $1.key }.map { "\($0.key): \($0.value)" }.joined(separator: " · "))
            }
            ForEach(backlog.findings.items) { item in
                AutonomosDetailChrome.card(item.title) {
                    AutonomosDetailChrome.field("hash", item.findingHash)
                    AutonomosDetailChrome.field("source", item.source)
                    AutonomosDetailChrome.field("owner", item.sourceOwner)
                    AutonomosDetailChrome.field("gap", item.gapKind)
                    AutonomosDetailChrome.field("risk", item.riskLevel)
                    AutonomosDetailChrome.field("priority", "\(item.priorityScore)")
                    AutonomosDetailChrome.field("route", item.route)
                    AutonomosDetailChrome.field("count", "\(item.count)")
                    if let createdAt = item.createdAt {
                        AutonomosDetailChrome.field("criado", createdAt)
                        if let date = AtlasTime.date(createdAt) {
                            AutonomosDetailChrome.field("idade", AutonomosChrome.relativeAge(from: date))
                        }
                    }
                    if let rule = item.ruleId { AutonomosDetailChrome.field("rule id", rule) }
                    if let text = item.ruleText { AutonomosDetailChrome.field("rule", text) }
                }
            }
        case .budgets:
            let b = backlog.budgets
            AutonomosDetailChrome.card("Limites públicos") {
                AutonomosDetailChrome.field("dev mode", b.devBudget.mode)
                AutonomosDetailChrome.field("dev work orders", "\(b.devBudget.maxConcurrentWorkOrders)")
                AutonomosDetailChrome.field("forge mode", b.forgeBudget.mode)
                AutonomosDetailChrome.field("forge obras", "\(b.forgeBudget.maxConcurrentObras)")
                AutonomosDetailChrome.field("wip", "\(b.wipUsed)/\(b.wipLimit)")
                AutonomosDetailChrome.field("dev routed", "\(b.devRouted)")
                AutonomosDetailChrome.field("forge routed", "\(b.forgeRouted)")
                AutonomosDetailChrome.field("queued", "\(b.queued)")
                AutonomosDetailChrome.field("budget consumed", b.budgetConsumed ? "sim" : "não")
                AutonomosDetailChrome.field("execution executed", b.executionExecuted ? "sim" : "não")
            }
        }
    }
}
