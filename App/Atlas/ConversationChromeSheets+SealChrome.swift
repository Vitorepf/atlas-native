import SwiftUI
import AtlasCore

// Seal visual chrome — peel de ConversationChromeSheets+SealBody.

extension StaleReadSeal {
    @ViewBuilder
    func sealChrome(now: Date) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 10, weight: .semibold))
                .accessibilityHidden(true)
            Text(StaleReadSealA11y.displayCaption(
                capturedAt: capturedAt,
                now: now,
                confirming: confirming,
                reduceMotion: reduceMotion
            ))
            .font(AtlasFont.mono(11))
            .modifier(NumericTextTransition(enabled: !reduceMotion && !confirming))
            .accessibilityHidden(true)
        }
        .foregroundStyle(AtlasTheme.textTertiary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .scaleEffect(confirming && !reduceMotion ? 1.045 : 1)
        .opacity(confirming && !reduceMotion ? 0.72 : 1)
        .animation(confirming && !reduceMotion ? .easeInOut(duration: 0.32) : nil, value: confirming)
    }
}
