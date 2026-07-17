import Foundation
import AtlasCore

// Counts — peel de AutonomosPublicDetailSheet a11y.

extension AutonomosPublicDetailSheet {
    static func publicItemCount(kind: AutonomosDetailSheet, backlog: AtlasAutonomosBacklogResponse) -> Int {
        switch kind {
        case .workOrders: return backlog.workOrders.count
        case .inbox: return backlog.inboxItems.count
        case .findings: return backlog.findings.items.count
        case .budgets: return 1
        }
    }
}
