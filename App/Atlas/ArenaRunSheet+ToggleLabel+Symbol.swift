import SwiftUI
import AtlasCore

// Toggle symbol — peel de ArenaRunSheet+ToggleLabel.

extension ArenaRunSheet {
    @ViewBuilder
    func toggleLabelSymbol(isOn: Bool) -> some View {
        ArenaPremiumIcon(
            symbol: isOn ? "checkmark.circle" : "circle",
            tone: isOn ? .active : .muted
        )
            .modifier(ArenaToggleSymbolBounce(enabled: !reduceMotion, isOn: isOn))
    }
}
