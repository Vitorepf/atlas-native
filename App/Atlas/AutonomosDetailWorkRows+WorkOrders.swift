import SwiftUI
import AtlasCore

// Work orders — peel de AutonomosDetailWorkRows.

@MainActor
enum AutonomosDetailWorkOrders {
    @ViewBuilder
    static func workOrders(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        ForEach(backlog.workOrders) { item in
            AutonomosDetailChrome.card(item.title) {
                AutonomosDetailWorkOrderFields.fields(item)
            }
        }
    }
}
