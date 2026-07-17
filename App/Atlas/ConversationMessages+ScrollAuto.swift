import SwiftUI
import UIKit
import AtlasCore

// Auto-scroll on bubble change — peel de ConversationMessages+Scroll.

extension ConversationMessages {
    func autoScrollToBottom(proxy: ScrollViewProxy) {
        guard !model.bubbles.isEmpty else { return }
        let count = model.bubbles.count
        let now = CFAbsoluteTimeGetCurrent()
        let countChanged = count != lastScrollBubbleCount
        guard countChanged || now - lastScrollAt >= 0.1 else { return }
        lastScrollAt = now
        lastScrollBubbleCount = count
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) {
            proxy.scrollTo("bottom", anchor: .bottom)
        }
    }
}
