import SwiftUI
import AtlasCore

// Active timer line — peel de ConversationCockpit+ReconnectLines.

extension ReconnectBanner {
    @ViewBuilder
    var reconnectActiveTimerLine: some View {
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
