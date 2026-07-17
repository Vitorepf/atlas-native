import SwiftUI
import AtlasCore

// A PROVA da execução — o que Cursor não mostra: depois da resposta, os passos
// ficam (persistentes, expansíveis), com o Atlas Decide (por que este modelo)
// e o quality gate (a auto-avaliação). Fechado = uma linha discreta.
// Extraído de ExecutionStateCard.swift (CICLO B compressão).
struct ExecutionProof: View {
    let bubble: ChatBubble
    var artifactItems: [AtlasTraceArtifacts.Item] = []
    var onOpenArtifacts: (TraceID) -> Void = { _ in }
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var open = false
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
            Button {
                if !reduceMotion {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
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
