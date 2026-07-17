import SwiftUI

/// Bounce RM-aware do toggle Arena — peel de ArenaRunSheet+Controls.
struct ArenaToggleSymbolBounce: ViewModifier {
    let enabled: Bool
    let isOn: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.symbolEffect(.bounce, value: isOn)
        } else {
            content
        }
    }
}
