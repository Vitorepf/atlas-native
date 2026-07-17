import SwiftUI
import AtlasCore

// shouldDisplay gate — peel de ExecutionProof.
// Restore hasDecisionSurface (lost in prior peel waves).

extension ExecutionProof {
    /// Campos publicados pelo ledger — nunca só o rótulo «atlas decide».
    static func hasDecisionSurface(_ d: AtlasDecisionSummary) -> Bool {
        d.selectedProvider != nil
            || d.selectedModel != nil
            || d.reason != nil
            || d.confidenceScore != nil
            || d.riskLevel != nil
            || d.routeMode != nil
            || d.wasOverridden
    }

    /// Passos, decide, quality ou artefatos reais — nunca card vazio pós-conclusão.
    static func shouldDisplay(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = []
    ) -> Bool {
        !bubble.activities.isEmpty
            || bubble.decisionSummary.map(Self.hasDecisionSurface) == true
            || bubble.qualitySummary != nil
            || (!artifactItems.isEmpty && bubble.traceId != nil)
    }
}
