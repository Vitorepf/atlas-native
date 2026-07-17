import SwiftUI
import AtlasCore

// Window caption — peel de AutonomosDigestSection+CardStack.

extension AutonomosNextDigestSection {
    @ViewBuilder
    func digestCardWindowCaption(last: Bool, window: String?) -> some View {
        if last, let window {
            Text(window)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
                .accessibilityHidden(true)
        }
    }
}
