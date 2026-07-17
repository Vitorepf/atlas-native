import SwiftUI
import AtlasCore

// Digest card stack — peel de AutonomosDigestSection+Card.

extension AutonomosNextDigestSection {
    @ViewBuilder
    func digestCardStack(last: Bool, window: String?) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            AutonomosChrome.sectionCaption(sectionTitle)
            if last, let window {
                Text(window)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(2)
                    .accessibilityHidden(true)
            }
            digestScheduleCopy(last: last)
            if last {
                lastDigestBody(digest)
            }
        }
    }
}
