import SwiftUI

// Headline typography — peel de AtlasCodeLoadFailure+Icon.

extension AtlasCodeLoadFailureEmpty {
    var failureHeadline: some View {
        Text(headline)
            .font(AtlasFont.serif(20, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityHidden(true)
    }
}
