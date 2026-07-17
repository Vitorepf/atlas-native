import SwiftUI
import AtlasCore

// Card + sheets — peel de ConversationComposer (régua ≤100).
// Body → ConversationComposer+CardBody.swift
// Chrome → ConversationComposer+CardChrome.swift
// Surface → ConversationComposer+CardSurface.swift

extension ConversationComposer {
    var composerCard: some View {
        composerCardSheets(composerCardSurface)
    }
}
