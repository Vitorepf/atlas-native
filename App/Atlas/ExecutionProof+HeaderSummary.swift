import SwiftUI
import AtlasCore

// Header summary text — peel de ExecutionProof+HeaderLabel.

extension ExecutionProof {
    @ViewBuilder
    var collapsedHeaderSummary: some View {
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
    }
}
