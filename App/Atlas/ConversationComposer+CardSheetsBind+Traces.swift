import SwiftUI
import AtlasCore

// Trace sheet args — peel de ConversationComposer+CardSheetsBind.

extension ConversationComposer {
    var composerCardSheetTraceArgs: (
        reviewTrace: Binding<ConversationReviewTraceRef?>,
        artifactTrace: Binding<ConversationReviewTraceRef?>,
        steerTrace: Binding<ConversationSteerTraceRef?>
    ) {
        (
            reviewTrace: $reviewTrace,
            artifactTrace: $artifactTrace,
            steerTrace: $steerTrace
        )
    }
}
