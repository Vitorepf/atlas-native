import SwiftUI
import UIKit
import AtlasCore

// List change scroll — peel de ConversationMessages+Scroll+BubbleLifecycle.

extension ConversationMessages {
    func scrollBubbleListChange(proxy: ScrollViewProxy) {
        autoScrollToBottom(proxy: proxy)
    }
}
