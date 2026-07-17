import SwiftUI
import AtlasCore

// Cores + spoken — peel de ArenaEngineIndexRow.
// MetricColors → ArenaEngineIndexRow+A11y+MetricColors.swift
// Spoken → ArenaEngineIndexRow+A11ySpoken.swift

extension ArenaEngineIndexRow {
    func metric(_ label: String, _ value: String, color: Color) -> some View {
        Text("\(label) \(value)")
            .font(AtlasFont.mono(11))
            .foregroundStyle(color)
            .monospacedDigit()
            .accessibilityHidden(true)
    }
}
