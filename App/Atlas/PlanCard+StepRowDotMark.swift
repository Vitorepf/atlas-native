import SwiftUI
import AtlasCore

// Dot mark — peel de PlanCard+StepRowDot.

extension PlanStepRowView {
    @ViewBuilder
    var stepDotMark: some View {
        ZStack {
            Circle().fill(dotFill(state)).frame(width: 13, height: 13)
                .opacity(state == .current && pulse && !reduceMotion ? 0.55 : 1)
            if state == .done {
                Image(systemName: "checkmark").atlasSans(7, .bold)
                    .foregroundStyle(AtlasTheme.bg)
            } else if state == .current {
                Circle().fill(AtlasTheme.bg).frame(width: 5, height: 5)
            }
        }
        .padding(.top, 2)
    }
}
