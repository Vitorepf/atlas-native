import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Review/steer/queue sheets — peel de ConversationSheets+Modifier.

extension ConversationComposerSheetsModifier {
    func reviewSteerQueueSheets<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $reviewTrace) { ref in
                ChangeReviewSheet(reviews: model.reviews, traceId: ref.id)
            }
            .sheet(item: $artifactTrace) { ref in
                ArtifactSheet(reviews: model.reviews, traceId: ref.id)
            }
            .sheet(item: $steerTrace) { ref in
                SteerInteractionSheet(
                    traceId: ref.id,
                    model: model
                ) { instruction, scope in
                    onSteerSubmit(ref.id, instruction, scope)
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showQueueSheet) {
                QueuedFollowUpsSheet(model: model)
            }
    }
}
