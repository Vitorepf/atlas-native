import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Queue sheet — peel de ConversationSheets+ModifierReview.

extension ConversationComposerSheetsModifier {
    func queueSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showQueueSheet) {
                QueuedFollowUpsSheet(model: model)
            }
    }
}
