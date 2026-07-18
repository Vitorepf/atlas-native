import SwiftUI
import AtlasCore

// Work order fields — peel de AutonomosDetailWorkRows.

@MainActor
enum AutonomosDetailWorkOrderFields {
    @ViewBuilder
    static func fields(_ item: AtlasAutonomosWorkOrder) -> some View {
        AutonomosDetailChrome.field("id", item.workOrderId)
        AutonomosDetailChrome.field("finding", item.findingHash)
        AutonomosDetailChrome.field("route", item.route)
        if let ownerService = item.routesToOwnerService {
            AutonomosDetailChrome.field("owner service", ownerService)
        }
        AutonomosDetailChrome.field("risk", item.riskLevel)
        AutonomosDetailChrome.field("priority", "\(item.priorityScore)")
        AutonomosDetailChrome.field("status", item.status)
        if let createdAt = item.createdAt {
            AutonomosDetailChrome.field("criado", createdAt)
            if let date = AtlasTime.date(createdAt) {
                AutonomosDetailChrome.field("idade", AutonomosChrome.relativeAge(from: date))
            }
        }
        orderFieldFlags(item)
    }
}
