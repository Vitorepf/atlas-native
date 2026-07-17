import SwiftUI
import AtlasCore

// Header — peel de ArenaIndexSection.
// Captions → ArenaIndexSection+Captions.swift

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
            if !composite.weightsPublic.isEmpty {
                Text("\(composite.weightsPublic.count) pesos")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(sectionSpokenLabel)
    }
}
