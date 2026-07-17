import SwiftUI
import AtlasCore

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
        spokenCollapsed(expanded: false)
    }

    func spokenCollapsed(expanded: Bool) -> String {
        var parts = ["prova da execução", expanded ? "expandida" : "recolhida"]
        if !bubble.activities.isEmpty { parts.append("\(bubble.activities.count) passos") }
        if let ms = bubble.elapsedMs, ms > 0 { parts.append(humanDuration(ms)) }
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
                        .modifier(NumericTextTransition(enabled: !reduceMotion))
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
}
