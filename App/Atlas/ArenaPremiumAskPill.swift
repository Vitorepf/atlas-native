import SwiftUI

/// Pílula agêntica da Arena — único tipo visual = craft da home
/// (`RootView+InputBarContent` + `HomeComposerStar` + fio de ouro artesanal).
/// Só o convite muda; o pack nunca aparece na cara.
struct ArenaPremiumAskPill: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let invite: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            action()
        }) {
            HStack(spacing: 12) {
                RootView.HomeComposerStar()
                Text(invite)
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .atlasGlassCapsule()
            .overlay(
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                AtlasTheme.accent.opacity(0.22),
                                AtlasTheme.accent.opacity(0.04),
                                AtlasTheme.accent.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.75
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(invite)
        .accessibilityHint("Abre conversa com contexto desta medição")
        .accessibilityIdentifier(A11yID.arenaPremiumAskPill)
    }
}
