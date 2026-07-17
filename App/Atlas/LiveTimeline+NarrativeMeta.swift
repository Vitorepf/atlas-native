import SwiftUI
import AtlasCore

// Duration meta — peel de NarrativeRowView+NarrativeBody.
// Traits → LiveTimeline+NarrativeTraits.swift

extension NarrativeRowView {
    @ViewBuilder
    var narrativeDurationMeta: some View {
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
