import SwiftUI
import AtlasCore

// Steer callback tuple — peel de ConversationMessages+RowsTurn+Assembly.

extension ConversationMessages {
    var editorialTurnSteerTuple: (
        onSteer: (TraceID) -> Void,
        onOpenArtifacts: (TraceID) -> Void
    ) {
        editorialTurnSteerArtifactsCallbacks()
    }
}
