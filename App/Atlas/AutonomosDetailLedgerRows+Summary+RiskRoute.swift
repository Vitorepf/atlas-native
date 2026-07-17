import SwiftUI
import AtlasCore

// byRisk/byRoute — peel de AutonomosDetailLedgerRows+Summary.

extension AutonomosDetailLedgerRows {
    @ViewBuilder
    static func findingsSummaryRiskRoute(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
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
