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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var open = false
    @State private var replayIndex = 0

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

    private var summaryLine: String {
        var parts: [String] = []
        if !bubble.activities.isEmpty { parts.append("\(bubble.activities.count) passos") }
        if let ms = bubble.elapsedMs, ms > 0 { parts.append(humanDuration(ms)) }
        if let q = bubble.qualitySummary { parts.append("quality \(String(format: "%.1f", q.score))") }
        if !artifactItems.isEmpty { parts.append("\(artifactItems.count) artefatos") }
        return parts.joined(separator: " · ")
    }

    private var spokenCollapsed: String {
        var parts = ["prova da execução"]
        if !bubble.activities.isEmpty { parts.append("\(bubble.activities.count) passos") }
        if bubble.decisionSummary.map(Self.hasDecisionSurface) == true { parts.append("decisão do atlas") }
        if bubble.qualitySummary != nil { parts.append("avaliação de qualidade") }
        if !artifactItems.isEmpty { parts.append("\(artifactItems.count) artefatos") }
        return parts.joined(separator: ", ")
    }

    @ViewBuilder
    private var replayScrubber: some View {
        let stamped = timestampedActivities
        if stamped.count >= 2 {
            let index = min(replayIndex, stamped.count - 1)
            let selected = stamped[index]
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("REPLAY")
                        .font(AtlasFont.mono(10))
                        .tracking(1.1)
                        .foregroundStyle(AtlasTheme.accent)
                    Spacer()
                    Text("\(index + 1)/\(stamped.count)")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .modifier(LiveTimelineNumericTransition(enabled: !reduceMotion))
                }
                Text(selected.activity.title)
                    .font(.system(.caption, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(2)
                Text(selected.activity.occurredAt ?? "")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                if reduceMotion {
                    Stepper("passo \(index + 1)", value: Binding(
                        get: { replayIndex },
                        set: { replayIndex = min(max(0, $0), stamped.count - 1) }
                    ), in: 0...(stamped.count - 1))
                    .labelsHidden()
                    .accessibilityLabel("replay da execução, passo \(index + 1) de \(stamped.count)")
                } else {
                    Slider(value: Binding(
                        get: { Double(replayIndex) },
                        set: { replayIndex = min(max(0, Int($0.rounded())), stamped.count - 1) }
                    ), in: 0...Double(stamped.count - 1), step: 1)
                    .tint(AtlasTheme.accent)
                    .accessibilityLabel("scrubber de replay da execução")
                    .accessibilityValue("passo \(index + 1) de \(stamped.count)")
                }
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.bgRecessed))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
            .accessibilityIdentifier(A11yID.executionReplayScrubber)
        } else if !bubble.activities.isEmpty {
            Text("REPLAY indisponível · eventos sem timestamps")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel("replay indisponível porque os eventos não têm timestamps")
        }
    }

    private var timestampedActivities: [(activity: AtlasAgentActivity, date: Date)] {
        bubble.activities.compactMap { activity in
            guard let date = AtlasTime.date(activity.occurredAt) else { return nil }
            return (activity, date)
        }
    }

    private func decideLine(_ d: AtlasDecisionSummary) -> String {
        var out = "atlas decide"
        if let m = d.routeMode { out += " · \(m)" }
        if let p = d.selectedProvider { out += " · \(p)" }
        if let c = d.confidenceScore { out += " · conf \(String(format: "%.2f", c))" }
        if d.wasOverridden { out += " · override" }
        return out
    }

    private func qualityLine(_ q: AtlasQualitySummary) -> String {
        var out = "quality \(String(format: "%.1f", q.score)) · \(q.status)"
        if q.flagCount > 0 { out += " · \(q.flagCount) alertas" }
        if q.actionCount > 0 { out += " · \(q.actionCount) ações" }
        return out
    }

    private func qualitySpoken(_ q: AtlasQualitySummary) -> String {
        var parts = ["qualidade \(String(format: "%.1f", q.score)), status \(q.status)"]
        if q.flagCount > 0 { parts.append("\(q.flagCount) alertas") }
        if q.actionCount > 0 { parts.append("\(q.actionCount) ações de correção") }
        return parts.joined(separator: ", ")
    }

    private func activitySpoken(_ act: AtlasAgentActivity) -> String {
        var parts = [act.title]
        if let d = act.detail, !d.isEmpty { parts.append(d) }
        return parts.joined(separator: ", ")
    }

    private func qualityColor(_ q: AtlasQualitySummary) -> Color {
        let status = q.status.lowercased()
        if status.contains("pass") || status.contains("ok") || status.contains("success") {
            return AtlasTheme.domAutonomos
        }
        if status.contains("fail") || status.contains("warn") || status.contains("flag") {
            return AtlasTheme.domOperacional
        }
        return AtlasTheme.textSecondary
    }

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
}
