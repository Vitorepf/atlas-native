import SwiftUI
import AtlasCore

// Progress row — peel de ComposerToolbar+AttachmentStripUpload+ProgressStack.

extension AttachmentStrip {
    @ViewBuilder
    func uploadProgressRow(_ p: Double) -> some View {
        HStack(spacing: 10) {
            uploadProgressBar(p)
            uploadPercentLabel(p)
        }
    }
}
