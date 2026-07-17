import SwiftUI
import AtlasCore

// Static applying text — peel de ChangeReviewRunActions+Applying.

extension ChangeReviewRunActions {
    var applyingStaticLabel: some View {
        Text("registrando…")
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityLabel("registrando decisão")
    }
}
