import SwiftUI

/// Chrome único da pílula agêntica (baseline Home craft).
/// Só mudam: `invite`, `action`, `accessibilityIdentifier` / hint.
/// Pack nunca na cara — só viaja em `turnFacts`.
struct AgenticPill: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let invite: String
    var accessibilityId: String = A11yID.arenaPremiumAskPill
    var accessibilityHintText: String = "Abre conversa com o contexto desta tela"
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
            // Vidro no background do label — glassEffect.interactive no iOS 26
            // aplicado como modifier de conteúdo às vezes engole o identifier.
            .background { Capsule().fill(AtlasTheme.bgRecessed.opacity(0.01)) }
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
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(invite)
        .accessibilityHint(accessibilityHintText)
        .accessibilityIdentifier(accessibilityId)
    }
}

/// Compat: call sites antigos Arena/Autônomos.
typealias ArenaPremiumAskPill = AgenticPill
