import SwiftUI
import AtlasCore

// Attachment strip — peel de ConversationComposer+CardStrip.

extension ConversationComposer {
    @ViewBuilder
    var composerAttachmentOnly: some View {
        composerAttachmentStrip
    }
}
