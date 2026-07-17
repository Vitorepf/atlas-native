import SwiftUI
import AtlasCore

// Cards de work orders/inbox/findings/budgets — peel de AutonomosDetailSheet.
// Work/inbox → AutonomosDetailWorkRows · Findings/budgets → AutonomosDetailLedgerRows

enum AutonomosDetailContent {
    @ViewBuilder
    static func rows(kind: AutonomosDetailSheet, backlog: AtlasAutonomosBacklogResponse) -> some View {
        switch kind {
        case .workOrders:
            AutonomosDetailWorkRows.workOrders(backlog)
        case .inbox:
            AutonomosDetailWorkRows.inbox(backlog)
        case .findings:
            AutonomosDetailLedgerRows.findings(backlog)
        case .budgets:
            AutonomosDetailLedgerRows.budgets(backlog)
        }
    }
}
