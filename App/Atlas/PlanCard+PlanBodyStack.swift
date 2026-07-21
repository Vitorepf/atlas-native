import SwiftUI
import AtlasCore

// Plan body stack — peel de PlanCard+PlanGate.

extension PlanCard {
    @ViewBuilder
    func planCardBodyStack(plan: AtlasExecutionPlan) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            planBody(plan: plan)
        }
    }
}
