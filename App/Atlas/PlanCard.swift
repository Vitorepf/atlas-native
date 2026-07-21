import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: PlanCard + StepRow + FlexWrap fused

// MARK: - Host

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

// MARK: - Body

// WAVE-121 PlanCard body peel

extension PlanCard {
    @ViewBuilder
    func planToolsChips(_ plan: AtlasExecutionPlan) -> some View {
        if !plan.tools.isEmpty {
            chipRow(label: "ferramentas", items: plan.tools.map(\.label))
        }
    }
}

extension PlanCard {
    func planDetail(_ plan: AtlasExecutionPlan) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            planAgentsChips(plan)
            planToolsChips(plan)
            planGatesChips(plan)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(PlanJudgment.spokenPlanDetail(plan))
        .transition(reduceMotion ? .identity : .opacity)
    }
}

extension PlanCard {
    @ViewBuilder
    func planDetailToggleButton(plan: AtlasExecutionPlan) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            withAnimation(reduceMotion ? nil : AtlasMotion.editorial) {
                showDetail.toggle()
            }
        } label: {
            Text(showDetail ? "menos" : "ferramentas · agentes · gates")
                .atlasSans(11, .medium).foregroundStyle(AtlasTheme.textSecondary)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(A11yID.planDetailToggle)
        .accessibilityLabel(PlanJudgment.spokenDetailToggle(showDetail: showDetail))
        .accessibilityHint(showDetail ? "toque para recolher" : "toque para expandir")
    }
}

extension PlanCard {
    @ViewBuilder
    func planDetailSection(plan: AtlasExecutionPlan) -> some View {
        if !plan.tools.isEmpty || !plan.agents.isEmpty || !plan.qualityGates.isEmpty {
            planDetailToggleButton(plan: plan)
            if showDetail { planDetail(plan) }
        }
    }
}

// MARK: - Steps · revisions gate

extension PlanCard {
    @ViewBuilder
    var planCardGate: some View {
        if let plan, !plan.steps.isEmpty {
            planCardChrome(plan: plan) {
                planCardBodyStack(plan: plan)
            }
        }
    }
}

extension PlanCard {
    var plan: AtlasExecutionPlan? { bubble.executionPlan }
    var executionProgress: AtlasExecutionPlan.Progress? { bubble.executionProgress }
    var currentIndex: Int? { executionProgress?.current }
    var isTerminal: Bool { executionProgress?.isTerminal == true }
}

extension PlanCard {
    var revisions: [AtlasTraceGovernance.PlanRevision] { bubble.planRevisions }
    var meaningfulRevisions: [AtlasTraceGovernance.PlanRevision] {
        revisions.filter { rev in
            rev.reason?.isEmpty == false || rev.archivedAt != nil || !rev.stepTitles.isEmpty
        }
    }
}

extension PlanCard {
    @ViewBuilder
    func revisionToggle(plan: AtlasExecutionPlan) -> some View {
        let count = meaningfulRevisions.count
        revisionToggleControl(plan: plan, count: count)
        if showRevisions {
            PlanRevisionCompare(plan: plan, revisions: meaningfulRevisions)
                .transition(reduceMotion ? .identity : .opacity)
        }
    }
}

extension PlanCard {
    func revisionToggleControl(plan: AtlasExecutionPlan, count: Int) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            withAnimation(reduceMotion ? nil : AtlasMotion.editorial) {
                showRevisions.toggle()
            }
        } label: {
            Text(showRevisions ? "ocultar versões" : "comparar versões · \(count)")
                .atlasSans(11, .medium).foregroundStyle(AtlasTheme.textSecondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(PlanJudgment.spokenRevisionToggle(expanded: showRevisions, count: count))
        .accessibilityHint(showRevisions ? "toque para ocultar" : "toque para expandir")
    }
}

// MARK: - Steps (state + list)

extension PlanCard {
    /// WAVE-040: step lifecycle owned by PlanJudgment.
    func stepState(_ idx: Int) -> PlanStepState {
        PlanJudgment.stepState(
            index: idx,
            progress: executionProgress,
            isTerminal: isTerminal
        )
    }
}

extension PlanCard {
    func planStepsList(plan: AtlasExecutionPlan) -> some View {
        planStepsRows(plan: plan)
            .accessibilityIdentifier(A11yID.planSteps)
    }
}

extension PlanCard {
    func planStepRow(step: AtlasExecutionPlan.Step, index: Int, total: Int) -> some View {
        let state = stepState(index)
        return PlanStepRowView(
            step: step,
            index: index,
            total: total,
            state: state,
            isLast: index == total - 1,
            spokenLabel: PlanJudgment.spokenStep(step: step, state: state, index: index, total: total),
            reduceMotion: reduceMotion
        )
    }
}

extension PlanCard {
    func planStepsRows(plan: AtlasExecutionPlan) -> some View {
        let total = plan.steps.count
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(plan.steps.enumerated()), id: \.element.id) { idx, step in
                planStepRow(step: step, index: idx, total: total)
            }
        }
    }
}
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
extension PlanFlexWrap {
    func measureFlexWrap(
        maxWidth: CGFloat,
        subviews: Subviews
    ) -> (width: CGFloat, height: CGFloat) {
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0; y += lineHeight + lineSpacing; lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return (x, y + lineHeight)
    }
}

// MARK: - Layout (flex wrap)

struct PlanFlexWrap: Layout {
    var spacing: CGFloat = 6
    var lineSpacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let measured = measureFlexWrap(maxWidth: maxWidth, subviews: subviews)
        return CGSize(
            width: maxWidth == .infinity ? measured.width : maxWidth,
            height: measured.height
        )
    }
}

extension PlanFlexWrap {
    func placeFlexWrapSubview(
        _ sub: LayoutSubview,
        x: inout CGFloat,
        y: inout CGFloat,
        lineHeight: inout CGFloat,
        bounds: CGRect
    ) {
        let size = sub.sizeThatFits(.unspecified)
        if x + size.width > bounds.maxX, x > bounds.minX {
            x = bounds.minX; y += lineHeight + lineSpacing; lineHeight = 0
        }
        sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
        x += size.width + spacing
        lineHeight = max(lineHeight, size.height)
    }
}

extension PlanFlexWrap {
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, lineHeight: CGFloat = 0
        for sub in subviews {
            placeFlexWrapSubview(sub, x: &x, y: &y, lineHeight: &lineHeight, bounds: bounds)
        }
    }
}

extension PlanFlowChips {
    func flowChipCell(_ item: String) -> some View {
        Text(item)
            .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textSecondary)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
            .lineLimit(1)
            .accessibilityHidden(true)
    }
}

struct PlanFlowChips: View {
    let items: [String]
    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            PlanFlexWrap(spacing: 6, lineSpacing: 6) {
                ForEach(items, id: \.self) { item in
                    flowChipCell(item)
                }
            }
            .accessibilityHidden(true)
        }
    }
}

// MARK: - Face strip

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
