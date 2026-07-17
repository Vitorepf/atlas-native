import SwiftUI

/// Cabeçalho da área Autônomos — voltar, título, refresh da área selecionada.
struct AutonomosViewHeader: View {
    let auditModeEnabled: Bool
    let canRefresh: Bool
    let onBack: () -> Void
    let onRefresh: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AtlasTheme.surface))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Autônomos")
                    .font(AtlasFont.serif(21, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text("ÁREA PRÓPRIA · 24/7")
                    .font(AtlasFont.mono(10)).tracking(1.2)
                    .foregroundStyle(AtlasTheme.accent)
                if auditModeEnabled {
                    Text("MODO AUDITORIA")
                        .font(AtlasFont.mono(9)).tracking(1.0)
                        .foregroundStyle(AtlasTheme.domOperacional)
                }
            }
            Spacer()
            Button(action: onRefresh) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AtlasTheme.surface))
            }
            .disabled(!canRefresh)
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, 8)
    }
}
