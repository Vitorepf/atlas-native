import SwiftUI
import AtlasCore

// Inbox cards — peel de AutonomosDetailWorkRows.

enum AutonomosDetailInboxRows {
    @ViewBuilder
    static func inbox(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        ForEach(backlog.inboxItems) { item in
            AutonomosDetailChrome.card(item.title) {
                AutonomosDetailChrome.field("finding", item.findingHash)
                AutonomosDetailChrome.field("route", item.route)
                AutonomosDetailChrome.field("risk", item.riskLevel)
                AutonomosDetailChrome.field("priority", "\(item.priorityScore)")
                if let createdAt = item.createdAt {
                    AutonomosDetailChrome.field("criado", createdAt)
                    if let date = AtlasTime.date(createdAt) {
                        AutonomosDetailChrome.field("idade", AutonomosChrome.relativeAge(from: date))
                    }
                }
                AutonomosDetailChrome.field("decisão exigida", item.decisionRequired ? "sim" : "não")
                AutonomosDetailChrome.field("opções", item.decisionOptions.joined(separator: " · "))
            }
        }
    }
}
