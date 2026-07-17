import Foundation
import AtlasCore

/// Decision count helper — peel de AutonomosAwaitingSection+A11y.

extension AutonomosAwaitingYouSection {
    static func decisionCount(in backlog: AtlasAutonomosBacklogResponse?) -> Int {
        guard let backlog else { return 0 }
        return backlog.inboxItems.filter(\.decisionRequired).count
            + backlog.workOrders.filter(\.operatorDecisionRequired).count
    }
}
