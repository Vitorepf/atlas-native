import SwiftUI
import UIKit
import AtlasCore

// Scroll throttle gate — peel de ConversationMessages+ScrollAuto.

extension ConversationMessages {
    func shouldAutoScroll(now: CFAbsoluteTime, count: Int) -> Bool {
        let countChanged = count != lastScrollBubbleCount
        return countChanged || now - lastScrollAt >= 0.1
    }
}
