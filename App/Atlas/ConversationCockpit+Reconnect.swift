import SwiftUI
import AtlasCore

// Banner de reconexão (cockpit secondary). Primary face = ExecutingStrip.
// Só `reconnectNotice` (transporte) e presentation `.recovering` (ledger).

struct ReconnectBanner: View {
    let bubble: ChatBubble
    let reduceMotion: Bool

    var body: some View {
        if bubble.showsReconnectSurface, let primary = bubble.reconnectPrimaryLine {
            VStack(alignment: .leading, spacing: 4) {
                ExecutionBanner(
                    text: primary,
                    icon: bubble.reconnectBannerIcon,
                    tint: AtlasTheme.textSecondary,
                    reduceMotion: reduceMotion,
                    embedInParent: true
                )
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
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(bubble.reconnectSpokenLabel)
            .accessibilityIdentifier(A11yID.executionReconnectBanner)
        }
    }
}
