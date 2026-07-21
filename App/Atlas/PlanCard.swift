import AtlasCore
import SwiftUI

// IDLE-COMPRESS PlanCard host + peels RevisionBody/StepRow (canon §7)

// WAVE-105: spoken → PlanJudgment only (shims deleted)

extension PlanCard {
    @ViewBuilder
    func planBody(plan: AtlasExecutionPlan) -> some View {
        planHeader(plan: plan)
        PlanFaceStrip(plan: plan, progress: executionProgress)
        planStepsList(plan: plan)
        if session.auditModeEnabled, isTerminal, let progress = executionProgress {
            auditTerminalLine(plan: plan, progress: progress)
        }
        if !meaningfulRevisions.isEmpty {
            revisionToggle(plan: plan)
        }
        planDetailSection(plan: plan)
    }
}

extension PlanCard {
    func planCardChrome<Content: View>(plan: AtlasExecutionPlan, @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(12)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control, fillOpacity: 0.5)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(PlanJudgment.spokenCard(plan: plan, progress: executionProgress))
            .accessibilityIdentifier(A11yID.planCard)
    }
}

extension PlanCard {
    func planHeader(plan: AtlasExecutionPlan) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "list.bullet.rectangle")
                .atlasSans(12).foregroundStyle(AtlasTheme.accent.opacity(0.85))
                .accessibilityHidden(true)
            Text(plan.title)
                .font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(plan.title)
            Spacer(minLength: 0)
            if let progress = bubble.executionProgress {
                planHeaderProgress(progress)
            }
        }
        .accessibilityElement(children: .contain)
    }
}

extension PlanCard {
    @ViewBuilder
    func planHeaderProgress(_ progress: AtlasExecutionPlan.Progress) -> some View {
        Text(PlanJudgment.progressBadge(progress))
            .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
            .accessibilityLabel(PlanJudgment.spokenProgressBadge(progress))
            .accessibilityIdentifier(A11yID.planProgress)
    }
}

extension PlanCard {
    @ViewBuilder
    func planCardBodyStack(plan: AtlasExecutionPlan) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            planBody(plan: plan)
        }
    }
}


// MARK: - Types / Inputs

struct PlanCard: View {
    let bubble: ChatBubble
    @Environment(AtlasSession.self) var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var showDetail = false
    @State var showRevisions = false

    // MARK: Body

    var body: some View {
        planCardGate
    }
}

// MARK: - Audit section

extension PlanCard {
    func auditTerminalLine(
        plan: AtlasExecutionPlan,
        progress: AtlasExecutionPlan.Progress
    ) -> some View {
        auditTerminalCopy(plan: plan, progress: progress)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(PlanJudgment.spokenAuditTerminal(plan: plan, progress: progress))
            .accessibilityAddTraits(.isStaticText)
    }
}

extension PlanCard {
    var auditCaption: some View {
        Text("AUDITORIA")
            .font(AtlasFont.mono(9))
            .tracking(0.8)
            .foregroundStyle(AtlasTheme.domOperacional)
            .accessibilityHidden(true)
    }
}

extension PlanCard {
    @ViewBuilder
    func auditProgressLine(
        plan: AtlasExecutionPlan,
        progress: AtlasExecutionPlan.Progress
    ) -> some View {
        Text("planejado \(plan.steps.count) · executado \(min(progress.current, progress.total))/\(progress.total)")
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textTertiary)
            .monospacedDigit()
            .accessibilityHidden(true)
    }
}

extension PlanCard {
    func auditTerminalCopy(
        plan: AtlasExecutionPlan,
        progress: AtlasExecutionPlan.Progress
    ) -> some View {
        HStack(spacing: 6) {
            auditCaption
            auditProgressLine(plan: plan, progress: progress)
            Spacer(minLength: 0)
            auditStatusWord(progress: progress)
        }
        .padding(.top, 2)
    }
}

extension PlanCard {
    func auditStatusWord(progress: AtlasExecutionPlan.Progress) -> some View {
        Text(progress.isTerminal ? "terminal" : "em curso")
            .font(AtlasFont.mono(9))
            .foregroundStyle(progress.isTerminal ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}

extension PlanCard {
    func chipRow(label: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased()).font(AtlasFont.mono(9)).tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            PlanFlowChips(items: items)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(PlanJudgment.spokenChipRow(label: label, items: items))
    }
}

extension PlanCard {
    @ViewBuilder
    func planAgentsChips(_ plan: AtlasExecutionPlan) -> some View {
        if !plan.agents.isEmpty {
            chipRow(label: "agentes", items: plan.agents.map(\.title))
        }
    }
}

extension PlanCard {
    @ViewBuilder
    func planGatesChips(_ plan: AtlasExecutionPlan) -> some View {
        if !plan.qualityGates.isEmpty {
            chipRow(label: "gates", items: plan.qualityGates.map(\.label))
        }
    }
}

