import SwiftUI
import AtlasCore

// Inbox cards — peel de AutonomosDetailWorkRows.
// Age → AutonomosDetailWorkRows+InboxAge.swift
// Core → AutonomosDetailWorkRows+InboxCore.swift
// Decision → AutonomosDetailWorkRows+InboxDecision.swift

@MainActor
enum AutonomosDetailInboxRows {
    @ViewBuilder
    static func inbox(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        ForEach(backlog.inboxItems) { item in
            AutonomosDetailChrome.card(item.title) {
                AutonomosDetailInboxCoreFields.fields(item)
                AutonomosDetailInboxAge.ageFields(item)
                AutonomosDetailInboxDecisionFields.fields(item)
            }
        }
    }
}
