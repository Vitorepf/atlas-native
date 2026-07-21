import SwiftUI
import UIKit
import AtlasCore

// FAB gate — peel de ConversationMessages+Scroll.

extension ConversationMessages {
    var showsScrollFAB: Bool { awayFromBottom && !model.bubbles.isEmpty }
}
