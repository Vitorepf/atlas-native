import SwiftUI
import AtlasCore

// Plan gate — peel de PlanCard.

extension PlanCard {
    @ViewBuilder
    var planCardGate: some View {
        if let plan, !plan.steps.isEmpty {
            planCardChrome(plan: plan) {
                VStack(alignment: .leading, spacing: 9) {
                    planBody(plan: plan)
                }
            }
        }
    }
}
