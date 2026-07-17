import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import AtlasCore

// Mode/effort sheets — peel de ConversationSheets+Modifier.

extension ConversationComposerSheetsModifier {
    func modeEffortSheets<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showModeSheet) { ModeSheet(selected: $mode) }
            .sheet(isPresented: $showEffortSheet) { EffortSheet(model: model) }
    }
}
