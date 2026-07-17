import SwiftUI
import Charts
import AtlasCore

// Title + score row — peel de ArenaEngineIndexRow.
// Coverage → ArenaEngineIndexRow+Coverage.swift
// Trailing → ArenaEngineIndexRow+TitleTrailing.swift

extension ArenaEngineIndexRow {
    var titleRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(engine.engine)
                .font(.system(.body, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .accessibilityHidden(true)
            Spacer(minLength: 8)
            titleTrailing
        }
    }
}
