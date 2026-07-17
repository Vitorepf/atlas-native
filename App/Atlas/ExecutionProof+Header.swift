import SwiftUI
import AtlasCore

// Header colapsado — peel de ExecutionProof.

extension ExecutionProof {
    var collapsedHeader: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.22)) { open.toggle() }
        } label: {
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
        .buttonStyle(.plain)
        .accessibilityLabel(spokenCollapsed(expanded: open))
        .accessibilityHint(open ? "toque para fechar a prova" : "toque para expandir a prova")
        .accessibilityIdentifier(A11yID.executionProof)
    }
}
