import SwiftUI
import AtlasCore

// A PROVA da execução — o que Cursor não mostra: depois da resposta, os passos
// ficam (persistentes, expansíveis), com o Atlas Decide (por que este modelo)
// e o quality gate (a auto-avaliação). Fechado = uma linha discreta.
// Header → ExecutionProof+Header.swift
struct ExecutionProof: View {
    let bubble: ChatBubble
    var artifactItems: [AtlasTraceArtifacts.Item] = []
    var onOpenArtifacts: (TraceID) -> Void = { _ in }
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var open = false
    @State var replayIndex = 0

    /// Passos, decide, quality ou artefatos reais — nunca card vazio pós-conclusão.
    static func shouldDisplay(
        bubble: ChatBubble,
        artifactItems: [AtlasTraceArtifacts.Item] = []
    ) -> Bool {
        !bubble.activities.isEmpty
            || bubble.decisionSummary.map(hasDecisionSurface) == true
            || bubble.qualitySummary != nil
            || (!artifactItems.isEmpty && bubble.traceId != nil)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            collapsedHeader
            if open {
                expandedProofContent
            }
        }
        .padding(.vertical, 8).padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.surface.opacity(0.35))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
        )
    }
}
