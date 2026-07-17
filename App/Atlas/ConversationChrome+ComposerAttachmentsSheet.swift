import SwiftUI
import PhotosUI
import UIKit

// Revelação progressiva do composer: foto, arquivo, câmera e contexto colado
// são capacidades reais, mas não ocupam a superfície de escrita o tempo todo.
struct ComposerAttachmentsSheet: View {
    @Binding var pickedPhoto: PhotosPickerItem?
    let onChooseFile: @MainActor () -> Void
    let onChooseCamera: @MainActor () -> Void
    let onPaste: @MainActor (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var pasteboardText: String? {
        UIPasteboard.general.string?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nonEmpty
    }

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
            .accessibilityLabel(ComposerAttachmentsA11y.spokenPhoto)
            .accessibilityHint(ComposerAttachmentsA11y.spokenPhotoHint)
            .accessibilityIdentifier(A11yID.attachmentPhoto)

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
            .accessibilityLabel(CameraPickerA11y.spokenChooseCamera)
            .accessibilityHint(CameraPickerA11y.spokenChooseCameraHint)
            .accessibilityIdentifier(A11yID.cameraPicker)

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
            .accessibilityLabel(ComposerAttachmentsA11y.spokenFile)
            .accessibilityHint(ComposerAttachmentsA11y.spokenFileHint)
            .accessibilityIdentifier(A11yID.attachmentFile)

            Button {
                guard let text = pasteboardText else { return }
                if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
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
        .accessibilityIdentifier(A11yID.attachmentsSheet)
        .accessibilityLabel(ComposerAttachmentsA11y.spokenSheet)
        .accessibilityHint(ComposerAttachmentsA11y.spokenSheetHint)
        .onChange(of: pickedPhoto) { _, photo in
            if photo != nil { dismiss() }
        }
    }

    private func choose(_ action: @escaping @MainActor () -> Void) {
        if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
        dismiss()
        Task { @MainActor in action() }
    }
}
