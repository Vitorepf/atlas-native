import SwiftUI
import AtlasCore

// Presentation chrome — peel de ConversationChrome SheetShell.

extension SheetShell {
    func sheetPresentationChrome<Content: View>(_ content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .background(AtlasTheme.bg.ignoresSafeArea())
            .presentationDetents([.medium, .large])
            .presentationBackground(AtlasTheme.bg)
            .presentationDragIndicator(.hidden)
    }
}
