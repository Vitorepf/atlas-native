import SwiftUI
import AtlasCore

// Keyboard grabber — peel de ConversationComposer+CardBody.

extension ConversationComposer {
    @ViewBuilder
    var composerCardBodyGrabber: some View {
        keyboardGrabber
    }
}
