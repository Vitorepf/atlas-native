import SwiftUI

/// Cabeçalho da área Autônomos — voltar, título, refresh da área selecionada.
/// Title → AutonomosViewHeader+Title.swift
struct AutonomosViewHeader: View {
    let auditModeEnabled: Bool
    let canRefresh: Bool
    let isHealthy: Bool
    let reduceMotion: Bool
    let onBack: () -> Void
    let onRefresh: () -> Void

    var body: some View {
        HStack(spacing: 12) {
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
            titleBlock
            Spacer()
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
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, 8)
    }
}
