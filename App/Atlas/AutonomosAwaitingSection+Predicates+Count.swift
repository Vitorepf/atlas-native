import SwiftUI
import AtlasCore

// Decision count — peel de AutonomosAwaitingSection+Predicates.

extension AutonomosAwaitingYouSection {
    var decisionCount: Int {
        inboxDecisions.count + workOrderDecisions.count
    }
}
