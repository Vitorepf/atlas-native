import SwiftUI
import AtlasCore

// IDLE-COMPRESS Cockpit body

// --- ConversationCockpit+AgentChrome.swift ---
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

// --- ConversationCockpit+AgentModel.swift ---
extension AgentRow {
    @ViewBuilder
    var agentModelLabel: some View {
        if let m = agent.model, !m.isEmpty, !m.hasSuffix("_default") {
            Text(m).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
        }
    }
}

// --- ConversationCockpit+AgentStatus.swift ---
extension AgentRow {
    var turnStatus: AtlasTurnStatus { AtlasTurnStatus(rawValue: agent.status) }

    var statusColor: Color {
        switch turnStatus {
        case .processing: return AtlasTheme.accent
        case .succeeded: return AtlasTheme.domAutonomos
        case .failed, .cancelled: return AtlasTheme.domOperacional
        default: return AtlasTheme.textTertiary
        }
    }

    var statusWord: String {
        switch turnStatus {
        case .queued: return "na fila"
        case .processing: return "processando"
        case .awaitingUserChoice: return "aguardando"
        case .awaitingExternal: return "aguardando externo"
        case .succeeded: return "pronto"
        case .failed: return "falhou"
        case .cancelled: return "cancelado"
        case .unknown(let raw): return raw
        default: return "—"
        }
    }
}

// --- ConversationCockpit+Agents+Content.swift ---
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

// --- ConversationCockpit+Agents.swift ---
struct AgentRow: View {
    let agent: ExecAgent
    var compactLane = false
    var body: some View {
        agentRowChrome(agentRowContent)
    }
}

// --- ConversationCockpit+ExecutingStrip.swift ---
// MARK: - Conversation live instrument (WAVE-006)
// Uma árvore visual: live · progress · reconnect · stop · steer.
// Reconnect banner (cockpit) e silence watchdog continuam secondary surfaces.

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
        .accessibilityIdentifier(A11yID.executionLiveStrip)
    }

    // MARK: Status

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

    @ViewBuilder
    var stripStatusTitle: some View {
        if bubble.showsReconnectSurface || bubble.executionProgress != nil {
            stripStatusReconnectOrProgress
        } else {
            stripStatusActivityOrIdle
        }
    }

    @ViewBuilder
    var stripStatusReconnectOrProgress: some View {
        if bubble.showsReconnectSurface, let line = bubble.reconnectPrimaryLine {
            Text(line)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(2)
                .accessibilityHidden(true)
        } else if let p = bubble.executionProgress {
            Text("\(p.current)/\(p.total) · \(p.title)")
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(2)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    var stripStatusActivityOrIdle: some View {
        if let act = bubble.currentActivity {
            HStack(spacing: 5) {
                Image(systemName: activityIcon(act.kind))
                    .atlasSans(10, .semibold)
                    .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                    .accessibilityHidden(true)
                Text(act.title)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)
                    .accessibilityHidden(true)
            }
        } else {
            Text("Seguindo a execução")
                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .layoutPriority(2)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    var stripStatusMeta: some View {
        TimelineView(.periodic(from: .now, by: 1)) { ctx in
            let secs = bubble.startedAt.map { max(0, Int(ctx.date.timeIntervalSince($0))) } ?? 0
            Text("· \(bubble.activities.count) evento\(bubble.activities.count == 1 ? "" : "s") · \(secs)s")
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .lineLimit(1)
                .accessibilityHidden(true)
        }
        if let stats = bubble.diffStats {
            Text("+\(stats.linesAdded) −\(stats.linesRemoved)")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.accent)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }

    // MARK: Actions

    @ViewBuilder
    var stripActionButtons: some View {
        if let onSteer {
            Button(action: onSteer) {
                Text("Redirecionar")
                    .font(.system(.footnote, weight: .medium))
                    .foregroundStyle(AtlasTheme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("redirecionar execução")
            .accessibilityHint("abre opções para redirecionar a execução ao vivo")
        }
        Button(action: onStop) {
            Text("Parar")
                .font(.system(.footnote, weight: .medium))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("parar execução")
        .accessibilityHint("interrompe a execução ao vivo")
    }

    // MARK: A11y (phase-aligned compound label)

    var stripAccessibilityLabel: String {
        var parts: [String] = []
        if bubble.showsReconnectSurface {
            parts.append(bubble.reconnectSpokenLabel)
        } else if let p = bubble.executionProgress {
            parts.append("execução ao vivo, passo \(p.current) de \(p.total), \(p.title)")
        } else if let act = bubble.currentActivity {
            parts.append("execução ao vivo, \(act.title)")
        } else {
            parts.append("seguindo a execução")
        }
        let events = bubble.activities.count
        parts.append("\(events) evento\(events == 1 ? "" : "s")")
        if let started = bubble.startedAt {
            let secs = max(0, Int(Date().timeIntervalSince(started)))
            parts.append("\(secs) segundos decorridos")
        }
        if let stats = bubble.diffStats {
            parts.append("mais \(stats.linesAdded), menos \(stats.linesRemoved) linhas")
        }
        return parts.joined(separator: ", ")
    }
}

// --- ConversationCockpit+ExecutionBanner.swift ---
struct ExecutionBanner: View {
    let text: String
    let icon: String
    let tint: Color
    var reduceMotion = false
    /// Quando o container pai compõe o spoken (reconexão, watchdog), o banner fica só visual.
    var embedInParent = false
    var accessibilityIdentifier: String?

    var body: some View {
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
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(tint.opacity(0.10)))
        .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).stroke(tint.opacity(0.35), lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityHidden(embedInParent)
        .accessibilityLabel(ExecutionBannerA11y.spoken(text: text))
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}

// --- ConversationCockpit+Reconnect+Bubble.swift ---
extension ChatBubble {
    var showsReconnectSurface: Bool {
        reconnectNotice != nil
            || (streaming && executionPresentationState?.kind == .recovering)
    }

    /// Linha principal: aviso do stream quando existe; senão título público do ledger.
    var reconnectPrimaryLine: String? {
        if let notice = reconnectNotice { return notice }
        guard streaming, executionPresentationState?.kind == .recovering else { return nil }
        return executionPresentationState?.title
    }

    var reconnectBannerIcon: String {
        executionPresentationState?.kind == .recovering
            ? "arrow.triangle.2.circlepath"
            : "wifi.exclamationmark"
    }

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

    var reconnectActiveTimerMs: Int? {
        guard streaming,
              executionPresentationState?.kind == .recovering,
              let timer = executionPresentationState?.timer
        else { return nil }
        return timer.elapsedActiveMilliseconds
    }

    var reconnectSpokenLabel: String {
        var parts: [String] = []
        if let notice = reconnectNotice {
            parts.append(notice)
        } else if let state = executionPresentationState, state.kind == .recovering {
            parts.append(state.title)
            if let detail = state.detail { parts.append(detail) }
            if let checkpoint = state.checkpoint { parts.append("checkpoint \(checkpoint)") }
        }
        if let ms = reconnectActiveTimerMs {
            parts.append("tempo ativo \(ExecutionStateCard.clock(ms))")
        }
        return parts.isEmpty ? "reconectando" : parts.joined(separator: ". ")
    }
}

// --- ConversationCockpit+Reconnect.swift ---
struct ReconnectBanner: View {
    let bubble: ChatBubble
    let reduceMotion: Bool

    var body: some View {
        if bubble.showsReconnectSurface, let primary = bubble.reconnectPrimaryLine {
            VStack(alignment: .leading, spacing: 4) {
                ExecutionBanner(
                    text: primary,
                    icon: bubble.reconnectBannerIcon,
                    tint: AtlasTheme.textSecondary,
                    reduceMotion: reduceMotion,
                    embedInParent: true
                )
                ForEach(Array(bubble.reconnectSecondaryLines.enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityHidden(true)
                }
                if let ms = bubble.reconnectActiveTimerMs {
                    Text("ativo \(ExecutionStateCard.clock(ms))")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .monospacedDigit()
                        .modifier(NumericTextTransition(enabled: !reduceMotion))
                        .accessibilityHidden(true)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(bubble.reconnectSpokenLabel)
            .accessibilityIdentifier(A11yID.executionReconnectBanner)
        }
    }
}

// ExecutionRibbon → ExecutionRibbon.swift (IDLE-COMPRESS)

// --- ConversationCockpit+Watchdog.swift ---
struct SilenceWatchdog: View {
    let bubble: ChatBubble
    let reduceMotion: Bool

    var tickInterval: TimeInterval { reduceMotion ? 30 : 15 }

    var body: some View {
        TimelineView(.periodic(from: .now, by: tickInterval)) { context in
            silenceGate(now: context.date)
        }
    }

    @ViewBuilder
    private func silenceGate(now: Date) -> some View {
        if bubble.streaming,
           let silence = silenceSeconds(now: now),
           silence > 90 {
            Group {
                ExecutionBanner(
                    text: "Sem novos eventos há \(silence)s",
                    icon: "timer",
                    tint: AtlasTheme.domOperacional,
                    reduceMotion: reduceMotion,
                    embedInParent: true
                )
                .modifier(NumericTextTransition(enabled: !reduceMotion))
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(SilenceWatchdogA11y.spoken(seconds: silence))
            .accessibilityIdentifier(A11yID.executionSilenceWatchdog)
        }
    }

    private func silenceSeconds(now: Date) -> Int? {
        guard bubble.streaming else { return nil }
        let last = bubble.activities.reversed().compactMap { AtlasTime.date($0.occurredAt) }.first
            ?? bubble.startedAt
        guard let last else { return nil }
        return max(0, Int(now.timeIntervalSince(last)))
    }
}

enum SilenceWatchdogA11y {
    static func spoken(seconds: Int) -> String {
        "execução ao vivo sem novos eventos há \(seconds) segundos"
    }
}

