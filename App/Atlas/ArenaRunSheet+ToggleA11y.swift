import SwiftUI
import AtlasCore

// Toggle a11y label — peel de ArenaRunSheet+ToggleLabel.

extension ArenaRunSheet {
    func toggleAccessibilityLabel(title: String, subtitle: String?, isOn: Bool) -> String {
        let state = isOn ? "selecionado" : "não selecionado"
        if let subtitle { return "\(title), \(subtitle), \(state)" }
        return "\(title), \(state)"
    }
}
