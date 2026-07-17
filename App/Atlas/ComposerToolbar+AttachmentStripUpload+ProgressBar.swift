import SwiftUI
import AtlasCore

// Progress bar — peel de ComposerToolbar+AttachmentStripUpload.

extension AttachmentStrip {
    @ViewBuilder
    func uploadProgressBar(_ p: Double) -> some View {
        ProgressView(value: p).tint(AtlasTheme.accent)
    }
}
