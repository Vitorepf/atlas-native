import SwiftUI
import AtlasCore

// Work/inbox detail rows — peel de AutonomosDetailContent.

@MainActor
enum AutonomosDetailContentWork {
    @ViewBuilder
    static func rows(kind: AutonomosDetailSheet, backlog: AtlasAutonomosBacklogResponse) -> some View {
        switch kind {
        case .workOrders:
            AutonomosDetailWorkRows.workOrders(backlog)
        case .inbox:
            AutonomosDetailWorkRows.inbox(backlog)
        default:
            EmptyView()
        }
    }
}
