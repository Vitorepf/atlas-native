import SwiftUI
import AtlasCore

// Findings/budgets detail rows — peel de AutonomosDetailContent.

@MainActor
enum AutonomosDetailContentLedger {
    @ViewBuilder
    static func rows(kind: AutonomosDetailSheet, backlog: AtlasAutonomosBacklogResponse) -> some View {
        switch kind {
        case .findings:
            AutonomosDetailLedgerRows.findings(backlog)
        case .budgets:
            AutonomosDetailLedgerRows.budgets(backlog)
        default:
            EmptyView()
        }
    }
}
