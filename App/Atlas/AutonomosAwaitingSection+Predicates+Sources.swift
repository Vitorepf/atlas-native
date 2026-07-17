import SwiftUI
import AtlasCore

// Decision sources — peel de AutonomosAwaitingSection+Predicates.

extension AutonomosAwaitingYouSection {
    var inboxDecisions: [AtlasAutonomosInboxItem] {
        backlog?.inboxItems.filter(\.decisionRequired) ?? []
    }

    var workOrderDecisions: [AtlasAutonomosWorkOrder] {
        backlog?.workOrders.filter(\.operatorDecisionRequired) ?? []
    }
}
