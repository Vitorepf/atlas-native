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
    var onShowEffort: () -> Void
    var onSend: () -> Void

    var canSubmit: Bool {
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
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.28), value: model.draftText.isEmpty)
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
}
