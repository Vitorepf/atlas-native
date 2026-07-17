import SwiftUI
import AtlasCore

/// Selos de leitura e marcador de novidade — peel de ConversationChromeSheets+Receipt.

struct StaleReadSeal: View {
    let capturedAt: Date
    let confirming: Bool
    let reduceMotion: Bool

    var body: some View {
        TimelineView(.periodic(from: Date(), by: 60)) { context in
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 10, weight: .semibold))
                Text(reduceMotion && confirming
                     ? "leitura atualizada"
                     : "visto há \(atlasRelativeAgePT(since: capturedAt, now: context.date))")
                    .font(AtlasFont.mono(11))
            }
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .scaleEffect(confirming && !reduceMotion ? 1.045 : 1)
            .opacity(confirming && !reduceMotion ? 0.72 : 1)
            .animation(confirming && !reduceMotion ? .easeInOut(duration: 0.32) : nil, value: confirming)
            .accessibilityLabel(confirming
                                ? "histórico salvo atualizado"
                                : "histórico salvo visto há \(atlasRelativeAgePT(since: capturedAt, now: context.date))")
        }
    }
}

struct NewSinceLastVisitMarker: View {
    var body: some View {
        HStack(spacing: 8) {
            Rectangle().fill(AtlasTheme.accent.opacity(0.65)).frame(height: 1)
            Text("NOVO DESDE ÚLTIMA VISITA")
                .font(AtlasFont.mono(10))
                .tracking(1.1)
                .foregroundStyle(AtlasTheme.accent)
            Rectangle().fill(AtlasTheme.accent.opacity(0.65)).frame(height: 1)
        }
        .accessibilityIdentifier(A11yID.conversationNewMarker)
        .accessibilityLabel("novo desde a última visita")
    }
}
