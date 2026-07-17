import SwiftUI
import AtlasCore

// Schedule copy — peel de AutonomosDigestSection+Card.

extension AutonomosNextDigestSection {
    @ViewBuilder
    func digestScheduleCopy(last: Bool) -> some View {
        if let next = digest.nextDigestAt?.nonEmpty {
            Text(next)
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textPrimary)
                .textSelection(.enabled)
                .accessibilityHidden(true)
        } else if last {
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

    var sectionTitle: String {
        digest.nextDigestAt?.nonEmpty != nil ? "PRÓXIMO RESUMO" : "RESUMO GOVERNADO"
    }
}
