import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Steer sheet — peel de ConversationSheets+ModifierReview.

extension ConversationComposerSheetsModifier {
    func steerSheet<Content: View>(on content: Content) -> some View {
        content
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
    }
}
