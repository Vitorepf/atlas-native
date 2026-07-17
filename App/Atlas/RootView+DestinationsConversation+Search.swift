import SwiftUI
import AtlasCore

// Search destination — peel de RootView+DestinationsConversation.

extension RootView {
    @ViewBuilder
    var rootConversationSearchDestination: some View {
        SearchView()
    }
}
