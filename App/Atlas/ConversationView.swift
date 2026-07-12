import SwiftUI
import AtlasCore

// A conversa — a base da comunicação. Metáfora de PÁGINA EDITORIAL, não bolhas
// SaaS: o turno do operador é uma citação com barra bronze; o do Atlas é uma
// página cheia (markdown editorial) com assinatura de provider, feedback
// governado e streaming vivo. Composer com placeholder serif, foco gold e
// pills geral·auto. Tudo respeitando Reduce Motion.
struct ConversationView: View {
    let title: String
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var model: ConversationModel
    @State private var draft = ""
    @State private var effort: AtlasComputeEffort = .auto
    @FocusState private var focused: Bool

    init(client: AtlasClient, threadId: String?, title: String) {
        self.title = title
        _model = State(initialValue: ConversationModel(client: client, threadId: threadId))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                messages
            }
            composer
        }
        .navigationBarHidden(true)
        .overlay(alignment: .top) { toast }
        .task { await model.load() }
        .onAppear { effort = AtlasComputeEffort(rawValue: UserDefaults.standard.string(forKey: "atlas.composer.effort") ?? "") ?? .auto }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
            }
            Spacer()
            Text(title).font(AtlasFont.serif(17, .semibold)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 4)
    }

    // MARK: - Turnos (página editorial)

    private var messages: some View {
        ScrollViewReader { proxy in
            ScrollView {
                if model.bubbles.isEmpty {
                    EmptyConversation(reduceMotion: reduceMotion)
                } else {
                    LazyVStack(alignment: .leading, spacing: 40) {
                        ForEach(model.bubbles) { bubble in
                            EditorialTurn(bubble: bubble, reduceMotion: reduceMotion,
                                          onFeedback: { kind in Task { await model.feedback(bubble.id, kind) } },
                                          onCopy: { copy(bubble.text, label: bubble.role == "user" ? "mensagem" : "resposta") },
                                          onStop: { model.cancel() })
                            .id(bubble.id)
                        }
                        Color.clear.frame(height: 96).id("bottom")
                    }
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, 16)
                }
            }
            .scrollIndicators(.hidden)
            .onChange(of: model.bubbles) {
                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) { proxy.scrollTo("bottom", anchor: .bottom) }
            }
        }
    }

    // MARK: - Composer elevado

    private var composer: some View {
        VStack(spacing: 10) {
            // Pills geral · auto (roteamento + esforço)
            HStack(spacing: 8) {
                pill(label: "geral") { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
                pill(label: effort.shortLabel) {
                    effort = effort.next
                    UserDefaults.standard.set(effort.rawValue, forKey: "atlas.composer.effort")
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
                Spacer()
            }

            HStack(spacing: 10) {
                Image(systemName: "paperclip")
                    .font(.system(size: 17)).foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 30, height: 30)

                ZStack(alignment: .topLeading) {
                    Text(model.bubbles.isEmpty ? "Escreva ao Atlas" : "Continuar com Atlas")
                        .font(AtlasFont.serifItalic(19)).foregroundStyle(AtlasTheme.textTertiary)
                        .allowsHitTesting(false).opacity(draft.isEmpty ? 1 : 0)
                        .offset(y: -1)
                        .animation(.easeOut(duration: 0.28), value: draft.isEmpty)
                    TextField("", text: $draft, axis: .vertical)
                        .font(.system(size: 16)).foregroundStyle(AtlasTheme.textPrimary)
                        .tint(AtlasTheme.accent).lineLimit(1...6).focused($focused)
                }

                sendOrMic
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(
                Capsule(style: .continuous).fill(AtlasTheme.surface)
                    .overlay(Capsule(style: .continuous).stroke(focused ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
            )
            .animation(.easeOut(duration: 0.32), value: focused)
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 28).padding(.bottom, 6)
        .background(
            LinearGradient(colors: [AtlasTheme.bg.opacity(0), AtlasTheme.bg, AtlasTheme.bg], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }

    private var sendOrMic: some View {
        let canSubmit = !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !model.isSending
        return ZStack {
            Image(systemName: "mic.fill")
                .font(.system(size: 17)).foregroundStyle(AtlasTheme.textSecondary)
                .opacity(canSubmit ? 0 : 1).allowsHitTesting(!canSubmit)
            Button(action: send) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 27)).foregroundStyle(AtlasTheme.accent)
            }
            .buttonStyle(.plain)
            .opacity(canSubmit ? 1 : 0).allowsHitTesting(canSubmit)
        }
        .frame(width: 30, height: 30)
        .animation(.easeOut(duration: 0.28), value: canSubmit)
    }

    private func pill(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Circle().fill(AtlasTheme.accent.opacity(0.95)).frame(width: 5.5, height: 5.5)
                Text(label).font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.textSecondary)
            }
            .padding(.horizontal, 11).padding(.vertical, 6)
            .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
        }
        .buttonStyle(PressableScale())
    }

    // MARK: - Toast editorial

    @ViewBuilder private var toast: some View {
        if let t = model.toast {
            Text(t)
                .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textPrimary)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .background(Capsule().fill(AtlasTheme.surfaceHi).overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
                .task {
                    try? await Task.sleep(nanoseconds: 1_400_000_000)
                    withAnimation(AtlasMotion.editorial) { model.toast = nil }
                }
        }
    }

    private func send() {
        let text = draft
        draft = ""
        Task { await model.send(text) }
    }

    private func copy(_ text: String, label: String) {
        UIPasteboard.general.string = text
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(AtlasMotion.editorial) { model.toast = "\(label) copiada" }
    }
}

// MARK: - Um turno (usuário = citação; Atlas = página)

private struct EditorialTurn: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onFeedback: (FeedbackKind) -> Void
    let onCopy: () -> Void
    let onStop: () -> Void
    @State private var placed = false

    var body: some View {
        Group {
            if bubble.role == "user" {
                Text("“\(bubble.text)”")
                    .font(AtlasFont.serifItalic(18)).lineSpacing(8).foregroundStyle(AtlasTheme.textPrimary)
                    .padding(.leading, 16)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 1).fill(AtlasTheme.accent).frame(width: 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    if bubble.streaming {
                        ExecutionRibbon(bubble: bubble, reduceMotion: reduceMotion, onStop: onStop)
                    }
                    if !bubble.text.isEmpty {
                        AtlasMarkdownView(text: bubble.text)
                    }
                    if !bubble.streaming {
                        SignatureLine(provider: bubble.provider, model: bubble.model, elapsedMs: bubble.elapsedMs)
                        FeedbackRow(active: bubble.feedbackAction, onFeedback: onFeedback)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onLongPressGesture(minimumDuration: 0.38) { onCopy() }
            }
        }
        .opacity(placed ? 1 : 0)
        .offset(y: placed ? 0 : 12)
        .onAppear {
            if reduceMotion { placed = true }
            else { withAnimation(AtlasMotion.arrival) { placed = true } }
        }
    }
}

// A assinatura sussurrada: "— claude-sonnet-4-6, em 6,6 s" — o MODELO exato +
// duração (Cursor esconde o modelo). Fraunces italic, atrasada 220ms.
private struct SignatureLine: View {
    let provider: String?
    let model: String?
    let elapsedMs: Int?
    @State private var shown = false
    var body: some View {
        Text(signature)
            .font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.textPrimary.opacity(0.4))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .opacity(shown ? 1 : 0)
            .task {
                try? await Task.sleep(nanoseconds: 220_000_000)
                withAnimation(.easeIn(duration: 0.28)) { shown = true }
            }
    }
    private var signature: String {
        let who = (model?.isEmpty == false && !(model ?? "").hasSuffix("_default")) ? model! : providerWord(provider)
        if let ms = elapsedMs, ms > 0 { return "— \(who), em \(humanDuration(ms))" }
        return "— \(who)"
    }
}

func humanDuration(_ ms: Int) -> String {
    if ms < 1000 { return "um instante" }
    if ms < 60000 { return String(format: "%.1f s", Double(ms) / 1000).replacingOccurrences(of: ".", with: ",") }
    return "\(ms / 60000) min"
}

// Feedback dirigido — treina o roteamento (o que Cursor/Codex não têm).
private struct FeedbackRow: View {
    let active: String?
    let onFeedback: (FeedbackKind) -> Void
    var body: some View {
        HStack(spacing: 8) {
            ForEach(FeedbackKind.allCases) { kind in
                let isActive = active == kind.activeAction
                Button { onFeedback(kind) } label: {
                    Text(isActive ? "\(kind.label) ✓" : kind.label)
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(isActive ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .overlay(Capsule().stroke(isActive ? AtlasTheme.domAutonomos.opacity(0.5) : AtlasTheme.separator, lineWidth: 1))
                }
                .buttonStyle(PressableScale())
            }
            Spacer()
        }
        .padding(.top, 2)
    }
}

// A RIBBON DE EXECUÇÃO — o diferencial vs Cursor. Mostra AO VIVO: quanto tempo,
// a ORQUESTRA (cada agente/provider/modelo + status), o estágio do Atlas Decide,
// e um botão Stop. Cursor mostra 1 agente; o Atlas mostra a máquina inteira.
private struct ExecutionRibbon: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                BreathingDiamond(size: 14, reduceMotion: reduceMotion)
                TimelineView(.periodic(from: .now, by: 1)) { ctx in
                    Text(statusLabel(now: ctx.date))
                        .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textSecondary)
                }
                Spacer()
                Button(action: onStop) {
                    Image(systemName: "stop.fill").font(.system(size: 10))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .frame(width: 26, height: 26).background(Circle().fill(AtlasTheme.surfaceHi))
                }.buttonStyle(.plain)
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
    private func statusLabel(now: Date) -> String {
        let secs = bubble.startedAt.map { max(0, Int(now.timeIntervalSince($0))) } ?? 0
        let working = bubble.agents.contains { $0.status == "processing" } || !bubble.text.isEmpty
        return "\(working ? "Trabalhando" : "Pensando") \(secs)s"
    }
}

private struct AgentRow: View {
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

// Losango bronze respirando (SyncDiamond) — a resposta viva.
private struct BreathingDiamond: View {
    let size: CGFloat
    let reduceMotion: Bool
    @State private var on = false
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(AtlasTheme.accent)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(45))
            .scaleEffect(on ? 1.18 : 1)
            .opacity(on ? 0.45 : 1)
            .onAppear { if !reduceMotion { withAnimation(AtlasMotion.breath(0.9)) { on = true } } else { on = false } }
    }
}

// Botão com press-scale spring (tato físico).
struct PressableScale: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(configuration.isPressed ? .easeOut(duration: 0.12) : .spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// claude_cli → "claude", conselho → "conselho", etc.
func providerWord(_ p: String?) -> String {
    guard let p, !p.isEmpty else { return "atlas" }
    let x = p.lowercased()
    for (k, v) in [("claude", "claude"), ("codex", "codex"), ("gemini", "gemini"),
                   ("hermes", "hermes"), ("minimax", "minimax"),
                   ("council", "conselho"), ("conselho", "conselho")] where x.contains(k) {
        return v
    }
    return x
}

// Empty state vivo: a pergunta contemplativa ✦
private struct EmptyConversation: View {
    let reduceMotion: Bool
    @State private var breathe = false
    var body: some View {
        VStack(spacing: 0) {
            Text("✦")
                .font(AtlasFont.serif(32)).foregroundStyle(AtlasTheme.accent)
                .shadow(color: AtlasTheme.accent.opacity(0.30), radius: 4, y: 1)
                .scaleEffect(breathe ? 1.06 : 1).opacity(breathe ? 0.85 : 1)
            Spacer().frame(height: 40)
            Text("“O que você quer pensar agora?”")
                .font(AtlasFont.serifItalic(22)).lineSpacing(10)
                .multilineTextAlignment(.center).foregroundStyle(AtlasTheme.textPrimary)
        }
        .padding(.horizontal, 32).padding(.top, 140)
        .frame(maxWidth: .infinity)
        .onAppear { if !reduceMotion { withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) { breathe = true } } }
    }
}
