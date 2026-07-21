import AtlasCore
import Foundation
import SwiftUI

// Cycle 041 fuse → ConversationCockpit+Reconnect.swift

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
