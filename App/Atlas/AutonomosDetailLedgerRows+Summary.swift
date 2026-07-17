import SwiftUI
import AtlasCore

// Findings summary fields — peel de AutonomosDetailLedgerRows.

extension AutonomosDetailLedgerRows {
    @ViewBuilder
    static func findingsSummary(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
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
    }
}
