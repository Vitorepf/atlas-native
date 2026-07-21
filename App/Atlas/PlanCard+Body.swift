import SwiftUI
import AtlasCore

// Plan body stack — peel de PlanCard.

extension PlanCard {
    @ViewBuilder
    func planBody(plan: AtlasExecutionPlan) -> some View {
        planHeader(plan: plan)
        planStepsList(plan: plan)
        if session.auditModeEnabled, isTerminal, let progress = executionProgress {
            auditTerminalLine(plan: plan, progress: progress)
        }
        // C19 / cena 02: "comparar versões" só com planRevisions reais.
        if !meaningfulRevisions.isEmpty {
            revisionToggle(plan: plan)
        }
        planDetailSection(plan: plan)
    }
}
