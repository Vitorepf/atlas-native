import SwiftUI
import AtlasCore

// Scrubber chrome — peel de ExecutionProof+Scrubber.

extension ExecutionProof {
    func replayScrubberChrome(
        index: Int,
        total: Int,
        selected: (activity: AtlasAgentActivity, date: Date)
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("REPLAY")
                    .font(AtlasFont.mono(10))
                    .tracking(1.1)
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityHidden(true)
                Spacer()
                Text("\(index + 1)/\(total)")
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
            replayControls(stampedCount: total)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.bgRecessed))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
        .accessibilityIdentifier(A11yID.executionReplayScrubber)
    }
}
