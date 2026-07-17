import SwiftUI
import AtlasCore

/// Fallback schedule copy — peel de AutonomosDigestSection+ScheduleCopy.

extension AutonomosNextDigestSection {
    @ViewBuilder
    func digestScheduleCopyFallback(last: Bool) -> some View {
        if last {
            Text("sem agenda publicada — último resumo abaixo")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        } else if let reason = digest.schedule.reason?.nonEmpty {
            Text(reason)
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }
}
