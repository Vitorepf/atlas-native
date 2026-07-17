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
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Obra concluída")
                            .font(.system(.subheadline, weight: .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        if !summaryLine.isEmpty {
                            Text(summaryLine)
                                .font(.system(.caption)).foregroundStyle(AtlasTheme.textTertiary)
                                .lineLimit(1)
                        }
                    }
                    Spacer(minLength: 0)
                    Text(open ? "Fechar" : "Abrir")
                        .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(spokenCollapsed)
            .accessibilityHint(open ? "toque para fechar" : "toque para expandir")
            .accessibilityIdentifier(A11yID.executionProof)

            if open {
                VStack(alignment: .leading, spacing: 7) {
                    replayScrubber
                    if !bubble.activities.isEmpty {
                        ForEach(bubble.activities) { act in
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Image(systemName: activityIcon(act.kind))
                                    .font(.system(size: 11)).foregroundStyle(AtlasTheme.accent.opacity(0.8))
                                    .frame(width: 15)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(act.title)
                                        .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                                    if let d = act.detail, !d.isEmpty {
                                        Text(d).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                                            .lineLimit(2).truncationMode(.middle)
                                    }
                                }
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel(activitySpoken(act))
                        }
                    }
                    if let d = bubble.decisionSummary, Self.hasDecisionSurface(d) {
                        Divider().overlay(AtlasTheme.separatorSoft)
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.branch")
                                .font(.system(size: 11)).foregroundStyle(AtlasTheme.accent.opacity(0.8)).frame(width: 15)
                            Text(decideLine(d))
                                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                                .lineLimit(2)
                        }
                        if let r = d.reason, !r.isEmpty {
                            Text(""\(r)"")
                                .font(AtlasFont.serifItalic(12)).foregroundStyle(AtlasTheme.textSecondary)
                                .padding(.leading, 23)
                        }
                    }
                    if let q = bubble.qualitySummary {
                        HStack(spacing: 6) {
                            Image(systemName: "seal")
                                .font(.system(size: 11)).foregroundStyle(qualityColor(q)).frame(width: 15)
                            Text(qualityLine(q))
                                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                        }
                        .accessibilityLabel(qualitySpoken(q))
                    }
                    if !artifactItems.isEmpty, let traceId = bubble.traceId {
                        Button {
                            if !reduceMotion {
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            }
                            onOpenArtifacts(traceId)
                        } label: {
                            HStack(spacing: 6) {
                                Text("⎘")
                                    .font(AtlasFont.mono(12))
                                    .foregroundStyle(AtlasTheme.accent.opacity(0.8))
                                    .frame(width: 15)
                                Text("ARTEFATOS (\(artifactItems.count))")
                                    .font(AtlasFont.mono(12))
                                    .foregroundStyle(AtlasTheme.textSecondary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(AtlasTheme.textTertiary)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier(A11yID.artifactsRow)
                        .accessibilityLabel("artefatos desta execução, \(artifactItems.count)")
                    }
                }
                .padding(.top, 8)
                .padding(.leading, 4)
                .transition(reduceMotion ? .identity : .opacity)
                .onChange(of: bubble.activities.count) {
                    replayIndex = min(replayIndex, max(0, timestampedActivities.count - 1))
                }
            }
        }
        .padding(.vertical, 8).padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.surface.opacity(0.35))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
        )
    }
}
