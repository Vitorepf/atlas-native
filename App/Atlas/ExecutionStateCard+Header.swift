import SwiftUI
import AtlasCore

// Header title row — peel de ExecutionStateCard.

extension ExecutionStateCard {
    var stateHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(tint)
                .accessibilityHidden(true)
            Text(state.title)
                .font(.system(.footnote, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Spacer(minLength: 0)
            if let badge = kindBadge {
                Text(badge)
                    .font(AtlasFont.mono(10)).tracking(0.8)
                    .foregroundStyle(tint)
                    .accessibilityHidden(true)
            }
        }
    }
}
