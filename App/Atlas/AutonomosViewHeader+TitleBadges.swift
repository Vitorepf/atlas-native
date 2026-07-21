import SwiftUI

// Title badges — peel de AutonomosViewHeader+Title.

extension AutonomosViewHeader {
    @ViewBuilder
    var titleBadges: some View {
        if !subtitle.isEmpty {
            Text(subtitle.uppercased())
                .font(AtlasFont.mono(10)).tracking(1.2)
                .foregroundStyle(subtitleLive ? AtlasTheme.accent : AtlasTheme.textTertiary)
                .accessibilityHidden(true)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
        }
        if auditModeEnabled {
            Text("MODO AUDITORIA")
                .font(AtlasFont.mono(9)).tracking(1.0)
                .foregroundStyle(AtlasTheme.domOperacional)
                .accessibilityHidden(true)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
        }
    }
}
