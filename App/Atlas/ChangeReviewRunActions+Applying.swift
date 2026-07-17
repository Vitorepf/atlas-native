import SwiftUI
import AtlasCore

// Indicador applying — peel de ChangeReviewRunActions+Buttons.

extension ChangeReviewRunActions {
    @ViewBuilder
    var applyingIndicator: some View {
        if reduceMotion {
            Text("registrando…")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel("registrando decisão")
        } else {
            ProgressView()
                .tint(AtlasTheme.accent)
                .accessibilityLabel("registrando decisão")
        }
    }
}
