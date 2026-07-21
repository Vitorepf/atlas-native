import SwiftUI
import AtlasCore

// Accept button label — peel de ChangeReviewRunActions+Buttons.

extension ChangeReviewRunActions {
    var acceptButtonLabel: some View {
        Text("Aceitar tudo")
            .font(AtlasFont.mono(11, .semibold)).foregroundStyle(AtlasTheme.bg)
            .padding(.horizontal, 18).padding(.vertical, 10)
            .background(Capsule().fill(AtlasTheme.accent))
    }
}
