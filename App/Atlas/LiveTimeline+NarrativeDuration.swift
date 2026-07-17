import SwiftUI
import AtlasCore

// Duration chip — peel de LiveTimeline+NarrativeMeta.

extension NarrativeRowView {
    @ViewBuilder
    var narrativeDurationChip: some View {
        if let duration = row.durationMs {
            HStack(spacing: 5) {
                Text("Δ \(humanDuration(duration))")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(row.isP90 ? AtlasTheme.domOperacional : AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
                if row.isP90 {
                    Text("p90")
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.domOperacional)
                }
            }
            .accessibilityHidden(true)
        }
    }
}
