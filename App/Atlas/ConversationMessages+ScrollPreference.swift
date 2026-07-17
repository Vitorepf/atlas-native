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
        applyScrollDistancePref(
            content()
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
        )
            .overlay(alignment: .bottomTrailing) {
                scrollFAB(proxy: proxy)
            }
    }
}
