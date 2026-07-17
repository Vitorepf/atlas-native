import SwiftUI
import AtlasCore

// Scrubber de replay — peel de ExecutionProof+Replay (régua ≤100).
// Controls → ExecutionProof+ScrubberControls.swift

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
                replayControls(stampedCount: stamped.count)
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
