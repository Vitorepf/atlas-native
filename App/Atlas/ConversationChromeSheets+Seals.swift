import SwiftUI
import AtlasCore

/// Selos de leitura — peel de ConversationChromeSheets+Receipt.
/// New marker → ConversationChromeSheets+NewMarker.swift

struct StaleReadSeal: View {
    let capturedAt: Date
    let confirming: Bool
    let reduceMotion: Bool

    var body: some View {
        Group {
            if reduceMotion || confirming {
                sealBody(now: Date())
            } else {
                TimelineView(.periodic(from: Date(), by: 60)) { context in
                    sealBody(now: context.date)
                }
            }
        }
        .accessibilityIdentifier(A11yID.conversationStaleReadSeal)
        .accessibilityAddTraits(confirming || reduceMotion ? .isStaticText : .updatesFrequently)
    }

    @ViewBuilder
    private func sealBody(now: Date) -> some View {
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(StaleReadSealA11y.spokenLabel(
            capturedAt: capturedAt,
            now: now,
            confirming: confirming,
            reduceMotion: reduceMotion
        ))
    }
}
