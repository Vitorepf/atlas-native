import SwiftUI
import AtlasCore

// Dot column — peel de PlanStepRowView.
// Fill → PlanCard+StepRowDotFill.swift
// Spine → PlanCard+StepRowDotSpine.swift

extension PlanStepRowView {
    var stepDotColumn: some View {
        VStack(spacing: 0) {
            stepDotMark
            stepDotSpine
        }
        .frame(width: 13)
        .accessibilityHidden(true)
    }
}
