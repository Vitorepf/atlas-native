import SwiftUI
import AtlasCore

// Upload progress row — peel de ComposerToolbar+AttachmentStripUpload.

extension AttachmentStrip {
    @ViewBuilder
    var uploadProgressRow: some View {
        if let p = uploadPercent {
            uploadProgressStack(p)
        }
    }
}
