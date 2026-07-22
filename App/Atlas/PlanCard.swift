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
        Text(HomeOpsJudgment.productAuditBadge)
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

// MARK: - PlanJudgment

// MARK: - Types

/// Exclusive plan progress face (WAVE-040).
enum PlanProgressFace: Equatable {
    /// No plan on the bubble.
    case absent
    /// Plan published; no progress checkpoint yet.
    case pending(steps: Int)
    /// Progress published; not terminal.
    case running(current: Int, total: Int, title: String)
    /// Progress terminal.
    case terminal(current: Int, total: Int, title: String)

    var productWord: String {
        switch self {
        case .absent: return "absent"
        case .pending: return "pending"
        case .running: return "running"
        case .terminal: return "terminal"
        }
    }

    var kicker: String {
        switch self {
        case .absent: return "Plano"
        case .pending: return "Plano sem checkpoint"
        case .running: return "Plano em curso"
        case .terminal: return "Plano terminal"
        }
    }

    var spokenFace: String {
        switch self {
        case .absent:
            return "sem plano de execução publicado"
        case .pending(let steps):
            return steps == 1
                ? "plano com 1 passo, nenhum checkpoint observado"
                : "plano com \(steps) passos, nenhum checkpoint observado"
        case .running(let current, let total, let title):
            return "plano em curso, checkpoint \(current) de \(total), \(title)"
        case .terminal(let current, let total, let title):
            return "plano terminal, \(current) de \(total), \(title)"
        }
    }
}

/// Step lifecycle for plan rows — pure, not View-owned.
enum PlanStepState: Equatable {
    case done
    case current
    case pending

    var productWord: String {
        switch self {
        case .done: return "done"
        case .current: return "current"
        case .pending: return "pending"
        }
    }

    var spoken: String {
        switch self {
        case .done: return "concluído"
        case .current: return "em curso"
        case .pending: return "pendente"
        }
    }
}

// MARK: - Judgment

/// Pure plan progress grammar — face · step · pack · spoken.
enum PlanJudgment {

    // MARK: Face

    static func face(
        plan: AtlasExecutionPlan?,
        progress: AtlasExecutionPlan.Progress?
    ) -> PlanProgressFace {
        // Progress alone is honest (cockpit may publish checkpoint without full plan).
        if let progress {
            if progress.isTerminal {
                return .terminal(
                    current: progress.current,
                    total: progress.total,
                    title: progress.title
                )
            }
            return .running(
                current: progress.current,
                total: progress.total,
                title: progress.title
            )
        }
        guard let plan, !plan.steps.isEmpty else { return .absent }
        return .pending(steps: plan.steps.count)
    }

    static func face(bubble: ChatBubble) -> PlanProgressFace {
        face(plan: bubble.executionPlan, progress: bubble.executionProgress)
    }

    // MARK: Step state

    /// 1-based checkpoint semantics: idx 0 is step 1.
    static func stepState(
        index: Int,
        progress: AtlasExecutionPlan.Progress?,
        isTerminal: Bool
    ) -> PlanStepState {
        guard let progress else { return .pending }
        if isTerminal || progress.isTerminal { return .done }
        let c = progress.current
        if index + 1 < c { return .done }
        if index + 1 == c { return .current }
        return .pending
    }

    static func stepState(
        index: Int,
        plan: AtlasExecutionPlan?,
        progress: AtlasExecutionPlan.Progress?
    ) -> PlanStepState {
        let terminal = progress?.isTerminal == true
        return stepState(index: index, progress: progress, isTerminal: terminal)
    }

    // MARK: Summary

    /// Shared card + cockpit line: never invent title when progress nil.
    static func summaryLine(
        plan: AtlasExecutionPlan?,
        progress: AtlasExecutionPlan.Progress?
    ) -> String {
        switch face(plan: plan, progress: progress) {
        case .absent:
            return "sem plano publicado"
        case .pending(let steps):
            return steps == 1 ? "1 passo · sem checkpoint" : "\(steps) passos · sem checkpoint"
        case .running(let current, let total, let title):
            return "\(current)/\(total) · \(title)"
        case .terminal(let current, let total, let title):
            return "\(current)/\(total) · \(title) · terminal"
        }
    }

    static func summaryLine(bubble: ChatBubble) -> String {
        summaryLine(plan: bubble.executionPlan, progress: bubble.executionProgress)
    }

    static func progressBadge(_ progress: AtlasExecutionPlan.Progress) -> String {
        "\(progress.current)/\(progress.total)"
    }

    static func spokenProgressBadge(_ progress: AtlasExecutionPlan.Progress) -> String {
        "\(progress.current) de \(progress.total) passos, \(progress.title)"
    }

    // MARK: Spoken card

    static func spokenCard(
        plan: AtlasExecutionPlan,
        progress: AtlasExecutionPlan.Progress?
    ) -> String {
        var parts = ["plano da obra, \(plan.title), \(plan.steps.count) passos"]
        parts.append(face(plan: plan, progress: progress).spokenFace)
        return parts.joined(separator: ", ")
    }

    static func spokenRevisionGroup(label: String, stepCount: Int) -> String {
        let noun = stepCount == 1 ? "passo" : "passos"
        return "\(label), \(stepCount) \(noun)"
    }

    static func spokenStep(
        step: AtlasExecutionPlan.Step,
        state: PlanStepState,
        index: Int,
        total: Int
    ) -> String {
        ["passo \(index + 1) de \(total)", step.title, state.spoken]
            .joined(separator: ", ")
    }

    static func spokenAuditTerminal(
        plan: AtlasExecutionPlan,
        progress: AtlasExecutionPlan.Progress
    ) -> String {
        let executed = min(progress.current, progress.total)
        return "auditoria do plano, \(plan.steps.count) passos planejados, \(executed) de \(progress.total) executados, \(progress.isTerminal ? "terminal" : "em curso")"
    }


    // MARK: - Chrome spoken
    // MARK: Card chrome spoken (WAVE-105)

    static func spokenChipRow(label: String, items: [String]) -> String {
        "\(label), \(items.count) itens, \(items.joined(separator: ", "))"
    }

    static func spokenPlanDetail(_ plan: AtlasExecutionPlan) -> String {
        var parts: [String] = []
        if !plan.agents.isEmpty {
            parts.append("agentes, \(plan.agents.map(\.title).joined(separator: ", "))")
        }
        if !plan.tools.isEmpty {
            parts.append("ferramentas, \(plan.tools.map(\.label).joined(separator: ", "))")
        }
        if !plan.qualityGates.isEmpty {
            parts.append("gates, \(plan.qualityGates.map(\.label).joined(separator: ", "))")
        }
        return parts.joined(separator: ", ")
    }

    static func spokenRevisionToggle(expanded: Bool, count: Int) -> String {
        expanded
            ? "comparar versões do plano, expandido, \(count) versões"
            : "comparar versões do plano, \(count) versões"
    }

    static func spokenDetailToggle(showDetail: Bool) -> String {
        showDetail
            ? "ocultar ferramentas agentes e gates"
            : "mostrar ferramentas agentes e gates"
    }

    // MARK: Pack

    static func packFacts(
        plan: AtlasExecutionPlan?,
        progress: AtlasExecutionPlan.Progress?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(plan: plan, progress: progress)
        facts.append("plan_face: \(face.productWord)")
        guard let plan, !plan.steps.isEmpty else {
            absences.append("plano de execução não publicado neste recorte")
            return (facts, absences)
        }
        facts.append("plan_title: \(plan.title)")
        facts.append("plan_steps: \(plan.steps.count)")
        facts.append(summaryLine(plan: plan, progress: progress))
        if let progress {
            facts.append("progress_current: \(progress.current)")
            facts.append("progress_total: \(progress.total)")
            facts.append("progress_title: \(progress.title)")
            facts.append("progress_terminal: \(progress.isTerminal)")
        } else {
            absences.append("nenhum checkpoint de progresso observado")
        }
        if !plan.agents.isEmpty {
            facts.append("agents: " + plan.agents.map(\.title).joined(separator: ", "))
        } else {
            absences.append("sem agentes no plano publicado")
        }
        if !plan.tools.isEmpty {
            facts.append("tools: " + plan.tools.map(\.label).joined(separator: ", "))
        }
        if !plan.qualityGates.isEmpty {
            facts.append("gates: " + plan.qualityGates.map(\.label).joined(separator: ", "))
        }
        return (facts, absences)
    }

}

// MARK: - PlanRevisionCompare

// MARK: - Types / Helpers

extension PlanRevisionCompare {
    var latestComparison: RevisionComparison? {
        guard let revision = revisions.last(where: { !$0.stepTitles.isEmpty }) else { return nil }
        let current = plan.steps.map(\.title)
        let archived = revision.stepTitles
        return RevisionComparison(
            revision: revision,
            left: archived.filter { !current.contains($0) },
            entered: current.filter { !archived.contains($0) }
        )
    }

    struct RevisionComparison {
        let revision: AtlasTraceGovernance.PlanRevision
        let left: [String]
        let entered: [String]
        var hasChanges: Bool { !left.isEmpty || !entered.isEmpty }
    }
}

extension PlanRevisionCompare {
    enum RevisionTone { case removed, added }

    func hasArchiveMetadata(_ rev: AtlasTraceGovernance.PlanRevision) -> Bool {
        rev.reason?.isEmpty == false || rev.archivedAt != nil || !rev.stepTitles.isEmpty
    }

    func editorialArchivedAt(_ raw: String) -> String {
        if let tIndex = raw.firstIndex(of: "T") {
            return String(raw[..<tIndex])
        }
        return raw
    }
}

// MARK: - Body

struct PlanRevisionCompare: View {
    let plan: AtlasExecutionPlan
    let revisions: [AtlasTraceGovernance.PlanRevision]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            comparisonBody
            revisionArchiveList
        }
    }
}

extension PlanRevisionCompare {
    @ViewBuilder
    var revisionArchiveList: some View {
        if revisions.contains(where: hasArchiveMetadata) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(revisions) { rev in
                    if hasArchiveMetadata(rev) {
                        revisionArchiveRow(rev)
                    }
                }
            }
        }
    }
}

extension PlanRevisionCompare {
    @ViewBuilder
    var comparisonEnteredList: some View {
        if let comparison = latestComparison, comparison.hasChanges, !comparison.entered.isEmpty {
            revisionList(label: "entraram", items: comparison.entered, tone: .added)
        }
    }
}

extension PlanRevisionCompare {
    @ViewBuilder
    var comparisonLeftList: some View {
        if let comparison = latestComparison, comparison.hasChanges, !comparison.left.isEmpty {
            revisionList(label: "saíram", items: comparison.left, tone: .removed)
        }
    }
}

extension PlanRevisionCompare {
    @ViewBuilder
    var comparisonBody: some View {
        if let comparison = latestComparison, comparison.hasChanges {
            VStack(alignment: .leading, spacing: 7) {
                Text("v\(comparison.revision.revision) arquivado → plano atual")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                comparisonLeftList
                comparisonEnteredList
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(comparisonAccessibilityLabel(comparison))
        }
    }
}

extension PlanRevisionCompare {
    func revisionBulletRow(item: String, tone: RevisionTone) -> some View {
        Text("• \(item)")
            .atlasSans(12)
            .foregroundStyle(tone == .removed ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
            .strikethrough(tone == .removed, color: AtlasTheme.textTertiary.opacity(0.7))
            .lineLimit(2)
            .accessibilityHidden(true)
    }
}

extension PlanRevisionCompare {
    @ViewBuilder
    func revisionListItems(items: [String], tone: RevisionTone) -> some View {
        ForEach(items, id: \.self) { item in
            revisionBulletRow(item: item, tone: tone)
        }
    }
}

extension PlanRevisionCompare {
    func revisionList(label: String, items: [String], tone: RevisionTone) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(AtlasFont.mono(9))
                .tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            revisionListItems(items: items, tone: tone)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            PlanJudgment.spokenRevisionGroup(label: label, stepCount: items.count)
        )
    }
}

// MARK: - Archive chrome

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

extension PlanRevisionCompare {
    @ViewBuilder
    func revisionArchiveMeta(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        revisionArchiveReason(rev)
        revisionArchiveWhen(rev)
        revisionArchiveSteps(rev)
    }
}

extension PlanRevisionCompare {
    @ViewBuilder
    func revisionArchiveReason(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        if let reason = rev.reason, !reason.isEmpty {
            Text(rev.humanReason)
                .atlasSans(12)
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }
}

extension PlanRevisionCompare {
    func revisionArchiveRow(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            revisionArchiveHeader(rev)
            revisionArchiveMeta(rev)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(revisionArchiveAccessibilityLabel(rev))
    }
}

extension PlanRevisionCompare {
    @ViewBuilder
    func revisionArchiveSteps(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        if !rev.stepTitles.isEmpty {
            Text(rev.stepTitles.joined(separator: " · "))
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }
}

extension PlanRevisionCompare {
    @ViewBuilder
    func revisionArchiveWhen(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        if let archivedAt = rev.archivedAt {
            Text(editorialArchivedAt(archivedAt))
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - A11y

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

// MARK: - EditorialTurn

// MARK: - EditorialTurn

// MARK: - Types / Inputs

struct EditorialTurn: View, Equatable {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onFeedback: (FeedbackKind) -> Void
    let onCopy: () -> Void
    var onEditResend: () -> Void = {}
    let onStop: () -> Void
    let onExecutionChoice: (JobID, String) -> Void
    var onRetry: (JobID) -> Void = { _ in }
    var onSteer: (TraceID) -> Void = { _ in }
    var artifactItems: [AtlasTraceArtifacts.Item] = []
    var onOpenArtifacts: (TraceID) -> Void = { _ in }
    @State var placed = false

    // MARK: Body

    var body: some View {
        applyArrival(turnBody)
    }
}

// MARK: - Body / Sections (assistant)

extension EditorialTurn {
    func applyArrival<Content: View>(_ content: Content) -> some View {
        content
            .opacity(placed ? 1 : 0)
            .offset(y: placed ? 0 : 12)
            .onAppear {
                if reduceMotion { placed = true }
                else { withAnimation(AtlasMotion.arrival) { placed = true } }
            }
    }
}

extension EditorialTurn {
    @ViewBuilder
    var assistantTurn: some View {
        VStack(alignment: .leading, spacing: 12) {
            assistantPlanCard
            assistantExecutionRibbon
            assistantExecutionBlock
            assistantClosing
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 0.38) { onCopy() }
        .accessibilityHint(EditorialTurnJudgment.spokenCopyLongPressHint)
    }
}

extension EditorialTurn {
    @ViewBuilder
    var assistantExecutionBlock: some View {
        if let state = bubble.executionPresentationState {
            assistantExecutionCard(state)
        }
    }
}

extension EditorialTurn {
    @ViewBuilder
    func assistantExecutionCard(_ state: AtlasExecutionPresentationState) -> some View {
        if ExecutionStateCard.shouldDisplay(state: state) {
            ExecutionStateCard(
                state: state,
                jobId: bubble.executionChoiceJobId,
                onChoose: onExecutionChoice,
                retryableJobId: bubble.retryableJobId,
                onRetry: onRetry,
                onSteer: assistantSteerHandler
            )
        }
    }
}

extension EditorialTurn {
    var assistantSteerHandler: (() -> Void)? {
        let steerTrace = bubble.executionPresence?.isOngoing == true ? bubble.traceId : nil
        return steerTrace.map { trace in { onSteer(trace) } }
    }
}

extension EditorialTurn {
    @ViewBuilder
    var assistantPlanCard: some View {
        PlanCard(bubble: bubble)
    }
}

extension EditorialTurn {
    @ViewBuilder
    var assistantExecutionRibbon: some View {
        // WAVE-027: presence-ongoing keeps ribbon; not streaming-only (sink ≡ strip).
        // WAVE-012 dual-surface reconnect silence remains inside ExecutionRibbon.
        if bubble.hasLiveExecutionSurface,
           ConversationExecutionPhase.isPresenceOngoing(bubble) {
            ExecutionRibbon(bubble: bubble, reduceMotion: reduceMotion, onStop: onStop)
        }
    }
}

// MARK: - Body branches

extension EditorialTurn {
    @ViewBuilder
    var turnBodyAssistantBranch: some View {
        assistantTurn
    }
}

extension EditorialTurn {
    @ViewBuilder
    var turnBodyUserBranch: some View {
        userTurn
    }
}

extension EditorialTurn {
    var turnBody: some View {
        Group {
            if bubble.role == "user" {
                turnBodyUserBranch
            } else {
                turnBodyAssistantBranch
            }
        }
    }
}

// MARK: - Equatable

extension EditorialTurn {
    nonisolated static func == (lhs: EditorialTurn, rhs: EditorialTurn) -> Bool {
        lhs.bubble == rhs.bubble && lhs.reduceMotion == rhs.reduceMotion && lhs.artifactItems == rhs.artifactItems
    }
}

// MARK: - EditorialTurnChrome

// MARK: - Feedback

struct FeedbackRow: View {
    let active: String?
    let reduceMotion: Bool
    let onFeedback: (FeedbackKind) -> Void
    var body: some View {
        HStack(spacing: 8) {
            ForEach(FeedbackKind.allCases) { kind in
                feedbackChip(kind)
            }
            Spacer()
        }
        .padding(.top, 2)
    }
}

extension FeedbackRow {
    func feedbackChipA11y<Content: View>(
        _ content: Content,
        kind: FeedbackKind,
        isActive: Bool
    ) -> some View {
        content
            .accessibilityLabel(EditorialTurnJudgment.spokenFeedbackLabel(kind: kind, active: isActive))
            .accessibilityHint(EditorialTurnJudgment.spokenFeedbackHint)
            .accessibilityAddTraits(isActive ? .isSelected : [])
            .accessibilityIdentifier(A11yID.editorialTurnFeedback(kind.rawValue))
    }
}

extension FeedbackRow {
    func feedbackChipLabel(_ kind: FeedbackKind, isActive: Bool) -> some View {
        Text(isActive ? "\(kind.label) ✓" : kind.label)
            .font(AtlasFont.serifItalic(13))
            .foregroundStyle(isActive ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .overlay(
                Capsule().stroke(
                    isActive ? AtlasTheme.domAutonomos.opacity(0.5) : AtlasTheme.separator,
                    lineWidth: 1
                )
            )
    }
}

extension FeedbackRow {
    func feedbackChip(_ kind: FeedbackKind) -> some View {
        let isActive = active == kind.activeAction
        return feedbackChipA11y(
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onFeedback(kind)
            } label: {
                feedbackChipLabel(kind, isActive: isActive)
            }
            .buttonStyle(PressableScale()),
            kind: kind,
            isActive: isActive
        )
    }
}

// MARK: - Shared format helpers (multi-call-site · WAVE-069 peels)

func humanDuration(_ ms: Int) -> String {
    EditorialTurnJudgment.humanDuration(ms)
}

func providerWord(_ p: String?) -> String {
    guard let p, !p.isEmpty else { return "" }
    return EditorialTurnJudgment.providerWord(p)
}

// MARK: - Signature (WAVE-069)

struct SignatureLine: View {
    let provider: String?
    let model: String?
    let elapsedMs: Int?
    let reduceMotion: Bool
    @State var shown = false

    var body: some View {
        Text(signature)
            .font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.textPrimary.opacity(0.4))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .opacity(shown ? 1 : 0)
            .accessibilityLabel(EditorialTurnJudgment.spokenSignature(provider: provider, model: model, elapsedMs: elapsedMs))
            .accessibilityValue(
                EditorialTurnJudgment.face(provider: provider, model: model).productWord
            )
            .accessibilityIdentifier(A11yID.editorialTurnSignature)
            .onAppear { revealSignature() }
    }
}

extension SignatureLine {
    static func shouldDisplay(provider: String?, model: String?) -> Bool {
        EditorialTurnJudgment.face(provider: provider, model: model) != .absent
    }
}

extension SignatureLine {
    var signature: String {
        let who = signatureWho
        if let ms = elapsedMs, ms > 0 {
            return "— \(who), em \(EditorialTurnJudgment.humanDuration(ms))"
        }
        return "— \(who)"
    }

    var signatureWho: String {
        EditorialTurnJudgment.signatureWho(provider: provider, model: model)
            ?? "provedor não publicado"
    }
}

extension SignatureLine {
    func revealSignature() {
        if reduceMotion { shown = true; return }
        Task {
            try? await Task.sleep(nanoseconds: 220_000_000)
            withAnimation(.easeIn(duration: 0.28)) { shown = true }
        }
    }
}
// MARK: - User branch

extension EditorialTurn {
    @ViewBuilder
    var userTurn: some View {
        VStack(alignment: .leading, spacing: 8) {
            userQuote
            userEditResendButton
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension EditorialTurn {
    var userEditResendButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onEditResend()
        } label: {
            userEditResendLabel
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(EditorialTurnJudgment.spokenEditResend)
        .accessibilityHint(EditorialTurnJudgment.spokenEditResendHint)
    }
}

extension EditorialTurn {
    var userEditResendLabel: some View {
        HStack(spacing: 5) {
            Image(systemName: "arrow.turn.down.right")
                .atlasSans(10, .semibold)
                .accessibilityHidden(true)
            Text("editar e reenviar")
                .atlasSans(11, .medium)
        }
        .foregroundStyle(AtlasTheme.textSecondary)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
    }
}

extension EditorialTurn {
    var userQuote: some View {
        Text("\"\(bubble.text)\"")
            .font(AtlasFont.serifItalic(18)).lineSpacing(8).foregroundStyle(AtlasTheme.textPrimary)
            .padding(.leading, 16)
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 1).fill(AtlasTheme.accent).frame(width: 2)
                    .accessibilityHidden(true)
            }
            .accessibilityLabel(EditorialTurnJudgment.spokenUserMessage(bubble.text))
    }
}
// MARK: - Closing / proof / signature / feedback

extension EditorialTurn {
    @ViewBuilder
    var assistantClosing: some View {
        if !bubble.streaming,
           ExecutionProof.shouldDisplay(bubble: bubble, artifactItems: artifactItems) {
            ExecutionProof(bubble: bubble, artifactItems: artifactItems, onOpenArtifacts: onOpenArtifacts)
            Text(EditorialTurnJudgment.productFinalAnswerKicker)
                .font(.system(.caption2, weight: .semibold)).tracking(1.6)
                .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                .accessibilityLabel(EditorialTurnJudgment.spokenFinalAnswerKicker)
                .accessibilityAddTraits(.isHeader)
        }
        assistantClosingTail
    }
}

extension EditorialTurn {
    @ViewBuilder
    var assistantClosingMeta: some View {
        if !bubble.streaming {
            if SignatureLine.shouldDisplay(provider: bubble.provider, model: bubble.model) {
                SignatureLine(
                    provider: bubble.provider, model: bubble.model,
                    elapsedMs: bubble.elapsedMs, reduceMotion: reduceMotion)
            }
            FeedbackRow(active: bubble.feedbackAction, reduceMotion: reduceMotion, onFeedback: onFeedback)
        }
    }
}

extension EditorialTurn {
    @ViewBuilder
    var assistantClosingTail: some View {
        if !bubble.text.isEmpty {
            AtlasMarkdownView(text: bubble.text, streaming: bubble.streaming)
        }
        assistantClosingMeta
    }
}

// MARK: - Judgment

// MARK: - Types

/// Exclusive editorial signature face (WAVE-069).
enum EditorialSignatureFace: Equatable {
    case present(who: String)
    case absent

    var productWord: String {
        switch self {
        case .present: return "present"
        case .absent: return "absent"
        }
    }

    var spokenFace: String {
        switch self {
        case .present(let who):
            return "resposta de \(who)"
        case .absent:
            return "assinatura ausente"
        }
    }
}

// MARK: - Judgment

/// Pure editorial-turn grammar — signature · feedback · pack.
enum EditorialTurnJudgment {

    static let spokenFinalAnswerKicker = "resposta final"
    static let spokenCopyLongPressHint = "pressionar e segurar copia a resposta"
    static let spokenFeedbackHint = "envia feedback ao roteamento do Atlas para este turno"

    static func signatureWho(provider: String?, model: String?) -> String? {
        if let model, !model.isEmpty, !model.hasSuffix("_default") { return model }
        if let provider, !provider.isEmpty {
            let word = providerWord(provider)
            return word.isEmpty ? provider : word
        }
        return nil
    }

    /// Provider product word — same map as EditorialTurn `providerWord` free fn.
    static func providerWord(_ provider: String) -> String {
        let x = provider.lowercased()
        for (k, v) in [
            ("claude", "claude"), ("codex", "codex"), ("gemini", "gemini"),
            ("hermes", "hermes"), ("minimax", "minimax"),
            ("council", "conselho"), ("conselho", "conselho")
        ] where x.contains(k) {
            return v
        }
        return x
    }

    static func face(provider: String?, model: String?) -> EditorialSignatureFace {
        if let who = signatureWho(provider: provider, model: model) {
            return .present(who: who)
        }
        return .absent
    }

    static func spokenSignature(
        provider: String?,
        model: String?,
        elapsedMs: Int?
    ) -> String {
        guard let who = signatureWho(provider: provider, model: model) else {
            return ""
        }
        if let ms = elapsedMs, ms > 0 {
            return "resposta de \(who), em \(humanDuration(ms))"
        }
        return "resposta de \(who)"
    }

    static func spokenUserMessage(_ text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "mensagem sua, vazia" : "mensagem sua, \(trimmed)"
    }

    static func spokenFeedbackBase(kind: FeedbackKind) -> String {
        switch kind {
        case .util: return "marcar resposta como útil"
        case .contexto: return "marcar contexto errado"
        case .longo: return "marcar resposta longa demais"
        case .fraco: return "marcar resposta fraca"
        }
    }

    static func spokenFeedbackLabel(kind: FeedbackKind, active: Bool) -> String {
        let base = spokenFeedbackBase(kind: kind)
        return active ? "\(base), selecionado" : base
    }

    /// Same duration honesty as EditorialTurn free `humanDuration`.
    static func humanDuration(_ ms: Int) -> String {
        if ms < 1000 { return "um instante" }
        if ms < 60000 {
            return String(format: "%.1f s", Double(ms) / 1000)
                .replacingOccurrences(of: ".", with: ",")
        }
        return "\(ms / 60000) min"
    }

    static func packFacts(
        provider: String?,
        model: String?,
        elapsedMs: Int?,
        feedbackAction: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(provider: provider, model: model)
        facts.append("editorial_signature_face: \(face.productWord)")
        switch face {
        case .present(let who):
            facts.append("editorial_who: \(who)")
        case .absent:
            absences.append("assinatura do turno ausente")
        }
        if let ms = elapsedMs, ms > 0 {
            facts.append("editorial_elapsed_ms: \(ms)")
        }
        if let feedbackAction, !feedbackAction.isEmpty {
            facts.append("editorial_feedback: \(feedbackAction)")
        } else {
            absences.append("sem feedback do operador neste turno")
        }
        return (facts, absences)
    }

    static let spokenEditResend = "editar esta mensagem e reenviar como novo turno"
    static let productFinalAnswerKicker = "RESPOSTA FINAL"
    static let spokenEditResendHint = "abre o compositor com este texto para um novo envio"
}
