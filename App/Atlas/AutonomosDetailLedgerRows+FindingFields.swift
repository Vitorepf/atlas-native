import SwiftUI
import AtlasCore

// Finding card fields — peel de AutonomosDetailLedgerRows+Findings.

extension AutonomosDetailLedgerFindings {
    @ViewBuilder
    static func findingCardFields(_ item: AtlasAutonomosFinding) -> some View {
        AutonomosDetailChrome.field("hash", item.findingHash)
        AutonomosDetailChrome.field("source", item.source)
        AutonomosDetailChrome.field("owner", item.sourceOwner)
        AutonomosDetailChrome.field("gap", item.gapKind)
        AutonomosDetailChrome.field("risk", item.riskLevel)
        AutonomosDetailChrome.field("priority", "\(item.priorityScore)")
        AutonomosDetailChrome.field("route", item.route)
        AutonomosDetailChrome.field("count", "\(item.count)")
        if let createdAt = item.createdAt {
            AutonomosDetailChrome.field("criado", createdAt)
            if let date = AtlasTime.date(createdAt) {
                AutonomosDetailChrome.field("idade", AutonomosChrome.relativeAge(from: date))
            }
        }
        if let rule = item.ruleId { AutonomosDetailChrome.field("rule id", rule) }
        if let text = item.ruleText { AutonomosDetailChrome.field("rule", text) }
    }
}
