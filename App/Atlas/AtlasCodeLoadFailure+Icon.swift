import SwiftUI

// Ícone + tipografia da falha — peel de AtlasCodeLoadFailure.

extension AtlasCodeLoadFailureEmpty {
    var failureIcon: some View {
        Image(systemName: "exclamationmark.triangle")
            .font(.system(size: 24))
            .foregroundStyle(AtlasCodePalette.alert)
            .accessibilityHidden(true)
    }

    var failureHeadline: some View {
        Text(headline)
            .font(AtlasFont.serif(20, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityHidden(true)
    }

    var failureMessage: some View {
        Text(message)
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textTertiary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 28)
            .accessibilityHidden(true)
    }
}
