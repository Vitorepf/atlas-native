import SwiftUI
import AtlasCore

// Scroll stack — peel de ConversationChrome SheetShell.

extension SheetShell {
    var sheetScrollBody: some View {
        VStack(spacing: 0) {
            sheetHandle
            sheetTitle
            ScrollView { VStack(spacing: 0) { content } }
            Spacer(minLength: 0)
        }
    }
}
