import SwiftUI
import AtlasCore

// Budgets — peel de AutonomosDetailLedgerRows.
// Fields → AutonomosDetailLedgerRows+BudgetFields.swift

@MainActor
enum AutonomosDetailLedgerBudgets {
    @ViewBuilder
    static func budgets(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        AutonomosDetailChrome.card("Limites públicos") {
            AutonomosDetailLedgerBudgetFields.fields(backlog.budgets)
        }
    }
}
