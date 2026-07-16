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

    var body: some View {
        HStack(spacing: 8) {
            BreathingDiamond(size: 8, reduceMotion: reduceMotion)
            // C10: com checkpoint REAL do plano, a faixa vira "N/M · etapa".
            // Trace legado (progress nil) não inventa número nem barra.
            if let p = bubble.executionProgress {
                Text("\(p.current)/\(p.total) · \(p.title)")
                    .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
            } else {
                Text("Seguindo a execução")
                    .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
            }
            TimelineView(.periodic(from: .now, by: 1)) { ctx in
                let secs = bubble.startedAt.map { max(0, Int(ctx.date.timeIntervalSince($0))) } ?? 0
                Text("· \(bubble.activities.count) evento\(bubble.activities.count == 1 ? "" : "s") · \(secs)s")
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
            }
            Spacer()
            Button(action: onStop) {
                Text("Parar")
                    .font(.system(.footnote, weight: .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("parar execução")
        }
        .padding(.horizontal, 6)
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
            // A CONSTRUÇÃO AO VIVO — todos os passos empilham conforme chegam
            // (contrato C5: projeção segura). O atual pulsa; os anteriores
            // assentam. É a progressão do Cursor, na gramática do Atlas.
            if !bubble.activities.isEmpty {
                LiveTimeline(activities: bubble.activities, reduceMotion: reduceMotion)
            }
            if !bubble.agents.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(bubble.agents) { AgentRow(agent: $0) }
                }.padding(.leading, 24)
            }
            if let strat = bubble.decideStrategy {
                Text("atlas decide · \(strat)" + (bubble.decideStage.map { " → \($0)" } ?? ""))
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary).padding(.leading, 24)
            }
        }
        .padding(.vertical, 10).padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.surface.opacity(0.5))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
        )
    }
}

struct AgentRow: View {
    let agent: ExecAgent
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
