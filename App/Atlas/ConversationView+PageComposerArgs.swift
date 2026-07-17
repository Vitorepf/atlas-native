import SwiftUI
import PhotosUI
import AtlasCore

// ConversationComposer args — peel de ConversationView+PageComposerCard.
// Core → ConversationView+PageComposerArgs+Core.swift
// Bindings → ConversationView+PageComposerArgs+Bindings.swift

extension ConversationView {
    var conversationComposerArgs: ConversationComposer {
        conversationComposerCoreArgs(bindings: conversationComposerSheetBindings)
    }
}
