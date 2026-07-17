import SwiftUI
import UIKit
import AtlasCore

// Empty list change — peel de ConversationMessages+Scroll+BubbleLifecycle.

extension ConversationMessages {
    func scrollBubbleEmptyChange(_ empty: Bool) {
        if empty { awayFromBottom = false }
    }
}
