import SwiftUI
import AtlasCore

/// Selos de leitura e marcador de novidade — peel de ConversationChromeSheets+Receipt.

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

struct NewSinceLastVisitMarker: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle().fill(AtlasTheme.accent.opacity(0.65)).frame(height: 1)
                .accessibilityHidden(true)
            Text("NOVO DESDE ÚLTIMA VISITA")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.accent)
                .accessibilityHidden(true)
            Rectangle().fill(AtlasTheme.accent.opacity(0.65)).frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityIdentifier(A11yID.conversationNewMarker)
        .accessibilityLabel("novo desde a última visita")
        .accessibilityAddTraits(.isStaticText)
    }
}
