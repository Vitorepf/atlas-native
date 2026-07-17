import SwiftUI
import AtlasCore

// shouldDisplay gate — peel de ExecutionProof.
// Decision surface → ExecutionProof+DecisionSurface.swift

extension ExecutionProof {
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
