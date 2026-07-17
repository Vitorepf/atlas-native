import SwiftUI
import AtlasCore

// Header — peel de ArenaIndexSection.
// Captions → ArenaIndexSection+Captions.swift
// Weights → ArenaIndexSection+HeaderWeights.swift

extension ArenaIndexSection {
    var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text("O ÍNDICE")
                    .font(.system(.caption, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                Text(coverageCaption)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            Spacer()
            sectionHeaderWeights
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(sectionSpokenLabel)
    }
}
