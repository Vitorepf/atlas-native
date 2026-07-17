import SwiftUI
import AtlasCore

/// Detail sheet titles — peel de AutonomosDetailSheet+Kind.
/// Work → AutonomosDetailSheet+Kind+Title+Work.swift

extension AutonomosDetailSheet {
    var title: String {
        if let work = titleWork { return work }
        switch self {
        case .budgets: return "Budgets"
        case .findings: return "Findings"
        default: return "Work orders"
        }
    }
}
