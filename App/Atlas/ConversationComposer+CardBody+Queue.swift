import SwiftUI
import AtlasCore

// Queue chip — peel de ConversationComposer+CardBody.

extension ConversationComposer {
    @ViewBuilder
    var composerCardBodyQueue: some View {
        queueChipSection
    }
}
