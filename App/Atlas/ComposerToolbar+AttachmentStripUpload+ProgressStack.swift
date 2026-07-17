import SwiftUI
import AtlasCore

// Progress stack — peel de ComposerToolbar+AttachmentStripUpload.

extension AttachmentStrip {
    @ViewBuilder
    func uploadProgressStack(_ p: Double) -> some View {
        HStack(spacing: 10) {
            uploadProgressBar(p)
            uploadPercentLabel(p)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("enviando anexos, \(Int(p * 100)) por cento")
    }
}
