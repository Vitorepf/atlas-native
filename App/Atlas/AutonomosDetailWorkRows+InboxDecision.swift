import SwiftUI
import AtlasCore

// Decision fields — peel de AutonomosDetailWorkRows+Inbox.

@MainActor
enum AutonomosDetailInboxDecisionFields {
    @ViewBuilder
    static func fields(_ item: AtlasAutonomosInboxItem) -> some View {
        AutonomosDetailChrome.field("decisão exigida", item.decisionRequired ? "sim" : "não")
        AutonomosDetailChrome.field("opções", item.decisionOptions.joined(separator: " · "))
    }
}
