import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Modifier chain — peel de ConversationSheets+Modifier.

extension ConversationComposerSheetsModifier {
    func modifierChain(on content: Content) -> some View {
        handoffAndQueueObservers(on:
            attachmentModifiers(on:
                reviewSteerQueueSheets(on:
                    modeEffortSheets(on: content)
                )
            )
        )
    }
}
