import SwiftUI
import AtlasCore

// Progress a11y — peel de ComposerToolbar+AttachmentStripUpload+ProgressStack.

extension AttachmentStrip {
    @ViewBuilder
    func uploadProgressA11y<Content: View>(_ content: Content, percent: Double) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel("enviando anexos, \(Int(percent * 100)) por cento")
    }
}
