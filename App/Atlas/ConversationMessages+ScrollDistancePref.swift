import SwiftUI
import UIKit
import AtlasCore

// Scroll distance preference — peel de ConversationMessages+ScrollPreference.

extension ConversationMessages {
    func applyScrollDistancePref<Content: View>(_ content: Content) -> some View {
        content.onPreferenceChange(BottomDistanceKey.self) { minY in
            guard !model.bubbles.isEmpty else {
                awayFromBottom = false
                return
            }
            awayFromBottom = minY > UIScreen.main.bounds.height + 140
        }
    }
}
