import SwiftUI
import AtlasCore

// Toolbar do composer: paperclip + campo + trailing (enviar / processando / menu
// de modo·esforço·workspace). Peel de ConversationComposer (régua <200).

struct ComposerToolbar: View {
    var model: ConversationModel
    var reduceMotion: Bool
    var focused: FocusState<Bool>.Binding
    var expanded: Bool
    var mode: String
    var liveBubble: ChatBubble?
    var onAttach: () -> Void
    var onShowWorkspace: () -> Void
    var onShowMode: () -> Void
    var onSend: () -> Void

    private var canSubmit: Bool {
        let hasText = !model.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if model.isSending || liveBubble != nil {
            return hasText
        }
        return hasText || !model.drafts.isEmpty
    }

    var body: some View {
        HStack(spacing: 10) {
            Button {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                onAttach()
            } label: {
                Image(systemName: "paperclip")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("adicionar anexo")
            ZStack(alignment: .topLeading) {
                Text(model.bubbles.isEmpty ? "Escreva ao Atlas" : "Continuar com Atlas")
                    .font(AtlasFont.serifItalic(expanded ? 20 : 18)).foregroundStyle(AtlasTheme.textTertiary)
                    .allowsHitTesting(false).opacity(model.draftText.isEmpty ? 1 : 0).offset(y: expanded ? 0 : -1)
                    .animation(.easeOut(duration: 0.28), value: model.draftText.isEmpty)
                TextField("", text: Binding(
                    get: { model.draftText },
                    set: { model.updateDraft($0) }
                ), axis: .vertical)
                    .font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                    .tint(AtlasTheme.accent).lineLimit(1...6).focused(focused)
                    .accessibilityIdentifier(A11yID.conversationInput)
            }
            trailingControl
        }
    }

    // Contexto fica atrás de uma única ação real. O modo, o esforço e o
    // workspace continuam disponíveis, sem disputar a atenção da escrita.
    @ViewBuilder private var trailingControl: some View {
        if canSubmit {
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 29))
                    .foregroundStyle(AtlasTheme.accent)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.return, modifiers: .command)
            .accessibilityLabel(model.isSending ? "adicionar à fila" : "enviar ao Atlas")
        } else if model.isSending {
            BreathingDiamond(size: 13, reduceMotion: reduceMotion)
                .frame(width: 32, height: 32)
                .accessibilityLabel("Atlas processando")
        } else {
            Menu {
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    onShowWorkspace()
                } label: {
                    Label("Workspace: \(model.workspaceName ?? "Atlas")", systemImage: "square.grid.2x2")
                }
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    onShowMode()
                } label: {
                    Label("Modo: \(mode.capitalized)", systemImage: "slider.horizontal.3")
                }
                Button {
                    model.cycleEffort()
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    Label("Esforço: \(model.effort.shortLabel)", systemImage: "gauge.with.dots.needle.33percent")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 32, height: 32)
                    .contentShape(Circle())
            }
            .accessibilityLabel("opções da conversa")
        }
    }
}

// Faixa de anexos + progresso de upload — contrato LocalDraft / uploadPercent.
struct AttachmentStrip: View {
    let drafts: [LocalDraft]
    let reduceMotion: Bool
    let uploadPercent: Double?
    let onRemove: (String) -> Void
    let onFailedTap: (String) -> Void

    var body: some View {
        Group {
            if !drafts.isEmpty {
                DraftStrip(drafts: drafts, reduceMotion: reduceMotion,
                           onRemove: onRemove, onFailedTap: onFailedTap)
            }
            if let p = uploadPercent {
                HStack(spacing: 10) {
                    ProgressView(value: p).tint(AtlasTheme.accent)
                    Text("\(Int(p * 100))%")
                        .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                        .monospacedDigit()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("enviando anexos, \(Int(p * 100)) por cento")
            }
        }
    }
}
