import SwiftUI
import PhotosUI
import UIKit
import AtlasCore

// Os móveis da conversa — turno editorial, empty state, strip de anexos e
// sheets. Extraído de ConversationView (régua da constituição: view enxuta).

struct EditorialTurn: View, Equatable {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onFeedback: (FeedbackKind) -> Void
    let onCopy: () -> Void
    let onStop: () -> Void
    let onExecutionChoice: (JobID, String) -> Void
    var onRetry: (JobID) -> Void = { _ in }
    var artifactItems: [AtlasTraceArtifacts.Item] = []
    var onOpenArtifacts: (TraceID) -> Void = { _ in }
    @State private var placed = false

    // F2.10: igualdade só no que a tela mostra — closures recriadas pelo pai
    // não invalidam o subtree (pare com `.equatable()` no call site).
    nonisolated static func == (lhs: EditorialTurn, rhs: EditorialTurn) -> Bool {
        lhs.bubble == rhs.bubble && lhs.reduceMotion == rhs.reduceMotion && lhs.artifactItems == rhs.artifactItems
    }

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
                    // O PLANO da obra: durante a execução, o roteiro é percorrido
                    // ao vivo (done/atual/pendente); depois, fica como prova.
                    PlanCard(bubble: bubble)
                    if bubble.streaming {
                        ExecutionRibbon(bubble: bubble, reduceMotion: reduceMotion, onStop: onStop)
                    }
                    if let state = bubble.executionPresentationState {
                        ExecutionStateCard(
                            state: state,
                            jobId: bubble.executionChoiceJobId,
                            onChoose: onExecutionChoice,
                            retryableJobId: bubble.retryableJobId,
                            onRetry: onRetry
                        )
                    }
                    let hasProof = !bubble.activities.isEmpty || bubble.decisionSummary != nil || bubble.qualitySummary != nil
                    if !bubble.streaming && hasProof {
                        ExecutionProof(bubble: bubble, artifactItems: artifactItems, onOpenArtifacts: onOpenArtifacts)
                        Text("RESPOSTA FINAL")
                            .font(.system(.caption2, weight: .semibold)).tracking(1.6)
                            .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                    }
                    if !bubble.text.isEmpty {
                        AtlasMarkdownView(text: bubble.text, streaming: bubble.streaming)
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
struct SignatureLine: View {
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
struct FeedbackRow: View {
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

// Empty state vivo: a pergunta contemplativa ✦ + convites REAIS (cada chip
// dispara um envio de verdade — nada decorativo).
struct EmptyConversation: View {
    let reduceMotion: Bool
    /// Assunto da conversa. Ausente = a conversa do Atlas, que é sobre tudo.
    var prompt: String? = nil
    var suggestionsOverride: [String]? = nil
    let onSuggestion: (String) -> Void
    @State private var breathe = false

    init(
        reduceMotion: Bool,
        prompt: String? = nil,
        suggestions: [String]? = nil,
        onSuggestion: @escaping (String) -> Void
    ) {
        self.reduceMotion = reduceMotion
        self.prompt = prompt
        self.suggestionsOverride = suggestions
        self.onSuggestion = onSuggestion
    }

    private var suggestions: [String] {
        suggestionsOverride ?? [
            "O que está rodando no Atlas agora?",
            "Resuma meu dia até aqui",
            "Qual o status dos meus projetos?",
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("✦")
                .font(AtlasFont.serif(32)).foregroundStyle(AtlasTheme.accent)
                .shadow(color: AtlasTheme.accent.opacity(0.30), radius: 4, y: 1)
                .scaleEffect(breathe ? 1.06 : 1).opacity(breathe ? 0.85 : 1)
            Spacer().frame(height: 40)
            Text("“\(prompt ?? "O que você quer pensar agora?")”")
                .font(AtlasFont.serifItalic(22)).lineSpacing(10)
                .multilineTextAlignment(.center).foregroundStyle(AtlasTheme.textPrimary)
            Spacer().frame(height: 44)
            VStack(spacing: 10) {
                ForEach(suggestions, id: \.self) { s in
                    Button { onSuggestion(s) } label: {
                        Text(s)
                            .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textSecondary)
                            .padding(.horizontal, 18).padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Capsule().fill(AtlasTheme.surface)
                                .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1)))
                    }
                    .buttonStyle(PressableScale())
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.horizontal, 32).padding(.top, 120)
        .frame(maxWidth: .infinity)
        .onAppear { if !reduceMotion { withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) { breathe = true } } }
    }
}

// MARK: - Strip de anexos do composer

// A strip renderiza LocalDraft e nada mais (contrato único de UI de anexos).
// Estados legíveis: pronto (borda sutil), subindo (véu + spinner), falhou
// (borda vermelha + ⚠; tocar mostra o motivo). ✕ com alvo de 44pt.
struct DraftStrip: View {
    let drafts: [LocalDraft]
    let reduceMotion: Bool
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(drafts) { d in
                    DraftThumb(draft: d, onRemove: onRemove, onFailedTap: onFailedTap)
                        .transition(reduceMotion ? .opacity
                                    : .scale(scale: 0.86).combined(with: .opacity))
                }
            }
            .padding(.top, 6).padding(.trailing, 6)
        }
        .scrollClipDisabled()   // o ✕ vaza do thumb; sem isto o clip corta o alvo
    }
}

// Decodifica a preview UMA vez por draft (o body roda a cada frame de scroll;
// UIImage(data:) ali dentro custava a fluidez). Cache em memória, chave = id.
@MainActor
private enum DraftThumbCache {
    static let store = NSCache<NSString, UIImage>()
    static func image(for draft: LocalDraft) -> UIImage? {
        if let hit = store.object(forKey: draft.id as NSString) { return hit }
        guard let data = draft.preview, let ui = UIImage(data: data) else { return nil }
        store.setObject(ui, forKey: draft.id as NSString)
        return ui
    }
}

struct DraftThumb: View {
    let draft: LocalDraft
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    private var failedMessage: String? {
        if case .falhou(let m) = draft.state { return m }
        return nil
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            thumb
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(failedMessage != nil ? AtlasTheme.domOperacional.opacity(0.8) : AtlasTheme.separator,
                            lineWidth: failedMessage != nil ? 1.5 : 1))
                .overlay { stateVeil }
                .onTapGesture { if let m = failedMessage { onFailedTap("falhou: \(m)") } }

            if draft.state != .subindo {
                Button { onRemove(draft.id) } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(AtlasTheme.textPrimary, AtlasTheme.bgRecessed)
                        .padding(8)          // alvo ~44pt sem crescer o ícone
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .offset(x: 12, y: -12)
                .accessibilityLabel("remover \(draft.fileName)")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(a11yLabel)
    }

    @ViewBuilder private var thumb: some View {
        if draft.kind == .image, let ui = DraftThumbCache.image(for: draft) {
            Image(uiImage: ui).resizable().scaledToFill()
        } else {
            VStack(spacing: 4) {
                Image(systemName: "doc.fill").font(.system(size: 20)).foregroundStyle(AtlasTheme.textSecondary)
                Text((draft.fileName as NSString).pathExtension.uppercased())
                    .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AtlasTheme.surfaceHi)
        }
    }

    @ViewBuilder private var stateVeil: some View {
        if draft.state == .subindo {
            ZStack { ProgressView().tint(.white) }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black.opacity(0.38))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else if failedMessage != nil {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16))
                .foregroundStyle(AtlasTheme.domOperacional)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(6)
        }
    }

    private var a11yLabel: String {
        let mb = String(format: "%.1f", Double(draft.bytes) / 1_048_576)
        let state: String
        switch draft.state {
        case .pronto: state = "pronto para enviar"
        case .subindo: state = "enviando"
        case .falhou: state = "falhou, toque para ver o motivo"
        }
        return "anexo \(draft.fileName), \(mb) megabytes, \(state)"
    }
}

// MARK: - Sheets (seletores funcionais, tema Atlas)

struct SheetShell<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3).fill(AtlasTheme.textTertiary.opacity(0.5))
                .frame(width: 40, height: 5).padding(.top, 10).padding(.bottom, 16)
            Text(title).font(AtlasFont.serif(20, .semibold)).foregroundStyle(AtlasTheme.textPrimary).padding(.bottom, 14)
            ScrollView { VStack(spacing: 0) { content } }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .background(AtlasTheme.bg.ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .presentationBackground(AtlasTheme.bg)
        .presentationDragIndicator(.hidden)
    }
}

struct SheetRow: View {
    let label: String
    var sub: String? = nil
    let selected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label).font(.system(size: 17)).foregroundStyle(AtlasTheme.textPrimary)
                    if let sub { Text(sub).font(.system(size: 13)).foregroundStyle(AtlasTheme.textTertiary) }
                }
                Spacer()
                if selected { Image(systemName: "checkmark").font(.system(size: 15, weight: .semibold)).foregroundStyle(AtlasTheme.accent) }
            }
            .padding(.horizontal, 24).padding(.vertical, 15).contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) { Divider().overlay(AtlasTheme.separator).padding(.leading, 24) }
    }
}

struct ModeSheet: View {
    @Binding var selected: String
    @Environment(\.dismiss) private var dismiss
    private let modes = [
        ("geral", "Geral", "conversa e raciocínio amplos"),
        ("operacional", "Operacional", "tarefas do dia, decisões, execução"),
        ("autônomos", "Autônomos", "obras longas, agentes em background"),
        ("programação", "Programação", "código em um ou vários repos"),
    ]
    var body: some View {
        SheetShell(title: "Modo") {
            ForEach(modes, id: \.0) { key, label, sub in
                SheetRow(label: label, sub: sub, selected: key == selected) {
                    selected = key; UIImpactFeedbackGenerator(style: .soft).impactOccurred(); dismiss()
                }
            }
        }
    }
}

// Revelação progressiva do composer: foto, arquivo, câmera e contexto colado
// são capacidades reais, mas não ocupam a superfície de escrita o tempo todo.
struct ComposerAttachmentsSheet: View {
    @Binding var pickedPhoto: PhotosPickerItem?
    let onChooseFile: @MainActor () -> Void
    let onChooseCamera: @MainActor () -> Void
    let onPaste: @MainActor (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        SheetShell(title: "Adicionar") {
            PhotosPicker(selection: $pickedPhoto, matching: .images) {
                ComposerAttachmentRow(
                    icon: "photo",
                    title: "Foto",
                    subtitle: "Escolher da biblioteca"
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("escolher foto")

            Button {
                choose(onChooseCamera)
            } label: {
                ComposerAttachmentRow(
                    icon: "camera",
                    title: "Câmera",
                    subtitle: "Capturar agora"
                )
            }
            .buttonStyle(.plain)

            Button {
                choose(onChooseFile)
            } label: {
                ComposerAttachmentRow(
                    icon: "doc",
                    title: "Arquivo",
                    subtitle: "PDF, texto, código ou dados"
                )
            }
            .buttonStyle(.plain)

            Button {
                let text = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines)
                dismiss()
                guard let text, !text.isEmpty else { return }
                Task { @MainActor in onPaste(text) }
            } label: {
                ComposerAttachmentRow(
                    icon: "doc.on.clipboard",
                    title: "Colar contexto",
                    subtitle: "Adicionar texto da área de transferência"
                )
            }
            .buttonStyle(.plain)
        }
        .onChange(of: pickedPhoto) { _, photo in
            if photo != nil { dismiss() }
        }
    }

    private func choose(_ action: @escaping @MainActor () -> Void) {
        dismiss()
        Task { @MainActor in action() }
    }
}

private struct ComposerAttachmentRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(AtlasTheme.accent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 17)).foregroundStyle(AtlasTheme.textPrimary)
                Text(subtitle).font(.system(size: 13)).foregroundStyle(AtlasTheme.textTertiary)
            }
            Spacer()
        }
        .padding(.horizontal, 24).padding(.vertical, 15)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) { Divider().overlay(AtlasTheme.separator).padding(.leading, 24) }
    }
}

struct WorkspaceSheet: View {
    let workspaces: [Workspace]
    let current: String?
    let onPick: (Workspace) -> Void
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        SheetShell(title: "Workspace") {
            if workspaces.isEmpty {
                Text("Nenhum workspace ainda").font(.system(size: 15)).foregroundStyle(AtlasTheme.textTertiary).padding(.top, 40)
            } else {
                ForEach(workspaces) { ws in
                    SheetRow(label: ws.name, sub: "\(ws.count) conversas · main", selected: ws.name == current) {
                        onPick(ws); UIImpactFeedbackGenerator(style: .soft).impactOccurred(); dismiss()
                    }
                }
            }
        }
    }
}
