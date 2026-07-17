import SwiftUI
import PhotosUI
import UIKit

/// Opções da folha de anexos — peel de ComposerAttachmentsSheet (régua ≤100).

extension ComposerAttachmentsSheet {
    var pasteboardText: String? {
        UIPasteboard.general.string?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nonEmpty
    }

    @ViewBuilder var attachmentOptions: some View {
        PhotosPicker(selection: $pickedPhoto, matching: .images) {
            ComposerAttachmentRow(icon: "photo", title: "Foto", subtitle: "Escolher da biblioteca")
        }
        .buttonStyle(.plain)
        .accessibilityLabel(ComposerAttachmentsA11y.spokenPhoto)
        .accessibilityHint(ComposerAttachmentsA11y.spokenPhotoHint)
        .accessibilityIdentifier(A11yID.attachmentPhoto)

        Button { choose(onChooseCamera) } label: {
            ComposerAttachmentRow(icon: "camera", title: "Câmera", subtitle: "Capturar agora")
        }
        .buttonStyle(.plain)
        .accessibilityLabel(CameraPickerA11y.spokenChooseCamera)
        .accessibilityHint(CameraPickerA11y.spokenChooseCameraHint)
        .accessibilityIdentifier(A11yID.cameraPicker)

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
