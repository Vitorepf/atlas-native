import SwiftUI

// Message typography — peel de AtlasCodeLoadFailure+Icon.

extension AtlasCodeLoadFailureEmpty {
    var failureMessage: some View {
        Text(message)
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textTertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 28)
            .accessibilityHidden(true)
    }
}
