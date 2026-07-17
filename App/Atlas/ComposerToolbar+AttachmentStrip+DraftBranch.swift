import SwiftUI
import AtlasCore

// Draft branch — peel de ComposerToolbar+AttachmentStrip.

extension AttachmentStrip {
    @ViewBuilder
    var attachmentDraftBranch: some View {
        if !drafts.isEmpty {
            DraftStrip(drafts: drafts, reduceMotion: reduceMotion,
                       onRemove: onRemove, onFailedTap: onFailedTap)
        }
    }
}
