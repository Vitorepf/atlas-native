import SwiftUI
import AtlasCore

// Header title row — peel de ExecutionStateCard.
// Badge → ExecutionStateCard+Header+Badge.swift

extension ExecutionStateCard {
    var stateHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: icon)
                .atlasSans(13, .semibold)
                .foregroundStyle(tint)
                .accessibilityHidden(true)
            Text(state.title)
                .font(AtlasFont.mono(11, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Spacer(minLength: 0)
            stateHeaderBadge
        }
    }
}
