import SwiftUI
import AtlasCore

// Composer attachment strip — peel de ConversationComposer+CardStrip.

extension ConversationComposer {
    var composerAttachmentStrip: some View {
        AttachmentStrip(
            drafts: model.drafts,
            reduceMotion: reduceMotion,
            uploadPercent: model.uploadPercent,
            onRemove: { model.removeDraft($0) },
            onFailedTap: { model.toast = $0 }
        )
    }
}
