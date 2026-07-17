import SwiftUI
import AtlasCore

// Pílula de pergunta — peel de AtlasCodeView+Graph (régua ~160).

extension AtlasCodeView {
    /// Lei 7: a pílula nunca some — nem aqui. E agora ela responde.
    var askPill: some View {
        HStack(spacing: 9) {
            Text("✦")
                .font(AtlasFont.serif(13))
                .foregroundStyle(AtlasTheme.accent)
            Text(anchorLegend ?? "pergunte sobre este repositório")
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(anchorLegend != nil ? AtlasTheme.textSecondary : AtlasTheme.textTertiary)
                .lineLimit(1)
                .accessibilityIdentifier(A11yID.codeAskAnchorNote)
            Spacer(minLength: 0)
            if askModel.isAnchoring {
                Button { askModel.clear() } label: {
                    Text("mostrar tudo")
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(A11yID.codeAskClear)
            }
            Image(systemName: "chevron.up")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(AtlasTheme.separator, lineWidth: 0.5))
        .contentShape(Capsule())
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            askDraft = ""
            showsAskCard = true
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.bottom, 10)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Conversar com o Atlas sobre este repositório")
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier(A11yID.codeAskPill)
    }
}
