import SwiftUI
import AtlasCore

// Card padding — peel de ConversationComposer+Card.
// Spoken → ConversationComposer+CardSpoken.swift

extension ConversationComposer {
    var composerCardPadding: EdgeInsets {
        expanded
            ? EdgeInsets(top: 14, leading: 18, bottom: 14, trailing: 18)
            : EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
    }
}
