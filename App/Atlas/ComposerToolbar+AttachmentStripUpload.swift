import SwiftUI
import AtlasCore

// Upload percent row — peel de ComposerToolbar+AttachmentStrip.
// ProgressBar → ComposerToolbar+AttachmentStripUpload+ProgressBar.swift
// PercentLabel → ComposerToolbar+AttachmentStripUpload+PercentLabel.swift

extension AttachmentStrip {
    @ViewBuilder
    var uploadProgressRow: some View {
        if let p = uploadPercent {
            HStack(spacing: 10) {
                uploadProgressBar(p)
                uploadPercentLabel(p)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("enviando anexos, \(Int(p * 100)) por cento")
        }
    }

    var isVisible: Bool { !drafts.isEmpty || uploadPercent != nil }
}
