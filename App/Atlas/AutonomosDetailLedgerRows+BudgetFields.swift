import SwiftUI
import AtlasCore

// Budget fields — peel de AutonomosDetailLedgerRows+Budgets.

@MainActor
enum AutonomosDetailLedgerBudgetFields {
    @ViewBuilder
    static func fields(_ b: AtlasAutonomosBacklogBudgets) -> some View {
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
