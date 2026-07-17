import Foundation
import AtlasCore

// Work backlog counts — peel de AutonomosDetailSheet+A11yCount.

extension AutonomosPublicDetailSheet {
    static func publicWorkCount(kind: AutonomosDetailSheet, backlog: AtlasAutonomosBacklogResponse) -> Int? {
        switch kind {
        case .workOrders: return backlog.workOrders.count
        case .inbox: return backlog.inboxItems.count
        default: return nil
        }
    }
}
