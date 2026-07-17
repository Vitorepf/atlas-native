import SwiftUI
import UIKit
import AtlasCore

// Preference + FAB overlay — peel de ConversationMessages+Scroll.

extension ConversationMessages {
    @ViewBuilder
    func scrollPreferenceChrome<Content: View>(
        proxy: ScrollViewProxy,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .onPreferenceChange(BottomDistanceKey.self) { minY in
                guard !model.bubbles.isEmpty else {
                    awayFromBottom = false
                    return
                }
                awayFromBottom = minY > UIScreen.main.bounds.height + 140
            }
            .overlay(alignment: .bottomTrailing) {
                scrollFAB(proxy: proxy)
            }
    }
}
