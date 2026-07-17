import SwiftUI
import UIKit
import AtlasCore

// FAB overlay — peel de ConversationMessages+ScrollPreference.

extension ConversationMessages {
    @ViewBuilder
    func scrollFABOverlay<Content: View>(
        proxy: ScrollViewProxy,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .overlay(alignment: .bottomTrailing) {
                scrollFAB(proxy: proxy)
            }
    }
}
