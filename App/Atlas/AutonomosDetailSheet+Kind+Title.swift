import SwiftUI
import AtlasCore

/// Detail sheet titles — peel de AutonomosDetailSheet+Kind.

extension AutonomosDetailSheet {
    var title: String {
        switch self {
        case .workOrders: return "Work orders"
        case .inbox: return "Inbox"
        case .budgets: return "Budgets"
        case .findings: return "Findings"
        }
    }
}
