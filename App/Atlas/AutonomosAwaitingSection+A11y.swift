import Foundation
import AtlasCore

/// Spoken labels — peel de AutonomosAwaitingYouSection (régua ≤100).

extension AutonomosAwaitingYouSection {
    var sectionSpokenLabel: String {
        if decisionCount == 1 {
            return "aguardando você, 1 decisão pendente"
        }
        return "aguardando você, \(decisionCount) decisões pendentes"
    }

    func inboxSpokenLabel(count: Int) -> String {
        count == 1
            ? "abrir 1 decisão de inbox pendente"
            : "abrir \(count) decisões de inbox pendentes"
    }

    func workOrdersSpokenLabel(count: Int) -> String {
        count == 1
            ? "abrir 1 ordem aguardando sua decisão"
            : "abrir \(count) ordens aguardando sua decisão"
    }

    static func decisionCount(in backlog: AtlasAutonomosBacklogResponse?) -> Int {
        guard let backlog else { return 0 }
        return backlog.inboxItems.filter(\.decisionRequired).count
            + backlog.workOrders.filter(\.operatorDecisionRequired).count
    }
}
