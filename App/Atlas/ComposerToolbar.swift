import AtlasCore
import SwiftUI

// Cycle 030 fuse → ComposerToolbar.swift

// Toolbar do composer: paperclip + campo + trailing (enviar / processando / menu

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

    var body: some View {
        toolbarRow
    }
}

extension ComposerToolbar {
    @ViewBuilder
    var toolbarRowAttach: some View {
        attachButton
    }
}

extension ComposerToolbar {
    @ViewBuilder
    var toolbarRowField: some View {
        composerTextField
    }
}

extension ComposerToolbar {
    @ViewBuilder
    var toolbarRowTrailing: some View {
        trailingControl
    }
}

extension ComposerToolbar {
    var toolbarRow: some View {
        HStack(spacing: 10) {
            toolbarRowAttach
            toolbarRowField
            toolbarRowTrailing
        }
        .accessibilityElement(children: .contain)
    }
}

extension ComposerToolbar {
    var canSubmitFromDraft: Bool {
        let hasText = !model.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasText || !model.drafts.isEmpty
    }
}

extension ComposerToolbar {
    var canSubmitWhileSending: Bool {
        !model.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension ComposerToolbar {
    var canSubmit: Bool {
        if model.isSending || liveBubble != nil {
            return canSubmitWhileSending
        }
        return canSubmitFromDraft
    }
}

extension ComposerToolbar {
    @ViewBuilder
    var composerFieldPlaceholder: some View {
        Text(model.bubbles.isEmpty ? "Escreva ao Atlas" : "Continuar com Atlas")
            .font(AtlasFont.serifItalic(expanded ? 20 : 18)).foregroundStyle(AtlasTheme.textTertiary)
            .allowsHitTesting(false).opacity(model.draftText.isEmpty ? 1 : 0).offset(y: expanded ? 0 : -1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.28), value: model.draftText.isEmpty)
            .accessibilityHidden(true)
    }
}

extension ComposerToolbar {
    var composerTextFieldInput: some View {
        TextField("", text: Binding(
            get: { model.draftText },
            set: { model.updateDraft($0) }
        ), axis: .vertical)
            .font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
            .tint(AtlasTheme.accent).lineLimit(1...6).focused(focused)
            .accessibilityIdentifier(A11yID.conversationInput)
            .accessibilityLabel(spokenInputLabel())
            .accessibilityHint(spokenInputHint())
    }
}

extension ComposerToolbar {
    var composerTextField: some View {
        ZStack(alignment: .topLeading) {
            composerFieldPlaceholder
            composerTextFieldInput
        }
    }
}

extension ComposerToolbar {
    var attachButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onAttach()
        } label: {
            Image(systemName: "paperclip")
                .atlasSans(17, .medium)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("adicionar anexo")
        .accessibilityHint("abre foto, arquivo ou colar")
    }
}
