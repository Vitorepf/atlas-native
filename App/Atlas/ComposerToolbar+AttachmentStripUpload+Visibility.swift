import SwiftUI
import AtlasCore

// Strip visibility — peel de ComposerToolbar+AttachmentStripUpload.

extension AttachmentStrip {
    var isVisible: Bool { !drafts.isEmpty || uploadPercent != nil }
}
