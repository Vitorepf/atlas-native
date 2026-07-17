import SwiftUI
import AtlasCore

// Toggle symbol — peel de ArenaRunSheet+ToggleLabel.

extension ArenaRunSheet {
    @ViewBuilder
    func toggleLabelSymbol(isOn: Bool) -> some View {
        Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
            .foregroundStyle(isOn ? AtlasTheme.accent : AtlasTheme.textTertiary)
            .modifier(ArenaToggleSymbolBounce(enabled: !reduceMotion, isOn: isOn))
            .accessibilityHidden(true)
    }
}
