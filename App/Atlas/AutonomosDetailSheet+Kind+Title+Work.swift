import SwiftUI
import AtlasCore

/// Work detail titles — peel de AutonomosDetailSheet+Kind+Title.

extension AutonomosDetailSheet {
    var titleWork: String? {
        switch self {
        case .workOrders: return "Work orders"
        case .inbox: return "Inbox"
        default: return nil
        }
    }
}
