import SwiftUI
import AtlasCore

// Toggle row — peel de ArenaRunSheet+Controls.
// Label → ArenaRunSheet+ToggleLabel.swift

extension ArenaRunSheet {
    func toggleRow(title: String, subtitle: String?, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            toggleLabel(title: title, subtitle: subtitle, isOn: isOn)
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(toggleAccessibilityLabel(title: title, subtitle: subtitle, isOn: isOn))
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}
