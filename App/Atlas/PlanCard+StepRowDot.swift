import SwiftUI
import AtlasCore

// Dot column — peel de PlanStepRowView.
// Fill → PlanCard+StepRowDotFill.swift

extension PlanStepRowView {
    var stepDotColumn: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle().fill(dotFill(state)).frame(width: 13, height: 13)
                    .opacity(state == .current && pulse && !reduceMotion ? 0.55 : 1)
                if state == .done {
                    Image(systemName: "checkmark").font(.system(size: 7, weight: .bold))
                        .foregroundStyle(AtlasTheme.bg)
                } else if state == .current {
                    Circle().fill(AtlasTheme.bg).frame(width: 5, height: 5)
                }
            }
            .padding(.top, 2)
            if !isLast {
                Rectangle().fill(AtlasTheme.accent.opacity(state == .pending ? 0.15 : 0.35))
                    .frame(width: 1.5).frame(maxHeight: .infinity)
            }
        }
        .frame(width: 13)
        .accessibilityHidden(true)
    }
}
