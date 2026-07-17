import SwiftUI
import AtlasCore

// Work orders — peel de AutonomosDetailContent (régua ≤100).
// Orders → AutonomosDetailWorkRows+WorkOrders.swift
// Inbox → AutonomosDetailWorkRows+Inbox.swift
// Fields → AutonomosDetailWorkRows+OrderFields.swift

@MainActor
enum AutonomosDetailWorkRows {
    @ViewBuilder
    static func workOrders(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        AutonomosDetailWorkOrders.workOrders(backlog)
    }

    @ViewBuilder
    static func inbox(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        AutonomosDetailInboxRows.inbox(backlog)
    }
}
