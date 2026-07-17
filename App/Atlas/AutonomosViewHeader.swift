import SwiftUI

/// Cabeçalho da área Autônomos — voltar, título, refresh da área selecionada.
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
            VStack(alignment: .leading, spacing: 2) {
                Text("Autônomos")
                    .font(AtlasFont.serif(21, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                if !isHealthy {
                    Text("ÁREA PRÓPRIA · 24/7")
                        .font(AtlasFont.mono(10)).tracking(1.2)
                        .foregroundStyle(AtlasTheme.accent)
                        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
                }
                if auditModeEnabled {
                    Text("MODO AUDITORIA")
                        .font(AtlasFont.mono(9)).tracking(1.0)
                        .foregroundStyle(AtlasTheme.domOperacional)
                        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(spokenTitle(isHealthy: isHealthy, auditModeEnabled: auditModeEnabled))
            .accessibilityIdentifier(A11yID.autonomosHeader)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: isHealthy)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: auditModeEnabled)
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
