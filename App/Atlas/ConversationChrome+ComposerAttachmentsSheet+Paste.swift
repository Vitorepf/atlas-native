import SwiftUI
import PhotosUI
import UIKit

// Paste + file options — peel de ComposerAttachmentsSheet+Options.

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentFileAndPaste: some View {
        Button { choose(onChooseFile) } label: {
            ComposerAttachmentRow(icon: "doc", title: "Arquivo", subtitle: "PDF, texto, código ou dados")
        }
        .buttonStyle(.plain)
        .accessibilityLabel(ComposerAttachmentsA11y.spokenFile)
        .accessibilityHint(ComposerAttachmentsA11y.spokenFileHint)
        .accessibilityIdentifier(A11yID.attachmentFile)

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

    func choose(_ action: @escaping @MainActor () -> Void) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        dismiss()
        Task { @MainActor in action() }
    }
}
