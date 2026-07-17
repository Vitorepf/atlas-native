import SwiftUI
import UIKit
import AtlasCore

// Bubble lifecycle — peel de ConversationMessages+Scroll.

extension ConversationMessages {
    func scrollBubbleEmptyChange(_ empty: Bool) {
        if empty { awayFromBottom = false }
    }

    func scrollBubbleListChange(proxy: ScrollViewProxy) {
        autoScrollToBottom(proxy: proxy)
    }
}
