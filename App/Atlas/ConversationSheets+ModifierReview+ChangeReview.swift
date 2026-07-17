import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Change-review sheets — peel de ConversationSheets+ModifierReview.

extension ConversationComposerSheetsModifier {
    func changeReviewSheets<Content: View>(on content: Content) -> some View {
        content
            .sheet(item: $reviewTrace) { ref in
                ChangeReviewSheet(reviews: model.reviews, traceId: ref.id)
            }
            .sheet(item: $artifactTrace) { ref in
                ArtifactSheet(reviews: model.reviews, traceId: ref.id)
            }
    }
}
