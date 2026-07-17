import SwiftUI
import AtlasCore

// Upload percent row — peel de ComposerToolbar+AttachmentStrip.
// ProgressBar → ComposerToolbar+AttachmentStripUpload+ProgressBar.swift
// PercentLabel → ComposerToolbar+AttachmentStripUpload+PercentLabel.swift
// ProgressStack → ComposerToolbar+AttachmentStripUpload+ProgressStack.swift

extension AttachmentStrip {
    @ViewBuilder
    var uploadProgressRow: some View {
        if let p = uploadPercent {
            uploadProgressStack(p)
        }
    }

    var isVisible: Bool { !drafts.isEmpty || uploadPercent != nil }
}
