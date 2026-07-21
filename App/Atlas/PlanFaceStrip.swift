import AtlasCore
import SwiftUI

// MARK: - Plan face strip (WAVE-040)

/// Thin exclusive plan progress face under PlanCard header.
struct PlanFaceStrip: View {
    let plan: AtlasExecutionPlan
    let progress: AtlasExecutionPlan.Progress?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var face: PlanProgressFace {
        PlanJudgment.face(plan: plan, progress: progress)
    }

    var body: some View {
        switch face {
        case .absent:
            EmptyView()
        case .pending, .running, .terminal:
            stripChrome
        }
    }

    private var stripChrome: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Circle()
                .fill(dotColor)
                .frame(width: 7, height: 7)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(face.kicker)
                    .font(AtlasFont.mono(9))
                    .tracking(0.7)
                    .foregroundStyle(titleColor)
                Text(PlanJudgment.summaryLine(plan: plan, progress: progress))
                    .font(AtlasFont.serif(12))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(face.spokenFace)
        .accessibilityIdentifier(A11yID.planFace)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: face.productWord)
    }

    private var dotColor: Color {
        switch face {
        case .terminal: return AtlasTheme.domAutonomos
        case .running: return AtlasTheme.accent
        case .pending: return AtlasTheme.textTertiary
        case .absent: return AtlasTheme.textTertiary
        }
    }

    private var titleColor: Color {
        switch face {
        case .terminal: return AtlasTheme.domAutonomos
        case .running: return AtlasTheme.accent
        case .pending, .absent: return AtlasTheme.textTertiary
        }
    }
}
