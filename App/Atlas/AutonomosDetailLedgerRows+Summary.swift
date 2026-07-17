import SwiftUI
import AtlasCore

// Findings summary fields — peel de AutonomosDetailLedgerRows.
// RiskRoute → AutonomosDetailLedgerRows+Summary+RiskRoute.swift

extension AutonomosDetailLedgerRows {
    @ViewBuilder
    static func findingsSummary(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        AutonomosDetailChrome.card("Resumo") {
            AutonomosDetailChrome.field("total", "\(backlog.findings.total)")
            AutonomosDetailChrome.field("distintos", "\(backlog.findings.distinctTotal)")
            AutonomosDetailChrome.field("retornados", "\(backlog.findings.returned)")
            findingsSummaryRiskRoute(backlog)
        }
    }
}
