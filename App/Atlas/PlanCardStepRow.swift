import AtlasCore
import SwiftUI

// IDLE-COMPRESS peel PlanStepRowView from PlanCard (canon §7 · same domain)

extension PlanStepRowView {
    var stepRowBody: some View {
        applyStepPulse(
            stepRowA11yChrome(stepRowLayout)
        )
    }
}

extension PlanStepRowView {
    func stepRowA11yChrome<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenLabel)
            .accessibilityAddTraits(state == .current ? .isSelected : [])
            .accessibilityIdentifier(A11yID.planStep(index))
    }
}

// MARK: - Step row

struct PlanStepRowView: View {
    let step: AtlasExecutionPlan.Step
    let index: Int
    let total: Int
    let state: PlanStepState
    let isLast: Bool
    let spokenLabel: String
    let reduceMotion: Bool
    @State var pulse = false

    var body: some View {
        stepRowBody
    }
}

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

extension PlanStepRowView {
    func dotFill(_ s: PlanStepState) -> Color {
        switch s {
        case .done: return AtlasTheme.accent
        case .current: return AtlasTheme.accent
        case .pending: return AtlasTheme.separator
        }
    }
}

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

extension PlanStepRowView {
    @ViewBuilder
    var stepDotSpine: some View {
        if !isLast {
            Rectangle().fill(AtlasTheme.accent.opacity(state == .pending ? 0.15 : 0.35))
                .frame(width: 1.5).frame(maxHeight: .infinity)
        }
    }
}

extension PlanStepRowView {
    var stepRowLayout: some View {
        HStack(alignment: .top, spacing: 10) {
            stepDotColumn
            stepTitleColumn
            Spacer(minLength: 0)
        }
    }
}

extension PlanStepRowView {
    func applyStepPulse<Content: View>(_ content: Content) -> some View {
        content
            .onAppear {
                if state == .current && !reduceMotion {
                    withAnimation(AtlasMotion.breath(0.9)) { pulse = true }
                }
            }
            .onChange(of: state == .current) { _, now in if !now { pulse = false } }
    }
}

extension PlanStepRowView {
    var stepTitleColumn: some View {
        Text(step.title)
            .font(.system(.caption))
            .foregroundStyle(state == .pending ? AtlasTheme.textTertiary
                             : state == .current ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
            .lineLimit(2)
            .accessibilityHidden(true)
            .padding(.bottom, isLast ? 0 : 9)
    }
}
