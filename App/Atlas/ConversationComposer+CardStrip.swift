import SwiftUI
import AtlasCore

// Strip + toolbar do composer — peel de ConversationComposer+CardBody.
// Attach → ConversationComposer+CardStrip+Attach.swift
// Toolbar → ConversationComposer+CardStrip+Toolbar.swift

extension ConversationComposer {
    @ViewBuilder
    var composerStripToolbar: some View {
        composerAttachmentOnly
        composerToolbarOnly
    }
}
