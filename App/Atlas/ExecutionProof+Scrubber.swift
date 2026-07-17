import SwiftUI
import AtlasCore

// Scrubber de replay — peel de ExecutionProof+Replay (régua ≤100).

extension ExecutionProof {
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
                        .accessibilityHidden(true)
                    Spacer()
                    Text("\(index + 1)/\(stamped.count)")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .modifier(NumericTextTransition(enabled: !reduceMotion))
                        .accessibilityHidden(true)
                }
                Text(selected.activity.title)
                    .font(.system(.caption, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(2)
                    .accessibilityHidden(true)
                Text(selected.activity.occurredAt ?? "")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .accessibilityHidden(true)
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
}
