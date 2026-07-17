import SwiftUI
import AtlasCore

// Index header weights — peel de ArenaIndexSection+Header.

extension ArenaIndexSection {
    @ViewBuilder
    var sectionHeaderWeights: some View {
        if !composite.weightsPublic.isEmpty {
            Text("\(composite.weightsPublic.count) pesos")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
    }
}
