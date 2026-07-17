import SwiftUI
import AtlasCore

// Risk/meta fields — peel de AutonomosDetailLedgerRows+FindingFields.

extension AutonomosDetailLedgerFindings {
    @ViewBuilder
    static func findingRiskMetaFields(_ item: AtlasAutonomosFinding) -> some View {
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
