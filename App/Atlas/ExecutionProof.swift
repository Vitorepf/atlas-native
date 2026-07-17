import SwiftUI
import AtlasCore

// A PROVA da execução — o que Cursor não mostra: depois da resposta, os passos
// ficam (persistentes, expansíveis), com o Atlas Decide (por que este modelo)
// e o quality gate (a auto-avaliação). Fechado = uma linha discreta.
// Header → ExecutionProof+Header.swift
// Chrome → ExecutionProof+Chrome.swift
// Gate → ExecutionProof+ShouldDisplay.swift
struct ExecutionProof: View {
    let bubble: ChatBubble
    var artifactItems: [AtlasTraceArtifacts.Item] = []
    var onOpenArtifacts: (TraceID) -> Void = { _ in }
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var open = false
    @State var replayIndex = 0

    var body: some View {
        proofChrome {
            VStack(alignment: .leading, spacing: 0) {
                collapsedHeader
                if open {
                    expandedProofContent
                }
            }
        }
    }
}
