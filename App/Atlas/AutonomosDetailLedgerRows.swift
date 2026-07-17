import SwiftUI
import AtlasCore

// Findings — peel de AutonomosDetailContent (régua ≤100).
// Budgets → AutonomosDetailLedgerRows+Budgets.swift
// Items → AutonomosDetailLedgerRows+Findings.swift

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
        AutonomosDetailLedgerFindings.findingCards(backlog)
    }

    @ViewBuilder
    static func budgets(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        AutonomosDetailLedgerBudgets.budgets(backlog)
    }
}
