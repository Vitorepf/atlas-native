import SwiftUI
import AtlasCore

// Scrubber title row — peel de ExecutionProof+ScrubberHeader.

extension ExecutionProof {
    func replayScrubberTitle(index: Int, total: Int) -> some View {
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
    }
}
