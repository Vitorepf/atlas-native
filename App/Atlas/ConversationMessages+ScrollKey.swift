import SwiftUI
import UIKit
import AtlasCore

// Preferência de distância do fundo — peel de ConversationMessages+Scroll.

struct BottomDistanceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}
