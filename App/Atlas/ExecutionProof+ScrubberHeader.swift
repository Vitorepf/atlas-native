import SwiftUI
import AtlasCore

// Scrubber header — peel de ExecutionProof+ScrubberChrome.
// Meta → ExecutionProof+ScrubberMeta.swift

extension ExecutionProof {
    func replayScrubberHeader(
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
            replayScrubberMeta(selected: selected)
        }
    }
}
