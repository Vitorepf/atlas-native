import SwiftUI
import AtlasCore

// Collapsed header label — peel de ExecutionProof+Header.

extension ExecutionProof {
    var collapsedHeaderLabel: some View {
        HStack(spacing: 10) {
            Circle().fill(AtlasTheme.accent).frame(width: 10, height: 10)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 1) {
                Text("Obra concluída")
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                if !summaryLine.isEmpty {
                    Text(summaryLine)
                        .font(.system(.caption)).foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(1)
                        .accessibilityHidden(true)
                }
            }
            Spacer(minLength: 0)
            Text(open ? "Fechar" : "Abrir")
                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
    }
}
