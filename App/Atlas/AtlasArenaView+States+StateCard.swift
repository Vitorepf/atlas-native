import SwiftUI
import AtlasCore

// State card — peel de AtlasArenaView+States.

extension AtlasArenaView {
    func stateCard(_ message: String) -> some View {
        Text(message)
            .font(.system(.subheadline))
            .foregroundStyle(AtlasTheme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .atlasCard()
            .accessibilityLabel(message)
    }
}
