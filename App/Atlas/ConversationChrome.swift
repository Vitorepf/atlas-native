import SwiftUI
import AtlasCore

// Shell compartilhado dos sheets do composer.
// Turno editorial → EditorialTurn.swift; strip → DraftStrip.swift.
// Seletores → ConversationChrome+ComposerSheets.swift · Row → +SheetRow
// Chrome → ConversationChrome+SheetChrome.swift

struct SheetShell<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(spacing: 0) {
            sheetHandle
            sheetTitle
            ScrollView { VStack(spacing: 0) { content } }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .background(AtlasTheme.bg.ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .presentationBackground(AtlasTheme.bg)
        .presentationDragIndicator(.hidden)
    }
}
