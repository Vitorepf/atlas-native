import SwiftUI
import AtlasCore

/// Decisão — peel de ExecutionProof+Expanded (régua ≤100).
/// Artefatos → ExecutionProof+Expanded+Artifacts.swift
/// Quality → ExecutionProof+Expanded+Quality.swift
/// Reason → ExecutionProof+Expanded+Reason.swift

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
            decisionReason(d)
        }
    }
}
