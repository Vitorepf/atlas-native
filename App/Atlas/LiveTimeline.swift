import SwiftUI
import AtlasCore

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
