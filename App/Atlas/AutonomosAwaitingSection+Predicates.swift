import SwiftUI
import AtlasCore

// Predicados de decisão — peel de AutonomosAwaitingYouSection.

extension AutonomosAwaitingYouSection {
    var inboxDecisions: [AtlasAutonomosInboxItem] {
        backlog?.inboxItems.filter(\.decisionRequired) ?? []
    }

    var workOrderDecisions: [AtlasAutonomosWorkOrder] {
        backlog?.workOrders.filter(\.operatorDecisionRequired) ?? []
    }

    var decisionCount: Int {
        inboxDecisions.count + workOrderDecisions.count
    }
}
