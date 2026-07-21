import SwiftUI
import AtlasCore

// Plan card — peel de EditorialTurn+Assistant.

extension EditorialTurn {
    @ViewBuilder
    var assistantPlanCard: some View {
        PlanCard(bubble: bubble)
    }
}
