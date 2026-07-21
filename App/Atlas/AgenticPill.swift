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
            // Soft impact: pílula is invitation, not commit.
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            action()
        }) {
            HStack(spacing: 12) {
                RootView.HomeComposerStar()
                Text(invite)
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 13)
            .frame(minHeight: 48) // HIG 44pt; breath room for Dynamic Type
            // Vidro no background do label — glassEffect.interactive no iOS 26
            // aplicado como modifier de conteúdo às vezes engole o identifier.
            .background { Capsule().fill(AtlasTheme.bgRecessed.opacity(0.01)) }
            .atlasGlassCapsule()
            .overlay(
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                AtlasTheme.accent.opacity(0.26),
                                AtlasTheme.accent.opacity(0.05),
                                AtlasTheme.accent.opacity(0.14)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.75
                    )
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(invite))
        .accessibilityHint(Text(accessibilityHintText))
        .accessibilityIdentifier(accessibilityId)
        .accessibilityAddTraits(.isButton)
    }
}

/// Compat: call sites antigos Arena/Autônomos.
typealias ArenaPremiumAskPill = AgenticPill
