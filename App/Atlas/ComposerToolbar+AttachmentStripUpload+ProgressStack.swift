import SwiftUI
import AtlasCore

// Progress stack — peel de ComposerToolbar+AttachmentStripUpload.
// Row → ComposerToolbar+AttachmentStripUpload+ProgressStack+Row.swift
// A11y → ComposerToolbar+AttachmentStripUpload+ProgressStack+A11y.swift

extension AttachmentStrip {
    @ViewBuilder
    func uploadProgressStack(_ p: Double) -> some View {
        uploadProgressA11y(uploadProgressRow(p), percent: p)
    }
}
