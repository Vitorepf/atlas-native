import SwiftUI

// Legenda de seção Autônomos — peel de AutonomosChrome (CICLO C residual honesty).
// `.decorative`: spoken composto no container pai. `.header`: landmark em empty/quiet.

extension AutonomosChrome {
    enum SectionCaptionRole {
        case decorative
        case header
    }

    @ViewBuilder
    static func sectionCaption(_ text: String, role: SectionCaptionRole = .decorative) -> some View {
        Text(text)
            .font(.system(.caption, weight: .semibold))
            .tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
            .modifier(SectionCaptionA11y(role: role))
    }
}

private struct SectionCaptionA11y: ViewModifier {
    let role: AutonomosChrome.SectionCaptionRole

    func body(content: Content) -> some View {
        switch role {
        case .decorative:
            content.accessibilityHidden(true)
        case .header:
            content.accessibilityAddTraits(.isHeader)
        }
    }
}
