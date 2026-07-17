import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Review/artifact/queue sheets — peel de ConversationSheets+Modifier.
// Steer → ConversationSheets+ModifierSteer.swift

extension ConversationComposerSheetsModifier {
    func reviewSteerQueueSheets<Content: View>(on content: Content) -> some View {
        steerSheet(on:
            content
                .sheet(item: $reviewTrace) { ref in
                    ChangeReviewSheet(reviews: model.reviews, traceId: ref.id)
                }
                .sheet(item: $artifactTrace) { ref in
                    ArtifactSheet(reviews: model.reviews, traceId: ref.id)
                }
                .sheet(isPresented: $showQueueSheet) {
                    QueuedFollowUpsSheet(model: model)
                }
        )
    }
}
