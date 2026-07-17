import SwiftUI
import PhotosUI
import UIKit

/// Opções da folha de anexos — peel de ComposerAttachmentsSheet (régua ≤100).
/// Paste → ConversationChrome+ComposerAttachmentsSheet+Paste.swift

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

        attachmentFileAndPaste
    }
}
