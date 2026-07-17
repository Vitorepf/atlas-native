import SwiftUI
import AtlasCore

/// Next digest line — peel de AutonomosDigestSection+ScheduleCopy.

extension AutonomosNextDigestSection {
    @ViewBuilder
    func digestScheduleCopyNext(_ next: String) -> some View {
        Text(next)
            .font(AtlasFont.serifItalic(15))
            .foregroundStyle(AtlasTheme.textPrimary)
            .textSelection(.enabled)
            .accessibilityHidden(true)
    }
}
