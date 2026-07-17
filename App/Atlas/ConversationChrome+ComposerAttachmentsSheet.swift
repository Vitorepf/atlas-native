import SwiftUI
import PhotosUI
import UIKit

// Revelação progressiva do composer: foto, arquivo, câmera e contexto colado.
// Opções → +Options.
// Chrome → ConversationChrome+ComposerAttachmentsChrome.swift
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
