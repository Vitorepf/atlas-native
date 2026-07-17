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
        scrollFABOverlay(proxy: proxy) {
            scrollContentIndicators(
                applyScrollDistancePref(content())
            )
        }
    }
}
