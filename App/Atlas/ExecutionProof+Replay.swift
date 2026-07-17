import SwiftUI
import AtlasCore

// Replay scrubber + helpers — peel de ExecutionProof (régua anti-inchaço).

extension ExecutionProof {
    var summaryLine: String {
        var parts: [String] = []
        if !bubble.activities.isEmpty { parts.append("\(bubble.activities.count) passos") }
        if let ms = bubble.elapsedMs, ms > 0 { parts.append(humanDuration(ms)) }
        if let q = bubble.qualitySummary { parts.append("quality \(String(format: "%.1f", q.score))") }
        if !artifactItems.isEmpty { parts.append("\(artifactItems.count) artefatos") }
        return parts.joined(separator: " · ")
    }

    var spokenCollapsed: String {
        var parts = ["prova da execução"]
        if !bubble.activities.isEmpty { parts.append("\(bubble.activities.count) passos") }
        if bubble.decisionSummary.map(Self.hasDecisionSurface) == true { parts.append("decisão do atlas") }
        if bubble.qualitySummary != nil { parts.append("avaliação de qualidade") }
        if !artifactItems.isEmpty { parts.append("\(artifactItems.count) artefatos") }
        return parts.joined(separator: ", ")
    }

    @ViewBuilder
    var replayScrubber: some View {
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

    var timestampedActivities: [(activity: AtlasAgentActivity, date: Date)] {
        bubble.activities.compactMap { activity in
            guard let date = AtlasTime.date(activity.occurredAt) else { return nil }
            return (activity, date)
        }
    }

    func decideLine(_ d: AtlasDecisionSummary) -> String {
        var out = "atlas decide"
        if let m = d.routeMode { out += " · \(m)" }
        if let p = d.selectedProvider { out += " · \(p)" }
        if let c = d.confidenceScore { out += " · conf \(String(format: "%.2f", c))" }
        if d.wasOverridden { out += " · override" }
        return out
    }

    func qualityLine(_ q: AtlasQualitySummary) -> String {
        var out = "quality \(String(format: "%.1f", q.score)) · \(q.status)"
        if q.flagCount > 0 { out += " · \(q.flagCount) alertas" }
        if q.actionCount > 0 { out += " · \(q.actionCount) ações" }
        return out
    }

    func qualitySpoken(_ q: AtlasQualitySummary) -> String {
        var parts = ["qualidade \(String(format: "%.1f", q.score)), status \(q.status)"]
        if q.flagCount > 0 { parts.append("\(q.flagCount) alertas") }
        if q.actionCount > 0 { parts.append("\(q.actionCount) ações de correção") }
        return parts.joined(separator: ", ")
    }

    func activitySpoken(_ act: AtlasAgentActivity) -> String {
        var parts = [act.title]
        if let d = act.detail, !d.isEmpty { parts.append(d) }
        return parts.joined(separator: ", ")
    }

    func qualityColor(_ q: AtlasQualitySummary) -> Color {
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
