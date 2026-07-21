import AtlasCore
import Foundation
import SwiftUI
import WidgetKit

// Cycle 044 fuse → ConversationCockpit.swift

// O cockpit da execução — faixa no composer, ribbon, narrativa viva e a

extension ExecutingStrip {
    @ViewBuilder
    var stripStatus: some View {
        HStack(spacing: 8) {
            stripStatusLeading
            stripStatusTitle
            stripStatusMeta
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(stripAccessibilityLabel)
        // Live elapsed/activity copy moves; Reduce Motion keeps it static.
        .accessibilityAddTraits(reduceMotion ? .isStaticText : [.isStaticText, .updatesFrequently])
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusActivityOrIdle: some View {
        if let act = bubble.currentActivity {
            stripStatusActivityRow(act)
        } else {
            stripStatusIdleLine
        }
    }
}

extension ExecutingStrip {
    var stripStatusIdleLine: some View {
        Text("Seguindo a execução")
            .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
            .lineLimit(1)
            .layoutPriority(2)
            .accessibilityHidden(true)
    }
}

extension ExecutingStrip {
    @ViewBuilder
    func stripStatusActivityRow(_ act: AtlasAgentActivity) -> some View {
        HStack(spacing: 5) {
            Image(systemName: activityIcon(act.kind))
                .atlasSans(10, .semibold)
                .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                .accessibilityHidden(true)
            Text(act.title)
                .font(.system(.footnote))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(2)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusLeading: some View {
        if bubble.showsReconnectSurface {
            Image(systemName: bubble.reconnectBannerIcon)
                .atlasSans(10, .semibold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion)
                .accessibilityHidden(true)
        } else {
            BreathingDiamond(size: 8, reduceMotion: reduceMotion)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusDiffStats: some View {
        if let stats = bubble.diffStats {
            Text("+\(stats.linesAdded) −\(stats.linesRemoved)")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.accent)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusEventTimer: some View {
        TimelineView(.periodic(from: .now, by: 1)) { ctx in
            let secs = bubble.startedAt.map { max(0, Int(ctx.date.timeIntervalSince($0))) } ?? 0
            Text("· \(bubble.activities.count) evento\(bubble.activities.count == 1 ? "" : "s") · \(secs)s")
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusMeta: some View {
        stripStatusEventTimer
        stripStatusDiffStats
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusProgressLine: some View {
        if let p = bubble.executionProgress {
            Text("\(p.current)/\(p.total) · \(p.title)")
                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(2)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusReconnectLine: some View {
        if bubble.showsReconnectSurface, let line = bubble.reconnectPrimaryLine {
            Text(line)
                .font(.system(.footnote))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(2)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusReconnectOrProgress: some View {
        if bubble.showsReconnectSurface, bubble.reconnectPrimaryLine != nil {
            stripStatusReconnectLine
        } else if bubble.executionProgress != nil {
            stripStatusProgressLine
        }
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripStatusTitle: some View {
        if bubble.showsReconnectSurface || bubble.executionProgress != nil {
            stripStatusReconnectOrProgress
        } else {
            stripStatusActivityOrIdle
        }
    }
}

struct ExecutionBanner: View {
    let text: String
    let icon: String
    let tint: Color
    var reduceMotion = false
    /// Quando o container pai compõe o spoken (reconexão, watchdog), o banner fica só visual.
    var embedInParent = false
    var accessibilityIdentifier: String?

    var body: some View {
        bannerChrome
            .accessibilityElement(children: .ignore)
            .accessibilityHidden(embedInParent)
            .accessibilityLabel(text)
            .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}

extension ExecutionBanner {
    func bannerChromeFrame<Content: View>(_ content: Content) -> some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(tint.opacity(0.10)))
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(tint.opacity(0.35), lineWidth: 1))
    }
}

extension ExecutionBanner {
    var bannerContentRow: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .atlasSans(11, .semibold)
                .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion)
                .accessibilityHidden(true)
            Text(text)
                .font(AtlasFont.mono(10))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .foregroundStyle(tint)
    }
}

extension ExecutionBanner {
    var bannerChrome: some View {
        bannerChromeFrame(bannerContentRow)
    }
}

// A RIBBON DE EXECUÇÃO — o diferencial vs Cursor. Mostra AO VIVO: quanto tempo,
// a ORQUESTRA (cada agente/provider/modelo + status), o estágio do Atlas Decide,
// e um botão Stop. Cursor mostra 1 agente; o Atlas mostra a máquina inteira.
struct ExecutionRibbon: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var body: some View {
        executionRibbonCard(executionRibbonStack)
    }
}

extension ExecutionRibbon {
    @ViewBuilder
    var decideStrategyLine: some View {
        if let strat = bubble.decideStrategy {
            Text("atlas decide · \(strat)" + (bubble.decideStage.map { " → \($0)" } ?? ""))
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary).padding(.leading, 24)
        }
    }
}

extension ExecutionRibbon {
    @ViewBuilder
    var agentLanes: some View {
        if !bubble.agents.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                agentLanesCaption
                ForEach(bubble.agents) { AgentRow(agent: $0, compactLane: bubble.agents.count >= 2) }
            }.padding(.leading, 24)
        }
    }
}

extension ExecutionRibbon {
    @ViewBuilder
    var agentLanesCaption: some View {
        if bubble.agents.count >= 2 {
            Text("LANES")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }
}


extension ExecutionRibbon {
    @ViewBuilder
    var activitiesTimelineBlock: some View {
        if !bubble.activities.isEmpty {
            LiveTimeline(activities: bubble.activities, reduceMotion: reduceMotion)
        }
    }
}

extension ExecutionRibbon {
    @ViewBuilder
    var reconnectBannerStack: some View {
        ReconnectBanner(bubble: bubble, reduceMotion: reduceMotion)
        SilenceWatchdog(bubble: bubble, reduceMotion: reduceMotion)
    }
}

extension ExecutionRibbon {
    func executionRibbonCard<V: View>(_ content: V) -> some View {
        content
            .padding(.vertical, 10).padding(.horizontal, 14)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control, fillOpacity: 0.5)
    }
}

extension ExecutionRibbon {
    var executionRibbonStack: some View {
        VStack(alignment: .leading, spacing: 8) {
            reconnectBannerStack
            activitiesTimelineBlock
            agentLanes
            decideStrategyLine
        }
    }
}

extension AgentRow {
    var agentRowContent: some View {
        HStack(spacing: 8) {
            Circle().fill(statusColor).frame(width: 6, height: 6)
            Text(agent.agent ?? providerWord(agent.provider))
                .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textSecondary)
            agentModelLabel
            Spacer()
            Text(statusWord).font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textTertiary)
        }
    }
}

struct AgentRow: View {
    let agent: ExecAgent
    var compactLane = false
    var body: some View {
        agentRowChrome(agentRowContent)
    }
}

extension AgentRow {
    func agentRowChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(.vertical, compactLane ? 3 : 0)
            .padding(.horizontal, compactLane ? 8 : 0)
            .background {
                if compactLane {
                    Capsule().fill(AtlasTheme.bgRecessed)
                }
            }
    }
}

extension AgentRow {
    @ViewBuilder
    var agentModelLabel: some View {
        if let m = agent.model, !m.isEmpty, !m.hasSuffix("_default") {
            Text(m).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
        }
    }
}

extension AgentRow {
    var statusColorActive: Color? {
        switch turnStatus {
        case .processing: return AtlasTheme.accent
        case .succeeded: return AtlasTheme.domAutonomos
        default: return nil
        }
    }
}

extension AgentRow {
    var turnStatus: AtlasTurnStatus { AtlasTurnStatus(rawValue: agent.status) }

    var statusColor: Color {
        if let active = statusColorActive { return active }
        switch turnStatus {
        case .failed, .cancelled: return AtlasTheme.domOperacional
        default: return AtlasTheme.textTertiary
        }
    }
}

extension AgentRow {
    var statusWordQueued: String? {
        switch turnStatus {
        case .queued: return "na fila"
        case .processing: return "processando"
        default: return nil
        }
    }
}

extension AgentRow {
    var statusWordActive: String? {
        if let queued = statusWordQueued { return queued }
        switch turnStatus {
        case .awaitingUserChoice: return "aguardando"
        case .awaitingExternal: return "aguardando externo"
        default: return nil
        }
    }
}

extension AgentRow {
    var statusWordDone: String? {
        switch turnStatus {
        case .succeeded: return "pronto"
        case .failed: return "falhou"
        case .cancelled: return "cancelado"
        default: return nil
        }
    }
}

extension AgentRow {
    var statusWordTerminal: String {
        if let done = statusWordDone { return done }
        if case .unknown(let raw) = turnStatus { return raw }
        return statusWordActive ?? "—"
    }
}

extension AgentRow {
    var statusWord: String {
        statusWordActive ?? statusWordTerminal
    }
}

extension ChatBubble {
    /// Linha principal: aviso do stream quando existe; senão título público do ledger.
    var reconnectPrimaryLine: String? {
        if let notice = reconnectNotice { return notice }
        guard streaming, executionPresentationState?.kind == .recovering else { return nil }
        return executionPresentationState?.title
    }
}

extension ChatBubble {
    var showsReconnectSurface: Bool {
        reconnectNotice != nil
            || (streaming && executionPresentationState?.kind == .recovering)
    }
}

extension ChatBubble {
    var reconnectBannerIcon: String {
        executionPresentationState?.kind == .recovering
            ? "arrow.triangle.2.circlepath"
            : "wifi.exclamationmark"
    }
}

extension ChatBubble {
    /// Detalhe/checkpoint só do contrato de apresentação — nunca retry inventado.
    var reconnectSecondaryLines: [String] {
        guard streaming, executionPresentationState?.kind == .recovering else { return [] }
        var lines: [String] = []
        if reconnectNotice == nil, let detail = executionPresentationState?.detail {
            lines.append(detail)
        }
        if let checkpoint = executionPresentationState?.checkpoint {
            lines.append("checkpoint · \(checkpoint)")
        }
        return lines
    }
}

extension ChatBubble {
    var reconnectActiveTimerMs: Int? {
        guard streaming,
              executionPresentationState?.kind == .recovering,
              let timer = executionPresentationState?.timer
        else { return nil }
        return timer.elapsedActiveMilliseconds
    }
}

extension ChatBubble {
    var reconnectSpokenCoreParts: [String] {
        var parts: [String] = []
        if let notice = reconnectNotice {
            parts.append(notice)
        } else if let state = executionPresentationState, state.kind == .recovering {
            parts.append(state.title)
            if let detail = state.detail { parts.append(detail) }
            if let checkpoint = state.checkpoint { parts.append("checkpoint \(checkpoint)") }
        }
        return parts
    }
}

extension ChatBubble {
    var reconnectSpokenLabel: String {
        var parts = reconnectSpokenCoreParts
        if let ms = reconnectActiveTimerMs {
            parts.append("tempo ativo \(ExecutionStateCard.clock(ms))")
        }
        return parts.isEmpty ? "reconectando" : parts.joined(separator: ". ")
    }
}

// Banner de reconexão — só `reconnectNotice` (transporte) e

struct ReconnectBanner: View {
    let bubble: ChatBubble
    let reduceMotion: Bool

    var body: some View {
        if bubble.showsReconnectSurface, let primary = bubble.reconnectPrimaryLine {
            reconnectBannerBody(primary: primary)
        }
    }
}

extension ReconnectBanner {
    @ViewBuilder
    func reconnectBannerBody(primary: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ExecutionBanner(
                text: primary,
                icon: bubble.reconnectBannerIcon,
                tint: AtlasTheme.textSecondary,
                reduceMotion: reduceMotion,
                embedInParent: true
            )
            secondaryLines
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(bubble.reconnectSpokenLabel)
        .accessibilityIdentifier(A11yID.executionReconnectBanner)
    }
}

extension ReconnectBanner {
    @ViewBuilder
    var reconnectActiveTimerLine: some View {
        if let ms = bubble.reconnectActiveTimerMs {
            Text("ativo \(ExecutionStateCard.clock(ms))")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
    }
}

extension ReconnectBanner {
    @ViewBuilder
    var reconnectSecondaryLoop: some View {
        ForEach(Array(bubble.reconnectSecondaryLines.enumerated()), id: \.offset) { _, line in
            Text(line)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }
}

extension ReconnectBanner {
    @ViewBuilder
    var secondaryLines: some View {
        reconnectSecondaryLoop
        reconnectActiveTimerLine
    }
}

/// Só fala quando o stream publica streaming e o contador é real.

enum SilenceWatchdogA11y {
    static func spoken(seconds: Int) -> String {
        "execução ao vivo sem novos eventos há \(seconds) segundos"
    }
}

extension SilenceWatchdog {
    @ViewBuilder
    func silenceGate(now: Date) -> some View {
        if bubble.streaming,
           let silence = silenceSeconds(now: now),
           silence > 90 {
            silenceBanner(seconds: silence)
        }
    }
}

struct SilenceWatchdog: View {
    let bubble: ChatBubble
    let reduceMotion: Bool

    var tickInterval: TimeInterval { reduceMotion ? 30 : 15 }

    var body: some View {
        TimelineView(.periodic(from: .now, by: tickInterval)) { context in
            silenceGate(now: context.date)
        }
    }
}

extension SilenceWatchdog {
    func silenceBanner(seconds: Int) -> some View {
        Group {
            ExecutionBanner(
                text: "Sem novos eventos há \(seconds)s",
                icon: "timer",
                tint: AtlasTheme.domOperacional,
                reduceMotion: reduceMotion,
                embedInParent: true
            )
            .modifier(NumericTextTransition(enabled: !reduceMotion))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(SilenceWatchdogA11y.spoken(seconds: seconds))
        .accessibilityIdentifier(A11yID.executionSilenceWatchdog)
    }
}

extension SilenceWatchdog {
    func silenceSeconds(now: Date) -> Int? {
        guard bubble.streaming else { return nil }
        let last = bubble.activities.reversed().compactMap { AtlasTime.date($0.occurredAt) }.first
            ?? bubble.startedAt
        guard let last else { return nil }
        return max(0, Int(now.timeIntervalSince(last)))
    }
}


// Cycle 044 fuse → PlanCard.swift

// O PLANO da obra — o roteiro que o servidor computou (workflow, passos,
// ferramentas, agentes, gates). Antes ficava invisível; agora cada passo
// mostra done/atual/pendente a partir do checkpoint REAL (executionProgress).
// Sem plano no trace, o card não existe. Nada é inventado.

struct PlanCard: View {
    let bubble: ChatBubble
    @Environment(AtlasSession.self) var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var showDetail = false
    @State var showRevisions = false

    var body: some View {
        planCardGate
    }

    // MARK: Progress / plan data

    var plan: AtlasExecutionPlan? { bubble.executionPlan }
    /// Checkpoint observado no stream; nil = nenhum passo marcado ainda (tudo pendente).
    var executionProgress: AtlasExecutionPlan.Progress? { bubble.executionProgress }
    var currentIndex: Int? { executionProgress?.current }
    var isTerminal: Bool { executionProgress?.isTerminal == true }

    var revisions: [AtlasTraceGovernance.PlanRevision] { bubble.planRevisions }
    /// Só revisões com metadata real do servidor — ausência não vira “v1” nem motivo genérico.
    var meaningfulRevisions: [AtlasTraceGovernance.PlanRevision] {
        revisions.filter { rev in
            rev.reason?.isEmpty == false || rev.archivedAt != nil || !rev.stepTitles.isEmpty
        }
    }

    // MARK: Gate + chrome + body

    @ViewBuilder
    var planCardGate: some View {
        if let plan, !plan.steps.isEmpty {
            planCardChrome(plan: plan) {
                planCardBodyStack(plan: plan)
            }
        }
    }

    func planCardChrome<Content: View>(plan: AtlasExecutionPlan, @ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(12)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control, fillOpacity: 0.5)
            // Contain without fused label: detail/revisions toggles stay focusable.
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.planCard)
    }

    @ViewBuilder
    func planCardBodyStack(plan: AtlasExecutionPlan) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            planBody(plan: plan)
        }
    }

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

    // MARK: Header

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

    @ViewBuilder
    func planHeaderProgress(_ progress: AtlasExecutionPlan.Progress) -> some View {
        Text("\(progress.current)/\(progress.total)")
            .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
            .accessibilityLabel(spokenProgressBadge(progress))
            .accessibilityIdentifier(A11yID.planProgress)
    }

    // MARK: Steps

    enum StepState { case done, current, pending }

    func planStepsList(plan: AtlasExecutionPlan) -> some View {
        planStepsRows(plan: plan)
            .accessibilityIdentifier(A11yID.planSteps)
    }

    func planStepsRows(plan: AtlasExecutionPlan) -> some View {
        let total = plan.steps.count
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(plan.steps.enumerated()), id: \.element.id) { idx, step in
                planStepRow(step: step, index: idx, total: total)
            }
        }
    }

    func planStepRow(step: AtlasExecutionPlan.Step, index: Int, total: Int) -> some View {
        let state = stepState(index)
        return PlanStepRowView(
            step: step,
            index: index,
            total: total,
            state: state,
            isLast: index == total - 1,
            spokenLabel: spokenStep(step: step, state: state, index: index, total: total),
            reduceMotion: reduceMotion
        )
    }

    func stepState(_ idx: Int) -> StepState {
        guard let c = currentIndex else { return .pending }
        if isTerminal { return .done }
        if idx + 1 < c { return .done }
        if idx + 1 == c { return .current }
        return .pending
    }
}

// A11y e spoken labels do PlanCard.

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

    static func spokenStepState(_ state: StepState) -> String {
        switch state {
        case .done: "concluído"
        case .current: "em curso"
        case .pending: "pendente"
        }
    }

    func spokenChipRow(label: String, items: [String]) -> String {
        "\(label), \(items.count) itens, \(items.joined(separator: ", "))"
    }

    func spokenProgressBadge(_ progress: AtlasExecutionPlan.Progress) -> String {
        "\(progress.current) de \(progress.total) passos, \(progress.title)"
    }

    func spokenAuditTerminal(plan: AtlasExecutionPlan, progress: AtlasExecutionPlan.Progress) -> String {
        "auditoria do plano, \(plan.steps.count) passos planejados, \(min(progress.current, progress.total)) de \(progress.total) executados, \(progress.isTerminal ? "terminal" : "em curso")"
    }

    func spokenRevisionToggle(expanded: Bool, count: Int) -> String {
        expanded
            ? "comparar versões do plano, expandido, \(count) versões"
            : "comparar versões do plano, \(count) versões"
    }
}

// Auditoria terminal do plano (modo audit).

extension PlanCard {
    func auditTerminalLine(
        plan: AtlasExecutionPlan,
        progress: AtlasExecutionPlan.Progress
    ) -> some View {
        auditTerminalCopy(plan: plan, progress: progress)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenAuditTerminal(plan: plan, progress: progress))
            .accessibilityAddTraits(.isStaticText)
    }

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

    var auditCaption: some View {
        Text("AUDITORIA")
            .font(AtlasFont.mono(9))
            .tracking(0.8)
            .foregroundStyle(AtlasTheme.domOperacional)
            .accessibilityHidden(true)
    }

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

    func auditStatusWord(progress: AtlasExecutionPlan.Progress) -> some View {
        Text(progress.isTerminal ? "terminal" : "em curso")
            .font(AtlasFont.mono(9))
            .foregroundStyle(progress.isTerminal ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}

// Detalhe do plano: toggle ferramentas/agentes/gates + flow chips + flex wrap.

extension PlanCard {
    @ViewBuilder
    func planDetailSection(plan: AtlasExecutionPlan) -> some View {
        if !plan.tools.isEmpty || !plan.agents.isEmpty || !plan.qualityGates.isEmpty {
            planDetailToggleButton(plan: plan)
            if showDetail { planDetail(plan) }
        }
    }

    @ViewBuilder
    func planDetailToggleButton(plan: AtlasExecutionPlan) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            withAnimation(reduceMotion ? nil : AtlasMotion.editorial) {
                showDetail.toggle()
            }
        } label: {
            // Ação fala em sans (mono é hash/recibo/meta — canon §C).
            Text(showDetail ? "menos" : "ferramentas · agentes · gates")
                .atlasSans(11, .medium).foregroundStyle(AtlasTheme.textSecondary)
                .frame(minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(A11yID.planDetailToggle)
        .accessibilityLabel(showDetail ? "ocultar ferramentas agentes e gates" : "mostrar ferramentas agentes e gates")
        .accessibilityHint(showDetail ? "toque para recolher" : "toque para expandir")
        .accessibilityAddTraits(showDetail ? [.isButton, .isSelected] : .isButton)
    }

    func planDetail(_ plan: AtlasExecutionPlan) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            planAgentsChips(plan)
            planToolsChips(plan)
            planGatesChips(plan)
        }
        // Contain without fused label: chip rows speak their own labels.
        .accessibilityElement(children: .contain)
        .transition(reduceMotion ? .identity : .opacity)
    }

    @ViewBuilder
    func planAgentsChips(_ plan: AtlasExecutionPlan) -> some View {
        if !plan.agents.isEmpty {
            chipRow(label: "agentes", items: plan.agents.map(\.title))
        }
    }

    @ViewBuilder
    func planToolsChips(_ plan: AtlasExecutionPlan) -> some View {
        if !plan.tools.isEmpty {
            chipRow(label: "ferramentas", items: plan.tools.map(\.label))
        }
    }

    @ViewBuilder
    func planGatesChips(_ plan: AtlasExecutionPlan) -> some View {
        if !plan.qualityGates.isEmpty {
            chipRow(label: "gates", items: plan.qualityGates.map(\.label))
        }
    }

    func chipRow(label: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased()).font(AtlasFont.mono(9)).tracking(0.8)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            PlanFlowChips(items: items)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spokenChipRow(label: label, items: items))
    }
}

/// Chips em fluxo para agentes/ferramentas/gates.
/// Pai combina spoken via PlanCard.spokenChipRow; chips individuais silenciosos.
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

    func flowChipCell(_ item: String) -> some View {
        Text(item)
            .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textSecondary)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
            .lineLimit(1)
            .accessibilityHidden(true)
    }
}

/// Layout que envolve os filhos em múltiplas linhas (sem dependência externa).
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

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, lineHeight: CGFloat = 0
        for sub in subviews {
            placeFlexWrapSubview(sub, x: &x, y: &y, lineHeight: &lineHeight, bounds: bounds)
        }
    }

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

// Linha de passo do plano (dot, spine, title, pulse, a11y chrome).

struct PlanStepRowView: View {
    let step: AtlasExecutionPlan.Step
    let index: Int
    let total: Int
    let state: PlanCard.StepState
    let isLast: Bool
    let spokenLabel: String
    let reduceMotion: Bool
    @State var pulse = false

    var body: some View {
        stepRowBody
    }

    var stepRowBody: some View {
        applyStepPulse(
            stepRowA11yChrome(stepRowLayout)
        )
    }

    var stepRowLayout: some View {
        HStack(alignment: .top, spacing: 10) {
            stepDotColumn
            stepTitleColumn
            Spacer(minLength: 0)
        }
    }

    var stepTitleColumn: some View {
        Text(step.title)
            .font(.system(.caption))
            .foregroundStyle(state == .pending ? AtlasTheme.textTertiary
                             : state == .current ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
            .lineLimit(2)
            .accessibilityHidden(true)
            .padding(.bottom, isLast ? 0 : 9)
    }

    func applyStepPulse<Content: View>(_ content: Content) -> some View {
        content
            .onAppear {
                if state == .current && !reduceMotion {
                    withAnimation(AtlasMotion.breath(0.9)) { pulse = true }
                }
            }
            .onChange(of: state == .current) { _, now in if !now { pulse = false } }
    }

    func stepRowA11yChrome<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenLabel)
            .accessibilityAddTraits(state == .current ? .isSelected : [])
            .accessibilityIdentifier(A11yID.planStep(index))
    }

    var stepDotColumn: some View {
        VStack(spacing: 0) {
            stepDotMark
            stepDotSpine
        }
        .frame(width: 13)
        .accessibilityHidden(true)
    }

    func dotFill(_ s: PlanCard.StepState) -> Color {
        switch s {
        case .done: return AtlasTheme.accent
        case .current: return AtlasTheme.accent
        case .pending: return AtlasTheme.separator
        }
    }

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

    @ViewBuilder
    var stepDotSpine: some View {
        if !isLast {
            Rectangle().fill(AtlasTheme.accent.opacity(state == .pending ? 0.15 : 0.35))
                .frame(width: 1.5).frame(maxHeight: .infinity)
        }
    }
}

// C19 / cena 02 — "comparar versões" só com planRevisions tipados.

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

    func revisionToggleControl(plan: AtlasExecutionPlan, count: Int) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            withAnimation(reduceMotion ? nil : AtlasMotion.editorial) {
                showRevisions.toggle()
            }
        } label: {
            // Ação fala em sans (mono é hash/recibo/meta — canon §C).
            Text(showRevisions ? "ocultar versões" : "comparar versões · \(count)")
                .atlasSans(11, .medium).foregroundStyle(AtlasTheme.textSecondary)
                .frame(minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(spokenRevisionToggle(expanded: showRevisions, count: count))
        .accessibilityHint(showRevisions ? "toque para ocultar" : "toque para expandir")
        .accessibilityAddTraits(showRevisions ? [.isButton, .isSelected] : .isButton)
    }
}

struct PlanRevisionCompare: View {
    let plan: AtlasExecutionPlan
    let revisions: [AtlasTraceGovernance.PlanRevision]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            comparisonBody
            revisionArchiveList
        }
    }

    enum RevisionTone { case removed, added }

    struct RevisionComparison {
        let revision: AtlasTraceGovernance.PlanRevision
        let left: [String]
        let entered: [String]
        var hasChanges: Bool { !left.isEmpty || !entered.isEmpty }
    }

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

    func hasArchiveMetadata(_ rev: AtlasTraceGovernance.PlanRevision) -> Bool {
        rev.reason?.isEmpty == false || rev.archivedAt != nil || !rev.stepTitles.isEmpty
    }

    func editorialArchivedAt(_ raw: String) -> String {
        if let tIndex = raw.firstIndex(of: "T") {
            return String(raw[..<tIndex])
        }
        return raw
    }

    // MARK: Compare body

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

    @ViewBuilder
    var comparisonLeftList: some View {
        if let comparison = latestComparison, comparison.hasChanges, !comparison.left.isEmpty {
            revisionList(label: "saíram", items: comparison.left, tone: .removed)
        }
    }

    @ViewBuilder
    var comparisonEnteredList: some View {
        if let comparison = latestComparison, comparison.hasChanges, !comparison.entered.isEmpty {
            revisionList(label: "entraram", items: comparison.entered, tone: .added)
        }
    }

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

    // MARK: Lists

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
        .accessibilityLabel("\(label), \(items.count) passo\(items.count == 1 ? "" : "s")")
    }

    @ViewBuilder
    func revisionListItems(items: [String], tone: RevisionTone) -> some View {
        ForEach(items, id: \.self) { item in
            revisionBulletRow(item: item, tone: tone)
        }
    }

    func revisionBulletRow(item: String, tone: RevisionTone) -> some View {
        Text("• \(item)")
            .atlasSans(12)
            .foregroundStyle(tone == .removed ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
            .strikethrough(tone == .removed, color: AtlasTheme.textTertiary.opacity(0.7))
            .lineLimit(2)
            .accessibilityHidden(true)
    }

    // MARK: Archive

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

    func revisionArchiveRow(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            revisionArchiveHeader(rev)
            revisionArchiveMeta(rev)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(revisionArchiveAccessibilityLabel(rev))
    }

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

    @ViewBuilder
    func revisionArchiveMeta(_ rev: AtlasTraceGovernance.PlanRevision) -> some View {
        revisionArchiveReason(rev)
        revisionArchiveWhen(rev)
        revisionArchiveSteps(rev)
    }

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


// Cycle 044 fuse → ExecutionProof.swift

// A PROVA da execução — o que Cursor não mostra: depois da resposta, os passos
// ficam (persistentes, expansíveis), com o Atlas Decide (por que este modelo)
// e o quality gate (a auto-avaliação). Fechado = uma linha discreta.
struct ExecutionProof: View {
    let bubble: ChatBubble
    var artifactItems: [AtlasTraceArtifacts.Item] = []
    var onOpenArtifacts: (TraceID) -> Void = { _ in }
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var open = false
    @State var replayIndex = 0

    var body: some View {
        proofChrome { proofStack }
    }
}

extension ExecutionProof {
    func proofChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.vertical, 8).padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.surface.opacity(0.35))
                    .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
            )
    }
}

extension ExecutionProof {
    var proofStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            collapsedHeader
            if open {
                expandedProofContent
            }
        }
    }
}

extension ExecutionProof {
    /// Passos, decide, quality ou artefatos reais — nunca card vazio pós-conclusão.
    static func shouldDisplay(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = []
    ) -> Bool {
        !bubble.activities.isEmpty
            || bubble.decisionSummary.map(Self.hasDecisionSurface) == true
            || bubble.qualitySummary != nil
            || (!artifactItems.isEmpty && bubble.traceId != nil)
    }
}

extension ExecutionProof {
    var collapsedHeader: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            withAnimation(reduceMotion ? nil : AtlasMotion.editorial) { open.toggle() }
        } label: {
            collapsedHeaderLabel
        }
        .buttonStyle(.plain)
        .accessibilityLabel(spokenCollapsed(expanded: open))
        .accessibilityHint(open ? "toque para fechar a prova" : "toque para expandir a prova")
        .accessibilityAddTraits(open ? [.isButton, .isSelected] : .isButton)
        .accessibilityIdentifier(A11yID.executionProof)
    }
}

extension ExecutionProof {
    var collapsedHeaderLabel: some View {
        HStack(spacing: 10) {
            Circle().fill(AtlasTheme.accent).frame(width: 10, height: 10)
                .accessibilityHidden(true)
            collapsedHeaderSummary
            Spacer(minLength: 0)
            Text(open ? "Fechar" : "Abrir")
                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
        .frame(minHeight: 44)
        .contentShape(Rectangle())
    }
}

extension ExecutionProof {
    @ViewBuilder
    var collapsedHeaderSummary: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("Obra concluída")
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            if !summaryLine.isEmpty {
                Text(summaryLine)
                    .font(.system(.caption)).foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .accessibilityHidden(true)
            }
        }
    }
}

extension ExecutionProof {
    /// Campos publicados pelo ledger — nunca só o rótulo «atlas decide».
    static func hasDecisionSurface(_ d: AtlasDecisionSummary) -> Bool {
        d.selectedProvider != nil
            || d.selectedModel != nil
            || d.reason != nil
            || d.confidenceScore != nil
            || d.riskLevel != nil
            || d.routeMode != nil
            || d.wasOverridden
    }
}

extension ExecutionProof {
    @ViewBuilder
    var artifactsBlock: some View {
        if !artifactItems.isEmpty, let traceId = bubble.traceId {
            artifactsButtonA11y(
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onOpenArtifacts(traceId)
                } label: {
                    artifactsButtonLabel(count: artifactItems.count)
                },
                count: artifactItems.count
            )
        }
    }
}

extension ExecutionProof {
    func artifactsButtonA11y<Content: View>(_ content: Content, count: Int) -> some View {
        content
            .buttonStyle(.plain)
            .accessibilityIdentifier(A11yID.artifactsRow)
            .accessibilityLabel("artefatos desta execução, \(count)")
            .accessibilityHint("abre a lista de artefatos deste trace")
            .accessibilityAddTraits(.isButton)
    }
}

extension ExecutionProof {
    var artifactsChevron: some View {
        Image(systemName: "chevron.right")
            .atlasSans(10, .semibold)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}

extension ExecutionProof {
    func artifactsButtonLabel(count: Int) -> some View {
        HStack(spacing: 6) {
            artifactsButtonLead(count: count)
            artifactsChevron
        }
        .frame(minHeight: 44, alignment: .leading)
        .contentShape(Rectangle())
    }
}

extension ExecutionProof {
    func artifactsButtonLead(count: Int) -> some View {
        HStack(spacing: 6) {
            Text("⎘")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.accent.opacity(0.8))
                .frame(width: 15)
                .accessibilityHidden(true)
            Text("ARTEFATOS (\(count))")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
            Spacer()
        }
    }
}

extension ExecutionProof {
    @ViewBuilder
    var decisionBlock: some View {
        if let d = bubble.decisionSummary, Self.hasDecisionSurface(d) {
            Divider().overlay(AtlasTheme.separatorSoft).accessibilityHidden(true)
            decisionSummaryRow(d)
            decisionReason(d)
        }
    }
}

extension ExecutionProof {
    @ViewBuilder
    func decisionSummaryRow(_ d: AtlasDecisionSummary) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.triangle.branch")
                .atlasSans(11).foregroundStyle(AtlasTheme.accent.opacity(0.8)).frame(width: 15)
                .accessibilityHidden(true)
            Text(decideLine(d))
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(decisionSpoken(d))
    }
}

extension ExecutionProof {
    @ViewBuilder
    var qualityBlock: some View {
        if let q = bubble.qualitySummary {
            HStack(spacing: 6) {
                Image(systemName: "seal")
                    .atlasSans(11).foregroundStyle(qualityColor(q)).frame(width: 15)
                    .accessibilityHidden(true)
                Text(qualityLine(q))
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
            }
            .accessibilityLabel(qualitySpoken(q))
        }
    }

    /// Cor do selo de qualidade — RECONSTRUÍDO pós-merge (vivia private no
    func qualityColor(_ q: AtlasQualitySummary) -> Color {
        q.status.lowercased().contains("pass") || q.score >= 0.7
            ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional
    }

}

extension ExecutionProof {
    @ViewBuilder
    func decisionReason(_ d: AtlasDecisionSummary) -> some View {
        if let r = d.reason, !r.isEmpty {
            Text("\"\(r)\"")
                .font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textSecondary)
                .padding(.leading, 23)
                .accessibilityLabel("motivo, \(r)")
        }
    }
}

extension ExecutionProof {
    @ViewBuilder
    var expandedProofContent: some View {
        VStack(alignment: .leading, spacing: 7) {
            replayScrubber
            activityRows
            decisionBlock
            qualityBlock
            artifactsBlock
        }
        .padding(.top, 8)
        .padding(.leading, 4)
        .transition(reduceMotion ? .identity : .opacity)
        .onChange(of: bubble.activities.count) {
            replayIndex = min(replayIndex, max(0, timestampedActivities.count - 1))
        }
    }
}

extension ExecutionProof {
    func activityRowCell(index: Int, act: AtlasAgentActivity) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: activityIcon(act.kind))
                .atlasSans(11).foregroundStyle(AtlasTheme.accent.opacity(0.8))
                .frame(width: 15)
                .accessibilityHidden(true)
            activityRowCopy(act)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "passo \(index + 1) de \(bubble.activities.count), \(activitySpoken(act))"
        )
    }
}

extension ExecutionProof {
    @ViewBuilder
    var activityRows: some View {
        if !bubble.activities.isEmpty {
            ForEach(Array(bubble.activities.enumerated()), id: \.element.id) { index, act in
                activityRowCell(index: index, act: act)
            }
        }
    }
}

extension ExecutionProof {
    func activityRowCopy(_ act: AtlasAgentActivity) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(act.title)
                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
            if let d = act.detail, !d.isEmpty {
                Text(d).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(2).truncationMode(.middle)
            }
        }
    }
}

extension ExecutionProof {
    func decideLine(_ d: AtlasDecisionSummary) -> String {
        var out = "atlas decide"
        if let m = d.routeMode { out += " · \(m)" }
        if let p = d.selectedProvider { out += " · \(p)" }
        if let c = d.confidenceScore { out += " · conf \(String(format: "%.2f", c))" }
        if d.wasOverridden { out += " · override" }
        return out
    }
}

extension ExecutionProof {
    func qualityLineFlags(_ q: AtlasQualitySummary, base: String) -> String {
        var out = base
        if q.flagCount > 0 { out += " · \(q.flagCount) alertas" }
        if q.actionCount > 0 { out += " · \(q.actionCount) ações" }
        return out
    }
}

extension ExecutionProof {
    func qualitySpoken(_ q: AtlasQualitySummary) -> String {
        var parts = ["qualidade \(String(format: "%.1f", q.score)), status \(q.status)"]
        if q.flagCount > 0 { parts.append("\(q.flagCount) alertas") }
        if q.actionCount > 0 { parts.append("\(q.actionCount) ações de correção") }
        return parts.joined(separator: ", ")
    }
}

extension ExecutionProof {
    func activitySpoken(_ act: AtlasAgentActivity) -> String {
        var parts = [act.title]
        if let d = act.detail, !d.isEmpty { parts.append(d) }
        return parts.joined(separator: ", ")
    }
}

extension ExecutionProof {
    func spokenCollapsedMetricsParts() -> [String] {
        var parts: [String] = []
        if !bubble.activities.isEmpty { parts.append("\(bubble.activities.count) passos") }
        if let ms = bubble.elapsedMs, ms > 0 { parts.append(humanDuration(ms)) }
        if bubble.decisionSummary.map(Self.hasDecisionSurface) == true { parts.append("decisão do atlas") }
        if bubble.qualitySummary != nil { parts.append("avaliação de qualidade") }
        if !artifactItems.isEmpty { parts.append("\(artifactItems.count) artefatos") }
        return parts
    }
}

extension ExecutionProof {
    var spokenCollapsed: String {
        spokenCollapsed(expanded: false)
    }

    func spokenCollapsed(expanded: Bool) -> String {
        (
            ["prova da execução", expanded ? "expandida" : "recolhida"]
            + spokenCollapsedMetricsParts()
        ).joined(separator: ", ")
    }
}

extension ExecutionProof {
    var timestampedActivities: [(activity: AtlasAgentActivity, date: Date)] {
        bubble.activities.compactMap { activity in
            guard let date = AtlasTime.date(activity.occurredAt) else { return nil }
            return (activity, date)
        }
    }
}

extension ExecutionProof {
    var summaryLine: String {
        var parts: [String] = []
        if !bubble.activities.isEmpty { parts.append("\(bubble.activities.count) passos") }
        if let ms = bubble.elapsedMs, ms > 0 { parts.append(humanDuration(ms)) }
        if let q = bubble.qualitySummary { parts.append("quality \(String(format: "%.1f", q.score))") }
        if !artifactItems.isEmpty { parts.append("\(artifactItems.count) artefatos") }
        return parts.joined(separator: " · ")
    }
}

extension ExecutionProof {
    func decisionSpokenRoute(_ d: AtlasDecisionSummary) -> [String] {
        var parts = ["decisão do atlas"]
        if let m = d.routeMode { parts.append("modo \(m)") }
        if let p = d.selectedProvider { parts.append("provedor \(p)") }
        return parts
    }
}

extension ExecutionProof {
    func decisionSpoken(_ d: AtlasDecisionSummary) -> String {
        var parts = decisionSpokenRoute(d)
        if let c = d.confidenceScore { parts.append("confiança \(String(format: "%.2f", c))") }
        if d.wasOverridden { parts.append("substituída manualmente") }
        if let r = d.reason, !r.isEmpty { parts.append("motivo \(r)") }
        return parts.joined(separator: ", ")
    }
}

extension ExecutionProof {
    func qualityLine(_ q: AtlasQualitySummary) -> String {
        let base = "quality \(String(format: "%.1f", q.score)) · \(q.status)"
        return qualityLineFlags(q, base: base)
    }
}

extension ExecutionProof {
    func replaySliderControl(stampedCount: Int) -> some View {
        Slider(value: Binding(
            get: { Double(replayIndex) },
            set: { replayIndex = min(max(0, Int($0.rounded())), stampedCount - 1) }
        ), in: 0...Double(stampedCount - 1), step: 1)
        .tint(AtlasTheme.accent)
        .accessibilityLabel("scrubber de replay da execução")
        .accessibilityValue("passo \(min(replayIndex, stampedCount - 1) + 1) de \(stampedCount)")
    }
}

extension ExecutionProof {
    func replayStepperControl(stampedCount: Int) -> some View {
        Stepper("passo \(min(replayIndex, stampedCount - 1) + 1)", value: Binding(
            get: { replayIndex },
            set: { replayIndex = min(max(0, $0), stampedCount - 1) }
        ), in: 0...(stampedCount - 1))
        .labelsHidden()
        .accessibilityLabel("replay da execução, passo \(min(replayIndex, stampedCount - 1) + 1) de \(stampedCount)")
    }
}

extension ExecutionProof {
    @ViewBuilder
    func replayControls(stampedCount: Int) -> some View {
        if reduceMotion {
            replayStepperControl(stampedCount: stampedCount)
        } else {
            replaySliderControl(stampedCount: stampedCount)
        }
    }
}

extension ExecutionProof {
    func replayScrubberChrome(
        index: Int,
        total: Int,
        selected: (activity: AtlasAgentActivity, date: Date)
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            replayScrubberHeader(index: index, total: total, selected: selected)
            replayControls(stampedCount: total)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.bgRecessed))
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
        .accessibilityIdentifier(A11yID.executionReplayScrubber)
    }
}

extension ExecutionProof {
    @ViewBuilder
    var replayScrubber: some View {
        let stamped = timestampedActivities
        if stamped.count >= 2 {
            let index = min(replayIndex, stamped.count - 1)
            let selected = stamped[index]
            replayScrubberChrome(index: index, total: stamped.count, selected: selected)
        } else if !bubble.activities.isEmpty {
            Text("REPLAY indisponível · eventos sem timestamps")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel("replay indisponível porque os eventos não têm timestamps")
        }
    }
}

extension ExecutionProof {
    func replayScrubberTitle(index: Int, total: Int) -> some View {
        HStack {
            Text("REPLAY")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
            Spacer()
            Text("\(index + 1)/\(total)")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionProof {
    func replayScrubberHeader(
        index: Int,
        total: Int,
        selected: (activity: AtlasAgentActivity, date: Date)
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            replayScrubberTitle(index: index, total: total)
            replayScrubberMeta(selected: selected)
        }
    }
}

extension ExecutionProof {
    func replayScrubberMeta(selected: (activity: AtlasAgentActivity, date: Date)) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(selected.activity.title)
                .font(.system(.caption, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(2)
                .accessibilityHidden(true)
            Text(selected.activity.occurredAt ?? "")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}


// Cycle 044 fuse → ExecutionStateCard.swift

/// Cena operacional do Fable 5: o estado chega pronto do ledger e só então a
/// conversa oferece uma ação. Não há botão, prazo ou risco criado pela casca.
struct ExecutionStateCard: View {
    let state: AtlasExecutionPresentationState
    let jobId: JobID?
    let onChoose: (JobID, String) -> Void
    var retryableJobId: JobID? = nil
    var onRetry: (JobID) -> Void = { _ in }
    var onSteer: (() -> Void)? = nil

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        stateCardChrome { stateCardStack }
    }
}

// Action buttons, style, choices, steer, retry. Cycle 020 fuse.

extension ExecutionStateCard {
    @ViewBuilder
    var actionButtons: some View {
        choiceActionButtons
        steerButton
    }

    @ViewBuilder
    var choiceActionButtons: some View {
        if effectiveChoiceJobId != nil, !state.actions.isEmpty {
            choiceButtonsStack
        } else {
            retryFallbackButton
        }
    }

    @ViewBuilder
    var choiceButtonsStack: some View {
        if let choiceJobId = effectiveChoiceJobId, !state.actions.isEmpty {
            HStack(spacing: 8) {
                ForEach(state.actions) { action in
                    choiceActionButton(action, choiceJobId: choiceJobId)
                }
            }
        }
    }

    func choiceActionButton(_ action: AtlasExecutionPresentationState.Action, choiceJobId: JobID) -> some View {
        Button {
            // Medium: server-declared execution choice is a governed commit.
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onChoose(choiceJobId, action.id)
        } label: {
            Text(action.title)
                .font(.system(.caption, weight: .semibold))
                .lineLimit(1)
                .padding(.horizontal, 11).padding(.vertical, 8)
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(ExecutionStateActionStyle(
            style: action.style,
            reduceMotion: reduceMotion
        ))
        .accessibilityIdentifier(A11yID.executionActionChoice(action.id))
        .accessibilityLabel(action.title)
        .accessibilityHint("ação declarada pelo servidor")
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(action.style == .primary || action.style == .destructive ? 9 : 0)
    }

    @ViewBuilder
    var retryFallbackButton: some View {
        if showsRetryFallback, let retryableJobId {
            retryFallbackAction(retryableJobId)
        }
    }

    @ViewBuilder
    func retryFallbackAction(_ jobId: JobID) -> some View {
        retryFallbackA11y(
            Button {
                // Medium: re-queue failed job is governed.
                AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
                onRetry(jobId)
            } label: {
                retryFallbackLabel
            }
        )
    }

    func retryFallbackA11y<Content: View>(_ content: Content) -> some View {
        content
            .buttonStyle(ExecutionStateActionStyle(
                style: .primary,
                reduceMotion: reduceMotion
            ))
            .accessibilityIdentifier(A11yID.executionRetry)
            .accessibilityLabel("retomar execução a partir do último checkpoint")
            .accessibilityHint("reenfileira o job que falhou")
            .accessibilityAddTraits(.isButton)
            .accessibilitySortPriority(9)
    }

    var retryFallbackLabel: some View {
        Text("Retomar")
            .font(.system(.caption, weight: .semibold))
            .padding(.horizontal, 11).padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(Rectangle())
    }

    @ViewBuilder
    var steerButton: some View {
        if onSteer != nil {
            steerActionButton
        }
    }

    @ViewBuilder
    var steerActionButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onSteer?()
        } label: {
            steerButtonLabel
        }
        .buttonStyle(ExecutionStateActionStyle(
            style: .secondary,
            reduceMotion: reduceMotion
        ))
        .accessibilityLabel("redirecionar esta execução")
        .accessibilityHint("abre instrução para o próximo checkpoint seguro")
        .accessibilityAddTraits(.isButton)
    }

    var steerButtonLabel: some View {
        Text("Redirecionar")
            .font(.system(.caption, weight: .semibold))
            .lineLimit(1)
            .padding(.horizontal, 11).padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 44)
            .contentShape(Rectangle())
    }
}

/// Estilo dos botões de ação do ExecutionStateCard.
struct ExecutionStateActionStyle: ButtonStyle {
    let style: AtlasExecutionPresentationState.ActionStyle
    var reduceMotion: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .background(Capsule().fill(background.opacity(configuration.isPressed ? 0.72 : 1)))
            .overlay(Capsule().stroke(border, lineWidth: 1))
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.97 : 1))
            .animation(
                reduceMotion
                    ? nil
                    : (configuration.isPressed
                        ? .easeOut(duration: AtlasMotion.instinct)
                        : .spring(response: 0.25, dampingFraction: 0.82)),
                value: configuration.isPressed
            )
    }

    var border: Color {
        style == .destructive ? AtlasTheme.domOperacional.opacity(0.55) : AtlasTheme.separator
    }

    var background: Color {
        switch style {
        case .primary: return AtlasTheme.accent
        case .secondary: return AtlasTheme.surfaceHi
        case .destructive: return AtlasTheme.domOperacional.opacity(0.2)
        }
    }

    var foreground: Color {
        style == .primary ? AtlasTheme.bg : AtlasTheme.textPrimary
    }
}

// Awaiting/failed leave/retry predicates + spoken assembly. Cycle 020 fuse.

extension ExecutionStateCard {
    static func copyMentionsCanLeave(_ text: String?) -> Bool {
        guard let text = text?.lowercased() else { return false }
        return text.contains("pode sair")
    }
}

extension ExecutionStateCard {
    /// Cena 13: o motivo falado vem do `detail` publicado pelo servidor.
    var spokenFailureReason: String? {
        guard state.kind == .failed, let detail = state.detail else { return nil }
        return "motivo: \(detail)"
    }

    var failureReasonA11y: String? {
        guard state.kind == .failed, let detail = state.detail else { return nil }
        return "motivo da falha: \(detail)"
    }
}

extension ExecutionStateCard {
    /// «Pode sair» só quando o contrato pausa o timer ou o servidor já publicou essa copy.
    var leaveScreenKicker: String? {
        guard state.kind == .awaitingExternal else { return nil }
        if Self.copyMentionsCanLeave(state.detail) || Self.copyMentionsCanLeave(state.title) {
            return nil
        }
        guard state.timer?.timing == .paused else { return nil }
        return "Você pode sair desta tela"
    }
}

extension ExecutionStateCard {
    var showsRetryFallback: Bool {
        state.kind == .failed
            && state.actions.isEmpty
            && retryableJobId != nil
    }
}

extension ExecutionStateCard {
    func spokenMetaParts(into parts: inout [String]) {
        if let kicker = leaveScreenKicker { parts.append(kicker) }
        if let checkpoint = state.checkpoint { parts.append("checkpoint \(checkpoint)") }
    }
}

extension ExecutionStateCard {
    func spokenReasonParts(into parts: inout [String]) {
        if let reason = spokenFailureReason {
            parts.append(reason)
        } else if let detail = state.detail {
            parts.append(detail)
        }
    }
}

extension ExecutionStateCard {
    func spokenDetailParts(into parts: inout [String]) {
        spokenReasonParts(into: &parts)
        spokenMetaParts(into: &parts)
    }
}

extension ExecutionStateCard {
    func spokenSummaryLead(into parts: inout [String]) {
        if let kind = spokenKind { parts.append(kind) }
        parts.append(state.title)
    }
}

extension ExecutionStateCard {
    func spokenSummaryTail(into parts: inout [String]) {
        spokenDetailParts(into: &parts)
        spokenTimingParts(into: &parts)
    }
}

extension ExecutionStateCard {
    var spokenSummaryText: String {
        var parts: [String] = []
        spokenSummaryLead(into: &parts)
        spokenSummaryTail(into: &parts)
        return parts.joined(separator: ". ")
    }
}

extension ExecutionStateCard {
    func spokenDeadlineParts(into parts: inout [String]) {
        if let deadline = publishedExternalDeadline { parts.append("próxima mudança \(deadline)") }
        if let action = spokenActionFragment { parts.append(action) }
    }
}

extension ExecutionStateCard {
    func spokenTimerPart(into parts: inout [String]) {
        if let fragment = spokenTimerFragment { parts.append(fragment) }
    }
}

extension ExecutionStateCard {
    func spokenTimingParts(into parts: inout [String]) {
        spokenTimerPart(into: &parts)
        spokenDeadlineParts(into: &parts)
    }
}

extension ExecutionStateCard {
    var spokenSummary: String { spokenSummaryText }
}

extension ExecutionStateCard {
    var spokenActionFragment: String? {
        if !state.actions.isEmpty {
            return "\(state.actions.count) ação\(state.actions.count == 1 ? "" : "ões") disponíveis"
        }
        if showsRetryFallback {
            return "retomar disponível"
        }
        return nil
    }
}

extension ExecutionStateCard {
    /// Prazo só na espera externa; o campo `deadline` do contrato não vale para outros kinds.
    var publishedExternalDeadline: String? {
        guard state.kind == .awaitingExternal else { return nil }
        return state.deadline
    }

    /// Job para ações declaradas: atenção usa `jobId`; falha usa `retryableJobId` real.
    var effectiveChoiceJobId: JobID? {
        if let jobId { return jobId }
        if state.kind == .failed { return retryableJobId }
        return nil
    }
}

// Presentation: chrome, header, meta, detail, icon, badge, timers, tint, stack. Cycle 020 fuse.

extension ExecutionStateCard {
    func stateCardChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.card)
                    .fill(AtlasTheme.surface.opacity(0.68))
                    .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).stroke(tint.opacity(0.42), lineWidth: 1))
            )
            // Contain without fused label: choice/retry/steer buttons stay focusable.
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.executionStateCard)
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var detailLine: some View {
        if let detail = state.detail {
            Text(detail)
                .font(.footnote)
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    static func shouldDisplay(state: AtlasExecutionPresentationState) -> Bool {
        if state.kind == .completed,
           state.actions.isEmpty,
           state.detail == nil,
           state.checkpoint == nil,
           state.deadline == nil {
            return false
        }
        return true
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var stateHeaderBadge: some View {
        if let badge = kindBadge {
            Text(badge)
                .font(AtlasFont.mono(10)).tracking(0.8)
                .foregroundStyle(tint)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    var stateHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: icon)
                .atlasSans(13, .semibold)
                .foregroundStyle(tint)
                .accessibilityHidden(true)
            Text(state.title)
                .font(.system(.footnote, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Spacer(minLength: 0)
            stateHeaderBadge
        }
    }
}

extension ExecutionStateCard {
    var iconWait: String? {
        switch state.kind {
        case .attentionRequired: return "exclamationmark.shield"
        case .awaitingExternal: return "hourglass"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var iconAttention: String? {
        if let wait = iconWait { return wait }
        switch state.kind {
        case .recovering: return "arrow.triangle.2.circlepath"
        case .replanning: return "arrow.triangle.branch"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var iconTerminal: String {
        switch state.kind {
        case .failed: return "xmark.octagon"
        case .completed: return "checkmark.seal"
        default: return iconAttention ?? "exclamationmark.shield"
        }
    }
}

extension ExecutionStateCard {
    var icon: String {
        iconAttention ?? iconTerminal
    }

    /// Pure formatter — nonisolated so spoken helpers outside MainActor can call it.
    nonisolated static func clock(_ ms: Int) -> String {
        AtlasTime.formatActiveDuration(milliseconds: ms)
    }
}

extension ExecutionStateCard {
    var kindBadgeWait: String? {
        switch state.kind {
        case .attentionRequired: return "PAUSADO"
        case .awaitingExternal: return "AGUARDANDO"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var kindBadgeAttention: String? {
        if let wait = kindBadgeWait { return wait }
        switch state.kind {
        case .recovering: return "RECONECTANDO"
        case .replanning: return "REPLANEJANDO"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    /// Selo 1:1 com `kind` — nunca copy inventada além do mapeamento canônico.
    var kindBadge: String? {
        switch state.kind {
        case .failed: return "FALHOU"
        case .completed: return nil
        default: return kindBadgeAttention
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder var metaKickerLines: some View {
        if let kicker = leaveScreenKicker {
            Text(kicker)
                .font(.system(.caption, weight: .semibold))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
        if let checkpoint = state.checkpoint {
            Text("checkpoint · \(checkpoint)")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder var metaLines: some View {
        metaKickerLines
        timerMetaLines
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var deadlineMetaLine: some View {
        if let deadline = publishedExternalDeadline {
            Text("Próxima mudança: \(deadline)")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var frozenTimerLine: some View {
        if let frozen = frozenTimerText {
            Text(frozen)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var recoveringTimerLine: some View {
        if frozenTimerText == nil, let active = recoveringTimerText {
            Text(active)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}

extension ExecutionStateCard {
    @ViewBuilder
    var timerMetaLines: some View {
        frozenTimerLine
        recoveringTimerLine
        deadlineMetaLine
    }
}

extension ExecutionStateCard {
    var spokenKindWait: String? {
        switch state.kind {
        case .attentionRequired: return "execução pausada, aguardando decisão"
        case .awaitingExternal: return "aguardando sistema externo"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var spokenKindAttention: String? {
        if let wait = spokenKindWait { return wait }
        switch state.kind {
        case .recovering: return "reconectando"
        case .replanning: return "replanejando"
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var spokenKindTerminal: String {
        switch state.kind {
        case .failed: return "execução falhou"
        case .completed: return "execução concluída"
        default: return spokenKindAttention ?? "execução"
        }
    }
}

extension ExecutionStateCard {
    var spokenKind: String? {
        spokenKindAttention ?? spokenKindTerminal
    }
}

extension ExecutionStateCard {
    var tintAttention: Color? {
        switch state.kind {
        case .attentionRequired: return AtlasTheme.accent
        case .awaitingExternal, .recovering: return AtlasTheme.textSecondary
        default: return nil
        }
    }
}

extension ExecutionStateCard {
    var tint: Color {
        if let attention = tintAttention { return attention }
        switch state.kind {
        case .failed: return AtlasTheme.domOperacional
        case .replanning, .completed: return AtlasTheme.domAutonomos
        default: return AtlasTheme.accent
        }
    }
}

extension ExecutionStateCard {
    var stateCardStack: some View {
        VStack(alignment: .leading, spacing: 10) {
            stateHeader
            detailLine
            metaLines
            actionButtons
        }
    }
}

extension ExecutionStateCard {
    /// Timer congelado (‖) — paridade Island/Lock para `.attentionRequired` e
    /// `.awaitingExternal` quando o servidor publica `timing: paused`.
    var frozenTimerText: String? {
        guard let timer = state.timer, timer.timing == .paused else { return nil }
        switch state.kind {
        case .attentionRequired, .awaitingExternal:
            return "‖ \(Self.clock(timer.elapsedActiveMilliseconds))"
        default:
            return nil
        }
    }
}

extension ExecutionStateCard {
    var frozenTimerA11y: String? {
        guard let timer = state.timer, timer.timing == .paused else { return nil }
        switch state.kind {
        case .attentionRequired, .awaitingExternal:
            return "tempo ativo congelado em \(Self.clock(timer.elapsedActiveMilliseconds))"
        default:
            return nil
        }
    }
}

extension ExecutionStateCard {
    var recoveringTimerText: String? {
        guard state.kind == .recovering, let timer = state.timer else { return nil }
        return "ativo \(Self.clock(timer.elapsedActiveMilliseconds))"
    }

    var spokenTimerFragment: String? {
        frozenTimerA11y ?? recoveringTimerText
    }
}


// Cycle 044 fuse → LiveTimeline.swift

extension LiveTimeline {
    @ViewBuilder
    var timelineBody: some View {
        if baseRows.isEmpty {
            EmptyView()
        } else if rows.isEmpty {
            filterSilenceSurface
        } else {
            timelineSurface
        }
    }
}

// A narrativa viva da execução: cada linha espelha um `AtlasAgentActivity`
// real do contrato C5. Sem agregação inventada, sem placeholder quando vazio.
struct LiveTimeline: View {
    let activities: [AtlasAgentActivity]
    let reduceMotion: Bool
    @State var filter: TimelineReadFilter = .all

    var body: some View {
        timelineBody
    }
}

extension TimelineReadFilter {
    func applyAllOrP90(to rows: [NarrativeRow]) -> [NarrativeRow] {
        switch self {
        case .all:
            return rows
        case .p90:
            return rows.filter(\.isP90)
        default:
            return rows
        }
    }
}

extension TimelineReadFilter {
    func applyStyleFilter(to rows: [NarrativeRow]) -> [NarrativeRow]? {
        switch self {
        case .intent:
            return rows.filter { $0.style == .intent }
        case .tools:
            return rows.filter { $0.style == .single }
        default:
            return nil
        }
    }
}

extension TimelineReadFilter {
    func apply(to rows: [NarrativeRow]) -> [NarrativeRow] {
        if let styled = applyStyleFilter(to: rows) { return styled }
        return applyAllOrP90(to: rows)
    }
}

extension TimelineFilterChips {
    func filterChipA11y<Content: View>(
        _ content: Content,
        option: TimelineReadFilter,
        active: Bool,
        count: Int
    ) -> some View {
        content
            .accessibilityLabel(LiveTimelineA11y.spokenFilterChip(option,
                                                                  count: count,
                                                                  active: active,
                                                                  silent: active && filterSilence))
            .accessibilityHint(LiveTimelineA11y.spokenFilterHint())
            .accessibilityAddTraits(active ? [.isButton, .isSelected] : .isButton)
            .accessibilityIdentifier(A11yID.liveTimelineFilter(option.rawValue))
    }
}

extension TimelineFilterChips {
    func filterChipAction(_ option: TimelineReadFilter) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
            filter = option
        }
    }
}

extension TimelineFilterChips {
    func filterChipButton(_ option: TimelineReadFilter, active: Bool, count: Int) -> some View {
        filterChipA11y(
            Button {
                filterChipAction(option)
            } label: {
                chipLabel(option, active: active)
            }
            .buttonStyle(.plain),
            option: option,
            active: active,
            count: count
        )
    }
}

extension TimelineFilterChips {
    func chipLabel(_ option: TimelineReadFilter, active: Bool) -> some View {
        Text(option.label)
            .font(AtlasFont.mono(9))
            .foregroundStyle(active ? AtlasTheme.accent : AtlasTheme.textTertiary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(minHeight: 44) // HIG interactive minimum
            .background(Capsule().fill(active ? AtlasTheme.goldVeil : AtlasTheme.bgRecessed))
            .overlay(Capsule().stroke(active ? AtlasTheme.goldBorder : AtlasTheme.separatorSoft, lineWidth: 1))
            .contentShape(Capsule())
    }
}

extension TimelineFilterChips {
    @ViewBuilder
    var filterChipLoop: some View {
        ForEach(TimelineReadFilter.allCases) { option in
            let active = option == filter
            let count = option.apply(to: baseRows).count
            filterChipButton(option, active: active, count: count)
        }
    }
}

extension TimelineReadFilter {
    var label: String {
        switch self {
        case .all: return "todos"
        case .intent: return "intenção"
        case .tools: return "ferramentas"
        case .p90: return "p90"
        }
    }
}

enum TimelineReadFilter: String, CaseIterable, Identifiable {
    case all
    case intent
    case tools
    case p90

    var id: String { rawValue }
}

struct TimelineFilterChips: View {
    @Binding var filter: TimelineReadFilter
    var baseRows: [NarrativeRow]
    var reduceMotion: Bool = false
    var filterSilence: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            filterChipLoop
        }
        .padding(.leading, 20)
        .accessibilityIdentifier(A11yID.liveTimelineFilters)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: filter)
    }
}

extension NarrativeRowView {
    var narrativeA11y: some View {
        narrativeBody
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(LiveTimelineA11y.spokenRow(row: row,
                                                           index: index,
                                                           total: total,
                                                           isCurrent: isCurrent))
            .accessibilityValue(LiveTimelineA11y.rowValue(index: index, total: total, isCurrent: isCurrent))
            .accessibilityAddTraits(currentTraits)
    }
}

extension NarrativeRowView {
    var narrativeBody: some View {
        HStack(alignment: .top, spacing: 10) {
            narrativeSpine
            narrativeTextStack
            Spacer(minLength: 0)
        }
    }
}

extension NarrativeRowView {
    @ViewBuilder
    var narrativeDetailLine: some View {
        if let detail = row.detail, !detail.isEmpty {
            Text(detail).font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(row.style == .intent ? 2 : 1)
                .truncationMode(.middle)
                .accessibilityHidden(true)
        }
    }
}

extension NarrativeRowView {
    @ViewBuilder
    var narrativeP90Badge: some View {
        if row.isP90 {
            Text("p90")
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.domOperacional)
        }
    }
}

extension NarrativeRowView {
    @ViewBuilder
    var narrativeDurationChip: some View {
        if let duration = row.durationMs {
            HStack(spacing: 5) {
                Text("Δ \(humanDuration(duration))")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(row.isP90 ? AtlasTheme.domOperacional : AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
                narrativeP90Badge
            }
            .accessibilityHidden(true)
        }
    }
}

extension NarrativeRowView {
    @ViewBuilder
    var narrativeDurationMeta: some View {
        narrativeDurationChip
    }
}

extension NarrativeRowView {
    func narrativePulseLifecycle() -> some View {
        narrativeA11y
            .onAppear {
                if isCurrent && !reduceMotion {
                    withAnimation(AtlasMotion.breath(0.9)) { pulse = true }
                }
            }
            .onChange(of: isCurrent) { _, now in if !now { pulse = false } }
    }
}

struct NarrativeRow: Identifiable, Equatable {
    enum Style { case intent, single }
    let id: String
    let style: Style
    let title: String
    let detail: String?
    let occurredAt: Date?
    var durationMs: Int? = nil
    var isP90: Bool = false
}

extension NarrativeRowView {
    var narrativeSpine: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(isCurrent ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.4))
                .frame(width: 7, height: 7)
                .opacity(isCurrent && pulse && !reduceMotion ? 0.4 : 1)
                .padding(.top, 5)
            if !isLast {
                Rectangle()
                    .fill(AtlasTheme.accent.opacity(0.22))
                    .frame(width: 1.5)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 10)
        .accessibilityHidden(true)
    }
}

extension NarrativeRowView {
    var narrativeTextStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(row.title)
                .font(row.style == .intent ? .system(.footnote) : .system(.caption))
                .foregroundStyle(row.style == .intent
                    ? (isCurrent ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
                    : AtlasTheme.textTertiary)
                .lineLimit(row.style == .intent ? 3 : 2)
                .accessibilityHidden(true)
            narrativeDetailLine
            narrativeDurationMeta
        }
        .padding(.bottom, 10)
    }
}

extension NarrativeRowView {
    var currentTraits: AccessibilityTraits {
        guard isCurrent else { return [] }
        return reduceMotion ? .isSelected : [.isSelected, .updatesFrequently]
    }
}

struct NarrativeRowView: View {
    let row: NarrativeRow
    let index: Int
    let total: Int
    let isCurrent: Bool
    let isLast: Bool
    let reduceMotion: Bool
    @State var pulse = false

    var body: some View {
        narrativePulseLifecycle()
    }
}

enum LiveTimelineA11y {
    static func spokenSectionLabel(stepCount: Int) -> String {
        "orquestra ao vivo, \(stepCount) passo\(stepCount == 1 ? "" : "s")"
    }
}

extension LiveTimelineA11y {
    static func spokenFilterChip(_ filter: TimelineReadFilter,
                                 count: Int,
                                 active: Bool,
                                 silent: Bool) -> String {
        "filtrar timeline por \(filter.label), \(count) passo\(count == 1 ? "" : "s")"
            + spokenFilterChipSuffix(active: active, silent: silent)
    }
}

extension LiveTimelineA11y {
    static func spokenFilterChipSuffix(active: Bool, silent: Bool) -> String {
        var suffix = ""
        if active { suffix += ", selecionado" }
        if silent { suffix += ", nenhum passo neste filtro" }
        return suffix
    }
}

extension LiveTimelineA11y {
    static func spokenFilterHint() -> String {
        "altera quais passos da orquestra são exibidos"
    }
}

extension LiveTimelineA11y {
    static func spokenRow(row: NarrativeRow, index: Int, total: Int, isCurrent: Bool) -> String {
        var parts = ["passo \(index + 1) de \(total)", row.title]
        if let detail = row.detail, !detail.isEmpty { parts.append(detail) }
        if let duration = row.durationMs {
            parts.append("duração \(humanDuration(duration))")
            if row.isP90 { parts.append("acima do p90") }
        }
        if isCurrent { parts.append("passo atual da orquestra") }
        return parts.joined(separator: ", ")
    }
}

extension LiveTimelineA11y {
    static func rowValue(index: Int, total: Int, isCurrent: Bool) -> String {
        isCurrent ? "passo \(index + 1) de \(total), em andamento" : "passo \(index + 1) de \(total)"
    }
}

func activityIconIntent(_ kind: AtlasAgentActivity.Kind) -> String? {
    switch kind {
    case .understanding: return "text.magnifyingglass"
    case .context: return "square.stack.3d.up"
    case .planning: return "list.bullet.rectangle"
    case .permission: return "lock.shield"
    case .reasoning: return "brain"
    default: return nil
    }
}

func activityIconTerminal(_ kind: AtlasAgentActivity.Kind) -> String? {
    switch kind {
    case .completed: return "checkmark.circle.fill"
    case .warning: return "exclamationmark.triangle.fill"
    case .progress: return "ellipsis.circle"
    default: return nil
    }
}

func activityIconTool(_ kind: AtlasAgentActivity.Kind) -> String? {
    switch kind {
    case .executing: return "chevron.left.forwardslash.chevron.right"
    case .reading: return "doc.text"
    case .editing: return "pencil.line"
    case .verifying: return "checkmark.seal"
    case .evidence: return "tray.full"
    default: return nil
    }
}

/// Ícone por kind de atividade (vocabulário estável do contrato C5).

func activityIcon(_ kind: AtlasAgentActivity.Kind) -> String {
    activityIconIntent(kind)
        ?? activityIconTool(kind)
        ?? activityIconTerminal(kind)
        ?? "ellipsis.circle"
}

func annotateNarrativeDurations(_ rows: inout [NarrativeRow]) {
    guard rows.count > 1 else { return }
    for index in rows.indices.dropLast() {
        guard let start = rows[index].occurredAt,
              let end = rows[rows.index(after: index)].occurredAt else { continue }
        rows[index].durationMs = max(0, Int(end.timeIntervalSince(start) * 1000))
    }
    annotateNarrativeP90(&rows)
}

func isNarrativeIntentKind(_ kind: AtlasAgentActivity.Kind) -> Bool {
    [.understanding, .planning, .reasoning, .permission,
     .completed, .warning, .evidence, .verifying].contains(kind)
}

func annotateNarrativeP90(_ rows: inout [NarrativeRow]) {
    let durations = rows.compactMap(\.durationMs).sorted()
    guard !durations.isEmpty else { return }
    let p90Index = min(durations.count - 1, Int(ceil(Double(durations.count) * 0.9)) - 1)
    let threshold = durations[max(0, p90Index)]
    guard threshold > 0 else { return }
    for index in rows.indices {
        rows[index].isP90 = (rows[index].durationMs ?? 0) >= threshold
    }
}

extension LiveTimeline {
    var baseRows: [NarrativeRow] { narrativeRows(from: activities) }
    var rows: [NarrativeRow] { filter.apply(to: baseRows) }
    var showsFilterChips: Bool { baseRows.count > 2 }
    var filterSilence: Bool { showsFilterChips && filter != .all && rows.isEmpty }
}

func narrativeRowMap(from activities: [AtlasAgentActivity]) -> [NarrativeRow] {
    activities.map { activity in
        NarrativeRow(
            id: activity.id,
            style: isNarrativeIntentKind(activity.kind) ? .intent : .single,
            title: activity.title,
            detail: activity.detail,
            occurredAt: AtlasTime.date(activity.occurredAt)
        )
    }
}

// Cada passo espelha um `AtlasAgentActivity` real; a casca não inventa títulos.

/// Projeta atividades reais 1:1 — sem agregar nem renomear ferramentas.
func narrativeRows(from activities: [AtlasAgentActivity]) -> [NarrativeRow] {
    var rows = narrativeRowMap(from: activities)
    annotateNarrativeDurations(&rows)
    return rows
}

extension LiveTimeline {
    func timelineScrollToLast(_ proxy: ScrollViewProxy) {
        guard let last = rows.last?.id else { return }
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            proxy.scrollTo(last, anchor: .bottom)
        }
    }
}

extension LiveTimeline {
    var timelineScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                timelineRows
            }
            .frame(maxHeight: min(CGFloat(rows.count) * 34 + 12, 232))
            .scrollIndicators(.hidden)
            .onChange(of: rows.count) { timelineScrollToLast(proxy) }
            .animation(reduceMotion ? nil : .easeOut(duration: 0.22), value: rows.count)
        }
    }
}

extension LiveTimeline {
    var timelineRows: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.id) { idx, row in
                NarrativeRowView(row: row,
                                 index: idx,
                                 total: rows.count,
                                 isCurrent: idx == rows.count - 1,
                                 isLast: idx == rows.count - 1,
                                 reduceMotion: reduceMotion)
                    .id(row.id)
                    .transition(reduceMotion ? .opacity
                                : .move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.trailing, 4)
    }
}

extension LiveTimeline {
    func filterSilenceA11y<V: View>(_ content: V) -> some View {
        content
            // Contain without fused label: filter chips stay selectable.
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.liveTimelineFilterSilence)
    }
}

extension LiveTimeline {
    @ViewBuilder
    var filterSilenceSurface: some View {
        if showsFilterChips {
            filterSilenceA11y(
                TimelineFilterChips(filter: $filter,
                                    baseRows: baseRows,
                                    reduceMotion: reduceMotion,
                                    filterSilence: filterSilence)
            )
        }
    }
}

extension LiveTimeline {
    var timelineSurface: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showsFilterChips {
                TimelineFilterChips(filter: $filter,
                                    baseRows: baseRows,
                                    reduceMotion: reduceMotion,
                                    filterSilence: false)
            }
            timelineScroll
        }
        // Contain without fused label: chips + step rows stay focusable.
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.liveTimeline)
    }
}
