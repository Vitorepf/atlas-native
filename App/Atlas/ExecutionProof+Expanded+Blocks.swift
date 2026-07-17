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
            decisionSummaryRow(d)
            decisionReason(d)
        }
    }
}
