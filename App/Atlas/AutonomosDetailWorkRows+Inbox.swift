import SwiftUI
import AtlasCore

// Inbox cards — peel de AutonomosDetailWorkRows.
// Age → AutonomosDetailWorkRows+InboxAge.swift

enum AutonomosDetailInboxRows {
    @ViewBuilder
    static func inbox(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        ForEach(backlog.inboxItems) { item in
            AutonomosDetailChrome.card(item.title) {
                AutonomosDetailChrome.field("finding", item.findingHash)
                AutonomosDetailChrome.field("route", item.route)
                AutonomosDetailChrome.field("risk", item.riskLevel)
                AutonomosDetailChrome.field("priority", "\(item.priorityScore)")
                AutonomosDetailInboxAge.ageFields(item)
                AutonomosDetailChrome.field("decisão exigida", item.decisionRequired ? "sim" : "não")
                AutonomosDetailChrome.field("opções", item.decisionOptions.joined(separator: " · "))
            }
        }
    }
}
