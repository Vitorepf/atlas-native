import SwiftUI
import AtlasCore

/// Kind enum da folha pública Autônomos — peel de AutonomosDetailSheet.

enum AutonomosDetailSheet: String, Identifiable {
    case workOrders
    case inbox
    case budgets
    case findings

    var id: String { rawValue }
    var title: String {
        switch self {
        case .workOrders: return "Work orders"
        case .inbox: return "Inbox"
        case .budgets: return "Budgets"
        case .findings: return "Findings"
        }
    }
}
