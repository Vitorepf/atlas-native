import SwiftUI
import PhotosUI
import UIKit

// Paste button — peel de ComposerAttachmentsSheet+Paste.

extension ComposerAttachmentsSheet {
    @ViewBuilder var pasteButton: some View {
        Button {
            guard let text = pasteboardText else { return }
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            dismiss()
            Task { @MainActor in onPaste(text) }
        } label: {
            ComposerAttachmentRow(
                icon: "doc.on.clipboard",
                title: "Colar contexto",
                subtitle: pasteboardText == nil
                    ? "Nada na área de transferência"
                    : "Adicionar texto da área de transferência"
            )
        }
        .buttonStyle(.plain)
        .disabled(pasteboardText == nil)
        .accessibilityLabel(ComposerAttachmentsA11y.spokenPaste(hasText: pasteboardText != nil))
        .accessibilityHint(pasteboardText == nil
            ? ComposerAttachmentsA11y.spokenPasteDisabledHint
            : ComposerAttachmentsA11y.spokenPasteHint)
        .accessibilityIdentifier(A11yID.attachmentPaste)
    }
}
