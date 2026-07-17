import SwiftUI
import AtlasCore

// Dot fill colors — peel de PlanCard+StepRowDot.

extension PlanStepRowView {
    func dotFill(_ s: PlanCard.StepState) -> Color {
        switch s {
        case .done: return AtlasTheme.accent
        case .current: return AtlasTheme.accent
        case .pending: return AtlasTheme.separator
        }
    }
}
