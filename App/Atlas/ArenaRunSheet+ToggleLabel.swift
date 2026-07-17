import SwiftUI
import AtlasCore

// Toggle label content — peel de ArenaRunSheet+Toggle.
// A11y → ArenaRunSheet+ToggleA11y.swift
// Subtitle → ArenaRunSheet+ToggleSubtitle.swift
// Symbol → ArenaRunSheet+ToggleLabel+Symbol.swift
// TitleStack → ArenaRunSheet+ToggleLabel+TitleStack.swift

extension ArenaRunSheet {
    func toggleLabel(title: String, subtitle: String?, isOn: Bool) -> some View {
        HStack(spacing: 10) {
            toggleLabelSymbol(isOn: isOn)
            toggleLabelTitleStack(title: title, subtitle: subtitle)
            Spacer()
        }
        .contentShape(Rectangle())
    }
}
