import SwiftUI

// Botões back/refresh — peel de AutonomosViewHeader.

extension AutonomosViewHeader {
    var backButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onBack()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 40, height: 40)
                .background(Circle().fill(AtlasTheme.surface))
        }
        .accessibilityLabel(spokenBackLabel())
        .accessibilityHint(spokenBackHint())
        .accessibilityIdentifier(A11yID.autonomosBack)
    }

    var refreshButton: some View {
        Button {
            if canRefresh { AtlasMotion.softImpact(reduceMotion: reduceMotion) }
            onRefresh()
        } label: {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(canRefresh ? AtlasTheme.textSecondary : AtlasTheme.textTertiary)
                .frame(width: 40, height: 40)
                .background(Circle().fill(AtlasTheme.surface))
        }
        .disabled(!canRefresh)
        .opacity(canRefresh ? 1 : 0.45)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: canRefresh)
        .accessibilityLabel(spokenRefreshLabel(canRefresh: canRefresh))
        .accessibilityHint(spokenRefreshHint(canRefresh: canRefresh))
        .accessibilityIdentifier(A11yID.autonomosRefresh)
    }
}
