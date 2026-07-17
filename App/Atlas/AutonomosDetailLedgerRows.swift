import SwiftUI
import AtlasCore

// Findings — peel de AutonomosDetailContent (régua ≤100).
// Budgets → AutonomosDetailLedgerRows+Budgets.swift
// Items → AutonomosDetailLedgerRows+Findings.swift
// Summary → AutonomosDetailLedgerRows+Summary.swift

@MainActor
enum AutonomosDetailLedgerRows {
    @ViewBuilder
    static func findings(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        findingsSummary(backlog)
        AutonomosDetailLedgerFindings.findingCards(backlog)
    }

    @ViewBuilder
    static func budgets(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        AutonomosDetailLedgerBudgets.budgets(backlog)
    }
}
