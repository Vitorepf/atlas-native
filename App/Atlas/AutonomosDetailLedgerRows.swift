import SwiftUI
import AtlasCore

// Findings — peel de AutonomosDetailContent (régua ≤100).
// Budgets → AutonomosDetailLedgerRows+Budgets.swift

enum AutonomosDetailLedgerRows {
    @ViewBuilder
    static func findings(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        AutonomosDetailChrome.card("Resumo") {
            AutonomosDetailChrome.field("total", "\(backlog.findings.total)")
            AutonomosDetailChrome.field("distintos", "\(backlog.findings.distinctTotal)")
            AutonomosDetailChrome.field("retornados", "\(backlog.findings.returned)")
            AutonomosDetailChrome.field(
                "por risco",
                backlog.findings.byRisk.sorted { $0.key < $1.key }.map { "\($0.key): \($0.value)" }.joined(separator: " · ")
            )
            AutonomosDetailChrome.field(
                "por rota",
                backlog.findings.byRoute.sorted { $0.key < $1.key }.map { "\($0.key): \($0.value)" }.joined(separator: " · ")
            )
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
    }

    @ViewBuilder
    static func budgets(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        AutonomosDetailLedgerBudgets.budgets(backlog)
    }
}
