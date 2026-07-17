import SwiftUI
import AtlasCore

/// Decisão / quality — peel de ExecutionProof+Expanded (régua ≤100).
/// Artefatos → ExecutionProof+Expanded+Artifacts.swift

extension ExecutionProof {
    @ViewBuilder
    var decisionBlock: some View {
        if let d = bubble.decisionSummary, Self.hasDecisionSurface(d) {
            Divider().overlay(AtlasTheme.separatorSoft).accessibilityHidden(true)
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 11)).foregroundStyle(AtlasTheme.accent.opacity(0.8)).frame(width: 15)
                    .accessibilityHidden(true)
                Text(decideLine(d))
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(2)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(decisionSpoken(d))
            if let r = d.reason, !r.isEmpty {
                Text(""\(r)"")
                    .font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textSecondary)
                    .padding(.leading, 23)
                    .accessibilityLabel("motivo, \(r)")
            }
        }
    }

    @ViewBuilder
    var qualityBlock: some View {
        if let q = bubble.qualitySummary {
            HStack(spacing: 6) {
                Image(systemName: "seal")
                    .font(.system(size: 11)).foregroundStyle(qualityColor(q)).frame(width: 15)
                    .accessibilityHidden(true)
                Text(qualityLine(q))
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
            }
            .accessibilityLabel(qualitySpoken(q))
        }
    }
}
