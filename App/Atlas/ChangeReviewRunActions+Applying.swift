import SwiftUI
import AtlasCore

// Indicador applying — peel de ChangeReviewRunActions+Buttons.
// Static → ChangeReviewRunActions+ApplyingStatic.swift

extension ChangeReviewRunActions {
    @ViewBuilder
    var applyingIndicator: some View {
        if reduceMotion {
            applyingStaticLabel
        } else {
            ProgressView()
                .tint(AtlasTheme.accent)
                .accessibilityLabel("registrando decisão")
        }
    }
}
