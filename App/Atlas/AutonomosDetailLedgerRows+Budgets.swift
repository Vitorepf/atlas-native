import SwiftUI
import AtlasCore

// Budgets — peel de AutonomosDetailLedgerRows.

enum AutonomosDetailLedgerBudgets {
    @ViewBuilder
    static func budgets(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
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
