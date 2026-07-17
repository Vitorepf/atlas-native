import SwiftUI
import AtlasCore

// O cockpit da execução — faixa no composer, ribbon, narrativa viva e a
// prova persistente. Extraído de ConversationView (mesma linguagem, arquivo próprio).

// A faixa de execução: UMA linha quieta dentro do card do composer —
// "◆ Seguindo a execução · N eventos · Xs · Parar". Sem caixa própria,
// sem segundo elemento; o campo de escrever permanece vivo logo abaixo.
struct ExecutingStrip: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var onSteer: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 8) {
            BreathingDiamond(size: 8, reduceMotion: reduceMotion)
            // C10: com checkpoint REAL do plano, a faixa vira "N/M · etapa".
            // Trace legado (progress nil) não inventa número nem barra.
            if let p = bubble.executionProgress {
                Text("\(p.current)/\(p.total) · \(p.title)")
                    .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)
            } else if let act = bubble.currentActivity {
                HStack(spacing: 5) {
                    Image(systemName: activityIcon(act.kind))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                        .accessibilityHidden(true)
                    Text(act.title)
                        .font(.system(.footnote))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .layoutPriority(2)
                }
            } else {
                Text("Seguindo a execução")
                    .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                    .layoutPriority(2)
            }
            TimelineView(.periodic(from: .now, by: 1)) { ctx in
                let secs = bubble.startedAt.map { max(0, Int(ctx.date.timeIntervalSince($0))) } ?? 0
                Text("· \(bubble.activities.count) evento\(bubble.activities.count == 1 ? "" : "s") · \(secs)s")
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .modifier(LiveTimelineNumericTransition(enabled: !reduceMotion))
                    .lineLimit(1)
            }
            // C18: pílula +N −M só quando o servidor mediu shortstat no workspace.
            if let stats = bubble.diffStats {
                Text("+\(stats.linesAdded) −\(stats.linesRemoved)")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.accent)
                    .lineLimit(1)
                    .accessibilityLabel("mais \(stats.linesAdded), menos \(stats.linesRemoved) linhas")
            }
            Spacer(minLength: 0)
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
            }
            Button(action: onStop) {
                Text("Parar")
                    .font(.system(.footnote, weight: .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("parar execução")
        }
        .padding(.horizontal, 6)
        .lineLimit(1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(stripAccessibilityLabel)
    }

    private var stripAccessibilityLabel: String {
        if let p = bubble.executionProgress {
            return "execução ao vivo, passo \(p.current) de \(p.total), \(p.title)"
        }
        if let act = bubble.currentActivity {
            return "execução ao vivo, \(act.title), \(bubble.activities.count) eventos"
        }
        return "seguindo a execução, \(bubble.activities.count) eventos"
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
        VStack(alignment: .leading, spacing: 8) {
            if let notice = bubble.reconnectNotice {
                ExecutionBanner(
                    text: notice,
                    icon: "wifi.exclamationmark",
                    tint: AtlasTheme.accent,
                    accessibilityIdentifier: A11yID.executionReconnectBanner
                )
            }
            SilenceWatchdog(bubble: bubble)
            // A CONSTRUÇÃO AO VIVO — todos os passos empilham conforme chegam
            // (contrato C5: projeção segura). O atual pulsa; os anteriores
            // assentam. É a progressão do Cursor, na gramática do Atlas.
            if !bubble.activities.isEmpty {
                LiveTimeline(activities: bubble.activities, reduceMotion: reduceMotion)
            }
            if !bubble.agents.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    if bubble.agents.count >= 2 {
                        Text("LANES")
                            .font(AtlasFont.mono(10))
                            .tracking(1.1)
                            .foregroundStyle(AtlasTheme.textTertiary)
                    }
                    ForEach(bubble.agents) { AgentRow(agent: $0, compactLane: bubble.agents.count >= 2) }
                }.padding(.leading, 24)
            }
            if let strat = bubble.decideStrategy {
                Text("atlas decide · \(strat)" + (bubble.decideStage.map { " → \($0)" } ?? ""))
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary).padding(.leading, 24)
            }
        }
        .padding(.vertical, 10).padding(.horizontal, 14)
        .atlasCard(cornerRadius: 12, fillOpacity: 0.5)
    }
}

struct AgentRow: View {
    let agent: ExecAgent
    var compactLane = false
    var body: some View {
        HStack(spacing: 8) {
            Circle().fill(statusColor).frame(width: 6, height: 6)
            Text(agent.agent ?? providerWord(agent.provider))
                .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textSecondary)
            if let m = agent.model, !m.isEmpty, !m.hasSuffix("_default") {
                Text(m).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary).lineLimit(1)
            }
            Spacer()
            Text(statusWord).font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textTertiary)
        }
        .padding(.vertical, compactLane ? 3 : 0)
        .padding(.horizontal, compactLane ? 8 : 0)
        .background {
            if compactLane {
                Capsule().fill(AtlasTheme.bgRecessed)
            }
        }
    }
    private var turnStatus: AtlasTurnStatus { AtlasTurnStatus(rawValue: agent.status) }
    private var statusColor: Color {
        switch turnStatus {
        case .processing: return AtlasTheme.accent
        case .succeeded: return AtlasTheme.domAutonomos
        case .failed, .cancelled: return AtlasTheme.domOperacional
        default: return AtlasTheme.textTertiary
        }
    }
    private var statusWord: String {
        switch turnStatus {
        case .queued: return "na fila"
        case .processing: return "processando"
        case .succeeded: return "pronto"
        case .failed: return "falhou"
        case .cancelled: return "cancelado"
        case .awaitingUserChoice: return "aguardando"
        case .awaitingExternal: return "aguardando externo"
        case .unknown(let raw): return raw
        }
    }
}

private struct ExecutionBanner: View {
    let text: String
    let icon: String
    let tint: Color
    var accessibilityIdentifier: String?

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(AtlasFont.mono(10))
                .lineLimit(2)
            Spacer(minLength: 0)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(RoundedRectangle(cornerRadius: 10).fill(tint.opacity(0.10)))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(tint.opacity(0.35), lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}

private struct SilenceWatchdog: View {
    let bubble: ChatBubble

    var body: some View {
        TimelineView(.periodic(from: .now, by: 15)) { context in
            if let silence = silenceSeconds(now: context.date), silence > 90 {
                ExecutionBanner(
                    text: "Sem novos eventos há \(silence)s",
                    icon: "timer",
                    tint: AtlasTheme.domOperacional,
                    accessibilityIdentifier: A11yID.executionSilenceWatchdog
                )
                .contentTransition(.numericText())
            }
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
