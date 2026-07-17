import SwiftUI
import AtlasCore

// Secondary lines + timer — peel de ReconnectBanner.

extension ReconnectBanner {
    @ViewBuilder
    var secondaryLines: some View {
        ForEach(Array(bubble.reconnectSecondaryLines.enumerated()), id: \.offset) { _, line in
            Text(line)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
        if let ms = bubble.reconnectActiveTimerMs {
            Text("ativo \(ExecutionStateCard.clock(ms))")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .accessibilityHidden(true)
        }
    }
}
