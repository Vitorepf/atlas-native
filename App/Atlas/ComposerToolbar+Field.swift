import SwiftUI
import AtlasCore

// Campo de texto do composer — peel de ComposerToolbar.
// Attach → ComposerToolbar+FieldAttach.swift

extension ComposerToolbar {
    var composerTextField: some View {
        ZStack(alignment: .topLeading) {
            Text(model.bubbles.isEmpty ? "Escreva ao Atlas" : "Continuar com Atlas")
                .font(AtlasFont.serifItalic(expanded ? 20 : 18)).foregroundStyle(AtlasTheme.textTertiary)
                .allowsHitTesting(false).opacity(model.draftText.isEmpty ? 1 : 0).offset(y: expanded ? 0 : -1)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.28), value: model.draftText.isEmpty)
                .accessibilityHidden(true)
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
}
