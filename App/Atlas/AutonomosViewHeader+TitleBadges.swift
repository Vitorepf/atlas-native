import SwiftUI

// Title badges — peel de AutonomosViewHeader+Title.

extension AutonomosViewHeader {
    @ViewBuilder
    var titleBadges: some View {
        if !isHealthy {
            Text("ÁREA PRÓPRIA · 24/7")
                .font(AtlasFont.mono(10)).tracking(1.2)
                .foregroundStyle(AtlasTheme.accent)
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
