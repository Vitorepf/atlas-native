import SwiftUI
import AtlasCore

// Work orders — peel de AutonomosDetailContent (régua ≤100).
// Inbox → AutonomosDetailWorkRows+Inbox.swift
// Fields → AutonomosDetailWorkRows+OrderFields.swift

enum AutonomosDetailWorkRows {
    @ViewBuilder
    static func workOrders(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        ForEach(backlog.workOrders) { item in
            AutonomosDetailChrome.card(item.title) {
                AutonomosDetailWorkOrderFields.fields(item)
            }
        }
    }

    @ViewBuilder
    static func inbox(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        AutonomosDetailInboxRows.inbox(backlog)
    }
}
