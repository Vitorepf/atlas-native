import SwiftUI
import AtlasCore

// Strip toolbar — peel de ConversationComposer+CardBody.

extension ConversationComposer {
    @ViewBuilder
    var composerCardBodyStrip: some View {
        composerStripToolbar
    }
}
