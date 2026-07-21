import AtlasCore
import Foundation
import SwiftUI

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

struct ExecutingStrip: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var onSteer: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 8) {
            stripStatus
            Spacer(minLength: 0)
            stripActionButtons
        }
        .padding(.horizontal, 6)
        .lineLimit(1)
        .accessibilityElement(children: .contain)
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
            .accessibilityLabel(ExecutionBannerA11y.spoken(text: text))
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
