import SwiftUI

// Legenda de seção Autônomos — peel de AutonomosChrome (CICLO C residual honesty).
// `.decorative`: spoken composto no container pai. `.header`: landmark em empty/quiet.
// A11y → AutonomosChrome+CaptionA11y.swift

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
