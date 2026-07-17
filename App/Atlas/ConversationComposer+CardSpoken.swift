import SwiftUI
import AtlasCore

// Spoken label — peel de ConversationComposer+CardChrome.

extension ConversationComposer {
    var composerCardSpokenLabel: String {
        ConversationComposerA11y.spokenCard(
            expanded: expanded,
            draftCount: model.drafts.count,
            queueCount: model.queuedMessages.count,
            isSending: model.isSending
        )
    }
}
