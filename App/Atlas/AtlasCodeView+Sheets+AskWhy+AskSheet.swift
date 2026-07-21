import SwiftUI
import AtlasCore

// Ask card sheet — peel de AtlasCodeView+Sheets+AskWhy.

extension AtlasCodeAskWhySheetsModifier {
    func askWhyAskSheet<Content: View>(on content: Content) -> some View {
        content
            .sheet(isPresented: $showsAskCard) {
                askConversationSheet
            }
    }
}
