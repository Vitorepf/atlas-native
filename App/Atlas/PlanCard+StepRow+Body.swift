import WidgetKit
import SwiftUI
import AtlasCore

// Step row body — peel de PlanCard+StepRow.

extension PlanStepRowView {
    var stepRowBody: some View {
        applyStepPulse(
            stepRowA11yChrome(stepRowLayout)
        )
    }
}
