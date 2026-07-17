import SwiftUI
import AtlasCore

// O cockpit da execução — faixa no composer, ribbon, narrativa viva e a
// prova persistente. Extraído de ConversationView (mesma linguagem, arquivo próprio).
// Agentes/banners → ConversationCockpit+Agents.swift.

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
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
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
