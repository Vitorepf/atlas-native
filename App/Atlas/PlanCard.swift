import SwiftUI
import AtlasCore

// WAVE-014 fused PlanCard.swift

// --- PlanCard+A11y.swift ---
extension PlanCard {
    func spokenCardLabel(plan: AtlasExecutionPlan, progress: AtlasExecutionPlan.Progress?) -> String {
        var parts = ["plano da obra, \(plan.title), \(plan.steps.count) passos"]
        if let progress {
            parts.append("checkpoint \(progress.current) de \(progress.total), \(progress.title)")
            if progress.isTerminal { parts.append("concluído") }
        } else {
            parts.append("nenhum checkpoint observado, passos pendentes")
        }
        return parts.joined(separator: ", ")
    }
}

// --- PlanCard+A11yChipRow.swift ---
extension PlanCard {
    func spokenChipRow(label: String, items: [String]) -> String {
        "\(label), \(items.count) itens, \(items.joined(separator: ", "))"
    }
}

// --- PlanCard+A11yDetail+Audit.swift ---
extension PlanCard {
    func spokenAuditTerminal(plan: AtlasExecutionPlan, progress: AtlasExecutionPlan.Progress) -> String {
        "auditoria do plano, \(plan.steps.count) passos planejados, \(min(progress.current, progress.total)) de \(progress.total) executados, \(progress.isTerminal ? "terminal" : "em curso")"
    }
}

// --- PlanCard+A11yDetail+Plan.swift ---
extension PlanCard {
    func spokenPlanDetail(_ plan: AtlasExecutionPlan) -> String {
        var parts: [String] = []
        if !plan.agents.isEmpty { parts.append("agentes, \(plan.agents.map(\.title).joined(separator: ", "))") }
        if !plan.tools.isEmpty { parts.append("ferramentas, \(plan.tools.map(\.label).joined(separator: ", "))") }
        if !plan.qualityGates.isEmpty { parts.append("gates, \(plan.qualityGates.map(\.label).joined(separator: ", "))") }
        return parts.joined(separator: ", ")
    }
}

// --- PlanCard+A11yDetail+Revision.swift ---
extension PlanCard {
    func spokenRevisionToggle(expanded: Bool, count: Int) -> String {
        expanded
            ? "comparar versões do plano, expandido, \(count) versões"
            : "comparar versões do plano, \(count) versões"
    }
}

// --- PlanCard+A11yProgressBadge.swift ---
extension PlanCard {
    func spokenProgressBadge(_ progress: AtlasExecutionPlan.Progress) -> String {
        "\(progress.current) de \(progress.total) passos, \(progress.title)"
    }
}

// --- PlanCard+A11yStep.swift ---
extension PlanCard {
    func spokenStep(
        step: AtlasExecutionPlan.Step,
        state: StepState,
        index: Int,
        total: Int
    ) -> String {
        var parts = ["passo \(index + 1) de \(total)", step.title]
        parts.append(Self.spokenStepState(state))
        return parts.joined(separator: ", ")
    }
}

// --- PlanCard+A11yStepState.swift ---
extension PlanCard {
    static func spokenStepState(_ state: StepState) -> String {
        switch state {
        case .done: "concluído"
        case .current: "em curso"
        case .pending: "pendente"
        }
    }
}

// --- PlanCard+Body.swift ---
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

// --- PlanCard+Chrome.swift ---
extension PlanCard {
    func planCardChrome<Content: View>(plan: AtlasExecutionPlan, @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(12)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control, fillOpacity: 0.5)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(spokenCardLabel(plan: plan, progress: executionProgress))
            .accessibilityIdentifier(A11yID.planCard)
    }
}

// --- PlanCard+Header.swift ---
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

// --- PlanCard+HeaderProgress.swift ---
extension PlanCard {
    @ViewBuilder
    func planHeaderProgress(_ progress: AtlasExecutionPlan.Progress) -> some View {
        Text("\(progress.current)/\(progress.total)")
            .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
            .accessibilityLabel(spokenProgressBadge(progress))
            .accessibilityIdentifier(A11yID.planProgress)
    }
}

// --- PlanCard+PlanBodyStack.swift ---
extension PlanCard {
    @ViewBuilder
    func planCardBodyStack(plan: AtlasExecutionPlan) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            planBody(plan: plan)
        }
    }
}

// --- PlanCard+RevisionA11y.swift ---
extension PlanRevisionCompare {
    func comparisonAccessibilityLabel(_ comparison: RevisionComparison) -> String {
        var parts = ["comparação do plano, versão \(comparison.revision.revision) arquivada"]
        if !comparison.left.isEmpty {
            parts.append("\(comparison.left.count) passos saíram")
        }
        if !comparison.entered.isEmpty {
            parts.append("\(comparison.entered.count) passos entraram")
        }
        return parts.joined(separator: ", ")
    }
}

// --- PlanCard+RevisionArchiveA11y.swift ---
extension PlanRevisionCompare {
    func revisionArchiveAccessibilityLabel(_ rev: AtlasTraceGovernance.PlanRevision) -> String {
        var parts = ["plano versão \(rev.revision) arquivado"]
        if let reason = rev.reason, !reason.isEmpty {
            parts.append(rev.humanReason)
        }
        if let archivedAt = rev.archivedAt {
            parts.append("em \(editorialArchivedAt(archivedAt))")
        }
        if !rev.stepTitles.isEmpty {
            parts.append("\(rev.stepTitles.count) passos")
        }
        return parts.joined(separator: ", ")
    }
}

// --- PlanCard+RevisionArchiveHeader.swift ---
extension PlanRevisionCompare {
    func revisionArchiveHeader(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        HStack(spacing: 6) {
            Text("v\(rev.revision) arquivado")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
            if let iteration = rev.iteration {
                Text("iter \(iteration)")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .accessibilityHidden(true)
            }
            Spacer(minLength: 0)
        }
    }
}

// --- PlanCard+StepRow+Body.swift ---
extension PlanStepRowView {
    var stepRowBody: some View {
        applyStepPulse(
            stepRowA11yChrome(stepRowLayout)
        )
    }
}

// --- PlanCard+StepRowA11y.swift ---
extension PlanStepRowView {
    func stepRowA11yChrome<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenLabel)
            .accessibilityAddTraits(state == .current ? .isSelected : [])
            .accessibilityIdentifier(A11yID.planStep(index))
    }
}

// --- PlanCard.swift ---
struct PlanCard: View {
    let bubble: ChatBubble
    @Environment(AtlasSession.self) var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var showDetail = false
    @State var showRevisions = false

    var body: some View {
        planCardGate
    }
}

