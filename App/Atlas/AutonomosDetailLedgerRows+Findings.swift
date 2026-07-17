import SwiftUI
import AtlasCore

// Findings items — peel de AutonomosDetailLedgerRows.
// Fields → AutonomosDetailLedgerRows+FindingFields.swift

@MainActor
enum AutonomosDetailLedgerFindings {
    @ViewBuilder
    static func findingCards(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        ForEach(backlog.findings.items) { item in
            AutonomosDetailChrome.card(item.title) {
                findingCardFields(item)
            }
        }
    }
}
