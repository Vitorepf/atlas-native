import AtlasCore
import PhotosUI
import SwiftUI

// Cycle 041 fuse → ConversationChrome+ComposerAttachments.swift

extension ComposerAttachmentsSheet {
    var attachmentsSheetChrome: some View {
        SheetShell(title: "Adicionar") {
            attachmentOptions
        }
        .accessibilityIdentifier(A11yID.attachmentsSheet)
        .accessibilityLabel(ComposerAttachmentsA11y.spokenSheet)
        .accessibilityHint(ComposerAttachmentsA11y.spokenSheetHint)
        .onChange(of: pickedPhoto) { _, photo in
            if photo != nil { dismiss() }
        }
    }
}

extension ComposerAttachmentsSheet {
    var pasteboardText: String? {
        UIPasteboard.general.string?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nonEmpty
    }

    @ViewBuilder var attachmentOptions: some View {
        attachmentPhotoOptions
        attachmentFileAndPaste
    }
}

extension ComposerAttachmentsSheet {
    func pasteButtonA11y<V: View>(_ button: V) -> some View {
        button
            .disabled(pasteboardText == nil)
            .accessibilityLabel(ComposerAttachmentsA11y.spokenPaste(hasText: pasteboardText != nil))
            .accessibilityHint(pasteboardText == nil
                ? ComposerAttachmentsA11y.spokenPasteDisabledHint
                : ComposerAttachmentsA11y.spokenPasteHint)
            .accessibilityIdentifier(A11yID.attachmentPaste)
    }
}

extension ComposerAttachmentsSheet {
    func pasteButtonAction() {
        guard let text = pasteboardText else { return }
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        dismiss()
        Task { @MainActor in onPaste(text) }
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentFileOption: some View {
        Button { choose(onChooseFile) } label: {
            ComposerAttachmentRow(icon: "doc", title: "Arquivo", subtitle: "PDF, texto, código ou dados")
        }
        .buttonStyle(.plain)
        .accessibilityLabel(ComposerAttachmentsA11y.spokenFile)
        .accessibilityHint(ComposerAttachmentsA11y.spokenFileHint)
        .accessibilityIdentifier(A11yID.attachmentFile)
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentFileAndPaste: some View {
        attachmentFileOption
        pasteButton
    }

    func choose(_ action: @escaping @MainActor () -> Void) {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        dismiss()
        Task { @MainActor in action() }
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var pasteButton: some View {
        pasteButtonA11y(
            Button {
                pasteButtonAction()
            } label: {
                pasteButtonLabel
            }
            .buttonStyle(.plain)
        )
    }
}

extension ComposerAttachmentsSheet {
    var pasteButtonLabel: some View {
        ComposerAttachmentRow(
            icon: "doc.on.clipboard",
            title: "Colar contexto",
            subtitle: pasteboardText == nil
                ? "Nada na área de transferência"
                : "Adicionar texto da área de transferência"
        )
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentCameraOption: some View {
        Button { choose(onChooseCamera) } label: {
            ComposerAttachmentRow(icon: "camera", title: "Câmera", subtitle: "Capturar agora")
        }
        .buttonStyle(.plain)
        .accessibilityLabel(CameraPickerA11y.spokenChooseCamera)
        .accessibilityHint(CameraPickerA11y.spokenChooseCameraHint)
        .accessibilityIdentifier(A11yID.cameraPicker)
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentPhotoOption: some View {
        PhotosPicker(selection: $pickedPhoto, matching: .images) {
            ComposerAttachmentRow(icon: "photo", title: "Foto", subtitle: "Escolher da biblioteca")
        }
        .buttonStyle(.plain)
        .accessibilityLabel(ComposerAttachmentsA11y.spokenPhoto)
        .accessibilityHint(ComposerAttachmentsA11y.spokenPhotoHint)
        .accessibilityIdentifier(A11yID.attachmentPhoto)
    }
}

extension ComposerAttachmentsSheet {
    @ViewBuilder var attachmentPhotoOptions: some View {
        attachmentPhotoOption
        attachmentCameraOption
    }
}

// Revelação progressiva do composer: foto, arquivo, câmera e contexto colado.
struct ComposerAttachmentsSheet: View {
    @Binding var pickedPhoto: PhotosPickerItem?
    let onChooseFile: @MainActor () -> Void
    let onChooseCamera: @MainActor () -> Void
    let onPaste: @MainActor (String) -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        attachmentsSheetChrome
    }
}

extension ComposerAttachmentRow {
    var attachmentRowIcon: some View {
        Image(systemName: icon)
            .atlasSans(17, .medium)
            .foregroundStyle(AtlasTheme.accent)
            .frame(width: 28)
            .accessibilityHidden(true)
    }
}

extension ComposerAttachmentRow {
    var attachmentRowTextStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).atlasSans(17).foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(subtitle).atlasSans(13).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

extension ComposerAttachmentRow {
    var attachmentRowCopy: some View {
        HStack(spacing: 14) {
            attachmentRowIcon
            attachmentRowTextStack
            Spacer()
        }
        .padding(.horizontal, 24).padding(.vertical, 15)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) { Divider().overlay(AtlasTheme.separator).padding(.leading, 24) }
    }
}

struct ComposerAttachmentRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        attachmentRowCopy
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(title), \(subtitle)")
    }
}
