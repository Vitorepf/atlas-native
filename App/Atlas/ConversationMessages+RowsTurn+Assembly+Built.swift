import SwiftUI
import AtlasCore

// Built editorial turn — peel de ConversationMessages+RowsTurn+Assembly.

extension ConversationMessages {
    func editorialTurnAssemblyBuilt(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item]
    ) -> EditorialTurn {
        editorialTurnAssembly(
            bubble: bubble,
            artifactItems: artifactItems,
            exec: editorialTurnExecTuple(for: bubble),
            steer: editorialTurnSteerTuple
        )
    }
}
