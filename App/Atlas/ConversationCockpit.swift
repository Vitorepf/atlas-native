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

/// Cena operacional do Fable 5: o estado chega pronto do ledger e só então a
/// conversa oferece uma ação. Não há botão, prazo ou risco criado pela casca.
struct ExecutionStateCard: View {
    let state: AtlasExecutionPresentationState
    let jobId: String?
    let onChoose: (String, String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(tint)
                Text(state.title)
                    .font(.system(.footnote, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Spacer(minLength: 0)
                if state.kind == .attentionRequired {
                    Text("PAUSADO")
                        .font(AtlasFont.mono(10)).tracking(0.8)
                        .foregroundStyle(tint)
                }
            }
            if let detail = state.detail {
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let deadline = state.deadline {
                Text("Próxima mudança: \(deadline)")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
            }
            if state.kind == .attentionRequired, let jobId, !state.actions.isEmpty {
                HStack(spacing: 8) {
                    ForEach(state.actions) { action in
                        Button { onChoose(jobId, action.id) } label: {
                            Text(action.title)
                                .font(.system(.caption, weight: .semibold))
                                .lineLimit(1)
                                .padding(.horizontal, 11).padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ExecutionStateActionStyle(style: action.style))
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AtlasTheme.surface.opacity(0.68))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(tint.opacity(0.42), lineWidth: 1))
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.title)
    }

    private var tint: Color {
        switch state.kind {
        case .attentionRequired: return AtlasTheme.accent
        case .awaitingExternal, .recovering: return AtlasTheme.textSecondary
        case .failed: return AtlasTheme.domOperacional
        case .replanning, .completed: return AtlasTheme.domAutonomos
        }
    }

    private var icon: String {
        switch state.kind {
        case .attentionRequired: return "exclamationmark.shield"
        case .awaitingExternal: return "hourglass"
        case .recovering: return "arrow.triangle.2.circlepath"
        case .replanning: return "arrow.triangle.branch"
        case .failed: return "xmark.octagon"
        case .completed: return "checkmark.seal"
        }
    }
}

private struct ExecutionStateActionStyle: ButtonStyle {
    let style: AtlasExecutionPresentationState.ActionStyle

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .background(Capsule().fill(background.opacity(configuration.isPressed ? 0.72 : 1)))
            .overlay(Capsule().stroke(border, lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }

    private var background: Color {
        switch style {
        case .primary: return AtlasTheme.accent
        case .secondary: return AtlasTheme.surfaceHi
        case .destructive: return AtlasTheme.domOperacional.opacity(0.2)
        }
    }

    private var foreground: Color {
        style == .primary ? AtlasTheme.bg : AtlasTheme.textPrimary
    }

    private var border: Color {
        style == .destructive ? AtlasTheme.domOperacional.opacity(0.55) : AtlasTheme.separator
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
    private var statusColor: Color {
        switch agent.status {
        case "processing": return AtlasTheme.accent
        case "succeeded": return AtlasTheme.domAutonomos
        case "failed", "cancelled": return AtlasTheme.domOperacional
        default: return AtlasTheme.textTertiary
        }
    }
    private var statusWord: String {
        switch agent.status {
        case "queued": return "na fila"
        case "processing": return "processando"
        case "succeeded": return "pronto"
        case "failed": return "falhou"
        case "cancelled": return "cancelado"
        case "awaiting_user_choice": return "aguardando"
        default: return agent.status
        }
    }
}

// A NARRATIVA viva da execução (proposta visual aprovada): intenções do
// agente em frase cheia, clusters de ferramentas AGREGADOS ("Explorou 4
// arquivos"), fio vertical costurando os passos, o atual pulsando. Nada
// inventado: só agrega o que o contrato C5 entregou.
struct LiveTimeline: View {
    let activities: [AtlasAgentActivity]
    let reduceMotion: Bool

    // Agrega runs consecutivos de ferramenta do mesmo kind em UMA linha
    // narrada; intenções (understanding/planning/reasoning) passam íntegras.
    private var rows: [NarrativeRow] { narrativeRows(from: activities) }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { idx, row in
                        NarrativeRowView(row: row,
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
            .frame(maxHeight: min(CGFloat(rows.count) * 34 + 12, 232))
            .scrollIndicators(.hidden)
            .onChange(of: rows.count) {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                    proxy.scrollTo(rows.last?.id, anchor: .bottom)
                }
            }
            .animation(reduceMotion ? nil : .easeOut(duration: 0.22), value: rows.count)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("execução ao vivo, \(activities.count) eventos")
    }
}

struct NarrativeRow: Identifiable, Equatable {
    enum Style { case intent, tools, single }
    let id: String
    let style: Style
    let icon: String
    let title: String
    let detail: String?
}

// Colapsa ferramentas consecutivas: [read,read,execute,read] → "Explorou 3
// arquivos e 1 comando". Intenção nunca colapsa — é a voz do agente.
func narrativeRows(from activities: [AtlasAgentActivity]) -> [NarrativeRow] {
    var rows: [NarrativeRow] = []
    var toolRun: [AtlasAgentActivity] = []

    func isIntent(_ a: AtlasAgentActivity) -> Bool {
        [.understanding, .planning, .reasoning, .permission,
         .completed, .warning, .evidence, .verifying].contains(a.kind)
    }
    func flushTools() {
        guard !toolRun.isEmpty else { return }
        if toolRun.count == 1, let only = toolRun.first {
            rows.append(NarrativeRow(id: only.id, style: .single,
                                     icon: activityIcon(only.kind),
                                     title: only.title, detail: only.detail))
        } else {
            let reads = toolRun.filter { $0.kind == .reading }.count
            let execs = toolRun.filter { $0.kind == .executing }.count
            let edits = toolRun.filter { $0.kind == .editing }.count
            var parts: [String] = []
            if reads > 0 { parts.append("\(reads) arquivo\(reads > 1 ? "s" : "")") }
            if execs > 0 { parts.append("\(execs) comando\(execs > 1 ? "s" : "")") }
            if edits > 0 { parts.append("\(edits) edição\(edits > 1 ? "ões" : "")") }
            let last = toolRun.last!
            rows.append(NarrativeRow(id: last.id, style: .tools,
                                     icon: "square.stack.3d.up",
                                     title: "Explorou " + parts.joined(separator: " e "),
                                     detail: last.detail))
        }
        toolRun.removeAll()
    }

    for a in activities {
        if isIntent(a) {
            flushTools()
            rows.append(NarrativeRow(id: a.id, style: .intent,
                                     icon: activityIcon(a.kind),
                                     title: a.title, detail: a.detail))
        } else {
            // ferramenta nova de kind diferente do run atual? mantém no run —
            // o resumo é misto de propósito ("4 arquivos e 3 comandos")
            toolRun.append(a)
            if toolRun.count == 1 || a.id == activities.last?.id { }
        }
    }
    // O run final NÃO colapsa a última ferramenta: ela é o "agora"
    if let current = toolRun.last {
        let previous = toolRun.dropLast()
        if !previous.isEmpty {
            let saved = toolRun; toolRun = Array(previous); flushTools(); _ = saved
        } else { toolRun.removeAll() }
        rows.append(NarrativeRow(id: current.id, style: .single,
                                 icon: activityIcon(current.kind),
                                 title: current.title, detail: current.detail))
    }
    return rows
}

struct NarrativeRowView: View {
    let row: NarrativeRow
    let isCurrent: Bool
    let isLast: Bool
    let reduceMotion: Bool
    @State private var pulse = false

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // O fio: nó + linha vertical costurando a narrativa
            VStack(spacing: 0) {
                Circle()
                    .fill(isCurrent ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.4))
                    .frame(width: 7, height: 7)
                    .opacity(isCurrent && pulse ? 0.4 : 1)
                    .padding(.top, 5)
                if !isLast {
                    Rectangle()
                        .fill(AtlasTheme.accent.opacity(0.22))
                        .frame(width: 1.5)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(row.title)
                    .font(row.style == .intent ? .system(.footnote) : .system(.caption))
                    .foregroundStyle(row.style == .intent
                        ? (isCurrent ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
                        : AtlasTheme.textTertiary)
                    .lineLimit(row.style == .intent ? 3 : 1)
                if row.style == .single, let d = row.detail, !d.isEmpty {
                    Text(d).font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(1).truncationMode(.middle)
                }
            }
            .padding(.bottom, 10)
            Spacer(minLength: 0)
        }
        .onAppear {
            if isCurrent && !reduceMotion {
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) { pulse = true }
            }
        }
        .onChange(of: isCurrent) { _, now in if !now { pulse = false } }
    }
}

// Ícone por kind de atividade (vocabulário estável do contrato C5).
func activityIcon(_ kind: AtlasAgentActivity.Kind) -> String {
    switch kind {
    case .understanding: return "text.magnifyingglass"
    case .context: return "square.stack.3d.up"
    case .planning: return "list.bullet.rectangle"
    case .permission: return "lock.shield"
    case .reasoning: return "brain"
    case .executing: return "chevron.left.forwardslash.chevron.right"
    case .reading: return "doc.text"
    case .editing: return "pencil.line"
    case .verifying: return "checkmark.seal"
    case .evidence: return "tray.full"
    case .completed: return "checkmark.circle.fill"
    case .warning: return "exclamationmark.triangle.fill"
    case .progress: return "ellipsis.circle"
    }
}

// A PROVA da execução — o que Cursor não mostra: depois da resposta, os passos
// ficam (persistentes, expansíveis), com o Atlas Decide (por que este modelo)
// e o quality gate (a auto-avaliação). Fechado = uma linha discreta.
struct ExecutionProof: View {
    let bubble: ChatBubble
    @State private var open = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                withAnimation(.easeOut(duration: 0.22)) { open.toggle() }
            } label: {
                HStack(spacing: 10) {
                    Circle().fill(AtlasTheme.accent).frame(width: 10, height: 10)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Obra concluída")
                            .font(.system(.subheadline, weight: .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Text(summaryLine)
                            .font(.system(.caption)).foregroundStyle(AtlasTheme.textTertiary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                    Text(open ? "Fechar" : "Abrir")
                        .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("prova da execução, \(bubble.activities.count) passos")
            .accessibilityHint(open ? "toque para fechar" : "toque para expandir")

            if open {
                VStack(alignment: .leading, spacing: 7) {
                    ForEach(bubble.activities) { act in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Image(systemName: activityIcon(act.kind))
                                .font(.system(size: 11)).foregroundStyle(AtlasTheme.accent.opacity(0.8))
                                .frame(width: 15)
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
                    if let d = bubble.decisionSummary {
                        Divider().overlay(AtlasTheme.separatorSoft)
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.branch")
                                .font(.system(size: 11)).foregroundStyle(AtlasTheme.accent.opacity(0.8)).frame(width: 15)
                            Text(decideLine(d))
                                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                                .lineLimit(2)
                        }
                        if let r = d.reason, !r.isEmpty {
                            Text("“\(r)”")
                                .font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textSecondary)
                                .padding(.leading, 23)
                        }
                    }
                    if let q = bubble.qualitySummary {
                        HStack(spacing: 6) {
                            Image(systemName: "seal")
                                .font(.system(size: 11)).foregroundStyle(qualityColor(q)).frame(width: 15)
                            Text("quality \(String(format: "%.1f", q.score)) · \(q.status)" +
                                 (q.flagCount > 0 ? " · \(q.flagCount) alertas" : ""))
                                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                        }
                    }
                }
                .padding(.top, 8)
                .padding(.leading, 4)
                .transition(.opacity)
            }
        }
        .padding(.vertical, 8).padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.surface.opacity(0.35))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
        )
    }

    private var summaryLine: String {
        var parts: [String] = []
        if !bubble.activities.isEmpty { parts.append("\(bubble.activities.count) passos") }
        if let ms = bubble.elapsedMs, ms > 0 { parts.append(humanDuration(ms)) }
        if let q = bubble.qualitySummary { parts.append("quality \(String(format: "%.1f", q.score))") }
        return parts.isEmpty ? "provas e histórico preservados" : parts.joined(separator: " · ")
    }

    private func decideLine(_ d: AtlasDecisionSummary) -> String {
        var out = "atlas decide"
        if let m = d.routeMode { out += " · \(m)" }
        if let p = d.selectedProvider { out += " · \(p)" }
        if let c = d.confidenceScore { out += " · conf \(String(format: "%.2f", c))" }
        if d.wasOverridden { out += " · override" }
        return out
    }

    private func qualityColor(_ q: AtlasQualitySummary) -> Color {
        q.status.lowercased().contains("pass") || q.score >= 0.7
            ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional
    }
}
