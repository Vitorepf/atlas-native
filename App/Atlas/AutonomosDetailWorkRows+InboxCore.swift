import SwiftUI
import AtlasCore

// Core fields do inbox card — peel de AutonomosDetailWorkRows+Inbox.

@MainActor
enum AutonomosDetailInboxCoreFields {
    @ViewBuilder
    static func fields(_ item: AtlasAutonomosInboxItem) -> some View {
        AutonomosDetailChrome.field("finding", item.findingHash)
        AutonomosDetailChrome.field("route", item.route)
        AutonomosDetailChrome.field("risk", item.riskLevel)
        AutonomosDetailChrome.field("priority", "\(item.priorityScore)")
    }
}
