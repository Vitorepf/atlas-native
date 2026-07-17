import SwiftUI

// Título + badges — peel de AutonomosViewHeader.

extension AutonomosViewHeader {
    var titleBlock: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Autônomos")
                .font(AtlasFont.serif(21, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
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
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(spokenTitle(isHealthy: isHealthy, auditModeEnabled: auditModeEnabled))
        .accessibilityIdentifier(A11yID.autonomosHeader)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: isHealthy)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: auditModeEnabled)
    }
}
