import SwiftUI
import UIKit
import AtlasCore

// Scroll indicators — peel de ConversationMessages+ScrollPreference.

extension ConversationMessages {
    @ViewBuilder
    func scrollContentIndicators<Content: View>(_ content: Content) -> some View {
        content
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
    }
}
