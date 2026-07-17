import SwiftUI
import AtlasCore

// Corpo strip+toolbar — peel de ConversationComposer+Card.
// Strip → ConversationComposer+CardStrip.swift

extension ConversationComposer {
    @ViewBuilder
    var composerCardBody: some View {
        composerCardBodyLive
        composerCardBodyQueue
        composerCardBodyGrabber
        composerCardBodyStrip
    }
}
